package com.coder.core.displays.world.char
{
	import com.coder.core.controls.elisor.HeartbeatFactory;
	import com.coder.core.displays.DisplaySprite;
	import com.coder.utils.BitmapScale9Grid;
	
	import flash.display.BitmapData;
	import flash.display.Shape;
	import flash.filters.GlowFilter;
	import flash.geom.Rectangle;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.utils.clearTimeout;
	import flash.utils.setTimeout;
	
	import flashx.textLayout.formats.TextAlign;

	public class WordShape extends DisplaySprite
	{
		public static var _backgroundBitmap_:BitmapData = new BitmapData(71, 41, false, 0);
		public static var _backgroundBitmap_2:BitmapData;
		public static var backgroundBitmapRect:Rectangle = new Rectangle(5, 5, 50, 16);
		
		private static var _textColor_:uint = 0xFFFFFF;
		private static var _filter_:Array = [new GlowFilter(0, 1, 2, 2)];
		private static var bitmapScale9Grid:BitmapScale9Grid = new BitmapScale9Grid();

		public var wordTxt:TextField;
		public var state:String = "show";
		
		private var textFromat:TextFormat;
		private var timeIndex:int;
		private var shape:Shape;

		public function WordShape()
		{
			super();
			textFromat = new TextFormat(null, 12, 0xE1E1E1);
			shape = new Shape();
			addChild(shape);
			this.width = 160;
			this.height = 41;
		}
		
		public function sayWord(text:String, showTime:int=8000):void
		{
			var wordWidth:int;
			var wordHeight:int;
			if (text && text != "") {
				clearTimeout(timeIndex);
				if (this.wordTxt == null) {
					this.wordTxt = new TextField();
					this.wordTxt.textColor = _textColor_;
					wordTxt.defaultTextFormat = textFromat;
					this.wordTxt.filters = _filter_;
					this.wordTxt.cacheAsBitmap = true;
					this.wordTxt.mouseEnabled = false;
					this.wordTxt.mouseWheelEnabled = false;
					this.wordTxt.selectable = false;
					this.wordTxt.width = 150;
					this.wordTxt.wordWrap = true;
					this.wordTxt.multiline = true;
				}
				this.wordTxt.width = 150;
				this.wordTxt.height = 80;
				this.wordTxt.htmlText = text;
				this.wordTxt.height = this.wordTxt.textHeight + 4;
				this.wordTxt.width = this.wordTxt.textWidth + 4;
				this.wordTxt.y = 5;
				this.wordTxt.x = 8;
				timeIndex = setTimeout(closeFunc, showTime);
				if (this.wordTxt.width > 160) {
					this.wordTxt.width = 160;
					this.wordTxt.x = (150 - this.wordTxt.textWidth) / 2;
				}
				this.wordTxt.defaultTextFormat = textFromat;
				this.addChild(this.wordTxt);
				bitmapScale9Grid.setup(_backgroundBitmap_, backgroundBitmapRect);
				textFromat.leading = 2;
				
				wordWidth = this.wordTxt.width + 20 - 4;
				wordHeight = this.wordTxt.height;
				if (wordTxt.length <= 12) {
					wordHeight = 32;
					wordTxt.y = 4;
					textFromat.align = TextAlign.CENTER;
				} else {
					wordHeight = 41;
					wordTxt.y = 5;
					textFromat.align = TextAlign.LEFT;
				}
				this.wordTxt.defaultTextFormat = textFromat;
				this.wordTxt.htmlText = text;
				
				bitmapScale9Grid.width = wordWidth;
				bitmapScale9Grid.height = wordHeight;
				if (wordWidth < 84) {
					wordWidth = 84;
					bitmapScale9Grid.width = wordWidth;
				}
				if (wordWidth > 150) {
					wordWidth = 160;
					bitmapScale9Grid.width = wordWidth;
				}
				bitmapScale9Grid.draw(this.graphics);
				this.alpha = 0;
				this.state = "show";
				HeartbeatFactory.getInstance().addFrameOrder(loop);
				if (_backgroundBitmap_2) {
					shape.graphics.beginBitmapFill(_backgroundBitmap_2);
					shape.graphics.drawRect(0, 0, _backgroundBitmap_2.width, (_backgroundBitmap_2.height - 1));
				}
				shape.x = (wordWidth / 2) - (shape.width / 2);
				shape.y = wordHeight;
				this.width = this.getBounds(null).width;
				this.height = (wordHeight + 9);
				if (this.parent) {
					(this.parent as CharHead).updateEffectPos();
				}
			} else {
				closeFunc();
			}
		}
		
		public function dealy():void
		{
		}
		
		public function closeFunc():void
		{
			this.state = "close";
			HeartbeatFactory.getInstance().addFrameOrder(loop);
		}
		
		public function closeFunc2():void
		{
			this.graphics.clear();
			if (wordTxt.parent) {
				wordTxt.parent.removeChild(this.wordTxt);
			}
			if (this.parent) {
				this.parent.removeChild(this);
			}
		}
		
		override public function dispose():void
		{
			clearTimeout(timeIndex);
			super.dispose();
		}
		
		public function loop():void
		{
			if (this.state == "show") {
				if (this.alpha < 1) {
					this.alpha = (this.alpha + 0.05);
				} else {
					this.alpha = 1;
					HeartbeatFactory.getInstance().removeFrameOrder(loop);
				}
			} else {
				if (this.alpha > 0) {
					this.alpha = (this.alpha - 0.05);
				} else {
					this.state = "normal";
					closeFunc2();
					this.alpha = 0;
					HeartbeatFactory.getInstance().removeFrameOrder(loop);
				}
			}
		}

	}
} 
