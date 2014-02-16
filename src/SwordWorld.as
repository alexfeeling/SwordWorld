package  
{
	import com.alex.animation.AnimationManager;
	import com.alex.component.PhysicsComponent;
	import com.alex.controll.KeyboardController;
	import com.alex.display.Tree;
	import com.alex.pattern.Commander;
	import com.alex.pool.InstancePool;
	import com.alex.skill.SkillManager;
	import com.alex.socket.GameSocket;
	import com.alex.util.Stats;
	import com.alex.worldmap.MapBlock;
	import com.alex.worldmap.Position;
	import com.alex.worldmap.WorldMap;
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	
	/**
	 * ...
	 * @author alex
	 */
	public class SwordWorld extends Sprite 
	{
		
		public function SwordWorld() 
		{
			if (stage) init();
			else addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		private function init(e:Event = null):void 
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);
			// entry point
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.align = StageAlign.TOP_LEFT;
			stage.addEventListener(Event.RESIZE, WorldMap.getInstance().onStageChange);
			
			new GameSocket(stage);
			//return;
			InstancePool.startUp();
			InstancePool.preset(MapBlock, 20);
			InstancePool.preset(Position, 20);
			InstancePool.preset(Tree, 20);
			InstancePool.preset(PhysicsComponent, 20);
			
			Commander.registerExecutor(SkillManager.getInstance());
			//启动动画管理器
			AnimationManager.startUp(60);
			//添加动画
			AnimationManager.addToAnimationList(new KeyboardController(stage));
			
			var worldMap:WorldMap = WorldMap.getInstance();
			this.addChild(worldMap);
			
			///显示fps工具类
			this.addChild(new Stats());
		}
		
	}

}