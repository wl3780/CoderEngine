package com.coder.interfaces.system
{
	import com.coder.interfaces.dock.IProto;
	
	import flash.events.IEventDispatcher;

	public interface IOrderDispatcher extends IEventDispatcher, IProto
	{
		function addFrameOrder(heartBeatHandler:Function, deay:int=-1, isOnStageHandler:Boolean=false):void;
		
		function removeFrameOrder(heartBeatHandler:Function):void;
		
		function hasFrameOrder(heartBeatHandler:Function):Boolean;
		
		function removeTotalFrameOrder():void;
		
		function removeTotalEventOrder():void;
		
		function removeTotalOrders():void;
		
		function setInterval(heartBeatHandler:Function, delay:int, ... args):void;
		
		function setTimeOut(closureHandler:Function, deay:int, ... args):String;
	}
}
