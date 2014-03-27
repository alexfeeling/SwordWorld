package com.alex.worldmap 
{
	import com.alex.component.PhysicsComponent;
	import com.alex.constant.MoveDirection;
	import com.alex.display.IPhysics;
	import com.alex.pool.InstancePool;
	import com.alex.pool.IRecycle;
	/**
	 * ...
	 * @author alex
	 */
	public class Position implements IRecycle
	{
		
		public var phycItem:IPhysics;
		
		private var _gridX:int;
		private var _gridY:int;
		
		///格子内坐标X
		private var _insideX:int;
		///格子内坐标Y
		private var _insideY:int;
		private var _isRelease:Boolean;
		
		///海拔高度
		public var elevation:int;
		
		///相对海拔高度
		public var relativeElevation:int;
		
		public function Position() 
		{
			
		}
		
		protected function init(vGridX:int = 0, vGridY:int = 0, 
								vInsideX:int = -1, vInsideY:int = -1,
								vElevation:int = 0):Position 
		{
			this._gridX = vGridX;
			this._gridY = vGridY;
			this._insideX = vInsideX == -1?MapBlock.GRID_WIDTH / 2:vInsideX;
			this._insideY = vInsideY == -1?MapBlock.GRID_HEIGHT / 2:vInsideY;
			this.elevation = vElevation;
			this._isRelease = false;
			return this;
		}
		
		public static function make(gridX:int = 0, gridY:int = 0, insideX:int = -1, insideY:int = -1, elevation:int = 0):Position {
			//return InstancePool.getPosition(gridX, gridY, insideX, insideY, elevation);
			return (InstancePool.getInstance(Position) as Position).init(gridX, gridY, insideX, insideY, elevation);
		}
		
		//与目标单位贴合
		public function nestleUpTo(vDirection:int, vTarget:IPhysics):void {
			var myPhysicsComponent:PhysicsComponent = this.phycItem.physicsComponent;
			var targetPhysicsComponent:PhysicsComponent = vTarget.physicsComponent;
			var targetPosition:Position = vTarget.position;
			switch(vDirection) {
				case MoveDirection.X_LEFT:
					this.gridX = targetPosition.gridX;
					this.insideX = targetPosition.insideX + 
						((myPhysicsComponent.length + targetPhysicsComponent.length) >> 1);
					break;
				case MoveDirection.X_RIGHT:
					this.gridX = targetPosition.gridX;
					this.insideX = targetPosition.insideX -
						((myPhysicsComponent.length + targetPhysicsComponent.length) >> 1);
					break;
				case MoveDirection.Y_UP:
					this.gridY = targetPosition.gridY;
					this.insideY = targetPosition.insideY + 
						((myPhysicsComponent.width + targetPhysicsComponent.width) >> 1);
					break;
				case MoveDirection.Y_DOWN:
					this.gridY = targetPosition.gridY;
					this.insideY = targetPosition.insideY - 
						((myPhysicsComponent.width + targetPhysicsComponent.width) >> 1);
					break;
				case MoveDirection.Z_BOTTOM:
					this.elevation = targetPosition.elevation + targetPhysicsComponent.height;
					myPhysicsComponent.forceStopZ();
					break;
				case MoveDirection.Z_TOP:
					this.elevation = targetPosition.elevation - targetPhysicsComponent.height;
					myPhysicsComponent.forceStopZ();
					break;
			}
		}
		
		public function move(vDirection:int, vDistance:int):void {
			switch(vDirection) {
				case MoveDirection.X_LEFT://左
					this.insideX -= vDistance;
					break;
				case MoveDirection.X_RIGHT://右
					this.insideX += vDistance;
					break;
				case MoveDirection.Y_UP://上
					this.insideY -= vDistance;
					break;
				case MoveDirection.Y_DOWN://下
					this.insideY += vDistance;
					break;
				case MoveDirection.Z_BOTTOM://下落
					this.elevation -= vDistance;
					this.elevation = Math.max(this.elevation, 0);
					break;
				case MoveDirection.Z_TOP://上升
					this.elevation += vDistance;
					break;
			}
		}
		
		///比较X位置，目标在左边返回-1，在右边返回1，相等返回0
		public function compareX(vPosition:Position):int {
			if (vPosition.gridX < _gridX) {
				return -1;
			} else if (vPosition.gridX > _gridX) {
				return 1;
			} else if (vPosition.insideX < _insideX) {
				return -1;
			} else if (vPosition.insideX > _insideX) {
				return 1;
			} else {
				return 0;
			}
		}
		
		///地图块内格子坐标X
		public function get gridX():int 
		{
			return _gridX;
		}
		
		public function set gridX(value:int):void 
		{
			if (_gridX == value) {
				return;
			}
			var orgin:int = _gridX;
			_gridX = value;
			WorldMap.getInstance().refreshGridItem(phycItem, orgin, gridY);
		}
		
		///地图块内格子坐标Y
		public function get gridY():int 
		{
			return _gridY;
		}
		
		public function set gridY(value:int):void 
		{
			if (_gridY == value) {
				return;
			}
			var orgin:int = _gridY;
			_gridY = value;
			WorldMap.getInstance().refreshGridItem(phycItem, gridX, orgin);
		}
		
		public function get globalX():int {
			return this.gridX * MapBlock.GRID_WIDTH + this.insideX;
		}
		
		public function get globalY():int {
			return this.gridY * MapBlock.GRID_HEIGHT + this.insideY;
		}
		
		public function set globalX(value:int):void {
			this.gridX = int(value / MapBlock.GRID_WIDTH);
			this._insideX = int(value % MapBlock.GRID_WIDTH);
		}
		
		public function get insideX():int 
		{
			return _insideX;
		}
		
		public function set insideX(value:int):void 
		{
			_insideX = int(value);
			if (_insideX < 0) {
				_insideX += MapBlock.GRID_WIDTH;
				this.gridX--;
			} else if (_insideX >= MapBlock.GRID_WIDTH) {
				_insideX -= MapBlock.GRID_WIDTH;
				this.gridX++;
			} 
		}
		
		public function get insideY():int 
		{
			return _insideY;
		}
		
		public function set insideY(value:int):void 
		{
			_insideY = int(value);
			if (_insideY < 0) {
				_insideY += MapBlock.GRID_HEIGHT;
				this.gridY--;
			} else if (_insideY >= MapBlock.GRID_HEIGHT) {
				_insideY -= MapBlock.GRID_HEIGHT;
				this.gridY++;
			}
		}
		
		///复制格子
		public function copy():Position {
			//return InstancePool.getPosition(this._gridX, this._gridY, 
						//this.insideX, this.insideY, this.elevation);
			return Position(InstancePool.getInstance(Position)).init(this._gridX, this._gridY, 
						this.insideX, this.insideY, this.elevation);
		}
		
		/* INTERFACE com.alex.pool.IRecycle */
		
		public function release():void 
		{
			if (this._isRelease) {
				throw "already release.";
			}
			this._isRelease = true;
			InstancePool.recycle(this);
			this.phycItem = null;
			this._gridX = 0;
			this._gridY = 0;
			this.insideX = 0;
			this.insideY = 0;
			this.elevation = 0;
		}
		
		/* INTERFACE com.alex.pool.IRecycle */
		
		public function isRelease():Boolean 
		{
			return this._isRelease;
		}
		
	}

}