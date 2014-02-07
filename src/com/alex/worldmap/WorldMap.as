package com.alex.worldmap 
{
	import adobe.utils.CustomActions;
	import com.alex.animation.AnimationManager;
	import com.alex.animation.IAnimation;
	import com.alex.constant.ForceDirection;
	import com.alex.constant.ItemType;
	import com.alex.display.IPhysics;
	import com.alex.pool.IRecycle;
	import com.alex.skill.Skill;
	import com.alex.pattern.Commander;
	import com.alex.pattern.IOrderExecutor;
	import com.alex.constant.OrderConst;
	import com.alex.controll.KeyboardController;
	import com.alex.display.IDisplay;
	import com.alex.display.Tree;
	import com.alex.pattern.IOrderExecutor;
	import com.alex.pool.InstancePool;
	import com.alex.role.MainRole;
	import com.alex.util.IdMachine;
	import flash.display.Bitmap;
	import flash.display.DisplayObject;
	import flash.display.Loader;
	import flash.display.LoaderInfo;
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.events.DRMCustomProperties;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.media.VideoCodec;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.utils.Dictionary;
	import flash.utils.getTimer;
	
	/**
	 * ...
	 * @author alex
	 */
	public class WorldMap extends Sprite implements IAnimation,IOrderExecutor
	{
		
		public static var ASSET_LOAD:String = "asset/map/";
		
		///所有地图块，用字典存放
		private var _allMapBlockDic:Dictionary;
		
		///=================打算改成只用地图格存储对象===============
		private var _allMapGridDic:Dictionary;
		
		private static var MIDDLE_BLOCK_X:int;
		private static var MIDDLE_BLOCK_Y:int;
		
		///地图块水平最大存放对象个数
		public static var BLOCK_X_SIZE:int;
		///地图块垂直最大存放对象个数
		public static var BLOCK_Y_SIZE:int;
		
		public static var STAGE_WIDTH:Number = 1024;
		public static var STAGE_HEIGHT:Number = 768;
		
		///存放地图背景图片sprite
		private var _mapImageSp:Sprite;
		///存放地图格对象sprite
		private var _mapGridItemSp:Sprite;
		
		private var _mainRole:MainRole;
		
		private var _allOtherDisplay:Dictionary;
		
		public function WorldMap() {
			if (_instance != null) {
				throw "WorldMap已经有单例对象，不可再实例化";
			}
			init();
		}
		
		private static var _instance:WorldMap;
		public static function getInstance():WorldMap {
			if (_instance == null) {
				_instance = new WorldMap();
			} 
			return _instance;
		}
		
		public function onStageChange(event:Event):void {
			STAGE_WIDTH = (event.target as Stage).stageWidth;
			STAGE_HEIGHT = (event.target as Stage).stageHeight;
			this.refreshMapPosition(this._mainRole);
		}
		
		private function init():void {
			_allMapGridDic = new Dictionary();
			_allMapBlockDic = new Dictionary();
			BLOCK_X_SIZE = 8;//Math.ceil(this.stageWidth / MapBlock.GRID_WIDTH);
			BLOCK_Y_SIZE = 8;//Math.ceil(this.stageHeight / MapBlock.GRID_HEIGHT);
			
			_mapImageSp = new Sprite();
			_mapGridItemSp = new Sprite();
			this.addChild(_mapImageSp);
			this.addChild(_mapGridItemSp);
			
			_allOtherDisplay = new Dictionary();
			
			this.loadMapBlock(0, 0);
			this.loadMapBlock(0, 1);
			this.loadMapBlock(1, 0);
			this.loadMapBlock(1, 1);
			
			Commander.registerHandler(this);
			AnimationManager.addToAnimationList(this);
		}
		
		private function initData(mapData:String):void {
			var mapDataList:Array = JSON.parse(mapData) as Array;
			if (mapDataList == null && mapDataList.length < 1) {
				return;
			}
			var newBlockX:int = int(mapDataList[0].blockX);
			var newBlockY:int = int(mapDataList[0].blockY);
			
			var newMapBlock:MapBlock = InstancePool.getMapBlock(newBlockX, newBlockY);
			
			this.addMapBlock(newMapBlock);
			
			for (var i:int = 1; i < mapDataList.length; i++) {
				var mapGridObj:Object = mapDataList[i];
				if (mapGridObj.ignore == 1 || 
					mapGridObj.gridX >= BLOCK_X_SIZE ||
					mapGridObj.gridY >= BLOCK_Y_SIZE) {
					continue;
				}
				var differBlockXNum:int = (newBlockX - MIDDLE_BLOCK_X) * BLOCK_X_SIZE;
				var differBlockYNum:int = (newBlockY - MIDDLE_BLOCK_Y) * BLOCK_Y_SIZE;
				if (mapGridObj.gridX != null && mapGridObj.gridY != null) {
					var position:Position = InstancePool.getPosition(newBlockX * BLOCK_X_SIZE + int(mapGridObj.gridX), 
						newBlockY * BLOCK_Y_SIZE + int(mapGridObj.gridY));
					if (mapGridObj.insideX != null) {
						position.insideX = mapGridObj.insideX;
					}
					if (mapGridObj.insideY != null) {
						position.insideY = mapGridObj.insideY;
					}
				}
				else {
					continue;
				}
				switch(mapGridObj.type) {
					case "wall"://墙格，无法通过的无形障碍格
						//var gridItem:IMapGridItem = new WallGrid(position);
						//newMapBlock.addItem(gridItem);
						break;
					case "tree"://树
						var displayItem:IDisplay = InstancePool.getTree(position);
						this.addGridItem(displayItem);
						this._mapGridItemSp.addChild(displayItem.toDisplayObject());
						this._allOtherDisplay[displayItem.id] = displayItem;
						break;
					case "main_role"://主角
						if (this._mainRole != null) {
							throw "error";
						}
						this._mainRole = new MainRole().init(position);// InstancePool.getMainRole(position);
						this.addGridItem(this._mainRole);
						this._mapGridItemSp.addChild(this._mainRole);
						var mapX:Number = (STAGE_WIDTH >> 1) - this._mainRole.toDisplayObject().x;
						var mapY:Number = (STAGE_HEIGHT >> 1) - this._mainRole.toDisplayObject().y;
						this.x = mapX;
						this.y = mapY;
						break;
				}
			}
		}
		
		public function addMapBlock(mapBlock:MapBlock):void {
			var mapXBlockDic:Dictionary = this._allMapBlockDic[mapBlock.blockX] as Dictionary;
			if (mapXBlockDic == null) {
				mapXBlockDic = new Dictionary();
				this._allMapBlockDic[mapBlock.blockX] = mapXBlockDic;
			} else if (mapXBlockDic[mapBlock.blockY] != null &&
						mapXBlockDic[mapBlock.blockY] is IRecycle) {
				//该位置已经有对象，释放他
				(mapXBlockDic[mapBlock.blockY] as IRecycle).release();
				mapXBlockDic[mapBlock.blockY] = null;
			}
			mapXBlockDic[mapBlock.blockY] = mapBlock;
		}
		
		public function getMapBlock(blockX:int, blockY:int):MapBlock {
			if ((this._allMapBlockDic[blockX] as Dictionary) == null) {
				return null;
			}
			return this._allMapBlockDic[blockX][blockY] as MapBlock;
		}
		
		///删除单个地图块
		private function removeMapBlock(blockX:int, blockY:int):void {
			this.sendCommand(OrderConst.REMOVE_MAP_BLOCK, 
				{ blockX:blockX, blockY:blockY} );
			if (this._allMapBlockDic[blockX] == null) {
				return;
			}
			if (this._allMapBlockDic[blockX][blockY] != null) {
				this._allMapBlockDic[blockX][blockY] = null;
				delete this._allMapBlockDic[blockX][blockY];
			}
		}
		
		///删除整列地图块
		private function removeMapBlockByX(blockX:int):void {
			this.sendCommand(OrderConst.REMOVE_ALL_COLUMN_MAP_BLOCK, blockX);
			if (this._allMapBlockDic[blockX] != null) {
				this._allMapBlockDic[blockX] = null;
				delete this._allMapBlockDic[blockX];
			}
		}
		
		///删除整行地图块
		private function removeMapBlockByY(blockY:int):void {
			this.sendCommand(OrderConst.REMOVE_ALL_ROW_MAP_BLOCK, blockY);
			for each(var mdy:Dictionary in this._allMapBlockDic) {
				if (mdy != null && mdy[blockY] != null) {
					mdy[blockY] = null;
					delete mdy[blockY];
				}
			}
		}
		
		public function getGridItemDic(vGridX:int, vGridY:int):Dictionary {
			if (this._allMapGridDic[vGridX] == null) {
				return null;
			}
			return this._allMapGridDic[vGridX][vGridY] as Dictionary;
		}
		
		public function addGridItem(vItem:IPhysics):void {
			if (!vItem) {
				return;
			}
			var position:Position = vItem.position;
			if (!position) {
				return;
			}
			if (this._allMapGridDic[position.gridX] == null) {
				this._allMapGridDic[position.gridX] = new Dictionary();
				this._allMapGridDic[position.gridX][position.gridY] = new Dictionary();
			} else if (this._allMapGridDic[position.gridX][position.gridY] == null) {
				this._allMapGridDic[position.gridX][position.gridY] = new Dictionary();
			}
			this._allMapGridDic[position.gridX][position.gridY][vItem.id] = vItem;
			vItem.refreshItemXY();
		}
		
		public function removeGridItem(vItem:IPhysics):void {
			if (!vItem) {
				throw "error";
				return;
			}
			var position:Position = vItem.position;
			if (!position) {
				throw "error";
				return;
			}
			if (this._allMapGridDic[position.gridX] == null) {
				throw "error";
				return;
			}
			var itemDic:Dictionary = this._allMapGridDic[position.gridX][position.gridY] as Dictionary;
			if (itemDic == null) {
				throw "error";
				return;
			}
			delete itemDic[vItem.id];
		}
		
		public function refreshGridItem(vItem:IPhysics, vOrginGridX:int, vOrginGridY:int):void {
			if (vItem.position.gridX == vOrginGridX && vItem.position.gridY == vOrginGridY) {
				return;
			}
			var itemDic:Dictionary = getGridItemDic(vOrginGridX, vOrginGridY);
			if (!itemDic) {
				throw "error";
				return;
			}
			if (itemDic[vItem.id] != vItem) {
				throw "error";
			}
			delete itemDic[vItem.id];
			addGridItem(vItem);
		}
		
		///通过地图坐标来加载地图块对象
		private function loadMapBlock(blockX:int, blockY:int):void {
			if (blockX < 0 || blockY < 0) {
				return;
			}
			if (this._allMapBlockDic[blockX] != null && 
				this._allMapBlockDic[blockX][blockY] != null)
			{
				//该位置已经有对象，不加载
				return;
			}
			var urlLoader:URLLoader = new URLLoader();
			urlLoader.addEventListener(Event.COMPLETE, onLoadComplete);
			urlLoader.addEventListener(IOErrorEvent.IO_ERROR, onError);
			
			urlLoader.load(new URLRequest(WorldMap.ASSET_LOAD + "mapblock_" + blockX + "_" + blockY + ".map"));
			
		}
		
		private function onLoadComplete(event:Event):void {
			(event.target as URLLoader).removeEventListener(Event.COMPLETE, onLoadComplete);
			this.initData(String(event.target.data));
		}
		
		private function onError(event:Event):void {
			(event.target as URLLoader).removeEventListener(Event.COMPLETE, onLoadComplete);
		}
		
		///单位移动，如果步伐过大，会将步伐距离切割为数次移动
		private static var STEP:int = 20;
		///direction:0左，1右，2上，3下
		public function itemMove(vItem:IPhysics, vDirection:int, vDistance:Number):void {
			var tDistance:Number = vDistance;
			while (tDistance > STEP) {
				var isHit:Boolean = getInstance().f_itemMove(vItem, vDirection, STEP);
				if (isHit) {
					vItem.refreshItemXY();
					return;
				}
				tDistance -= STEP;
			}
			getInstance().f_itemMove(vItem, vDirection, tDistance);
			vItem.refreshItemXY();
		}
		
		///单位移动,direction:0左，1右，2上，3下
		//0无碰撞 1碰撞 2释放 XXXX
		private function f_itemMove(item:IPhysics, direction:int, distance:Number):Boolean {
			var pos:Position = item.position;
			if (pos == null) {
				return false;
			}
			//先移动相应距离
			pos.move(direction, distance);
			
			if (item.physicsComponent.physicsType == ItemType.SOLID) {
				var itemList:Array = this.getAroudItemsByMove(direction, item.position);
			} else {
				itemList = this.getAroudItems(item.position);
			}
			
			var isHitItem:Boolean = false;
			///移动结果：0无碰撞 1碰撞 2释放
			for (var i:int = 0; i < itemList.length; i++) {
				var itemDic:Dictionary = itemList[i] as Dictionary;
				if (itemDic == null) {
					continue;
				}
				for each(var tempItem:IPhysics in itemDic) {
					if (tempItem == item || 
						(tempItem is Skill && (tempItem as Skill).ownner == item) ||
						(item is Skill && (item as Skill).ownner == tempItem))
					{
						continue;
					}
					if (physicsItemHitTest(item, tempItem)) {
						if (item.physicsComponent.physicsType == ItemType.BUBBLE) {
							var skillItem:Skill = item as Skill;
							if (skillItem) {//我是技能，撞到你了吧！！
								skillItem.collide(tempItem);
								return false;
							}
						} else if (item.physicsComponent.physicsType == ItemType.SOLID) {
							if (tempItem.physicsComponent.physicsType == ItemType.SOLID) {
								isHitItem = true;
								//刚体碰撞到刚体，停止移动，贴合
								item.position.fit(direction, tempItem);
							} 
						}  
					}
				}
			}
			return isHitItem;
		}
		
		public function getAroudItemsByMove(vDir:int, vPosition:Position):Array {
			var result:Array = [];
			switch(vDir) {
				case ForceDirection.X_LEFT:
					return 	[
								this.getGridItemDic(vPosition.gridX - 1, vPosition.gridY),
								this.getGridItemDic(vPosition.gridX - 1, vPosition.gridY - 1),
								this.getGridItemDic(vPosition.gridX - 1, vPosition.gridY + 1),
								this.getGridItemDic(vPosition.gridX, vPosition.gridY),
								this.getGridItemDic(vPosition.gridX, vPosition.gridY - 1),
								this.getGridItemDic(vPosition.gridX, vPosition.gridY + 1)
							];
				case ForceDirection.X_RIGHT:
					return  [
								this.getGridItemDic(vPosition.gridX + 1, vPosition.gridY),
								this.getGridItemDic(vPosition.gridX + 1, vPosition.gridY - 1),
								this.getGridItemDic(vPosition.gridX + 1, vPosition.gridY + 1),
								this.getGridItemDic(vPosition.gridX, vPosition.gridY),
								this.getGridItemDic(vPosition.gridX, vPosition.gridY - 1),
								this.getGridItemDic(vPosition.gridX, vPosition.gridY + 1)
							];
				case ForceDirection.Y_UP:
					return	[
								this.getGridItemDic(vPosition.gridX, vPosition.gridY - 1),
								this.getGridItemDic(vPosition.gridX - 1, vPosition.gridY - 1),
								this.getGridItemDic(vPosition.gridX + 1, vPosition.gridY - 1),
								this.getGridItemDic(vPosition.gridX, vPosition.gridY),
								this.getGridItemDic(vPosition.gridX - 1, vPosition.gridY),
								this.getGridItemDic(vPosition.gridX + 1, vPosition.gridY)
							];
				case ForceDirection.Y_DOWN:
					return  [
								this.getGridItemDic(vPosition.gridX, vPosition.gridY + 1),
								this.getGridItemDic(vPosition.gridX - 1, vPosition.gridY + 1),
								this.getGridItemDic(vPosition.gridX + 1, vPosition.gridY + 1),
								this.getGridItemDic(vPosition.gridX, vPosition.gridY),
								this.getGridItemDic(vPosition.gridX - 1, vPosition.gridY),
								this.getGridItemDic(vPosition.gridX + 1, vPosition.gridY)
							];
				case ForceDirection.Z_BOTTOM:
				case ForceDirection.Z_TOP:
					return this.getAroudItems(vPosition);
			}
			return null;
		}
		
		public function getAroudItems(vPosition:Position):Array {
			return	[
						this.getGridItemDic(vPosition.gridX, vPosition.gridY - 1),
						this.getGridItemDic(vPosition.gridX, vPosition.gridY),
						this.getGridItemDic(vPosition.gridX, vPosition.gridY + 1),
						this.getGridItemDic(vPosition.gridX - 1, vPosition.gridY - 1),
						this.getGridItemDic(vPosition.gridX - 1, vPosition.gridY),
						this.getGridItemDic(vPosition.gridX - 1, vPosition.gridY + 1),
						this.getGridItemDic(vPosition.gridX + 1, vPosition.gridY - 1),
						this.getGridItemDic(vPosition.gridX + 1, vPosition.gridY),
						this.getGridItemDic(vPosition.gridX + 1, vPosition.gridY + 1)
					];
		}

		//整个地图对象的新位置
		private function refreshMapPosition(item:IDisplay):void {
			if (!item) {
				throw "item 不可为空";
			}
			//整个地图对象的新位置
			var mapX:Number = (STAGE_WIDTH >> 1) - item.toDisplayObject().x;
			var mapY:Number = (STAGE_HEIGHT >> 1) - item.toDisplayObject().y;
			this.x = mapX;
			this.y = mapY;
		}
		
		///物理单位碰撞检测
		public static function physicsItemHitTest(vItemA:IPhysics, vItemB:IPhysics):Boolean {
			if (vItemA == null || vItemB == null) {
				return false;
			}
			var gx1:Number = vItemA.position.globalX;
			var gy1:Number = vItemA.position.globalY;
			var gx2:Number = vItemB.position.globalX;
			var gy2:Number = vItemB.position.globalY;
			var ele1:Number = vItemA.position.elevation;
			var ele2:Number = vItemB.position.elevation;
			var length1:Number = vItemA.physicsComponent.length;
			var width1:Number = vItemA.physicsComponent.width;
			var height1:Number = vItemA.physicsComponent.height;
			var length2:Number = vItemB.physicsComponent.length;
			var width2:Number = vItemB.physicsComponent.width;
			var height2:Number = vItemB.physicsComponent.height;
			if (Math.abs(gx1 - gx2) < int((length1 + length2) >> 1) &&
				Math.abs(gy1 - gy2) < int((width1 + width2) >> 1) &&
				((ele2 < height1 + ele1) && (ele1 < height2 + ele2)))
			{
				return true;
			}
			return false;
		}
		
		/* INTERFACE alex.animation.IAnimation */
		
		public function isPause():Boolean 
		{
			return false;
		}
		
		public function isPlayEnd():Boolean 
		{
			return false;
		}
		
		public function gotoNextFrame(passedTime:Number):void 
		{
			if (this._mainRole) {
				this._mainRole.gotoNextFrame(passedTime);
				this.refreshMapPosition(this._mainRole);
			}
			for each(var display:IAnimation in this._allOtherDisplay) {
				if (display) {
					display.gotoNextFrame(passedTime);
				}
			}
			if (_mapGridItemSp.numChildren > 1) {
				displayQuickSort(0, _mapGridItemSp.numChildren - 1);
			}
		}
		
		///显示对象深度排序
		private function displayQuickSort(start:int, end:int):void {
		    var i:int = start;
		    var j:int = end;
			while (i < j) {
				while(i<j && _mapGridItemSp.getChildAt(i).y <= _mapGridItemSp.getChildAt(j).y){     
					//以数组start下标的数据为key，右侧扫描
					j--;
				}
				if (i < j) {                  
					//右侧扫描，找出第一个比key小的，交换位置
					_mapGridItemSp.swapChildrenAt(i, j);
				}
				while (i < j && _mapGridItemSp.getChildAt(i).y <= _mapGridItemSp.getChildAt(j).y) {    
					//左侧扫描（此时a[j]中存储着key值）
					i++;
				}
				if (i < j) {            
					//找出第一个比key大的，交换位置
					_mapGridItemSp.swapChildrenAt(i, j);
				}
			}
			if (i - start > 1) {
				//递归调用，把key前面的完成排序
				displayQuickSort(start, i - 1);
			}
			if (end - i > 1) {
				//递归调用，把key后面的完成排序
				displayQuickSort(i + 1, end);    
			}
		}
		
		/* INTERFACE alex.pattern.ICommandHandler */
		public function getExecuteOrderList():Array 
		{
			return [
						OrderConst.MAP_ITEM_MOVE,
						OrderConst.ADD_ITEM_TO_WORLD_MAP,
						OrderConst.REMOVE_ITEM_FROM_WORLD_MAP
					];
		}
		
		public function executeOrder(commandName:String, commandParam:Object = null):void 
		{
			switch(commandName) {
				case OrderConst.MAP_ITEM_MOVE:
					var display:IPhysics = commandParam.display as IPhysics;
					var direction:int = int(commandParam.direction);
					var distance:Number = Number(commandParam.distance);
					if (display != null && !isNaN(distance)) {
						this.itemMove(display, direction, distance);
					}
					break;
				case OrderConst.ADD_ITEM_TO_WORLD_MAP://添加对象到地图中
					var item:IPhysics = commandParam as IPhysics;
					if (item == null) {
						break;
					}
					this.addGridItem(item);
					this._mapGridItemSp.addChild((item as IDisplay).toDisplayObject());
					this._allOtherDisplay[item.id] = item;
					break;
				case OrderConst.REMOVE_ITEM_FROM_WORLD_MAP://从地图中移除对象
					item = commandParam as IPhysics;
					if (item && this._allOtherDisplay[item.id]) {
						this._allOtherDisplay[item.id] = null;
						delete this._allOtherDisplay[item.id];
						this.removeGridItem(item);
					}
					break;
			}
		}
		
		public function getExecutorId():String 
		{
			return "WorldMap";
		}
		
		/* INTERFACE com.alex.pattern.ICommandSender */
		
		public function sendCommand(commandName:String, commandParam:Object = null):void 
		{
			Commander.sendOrder(commandName, commandParam);
		}
		
		/* INTERFACE com.alex.animation.IAnimation */
		
		public function get id():String 
		{
			return "WorldMap";
		}
		
	}

}