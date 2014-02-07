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
		private var _allCommand:Dictionary;
		
		public function Commander() 
		{
			if (_instance != null) {//只能实例化一次
				throw "Commander已经有单例对象，不可再实例化";
			}
			init();
		}
		
		private function init():void {
			_allCommand = new Dictionary();
		}
		
		private static function getInstance():Commander {
			if (_instance == null) {
				_instance = new Commander();
			}
			return _instance;
		}
		
		///注册命令执行者，要执行想监听的命令，则要先注册为执行者
		public static function registerHandler(handler:ICommandHandler):void {
			getInstance().m_register(handler);
		}
		
		///取消监听命令、执行命令
		public static function cancelHandler(handler:ICommandHandler):void {
			getInstance().m_remove(handler);
		}
		
		///发送命令，只有实现ICommandSender接口的类对象才可发送命令
		public static function sendCommand(commandName:String, commandParam:Object = null):void {
			getInstance().m_sendCommand(commandName, commandParam);
		}
		
		private function m_register(handler:ICommandHandler):void {
			var hId:String = handler.getHandlerId();
			if (hId == null || hId == "") {
				return;
			}
			var commandList:Array = handler.getCommandList();
			if (commandList == null || commandList.length == 0) {
				return;
			}
			for (var i:int = 0, len:int = commandList.length; i < len; i++) {
				var command:String = commandList[i] as String;
				if (command == null || command == "") {
					continue;
				}
				var commandHandlerDic:Dictionary = _allCommand[command] as Dictionary;
				if (commandHandlerDic == null) {
					commandHandlerDic = new Dictionary();
					_allCommand[command] = commandHandlerDic;
				}
				commandHandlerDic[hId] = handler;
			}
		}
		
		///移除执行者
		private function m_remove(vHandler:ICommandHandler):void {
			if (vHandler == null) {
				return;
			}
			var hId:String = vHandler.getHandlerId();
			if (hId == null) {
				return;
			}
			var commandList:Array = vHandler.getCommandList();
			if (commandList != null) {
				for (var i:int = 0, len:int = commandList.length; i < len; i++) {
					var command:String = commandList[i] as String;
					if (command != null && command != "") {
						var commandHandlersDic:Dictionary = _allCommand[command] as Dictionary;
						if (commandHandlersDic != null) {
							delete commandHandlersDic[hId];
						}
					}
				}
			}
		}
		
		private function m_sendCommand(commandName:String, commandParam:Object = null):void {
			if (commandName == null || commandName == "") {
				return;
			}
			var handlersDic:Dictionary = _allCommand[commandName] as Dictionary;
			if (handlersDic == null) {
				return;
			}
			for each(var fObj:ICommandHandler in handlersDic) {
				if (fObj != null) {
					fObj.handleCommand(commandName, commandParam);
				} 
			}
		}
		
		private static function isDictionaryEmpty(vDic:Dictionary):Boolean {
			for each(var obj:Object in vDic) {
				if (obj != null) {
					return false;
				}
			}
			return true;
		}
		
	}

}