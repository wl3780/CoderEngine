package com.coder.interfaces.dock
{
	import flash.utils.ByteArray;

	public interface ISocket_tos extends IProto
	{
		function get pack_id():int;

		function encode():ByteArray;
		
		/**
		 * 释放ByteArray
		 */		
		function clear():void;
	}
}