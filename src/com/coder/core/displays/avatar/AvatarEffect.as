package com.coder.core.displays.avatar
{
	import com.coder.core.displays.DisplaySprite;
	import com.coder.core.displays.InteractiveEffect;
	import com.coder.core.displays.world.Scene;
	import com.coder.core.terrain.tile.TileUtils;
	import com.coder.engine.Asswc;
	import com.coder.interfaces.display.IAvatar;
	import com.coder.interfaces.display.IDisplay;
	import com.coder.interfaces.display.ISceneItem;
	import com.coder.utils.Hash;
	import com.coder.utils.geom.LinearUtils;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.utils.clearTimeout;

	public class AvatarEffect extends DisplaySprite implements IDisplay, ISceneItem, IAvatar
	{
		public static var bitmapHash:Array = [];
		
		private static var _recoverQueue_:Vector.<AvatarEffect> = new Vector.<AvatarEffect>();
		private static var _recoverIndex_:int = 50;
		
		private static var recoverEffectAray:Array = [];
		private static var stageIntersectsPoint:Point = new Point();
		private static var intersectsRect:Rectangle = new Rectangle(0, 0, 2, 2);

		public var autoStageVisible:Boolean = false;
		public var toDestroy:Boolean = false;
		public var isLockDispose:Boolean;
		public var _ActionPlayEndFunc_:Function;
		public var timeOutIndex:int;
		public var autoRecover:Boolean = true;
		public var autoDispose:Boolean = false;
		public var playEndFunc:Function;
		public var playEndParams:Array;
		
		protected var _effectsUnitHash_:Hash;
		protected var _layer_:String;
		protected var _char_id_:String;
		protected var _stop_:Boolean;
		protected var _unit_:AvatarUnit;
		protected var bmd_eid:Bitmap;
		
		private var _scene_id:String;
		private var __oid__:String;

		public function AvatarEffect()
		{
			_effectsUnitHash_ = new Hash();
			this.mouseEnabled = false;
			this.mouseChildren = false;
			this.tabEnabled = false;
			this.tabChildren = false;
			
			super();
			setup();
		}
		
		public static function takeUnitDisplay(unitDisplay_id:String):AvatarEffect
		{
			return AvatarUnitDisplay._instanceHash_.take(unitDisplay_id) as AvatarEffect;
		}
		
		public static function createChar():AvatarEffect
		{
			var result:AvatarEffect = null;
			if (recoverEffectAray.length) {
				result = recoverEffectAray.pop();
				result.reset();
			} else {
				result = new AvatarEffect();
			}
			return result;
		}

		public function play(action:String, renderType:int=0, playEndFunc:Function=null, stopFrame:int=-1):void
		{
			unit.reloadEffectHash();
		}
		
		public function setup():void
		{
			AvatarUnitDisplay._instanceHash_.remove(this.id);
			this.reset();
		}
		
		public function get scene_id():String
		{
			return _scene_id;
		}
		public function set scene_id(value:String):void
		{
			_scene_id = value;
		}
		
		public function stop():void
		{
		}
		
		public function loadAvatarPart(type:String, idName:String, random:int=0):void
		{
		}
		
		public function getDretion(curr_x:int, curr_y:int, tar_x:Number, tar_y:Number):int
		{
			return LinearUtils.getDirection(curr_x, curr_y, tar_x, tar_y);
		}
		
		public function setEffectStopFrame(actionData_id:String, frame:int=-1):void
		{
			this.unit.setEffectStopFrame(actionData_id, frame);
		}
		
		public function setEffectPlayEndAndStop(actionData_id:String, frame:int=-1):void
		{
			this.unit.setEffectPlayEndAndStop(actionData_id, frame);
		}
		public function loadEffect(idName:String, layer:String=null, passKey:String=null, remove:Boolean=false, dir:int=0, offsetX:int=0, offsetY:int=0, replay:int=-2, random:int=0, type:String="eid"):String
		{
			if (layer == null) {
				layer = "TOP_LAYER";
			}
			return unit.loadEffect(idName, layer, passKey, remove, offsetX, offsetY, replay, random, "stand", type);
		}
		
		public function onEffectPlayEnd(oid:String):void
		{
			if (playEndFunc != null) {
				if (playEndParams != null) {
					playEndFunc.apply(null, playEndParams);
				} else {
					playEndFunc();
				}
			}
			if (autoDispose && autoRecover) {
				this.dispose();
			}
		}
		
		public function get unit():AvatarUnit
		{
			return _unit_;
		}
		
		override public function addChild(child:DisplayObject):DisplayObject
		{
			return super.addChild(child);
		}
		
		public function set unit(value:AvatarUnit):void
		{
			_unit_ = value;
			if (value) {
				AvatarRenderElisor.getInstance().addUnit(value);
			}
		}
		
		public function onBodyRender(renderType:String, bitmapType:String, bitmapData:BitmapData, tx:int, ty:int, shadow:BitmapData=null):void
		{
		}
		
		public function setAngleToDir(tilePoint:Point, dir:int):void
		{
			var angle:Number = LinearUtils.getAnglebyDir(tilePoint, dir);
			this.rotation = (angle - 90);
		}
		
		public function onEffectRender(oid:String, renderType:String, bitmapData:BitmapData, tx:int, ty:int):void
		{
			if (this.isDisposed || !_effectsUnitHash_) {
				if (this.stage) {
					dispose();
				}
				return;
			}
			__oid__ = oid;
			var effBitmap:Bitmap = null;
			if (_effectsUnitHash_.has(oid) == false) {
				if (bitmapHash.length) {
					effBitmap = bitmapHash.pop();
				} else {
					effBitmap = new Bitmap();
				}
				_effectsUnitHash_.put(oid, effBitmap);
			} else {
				effBitmap = _effectsUnitHash_.take(oid) as Bitmap;
			}
			if (renderType == "body_bottom_effect") {
				effBitmap.name = renderType;
			} else {
				if (renderType == "TOP_UP_LAYER") {
					effBitmap.name = renderType;
				} else {
					addChild(effBitmap);
				}
			}
			if (bitmapData == null) {
				_effectsUnitHash_.remove(oid);
				if (effBitmap && effBitmap.parent) {
					effBitmap.parent.removeChild(effBitmap);
				}
				effBitmap = null;
			}
			setBitmapValue(effBitmap, bitmapData, -tx, -ty);
		}
		
		override public function get parent():DisplayObjectContainer
		{
			return super.parent;
		}
		
		public function onRenderBitmap(renderType:String, bitmapType:String, bitmapData:BitmapData, tx:int, ty:int, shadow:BitmapData=null):void
		{
			if (bitmapData) {
				setBitmapValue(bmd_eid, bitmapData, -tx, -ty);
			}
		}
		
		public function setBitmapValue(bitmap:Bitmap, bitmapData:BitmapData, vx:int, vy:int):void
		{
			if (!bitmap) {
				return;
			}
			if (stageIntersects) {
				return;
			}
			if (bitmap.bitmapData != bitmapData) {
				var arr:Array = null;
				bitmap.bitmapData = bitmapData;
				if (bitmap.name.indexOf("body_bottom_effect") != -1) {
					if (bitmap.name.indexOf("#") != -1) {
						arr = bitmap.name.split("#");
						bitmap.x = arr[1] + vx;
						bitmap.y = arr[2] + vy;
					} else {
						bitmap.x = this.x + vx;
						bitmap.y = this.y + vy;
						bitmap.name = "body_bottom_effect#" + x + "#" + y;
						Scene.scene.bottomLayer.addChild(bitmap);
					}
				} else {
					if (bitmap.name.indexOf("body_top_effect") != -1) {
						if (bitmap.name.indexOf("#") != -1) {
							arr = bitmap.name.split("#");
							bitmap.x = arr[1] + vx;
							bitmap.y = arr[2] + vy;
						} else {
							bitmap.x = this.x + vx;
							bitmap.y = this.y + vy;
							bitmap.name = "body_top_effect#" + x + "#" + y;
							Scene.scene.topLayer.addChild(bitmap);
						}
					} else {
						if (bitmap.name.indexOf("TOP_UP_LAYER") != -1) {
							if (bitmap.name.indexOf("#") != -1) {
								arr = bitmap.name.split("#");
								bitmap.x = arr[1] + vx;
								bitmap.y = arr[2] + vy;
							} else {
								bitmap.x = this.x + vx;
								bitmap.y = this.y + vy;
								bitmap.name = "TOP_UP_LAYER#" + x + "#" + y;
								Scene.scene.topLayer.addChild(bitmap);
							}
						} else {
							bitmap.x = vx;
							bitmap.y = vy;
						}
					}
				}
			}
		}
		
		public function get stageIntersects():Boolean
		{
			if (!autoStageVisible) {
				return true;
			}
			if (Scene.stageRect) {
				var rect:Rectangle = intersectsRect;
				rect.x = x;
				rect.y = y;
				if (rect.width == 0) {
					rect.width = 30;
				}
				if (rect.height == 0) {
					rect.height = 100;
				}
				return Scene.stageRect.intersects(rect) ? true : false;
			}
			return true;
		}
		
		public function playEnd(act:String):void
		{
			if (_ActionPlayEndFunc_ != null){
				_ActionPlayEndFunc_(act);
				_ActionPlayEndFunc_ = null;
			}
			if (autoDispose) {
				this.dispose();
			}
		}
		
		public function recover():void
		{
			if (_isDisposed_) {
				return;
			}
			_isDisposed_ = true;
			autoRecover = true;
			if (_effectsUnitHash_) {
				for each (var bitmap:Bitmap in _effectsUnitHash_) {
					if (bitmap.parent) {
						bitmap.parent.removeChild(bitmap);
					}
				}
			}
			_effectsUnitHash_.reset();
			if (this.parent) {
				parent.removeChild(this);
			}
			_layer_ = null;
			_char_id_ = null;
			scene_id = null;
			if (bmd_eid && bmd_eid.parent) {
				bmd_eid.parent.removeChild(bmd_eid);
			}
			bmd_eid = null;
			_ActionPlayEndFunc_ = null;
			playEndFunc = null;
			this.removeChildren();
			
			if (unit) {
				AvatarRenderElisor.getInstance().removeUnit(unit.id);
			}
			if (_recoverQueue_.length <= _recoverIndex_) {
				_recoverQueue_.push(this);
			}
			_unit_.dispose();
			_unit_ = null;
			if (this is InteractiveEffect == false) {
				recoverEffectAray.push(this);
			}
		}
		
		public function reset():void
		{
			_id_ = Asswc.getSoleId();
			AvatarUnitDisplay._instanceHash_.put(this.id, this, true);
			_isDisposed_ = false;
			if (_unit_) {
				_unit_.dispose();
			}
			_unit_ = AvatarUnit.createAvatarUnit();
			_unit_.oid = this.id;
			_unit_.init();
			unit = _unit_;
		}
		
		override public function resetForDisposed():void
		{
			autoStageVisible = false;
			_layer_ = null;
			_char_id_ = null;
			toDestroy = false;
			_stop_ = false;
			_unit_ = null;
			bmd_eid = null;
			isLockDispose = false;
			_ActionPlayEndFunc_ = null;
			timeOutIndex = 0;
			autoRecover = true;
			_scene_id = null;
			autoDispose = false;
			super.resetForDisposed();
			var _local1:Boolean;
			this.mouseEnabled = _local1;
			this.mouseChildren = _local1;
			_local1 = false;
			this.tabEnabled = _local1;
			this.tabChildren = _local1;
			_id_ = Asswc.getSoleId();
			AvatarUnitDisplay._instanceHash_.put(this.id, this, true);
			_isDisposed_ = false;
			if (_unit_) {
				_unit_.dispose();
			}
			_unit_ = AvatarUnit.createAvatarUnit();
			_unit_.oid = this.id;
			_unit_.init();
			unit = _unit_;
		}
		
		override public function dispose():void
		{
			var index:int = Scene.scene.tarHash.indexOf(this);
			if (index != -1) {
				Scene.scene.tarHash.splice(index, 1);
			}
			clearTimeout(this.timeOutIndex);
			AvatarUnitDisplay._instanceHash_.remove(this.id);
			index = _recoverQueue_.indexOf(this);
			if (index != -1) {
				_recoverQueue_.splice(index, 1);
			}
			super.dispose();
			if (unit) {
				_unit_.dispose();
				_unit_ = null;
			}
			for each (var bitmap:Bitmap in _effectsUnitHash_) {
				if (bitmap.parent) {
					bitmap.parent.removeChild(bitmap);
				}
			}
			_effectsUnitHash_ = null;
			if (bmd_eid) {
				if (bmd_eid.parent) {
					bmd_eid.parent.removeChild(bmd_eid);
				}
				bmd_eid = null;
			}
			playEndFunc = null;
			timeOutIndex = 0;
			autoRecover = true;
			this.alpha = 1;
			_ActionPlayEndFunc_ = null;
			_stop_ = false;
			autoStageVisible = false;
			_layer_ = null;
			_char_id_ = null;
			toDestroy = true;
			this.graphics.clear();
			recoverEffectAray.push(this);
		}
		
		public function get tilePoint():Point
		{
			return TileUtils.pixelsToTile(x, y);
		}
		
		public function get point():Point
		{
			return TileUtils.pixelsAlginTile(x, y);
		}
		
		public function get layer():String
		{
			return _layer_;
		}
		public function set layer(value:String):void
		{
			_layer_ = value;
		}
		
		public function set char_id(value:String):void
		{
			_char_id_ = value;
		}
		public function get char_id():String
		{
			return _char_id_;
		}

	}
}
