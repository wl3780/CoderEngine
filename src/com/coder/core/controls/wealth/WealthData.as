package com.coder.core.controls.wealth
{
	import com.coder.engine.Asswc;
	import com.coder.core.protos.Proto;
	import com.coder.utils.Hash;
	import com.coder.utils.log.Log;
	
	import flash.net.URLLoaderDataFormat;
	import flash.utils.getTimer;
	
	public final class WealthData extends Proto
	{
		private static var instanceHash:Hash = new Hash();

		public var data:Object;
		public var dataFormat:String = URLLoaderDataFormat.TEXT;
		public var loaded:Boolean;
		public var time:int;
		public var prio:int = 5;
		
		protected var _wid_:String;
		
		private var _url:String;
		private var _type:String;
		private var _suffix:String;
		private var _isPend:Boolean;

		public function WealthData()
		{
			instanceHash.put(this.id, this);
		}
		
		public static function getWealthData(id:String):WealthData
		{
			return instanceHash.take(id) as WealthData;
		}
		
		public static function resetInstanceHash():void
		{
			instanceHash.reset();
		}
		
		public static function removeWealthData(id:String):WealthData
		{
			return instanceHash.remove(id) as WealthData;
		}

		public function set wid(value:String):void
		{
			_wid_ = value;
		}
		public function get wid():String
		{
			return _wid_;
		}
		
		public function get url():String
		{
			return _url;
		}
		public function set url(value:String):void
		{
			_url = value;
			if (value) {
				try {
					_suffix = value.split(".").pop();
					_suffix = _suffix.split("?").shift();
					if (Asswc.SWF_Files.indexOf(_suffix) != -1) {
						_type = WealthConst.SWF_WEALTH;
					} else {
						if (Asswc.IMG_Files.indexOf(_suffix) != -1) {
							_type = WealthConst.IMG_WEALTH;
						} else {
							_type = WealthConst.BING_WEALTH;
						}
					}
				} catch(e:Error) {
					Log.error(this, toString() + "请检查资源地址格式是否正确");
				}
			}
			time = getTimer();
		}
		
		public function get type():String
		{
			return _type;
		}
		
		public function get suffix():String
		{
			return _suffix;
		}
		
		public function set isPend(value:Boolean):void
		{
			_isPend = value;
		}
		public function get isPend():Boolean
		{
			return _isPend;
		}
		
		override public function dispose():void
		{
			removeWealthData(this.id);
			_suffix = null;
			_type = null;
			super.dispose();
		}
	}
}
