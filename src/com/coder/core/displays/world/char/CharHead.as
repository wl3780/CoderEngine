package com.coder.core.displays.world.char
{
	import com.coder.core.controls.elisor.HeartbeatFactory;
	import com.coder.core.displays.DisplaySprite;
	import com.coder.core.displays.avatar.AvatarEffect;
	import com.coder.core.displays.avatar.AvatarUnitDisplay;
	import com.coder.core.displays.items.Image;
	import com.coder.core.displays.world.SceneConst;
	import com.coder.engine.Asswc;
	import com.coder.global.EngineGlobal;
	import com.coder.utils.FPSUtils;
	import com.coder.utils.Hash;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.Loader;
	import flash.display.Sprite;
	import flash.geom.Matrix;
	import flash.geom.Rectangle;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.utils.getTimer;
	
	public class CharHead extends DisplaySprite
	{
		private static var intanceHash:Vector.<CharHead> = new Vector.<CharHead>();
		private static var cacheBmdHash:Hash = new Hash();
		private static var charHeadQueue:Array = [];

		private static var defaultTextFormat:TextFormat = new TextFormat("宋体", 12);

		private static var _blood_:BloodKit = new BloodKit();
		private static var _nei_:BloodKit = new BloodKit(0xFFFF00);
		
		private static var _nameText_:TextField = new TextField();
		private static var _professionNameText_:TextField = new TextField();
		private static var _unionNameText_:TextField = new TextField();
		private static var _sprite_:Sprite = new Sprite();
		private static var _bloodText_:TextField = new TextField();
		
		private static const _renderNum_:int = 1;
		private static var _renderIndex_:int = 0;

		public var char_id:String;
		public var cacheMode:Boolean = false;
		
		private var bmd:BitmapData;
		private var topIdName:String;
		private var renderInterval:int;
		private var renderIndex:int;
		private var renderTime:int;
		private var tmpTime:int;
		
		private var _headIconSize:int = 30;
		private var _disposed_:Boolean = false;
		private var _name_:String;
		private var _unionName_:String;
		private var _professionName_:String;
		private var _nameColor_:uint;
		private var _professionNameColor_:uint;
		private var _unionColor_:uint;
		private var _professionNameVisible_:Boolean;
		private var _nameVisible_:Boolean;
		private var _unionNameVisible_:Boolean;
		private var _bloodKitVisible_:Boolean;
		private var _owner_:String;
		private var _currBlood_:int;
		private var _maxBlood_:int;
		private var _neiKitVisible_:Boolean;
		private var _currNei_:int;
		private var _maxNei_:int;
		private var _headIconLeft:DisplayObject;
		private var _headIconRight:DisplayObject;
		private var _flag:DisplayObject;
		private var _headIconCenter:DisplayObject;
		private var _headBitmapData:BitmapData;
		private var _topIcon:AvatarEffect;
		private var _topImage:Image;
		private var _topIndexY:int;
		private var _tile:CharTitleImage;
		private var _wordShape_:WordShape;
		private var _isDisposed:Boolean;
		private var _heidTitle:Boolean;
		private var _isCharNameBitmapMode:Boolean;

		public function CharHead()
		{
			init();
		}
		
		public static function setBloodBitmapData(value:BitmapData):void
		{
			_blood_.overBitmapData = value;
		}
		
		public static function setNeiLiBitmapData(value:BitmapData):void
		{
			_nei_.overBitmapData = value;
		}
		
		public static function setBGBitmapData(value:BitmapData):void
		{
			_nei_.bitmapData = value;
			_blood_.bitmapData = value;
		}
		
		public static function createCharHead():CharHead
		{
			var result:CharHead = null;
			if (charHeadQueue.length) {
				result = charHeadQueue.pop();
				result.resetForDisposed();
			} else {
				result = new CharHead();
			}
			return result;
		}

		public function get currHP():int
		{
			return _currBlood_;
		}
		public function get maxHP():int
		{
			return _maxBlood_;
		}
		
		public function sayWord(value:String):void
		{
			if (value) {
				if (!_wordShape_) {
					_wordShape_ = new WordShape();
				}
				if (!_wordShape_.parent) {
					addChild(_wordShape_);
				}
				_wordShape_.sayWord(value);
				updateEffectPos();
			} else {
				if (_wordShape_) {
					_wordShape_.closeFunc();
				}
			}
		}
		
		public function setHeidTitle(value:Boolean):void
		{
			_heidTitle = value;
			if (value) {
				if (_tile && _tile.parent) {
					_tile.parent.removeChild(_tile);
				}
			} else {
				if (_tile) {
					addChild(_tile);
				}
			}
		}
		
		public function showTile(char:Char, tiles:Array, type:int=0):void
		{
			if (tiles && !_tile) {
				_tile = CharTitleImage.createCharTitleImage(char);
				_tile.onReanderFunc = doit;
			} else {
				if (_tile && !_tile.char) {
					_tile = CharTitleImage.createCharTitleImage(char);
					_tile.onReanderFunc = doit;
				}
			}
			_tile.setTiles(tiles, type);
			if (tiles.length) {
				this.setHeadIcon(_tile);
			} else {
				this.setHeadIcon(null);
			}
			if (_heidTitle) {
				if (_tile && _tile.parent) {
					_tile.parent.removeChild(_tile);
				}
			}
			setHeidTitle(_heidTitle);
			doit();
		}
		
		public function get currNei():int
		{
			return _currNei_;
		}
		public function get maxNei():int
		{
			return _maxNei_;
		}
		
		public function setNeiValue(curr:int, max:int):void
		{
			_currNei_ = curr;
			_maxNei_ = max;
			doit();
		}
		
		public function setBloodValue(curr:int, max:int):void
		{
			_currBlood_ = curr;
			_maxBlood_ = max;
			doit();
		}
		
		public function setTopImage(value:Object):void
		{
			if (!_topImage) {
				_topImage = new Image();
			}
			_topImage.source = value;
			addChild(_topImage);
			doit();
		}
		
		public function setTopIcon(idName:String, passKey:String=null):void
		{
			if (_topIcon) {
				if (_topIcon.parent) {
					_topIcon.parent.removeChild(_topIcon);
				}
				_topIcon.recover();
			}
			if (!idName || idName == "0") {
				topIdName = null;
			} else {
				_topIcon = new AvatarEffect();
				_topIcon.name = "task_icon";
				topIdName = idName;
				_topIcon.loadEffect(idName, SceneConst.TOP_LAYER, passKey);
				addChild(_topIcon);
			}
			doit();
		}
		
		public function set bloodKitVisible(value:Boolean):void
		{
			_bloodKitVisible_ = value;
			doit();
		}
		
		public function set neiKitVisible(value:Boolean):void
		{
			_neiKitVisible_ = value;
			doit();
		}
		
		public function set nameVisible(value:Boolean):void
		{
			if (_nameVisible_ == value) {
				return;
			}
			_nameVisible_ = value;
			doit();
		}
		
		public function set professionNameVisible(value:Boolean):void
		{
			if (_professionNameVisible_ == value) {
				return;
			}
			_professionNameVisible_ = value;
			doit();
		}
		
		public function set professionNameColor(value:uint):void
		{
			if (_professionNameColor_ == value) {
				return;
			}
			_professionNameColor_ = value;
			doit();
		}
		
		public function set nameColor(value:uint):void
		{
			if (_nameColor_ == value) {
				return;
			}
			_nameColor_ = value;
			doit();
		}
		
		public function set professionName(value:String):void
		{
			if (_professionName_ == value) {
				return;
			}
			_professionName_ = value;
			doit();
		}
		
		public function set unionName(value:String):void
		{
			if (_unionName_ == value) {
				return;
			}
			if (value) {
				_unionNameVisible_ = true;
			} else {
				_unionNameVisible_ = false;
			}
			_unionName_ = value;
			doit();
		}
		
		override public function set name(value:String):void
		{
			if (_name_ == value) {
				return;
			}
			_name_ = value;
			doit();
		}
		
		public function get neiKitVisible():Boolean
		{
			return _neiKitVisible_;
		}
		
		public function get bloodKitVisible():Boolean
		{
			return _bloodKitVisible_;
		}
		
		public function get nameVisible():Boolean
		{
			return _nameVisible_;
		}
		
		public function get nameColor():uint
		{
			return _nameColor_;
		}
		
		public function get professionNameVisible():Boolean
		{
			return _professionNameVisible_;
		}
		
		public function get professionNameColor():uint
		{
			return _professionNameColor_;
		}
		
		public function get professionName():String
		{
			return _professionName_;
		}
		
		public function get unionName():String
		{
			return _unionName_;
		}
		
		override public function get name():String
		{
			return _name_;
		}
		
		public function showFlag(value:DisplayObject):void
		{
			if (_flag && _flag.parent) {
				_flag.parent.removeChild(_flag);
			}
			_flag = value;
			this.doit();
		}
		
		public function disposeFlag():void
		{
			if (_flag) {
				if (_flag.parent){
					_flag.parent.removeChild(_flag);
				}
				if (_flag as Loader) {
					Loader(_flag).unloadAndStop();
				}
				if (_flag as Bitmap) {
					Object(_flag).bitmapData = null;
				}
				_flag = null;
			}
		}
		
		public function setHeadIcon(value:Object, align:String="center"):void
		{
			if (!value) {
				this.disposeHeadIcon(align);
				return;
			}
			
			var icon:DisplayObject = null;
			if (value as BitmapData) {
				icon = new Bitmap();
				Bitmap(icon).bitmapData = value as BitmapData;
			} else {
				if (value as DisplayObject) {
					icon = value as DisplayObject;
				}
			}
			if (align == "left") {
				_headIconLeft = icon;
			}
			if (align == "right") {
				_headIconRight = icon;
			}
			if (align == "center") {
				_headIconCenter = icon;
			}
			if (icon) {
				this.addChild(icon);
			}
			this.doit();
		}
		
		public function disposeHeadIcon(type:String="all"):void
		{
			if (_headIconLeft && (type == "all" || type == "left")) {
				if (_headIconLeft.parent) {
					_headIconLeft.parent.removeChild(_headIconLeft);
				}
				if (_headIconLeft as Loader) {
					Loader(_headIconLeft).unloadAndStop();
				}
				if (_headIconLeft as Bitmap) {
					Bitmap(_headIconLeft).bitmapData = null;
				}
				_headIconLeft = null;
			}
			if (_headIconRight && (type == "all" || type == "right")) {
				if (_headIconRight.parent) {
					_headIconRight.parent.removeChild(_headIconRight);
				}
				if (_headIconRight as Loader) {
					Loader(_headIconRight).unloadAndStop();
				}
				if (_headIconRight as Bitmap) {
					Bitmap(_headIconRight).bitmapData = null;
				}
				_headIconRight = null;
			}
			if (_headIconCenter && (type == "all" || type == "center")) {
				if (_headIconCenter.parent) {
					_headIconCenter.parent.removeChild(_headIconCenter);
				}
				if (_headIconCenter as Loader) {
					Loader(_headIconCenter).unloadAndStop();
				}
				if (_headIconCenter as Bitmap) {
					Bitmap(_headIconCenter).bitmapData = null;
				}
				_headIconCenter = null;
			}
		}
		
		public function doit():void
		{
			tmpTime = getTimer();
			HeartbeatFactory.getInstance().addFrameOrder(onEnterFrameFunc);
		}
		
		protected function onEnterFrameFunc():void
		{
			_renderIndex_ = _renderIndex_ + 1;
			if (_renderIndex_ > 1) {
				_renderIndex_ = 0;
			}
			var char:Char = AvatarUnitDisplay.takeUnitDisplay(oid) as Char;
			if (!char || char.char_id != char_id) {
				HeartbeatFactory.getInstance().removeFrameOrder(onEnterFrameFunc);
				return;
			}
			if (renderIndex == _renderIndex_ || getTimer() - tmpTime > renderInterval || FPSUtils.fps > 30) {
				tmpTime = getTimer();
				HeartbeatFactory.getInstance().removeFrameOrder(onEnterFrameFunc);
				if (char) {
					onRender();
				}
			}
		}
		
//		public function init():void{
		override protected function init():void
		{
			super.init();
			this.tabEnabled = false;
			this.tabChildren = false;
			this.mouseEnabled = false;
			this.mouseChildren = false;
			
			_nameText_.filters = EngineGlobal.textFilter;
			_unionNameText_.filters = EngineGlobal.textFilter;
			_professionNameText_.filters = EngineGlobal.textFilter;
			_nameText_.defaultTextFormat = defaultTextFormat;
			_unionNameText_.defaultTextFormat = defaultTextFormat;
			_professionNameText_.defaultTextFormat = defaultTextFormat;
			renderInterval = ((Math.random() * 700) >> 0) + 100;
			renderIndex = ((Math.random() * (1 + 1)) >> 0);
		}
		
		public function set isCharNameBitmapMode(value:Boolean):void
		{
			_isCharNameBitmapMode = value;
		}
		
		override public function onRender():void
		{
			if (_disposed_) {
				return;
			}
			if (_isDisposed) {
				return;
			}
			
			var _this:* = _sprite_;
			_nameText_.htmlText = "";
			_professionNameText_.htmlText = "";
			_unionNameText_.htmlText = "";
			_bloodText_.htmlText = "";
			if (this.bmd) {
				this.bmd.dispose();
				this.bmd = null;
			}
			if (cacheMode) {
				bmd = cacheBmdHash.take(_name_ + _nameColor_) as BitmapData;
				if (bmd && (bmd.width == 0 || bmd.height)) {
					bmd = null;
				}
			}
			this.graphics.clear();
			while (_this.numChildren) {
				_this.removeChildAt(0);
			}
			if (_flag && _flag.parent) {
				_flag.parent.removeChild(_flag);
			}
			if (_headIconLeft && _headIconLeft.parent) {
				_headIconLeft.parent.removeChild(_headIconLeft);
			}
			if (_headIconRight && _headIconRight.parent) {
				_headIconRight.parent.removeChild(_headIconRight);
			}
			if (_headIconCenter && _headIconCenter.parent) {
				_headIconCenter.parent.removeChild(_headIconCenter);
			}
			if (_bloodKitVisible_) {
				_this.addChild(_bloodText_);
				_this.addChild(_blood_);
			}
			if (_neiKitVisible_) {
				_this.addChild(_nei_);
			}
			if (_name_ && _nameVisible_) {
				_this.addChild(_nameText_);
			}
			if (_professionName_ && _professionNameVisible_) {
				_this.addChild(_professionNameText_);
			}
			if (_unionName_) {
				_this.addChild(_unionNameText_);
			}
			if (_professionName_ && _professionNameVisible_) {
				with (_professionNameText_) {
					textColor = professionNameColor;
					width = 200;
					htmlText = _professionName_;
					width = (textWidth + 4);
					x = (-(width) / 2);
					height = (textHeight + 4);
					y = 0;
				}
			}
			if (_unionName_ && _unionNameVisible_) {
				with (_unionNameText_) {
					textColor = 0xFFFFFF;
					width = 200;
					htmlText = _unionName_;
					width = (textWidth + 4);
					x = (-(width) / 2);
					height = (textHeight + 4);
				}
				if (_professionName_ && _unionNameVisible_) {
					_unionNameText_.y = _professionNameText_.textHeight + 2;
				} else {
					_unionNameText_.y = 0;
				}
			}
			if (_name_ && _nameVisible_) {
				with (_nameText_) {
					textColor = nameColor;
					width = 200;
					htmlText = _name_;
					width = (textWidth + 4);
					x = (-(width) / 2);
					height = (textHeight + 4);
					if (_unionName_ && _nameVisible_) {
						y = _unionNameText_.y + _unionNameText_.textHeight + 2;
					} else {
						if (_professionName_ && _professionNameVisible_) {
							y = _professionNameText_.y + _professionNameText_.textHeight + 2;
						} else {
							y = 0;
						}
					}
				}
			}
			if (_bloodKitVisible_) {
				with (_bloodText_) {
					defaultTextFormat = new TextFormat("宋体", 12, 0xFFFFFF);
					filters = EngineGlobal.textFilter;
					width = 200;
					text = _currBlood_ + "/" + _maxBlood_;
					width = textWidth + 4;
					x = -width / 2 + 1;
					height = textHeight + 4;
					if (_nameText_) {
						y = _nameText_.y + _nameText_.textHeight + 4;
					} else {
						if (_unionNameText_) {
							y = _unionNameText_.y + _unionNameText_.textHeight + 2;
						} else {
							if (_professionNameText_) {
								y = _professionNameText_.y + _professionNameText_.textHeight + 2;
							}
						}
					}
				}
				with (_blood_) {
					width = 46;
					height = 5;
					setValue(_currBlood_, _maxBlood_);
					x = (-(width) / 2);
					y = ((_bloodText_.y + 16) + 2);
				}
				with (_nei_) {
					width = 46;
					height = 5;
					setValue(_currNei_, _maxNei_);
					x = -width / 2;
					y = _blood_.y + 4;
				}
			}
			var rect:Rectangle = _sprite_.getBounds(null);
			rect.height = _sprite_.height;
			rect.width = _sprite_.width;
			var pass:Boolean = true;
			if (rect.isEmpty()) {
				pass = false;
			}
			var mat:Matrix = new Matrix();
			mat.tx = -rect.x;
			mat.ty = -rect.y;
			if (!bmd) {
				this.bmd = new BitmapData(_sprite_.width + 2, _sprite_.height + 2, true, 0);
				this.bmd.draw(_sprite_, mat);
			}
			if (_nameText_.parent) {
				_nameText_.parent.removeChild(_nameText_);
			}
			if (_professionNameText_.parent) {
				_professionNameText_.parent.removeChild(_professionNameText_);
			}
			if (_unionNameText_.parent) {
				_unionNameText_.parent.removeChild(_unionNameText_);
			}
			if (_blood_.parent) {
				_blood_.parent.removeChild(_blood_);
			}
			if (pass) {
				mat = new Matrix();
				mat.tx = rect.x;
				mat.ty = -bmd.height;
				this.graphics.beginBitmapFill(bmd, mat, false);
				this.graphics.drawRect(mat.tx, mat.ty, bmd.width, bmd.height);
				_topIndexY = -bmd.height;
			} else {
				_topIndexY = 0;
			}
			if (cacheMode) {
				cacheBmdHash.put((_name_ + _nameColor_), bmd.clone());
			}
			if (_headIconLeft) {
				_headIconLeft.y = -_headIconSize / 2;
				_headIconLeft.x = _blood_.width - _headIconSize - 5;
				if (_headIconLeft.width > 0) {
					_headIconLeft.x = mat.tx - _headIconLeft.width - 1;
				}
				if (!_headIconLeft.parent) {
					this.addChild(_headIconLeft);
				}
			}
			if (_flag) {
				if (_headIconLeft) {
					_flag.x = _headIconLeft.x - _headIconSize - 5;
					if (_flag.width > 0) {
						_flag.x = _headIconLeft.x - _flag.width - 1;
					}
				} else {
					_flag.x = ((mat.tx - _headIconSize) - 5);
					if (_flag.width > 0) {
						_flag.x = _blood_.width - _flag.width - 1;
					}
				}
				_flag.y = -_headIconSize / 2;
				if (!_flag.parent) {
					this.addChild(_flag);
				}
			}
			if (_headIconRight) {
				_headIconRight.y = -_headIconSize / 2;
				_headIconRight.x = _blood_.width - _headIconSize + 5;
				if (_headIconRight.width > 0) {
					_blood_.width - _headIconRight.width;
				}
				if (!_headIconRight.parent) {
					this.addChild(_headIconRight);
				}
			}
			if (_headIconCenter) {
				_headIconCenter.y = -bmd.height;
				_headIconCenter.x = 0;
				if (!_heidTitle && !_headIconCenter.parent) {
					this.addChild(_headIconCenter);
				}
				_topIndexY = _headIconCenter.y - _headIconCenter.height;
			}
			if (_topIcon && topIdName && !_topIcon.parent) {
				addChild(_topIcon);
			}
			if (_topImage && !_topImage.parent) {
				addChild(_topImage);
			}
			updateEffectPos();
		}
		
		public function updateEffectPos():void
		{
			var offsetY:int;
			if (_topIcon) {
				_topIcon.y = _topIndexY;
			}
			if (_topImage) {
				if (_topIcon) {
					_topImage.y = _topIndexY - _topIcon.height;
				} else {
					_topImage.y = _topIndexY;
				}
			}
			if (_wordShape_ && _wordShape_.parent) {
				if (_topImage) {
					offsetY = _topImage.y;
				} else {
					if (_topIcon) {
						offsetY = _topIcon.y;
					} else {
						offsetY = _topIndexY;
					}
				}
				_wordShape_.y = -_wordShape_.height + offsetY;
				_wordShape_.x = -_wordShape_.width / 2;
			}
		}
		
		public function recover():void
		{
			if (this.bmd) {
				this.bmd.dispose();
			}
			this.graphics.clear();
			while (_sprite_.numChildren) {
				_sprite_.removeChildAt(0);
			}
			if (_flag && _flag.parent) {
				_flag.parent.removeChild(_flag);
			}
			if (_headIconLeft && _headIconLeft.parent) {
				_headIconLeft.parent.removeChild(_headIconLeft);
			}
			if (_headIconRight && _headIconRight.parent) {
				_headIconRight.parent.removeChild(_headIconRight);
			}
			if (_headIconCenter && _headIconCenter.parent) {
				_headIconCenter.parent.removeChild(_headIconCenter);
			}
			if (_topIcon && _topIcon.parent) {
				_topIcon.parent.removeChild(_topIcon);
			}
			_bloodKitVisible_ = false;
			_currBlood_ = 0;
			_maxBlood_ = 0;
			_name_ = "";
			_nameVisible_ = false;
			_nameColor_ = 0xFFFFFF;
			_professionName_ = "";
			_professionNameColor_ = 0xFFFFFF;
			_professionNameVisible_ = false;
			_nameVisible_ = false;
			if (_tile) {
				if (_tile.parent) {
					_tile.parent.removeChild(_tile);
				}
				_tile.dispose();
				_tile = null;
			}
			if (_wordShape_) {
				if (_wordShape_.parent) {
					_wordShape_.parent.removeChild(_wordShape_);
				}
				_wordShape_.dispose();
				_wordShape_ = null;
			}
		}
		
		override public function resetForDisposed():void{
			this.graphics.clear();
			_headIconSize = 30;
			_disposed_ = false;
			_nameColor_ = 0;
			_professionNameColor_ = 0;
			_unionColor_ = 0;
			_professionNameVisible_ = false;
			_nameVisible_ = false;
			_unionNameVisible_ = false;
			_bloodKitVisible_ = false;
			_owner_ = null;
			_currBlood_ = 0;
			_maxBlood_ = 0;
			bmd = null;
			_neiKitVisible_ = false;
			_currNei_ = 0;
			_maxNei_ = 0;
			_topIndexY = 0;
			_isDisposed = false;
			_heidTitle = false;
			_isCharNameBitmapMode = false;
			if (_tile) {
				if (_tile.parent) {
					_tile.parent.removeChild(_tile);
				}
				_tile.dispose();
			}
			_tile = null;
			super.resetForDisposed();
			init();
		}
		
		override public function dispose():void
		{
			HeartbeatFactory.getInstance().removeFrameOrder(onEnterFrameFunc);
			graphics.clear();
			char_id = null;
			_disposed_ = true;
			_headIconSize = 0;
			_isDisposed = true;
			_name_ = null;
			_unionName_ = null;
			_professionName_ = null;
			_nameColor_ = 0;
			_professionNameColor_ = 0;
			_unionColor_ = 0;
			_professionNameVisible_ = false;
			_nameVisible_ = false;
			_unionNameVisible_ = false;
			_bloodKitVisible_ = false;
			_owner_ = null;
			_currBlood_ = 0;
			_maxBlood_ = 0;
			bmd = null;
			x = 0;
			y = 0;
			this.oid = null;
			_neiKitVisible_ = false;
			_currNei_ = 0;
			_maxNei_ = 0;
			_topIndexY = 0;
			if (_headIconLeft) {
				if (_headIconLeft.parent) {
					_headIconLeft.parent.removeChild(_headIconLeft);
				}
				_headIconLeft = null;
			}
			if (_headIconRight) {
				if (_headIconRight.parent) {
					_headIconRight.parent.removeChild(_headIconRight);
				}
				_headIconRight = null;
			}
			if (_headIconCenter) {
				if (_headIconCenter.parent) {
					_headIconCenter.parent.removeChild(_headIconCenter);
				}
				_headIconCenter = null;
			}
			if (_flag) {
				if (_flag.parent) {
					_flag.parent.removeChild(_flag);
				}
				_flag = null;
			}
			_headBitmapData = null;
			if (_topIcon) {
				if (_topIcon.parent) {
					_topIcon.parent.removeChild(_topIcon);
				}
				_topIcon.dispose();
				_topIcon = null;
			}
			if (_topImage) {
				if (_topImage.parent) {
					_topIcon.parent.removeChild(_topImage);
				}
				_topImage.dispose();
				_topImage = null;
			}
			if (_tile) {
				if (_tile.parent) {
					_tile.parent.removeChild(_tile);
				}
				_tile.dispose();
				_tile = null;
			}
			if (_wordShape_) {
				if (_wordShape_.parent) {
					_wordShape_.parent.removeChild(_wordShape_);
				}
				_wordShape_.dispose();
				_wordShape_ = null;
			}
			if (this.parent) {
				this.parent.removeChild(this);
			}
			super.dispose();
			if (charHeadQueue.length < Asswc.POOL_INDEX) {
				charHeadQueue.push(this);
			}
		}
		
		public function get isSaying():Boolean
		{
			if (_wordShape_ && _wordShape_.parent) {
				return true;
			}
			return false;
		}

	}
} 
