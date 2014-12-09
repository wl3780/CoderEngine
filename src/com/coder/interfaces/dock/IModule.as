package com.coder.interfaces.dock
{
	public interface IModule extends IProto
	{
		function get name():String;

		function get lock():Boolean;

		function set lock(value:Boolean):void;

		function register():void;

		function unregister():void;

		function send(message:IMessage):void;

		function subHandle(message:IMessage):void;

		function registerSubProxy(... args):void;
		
		function registerSubPackage(... args):void;
		
		function registerPackParser(... args):void;
	}
}