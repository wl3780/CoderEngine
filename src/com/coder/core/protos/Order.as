package com.coder.core.protos
{
	import com.coder.interfaces.system.IOrder;

	public class Order extends Proto implements IOrder
	{
		protected var _executedHandler_:Function;
		protected var _applyHandler_:Function;
		protected var _status_:String;

		public function Order()
		{
			super();
		}
		
		public function execute():void
		{
			if (_applyHandler_ != null) {
				_applyHandler_();
			}
		}
		
		public function get executedHandler():Function
		{
			return _executedHandler_;
		}
		
		public function get applyHandler():Function
		{
			return _applyHandler_;
		}
		
		override public function dispose():void
		{
			super.dispose();
			_executedHandler_ = null;
			_applyHandler_ = null;
			_status_ = null;
		}
	}
}
