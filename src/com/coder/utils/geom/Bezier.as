package com.coder.utils.geom
{
	import flash.geom.Point;

	/**
	 * 贝塞尔曲线
	 */	
	public class Bezier
	{
		public function Bezier()
		{
		}
		
		/**
		 * 三次贝塞尔曲线
		 * @param p1
		 * @param p2
		 * @param c1
		 * @param c2
		 * @param num
		 * @return 
		 */		
		public static function drawBezier3(p1:Point, p2:Point, c1:Point, c2:Point, num:int=10):Array
		{
			var t:Number = 0;
			var rt:Number;
			var pos_x:Number;
			var pos_y:Number;
			var delta:Number = 1 / num;
			var result:Array = [];
			while (t <= 1) {
				rt = 1 - t;
				pos_x = Math.pow(rt, 3) * p1.x + 3 * c1.x * t * Math.pow(rt, 2) + 3 * c2.x * Math.pow(t, 2) * rt + p2.x * Math.pow(t, 3);
				pos_y = Math.pow(rt, 3) * p1.y + 3 * c1.y * t * Math.pow(rt, 2) + 3 * c2.y * Math.pow(t, 2) * rt + p2.y * Math.pow(t, 3);
				result.push(new Point(pos_x, pos_y));
				t = t + delta;
			}
			return result;
		}
		
		/**
		 * 二次贝塞尔曲线
		 * @param p1
		 * @param p2
		 * @param c
		 * @param num
		 * @return 
		 */		
		public static function drawBezier(p1:Point, p2:Point, c:Point, num:int=40):Array
		{
			var pos_x:Number;
			var pos_y:Number;
			var delta:Number = 1 / num;
			var t:Number = 0;
			var path:Array = [];
			while (t <= 1) {
				pos_x = Math.pow((1 - t), 2) * p1.x + 2 * t * (1 - t) * c.x + Math.pow(t, 2) * p2.x;
				pos_y = Math.pow((1 - t), 2) * p1.y + 2 * t * (1 - t) * c.y + Math.pow(t, 2) * p2.y;
				path.push(new Point(pos_x, pos_y));
				t = (t + delta);
			}
			return path;
		}
	}
}