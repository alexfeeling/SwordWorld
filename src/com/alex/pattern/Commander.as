package com.alex.pattern
{
	import adobe.utils.CustomActions;
	import com.alex.worldmap.MapBlock;
	import flash.utils.Dictionary;
	
	/**
	 * 命令接收分发处理
	 * @author alex
	 */
	public class Commander
	{
		
		private static var _instance:Commander;
		
		///所有命令
		private var _allOrder:Dictionary;
		
		public function Commander()
		{
			if (_instance != null)
			{ //只能实例化一次
				throw "Commander已经有单例对象，不可再实例化";
			}
			init();
		}
		
		private function init():void
		{
			_allOrder = new Dictionary();
		}
		
		private static function getInstance():Commander
		{
			if (_instance == null)
			{
				_instance = new Commander();
			}
			return _instance;
		}
		
		///注册命令执行者，要执行想监听的命令，则要先注册为执行者
		public static function registerExecutor(executor:IOrderExecutor):void
		{
			getInstance().m_register(executor);
		}
		
		///取消监听命令、执行命令
		public static function cancelExecutor(executor:IOrderExecutor):void
		{
			getInstance().m_remove(executor);
		}
		
		///发送命令，只有实现ICommandSender接口的类对象才可发送命令
		public static function sendOrder(orderName:String, orderParam:Object = null, orderExecutor:IOrderExecutor = null):void
		{
			if (orderExecutor)
			{
				orderExecutor.executeOrder(orderName);
			}
			else
			{
				getInstance().m_sendOrder(orderName, orderParam);
			}
		}
		
		private function m_register(executor:IOrderExecutor):void
		{
			var hId:String = executor.getExecutorId();
			if (hId == null || hId == "")
			{
				return;
			}
			var orderList:Array = executor.getExecuteOrderList();
			if (orderList == null || orderList.length == 0)
			{
				return;
			}
			for (var i:int = 0, len:int = orderList.length; i < len; i++)
			{
				var order:String = orderList[i] as String;
				if (order == null || order == "")
				{
					continue;
				}
				var executorDic:Dictionary = _allOrder[order] as Dictionary;
				if (executorDic == null)
				{
					executorDic = new Dictionary();
					_allOrder[order] = executorDic;
				}
				executorDic[hId] = executor;
			}
		}
		
		///移除执行者
		private function m_remove(vHandler:IOrderExecutor):void
		{
			if (vHandler == null)
			{
				return;
			}
			var hId:String = vHandler.getExecutorId();
			if (hId == null)
			{
				return;
			}
			var orderList:Array = vHandler.getExecuteOrderList();
			if (orderList != null)
			{
				for (var i:int = 0, len:int = orderList.length; i < len; i++)
				{
					var order:String = orderList[i] as String;
					if (order != null && order != "")
					{
						var executorDic:Dictionary = _allOrder[order] as Dictionary;
						if (executorDic != null)
						{
							delete executorDic[hId];
						}
					}
				}
			}
		}
		
		private function m_sendOrder(orderName:String, orderParam:Object = null):void
		{
			if (orderName == null || orderName == "")
			{
				return;
			}
			var executorDic:Dictionary = _allOrder[orderName] as Dictionary;
			if (executorDic == null)
			{
				return;
			}
			for each (var fObj:IOrderExecutor in executorDic)
			{
				if (fObj != null)
				{
					fObj.executeOrder(orderName, orderParam);
				}
			}
		}
		
		private static function isDictionaryEmpty(vDic:Dictionary):Boolean
		{
			for each (var obj:Object in vDic)
			{
				if (obj != null)
				{
					return false;
				}
			}
			return true;
		}
	
	}

}