package com.coder.interfaces.display
{
	import flash.display.BitmapData;

	public interface IAvatar extends IDisplay
	{
		function stop():void;
		
		function play(action:String, renderType:int=0, playEndFunc:Function=null, stopFrame:int=-1):void;
		
		function loadAvatarPart(type:String, idName:String, random:int=0):void;
		
		function onEffectRender(oid:String, renderType:String, bitmapData:BitmapData, tx:int, ty:int):void;
		
		function onBodyRender(renderType:String, bitmapType:String, bitmapData:BitmapData, tx:int, ty:int, shadow:BitmapData=null):void;
		
		function playEnd(act:String):void;
		
		function onEffectPlayEnd(oid:String):void;
		
		function recover():void;
	}
}
