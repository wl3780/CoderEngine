package com.coder.core.displays.items.unit
{
	import com.coder.core.controls.elisor.Elisor;
	import com.coder.core.controls.wealth.WealthElisor;
	import com.coder.core.controls.wealth.WealthStoragePort;
	import com.coder.engine.Asswc;
	import com.coder.interfaces.display.ILoader;
	import com.coder.interfaces.system.IOrderDispatcher;
	import com.coder.utils.Hash;
	import com.coder.utils.ObjectUtils;
	
	import flash.display.Loader;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.net.URLRequest;
	import flash.system.ApplicationDomain;
	import flash.system.LoaderContext;

	public class DisplayLoader extends Loader implements ILoader, IOrderDispatcher
	{
		private static var _elisor_:Elisor = Elisor.getInstance();
		private static var loaderQueue:Vector.<DisplayLoader> = new Vector.<DisplayLoader>();
		private static var hash:Hash = new Hash();

		public var isDisposed:Boolean = false;
		
		protected var _path_:String;
		protected var _className_:String;
		protected var _id_:String;
		protected var _oid_:String;
		protected var _proto_:Object;
		protected var _callSuccess_:Function;
		protected var _callError_:Function;
		protected var _callProgress_:Function;

		public function DisplayLoader()
		{
			_id_ = Asswc.getSoleId();
			WealthElisor.loaderInstanceHash.put(this.id, this);
		}
		
		public static function getDisplayLoader():DisplayLoader
		{
			var loader:DisplayLoader = null;
			if (loaderQueue.length) {
				loader = loaderQueue.pop();
				loader.pid = Asswc.getSoleId();
				loader.isDisposed = false;
				WealthElisor.loaderInstanceHash.put(loader.id, loader);
			} else {
				loader new DisplayLoader();
			}
			return loader;
		}

		public function loadElemt(url:String, successFunc:Function=null, errorFunc:Function=null, progressFunc:Function=null, loaderContext:LoaderContext=null):void
		{
			if (isDisposed) {
				return;
			}
			
			if (!url || url.indexOf("null") != -1) {
				_errorFunc_(null);
				return;
			}
			
			hash.put(url, url);
			_path_ = url;
			_callSuccess_ = successFunc;
			_callError_ = errorFunc;
			_callProgress_ = progressFunc;
			this.contentLoaderInfo.addEventListener(Event.COMPLETE, _successFunc_);
			this.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, _errorFunc_);
			this.contentLoaderInfo.addEventListener(ProgressEvent.PROGRESS, _progressFunc_);
			try {
				this.load(new URLRequest(url), loaderContext);
			} catch (e:Error) {
				var context:LoaderContext = new LoaderContext(false, ApplicationDomain.currentDomain);
				this.load(new URLRequest(url), context);
			}
		}
		protected function _progressFunc_(event:ProgressEvent):void
		{
			if (_callProgress_ != null) {
				_callProgress_(this.path, event.bytesLoaded, event.bytesTotal);
			}
		}
		
		protected function _errorFunc_(event:IOErrorEvent):void
		{
			this.contentLoaderInfo.removeEventListener(Event.COMPLETE, _successFunc_);
			this.contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR, _errorFunc_);
			this.contentLoaderInfo.removeEventListener(ProgressEvent.PROGRESS, _progressFunc_);
			
			if (_callError_ != null) {
				var tmp:Function = _callError_;
				_callError_ = null;
				tmp(path);
			}
			_callSuccess_ = null;
			_callProgress_ = null;
		}
		
		protected function _successFunc_(event:Event):void
		{
			this.contentLoaderInfo.removeEventListener(Event.COMPLETE, _successFunc_);
			this.contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR, _errorFunc_);
			this.contentLoaderInfo.removeEventListener(ProgressEvent.PROGRESS, _progressFunc_);
			WealthStoragePort.depositWealth(this.path, this.id);
			
			if (_callSuccess_ != null){
				var tmp:Function = _callSuccess_;
				_callSuccess_ = null;
				tmp(path);
			}
			_callError_ = null;
			_callProgress_ = null;
		}
		
		public function get path():String
		{
			return _path_;
		}
		
		override public function addEventListener(type:String, listener:Function, useCapture:Boolean=false, priority:int=0, useWeakReference:Boolean=false):void
		{
			if (!_elisor_.hasEventOrder(this.id, type)) {
				_elisor_.addEventOrder(this, type, listener);
				super.addEventListener(type, listener, useCapture);
			}
		}
		
		override public function removeEventListener(type:String, listener:Function, useCapture:Boolean=false):void
		{
			_elisor_.removeEventOrder(this.id, type);
			super.removeEventListener(type, listener);
		}
		
		public function addFrameOrder(heartBeatHandler:Function, deay:int=0, isOnStageHandler:Boolean=false):void
		{
			_elisor_.addFrameOrder(this, heartBeatHandler, deay, isOnStageHandler);
		}
		
		public function removeFrameOrder(heartBeatHandler:Function):void
		{
			_elisor_.removeFrameOrder(heartBeatHandler);
		}
		
		public function hasFrameOrder(heartBeatHandler:Function):Boolean
		{
			return _elisor_.hasFrameOrder(heartBeatHandler);
		}
		
		public function setTimeOut(closureHandler:Function, delay:int, ... args):String
		{
			var params:Array = [this, closureHandler].concat(args);
			return _elisor_.setTimeOut.apply(null, params);
		}
		
		public function setInterval(heartBeatHandler:Function, delay:int, ... args):void
		{
			var params:Array = [this, heartBeatHandler, delay].concat(args);
			_elisor_.setInterval.apply(null, params);
		}
		
		public function removeTotalFrameOrder():void
		{
			_elisor_.removeTotalFrameOrder(this);
		}
		
		public function removeTotalEventOrder():void
		{
			_elisor_.removeTotalEventOrder(this);
		}
		
		public function removeTotalOrders():void
		{
			removeTotalEventOrder();
			removeTotalFrameOrder();
		}
		
		public function get id():String
		{
			return _id_;
		}
		
		internal function set pid(value:String):void
		{
			_id_ = value;
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
			this.contentLoaderInfo.removeEventListener(Event.COMPLETE, _successFunc_);
			this.contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR, _errorFunc_);
			this.contentLoaderInfo.removeEventListener(ProgressEvent.PROGRESS, _progressFunc_);
			WealthStoragePort.removeWealth(_path_);
			WealthElisor.getInstance().cancelByPath(_path_);
			WealthElisor.loaderInstanceHash.remove(this.id);
			this.removeTotalOrders();
			_path_ = null;
			_proto_ = null;
			_oid_ = null;
			_id_ = null;
			_callError_ = null;
			_callProgress_ = null;
			_callSuccess_ = null;
			this.isDisposed = true;
			this.unload();
			this.unloadAndStop();
		}

	}
}
