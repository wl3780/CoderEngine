package com.coder.core.displays.world
{
	import com.coder.core.controls.wealth.WealthElisor;
	import com.coder.core.controls.wealth.WealthStoragePort;
	import com.coder.core.displays.DisplaySprite;
	import com.coder.core.displays.avatar.Avatar;
	import com.coder.core.displays.avatar.AvatarEffect;
	import com.coder.core.displays.avatar.AvatarRequestElisor;
	import com.coder.core.displays.avatar.AvatarUnitDisplay;
	import com.coder.core.displays.items.interactive.NodeTree;
	import com.coder.core.displays.world.char.Char;
	import com.coder.core.displays.world.char.MainChar;
	import com.coder.core.terrain.astar.TileAstar;
	import com.coder.core.terrain.tile.ItemData;
	import com.coder.core.terrain.tile.Tile;
	import com.coder.core.terrain.tile.TileGroup;
	import com.coder.core.terrain.tile.TileMapData;
	import com.coder.core.terrain.tile.TileUtils;
	import com.coder.engine.Asswc;
	import com.coder.engine.Engine;
	import com.coder.global.EngineGlobal;
	import com.coder.interfaces.display.IAvatar;
	import com.coder.interfaces.display.IChar;
	import com.coder.interfaces.display.IInteractiveObject;
	import com.coder.interfaces.display.INoderDisplay;
	import com.coder.interfaces.display.IScene;
	import com.coder.interfaces.display.ISceneItem;
	import com.coder.utils.FPSUtils;
	import com.coder.utils.FilterUtils;
	import com.coder.utils.Hash;
	import com.coder.utils.HitTest;
	import com.coder.utils.RecoverUtils;
	import com.coder.utils.geom.LinearUtils;
	import com.coder.utils.geom.SuperKey;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.GradientType;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.filters.BlurFilter;
	import flash.filters.ColorMatrixFilter;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.utils.Dictionary;
	import flash.utils.Timer;
	import flash.utils.getTimer;

	public class Scene extends DisplaySprite implements IScene
	{

		public static var stageRect:Rectangle;
		public static var charGridsHash:Array = [];
		public static var isDepthChange:Boolean;
		
		protected static var instance:Scene;
		
		private static var stagePoint:Point = new Point();

		public var isReady:Boolean;
		public var lockMove:Boolean;
		public var isRuning:Boolean;
		public var inited:Boolean;
		public var lockSceneMove:Boolean;
		public var isMouseDown:Boolean = false;
		public var mapData:TileMapData;
		public var shiftKey:Boolean;
		public var isBlockMode:Boolean = false;
		public var instanceHash:Hash;
		public var isDebug:Boolean;
		public var moveTime:int;
		public var effectItems:Array;
		public var tarHash:Array;
		
		protected var $mainChar:MainChar;
		protected var $topLayer:Sprite;
		protected var $middleLayer:Sprite;
		protected var $bottomLayer:Sprite;
		protected var $mapLayer:MapLayer;
		protected var $itemLayer:Sprite;
		protected var $nodeTree:NodeTree;
		protected var $container:DisplayObjectContainer;
		protected var $astart:TileAstar;
		
		protected var mousePoint:Point;
		protected var isKeyDown:Boolean = false;
		protected var _selectTarget_:Char;
		protected var _mouseTarget_:Char;
		protected var _walkEndFunc_:Function;
		protected var keyTime:int;
		protected var _isMouseMove_:Boolean = false;
		protected var _mouseMovePoint_:Point;
		protected var depthTime:int;
		protected var depthTime2:int;
		protected var stageIntersectsHash:Dictionary;
		
		private var timer:Timer;
		private var cleanTime:int;
		private var durTime:int = 0;
		private var num:int = 0;

		public function Scene()
		{
			$astart = new TileAstar();
			mousePoint = new Point();
			timer = new Timer(0);
			_mouseMovePoint_ = new Point();
			effectItems = [];
			stageIntersectsHash = new Dictionary();
			tarHash = [];
			instance = this;
			super();
			this.mouseEnabled = false;
			this.mouseChildren = false;
			this.setup();
			inited = true;
		}
		
		public static function get scene():Scene
		{
			return instance;
		}

		override public function get stage():Stage
		{
			return Engine.stage;
		}
		
		public function get mainChar():MainChar
		{
			return $mainChar;
		}
		
		public function get mapLayer():MapLayer
		{
			return $mapLayer;
		}
		
		public function get topLayer():Sprite
		{
			return $topLayer;
		}
		
		public function get middleLayer():Sprite
		{
			return $middleLayer;
		}
		
		public function get itemLayer():Sprite
		{
			return $itemLayer;
		}
		
		public function get bottomLayer():Sprite
		{
			return $bottomLayer;
		}
		
		public function get walkEndFunc():Function
		{
			return _walkEndFunc_;
		}
		public function set walkEndFunc(value:Function):void
		{
			_walkEndFunc_ = value;
		}
		
		protected function setup():void
		{
			if (inited) {
				return;
			}
			if (EngineGlobal.char_shadow == null) {
				var w:Array = [30, 80, 120];
				var h:Array = [20, 30, 50];
				var bw:Array = [60, 120, 150];
				var bh:Array = [40, 40, 60];
				var tx:Array = [15, 15, 15];
				var ty:Array = [5, 2, 2];
				var shape:Shape = new Shape();
				
				var rect:Rectangle = null;
				var bmd:BitmapData = null;
				var mat:Matrix = null;
				var index:int = 0;
				while (index < w.length) {
					shape.graphics.clear();
					shape.graphics.beginGradientFill(GradientType.LINEAR, [0, 0, 0, 0], [0.9, 0.8, 0.7, 0.6], [1, 1, 1, 1]);
					shape.graphics.drawEllipse(0, 0, w[index], h[index]);
					shape.filters = [new BlurFilter(20, 10)];
					
					rect = shape.getBounds(shape);
					bmd = new BitmapData(bw[index], bh[index], true, 0);
					mat = RecoverUtils.matrix;
					mat.tx = tx[index];
					mat.ty = ty[index];
					bmd.draw(shape, mat);
					EngineGlobal.char_shadow_arr.push(bmd);
					index++;
				}
				EngineGlobal.char_shadow = EngineGlobal.char_shadow_arr[0];
				shape = null;
			}
			
			timer.addEventListener(TimerEvent.TIMER, timerFunc);
			timer.start();
			
			this.mouseEnabled = false;
			this.mouseChildren = false;
			this.tabEnabled = false;
			this.tabChildren = false;
			
			this.$nodeTree = new NodeTree(SceneConst.SCENE_ITEM_NODER);
			this.$nodeTree.build(new Rectangle(0, 0, 15000, 15000), 80);
			
			this.$topLayer = new DisplaySprite();
			this.$topLayer.mouseChildren = false;
			this.$topLayer.mouseEnabled = false;
			this.$topLayer.tabEnabled = false;
			this.$topLayer.tabChildren = false;
			this.$topLayer.name = SceneConst.TOP_LAYER;
			
			this.$middleLayer = new Sprite();
			this.$middleLayer.mouseChildren = false;
			this.$middleLayer.mouseEnabled = false;
			this.$middleLayer.tabEnabled = false;
			this.$middleLayer.tabChildren = false;
			this.$middleLayer.name = SceneConst.MIDDLE_LAYER;
			
			this.$itemLayer = new Sprite();
			this.$itemLayer.mouseEnabled = false;
			this.$itemLayer.mouseChildren = false;
			this.$itemLayer.tabEnabled = false;
			this.$itemLayer.tabChildren = false;
			this.$itemLayer.name = SceneConst.ITEM_LAYER;
			
			this.$bottomLayer = new Sprite();
			this.$bottomLayer.mouseEnabled = false;
			this.$bottomLayer.mouseChildren = false;
			this.$bottomLayer.tabEnabled = false;
			this.$bottomLayer.tabChildren = false;
			this.$bottomLayer.name = SceneConst.BOTTOM_LAYER;
			
			this.addChild($bottomLayer);
			this.addChild($itemLayer);
			this.addChild($middleLayer);
			this.addChild($topLayer);
			
			this.$mapLayer = new MapLayer();
			
			this.$mainChar = new MainChar();
			this.addItem($mainChar, SceneConst.MIDDLE_LAYER);
			
			SuperKey.getInstance().addEventListener(SuperKey.DEBUG, debug);
			SuperKey.getInstance().addEventListener(KeyboardEvent.KEY_DOWN, _KeyDownFunc_);
			SuperKey.getInstance().addEventListener(KeyboardEvent.KEY_UP, _KeyUpFunc_);
			
			var char:Char = null;
			var pIndex:int = 0;
			while (pIndex < Asswc.POOL_INDEX) {
				char = Char.createChar();
				char.charName = "  ";
				char.shadowAvatar("ym1001");
				char.dispose();
				pIndex++;
			}
		}
		
		protected function debug(e:Event):void
		{
		}
		
		protected function timerFunc(event:TimerEvent):void
		{
			mainChar.loopMove();
			this.mainChar.loop();
			sceneMoveTo(this.mainChar.x, this.mainChar.y);
		}
		
		protected function _KeyUpFunc_(event:KeyboardEvent):void
		{
		}
		
		protected function _KeyDownFunc_(event:KeyboardEvent):void
		{
		}
		
		public function start(parent:DisplayObjectContainer):void
		{
			this.$container = parent;
			$container.addChildAt(this.$mapLayer, 0);
			$container.addChildAt(this, 1);
			addHandler();
		}
		
		protected function addHandler():void
		{
			// 鼠标右键支持
			stage.addEventListener("rightMouseDown", _EngineMouseRightDownFunc_);
			stage.addEventListener("rightMouseUp", _EngineMouseRightUpFunc_);
			stage.addEventListener(MouseEvent.MOUSE_DOWN, _EngineMouseDownFunc_);
			stage.addEventListener(MouseEvent.MOUSE_MOVE, _EngineMouseMoveFunc_);
			stage.addEventListener(MouseEvent.MOUSE_UP, _EngineMouseUpFunc_);
			stage.addEventListener(Event.ENTER_FRAME, _EngineEnterFrameFunc_);
		}
		
		public function get isMouseMove():Boolean
		{
			return _isMouseMove_;
		}
		
		protected function _EngineMouseMoveFunc_(event:MouseEvent):void
		{
			if (Asswc.sceneIntersects == false) {
				return;
			}
			var distance:int = Point.distance(_mouseMovePoint_, new Point(mouseX, mouseY));
			if (distance > 10) {
				_mouseMovePoint_.x = mouseX;
				_mouseMovePoint_.y = mouseY;
				_isMouseMove_ = true;
				if (_mouseTarget_ && _mouseTarget_.clickEnabled) {
					_mouseTarget_.filters = [];
					if (_mouseTarget_.poisoningFilters) {
						_mouseTarget_.filters.push(_mouseTarget_.poisoningFilters);
					}
				}
				var underChar:Char = getUnderPointTar() as Char;
				_mouseTarget_ = underChar;
				if (_mouseTarget_ && _mouseTarget_.clickEnabled) {
					_mouseTarget_.filters = [new ColorMatrixFilter(FilterUtils.light(30))];
					if (_mouseTarget_.poisoningFilters) {
						_mouseTarget_.filters.push(_mouseTarget_.poisoningFilters);
					}
				}
			} else {
				_isMouseMove_ = false;
			}
		}
		
		protected function _EngineMouseRightUpFunc_(event:MouseEvent):void
		{
		}
		
		protected function _EngineMouseRightDownFunc_(event:MouseEvent):void
		{
		}
		
		protected function _EngineMouseDownFunc_(e:MouseEvent):void
		{
			var target:Char = getUnderPointTar() as Char;
			if (target) {
				_selectTarget_ = target;
			}
		}
		
		protected function _EngineMouseUpFunc_(e:MouseEvent):void
		{
			isMouseDown = false;
		}
		
		public function drawTile(x:Number, y:Number):void
		{
			TileUtils.drawTile(this.$topLayer.graphics, x, y, 0xFF0000);
		}
		
		protected function _EngineEnterFrameFunc_(e:Event):void
		{
			if (this.stage) {
				if (stageRect == null) {
					stageRect = new Rectangle();
				}
				var gPoint:Point = this.globalToLocal(stagePoint);
				stageRect.x = gPoint.x;
				stageRect.y = gPoint.y;
				stageRect.width = this.stage.stageWidth;
				stageRect.height = this.stage.stageHeight;
			}
			charQueueMove();
			var passTime:int = 500;
			if (this.middleLayer.numChildren > 100 && FPSUtils.fps < 10) {
				passTime = 3000;
			} else {
				if (mainChar.isRuning) {
					passTime = 220;
					if (this.middleLayer.numChildren > 100 && FPSUtils.fps < 25) {
						passTime = 250;
					}
				}
			}
			passTime = 500;
			if (mainChar.isRuning) {
				passTime = 500;
			}
			if (FPSUtils.fps < 10) {
				passTime = 2000;
			}
			if (getTimer() - depthTime2 > passTime && FPSUtils.fps > 5) {
				depthTime2 = getTimer();
				autoDepth();
			}
		}
		
		protected function createEffect():void
		{
			var data:ItemData = null;
			var eff:AvatarEffect = null;
			var index:int = 0;
			while (index < mapData.items.length) {
				data = mapData.items[index];
				eff = AvatarEffect.createChar();
				eff.type = SceneConst.STATIC_STAGE_EFFECT;
				eff.autoStageVisible = true;
				eff.name = "state_stage_effect";
				eff.x = data.x;
				eff.scene_id = mapData.map_id + "";
				eff.scene_id = mapData.map_id + "";
				eff.y = data.y;
				eff.proto = data;
				eff.setAngleToDir(eff.tilePoint, data.dir);
				if (mapData.map_id == 10291) {
					eff.loadEffect(data.item_id, SceneConst.BODY_BOTTOM_EFFECT, null, false, 0, 0, 0, -2, (((Math.random() * 200) >> 0) + 250));
					addItem(eff, SceneConst.BOTTOM_LAYER);
				} else {
					eff.loadEffect(data.item_id, SceneConst.MIDDLE_LAYER, null, false, 0, 0, 0, -2, (((Math.random() * 200) >> 0) + 250));
					addItem(eff, SceneConst.MIDDLE_LAYER);
				}
				effectItems.push(eff);
				index++;
			}
		}
		
		public function getUnderPointTar():INoderDisplay
		{
			var bitmap:Bitmap = null;
			var rect:Rectangle = null;
			var idName:String = null;
			var owner:Char = null;
			var mPoint:Point = new Point(this.mouseX, this.mouseY);
			var disArr:Array = fine(mPoint.x, mPoint.y, 100);
			var target:INoderDisplay = HitTest.getChildUnderPoint(this, mPoint, disArr, [mainChar]) as INoderDisplay;
			if (!target) {
				var index:int = 0;
				while (index < bottomLayer.numChildren) {
					bitmap = bottomLayer.getChildAt(index) as Bitmap;
					if (bitmap && bitmap.name && bitmap.name.indexOf("#") != -1) {
						rect = bitmap.getBounds(bottomLayer);
						if (rect.contains(bottomLayer.mouseX, bottomLayer.mouseY)) {
							idName = bitmap.name.split("#")[0];
							owner = AvatarUnitDisplay.takeUnitDisplay(idName) as Char;
							if (owner && owner.type == "char" && owner.speciaState == "STATE_ON_SELL" && owner != mainChar) {
								target = owner as Char;
								break;
							}
						}
					}
					index++;
				}
			}
			return target;
		}
		
		public function charQueueMove():void
		{
			if ((getTimer() - durTime) < 15) {
				return;
			}
			var interact:IInteractiveObject = null;
			var count:int = this.$middleLayer.numChildren;
			while (count) {
				interact = this.middleLayer.getChildAt(count - 1) as IInteractiveObject;
				if (interact && interact != mainChar) {
					interact.loopMove();
					if (interact as Char) {
						Char(interact).loop();
					}
				}
				count--;
			}
			count = this.itemLayer.numChildren;
			while (count) {
				interact = this.itemLayer.getChildAt(count - 1) as IInteractiveObject;
				if (interact && interact != mainChar) {
					interact.loopMove();
					if (interact as Char) {
						Char(interact).loop();
					}
				}
				count--;
			}
		}
		
		protected function autoDepth():void
		{
			if (!this.isReady) {
				return;
			}
			if (!isDepthChange) {
				return;
			}
			isDepthChange = false;
			
			var item:ISceneItem = null;
			stageIntersectsHash = new Dictionary();
			var array:Array = [];
			var i:int = 0;
			var count:int = this.$middleLayer.numChildren;
			while (i < count) {
				item = this.$middleLayer.getChildAt(i) as ISceneItem;
				if (item) {
					if (item.stageIntersects) {
						if (stageIntersectsHash[item.char_id] == null) {
							stageIntersectsHash[item.char_id] = item.char_id;
							array.push(item);
						}
					} else {
						if (item.layer == SceneConst.MIDDLE_LAYER && mapData.scene_id != "10291") {
							this.$middleLayer.removeChild(item as DisplayObject);
							i--;
							count--;
						}
					}
				}
				i++;
			}
			
			var eff:AvatarEffect = null;
			var isOk:Boolean;
			var tar:DisplayObject = null;
			var index:int;
			var j:int = 0;
			while (j < effectItems.length) {
				eff = effectItems[j];
				isOk = stageIntersectsHash[item.char_id]==null ? false : true;
				if (!eff.stageIntersects) {
					tar = eff as DisplayObject;
					if (tar.parent) {
						tar.parent.removeChild(tar);
						index = array.indexOf(eff);
						array.splice(index, 1);
					}
				} else {
					if (isOk) {
						array.push(eff);
					}
				}
				j++;
			}
			
			count = array.length;
			array.sortOn(["y", "type"], [Array.NUMERIC, Array.NUMERIC]);
			var k:int;
			while (k < count) {
				item = array[k];
				if (k < this.$middleLayer.numChildren) {
					this.$middleLayer.addChildAt(item as DisplayObject, k);
				} else {
					this.$middleLayer.addChild(item as DisplayObject);
				}
				k++;
			}
		}
		
		public function addItem(value:ISceneItem, layer:String):void
		{
			if (value) {
				value.layer = layer;
			}
			if (tarHash.indexOf(tarHash) == -1) {
				tarHash.push(value);
			}
			enterFrameAddTo();
			isDepthChange = true;
		}
		
		public function sceneScroll():void
		{
			mainChar.loopMove();
			this.mainChar.loop();
			sceneMoveTo(this.mainChar.x, this.mainChar.y);
		}
		
		public function enterFrameAddTo():void
		{
			var value:ISceneItem = null;
			var layer:String = null;
			var len:int = tarHash.length;
			var i:int = 0;
			while (i < len) {
				if (tarHash.length) {
					value = tarHash.shift();
					switch (layer) {
						case SceneConst.MIDDLE_LAYER:
							this.$middleLayer.addChild(value as DisplayObject);
							break;
						case SceneConst.ITEM_LAYER:
							this.$itemLayer.addChild(value as DisplayObject);
							break;
						case SceneConst.TOP_LAYER:
							this.$topLayer.addChild(value as DisplayObject);
							break;
						case SceneConst.BOTTOM_LAYER:
							this.$bottomLayer.addChild(value as DisplayObject);
							break;
						case SceneConst.ITEM_LAYER:
							this.$itemLayer.addChild(value as DisplayObject);
							break;
					}
				}
				i++;
			}
		}
		
		public function removeItem(value:ISceneItem):void
		{
		}
		
		public function takeItem(char_id:String):ISceneItem
		{
			return null;
		}
		
		public function changeScene(scene_id:int):void
		{
			AvatarRequestElisor.stop = true;
			clean();
			if (num == 0) {
				mapLayer.changeScene(scene_id + "");
			}
		}
		
		public function clean():void
		{
			var char:DisplayObject = null;
			var j:int;
			var arr:Array = null;
			var ok:Boolean;
			var k:int;
			var rIndex:int;
			var avatar:Avatar = null;
			var display:AvatarUnitDisplay = null;
			Char.charQueueHash.length = 0;
			var _local9:Array = [];
			var displayQueue:Array = [$middleLayer, $itemLayer, $bottomLayer, $topLayer];
			var i:int = 0;
			var tarx:Sprite = null;
			while (i < displayQueue.length) {
				tarx = displayQueue[i];
				j = 0;
				arr = [];
				while (j < tarx.numChildren) {
					char = tarx.getChildAt(j);
					if (char as IAvatar && char != mainChar) {
						ok = true;
						if ((char as AvatarEffect) && (char as AvatarEffect).isLockDispose == false || !(char as AvatarEffect).autoRecover || !(char as AvatarEffect).autoDispose) {
							ok = false;
						}
						if (ok) {
							arr.push(char);
						}
					}
					j++;
				}
				k = 0;
				while (k < arr.length) {
					char = arr[k];
					IAvatar(char).dispose();
					k++;
				}
				arr.length = 0;
				i++;
			}
			
			instanceHash = new Hash();
			this.addItem(mainChar, mainChar.layer);
			mainChar.showHeadShapAndShadowShape();
			var reload:Array = [];
			var hash:Hash = AvatarUnitDisplay.instanceHash;
			for each (var tar in hash) {
				if (tar != mainChar) {
					if (tar as AvatarEffect) {
						if (AvatarEffect(tar).autoRecover) {
							hash.remove(tar.id);
							tar.dispose();
						} else {
							reload.push(tar);
						}
					} else {
						if (tar as Char && Char(tar).isDisposed) {
							hash.remove(tar.id);
						} else {
							reload.push(tar);
						}
					}
				}
			}
			
			WealthStoragePort.clear();
			WealthElisor.isClearing = false;
			rIndex = 0;
			while (rIndex < reload.length) {
				tar = reload[rIndex];
				if (tar as AvatarEffect) {
					AvatarEffect(tar).unit.reloadEffectHash();
				} else {
					avatar = tar as Avatar;
					if (avatar) {
						avatar.unit.loadActSWF();
						avatar.unit.reloadEffectHash();
					}
					display = tar as AvatarUnitDisplay;
					if (display && display.unit) {
						display.unit.loadActSWF();
						display.unit.reloadEffectHash();
					}
				}
				rIndex++;
			}
			reload = null;
		}
		
		public function cleanCheck():void
		{
			var _local2 = null;
			var _local9:int;
			var _local16 = null;
			var _local11:int;
			var _local17 = null;
			var _local13:Boolean;
			var _local4 = null;
			var _local8 = null;
			var _local7:int;
			var _local1 = null;
			var _local6 = null;
			var _local5 = null;
			if (WealthElisor.isClearing) {
				return;
			}
			var _local10:Array = [];
			var _local12:Array = [$middleLayer, itemLayer, bottomLayer, topLayer];
			_local9 = 0;
			while (_local9 < _local12.length) {
				_local16 = _local12[_local9];
				_local2 = _local16;
				_local11 = 0;
				while (_local11 < _local16.numChildren) {
					if ((((((_local2 as IAvatar)) && (!((_local2 == mainChar))))) && (!((_local8.name == "tile"))))) {
						_local13 = true;
						if ((((((((((_local2 as AvatarEffect)) && (((_local2 as AvatarEffect).isLockDispose == false)))) || (!((_local2 as AvatarEffect).autoRecover)))) || (!((_local2 as AvatarEffect).autoDispose)))) || ((_local2 as Object).stageIntersects))) {
							_local13 = false;
						}
						if (_local13) {
							IAvatar(_local2).dispose();
						}
					}
					_local11++;
				}
				_local9++;
			}
			instanceHash = new Hash();
			this.addItem(mainChar, mainChar.layer);
			mainChar.showHeadShapAndShadowShape();
			var _local15:Array = [];
			var _local3:Hash = AvatarUnitDisplay.instanceHash;
			for each (var _local14:IAvatar in _local3) {
				_local4 = (_local14 as Char);
				if (_local14 != mainChar) {
					_local8 = (_local14 as AvatarEffect);
					if (_local8) {
						if (((_local8.autoRecover) && (!((_local8.name == "tile"))))) {
							_local3.remove(_local14.id);
							_local14.dispose();
						} else {
							_local15.push(_local14);
						}
					} else {
						if (((_local4) && (((((!(_local4.proto)) || (_local4.isDisposed))) || ((_local4.stageIntersects == false)))))) {
							_local3.remove(_local14.id);
							_local14.dispose();
						} else {
							_local15.push(_local14);
						}
					}
				}
			}
			AvatarRequestElisor.getInstance().clear();
			WealthElisor.isClearing = false;
			_local7 = 0;
			while (_local7 < _local15.length) {
				_local1 = _local15[_local7];
				if ((_local1 as Object).unit) {
					if ((_local1 as AvatarEffect)) {
						AvatarEffect(_local1).unit.reloadEffectHash();
					} else {
						_local6 = (_local1 as Avatar);
						if (((_local6) && (_local6.stageIntersects))) {
							_local6.unit.loadActSWF();
							_local6.unit.reloadEffectHash();
						}
						_local5 = (_local1 as AvatarUnitDisplay);
						if (((_local5) && (_local5.stageIntersects))) {
							_local5.unit.loadActSWF();
							_local5.unit.reloadEffectHash();
						}
					}
				}
				_local7++;
			}
			_local15 = null;
			AvatarRequestElisor.stop = false;
		}
		
		public function fine(x:Number, y:Number, size:int):Array
		{
			var rect:Rectangle = new Rectangle(x - size, y - size, size * 2, size * 2);
			return this.$nodeTree.find(rect, false, size);
		}
		
		public function setupReady():void
		{
			cleanTime = getTimer();
			this.mapData = mapLayer.mapdata;
			isReady = true;
			var char:Char = null;
			var count:int = 0;
			while (count < this.mapLayer.numChildren) {
				char = mapLayer.getChildAt(count) as Char;
				if (char) {
					char.updateAlpha();
				}
				count++;
			}
		}
		
		public function checkMainCharWalkEnadled():void
		{
			if (!isReady) {
				return;
			}
			var p:* = TileUtils.pixelsToTile(mainChar.x, mainChar.y);
			var key:* = p.x + "|" + p.y;
			var tile:* = TileGroup.instance.take(key) as Tile;
			if (((!(tile)) || ((tile.type <= 0)))) {
				var levelFunc = function (_arg1:int):void{
					if (paths.length) {
						TileUtils.loop_break = true;
					}
				}
				var loopFunc = function (_arg1:int, _arg2:int):void{
					var _local4 = null;
					var _local3:int;
					var _local5:Tile = (TileGroup.instance.take(((_arg1 + "|") + _arg2)) as Tile);
					if (_local5) {
						_local4 = TileUtils.tileToPixels(new Point(_arg1, _arg2));
						_local3 = LinearUtils.getDirection(mainChar.x, mainChar.y, _local4.x, _local4.y);
						if (_local3 == mainChar.dir) {
							_local3 = 0;
						}
						paths.push({
							dis:Point.distance(_local4, p),
							p:_local4,
							dir:_local3
						});
					}
				}
				var paths:* = [];
				TileUtils.loopRect(p.x, p.y, 10, 0, loopFunc, levelFunc);
				paths.sortOn(["dis", "dir"], [16, 16]);
				if (paths.length) {
					mainChar.setTileXY(paths[0].p.x, paths[0].p.y);
				}
			}
		}
		
		public function miniBitmapReady(bmd:BitmapData):void
		{
		}
		
		public function charMoveTo(char:IChar, movePath:Array, walkEndFunc:Function=null):void
		{
			if (char && !char.isDisposed) {
				char.tarMoveTo(movePath);
			}
		}
		
		public function sceneMoveTo(x:Number, y:Number):void
		{
			var focusP:Point = getCameraFocusTo(x, y);
			uniformSpeedMove(new Point(this.x, this.y), focusP);
		}
		
		public function uniformSpeedMoveTo(x:Number, y:Number):void
		{
			var focusP:Point = getCameraFocusPoint(x, y);
			var currP:Point = new Point(this.x, this.y);
			uniformSpeedMove(currP, focusP);
		}
		
		protected function uniformSpeedMove(cur_point:Point, tar_point:Point):void
		{
			var _local5 = null;
			var _local4:Number = Point.distance(tar_point, cur_point);
			var _local3 = 1;
			var _local6 = 1;
			while (_local6 <= _local3) {
				_local5 = Point.interpolate(tar_point, cur_point, (_local6 * (1 / _local3)));
				Point.interpolate(tar_point, cur_point, (_local6 * (1 / _local3))).x = _local5.x.toFixed(2);
				_local5.y = _local5.y.toFixed(2);
				this.mapLayer.x = _local5.x;
				this.mapLayer.y = _local5.y;
				this.x = _local5.x;
				this.y = _local5.y;
				_local6++;
			}
		}
		
		public function getCameraFocusTo(px:Number, py:Number):Point
		{
			var _local8:Number;
			var _local7:Number;
			var _local6:int = Engine.stage.stageWidth;
			var _local10:int = Engine.stage.stageHeight;
			var _local5 = 8000;
			var _local4 = 8000;
			if (((((this.mapData) && ((this.mapData.pixel_width > 0)))) && ((this.mapData.pixel_height > 0)))) {
				_local5 = this.mapData.pixel_width;
				_local4 = this.mapData.pixel_height;
			}
			var _local3:Number = (_local6 / 2);
			var _local9:Number = (_local10 / 2);
			if ((((_local5 < _local6)) || ((((px >= _local3)) && ((px <= (_local5 - _local3))))))) {
				_local8 = (_local3 - px);
			} else {
				if (px <= _local3) {
					_local8 = 0;
				} else {
					_local8 = (_local6 - _local5);
				}
			}
			if ((((_local4 < _local10)) || ((((py >= _local9)) && ((py <= (_local4 - _local9))))))) {
				_local7 = (_local9 - py);
			} else {
				if (py <= _local9) {
					_local7 = 0;
				} else {
					_local7 = (_local10 - _local4);
				}
			}
			return (new Point(_local8, _local7));
		}
		
		public function getCameraFocusPoint(px:Number, py:Number):Point
		{
			var _local18:Number;
			var _local17:Number;
			var _local15:int = Engine.stage.stageWidth;
			var _local11:int = Engine.stage.stageHeight;
			var _local16 = 10000;
			var _local3 = 10000;
			if (((((this.mapData) && ((this.mapData.pixel_width > 0)))) && ((this.mapData.pixel_height > 0)))) {
				_local16 = this.mapData.pixel_width;
				_local3 = this.mapData.pixel_height;
			}
			var _local12:int;
			var _local21:Point = new Point();
			_local21.x = px;
			_local21.y = py;
			var _local22:Point = this.localToGlobal(_local21);
			var _local9:Number = (_local15 / 2);
			var _local7:Number = (_local11 / 2);
			var _local20:Point = this.localToGlobal(_local21);
			_local21 = new Point();
			_local21.x = _local9;
			_local21.y = _local7;
			var _local14:int = Point.distance(_local21, _local20);
			var _local13 = _local12;
			var _local4:Number = scaleX;
			var _local6:Number = (_local20.x - _local9);
			var _local8:Number = (_local20.y - _local7);
			var _local10:Number = Math.atan2(_local8, _local6).toFixed(2) as Number;
			_local20.x = ((_local9 + ((Math.cos(_local10) * _local12) * _local4)).toFixed(1) + "2") as Number;
			_local20.y = ((_local7 + ((Math.sin(_local10) * _local12) * _local4)).toFixed(1) + "2") as Number;
			var _local5:Number = (_local15 - _local16);
			var _local19:Number = (_local11 - _local3);
			if ((((px >= (_local9 + _local12))) && ((px <= ((_local16 - _local9) - _local12))))) {
				if (_local14 >= (_local13 * _local4)) {
					_local18 = (_local20.x - px);
					if (_local18 > 0) {
						_local18 = 0;
					}
					if (_local18 < _local5) {
						_local18 = _local5;
					}
				}
			} else {
				if (px <= (_local9 + _local12)) {
					_local18 = (_local20.x - px);
					if (_local18 > 0) {
						_local18 = 0;
					}
				} else {
					_local18 = (_local20.x - px);
					if (_local18 < _local5) {
						_local18 = _local5;
					}
				}
			}
			if ((((py >= (_local7 + _local12))) && ((py <= ((_local3 - _local7) - _local12))))) {
				if (_local14 >= (_local13 * _local4)) {
					_local17 = (_local20.y - py);
					if (_local17 > 0) {
						_local17 = 0;
					}
					if (_local17 < _local19) {
						_local17 = _local19;
					}
				}
			} else {
				if (py <= (_local7 + _local12)) {
					_local17 = (_local20.y - py);
					if (_local17 > 0) {
						_local17 = 0;
					}
				} else {
					_local17 = (_local20.y - py);
					if (_local17 < _local19) {
						_local17 = _local19;
					}
				}
			}
			return (new Point(_local18, _local17));
		}

	}
}
