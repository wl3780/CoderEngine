package com.coder.core.terrain.tile
{
	import flash.geom.Point;

	public final class Tile
	{
		private static var _tileHash_:Vector.<Tile> = new Vector.<Tile>();

		public var initValue:int;
		public var type:int;
		public var isSell:Boolean;
		public var isSafe:Boolean;
		public var isAlpha:Boolean;
		public var _pt_:Point;
		public var quoteIndex:int;
		public var charIndex:int;
		
		private var _x_:int;
		private var _y_:int;
		private var _key_:String;

		public function Tile()
		{
			super();
			_pt_ = new Point();
		}
		
		public static function createTile():Tile
		{
			if (_tileHash_.length) {
				return _tileHash_.pop();
			}
			return new Tile();
		}

		public function setTileIndex(x:Number, y:Number):void
		{
			TileUtils.pixelsToTile(x, y, _pt_);
		}
		
		public function setXY(x:int, y:int):void
		{
			_x_ = x;
			_y_ = y;
			_pt_.x = x;
			_pt_.y = y;
			_key_ = _x_ + "|" + _y_;
		}
		
		public function set x(value:int):void
		{
			_x_ = value;
			_pt_.x = value;
			_key_ = _x_ + "|" + _y_;
		}
		
		public function set y(value:int):void
		{
			_y_ = value;
			_pt_.y = value;
			_key_ = _x_ + "|" + _y_;
		}
		
		public function get x():int
		{
			return _x_;
		}
		
		public function get y():int
		{
			return _y_;
		}
		
		public function get pt():Point
		{
			return _pt_;
		}
		
		public function get key():String
		{
			return _key_;
		}

	}
} 
