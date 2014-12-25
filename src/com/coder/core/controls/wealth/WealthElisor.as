package com.coder.core.controls.wealth
{
	import com.coder.core.displays.items.unit.BingLoader;
	import com.coder.core.displays.items.unit.DisplayLoader;
	import com.coder.engine.Asswc;
	import com.coder.interfaces.display.ILoader;
	import com.coder.utils.Hash;
	import com.coder.utils.log.Log;
	
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.system.ApplicationDomain;
	import flash.system.LoaderContext;
	import flash.system.Security;
	import flash.utils.Dictionary;

	public final class WealthElisor
	{
		public static var isClearing:Boolean;
		public static var loaderInstanceHash:Hash = new Hash();
		
		private static var _instance:WealthElisor;

		private var loaderContext:LoaderContext;
		private var wealthHash:Dictionary;

		public function WealthElisor()
		{
			super();
			wealthHash = new Dictionary();
			
			var checkPolicy:Boolean = false;
			if (Security.sandboxType == Security.REMOTE) {
				checkPolicy = true;
			}
			loaderContext = new LoaderContext(checkPolicy, ApplicationDomain.currentDomain);
		}
		
		public static function getInstance():WealthElisor
		{
			return _instance ||= new WealthElisor();
		}
		
		public static function removeSign(path:String):void
		{
			var dict:Dictionary = _instance.wealthHash;
			var sign:Sign = dict[path] as Sign;
			if (sign) {
				sign.dispose();
			}
			delete dict[path];
		}
		
		public static function clear(unHash:Hash):void
		{
			var arr:Array = null;
			var file:String = null;
			var sign:Sign = null;
			var dict:Dictionary = _instance.wealthHash;
			for (var path:String in dict) {
				arr = path.split("/");
				file = arr[arr.length - 1];
				if ( unHash.has(file) ) {
					sign = dict[path];
					sign.dispose();
					delete dict[path];
				}
			}
		}

		public function loadWealth(wealthData:WealthData, lc:LoaderContext=null):void
		{
			if (!wealthData) {
				return;
			}
			
			var url:String = wealthData.url;
			var owner:String = wealthData.id;
			var sign:Sign = wealthHash[url] as Sign;
			if (sign == null) {
				sign = new Sign();
				wealthHash[url] = sign;
				sign.path = url;
			}
			if (sign.wealths.indexOf(owner) == -1) {
				sign.wealths.push(owner);
			}
			
			var loader:ILoader = null;
			if (!sign.isLoaded && !sign.isPend) {
				sign.lc = lc;
				sign.isPend = true;
				sign.wealth_id = owner;
				if (wealthData.type == WealthConst.BING_WEALTH || wealthData.dataFormat == URLLoaderDataFormat.BINARY) {
					loader = new BingLoader();
					URLLoader(loader).dataFormat = wealthData.dataFormat;
					loader.loadElemt(wealthData.url, _callSuccess_, _callError_, _callProgress_, lc ? lc : this.loaderContext);
				} else if (wealthData.type == WealthConst.SWF_WEALTH || wealthData.type == WealthConst.IMG_WEALTH) {
					loader = new DisplayLoader();
					loader.loadElemt(wealthData.url, _callSuccess_, _callError_, _callProgress_, lc ? lc : this.loaderContext);
				}
				updateWealthState(sign.wealths, "isPend", sign.isPend);
			} else if (!sign.isLoaded && sign.isPend) {
				updateWealthState(sign.wealths, "isPend", sign.isPend);
			} else if (sign.isLoaded) {
				updateWealthState(sign.wealths, "loaded", sign.isLoaded);
			}
		}
		
		private function updateWealthState(wealths:Vector.<String>, proto:String, value:Boolean):void
		{
			if (!wealths || wealths.length == 0) {
				return;
			}
			
			var wealthData:WealthData = null;
			var wealthQueue:Object = null;
			for each (var wealthId:String in wealths) {
				wealthData = WealthData.getWealthData(wealthId);
				wealthQueue = WealthQueueAlone.getWealthQueue(wealthData.wid);
				if (wealthData && wealthQueue) {
					if (wealthQueue is WealthQueueAlone) {
						WealthQueueAlone(wealthQueue).setStateLimitIndex();
					}
					
					if ("isPend" == proto) {
						wealthData.isPend = value;
						if (wealthData.loaded == false) {
							wealthQueue._callSuccess_(wealthData.id);
						}
					} else if ("loaded" == proto) {
						
					}
				}
			}
		}
		
		protected function _callSuccess_(path:String):void
		{
			var sign:Sign = wealthHash[path] as Sign;
			if (sign) {
				sign.isLoaded = true;
				update(path, 1);
			}
		}
		
		protected function _callError_(path:String):void
		{
			var sign:Sign = wealthHash[path] as Sign;
			if (sign) {
				Log.error(this, sign.path);
				
				var wealthData:WealthData = WealthData.getWealthData(sign.wealth_id);
				if (wealthData && sign.tryNum > 0) {
					WealthStoragePort.disposeLoaderByWealth(sign.path);
					sign.tryNum = sign.tryNum - 1;
					sign.isPend = false;
					loadWealth(wealthData, sign.lc);
				} else {
					sign.isLoaded = true;
					update(path, 0);
				}
			}
		}
		
		protected function _callProgress_(path:String, bytesLoaded:Number, bytesTotal:Number):void
		{
			var sign:Sign = wealthHash[path] as Sign;
			if (sign) {
				sign.isPend = true;
				update(path, 2, bytesLoaded, bytesTotal);
			}
		}
		
		public function update(url:String, state:int, bytesLoaded:Number=0, bytesTotal:Number=0):void
		{
			var sign:Sign = wealthHash[url] as Sign;
			if (!sign) {
				return;
			}
			
			var wealthData:WealthData = null;
			var wealthQueue:Object = null;
			if (state == 0 || state == 1) {
				while (sign.wealths.length) {
					wealthData = WealthData.getWealthData( sign.wealths.shift() );
					if (wealthData && wealthData.loaded == false && Asswc.enabled) {
						wealthQueue = WealthQueueAlone.getWealthQueue(wealthData.wid) as Object;
						if (wealthQueue) {
							if (state == 0) {
								wealthQueue._callError_(wealthData.id);
							} else if (state == 1) {
								wealthQueue._callSuccess_(wealthData.id);
							}
						}
					}
				}
			} else {
				for each (var wealthId:String in sign.wealths) {
					wealthData = WealthData.getWealthData(wealthId);
					if (wealthData) {
						wealthQueue = WealthQueueAlone.getWealthQueue(wealthData.wid) as Object;
						if (wealthQueue && wealthQueue.name != WealthConst.AVATAR_REQUEST_WEALTH) {
							wealthQueue._callProgress_(wealthData.id, bytesLoaded, bytesTotal);
						}
					}
				}
			}
		}
		
		public function checkWealthPendSatte(url:String):Boolean
		{
			var sign:Sign = wealthHash[url] as Sign;
			if (sign) {
				return sign.isPend;
			}
			return false;
		}
		
		public function checkWealthHasCache(url:String):Boolean
		{
			var sign:Sign = wealthHash[url] as Sign;
			if (sign) {
				return sign.isLoaded;
			}
			return false;
		}
		
		public function cancelWealth(wealth_id:String):void
		{
			var wealthData:WealthData = WealthData.getWealthData(wealth_id);
			if (wealthData) {
				var url:String = wealthData.url;
				var sign:Sign = wealthHash[url] as Sign;
				if (sign) {
					var index:int = sign.wealths.indexOf(url);
					if (index != -1) {
						sign.wealths.splice(index, 1);
						if (sign.isPend && !sign.isLoaded && sign.wealths.length == 0) {
							var loader:ILoader = loaderInstanceHash.remove(url) as ILoader;
							if (loader) {
								loader.dispose();
							}
						}
					}
				}
			}
		}
		
		public function cancelByPath(url:String):void
		{
			if (!url) {
				return;
			}
			
			var sign:Sign = wealthHash[url] as Sign;
			if (sign && sign.isPend && !sign.isLoaded) {
				sign.wealths = new Vector.<String>();
				var loader:ILoader = loaderInstanceHash.remove(url) as ILoader;
				if (loader) {
					loader.dispose();
				}
			}
		}
	}
}

import com.coder.core.protos.Proto;

import flash.system.LoaderContext;

class Sign extends Proto
{
	public var tryNum:int = 1;
	public var path:String;
	public var wealths:Vector.<String>;
	public var isPend:Boolean;
	public var isLoaded:Boolean;
	public var wealth_id:String;
	public var lc:LoaderContext;

	public function Sign()
	{
		super();
		wealths = new Vector.<String>();
	}
	
	override public function dispose():void
	{
		super.dispose();
		this.path = null;
		wealths = null;
		wealth_id = null;
	}
}
