package com.alex.display 
{
	import com.alex.component.PhysicsComponent;
	import com.alex.constant.CommandConst;
	import com.alex.constant.ItemType;
	import com.alex.pattern.Commander;
	import com.alex.pattern.ICommandHandler;
	import com.alex.pool.InstancePool;
	import com.alex.util.IdMachine;
	import com.alex.worldmap.MapBlock;
	import com.alex.worldmap.Position;
	import flash.display.DisplayObject;
	import flash.display.Shape;
	import flash.display.Sprite;
	
	/**
	 * ...
	 * @author alex
	 */
	public class BasePhysicsItem extends Sprite implements IDisplay, ICommandHandler
	{
		
		protected var _physicsComponent:PhysicsComponent;
		protected var _position:Position;
		
		protected var _isRelease:Boolean = false;
		protected var _id:String;
		
		protected var _shadow:Shape;
		protected var _body:Sprite;
		
		public function BasePhysicsItem() 
		{
			
		}
		
		public function initBase(vPosition:Position, vPhysicsComponent:PhysicsComponent):BasePhysicsItem {
			this._position = vPosition;
			this._position.phycItem = this;
			this._physicsComponent = vPhysicsComponent;
			this._isRelease = false;
			Commander.registerHandler(this);
			_shadow = new Shape();
			_body = new Sprite();
			this.addChild(_shadow);
			this.addChild(_body);
			return this;
		}
		
		/* INTERFACE com.alex.display.IDisplay */
		
		public function toDisplayObject():DisplayObject 
		{
			return this;
		}
		
		public function refreshElevation():void 
		{
			
		}
		
		public function get physicsComponent():PhysicsComponent 
		{
			return _physicsComponent;
		}
		
		public function get position():Position 
		{
			return _position;
		}
		
		//public function set position(value:Position):void 
		//{
			//_position = value;
		//}
		
		public function get id():String 
		{
			return _id;
		}
		
		public function release():void 
		{
			if (this._isRelease) {
				throw "error";
			}
			Commander.sendCommand(CommandConst.REMOVE_ITEM_FROM_WORLD_MAP, this);
			Commander.cancelHandler(this);
			this._id = null;
			this._position.release();
			this._position = null;
			this._physicsComponent.release();
			this._physicsComponent = null;
			this._isRelease = true;
			InstancePool.recycle(this);
		}
		
		/* INTERFACE com.alex.pattern.ICommandHandler */
		
		public function getCommandList():Array 
		{
			return [
						CommandConst.ROLE_START_MOVE,
						CommandConst.ROLE_STOP_MOVE,
					];
		}
		
		public function handleCommand(commandName:String, commandParam:Object = null):void 
		{
			switch(commandName) {
				case CommandConst.ROLE_START_MOVE:
					this._physicsComponent.startMove(commandParam as int);
					if (commandParam == 0) {
						this._physicsComponent.faceDirection = -1;
					} else if (commandParam == 1) {
						this._physicsComponent.faceDirection = 1;
					}
					this._body.scaleX = this._physicsComponent.faceDirection;
					break;
				case CommandConst.ROLE_STOP_MOVE:
					this._physicsComponent.stopMove(int(commandParam));
					break;
			}
		}
		
		public function getHandlerId():String 
		{
			return this.id;
		}
		
		public function refreshItemXY():void {
			if (this.position == null) {
				return;
			}
			this.x = position.gridX * MapBlock.GRID_WIDTH + position.insideX;
			this.y = position.gridY * MapBlock.GRID_HEIGHT + position.insideY;
		}
	}

}