package com.coder.interfaces.system
{
	import com.coder.interfaces.dock.IProto;

	public interface IOrder extends IProto
	{
		function execute():void;
		
		function get executedHandler():Function;
	}
}
