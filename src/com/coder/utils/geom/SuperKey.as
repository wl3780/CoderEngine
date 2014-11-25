package com.coder.utils.geom
{
	import flash.display.Stage;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.KeyboardEvent;
	import flash.utils.getTimer;

	public class SuperKey extends EventDispatcher
	{
		public static const SUPER:String = "SAIMAN";
		public static const DEBUG:String = "DEBUG";
		public static const HELLP:String = "HELLP";
		public static const GM:String = "GM";
		public static const KEY:String = "KEY";

		private static var _instance:SuperKey;

		private var keyArray:Array;
		private var stage:Stage;
		private var time:int = 0;
		private var inputMode:Boolean;
		private var inputTime:int;

		public function SuperKey()
		{
			super();
			keyArray = [];
		}
		
		public static function getInstance():SuperKey
		{
			return _instance ||= new SuperKey();
		}

		public function setUp(stage:Stage):void
		{
			this.stage = stage;
			this.stage.addEventListener(KeyboardEvent.KEY_DOWN, keydownFunc);
			this.stage.addEventListener(KeyboardEvent.KEY_UP, keyupFunc);
		}
		
		private function keydownFunc(evt:KeyboardEvent):void
		{
			this.dispatchEvent(evt);
			if (inputMode) {
				if ((getTimer() - inputTime) > 10000) {
					inputMode = false;
					keyArray.length = 0;
					return;
				}
				if (evt.shiftKey && evt.keyCode == 16) {
					keyArray.length = 0;
				}
				if ((getTimer() - time) < 1000 || time == 0) {
					time = getTimer();
					keyArray.push(String.fromCharCode(evt.keyCode));
				} else {
					time = 0;
					keyArray.length = 0;
					keyArray.push(String.fromCharCode(evt.keyCode));
				}
			}
			if (evt.shiftKey && String.fromCharCode(evt.keyCode) == "¿") {
				this.dispatchEvent(new Event(KEY));
				this.inputMode = true;
				this.inputTime = getTimer();
				this.keyArray.length = 0;
			}
			
			var input:String = keyArray.join("");
			if (input == SUPER) {
				this.dispatchEvent(new Event(SUPER));
			} else if (input == DEBUG) {
				this.dispatchEvent(new Event(DEBUG));
			} else if (input == HELLP) {
				this.dispatchEvent(new Event(HELLP));
			} else if (input == GM) {
				this.dispatchEvent(new Event(GM));
			}
			
			this.stage.removeEventListener(KeyboardEvent.KEY_DOWN, keydownFunc);
			this.stage.removeEventListener(KeyboardEvent.KEY_UP, keyupFunc);
			this.stage.addEventListener(KeyboardEvent.KEY_DOWN, keydownFunc);
			this.stage.addEventListener(KeyboardEvent.KEY_UP, keyupFunc);
		}
		
		private function keyupFunc(e:KeyboardEvent):void
		{
			this.dispatchEvent(e);
		}

	}
}
