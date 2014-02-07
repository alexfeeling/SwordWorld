package com.alex.pattern
{
	
	/**
	 * 实现该接口方可处理命令
	 * @author alex
	 */
	public interface ICommandHandler 
	{
		
		function getCommandList():Array;
		
		function handleCommand(commandName:String, commandParam:Object = null):void;
		
		function getHandlerId():String;
		
	}
	
}