package com.coder.core.displays.avatar
{
	import com.coder.core.displays.DisplayObjectPort;
	import com.coder.core.displays.items.interactive.NoderSprite;
	import com.coder.core.displays.world.Scene;
	import com.coder.core.displays.world.SceneConst;
	import com.coder.core.displays.world.char.Char;
	import com.coder.engine.Asswc;
	import com.coder.interfaces.display.IAvatar;
	import com.coder.utils.FPSUtils;
	import com.coder.utils.Hash;
	import com.coder.utils.geom.LinearUtils;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.geom.Rectangle;
	
	public class AvatarUnitDisplay extends NoderSprite implements IAvatar
	{
		public static var default_bitmapData:BitmapData = new BitmapData(35, 80, false, 0);
		internal static var _instanceHash_:Hash = new Hash();

		private static var _recoverQueue_:Vector.<AvatarUnitDisplay> = new Vector.<AvatarUnitDisplay>();
		private static var _recoverIndex_:int = 5;
		private static var idPart:Object = {
			mid:"bmd_mid",
			wid:"bmd_wid",
			wgid:"bmd_wgid"
		}
		private static var depthHash:Array = [["wgid", "mid", "wid"], ["wgid", "wid", "mid"], ["wid", "wgid", "mid"], ["wid", "mid", "wgid"], ["wid", "mid", "wgid"], ["mid", "wgid", "wid"], ["wgid", "mid", "wid"], ["wgid", "mid", "wid"]];
		private static var depthAttackHash:Array = [["wgid", "mid", "wid"], ["wgid", "wid", "mid"], ["wid", "mid", "wgid"], ["wid", "mid", "wgid"], ["wid", "mid", "wgid"], ["mid", "wgid", "wid"], ["wgid", "mid", "wid"], ["wgid", "mid", "wid"]];
		private static var deathHash:Array = ["wid", "mid", "wgid"];
		private static var charIntersectsRect:Rectangle = new Rectangle();

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
		
		protected var shadow_mid:Bitmap;
		protected var bmd_mid:Bitmap;
		protected var bmd_wid:Bitmap;
		protected var bmd_wgid:Bitmap;
		protected var bmd_eid:Bitmap;
		protected var bmd_midm:Bitmap;
		protected var bmd_eid_top:Bitmap;
		protected var bmd_eid_bottom:Bitmap;
		
		protected var _hide_body_:Boolean = false;
		protected var _hide_wgid_:Boolean = false;
		protected var _hide_title_:Boolean = false;

		public function AvatarUnitDisplay()
		{
			super();
			_effectsUnitHash_ = new Hash();
			setup();
		}
		
		public static function get instanceHash():Hash
		{
			return _instanceHash_;
		}
		
		public static function takeUnitDisplay(unitDisplay_id:String):IAvatar
		{
			return _instanceHash_.take(unitDisplay_id) as IAvatar;
		}

		public function set priorLoadQueue(value:Vector.<String>):void
		{
			unit.priorLoadQueue = value;
		}
		public function get priorLoadQueue():Vector.<String>
		{
			return unit.priorLoadQueue;
		}
		
		public function hideBody(value:Boolean):void
		{
			_hide_body_ = value;
		}
		
		public function hideWing(value:Boolean):void
		{
			_hide_wgid_ = value;
		}
		
		public function hideTitle(value:Boolean):void
		{
			_hide_title_ = value;
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
			DisplayObjectPort.removeTarget(this);
			_id_ = Asswc.getSoleId();
			this.registerNodeTree(SceneConst.SCENE_ITEM_NODER);
			DisplayObjectPort.addTarget(this);
			_instanceHash_.put(this.id, this, true);
			this.reset();
		}
		
		public function get isMainChar():Boolean
		{
			return _isMainChar_;
		}
		
		public function stop():void
		{
			_stop_ = true;
			unit.stopPlay = true;
		}
		
		public function start():void
		{
			if (_stop_) {
				_stop_ = false;
				unit.stopPlay = false;
			}
		}
		
		public function play(action:String, renderType:int=0, playEndFunc:Function=null, stopFrame:int=-1):void
		{
			var list:Array = ["attack", "skill", "attack_warm", "skill_warm", "hit"];
			if ((list.indexOf(action) != -1) && (FPSUtils.fps <= 4)) {
				unit.loadActSWF();
				if (playEndFunc != null) {
					playEndFunc();
				}
				return;
			}
			if (playEndFunc != _ActionPlayEndFunc_) {
				_ActionPlayEndFunc_ = playEndFunc;
			}
			if (isLoopMove && action == ActionConst.Stand) {
				return;
			}
			if (action == ActionConst.Death) {
				renderType = AvatarUnit.PLAY_NEXT_RENDER;
			}
			this.unit.play(action, renderType, playEndFunc, stopFrame);
			updateBitmapDepth();
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
		
		public function loadEffect(idName:String, layer:String=SceneConst.TOP_LAYER, passKey:String=null, remove:Boolean=false, dir:int=0, offsetX:int=0, offsetY:int=0, replay:int=-2, random:int=0, act:String="stand", type:String="eid"):String
		{
			if (!unit) {
				return null;
			}
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
		
		public function updateBitmapDepth():void{
			var depthInfos:Array = depthHash[dir];
			if (act == "attack" || act == "attack_warm" || act == "skill" || act == "skill_warm") {
				depthInfos = depthAttackHash[dir];
			}
			if (act == "death") {
				depthInfos = deathHash;
			}
			if (!depthInfos) {
				return;
			}
			
			var actKey:String = null;
			var actBitmap:Bitmap = null;
			var index:int = 0;
			while (index < depthInfos.length) {
				actKey = idPart[depthInfos[index]];
				actBitmap = this[actKey];
				if (!_hide_body_) {
					if (_hide_wgid_ && actKey == "bmd_wgid") {
						if (actBitmap && actBitmap.parent) {
							actBitmap.parent.removeChild(actBitmap);
						}
					} else {
						if (actBitmap) {
							addChildAt(actBitmap, 0);
						}
					}
				} else {
					if (actBitmap && actBitmap.parent) {
						actBitmap.parent.removeChild(actBitmap);
					}
				}
				index++;
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
			if (value) {
				_unit_ = value;
				_unit_.isMain = _isMainChar_;
				if (value) {
					AvatarRenderElisor.getInstance().addUnit(value);
				}
			} else {
				_unit_.dispose();
			}
		}
		
		public function onEffectRender(oid:String, renderType:String, bitmapData:BitmapData, tx:int, ty:int):void
		{
			var bitmap:Bitmap = null;
			if (bitmapData && _effectsUnitHash_.has(oid) == false) {
				if (AvatarEffect.bitmapHash.length) {
					bitmap = AvatarEffect.bitmapHash.pop();
				} else {
					bitmap = new Bitmap();
				}
				bitmap.name = oid;
				_effectsUnitHash_.put(oid, bitmap);
			} else {
				bitmap = _effectsUnitHash_.take(oid) as Bitmap;
			}
			if (renderType == "BOTTOM_LAYER" || renderType == "body_bottom_effect" || renderType == "body_top_effect") {
				if (bitmapData && bitmap.name.indexOf(renderType) == -1) {
					bitmap.name = renderType;
				}
			} else {
				if (bitmapData) {
					addChild(bitmap);
				}
			}
			if (bitmapData == null) {
				_effectsUnitHash_.remove(oid);
				if (bitmap) {
					bitmap.bitmapData = null;
					if (bitmap.parent) {
						bitmap.parent.removeChild(bitmap);
					}
					bitmap = null;
				}
				return;
			}
			setBitmapValue(bitmap, bitmapData, -tx, -ty);
		}
		
		public function onBodyRender(renderType:String, bitmapType:String, bitmapData:BitmapData, tx:int, ty:int, shadow:BitmapData=null):void
		{
			var bitmap:Bitmap = null;
			if (bitmapData) {
				if (!_hide_body_) {
					if (renderType == "body_type") {
						switch (bitmapType) {
							case "mid":
								if (!bmd_mid) {
									bmd_mid = new Bitmap();
								}
								bitmap = bmd_mid;
								break;
							case "wid":
								if (!bmd_wid) {
									bmd_wid = new Bitmap();
								}
								bitmap = bmd_wid;
								break;
							case "wgid":
								if (!bmd_wgid) {
									bmd_wgid = new Bitmap();
								}
								bitmap = bmd_wgid;
								break;
							case "midm":
								if (!bmd_midm) {
									bmd_midm = new Bitmap();
								}
								bitmap = bmd_midm;
								break;
						}
					} else if (renderType == "body_effect") {
						if (!bmd_eid) {
							bmd_eid = new Bitmap();
							addChild(bmd_eid);
						}
						bitmap = bmd_eid;
					} else if (renderType == "body_top_effect") {
						if (!bmd_eid_bottom) {
							bmd_eid_bottom = new Bitmap();
						}
						bitmap = bmd_eid_bottom;
					} else if (renderType == "body_bottom_effect") {
						if (!bmd_eid_top) {
							bmd_eid_top = new Bitmap();
						}
						bitmap = bmd_eid_top;
					} else if (renderType == "effect") {
						if (!_effectsUnitHash_) {
							_effectsUnitHash_ = new Hash();
						}
					}
				}
				
				if (_hide_body_) {
					if (this.bmd_mid && bmd_mid.bitmapData) {
						bmd_mid.bitmapData = null;
					}
					if (this.bmd_wid && bmd_wid.bitmapData) {
						bmd_wid.bitmapData = null;
					}
					if (this.bmd_wgid && bmd_wgid.bitmapData) {
						bmd_wgid.bitmapData = null;
					}
				} else {
					if (_hide_wgid_) {
						if (this.bmd_wgid && bmd_wgid.bitmapData) {
							bmd_wgid.bitmapData = null;
						}
					}
					if (!bitmap.parent && bitmapData) {
						updateBitmapDepth();
					}
					setBitmapValue(bitmap, bitmapData, -tx, -ty);
				}
			} else {
				if (renderType == "body_type") {
					switch (bitmapType) {
						case "mid":
							if (bmd_mid && bmd_mid.bitmapData) {
								bmd_mid.bitmapData = null;
							}
							break;
						case "wid":
							if (bmd_wid && bmd_wid.bitmapData) {
								bmd_wid.bitmapData = null;
							}
							break;
						case "wgid":
							if (bmd_wgid && bmd_wgid.bitmapData) {
								bmd_wgid.bitmapData = null;
							}
							break;
						case "midm":
							if (bmd_midm && bmd_midm.bitmapData) {
								bmd_midm.bitmapData = null;
							}
							break;
					}
				} else if (renderType == "body_effect") {
					if (bmd_eid && bmd_eid.bitmapData) {
						bmd_eid.bitmapData = null;
					}
				} else if (renderType == "body_top_effect") {
					if (bmd_eid_bottom && bmd_eid_bottom.bitmapData) {
						bmd_eid_bottom.bitmapData = null;
					}
				} else if (renderType == "body_bottom_effect") {
					if (bmd_eid_top && bmd_eid_top.bitmapData) {
						bmd_eid_top.bitmapData = null;
					}
				} else if (renderType == "effect") {
					if (bmd_eid && bmd_eid.bitmapData) {
						bmd_eid.bitmapData = null;
					}
				}
			}
		}
		
		public function updateEffectXY():void
		{
			var arr:Array = null;
			var rType:String = null;
			for each (var bitmap:Bitmap in _effectsUnitHash_) {
				if (bitmap.name.indexOf("body_bottom_effect") != -1 || bitmap.name.indexOf("body_top_effect") != -1 || bitmap.name.indexOf("BOTTOM_LAYER") != -1) {
					arr = bitmap.name.split("#");
					bitmap.x = this.x + arr[4];
					bitmap.y = this.y + arr[5];
					rType = "";
					if (bitmap.name.indexOf("BOTTOM_LAYER") != -1) {
						rType = "BOTTOM_LAYER";
					}
					if (bitmap.name.indexOf("body_bottom_effect") != -1) {
						rType = "body_bottom_effect";
					}
					if (bitmap.name.indexOf("body_top_effect") != -1) {
						rType = "body_top_effect";
					}
					bitmap.name = id + "#" + rType + "#" + x + "#" + y + "#" + arr[4] + "#" + arr[5];
					if (!bitmap.parent && rType == "BOTTOM_LAYER") {
						Scene.scene.bottomLayer.addChild(bitmap);
					}
				}
			}
		}
		
		override public function set x(value:Number):void
		{
			super.x = value;
			updateEffectXY();
		}
		
		override public function set y(value:Number):void
		{
			super.y = value;
			updateEffectXY();
		}
		
		public function setBitmapValue(bitmap:Bitmap, bitmapData:BitmapData, vx:int, vy:int):void{
			if (!bitmap) {
				return;
			}
			if (bitmapData == null) {
				if (bitmap.parent) {
					bitmap.parent.removeChild(bitmap);
				}
				return;
			}
			if (_hide_body_ && bitmap && (bitmap == bmd_mid || bitmap == bmd_wid || bitmap == bmd_wgid)) {
				return;
			}
			if (stageIntersects) {
				var avatar:IAvatar = AvatarUnitDisplay.takeUnitDisplay(id);
				if (bitmap.bitmapData != bitmapData) {
					bitmap.bitmapData = bitmapData;
				}
				var bName:String = bitmap.name;
				if (bName.indexOf("body_bottom_effect") != -1) {
					if (bName.indexOf("#") != -1) {
						var arr:Array = bName.split("#");
						bitmap.x = arr[2] + vx;
						bitmap.y = arr[3] + vy;
						bitmap.name = id + "#" + "body_bottom_effect" + "#" + x + "#" + y + "#" + vx + "#" + vy;
					} else {
						bitmap.x = this.x + vx;
						bitmap.y = this.y + vy;
						bitmap.name = id + "#" + "body_bottom_effect" + "#" + x + "#" + y + "#" + vx + "#" + vy;
						if (bitmap.bitmapData != bitmapData || !bitmap.parent) {
							Scene.scene.bottomLayer.addChild(bitmap);
						}
					}
				} else {
					if (bName.indexOf("body_top_effect") != -1) {
						if (bName.indexOf("#") != -1) {
							arr = bName.split("#");
							if (int(arr[2] + vx) != bitmap.x) {
								bitmap.x = arr[2] + vx;
							}
							if (bitmap.y != int(arr[3] + vy)) {
								bitmap.y = arr[3] + vy;
							}
							bitmap.name = id + "#" + "body_bottom_effect" + "#" + x + "#" + y + "#" + vx + "#" + vy;
						} else {
							bitmap.x = this.x + vx;
							bitmap.y = this.y + vy;
							bitmap.name = id + "#" + "body_bottom_effect" + "#" + x + "#" + y + "#" + vx + "#" + vy;
							if (bitmap.bitmapData != bitmapData || !bitmap.parent) {
								Scene.scene.topLayer.addChild(bitmap);
							}
						}
					} else {
						if (bName.indexOf("BOTTOM_LAYER") != -1) {
							bitmap.x = x + vx;
							bitmap.y = y + vy;
							bitmap.name = id + "#" + "BOTTOM_LAYER" + "#" + x + "#" + y + "#" + vx + "#" + vy;
							updateEffectXY();
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
			if (Scene.stageRect && (this as Char)) {
				var rect:Rectangle = charIntersectsRect;
				rect.x = x - 100;
				rect.y = y - 150;
				rect.width = 200;
				rect.height = 300;
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
			DisplayObjectPort.removeTarget(this);
			_id_ = Asswc.getSoleId();
			this.registerNodeTree(SceneConst.SCENE_ITEM_NODER);
			DisplayObjectPort.addTarget(this);
			_instanceHash_.put(this.id, this, true);
			this.name = "char";
			_isDisposed_ = false;
			if (_unit_) {
				_unit_.dispose();
			}
			_unit_ = AvatarUnit.createAvatarUnit();
			_unit_.isMain = _isMainChar_;
			_unit_.oid = this.id;
			_unit_.init();
			unit = _unit_;
			priorLoadQueue = new <String>["stand"];
			if (bmd_mid && bmd_mid.bitmapData) {
				bmd_mid.bitmapData = null;
			}
			if (bmd_wid && bmd_wid.bitmapData) {
				bmd_wid.bitmapData = null;
			}
			if (bmd_midm && bmd_midm.bitmapData) {
				bmd_midm.bitmapData = null;
			}
			if (bmd_wgid && bmd_wgid.bitmapData) {
				bmd_wgid.bitmapData = null;
			}
			if (bmd_eid && bmd_eid.bitmapData) {
				bmd_eid.bitmapData = null;
			}
			if (bmd_eid_top && bmd_eid_top.bitmapData) {
				bmd_eid_top.bitmapData = null;
			}
			if (bmd_eid_bottom && bmd_eid_bottom.bitmapData) {
				bmd_eid_bottom.bitmapData = null;
			}
			this.activate();
		}
		
		override public function resetForDisposed():void
		{
			super.resetForDisposed();
			_effectsUnitHash_ = new Hash();
			_isMainChar_ = false;
			_stop_ = false;
			isLoopMove = false;
			_hide_body_ = false;
			_hide_wgid_ = false;
			_hide_title_ = false;
			setup();
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
				_ActionPlayEndFunc_ = null;
			}
		}
		
		public function recover():void
		{
			if (_isDisposed_) {
				return;
			}
			_isDisposed_ = true;
			playEndFunc = null;
			this.unactivate();
			for each (var bitmap:Bitmap in _effectsUnitHash_) {
				if (bitmap.parent) {
					bitmap.parent.removeChild(bitmap);
				}
			}
			_effectsUnitHash_.reset();
			if (unit) {
				AvatarRenderElisor.getInstance().removeUnit(unit.id);
			}
			unit.dispose();
			priorLoadQueue = new <String>["stand"];
			if (_recoverQueue_.length <= _recoverIndex_) {
				_recoverQueue_.push(this);
			}
		}
		
		override public function dispose():void
		{
			AvatarUnitDisplay._instanceHash_.remove(this.id);
			var index:int = _recoverQueue_.indexOf(this);
			if (index != -1) {
				_recoverQueue_.splice(index, 1);
			}
			priorLoadQueue = null;
			if (bmd_mid) {
				if (bmd_mid.parent) {
					bmd_mid.parent.removeChild(bmd_mid);
				}
				bmd_mid.bitmapData = null;
			}
			if (bmd_wid) {
				if (bmd_wid.parent) {
					bmd_wid.parent.removeChild(bmd_wid);
				}
				bmd_wid.bitmapData = null;
			}
			if (bmd_wgid) {
				if (bmd_wgid.parent) {
					bmd_wgid.parent.removeChild(bmd_wgid);
				}
				bmd_wgid.bitmapData = null;
			}
			if (bmd_eid) {
				if (bmd_eid.parent) {
					bmd_eid.parent.removeChild(bmd_eid);
				}
				bmd_eid.bitmapData = null;
			}
			if (bmd_midm) {
				if (bmd_midm.parent) {
					bmd_midm.parent.removeChild(bmd_midm);
				}
				bmd_midm.bitmapData = null;
			}
			if (bmd_eid_top) {
				if (bmd_eid_top.parent) {
					bmd_eid_top.parent.removeChild(bmd_eid_top);
				}
				bmd_eid_top.bitmapData = null;
			}
			if (bmd_eid_bottom) {
				if (bmd_eid_bottom.parent) {
					bmd_eid_bottom.parent.removeChild(bmd_eid_bottom);
				}
				bmd_eid_bottom.bitmapData = null;
			}
			super.dispose();
			if (unit) {
				_unit_.dispose();
			}
			_unit_ = null;
			this.unactivate();
			for each (var bitmap:Bitmap in _effectsUnitHash_) {
				if (bitmap.parent) {
					bitmap.parent.removeChild(bitmap);
				}
			}
			_effectsUnitHash_ = null;
			this.alpha = 1;
			isLoopMove = false;
			_ActionPlayEndFunc_ = null;
			mid = null;
			wid = null;
			midm = null;
			wgid = null;
			_isMainChar_ = false;
			_stop_ = false;
			bmd_mid = null;
			bmd_wid = null;
			bmd_wgid = null;
			bmd_eid = null;
			bmd_midm = null;
			bmd_eid = null;
			bmd_eid_top = null;
			bmd_eid_bottom = null;
		}

	}
} 
