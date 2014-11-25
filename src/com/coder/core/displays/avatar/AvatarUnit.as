package com.coder.core.displays.avatar
{
	import com.coder.core.displays.world.Scene;
	import com.coder.core.displays.world.char.Char;
	import com.coder.core.displays.world.char.MainChar;
	import com.coder.core.protos.Proto;
	import com.coder.engine.Asswc;
	import com.coder.global.EngineGlobal;
	import com.coder.interfaces.display.IAvatar;
	import com.coder.utils.FPSUtils;
	import com.coder.utils.Hash;
	import com.coder.utils.log.Log;
	
	import flash.system.Capabilities;
	import flash.utils.clearTimeout;
	import flash.utils.getTimer;

	public class AvatarUnit extends Proto
	{
		public static var DEATH_STOP_FRAME:int = 3;
		public static var NORMAL_RENDER:int = 0;
		public static var UN_PLAY_NEXT_RENDER:int = 1;
		public static var PLAY_NEXT_RENDER:int = 2;
		
		public static var mainTypeHash:Vector.<String> = new Vector.<String>(4);
		public static var loopActions:Vector.<String> = new Vector.<String>(5);
		public static var unitType:Vector.<String> = new Vector.<String>(9);
		
		private static var _instanceHash_:Hash = new Hash();
		private static var _recoverQueue_:Vector.<AvatarUnit> = new Vector.<AvatarUnit>();
		private static var _recoverIndex_:int = 50;
		private static var _effectIndex_:int;

		public var isCharMode:Boolean = false;
		public var priorLoadQueue:Vector.<String>;
		public var isDisposed:Boolean;
		
		public var sex:int = 0;
		public var charType:String;
		public var ownerType:String;
		public var mainActionData:AvatarActionData;
		public var stopPlay:Boolean;
		public var isMain:Boolean;
		public var renderTime:int;
		public var renderDurTime:int;
		public var renderindex:int;
		public var bodyPartsHash:Hash;
		public var effectHash:Hash;
		
		protected var _skillFrameFunc_:Function;
		protected var _hitFrameFunc_:Function;
		protected var _actNow_:String;
		protected var _actNext_:String;
		protected var _actPrve_:String;
		protected var _currFrame_:int;
		protected var _totalFrames_:int;
		protected var _interval_:int;
		protected var _dir_:int;
		protected var _ratio_:Number;
		protected var _actMode_:String;
		protected var _isDisposed_:Boolean;
		
		private var _bodyOverTime_:int;
		private var _effectOverTime_:int;
		private var act_replay:int;
		private var _mainType:String;
		private var _lockDir:int = -1;
		private var setTimeOutIndex:int;
		private var index:int;
		private var index2:int;
		private var frameCounter:int;
		private var actionDataArray:Vector.<AvatarActionData>;

		public function AvatarUnit()
		{
			priorLoadQueue = new <String>["stand"];
			bodyPartsHash = new Hash();
			effectHash = new Hash();
			actionDataArray = new Vector.<AvatarActionData>();
			super();
			renderTime = getTimer() + (Math.random() * 0 >> 0);
			renderindex = (Math.random() * AvatarRenderElisor.readnerNum) >> 0;
			renderDurTime = (Math.random() * 25) >> 0;
			AvatarUnit._instanceHash_.put(this.id, this);
		}
		
		protected static function get effectIndex():String
		{
			_effectIndex_ = _effectIndex_ + 1;
			return _effectIndex_ + "";
		}
		
		public static function removeUnit(id:String):void
		{
			_instanceHash_.remove(id);
		}
		
		public static function takeAvatarUnit(id:String):AvatarUnit
		{
			return AvatarUnit._instanceHash_.take(id) as AvatarUnit;
		}
		
		public static function createAvatarUnit():AvatarUnit
		{
			var result:AvatarUnit = null;
			if (_recoverQueue_.length) {
				result = _recoverQueue_.pop();
				result._id_ = Asswc.getSoleId();
				AvatarUnit._instanceHash_.put(result.id, result);
			} else {
				result = new AvatarUnit();
			}
			return result;
		}

		public function init():void
		{
			_actPrve_ = "stand";
			_actNext_ = "stand";
			_actNow_ = "stand";
			_dir_ = 0;
			_currFrame_ = 0;
			this.play(_actNow_);
		}
		
		public function loadActSWF():void
		{
			if (mainActionData && mainActionData.isReady && !this.stopPlay) {
				var curAct:String = _actNow_;
				if (curAct == "attack_warm") {
					curAct = "attack";
				}
				for each (var item:AvatarActionData in bodyPartsHash) {
					if (item) {
						item.loadActSWF(curAct, dir);
					}
				}
			}
		}
		
		public function get act_replayIndex():int
		{
			return this.act_replay;
		}
		
		protected function set totalFrames(value:int):void
		{
			mainActionData.updateTotalFrame();
			_totalFrames_ = mainActionData.totalFrames;
		}
		protected function get totalFrames():int
		{
			return _totalFrames_;
		}
		
		public function get currFrame():int
		{
			return _currFrame_;
		}
		public function set currFrame(value:int):void
		{
			_currFrame_ = value;
		}
		
		public function onBodyRender(renderType:int=0):void
		{
			var _local22 = null;
			var _local18:int;
			var _local17:int;
			var _local13:int;
			var _local5:int;
			var _local19:int;
			var _local4:int;
			var _local21 = null;
			var _local20:Boolean;
			var _local14 = null;
			var _local9 = null;
			var _local24 = null;
			var _local8 = null;
			var _local12:int;
			var _local16:int;
			var _local23 = null;
			var _local15 = null;
			var _local11:int;
			var _local10:int;
			var _local2:int;
			var _local6 = null;
			var _local3 = null;
			var _local7 = null;
			if (_isDisposed_) {
				return;
			}
			if (((((((mainActionData) && (mainActionData.isReady))) && (!(this.stopPlay)))) || (((EngineGlobal.shadowAvatarGroup) && (mainActionData))))) {
				_local22 = AvatarUnitDisplay.takeUnitDisplay(this.oid);
				if (((_local22) && ((_local22.name == "showad")))) {
					return;
				}
				if (!_local22) {
					return;
				}
				_totalFrames_ = mainActionData.totalFrames;
				if (_currFrame_ >= _totalFrames_) {
					try {
						_local18 = mainActionData.getDataFromat(_actNow_).intervalTimes[(currFrame - 1)];
						if ((getTimer() - _bodyOverTime_) < _local18) {
							return;
						}
					} catch(e:Error) {
					}
					if (mainActionData.charType == "effect") {
						act_replay = mainActionData.replay;
					}
					if ((((act_replay > 0)) || ((act_replay == -1)))) {
						currFrame = 0;
						if (act_replay != -1) {
							act_replay = (act_replay - 1);
						}
					} else {
						if ((((_actNow_ == "death")) || (!((mainActionData.stopFrame == -1))))) {
							var _local27 = (totalFrames - 1);
							mainActionData.stopFrame = _local27;
							_currFrame_ = _local27;
						} else {
							_currFrame_ = ((mainActionData.stopFrame)!=-1) ? mainActionData.stopFrame : 0;
							if (isLoopAct(_actNow_)) {
								if (_actNext_ != _actNow_) {
									if (isLoopAct(_actNext_) == false) {
										_actPrve_ = _actNow_;
										this.play(_actNext_, PLAY_NEXT_RENDER);
										return;
									}
									_local22.playEnd(_actNow_);
									_actPrve_ = _actNow_;
									this.play(_actNext_, PLAY_NEXT_RENDER);
								}
							} else {
								if (mainActionData.charType == "effect") {
									return;
								}
								_actPrve_ = _actNow_;
								if (((!((_actNow_ == "attack"))) && (!((_actNow_ == "skill"))))) {
									_local22.playEnd(_actNow_);
								}
								if ((((_actNow_ == "attack")) || ((_actNow_ == "skill")))) {
									if (!isCharMode) {
										_local22.play("stand", PLAY_NEXT_RENDER);
										_actNext_ = "stand";
									} else {
										if (Capabilities.playerType != "Desktop") {
											_local22.play("attack_warm");
											_actNext_ = "attack_warm";
											setTimeOutIndex = getTimer();
										}
									}
								} else {
									this.play("stand", PLAY_NEXT_RENDER);
									_actNext_ = "stand";
								}
							}
						}
					}
				}
				if ((((((setTimeOutIndex > 0)) && (((getTimer() - setTimeOutIndex) > 5000)))) && ((((_actNow_ == "attack_warm")) || ((_actNow_ == "skill_warm")))))) {
					setTimeOutIndex = getTimer();
					this.play("stand");
				} else {
					if (((!((_actNow_ == "attack_warm"))) && (!((_actNow_ == "skill_warm"))))) {
						setTimeOutIndex = getTimer();
					}
				}
				if (mainActionData.currDir != _dir_) {
					mainActionData.currDir = _dir_;
				}
				if (_actNow_ != mainActionData.currAct) {
					mainActionData.setCurrActButDoNotLoadAvatarSWF(_actNow_);
				}
				mainActionData.currFrame = _currFrame_;
				if (isCharMode) {
					if (_actNow_ == "run") {
						_interval_ = ((428 / totalFrames) - 1);
					} else {
						if (_actNow_ == "walk") {
							_interval_ = ((560 / totalFrames) - 1);
						} else {
							_interval_ = mainActionData.currInterval;
						}
					}
				} else {
					_interval_ = mainActionData.currInterval;
				}
				_local17 = 0;
				if ((((renderDurTime > 0)) && ((_local22 == Scene.scene.mainChar)))) {
					renderDurTime = 0;
				}
				_local13 = Scene.scene.middleLayer.numChildren;
				_local5 = FPSUtils.fps;
				if ((_local22 as Char)) {
					if ((((_local22.type == "monster_normal")) || ((_local22.type == "0npc_normal")))) {
						if (_actNow_ == "stand") {
							_local17 = (((Math.random() * 200) >> 0) + 30);
							if (_local13 > 50) {
								_local17 = (_local17 + 100);
							}
							if ((((_local13 > 50)) && ((_local5 < 10)))) {
								_local17 = (_local17 + 1000);
							}
						} else {
							if (_local13 > 50) {
								_local17 = (_local17 + 50);
							}
						}
					} else {
						if (_local22.type == "char") {
							if (_actNow_ == "stand") {
								_local17 = (((Math.random() * 200) >> 0) + 30);
								if (_local13 > 50) {
									_local17 = (_local17 + 100);
								}
								if ((((_local13 > 50)) && ((_local5 < 10)))) {
									_local17 = (_local17 + (300 + ((Math.random() * 200) >> 0)));
								}
							} else {
								if (_local13 > 50) {
									_local17 = (_local17 + 15);
								}
							}
						}
					}
				}
				if (_local22 == Scene.scene.mainChar) {
					_local19 = (_interval_ + mainActionData.random);
				} else {
					_local19 = ((_interval_ + mainActionData.random) + _local17);
				}
				_local4 = (getTimer() - _bodyOverTime_);
				if (((((_local4 - _local19) >= -1)) || (((renderType) && ((_currFrame_ < totalFrames)))))) {
					_local20 = true;
					for each (_local21 in bodyPartsHash) {
						if (_local21) {
							_local21.currFrame = _currFrame_;
							_local21.currDir = _dir_;
							_local21.currAct = _actNow_;
							if (((((((_local20) && ((_local22 as Char)))) && ((_local22 as Char).isCharMode))) && (!(((_local22 as Char).shadow_id == null))))) {
								_local20 = false;
								_local14 = (AvatarUnitDisplay._instanceHash_.take((_local22 as Char).shadow_id) as AvatarUnitDisplay);
								if ((_local22 as Char).sex == 1) {
									_local9 = EngineGlobal.avatarDataMale;
									_local24 = EngineGlobal.shadowAvatarGroupMale;
								} else {
									_local9 = EngineGlobal.avatarDataFamale;
									_local24 = EngineGlobal.shadowAvatarGroupFamale;
								}
								if (((((_local24) && (_local24.isLoaded))) && (_local9))) {
									_local9.currDir = _dir_;
									_local9.currFrame = _currFrame_;
									_local9.currAct = _actNow_;
									_local8 = _local9.getBitmapData(_dir_, _currFrame_);
									_local12 = _local9.getBitmapDataOffsetX(_dir_, _currFrame_);
									_local16 = _local9.getBitmapDataOffsetY(_dir_, _currFrame_);
									_local23 = _local9.type;
									if (unitType.indexOf(_local14.unit.charType) == -1) {
										if (_local14.visible) {
											_local14.onBodyRender("body_effect", _local7, _local8, _local12, _local16);
										}
									} else {
										_local14.onBodyRender("body_type", _local7, _local8, _local12, _local16);
									}
								}
							}
							_local15 = _local21.getBitmapData(_dir_, _currFrame_);
							_local11 = _local21.getBitmapDataOffsetX(_dir_, _currFrame_);
							_local10 = _local21.getBitmapDataOffsetY(_dir_, _currFrame_);
							if (((((((isCharMode) && ((_local22 as Char)))) && (!(_local15)))) && ((_local21.type == "mid")))) {
								_local2 = (_local22 as Char).sex;
								if (_local2 == 1) {
									_local6 = EngineGlobal.avatarDataBaseMale;
									_local3 = EngineGlobal.shadowAvatarGroupBaseMale;
								} else {
									_local6 = EngineGlobal.avatarDataBaseMale;
									_local3 = EngineGlobal.shadowAvatarGroupBaseMale;
								}
								if (_local6) {
									_local6.currDir = _dir_;
									_local6.currFrame = _currFrame_;
									_local6.currAct = _actNow_;
									_local15 = _local6.getBitmapData(_dir_, _currFrame_);
									_local11 = _local6.getBitmapDataOffsetX(_dir_, _currFrame_);
									_local10 = _local21.getBitmapDataOffsetY(_dir_, _currFrame_);
								}
							}
							_local7 = _local21.type;
							if (unitType.indexOf(this.charType) == -1) {
								if (((_local22) && (_local22.visible))) {
									_local22.onBodyRender("body_effect", _local7, _local15, _local11, _local10);
								}
							} else {
								if (_local22) {
									_local22.onBodyRender("body_type", _local7, _local15, _local11, _local10);
								}
							}
						}
					}
					if (((((_local4 - _local19) >= 0)) || ((renderType == PLAY_NEXT_RENDER)))) {
						if (((((!((_skillFrameHandler_ == null))) && ((_currFrame_ == mainActionData.skillFrame)))) && ((((_actNow_ == "attack")) || ((_actNow_ == "skill")))))) {
							_skillFrameHandler_(_actNow_, _currFrame_);
						}
						if (((!((_hitFrameHandler_ == null))) && ((_currFrame_ == mainActionData.hitFrame)))) {
							_hitFrameHandler_(_actNow_, _currFrame_);
						}
						if (_actNow_ != "attack_warm") {
							_currFrame_ = (_currFrame_ + 1);
						}
						_bodyOverTime_ = getTimer();
					}
				}
			}
		}
		
		public function effectPlay(key:String, act:String, frame:int=-1):void
		{
			var param:Object = effectHash.take(key);
			if (param) {
				var actionId:String = param.actionData_id;
				var actionData:AvatarActionData = AvatarActionData.takeAvatarData(actionId);
				if (act != actionData.currAct) {
					actionData.currAct = act;
					if (frame != -1) {
						actionData.currFrame = frame;
					}
				}
			}
		}
		
		public function onEffectRender():void
		{
			var _local6:int;
			var _local11 = null;
			var _local5 = null;
			var _local16:int;
			var _local4 = null;
			var _local17 = null;
			var _local8:Boolean;
			var _local19 = null;
			var _local7 = null;
			var _local20:Boolean;
			var _local2:Boolean;
			var _local15:int;
			var _local1:int;
			var _local13 = null;
			var _local10:int;
			var _local9:int;
			var _local12 = null;
			var _local14 = null;
			if (_isDisposed_ || oid == null) {
				return;
			}
			effectHash.length;
			var _local18:IAvatar = AvatarUnitDisplay.takeUnitDisplay(this.oid);
			for each (var _local3:Object in effectHash) {
				_local11 = _local3.key;
				_local5 = _local3.actionData_id;
				_local16 = 0;
				_local4 = _local3.layer;
				_local17 = AvatarActionData.takeAvatarData(_local5);
				_local8 = false;
				_local19 = _local17.currDataFormat;
				if (_local19) {
					if (_local19.totalDir > 1) {
						_local16 = _dir_;
					}
					_local7 = _local17.type;
					_local20 = true;
					if (_local19.id != _local17.recordDataFormat) {
						_local8 = true;
					}
					_local17.recordDataFormat = _local19.id;
					if ((((_local17.replay == 0)) || (_local8))) {
						_local17.replay = _local19.replay;
					}
					if ((((FPSUtils.fps < 5)) && (!((_local17.replay == -1))))) {
						_local17.currFrame = _local17.totalFrames;
					}
					if (((!((_local17.stopFrame == -1))) && ((_local17.stopFrame >= _local17.totalFrames)))) {
						_local17.stopFrame = (_local17.totalFrames - 1);
					}
					if (_local17.playEndAndStopFrame != -1) {
						if (_local17.playEndAndStopFrame >= _local17.totalFrames) {
							_local17.playEndAndStopFrame = (_local17.totalFrames - 1);
						}
						if (_local17.playEndAndStopFrame < -1) {
							_local17.playEndAndStopFrame = 0;
						}
					}
					var _local21;
					if ((((((_local17.currFrame >= _local17.totalFrames)) || (((!((_local17.stopFrame == -1))) && ((_local17.currFrame >= _local17.stopFrame)))))) || ((((_local17.currFrame >= _local17.totalFrames)) && (!((_local17.playEndAndStopFrame == -1))))))) {
						_local2 = ((!((_local17.stopFrame == -1))) && ((_local17.currFrame >= _local17.stopFrame)));
						if (_local17.replay == -1) {
//							(_local2) ? _local21 = _local17.stopFrame;
//_local17.currFrame = _local21;
//_local21 : _local21 = 0;
//_local17.currFrame = _local21;
//_local21;
							if (((!(_local2)) && (!((_local17.playEndAndStopFrame == -1))))) {
								_local21 = _local17.playEndAndStopFrame;
								_local17.currFrame = _local21;
								_local17.stopFrame = _local21;
							}
							if (_local17.currAct != "stand") {
								_local17.currAct = "stand";
								_local17.replay = _local17.currDataFormat.replay;
							}
						} else {
//							(_local2) ? _local21 = _local17.stopFrame;
//_local17.currFrame = _local21;
//_local21 : _local21 = 0;
//_local17.currFrame = _local21;
//_local21;
							if (((!(_local2)) && (!((_local17.playEndAndStopFrame == -1))))) {
								if (_local18) {
									_local18.onEffectPlayEnd(_local11);
								}
								_local21 = _local17.playEndAndStopFrame;
								_local17.currFrame = _local21;
								_local17.stopFrame = _local21;
								_local2 = true;
								_local17.replay = 1;
							}
							if (!_local2) {
								if (_local17.currDataFormat.replay == 1) {
									try {
										_local15 = _local17.getDataFromat(_actNow_).intervalTimes[(_local17.currFrame - 1)];
										if ((getTimer() - _local17.passTime) < _local15) {
											return;
										}
									} catch(e:Error) {
										_local17.currFrame = _local17.totalFrames;
										_local15 = _local17.currDataFormat.intervalTimes[(_local17.currFrame - 1)];
										if ((getTimer() - _local17.passTime) < _local15) {
											return;
										}
									}
									_local20 = false;
									if (_local3.layer == "TOP_LAYER") {
										if (_local18) {
											_local18.onEffectRender(_local11, "body_top_effect", null, 0, 0);
										}
									} else {
										if (_local3.layer == "body_bottom_effect") {
											if (_local18) {
												_local18.onEffectRender(_local11, "body_bottom_effect", null, 0, 0);
											}
										} else {
											if (_local3.layer == "BOTTOM_LAYER") {
												if (_local18) {
													_local18.onEffectRender(_local11, "BOTTOM_LAYER", null, 0, 0);
												}
											} else {
												if (_local18) {
													_local18.onEffectRender(_local11, "body_effect", null, 0, 0);
												}
											}
										}
									}
									if (((!((_local17.currAct == "stand"))) || (_local8))) {
										_local17.currAct = "stand";
									} else {
										effectHash.remove(_local11);
										if (_local18) {
											_local18.onEffectPlayEnd(_local11);
										}
										if (((_local18) && (!((_local18 is AvatarUnitDisplay))))) {
											if ((_local18 as AvatarEffect).autoRecover) {
												_local18.recover();
											}
										}
									}
								} else {
									_local17.replay = (_local17.replay - 1);
									_local17.currFrame = 0;
								}
							}
						}
					}
					_local1 = (_local17.currInterval + _local17.random);
					if ((((_local18.type == "STATIC_STAGE_EFFECT")) && (Scene.scene.mainChar.isRuning))) {
						_local1 = (_local1 + (((Math.random() * 80) >> 0) + 50));
						if (Scene.scene.mainChar.isRuning) {
							_local1 = (_local1 + 120);
						}
					}
					if ((((((Scene.scene.numChildren > 100)) && ((FPSUtils.fps < 10)))) && ((isMain == false)))) {
						_local1 = (_local1 + ((Scene.scene.numChildren * 3) + 100));
					}
					if (((((getTimer() - _local17.passTime) > _local1)) && (_local20))) {
						_local17.passTime = getTimer();
						_local6 = _local17.currFrame;
						_local13 = _local17.getBitmapData(_local16, _local6);
						_local10 = _local17.getBitmapDataOffsetX(_local16, _local6);
						_local9 = _local17.getBitmapDataOffsetY(_local16, _local6);
						if (_local18) {
							if ((((_local3.layer == "body_top_effect")) || ((_local3.layer == "TOP_LAYER")))) {
								_local18.onEffectRender(_local11, "body_top_effect", _local13, _local10, _local9);
							} else {
								if (_local3.layer == "TOP_UP_LAYER") {
									_local18.onEffectRender(_local11, "TOP_UP_LAYER", _local13, _local10, _local9);
								} else {
									if (_local3.layer == "body_bottom_effect") {
										_local18.onEffectRender(_local11, "body_bottom_effect", _local13, _local10, _local9);
									} else {
										if (_local3.layer == "BOTTOM_LAYER") {
											if (_local18) {
												_local18.onEffectRender(_local11, "BOTTOM_LAYER", _local13, _local10, _local9);
											}
										} else {
											_local18.onEffectRender(_local11, "body_effect", _local13, _local10, _local9);
										}
									}
								}
							}
						}
						_local17.currFrame = (_local17.currFrame + 1);
					}
				} else {
					if (_local17.isReady) {
						if (_local17.currAct == "stand") {
							_local12 = AvatarUnitDisplay.takeUnitDisplay(this.oid);
							if (_local3.layer == "TOP_LAYER") {
								_local12.onEffectRender(_local11, "body_top_effect", null, 0, 0);
							} else {
								if (_local3.layer == "body_bottom_effect") {
									_local12.onEffectRender(_local11, "body_bottom_effect", null, 0, 0);
								} else {
									_local12.onEffectRender(_local11, "body_effect", null, 0, 0);
								}
							}
							_local14 = (_local12 as AvatarEffect);
							if (((_local14) && (_local14.parent))) {
								_local14.parent.removeChild(_local14);
							}
						}
					}
				}
			}
		}
		
		protected function _skillFrameHandler_(act:String, frame:int):void
		{
			AvatarUnitDisplay.takeUnitDisplay(this.oid).playEnd(_actNow_);
			if (_skillFrameFunc_ != null) {
				_skillFrameFunc_();
			}
		}
		
		protected function _hitFrameHandler_(act:String, frame:int):void
		{
			if (_hitFrameFunc_ != null) {
				_hitFrameFunc_();
			}
		}
		
		public function setEffectStopFrame(actionData_id:String, frame:int=-1):void
		{
			var actData:AvatarActionData = AvatarActionData.takeAvatarData(actionData_id);
			if (actData) {
				frame == -1 ? frame = 9999 : "";
				actData.stopFrame = frame;
			}
		}
		
		public function setEffectPlayEndAndStop(actionData_id:String, frame:int=-1):void
		{
			var actData:AvatarActionData = AvatarActionData.takeAvatarData(actionData_id);
			if (actData) {
				frame == -1 ? frame = 9999 : "";
				actData.playEndAndStopFrame = frame;
			}
			if (actData.stopFrame != -1) {
				actData.stopFrame = -1;
			}
		}
		
		public function loadEffect(idName:String, layer:String="TOP_LAYER", passKey:String=null, remove:Boolean=false, offsetX:int=0, offsetY:int=0, replay:int=-2, random:int=0, act:String="stand", type:String="eid"):String
		{
			if (this.isDisposed) {
				return null;
			}
			if ((!idName || idName == "0" || idName == "null") && passKey == null) {
				Log.error(this, "请求加载特效的 idName 不能为空 null 或者“0” ");
				return "";
			}
			if (!passKey || passKey == "null") {
				passKey = idName + Asswc.LINE + effectIndex;
			}
			var tmpName:String = type + Asswc.LINE + idName;
			var format:String = AvatarRequestElisor.getInstance().loadAvatarFormat(this.id, tmpName);
			var actData:AvatarActionData = AvatarActionData.takeAvatarData(format);
			actData.random = random;
			if (replay != -2) {
				actData.replay = replay;
			}
			actData.offsetX = offsetX;
			actData.offsetY = offsetY;
			actData.currAct = act;
			var param:Object = {
				actionData_id:format,
				key:passKey,
				layer:layer
			}
			if (remove) {
				var paramKey:String = param.key;
				var avatar:IAvatar = AvatarUnitDisplay.takeUnitDisplay(this.oid);
				if (param.layer == "TOP_LAYER") {
					avatar.onEffectRender(paramKey, "body_top_effect", null, 0, 0);
				} else {
					if (param.layer == "body_bottom_effect") {
						avatar.onEffectRender(paramKey, "body_bottom_effect", null, 0, 0);
					} else {
						avatar.onEffectRender(paramKey, "body_effect", null, 0, 0);
					}
				}
				if (avatar && !(avatar is AvatarUnitDisplay)) {
					if (avatar as AvatarEffect && (avatar as AvatarEffect).autoRecover) {
						avatar.recover();
					}
				}
				if (effectHash) {
					effectHash.remove(passKey);
				}
			} else {
				if (effectHash) {
					effectHash.put(passKey, param, remove);
				}
			}
			return format;
		}
		
		public function reloadEffectHash():void
		{
			var actData:AvatarActionData = null;
			for each (var item:Object in effectHash) {
				actData = AvatarActionData.takeAvatarData(item.actionData_id);
				if (actData) {
					actData.loadActSWF(_actNow_, 0);
				}
			}
		}
		
		public function removeEffect(idName:String, layer:String, passKey:String=null, type:String="eid"):void
		{
			var tmpKey:String = type + Asswc.LINE + idName + Asswc.LINE + passKey;
			if (passKey && passKey != "0") {
				tmpKey = passKey;
			}
			var tmpId:String = effectHash.remove(tmpKey) as String;
			var param:Object = {
				actionData_id:tmpId,
				key:tmpKey,
				layer:layer
			}
			var paramKey:String = param.key;
			if (param.layer == "TOP_LAYER") {
				AvatarUnitDisplay.takeUnitDisplay(this.oid).onEffectRender(paramKey, "body_top_effect", null, 0, 0);
			} else {
				if (param.layer == "body_bottom_effect") {
					AvatarUnitDisplay.takeUnitDisplay(this.oid).onEffectRender(paramKey, "body_bottom_effect", null, 0, 0);
				} else {
					AvatarUnitDisplay.takeUnitDisplay(this.oid).onEffectRender(paramKey, "body_effect", null, 0, 0);
				}
			}
		}
		
		public function loadAvatarParts(_type_:String, idName:String, offsetX:int=0, offsetY:int=0, random:int=0):void
		{
			if (!idName || idName == "0") {
				if (mainTypeHash.indexOf(_type_) != -1) {
					AvatarUnitDisplay.takeUnitDisplay(this.oid).onBodyRender("body_type", _type_, null, 0, 0);
				} else {
					AvatarUnitDisplay.takeUnitDisplay(this.oid).onBodyRender("body_effect", _type_, null, 0, 0);
				}
				bodyPartsHash.remove(_type_);
			} else {
				var tmpId:String = _type_ + Asswc.LINE + idName;
				var format:String = AvatarRequestElisor.getInstance().loadAvatarFormat(this.id, tmpId);
				var actData:AvatarActionData = AvatarActionData.takeAvatarData(format);
				actData.offsetX = offsetX;
				actData.offsetY = offsetY;
				var isOther:Boolean = _type_ != "wid" && _type_ != "wgid" && _type_ != "midm";
				if (isOther || mainType != null) {
					var tmpType:String = _type_ == "mid" ? "mid" : "eid";
					if ((!mainActionData && mainType == "wgid") || mainType == null || (mainActionData && mainType == tmpType)) {
						this.mainActionData = actData;
						if (mainType == null) {
							if (_type_ == "mid" || mainTypeHash.indexOf(_type_) != -1) {
								mainType = "mid";
								this.mainActionData.charType = mainType;
							} else {
								mainType = "eid";
								this.mainActionData.charType = mainType;
								_dir_ = 0;
							}
						}
						mainActionData.random = random;
						if (_currFrame_ >= mainActionData.totalFrames) {
							_currFrame_ = 0;
						}
						mainActionData.currFrame = _currFrame_;
						mainActionData.currDir = _dir_;
						mainActionData.currAct = _actNow_;
					}
				}
				actionDataArray.push(actData);
				bodyPartsHash.put(_type_, actData, true);
			}
		}
		
		private function update():void
		{
			mainActionData.currAct = _actNow_;
			if (_currFrame_ >= mainActionData.totalFrames) {
				_currFrame_ = 0;
			}
			mainActionData.currFrame = _currFrame_;
			mainActionData.currDir = _dir_;
		}
		
		public function isLoopAct(act:String):Boolean
		{
			if (loopActions.indexOf(act) != -1) {
				return true;
			}
			return false;
		}
		
		public function get needWalk():Boolean
		{
			return true;
		}
		
		public function get hitFrameFunc():Function
		{
			return _hitFrameFunc_;
		}
		public function set hitFrameFunc(value:Function):void
		{
			_hitFrameFunc_ = value;
		}
		
		public function get skillFrameFunc():Function
		{
			return _skillFrameFunc_;
		}
		public function set skillFrameFunc(value:Function):void
		{
			_skillFrameFunc_ = value;
		}
		
		public function get mainType():String
		{
			return _mainType;
		}
		public function set mainType(value:String):void
		{
			_mainType = value;
		}
		
		public function playEffect(effect:String, playEndFunc:Function=null):void
		{
		}
		
		public function play(act:String, renderType:int=0, playEndFunc:Function=null, stopFrame:int=-1):void
		{
			if (isLoopAct(act) || renderType) {
				var avatar:IAvatar = AvatarUnitDisplay.takeUnitDisplay(this.oid);
				if (!(avatar as MainChar)) {
					renderType = 0;
				}
				if (_actNow_ != act) {
					_actPrve_ = _actNow_;
					if ((act == "walk" && _actNow_ == "run") || (act == "run" && _actNow_ == "walk")) {
						if (mainActionData) {
							if (_currFrame_ >= mainActionData.totalFrames) {
								_currFrame_ = 0;
							}
							mainActionData.currFrame = _currFrame_;
							mainActionData.currAct = act;
							renderType = AvatarUnit.UN_PLAY_NEXT_RENDER;
							mainActionData.stopFrame = stopFrame;
						}
					} else {
						_currFrame_ = stopFrame != -1 ? stopFrame : 0;
						if (mainActionData) {
							mainActionData.stopFrame = stopFrame;
						}
						if (act == "stand" && (_actNow_ == "run" || _actNow_ == "walk")) {
							if (mainActionData) {
								if (_currFrame_ >= mainActionData.totalFrames) {
									_currFrame_ = 0;
								}
								mainActionData.currFrame = _currFrame_;
								mainActionData.currAct = act;
								mainActionData.stopFrame = stopFrame;
							}
							_actNow_ = act;
						}
					}
					if (mainActionData && act == "death" && stopFrame == -1) {
						mainActionData.stopFrame = DEATH_STOP_FRAME;
					}
					_actNow_ = act;
					_actNext_ = act;
					act_replay = 0;
					loadActSWF();
					this.onBodyRender(renderType);
				} else {
					if (renderType == PLAY_NEXT_RENDER && isLoopAct(act) == false) {
						act_replay = (act_replay + 1);
						loadActSWF();
					}
				}
			} else {
				_actNext_ = act;
				if (mainActionData) {
					mainActionData.stopFrame = stopFrame;
				}
				if (isLoopAct(act) == false && isLoopAct(_actNow_)) {
					if (_actNow_ != act) {
						_currFrame_ = 0;
						_actPrve_ = _actNow_;
						_bodyOverTime_ = getTimer();
						play(act, PLAY_NEXT_RENDER);
						act_replay = 0;
						return;
					}
					act_replay = (act_replay + 1);
				} else {
					if (_actNow_ == act && isLoopAct(act) == false) {
						act_replay = act_replay + 1;
					}
				}
				this.onBodyRender(renderType);
			}
		}
		
		public function get act():String
		{
			return _actNow_;
		}
		
		public function set dir(value:uint):void
		{
			if (value < 0) {
				dir = 0;
			}
			if (value > 7) {
				dir = 7;
			}
			if (_dir_ != value) {
				if (_lockDir != -1) {
					value = _lockDir;
				}
				_dir_ = value;
				if (FPSUtils.fps < 30) {
					this.onBodyRender();
				} else {
					this.onBodyRender(UN_PLAY_NEXT_RENDER);
				}
			}
		}
		
		public function get dir():uint
		{
			return _dir_;
		}
		
		private function analyeRequestPath(fileName:String, type:String, version:String=null):void
		{
		}
		
		override public function clone():Object
		{
			var me:AvatarUnit = AvatarUnit.createAvatarUnit();
			return me;
		}
		
		public function reset():void
		{
			_isDisposed_ = false;
			mainType = null;
			AvatarUnit._instanceHash_.put(this.id, this);
		}
		
		public function recover():void
		{
			if (_isDisposed_) {
				return;
			}
			if (this == Char.unitFamale || this == Char.unitMale) {
				return;
			}
			this.bodyPartsHash.reset();
			var paramKey:String = null;
			for each (var item:Object in effectHash) {
				paramKey = item.key;
				if (item.layer == "TOP_LAYER") {
					AvatarUnitDisplay.takeUnitDisplay(this.oid).onEffectRender(paramKey, "body_top_effect", null, 0, 0);
				} else {
					if (item.layer == "body_bottom_effect") {
						AvatarUnitDisplay.takeUnitDisplay(this.oid).onEffectRender(paramKey, "body_bottom_effect", null, 0, 0);
					} else {
						AvatarUnitDisplay.takeUnitDisplay(this.oid).onEffectRender(paramKey, "body_effect", null, 0, 0);
					}
				}
				effectHash.remove(paramKey);
			}
			this.effectHash.reset();
			AvatarUnit._instanceHash_.remove(this.id);
			this.dispose();
			reset();
			if (_recoverQueue_.length <= _recoverIndex_) {
				_recoverQueue_.push(this);
			}
		}
		
		override public function dispose():void{
			if (this == Char.unitFamale || this == Char.unitMale) {
				return;
			}
			
			var instanceHash:Hash = AvatarActionData.getInstanceHash();
			AvatarRenderElisor.getInstance().removeUnit(this.id);
			var actData:AvatarActionData = null;
			var tmpIndex:int = 0;
			while (tmpIndex < actionDataArray.length) {
				actData = actionDataArray[tmpIndex];
				if (instanceHash) {
					instanceHash.remove(actData.id);
				}
				if (actData) {
					actData.dispose();
				}
				tmpIndex++;
			}
			actionDataArray.length = 0;
			isDisposed = true;
			clearTimeout(setTimeOutIndex);
			_skillFrameFunc_ = null;
			_hitFrameFunc_ = null;
			_actNow_ = null;
			_actNext_ = null;
			_actPrve_ = null;
			_currFrame_ = 0;
			_totalFrames_ = 0;
			_interval_ = 0;
			_dir_ = 0;
			Number;
			_actMode_ = null;
			_bodyOverTime_ = 0;
			_effectOverTime_ = 0;
			act_replay = 0;
			charType = null;
			if (mainActionData) {
				mainActionData.dispose();
			}
			mainActionData = null;
			_mainType = null;
			stopPlay = true;
			isMain = false;
			_lockDir = -1;
			_isDisposed_ = true;
			for each (var item:AvatarActionData in bodyPartsHash) {
				AvatarActionData.removeAvatarActionData(item.id) as AvatarActionData;
			}
			if (this.bodyPartsHash) {
				this.bodyPartsHash.reset();
			}
			
			var paramKey:String = null;
			var avatar:IAvatar = null;
			for each (var param:Object in effectHash) {
				paramKey = param.key;
				avatar = AvatarUnitDisplay.takeUnitDisplay(this.oid);
				if (param.layer == "TOP_LAYER") {
					if (avatar) {
						avatar.onEffectRender(paramKey, "body_top_effect", null, 0, 0);
					}
				} else {
					if (param.layer == "body_bottom_effect") {
						if (avatar) {
							avatar.onEffectRender(paramKey, "body_bottom_effect", null, 0, 0);
						}
					} else {
						if (avatar) {
							avatar.onEffectRender(paramKey, "body_effect", null, 0, 0);
						}
					}
				}
				if (effectHash) {
					effectHash.remove(paramKey);
				}
			}
			this.effectHash = null;
			AvatarUnit._instanceHash_.remove(this.id);
			AvatarRenderElisor.getInstance().removeUnit(id);
			AvatarUnit._instanceHash_.remove(this.id);
			this.stopPlay = true;
			mainType = null;
			priorLoadQueue = null;
			super.dispose();
		}
		
		public function get lockDir():int
		{
			return _lockDir;
		}
		public function set lockDir(value:int):void
		{
			_lockDir = value;
			_dir_ = value;
		}

		new Vector.<String>(4)[0] = "mid";
		new Vector.<String>(4)[1] = "wid";
		new Vector.<String>(4)[2] = "wgid";
		new Vector.<String>(4)[3] = "midm";
		new Vector.<String>(5)[0] = "skill_warm";
		new Vector.<String>(5)[1] = "attack_warm";
		new Vector.<String>(5)[2] = "stand";
		new Vector.<String>(5)[3] = "run";
		new Vector.<String>(5)[4] = "walk";
		new Vector.<String>(9)[0] = "char";
		new Vector.<String>(9)[1] = "monster_normal";
		new Vector.<String>(9)[2] = "hero";
		new Vector.<String>(9)[3] = "pet";
		new Vector.<String>(9)[4] = "npc_car";
		new Vector.<String>(9)[5] = "hero_pet";
		new Vector.<String>(9)[6] = "0npc_normal";
		new Vector.<String>(9)[7] = "npc_summon";
		new Vector.<String>(9)[8] = "monster_summon";
	}
} 
