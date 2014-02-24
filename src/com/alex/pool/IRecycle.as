package com.alex.pool
{
	
	/**
	 * ...
	 * @author alex
	 */
	public interface IRecycle
	{
		
		///释放自己，让对象池回收你吧！
		function release():void;
		
		///是否已经释放
		function isRelease():Boolean;
	
	}

}