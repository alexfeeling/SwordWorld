package com.alex.skill 
{
	import flash.geom.Point;
	/**
	 * ...
	 * @author alex
	 */
	public class SkillData 
	{
		
		public var name:String;
		///是否单人伤害
		public var isSingleHurt:Boolean = true;
		///伤害范围，以格子行列数表示
		public var rangeOfHurt:Point;
		
		///最大作用目标个数
		public var maxImpactNum:int = 1;
		
		/**
		 * 技能类型：0锐器，1钝器，2拳脚，3内功
		 */
		public var type:int = 0;
		
		public function SkillData() 
		{
			
		}
		
	}

}