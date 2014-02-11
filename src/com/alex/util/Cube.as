package com.alex.util
{
	
	/**
	 * 立方体
	 * @author alex
	 */
	public class Cube
	{
		
		private var _x:int;
		private var _y:int;
		private var _z:int;
		private var _length:int;
		private var _width:int;
		private var _height:int;
		
		public function Cube(x:int = 0, y:int = 0, z:int = 0, length:int = 1, width:int = 1, height:int = 1)
		{
			_x = x;
			_y = y;
			_z = z;
			_length = length;
			_width = width;
			_height = height;
		}
		
		///是否立方相交
		public function intersects(targetCube:Cube):Boolean
		{
			if (!targetCube)
			{
				return false;
			}
			if ((this.x + this.length <= targetCube.x) || 
				(this.x >= targetCube.x + targetCube.length) || 
				(this.y + this.width <= targetCube.y) || 
				(this.y >= targetCube.y + targetCube.width) || 
				(this.z + this.height <= targetCube.z) || 
				(this.z >= targetCube.z + targetCube.height))
			{
				return false;
			}
			return true;
		}
		
		public function isLiftCube(targetCube:Cube):Boolean
		{
			if (!targetCube)
			{
				return false;
			}
			if ((this.x + this.length <= targetCube.x) || 
				(this.x >= targetCube.x + targetCube.length) || 
				(this.y + this.width <= targetCube.y) || 
				(this.y >= targetCube.y + targetCube.width) || 
				(this.z + this.height != targetCube.z))
			{
				return false;
			}
			return true;
		}
		
		public function get x():int
		{
			return _x;
		}
		
		public function set x(value:int):void
		{
			_x = value;
		}
		
		public function get y():int
		{
			return _y;
		}
		
		public function set y(value:int):void
		{
			_y = value;
		}
		
		public function get z():int
		{
			return _z;
		}
		
		public function set z(value:int):void
		{
			_z = value;
		}
		
		public function get length():int
		{
			return _length;
		}
		
		public function set length(value:int):void
		{
			_length = value;
		}
		
		public function get width():int
		{
			return _width;
		}
		
		public function set width(value:int):void
		{
			_width = value;
		}
		
		public function get height():int
		{
			return _height;
		}
		
		public function set height(value:int):void
		{
			_height = value;
		}
	
	}

}