package com.coder.core.displays.items.unit
{
	import com.coder.core.controls.wealth.WealthElisor;
	import com.coder.core.controls.wealth.WealthStoragePort;
	import com.coder.engine.Asswc;
	import com.coder.interfaces.display.ILoader;
	import com.coder.utils.ObjectUtils;
	
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.system.LoaderContext;

	public class BingLoader extends URLLoader implements ILoader
	{
		protected var _id_:String;
		protected var _oid_:String;
		protected var _path_:String;
		protected var _name_:String;
		protected var _className_:String;
		protected var _proto_:Object;
		
		protected var _callSuccess_:Function;
		protected var _callProgress_:Function;
		protected var _callError_:Function;

		public function BingLoader()
		{
			super();
			_id_ = Asswc.getSoleId();
			WealthElisor.loaderInstanceHash.put(this.id, this);
		}
		
		public function loadElemt(url:String, successFunc:Function=null, errorFunc:Function=null, progressFunc:Function=null, loaderContext:LoaderContext=null):void
		{
			_path_ = url;
			_callSuccess_ = successFunc;
			_callError_ = errorFunc;
			_callProgress_ = progressFunc;
			this.addEventListener(Event.COMPLETE, _successFunc_);
			this.addEventListener(IOErrorEvent.IO_ERROR, _errorFunc_);
			this.addEventListener(ProgressEvent.PROGRESS, _progressFunc_);
			this.load(new URLRequest(url));
		}
		
		protected function _progressFunc_(event:ProgressEvent):void
		{
			if (_callProgress_ != null) {
				_callProgress_(this.path, event.bytesLoaded, event.bytesTotal);
			}
		}
		
		protected function _errorFunc_(event:IOErrorEvent):void
		{
			if (_callError_ != null) {
				_callError_(path);
				_callError_ = null;
			}
			_callSuccess_ = null;
			_callProgress_ = null;
		}
		
		protected function _successFunc_(event:Event):void
		{
			WealthStoragePort.depositWealth(this.path, this.id);
			if (_callSuccess_ != null) {
				_callSuccess_(path);
				_callSuccess_ = null;
			}
			_callProgress_ = null;
			_callError_ = null;
		}
		
		public function get path():String
		{
			return _path_;
		}
		
		public function set name(value:String):void
		{
			_name_ = value;
		}
		public function get name():String
		{
			return _name_;
		}
		
		public function get id():String
		{
			return _id_;
		}
		
		public function get oid():String
		{
			return _oid_;
		}
		public function set oid(value:String):void
		{
			_oid_ = value;
		}
		
		public function get proto():Object
		{
			return _proto_;
		}
		public function set proto(value:Object):void
		{
			_proto_ = value;
		}
		
		public function clone():Object
		{
			return ObjectUtils.copy(this);
		}
		
		override public function toString():String
		{
			return "[" + _className_ + Asswc.SIGN + _id_ + "]";
		}
		
		public function get className():String
		{
			return _className_;
		}
		
		public function dispose():void
		{
			WealthStoragePort.removeWealth(_path_);
			WealthElisor.getInstance().cancelByPath(_path_);
			_path_ = null;
			_proto_ = null;
			_oid_ = null;
			_id_ = null;
			_callError_ = null;
			_callProgress_ = null;
			_callSuccess_ = null;
		}
		
		public function unloadAndStop(gc:Boolean=true):void
		{
			dispose();
		}

	}
}
