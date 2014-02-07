package com.alex.pattern
{
	
	/**
	 * 实现该接口才可发送命令
	 * @author alex
	 */
	public interface ICommandSender 
	{
		
		///发送命令，该命令可给实现ICommandSender的类对象处理
		function sendCommand(commandName:String, commandParam:Object = null):void;
		
	}
	
}