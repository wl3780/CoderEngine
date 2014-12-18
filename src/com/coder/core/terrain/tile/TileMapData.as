package com.coder.core.terrain.tile
{
	import com.coder.core.displays.world.Scene;
	import com.coder.core.protos.Proto;
	import com.coder.core.terrain.TileConst;
	import com.coder.engine.Asswc;
	import com.coder.global.EngineGlobal;
	import com.coder.utils.Hash;
	import com.coder.utils.log.Log;
	
	import flash.utils.ByteArray;
	
	public class TileMapData extends Proto
	{
		public var map_id:int;
		public var pixel_width:int;
		public var pixel_height:int;
		public var len:int;
		public var items:Array;
		public var sceneData:Object;
		public var width:int;
		public var height:int;
		public var pixel_x:int;
		public var pixel_y:int;
		public var imageIndexHash:Hash;
		public var scene_id:String;

		public function prasePro(x:int, y:int, pro:int):Tile
		{
			var color:int;
			var tile:Tile = Tile.createTile();
			var str:String = pro.toString();
			tile.type = str.slice(1, 2) as int;
			tile.initValue = tile.type;
			tile.isSafe = str.slice(2, 3) as Boolean;
			tile.isSell = str.slice(3, 4) as Boolean;
			tile.isAlpha = str.slice(4, 5) as Boolean;
			tile.setXY(x, y);
			if (tile.type > 0) {
				color = 0xFF00;
			} else {
				color = 0xFF0000;
			}
			return tile;
		}
		
		public function praseLayerpro(id:String, x:int, y:int, dir:int):ItemData
		{
			var result:ItemData = new ItemData();
			result.x = x;
			result.y = y;
			result.item_id = id;
			result.dir = dir;
			return result;
		}
		
		public function uncode(bytes:ByteArray, hash:Hash=null):void
		{
			if (bytes == null) {
				return;
			}
			var tile:Tile = null;
			var data:ItemData = null;
			var tile_x:int;
			var tile_y:int;
			var p_id:String = null;
			var px:int;
			var py:int;
			var dir:int;
			var index_x:int;
			var index_y:int;
			var key:String = null;
			imageIndexHash = new Hash();
			bytes.position = 0;
			this.items = [];
			try {
				bytes.uncompress();
			} catch(e:Error) {
				Log.error(this, e.getStackTrace());
			}
			bytes.position = 0;
			this.map_id = bytes.readShort();
			this.pixel_x = bytes.readShort();
			this.pixel_y = bytes.readShort();
			this.pixel_width = bytes.readShort();
			this.pixel_height = bytes.readShort();
			
			var index:int = 0;
			var len:int = bytes.readInt();
			Scene.scene.topLayer.graphics.clear();
			while (index < len) {
				tile_x = bytes.readShort();
				tile_y = bytes.readShort();
				index_x = (tile_x * TileConst.TILE_WIDTH) / EngineGlobal.IMAGE_WIDTH;
				index_y = (tile_y * TileConst.TILE_HEIGHT) / EngineGlobal.IMAGE_HEIGHT;
				key = index_x + Asswc.LINE + index_y;
				imageIndexHash.put(key, {
					scene_id:scene_id.toString(),
					key:key,
					dis:0,
					index_x:index_x,
					index_y:index_y
				}, true);
				tile = this.prasePro(tile_x, tile_y, bytes.readShort());
				if (tile_x >= 0 && tile_y >= 0) {
					if (hash) {
						hash.put(tile.key, tile);
					} else {
						TileGroup.instance.put(tile.key, tile);
					}
				}
				index++;
			}
			
			len = bytes.readShort();
			index = 0;
			while (index < len) {
				p_id = bytes.readUTF();
				px = bytes.readInt();
				py = bytes.readInt();
				dir = bytes.readByte();
				data = this.praseLayerpro(p_id, px, py, dir);
				this.items.push(data);
				index++;
			}
		}

	}
} 
