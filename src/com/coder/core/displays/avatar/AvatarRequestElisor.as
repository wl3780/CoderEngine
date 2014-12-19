package com.coder.core.displays.avatar
{
	import com.coder.core.controls.elisor.Elisor;
	import com.coder.core.controls.wealth.WealthData;
	import com.coder.core.controls.wealth.WealthElisor;
	import com.coder.core.controls.wealth.WealthQueueAlone;
	import com.coder.core.controls.wealth.WealthStoragePort;
	import com.coder.core.displays.items.unit.BingLoader;
	import com.coder.core.displays.items.unit.DisplayLoader;
	import com.coder.core.displays.world.Scene;
	import com.coder.core.events.WealthEvent;
	import com.coder.core.protos.Proto;
	import com.coder.engine.Asswc;
	import com.coder.engine.Engine;
	import com.coder.global.EngineGlobal;
	import com.coder.interfaces.display.ILoader;
	import com.coder.utils.FPSUtils;
	import com.coder.utils.Hash;
	import com.coder.utils.log.Log;
	
	import flash.display.BitmapData;
	import flash.utils.ByteArray;
	import flash.utils.Dictionary;
	import flash.utils.getTimer;

	public class AvatarRequestElisor extends Proto
	{
		private static const _emptyHash_:Hash = new Hash();

		public static var analyzeSWFQueue:Array = [];
		public static var analyzeSWFQueueNow:Array = [];
		public static var AvatarLoadHash:Hash = new Hash();
		public static var workerAnalyzeSWF:Function;
		public static var SWF_QUEUE:Array = [];
		
		private static var _instance_:AvatarRequestElisor;
		private static var _bitmapdataHash_:Hash = new Hash();
		private static var _swfHash_:Hash = new Hash();

		public var stop:Boolean = false;
		
		private var _wealthQueue_:WealthQueueAlone;
		private var _requestsHash_:Hash;
		private var _urlRequestsHash_:Hash;
		private var _analyzeIntervalTime_:int = 0;
		private var loadIndex:int = 80;
		private var tIndex:int = 0;
		private var analyeHash:Dictionary;
		private var warmHash:Object;

		public function AvatarRequestElisor()
		{
			_requestsHash_ = new Hash();
			_urlRequestsHash_ = new Hash();
			analyeHash = new Dictionary();
			warmHash = {
				attack:"attack_warm",
				walk:"walk_warm",
				run:"run_warm"
			}
			super();
			setup();
		}
		
		public static function set stop(value:Boolean):void
		{
			AvatarRequestElisor.getInstance().wealthQueue.stop = value;
		}
		public static function get stop():Boolean
		{
			return AvatarRequestElisor.getInstance().wealthQueue.stop;
		}
		
		public static function getBitmapDataHash(key:String, link:String):Dictionary
		{
			return _bitmapdataHash_.take(key) as Dictionary;
		}
		
		public static function getBitmapData(key:String, link:String):BitmapData
		{
			var dic:Dictionary = _bitmapdataHash_.take(key) as Dictionary;
			if (dic) {
				return dic[link] as BitmapData;
			}
			return null;
		}
		
		public static function getInstance():AvatarRequestElisor
		{
			return _instance_ ||= new AvatarRequestElisor();
		}
		
		public static function record(... args):void
		{
			if (!Engine.isRecord) {
				return;
			}
			if (Scene.scene && Scene.scene.mapData && Scene.scene.mainChar.proto) {
				if (AvatarLoadHash[Scene.scene.mapData.map_id] == null) {
					AvatarLoadHash[Scene.scene.mapData.map_id] = [];
				}
				var key:String = "{ grade:" + Scene.scene.mainChar.proto.grade + "," + "params:[" + args + "]}";
				AvatarLoadHash[Scene.scene.mapData.map_id].push(key);
			}
		}

		public function get wealthQueue():WealthQueueAlone
		{
			return _wealthQueue_;
		}
		
		public function setup():void
		{
			AvatarRenderElisor.getInstance();
			_wealthQueue_ = new WealthQueueAlone();
			_wealthQueue_.loaderContext = null;
			_wealthQueue_.delay = 18;
			_wealthQueue_.limitIndex = loadIndex;
			_wealthQueue_.name = "AvatarRequestElisor";
			_wealthQueue_.isSortOn = true;
			_wealthQueue_.addEventListener(WealthEvent.WEALTH_COMPLETE, onWealthLoadFunc);
			Elisor.getInstance().addFrameOrder(this, heartBeatHandler);
		}
		
		private function heartBeatHandler():void
		{
			var queueLen:int = analyzeSWFQueueNow.length;
			if (queueLen > 36) {
				queueLen = 36;
			}
			if (analyzeSWFQueueNow.length > 200) {
				queueLen = 200;
			}
			if (FPSUtils.fps < 15) {
				queueLen = 36;
			}
			var data:Object = null;
			while (queueLen > 0 && !stop && analyzeSWFQueueNow.length) {
				data = analyzeSWFQueueNow.shift();
				analyzeSWF(data);
				queueLen--;
			}
		}
		
		private function analyeNewBitmapData():void
		{
		}
		
		public function loadAvatarFormat(unit_id:String, idName:String):String{
			if (!idName || idName == "null" || idName == "0") {
				Log.error(this, "asdfasdf");
			}
			
			var path:String = EngineGlobal.getAvatarAssetsConfigPath(idName);
			var type:String = idName.split(Asswc.LINE)[0];
			var actData:AvatarActionData = AvatarActionData.createAvatarActionData();
			var group:AvatarDataFormatGroup = _requestsHash_.take(path) as AvatarDataFormatGroup;
			if (!group) {
				group = AvatarDataFormatGroup.createAvatarActionDataGroup();
				group.wealth_path = path;
				_requestsHash_.put(path, group);
			}
			group.quoteQueue.push(actData.id);
			actData.oid = unit_id;
			actData.type = type;
			actData.idName = idName;
			actData.path = path;
			actData.startTime = getTimer();
			actData.avatarDataFormatGroup_id = group.id;
			if (idName == ("mid_" + EngineGlobal.SHADOW_ID)) {
				EngineGlobal.shadowAvatarGroup = group;
				EngineGlobal.avatarData = actData;
			}
			if (idName == ("mid_" + EngineGlobal.FAMALE_SHADOW)) {
				EngineGlobal.shadowAvatarGroupFamale = group;
				EngineGlobal.avatarDataFamale = actData;
			}
			if (idName == ("mid_" + EngineGlobal.MALE_SHADOW)) {
				EngineGlobal.shadowAvatarGroupMale = group;
				EngineGlobal.avatarDataMale = actData;
			}
			if (idName == "mid_wco001") {
				EngineGlobal.shadowAvatarGroupBaseFamale = group;
				EngineGlobal.avatarDataBaseFamale = actData;
			}
			if (idName == "mid_wcx001") {
				EngineGlobal.shadowAvatarGroupBaseMale = group;
				EngineGlobal.avatarDataBaseMale = actData;
			}
			if (!group.isLoaded) {
				if (!group.isPend) {
					group.isPend = true;
					group.wealth_id = _wealthQueue_.addWealth(path, {
						actionDataGroup_id:group.id,
						avatarData_id:actData.id,
						avatarUnit_id:unit_id
					});
					group.wealth_path = WealthData.getWealthData(group.wealth_id).url;
					record(unit_id, idName);
				}
			} else {
				actData.onSetupReady();
			}
			return actData.id;
		}
		
		protected function onWealthLoadFunc(event:WealthEvent):void
		{
			var path:String = event.path;
			var loader:ILoader = WealthStoragePort.takeLoaderByWealth(path);
			var wealthData:WealthData = WealthData.getWealthData(event.wealth_id);
			if (loader as BingLoader) {
				if (wealthData.data) {
					var formatGroup:AvatarDataFormatGroup = AvatarDataFormatGroup.takeAvatarDataFormatGroup(wealthData.data.actionDataGroup_id);
					this.analyeAvatarDataFormat(formatGroup, (loader as BingLoader).data as ByteArray);
					formatGroup.isLoaded = true;
					formatGroup.isPend = false;
					formatGroup.noticeAvatarActionData();
				}
				wealthData.dispose();
			} else if (loader as DisplayLoader) {
				if (wealthData.data) {
					var actInfo:Object = getActAndDir(path);
					analyzeSWFQueueNow.push({
						data:wealthData.data,
						path:path,
						act:actInfo.act,
						dir:actInfo.dir
					});
				}
				wealthData.dispose();
			} else {
				Log.error(this, "加载完成【异常】loader查询失败！", path);
			}
		}
		
		public function getActAndDir(path:String):Object
		{
			var arr:Array = path.split("/");
			var fileName:String = arr[arr.length - 1].split(".")[0];
			arr = fileName.split("_");
			var act:String = arr[2];
			var dir:int = arr[arr.length - 1];
			return {
				act:act,
				dir:dir
			};
		}
		
		private function analyeAvatarDataFormat(dataFormatGroup:AvatarDataFormatGroup, byte:ByteArray):void
		{
			try {
				byte.position = 0;
				byte.uncompress();
			} catch(e:Error) {
				Log.error(this, "重复解压错？");
				return;
			}
			
			var idName:String = byte.readUTF();
			dataFormatGroup.idName = idName;
			var len:int = byte.readByte();
			var index:int;
			var avatarData:AvatarDataFormat;
			while (index < len) {
				avatarData = AvatarDataFormat.createAvatarDataFormat();
				avatarData.oid = dataFormatGroup.id;
				avatarData.idName = idName;
				var actionName:String = byte.readUTF();
				var totalFrames:int = byte.readByte();
				var actionSpeed:int = byte.readShort();
				var replay:int = byte.readInt();
				var skillFrame:int = byte.readByte();
				var hitFrame:int = byte.readByte();
				var totalDir:int = byte.readByte();
				avatarData.actionName = actionName;
				avatarData.totalFrames = totalFrames;
				avatarData.actionSpeed = actionSpeed;
				avatarData.replay = replay;
				avatarData.skillFrame = skillFrame==0 ? totalFrames - 2 : skillFrame;
				avatarData.hitFrame = hitFrame;
				avatarData.totalDir = totalDir;
				if (avatarData.replay == 0) {
					avatarData.replay = 1;
				}
				avatarData.totalTime = 0;
				
				var frameIndex:int = 0;
				while (frameIndex < totalFrames) {
					var interval:int = byte.readInt();
					avatarData.intervalTimes.push(actionSpeed + interval);
					avatarData.totalTime = avatarData.totalTime + actionSpeed + interval;
					frameIndex++;
				}
				
				var dirIndex:int = 0;
				while (dirIndex < totalDir) {
					avatarData.dirOffsetX[dirIndex] = byte.readInt();
					avatarData.dirOffsetY[dirIndex] = byte.readInt();
					dirIndex++;
				}
				
				dirIndex = 0;
				while (dirIndex < totalDir) {
					var bWidths:Vector.<uint> = new Vector.<uint>();
					var bHeights:Vector.<uint> = new Vector.<uint>();
					var bTxs:Vector.<int> = new Vector.<int>();
					var bTys:Vector.<int> = new Vector.<int>();
					var bBitmapdatas:Vector.<String> = new Vector.<String>();
					
					frameIndex = 0;
					while (frameIndex < totalFrames) {
						var w:int = byte.readShort();
						var h:int = byte.readShort();
						var tx:int = byte.readShort();
						var ty:int = byte.readShort();
						tx = tx - 400;
						ty = ty - 300;
						bWidths.push(w);
						bHeights.push(h);
						bTxs.push(tx);
						bTys.push(ty);
						bBitmapdatas.push(avatarData.getLink(dirIndex, frameIndex));
						frameIndex ++;
					}
					avatarData.widths.push(bWidths);
					avatarData.heights.push(bHeights);
					avatarData.txs.push(bTxs);
					avatarData.tys.push(bTys);
					avatarData.bitmapdatas.push(bBitmapdatas);
					dirIndex ++;
				}
				dataFormatGroup.addAction(actionName, avatarData);
				index++;
			}
			if (dataFormatGroup.isCreateWarn) {
				if (dataFormatGroup.hasAction("attack")) {
					addWarmDataFormat("attack", "attack_warm", idName, dataFormatGroup);
				}
				if (dataFormatGroup.hasAction("walk")) {
					addWarmDataFormat("walk", "walk_warm", idName, dataFormatGroup, 1);
				}
				if (dataFormatGroup.hasAction("run")) {
					addWarmDataFormat("run", "run_warm", idName, dataFormatGroup, 1);
				}
			}
		}
		
		private function addWarmDataFormat(copyFrom:String, warmAction:String, avatar_id:String, dataFormatGroup:AvatarDataFormatGroup, replay:int=-1):void
		{
			var avatarData:AvatarDataFormat = dataFormatGroup.takeAction(copyFrom);
			if (!avatarData) {
				return;
			}

			var resultData:AvatarDataFormat = AvatarDataFormat.createAvatarDataFormat();
			resultData.oid = dataFormatGroup.id;
			resultData.idName = avatar_id;
			resultData.actionName = warmAction;
			resultData.totalFrames = 1;
			resultData.actionSpeed = avatarData.actionSpeed;
			resultData.replay = -1;
			resultData.skillFrame = 0;
			resultData.hitFrame = 0;
			resultData.totalDir = avatarData.totalDir;
			
			var dirIndex:int = 0;
			while (dirIndex < resultData.totalDir) {
				resultData.intervalTimes.push(resultData.actionSpeed + 0);
				resultData.totalTime = resultData.totalTime + resultData.actionSpeed + 0;
				dirIndex++;
			}
			dirIndex = 0;
			while (dirIndex < resultData.totalDir) {
				resultData.dirOffsetX[dirIndex] = avatarData.dirOffsetX[dirIndex];
				resultData.dirOffsetY[dirIndex] = avatarData.dirOffsetY[dirIndex];
				dirIndex++;
			}
			dirIndex = 0;
			while (dirIndex < resultData.totalDir) {
				var bWidths:Vector.<uint> = avatarData.widths[dirIndex].slice(0, 1);
				var bHeights:Vector.<uint> = avatarData.heights[dirIndex].slice(0, 1);
				var bTxs:Vector.<int> = avatarData.txs[dirIndex].slice(0, 1);
				var bTys:Vector.<int> = avatarData.tys[dirIndex].slice(0, 1);
				var bBitmapdatas:Vector.<int> = avatarData.bitmapdatas[dirIndex].slice(0, 1);
				
				resultData.widths.push(bWidths);
				resultData.heights.push(bHeights);
				resultData.txs.push(bTxs);
				resultData.tys.push(bTys);
				resultData.bitmapdatas.push(bBitmapdatas);
				dirIndex++;
			}
			dataFormatGroup.addAction(warmAction, resultData);
		}
		
		public function loadAssetOnBrackGround(type:String, idName:String, act:String="stand"):void
		{
			var actArr:Array = [act];
			if (act == "all") {
				actArr = ["stand", "walk", "run", "attack", "skill"];
			}
			var configPath:String = null;
			var filePath:String = null;
			var index:int = 0;
			while (index < actArr.length) {
				configPath = EngineGlobal.getAvatarAssetsConfigPath(idName);
				filePath = EngineGlobal.AVATAR_ASSETS_DIR + EngineGlobal.TYPE_REFLEX[type] + "/" + idName + Asswc.LINE + act + ".tmp";
				_wealthQueue_.addWealth(configPath);
				_wealthQueue_.addWealth(filePath);
				index++;
			}
		}
		
		public function loadAvatarSWF(dataFormat_id:String, idName:String, act:String, dir:int=0):void
		{
			if (WealthElisor.isClearing) {
				return;
			}
			if (act.indexOf("warm") != -1) {
				return;
			}
			var idType:String = idName.split(Asswc.LINE)[0];
			var actType:String = EngineGlobal.TYPE_REFLEX[idType];
			var path:String = EngineGlobal.AVATAR_ASSETS_DIR + actType + "/" + idName + Asswc.LINE + act + Asswc.LINE + dir + ".tmp";
			var loader:DisplayLoader = WealthStoragePort.takeLoaderByWealth(path) as DisplayLoader;
			if (loader) {
				var avatarData:AvatarDataFormat = AvatarDataFormat.takeAvatarDataFormat(dataFormat_id);
				avatarData.path = path;
				var analyKey:String = avatarData.idName + "." + avatarData.actionName + "." + dir;
				var has:Boolean = false;
				if (analyeHash[avatarData.idName] != null) {
					has = analyeHash[avatarData.idName][analyKey] != null ? true : false;
				}
				if (!has) {
					var info:Object = getActAndDir(path);
					analyzeSWF({
						data:dataFormat_id,
						path:path,
						act:info.act,
						dir:info.dir
					});
				}
			} else {
				if (_wealthQueue_._wealthGroup_.hashWealth(path) == false) {
					var reqKey:String = dataFormat_id + "@" + path;
					_urlRequestsHash_.put(reqKey, reqKey, true);
					var arr:Array = [Scene.scene.mainChar.mid, Scene.scene.mainChar.wid, Scene.scene.mainChar.wgid];
					var prio:int = -1;
					if (path.indexOf("npc") != -1) {
						prio = 1;
					} else if (path.indexOf("ms") != -1) {
						prio = 2;
					}
					var index:int = 0;
					while (index < arr.length) {
						if (path.indexOf(arr[index])) {
							prio = -1;
							break;
						}
						index++;
					}
					_wealthQueue_.addWealth(path, dataFormat_id, null, null, prio);
				}
			}
		}
		
		public function checkDataFormatIsready(key:String):void
		{
		}
		
		public function hasRequests(idName:String, act:String):Boolean
		{
			for (var url:String in _urlRequestsHash_) {
				if (url.indexOf(idName) != -1 && url.indexOf(act) != -1) {
					return true;
				}
			}
			return false;
		}
		
		public function hasloadedHash(idName:String, act:String):Boolean
		{
			return false;
		}
		
		public function hasAnalyzeSWF(idName:String, act:String):Boolean
		{
			var dic:Dictionary = analyeHash[idName];
			if (dic) {
				for (var key:String in dic) {
					if (key.indexOf(idName) != -1 && key.indexOf(act) != -1) {
						return true;
					}
				}
			}
			return false;
		}
		
		public function isWaitNew(idName:String, act:String):Boolean
		{
			var swf:Object = null;
			var link:String = null;
			var index:int = 0;
			while (index < SWF_QUEUE.length) {
				swf = SWF_QUEUE[index];
				link = swf.link;
				if (link.indexOf(idName) == -1 && link.indexOf(act) == -1) {
					return true;
				}
				index++;
			}
			return false;
		}
		
		private function analyzeSWF(data:Object=null):void
		{
			var avatarDataGroup:AvatarDataFormatGroup = null;
			var link:String = null;
			var cls:Class = null;
			var totalFrams:int;
			var idName:String = null;
			var act:String = null;
			var path:String = null;
			var dir:int;
			var key:String = null;
			var loader:DisplayLoader = null;
			var isOk:Boolean;
			var dic:Dictionary = null;
			var bitmapdataDic:Dictionary = null;
			var frameIndex:int;
			var bmd:BitmapData = null;
			var id2:String = null;
			if ((!data && analyzeSWFQueue.length == 0) || WealthElisor.isClearing) {
				return;
			}
			if (!data) {
				data = analyzeSWFQueue.shift();
			}
			var _local14:String = data.data;
			var avatarData:AvatarDataFormat = AvatarDataFormat.takeAvatarDataFormat(_local14);
			if (avatarData) {
				avatarDataGroup = AvatarDataFormatGroup.takeAvatarDataFormatGroup(avatarData.oid);
				totalFrams = avatarData.totalFrames;
				idName = avatarData.idName;
				act = data.act;
				path = data.path;
				dir = data.dir;
				key = idName + "." + act + "." + dir;
				if (data.act != avatarData.actionName) {
					return;
				}
				if (act.indexOf("warm") != -1) {
					path = path.replace("attack_warm", "attack");
				}
				loader = WealthStoragePort.takeLoaderByWealth(path) as DisplayLoader;
				if (!loader) {
					return;
				}
				isOk = true;
				avatarData.setActReady(data.act, data.dir, true);
				if (analyeHash[idName] == null) {
					dic = new Dictionary();
					analyeHash[idName] = dic;
				} else {
					dic = analyeHash[idName];
				}
				if (dic[key] == null) {
					dic[key] = key;
					bitmapdataDic = _bitmapdataHash_.take(idName + "_" + act) as Dictionary;
					if (!bitmapdataDic) {
						bitmapdataDic = new Dictionary();
					}
					frameIndex = 0;
					while (frameIndex < totalFrams) {
						link = avatarData.getLink(dir, frameIndex);
						if (bitmapdataDic[link] == null && !WealthElisor.isClearing) {
							try {
								cls = loader.contentLoaderInfo.applicationDomain.getDefinition(link) as Class;
								bmd = new cls();
							} catch(e:Error) {
								if (bmd) {
									bmd.dispose();
								}
								bmd = null;
								isOk = false;
								avatarData.setActReady(act, dir, false);
							}
							if (bitmapdataDic) {
								bitmapdataDic[link] = bmd;
							}
							bmd = null;
						}
						frameIndex++;
					}
					if (isOk) {
						if (avatarDataGroup.isCreateWarn && warmHash[avatarData.actionName] != null) {
							id2 = avatarDataGroup.takeAction(warmHash[avatarData.actionName]).id;
							_bitmapdataHash_.put(idName + "_" + warmHash[avatarData.actionName], bitmapdataDic);
						}
						_bitmapdataHash_.put(idName + "_" + act, bitmapdataDic);
					}
					bitmapdataDic = null;
				}
			}
		}
		
		public function clear():void
		{
			var arr:Array = null;
			var swf_id:String = null;
			var dataFormat:AvatarDataFormat = null;
			var hash:Dictionary = null;
			var bmd:BitmapData = null;
			var id_:String = null;
			var actData:Object = null;
			var dataFormat_id:String = null;
			
			var reg:RegExp = /.*[wco|wcx|dcx|dco|fcx|fco].*/;
			WealthElisor.isClearing = true;
			analyzeSWFQueueNow.length = 0;
			_wealthQueue_.limitIndex = loadIndex;
			_wealthQueue_._wealthGroup_.resetWealths();
			_wealthQueue_.stop = true;
			trace("=-=-=-=-=-clear");
			var cacheMemory:Boolean;
			if (Engine.currMemory >= 700) {
				cacheMemory = false;
			}
			var assetsHash:Hash = new Hash();
			var assetsHash2:Hash = new Hash();
			var isOk:Boolean;
			for (var key:String in _bitmapdataHash_) {
				if (reg.test(key)) {
					if (cacheMemory) {
						isOk = false;
					}
				}
				if (isOk) {
					hash = _bitmapdataHash_[key];
					for (var tmp_id:String in hash) {
						arr = tmp_id.split(".");
						swf_id = arr[0] + "_" + arr[1] + ".tmp";
						assetsHash.put(swf_id, swf_id);
						swf_id = arr[0] + "." + arr[1];
						assetsHash2.put(swf_id, swf_id);
						WealthStoragePort.clean(arr[0]);
						bmd = hash[tmp_id] as BitmapData;
						if (bmd) {
							bmd.dispose();
						}
					}
					hash = new Dictionary();
					delete _bitmapdataHash_[key];
				}
			}
			var loaderInstanceHash:Hash = WealthElisor.loaderInstanceHash;
			trace("回收前：", loaderInstanceHash.length);
			for each (var loader:ILoader in loaderInstanceHash) {
				if ((loader as DisplayLoader)) {
					if (loader.path) {
						arr = loader.path.split("/");
						swf_id = arr[(arr.length - 1)];
						isOk = true;
						if (((reg.test(swf_id)) && (cacheMemory))) {
							isOk = false;
						}
						if (((((isOk) && ((loader as DisplayLoader)))) && (!((swf_id.indexOf(".tmp") == -1))))) {
							WealthElisor.removeSign(loader.path);
							id_ = loader.id;
							loader.dispose();
							loaderInstanceHash.remove(tmp_id);
						}
					}
				}
			}
			trace("回收后：", loaderInstanceHash.length);
			for (var link:String in _urlRequestsHash_) {
				arr = link.split("/");
				swf_id = arr[(arr.length - 1)];
				dataFormat_id = link.slice(0, link.indexOf("@", 2));
				dataFormat = AvatarDataFormat.takeAvatarDataFormat(dataFormat_id);
				isOk = true;
				if (((reg.test(dataFormat.idName)) && (cacheMemory))) {
					isOk = false;
				}
				if (isOk) {
					if (dataFormat) {
						actData = getActAndDir(link);
						dataFormat.resetActReady();
					}
					_urlRequestsHash_.remove(link);
				}
			}
			_urlRequestsHash_.reset();
			var hashx:Hash = AvatarDataFormat.getInstanceHash;
			for each (var dataFormat_:AvatarDataFormat in hashx) {
				isOk = true;
				if (((reg.test(dataFormat_.idName)) && (cacheMemory))) {
					isOk = false;
				}
				if (isOk) {
					dataFormat_.resetActReady();
				}
			}
			for (var link2:String in _swfHash_) {
				isOk = true;
				if (((reg.test(link2)) && (cacheMemory))) {
					isOk = false;
				}
				if (isOk) {
					if (assetsHash2.has(link2)) {
						_swfHash_.remove(link2);
					}
				}
			}
			analyeHash = new Dictionary();
			WealthElisor.clear(assetsHash);
			assetsHash.reset();
			assetsHash2.reset();
			_wealthQueue_.stop = false;
		}

	}
} 
