package com.alex.constant 
{
	/**
	 * 移动方向
	 * @author alex
	 */
	public class MoveDirection 
	{
		
		public static const X_LEFT:int = 0;
		
		public static const X_RIGHT:int = 1;
		
		public static const Y_UP:int = 2;
		
		public static const Y_DOWN:int = 3;
		
		public static const Z_TOP:int = 4;
		
		public static const Z_BOTTOM:int = 5;
		
		public function MoveDirection() 
		{
			throw "MoveDirection can't create a instance.";
		}
		
	}

}