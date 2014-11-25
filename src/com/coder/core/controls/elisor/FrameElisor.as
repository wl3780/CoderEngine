package com.coder.core.controls.elisor
{
	import com.coder.core.protos.Proto;
	import com.coder.engine.Asswc;
	import com.coder.utils.FPSUtils;
	import com.coder.utils.Hash;
	
	import flash.display.DisplayObject;
	import flash.display.Stage;
	import flash.events.Event;
	import flash.utils.getTimer;

	internal final class FrameElisor extends Proto
	{
		private static var _instance_:FrameElisor;

		private var heartbeatSize:int = 6;
		private var hash:Hash;
		
		private var enterFrameOrder:Vector.<Function>;
		private var enterFrameHeartbeatState:Vector.<Boolean>;
		private var enterFrameHeartbeatIndex:int;
		
		private var intervalFrameOrder:Vector.<Function>;
		private var intervalQueue:Vector.<int>;
		private var intervalCountQueue:Vector.<int>;
		private var intervalHeartbeatState:Vector.<Boolean>;
		private var intervalHeartbeatIndex:int;
		
		private var onStageFrameOrder:Vector.<Function>;
		private var onStageDisplays:Vector.<DisplayObject>;
		private var onStageHeartbeatState:Vector.<Boolean>;
		private var onStageHeartbeatIndex:int;
		
		private var delayFrameOrder:Vector.<Function>;
		private var delayFrameQueue:Vector.<int>;
		private var delayHeartbeatState:Vector.<Boolean>;
		private var delayHeartbeatIndex:int;
		
		private var _stop:Boolean;

		public function FrameElisor()
		{
			super();
			hash = new Hash();
			hash.oid = this.id;
			
			enterFrameOrder = new Vector.<Function>();
			enterFrameHeartbeatState = new Vector.<Boolean>();
			
			onStageFrameOrder = new Vector.<Function>();
			onStageDisplays = new Vector.<DisplayObject>();
			onStageHeartbeatState = new Vector.<Boolean>();
			
			intervalFrameOrder = new Vector.<Function>();
			intervalQueue = new Vector.<int>();
			intervalCountQueue = new Vector.<int>();
			intervalHeartbeatState = new Vector.<Boolean>();
			
			delayFrameOrder = new Vector.<Function>();
			delayFrameQueue = new Vector.<int>();
			delayHeartbeatState = new Vector.<Boolean>();
		}
		
		internal static function getInstance():FrameElisor
		{
			return _instance_ ||= new FrameElisor();
		}

		internal function get stop():Boolean
		{
			return _stop;
		}
		internal function set stop(value:Boolean):void
		{
			_stop = value;
		}
		
		internal function setup(stage:Stage):void
		{
			stage.addEventListener(Event.ENTER_FRAME, onEnterFrame);
		}
		
		private function onEnterFrame(event:Event):void
		{
			if (_stop || !Asswc.enabled) {
				return;
			}
			
			FPSUtils.fps < 3 ? heartbeatSize = 2 : heartbeatSize = 6;
			onEnterFrameHandler();
			onIntervalHandler();
			onDelayHandler();
		}
		
		private function onEnterFrameHandler():void
		{
			var orderNum:int = enterFrameOrder.length;
			if (orderNum <= 0) {
				return;
			}
			
			var applyHandler:Function = null;
			var state:Boolean;
			var orderIndex:int = Math.ceil(orderNum / heartbeatSize);
			var tmp:int = orderNum - orderIndex;
			while (tmp >= 0 && !_stop) {
				if (enterFrameHeartbeatIndex >= enterFrameOrder.length) {
					enterFrameHeartbeatIndex = 0;
				}
				
				applyHandler = enterFrameOrder[enterFrameHeartbeatIndex];
				state = enterFrameHeartbeatState[enterFrameHeartbeatIndex];
				if (!state && applyHandler != null) {
					applyHandler.apply();
				}
				enterFrameHeartbeatIndex ++;
				tmp--;
			}
		}
		
		private function onIntervalHandler():void
		{
			var orderNum:int = intervalFrameOrder.length;
			if (orderNum <= 0) {
				return;
			}
			
			var applyHandler:Function = null;
			var interval:int;
			var time:int;
			var state:Boolean;
			var order:FrameOrder = null;
			var orderIndex:int = Math.ceil(orderNum / heartbeatSize);
			var tmp:int = orderNum - orderIndex;
			while (tmp >= 0 && !_stop) {
				if (intervalHeartbeatIndex >= intervalFrameOrder.length) {
					intervalHeartbeatIndex = 0;
				}
				applyHandler = intervalFrameOrder[intervalHeartbeatIndex];
				time = intervalCountQueue[intervalHeartbeatIndex];
				interval = intervalQueue[intervalHeartbeatIndex];
				state = intervalHeartbeatState[intervalHeartbeatIndex];
				if (!state && applyHandler != null && (getTimer() - time) >= interval) {
					order = hash.take(applyHandler) as FrameOrder;
					if (order.proto) {
						applyHandler.apply(null, [order.proto]);
					} else {
						applyHandler.apply();
					}
					intervalCountQueue[intervalHeartbeatIndex] = getTimer();
				}
				intervalHeartbeatIndex ++;
				tmp--;
			}
		}
		
		private function onDelayHandler():void
		{
			var orderNum:int = delayFrameOrder.length;
			if (orderNum <= 0) {
				return;
			}
			
			var applyHandler:Function = null;
			var delay:int;
			var state:Boolean;
			var order:FrameOrder = null;
			var index:int;
			var orderIndex:int = Math.ceil(orderNum / heartbeatSize);
			var tmp:int = orderNum - orderIndex;
			while (tmp >= 0 && !_stop) {
				if (delayHeartbeatIndex >= delayFrameOrder.length) {
					delayHeartbeatIndex = 0;
				}
				applyHandler = delayFrameOrder[delayHeartbeatIndex];
				delay = delayFrameQueue[delayHeartbeatIndex];
				state = delayHeartbeatState[delayHeartbeatIndex];
				if (!state && applyHandler != null && (getTimer() - delay) >= 0) {
					order = hash.remove(applyHandler) as FrameOrder;
					if (order.proto) {
						applyHandler.apply(null, [order.proto]);
					} else {
						applyHandler.apply();
					}
					index = delayFrameOrder.indexOf(applyHandler);
					if (index != -1) {
						delayFrameOrder.splice(index, 1);
						delayFrameQueue.splice(index, 1);
						delayHeartbeatState.splice(index, 1);
						if (index >= delayHeartbeatIndex) {
							delayHeartbeatIndex = (delayHeartbeatIndex - 1);
						}
						if (delayHeartbeatIndex < 0) {
							delayHeartbeatIndex = 0;
						}
					}
					order.dispose();
					delayHeartbeatIndex --;
				}
				delayHeartbeatIndex ++;
				tmp --;
			}
		}
		
		internal function hasFrameOrder(heartBeatHandler:Function):Boolean
		{
			return hash.has(heartBeatHandler);
		}
		
		internal function takeFrameOrder(heartBeatHandler:Function):FrameOrder
		{
			return hash.take(heartBeatHandler) as FrameOrder;
		}
		
		internal function addFrameOrder(order:FrameOrder):void
		{
			var applyHandler:Function = order.applyHandler;
			if (!hash.has(applyHandler)) {
				this.stop = true;
				hash.put(applyHandler, order);
				if (OrderMode.ENTER_FRAME_ORDER == order.orderMode) {
					if (order.display) {
						onStageFrameOrder.push(applyHandler);
						onStageDisplays.push(order.display);
						onStageHeartbeatState.push(order.stop);
					} else {
						enterFrameOrder.push(applyHandler);
						enterFrameHeartbeatState.push(order.stop);
					}
				} else if (OrderMode.INTERVAL_FRAME_ORDER == order.orderMode) {
					intervalFrameOrder.push(applyHandler);
					intervalQueue.push(order.value);
					intervalCountQueue.push(getTimer() + order.value);
					intervalHeartbeatState.push(order.stop);
				} else if (OrderMode.DELAY_FRAME_ORDER == order.orderMode) {
					delayFrameOrder.push(applyHandler);
					delayFrameQueue.push(getTimer() + order.value);
					delayHeartbeatState.push(order.stop);
				}
				this.stop = false;
			}
		}
		
		internal function removeFrameOrder(applyHandler:Function):void
		{
			var order:FrameOrder = hash.remove(applyHandler) as FrameOrder;
			if (!order) {
				return;
			}
			
			var index:int;
			this.stop = true;
			if (OrderMode.ENTER_FRAME_ORDER == order.orderMode) {
				if (order.display) {
					index = onStageFrameOrder.indexOf(applyHandler);
					if (index != -1) {
						onStageDisplays.splice(index, 1);
						onStageFrameOrder.splice(index, 1);
						onStageHeartbeatState.splice(index, 1);
						if (index >= onStageHeartbeatIndex) {
							onStageHeartbeatIndex = onStageHeartbeatIndex - 1;
						}
						if (onStageHeartbeatIndex < 0) {
							onStageHeartbeatIndex = 0;
						}
					}
				} else {
					index = enterFrameOrder.indexOf(applyHandler);
					if (index != -1) {
						enterFrameOrder.splice(index, 1);
						enterFrameHeartbeatState.splice(index, 1);
						if (index >= enterFrameHeartbeatIndex) {
							enterFrameHeartbeatIndex = enterFrameHeartbeatIndex - 1;
						}
						if (enterFrameHeartbeatIndex < 0) {
							enterFrameHeartbeatIndex = 0;
						}
					}
				}
			} else if (OrderMode.INTERVAL_FRAME_ORDER == order.orderMode) {
				index = intervalFrameOrder.indexOf(applyHandler);
				if (index != -1) {
					intervalFrameOrder.splice(index, 1);
					intervalQueue.splice(index, 1);
					intervalCountQueue.splice(index, 1);
					intervalHeartbeatState.splice(index, 1);
					if (index >= intervalHeartbeatIndex) {
						intervalHeartbeatIndex = intervalHeartbeatIndex - 1;
					}
					if (intervalHeartbeatIndex < 0) {
						intervalHeartbeatIndex = 0;
					}
				}
			} else if (OrderMode.DELAY_FRAME_ORDER == order.orderMode) {
				index = delayFrameOrder.indexOf(applyHandler);
				if (index != -1) {
					delayFrameOrder.splice(index, 1);
					delayFrameQueue.splice(index, 1);
					delayHeartbeatState.splice(index, 1);
					if (index >= delayHeartbeatIndex) {
						delayHeartbeatIndex = delayHeartbeatIndex - 1;
					}
					if (delayHeartbeatIndex < 0) {
						delayHeartbeatIndex = 0;
					}
				}
			}
			order.dispose();
			this.stop = false;
		}
		
		internal function startFrameOrder(applyHandler:Function):void
		{
			var order:FrameOrder = hash.take(applyHandler) as FrameOrder;
			if (!order) {
				return;
			}
			
			var index:int;
			order.stop = false;
			if (OrderMode.ENTER_FRAME_ORDER == order.orderMode) {
				if (order.display) {
					index = onStageFrameOrder.indexOf(applyHandler);
					if (index != -1) {
						onStageHeartbeatState[index] = false;
					}
				} else {
					index = enterFrameOrder.indexOf(applyHandler);
					if (index != -1) {
						enterFrameHeartbeatState[index] = false;
					}
				}
			} else if (OrderMode.INTERVAL_FRAME_ORDER == order.orderMode) {
				index = intervalFrameOrder.indexOf(applyHandler);
				if (index != -1) {
					intervalHeartbeatState[index] = false;
				}
			} else if (OrderMode.DELAY_FRAME_ORDER == order.orderMode) {
				index = delayFrameOrder.indexOf(applyHandler);
				if (index != -1) {
					delayHeartbeatState[index] = false;
				}
			}
		}
		
		internal function stopFrameOrder(applyHandler:Function):void
		{
			var order:FrameOrder = hash.take(applyHandler) as FrameOrder;
			if (!order) {
				return;
			}
			
			var index:int;
			order.stop = true;
			if (OrderMode.ENTER_FRAME_ORDER === order.orderMode) {
				if (order.display) {
					index = onStageFrameOrder.indexOf(applyHandler);
					if (index != -1) {
						onStageHeartbeatState[index] = true;
					}
				} else {
					index = enterFrameOrder.indexOf(applyHandler);
					if (index != -1) {
						enterFrameHeartbeatState[index] = true;
					}
				}
			} else if (OrderMode.INTERVAL_FRAME_ORDER == order.orderMode) {
				index = intervalFrameOrder.indexOf(applyHandler);
				if (index != -1) {
					intervalHeartbeatState[index] = true;
				}
			} else if (OrderMode.DELAY_FRAME_ORDER == order.orderMode) {
				index = delayFrameOrder.indexOf(applyHandler);
				if (index != -1) {
					delayHeartbeatState[index] = true;
				}
			}
		}
		
		internal function stopFrameGroup(group_id:String):void
		{
			if (!group_id) {
				return;
			}
			for each (var order:FrameOrder in hash) {
				if (order.oid == group_id) {
					this.stopFrameGroup(group_id);
				}
			}
		}
		
		internal function startFrameGroup(group_id:String):void
		{
			if (!group_id) {
				return;
			}
			for each (var order:FrameOrder in hash) {
				if (order.oid == group_id) {
					this.startFrameGroup(group_id);
				}
			}
		}
		
		internal function removeFrameGroup(group_id:String):void
		{
			if (!group_id) {
				return;
			}
			for each (var order:FrameOrder in hash) {
				if (order.oid == group_id) {
					this.removeFrameGroup(group_id);
				}
			}
		}
		
		override public function dispose():void
		{
			super.dispose();
		}

	}
}
