package com.alex.unit
{
	import com.alex.animation.IAnimation;
	import com.alex.component.PhysicsComponent;
	import com.alex.constant.MoveDirection;
	import com.alex.constant.PhysicsType;
	import com.alex.constant.OrderConst;
	import com.alex.display.IDisplay;
	import com.alex.display.IPhysics;
	import com.alex.pattern.Commander;
	import com.alex.pattern.IOrderExecutor;
	import com.alex.pool.InstancePool;
	import com.alex.util.Cube;
	import com.alex.worldmap.MapBlock;
	import com.alex.worldmap.Position;
	import com.alex.worldmap.WorldMap;
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.utils.Dictionary;
	
	/**
	 * ...
	 * @author alexfeeling
	 */
	public class BaseUnit implements IDisplay, IAnimation
	{
		protected var _isRelease:Boolean;
		
		protected var _displayObject:Sprite;
		protected var _body:Sprite;
		protected var _shadow:Sprite;
		
		protected var _physicsComponent:PhysicsComponent;
		protected var _position:Position;
		protected var _id:String;
		
		public function BaseUnit()
		{
		
		}
		
		public function refresh(vId:String, vPosition:Position, vPhysicsComponent:PhysicsComponent):BaseUnit
		{
			this._isRelease = false;
			this._id = vId;
			this._position = vPosition;
			vPosition.phycItem = this;
			this._physicsComponent = vPhysicsComponent;
			this.createUI();
			Commander.registerExecutor(this);
			this.refreshDisplayXY();
			return this;
		}
		
		protected function createUI():void
		{
			this._displayObject = new Sprite();
			this._body = new Sprite();
			this._shadow = new Sprite();
			this._displayObject.addChild(_shadow);
			this._displayObject.addChild(_body);
		}
		
		/* INTERFACE com.alex.pattern.IOrderExecutor */
		
		public function getExecuteOrderList():Array
		{
			return [OrderConst.CHANGE_FACE_DIRECTION];
		}
		
		public function executeOrder(orderName:String, orderParam:Object = null):void
		{
			switch (orderName)
			{
				case OrderConst.CHANGE_FACE_DIRECTION: 
					if (orderParam == 1 || orderParam == -1)
					{
						this._body.scaleX = orderParam as int;
					}
					break;
				case OrderConst.MAP_ITEM_MOVE:
					this.move(orderParam[0], orderParam[1]);
					break;
			}
		}
		
		public function getExecutorId():String
		{
			return this._id;
		}
		
		/* INTERFACE com.alex.display.IDisplay */
		
		public function toDisplayObject():DisplayObject
		{
			return this._displayObject;
		}
		
		public function refreshElevation():void
		{
		
		}
		
		public function collide(unit:IPhysics, moveDir:int):Boolean
		{
			if (physicsComponent.physicsType == PhysicsType.SOLID && unit.physicsComponent.physicsType == PhysicsType.SOLID)
			{
				//刚体碰撞到刚体，停止移动，贴合
				position.nestleUpTo(moveDir, unit);
			}
			return false;
		}
		
		public function get position():Position
		{
			return _position;
		}
		
		public function get id():String
		{
			return _id;
		}
		
		public function get physicsComponent():PhysicsComponent
		{
			return _physicsComponent;
		}
		
		public function refreshDisplayXY():void
		{
			if (this._isRelease || this.position == null)
			{
				return;
			}
			this._displayObject.x = position.gridX * MapBlock.GRID_WIDTH + position.insideX;
			this._displayObject.y = position.gridY * MapBlock.GRID_HEIGHT + position.insideY;
		}
		
		public function release():void
		{
			if (this._isRelease)
			{
				throw "release error";
			}
			Commander.sendOrder(OrderConst.REMOVE_ITEM_FROM_WORLD_MAP, this);
			Commander.cancelExecutor(this);
			if (this._physicsComponent)
			{
				this._physicsComponent.release();
				this._physicsComponent = null;
			}
			if (this._position)
			{
				this._position.release();
				this._position = null;
			}
			this._body.removeChildren();
			this._shadow.removeChildren();
			this._displayObject.removeChildren();
			this._body = null;
			this._shadow = null;
			if (this._displayObject.parent)
			{
				this._displayObject.parent.removeChild(this._displayObject);
			}
			this._displayObject = null;
			this._id = null;
			this._isRelease = true;
			InstancePool.recycle(this);
		}
		
		/* INTERFACE com.alex.animation.IAnimation */
		
		public function isPause():Boolean
		{
			return false;
		}
		
		public function isPlayEnd():Boolean
		{
			return false;
		}
		
		public function gotoNextFrame(passedTime:Number):void
		{
			this._physicsComponent.run(passedTime);
		}
		
		private static var STEP:int = 20;
		
		///direction:0左，1右，2上，3下
		public function move(vDirection:int, vDistance:int):void
		{
			var tDistance:int = vDistance;
			var collidedUnit:IPhysics = null;
			var tempCollidedUnit:IPhysics = null;
			while (tDistance > 0)
			{
				tempCollidedUnit = f_itemMove(vDirection, Math.min(tDistance, STEP));
				tDistance -= STEP;
				if (tempCollidedUnit) {
					collidedUnit = tempCollidedUnit;
					break;
				}
			}
			this.refreshDisplayXY();
			if (vDirection == MoveDirection.Z_BOTTOM && collidedUnit) {
				this._physicsComponent.executeOrder(OrderConst.STAND_ON_UNIT, collidedUnit);
			} 
		}
		
		///单位移动,direction:0左，1右，2上，3下
		//0无碰撞 1碰撞 2释放 XXXX
		private function f_itemMove(direction:int, distance:int):IPhysics
		{
			//先移动相应距离
			_position.move(direction, distance);
			
			if (_physicsComponent.physicsType == PhysicsType.SOLID)
			{
				var unitList:Array = WorldMap.getInstance().getAroudItemsByMove(direction, _position);
			}
			else
			{
				unitList = WorldMap.getInstance().getAroudItems(_position);
			}
			
			var isHitUnit:Boolean = false;
			var collidedUnit:IPhysics = null;
			for (var i:int = 0; i < unitList.length; i++)
			{
				var unitDic:Dictionary = unitList[i] as Dictionary;
				if (unitDic == null)
				{
					continue;
				}
				for each (var tempUnit:IPhysics in unitDic)
				{
					if (this.canCollide(tempUnit))// && tempUnit.canCollide(this))
					{
						if (this._physicsComponent.toCube().intersects(tempUnit.physicsComponent.toCube()))
						{
							collidedUnit = tempUnit;
							if (this.collide(tempUnit, direction))
							{
								return collidedUnit;
							}
							//isHitUnit = true;
						}
					}
				}
			}
			//return isHitUnit;
			return collidedUnit;
		}
		
		public function canCollide(unit:IPhysics):Boolean
		{
			return this != unit && unit.physicsComponent.physicsType == PhysicsType.SOLID;
		}
	
	}

}