package com.coder.core.displays.avatar
{
	import com.coder.core.displays.DisplaySprite;
	import com.coder.core.displays.world.Scene;
	import com.coder.interfaces.display.IAvatar;
	import com.coder.utils.Hash;
	import com.coder.utils.geom.LinearUtils;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.geom.Rectangle;

	public class Avatar extends DisplaySprite implements IAvatar
	{
		private static var _recoverQueue_:Vector.<Avatar> = new Vector.<Avatar>();
		private static var _recoverIndex_:int = 50;
		
		public var isLoopMove:Boolean;
		public var mid:String;
		public var wid:String;
		public var midm:String;
		public var wgid:String;
		public var playEndFunc:Function;
		public var _ActionPlayEndFunc_:Function;

		protected var _effectsUnitHash_:Hash;
		protected var _isMainChar_:Boolean;
		protected var _stop_:Boolean;
		protected var _unit_:AvatarUnit;
		
		protected var bmd_mid:Bitmap;
		protected var bmd_wid:Bitmap;
		protected var bmd_wgid:Bitmap;
		protected var bmd_eid:Bitmap;
		protected var bmd_midm:Bitmap;
		protected var bmd_eid_top:Bitmap;
		protected var bmd_eid_bottom:Bitmap;
		
		private var idPart:Object;
		private var depthHash:Array;
		private var depthAttackHash:Array;
		private var deathHash:Array;

		public function Avatar()
		{
			_effectsUnitHash_ = new Hash();
			idPart = {
				mid:"bmd_mid",
				wid:"bmd_wid",
				wgid:"bmd_wgid"
			}
			depthHash = [["wgid", "mid", "wid"], ["wgid", "wid", "mid"], ["wid", "wgid", "mid"], ["wid", "mid", "wgid"], ["wid", "mid", "wgid"], ["mid", "wgid", "wid"], ["wgid", "mid", "wid"], ["wgid", "mid", "wid"]];
			depthAttackHash = [["wgid", "mid", "wid"], ["wgid", "wid", "mid"], ["wid", "mid", "wgid"], ["wid", "mid", "wgid"], ["wid", "mid", "wgid"], ["mid", "wgid", "wid"], ["wgid", "mid", "wid"], ["wgid", "mid", "wid"]];
			deathHash = ["wid", "mid", "wgid"];
			
			super();
			this.type = "char";
			setup();
			
			this.tabEnabled = false;
			this.tabChildren = false;
			this.mouseEnabled = false;
			this.mouseChildren = false;
		}
		
		public static function takeUnitDisplay(unitDisplay_id:String):IAvatar
		{
			return AvatarUnitDisplay._instanceHash_.take(unitDisplay_id) as IAvatar;
		}

		override public function set type(value:String):void
		{
			super.type = value;
			if (this.unit) {
				unit.charType = value;
			}
		}
		
		public function setup():void
		{
			AvatarUnitDisplay._instanceHash_.remove(this.id);
			this.reset();
		}
		
		public function get isMainChar():Boolean
		{
			return _isMainChar_;
		}
		
		public function stop():void
		{
		}
		
		public function play(action:String, renderType:int=0, playEndFunc:Function=null, stopFrame:int=-1):void
		{
			if (playEndFunc != _ActionPlayEndFunc_) {
				_ActionPlayEndFunc_ = playEndFunc;
			}
			if (isLoopMove && action == "stand") {
				return;
			}
			if (action == "death") {
				renderType = AvatarUnit.PLAY_NEXT_RENDER;
			}
			this.unit.play(action, renderType, playEndFunc, stopFrame);
			updateBitmapDepth();
		}
		
		public function setEffectStopFrame(actionData_id:String, frame:int):void
		{
			this.unit.setEffectStopFrame(actionData_id, frame);
		}
		
		public function hasEffect(key:String):Boolean
		{
			return unit.effectHash.has(key);
		}
		
		public function effectPlay(key:String, act:String, frame:int=-1):void
		{
			unit.effectPlay(key, act, frame);
		}
		
		public function loadAvatarPart(type:String, idName:String, random:int=0):void
		{
			if (type == "mid") {
				mid = idName;
			}
			if (type == "wid") {
				wid = idName;
			}
			if (type == "wgid") {
				wgid = idName;
			}
			if (type == "midm") {
				midm = idName;
			}
			updateBitmapDepth();
			unit.charType = this.type;
			unit.loadAvatarParts(type, idName, 0, 0, random);
		}
		
		public function loadEffect(idName:String, layer:String="TOP_LAYER", passKey:String=null, remove:Boolean=false, dir:int=0, offsetX:int=0, offsetY:int=0, replay:int=-2, random:int=0, act:String="stand", type:String="eid"):String
		{
			return unit.loadEffect(idName, layer, passKey, remove, offsetX, offsetY, replay, random, act, type);
		}
		
		public function death(value:Boolean):void
		{
		}
		
		public function set isAutoDispose(value:Boolean):void
		{
		}
		
		public function getDretion(curr_x:int, curr_y:int, tar_x:Number, tar_y:Number):int
		{
			return LinearUtils.getDirection(curr_x, curr_y, tar_x, tar_y);
		}
		
		public function get currFrame():int
		{
			return _unit_.mainActionData.currFrame;
		}
		
		public function getTotalFames(idName:String, action:String):int
		{
			return 0;
		}
		
		public function get isPlaying():Boolean
		{
			return false;
		}
		
		public function get dir():int
		{
			return _unit_.dir;
		}
		public function set dir(value:int):void
		{
			_unit_.dir = value;
			updateBitmapDepth();
		}
		
		public function updateBitmapDepth():void
		{
			var depthList:Array = depthHash[dir];
			if (depthList) {
				if (act == "attack" || act == "attack_warm") {
					depthList = depthAttackHash[dir];
				}
				if (act == "death") {
					depthList = deathHash;
				}
				
				var actKey:String = null;
				var actBitmap:Bitmap = null;
				var index:int = 0;
				while (index < depthList.length) {
					actKey = idPart[depthList[index]];
					actBitmap = this[actKey];
					if (actBitmap) {
						addChildAt(actBitmap, 0);
					}
					index++;
				}
			}
		}
		
		public function get act():String
		{
			return _unit_.act;
		}
		
		public function get unit():AvatarUnit
		{
			return _unit_;
		}
		public function set unit(value:AvatarUnit):void
		{
			_unit_ = value;
			_unit_.isMain = _isMainChar_;
			if (value) {
				AvatarRenderElisor.getInstance().addUnit(value);
			}
		}
		
		public function onEffectRender(oid:String, renderType:String, bitmapData:BitmapData, tx:int, ty:int):void
		{
			var actBitmap:Bitmap = null;
			if (bitmapData && _effectsUnitHash_.has(oid) == false) {
				actBitmap = new Bitmap();
				actBitmap.name = oid;
				_effectsUnitHash_.put(oid, actBitmap);
			} else {
				actBitmap = _effectsUnitHash_.take(oid) as Bitmap;
			}
			if (renderType == "body_bottom_effect" || renderType == "body_top_effect") {
				if (bitmapData && actBitmap.name.indexOf(renderType) == -1) {
					actBitmap.name = renderType;
				}
			} else {
				if (bitmapData) {
					addChild(actBitmap);
				}
			}
			if (bitmapData == null) {
				_effectsUnitHash_.remove(oid);
				if (actBitmap) {
					actBitmap.bitmapData = null;
				}
				if (actBitmap && actBitmap.parent) {
					actBitmap.parent.removeChild(actBitmap);
				}
				return;
			}
			setBitmapValue(actBitmap, bitmapData, -tx, -ty);
		}
		
		public function onBodyRender(renderType:String, bitmapType:String, bitmapData:BitmapData, tx:int, ty:int, shadow:BitmapData=null):void
		{
			if (bitmapData) {
				var actBitmap:Bitmap = null;
				if (renderType == "body_type") {
					if (bitmapType == "mid") {
						actBitmap = bmd_mid;
					} else {
						if (bitmapType == "wid") {
							actBitmap = bmd_wid;
						} else {
							if (bitmapType == "wgid") {
								actBitmap = bmd_wgid;
							} else {
								if (bitmapType == "midm") {
									actBitmap = bmd_midm;
								}
							}
						}
					}
				} else {
					if (renderType == "body_effect") {
						actBitmap = bmd_eid;
					} else {
						if (renderType == "body_top_effect") {
							actBitmap = bmd_eid_bottom;
						} else {
							if (renderType == "body_bottom_effect") {
								actBitmap = bmd_eid_top;
							} else {
								if (renderType == "effect") {
									if (!_effectsUnitHash_) {
										_effectsUnitHash_ = new Hash();
									}
								}
							}
						}
					}
				}
				if (!actBitmap.parent && bitmapData) {
					updateBitmapDepth();
				}
				setBitmapValue(actBitmap, bitmapData, -tx, -ty);
			} else {
				if (renderType == "body_type") {
					if (bitmapType == "mid" && bmd_mid && bmd_mid.bitmapData) {
						bmd_mid.bitmapData = null;
					} else {
						if (bitmapType == "wid" && bmd_wid && bmd_wid.bitmapData) {
							bmd_wid.bitmapData = null;
						} else {
							if (bitmapType == "wgid" && bmd_wgid && bmd_wgid.bitmapData) {
								bmd_wgid.bitmapData = null;
							} else {
								if (bitmapType == "midm" && bmd_midm && bmd_midm.bitmapData) {
									bmd_midm.bitmapData = null;
								}
							}
						}
					}
				} else {
					if (renderType == "body_effect") {
						bmd_eid.bitmapData = null;
					} else {
						if (renderType == "body_top_effect") {
							bmd_eid_bottom.bitmapData = null;
						} else {
							if (renderType == "body_bottom_effect") {
								bmd_eid_top.bitmapData = null;
							} else {
								if (renderType == "effect") {
									bmd_eid.bitmapData = null;
								}
							}
						}
					}
				}
			}
		}
		
		public function setBitmapValue(bitmap:Bitmap, bitmapData:BitmapData, vx:int, vy:int):void
		{
			if (!bitmap) {
				return;
			}
			if (bitmapData == null)  {
				if (bitmap.parent) {
					bitmap.parent.removeChild(bitmap);
				}
				return;
			}
			if (stageIntersects) {
				var arr:Array = null;
				if (bitmap.bitmapData != bitmapData) {
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
							if (bitmap.name.indexOf("#") != -1){
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
							bitmap.x = vx;
							bitmap.y = vy;
						}
					}
				}
			}
		}
		
		public function get stageIntersects():Boolean
		{
			if (Scene.stageRect) {
				var rect:Rectangle = this.getBounds(Scene.scene);
				if (rect.width == 0) {
					rect.width = 1;
				}
				if (rect.height == 0) {
					rect.height = 1;
				}
				return Scene.stageRect.intersects(rect) ? true : false;
			}
			return true;
		}
		
		public function reset():void
		{
			AvatarUnitDisplay._instanceHash_.put(this.id, this, true);
			_isDisposed_ = false;
			if (_unit_) {
				_unit_.dispose();
			}
			_unit_ = AvatarUnit.createAvatarUnit();
			_unit_.isMain = _isMainChar_;
			_unit_.oid = this.id;
			_unit_.init();
			unit = _unit_;
			if (!bmd_mid) {
				bmd_mid = new Bitmap();
			}
			if (bmd_mid.bitmapData) {
				bmd_mid.bitmapData = null;
			}
			if (!bmd_wid) {
				bmd_wid = new Bitmap();
			}
			if (bmd_wid.bitmapData) {
				bmd_wid.bitmapData = null;
			}
			if (!bmd_midm) {
				bmd_midm = new Bitmap();
			}
			if (bmd_midm.bitmapData) {
				bmd_midm.bitmapData = null;
			}
			if (!bmd_wgid) {
				bmd_wgid = new Bitmap();
			}
			if (bmd_wgid.bitmapData) {
				bmd_wgid.bitmapData = null;
			}
			if (!bmd_eid) {
				bmd_eid = new Bitmap();
			}
			if (bmd_eid.bitmapData) {
				bmd_eid.bitmapData = null;
			}
			if (!bmd_eid_top) {
				bmd_eid_top = new Bitmap();
			}
			if (bmd_eid_top.bitmapData) {
				bmd_eid_top.bitmapData = null;
			}
			if (!bmd_eid_bottom) {
				bmd_eid_bottom = new Bitmap();
			}
			if (bmd_eid_bottom.bitmapData) {
				bmd_eid_bottom.bitmapData = null;
			}
			if (this.type != "effect") {
				addChild(bmd_eid);
			}
		}
		
		public function onEffectPlayEnd(oid:String):void
		{
			if (playEndFunc != null) {
				playEndFunc();
			}
		}
		
		public function playEnd(act:String):void
		{
			if (_ActionPlayEndFunc_ != null) {
				_ActionPlayEndFunc_(act);
			}
			_ActionPlayEndFunc_ = null;
		}
		
		public function recover():void
		{
			if (_isDisposed_) {
				return;
			}
			_isDisposed_ = true;
			playEndFunc = null;
			for each (var item:Bitmap in _effectsUnitHash_) {
				if (item.parent) {
					item.parent.removeChild(item);
				}
			}
			_effectsUnitHash_.reset();
			if (unit) {
				AvatarRenderElisor.getInstance().removeUnit(unit.id);
			}
			if (_recoverQueue_.length <= _recoverIndex_) {
				_recoverQueue_.push(this);
			}
		}
		
		override public function dispose():void
		{
			super.dispose();
		}

	}
} 
