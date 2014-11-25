package com.coder.interfaces.dock
{
	public interface IMessage extends IProto
	{
		function get sender():String;

		function get geters():Vector.<String>;

		function get actionOrder():String;
		
		function get messageType():String;

		function get isDisposed():Boolean;

		function get isRevived():Boolean;

		function send():Boolean;

		function checkFormat():Boolean;

		function recover():void;

		function revive():void;
	}
}