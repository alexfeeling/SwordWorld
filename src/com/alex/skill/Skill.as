package com.alex.skill
{
	import com.alex.animation.AnimationManager;
	import com.alex.animation.IAnimation;
	import com.alex.component.PhysicsComponent;
	import com.alex.constant.OrderConst;
	import com.alex.constant.MoveDirection;
	import com.alex.constant.PhysicsType;
	import com.alex.display.IDisplay;
	import com.alex.display.IPhysics;
	import com.alex.pattern.Commander;
	import com.alex.pattern.IOrderExecutor;
	import com.alex.pool.InstancePool;
	import com.alex.pool.IRecycle;
	import com.alex.unit.AttackableUnit;
	import com.alex.unit.BaseUnit;
	import com.alex.unit.IAttackable;
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
		
		private var _name:String;
		
		public function Skill()
		{
		
		}
		
		protected function init(vName:String, vOwnner:AttackableUnit, vPosition:Position, vDir:int, vSpeed:Number, vWeight:Number = 0):Skill
		{
			refresh(IdMachine.getId(Skill), vPosition, PhysicsComponent.make(this, vPosition, vSpeed, 50, 50, 50, 10, PhysicsType.BUBBLE));
			this._name = vName;
			this._ownner = vOwnner;
			this._physicsComponent.startMove(vDir);
			this._lifeTime = 5000;
			return this;
		}
		
		public static function make(vName:String, vOwnner:AttackableUnit, vPosition:Position, vDir:int, vSpeed:int, vWeight:int):Skill
		{
			return Skill(InstancePool.getInstance(Skill)).init(vName, vOwnner, vPosition, vDir, vSpeed, vWeight);
		}
		
		override protected function createUI():void
		{
			super.createUI();
			var body:Shape = new Shape();
			body.y = -this.position.elevation; // this._elevation; 
			body.graphics.beginFill(0xff00ff, 0.2);
			//body.graphics.drawRect( -25, - 50, 50, 50);
			body.graphics.drawRect(-MapBlock.GRID_WIDTH / 2, -MapBlock.GRID_HEIGHT, MapBlock.GRID_WIDTH, MapBlock.GRID_HEIGHT);
			body.graphics.endFill();
			this._body.addChild(body);
		}
		
		public function getHitEnergy():Number
		{
			return 50;
		}
		
		///碰撞
		override public function collide(unit:IPhysics, moveDir:int):Boolean
		{
			if (unit == null || unit.physicsComponent.physicsType != PhysicsType.SOLID)
			{
				return false;
			}
			unit.physicsComponent.forceImpact(MoveDirection.Z_TOP, this.getHitEnergy());
			if (unit is IAttackable)
			{
				(unit as IAttackable).receiveAttackHurt(this.ownner, this._skillData);
			}
			this.release();
			return true;
		}
		
		override public function canCollide(unit:IPhysics):Boolean
		{
			return super.canCollide(unit) && unit != this.ownner;
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
			if (this._isRelease)
			{
				return;
			}
			super.gotoNextFrame(passedTime);
			if (this._isRelease)
			{
				return;
			}
			this._lifeTime -= passedTime;
			if (this._lifeTime <= 0)
			{
				this.release();
			}
		}
		
		public function get ownner():AttackableUnit
		{
			return _ownner;
		}
	
	}

}