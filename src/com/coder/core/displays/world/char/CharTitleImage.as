package com.coder.core.displays.world.char
{
	import com.coder.core.controls.wealth.WealthQueueGroup;
	import com.coder.core.displays.avatar.AvatarEffect;
	import com.coder.core.displays.items.Image;
	import com.coder.core.displays.items.ImageLoader;
	import com.coder.core.events.WealthEvent;
	import com.coder.utils.Hash;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.geom.Matrix;
	import flash.geom.Rectangle;
	import flash.net.URLRequest;
	
	public class CharTitleImage extends Image
	{
		private static var hash:Hash = new Hash();
		private static var _limitIndex_:int = 4;
		private static var wealthQuene:Array = [];
		private static var _wealthQuene_:WealthQueueGroup;
		private static var intanceHash:Vector.<CharTitleImage> = new Vector.<CharTitleImage>();

		public var onReanderFunc:Function;
		
		private var tileDatas:Object;
		private var effectHash:Array;
		private var _list:Array;
		private var _char:Char;
		private var _urlList:Array;
		private var _count:int = 0;

		public function CharTitleImage(char:Char)
		{
			tileDatas = {
				"97_1":"jm1052",
				"97_2":"jm1053",
				"97_3":"jm1054",
				98:"jm1056",
				99:"jm1055"
			}
			effectHash = [];
			super();
			_char = char;
			if (_wealthQuene_ == null) {
				_wealthQuene_ = new WealthQueueGroup();
				_wealthQuene_.addEventListener(WealthEvent.WEALTH_COMPLETE, loadedFunc);
			}
		}
		
		public static function createCharTitleImage(char:Char):CharTitleImage
		{
			var result:CharTitleImage = null;
			if (intanceHash.length) {
				result = intanceHash.pop();
				result.resetForDisposed();
				result._char = char;
				if (_wealthQuene_ == null) {
					_wealthQuene_ = new WealthQueueGroup();
					_wealthQuene_.addEventListener(WealthEvent.WEALTH_COMPLETE, result.loadedFunc);
				}
			} else {
				result = new CharTitleImage(char);
			}
			return result;
		}

		public function set char(value:Char):void
		{
			_char = value;
		}
		public function get char():Char
		{
			return _char;
		}
		
		public function setTiles(value:Array, type:int=0):void
		{
			if (type == 0) {
				_list = value;
				showTitle();
			} else {
				dynamicTiles = value;
			}
		}
		
		public function set dynamicTiles(value:Array):void
		{
			_list = value;
			showTitle2();
		}
		
		private function showTitle2():void
		{
			this.graphics.clear();
			
			var titleData:Object = null;
			var oldEffect:AvatarEffect = null;
			var newEffect:AvatarEffect = null;
			var title_id:String = null;
			var title_name:String = null;
			
			var index:int = 0;
			var len:int = effectHash.length;
			while (index < effectHash.length) {
				if (effectHash.length) {
					oldEffect = effectHash[index];
					oldEffect.dispose();
				}
				index++;
			}
			effectHash.length = 0;
			
			_urlList = [];
			index = 0;
			len = _list.length;
			while (index < len) {
				titleData = _list[index];
				if (titleData.type == 1) {
					_urlList.push(titleData.icon);
					newEffect = new AvatarEffect();
					newEffect.name = "tile";
					titleData.icont;
					title_id = tileDatas[titleData.titleId];
					newEffect.loadEffect(title_id, null, titleData.icon, false, 0, 0, 0, -1, 0);
					newEffect.play("stand");
					newEffect.y = -effectHash.length * 70 - 40;
					if (titleData.titleId == "98") {
						newEffect.y = newEffect.y + 20;
					}
					addChild(newEffect);
					effectHash.push(newEffect);
				} else {
					title_name = titleData.titleName;
				}
				index ++;
			}
			if (title_name != null) {
				_char.charProfessionNameVisible = true;
				_char.charProfessionName = title_name;
			} else {
				_char.charProfessionNameVisible = false;
				_char.charProfessionName = null;
			}
			if (onReanderFunc != null) {
				onReanderFunc();
			}
		}
		
		private function showTitle():void
		{
			var titleData:Object = null;
			var title_name:String = null;
			var effect:AvatarEffect = null;
			
			this.graphics.clear();
			
			var index:int = 0;
			var len:int = effectHash.length;
			while (index < len) {
				if (effectHash.length){
					effect = effectHash[index];
					effect.dispose();
				}
				index ++;
			}
			effectHash.length = 0;
			
			_urlList = [];
			index = 0;
			len = _list.length;
			while (index < len) {
				titleData = _list[index];
				if (titleData.type == 1) {
					_urlList.push(titleData.icon);
				} else {
					title_name = titleData.titleName;
				}
				index++;
			}
			if (title_name != null) {
				_char.charProfessionNameVisible = true;
				_char.charProfessionName = title_name;
			} else {
				_char.charProfessionNameVisible = false;
				_char.charProfessionName = null;
			}
			if (_urlList.length > 0) {
				onComplete = onComplete2;
				index = 0;
				while (index < _urlList.length) {
					this.load2(_urlList[index] as String);
					index++;
				}
			}
		}
		
		private function onComplete2():void
		{
			_count = _count + 1;
			var datas:Array = [];
			var index:int = 0;
			while (index < _urlList.length) {
				if (hash.has(_urlList[index])) {
					datas.push(hash.take(_urlList[index]));
				}
				index ++;
			}
			drawTitle2(datas);
		}
		
		protected function drawTitle2(array:Array):void
		{
			this.graphics.clear();
			var tmpData:BitmapData = null;
			var matrix:Matrix = null;
			var toX:Number;
			var toY:Number;
			var rect:Rectangle = null;
			var toW:Number;
			var toH:Number;
			_height_ = 0;
			var index:int = 0;
			while (index < array.length) {
				tmpData = array[index];
				if (tmpData) {
					toX = borderWidth;
					toY = borderHeight;
					rect = getBounds(this);
					matrix = new Matrix();
					_height_ = rect.height;
					
					toX = -tmpData.width / 2;
					toY = -rect.height - borderHeight + tmpData.height;
					matrix.tx = matrix.tx + toX;
					matrix.ty = matrix.ty + toY;
					this.graphics.beginBitmapFill(tmpData, matrix, false, smooth);
					toW = tmpData.width - borderWidth * 2;
					toH = tmpData.height - borderHeight * 2;
					this.graphics.drawRect(toX, toY, toW, toH);
				}
				index++;
			}
			if (onReanderFunc != null) {
				onReanderFunc();
			}
		}
		
		override public function set source(value:Object):void
		{
		}
		
		private function load2(url:String):void
		{
			if (url != DEFAULT_IMAGE) {
				this.path = url;
			}
			var tmpData:BitmapData = hash.take(url) as BitmapData;
			if (tmpData) {
				this.bitmapData = tmpData;
				onComplete2();
			} else {
				var params:Object = {url:url}
				wealthQuene.push(params);
				loadImage();
			}
		}
		
		private function loadImage():void
		{
			var params:Object = null;
			var url:String = null;
			var loader:ImageLoader = null;
			while (wealthQuene.length) {
				params = wealthQuene.shift();
				url = params.url;
				loader = new ImageLoader();
				loader.data = params;
				loader.contentLoaderInfo.addEventListener(Event.COMPLETE, loadedFunc);
				loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, loadErrorFunc);
				loader.load(new URLRequest(url));
			}
		}
		
		override protected function loadFinish():void
		{
		}
		
		private function loadedFunc(e:Event):void
		{
			var loader:ImageLoader = e.target.loader as ImageLoader;
			loader.contentLoaderInfo.removeEventListener(Event.COMPLETE, loadedFunc);
			loader.contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR, loadErrorFunc);
			var tmpBitmap:Bitmap = loader.content as Bitmap;
			var tmpData:BitmapData = tmpBitmap.bitmapData.clone();
			hash.put(loader.data.url, tmpData);
			loader.dispose();
			this.onComplete2();
			loadImage();
		}
		
		private function loadErrorFunc(e:IOErrorEvent):void
		{
			var loader:ImageLoader = e.target.loader as ImageLoader;
			loader.contentLoaderInfo.removeEventListener(Event.COMPLETE, loadedFunc);
			loader.contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR, loadErrorFunc);
			if (DEFAULT_IMAGE) {
				var tmpData:BitmapData = hash.take(DEFAULT_IMAGE) as BitmapData;
				if (tmpData) {
					this.bitmapData = tmpData;
				} else {
					this.load2(DEFAULT_IMAGE);
				}
			}
			loadImage();
		}
		
		override public function resetForDisposed():void
		{
			super.resetForDisposed();
		}
		
		override public function dispose():void
		{
			var effect:AvatarEffect = null;
			var index:int = 0;
			while (index < effectHash.length) {
				if (effectHash.length) {
					effect = effectHash[index];
					effect.dispose();
				}
				index++;
			}
			effectHash = [];
			_list = [];
			_char = null;
			_urlList = [];
			this.onComplete = null;
			this.onReanderFunc = null;
			super.dispose();
		}

	}
} 
