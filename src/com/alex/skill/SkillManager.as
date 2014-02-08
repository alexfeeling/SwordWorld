package com.alex.skill
{
	import com.alex.constant.OrderConst;
	import com.alex.pattern.Commander;
	import com.alex.pattern.IOrderExecutor;
	import flash.utils.Dictionary;
	
	/**
	 * ...
	 * @author alex
	 */
	public class SkillManager implements IOrderExecutor
	{
		
		private static const SKILL_KEY_CHI:String = "j";
		private static const SKILL_KEY_CHONG:String = "jj";
		private static const SKILL_KEY_PO:String = "k";
		private static const SKILL_KEY_SHEN:String = "kk";
		private static const SKILL_KEY_ZHAN:String = "jk";
		
		private var _skillKeyDic:Dictionary;
		
		public function SkillManager()
		{
			if (_instance != null)
			{ //只能实例化一次
				throw "SkillManager已经有单例对象，不可再实例化";
			}
			init();
		}
		
		private function init():void
		{
			_skillKeyDic = new Dictionary();
			var skillKey:Array = ["J", "JJ", "K", "KK", "JK"];
			var skillName:Array = ["刺", "冲", "破", "升", "斩"];
			for (var i:int = 0; i < skillKey.length; i++)
			{
				_skillKeyDic[skillKey[i]] = skillName[i];
			}
		}
		
		private static var _instance:SkillManager;
		
		public static function getInstance():SkillManager
		{
			if (_instance == null)
			{
				_instance = new SkillManager();
			}
			return _instance;
		}
		
		public function getSkillByKeyCombin(vKeyCombin:String):String
		{
			if (this._skillKeyDic[vKeyCombin] != null)
			{
				return this._skillKeyDic[vKeyCombin] as String;
			}
			return null;
		}
		
		public function checkSkillByCombin(vKeyCombin:String):Boolean
		{
			return this._skillKeyDic[vKeyCombin] != null;
		}
		
		public function getExecuteOrderList():Array
		{
			return [OrderConst.ROLE_USE_SKILL];
		}
		
		public function getExecutorId():String
		{
			return "skill_manager";
		}
		
		public function executeOrder(commandName:String, commandParam:Object = null):void
		{
			switch (commandName)
			{
				case OrderConst.ROLE_USE_SKILL: 
					if (commandParam is String)
					{
						//trace("use skill:", this._skillKeyDic[commandParam]);
						this.sendCommand(OrderConst.CREATE_SKILL, this._skillKeyDic[commandParam as String]);
					}
					break;
			}
		}
		
		/* INTERFACE com.alex.pattern.ICommandSender */
		
		public function sendCommand(commandName:String, commandParam:Object = null):void
		{
			Commander.sendOrder(commandName, commandParam);
		}
	
	}

}