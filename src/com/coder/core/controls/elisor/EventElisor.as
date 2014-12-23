package com.coder.core.controls.elisor
{
	import com.coder.core.protos.Proto;
	import com.coder.interfaces.system.IOrder;
	import com.coder.utils.Hash;
	
	import flash.utils.Dictionary;
	
	internal final class EventElisor extends Proto
	{
		private static var _instance:EventElisor;

		private var _orderHash:Dictionary;
		private var _length:int;

		public function EventElisor()
		{
			super();
			_orderHash = new Dictionary();
		}
		
		internal static function getInstance():EventElisor
		{
			return _instance ||= new EventElisor();
		}

		public function addOrder(order:EventOrder):Boolean
		{
			if (!order || !order.type || !order.oid) {
				return false;
			}
			
			var subHash:Hash = _orderHash[order.oid] as Hash;
			if (!subHash) {
				subHash = new Hash();
				_orderHash[order.oid] = subHash;
			}
			if (!subHash.has(order.type)) {
				_length ++;
			}
			subHash.put(order.type, order, true);
			return true;
		}
		
		public function removeEventOrder(oid:String, listenerType:String):void
		{
			if (!listenerType || !oid) {
				return;
			}
			
			var subHash:Hash = _orderHash[oid] as Hash;
			if (subHash) {
				var order:EventOrder = subHash.remove(listenerType) as EventOrder;
				if (order) {
					_length --;
					order.dispose();
				}
			}
		}
		
		public function hasEventOrder(oid:String, listenerType:String):Boolean
		{
			if (!listenerType || !oid) {
				return false;
			}
			
			var subHash:Hash = _orderHash[oid] as Hash;
			if (subHash) {
				return subHash.has(listenerType);
			}
			return false;
		}
		
		public function takeOrder(oid:String, listenerType:String):EventOrder
		{
			if (!listenerType || !oid) {
				return null;
			}
			
			var subHash:Hash = _orderHash[oid] as Hash;
			if (subHash) {
				return subHash.take(listenerType) as EventOrder;
			}
			return null;
		}
		
		public function hasGroup(oid:String):Boolean
		{
			var subHash:Hash = _orderHash[oid];
			if (subHash) {
				return subHash.length > 0;
			}
			return false;
		}
		
		public function takeGroupOrder(oid:String):Vector.<IOrder>
		{
			var result:Vector.<IOrder> = new Vector.<IOrder>();
			var subHash:Hash = _orderHash[oid] as Hash;
			if (subHash) {
				for each (var order:EventOrder in subHash) {
					result.push(order);
				}
			}
			return result;
		}
		
		public function disposeGroupOrders(oid:String):void
		{
			var suhHash:Hash = _orderHash[oid] as Hash;
			delete _orderHash[oid];
			if (suhHash) {
				for each (var order:EventOrder in suhHash) {
					order.dispose();
					_length --;
				}
				suhHash.dispose();
			}
		}
		
		override public function dispose():void
		{
			for (var key:String in _orderHash) {
				disposeGroupOrders(key);
			}
			_orderHash = null;
			_instance = null;
			super.dispose();
		}

	}
}
