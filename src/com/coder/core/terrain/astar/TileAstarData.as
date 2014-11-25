package com.coder.core.terrain.astar
{
	import flash.geom.Point;

	public class TileAstarData
	{
		public var key:String;
		public var pt:Point;
		public var G:int = 0;
		public var F:int = 0;
		public var parent:TileAstarData;

		public function TileAstarData(g:int, f:int, pt:Point)
		{
			this.G = g;
			this.F = f;
			if (pt) {
				this.key = pt.x + "|" + pt.y;
			}
			this.pt = pt;
		}
	}
} 
