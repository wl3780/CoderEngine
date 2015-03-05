package com.coder.core.displays.avatar
{
	import com.coder.core.controls.wealth.WealthStoragePort;
	import com.coder.core.displays.items.unit.DisplayLoader;
	import com.coder.core.displays.world.char.Char;
	import com.coder.core.protos.Proto;
	import com.coder.engine.Asswc;
	import com.coder.global.EngineGlobal;
	import com.coder.interfaces.display.IAvatar;
	import com.coder.utils.Hash;
	
	import flash.display.BitmapData;
	import flash.utils.Dictionary;
	import flash.utils.getTimer;

	public class AvatarActionData extends Proto
	{
		private static var _instanceHash_:Hash = new Hash();
		private static var _recoverQueue_:Vector.<AvatarActionData> = new Vector.<AvatarActionData>();
		private static var _recoverIndex_:int = 50;

		public var charType:String;
		public var layer:String;
		public var replay:int;
		public var offsetX:int;
		public var offsetY:int;
		public var playIntervalTimes:Vector.<int>;
		public var skillFrame:int;
		public var hitFrame:int;
		public var passTime:int;
		public var random:int = 0;
		public var reflex:String;
		public var recordDataFormat:String;
		public var playEndAndStopFrame:int = -1;
		
		protected var _path_:String;
		protected var _type_:String;
		protected var _idName_:String;
		protected var _isReady_:Boolean;
		protected var _overTime_:uint;
		protected var _totalFrames_:uint;
		protected var _offsetSpeed_:uint;
		protected var _isDisposed_:Boolean = false;
		
		protected var _stopFrame_:int = -1;
		protected var _currFrame_:uint;
		protected var _currDir_:uint;
		protected var _depth_:uint;
		
		protected var _currAction_:String = "stand";
		protected var _currInterval_:int;
		
		private var _avatarDataFormatGroup_id_:String;
		private var _startTime_:uint;
		
		private var _dataFormatGroup_:AvatarDataFormatGroup;
		private var _dataFormat_:AvatarDataFormat;
		private var recordDir:int;

		public static function checkNeedLoad(reflex:String, type:String, idName:String, act:String, dir:int):Boolean
		{
			var url:String = EngineGlobal.AVATAR_ASSETS_DIR + reflex + "/" + idName + Asswc.LINE + act + Asswc.LINE + dir + EngineGlobal.TMP_EXTENSION;
			var loader:DisplayLoader = WealthStoragePort.takeLoaderByWealth(url) as DisplayLoader;
			if (!loader) {
				return true;
			}
			return false;
		}
		
		public static function getInstanceHash():Hash
		{
			return AvatarActionData._instanceHash_;
		}
		
		public static function takeAvatarData(id:String):AvatarActionData
		{
			return AvatarActionData._instanceHash_.take(id) as AvatarActionData;
		}
		
		public static function createAvatarActionData():AvatarActionData
		{
			var result:AvatarActionData = null;
			if (_recoverQueue_.length) {
				result = _recoverQueue_.pop();
				result.reset();
				result._id_ = Asswc.getSoleId();
				AvatarActionData._instanceHash_.put(result.id, result);
			} else {
				result = new AvatarActionData();
			}
			return result;
		}
		
		public static function clean():void
		{
			var avatar:AvatarUnit = null;
			var hash:Hash = AvatarActionData.getInstanceHash();
			for each (var data:AvatarActionData in hash) {
				avatar = AvatarUnit.takeAvatarUnit(data.oid);
				if (!avatar) {
					hash.remove(data.id);
					data.dispose();
				}
			}
		}
		
		public static function removeAvatarActionData(id:String):AvatarActionData
		{
			var toDelete:AvatarActionData = AvatarActionData._instanceHash_.remove(id) as AvatarActionData;
			if (toDelete) {
				toDelete.dispose();
			}
			return toDelete;
		}
		
		public function AvatarActionData()
		{
			super();
			AvatarActionData._instanceHash_.put(this.id, this);
		}

		public function set offsetSpeed(value:uint):void
		{
			_offsetSpeed_ = value;
		}
		
		public function getDataFromat(act:String):AvatarDataFormat
		{
			var result:AvatarDataFormat = null;
			if (_dataFormatGroup_ && _dataFormatGroup_.isLoaded) {
				result = _dataFormatGroup_.takeAction(act);
				replay = result.replay;
			}
			return result;
		}
		
		public function set avatarDataFormatGroup_id(value:String):void
		{
			_avatarDataFormatGroup_id_ = value;
			_dataFormatGroup_ = AvatarDataFormatGroup.takeAvatarDataFormatGroup(value);
		}
		
		public function getBitmapData(dir:uint, frame:uint):BitmapData
		{
			if (_isDisposed_) {
				return null;
			}
			if (_dataFormat_) {
				return null;
			}
			
			if (_dataFormat_.totalDir == 1) {
				dir = 0;
			}
			if (dir < _dataFormat_.totalDir) {
				if (frame >= _dataFormat_.bitmapdatas[dir].length) {
					frame = _dataFormat_.bitmapdatas[dir].length - 1;
				}
				
				var link:String = _dataFormat_.bitmapdatas[dir][frame];
				var dic:Dictionary = AvatarRequestElisor.getBitmapDataHash(_dataFormat_.idName + "_" + _dataFormat_.actionName, link);
				var tmpData:BitmapData = null;
				if (dic) {
					tmpData = dic[link] as BitmapData;
					if (!tmpData) {
						if (reflex == null){
							reflex = EngineGlobal.TYPE_REFLEX[_type_];
						}
						if (checkNeedLoad(reflex, _type_, _idName_, _currAction_, _currDir_)) {
							var actName:String = _dataFormat_.actionName;
							if (actName == "attack_warm" || actName == "skill_warm") {
								actName = "attack";
							}
							loadActSWF(actName, dir);
						}
					}
				} else {
					if (reflex == null) {
						reflex = EngineGlobal.TYPE_REFLEX[_type_];
					}
					if (!checkNeedLoad(reflex, _type_, _idName_, _currAction_, _currDir_)) {
						loadActSWF(_dataFormat_.actionName, dir);
					}
				}
				return tmpData;
			}
			return null;
		}
		
		public function getBitmapDataOffsetX(dir:uint, frame:uint):int
		{
			if (_isDisposed_) {
				return 0;
			}
			if (_dataFormat_) {
				if (_dataFormat_.totalDir == 1) {
					dir = 0;
				}
				if (_dataFormat_.txs[dir] && frame < _dataFormat_.txs[dir].length) {
					return _dataFormat_.txs[dir][frame] - _dataFormat_.dirOffsetX[dir] + offsetX;
				}
			}
			return 0;
		}
		
		public function getBitmapDataOffsetY(dir:uint, frame:uint):int
		{
			if (_isDisposed_) {
				return 0;
			}
			if (_dataFormat_) {
				if (_dataFormat_.totalDir == 1) {
					dir = 0;
				}
				if (_dataFormat_.tys[dir] && frame < _dataFormat_.tys[dir].length) {
					return _dataFormat_.tys[dir][frame] - _dataFormat_.dirOffsetY[dir] + offsetY;
				}
			}
			return 0;
		}
		
		public function updateTotalFrame():void
		{
			if (_dataFormat_) {
				_totalFrames_ = _dataFormat_.totalFrames;
			}
		}
		
		internal function onSetupReady():void
		{
			if (_isDisposed_) {
				return;
			}
			_isReady_ = true;
			_startTime_ = getTimer();
			_dataFormat_ = _dataFormatGroup_.takeAction(_currAction_);
			if (_dataFormat_) {
				if (this.replay == 0) {
					this.replay = _dataFormat_.replay;
				}
				this.skillFrame = _dataFormat_.skillFrame;
				this.hitFrame = _dataFormat_.skillFrame;
				_totalFrames_ = _dataFormat_.totalFrames;
				var avatar:AvatarUnit = AvatarUnit.takeAvatarUnit(this.oid);
				if (avatar) {
					var dir:int = avatar.dir;
					if (_dataFormat_.totalDir == 1) {
						dir = 0;
					}
					if (_dataFormat_.idName.indexOf("eid") != -1) {
						AvatarRequestElisor.getInstance().loadAvatarSWF(_dataFormat_.id, idName, "stand", dir);
					} else {
						if (avatar.priorLoadQueue) {
							var queue:Vector.<String> = avatar.priorLoadQueue.slice();
							var act:String = avatar.act;
							if (act.indexOf("attack_warm") != -1) {
								act = "attack";
							}
							queue.push(act);
							
							var char:IAvatar = AvatarUnitDisplay.takeUnitDisplay(avatar.oid);
							var partIndex:int;
							var actIndex:int;
							if (char as Char && Char(char).type == "hero") {
								partIndex = 0;
								while (partIndex < 8) {
									while (actIndex < queue.length) {
										_dataFormat_ = _dataFormatGroup_.takeAction(queue[actIndex]);
										if (_dataFormat_) {
											replay = _dataFormat_.replay;
											AvatarRequestElisor.getInstance().loadAvatarSWF(_dataFormat_.id, idName, queue[actIndex], partIndex);
										}
										actIndex++;
									}
									partIndex++;
								}
							} else {
								while (actIndex < queue.length) {
									_dataFormat_ = _dataFormatGroup_.takeAction(queue[actIndex]);
									if (_dataFormat_) {
										replay = _dataFormat_.replay;
										AvatarRequestElisor.getInstance().loadAvatarSWF(_dataFormat_.id, idName, queue[actIndex], dir);
									}
									actIndex++;
								}
							}
						}
					}
				}
			}
		}
		
		internal function onRenderEnd():void
		{
		}
		
		public function play(act:String, dir:int=-1, frame:int=-1):void
		{
			if (_isDisposed_) {
				return;
			}
			AvatarRequestElisor.getInstance().loadAvatarSWF(_dataFormat_.id, this.idName, act, _currDir_);
		}
		
		public function get currDataFormat():AvatarDataFormat
		{
			if (_isDisposed_) {
				return null;
			}
			return _dataFormat_;
		}
		
		public function set currFrame(value:uint):void
		{
			if (_isDisposed_) {
				return;
			}
			if (value != _currFrame_) {
				_currFrame_ = value;
				if (_dataFormat_ && _currFrame_ < _dataFormat_.intervalTimes.length) {
					_currInterval_ = _dataFormat_.intervalTimes[_currFrame_];
				}
			}
		}
		
		public function get totalDir():int
		{
			if (_isDisposed_) {
				return 1;
			}
			if (_dataFormat_) {
				return _dataFormat_.totalDir;
			}
			return 1;
		}
		
		public function set currDir(value:uint):void
		{
			if (_isDisposed_) {
				return;
			}
			if (value != _currDir_) {
				_currDir_ = value;
			}
		}
		
		public function set currAct(value:String):void
		{
			if (_isDisposed_) {
				return;
			}
			if (_dataFormatGroup_ && _dataFormatGroup_.isLoaded) {
				_dataFormat_ = _dataFormatGroup_.takeAction(value);
				if (_dataFormat_) {
					this.skillFrame = _dataFormat_.skillFrame;
					this.hitFrame = _dataFormat_.skillFrame;
					replay = _dataFormat_.replay;
				}
				this.updateTotalFrame();
			}
			recordDir = _currDir_;
			_currAction_ = value;
		}
		
		public function setCurrActButDoNotLoadAvatarSWF(value:String):void
		{
			if (_isDisposed_) {
				return;
			}
			if (_currAction_ != value) {
				if (_dataFormatGroup_ && _dataFormatGroup_.isLoaded) {
					_dataFormat_ = _dataFormatGroup_.takeAction(value);
					if (_dataFormat_) {
						this.skillFrame = _dataFormat_.skillFrame;
						this.hitFrame = _dataFormat_.skillFrame;
						_totalFrames_ = _dataFormat_.totalFrames;
					}
				}
				recordDir = _currDir_;
				_currAction_ = value;
			}
		}
		
		public function loadActSWF(act:String, dir:int):void
		{
			if (_isDisposed_) {
				return;
			}
			if (_dataFormatGroup_ && _dataFormatGroup_.isLoaded && act) {
				_dataFormat_ = _dataFormatGroup_.takeAction(act);
				if (_dataFormat_) {
					this.skillFrame = _dataFormat_.skillFrame;
					this.hitFrame = _dataFormat_.skillFrame;
					if (act == "attack_warm") {
						act = "attack";
					}
					AvatarRequestElisor.getInstance().loadAvatarSWF(_dataFormat_.id, idName, act, dir);
				}
			}
		}
		
		public function set depth(value:int):void
		{
			_depth_ = value;
		}
		public function get depth():int
		{
			return (_depth_);
		}
		
		public function set stopFrame(value:int):void
		{
			_stopFrame_ = value;
		}
		public function get stopFrame():int
		{
			return _stopFrame_;
		}
		
		public function get offsetSpeed():uint
		{
			return _offsetSpeed_;
		}
		public function get avatarDataFormatGroup_id():String
		{
			return _avatarDataFormatGroup_id_;
		}
		
		public function get currFrame():uint
		{
			return _currFrame_;
		}
		
		public function get currDir():uint
		{
			return _currDir_;
		}
		
		public function get currAct():String
		{
			return _currAction_;
		}
		
		public function get currInterval():int
		{
			if (_dataFormat_) {
				var frame:int = _currFrame_ - 1;
				if (frame <= -1) {
					return 0;
				}
				if (frame >= _dataFormat_.intervalTimes.length) {
					frame = _dataFormat_.intervalTimes.length - 1;
				}
				_currInterval_ = _dataFormat_.intervalTimes[frame];
			}
			return _currInterval_;
		}
		
		public function get path():String
		{
			return _path_;
		}
		
		public function get isDisposed():Boolean
		{
			return _isDisposed_;
		}
		
		public function get type():String
		{
			return _type_;
		}
		
		public function get idName():String
		{
			return _idName_;
		}
		
		public function get isReady():Boolean
		{
			return _isReady_;
		}
		
		public function get overTime():int
		{
			return _overTime_;
		}
		
		public function get totalFrames():uint
		{
			return _totalFrames_;
		}
		
		public function get startTime():uint
		{
			return _startTime_;
		}
		
		public function set path(value:String):void
		{
			_path_ = value;
		}
		
		public function set isDisposed(value:Boolean):void
		{
			_isDisposed_ = value;
		}
		
		public function set type(value:String):void
		{
			_type_ = value;
		}
		
		public function set idName(value:String):void
		{
			_idName_ = value;
		}
		
		public function set isReady(value:Boolean):void
		{
			_isReady_ = value;
		}
		
		public function set overTime(value:int):void
		{
			_overTime_ = value;
		}
		
		public function set totalFrames(value:uint):void
		{
			_totalFrames_ = value;
		}
		
		public function set startTime(value:uint):void
		{
			_startTime_ = value;
		}
		
		override public function clone():Object
		{
			var result:AvatarActionData = AvatarActionData.createAvatarActionData();
			return result;
		}
		
		public function reset():void
		{
			_isDisposed_ = false;
		}
		
		public function recover():void
		{
			if (_isDisposed_) {
				return;
			}
			this.dispose();
			this.reset();
			if (_recoverQueue_.length <= _recoverIndex_) {
				_recoverQueue_.push(this);
			}
		}
		
		override public function dispose():void
		{
			playEndAndStopFrame = -1;
			AvatarActionData._instanceHash_.remove(this.id);
			if (_dataFormat_) {
				_dataFormat_ = null;
			}
			if (_dataFormatGroup_) {
				var index:int = _dataFormatGroup_.quoteQueue.indexOf(this.id);
				if (index != -1) {
					_dataFormatGroup_.quoteQueue.splice(index, 1);
				}
				_dataFormatGroup_ = null;
			}
			charType = null;
			_path_ = null;
			_type_ = null;
			_idName_ = null;
			_isReady_ = false;
			_overTime_ = 0;
			_totalFrames_ = 0;
			_offsetSpeed_ = 0;
			layer = null;
			_stopFrame_ = -1;
			_currFrame_ = 0;
			_currDir_ = 0;
			_depth_ = 0;
			replay = 0;
			_avatarDataFormatGroup_id_ = null;
			_startTime_ = 0;
			_currAction_ = "stand";
			_currInterval_ = 0;
			offsetX = 0;
			offsetY = 0;
			playIntervalTimes = null;
			skillFrame = 0;
			hitFrame = 0;
			_dataFormatGroup_ = null;
			_dataFormat_ = null;
			passTime = 0;
			random = 0;
			reflex = null;
			_isDisposed_ = true;
			super.dispose();
		}

	}
} 
