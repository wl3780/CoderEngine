package com.coder.core.displays.world.char
{
	import com.coder.core.displays.avatar.AvatarUnit;
	import com.coder.core.displays.avatar.AvatarUnitDisplay;
	import com.coder.core.displays.world.Scene;
	import com.coder.core.terrain.TileConst;
	import com.coder.core.terrain.tile.Tile;
	import com.coder.core.terrain.tile.TileGroup;
	import com.coder.core.terrain.tile.TileUtils;
	import com.coder.engine.Asswc;
	import com.coder.engine.Engine;
	import com.coder.global.EngineGlobal;
	import com.coder.interfaces.display.IChar;
	import com.coder.interfaces.display.ISceneItem;
	import com.coder.utils.FPSUtils;
	import com.coder.utils.RecoverUtils;
	import com.coder.utils.geom.LinearUtils;
	import com.coder.utils.log.Log;
	
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.filters.GlowFilter;
	import flash.geom.ColorTransform;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.utils.clearInterval;
	import flash.utils.clearTimeout;
	import flash.utils.getTimer;
	import flash.utils.setTimeout;

	public class Char extends AvatarUnitDisplay implements IChar
	{
		public static const charQueueHash:Vector.<Char> = new Vector.<Char>();
		public static const POISONING_COLOR:ColorTransform = new ColorTransform(1, 1, 1, 1, 10, -45, -110);
		private static const DEFAULT_COLOR:ColorTransform = new ColorTransform();

		public static var sayNumIndex:int = 3;
		public static var unitMale:AvatarUnit;
		public static var unitFamale:AvatarUnit;
		
		private static var _Point_:Point = new Point();
		private static var DEFAULT_HITAREA:Rectangle = new Rectangle(-25, -100, 50, 100);
		private static var septSize:int = TileConst.TILE_WIDTH + 1;

		public var isBoss:Boolean;
		public var isElite:Boolean;
		public var shadow_id:String;
		public var isBackMoving:Boolean;
		public var walkSpeed:int = 100;
		public var runSpeed:int = 230;
		public var data:Object;
		public var poisoningFilters:GlowFilter;
		public var timeOutIndex:int;
		public var buffTimeOutIndex:int;
		public var hoeTimeIndex:int;
		public var stopTimeIndex:int;
		public var clickEnabled:Boolean = true;
		public var isGlobalWalkMode:Boolean;
		public var allwayShowName:Boolean = false;
		public var charMoveFunc:Function;
		public var hasPickup:Boolean = false;
		public var canPickup:Boolean = true;
		public var lock:Boolean = false;
		public var collectionNum:int;
		public var actionCounter:int;
		public var dirCounter:int;
		public var checkTimeIndex:int = 0;
		public var frameIndex:int = 0;
		public var _vx_:Number = 0;
		public var _vy_:Number = 0;
		public var moveParams:Array;
		public var walkNextTileFunc:Function;
		public var walkNextTileParams:Array;
		
		protected var _char_id_:String;
		protected var _layer_:String;
		protected var _speed_:Number;
		protected var _tarPoint_:Point;
		protected var _totalTime_:Number = 0;
		protected var _movePath_:Array;
		protected var _bounds_:Rectangle;
		protected var _moveEndFunc_:Function;
		protected var _isRuning_:Boolean;
		protected var _isDeath_:Boolean;
		protected var _stopMove_:Boolean;
		protected var _point_:Point;
		protected var _loopMoveTime_:int;
		protected var shadowShape:CharShadow;
		protected var headShape:CharHead;
		protected var stopDurTime:int;
		
		private var _sex:int;
		private var headImageSprite:Sprite;
		private var _isDeath:Boolean;
		private var _lockMove:Boolean;
		private var _lockSkill:Boolean;
		private var _bodyHeight:int = 100;
		private var _isWalkMode:Boolean = false;
		private var _isStealth:Boolean;
		private var _dropShape:Shape;
		private var _speciaState:String = "normal";
		private var _tile_:Point;
		private var _isPoisoning:Boolean = false;
		private var _hitArea_:Rectangle;
		private var _scene_id:String;
		private var _isCharMode:Boolean;
		private var _lookDir:int = -1;
		private var bodyHeight2:int;
		private var _key_:String;
		private var lookMoveTime:int;
		private var lookSkillTime:int;
		private var sayWordTime:int;
		private var isAutoSay:Boolean;
		private var words:Array;
		private var sayTimeDur:int;
		private var imageQueue:Array;
		private var isNeedChanegSpeed:Boolean;
		private var imageDur:int;
		private var showBGTime:int;
		private var tmpPt:Point;
		private var checkActDur:int = 0;
		private var enterFrameCheck:Boolean = false;
		private var tileKey:String = "";

		public function Char()
		{
			_bounds_ = new Rectangle();
			_point_ = new Point();
			_hitArea_ = DEFAULT_HITAREA;
			words = [];
			imageQueue = [];
			tmpPt = new Point();
			walkNextTileParams = [];
			super();
			headImageSprite = Engine.getSprite();
			var _local1:Boolean;
			headImageSprite.mouseEnabled = _local1;
			headImageSprite.mouseChildren = _local1;
			headImageSprite.tabChildren = _local1;
			shadowShape = CharShadow.createCharShowd();
			shadowShape.oid = this.id;
			headShape = CharHead.createCharHead();
			headShape.oid = this.id;
			shadowShape.visible = !(_hide_body_);
			headImageSprite.name = "headImageSprite";
		}
		
		public static function createChar():Char
		{
			var result:Char = null;
			if (charQueueHash.length) {
				result = charQueueHash.pop();
				result.resetForDisposed();
				result.x = 0;
				result.y = 0;
				if (result.parent) {
					result.parent.removeChild(result);
				}
				return result;
			}
			return new Char();
		}

		public function get sex():int
		{
			return _sex;
		}
		public function set sex(value:int):void
		{
			_sex = value;
			unit.sex = value;
		}
		
		public function get bodyHeight():int
		{
			return _bodyHeight;
		}
		public function set bodyHeight(value:int):void
		{
			_bodyHeight = value;
			this.y = point.y;
		}
		
		public function get shadowUnitDisplay():AvatarUnitDisplay
		{
			return shadowShape.shadowUnit;
		}
		
		public function get tarPoint():Point
		{
			if (!_tarPoint_) {
				return null;
			}
			return _tarPoint_.clone();
		}
		
		public function heid(value:Boolean):void
		{
			if (((value) && (!(isDisposed)))) {
				if (parent) {
					this.parent.removeChild(this);
				}
				if (((headImageSprite) && (headImageSprite.parent))) {
					headImageSprite.parent.removeChild(headImageSprite);
				}
				if (((shadowShape) && (shadowShape.parent))) {
					shadowShape.parent.removeChild(shadowShape);
				}
				if (((headShape) && (headShape.parent))) {
					headShape.parent.removeChild(headShape);
				}
			} else {
				if (!this.parent) {
					Scene.scene.addItem(this, "MIDDLE_LAYER");
				}
				if (((((((((headImageSprite) && (!(headImageSprite.parent)))) && ((imageQueue.length > 0)))) && (!(this.isDisposed)))) && (this.parent))) {
					Scene.scene.topLayer.addChild(headImageSprite);
				}
				if (((shadowShape) && (!(shadowShape.parent)))) {
					Scene.scene.itemLayer.addChild(shadowShape);
				}
				if (((headShape) && (!(headShape.parent)))) {
					Scene.scene.topLayer.addChild(headShape);
				}
			}
		}
		
		public function get speciaState():String
		{
			return _speciaState;
		}
		public function set speciaState(value:String):void
		{
			_speciaState = value;
		}
		
		public function showTiles(tiles:Array, type:int=0):void
		{
			headShape.showTile(this, tiles, type);
		}
		
		public function get lockMove():Boolean
		{
			return _lockMove;
		}
		public function set lockMove(value:Boolean):void
		{
			if (value) {
				lookMoveTime = getTimer();
			}
			_lockMove = value;
		}
		
		public function get lockSkill():Boolean
		{
			return _lockSkill;
		}
		public function set lockSkill(value:Boolean):void
		{
			if (value) {
				lookSkillTime = getTimer();
			}
			_lockSkill = value;
		}
		
		public function set lookDir(value:int):void
		{
			_lookDir = value;
			unit.lockDir = value;
			dir = value;
		}
		public function get lookDir():int
		{
			return _lookDir;
		}
		
		public function showHeadShapAndShadowShape():void
		{
			if (headShape.parent == null) {
				Scene.scene.topLayer.addChild(headShape);
			}
			if (shadowShape.parent == null) {
				shadowShape.setShadowSize();
			}
		}
		
		public function set charBloodVisible(value:Boolean):void
		{
			if (this.isBoss) {
				this.headShape.bloodKitVisible = false;
			} else {
				this.headShape.bloodKitVisible = value;
			}
		}
		public function get charBloodVisible():Boolean
		{
			return headShape.bloodKitVisible;
		}
		
		public function set charNeilivisible(value:Boolean):void
		{
			if (isCharMode) {
				headShape.neiKitVisible = value;
			}
		}
		
		override public function hideBody(value:Boolean):void
		{
			super.hideBody(value);
			if (shadowShape) {
				this.shadowShape.visible = !value;
			}
		}
		override public function hideWing(value:Boolean):void
		{
			super.hideWing(value);
		}
		override public function hideTitle(value:Boolean):void
		{
			super.hideTitle(value);
			this.headShape.setHeidTitle(value);
		}
		
		public function setWords(value:Boolean, words:Array=null):void
		{
			this.isAutoSay = value;
			this.words = words;
			sayTimeDur = 9 + (Math.random() * 4 >> 0) * 1000;
			sayWordTime = getTimer() - 10000;
			autoSay();
		}
		
		public function autoSay():void
		{
			if (words && isAutoSay && (getTimer() - sayWordTime > sayTimeDur)) {
				sayWordTime = getTimer();
				this.sayWord(words[words.length * Math.random() >> 0]);
			}
		}
		
		public function get charNeilivisible():Boolean
		{
			return headShape.neiKitVisible;
		}
		
		public function setNei(curr:int, max:int):void
		{
			if (this.isCharMode) {
				this.headShape.neiKitVisible = true;
			} else {
				if (!isDeath) {
					this.headShape.neiKitVisible = false;
				}
			}
			this.headShape.setNeiValue(curr, max);
		}
		
		public function setHeadIcon(value:DisplayObject, align:String="center"):void
		{
			headShape.setHeadIcon(value, align);
		}
		
		public function setBlood(curr:int, max:int):void
		{
			if (this.isBoss) {
				this.headShape.bloodKitVisible = false;
			} else {
				if (!isDeath) {
					this.headShape.bloodKitVisible = true;
				}
			}
			this.headShape.setBloodValue(curr, max);
		}
		
		public function get isDeath():Boolean
		{
			return _isDeath;
		}
		public function set isDeath(value:Boolean):void
		{
			_isDeath = value;
		}
		
		public function set hitTestArea(value:Rectangle):void
		{
			_hitArea_ = value;
		}
		public function get hitTestArea():Rectangle
		{
			return _hitArea_;
		}
		
		public function set charNameColor(value:uint):void
		{
			this.headShape.nameColor = value;
		}
		
		public function set charHeadCacheMode(value:Boolean):void
		{
			this.headShape.cacheMode = value;
		}
		
		public function showHeadName(value:Boolean):void
		{
			if (value) {
				Scene.scene.topLayer.addChild(headShape);
			} else {
				if (headShape.parent) {
					headShape.parent.removeChild(headShape);
				}
			}
		}
		
		public function get headRect():Rectangle
		{
			return headShape.getBounds(this);
		}
		
		public function set charName(value:String):void
		{
			if (value) {
				if (!headShape) {
					headShape = CharHead.createCharHead();
				}
				this.headShape.name = value;
				Scene.scene.topLayer.addChild(headShape);
			} else {
				this.headShape.nameVisible = false;
				if (headShape.parent) {
					headShape.parent.removeChild(headShape);
				}
			}
		}
		
		public function set unionName(value:String):void
		{
			this.headShape.unionName = value;
		}
		
		public function set charNameVisible(value:Boolean):void
		{
			if (this.isBoss) {
				this.headShape.nameVisible = false;
			} else {
				this.headShape.nameVisible = value;
			}
		}
		
		public function set charProfessionNameColor(value:uint):void
		{
			this.headShape.professionNameColor = value;
		}
		
		public function set charProfessionName(value:String):void
		{
			if (value) {
				this.headShape.professionName = value;
				Scene.scene.topLayer.addChild(headShape);
			} else {
				this.headShape.professionNameVisible = false;
			}
		}
		
		public function set charProfessionNameVisible(value:Boolean):void
		{
			if (this.isBoss) {
				this.headShape.professionNameVisible = false;
			} else {
				this.headShape.professionNameVisible = value;
			}
		}
		
		override public function set x(value:Number):void
		{
			var oldKey:String = _key_;
			super.x = value;
			enterFrameCheck = true;
			_vx_ = value;
			_key_ = getKey();
			var newKey:String = _key_;
			setBlock(oldKey, newKey);
			if (_isMainChar_) {
				Scene.isDepthChange = true;
			}
		}
		
		override public function set alpha(value:Number):void
		{
			super.alpha = value;
			if (this.shadowShape) {
				this.shadowShape.alpha = value;
			}
		}
		
		public function checkCenterPoint():void
		{
			var distance:int = Point.distance(point, new Point(x, y));
			if (distance <= 5) {
				_tile_ = point.clone();
				_ChangeTileFunc_();
			}
			if (charMoveFunc != null) {
				charMoveFunc();
			}
		}
		
		public function checkGridSame(key:String):Boolean{
			var _local5:int;
			var _local3 = null;
			var mainChar:MainChar = Scene.scene.mainChar;
			var _local4:Array = Scene.scene.fine(point.x, point.y, 100);
			_local5 = 0;
			while (_local5 < _local4.length) {
				_local3 = _local4[_local5];
				if (((((((_local3) && ((((_local3.type == "char")) || ((_local3.type == "0npc_normal")))))) && (!((_local3 == mainChar))))) && (!((_local3 == this))))) {
					if ((((((_local3.isDisposed == false)) && ((_local3.isDeath == false)))) && ((_local3.key == key)))) {
						return (true);
					}
				}
				_local5++;
			}
			return (false);
		}
		public function checkCharInGrids(oldKey:String, newKey:String, enabled:Boolean, kill:Boolean=false):void{
			var _local7 = null;
			var _local6 = null;
			var _local9:int;
			var _local5 = null;
		}
		public function setBlock(oldKey:String, newKey:String, kill:Boolean=false):void{
			var _local4 = null;
			if (((Scene.scene.isBlockMode) && ((((type == "char")) || ((type == "0npc_normal")))))) {
				_local4 = (TileGroup.instance.take(oldKey) as Tile);
				if (((_local4) && (kill))) {
					_local4.quoteIndex = 0;
					_local4.type = _local4.initValue;
					return;
				}
				if (((((_local4) && ((((_local4.type == 0)) || (isDeath))))) && ((checkGridSame(oldKey) == false)))) {
					_local4.quoteIndex = (_local4.quoteIndex - 1);
					if (_local4.quoteIndex <= 0) {
						_local4.quoteIndex = 0;
						_local4.type = _local4.initValue;
					}
				}
				_local4 = (TileGroup.instance.take(newKey) as Tile);
				if ((((_isMainChar_ == false)) && (!(isDeath)))) {
					if (((_local4) && ((_local4.type > 0)))) {
						_local4.quoteIndex = (_local4.quoteIndex + 1);
						_local4.type = 0;
					}
				} else {
					if (((((_local4) && ((((_local4.type <= 0)) || (!(isDeath)))))) && ((checkGridSame(newKey) == false)))) {
						_local4.quoteIndex = 0;
						_local4.type = _local4.initValue;
					}
				}
			}
		}
		public function get isPoisoning():Boolean{
			return (_isPoisoning);
		}
		public function setPoisoning(value:Boolean):void{
			var _local4:int;
			var _local3 = null;
			_isPoisoning = value;
			var _local2:Array = [];
			if (this.bmd_mid) {
				_local2.push(bmd_mid);
			}
			_local4 = 0;
			while (_local4 < _local2.length) {
				_local3 = _local2[_local4];
				_local3.transform.colorTransform = (value) ? POISONING_COLOR : DEFAULT_COLOR;
				_local4++;
			}
		}
		public function get isStealth():Boolean{
			return (_isStealth);
		}
		public function set isStealth(value:Boolean):void{
			_isStealth = value;
			enterFrameCheck = true;
		}
		override public function set y(value:Number):void{
			var _local3:String = _key_;
			super.y = value;
			enterFrameCheck = true;
			_key_ = getKey();
			var _local2:String = _key_;
			setBlock(_local3, _local2);
			if (_isMainChar_) {
				Scene.isDepthChange = true;
			}
		}
		public function get point():Point{
			var _local2:int = (((x / TileConst.TILE_WIDTH) * TileConst.TILE_WIDTH) + TileConst.WH);
			var _local1:int = (((y / TileConst.TILE_HEIGHT) * TileConst.TILE_HEIGHT) + TileConst.HH);
			_point_ = Engine.getPoint();
			_point_.x = _local2;
			_point_.y = _local1;
			return (_point_);
		}
		public function setXY(x:Number, y:Number):void{
			var _local4:String = _key_;
			super.y = y;
			super.x = x;
			var _local3:String = _key_;
			setBlock(_local4, _local3);
			enterFrameCheck = true;
		}
		public function setTileXY(x:Number, y:Number):void{
			TileUtils.pixelsAlginTile(x, y, RecoverUtils.point);
			setXY(RecoverUtils.point.x, RecoverUtils.point.y);
		}
		public function get scene_id():String{
			return (_scene_id);
		}
		public function set scene_id(value:String):void{
			_scene_id = value;
		}
		public function set isRuning(value:Boolean):void{
			_isRuning_ = value;
		}
		public function get isRuning():Boolean{
			return (_isRuning_);
		}
		public function get layer():String{
			return (_layer_);
		}
		public function set layer(value:String):void{
			_layer_ = value;
		}
		public function set char_id(value:String):void{
			if (headShape) {
				headShape.char_id = value;
			}
			_char_id_ = value;
		}
		public function get char_id():String{
			return (_char_id_);
		}
		public function get speed():Number{
			return (_speed_);
		}
		public function set speed(value:Number):void{
			this.runSpeed = value;
			this.walkSpeed = (value / 2);
			_speed_ = value;
		}
		public function get moveEndFunc():Function{
			return (_moveEndFunc_);
		}
		public function set moveEndFunc(value:Function):void{
			_moveEndFunc_ = value;
		}
		public function addHeadImage(headImage:HeadImage):void{
			if (FPSUtils.fps < 10) {
				headImage.dispose();
				return;
			}
			if (((this.isDisposed) || (!(this.parent)))) {
				headImage.dispose();
				return;
			}
			if (headImageSprite == null) {
				headImageSprite = Engine.getSprite();
			}
			headImageSprite.x = x;
			headImageSprite.y = y;
			headImage.oid = this.id;
			imageQueue.push(headImage);
			if ((((headImageSprite.parent == null)) && (imageQueue.length))) {
				Scene.scene.topLayer.addChild(headImageSprite);
			}
		}
		public function moveTo(x:int, y:int):void{
			clearTimeout(hoeTimeIndex);
			_tarPoint_.x = x;
			_tarPoint_.y = y;
			_movePath_ = [];
			isRuning = true;
			_totalTime_ = 0;
			_loopMoveTime_ = getTimer();
			checkAndSetDir();
			if (isCharMode) {
				if ((((this.dir == 0)) || ((dir == 4)))) {
					if (((!((this.act == "walk"))) && (!((this.act == "run"))))) {
						this.play("walk");
					}
				} else {
					if (isWalkMode) {
						if (((!((this.act == "walk"))) && (!((this.act == "run"))))) {
							this.play("walk");
						}
					} else {
						if (((!((this.act == "run"))) && (!((this.act == "walk"))))) {
							this.play("run");
						}
					}
				}
			} else {
				this.play("walk");
			}
			unit.loadActSWF();
		}
		public function getKey():String{
			var _local2:int = (x / TileConst.TILE_WIDTH);
			var _local1:int = (y / TileConst.TILE_HEIGHT);
			return (((_local2 + "|") + _local1));
		}
		public function get key():String{
			return (_key_);
		}
		public function get tilePoint():Point{
			var _local2:int = (x / TileConst.TILE_WIDTH);
			var _local1:int = (y / TileConst.TILE_HEIGHT);
			return (new Point(_local2, _local1));
		}
		public function pixelsAlginTile():void{
			this.x = (((x / TileConst.TILE_WIDTH) * TileConst.TILE_WIDTH) + TileConst.WH);
			this.y = (((y / TileConst.TILE_HEIGHT) * TileConst.TILE_HEIGHT) + TileConst.HH);
		}
		public function distanceTo(tarPoint:Point):Number{
			return (Point.distance(this.point, tarPoint));
		}
		public function moveToTile(index_x:int, index_y:int):void{
			var _local3:Point = new Point(index_x, index_y);
			TileUtils.tileToPixels(_local3, _local3);
			moveTo(_local3.x, _local3.y);
		}
		public function setEffectStopFrame(actionData_id:String, frame:int):void{
			this.unit.setEffectStopFrame(actionData_id, frame);
		}
		public function faceTo(char:ISceneItem):void{
			if (((char) && (!(char.isDisposed)))) {
				this.dir = getDretion(point.x, point.y, Object(char).point.x, Object(char).point.y);
			}
		}
		public function faceToPoint(tar_x:Number, tar_y:Number):void{
			var _local3:Point = TileUtils.pixelsAlginTile(tar_x, tar_y);
			this.dir = getDretion(point.x, point.y, _local3.x, _local3.y);
		}
		public function removeEffect(idName:String, layer:String, passKey:String=null):void{
			if (unit) {
				unit.removeEffect(idName, layer, passKey);
			}
		}
		public function setDeath(value:Boolean=true, playEndFunc:Function=null, stopFrame:int=-1, t:int=320):void{
			this.isDeath = value;
			this.lockMove = value;
			this.lockSkill = false;
			this.setPoisoning(false);
			if (value) {
				this.headShape.visible = false;
				this.charBloodVisible = false;
				this.charNameVisible = false;
				bodyHeight2 = bodyHeight;
				this.bodyHeight = 60;
				this.setXY(x, y);
			} else {
				this.headShape.visible = true;
				this.charBloodVisible = true;
				if ((((type == "char")) || ((type == "hero")))) {
					this.charNameVisible = true;
				}
				bodyHeight = bodyHeight2;
				bodyHeight2 = 0;
				this.setXY(x, y);
			}
			if (value) {
				setBlock(key, key, true);
				this.stopMoveNow();
				if (stopFrame > 0) {
					this.play("death", AvatarUnit.PLAY_NEXT_RENDER, playEndFunc, stopFrame);
				} else {
					play("death", AvatarUnit.PLAY_NEXT_RENDER, playEndFunc, stopFrame);
				}
			} else {
				this.unit.stopPlay = false;
				if (((shadowShape) && (this.shadowShape.shadowUnit))) {
					this.shadowShape.shadowUnit.unit.stopPlay = false;
				}
				this.play("stand", AvatarUnit.PLAY_NEXT_RENDER, playEndFunc, stopFrame);
			}
			clearInterval(timeOutIndex);
			return;
			/*not popped
			clearInterval(hoeTimeIndex)
			*/
		}
		public function setTaskIcon(idName:String):void{
			this.headShape.setTopIcon(idName, "task");
		}
		public function setTopImage(value:String):void{
			headShape.setTopImage(value);
		}
		public function sayWord(value:String):void{
			this.headShape.sayWord(value);
		}
		public function get isSaying():Boolean{
			if (headShape) {
				if (headShape) {
					return (headShape.isSaying);
				}
			}
			return (false);
		}
		override public function playEnd(act:String):void{
			if (_ActionPlayEndFunc_ != null) {
				_ActionPlayEndFunc_(act);
			}
			if (unit.act_replayIndex <= 0) {
				_ActionPlayEndFunc_ = null;
			}
		}
		public function doCollection(playFunc:Function, playendFunc:Function):void{
			playFunc = playFunc;
			playendFunc = playendFunc;
			var this_:* = this;
			this.hoeTimeIndex = setTimeout(function (char:Char):void{
				clearTimeout(char.hoeTimeIndex);
				if (char) {
					if (playFunc != null) {
						playFunc(this_);
					}
					char.play("attack", 0, function ():void{
						if (playendFunc != null) {
							playendFunc(this_);
						}
						doCollection(playFunc, playendFunc);
					});
					collectionNum = (collectionNum + 1);
				}
			}, 900, this);
		}
		public function stopCollection():void{
			clearTimeout(this.hoeTimeIndex);
			this.lockMove = false;
			this.lockSkill = false;
			stopMoveNow(true);
		}
		
		public function set shadowShapeVisible(value:Boolean):void
		{
			if (shadowShape) {
				shadowShape.visible = value;
			}
		}
		
		override public function set type(value:String):void
		{
			super.type = value;
			if (unit) {
				this.unit.ownerType = value;
			}
			if (value == "char") {
				isCharMode = true;
			}
			if ((((value == "1item_pickup")) || ((value == "effect")))) {
				if (((shadowShape) && (shadowShape.parent))) {
					shadowShape.parent.removeChild(shadowShape);
				}
			}
		}
		
		public function shadowAvatar(idName:String):void
		{
			if (shadowShape) {
				if (unitFamale == null) {
					unitFamale = new AvatarUnit();
					unitFamale.isMain = _isMainChar_;
					unitFamale.init();
					unitFamale.charType = "unitFamale";
				}
				if (unitMale == null) {
					unitMale = new AvatarUnit();
					unitMale.isMain = _isMainChar_;
					unitMale.init();
					unitMale.charType = "unitMale";
				}
				if ((((idName == EngineGlobal.MALE_SHADOW)) || ((idName == EngineGlobal.FAMALE_SHADOW)))) {
					if (((!((shadowShape.shadowUnit.unit == unitFamale))) && (!((shadowShape.shadowUnit.unit == unitMale))))) {
						shadowShape.shadowUnit.unit.dispose();
					}
					if (idName == EngineGlobal.FAMALE_SHADOW) {
						shadowShape.shadowUnit.unit = unitFamale;
					} else {
						shadowShape.shadowUnit.unit = unitMale;
					}
				} else {
					shadowShape.shadowUnit.name = "otherhadow";
				}
				shadowShape.shadowUnit.loadAvatarPart("mid", idName);
				shadowShape.shadowUnit.unit.isCharMode = true;
				this.shadow_id = shadowShape.shadowUnit.id;
			}
			shadowShape.shadowUnit.unit.loadActSWF();
		}
		
		public function setShadowSize(value:int=0):void
		{
			shadowShape.setShadowSize(value);
		}
		
		override public function reset():void
		{
			super.reset();
			actionCounter = 0;
			dirCounter = 0;
			if (shadowShape) {
				shadowShape.visible = true;
			}
			this.isDeath = false;
			this.isRuning = false;
			this.isStealth = false;
			tmpPt = new Point();
			if ((this is MainChar) == false) {
				this.isCharMode = false;
			}
			_isDisposed_ = false;
			this.speciaState = "normal";
			this.data = null;
			this.proto = null;
			if (!headShape) {
				headShape = CharHead.createCharHead();
			}
			if (headShape) {
				if ((this is MainChar) == false) {
					headShape.bloodKitVisible = false;
					headShape.neiKitVisible = false;
				}
				this.headShape.visible = true;
			}
			this.setPoisoning(false);
			alpha = 1;
			clickEnabled = true;
			_lookDir = -1;
			isBoss = false;
			if (this.headShape) {
				this.headShape.recover();
			}
			if (headShape) {
				addChild(headShape);
			}
			if (shadowShape) {
				shadowShape.setShadowSize(0);
			}
		}
		
		override public function resetForDisposed():void
		{
			this.filters = [];
			_bounds_ = new Rectangle();
			isBoss = false;
			isElite = false;
			_point_ = new Point();
			_bodyHeight = 100;
			_isWalkMode = false;
			walkSpeed = 100;
			runSpeed = 230;
			visible = true;
			alpha = 1;
			x = 0;
			y = 0;
			clickEnabled = true;
			_speciaState = "normal";
			_isPoisoning = false;
			_hitArea_ = DEFAULT_HITAREA;
			isGlobalWalkMode = false;
			allwayShowName = false;
			_scene_id = null;
			hasPickup = false;
			canPickup = true;
			_isCharMode = false;
			_lookDir = -1;
			bodyHeight2 = 0;
			_key_ = null;
			lock = false;
			collectionNum = 0;
			super.resetForDisposed();
			headImageSprite = Engine.getSprite();
			var _local1:Boolean;
			headImageSprite.mouseEnabled = _local1;
			headImageSprite.mouseChildren = _local1;
			headImageSprite.tabChildren = _local1;
			shadowShape = CharShadow.createCharShowd();
			shadowShape.oid = this.id;
			headShape = CharHead.createCharHead();
			headShape.oid = this.id;
			shadowShape.visible = !(_hide_body_);
			headImageSprite.name = "headImageSprite";
		}
		
		override public function set dir(value:int):void
		{
			if (_lookDir != -1) {
				value = _lookDir;
			}
			if (this.speciaState == "STATE_ON_SELL") {
				return;
			}
			if (dir != value) {
				super.dir = value;
			}
		}
		
		public function setDrop(value:Shape):void
		{
			if (!value) {
				return;
			}
			if (_dropShape && _dropShape.parent) {
				_dropShape.parent.removeChild(_dropShape);
			}
			_dropShape = value;
			this.addChild(_dropShape);
		}
		
		override public function recover():void
		{
			dispose();
		}
		
		override public function dispose():void
		{
			var _local4:int;
			var _local2 = null;
			var _local3 = null;
			if (_isDisposed_) {
				return;
			}
			var _local1:int = Scene.scene.tarHash.indexOf(this);
			if (_local1 != -1) {
				Scene.scene.tarHash.splice(_local1, 1);
			}
			actionCounter = 0;
			dirCounter = 0;
			setBlock(key, key, true);
			this.isRuning = false;
			_tarPoint_ = null;
			_movePath_ = [];
			clearTimeout(timeOutIndex);
			clearTimeout(buffTimeOutIndex);
			clearTimeout(hoeTimeIndex);
			clearTimeout(stopTimeIndex);
			x = 0;
			y = 0;
			stopTimeIndex = 0;
			timeOutIndex = 0;
			buffTimeOutIndex = 0;
			hoeTimeIndex = 0;
			shadow_id = null;
			tileKey = null;
			lock = false;
			_local4 = 0;
			while (_local4 < imageQueue.length) {
				_local2 = imageQueue[_local4];
				if (_local2) {
					if (_local2.parent) {
						_local2.parent.removeChild(_local2);
					}
					_local2.dispose();
				}
				_local4++;
			}
			imageQueue = [];
			words = [];
			tmpPt = null;
			isAutoSay = false;
			sayWordTime = 0;
			collectionNum = 0;
			data = null;
			_moveEndFunc_ = null;
			moveParams = null;
			charMoveFunc = null;
			_bodyHeight = 0;
			walkSpeed = 0;
			runSpeed = 0;
			speciaState = null;
			poisoningFilters = null;
			clickEnabled = true;
			isBoss = false;
			isBackMoving = false;
			isGlobalWalkMode = false;
			allwayShowName = false;
			hasPickup = false;
			canPickup = true;
			bodyHeight2 = 0;
			_char_id_ = null;
			_layer_ = null;
			_speed_ = 0;
			_tarPoint_ = null;
			_totalTime_ = 0;
			_movePath_ = null;
			_bounds_ = null;
			_isRuning_ = false;
			_isDeath_ = false;
			_stopMove_ = false;
			_point_ = null;
			_loopMoveTime_ = 0;
			_isDeath = false;
			_lockMove = false;
			_lockSkill = false;
			_isWalkMode = false;
			_isStealth = false;
			_scene_id = null;
			_isCharMode = false;
			_lookDir = -1;
			_tile_ = null;
			_isPoisoning = false;
			_hitArea_ = null;
			this.filters = [];
			super.dispose();
			if (headShape) {
				headShape.dispose();
			}
			headShape = null;
			if (headImageSprite) {
				while (headImageSprite.numChildren) {
					_local3 = (headImageSprite.removeChildAt((headImageSprite.numChildren - 1)) as HeadImage);
					if (_local3) {
						_local3.dispose();
					}
				}
			}
			if (((headImageSprite) && (headImageSprite.parent))) {
				headImageSprite.parent.removeChild(headImageSprite);
			}
			if (headImageSprite) {
				Engine.putSprite(headImageSprite);
			}
			headImageSprite = null;
			if (shadowShape) {
				shadowShape.dispose();
			}
			shadowShape = null;
			if (_dropShape) {
				_dropShape.graphics.clear();
			}
			_dropShape = null;
			_vx_ = 0;
			_vy_ = 0;
			if (charQueueHash.length < Asswc.POOL_INDEX) {
				charQueueHash.push(this);
			}
		}
		
		public function tarMoveTo(value:Array):void
		{
			clearTimeout(hoeTimeIndex);
			_tarPoint_ = value.shift();
			if (!_tarPoint_) {
				_CharMoveEnd_();
				return;
			}
			var _local2:int = Point.distance(_tarPoint_, new Point(x, y));
			if ((((_local2 <= TileConst.WH)) && ((value.length == 0)))) {
				_CharMoveEnd_();
				return;
			}
			if (value.length >= 1) {
				checkAndSetDir(true);
			} else {
				checkAndSetDir();
			}
			if (isCharMode) {
				((value.length)>2) ? isNeedChanegSpeed = true : isNeedChanegSpeed = false;

				if (value.length) {
					if (isWalkMode) {
						this.play("walk", AvatarUnit.PLAY_NEXT_RENDER);
					} else {
						this.play("run", AvatarUnit.PLAY_NEXT_RENDER);
					}
				} else {
					if ((((this.dir == 0)) || ((dir == 4)))) {
						this.play("walk", AvatarUnit.PLAY_NEXT_RENDER);
					} else {
						if (isWalkMode) {
							this.play("walk", AvatarUnit.PLAY_NEXT_RENDER);
						} else {
							this.play("run", AvatarUnit.PLAY_NEXT_RENDER);
						}
					}
				}
			} else {
				if (this.act != "walk") {
					this.play("walk", AvatarUnit.PLAY_NEXT_RENDER);
				}
			}
			setMoveSpeed(act);
			unit.loadActSWF();
			_movePath_ = value;
			lockMove = false;
			isRuning = true;
			_totalTime_ = 0;
			_loopMoveTime_ = getTimer();
			loopMove();
		}
		
		private function updateWalkMode():void
		{
			var _local1:int;
			var _local3:Point = point;
			var _local4:Point = TileUtils.pixelsAlginTile(_tarPoint_.x, _tarPoint_.y);
			var _local2:int = Point.distance(_local3, _local4);
			if ((((dir == 0)) || ((dir == 4)))) {
				_local1 = TileConst.TILE_HEIGHT;
			} else {
				if ((((((((dir == 1)) || ((dir == 3)))) || ((dir == 5)))) || ((dir == 7)))) {
					if (((((proto) && (proto.hasOwnProperty("owner_char")))) && ((proto.owner_char > 0)))) {
						_local1 = TileConst.TILE_WIDTH;
					} else {
						_local1 = (TileConst.Tile_XIE + 8);
					}
				} else {
					_local1 = TileConst.TILE_WIDTH;
				}
			}
			if (_local2 > _local1) {
				if (isWalkMode) {
					isWalkMode = false;
				}
			} else {
				if (!isWalkMode) {
					isWalkMode = true;
				}
			}
		}
		
		public function setMoveSpeed(act:String):void
		{
			if (isCharMode) {
				if (act == "walk") {
					if ((((dir == 0)) || ((dir == 4)))) {
						_speed_ = (walkSpeed / 2);
					} else {
						_speed_ = walkSpeed;
					}
				} else {
					if (act == "run") {
						if (isWalkMode) {
							if ((((dir == 0)) || ((dir == 4)))) {
								_speed_ = (walkSpeed / 2);
							} else {
								_speed_ = walkSpeed;
							}
						} else {
							if ((((dir == 0)) || ((dir == 4)))) {
								_speed_ = walkSpeed;
							} else {
								_speed_ = runSpeed;
							}
						}
					}
				}
			} else {
				if ((((dir == 0)) || ((dir == 4)))) {
					_speed_ = (runSpeed / 2);
				} else {
					_speed_ = runSpeed;
				}
			}
		}
		
		override public function play(act:String, renderType:int=0, playEndFunc:Function=null, stopFrame:int=-1):void
		{
			if (this.lockSkill) {
				return;
			}
			setMoveSpeed(act);
			if (isCharMode) {
				this.shadowShape.play(act, renderType, null, stopFrame);
			}
			super.play(act, renderType, playEndFunc, stopFrame);
		}
		
		public function loop():void{
			var _local2:int;
			var _local4:int;
			var _local1 = null;
			var _local3 = null;
			if (shadowShape) {
				shadowShape.y = (y + 5);
				shadowShape.x = x;
			}
			if (headShape) {
				headShape.y = (y - bodyHeight);
				headShape.x = x;
			}
			if (headImageSprite) {
				this.headImageSprite.y = y;
				this.headImageSprite.x = x;
			}
			if (enterFrameCheck) {
				enterFrameCheck = false;
				checkCenterPoint();
				updateAlpha();
			}
			if ((getTimer() - checkTimeIndex) < 85) {
				return;
			}
			checkTimeIndex = getTimer();
			if (((imageQueue.length) && (((getTimer() - imageDur) > 80)))) {
				imageDur = getTimer();
				_local2 = 1;
				if (FPSUtils.fps < 5) {
					_local2 = imageQueue.length;
				}
				_local4 = 0;
				while (_local4 < _local2) {
					_local1 = imageQueue.shift();
					_local1.startPlay();
					if (headImageSprite) {
						this.headImageSprite.addChild(_local1);
					}
					if (((((((headImageSprite) && ((headImageSprite.parent == null)))) && (!(this.isDisposed)))) && (this.parent))) {
						Scene.scene.topLayer.addChild(headImageSprite);
					}
					_local4++;
				}
			}
			if (((((((headImageSprite) && (headImageSprite.parent))) && ((headImageSprite.numChildren == 0)))) && ((imageQueue.length == 0)))) {
				while (headImageSprite.numChildren) {
					_local3 = (headImageSprite.removeChildAt((headImageSprite.numChildren - 1)) as HeadImage);
					if (_local3) {
						_local3.dispose();
					}
				}
				headImageSprite.parent.removeChild(headImageSprite);
			}
			if (((((((this.headShape) && (headShape.bloodKitVisible))) && (this.proto))) && (this.proto.hasOwnProperty("currHP")))) {
				if (proto.currHP != headShape.currHP) {
					this.setBlood(this.proto.currHP, this.proto.maxHP);
				}
			}
			if (((lockMove) && (((getTimer() - lookMoveTime) > 1200)))) {
				lockMove = false;
			}
			if (((lockSkill) && (((getTimer() - lookSkillTime) > 1200)))) {
				lockSkill = false;
			}
			autoSay();
		}
		
		public function loopMove():void
		{
			if (this != Scene.scene.mainChar) {
				if ((getTimer() - frameIndex) < 15) {
					return;
				}
				frameIndex = getTimer();
			}
			if (_movePath_ && _movePath_.length >= 0 && _isRuning_ && !_isDeath_ && !_stopMove_) {
				_totalTime_ = _totalTime_ + getTimer() - _loopMoveTime_;
				if (_totalTime_ > 0 && _tarPoint_) {
					_tarMove_();
				}
			}
			_loopMoveTime_ = getTimer();
		}
		
		override public function onBodyRender(renderType:String, bitmapType:String, bitmapData:BitmapData, tx:int, ty:int, shadow:BitmapData=null):void
		{
			super.onBodyRender(renderType, bitmapType, bitmapData, tx, ty, shadow);
			if (isBoss && bmd_mid && bmd_mid.bitmapData == null && type == "monster_normal" && act != "death") {
				if ((getTimer() - showBGTime) > 100) {
					showBGTime = getTimer();
					if (bmd_mid.bitmapData != default_bitmapData) {
						bmd_mid.bitmapData = default_bitmapData;
					}
					bmd_mid.x = -default_bitmapData.width / 2;
					bmd_mid.y = -default_bitmapData.height - 3;
				}
			} else {
				showBGTime = getTimer();
			}
		}
		
		public function get movePath():Array
		{
			return _movePath_;
		}
		
		public function checkAndGotoStopMove():void
		{
			if (isRuning == false && !_tarPoint_ && _movePath_.length == 0) {
				stopMoveNow(true);
			}
		}
		
		public function stopMove(playStand:Boolean=false, playAction:Boolean=true):void
		{
			Log.debug(this, "STOP_MOVE");
			stopMoveNow(playStand, playAction);
		}
		
		public function stopMoveNow(playStand:Boolean=false, playAction:Boolean=true):void
		{
			stopDurTime = getTimer();
			if (playAction && unit) {
				if (playStand || (act != "stand" && act != "death" && !this.isLoopMove && act.indexOf("warm") == -1)) {
					this.play("stand", AvatarUnit.UN_PLAY_NEXT_RENDER);
				}
			}
			var distance:int = Point.distance(point, new Point(x, y));
			if (distance > 6) {
			}
			this.isRuning = false;
			_tarPoint_ = null;
			_movePath_ = [];
		}
		
		public function gotoAndStop(value:int):void
		{
			this.start();
			this.unit.mainActionData.currFrame = value;
			this.unit.onBodyRender(AvatarUnit.UN_PLAY_NEXT_RENDER);
			this.stop();
		}
		
		public function changeCharMoveAction():void
		{
			if (_tarPoint_) {
				var pass:int;
				var distance:int = Point.distance(_tarPoint_, new Point(x, y));
				if (isCharMode) {
					if (dir == 0 || dir == 4) {
						pass = TileConst.TILE_HEIGHT * 2;
					} else {
						pass = TileConst.TILE_WIDTH * 2;
					}
					if (isNeedChanegSpeed && distance < pass) {
						this.play("walk");
					} else {
						if (this.dir == 0 || this.dir == 4) {
							if (isWalkMode) {
								this.play("walk");
							} else {
								this.play("run");
							}
						} else {
							if (isWalkMode) {
								this.play("walk");
							} else {
								this.play("run");
							}
						}
					}
				}
			}
		}
		
		public function get isWalkMode():Boolean
		{
			return _isWalkMode;
		}
		public function set isWalkMode(value:Boolean):void
		{
			if (isCharMode) {
				if (isGlobalWalkMode) {
					_isWalkMode = true;
				} else {
					_isWalkMode = value;
				}
			} else {
				_isWalkMode = value;
			}
			changeCharMoveAction();
		}
		
		public function _tarMove_():void
		{
			var _local9:Number;
			var _local7:Number;
			var _local4 = null;
			var _local6 = null;
			var _local3 = null;
			var _local10:int;
			var _local5:int;
			if (((_stopMove_) || (!(Scene.scene.isReady)))) {
				return;
			}
			if ((((_tarPoint_ == null)) || ((_speed_ == 0)))) {
				_CharMoveEnd_();
				if (_speed_ == 0) {
					trace("移动速度为0 ！");
				}
				return;
			}
			var _local8:int = _speed_;
			tmpPt.x = x;
			tmpPt.y = y;
			var _local2:Number = Point.distance(tmpPt, _tarPoint_);
			var _local1:int = ((_local2 / _local8) * 1000);
			if (_totalTime_ >= _local1) {
				_totalTime_ = (_totalTime_ - _local1);
			} else {
				_local1 = _totalTime_;
				_totalTime_ = 0;
			}
			if (_local1 > 0) {
				_local9 = ((_local8 * _local1) / 1000);
				_local7 = (_local9 / _local2);
				_local4 = Point.interpolate(_tarPoint_, tmpPt, _local7);
				if (((((Scene.scene.stage) && (Scene.scene.isBlockMode))) && (_isMainChar_))) {
					_local6 = TileUtils.pixelsToTile(_local4.x, _local4.y);
					_local3 = (TileGroup.instance.take(((_local6.x + "|") + _local6.y)) as Tile);
					_local10 = Point.distance(TileUtils.tileToPixels(_local6), new Point(x, y));
					if (((((((_local3) && ((_local3.type <= 0)))) && ((_local10 <= 5)))) && (!((((_local6.x + "|") + _local6.y) == key))))) {
						_CharMoveEnd_();
						return;
					}
				}
				if (isMainChar) {
					this.x = _local4.x.toFixed(2);
					this.y = _local4.y.toFixed(2);
				} else {
					this.x = _local4.x;
					this.y = _local4.y;
				}
				tmpPt.x = x;
				tmpPt.y = y;
				if (!_tarPoint_) {
					return;
				}
				_local2 = Point.distance(tmpPt, _tarPoint_);
				if (((isCharMode) && ((isNeedChanegSpeed == false)))) {
					checkActDur = getTimer();
					if ((((this.dir == 0)) || ((this.dir == 4)))) {
						if (isWalkMode) {
							this.play("walk");
						} else {
							this.play("run");
						}
					} else {
						if (isWalkMode) {
							this.play("walk");
						} else {
							this.play("run");
						}
					}
				}
			}
			if (_local2 <= 0.5) {
				x = _tarPoint_.x;
				y = _tarPoint_.y;
				_totalTime_ = 0;
				if (_movePath_.length > 0) {
					_tarPoint_ = _movePath_.shift();
					if (((!(isLoopMove)) || ((_movePath_.length >= 0)))) {
						updateWalkMode();
						_local5 = 15;
						if ((((_movePath_.length == 0)) && (!(isLoopMove)))) {
							_local5 = 5;
						}
						if (Point.distance(new Point(this.x, this.y), _tarPoint_) >= _local5) {
							if (TileUtils.pixelsToTile(x, y).toString() != TileUtils.pixelsAlginTile(_tarPoint_.x, _tarPoint_.y).toString()) {
								this.dir = LinearUtils.getCharDir(this.x, this.y, _tarPoint_.x, _tarPoint_.y);
							}
						}
					}
					changeCharMoveAction();
				} else {
					if (_movePath_.length == 0) {
						_CharMoveEnd_();
					}
				}
			}
			if (_totalTime_ > 0) {
				_tarMove_();
			}
		}
		
		public function getRunDir():int
		{
			if (!_tarPoint_) {
				return dir;
			}
			var currP:Point = TileUtils.pixelsToTile(this.x, this.y);
			var tarP:Point = TileUtils.pixelsToTile(_tarPoint_.x, _tarPoint_.y);
			if (currP.toString() != tarP.toString()) {
				return LinearUtils.getCharDir(this.x, this.y, _tarPoint_.x, _tarPoint_.y);
			}
			return dir;
		}
		
		protected function checkAndSetDir(now:Boolean=false):void
		{
			if (!_tarPoint_) {
				return;
			}
			var currP:Point = TileUtils.pixelsToTile(this.x, this.y);
			var tarP:Point = TileUtils.pixelsToTile(_tarPoint_.x, _tarPoint_.y);
			if (currP.toString() != tarP.toString() && (!isLoopMove || now)) {
				this.dir = LinearUtils.getCharDir(this.x, this.y, _tarPoint_.x, _tarPoint_.y);
			}
		}
		
		protected function _CharMoveEnd_():void
		{
			if (!_isMainChar_) {
				stopMoveNow();
			}
			if (moveEndFunc != null) {
				if (moveParams) {
					moveEndFunc.apply(null, moveParams);
				} else {
					moveEndFunc();
				}
			}
		}
		
		public function _ChangeTileFunc_():void
		{
			if (type == "hero") {
				if (walkNextTileFunc != null) {
					walkNextTileFunc.apply(null, walkNextTileParams);
				}
			} else {
				otherCharWalkNxetTile();
			}
		}
		
		public function otherCharWalkNxetTile():void
		{
			if (walkNextTileFunc != null) {
				walkNextTileFunc.apply(null, walkNextTileParams);
				
				walkNextTileFunc = null;
				walkNextTileParams = null;
			}
		}
		
		public function updateAlpha():void
		{
			if (tileKey != key) {
				var tile:Tile = TileGroup.instance.take(key) as Tile;
				if (tile) {
					if (isStealth) {
						if (this.alpha != 0.5) {
							this.alpha = 0.5;
						}
					} else  if (tile.isAlpha) {
						if (this.alpha != 0.5 || tileKey == tile.key) {
							this.alpha = 0.5;
						}
					} else {
						if (this.alpha != 1 || tileKey == tile.key) {
							this.alpha = 1;
						}
					}
					tileKey = key;
				}
			}
		}
		
		public function get isCharMode():Boolean
		{
			return _isCharMode;
		}
		public function set isCharMode(value:Boolean):void
		{
			_isCharMode = value;
			if (unit) {
				unit.isCharMode = value;
			}
		}

	}
} 
