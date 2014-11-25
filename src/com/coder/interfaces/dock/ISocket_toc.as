package com.coder.interfaces.dock
{
	import flash.utils.ByteArray;

	public interface ISocket_toc extends IProto
	{
		function get pack_id():int;

		function decode(byte:ByteArray):void;
	}
}