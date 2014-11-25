package com.coder.core.controls.elisor
{
	import com.coder.core.protos.Order;
	import com.coder.engine.Asswc;
	
	import flash.display.DisplayObject;
	
	public final class FrameOrder extends Order
	{
		private static var OrderQueue:Vector.<FrameOrder> = new Vector.<FrameOrder>();

		public var value:int;
		public var display:DisplayObject;
		
		private var _stop:Boolean;
		private var _orderMode:String;

		public function FrameOrder()
		{
			super();
		}
		
		public static function createFrameOrder():FrameOrder
		{
			var order:FrameOrder = null;
			if (OrderQueue.length) {
				order = OrderQueue.pop();
				order.id = Asswc.getSoleId();
			} else {
				order = new FrameOrder();
			}
			return order;
		}

		public function get stop():Boolean
		{
			return _stop;
		}
		public function set stop(value:Boolean):void
		{
			_stop = value;
		}
		
		public function get orderMode():String
		{
			return _orderMode;
		}
		
		public function get isOnStageHandler():Boolean
		{
			if (display) {
				return true;
			}
			return false;
		}
		
		public function setup(orderType:String, oid:String, applyHandler:Function, executedHandler:Function=null):void
		{
			_orderMode = orderType;
			_oid_ = oid;
			_applyHandler_ = applyHandler;
			_executedHandler_ = executedHandler;
		}
		
		override public function execute():void
		{
		}
		
		override public function dispose():void
		{
			super.dispose();
			this.display = null;
			this.value = 0;
			_stop = false;
			_orderMode = null;
			OrderQueue.push(this);
		}

	}
}
