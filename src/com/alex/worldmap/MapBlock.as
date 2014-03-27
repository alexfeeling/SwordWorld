package com.alex.worldmap 
{
	import adobe.utils.CustomActions;
	import com.alex.constant.OrderConst;
	import com.alex.display.IDisplay;
	import com.alex.display.IPhysics;
	import com.alex.display.Tree;
	import com.alex.pattern.Commander;
	import com.alex.pattern.IOrderExecutor;
	import com.alex.pool.InstancePool;
	import com.alex.pool.IRecycle;
	import com.alex.role.MainRole;
	import com.alex.skill.SkillShow;
	import com.alex.util.IdMachine;
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.geom.Rectangle;
	import flash.utils.Dictionary;
	import flash.utils.getQualifiedClassName;
	
	/**
	 * ...
	 * @author alex
	 */
	public class MapBlock implements IRecycle, IOrderExecutor 
	{
		
		///地图格大小
		public static const GRID_WIDTH:int = 40 * 2;
		public static const GRID_HEIGHT:int = 30 * 2;
		
		public var blockX:int;
		public var blockY:int;
		
		private var _allMapGridDic:Dictionary;
		
		private var _id:String;
		
		private var _isRelease:Boolean = true;
		
		public function MapBlock() 
		{
			
		}
		
		public function init(vBlockX:int, vBlockY:int):MapBlock {
			this._allMapGridDic = new Dictionary();
			this.blockX = vBlockX;
			this.blockY = vBlockY;
			
			this._id = IdMachine.getId(MapBlock);
			
			Commander.registerExecutor(this);
			
			_isRelease = false;
			return this;
		}
		
		public static function make(vBlockX:int, vBlockY:int):MapBlock {
			return MapBlock(InstancePool.getInstance(MapBlock)).init(vBlockX, vBlockY);
		}
		
		///添加单位到地图中
		//public function addItem(item:IPhysics, position:Position = null):void {
			//if (item == null) {
				//return;
			//}
			//if (position == null) {
				//position = item.position;
			//} else {
				//item.position = position;
			//}
			//
			//if (this._allMapGridDic[position.gridX] == null) {
				//this._allMapGridDic[position.gridX] = new Dictionary();;
				//this._allMapGridDic[position.gridX][position.gridY] = item;
			//} else {
				//if (this._allMapGridDic[position.gridX][position.gridY] == null) {
					//this._allMapGridDic[position.gridX][position.gridY] = item;
				//} else {
					//格子中已经有单位
					//var tempObj:Object = this._allMapGridDic[position.gridX][position.gridY];
					//if (tempObj is Array) {
						//(tempObj as Array).push(item);
					//} else {
						//this._allMapGridDic[position.gridX][position.gridY] = [tempObj, item];
					//}
				//}
			//}
			//item.mapBlock = this;
		//}
		//
		//public function getItem(gridX:int, gridY:int):Object {
			//if ((this._allMapGridDic[gridX] as Dictionary) == null) {
				//return null;
			//}
			//return this._allMapGridDic[gridX][gridY];
		//}
		
		/* INTERFACE com.alex.pattern.ICommandHandler */
		public function getExecuteOrderList():Array 
		{
			return [
						OrderConst.REMOVE_MAP_BLOCK,
						OrderConst.REMOVE_ALL_ROW_MAP_BLOCK,
						OrderConst.REMOVE_ALL_COLUMN_MAP_BLOCK
					];
		}
		
		public function executeOrder(commandName:String, commandParam:Object = null):void 
		{
			if (this._isRelease) {
				return;
			}
			switch(commandName) {
				case OrderConst.REMOVE_MAP_BLOCK:
					if (commandParam.blockX == this.blockX &&
						commandParam.blockY == this.blockY) 
					{
						this.release();
					}
					break;
				case OrderConst.REMOVE_ALL_ROW_MAP_BLOCK:
					if (commandParam == this.blockY) {
						this.release();
					}
					break;
				case OrderConst.REMOVE_ALL_COLUMN_MAP_BLOCK:
					if (commandParam == this.blockX) {
						this.release();
					}
					break;
			}
		}
		
		public function getExecutorId():String 
		{
			return this._id;
		}
		
		/* INTERFACE com.alex.pool.IRecycle */
		public function release():void 
		{
			if (_isRelease) {
				throw("this MapBlock instance had released.");
			}
			Commander.cancelExecutor(this);
			InstancePool.recycle(this);
			_isRelease = true;
			for each(var mapGridDicX:Dictionary in this._allMapGridDic) {
				for each(var itemList:Object in mapGridDicX) {
					if (itemList is Array) {
						for (var i:int = itemList.length - 1; i >= 0; i--) {
							if (itemList[i] is IRecycle) {
								(itemList[i] as IRecycle).release();
							}
						}
					} else {
						if (itemList is IRecycle) {
							(itemList as IRecycle).release();
						}
					}
				}
			}
			this._id = null;
			this.blockX = 0;
			this.blockY = 0;
			this._allMapGridDic = null;
		}
		
		public function removeSingleItem(item:IPhysics, gridX:int, gridY:int, isRelease:Boolean = true):void {
			if (_isRelease) {
				return;
			}
			if ((this._allMapGridDic[gridX] as Dictionary) == null ||
				this._allMapGridDic[gridX][gridY] == null) 
			{
				throw "删除位置为空";
				return;
			}
			if (this._allMapGridDic[gridX][gridY] is Array) {
				var itemList:Array = this._allMapGridDic[gridX][gridY] as Array;
				if (itemList != null) {
					var idx:int = itemList.indexOf(item);
					if (idx >= 0 && itemList[idx] == item) {
						if (isRelease && item is IRecycle) {
							(item as IRecycle).release();
						}
						itemList.splice(idx, 1);
					}
					if (itemList.length <= 0) {
						this._allMapGridDic[gridX][gridY] = null;
						delete this._allMapGridDic[gridX][gridY];
					} else if (itemList.length == 1) {
						this._allMapGridDic[gridX][gridY] = itemList[0];
					}
				}
			} else {
				var tempObj:Object = this._allMapGridDic[gridX][gridY];
				if (tempObj == item) {
					if (isRelease && tempObj is IRecycle) {
						(tempObj as IRecycle).release();
					}
					this._allMapGridDic[gridX][gridY] = null;
					delete this._allMapGridDic[gridX][gridY];
				}
			}
		}
		
		/* INTERFACE com.alex.pool.IRecycle */
		
		public function isRelease():Boolean 
		{
			return this._isRelease;
		}
		
	}

}