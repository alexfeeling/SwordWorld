package com.alex.pattern
{
	
	/**
	 * 命令执行者，实现该接口方可处理命令
	 * @author alex
	 */
	public interface IOrderExecutor
	{
		
		///获取听从处理的命令
		function getExecuteOrderList():Array;
		
		///执行命令
		function executeOrder(orderName:String, orderParam:Object = null):void;
		
		///获取执行者ID
		function getExecutorId():String;
	
	}

}