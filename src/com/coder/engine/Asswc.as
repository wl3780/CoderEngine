package com.coder.engine
{
	import com.coder.utils.FPSUtils;
	
	import flash.display.DisplayObject;
	import flash.display.Stage;
	import flash.events.Event;
	import flash.utils.getTimer;

	public class Asswc
	{
		public static const SIGN:String = "@";
		public static var DIM:String = "【+】";
		public static var LINE:String = "_";
		public static var POOL_INDEX:int = 200;
		
		public static var enabled:Boolean = true;
		public static var sceneIntersects:Boolean;
		public static var sceneClickEnabled:Boolean = true;
		public static var compress:Boolean = false;	// 是否使用数据压缩
		
		public static var track:Function;
		
		public static const SWF_Files:Vector.<String> = new <String>["swf","tmp"];
		public static const IMG_Files:Vector.<String> = new <String>["png","jpg","jpeg","gif","jxr",""];
		public static const TEXT_Files:Vector.<String> = new <String>["text","css","as","xml","html"];

		private static var _stage_:Stage;
		private static var instance_index:int = 2147483647;
		
		private static var cheatNum:int;
		private static var cheatTime:int;
		private static var timerNum:int;
		private static var _isCheat_:Boolean = false;

		public static function setup(target:DisplayObject):void
		{
			stage = target.stage;
			FPSUtils.setup(stage);
			stage.addEventListener(Event.ENTER_FRAME, _enterFramefunc_);
		}
		
		public static function set stage(value:Stage):void
		{
			_stage_ = value;
		}
		public static function get stage():Stage
		{
			return _stage_;
		}
		
		public static function get instance_key():int
		{
			instance_index --;
			if (instance_index < 0) {
				instance_index = 2147483647;
			}
			return instance_index;
		}
		
		public static function getSoleId():String
		{
			return SIGN + Asswc.instance_key.toString(16);
		}
		
		public static function get isCheat():Boolean
		{
			return _isCheat_;
		}
		
		private static function _enterFramefunc_(event:Event):void
		{
			checkCheat();
		}
		
		/**
		 * 防加速，判断
		 */		
		private static function checkCheat():void
		{
			var now:Date = new Date();
			var clientTime:int = getTimer() - timerNum;
			var realTime:int = now.time - cheatTime;
			if (clientTime - realTime > 3) {
				cheatNum ++;
				if (cheatNum > 5) {
					_isCheat_ = true;
				}
			} else {
				cheatNum = 0;
			}
			timerNum = getTimer();
			cheatTime = now.time;
		}
	}
}
