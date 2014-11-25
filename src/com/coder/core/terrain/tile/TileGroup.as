package com.coder.core.terrain.tile
{
	import com.coder.utils.Hash;
	
	import flash.geom.Point;

	public dynamic class TileGroup extends Hash
	{
		private static var _instance_:TileGroup;

		public static function get instance():TileGroup
		{
			return _instance_ ||= new TileGroup();
		}

		public function get8GridsKeys(pt:Point):Array
		{
			var key:String = null;
			var result:Array = [];
			var px:int = pt.x;
			var py:int = pt.y;
			var dx:int = px - 1;
			var dy:int;
			while (dx <= (px + 1)) {
				dy = py - 1;
				while (dy <= (py + 1)) {
					key = dx + "|" + dy;
					result.push(key);
					dy++;
				}
				dx++;
			}
			return result;
		}
		
		public function get8Grids(pt:Point, size:int=1):Array
		{
			var key:String = null;
			var tile:Tile = null;
			var result:Array = [];
			var px:int = pt.x;
			var py:int = pt.y;
			var dx:int = px - size;
			var dy:int;
			while (dx <= (px + size)) {
				dy = py - size;
				while (dy <= (py + size)) {
					key = dx + "|" + dy;
					if (key != (pt.x + "|" + pt.y)) {
						tile = take(key) as Tile;
						if (tile && tile.type > 0) {
							result.push(TileUtils.tileToPixels(new Point(dx, dy)));
						}
					}
					dy++;
				}
				dx++;
			}
			return result;
		}

	}
} 
