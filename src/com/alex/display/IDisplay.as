package com.alex.display 
{
	import flash.display.DisplayObject;
	
	/**
	 * ...
	 * @author alex
	 */
	public interface IDisplay extends IPhysics
	{
		
		///获得显示对象
		function toDisplayObject():DisplayObject;
		
		///刷新海拔高度
		function refreshElevation():void;
		
		function refreshDisplayXY():void;
		
	}
	
}