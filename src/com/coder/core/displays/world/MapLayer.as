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
	import flash.net.URLLoaderDataFormat;
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
			tar_rect = new Rectangle(0, 0, EngineGlobal.IMAGE_WIDTH, EngineGlobal.IMAGE_HEIGHT);
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
			var tmp_id:String = this.scene_id;
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
		
		private function setupProLoader():void
		{
			imageKeyQueue = [];
			if (ImageLoadQueue && ImageLoadQueue.length) {
				var path:String = null;
				var tileKey:String = null;
				var index:int = 0;
				while (index < ImageLoadQueue.length) {
					path = EngineGlobal.SCENE_IMAGE_DIR + "map_image/scene_" + scene_id + "/" + ImageLoadQueue[index][0] + Asswc.LINE + ImageLoadQueue[index][1] + ".jpg?ver=" + EngineGlobal.version;
					if (!requestHash.has(path) && EImageLoadQueue["imageQueue_" + scene_id]) {
						tileKey = ImageLoadQueue[index][0] + Asswc.LINE + ImageLoadQueue[index][1];
						imageKeyQueue.push({
							scene_id:scene_id,
							key:tileKey,
							dis:0,
							index_x:ImageLoadQueue[index][0],
							index_y:ImageLoadQueue[index][1]
						});
					}
					index++;
				}
			} else {
				for each (var item:Object in mapdata.imageIndexHash) {
					if (imageKeyQueue.length < 500) {
						imageKeyQueue.push(item);
					}
				}
			}
		}
		
		protected function unloadedFunc(event:Event):void
		{
		}
		
		private function setupScene():void
		{
			var path:String = EngineGlobal.SCENE_IMAGE_DIR + "map_mini/scene_" + scene_id + ".jpg?ver=" + EngineGlobal.version;
			if (WealthStoragePort.takeLoaderByWealth(path) != null) {
				var mapLoader:DisplayLoader = WealthStoragePort.takeLoaderByWealth(path) as DisplayLoader;
				mapLoader.contentLoaderInfo.bytes;
				miniMapLoadedFunc(null, mapLoader);
			} else {
				loaderContext.imageDecodingPolicy = ImageDecodingPolicy.ON_LOAD;
				if (protoLoader) {
					protoLoader.removeEventListener(Event.COMPLETE, miniJPGLoadFunc);
					protoLoader.removeEventListener(IOErrorEvent.IO_ERROR, errorFunc);
				}
				if (!loadMiniJPGBytesHash.has(path)) {
					protoLoader = new ProtoURLLoader();
					protoLoader.name = path;
					protoLoader.dataFormat = URLLoaderDataFormat.BINARY;
					protoLoader.addEventListener(Event.COMPLETE, miniJPGLoadFunc);
					protoLoader.addEventListener(IOErrorEvent.IO_ERROR, errorFunc);
					protoLoader.load(new URLRequest(path));
				} else {
					var proLoader:ProtoURLLoader = loadMiniJPGBytesHash.take(path) as ProtoURLLoader;
					loadMiniJPG(proLoader.data, path);
				}
			}
		}
		
		private function loadMapData(scene_id:String):void
		{
			this.isReady = false;
			var path:String = EngineGlobal.SCENE_IMAGE_DIR + "map_data/scene_" + scene_id + ".data?ver=" + EngineGlobal.version;
			var bLoader:BingLoader = WealthStoragePort.takeLoaderByWealth(path) as BingLoader;
			if (mapdataHash.has(path) || bLoader) {
				if (bLoader) {
					analyzeMapData(bLoader.data as ByteArray);
				} else {
					analyzeMapData(mapdataHash.take(path).data as ByteArray);
				}
				setupProLoader();
				setupScene();
				Scene.scene.setupReady();
				this.isReady = true;
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
				mapdataLoader.name = path;
				mapdataLoader.dataFormat = URLLoaderDataFormat.BINARY;
				mapdataLoader.load(new URLRequest(path));
				mapdataLoader.addEventListener(Event.COMPLETE, onMapDataComplete);
				mapdataLoader.addEventListener(IOErrorEvent.IO_ERROR, onMapDataError);
			}
		}
		
		protected function onMapDataComplete(event:Event):void
		{
			setupScene();
			var pLoader:ProtoURLLoader = event.target as ProtoURLLoader;
			mapdataHash.put(pLoader.name, pLoader);
			analyzeMapData(pLoader.data);
			Scene.scene.setupReady();
			AvatarRequestElisor.stop = false;
		}
		
		private function analyzeMapData(bytes:ByteArray):void
		{
			if (mapdataLoader) {
				mapdataLoader.removeEventListener(Event.COMPLETE, onMapDataComplete);
				mapdataLoader.removeEventListener(IOErrorEvent.IO_ERROR, onMapDataError);
			}
			TileGroup.instance.reset();
			mapdata.scene_id = scene_id;
			mapdata.uncode(bytes);
			mapdata.map_id = scene_id as int;
			var path:String = EngineGlobal.SCENE_IMAGE_DIR + "map_mini/scene_" + scene_id + ".jpg?ver=" + EngineGlobal.version;
			if (WealthStoragePort.takeLoaderByWealth(path) != null || loadMiniJPGBytesHash.take(path) as ProtoURLLoader) {
				if (bg_bmd) {
					var sx:Number = mapdata.pixel_width / bg_bmd.width;
					var sy:Number = mapdata.pixel_height / bg_bmd.height;
					var m:Matrix = new Matrix();
					m.scale(sx, sy);
					this.graphics.clear();
					this.graphics.beginBitmapFill(bg_bmd, m, false);
					this.graphics.drawRect(0, 0, mapdata.pixel_width, mapdata.pixel_height);
				}
				loadHash.reset();
				stageIntersects(true);
			}
		}
		
		protected function errorFunc(event:IOErrorEvent):void
		{
			Log.error(this, ("小地图加载失败：" + scene_id));
			setupScene();
		}
		
		protected function onMapDataError(event:IOErrorEvent):void
		{
			Log.error(this, ("地图数据加载失败：" + event.target.name));
			mapdataHash.remove(event.target.name);
			loadMapData(scene_id);
		}
		
		private function miniMapLoadedFunc(evt:Event=null, loaderx:Loader=null):void
		{
			this.graphics.clear();
			if (bg_bmd) {
				bg_bmd.dispose();
			}
			if (loaderx) {
				bg_bmd = (loaderx.content as Bitmap).bitmapData.clone();
			} else {
				bg_bmd = (evt.target.loader.content as Bitmap).bitmapData.clone();
			}
			Scene.scene.miniBitmapReady(bg_bmd);
			var bmd:BitmapData = new BitmapData(bg_bmd.width, bg_bmd.height, true, 0);
			bmd.applyFilter(bg_bmd, bg_bmd.rect, new Point(), new BlurFilter(10, 10, 1));
			bg_bmd = bmd;
			
			var pixel_width:int = 6000;
			var pixel_height:int = 6000;
			if (mapdata) {
				pixel_width = mapdata.pixel_width;
				pixel_height = mapdata.pixel_height;
				var imageNum:* = (pixel_width / EngineGlobal.IMAGE_WIDTH) * (pixel_height / EngineGlobal.IMAGE_HEIGHT);
				var size:* = loaderQueue.length - (imageNum * 0.7);
				if (size > 0) {
					loaderQueue.splice((loaderQueue.length - size + 1), size);
				} else {
					if (size < 0) {
						var n:* = Math.abs(size);
						while (n) {
							loaderQueue.push(new Loader());
							n --;
						}
					}
				}
			}
			
			if (loader) {
				this.loader.unloadAndStop();
				setTimeout(function (tmpLoader:Loader):void{
					tmpLoader.contentLoaderInfo.removeEventListener(Event.COMPLETE, miniMapLoadedFunc);
					tmpLoader.contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR, errorFunc);
					tmpLoader.contentLoaderInfo.removeEventListener(Event.UNLOAD, unloadedFunc);
				}, 500, loader);
			}
			this.loader = null;
			if (bg_bmd) {
				var sw:Number = pixel_width / bg_bmd.width;
				var sh:Number = pixel_height / bg_bmd.height;
				var mat:Matrix = new Matrix();
				mat.scale(sw, sh);
				this.graphics.clear();
				this.graphics.beginBitmapFill(bg_bmd, mat, false);
				this.graphics.drawRect(0, 0, pixel_width, pixel_height);
			}
			loadHash.reset();
			stageIntersects(true);
		}
		
		protected function timerFunc(event:TimerEvent):void
		{
			loop();
		}
		
		public function loop():void
		{
			if (clearing) {
				return;
			}
			if (Engine.stage) {
				var p:Point = new Point();
				p = this.globalToLocal(p);
				this.stage_rect.x = p.x;
				this.stage_rect.y = p.y;
				this.stage_rect.width = Engine.stage.stageWidth;
				this.stage_rect.height = Engine.stage.stageHeight;
			}
			var dur:int;
			loadImage();
			if ((getTimer() - loadImageTime) > dur) {
				loadImageTime = getTimer();
				loopLoad();
			}
			stageIntersects();
		}
		
		private function getNear():Object
		{
			var keyObj:Object = null;
			var keyIndex:int;
			stage_point.x = Engine.stage.stageWidth / 2;
			stage_point.y = Engine.stage.stageHeight / 2;
			stage_point = this.globalToLocal(stage_point);
			var tX:int = stage_point.x / EngineGlobal.IMAGE_WIDTH;
			var tY:int = stage_point.y / EngineGlobal.IMAGE_HEIGHT;
			var lPoint:Point = new Point();
			var tPoint:Point = new Point(tX, tY);
			var index:int = 0;
			while (index < imageKeyQueue.length) {
				lPoint.x = imageKeyQueue[index].index_x;
				lPoint.y = imageKeyQueue[index].index_y;
				imageKeyQueue[index].dis = Math.abs(lPoint.x - tPoint.x) + Math.abs(lPoint.y - tPoint.y);
				if (index == 0) {
					keyObj = imageKeyQueue[index];
					keyIndex = index;
				} else {
					if (imageKeyQueue[index].dis < keyObj.dis) {
						keyObj = imageKeyQueue[index];
						keyIndex = index;
					}
				}
				index++;
			}
			return {
				tar:keyObj,
				index:keyIndex
			};
		}
		
		public function loopLoad():void
		{
			var data:Object = null;
			var key:String = null;
			var s_id:String = null;
			var arr:Array = null;
			var rect:Rectangle = null;
			var b:Boolean;
			if (imageKeyQueue.length == 0) {
				return;
			}
			loadInterval = getTimer();
			var time:int = 20;
			if ((getTimer() - changeSceneTime) < 8000) {
				time = 0;
			}
			var pass:Boolean = (getTimer() - backgroundLoadTime) > time;
			if (pass) {
				backgroundLoadTime = getTimer();
			}
			var index:int;
			while (index < 4) {
				if (imageKeyQueue.length && _limitIndex_ > 0) {
					data = getNear();
					key = data.tar.key;
					s_id = data.tar.scene_id;
					arr = key.split(Asswc.LINE);
					rect = new Rectangle();
					rect.x = arr[0] * EngineGlobal.IMAGE_WIDTH - 150;
					rect.y = arr[1] * EngineGlobal.IMAGE_HEIGHT - 50;
					rect.width = EngineGlobal.IMAGE_WIDTH + 300;
					rect.height = EngineGlobal.IMAGE_HEIGHT + 100;
					b = stage_rect.intersects(rect);
					b = Scene.scene.mainChar.isRuning;
					// 判断有问题
					if (stage_rect.intersects(rect) || _limitIndex_ > 0 || Scene.scene.mainChar.isRuning == false && pass) {
						imageKeyQueue.splice(data.index, 1);
						if (s_id == scene_id) {
							load(arr[0], arr[1]);
						}
					}
				}
				index++;
			}
		}
		
		public function loadImage():void
		{
			if (!isReady) {
				return;
			}
			var sPoint:Point = this.globalToLocal(new Point());
			var ePoint:Point = this.globalToLocal(new Point(Engine.stage.stageWidth, Engine.stage.stageHeight));
			var p1_x:int = sPoint.x / EngineGlobal.IMAGE_WIDTH;
			var p1_y:int = sPoint.y / EngineGlobal.IMAGE_HEIGHT;
			var p2_x:int = ePoint.x / EngineGlobal.IMAGE_WIDTH;
			var p2_y:int = ePoint.y / EngineGlobal.IMAGE_HEIGHT;
			var start_x:int = Math.min(p1_x, p2_x);
			var end_x:int = Math.max(p1_x, p2_x);
			var start_y:int = Math.min(p1_y, p2_y);
			var end_y:int = Math.max(p1_y, p2_y);
			var i:int = start_x;
			var j:int;
			while (i <= end_x) {
				j = start_y;
				while (j <= end_y) {
					loopImageLoadFunc(i, j);
					j++;
				}
				i++;
			}
		}
		
		private function loopImageLoadFunc(index_x:int, index_y:int):void
		{
			if (index_x < 0 || index_y < 0) {
				return;
			}
			var path:String = EngineGlobal.SCENE_IMAGE_DIR + "map_image/scene_" + scene_id + "/" + index_x + Asswc.LINE + index_y + ".jpg?ver=" + EngineGlobal.version;
			if (requestHash.has(path)) {
				return;
			}
			tar_rect.x = index_x * EngineGlobal.IMAGE_WIDTH;
			tar_rect.y = index_y * EngineGlobal.IMAGE_HEIGHT;
			if (stage_rect.intersects(tar_rect)) {
				var key:String = index_x + "_" + index_y;
				var isIn:Boolean = false;
				var index:int = 0;
				while (index < imageKeyQueue.length) {
					if (imageKeyQueue[index].key == key) {
						isIn = true;
						break;
					}
					index++;
				}
				if (isIn == false) {
					imageKeyQueue.push({
						scene_id:scene_id,
						key:key,
						dis:0,
						index_x:index_x,
						index_y:index_y
					});
				}
			}
		}
		
		private function load(index_x:int, index_y:int):void
		{
			var path:String = EngineGlobal.SCENE_IMAGE_DIR + "map_image/scene_" + scene_id + "/" + index_x + Asswc.LINE + index_y + ".jpg?ver=" + EngineGlobal.version;
			if (!requestHash.has(path) && _limitIndex_ > 0) {
				var tmpLoader:Loader = null;
				if (loaderQueue.length) {
					tmpLoader = loaderQueue.pop();
					try {
						tmpLoader.unload();
					} catch(e:Error) {
					}
				} else {
					tmpLoader = new Loader();
				}
				requestHash.put(path, tmpLoader);
				tmpLoader.name = path;
				tmpLoader.x = index_x * EngineGlobal.IMAGE_WIDTH;
				tmpLoader.y = index_y * EngineGlobal.IMAGE_HEIGHT;
				tmpLoader.load(new URLRequest(path), loaderContext);
				tmpLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, onLoadedFunc);
				tmpLoader.contentLoaderInfo.addEventListener(Event.UNLOAD, onUnloadFunc);
				tmpLoader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, onErrorFunc);
				_limitIndex_ --;
			}
		}
		
		protected function onErrorFunc(event:IOErrorEvent):void
		{
			var tmpLoader:Loader = event.target.loader as Loader;
			tmpLoader.contentLoaderInfo.removeEventListener(Event.COMPLETE, onLoadedFunc);
			tmpLoader.contentLoaderInfo.removeEventListener(Event.UNLOAD, onUnloadFunc);
			tmpLoader.contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR, onErrorFunc);
			requestHash.remove(tmpLoader.name);
			if (_limitIndex_ < _general_limitIndex_) {
				_limitIndex_ ++;
			}
		}
		
		protected function onUnloadFunc(event:Event):void
		{
			var tmpLoader:Loader = event.target.loader as Loader;
			tmpLoader.contentLoaderInfo.removeEventListener(Event.COMPLETE, onLoadedFunc);
			tmpLoader.contentLoaderInfo.removeEventListener(Event.UNLOAD, onUnloadFunc);
			tmpLoader.contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR, onErrorFunc);
			requestHash.remove(event.target.loader.name);
			if (_limitIndex_ < _general_limitIndex_) {
				_limitIndex_ --;
			}
		}
		
		protected function onLoadedFunc(event:Event):void
		{
			var tmpLoader:Loader = event.target.loader as Loader;
			tmpLoader.contentLoaderInfo.removeEventListener(Event.COMPLETE, onLoadedFunc);
			tmpLoader.contentLoaderInfo.removeEventListener(Event.UNLOAD, onUnloadFunc);
			tmpLoader.contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR, onErrorFunc);
			if (_limitIndex_ < _general_limitIndex_) {
				_limitIndex_ ++;
			}
		}
		
		public function stageIntersects(pass:Boolean=false):void
		{
			if (!isReady) {
				return;
			}
			if (requestHash.length == 0 && !pass) {
				return;
			}
			var s_p:Point = this.globalToLocal(new Point());
			var e_p:Point = this.globalToLocal(new Point(Engine.stage.stageWidth, Engine.stage.stageHeight));
			var p1_x:int = s_p.x / EngineGlobal.IMAGE_WIDTH;
			var p1_y:int = s_p.y / EngineGlobal.IMAGE_HEIGHT;
			var p2_x:int = e_p.x / EngineGlobal.IMAGE_WIDTH;
			var p2_y:int = e_p.y / EngineGlobal.IMAGE_HEIGHT;
			var start_x:int = Math.min(p1_x, p2_x);
			var end_x:int = Math.max(p1_x, p2_x);
			var start_y:int = Math.min(p1_y, p2_y);
			var end_y:int = Math.max(p1_y, p2_y);
			var indexI:int;
			var indexJ:int;
			while (indexI <= end_x) {
				indexJ = start_y;
				while (indexJ <= end_y) {
					onRenderImageLoadFunc(indexI, indexJ);
					indexJ++;
				}
				indexI++;
			}
		}
		
		private function onRenderImageLoadFunc(index_x:int, index_y:int):void
		{
			tar_rect.x = index_x * EngineGlobal.IMAGE_WIDTH;
			tar_rect.y = index_y * EngineGlobal.IMAGE_HEIGHT;
			if (stage_rect.intersects(tar_rect)) {
				var path:String = EngineGlobal.SCENE_IMAGE_DIR + "map_image/scene_" + scene_id + "/" + index_x + Asswc.LINE + index_y + ".jpg?ver=" + EngineGlobal.version;
				if (loadHash.has(path) == false) {
					var image:Bitmap = null;
					var tmpLoader:Loader = requestHash.take(path) as Loader;
					if (tmpLoader) {
						image = tmpLoader.content as Bitmap;
					}
					if (image && image.bitmapData) {
						loadHash.put(path, path);
						draw2(this.graphics, tar_rect.x, tar_rect.y, image.bitmapData);
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
			stageIndexW = Math.ceil(Engine.stage.stageWidth / EngineGlobal.IMAGE_WIDTH);
			stageIndexH = Math.ceil(Engine.stage.stageHeight / EngineGlobal.IMAGE_HEIGHT);
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
