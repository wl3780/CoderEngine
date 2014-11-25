package com.coder.core.controls.elisor
{
	import com.coder.core.protos.Proto;
	import com.coder.interfaces.system.IOrder;
	import com.coder.utils.Hash;
	
	import flash.utils.Dictionary;
	
	internal final class EventElisor extends Proto
	{
		private static var _instance:EventElisor;

		private var _orderQueues:Dictionary;
		private var _length:int;

		public function EventElisor()
		{
			super();
			_orderQueues = new Dictionary();
		}
		
		internal static function getInstance():EventElisor
		{
			return _instance ||= new EventElisor();
		}

		public function addOrder(order:EventOrder):Boolean
		{
			if (!order || order.type == null || order.oid == null) {
				return false;
			}
			
			var orderHash:Hash = _orderQueues[order.oid] as Hash;
			if (!orderHash) {
				orderHash = new Hash();
				_orderQueues[order.oid] = orderHash;
			}
			if (!orderHash.has(order.type)) {
				_length = _length + 1;
			}
			orderHash.put(order.type, order, true);
			return true;
		}
		
		public function removeEventOrder(oid:String, listenerType:String):void
		{
			if (!listenerType || !oid) {
				return;
			}
			
			var orderHash:Hash = _orderQueues[oid] as Hash;
			if (orderHash) {
				var order:EventOrder = orderHash.remove(listenerType) as EventOrder;
				if (order) {
					_length = _length - 1;
					order.dispose();
				}
			}
		}
		
		public function hasEventOrder(oid:String, listenerType:String):Boolean
		{
			var orderHash:Hash = _orderQueues[oid] as Hash;
			if (!orderHash) {
				return false;
			}
			return orderHash.has(listenerType);
		}
		
		public function takeOrder(oid:String, type:String):EventOrder
		{
			var orderHash:Hash = _orderQueues[oid] as Hash;
			if (!orderHash) {
				return null;
			}
			return orderHash.take(type) as EventOrder;
		}
		
		public function hasGroup(oid:String):Boolean
		{
			var orderHash:Hash = _orderQueues[oid];
			if (!orderHash) {
				return false;
			}
			return orderHash.length > 0;
		}
		
		public function takeGroupOrder(oid:String):Vector.<IOrder>
		{
			var result:Vector.<IOrder> = new Vector.<IOrder>();
			var orderHash:Hash = _orderQueues[oid] as Hash;
			if (orderHash) {
				for each (var order:EventOrder in orderHash) {
					result.push(order);
				}
			}
			return result;
		}
		
		public function disposeGroupOrders(oid:String):void
		{
			var orderHash:Hash = _orderQueues[oid] as Hash;
			delete _orderQueues[oid];
			if (orderHash) {
				for each (var order:EventOrder in orderHash) {
					order.dispose();
					_length = _length - 1;
				}
				orderHash.dispose();
			}
		}
		
		override public function dispose():void
		{
			for (var key:String in _orderQueues) {
				disposeGroupOrders(key);
			}
			_orderQueues = null;
			_instance = null;
			super.dispose();
		}

	}
}
