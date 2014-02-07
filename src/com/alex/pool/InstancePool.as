package com.alex.pool 
{
	import com.alex.component.PhysicsComponent;
	import com.alex.display.IDisplay;
	import com.alex.display.IPhysics;
	import com.alex.display.Tree;
	import com.alex.model.EnergyVector;
	import com.alex.role.MainRole;
	import com.alex.skill.Skill;
	import com.alex.worldmap.MapBlock;
	import com.alex.worldmap.Position;
	import flash.utils.Dictionary;
	import flash.utils.getDefinitionByName;
	import flash.utils.getQualifiedClassName;
	/**
	 * ...
	 * @author alex
	 */
	public class InstancePool 
	{
		
		private var _m_poolDic:Dictionary;
		private static var _instance:InstancePool;
		
		public function InstancePool() 
		{
			if (_instance != null) {//只能实例化一次
				throw "InstancePool已经有单例对象，不可再实例化";
			}
		}
		
		///对象池初始化
		public static function startUp():void {
			_instance = new InstancePool();
			_instance._m_poolDic = new Dictionary();
		}
		
		///预先装置对应对象池
		public static function preset(vClass:Class, num:int = 10):void {
			if (_instance == null || _instance._m_poolDic == null) {
				return;
			}
			var pool:Array = _instance._m_poolDic[vClass] as Array;
			if (pool == null) {
				pool = [];
				_instance._m_poolDic[vClass] = pool;
			}
			for (var i:int = 0; i < num; i++) {
				pool.push(new vClass() as IRecycle);
			}
		}
		
		///获取对象
		public static function getInstance(vClass:Class):IRecycle {
			var pool:Array = _instance._m_poolDic[vClass] as Array;
			if (pool == null) {
				pool = [];
				_instance._m_poolDic[vClass] = pool;
			}
			if (pool.length <= 0) {
				for (var i:int = 0; i < 10; i++) {
					pool.push(new vClass());
				}
			}
			return pool.pop() as IRecycle;
		}
		
		///回收对象
		public static function recycle(vInstance:IRecycle):void {
			var vClass:Class = getDefinitionByName(getQualifiedClassName(vInstance)) as Class;
			var pool:Array = _instance._m_poolDic[vClass] as Array;
			if (pool != null) {
				pool.push(vInstance);
			}
		}
		
		public static function getTree(vPosition:Position):Tree {
			return (getInstance(Tree) as Tree).init(vPosition);
		}
		
		//public static function getMainRole(vPosition:Position):MainRole {
			//return (getInstance(MainRole) as MainRole).init(vPosition);
		//}
		
		public static function getPosition(vGridX:int = 0, vGridY:int = 0, 
									vInsideX:Number = -1, vInsideY:Number = -1,
									vElevation:Number = 0):Position {
			return (getInstance(Position) as Position).init(vGridX, vGridY, vInsideX, vInsideY, vElevation);
		}
		
		public static function getMapBlock(vBlockX:int, VBlockY:int):MapBlock {
			return (getInstance(MapBlock) as MapBlock).init(vBlockX, VBlockY);
		}
		
		public static function getPhysicsComponent(vDisplay:IDisplay, vPosition:Position, vSpeed:Number, vLength:Number, vWidth:Number, vHeight:Number, vMass:Number, vPhysicsType:int):PhysicsComponent {
			return (getInstance(PhysicsComponent) as PhysicsComponent).init(vDisplay, vPosition, vSpeed, vLength, vWidth, vHeight, vMass, vPhysicsType);
		}
		
		public static function getSkill(vName:String, vOwnner:IPhysics, vPosition:Position, vDir:int, vSpeed:Number, vWeight:Number = 0):Skill {
			return (getInstance(Skill) as Skill).init(vName, vOwnner, vPosition, vDir, vSpeed, vWeight);
		}
		
		public static function getEnergyVector(vDir:int, vEnergy:Number):EnergyVector {
			return (getInstance(EnergyVector) as EnergyVector).init(vDir, vEnergy);
		}
		
	}

}