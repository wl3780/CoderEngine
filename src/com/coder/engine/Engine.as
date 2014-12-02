package com.coder.engine
{
	import com.coder.core.controls.dock.ModuleDock;
	import com.coder.core.controls.elisor.Elisor;
	import com.coder.core.controls.elisor.HeartbeatFactory;
	import com.coder.core.displays.avatar.Avatar;
	import com.coder.core.displays.world.Scene;
	import com.coder.global.EngineGlobal;
	import com.coder.utils.GameTimer;
	import com.coder.utils.geom.SuperKey;
	import com.coder.utils.log.Log;
	
	import flash.display.DisplayObjectContainer;
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.system.System;
	import flash.utils.getTimer;

	public class Engine
	{
		public static const cleanMemoryValue:int = 700;

		public static var recordAvatar:Avatar = new Avatar();
		public static var recordAvatarMonster:Avatar = new Avatar();
		public static var recordAvatarChar:Avatar = new Avatar();
		
		public static var isRecord:Boolean = false;
		public static var frameRate:uint;
		
		private static var _instance_:Engine;
		private static var _stage_:Stage;
		private static var _Memory_:Number = 0;
		private static var _MemoryIndex_:Number = 0;
		private static var isLoadBefor:Boolean;
		private static var _RectangleHash_:Array = [];
		private static var _PointleHash_:Array = [];
		private static var _SpriteHash_:Array = [];

		public static function get stage():Stage
		{
			return _stage_;
		}
		public static function set stage(value:Stage):void
		{
			_stage_ = value;
		}
		
		public static function get currMemory():int
		{
			if ((getTimer() - _MemoryIndex_) > 30000) {
				_MemoryIndex_ = getTimer();
				_Memory_ = System.privateMemory / 0x0400 / 0x0400;
			}
			return _Memory_;
		}
		
		public static function get instance():Engine
		{
			return _instance_ ||= new Engine();
		}
		
		public static function loadBefor():void
		{
			if (isLoadBefor == false) {
				isLoadBefor = true;
				recordAvatar.unit.priorLoadQueue = new <String>["stand","walk","run"];
				recordAvatar.loadAvatarPart("mid", EngineGlobal.SHADOW_ID);
			}
		}
		
		public static function recordLoad(type:String, idName:String):void
		{
			recordAvatar.loadAvatarPart(type, idName);
		}
		
		public static function get visionRect():Rectangle
		{
			return Scene.stageRect;
		}
		
		public static function getRect():Rectangle
		{
			var rect:Rectangle = null;
			if (_RectangleHash_.length) {
				rect = _RectangleHash_.pop();
			} else {
				rect = new Rectangle();
			}
			return rect;
		}
		public static function putRect(value:Rectangle):void
		{
			value.setEmpty();
			_RectangleHash_.push(value);
		}
		
		public static function getPoint():Point
		{
			var point:Point = null;
			if (_PointleHash_.length) {
				point = _PointleHash_.pop();
			} else {
				point = new Point();
			}
			return point;
		}
		public static function putPoint(value:Rectangle):void
		{
			value.x = 0;
			value.y = 0;
			_PointleHash_.push(value);
		}
		
		public static function getSprite():Sprite
		{
			var sprite:Sprite = null;
			if (_SpriteHash_.length) {
				sprite = _SpriteHash_.pop();
			} else {
				sprite = new Sprite();
			}
			return sprite;
		}
		public static function putSprite(value:Sprite):void
		{
			value.removeChildren();
			value.x = 0;
			value.y = 0;
			value.name = "";
			
			value.mouseEnabled = false;
			value.mouseChildren = false;
			value.tabChildren = false;
			if (value.alpha != 1) {
				value.alpha = 1;
			}
			if (value.visible == false) {
				value.visible = true;
			}
			_SpriteHash_.push(value);
		}

		public function setup(target:DisplayObjectContainer, moduleConstClass:Class, assetsPath:String, networkModule:Class=null, trackFunc:Function=null):void
		{
			frameRate = target.stage.frameRate;
			
			Asswc.setup(target);
			Asswc.track = trackFunc;
			
			Engine.stage = target.stage;
			Elisor.getInstance().setup(stage);
			EngineGlobal.ELEMENTS_HOST_PATH = assetsPath;
			SuperKey.getInstance().setup(stage);
			HeartbeatFactory.getInstance().setup(stage);
			GameTimer.getInstance().setup(stage);
			if (moduleConstClass && networkModule) {
				ModuleDock.setup(moduleConstClass, networkModule);
			}
			
			Log.debug(this, "系统模块初始化完毕！");
			recordAvatar.unit.isCharMode = true;
		}

	}
}
