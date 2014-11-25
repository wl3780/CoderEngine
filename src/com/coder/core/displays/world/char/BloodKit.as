package com.coder.core.displays.world.char
{
	import flash.display.BitmapData;
	import flash.display.Shape;
	import flash.geom.Matrix;

	public class BloodKit extends Shape
	{
		private var bmd:BitmapData;
		private var currValue:Number;
		private var maxValue:Number;
		private var percent:Number = 0;
		private var _width:Number = 0;
		private var _height:Number = 0;
		private var _bitmapData:BitmapData;
		private var _overBitmapData:BitmapData;
		private var _color:uint;
		private var _isCharNameBitmapMode:Boolean;

		public function BloodKit(color:uint=0xFF0000)
		{
			_color = color;
			this.width = 40;
			this.height = 3;
			this.cacheAsBitmap = true;
		}
		
		public function set isCharNameBitmapMode(value:Boolean):void
		{
			_isCharNameBitmapMode = value;
		}
		
		public function set overBitmapData(value:BitmapData):void
		{
			_overBitmapData = value;
			this.onRender();
		}
		
		public function set bitmapData(value:BitmapData):void
		{
			_bitmapData = value;
			this.onRender();
		}
		
		public function setValue(currValue:int, maxValue:int):void
		{
			this.currValue = currValue;
			this.maxValue = maxValue;
			percent = ((currValue / maxValue) * 100) / 100;
			if (percent > 1) {
				percent = 1;
			}
			if (percent < 0) {
				percent = 0;
			}
			if (((currValue / maxValue) * 100) == 0) {
				percent = 0;
			}
			onRender();
		}
		
		public function onRender():void
		{
			this.graphics.clear();
			if (_bitmapData) {
				_height = _bitmapData.height + 1;
				_width = _bitmapData.width;
				this.graphics.beginBitmapFill(_bitmapData);
				this.graphics.drawRect(0, 0, _bitmapData.width, _bitmapData.height);
			} else {
				this.graphics.beginFill(_color);
				this.graphics.drawRect(0, 2, (this.width * percent), this.height);
			}
			this.graphics.endFill();
			if (_overBitmapData) {
				var matrix:Matrix = new Matrix();
				matrix.tx = 1;
				matrix.ty = 1;
				this.graphics.beginBitmapFill(_overBitmapData, matrix);
				this.graphics.drawRect(matrix.tx, matrix.ty, (_overBitmapData.width * percent), _overBitmapData.height);
				this.graphics.endFill();
			} else {
				this.graphics.lineStyle(0.1, 0);
				this.graphics.drawRect(0, 2, width, height);
				this.graphics.endFill();
			}
		}
		
		override public function set width(value:Number):void
		{
			_width = value;
			onRender();
		}
		
		override public function set height(value:Number):void
		{
			_height = value;
			onRender();
		}
		
		override public function get width():Number
		{
			return _width;
		}
		
		override public function get height():Number
		{
			return _height;
		}

	}
} 
