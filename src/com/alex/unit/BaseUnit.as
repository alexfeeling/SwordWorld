package com.alex.unit 
{
	import com.alex.animation.IAnimation;
	import com.alex.component.PhysicsComponent;
	import com.alex.display.IDisplay;
	import com.alex.pattern.IOrderExecutor;
	import com.alex.worldmap.Position;
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	
	/**
	 * ...
	 * @author alexfeeling
	 */
	public class BaseUnit implements IDisplay, IOrderExecutor, IAnimation
	{
		
		protected var _displayObject:Sprite;
		protected var _body:Sprite;
		protected var _shadow:Sprite;
		
		protected var _physicsComponent:PhysicsComponent;
		protected var _position:Position;
		protected var _id:String;
		
		public function BaseUnit() 
		{
			
		}
		
		public function refresh(vPosition:Position, vPhysicsComponent:PhysicsComponent):void {
			this._position = vPosition;
			this._physicsComponent = vPhysicsComponent;
		}
		
		private function createUI():void {
			this._displayObject = new Sprite();
			this._body = new Sprite();
			this._shadow = new Sprite();
			this._displayObject.addChild(_shadow);
			this._displayObject.addChild(_body);
		}
		
		/* INTERFACE com.alex.pattern.IOrderExecutor */
		
		public function getExecuteOrderList():Array 
		{
			
		}
		
		public function executeOrder(orderName:String, orderParam:Object = null):void 
		{
			
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
			
		}
		
		public function release():void 
		{
			
		}
		
		/* INTERFACE com.alex.animation.IAnimation */
		
		public function isPause():Boolean 
		{
			
		}
		
		public function isPlayEnd():Boolean 
		{
			
		}
		
		public function gotoNextFrame(passedTime:Number):void 
		{
			this._physicsComponent.run(passedTime);
		}
		
	}

}