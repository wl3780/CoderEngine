package com.coder.core.controls.elisor
{
	import com.coder.core.displays.DisplayObjectPort;
	import com.coder.core.protos.Order;
	import com.coder.engine.Asswc;
	import com.coder.interfaces.system.IOrderDispatcher;
	
	import flash.net.registerClassAlias;

	public class EventOrder extends Order
	{
		private static var OrderQueue:Vector.<EventOrder> = new Vector.<EventOrder>();

		protected var _listener_:Function;
		protected var _listenerType_:String;
		protected var _orderMode_:String;

		public function EventOrder()
		{
			super();
			_className_ = null;
			registerClassAlias("com.coder.save.EventOrder", EventOrder);
			_orderMode_ = OrderMode.EVENT_ORDER;
		}
		
		public static function createEventOrder():EventOrder
		{
			var order:EventOrder = OrderQueue.length ? OrderQueue.pop() : new EventOrder();
			return order;
		}

		public function get type():String
		{
			return _listenerType_;
		}
		
		public function register(oid:String, className:String, listenerType:String, listener:Function):void
		{
			_listener_ = listener;
			_listenerType_ = listenerType;
			_oid_ = oid;
			_className_ = className;
			_id_ = oid + Asswc.SIGN + listenerType;
		}
		
		override public function dispose():void
		{
			unactivate();
			_listener_ = null;
			_listenerType_ = null;
			super.dispose();
		}
		
		override public function execute():void
		{
			activate();
		}
		
		public function activate():void
		{
			var pispatcher:IOrderDispatcher = DisplayObjectPort.takeTargetByClassName(this.className, this.oid);
			if (pispatcher) {
				pispatcher.addEventListener(this.type, _listener_);
			}
		}
		
		public function unactivate():void
		{
			var pispatcher:IOrderDispatcher = DisplayObjectPort.removeTargetByClassName(this.className, this.oid);
			if (pispatcher) {
				pispatcher.removeEventListener(this.type, _listener_);
			}
		}

	}
}
