package com.alex.display 
{
	import com.alex.worldmap.IMapGridItem;
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.geom.Rectangle;
	import flash.media.Video;
	
	/**
	 * 有生命的单位（实体单位）
	 * @author alex
	 */
	public class ZoeticItem extends Sprite implements IDisplay
	{
		
		private var _mapStation:Shape;
		private var _body:MovieClip;
		
		private var _modelId:String;
		private var _effectWidth:int;
		private var _effectHeight:int;
		
		public function ZoeticUnit(modelId:String, effectWidth:int, effectHeight:int) 
		{
			this._modelId = modelId;
			this._effectWidth = effectWidth;
			this._effectHeight = effectHeight; 
		}
		
		private function init():void {
			_mapStation = new Shape();
			_mapStation.graphics.beginFill(0x0, 0);
			_mapStation.graphics.drawRect(this._effectWidth / 2, this._effectHeight / 2, 
							this._effectWidth, this._effectHeight);
			_mapStation.graphics.endFill();
			this.addChild(_mapStation);
		}
		
		public function getMapStation():Rectangle {
			return new Rectangle(this._mapStation.x, this._mapStation.y,
							this._mapStation.width, this._mapStation.height);
		}
		
		public function toDisplayObject():DisplayObject {
			return this;
		}
		
		public function getX():Number {
			return this.x;
		}
		
		public function getY():Number {
			return this.y;
		}
		
		public function setX(x:Number):void {
			this.x = x;
		}
		
		public function setY(y:Number):void {
			this.y = y;
		}
		
		public function getWidth():Number {
			return this._mapStation.width;
		}
		
		public function getHeight():Number {
			return this._mapStation.height;
		}
		
		public function setWidth(vWidth:Number):void {
			
		}
		
		public function setHeight(vHeight:Number):void {
			
		}
		
	}

}