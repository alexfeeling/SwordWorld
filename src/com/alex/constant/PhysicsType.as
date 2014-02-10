package com.alex.constant 
{
	/**
	 * ...
	 * @author alex
	 */
	public class PhysicsType 
	{
		
		public function PhysicsType() 
		{
			throw "PhysicsType can't create a instance.";
		}

		///刚体，刚体与刚体间无法穿越
		public static const SOLID:int = 0;
		
		///虚体，虚体与所有体都可以穿越
		public static const VIRTUAL:int = 1;
		
		///泡沫体，泡沫体与所有体都可穿越，但是一碰撞就是被销毁
		public static const BUBBLE:int = 2
		
		///NPC
		public static const NPC:int = 3;
		
		///墙格
		public static const WALL:int = 4;
		
	}

}