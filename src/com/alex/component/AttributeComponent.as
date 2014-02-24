package com.alex.component
{
	import com.alex.constant.OrderConst;
	import com.alex.display.IPhysics;
	import com.alex.pattern.Commander;
	import com.alex.pattern.IOrderExecutor;
	import com.alex.pool.InstancePool;
	import com.alex.pool.IRecycle;
	import com.alex.util.IdMachine;
	
	/**
	 * 单位属性组件
	 * @author alexfeeling
	 */
	public class AttributeComponent implements IOrderExecutor, IRecycle
	{
		
		private var _id:String;
		
		private var _phycObject:IPhysics;
		
		///气血
		private var _life:int = 0;
		///气血最大值
		private var _maxLife:int = 100;
		
		///内力，气力
		private var _energy:int = 0;
		///内力最大值
		private var _maxEnergy:int = 100;
		private var _isRelease:Boolean = false;
		
		public function AttributeComponent()
		{
		
		}
		
		protected function init(phycObj:IPhysics, maxLife:int, maxEnergy:int, life:int = -1, energy:int = -1):AttributeComponent
		{
			this._isRelease = false;
			this._id = IdMachine.getId(AttributeComponent);
			this._phycObject = phycObj;
			this._maxLife = maxLife;
			this._maxEnergy = maxEnergy;
			this._life = life < 0 ? this._maxLife : life;
			this._energy = energy < 0 ? this._maxEnergy : energy;
			Commander.registerExecutor(this);
			return this;
		}
		
		public static function make(phycObj:IPhysics, maxLife:int, maxEnergy:int, life:int = -1, energy:int = -1):AttributeComponent
		{
			return AttributeComponent(InstancePool.getInstance(AttributeComponent)).init(phycObj, maxLife, maxEnergy, life, energy);
		}
		
		/* INTERFACE com.alex.pattern.IOrderExecutor */
		
		public function getExecuteOrderList():Array
		{
			return [];
		}
		
		public function executeOrder(orderName:String, orderParam:Object = null):void
		{
		
		}
		
		public function getExecutorId():String
		{
			return this._id;
		}
		
		/* INTERFACE com.alex.pool.IRecycle */
		
		public function release():void
		{
			if (_isRelease)
			{
				throw "already release.";
			}
			_isRelease = true;
			Commander.cancelExecutor(this);
			this._id;
			this._phycObject = null;
			this._life = 0;
			this._maxLife = 0;
			this._energy = 0;
			this._maxEnergy = 0;
			InstancePool.recycle(this);
		}
		
		/* INTERFACE com.alex.pool.IRecycle */
		
		public function isRelease():Boolean
		{
			return this._isRelease;
		}
		
		public function get life():int
		{
			return _life;
		}
		
		public function set life(value:int):void
		{
			_life = Math.min(_maxLife, Math.max(0, value));
			if (_life == 0)
			{
				this._phycObject.executeOrder(OrderConst.LIFE_EMPTY);
			}
		}
		
		public function get energy():int
		{
			return _energy;
		}
		
		public function set energy(value:int):void
		{
			_energy = Math.min(_maxEnergy, Math.max(0, value));
		}
	
	}

}