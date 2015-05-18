package com.coder.core.controls.dock
{
	import com.coder.core.protos.Proto;
	import com.coder.interfaces.dock.IMessage;
	import com.coder.interfaces.dock.IProxy;
	import com.coder.interfaces.dock.ISocket_tos;

	public class SubProxy extends Proto implements IProxy
	{
		private var _lock:Boolean;

		public function SubProxy()
		{
			super();
		}
		
		public function send(message:IMessage):void
		{
			MessageDock.getInstance().send(message);
		}
		
		/**
		 * 是否需要注册的依据
		 * @return 
		 */		
		public function checkFromat():Boolean
		{
			return true;
		}
		
		public function subHandle(message:IMessage):void
		{
		}
		
		public function get lock():Boolean
		{
			return _lock;
		}
		public function set lock(value:Boolean):void
		{
			_lock = value;
		}
		
		public function sendToModule(actionOrder:String, geter:String, data:Object=null):void
		{
			Message.sendToModule(actionOrder, geter, data, this.oid);
		}
		
		public function sendToModules(actionOrder:String, gaters:Vector.<String>, data:Object=null):void
		{
			Message.sendToModules(actionOrder, gaters, data, this.oid);
		}
		
		public function sendToTotalModule(actionOrder:String, data:Object=null):void
		{
			Message.sendToTotalModule(actionOrder, data, this.oid);
		}
		
		public function sendToService(data:ISocket_tos, actionOrder:String=null):void
		{
			Message.sendToService(data, actionOrder, this.oid);
		}
		
		public function sendToSubs(actionOrder:String, data:Object=null):void
		{
			Message.sendToSubs(actionOrder, data, this.oid);
		}

	}
}
