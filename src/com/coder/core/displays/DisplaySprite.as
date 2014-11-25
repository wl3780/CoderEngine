package com.coder.core.displays
{
	import com.coder.core.controls.elisor.Elisor;
	import com.coder.core.displays.world.Scene;
	import com.coder.engine.Asswc;
	import com.coder.interfaces.display.IDisplay;
	import com.coder.interfaces.system.IOrderDispatcher;
	import com.coder.utils.GraphicsUtils;
	import com.coder.utils.ObjectUtils;
	
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.Graphics;
	import flash.display.Sprite;
	import flash.utils.getQualifiedClassName;

	public class DisplaySprite extends Sprite implements IDisplay, IOrderDispatcher
	{
		private static var _elisor_:Elisor = Elisor.getInstance();

		protected var _isDisposed_:Boolean;
		protected var _id_:String;
		protected var _oid_:String;
		protected var _proto_:Object;
		protected var _type_:String;
		protected var _enabled_:Boolean;
		protected var _className_:String;

		public function DisplaySprite()
		{
			super();
			init();
		}
		
		protected function init():void
		{
			_id_ = Asswc.getSoleId();
			DisplayObjectPort.addTarget(this);
		}
		
		override public function addChild(child:DisplayObject):DisplayObject
		{
			if (getQualifiedClassName(child).indexOf("Sprite") != -1) {
				child;
			}
			return super.addChild(child);
		}
		
		override public function addEventListener(type:String, listener:Function, useCapture:Boolean=false, priority:int=0, useWeakReference:Boolean=false):void
		{
			if (!_elisor_.hasEventOrder(this.id, type)) {
				_elisor_.addEventOrder(this, type, listener);
				super.addEventListener(type, listener, useCapture);
			}
		}
		
		override public function removeEventListener(type:String, listener:Function, useCapture:Boolean=false):void
		{
			super.removeEventListener(type, listener);
			_elisor_.removeEventOrder(this.id, type);
		}
		
		public function addFrameOrder(heartBeatHandler:Function, deay:int=0, isOnStageHandler:Boolean=false):void
		{
			_elisor_.addFrameOrder(this, heartBeatHandler, deay, isOnStageHandler);
		}
		
		public function removeFrameOrder(heartBeatHandler:Function):void
		{
			_elisor_.removeFrameOrder(heartBeatHandler);
		}
		
		public function hasFrameOrder(heartBeatHandler:Function):Boolean
		{
			return _elisor_.hasFrameOrder(heartBeatHandler);
		}
		
		public function setTimeOut(closureHandler:Function, delay:int, ... args):String
		{
			var params:Array = [this, closureHandler, delay].concat(args);
			return _elisor_.setTimeOut.apply(null, params);
		}
		
		public function setInterval(heartBeatHandler:Function, delay:int, ... args):void
		{
			var params:Array = [this, heartBeatHandler, delay].concat(args);
			_elisor_.setInterval.apply(null, params);
		}
		
		public function removeTotalFrameOrder():void
		{
			_elisor_.removeTotalFrameOrder(this);
		}
		
		public function removeTotalEventOrder():void
		{
			_elisor_.removeTotalEventOrder(this);
		}
		
		public function removeTotalOrders():void
		{
			removeTotalEventOrder();
			removeTotalFrameOrder();
		}
		
		public function set enabled(value:Boolean):void
		{
			_enabled_ = value;
		}
		public function get enabled():Boolean
		{
			return _enabled_;
		}
		
		public function get type():String
		{
			return _type_;
		}
		public function set type(value:String):void
		{
			_type_ = value;
		}
		
		public function get isDisposed():Boolean
		{
			return _isDisposed_;
		}
		
		public function onRender():void
		{
		}
		
		public function draw(graphics:Graphics, bitmapData:BitmapData, pox:int, poy:int, width:int, height:int):void
		{
			GraphicsUtils.draw(graphics, bitmapData, pox, poy, width, height);
		}
		
		public function get id():String
		{
			return _id_;
		}
		public function set id(value:String):void
		{
			if (_id_ != value) {
				_id_ = value;
			}
		}
		
		public function get oid():String
		{
			return _oid_;
		}
		public function set oid(value:String):void
		{
			_oid_ = value;
		}
		
		public function get proto():Object
		{
			return _proto_;
		}
		public function set proto(value:Object):void
		{
			_proto_ = value;
		}
		
		public function clone():Object
		{
			return ObjectUtils.copy(this);
		}
		
		public function resetForDisposed():void
		{
			_isDisposed_ = false;
			_enabled_ = false;
			init();
		}
		
		public function dispose():void
		{
			Scene.isDepthChange = true;
			if (this.parent) {
				this.parent.removeChild(this);
			}
			this.removeTotalOrders();
			DisplayObjectPort.removeTarget(this);
			_proto_ = null;
			_oid_ = null;
			_id_ = null;
			_enabled_ = true;
			_type_ = null;
			this.graphics.clear();
			removeDisplayObject(this);
			_isDisposed_ = true;
		}
		
		override public function toString():String
		{
			return "[" + this.className + Asswc.SIGN + _id_ + "]";
		}
		
		public function get className():String
		{
			if (_className_ == null) {
				_className_ = getQualifiedClassName(this);
			}
			return _className_;
		}
		
		protected function removeDisplayObject(value:DisplayObjectContainer):void
		{
			var child:DisplayObject = null;
			while (value.numChildren) {
				child = value.removeChildAt(value.numChildren - 1);
				if ((child is DisplayObjectContainer) && (child as DisplayObjectContainer).numChildren) {
					removeDisplayObject(child as DisplayObjectContainer);
				} else {
					if (child is IDisplay) {
						IDisplay(child).dispose();
					}
				}
			}
		}
	}
}
