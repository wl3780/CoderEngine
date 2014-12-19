package com.coder.core.displays.world.char
{
	import com.coder.core.controls.elisor.Elisor;
	import com.coder.core.displays.avatar.AvatarUnitDisplay;
	import com.coder.core.protos.Proto;
	import com.coder.engine.Asswc;
	
	import flash.display.Shape;
	import flash.utils.getTimer;

	public class HeadImage extends Shape
	{
		private static var elisorTar:Proto = new Proto();
		private static var elisor:Elisor;
		private static var queueHash:Vector.<HeadImage> = new Vector.<HeadImage>();
		private static var headImageHash:Array = [];

		public var dy:Number = 2;
		public var time:int;
		public var stop:Boolean = false;
		public var playEndFunc:Function;
		public var monutHeight:int;
		public var body_height:int;
		public var showType:int = 0;
		public var id:String;
		public var oid:String;
		
		private var va:Number = 0.025;
		private var startY:int;
		private var startTime:int;
		private var dx:int = 15;
		private var startSpeedY:int = 3;

		public function HeadImage()
		{
			super();
			id = Asswc.getSoleId();
			if (!elisor) {
				elisor = Elisor.getInstance();
				elisor.addFrameOrder(elisorTar, heartCeatHandler);
			}
		}
		
		private static function heartCeatHandler():void
		{
			if (queueHash.length) {
				var char:Char = null;
				var head:HeadImage = null;
				var index:int = 0;
				while (index < queueHash.length) {
					head = queueHash[index];
					char = AvatarUnitDisplay.takeUnitDisplay(head.oid) as Char;
					if (!char || char.proto == null || !char.stage) {
						queueHash.splice(index, 1);
						head.dispose();
						index--;
					} else {
						head.onPlay();
					}
					index++;
				}
			}
		}
		
		public static function createHeadImage():HeadImage
		{
			var image:HeadImage = null;
			if (headImageHash.length) {
				image = headImageHash.pop();
				image.scaleY = 1;
				image.scaleX = 1;
				with (image) {
					dy = 2;
					time = 0;
					va = 0.025;
					stop = false;
					startY = 0;
					startTime = 0;
					monutHeight = 0;
					body_height = 0;
					dx = 15;
					startSpeedY = 3;
					showType = 0;
					id = null;
					oid = null;
					alpha = 1;
					visible = true;
					x = 0;
					y = 0;
				}
				image.graphics.clear();
			} else {
				image = new HeadImage();
			}
			return image;
		}

		public function startPlay():void
		{
			queueHash.push(this);
		}
		
		public function setStartY(value:int, body_height:int, type:int=0):void
		{
			startTime = getTimer();
			startY = 0;
			dx = 8;
			alpha = 1;
			monutHeight = -Math.abs(value);
			var toY:int = value;
			this.y = toY;
			startY = toY;
			this.cacheAsBitmap = true;
			startSpeedY = 3;
			this.showType = type;
			if (showType == 0) {
				dx = 5;
				this.x = -width / 2;
			} else {
				if (showType == 5){
					toY = (y + 0);
					y = toY;
					startY = toY;
				} else {
					if (showType == 1) {
						toY = 2;
						this.scaleY = toY;
						this.scaleX = toY;
						this.y = -100;
						this.dy = 0.3;
						dx = 4;
						va = 0.0333333333333333;
					} else {
						if (showType == 2) {
							toY = 1;
							this.scaleY = toY;
							this.scaleX = toY;
							this.dy = 0.05;
							dx = 4;
						}
					}
				}
			}
		}
		
		override public function set x(value:Number):void
		{
			super.x = value;
		}
		
		public function onPlay():void
		{
			if (this.stop || (getTimer() - time) <= 2) {
				return;
			}
			
			time = getTimer();
			var handleCount:int = 1;
			var dur:int = getTimer() - startTime;
			if (this.showType == 0) {
				if (startSpeedY < 0) {
					startSpeedY = 0;
				}
				dx = dx - 0.2;
				dy = dy + dx;
				if (startSpeedY > 0) {
					startSpeedY = startSpeedY - 0.1;
				}
				startY = startY - dy;
				this.y = startY;
				if (dur > 200) {
					dy = 1.5 * handleCount + startSpeedY;
					this.alpha = this.alpha - va * handleCount;
					if (dur > 2000) {
						alpha = -1;
					}
				} else {
					dy = 2 * handleCount + startSpeedY;
				}
			} else {
				if (this.showType == 5) {
					if (startSpeedY < 0) {
						startSpeedY = 0;
					}
					dy = handleCount + startSpeedY;
					if (startSpeedY > 0) {
						startSpeedY = startSpeedY - 0.1;
					}
					startY = startY - dy;
					this.y = startY;
					if (dur > 300) {
						dy = 2 * handleCount + startSpeedY;
						this.alpha = this.alpha - va * handleCount * 2;
						if (dur > 2000) {
							alpha = -1;
						}
					} else {
						dy = 2 * handleCount + startSpeedY;
					}
				} else {
					if (this.showType == 1) {
						if (scaleX > 1) {
							this.scaleX = this.scaleX - Math.abs(dy);
							this.scaleY = this.scaleY - Math.abs(dy);
						}
						if (scaleX < 1) {
							this.scaleY = 1;
							this.scaleX = 1;
						}
						if (dur > 300) {
							this.alpha = this.alpha - va * handleCount;
							this.y = this.y - dx * handleCount;
						}
						if (dur > 3000) {
							alpha = -1;
						}
					} else {
						if (this.showType == 2) {
							if (dur > 200) {
								this.alpha = this.alpha - va * handleCount;
								this.y = this.y - dx * handleCount;
							}
							if (dur > 3000) {
								alpha = -1;
							}
						}
					}
				}
			}
			
			if (this.alpha < 0) {
				if (playEndFunc != null) {
					playEndFunc(id);
					playEndFunc = null;
				}
				if (this.parent){
					this.parent.removeChild(this);
				}
				this.dispose();
				this.stop = true;
			}
		}
		
		public function dispose():void
		{
			playEndFunc = null;
			if (this.parent) {
				this.parent.removeChild(this);
			}
			var index:int = queueHash.indexOf(this);
			if (index != -1) {
				queueHash.splice(index, 1);
			}
			headImageHash.push(this);
		}

	}
} 
