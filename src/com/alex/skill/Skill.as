package com.alex.skill 
{
	import com.alex.animation.AnimationManager;
	import com.alex.animation.IAnimation;
	import com.alex.component.PhysicsComponent;
	import com.alex.constant.OrderConst;
	import com.alex.constant.ForceDirection;
	import com.alex.constant.ItemType;
	import com.alex.display.BasePhysicsItem;
	import com.alex.display.IDisplay;
	import com.alex.display.IPhysics;
	import com.alex.pattern.Commander;
	import com.alex.pattern.IOrderExecutor;
	import com.alex.pool.InstancePool;
	import com.alex.pool.IRecycle;
	import com.alex.unit.AttackableUnit;
	import com.alex.unit.BaseUnit;
	import com.alex.util.IdMachine;
	import com.alex.worldmap.MapBlock;
	import com.alex.worldmap.Position;
	import com.alex.worldmap.WorldMap;
	import flash.display.DisplayObject;
	import flash.display.Shape;
	import flash.display.Sprite;
	/**
	 * ...
	 * @author alex
	 */
	public class Skill extends BaseUnit
	{
		
		private var _ownner:AttackableUnit;
		
		private var _lifeTime:Number = 0;
		
		private var _skillData:SkillData;
		
		public function Skill() 
		{
			
		}
		
		public function init(vName:String, vOwnner:AttackableUnit, vPosition:Position, 
				vDir:int, vSpeed:Number, vWeight:Number = 0):Skill 
		{
			refresh(IdMachine.getId(Skill), vPosition, InstancePool.getPhysicsComponent(this, vPosition, vSpeed, 50, 50, 50, 10, ItemType.BUBBLE));
			//this.name = vName;
			this._ownner = vOwnner;
			this._physicsComponent.startMove(vDir);
			this._lifeTime = 5000;
			return this;
		}
		
		override protected function createUI():void {
			super.createUI();
			var body:Shape = new Shape();
			body.y = - this.position.elevation;// this._elevation; 
			body.graphics.beginFill(0xff00ff, 0.2);
			//body.graphics.drawRect( -25, - 50, 50, 50);
			body.graphics.drawRect( -MapBlock.GRID_WIDTH/2, - MapBlock.GRID_HEIGHT, MapBlock.GRID_WIDTH, MapBlock.GRID_HEIGHT);
			body.graphics.endFill();
			this._body.addChild(body);
		}
		
		public function getHitEnergy():Number {
			return 100;
		}
		
		///碰撞
		public function collide(item:IPhysics):void {
			if (item == null || item.physicsComponent.physicsType != ItemType.SOLID) {
				return;
			}
			item.physicsComponent.forceImpact(ForceDirection.Z_TOP, this.getHitEnergy());
			this.release();
		}
		
		/* INTERFACE com.alex.display.IDisplay */
		override public function refreshElevation():void 
		{
			
		}
		
		override public function release():void 
		{
			super.release();
			this._ownner = null;
		}
		
		override public function gotoNextFrame(passedTime:Number):void 
		{
			if (this._isRelease) {
				return;
			}
			super.gotoNextFrame(passedTime);
			if (this._isRelease) {
				return;
			}
			this._lifeTime -= passedTime;
			if (this._lifeTime <= 0) {
				this.release();
			}
		}
		
		public function get ownner():AttackableUnit 
		{
			return _ownner;
		}
		
	}

}