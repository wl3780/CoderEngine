package com.coder.core.controls.wealth
{
	import com.coder.core.protos.Proto;
	import com.coder.engine.Asswc;
	import com.coder.utils.Hash;
	
	import flash.net.URLLoaderDataFormat;
	import flash.utils.Dictionary;

	public final class WealthGroup extends Proto
	{
		internal static var instanceHash:Hash = new Hash();
		internal static var _recoverQueue_:Vector.<WealthGroup> = new Vector.<WealthGroup>();
		internal static var _recoverIndex_:int = 10;

		public var type:int;
		public var index:int;
		public var position:int;
		public var loadedIndex:int;
		
		protected var _isDisposed_:Boolean;
		
		private var _wealths:Dictionary;
		private var _wealthUrls:Array;
		private var _loaded_:Boolean;
		private var _length:int;

		public function WealthGroup()
		{
			super();
			instanceHash.put(_id_, this);
			this.type = WealthConst.PRIORITY_LEVEL;
			_wealths = new Dictionary();
			_wealthUrls = [];
		}
		
		public static function createWealthGroup():WealthGroup
		{
			var group:WealthGroup = null;
			if (_recoverQueue_.length) {
				group = _recoverQueue_.pop();
				instanceHash.put(group.id, group);
			} else {
				group = new WealthGroup();
			}
			return group;
		}

		public function get wealths():Array
		{
			return _wealthUrls;
		}
		public function resetWealths():void
		{
			_wealthUrls.length = 0;
			_wealths = new Dictionary();
		}
		
		public function sortOn(arr1:Array, arr2:Array):void
		{
			_wealthUrls.sortOn(arr1, arr2);
		}
		
		public function get loaded():Boolean
		{
			return _loaded_;
		}
		public function set loaded(value:Boolean):void
		{
			_loaded_ = value;
		}
		
		public function addWealth(url:String, data:Object=null, dataFormat:String=null, otherArgs:Object=null, prio:int=-1):String
		{
			var wealthData:WealthData = new WealthData();
			wealthData.url = url;
			wealthData.data = data;
			wealthData.proto = otherArgs;
			wealthData.oid = this.id;
			wealthData.wid = this.oid;
			if (prio != -1) {
				wealthData.prio = 0;
			}
			if (url.indexOf(".sm") != -1) {
				wealthData.prio = 0;
			}
			if (dataFormat) {
				wealthData.dataFormat = dataFormat;
			} else {
				if (wealthData.type == WealthConst.BING_WEALTH) {
					if (Asswc.TEXT_Files.indexOf(wealthData.suffix) != -1) {
						wealthData.dataFormat = URLLoaderDataFormat.TEXT;
					} else {
						wealthData.dataFormat = URLLoaderDataFormat.BINARY;
					}
				}
			}
			_wealths[wealthData.id] = wealthData;
			_wealthUrls.push(wealthData);
			return wealthData.id;
		}
		
		public function takeWealthById(id:String):WealthData
		{
			return _wealths[id] as WealthData;
		}
		
		public function hashWealth(url:String):Boolean
		{
			for each (var wealthData:WealthData in _wealths) {
				if (wealthData.url == url) {
					return true;
				}
			}
			return false;
		}
		
		public function removeWealthById(id:String):void
		{
			var wealthData:WealthData = _wealths[id] as WealthData;
			if (wealthData) {
				delete _wealths[id];
				var index:int = _wealthUrls.indexOf(wealthData);
				_wealthUrls.splice(index, 1);
				WealthElisor.getInstance().cancelWealth(id);
			}
		}
		
		override public function set oid(value:String):void
		{
			super.oid = value;
			for each (var wealthData:WealthData in _wealthUrls) {
				wealthData.wid = value;
			}
		}
		
		override public function dispose():void
		{
			instanceHash.remove(this.id);
			_wealths = null;
			_wealthUrls = null;
			_isDisposed_ = true;
			super.dispose();
		}
		 
		public function reset():void
		{
			_isDisposed_ = false;
			_wealths = new Dictionary();
			_wealthUrls.length = 0;
		}
		
		public function recover():void
		{
			if (_isDisposed_) {
				return;
			}
			this.reset();
			if (_recoverQueue_.length <= _recoverIndex_) {
				_recoverQueue_.push(this);
			}
		}
		
		public function getNextNeedWealthData():WealthData
		{
			for each (var wealthData:WealthData in _wealthUrls) {
				if (this.type == WealthConst.BUBBLE_LEVEL) {
					if (wealthData.loaded == false && wealthData.isPend == false) {
						return wealthData;
					}
					if (wealthData.loaded == false && wealthData.isPend) {
						return null;
					}
				} else {
					if (wealthData.loaded == false && wealthData.isPend == false) {
						return wealthData;
					}
				}
			}
			return null;
		}
		
		public function checkTotalFinish():void
		{
			var wealthData:WealthData = null;
			var wealthLen:int = _wealths.length;
			var loadedCount:int;
			var index:int;
			while (index < wealthLen) {
				wealthData = _wealthUrls[index];
				if (wealthData) {
					if (!wealthData.loaded) {
						_loaded_ = false;
					} else {
						loadedCount++;
					}
				}
				index++;
			}
			this.loadedIndex = loadedCount;
			if (loadedCount >= wealthLen) {
				_loaded_ = true;
			}
		}
		
		public function get length():int
		{
			return _wealthUrls.length;
		}
	}
}
