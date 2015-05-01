package com.coder.utils
{
	import flash.display.Stage;
	import flash.events.Event;
	import flash.utils.getTimer;

	public final class FPSUtils
	{
		private static const maxCount:int = 10;

		private static var _stage:Stage;
		private static var fpsTime:int;
		private static var count:int;
		private static var _fps:int = 30;
		private static var _lost_fps:int = 0;

		public static function get fps():int
		{
			return _fps;
		}
		
		public static function get lost_fps():int
		{
			return _lost_fps;
		}
		
		public static function setup(s:Stage):void
		{
			_fps = Math.round(s.frameRate);
			s.addEventListener(Event.ENTER_FRAME, onEnterFrame);
			_stage = s;
			fpsTime = getTimer();
			count = 0;
		}
		
		private static function onEnterFrame(event:Event):void
		{
			count = count + 1;
			if (count >= maxCount) {
				_fps = Math.round(1000 * maxCount / (getTimer() - fpsTime));
				var temp:int = _stage.frameRate - _fps;
				_lost_fps = (temp > 0) ? temp : 0;
				count = 0;
				fpsTime = getTimer();
			}
		}
	}
}
