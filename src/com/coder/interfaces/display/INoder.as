package com.coder.interfaces.display
{
	import flash.display.DisplayObject;
	import flash.geom.Rectangle;

	public interface INoder
	{

		function set x(value:Number):void;
		function get x():Number;
		
		function set y(value:Number):void;
		function get y():Number;
		
		function get node():INodeRect;
		
		function activate():void;
		
		function unactivate():void;
		
		function get isActivate():Boolean;
		
		function getBounds(targetCoordinateSpace:DisplayObject):Rectangle;
		
		function get id():String;
		
		function get tid():String;
		
		function get visible():Boolean;

	}
}
