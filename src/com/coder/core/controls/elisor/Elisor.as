package com.coder.core.controls.elisor
{
	import com.coder.core.protos.Proto;
	import com.coder.interfaces.dock.IProto;
	import com.coder.interfaces.system.IOrderDispatcher;
	
	import flash.display.DisplayObject;
	import flash.display.Stage;

	public final class Elisor extends Proto
	{
		private static var _instance:Elisor;

		public static function getInstance():Elisor
		{
			return _instance ||= new Elisor();
		}

		public function setup(stage:Stage):void
		{
			FrameElisor.getInstance().setup(stage);
		}
		
		// ---------------------------------------------
		public function addFrameOrder(target:IProto, heartBeatHandler:Function, delay:int=0, isOnStageHandler:Boolean=false):void
		{
			var order:FrameOrder = FrameOrder.createFrameOrder();
			order.value = delay;
			if (delay == 0) {
				order.setup(OrderMode.ENTER_FRAME_ORDER, target.id, heartBeatHandler);
			} else {
				if (isOnStageHandler) {
					order.display = target as DisplayObject;
				}
				order.setup(OrderMode.DELAY_FRAME_ORDER, target.id, heartBeatHandler);
			}
			FrameElisor.getInstance().addFrameOrder(order);
		}
		
		public function hasFrameOrder(heartBeatHandler:Function):Boolean
		{
			return FrameElisor.getInstance().hasFrameOrder(heartBeatHandler);
		}
		
		public function setInterval(target:IProto, heartBeatHandler:Function, delay:int, ... args):void
		{
			var order:FrameOrder = FrameOrder.createFrameOrder();
			order.value = delay;
			order.setup(OrderMode.INTERVAL_FRAME_ORDER, target.id, heartBeatHandler);
			FrameElisor.getInstance().addFrameOrder(order);
		}
		
		public function setTimeOut(target:IProto, closureHandler:Function, delay:int, ... args):String
		{
			var order:FrameOrder = FrameOrder.createFrameOrder();
			order.value = delay;
			order.setup(OrderMode.DELAY_FRAME_ORDER, target.id, closureHandler);
			order.proto = args;
			FrameElisor.getInstance().addFrameOrder(order);
			return order.id;
		}
		
		public function removeFrameOrder(heartBeatHandler:Function):void
		{
			FrameElisor.getInstance().removeFrameOrder(heartBeatHandler);
		}
		
		public function stopFrameOrder(heartBeatHandler:Function):void
		{
			FrameElisor.getInstance().stopFrameOrder(heartBeatHandler);
		}
		
		public function stopTargetFrameOrder(target:IProto):void
		{
			FrameElisor.getInstance().stopFrameGroup(target.id);
		}
		
		public function removeTotalFrameOrder(target:IProto):void
		{
			FrameElisor.getInstance().removeFrameGroup(target.id);
		}
		
		// ---------------------------------------------
		public function hasEventOrder(oid:String, listenerType:String):Boolean
		{
			return EventElisor.getInstance().hasEventOrder(oid, listenerType);
		}
		
		public function addEventOrder(tar:IOrderDispatcher, type:String, listener:Function):void
		{
			var order:EventOrder = EventOrder.createEventOrder();
			order.register(tar.id, tar.className, type, listener);
			EventElisor.getInstance().addOrder(order);
		}
		
		public function removeEventOrder(oid:String, listenerType:String):void
		{
			EventElisor.getInstance().removeEventOrder(oid, listenerType);
		}
		
		public function removeTotalEventOrder(target:IProto):void
		{
			EventElisor.getInstance().disposeGroupOrders(target.id);
		}
		
		public function removeTotlaOrder(target:IProto):void
		{
			this.removeTotalEventOrder(target);
			this.removeTotalFrameOrder(target);
		}

	}
}
