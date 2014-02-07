package com.alex.display 
{
	import com.alex.component.PhysicsComponent;
	import com.alex.constant.OrderConst;
	import com.alex.constant.ItemType;
	import com.alex.pattern.Commander;
	import com.alex.pattern.IOrderExecutor;
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
	public class BasePhysicsItem extends Sprite implements IDisplay, IOrderExecutor
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
			Commander.sendOrder(OrderConst.REMOVE_ITEM_FROM_WORLD_MAP, this);
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
		
		public function getExecuteOrderList():Array 
		{
			return [
						OrderConst.SET_FACE_DIRECTION
					];
		}
		
		public function executeOrder(commandName:String, commandParam:Object = null):void 
		{
			switch(commandName) {
				case OrderConst.SET_FACE_DIRECTION:
					if (commandParam == 1 || commandParam == -1) {
						this._body.scaleX = commandParam as int;
					}
					break;
			}
		}
		
		public function getExecutorId():String 
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