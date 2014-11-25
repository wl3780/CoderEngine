package com.coder.interfaces.display
{

	public interface IInteractiveObject
	{
		function get speed():Number;
		function set speed(value:Number):void;
		
		function get moveEndFunc():Function;
		function set moveEndFunc(value:Function):void;
		
		function tarMoveTo(value:Array):void;
		
		function _tarMove_():void;
		
		function loopMove():void;
	}
}
