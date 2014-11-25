package com.coder.core.controls.elisor
{
	import com.coder.utils.FPSUtils;
	
	import flash.display.DisplayObject;
	import flash.display.Stage;
	import flash.events.Event;
	import flash.utils.Dictionary;

	public class HeartbeatFactory
	{
		private static var _instance_:HeartbeatFactory;

		private var hash:Dictionary;
		private var unstageFrameOrder:Vector.<Function>;
		private var stageFrameOrder:Vector.<Function>;
		private var stageFrameOrderTarget:Vector.<DisplayObject>;
		private var heartbeatIndex:int = 0;
		private var heartbeatSize:int;
		private var startIndex:int;
		private var endIndex:int;

		public function HeartbeatFactory()
		{
			super();
			hash = new Dictionary();
			unstageFrameOrder = new Vector.<Function>();
			stageFrameOrder = new Vector.<Function>();
			stageFrameOrderTarget = new Vector.<DisplayObject>();
		}
		
		public static function getInstance():HeartbeatFactory
		{
			return _instance_ ||= new HeartbeatFactory();
		}

		public function setup(stage:Stage):void
		{
			stage.addEventListener(Event.ENTER_FRAME, onEnterFrame);
		}
		
		protected function onEnterFrame(event:Event):void
		{
			var index:int;
			var len:int;
			var order:Function = null;
			if (unstageFrameOrder.length) {
				FPSUtils.fps < 3 ? heartbeatSize = 2 : heartbeatSize = 6;
				heartbeatIndex = Math.ceil(unstageFrameOrder.length / heartbeatSize);
				for (index = 0, len = unstageFrameOrder.length - heartbeatIndex; index < len; index++) {
					if (startIndex >= unstageFrameOrder.length) {
						startIndex = 0;
					}
					order = unstageFrameOrder[startIndex];
					order.apply();
					startIndex ++;
				}
			}
			
			var dis:DisplayObject = null;
			for (index = 0, len = stageFrameOrder.length; index < len; index++) {
				dis = stageFrameOrderTarget[index];
				if (dis.stage) {
					order = stageFrameOrder[index];
					order.apply();
				}
			}
		}
		
		public function addFrameOrder(listener:Function, onStageTarget:DisplayObject=null):void
		{
			if (hash[listener] == null) {
				hash[listener] = {onStageTarget:onStageTarget}
				if (onStageTarget) {
					stageFrameOrder.push(listener);
					stageFrameOrderTarget.push(onStageTarget);
				} else {
					unstageFrameOrder.push(listener);
				}
			}
		}
		
		public function removeFrameOrder(listener:Function):void
		{
			if (hash[listener] != null) {
				var dis:DisplayObject = hash[listener].onStageTarget as DisplayObject;
				delete hash[listener];
				
				var index:int;
				if (!dis) {
					index = unstageFrameOrder.indexOf(listener);
					if (index != -1) {
						unstageFrameOrder.splice(index, 1);
					}
				} else {
					index = stageFrameOrder.indexOf(listener);
					if (index != -1) {
						stageFrameOrder.splice(index, 1);
						stageFrameOrderTarget.splice(index, 1);
					}
				}
			}
		}

	}
}
