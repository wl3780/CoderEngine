package com.coder.core.displays.items
{
	import com.coder.core.controls.elisor.HeartbeatFactory;
	import com.coder.core.displays.DisplayShape;
	import com.coder.core.displays.world.Scene;
	import com.coder.engine.Engine;
	import com.coder.utils.FPSUtils;
	import com.coder.utils.Hash;
	
	import flash.display.BitmapData;
	import flash.geom.Matrix;
	import flash.geom.Rectangle;
	import flash.utils.Dictionary;
	import flash.utils.getTimer;

	public class ImageEffect extends DisplayShape
	{
		private static var inited:Boolean;
		private static var hash:Hash = new Hash();
		private static var mat:Matrix = new Matrix();
		private static var stageRect:Rectangle = new Rectangle();

		public var pause:Boolean = false;
		public var replay:int = -1;
		public var optimization:Boolean = true;
		
		private var bitmapData:BitmapData;
		private var _stop:Boolean;
		private var totalFrame:int;
		private var currFrame:int;
		private var _size:int = 34;
		private var w:int;
		private var h:int;
		private var _dur:int = 90;
		private var delayTime:int;
		private var r:int;
		private var playEndFunc:Function;

		public function ImageEffect()
		{
			hash.put(this.id, this);
			this.r = (Math.random() * 100) >> 0;
		}
		
		private static function enterFrameFunc():void
		{
			for each (var eff:ImageEffect in hash) {
				if (!eff.stop) {
					eff.onReander();
				}
			}
		}
		
		public static function createImageEffect(bitmapData:BitmapData, play:Boolean=true):ImageEffect
		{
			var result:ImageEffect = new ImageEffect();
			result.setUp(bitmapData);
			if (play) {
				result.play(0);
			}
			return result;
		}

		public function get dur():int
		{
			return _dur;
		}
		public function set dur(value:int):void
		{
			_dur = value + (Math.random() * 50 >> 0);
			onReander();
		}
		
		public function set size(value:int):void
		{
			_size = value;
			onReander();
		}
		public function get size():int
		{
			return _size;
		}
		
		public function get stop():Boolean
		{
			return _stop;
		}
		public function set stop(value:Boolean):void
		{
			_stop = value;
		}
		
		public function play(frame:int=0, playEnd:Function=null, replayValue:int=-1):void
		{
			if (!inited) {
				inited = true;
				HeartbeatFactory.getInstance().addFrameOrder(enterFrameFunc);
			}
			this.replay = replayValue;
			this.playEndFunc = playEnd;
			this.currFrame = frame;
			this.stop = false;
		}
		
		public function onReander():void
		{
			var pass:int;
			if (optimization) {
				if (Scene.scene && Scene.scene.mainChar && Scene.scene.mainChar.isRuning) {
					FPSUtils.fps<5 ? pass = 600 : pass = 400;
				} else {
					FPSUtils.fps<5 ? pass = 500 : pass = 0;
				}
			}
			stageRect.width = Engine.stage.stageWidth;
			stageRect.height = Engine.stage.stageHeight;
			if ((getTimer() - delayTime) > (this.dur + r + pass)) {
				delayTime = getTimer();
				if (this.totalFrame > 0 && !_stop && this.stage) {
					if (this.currFrame >= this.totalFrame) {
						if (replay == -1) {
							this.currFrame = 0;
						} else {
							if (replay > 0) {
								replay = replay - 1;
							} else {
								hash.remove(this.id);
								bitmapData = null;
								this.replay = 0;
								this.graphics.clear();
								if (this.playEndFunc != null) {
									this.playEndFunc();
									this.playEndFunc = null;
								}
								return;
							}
						}
					}
					if (!pause && this.stage) {
						this.graphics.clear();
						mat.tx = 0;
						mat.tx = mat.tx - this.currFrame * size;
						this.graphics.beginBitmapFill(this.bitmapData, mat);
						this.graphics.drawRect(0, 0, size, bitmapData.height);
					}
					currFrame = currFrame + 1;
				}
			}
		}
		
		public function setUp(bitmapData:BitmapData):void
		{
			if (bitmapData) {
				this.bitmapData = bitmapData;
				this.totalFrame = this.bitmapData.width / size;
				onReander();
			}
		}
		
		override public function dispose():void
		{
			hash.remove(this.id);
			bitmapData = null;
			playEndFunc = null;
			this.replay = -1;
			this.graphics.clear();
			this.totalFrame = 0;
			this.currFrame = 0;
			_stop = true;
			super.dispose();
		}

	}
}
