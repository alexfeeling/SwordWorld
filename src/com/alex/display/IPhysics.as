package com.alex.display 
{
	import com.alex.component.PhysicsComponent;
	import com.alex.pattern.IOrderExecutor;
	import com.alex.pool.IRecycle;
	import com.alex.util.Cube;
	import com.alex.worldmap.Position;
	
	/**
	 * 拥有物理特性的对象接口
	 * @author alex
	 */
	public interface IPhysics extends IOrderExecutor, IRecycle
	{
		
		function get id():String;
		
		function get position():Position;
		
		///物理组件
		function get physicsComponent():PhysicsComponent;
		
		///能否碰撞此单位
		function canCollide(unit:IPhysics):Boolean;
		
	}
	
}