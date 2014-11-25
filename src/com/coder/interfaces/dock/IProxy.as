package com.coder.interfaces.dock
{
	public interface IProxy extends IProto
	{
		function send(message:IMessage):void;
		
		function subHandle(message:IMessage):void;
		
		function checkFromat():Boolean;
	}
}