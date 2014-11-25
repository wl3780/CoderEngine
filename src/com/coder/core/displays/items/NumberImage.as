package com.coder.core.displays.items
{
	import flash.display.Graphics;
	import flash.display.Shape;
	import flash.utils.Dictionary;

	public class NumberImage
	{
		private static var _instance:NumberImage;

		private var dic:Dictionary;
		public var hspace:Number = -6;

		public function NumberImage()
		{
			dic = new Dictionary();
		}
		
		public static function getInstance():NumberImage
		{
			return _instance ||= new NumberImage();
		}

		public function hasURL(url:String):Boolean
		{
			return dic[url] != null;
		}
		
		public function pushURL(url:String, desc:NumberDesc):void
		{
			dic[url] = desc;
		}
		
		public function getNumberDesc(url:String):NumberDesc
		{
			return dic[url];
		}
		
		public function toImage(countStr:String, url:String="num.png", graphics:Graphics=null, type:int=-1):Shape
		{
			var image:ImageShape = new ImageShape(graphics);
			image.toImage(countStr, url, type);
			image.cacheAsBitmap = true;
			return image;
		}
		
		public function toImageNum(countStr:String, url:String="num.png", graphics:Graphics=null):Shape
		{
			var image:ImageShape = new ImageShape(graphics);
			image.toImageNum(countStr, url);
			image.cacheAsBitmap = true;
			return image;
		}

	}
}

import com.coder.core.displays.items.NumberImage;

import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.Graphics;
import flash.display.Loader;
import flash.display.Shape;
import flash.events.Event;
import flash.events.IOErrorEvent;
import flash.geom.Matrix;
import flash.geom.Point;
import flash.geom.Rectangle;
import flash.net.URLRequest;

class ImageShape extends Shape
{
	public var url:String;
	public var hspace:Number = -3.5;
	public var type:int = 0;
	
	private var countStr:String;
	private var gr:Graphics;

	public function ImageShape(graphics:Graphics)
	{
		if (graphics != null) {
			this.gr = graphics;
		} else {
			this.gr = this.graphics;
		}
	}
	
	public function load():void
	{
		var loader:Loader = new Loader();
		loader.contentLoaderInfo.addEventListener(Event.COMPLETE, onLoadComplete);
		loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, ioerrorFunc);
		loader.load(new URLRequest(url));
	}
	
	public function load2():void
	{
		var loader:Loader = new Loader();
		loader.contentLoaderInfo.addEventListener(Event.COMPLETE, onLoadComplete2);
		loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, ioerrorFunc);
		loader.load(new URLRequest(url));
	}
	
	private function ioerrorFunc(e:IOErrorEvent):void
	{
		e.target.removeEventListener(IOErrorEvent.IO_ERROR, ioerrorFunc);
	}
	
	private function onLoadComplete2(event:Event):void
	{
		var rect:Rectangle = null;
		var tmpData:BitmapData = null;
		var numDesc:NumberDesc = new NumberDesc();
		numDesc.numBitmapData = (event.currentTarget.content as Bitmap).bitmapData;
		numDesc.numberWidth = numDesc.numBitmapData.width / 10;
		numDesc.numberHeight = numDesc.numBitmapData.height;
		for (var index:int = 0; index < 10; index++) {
			rect = new Rectangle((index * numDesc.numberWidth), 0, numDesc.numberWidth, numDesc.numberHeight);
			tmpData = new BitmapData(numDesc.numberWidth, numDesc.numberHeight, true, 0xFFFFFF);
			tmpData.copyPixels(numDesc.numBitmapData, rect, new Point(0, 0));
			numDesc.numArray[index] = tmpData;
		}
		NumberImage.getInstance().pushURL(url, numDesc);
		toImageNum(countStr, url);
	}
	
	private function onLoadComplete(event:Event):void
	{
		var tmpData:BitmapData = null;
		var rect:Rectangle = null;
		var numDesc:NumberDesc = new NumberDesc();
		numDesc.numBitmapData = (event.currentTarget.content as Bitmap).bitmapData;
		numDesc.numberWidth = numDesc.numBitmapData.width / 12;
		numDesc.numberHeight = numDesc.numBitmapData.height;
		for (var index:int = 0; index < 12; index++) {
			rect = new Rectangle((index * numDesc.numberWidth), 0, numDesc.numberWidth, numDesc.numberHeight);
			tmpData = new BitmapData(numDesc.numberWidth, numDesc.numberHeight, true, 0xFFFFFF);
			tmpData.copyPixels(numDesc.numBitmapData, rect, new Point(0, 0));
			numDesc.numArray[index] = tmpData;
		}
		NumberImage.getInstance().pushURL(url, numDesc);
		toImage(countStr, url, this.type);
	}
	
	public function toImageNum(countStr:String, url:String):void
	{
		if (NumberImage.getInstance().hasURL(url)) {
			var numDesc:NumberDesc = NumberImage.getInstance().getNumberDesc(url);
			var pen:Graphics = gr;
			var bit:int;
			var numW:Number = numDesc.numberWidth + hspace;
			var tmpData:BitmapData = null;
			for (var index:int = 0, len:int = countStr.length; index < len; index ++) {
				bit = countStr.charAt(index) as int;
				tmpData = numDesc.numArray[bit] as BitmapData;
				pen.beginBitmapFill(tmpData, new Matrix(1, 0, 0, 1, (index * numW), 0), false);
				pen.drawRect((index * numW), 0, numDesc.numberWidth, numDesc.numberHeight);
				pen.endFill();
			}
		} else {
			this.countStr = countStr;
			this.url = url;
			this.type = type;
			load2();
		}
	}
	
	public function toImage(countStr:String, url:String, type:int=-1):void
	{
		if (NumberImage.getInstance().hasURL(url)) {
			var numDesc:NumberDesc = NumberImage.getInstance().getNumberDesc(url);
			var len:int = countStr.length;
			var pen:Graphics = gr;
			var numW:Number = numDesc.numberWidth + hspace;
			var state:int = (type > 0) ? 0 : 1;
			var tmpData:BitmapData = numDesc.numArray[state] as BitmapData;
			pen.beginBitmapFill(tmpData, new Matrix(1, 0, 0, 1, 0, 0), false);
			pen.drawRect(0, 0, numDesc.numberWidth, numDesc.numberHeight);
			pen.endFill();
			
			var bit:int;
			for (var index:int = 2; index < (len + 2); index ++) {
				bit = countStr.charAt(index - 2) as int;
				tmpData = numDesc.numArray[bit + 2] as BitmapData;
				pen.beginBitmapFill(tmpData, new Matrix(1, 0, 0, 1, ((index - 1) * numW), 0), false);
				pen.drawRect(((index - 1) * numW), 0, numDesc.numberWidth, numDesc.numberHeight);
				pen.endFill();
			}
		} else {
			this.countStr = countStr;
			this.url = url;
			this.type = type;
			load();
		}
	}

}

class NumberDesc
{
	public var numBitmapData:BitmapData;
	public var numArray:Array;
	public var numberWidth:Number;
	public var numberHeight:Number;

	public function NumberDesc()
	{
		numArray = [];
	}
}
