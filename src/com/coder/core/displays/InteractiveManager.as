package com.coder.core.displays
{
	import com.coder.core.controls.elisor.Elisor;
	import com.coder.core.protos.Proto;
	import com.coder.interfaces.display.IInteractiveObject;

	public class InteractiveManager
	{
		private static var objectQueue:Vector.<IInteractiveObject> = new Vector.<IInteractiveObject>();

		private static var isReady:Boolean;

		public static function addObject(value:IInteractiveObject):void
		{
			if (value) {
				if (objectQueue.indexOf(value) == -1) {
					objectQueue.push(value);
				}
				setup();
			}
		}
		
		public static function removeObject(value:IInteractiveObject):void
		{
			if (value) {
				var index:int = objectQueue.indexOf(value);
				if (index != -1) {
					objectQueue.splice(index, 1);
				}
			}
		}
		
		private static function setup():void
		{
			if (!isReady) {
				isReady = true;
				Elisor.getInstance().addFrameOrder(new Proto(), loop);
			}
		}
		
		private static function loop():void
		{
			for each (var item:IInteractiveObject in objectQueue) {
				item.loopMove();
			}
		}
	}
} 
