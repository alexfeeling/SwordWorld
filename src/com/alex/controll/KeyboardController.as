package com.alex.controll 
{
	import com.alex.animation.IAnimation;
	import com.alex.constant.OrderConst;
	import com.alex.constant.MoveDirection;
	import com.alex.pattern.Commander;
	import com.alex.pattern.IOrderExecutor;
	import com.alex.skill.SkillShow;
	import com.alex.skill.SkillManager;
	import com.alex.worldmap.WorldMap;
	import flash.display.Stage;
	import flash.events.KeyboardEvent;
	import flash.utils.Dictionary;
	/**
	 * ...
	 * @author alex
	 */
	public class KeyboardController implements IOrderExecutor, IAnimation 
	{
		
		private var _stage:Stage;
		
		private var _keyDic:Dictionary;
		
		//方向键
		public static const KEY_W:int = 87;
		public static const KEY_S:int = 83;
		public static const KEY_A:int = 65;
		public static const KEY_D:int = 68;
		
		//招式键
		public static const KEY_I:int = 73;
		public static const KEY_J:int = 74;
		public static const KEY_K:int = 75;
		public static const KEY_L:int = 76;
		
		//功能键
		public static const KEY_SPACE:int = 32;
		public static const KEY_ESC:int = 27;
		public static const KEY_ENTER:int = 13;
		
		//UI键
		public static const KEY_B:int = 66;
		public static const KEY_C:int = 67;
		public static const KEY_V:int = 86;
		public static const KEY_X:int = 88;
		public static const KEY_M:int = 77;
		public static const KEY_N:int = 78;
		
		//物品键
		public static const KEY_TOP_0:int = 48;
		public static const KEY_TOP_1:int = 49;
		public static const KEY_TOP_2:int = 50;
		public static const KEY_TOP_3:int = 51;
		public static const KEY_TOP_4:int = 52;
		public static const KEY_TOP_5:int = 53;
		public static const KEY_TOP_6:int = 54;
		public static const KEY_TOP_7:int = 55;
		public static const KEY_TOP_8:int = 56;
		public static const KEY_TOP_9:int = 57;
		
		private static var KEY_CODE_TO_KEY_CHAR:Dictionary;
		
		///物品键
		private var _propKey:int = 0;
		
		///招式键
		private var _skillKey:int = 0;
		
		///组合键箱
		private var _keyCombinBox:String;
		
		///键停留时间，单位为毫秒
		private var _keyStayTime:int;
		
		///键停留触发时间，单位为毫秒
		private var _keyStayOverTime:int;
		
		public function KeyboardController(vStage:Stage) 
		{
			this._stage = vStage;
			startUp();
		}
				
		public function startUp():void {
			_keyDic = new Dictionary();
			_keyCombinBox = "";
			_keyStayTime = -1;
			_keyStayOverTime = 170;
			this._stage.addEventListener(KeyboardEvent.KEY_DOWN, this.onKeyDown);
			this._stage.addEventListener(KeyboardEvent.KEY_UP, this.onKeyRelease);
			if (KEY_CODE_TO_KEY_CHAR == null) {
				KEY_CODE_TO_KEY_CHAR = new Dictionary();
				KEY_CODE_TO_KEY_CHAR[KEY_I] = "I";
				KEY_CODE_TO_KEY_CHAR[KEY_J] = "J";
				KEY_CODE_TO_KEY_CHAR[KEY_K] = "K";
				KEY_CODE_TO_KEY_CHAR[KEY_L] = "L";
			}
		}
		
		private function onKeyDown(event:KeyboardEvent):void {
			if (_keyDic[event.keyCode] != 1) {
				_keyDic[event.keyCode] = 1;
				if (event.keyCode >= KEY_TOP_0 && event.keyCode <= KEY_TOP_9) {
					this._propKey = event.keyCode;
				}
				switch(event.keyCode) {
					case KEY_A:
						Commander.sendOrder(OrderConst.ROLE_START_MOVE, MoveDirection.X_LEFT);
						break;
					case KEY_D:
						Commander.sendOrder(OrderConst.ROLE_START_MOVE, MoveDirection.X_RIGHT);
						break;
					case KEY_W:
						Commander.sendOrder(OrderConst.ROLE_START_MOVE, MoveDirection.Y_UP);
						break;
					case KEY_S:
						Commander.sendOrder(OrderConst.ROLE_START_MOVE, MoveDirection.Y_DOWN);
						break;
					case KEY_I://跳跃，闪避
						Commander.sendOrder(OrderConst.ROLE_START_JUMP);
						this._skillKey = event.keyCode;
						this._keyStayTime = -1;
						break;
					case KEY_J://攻击1
						this._skillKey = event.keyCode;
						this._keyStayTime = -1;
						break;
					case KEY_K://攻击2
						this._skillKey = event.keyCode;
						this._keyStayTime = -1;
						break;
					case KEY_L://防御
						this._skillKey = event.keyCode;
						this._keyStayTime = -1;
						break;
					case KEY_B://背包
						
						break;
					case KEY_C://人物
						
						break;
					case KEY_S://技能
						
						break;
				}
			}
		}
		
		private function onKeyRelease(event:KeyboardEvent):void {
			switch(event.keyCode) {
				case KEY_A:
					Commander.sendOrder(OrderConst.ROLE_STOP_MOVE, MoveDirection.X_LEFT);
					break;
				case KEY_D:
					Commander.sendOrder(OrderConst.ROLE_STOP_MOVE, MoveDirection.X_RIGHT);
					break;
				case KEY_W:
					Commander.sendOrder(OrderConst.ROLE_STOP_MOVE, MoveDirection.Y_UP);
					break;
				case KEY_S:
					Commander.sendOrder(OrderConst.ROLE_STOP_MOVE, MoveDirection.Y_DOWN);
					break;
				case KEY_I:
					Commander.sendOrder(OrderConst.ROLE_END_JUMP);
					break;
			}
			_keyDic[event.keyCode] = 0;
			delete _keyDic[event.keyCode];
			this._propKey = 0;
		}
		
		public function getExecuteOrderList () : Array {
			return [
						
					];
		}
		
		public function getExecutorId () : String {
			return "keyboard_controller";
		}

		public function executeOrder (commandName:String, commandParam:Object = null) : void {
			
		}
		
		public function gotoNextFrame (passedTime:Number) : void {
			if (this._propKey != 0) {
				//使用物品
				Commander.sendOrder(OrderConst.ROLE_USE_PROP, this._propKey);
				_keyDic[this._propKey] = null;
				delete _keyDic[this._propKey];
				this._propKey = 0;
			}
			if (this._skillKey != 0) {
				if (this._keyStayTime == -1) {
					//加入招式组合
					if (SkillManager.getInstance().checkSkillByCombin(this._keyCombinBox + KEY_CODE_TO_KEY_CHAR[this._skillKey])) {
						this._keyCombinBox += KEY_CODE_TO_KEY_CHAR[this._skillKey];
						this._keyStayTime = 0;
					} else if (this._keyCombinBox != null && this._keyCombinBox.length > 0) {
						//如果新加键组合无招式，则用之前键组合触发技能
						Commander.sendOrder(OrderConst.ROLE_USE_SKILL, this._keyCombinBox);
						this._skillKey = 0;
						this._keyStayTime = -1;
						this._keyCombinBox = "";
					}
				} else if (this._keyStayTime >= 0) {
					this._keyStayTime += passedTime;
					if (this._keyStayTime >= this._keyStayOverTime) {
						Commander.sendOrder(OrderConst.ROLE_USE_SKILL, this._keyCombinBox);
						this._skillKey = 0;
						this._keyStayTime = -1;
						this._keyCombinBox = "";
					}
				} 
			} 
		}

		public function isPause () : Boolean {
			return false;
		}

		public function isPlayEnd () : Boolean {
			return false;
		}
		
		/* INTERFACE com.alex.animation.IAnimation */
		
		public function get id():String 
		{
			return "keyboard_controller";
		}
		
	}

}