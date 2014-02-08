package com.alex.unit 
{
	import com.alex.animation.IAnimation;
	import com.alex.component.PhysicsComponent;
	import com.alex.constant.OrderConst;
	import com.alex.display.IDisplay;
	import com.alex.pattern.Commander;
	import com.alex.pattern.IOrderExecutor;
	import com.alex.pool.InstancePool;
	import com.alex.worldmap.MapBlock;
	import com.alex.worldmap.Position;
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	
	/**
	 * ...
	 * @author alexfeeling
	 */
	public class BaseUnit implements IDisplay, IOrderExecutor, IAnimation
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
		
		public function refresh(vId:String, vPosition:Position, vPhysicsComponent:PhysicsComponent):BaseUnit {
			this._isRelease = false;
			this._id = vId;
			this._position = vPosition;
			vPosition.phycItem = this;
			this._physicsComponent = vPhysicsComponent;
			this.createUI();
			Commander.registerExecutor(this);
			return this;
		}
		
		protected function createUI():void {
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
			switch(orderName) {
				case OrderConst.CHANGE_FACE_DIRECTION:
					if (orderParam == 1 || orderParam == -1) {
						this._body.scaleX = orderParam as int;
					}
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
		
		public function refreshItemXY():void 
		{
			if (this.position == null) {
				return;
			}
			this._displayObject.x = position.gridX * MapBlock.GRID_WIDTH + position.insideX;
			this._displayObject.y = position.gridY * MapBlock.GRID_HEIGHT + position.insideY;
		}
		
		public function release():void 
		{
			if (this._isRelease) {
				throw "release error";
			}
			Commander.sendOrder(OrderConst.REMOVE_ITEM_FROM_WORLD_MAP, this);
			Commander.cancelExecutor(this);
			if (this._position) {
				this._position.release();
				this._position = null;
			}
			if (this._physicsComponent) {
				this._physicsComponent.release();
				this._physicsComponent = null;
			}
			this._body.removeChildren();
			this._shadow.removeChildren();
			this._displayObject.removeChildren();
			this._body = null;
			this._shadow = null;
			if (this._displayObject.parent) {
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
		
	}

}