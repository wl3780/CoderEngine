package com.coder.utils
{
	import com.coder.engine.Engine;
	
	import flash.display.Stage;
	import flash.events.Event;
	import flash.utils.getTimer;

	/**
	 * 游戏计时器
	 * 1、数组（特别是Vector）的访问速度需要比对象属性访问快，多以用一堆vector代替抽象成类
	 * 2、倒序的for循环要比while效率要好，并且移除时更安全
	 * 3、回调错开，不要在同一帧完成（1s回调时可以选择950ms）
	 * 4、无需补帧处理，只会增加负担；所以时间是不准确的，但可以通过其他方法校正
	 */	
	public class GameTimer
	{
		private static var _instance:GameTimer;
		
		private var loopCallOrder:Vector.<Function>;
		private var loopParamsOrder:Vector.<Array>;
		private var loopDelayOrder:Vector.<int>;
		private var loopFrameOrder:Vector.<int>;
		
		private var onceCallOrder:Vector.<Function>;
		private var onceParamsOrder:Vector.<Array>;
		private var onceFrameOrder:Vector.<int>;
		
		private var _frameIndex:int;
		private var _sysTimeStamp:Number = 0;
		private var _sysTimeRed:int;
		
		public function GameTimer()
		{
			loopCallOrder = new Vector.<Function>();
			loopParamsOrder = new Vector.<Array>();
			loopDelayOrder = new Vector.<int>();
			loopFrameOrder = new Vector.<int>();
			
			onceCallOrder = new Vector.<Function>();
			onceParamsOrder = new Vector.<Array>();
			onceFrameOrder = new Vector.<int>();
		}

		public static function getInstance():GameTimer
		{
			return _instance ||= new GameTimer();
		}
		
		public function setup(stage:Stage):void
		{
			stage.addEventListener(Event.ENTER_FRAME, onEnterFrame);
		}
		
		public function addLoopTime(delay:int, method:Function, args:Array=null):void
		{
			var frame:int = Math.ceil(delay * Engine.frameRate / 1000);
			addLoopFrame(frame, method, args);
		}
		
		public function addOnceTime(delay:int, method:Function, args:Array=null):void
		{
			var frame:int = Math.ceil(delay * Engine.frameRate / 1000);
			addOnceFrame(frame, method, args);
		}
		
		public function addLoopFrame(frame:int, method:Function, args:Array=null):void
		{
			if (frame) {
				loopDelayOrder.push(frame);
				loopCallOrder.push(method);
				loopParamsOrder.push(args);
				loopFrameOrder.push(_frameIndex + frame);
			}
		}
		
		public function addOnceFrame(frame:int, method:Function, args:Array=null):void
		{
			if (frame) {
				onceCallOrder.push(method);
				onceParamsOrder.push(args);
				onceFrameOrder.push(_frameIndex + frame);
			}
		}
		
		public function clearOrder(method:Function):void
		{
			var index:int = loopCallOrder.indexOf(method);
			if (index != -1) {
				loopDelayOrder.splice(index, 1);
				loopCallOrder.splice(index, 1);
				loopParamsOrder.splice(index, 1);
				loopFrameOrder.splice(index, 1);
			}
			
			index = onceCallOrder.indexOf(method);
			if (index != -1) {
				onceCallOrder.splice(index, 1);
				onceParamsOrder.splice(index, 1);
				onceFrameOrder.splice(index, 1);
			}
		}
		
		/**
		 * 计数处理函数
		 */
		protected function onEnterFrame(evt:Event):void
		{
			_frameIndex ++;
			var method:Function;
			var params:Array;
			for (var index:int = loopCallOrder.length - 1; index >= 0; index--) {
				if (_frameIndex >= loopFrameOrder[index]) {
					method = loopCallOrder[index];
					params = loopParamsOrder[index];
					method.apply(null, params);
					loopFrameOrder[index] += loopDelayOrder[index];
				}
			}
			
			for (index = onceCallOrder.length - 1; index >= 0; index--) {
				if (_frameIndex >= onceFrameOrder[index]) {
					method = onceCallOrder[index];
					params = onceParamsOrder[index];
					clearOrder(method);
					method.apply(null, params);
				}
			}
		}

		/**
		 * 当前系统时间（单位：ms） 
		 */
		public function get sysTime():Number
		{
			return _sysTimeStamp + getTimer() - _sysTimeRed;
		}
		public function set sysTime(value:Number):void
		{
			_sysTimeStamp = value;
			_sysTimeRed = getTimer();
		}

	}
}