package com.coder.core.displays.world.char
{
	import com.coder.core.displays.DisplayShape;
	import com.coder.core.displays.DisplaySprite;
	import com.coder.core.displays.avatar.AvatarRenderElisor;
	import com.coder.core.displays.avatar.AvatarUnit;
	import com.coder.core.displays.avatar.AvatarUnitDisplay;
	import com.coder.core.displays.world.Scene;
	import com.coder.core.displays.world.SceneItemNames;
	import com.coder.engine.Asswc;
	import com.coder.global.EngineGlobal;
	import com.coder.utils.RecoverUtils;
	
	import flash.display.BitmapData;
	import flash.geom.Matrix;

	public class CharShadow extends DisplaySprite
	{
		private static var showadShapeHash:Array = [];
		private static var showadAvatarHash:Array = [];
		private static var charShowdQueue:Array = [];

		private var shadow:AvatarUnitDisplay;
		private var shadowShape:DisplayShape;
		private var _dir_:int = 0;

		public function CharShadow()
		{
			setShadowSize();
		}
		
		public static function createShape():DisplayShape
		{
			if (showadShapeHash.length) {
				return showadShapeHash.pop();
			}
			return new DisplayShape();
		}
		
		public static function createCharShowd():CharShadow
		{
			var result:CharShadow = null;
			if (charShowdQueue.length) {
				result = charShowdQueue.pop();
				result.resetForDisposed();
			} else {
				result = new CharShadow();
			}
			return result;
		}

		public function setShadowSize(value:int=0):void
		{
			if (shadow && shadow.parent) {
				shadow.parent.removeChild(shadow);
			}
			if (shadowShape == null) {
				shadowShape = createShape();
			}
			if (shadowShape.proto == null) {
				shadowShape.proto = true;
				shadowShape.graphics.clear();
				var bmdShadow:BitmapData = EngineGlobal.char_shadow_arr[value];
				var mat:Matrix = RecoverUtils.matrix;
				mat.tx = -bmdShadow.width / 2;
				mat.ty = -bmdShadow.height / 2;
				shadowShape.graphics.beginBitmapFill(bmdShadow, mat);
				shadowShape.graphics.drawRect(-bmdShadow.width / 2, -bmdShadow.height / 2, bmdShadow.width, bmdShadow.height);
				shadowShape.cacheAsBitmap = true;
			}
			this.addChild(shadowShape);
			Scene.scene.itemLayer.addChild(this);
		}
		
		public function get shadowUnit():AvatarUnitDisplay
		{
			if (!shadow) {
				if (showadAvatarHash.length) {
					shadow = showadAvatarHash.pop();
					shadow.resetForDisposed();
				} else {
					shadow = new AvatarUnitDisplay();
				}
				shadow.y = -6;
				shadow.oid = this.oid;
				var mainChar:MainChar = AvatarUnitDisplay.takeUnitDisplay(oid) as MainChar;
				if (mainChar) {
					shadow.priorLoadQueue = new <String>["stand","walk","run","attack"];
				}
				shadow.dir = _dir_;
				shadow.name = SceneItemNames.SHADOW_NAME;
				shadow.unit.charType = CharTypes.SHADOW_TYPE;
				AvatarUnit.removeUnit(shadow.unit.id);
				AvatarRenderElisor.getInstance().removeUnit(shadow.unit.id);
			}
			if (this.shadowShape && this.shadowShape.parent) {
				shadowShape.parent.removeChild(shadowShape);
				if (showadShapeHash.length < 80) {
					showadShapeHash.push(shadowShape);
				}
				shadowShape = null;
			}
			addChild(shadow);
			return this.shadow;
		}
		
		public function play(action:String, renderType:int=0, playEndFunc:Function=null, stopFrame:int=-1):void
		{
			if (this.shadow) {
				shadow.play(action, renderType, playEndFunc, stopFrame);
			}
		}
		
		public function set dir(value:int):void
		{
			_dir_ = value;
			if (this.shadow) {
				shadow.dir = value;
			}
		}
		
		override public function resetForDisposed():void
		{
			_dir_ = 0;
			x = 0;
			y = 0;
			alpha = 1;
			visible = true;
			super.resetForDisposed();
			setShadowSize();
		}
		
		override public function dispose():void
		{
			if (this.shadowShape && this.shadowShape.parent) {
				shadowShape.parent.removeChild(shadowShape);
				showadShapeHash.push(shadowShape);
			}
			shadowShape = null;
			if (shadow) {
				if (shadow.parent) {
					shadow.parent.removeChild(shadow);
				}
				shadow.dispose();
				if (showadAvatarHash.length < Asswc.POOL_INDEX) {
					showadAvatarHash.push(shadow);
				}
			}
			shadow = null;
			super.dispose();
			if (charShowdQueue.length < Asswc.POOL_INDEX) {
				charShowdQueue.push(this);
			}
		}
		
		public function set act(value:String):void
		{
		}

	}
} 
