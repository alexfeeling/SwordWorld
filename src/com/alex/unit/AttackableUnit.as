package com.alex.unit
{
	import com.alex.animation.AnimationManager;
	import com.alex.animation.AttributeAnimation;
	import com.alex.component.AttributeComponent;
	import com.alex.component.PhysicsComponent;
	import com.alex.constant.MoveDirection;
	import com.alex.constant.OrderConst;
	import com.alex.constant.PhysicsType;
	import com.alex.display.IAttribute;
	import com.alex.display.IPhysics;
	import com.alex.skill.SkillData;
	import com.alex.unit.BaseUnit;
	import com.alex.util.Cube;
	import com.alex.worldmap.Position;
	import com.alex.worldmap.WorldMap;
	import flash.display.DisplayObject;
	import flash.display.Shape;
	import flash.geom.Rectangle;
	import flash.geom.Vector3D;
	import flash.utils.Dictionary;
	
	/**
	 * ...
	 * @author alex
	 */
	public class AttackableUnit extends BaseUnit implements IAttackable, IAttribute
	{
		/**
		 * 攻击目标
		 */
		//private var _attackTarget:AttackableUnit;
		private var _enemyTarget:AttackableUnit;
		/**
		 * 攻击区块
		 */
		private var _attackCube:Cube;
		
		///视线范围
		private var _rangeOfVision:Rectangle;
		
		private var _currentSkillData:SkillData;
		
		private var _allSkillDic:Dictionary;
		
		private var _attributeComponent:AttributeComponent;
		
		///是否正在死亡
		protected var _isDying:Boolean = false;
		
		public function AttackableUnit()
		{
			
		}
		
		protected function refreshAttribute(attributeComponent:AttributeComponent):void
		{
			this._attributeComponent = attributeComponent;
			_allSkillDic = new Dictionary();
			_allSkillDic["刺"] = [null, null, null, { type:"hurt", lifeHurt:50, xImpact: -30, zImpact:40 }, null, null, { type:"hurt", lifeHurt:50, xImpact:100, yImpact:50, zImpact: -40 }, null, null, { type:"end" } ];
			_allSkillDic["南剑诀"] = [null, null, null, { type:"distance", distanceId:"d1", lifeHurt:30, xImpact: 50, zImpact:20 }, null, null, { type:"distance", distanceId:"d1", lifeHurt:30, xImpact: -100, zImpact: -40 }, null, null, { type:"end" } ];
		}
		
		public function startAttack(vSkillName:String):void
		{
			//trace(vSkillName);
			if (this._isDying || _currentSkillData)
			{
				return;
			}
			_currentSkillData = new SkillData(this, _allSkillDic[vSkillName]);
			if (!_currentSkillData)
			{
				//无此技能
				return;
			}
			_attackCube = _currentSkillData.getAttackCube();
			for each (var target:AttackableUnit in searchTarget(_currentSkillData.maxImpactNum))
			{
				target.receiveAttackNotice(this);
			}
		}
		
		/* INTERFACE com.alex.display.IAttackable */
		
		public function receiveAttackNotice(vAttacker:AttackableUnit):void
		{
			if (this._isDying)
			{
				return;
			}
			if (this._physicsComponent.faceDirection == this._position.compareX(vAttacker.position))
			{
				//攻击者在我面对的方向
				
			}
		
		}
		
		/**
		 * 接收攻击
		 * @param	vAttacker 攻击者
		 * @param	vSkillData 技能数据
		 */
		public function receiveAttackHurt(attacker:AttackableUnit, hurtObj:Object):void
		{
			if (!this._isDying && hurtObj.lifeHurt)
			{
				this._attributeComponent.life -= hurtObj.lifeHurt;
			}
			if (hurtObj.xImpact)
			{
				this._physicsComponent.forceImpact(attacker.physicsComponent.faceDirection == 1?MoveDirection.X_RIGHT:MoveDirection.X_LEFT, 
					hurtObj.xImpact, true);
			}
			if (hurtObj.yImpact)
			{
				if (hurtObj.yImpact > 0)
				{
					this._physicsComponent.forceImpact(MoveDirection.Y_DOWN, hurtObj.yImpact, true);
				} else {
					this._physicsComponent.forceImpact(MoveDirection.Y_UP, hurtObj.yImpact, true);
				}
			}
			if (hurtObj.zImpact)
			{
				this._physicsComponent.forceImpact(MoveDirection.Z_TOP, hurtObj.zImpact, true);
			}
			//this.toDisplayObject().alpha = 0.5;
		}
		
		///查找攻击目标
		private function searchTarget(maxTargetNum:int = 1):Vector.<AttackableUnit>
		{
			var detectList:Array;
			if (this.physicsComponent.faceDirection == -1)
			{
				detectList = [WorldMap.getInstance().getGridItemDic(position.gridX, position.gridY), WorldMap.getInstance().getGridItemDic(position.gridX, position.gridY - 1), WorldMap.getInstance().getGridItemDic(position.gridX, position.gridY + 1), WorldMap.getInstance().getGridItemDic(position.gridX - 1, position.gridY), WorldMap.getInstance().getGridItemDic(position.gridX - 1, position.gridY - 1), WorldMap.getInstance().getGridItemDic(position.gridX - 1, position.gridY + 1), WorldMap.getInstance().getGridItemDic(position.gridX - 2, position.gridY), WorldMap.getInstance().getGridItemDic(position.gridX - 2, position.gridY - 1), WorldMap.getInstance().getGridItemDic(position.gridX - 2, position.gridY + 1)];
			}
			else if (this.physicsComponent.faceDirection == 1)
			{
				detectList = [WorldMap.getInstance().getGridItemDic(position.gridX, position.gridY), WorldMap.getInstance().getGridItemDic(position.gridX, position.gridY - 1), WorldMap.getInstance().getGridItemDic(position.gridX, position.gridY + 1), WorldMap.getInstance().getGridItemDic(position.gridX + 1, position.gridY), WorldMap.getInstance().getGridItemDic(position.gridX + 1, position.gridY - 1), WorldMap.getInstance().getGridItemDic(position.gridX + 1, position.gridY + 1), WorldMap.getInstance().getGridItemDic(position.gridX + 2, position.gridY), WorldMap.getInstance().getGridItemDic(position.gridX + 2, position.gridY - 1), WorldMap.getInstance().getGridItemDic(position.gridX + 2, position.gridY + 1)];
			}
			else
			{
				throw "faceDirection error";
			}
			var targetList:Vector.<AttackableUnit> = new Vector.<AttackableUnit>();
			for (var i:int = 0; i < detectList.length; i++)
			{
				var gridItemDic:Dictionary = detectList[i] as Dictionary;
				if (!gridItemDic)
				{
					continue;
				}
				for each (var detectTarget:IPhysics in gridItemDic)
				{
					if (!detectTarget || detectTarget==this || detectTarget.physicsComponent.physicsType != PhysicsType.SOLID)
					{
						continue;
					}
					if (_attackCube.intersects(detectTarget.physicsComponent.toCube()))
					{
						targetList.push(detectTarget);
						if (--maxTargetNum <= 0)
						{
							return targetList;
						}
					}
				}
			}
			return targetList;
		}
		
		public function attackHurt(hurtObj:Object, attackCube:Cube = null):void
		{
			if (attackCube)
			{
				this._attackCube = attackCube;
			}
			for each (var target:AttackableUnit in searchTarget(_currentSkillData.maxImpactNum))
			{
				target.receiveAttackHurt(this, hurtObj);
			}
			
		}
		
		public function attackEnd():void
		{
			//this._attackTarget = null;
			this._attackCube = null;
			this._currentSkillData = null;
		}
		
		override public function release():void
		{
			super.release();
			this._attackCube = null;
			this._currentSkillData = null;
			//this._attackTarget = null;
			this._rangeOfVision = null;
			this._isDying = false;
			this._allSkillDic = null;
		}
		
		/* INTERFACE com.alex.display.IAttribute */
		
		public function get attributeComponent():AttributeComponent
		{
			return _attributeComponent;
		}
		
		override public function getExecuteOrderList():Array
		{
			return super.getExecuteOrderList().concat(OrderConst.DIED_COMPLETE);
		}
		
		override public function executeOrder(orderName:String, orderParam:Object = null):void
		{
			switch (orderName)
			{
				case OrderConst.LIFE_EMPTY: 
					this._isDying = true;
					AnimationManager.addToAnimationList(new AttributeAnimation(this, {alpha: 0}, 5000, OrderConst.DIED_COMPLETE, null, this));
					break;
				case OrderConst.DIED_COMPLETE: 
					this.release();
					break;
				default: 
					super.executeOrder(orderName, orderParam);
			}
		}
		
		override public function gotoNextFrame(passedTime:Number):void 
		{
			super.gotoNextFrame(passedTime);
			if (this._currentSkillData) 
			{
				this._currentSkillData.run(passedTime);
			}
		}
	
	}

}