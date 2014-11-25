package com.coder.core.events
{
	import flash.events.ProgressEvent;

	public class WealthProgressEvent extends ProgressEvent
	{
		public static const PROGRESS:String = "PROGRESS";

		public var path:String;
		public var proto:Object;
		public var wealth_id:String;

		public function WealthProgressEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false, bytesLoaded:Number=0, bytesTotal:Number=0)
		{
			super(type, bubbles, cancelable, bytesLoaded, bytesTotal);
		}
	}
}
