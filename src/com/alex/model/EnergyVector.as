package com.alex.model 
{
	import com.alex.constant.MoveDirection;
	import com.alex.pool.InstancePool;
	import com.alex.pool.IRecycle;
	/**
	 * 向量动能，拥有动能的大小和方向
	 * @author alex
	 */
	public class EnergyVector implements IRecycle
	{
		
		public var energy:Number = 0;
		
		public var direction:int = MoveDirection.X_RIGHT;
		
		public function EnergyVector() 
		{
			
		}
		
		public function init(vDir:int, vEnergy:Number):EnergyVector {
			this.direction = vDir;
			this.energy = vEnergy;
			return this;
		}
		
		/* INTERFACE com.alex.pool.IRecycle */
		
		public function release():void 
		{
			this.energy = 0;
			this.direction = MoveDirection.X_RIGHT;
			InstancePool.recycle(this);
		}
		
	}

}