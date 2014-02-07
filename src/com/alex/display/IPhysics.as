package com.alex.display 
{
	import com.alex.component.PhysicsComponent;
	import com.alex.pool.IRecycle;
	import com.alex.worldmap.Position;
	
	/**
	 * 拥有物理特性的对象接口
	 * @author alex
	 */
	public interface IPhysics extends IRecycle
	{
		
		function get position():Position;
		
		//function set position(value:Position):void;
		
		function get id():String;
		
		///物理组件
		function get physicsComponent():PhysicsComponent;
		
		function refreshItemXY():void;
		
		//function onHit():void;
	}
	
}