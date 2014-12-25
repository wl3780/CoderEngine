package com.coder.core.controls.wealth
{
	import com.coder.core.controls.elisor.Elisor;
	import com.coder.core.events.WealthEvent;
	import com.coder.core.events.WealthProgressEvent;
	import com.coder.engine.Asswc;
	import com.coder.global.EngineGlobal;
	import com.coder.interfaces.dock.IProto;
	import com.coder.interfaces.system.IWealthQueue;
	import com.coder.utils.Hash;
	import com.coder.utils.ObjectUtils;
	
	import flash.events.EventDispatcher;
	import flash.system.LoaderContext;
	import flash.utils.getQualifiedClassName;
	import flash.utils.getTimer;

	public class WealthQueueGroup extends EventDispatcher implements IProto, IWealthQueue
	{
		public var loaderContext:LoaderContext;
		public var name:String;
		
		protected var _id_:String;
		protected var _oid_:String;
		protected var _proto_:Object;
		protected var _className_:String;
		protected var _isDispose_:Boolean;
		
		private var _delay:int = 0;
		private var _delayTime:int;
		private var _wealthGroup:WealthGroup;
		private var _wealthGroupQueue:Vector.<WealthGroup>;
		private var _wealthKeyHash:Hash;
		private var _limitIndex:int = 2;
		private var _stop:Boolean;
		
		private var dur:int = 0;
		private var wealthElisor:WealthElisor;

		public function WealthQueueGroup()
		{
			super();
			_id_ = EngineGlobal.WEALTH_QUEUE_GROUP_SIGN + Asswc.getSoleId();
			_className_ = getQualifiedClassName(this);
			WealthQueueAlone.instanceHash.put(this.id, this);
			
			_wealthGroupQueue = new Vector.<WealthGroup>();
			_wealthKeyHash = new Hash();
			wealthElisor = WealthElisor.getInstance();
			Elisor.getInstance().addFrameOrder(this, loop);
		}
		
		public function get limitIndex():int
		{
			return _limitIndex;
		}
		
		public function get stop():Boolean
		{
			return _stop;
		}
		public function set stop(value:Boolean):void
		{
			_stop = value;
		}
		
		public function loop():void
		{
			if (_stop) {
				return;
			}
			if ((getTimer() - _delayTime) > _delay) {
				_delayTime = getTimer();
				loadWealth();
			}
		}
		
		public function addWealthGroup(value:WealthGroup):void
		{
			value.oid = this.id;
			if (!_wealthKeyHash.has(value.id)) {
				_wealthGroupQueue.push(value);
				_wealthKeyHash.put(value.id, value);
			}
		}
		
		public function get group_length():int
		{
			var result:int = 0;
			for each (var group:WealthGroup in _wealthGroupQueue) {
				if (!group.loaded) {
					result ++;
				}
			}
			return result;
		}
		
		public function takeWealthGroup(gid:String):WealthGroup
		{
			return _wealthKeyHash.take(gid) as WealthGroup;
		}
		
		public function removeWealthGroup(gid:String):void
		{
			var group:WealthGroup = _wealthKeyHash.take(gid) as WealthGroup;
			if (group) {
				for each (var wealthData:WealthData in group.wealths) {
					wealthElisor.cancelWealth(wealthData.id);
				}
				var index:int = _wealthGroupQueue.indexOf(group);
				if (index != -1) {
					_wealthGroupQueue.splice(index, 1);
				}
			}
		}
		
		public function removeWealthById(wealth_id:String):void
		{
			var wealthData:WealthData = WealthData.getWealthData(wealth_id);
			if (wealthData && wealthData.oid) {
				var group:WealthGroup = _wealthKeyHash.take(wealthData.oid) as WealthGroup;
				if (group) {
					group.removeWealthById(wealth_id);
				}
			}
		}
		
		public function loadWealth():void
		{
			if ((getTimer() - dur) < 5 || WealthElisor.isClearing) {
				return;
			}
			
			var tmpGroup:WealthGroup = null;
			var index:int;
			var wealthData:WealthData = null;
			dur = getTimer();
			if (_wealthGroupQueue.length) {
				while (_limitIndex > 0 && !WealthElisor.isClearing && _wealthGroupQueue.length) {
					tmpGroup = _wealthGroup;
					_wealthGroup = getNeedWealthGroup();
					if (_wealthGroup && tmpGroup != _wealthGroup) {
						(_wealthGroup.type == 1) ? _limitIndex = 1 : _limitIndex = 2;
					} else {
						if (_wealthGroup == null) {
							if (_wealthGroupQueue.length) {
								index = 0;
								while (index < _wealthGroupQueue.length) {
									removeWealthGroup(_wealthGroupQueue[index].id);
									index++;
								}
							}
							_limitIndex = 2;
						}
					}
					if (_wealthGroup) {
						wealthData = _wealthGroup.getNextNeedWealthData();
						if (wealthData) {
							wealthElisor.loadWealth(wealthData, loaderContext);
						}
					}
					_limitIndex --;
				}
			}
		}
		
		private function getNeedWealthGroup():WealthGroup
		{
			for each (var group:WealthGroup in _wealthGroupQueue) {
				if (!group.loaded) {
					return group;
				}
			}
			return null;
		}
		
		internal final function _callSuccess_(wealth_id:String):void
		{
			var wealthData:WealthData = WealthData.getWealthData(wealth_id);
			if (wealthData) {
				_limitIndex += 1;
				wealthData.loaded = true;
				wealthData.isPend = false;
				wealthData.isSucc = true;
				var group:WealthGroup = updateWealthGroup(wealth_id);
				this.dispatchWealthEvent(WealthEvent.WEALTH_COMPLETE, wealthData.url, wealth_id, group.id);
				if (group.loaded) {
					this.dispatchWealthEvent(WealthEvent.WEALTH_GROUP_COMPLETE, wealthData.url, wealth_id, group.id);
					this.removeWealthGroup(group.id);
				}
			}
		}
		
		internal final function _callError_(wealth_id:String):void
		{
			var wealthData:WealthData = WealthData.getWealthData(wealth_id);
			if (wealthData) {
				_limitIndex += 1;
				wealthData.loaded = true;
				wealthData.isPend = false;
				wealthData.isSucc = false;
				var group:WealthGroup = updateWealthGroup(wealth_id);
				this.dispatchWealthEvent(WealthEvent.WEALTH_ERROR, wealthData.url, wealth_id, group.id);
				if (group.loaded) {
					this.dispatchWealthEvent(WealthEvent.WEALTH_GROUP_COMPLETE, wealthData.url, wealth_id, group.id);
				}
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
		
		private function updateWealthGroup(wealth_id:String):WealthGroup
		{
			var wealthData:WealthData = WealthData.getWealthData(wealth_id);
			if (wealthData) {
				var group:WealthGroup = this.takeWealthGroup(wealthData.oid);
				group.checkTotalFinish();
				return group;
			}
			return null;
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
			Elisor.getInstance().removeTotalFrameOrder(this);
			_proto_ = null;
			_oid_ = null;
			_id_ = null;
			_delay = 0;
			_delayTime = 0;
			_isDispose_ = true;
			_limitIndex = 0;
			_wealthGroup.dispose();
			_wealthGroup = null;
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
