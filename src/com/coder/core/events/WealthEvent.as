package com.coder.core.events
{
	import flash.events.Event;

	public class WealthEvent extends Event
	{
		public static const WEALTH_COMPLETE:String = "WEALTH_COMPLETE";
		
		public static const WEALTH_ERROR:String = "WEALTH_ERROR";
		
		public static const WEALTH_GROUP_COMPLETE:String = "WEALTH_GROUP_COMPLETE";

		public var path:String;
		public var wealth_id:String;
		public var wealthGroup_id:String;

		public function WealthEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
	}
}
