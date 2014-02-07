package com.alex.display 
{
	import com.alex.constant.ForceDirection;
	import com.alex.worldmap.WorldMap;
	import flash.display.DisplayObject;
	import flash.geom.Rectangle;
	import flash.utils.Dictionary;
	/**
	 * ...
	 * @author alex
	 */
	public class AttackableItem extends BasePhysicsItem implements IAttackable
	{
		
		private var _attackTarget:AttackableItem;
		private var _attackArea:Rectangle;
		
		public function AttackableItem() 
		{
			
		}
		
		public function initAttack():void {
			this._attackTarget = null;
		}
		
		public function startAttack(vSkillName:String):void {
			this._attackTarget = searchTarget();
			
		}
		
		/* INTERFACE com.alex.display.IAttackable */
		
		public function receiveAttackNotice(vAttacker:AttackableItem):void 
		{
			if (this._physicsComponent.faceDirection == this._position.compareX(vAttacker.position)) {
				//我能看到攻击者
			}
		}
		
		private function searchTarget():IAttackable {
			var detectList:Array;
			if (this.physicsComponent.faceDirection == -1) {
				detectList = [
								this.getGridItemDic(vPosition.gridX - 1, vPosition.gridY),
								this.getGridItemDic(vPosition.gridX - 1, vPosition.gridY - 1),
								this.getGridItemDic(vPosition.gridX - 1, vPosition.gridY + 1),
								this.getGridItemDic(vPosition.gridX, vPosition.gridY),
								this.getGridItemDic(vPosition.gridX, vPosition.gridY - 1),
								this.getGridItemDic(vPosition.gridX, vPosition.gridY + 1)
							];
			} else if (this.physicsComponent.faceDirection == 1) {
				detectList = [
								this.getGridItemDic(vPosition.gridX + 1, vPosition.gridY),
								this.getGridItemDic(vPosition.gridX + 1, vPosition.gridY - 1),
								this.getGridItemDic(vPosition.gridX + 1, vPosition.gridY + 1),
								this.getGridItemDic(vPosition.gridX, vPosition.gridY),
								this.getGridItemDic(vPosition.gridX, vPosition.gridY - 1),
								this.getGridItemDic(vPosition.gridX, vPosition.gridY + 1)
							];
			} else {
				throw "faceDirection error";
			}
			for (var i:int = 0; i < detectList.length; i++) {
				var gridItemDic:Dictionary = detectList[i] as Dictionary;
				if (!gridItemDic) {
					continue;
				}
				for each (var attackTarget:IAttackable in gridItemDic) {
					if (!attackTarget) {
						continue;
					}
					
				}
			}
			return null;
		}
		
		public function attackHurt():void {
			this._attackTarget = searchTarget();
		}
		
		public function attackEnd():void {
			this._attackTarget = null;
		}
		
		override public function release():void 
		{
			super.release();
			this._attackTarget = null;
		}
		
	}

}