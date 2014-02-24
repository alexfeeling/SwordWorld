package com.alex.worldmap 
{
	import com.alex.pool.InstancePool;
	import com.alex.pool.IRecycle;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	/**
	 * ...
	 * @author alex
	 */
	public class WallGrid implements IMapGridItem
	{
		
		private var _position:Position;
		private var _mapBlock:MapBlock;
		private var _id:String;
		
		public function WallGrid() 
		{
			
		}
		
		public function init(vPosition:Position):WallGrid {
			this._position = vPosition;
			return this;
		}
		
		/* INTERFACE com.alex.worldmap.IMapGridItem */
		
		public function get id():String 
		{
			return _id;
		}
		
		public function release():void 
		{
			InstancePool.recycle(this);
			if (this._position != null) {
				this._position.release();
				this._position = null;
			}
			if (this._mapBlock != null) {
				this._mapBlock.release();
				this._mapBlock = null;
			}
			this._id = null;
		}
		
		/* INTERFACE com.alex.worldmap.IMapGridItem */
		
		public function get isSolid():Boolean 
		{
			return true;
		}
		
		/* INTERFACE com.alex.worldmap.IMapGridItem */
		
		public function get mapBlock():MapBlock 
		{
			return _mapBlock;
		}
		
		public function set mapBlock(value:MapBlock):void 
		{
			_mapBlock = value;
		}
		
		public function get position():Position 
		{
			return _position;
		}
		
		public function set position(value:Position):void 
		{
			_position = value;
		}
				
	}

}