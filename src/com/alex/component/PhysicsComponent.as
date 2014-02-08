package com.alex.component 
{
	import com.alex.constant.OrderConst;
	import com.alex.constant.ForceDirection;
	import com.alex.constant.ItemType;
	import com.alex.display.BasePhysicsItem;
	import com.alex.display.IDisplay;
	import com.alex.display.IPhysics;
	import com.alex.display.Tree;
	import com.alex.pattern.Commander;
	import com.alex.pattern.IOrderExecutor;
	import com.alex.pool.InstancePool;
	import com.alex.pool.IRecycle;
	import com.alex.role.MainRole;
	import com.alex.skill.Skill;
	import com.alex.util.IdMachine;
	import com.alex.worldmap.Position;
	import com.alex.worldmap.WorldMap;
	import flash.display.DisplayObject;
	import flash.geom.Point;
	import flash.utils.getTimer;
	/**
	 * 物理组件，代表显示对象在地图世界中的实体表示。长宽高，位置，
	 * @author alex
	 */
	public class PhysicsComponent implements IOrderExecutor, IRecycle
	{
		
		public static const GRAVITY:Number = 9.8 * 1.7;
		
		///显示对象，拥有本移动组件的对象
		private var _displayObj:IDisplay;
		
		private var _length:Number = 0;
		private var _width:Number = 0;
		private var _height:Number = 0;
		
		private var _position:Position;
		
		private var _isMoveLeft:Boolean = false;
		private var _isMoveRight:Boolean = false;
		private var _isMoveUp:Boolean = false;
		private var _isMoveDown:Boolean = false;
		
		private var _xRunSpeed:Number;
		private var _yRunSpeed:Number;
		
		///物理类型
		private var _physicsType:int;
		
		///质量
		private var _mass:Number = 0;
		
		///x轴方向上的速度，负数为左，正数为右，0为停止
		private var _xVelocity:Number = 0;
		
		///y轴方向上的速度，负数为上，正数为下，0为停止
		private var _yVelocity:Number = 0;
		
		///z轴方向上的速度，负数为垂直向下，正数为垂直向上，0为停止
		private var _zVelocity:Number = 0;
		
		///摩擦系数
		private var _friction:Number = 0;
		
		///是否是自控状态
		private var _isSelfControl:Boolean = true;
		
		private var _isRelease:Boolean = false;
		
		private var _id:String;
		
		public var isStandOnSomething:Boolean = true;
		///被站立之上的对象
		public var standOnItem:IPhysics;
		
		///面向方向：1是向右，-1是向左
		private var _faceDirection:int = 1;
		
		public function PhysicsComponent() 
		{
			
		}
		
		public function init(vDisplay:IDisplay, vPosition:Position, vSpeed:Number, vLength:Number, vWidth:Number, vHeight:Number, vMass:Number, vPhysicsType:int):PhysicsComponent {
			this._isRelease = false;
			this._id = IdMachine.getId(PhysicsComponent);
			
			this._displayObj = vDisplay;
			this._position = vPosition;
			
			this._length = vLength;
			this._width = vWidth;
			this._height = vHeight;
			
			this._xRunSpeed = vSpeed;
			this._yRunSpeed = vSpeed * 0.7;
			
			this._mass = vMass;
			
			this._friction = 0.3;
			
			this._isSelfControl = true;
			
			this._physicsType = vPhysicsType;
			
			this.isStandOnSomething = true;
			
			Commander.registerExecutor(this);
			
			return this;
		}
		
		///开始移动
		///direction:0左，1右，2上，3下
		public function startMove(direction:int):void {
			if (!this._isSelfControl) {
				return;
			}
			switch(direction) {
				case ForceDirection.X_LEFT:
					this._isMoveLeft = true;
					this._isMoveRight = false;
					this.faceDirection = -1;
					if (this._position.elevation > 0 && 
						_physicsType == ItemType.SOLID) 
					{
						return;
					}
					if (this._isMoveUp) {
						this._yVelocity = -this._yRunSpeed * 0.7;
						this._xVelocity = -this._xRunSpeed * 0.7;
					} else if (this._isMoveDown) {
						this._yVelocity = this._yRunSpeed * 0.7;
						this._xVelocity = -this._xRunSpeed * 0.7;
					} else {
						this._xVelocity = -this._xRunSpeed;
					}
					break;
				case ForceDirection.X_RIGHT:
					this._isMoveRight = true;
					this._isMoveLeft = false;
					this.faceDirection = 1;
					if (this._position.elevation > 0 && 
						_physicsType == ItemType.SOLID) 
					{
						return;
					}
					if (this._isMoveUp) {
						this._yVelocity = -this._yRunSpeed * 0.7;
						this._xVelocity = this._xRunSpeed * 0.7;
					} else if (this._isMoveDown) {
						this._yVelocity = this._yRunSpeed * 0.7;
						this._xVelocity = this._xRunSpeed * 0.7;
					} else {
						this._xVelocity = this._xRunSpeed;
					}
					break;
				case 2:
					this._isMoveUp = true;
					this._isMoveDown = false;
					if (this._position.elevation > 0 && 
						_physicsType == ItemType.SOLID) 
					{
						return;
					}
					if (this._isMoveLeft) {
						this._xVelocity = -this._xRunSpeed * 0.7;
						this._yVelocity = -this._yRunSpeed * 0.7;
					} else if (this._isMoveRight) {
						this._xVelocity = this._xRunSpeed * 0.7;
						this._yVelocity = -this._yRunSpeed * 0.7;
					} else {
						this._yVelocity = -this._yRunSpeed;
					}
					break;
				case 3:
					this._isMoveDown = true;
					this._isMoveUp = false;
					if (this._position.elevation > 0 && 
						_physicsType == ItemType.SOLID) 
					{
						return;
					}
					if (this._isMoveLeft) {
						this._xVelocity = -this._xRunSpeed * 0.7;
						this._yVelocity = this._yRunSpeed * 0.7;
					} else if (this._isMoveRight) {
						this._xVelocity = this._xRunSpeed * 0.7;
						this._yVelocity = this._yRunSpeed * 0.7;
					} else {
						this._yVelocity = this._yRunSpeed;
					}
					break;
			}
		}
		
		///停止方向移动
		///direction:0左，1右，2上，3下
		public function stopMove(direction:int):void {
			if (!this._isSelfControl) {
				return;
			}
			switch(direction) {
				case ForceDirection.X_LEFT:
					this._isMoveLeft = false;
					if (!this._isMoveRight && this._position.elevation <= 0) {
						this._xVelocity = 0;
						if (_isMoveDown) {
							this._yVelocity = _yRunSpeed;
						} else if (_isMoveUp) {
							this._yVelocity = -_yRunSpeed;
						}
					}
					break;
				case ForceDirection.X_RIGHT:
					this._isMoveRight = false;
					if (!this._isMoveLeft && this._position.elevation <= 0) {
						this._xVelocity = 0;
						if (_isMoveDown) {
							this._yVelocity = _yRunSpeed;
						} else if (_isMoveUp) {
							this._yVelocity = -_yRunSpeed;
						}
					}
					break;
				case ForceDirection.Y_UP:
					this._isMoveUp = false;
					if (!this._isMoveDown && this._position.elevation <= 0) {
						this._yVelocity = 0;
						if (_isMoveLeft) {
							this._xVelocity = -_xRunSpeed;
						} else if (_isMoveRight) {
							this._xVelocity = _xRunSpeed;
						}
					}
					break;
				case ForceDirection.Y_DOWN:
					this._isMoveDown = false;
					if (!this._isMoveUp && this._position.elevation <= 0) {
						this._yVelocity = 0;
						if (_isMoveLeft) {
							this._xVelocity = -_xRunSpeed;
						} else if (_isMoveRight) {
							this._xVelocity = _xRunSpeed;
						}
					}
					break;
			}
		}
		
		///强制停止移动
		public function forceStopMove():void {
			this._isMoveLeft = false;
			this._isMoveRight = false;
			this._isMoveUp = false;
			this._isMoveDown = false;
			this._xVelocity = 0;
			this._yVelocity = 0;
		}
		
		public function forceStopZ():void {
			this._zVelocity = 0;
		}
		
		public function forceImpact(vDir:int, vVelocity:Number, isLoseControll:Boolean = false):void {
			if (isNaN(vVelocity)) {
				return;
			}
			this._isSelfControl = this._isSelfControl && !isLoseControll;
			//if (this._displayObj is Skill && !this._isSelfControl) {
				//return;
			//}
			switch(vDir) {
				case ForceDirection.X_LEFT:
					this._xVelocity -= vVelocity;
					break;
				case ForceDirection.X_RIGHT:
					this._xVelocity += vVelocity;
					break;
				case ForceDirection.Y_UP:
					this._yVelocity -= vVelocity;
					break;
				case ForceDirection.Y_DOWN:
					this._yVelocity += vVelocity;
					break;
				case ForceDirection.Z_BOTTOM:
					this._zVelocity -= vVelocity;
					break;
				case ForceDirection.Z_TOP:
					this._zVelocity += vVelocity;
					break;
			}
		}
		
		public function get xEnergy():Number {
			if (this._xVelocity >= 0) {
				return 0.5 * this._mass * Math.pow(this._xVelocity, 2);
			} else {
				return -0.5 * this._mass * Math.pow(this._xVelocity, 2);
			}
		}
		
		public function get yEnergy():Number {
			if (this._yVelocity >= 0) {
				return 0.5 * this._mass * Math.pow(this._yVelocity, 2);
			} else {
				return -0.5 * this._mass * Math.pow(this._yVelocity, 2);
			}
		}
		
		public function get zEnergy():Number {
			if (this._zVelocity >= 0) {
				return 0.5 * this._mass * Math.pow(this._zVelocity, 2);
			} else {
				return -0.5 * this._mass * Math.pow(this._zVelocity, 2);
			}
		}
		
		///获取质量
		public function get mass():Number 
		{
			return _mass;
		}
		
		///获取高度
		public function get height():Number 
		{
			return _height;
		}
		
		///获取宽度
		public function get width():Number 
		{
			return _width;
		}
		
		///获取长度
		public function get length():Number 
		{
			return _length;
		}
		
		public function get physicsType():int 
		{
			return _physicsType;
		}
		
		public function set physicsType(value:int):void 
		{
			_physicsType = value;
		}
		
		///面向方向：1是向右，-1是向左
		public function get faceDirection():int 
		{
			return _faceDirection;
		}
		
		public function set faceDirection(value:int):void 
		{
			if (value != _faceDirection) {
				_faceDirection = value;
				if (this._displayObj is IOrderExecutor) {
					(this._displayObj as IOrderExecutor).executeOrder(OrderConst.CHANGE_FACE_DIRECTION, this._faceDirection);
				}
			}
		}
		
		///运行移动，需要每帧运行
		public function run(passedTime:Number, isFocus:Boolean = false):void {
			if (!(this._displayObj is MainRole)) {
				//不在屏幕内的不更新
				var disObj:DisplayObject = this._displayObj.toDisplayObject();
				var pos:Point = disObj.parent.localToGlobal(new Point(disObj.x, disObj.y));
				if (pos.x < -disObj.width || pos.x > WorldMap.STAGE_WIDTH + disObj.width ||
					pos.y < -disObj.height || pos.y > WorldMap.STAGE_HEIGHT + disObj.height)
				{
					return;
				}
			}
			var tempTime:Number = passedTime / 100;
			//=============垂直方向运动=============
			this._moveOnZ(passedTime, tempTime, isFocus);
			if (this._isRelease) {
				return;
			}
			this._displayObj.refreshElevation();
			//=======================================
			
			this._moveOnX(passedTime, tempTime, isFocus);
			if (this._isRelease) {//执行完移动有可能已经释放
				return;
			}
			this._moveOnY(passedTime, tempTime, isFocus);
			if (this._isRelease) {//执行完移动有可能已经释放
				return;
			}
			if (!this._isSelfControl && this._xVelocity == 0 && this._yVelocity == 0) {
				this._isSelfControl = true;
			}
		}
		
		private function _moveOnX(passedTime:Number, tempTime:Number, isFocus:Boolean):void {
			if (!this._isSelfControl && this._position.elevation == 0) {
				var a:Number = this._friction * GRAVITY;
			} else {
				a = 0;
			}
			if (this._xVelocity > 0) {
				var distance:int = this._xVelocity * tempTime - 0.5 * a * Math.pow(tempTime, 2);
				if (a > 0) {
					this._xVelocity = Math.max(this._xVelocity - a * tempTime, 0);
				}
				if (distance > 0) {
					Commander.sendOrder(OrderConst.MAP_ITEM_MOVE, { display:this._displayObj, 
							direction:ForceDirection.X_RIGHT, distance:int(distance), isFocus:isFocus } );
				}
			} else if (this._xVelocity < 0) {
				distance = -this._xVelocity * tempTime - 0.5 * a * Math.pow(tempTime, 2);
				if (a > 0) {
					this._xVelocity = Math.min(this._xVelocity + a * tempTime, 0);
				}
				if (distance > 0) {
					Commander.sendOrder(OrderConst.MAP_ITEM_MOVE, { display:this._displayObj, 
							direction:ForceDirection.X_LEFT, distance:int(distance), isFocus:isFocus } );
				}
			} else {
				if (this._displayObj is Tree) {
					this._xVelocity = (Math.random() - 0.5) * 50;
					this._isSelfControl = false;
				}
			}
		}
		
		private function _moveOnY(passedTime:Number, tempTime:Number, isFocus:Boolean):void {
			if (!this._isSelfControl && this._position.elevation == 0) {
				var a:Number = this._friction * GRAVITY;
			} else {
				a = 0;
			}
			if (this._yVelocity > 0) {
				var distance:int = this._yVelocity * tempTime - 0.5 * a * Math.pow(tempTime, 2);
				if (a > 0) {
					this._yVelocity = Math.max(this._yVelocity - a * tempTime, 0);
				}
				if (distance > 0) {
					Commander.sendOrder(OrderConst.MAP_ITEM_MOVE, { display:this._displayObj, 
							direction:ForceDirection.Y_DOWN, distance:int(distance), isFocus:isFocus } );
				}
			} else if (this._yVelocity < 0) {
				distance = -this._yVelocity * tempTime - 0.5 * a * Math.pow(tempTime, 2);
				if (a > 0) {
					this._yVelocity = Math.min(this._yVelocity + a * tempTime, 0);
				}
				if (distance > 0) {
					Commander.sendOrder(OrderConst.MAP_ITEM_MOVE, { display:this._displayObj, 
							direction:ForceDirection.Y_UP, distance:int(distance), isFocus:isFocus } );
				}
			}else {
				if (this._displayObj is Tree) {
					this._isSelfControl = false;
					this._yVelocity = (Math.random() - 0.5) * 50;
				}
			}
		}
		
		private function _moveOnZ(passedTime:Number, tempTime:Number, isFocus:Boolean):void {
			if (this._position.elevation > 0) {
				var a:Number = GRAVITY;
			} else {
				a = 0;
			}
			if (this._zVelocity > 0) {
				var distance:Number = this._zVelocity * tempTime - 0.5 * a * tempTime * tempTime;
				this._zVelocity -= GRAVITY * passedTime/100;
				Commander.sendOrder(OrderConst.MAP_ITEM_MOVE, { display:this._displayObj, 
							direction:ForceDirection.Z_TOP, distance:int(distance), isFocus:isFocus } );
			} 
			else if (this._position.elevation > 0) {
				if (_physicsType == ItemType.SOLID) {
					distance = 0.5 * a * tempTime * tempTime - this._zVelocity * tempTime;
					this._zVelocity -= GRAVITY * passedTime/100;
					Commander.sendOrder(OrderConst.MAP_ITEM_MOVE, { display:this._displayObj, 
								direction:ForceDirection.Z_BOTTOM, distance:int(distance), isFocus:isFocus } );
				}
			} else {//碰到地面
				this._zVelocity = 0;
				this._position.elevation = 0;
				if (this._isSelfControl) {
					if ((_isMoveLeft || _isMoveRight) && (_isMoveUp || _isMoveDown)) {
						if (_isMoveRight) {
							_xVelocity = this._xRunSpeed * 0.7;
						} else {
							_xVelocity = -this._xRunSpeed * 0.7;
						}
						if (_isMoveDown) {
							_yVelocity = this._yRunSpeed * 0.7;
						} else {
							_yVelocity = -this._yRunSpeed * 0.7;
						}
					} else if (_isMoveLeft || _isMoveRight) {
						if (_isMoveRight) {
							_xVelocity = this._xRunSpeed;
						} else {
							_xVelocity = -this._xRunSpeed;
						}
					} else if (_isMoveUp || _isMoveDown) {
						if (_isMoveDown) {
							_yVelocity = this._yRunSpeed;
						} else {
							_yVelocity = -this._yRunSpeed;
						}
					} else {
						_xVelocity = 0;
						_yVelocity = 0;
					}
				}
				//if (this._displayObj is Tree) {
					//this.forceImpact(ForceDirection.Z_TOP, 100);
				//}
			}
		}
		
		/* INTERFACE com.alex.pattern.ICommandHandler */
		
		public function getExecuteOrderList():Array 
		{
			return [OrderConst.MAP_ITEM_FORCE_MOVE + this._displayObj.id];
		}
		
		public function executeOrder(commandName:String, commandParam:Object = null):void 
		{
			switch(commandName) {
				case OrderConst.MAP_ITEM_FORCE_MOVE + this._displayObj.id:
					var dir:int = commandParam.dir as int;
					var energy:Number = commandParam.energy as Number;
					var loseControll:Boolean = commandParam.loseControll as Boolean;
					this.forceImpact(dir, energy, loseControll);
					break;
			}
		}
		
		public function getExecutorId():String 
		{
			return this._id;
		}
		
		/* INTERFACE com.alex.pool.IRecycle */
		
		public function release():void 
		{
			Commander.cancelExecutor(this);
			InstancePool.recycle(this);
			this._isRelease = true;
			this._displayObj = null;
			this._position = null;
			this._friction = 0;
			this._xVelocity = 0;
			this._yVelocity = 0;
			this._zVelocity = 0;
			this._id = null;
			this.standOnItem = null;
		}
		
	}

}