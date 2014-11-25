package com.coder.core.displays.avatar
{
	import com.coder.core.displays.world.Scene;
	import com.coder.engine.Engine;
	import com.coder.global.EngineGlobal;
	import com.coder.interfaces.display.IAvatar;
	import com.coder.utils.FPSUtils;
	
	import flash.display.Shape;
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	import flash.utils.getTimer;

	public class AvatarRenderElisor extends Shape
	{
		public static var readnerNum:int = 2;

		private static var _instance_:AvatarRenderElisor;
		private static var unitQueue:Vector.<AvatarUnit> = new Vector.<AvatarUnit>();
		private static var timer:Timer = new Timer(0);

		private var index:int;
		private var renderIndex:int;
		private var intervalue:int = 0;
		private var readnerIndex:int = 0;

		public function AvatarRenderElisor()
		{
			addEventListener(Event.ENTER_FRAME, enterFrameFunc);
		}
		
		public static function getInstance():AvatarRenderElisor
		{
			return _instance_ ||= new AvatarRenderElisor();
		}
		
		public static function get unit_length():int
		{
			return unitQueue.length;
		}

		protected function enterFrameFunc(event:Event):void
		{
			heartBeatHandler();
		}
		
		protected function timerFrameFunc(event:TimerEvent):void
		{
		}
		
		public function addUnit(unit:AvatarUnit):void
		{
			if (unitQueue.indexOf(unit) == -1) {
				unitQueue.push(unit);
			}
		}
		
		public function removeUnit(unit_id:String):void
		{
			var avatarUnit:AvatarUnit = AvatarUnit.takeAvatarUnit(unit_id);
			if (avatarUnit) {
				var tmpIndex:int = unitQueue.indexOf(avatarUnit);
				if (tmpIndex != -1) {
					unitQueue.splice(tmpIndex, 1);
				}
			}
		}
		
		private function heartBeatHandler():void
		{
			if (!Scene.scene) {
				return;
			}
			if (Engine.stage) {
				EngineGlobal.stageRect.width = Engine.stage.stageWidth;
				EngineGlobal.stageRect.height = Engine.stage.stageHeight;
			}
			var needTime:int = 30;
			if (FPSUtils.fps < 10) {
				needTime = 60;
			}
			if (FPSUtils.fps < 5) {
				needTime = 150;
			}
			if (getTimer() - intervalue < needTime) {
				return;
			}
			index = unitQueue.length;
			readnerIndex = readnerIndex + 1;
			if (readnerIndex >= readnerNum) {
				readnerIndex = 0;
			}
			var avatarUnit:AvatarUnit = null;
			var tmpAvatar:IAvatar = null;
			var queueIndex:int = 0;
			while (queueIndex < unitQueue.length) {
				avatarUnit = unitQueue[queueIndex];
				tmpAvatar = AvatarUnitDisplay.takeUnitDisplay(avatarUnit.oid);
				if ((avatarUnit.renderindex == readnerIndex) || (tmpAvatar == Scene.scene.mainChar) || (tmpAvatar as AvatarEffect)) {
					if (tmpAvatar && avatarUnit && !avatarUnit.isDisposed && !tmpAvatar.isDisposed) {
						if (avatarUnit.charType != "showad") {
							if (avatarUnit.charType == "effect") {
								avatarUnit.onBodyRender();
								avatarUnit.onEffectRender();
							} else {
								if ((tmpAvatar as AvatarEffect)) {
									if (tmpAvatar.type == "STATIC_STAGE_EFFECT") {
										if (AvatarEffect(tmpAvatar).stageIntersects) {
											avatarUnit.onEffectRender();
										}
									} else {
										avatarUnit.onEffectRender();
									}
								} else {
									avatarUnit.onBodyRender();
									avatarUnit.onEffectRender();
								}
							}
						} else {
							unitQueue.splice(queueIndex, 1);
						}
					} else {
						unitQueue.splice(queueIndex, 1);
						if (!tmpAvatar) {
							avatarUnit.dispose();
						}
					}
				}
				queueIndex++;
			}
		}

	}
} 
