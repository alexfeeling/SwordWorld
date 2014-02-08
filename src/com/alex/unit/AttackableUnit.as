package com.alex.unit 
{
	import com.alex.component.PhysicsComponent;
	import com.alex.constant.ForceDirection;
	import com.alex.skill.SkillData;
	import com.alex.unit.BaseUnit;
	import com.alex.util.Cube;
	import com.alex.worldmap.Position;
	import com.alex.worldmap.WorldMap;
	import flash.display.DisplayObject;
	import flash.geom.Rectangle;
	import flash.geom.Vector3D;
	import flash.utils.Dictionary;
	/**
	 * ...
	 * @author alex
	 */
	public class AttackableUnit extends BaseUnit implements IAttackable
	{
		/**
		 * 攻击目标
		 */
		private var _attackTarget:AttackableUnit;
		private var _enemyTarget:AttackableUnit;
		/**
		 * 攻击区块
		 */
		private var _attackCube:Cube;
		
		///视线范围
		private var _rangeOfVision:Rectangle;
		
		private var _currentSkillData:SkillData;
		
		private var _allSkillDic:Dictionary;
		
		public function AttackableUnit() 
		{
			
		}
		
		public function startAttack(vSkillName:String):void {
			_currentSkillData = _allSkillDic[vSkillName] as SkillData;
			if (!_currentSkillData) {
				//无此技能
				return;
			}
			for each (var target:AttackableUnit in searchTarget(_currentSkillData.maxImpactNum)) {
				target.receiveAttackNotice(this);
			}
		}
		
		/* INTERFACE com.alex.display.IAttackable */
		
		public function receiveAttackNotice(vAttacker:AttackableUnit):void 
		{
			if (this._physicsComponent.faceDirection == this._position.compareX(vAttacker.position)) {
				//攻击者在我面对的方向
				
			}
		}
		
		/**
		 * 接收攻击
		 * @param	vAttacker 攻击者
		 * @param	vSkillData 技能数据
		 */
		public function receiveAttackHurt(vAttacker:AttackableUnit, vSkillData:SkillData):void 
		{
			
		}
		
		///查找攻击目标
		private function searchTarget(maxTargetNum:int = 1):Vector.<AttackableUnit> {
			var detectList:Array;
			if (this.physicsComponent.faceDirection == -1) {
				detectList = [
								WorldMap.getInstance().getGridItemDic(position.gridX, position.gridY),
								WorldMap.getInstance().getGridItemDic(position.gridX, position.gridY - 1),
								WorldMap.getInstance().getGridItemDic(position.gridX, position.gridY + 1),
								WorldMap.getInstance().getGridItemDic(position.gridX - 1, position.gridY),
								WorldMap.getInstance().getGridItemDic(position.gridX - 1, position.gridY - 1),
								WorldMap.getInstance().getGridItemDic(position.gridX - 1, position.gridY + 1),
								WorldMap.getInstance().getGridItemDic(position.gridX - 2, position.gridY),
								WorldMap.getInstance().getGridItemDic(position.gridX - 2, position.gridY - 1),
								WorldMap.getInstance().getGridItemDic(position.gridX - 2, position.gridY + 1)
							];
			} else if (this.physicsComponent.faceDirection == 1) {
				detectList = [
								WorldMap.getInstance().getGridItemDic(position.gridX, position.gridY),
								WorldMap.getInstance().getGridItemDic(position.gridX, position.gridY - 1),
								WorldMap.getInstance().getGridItemDic(position.gridX, position.gridY + 1),
								WorldMap.getInstance().getGridItemDic(position.gridX + 1, position.gridY),
								WorldMap.getInstance().getGridItemDic(position.gridX + 1, position.gridY - 1),
								WorldMap.getInstance().getGridItemDic(position.gridX + 1, position.gridY + 1),
								WorldMap.getInstance().getGridItemDic(position.gridX + 2, position.gridY),
								WorldMap.getInstance().getGridItemDic(position.gridX + 2, position.gridY - 1),
								WorldMap.getInstance().getGridItemDic(position.gridX + 2, position.gridY + 1)
							];
			} else {
				throw "faceDirection error";
			}
			var targetList:Vector.<AttackableUnit> = new Vector.<AttackableUnit>();
			for (var i:int = 0; i < detectList.length; i++) {
				var gridItemDic:Dictionary = detectList[i] as Dictionary;
				if (!gridItemDic) {
					continue;
				}
				for each (var detectTarget:AttackableUnit in gridItemDic) {
					if (!detectTarget) {
						continue;
					}
					if (_attackCube.intersects(detectTarget.toCube())) {
						targetList.push(detectTarget);
						if (--maxTargetNum <= 0) {
							return targetList;
						}
					}
				}
			}
			return targetList;
		}
		
		public function toCube():Cube {
			return new Cube(position.globalX, position.globalY, position.elevation, physicsComponent.length, physicsComponent.width, physicsComponent.height);
		}
		
		public function attackHurt():void {
			for each(var target:AttackableUnit in searchTarget(99)) {
				target.receiveAttackHurt(this, _currentSkillData);
			}
			
		}
		
		public function attackEnd():void {
			this._attackTarget = null;
		}
		
		override public function release():void 
		{
			super.release();
			this._attackCube = null;
			this._attackTarget = null;
			this._rangeOfVision = null;
		}
		
	}

}