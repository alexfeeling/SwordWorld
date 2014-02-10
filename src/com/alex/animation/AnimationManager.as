package com.alex.animation
{
	import com.alex.util.IdMachine;
	import flash.events.TimerEvent;
	import flash.utils.Dictionary;
	import flash.utils.getTimer;
	import flash.utils.Timer;
	
	/**
	 * 动画管理器，基于时间的动画。每个动画都要放入动画管理器里面管理。
	 * 要放入动画管理器先要实现IAnimation接口
	 * @author alex
	 */
	public class AnimationManager
	{
		
		private static var _instance:AnimationManager;
		
		private var _allAnimation:Dictionary;
		private var _beginTime:int;
		private var _timer:Timer;
		
		public function AnimationManager()
		{
			if (_instance != null)
			{ //只能实例化一次
				throw "AnimationManager已经有单例对象，不可再实例化";
			}
			_allAnimation = new Dictionary(); // new Vector.<IAnimation>();
		}
		
		private static function getInstance():AnimationManager
		{
			if (_instance == null)
			{
				_instance = new AnimationManager();
			}
			return _instance;
		}
		
		///启动动画管理器，默认帧频是60
		public static function startUp(fps:Number = 60):void
		{
			getInstance().m_start(fps);
		}
		
		///添加动画实现类对象到动画管理器中
		public static function addToAnimationList(animation:IAnimation, priority:int = 0):void
		{
			getInstance().m_addToAnimation(animation, priority);
		}
		
		public static function removeAnimation(animation:IAnimation):void
		{
			getInstance().m_removeAnimation(animation);
		}
		
		///改变帧频
		public static function changeFPS(fps:Number):void
		{
			getInstance().m_start(fps);
		}
		
		private function m_start(fps:Number):void
		{
			if (fps > 1000)
			{
				fps = 1000;
			}
			if (this._timer != null)
			{
				this._timer.stop();
				this._timer.removeEventListener(TimerEvent.TIMER, updateTime);
			}
			_timer = new Timer(1000 / fps);
			_timer.addEventListener(TimerEvent.TIMER, updateTime);
			_timer.start();
			_beginTime = getTimer();
		}
		
		private function m_addToAnimation(animation:IAnimation, priority:int = 0):void
		{
			if (animation != null)
			{
				_allAnimation[animation.id] = animation;
			}
		}
		
		private function m_removeAnimation(animation:IAnimation):void
		{
			this._allAnimation[animation.id] = null;
			delete this._allAnimation[animation.id];
		}
		
		private function updateTime(event:TimerEvent):void
		{
			var timer:Timer = event.target as Timer;
			var currentTime:int = getTimer();
			var passedTime:Number = currentTime - _beginTime;
			_beginTime = currentTime;
			for each (var animation:IAnimation in this._allAnimation)
			{
				
				if (animation.isPlayEnd())
				{
					this.m_removeAnimation(animation);
					continue;
				}
				if (animation.isPause())
				{
					continue;
				}
				animation.gotoNextFrame(passedTime);
			}
		}
	
	}

}