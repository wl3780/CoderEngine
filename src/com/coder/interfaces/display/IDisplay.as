package com.coder.interfaces.display
{
	import com.coder.interfaces.dock.IProto;
	
	import flash.display.BitmapData;
	import flash.display.Graphics;
	import flash.events.IEventDispatcher;

	public interface IDisplay extends IProto, IEventDispatcher
	{
		function get x():Number;
		function set x(value:Number):void;
		
		function get y():Number;
		function set y(value:Number):void;
		
		function set enabled(value:Boolean):void;
		function get enabled():Boolean;
		
		function get visible():Boolean;
		function set visible(value:Boolean):void;
		
		function get type():String;
		function set type(value:String):void;
		
		function get name():String;
		function set name(value:String):void;
		
		function get isDisposed():Boolean;
		
		function onRender():void;
		
		function draw(graphics:Graphics, bitmapData:BitmapData, pox:int, poy:int, width:int, height:int):void;
	}
}
