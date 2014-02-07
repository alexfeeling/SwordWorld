package com.alex.role 
{
	import com.alex.animation.AnimationManager;
	import com.alex.animation.IAnimation;
	import com.alex.component.PhysicsComponent;
	import com.alex.constant.CommandConst;
	import com.alex.constant.ForceDirection;
	import com.alex.constant.ItemType;
	import com.alex.display.BasePhysicsItem;
	import com.alex.display.IDisplay;
	import com.alex.pattern.Commander;
	import com.alex.pattern.ICommandHandler;
	import com.alex.pattern.ICommandSender;
	import com.alex.pool.InstancePool;
	import com.alex.pool.IRecycle;
	import com.alex.skill.Skill;
	import com.alex.util.IdMachine;
	import com.alex.worldmap.MapBlock;
	import com.alex.worldmap.Position;
	import com.alex.worldmap.WorldMap;
	import flash.display.Bitmap;
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.geom.Rectangle;
	import flash.utils.getDefinitionByName;
	
	/**
	 * ...
	 * @author alex
	 */
	public class MainRole extends BasePhysicsItem implements ICommandHandler, IAnimation
	{
		
		[Embed(source="/../bin/asset/role/run.swf", symbol="RoleRun")]
		public var RUN_CLASS:Class;
		
		private var _speed:Number = 25;
		
		///面向方向：1是向右，-1是向左
		//private var _faceDir:int = 1;
		
		private static var _instance:MainRole;
		
		public function MainRole() 
		{
			if (_instance) {
				throw "MainRole只能有一个对象";
			}
			_instance = this;
		}
		
		public static function getInstance():MainRole {
			return _instance;
		}
		
		public function init(vPosition:Position):MainRole {
			this._id = IdMachine.getId(MainRole);
			var phyc:PhysicsComponent = InstancePool.getPhysicsComponent(this, vPosition, this._speed, 80, 60, 100, 50, ItemType.SOLID);
			this.initBase(vPosition, phyc);
			this.createUI();
			return this;
		}
		
		private var run:MovieClip;
		private function createUI():void {
			_shadow.graphics.clear();
			_shadow.graphics.beginFill(0x0, 0.5);
			_shadow.graphics.drawRect( -MapBlock.GRID_WIDTH / 2, - MapBlock.GRID_HEIGHT / 2,
									MapBlock.GRID_WIDTH, MapBlock.GRID_HEIGHT);
			_shadow.graphics.endFill();
			_body = new Sprite();
			//_body.graphics.beginFill(0xffff00, 0.7);
			//_body.graphics.drawRect( -MapBlock.GRID_WIDTH / 2, -70, MapBlock.GRID_WIDTH, 70);
			//_body.graphics.endFill();
			run = new RUN_CLASS();
			//trace(run.width, run.height);
			//run.scaleX = 0.5;
			//run.scaleY = 0.5;
			//run.width = 100;
			//run.height = 100;
			//run.x = -run.width>>1;
			//run.y = -run.height;
			run.stop();
			_body.addChild(run);
			//var vc:Class = getDefinitionByName("RoleRun") as Class;
		}
		
	    override public function getCommandList():Array 
		{
			return super.getCommandList().concat([
													CommandConst.CREATE_SKILL,
													CommandConst.ROLE_JUMP
												]);
		}
		
		override public function handleCommand(commandName:String, commandParam:Object = null):void 
		{
			switch(commandName) {
				case CommandConst.CREATE_SKILL:
					var skillName:String = commandParam as String;
					if (skillName != null) {
						var sPosition:Position = this.position.copy();
						var skill:Skill = InstancePool.getSkill(skillName, this, sPosition, this._physicsComponent.faceDirection == 1?ForceDirection.X_RIGHT:ForceDirection.X_LEFT, 40, 10);
						Commander.sendCommand(CommandConst.ADD_ITEM_TO_WORLD_MAP, skill);
						//if (this._faceDir == 1) {
							//sPosition.insideX += 60;
						//} else if (this._faceDir == -1) {
							//sPosition.insideX -= 60;
						//} else {
							//break;
						//}
					}
					break;
				case CommandConst.ROLE_JUMP:
					if (this.position.elevation <= 0) {
						this._physicsComponent.forceImpact(ForceDirection.Z_TOP, 70);
					}
					break;
				default:
					super.handleCommand(commandName, commandParam);
			}
			
		}
		
		public function isPause():Boolean 
		{
			return false;
		}
		
		public function isPlayEnd():Boolean 
		{
			return false;
		}
		
		private var tempTime:Number = 0;
		private var fpsTime:Number = 1000 / 8;
		public function gotoNextFrame(passedTime:Number):void 
		{
			this._physicsComponent.run(passedTime, true);
			tempTime += passedTime;
			if (tempTime >= fpsTime) {
				tempTime-= fpsTime;
				if (run != null) {
					run.gotoAndStop((run.currentFrame + 1) % run.totalFrames);
				}
			}
		}
		
		/* INTERFACE com.alex.display.IDisplay */
		
		override public function refreshElevation():void 
		{
			var elevation:Number = Math.max(this._position.elevation, 0);
			this._body.y = -elevation;
		}
		
		/* INTERFACE com.alex.pool.IRecycle */
		override public function release():void 
		{
			super.release();
			if (this.parent != null) {
				this.parent.removeChild(this);
			}
			this.removeChildren(0);
			this._body = null;
			this._shadow = null;
			this._id = null;
			this._speed = 0;
		}
		
		
	}

}