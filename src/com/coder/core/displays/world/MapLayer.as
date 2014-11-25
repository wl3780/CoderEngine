package com.coder.core.displays.world
{
	import com.coder.core.controls.wealth.WealthStoragePort;
	import com.coder.core.displays.DisplaySprite;
	import com.coder.core.displays.avatar.AvatarRequestElisor;
	import com.coder.core.displays.items.unit.BingLoader;
	import com.coder.core.displays.items.unit.DisplayLoader;
	import com.coder.core.displays.items.unit.ProtoURLLoader;
	import com.coder.core.terrain.tile.TileGroup;
	import com.coder.core.terrain.tile.TileMapData;
	import com.coder.engine.Asswc;
	import com.coder.engine.Engine;
	import com.coder.global.EImageLoadQueue;
	import com.coder.global.EngineGlobal;
	import com.coder.interfaces.display.ITerrain;
	import com.coder.utils.Hash;
	import com.coder.utils.log.Log;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Graphics;
	import flash.display.Loader;
	import flash.display.Shape;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.TimerEvent;
	import flash.filters.BlurFilter;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.net.URLRequest;
	import flash.system.ImageDecodingPolicy;
	import flash.system.LoaderContext;
	import flash.utils.ByteArray;
	import flash.utils.Dictionary;
	import flash.utils.Timer;
	import flash.utils.getTimer;
	import flash.utils.setTimeout;

	public class MapLayer extends DisplaySprite implements ITerrain
	{
		public static var loadMiniJPGBytesHash:Hash = new Hash();
		public static var imagePathHash:Dictionary = new Dictionary();
		public static var ImageLoadQueue:Array;
		public static var loadFunc:Function;

		private static var loaderQueue:Vector.<Loader> = new Vector.<Loader>();
		private static var _instance:MapLayer;

		public var _limitIndex_:int = 15;
		public var mapdata:TileMapData;
		public var clearing:Boolean = false;
		public var loadInterval:int;
		public var backgroundLoadTime:int;
		
		private var mapdataHash:Hash;
		private var tar_rect:Rectangle;
		private var stage_rect:Rectangle;
		private var stageIndexW:int = 3;
		private var stageIndexH:int = 3;
		private var tar_point:Point;
		private var stage_point:Point;
		private var mat:Matrix;
		private var _general_limitIndex_:int = 4;
		private var loaderContext:LoaderContext;
		private var RequestQueue:Vector.<Number>;
		private var loadHash:Hash;
		private var requestHash:Hash;
		private var scene_id:String = "";
		private var miniShape:Shape;
		private var mapdataLoader:ProtoURLLoader;
		private var isReady:Boolean;
		private var bg_bmd:BitmapData;
		private var timer:Timer;
		private var changeSceneTime:int = 0;
		private var protoLoader:ProtoURLLoader;
		private var loader:Loader;
		private var renderImageTime:int = 0;
		private var loadImageTime:int = 0;
		private var interval:int = 0;
		private var tmpArray:Array;
		private var imageKeyQueue:Array;
		private var indexX:int = 0;
		private var indexY:int = 0;

		public function MapLayer()
		{
			mapdataHash = new Hash();
			tar_rect = new Rectangle(0, 0, 320, 180);
			stage_rect = new Rectangle();
			tar_point = new Point();
			stage_point = new Point();
			mat = new Matrix();
			loaderContext = new LoaderContext();
			RequestQueue = new Vector.<Number>();
			loadHash = new Hash();
			requestHash = new Hash();
			miniShape = new Shape();
			mapdata = new TileMapData();
			timer = new Timer(0);
			protoLoader = new ProtoURLLoader();
			loader = new Loader();
			tmpArray = [];
			imageKeyQueue = [];
			
			super();
			setup();
		}
		
		public static function get terrain():MapLayer
		{
			return _instance ||= new MapLayer();
		}

		public function setup():void
		{
			this.mouseEnabled = false;
			this.mouseChildren = false;
			this.tabEnabled = false;
			this.tabChildren = false;
			
			_instance = this;
			loaderContext.imageDecodingPolicy = ImageDecodingPolicy.ON_LOAD;
			for (var count:int = 1600; count > 0; count--) {
				loaderQueue.push(new Loader());
			}
			timer.addEventListener(TimerEvent.TIMER, timerFunc);
			timer.start();
		}
		
		public function changeScene(to_scene:String):void
		{
			var tmp_id:* = this.scene_id;
			this.scene_id = to_scene;
			_limitIndex_ = 15;
			if (to_scene != tmp_id) {
				clean();
				changeSceneTime = getTimer();
				loadMapData(to_scene);
			}
			return;
			setTimeout(function ():void{
				_limitIndex_ = _limitIndex_ > _general_limitIndex_ ? _general_limitIndex_ : _limitIndex_;
			}, 4000)
		}
		
		protected function miniJPGLoadFunc(event:Event):void
		{
			protoLoader.removeEventListener(Event.COMPLETE, miniJPGLoadFunc);
			protoLoader.removeEventListener(IOErrorEvent.IO_ERROR, errorFunc);
			if (!loadMiniJPGBytesHash.has(protoLoader.name)) {
				loadMiniJPGBytesHash.put(protoLoader.name, protoLoader);
			}
			loadMiniJPG(event.target.data, protoLoader.name);
		}
		
		public function loadMiniJPG(bytes:ByteArray, path:String):void
		{
			if (loader) {
				this.loader.contentLoaderInfo.removeEventListener(Event.COMPLETE, miniMapLoadedFunc);
				this.loader.contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR, errorFunc);
				this.loader.contentLoaderInfo.removeEventListener(Event.UNLOAD, unloadedFunc);
				loader.unloadAndStop();
			}
			bytes.position = 0;
			this.isReady = true;
			loader = new Loader();
			loader.name = path;
			this.loader.loadBytes(bytes);
			this.loader.contentLoaderInfo.addEventListener(Event.COMPLETE, miniMapLoadedFunc);
			this.loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, errorFunc);
			this.loader.contentLoaderInfo.addEventListener(Event.UNLOAD, unloadedFunc);
			loadImage();
			setupProLoader();
		}
		
		private function setupProLoader():void{
			var _local4:int;
			var _local1 = null;
			var _local3 = null;
			imageKeyQueue = [];
			if (((ImageLoadQueue) && (ImageLoadQueue.length))) {
				_local4 = 0;
				while (_local4 < ImageLoadQueue.length) {
					_local1 = ((((((((EngineGlobal.SCENE_IMAGE_DIR + "map_image/scene_") + scene_id) + "/") + ImageLoadQueue[_local4][0]) + Asswc.LINE) + ImageLoadQueue[_local4][1]) + ".jpg?ver=") + EngineGlobal.version);
					if (((!(requestHash.has(_local1))) && (EImageLoadQueue[("imageQueue_" + scene_id)]))) {
						_local3 = ((ImageLoadQueue[_local4][0] + Asswc.LINE) + ImageLoadQueue[_local4][1]);
						imageKeyQueue.push({
							scene_id:scene_id,
							key:_local3,
							dis:0,
							index_x:ImageLoadQueue[_local4][0],
							index_y:ImageLoadQueue[_local4][1]
						});
					}
					_local4++;
				}
			} else {
				for each (var _local2:Object in mapdata.imageIndexHash) {
					if (imageKeyQueue.length < 500) {
						imageKeyQueue.push(_local2);
					}
				}
			}
		}
		
		protected function unloadedFunc(event:Event):void
		{
		}
		
		private function setupScene():void
		{
			var _local1 = null;
			var _local2 = null;
			var _local3:String = ((((EngineGlobal.SCENE_IMAGE_DIR + "map_mini/scene_") + scene_id) + ".jpg?ver=") + EngineGlobal.version);
			if (WealthStoragePort.takeWealth(_local3) != null) {
				_local1 = (WealthStoragePort.takeWealth(_local3) as DisplayLoader);
				_local1.contentLoaderInfo.bytes;
				miniMapLoadedFunc(null, _local1);
			} else {
				loaderContext.imageDecodingPolicy = "onLoad";
				if (protoLoader) {
					protoLoader.removeEventListener(Event.COMPLETE, miniJPGLoadFunc);
					protoLoader.removeEventListener(IOErrorEvent.IO_ERROR, errorFunc);
				}
				if (!loadMiniJPGBytesHash.has(_local3)) {
					protoLoader = new ProtoURLLoader();
					protoLoader.name = _local3;
					protoLoader.dataFormat = "binary";
					protoLoader.addEventListener(Event.COMPLETE, miniJPGLoadFunc);
					protoLoader.addEventListener(IOErrorEvent.IO_ERROR, errorFunc);
					protoLoader.load(new URLRequest(_local3));
				} else {
					_local2 = (loadMiniJPGBytesHash.take(_local3) as ProtoURLLoader);
					loadMiniJPG(_local2.data, _local3);
				}
			}
		}
		private function loadMapData(scene_id:String):void{
			this.isReady = false;
			var _local3:String = ((((EngineGlobal.SCENE_IMAGE_DIR + "map_data/scene_") + scene_id) + ".data?ver=") + EngineGlobal.version);
			var _local2:BingLoader = (WealthStoragePort.takeWealth(_local3) as BingLoader);
			if (((mapdataHash.has(_local3)) || (_local2))) {
				if (_local2) {
					analyzeMapData((_local2.data as ByteArray));
				} else {
					analyzeMapData((mapdataHash.take(_local3).data as ByteArray));
				}
				setupProLoader();
				setupScene();
				Scene.scene.setupReady();
				isReady = true;
				loadHash.reset();
				stageIntersects(true);
			} else {
				if (mapdataLoader) {
					try {
						mapdataLoader.removeEventListener(Event.COMPLETE, onMapDataComplete);
						mapdataLoader.removeEventListener(IOErrorEvent.IO_ERROR, onMapDataError);
						mapdataLoader.close();
					} catch(e:Error) {
					}
				}
				mapdataLoader = new ProtoURLLoader();
				mapdataLoader.name = _local3;
				mapdataLoader.dataFormat = "binary";
				mapdataLoader.load(new URLRequest(_local3));
				mapdataLoader.addEventListener(Event.COMPLETE, onMapDataComplete);
				mapdataLoader.addEventListener(IOErrorEvent.IO_ERROR, onMapDataError);
			}
		}
		protected function onMapDataComplete(event:Event):void{
			setupScene();
			var _local2:ProtoURLLoader = (event.target as ProtoURLLoader);
			mapdataHash.put(_local2.name, _local2);
			analyzeMapData(_local2.data);
			Scene.scene.setupReady();
			AvatarRequestElisor.stop = false;
		}
		private function analyzeMapData(bytes:ByteArray):void{
			var _local5:Number;
			var _local4:Number;
			var _local2 = null;
			if (mapdataLoader) {
				mapdataLoader.removeEventListener(Event.COMPLETE, onMapDataComplete);
				mapdataLoader.removeEventListener(IOErrorEvent.IO_ERROR, onMapDataError);
			}
			TileGroup.instance.reset();
			mapdata.scene_id = scene_id;
			mapdata.uncode(bytes);
			mapdata.map_id = scene_id as int;
			var _local3:String = ((((EngineGlobal.SCENE_IMAGE_DIR + "map_mini/scene_") + scene_id) + ".jpg?ver=") + EngineGlobal.version);
			if (((!((WealthStoragePort.takeWealth(_local3) == null))) || ((loadMiniJPGBytesHash.take(_local3) as ProtoURLLoader)))) {
				if (bg_bmd) {
					_local5 = (mapdata.pixel_width / bg_bmd.width);
					_local4 = (mapdata.pixel_height / bg_bmd.height);
					this.graphics.clear();
					_local2 = new Matrix();
					_local2.scale(_local5, _local4);
					this.graphics.beginBitmapFill(bg_bmd, _local2, false);
					this.graphics.drawRect(0, 0, mapdata.pixel_width, mapdata.pixel_height);
				}
				loadHash.reset();
				stageIntersects(true);
			}
		}
		protected function errorFunc(event:IOErrorEvent):void{
			Log.error(this, ("小地图加载失败：" + scene_id));
			setupScene();
		}
		protected function onMapDataError(event:IOErrorEvent):void{
			Log.error(this, ("地图数据加载失败：" + event.target.name));
			mapdataHash.remove(event.target.name);
			loadMapData(scene_id);
		}
		private function miniMapLoadedFunc(e:Event=null, loaderx:Loader=null):void{
			e = e;
			loaderx = loaderx;
			this.graphics.clear();
			if (bg_bmd) {
				bg_bmd.dispose();
			}
			if (loaderx) {
				bg_bmd = BitmapData(Bitmap(loaderx.content).bitmapData).clone();
			} else {
				bg_bmd = BitmapData(e.target.loader.content.bitmapData).clone();
			}
			Scene.scene.miniBitmapReady(bg_bmd);
			var bmd:* = new BitmapData(bg_bmd.width, bg_bmd.height, true, 0);
			bmd.applyFilter(bg_bmd, bg_bmd.rect, new Point(), new BlurFilter(10, 10, 1));
			bg_bmd = bmd;
			var pixel_width:* = 6000;
			var pixel_height:* = 6000;
			if (mapdata) {
				pixel_width = mapdata.pixel_width;
				pixel_height = mapdata.pixel_height;
				var imageNum:* = ((pixel_width / 320) * (pixel_height / 180));
				var size:* = (loaderQueue.length - (imageNum * 0.7));
				if (size > 0) {
					loaderQueue.splice(((loaderQueue.length - size) + 1), size);
				} else {
					if (size < 0) {
						var n:* = Math.abs(size);
						while (n) {
							loaderQueue.push(new Loader());
							n = (n - 1);
						}
					}
				}
			}
			if (loader) {
				this.loader.unloadAndStop();
				setTimeout(function (_arg1):void{
					_arg1.contentLoaderInfo.removeEventListener(Event.COMPLETE, miniMapLoadedFunc);
					_arg1.contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR, errorFunc);
					_arg1.contentLoaderInfo.removeEventListener(Event.UNLOAD, unloadedFunc);
				}, 500, loader);
			}
			this.loader = null;
			if (bg_bmd) {
				var sw:* = (pixel_width / bg_bmd.width);
				var sh:* = (pixel_height / bg_bmd.height);
				this.graphics.clear();
				var mat:* = new Matrix();
				mat.scale(sw, sh);
				this.graphics.beginBitmapFill(bg_bmd, mat, false);
				this.graphics.drawRect(0, 0, pixel_width, pixel_height);
			}
			loadHash.reset();
			stageIntersects(true);
		}
		protected function timerFunc(event):void{
			loop();
		}
		public function loop():void{
			var _local1 = null;
			if (clearing) {
				return;
			}
			if (Engine.stage) {
				_local1 = new Point();
				_local1 = this.globalToLocal(_local1);
				this.stage_rect.x = _local1.x;
				this.stage_rect.y = _local1.y;
				this.stage_rect.width = Engine.stage.stageWidth;
				this.stage_rect.height = Engine.stage.stageHeight;
			}
			var _local2:int;
			loadImage();
			if ((getTimer() - loadImageTime) > _local2) {
				loadImageTime = getTimer();
				loopLoad();
			}
			stageIntersects();
		}
		private function getNear():Object{
			var _local5 = null;
			var _local8:int;
			var _local2:int;
			var _local7:int;
			stage_point.x = (Engine.stage.stageWidth / 2);
			stage_point.y = (Engine.stage.stageHeight / 2);
			stage_point = this.globalToLocal(stage_point);
			var _local4:int = (stage_point.x / 320);
			var _local6:int = (stage_point.y / 180);
			var _local1:Point = new Point();
			var _local3:Point = new Point(_local4, _local6);
			_local7 = 0;
			while (_local7 < imageKeyQueue.length) {
				_local1.x = imageKeyQueue[_local7].index_x;
				_local1.y = imageKeyQueue[_local7].index_y;
				imageKeyQueue[_local7].dis = (Math.abs((_local1.x - _local3.x)) + Math.abs((_local1.y - _local3.y)));
				if (_local7 == 0) {
					_local5 = imageKeyQueue[_local7];
					_local2 = _local7;
				} else {
					if (imageKeyQueue[_local7].dis < _local5.dis) {
						_local5 = imageKeyQueue[_local7];
						_local2 = _local7;
					}
				}
				_local7++;
			}
			return ({
				tar:_local5,
				index:_local2
			});
		}
		public function loopLoad():void{
			var _local4 = null;
			var _local7 = null;
			var _local6 = null;
			var _local3 = null;
			var _local5 = null;
			var _local2:Boolean;
			if (imageKeyQueue.length == 0) {
				return;
			}
			loadInterval = getTimer();
			var _local1 = 20;
			if ((getTimer() - changeSceneTime) < 8000) {
				_local1 = 0;
			}
			var _local9 = ((getTimer() - backgroundLoadTime) > _local1);
			if (_local9) {
				backgroundLoadTime = getTimer();
			}
			var _local8:int;
			while (_local8 < 4) {
				if (((imageKeyQueue.length) && ((_limitIndex_ > 0)))) {
					_local4 = getNear();
					_local7 = _local4.tar.key;
					_local6 = _local4.tar.scene_id;
					_local3 = _local7.split(Asswc.LINE);
					_local5 = new Rectangle();
					_local5.x = ((_local3[0] * 320) - 150);
					_local5.y = ((_local3[1] * 180) - 50);
					_local5.width = (320 + 300);
					_local5.height = (180 + 100);
					_local2 = stage_rect.intersects(_local5);
					_local2 = Scene.scene.mainChar.isRuning;
					if (((stage_rect.intersects(_local5)) || ((((((_limitIndex_ > 0)) || ((Scene.scene.mainChar.isRuning == false)))) && (_local9))))) {
						imageKeyQueue.splice(_local4.index, 1);
						if (_local6 == scene_id) {
							load(_local3[0], _local3[1]);
						}
					}
				}
				_local8++;
			}
		}
		public function loadImage():void{
			var _local8:int;
			if (!isReady) {
				return;
			}
			var _local3:Point = this.globalToLocal(new Point());
			var _local2:Point = this.globalToLocal(new Point(Engine.stage.stageWidth, Engine.stage.stageHeight));
			var _local7:int = (_local3.x / 320);
			var _local6:int = (_local3.y / 180);
			var _local4:int = (_local2.x / 320);
			var _local1:int = (_local2.y / 180);
			var _local9:int = Math.min(_local7, _local4);
			var _local10:int = Math.max(_local7, _local4);
			var _local5:int = Math.min(_local6, _local1);
			var _local12:int = Math.max(_local6, _local1);
			var _local11 = _local9;
			while (_local11 <= _local10) {
				_local8 = _local5;
				while (_local8 <= _local12) {
					loopImageLoadFunc(_local11, _local8);
					_local8++;
				}
				_local11++;
			}
		}
		private function loopImageLoadFunc(index_x:int, index_y:int):void{
			var _local5 = null;
			var _local3:Boolean;
			var _local6:int;
			if ((((index_x < 0)) || ((index_y < 0)))) {
				return;
			}
			var _local4:String = ((((((((EngineGlobal.SCENE_IMAGE_DIR + "map_image/scene_") + scene_id) + "/") + index_x) + Asswc.LINE) + index_y) + ".jpg?ver=") + EngineGlobal.version);
			if (requestHash.has(_local4)) {
				return;
			}
			tar_rect.x = (index_x * 320);
			tar_rect.y = (index_y * 180);
			if (stage_rect.intersects(tar_rect)) {
				_local5 = ((index_x + "_") + index_y);
				_local3 = false;
				_local6 = 0;
				while (_local6 < imageKeyQueue.length) {
					if (imageKeyQueue[_local6].key == _local5) {
						_local3 = true;
						break;
					}
					_local6++;
				}
				if (_local3 == false) {
					imageKeyQueue.push({
						scene_id:scene_id,
						key:_local5,
						dis:0,
						index_x:index_x,
						index_y:index_y
					});
				}
			}
		}
		private function load(index_x:int, index_y:int):void{
			var _local3 = null;
			var _local4:String = ((((((((EngineGlobal.SCENE_IMAGE_DIR + "map_image/scene_") + scene_id) + "/") + index_x) + Asswc.LINE) + index_y) + ".jpg?ver=") + EngineGlobal.version);
			if (((!(requestHash.has(_local4))) && ((_limitIndex_ > 0)))) {
				if (loaderQueue.length == 0) {
					_local3 = new Loader();
				}
				if (loaderQueue.length) {
					_local3 = loaderQueue.pop();
				}
				try {
					_local3.unload();
				} catch(e:Error) {
				}
				requestHash.put(_local4, _local3);
				_local3.name = _local4;
				_local3.x = (index_x * 320);
				_local3.y = (index_y * 180);
				_local3.load(new URLRequest(_local4), loaderContext);
				_local3.contentLoaderInfo.addEventListener(Event.COMPLETE, onLoadedFunc);
				_local3.contentLoaderInfo.addEventListener(Event.UNLOAD, onUnloadFunc);
				_local3.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, onErrorFunc);
				_limitIndex_ = (_limitIndex_ - 1);
			}
		}
		protected function onErrorFunc(event:IOErrorEvent):void{
			var _local2:Loader = (event.target.loader as Loader);
			_local2.contentLoaderInfo.removeEventListener(Event.COMPLETE, onLoadedFunc);
			_local2.contentLoaderInfo.removeEventListener(Event.UNLOAD, onUnloadFunc);
			_local2.contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR, onErrorFunc);
			requestHash.remove(event.target.loader.name);
			if (_limitIndex_ < _general_limitIndex_) {
				_limitIndex_ = (_limitIndex_ + 1);
			}
		}
		protected function onUnloadFunc(event:Event):void{
			var _local2:Loader = (event.target.loader as Loader);
			_local2.contentLoaderInfo.removeEventListener(Event.COMPLETE, onLoadedFunc);
			_local2.contentLoaderInfo.removeEventListener(Event.UNLOAD, onUnloadFunc);
			_local2.contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR, onErrorFunc);
			requestHash.remove(event.target.loader.name);
			if (_limitIndex_ < _general_limitIndex_) {
				_limitIndex_ = (_limitIndex_ + 1);
			}
		}
		protected function onLoadedFunc(event:Event):void{
			var _local2:Loader = (event.target.loader as Loader);
			_local2.contentLoaderInfo.removeEventListener(Event.COMPLETE, onLoadedFunc);
			_local2.contentLoaderInfo.removeEventListener(Event.UNLOAD, onUnloadFunc);
			_local2.contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR, onErrorFunc);
			if (_limitIndex_ < _general_limitIndex_) {
				_limitIndex_ = (_limitIndex_ + 1);
			}
		}
		public function stageIntersects(pass:Boolean=false):void{
			var _local13:int;
			if (!isReady) {
				return;
			}
			if ((((requestHash.length == 0)) && (!(pass)))) {
				return;
			}
			var _local9:Point = this.globalToLocal(new Point());
			var _local8:Point = this.globalToLocal(new Point(Engine.stage.stageWidth, Engine.stage.stageHeight));
			var _local12:int = (_local9.x / 320);
			var _local10:int = (_local9.y / 180);
			var _local3:int = (_local8.x / 320);
			var _local2:int = (_local8.y / 180);
			var _local5:int = Math.min(_local12, _local3);
			var _local6:int = Math.max(_local12, _local3);
			var _local4:int = Math.min(_local10, _local2);
			var _local7:int = Math.max(_local10, _local2);
			var _local11:int;
			while (_local11 <= _local6) {
				_local13 = _local4;
				while (_local13 <= _local7) {
					onRenderImageLoadFunc(_local11, _local13);
					_local13++;
				}
				_local11++;
			}
		}
		private function onRenderImageLoadFunc(index_x, index_y):void{
			var _local5 = null;
			var _local4 = null;
			var _local3 = null;
			tar_rect.x = (index_x * 320);
			tar_rect.y = (index_y * 180);
			if (stage_rect.intersects(tar_rect)) {
				_local5 = ((((((((EngineGlobal.SCENE_IMAGE_DIR + "map_image/scene_") + scene_id) + "/") + index_x) + Asswc.LINE) + index_y) + ".jpg?ver=") + EngineGlobal.version);
				if (loadHash.has(_local5) == false) {
					_local4 = (requestHash.take(_local5) as Loader);
					if (_local4) {
						_local3 = (_local4.content as Bitmap);
					}
					if (((((_local4) && (_local3))) && (_local3.bitmapData))) {
						loadHash.put(_local5, _local5);
						draw2(this.graphics, tar_rect.x, tar_rect.y, _local3.bitmapData);
					}
				}
			}
		}
		
		private function draw2(graphics:Graphics, x:int, y:int, bitmapData:BitmapData):void
		{
			var x_:int = x;
			var y_:int = y;
			mat.identity();	// 是否需要？
			mat.tx = x_;
			mat.ty = y_;
			this.graphics.beginBitmapFill(bitmapData, mat, false);
			var w_:int = x_ + bitmapData.width;
			var h_:int = y_ + bitmapData.height;
			this.graphics.drawTriangles(new <Number>[x_,y_,w_,y_,w_,h_,x_,h_], new <int>[0,1,2,2,3,0]);
		}
		
		public function reRender():void
		{
			this.graphics.clear();
			loadHash.reset();
			stageIntersects(true);
		}
		
		public function clean():void
		{
			if (loader) {
				this.loader.contentLoaderInfo.removeEventListener(Event.COMPLETE, miniMapLoadedFunc);
				this.loader.contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR, errorFunc);
				this.loader.contentLoaderInfo.removeEventListener(Event.UNLOAD, unloadedFunc);
				loader.unloadAndStop();
				loader = null;
			}
			this.graphics.clear();
			if (Engine.currMemory >= 700) {
				Log.debug(this, "回收小地切片图前内存:", Engine.currMemory);
				for each (var _local1:Loader in requestHash) {
					_local1.contentLoaderInfo.removeEventListener(Event.COMPLETE, onLoadedFunc);
					_local1.contentLoaderInfo.removeEventListener(Event.UNLOAD, onUnloadFunc);
					_local1.contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR, onErrorFunc);
					requestHash.remove(_local1.name);
					_local1.unloadAndStop();
					loaderQueue.push(_local1);
				}
			}
			loadHash.reset();
			loadImageTime = 0;
			imageKeyQueue = [];
			stageIndexW = Math.ceil((Engine.stage.stageWidth / 320));
			stageIndexH = Math.ceil((Engine.stage.stageHeight / 180));
			_limitIndex_ = (stageIndexW * stageIndexH);
			_limitIndex_ = _limitIndex_ > 15 ? 15 : _limitIndex_;
			_limitIndex_ = _limitIndex_ < _general_limitIndex_ ? _general_limitIndex_ : _limitIndex_;
			Log.debug(this, "回收小地切片图内存:", Engine.currMemory);
		}
		
		override public function onRender():void
		{
		}
	}
}
