package com.coder.core.socket
{
	import com.coder.core.protos.Proto;
	import com.coder.interfaces.dock.ISocket_tos;
	
	import flash.utils.ByteArray;

	public class Socket_tos extends Proto implements ISocket_tos
	{
		protected var _bytes:ByteArray;
		protected var _pack_id:int;

		public function Socket_tos()
		{
			super();
			_bytes = new ByteArray();
		}
		
		public function get pack_id():int
		{
			return _pack_id;
		}
		public function set pack_id(value:int):void
		{
			_pack_id = value;
		}
		
		public function encode():ByteArray
		{
			return _bytes;
		}
		
		public function clear():void
		{
			_bytes.clear();
			_bytes = null;
		}
		
		override public function toString():String
		{
			return "【发送消息号:" + _pack_id + "】" + super.toString();
		}
		
		protected function writeString(value:String):void
		{
			_bytes.writeUTF(value);
		}
		
		protected function writeByte(value:int):void
		{
			_bytes.writeByte(value);
		}
		
		protected function writeShort(value:int):void
		{
			_bytes.writeShort(value);
		}
		
		protected function writeBoolean(value:Boolean):void
		{
			value ? _bytes.writeByte(1) : _bytes.writeByte(0);
		}
		
		protected function writeInt(value:int):void
		{
			_bytes.writeInt(value);
		}
		
		protected function writeBytes(value:ByteArray):void
		{
			value.position = 0;
			_bytes.writeUnsignedInt(value.bytesAvailable);
			_bytes.writeBytes(value);
		}
		
		protected function writeLong(value:Number):void
		{
			var end:uint = value % 4294967296;
			var head:uint = (value - end) / 4294967296;
			_bytes.writeInt(head);
			_bytes.writeUnsignedInt(end);
		}
	}
}
