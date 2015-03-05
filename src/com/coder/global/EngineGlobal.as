package com.coder.global
{
	import com.coder.core.displays.avatar.AvatarActionData;
	import com.coder.core.displays.avatar.AvatarDataFormatGroup;
	import com.coder.engine.Asswc;
	
	import flash.display.BitmapData;
	import flash.filters.GlowFilter;
	import flash.geom.Rectangle;
	import flash.system.Capabilities;

	public class EngineGlobal
	{
		public static const MFPS:int = 5;
		
		public static const WEALTH_QUEUE_ALONE_SIGN:String = "【WQA】";
		public static const WEALTH_QUEUE_GROUP_SIGN:String = "【WQG】";
		
		public static const IMAGE_WIDTH:int = 320;
		public static const IMAGE_HEIGHT:int = 180;
		
		public static const AVATAR_IMAGE_WIDTH:int = 400;
		public static const AVATAR_IMAGE_HEIGHT:int = 300;
		
		public static const TYPE_REFLEX:Object = {
			mid:"clothes",
			eid:"effects",
			midm:"mounts",
			wid:"weapons",
			wgid:"wings"
		};
		public static const eid:String = "eid";
		public static const mid:String = "mid";
		public static const wid:String = "wid";
		public static const wgid:String = "wgid";
		public static const midm:String = "midm";
		
		public static const DELIMITER:String = "&";
		public static const SM_EXTENSION:String = ".sm";
		public static const TMP_EXTENSION:String = ".tmp";

		public static var shadowAvatarGroupMale:AvatarDataFormatGroup;
		public static var shadowAvatarGroupFamale:AvatarDataFormatGroup;
		public static var shadowAvatarGroupBaseMale:AvatarDataFormatGroup;
		public static var shadowAvatarGroupBaseFamale:AvatarDataFormatGroup;
		public static var shadowAvatarGroup:AvatarDataFormatGroup;
		
		public static var avatarData:AvatarActionData;
		public static var avatarDataMale:AvatarActionData;
		public static var avatarDataFamale:AvatarActionData;
		public static var avatarDataBaseMale:AvatarActionData;
		public static var avatarDataBaseFamale:AvatarActionData;
		
		public static var SHADOW_ID:String = "npc054";
		public static var MALE_SHADOW:String = "ym1001";
		public static var FAMALE_SHADOW:String = "yw1001";
		
		public static var isSceneReady:Boolean;
		public static var isSceneChanging:Boolean;
		public static var char_shadow:BitmapData;
		public static var char_shadow_arr:Vector.<BitmapData> = new Vector.<BitmapData>();

		public static var stageRect:Rectangle = new Rectangle();
		public static var textFilter:Array = [new GlowFilter(0, 1, 3, 3, 3)];
		public static var textFiltert:Array = [new GlowFilter(0, 1, 3, 3, 2)];
		
		private static var assetsHost:String;
		private static var SCENE_ASSETS_DIR_:String;
		private static var AVATAR_ASSETS_DIR_:String;

		public static function get language():String
		{
			return "zh_CN";
		}
		
		public static function get ELEMENTS_HOST_PATH():String
		{
			return assetsHost;
		}
		public static function set ELEMENTS_HOST_PATH(value:String):void
		{
			assetsHost = value;
		}
		
		public static function get version():String
		{
			return "ver-1";
		}
		
		public static function get SCENE_IMAGE_DIR():String
		{
			if (SCENE_ASSETS_DIR_ == null) {
				SCENE_ASSETS_DIR_ = ELEMENTS_HOST_PATH + "assets/" + language + "/maps/";
			}
			return SCENE_ASSETS_DIR_;
		}
		
		public static function get AVATAR_ASSETS_DIR():String
		{
			if (AVATAR_ASSETS_DIR_ == null) {
				if (Capabilities.playerType == "Desktop") {
					AVATAR_ASSETS_DIR_ = ELEMENTS_HOST_PATH + "/avatars/";
				} else {
					AVATAR_ASSETS_DIR_ = ELEMENTS_HOST_PATH + "assets/" + language + "/avatars/";
				}
			}
			return AVATAR_ASSETS_DIR_;
		}
		
		public static function getAvatarAssetsPath(idName:String):String
		{
			var idType:String = idName.split(Asswc.LINE)[0];
			return AVATAR_ASSETS_DIR + TYPE_REFLEX[idType] + "/" + idName + TMP_EXTENSION;
		}
		
		public static function getAvatarAssetsConfigPath(idName:String):String
		{
			var idType:String = idName.split(Asswc.LINE)[0];
			return AVATAR_ASSETS_DIR + "output/" + idName + SM_EXTENSION;
		}
	}
}
