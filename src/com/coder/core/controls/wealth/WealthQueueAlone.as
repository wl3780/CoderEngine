package com.coder.core.controls.wealth
{
	import com.coder.core.events.WealthEvent;
	import com.coder.core.events.WealthProgressEvent;
	import com.coder.engine.Asswc;
	import com.coder.global.EngineGlobal;
	import com.coder.interfaces.dock.IProto;
	import com.coder.interfaces.system.IWealthQueue;
	import com.coder.utils.Hash;
	import com.coder.utils.ObjectUtils;
	
	import flash.events.EventDispatcher;
	import flash.events.TimerEvent;
	import flash.net.registerClassAlias;
	import flash.system.ApplicationDomain;
	import flash.system.LoaderContext;
	import flash.system.Security;
	import flash.utils.Timer;
	import flash.utils.getQualifiedClassName;
	import flash.utils.getTimer;

	public class WealthQueueAlone extends EventDispatcher implements IProto, IWealthQueue
	{
		internal static var instanceHash:Hash = new Hash();
		public static var avatarRequestElisorTime:int;

		public var _wealthGroup_:WealthGroup;
		public var loaderContext:LoaderContext;
		public var isSortOn:Boolean;
		public var name:String;
		
		protected var _id_:String;
		protected var _oid_:String;
		protected var _proto_:Object;
		protected var _className_:String;
		protected var _isDispose_:Boolean;
		
		private var _delay:int = 15;
		private var _delayTime:int;
		private var _limitIndex:int = 2;
		private var _limitIndexMax:int = 2;
		private var _stop:Boolean = false;
		
		private var timer:Timer;
		private var wealthElisor:WealthElisor;

		public function WealthQueueAlone()
		{
			super();
			registerClassAlias("com.coder.WealthQuene", WealthQueueAlone);
			_id_ = EngineGlobal.WEALTH_QUEUE_ALONE_SIGN + Asswc.getSoleId();
			_className_ = getQualifiedClassName(this);
			instanceHash.put(this.id, this);
			wealthElisor = WealthElisor.getInstance();

			_wealthGroup_ = WealthGroup.createWealthGroup();
			_wealthGroup_.oid = this.id;
			
			var checkPolicy:Boolean = false;
			if (Security.sandboxType == Security.REMOTE) {
				checkPolicy = true;
			}
			loaderContext = new LoaderContext(checkPolicy, ApplicationDomain.currentDomain);
			
			timer = new Timer(5);
			timer.addEventListener(TimerEvent.TIMER, timerFunc);
			timer.start();
		}
		
		public static function getWealthQueue(id:String):IWealthQueue
		{
			return instanceHash.take(id) as IWealthQueue;
		}

		protected function timerFunc(event:TimerEvent):void
		{
			this.loop();
		}
		
		public function set limitIndex(value:int):void
		{
			_limitIndex = value;
			_limitIndexMax = value;
		}
		
		public function setStateLimitIndex():void
		{
			_limitIndex --;
			if (_limitIndex < 0) {
				_limitIndex = 0;
			}
		}
		
		public function get length():int
		{
			return _wealthGroup_.length;
		}
		
		public function get stop():Boolean
		{
			return _stop;
		}
		public function set stop(value:Boolean):void
		{
			_stop = value;
		}
		
		public function addWealth(url:String, data:Object=null, dataFormat:String=null, otherArgs:Object=null, prio:int=-1):String
		{
			if (_isDispose_) {
				return null;
			}
			
			var wealth_id:String = _wealthGroup_.addWealth(url, data, dataFormat, otherArgs, prio);
			if (isSortOn) {
				_wealthGroup_.sortOn(["prio", "time"], [Array.NUMERIC, Array.NUMERIC]);
			}
			return wealth_id;
		}
		
		public function loop():void
		{
			var pass:Boolean = true;
			if (name == WealthConst.AVATAR_REQUEST_WEALTH) {
				pass = false;
				if ((getTimer() - avatarRequestElisorTime) > 500) {
					pass = true;
				}
			}
			if (!_stop && pass && (getTimer() - _delayTime) > _delay) {
				_delayTime = getTimer();
				this.loadWealth();
			}
		}
		
		public function loadWealth():void
		{
			if (_wealthGroup_ && _wealthGroup_.length && !WealthElisor.isClearing && !_stop) {
				var index:int = 0;
				var wealthData:WealthData = null;
				while (index < _limitIndex) {
					if (!WealthElisor.isClearing && !_stop) {
						wealthData = _wealthGroup_.getNextNeedWealthData();
						if (wealthData) {
							wealthElisor.loadWealth(wealthData, loaderContext);
						}
					}
					index++;
				}
			}
		}
		
		internal final function _callSuccess_(wealth_id:String):void
		{
			var wealthData:WealthData = WealthData.getWealthData(wealth_id);
			if (wealthData && wealthData.loaded == false) {
				_limitIndex += 1;
				if (_limitIndex > _limitIndexMax) {
					_limitIndex = _limitIndexMax;
				}
				wealthData.loaded = true;
				wealthData.isPend = false;
				wealthData.isSucc = true;
				_wealthGroup_.removeWealthById(wealth_id);
				this.dispatchWealthEvent(WealthEvent.WEALTH_COMPLETE, wealthData.url, wealth_id, wealthData.oid);
			}
		}
		
		internal final function _callError_(wealth_id:String):void
		{
			var wealthData:WealthData = WealthData.getWealthData(wealth_id);
			if (wealthData && wealthData.loaded == false) {
				_limitIndex += 1;
				if (_limitIndex > _limitIndexMax) {
					_limitIndex = _limitIndexMax;
				}
				wealthData.loaded = true;
				wealthData.isPend = false;
				wealthData.isSucc = false;
				_wealthGroup_.removeWealthById(wealth_id);
				this.dispatchWealthEvent(WealthEvent.WEALTH_ERROR, wealthData.url, wealth_id, wealthData.oid);
			}
		}
		
		internal final function _callProgress_(wealth_id:String, bytesLoaded:Number, bytesTotal:Number):void
		{
			var wealthData:WealthData = WealthData.getWealthData(wealth_id);
			if (wealthData) {
				this.dispatchWealthProgressEvent(wealthData.url, wealth_id, bytesLoaded, bytesTotal);
			}
		}
		
		private function dispatchWealthEvent(eventType:String, path:String, wealth_id:String, wealthGroup_id:String):void
		{
			var event:WealthEvent = new WealthEvent(eventType);
			event.path = path;
			event.wealth_id = wealth_id;
			event.wealthGroup_id = wealthGroup_id;
			this.dispatchEvent(event);
		}
		
		private function dispatchWealthProgressEvent(path:String, wealth_id:String, bytesLoaded:Number, bytesTotal:Number):void
		{
			var event:WealthProgressEvent = new WealthProgressEvent(WealthProgressEvent.PROGRESS);
			event.path = path;
			event.bytesLoaded = bytesLoaded;
			event.wealth_id = wealth_id;
			event.bytesTotal = bytesTotal;
			this.dispatchEvent(event);
		}
		
		public function removeWealth(wealth_id:String):void
		{
			if (_isDispose_) {
				return;
			}
			wealthElisor.cancelWealth(wealth_id);
			_wealthGroup_.removeWealthById(wealth_id);
		}
		
		public function get delay():int
		{
			return _delay;
		}
		public function set delay(value:int):void
		{
			_delay = value;
		}
		
		public function get id():String
		{
			return _id_;
		}
		public function set id(value:String):void
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
		
		public function dispose():void
		{
			timer.stop();
			timer.removeEventListener(TimerEvent.TIMER, timerFunc);
			timer = null;
			
			instanceHash.remove(this.id);
			_id_ = null;
			_oid_ = null;
			_proto_ = null;
			_className_ = null;
			_delay = 0;
			_delayTime = 0;
			_limitIndex = 0;
			_isDispose_ = true;
			_wealthGroup_.dispose();
			_wealthGroup_ = null;
			this.wealthElisor = null;
			this.stop = false;
		}
		
		override public function toString():String
		{
			return "[" + _className_ + Asswc.SIGN + _id_ + "]";
		}
		
		public function get className():String
		{
			return _className_;
		}
	}
} 
