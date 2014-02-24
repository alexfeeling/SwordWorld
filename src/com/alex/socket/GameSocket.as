package com.alex.socket 
{
	import flash.display.Stage;
	import flash.events.AVDictionaryDataEvent;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.KeyboardEvent;
	import flash.events.ProgressEvent;
	import flash.net.Socket;
	import flash.utils.ByteArray;
	/**
	 * ...
	 * @author alexfeeling
	 */
	public class GameSocket 
	{
		
		private var _socket:Socket;
		private var _stage:Stage;
		
		private static var SERVER_HOST:String = "localhost";
		private static var SERVER_PORT:String = 8899;
		
		public function GameSocket(stage:Stage) 
		{
			_stage = stage;
			_stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
			this.connectToServer();
		}
		
		private function onKeyDown(evt:KeyboardEvent):void {
			if (evt.keyCode == 32) {
				if (_socket) {
					try 
					{
						_socket.writeByte(0);
						var str:String = "on pressing space";
						_socket.writeByte(str.length);
						_socket.writeUTFBytes(str);
						_socket.flush();
					} 
					catch (err:Error) 
					{
						trace(err);
						_socket.close();
					}
				}
			}
		}
		
		public function connectToServer():void {
			if (_socket) {
				_socket.close();
				_socket = null;
			}
			_socket = new Socket();
			_socket.addEventListener(Event.CONNECT, onConnected);
			_socket.addEventListener(Event.CLOSE, onClose);
			_socket.addEventListener(IOErrorEvent.IO_ERROR, onError);
			_socket.addEventListener(ProgressEvent.SOCKET_DATA, onData);
			_socket.connect(SERVER_HOST, SERVER_PORT);
		}
		
		private function onConnected(evt:Event):void {
			trace("connected server");
			//_socket.writeUTFBytes("hello server");
			//return;
			for (var i:int = 0; i < 10; i++) {
				_socket.writeByte(0);
				var str:String = "hello Server!" + i;
				_socket.writeByte(str.length);
				_socket.writeUTFBytes(str);
			}
			_socket.flush();
		}
		
		private function onClose(evt:Event):void {
			trace("connection close");
		}
		
		private function onError(evt:IOErrorEvent):void {
			trace("socket error:", evt.text);
			connectToServer();
		}
		
		private function onData(evt:ProgressEvent):void {
			//trace("received data:", evt.currentTarget.data);
			//var buffer:ByteArray = new ByteArray();
			//while (_socket.bytesAvailable) {
				//buffer.writeByte(_socket.readByte());
			//}
			
			//buffer.position = 0;
			//var len:int = buffer.readByte();
			//trace(len);
			//trace(buffer.readUTFBytes(len));
			//buffer.clear();
			
			try 
			{
				while(_socket.bytesAvailable) {
					var len:int = _socket.readByte();
					var str:String = _socket.readUTFBytes(len);
					trace("receive data:" + str);
				}
			} 
			catch (err:Error) 
			{
				trace(err);
			} finally {
				_socket.close();
				_socket = null;
				connectToServer();
			}
			
		}
		
	}

}