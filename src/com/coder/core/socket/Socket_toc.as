﻿package com.coder.core.socket
{
	import com.coder.core.protos.Proto;
	import com.coder.engine.Asswc;
	import com.coder.interfaces.dock.ISocket_toc;
	
	import flash.utils.ByteArray;

	public class Socket_toc extends Proto implements ISocket_toc
	{
		protected var _pack_id:int;
		protected var _bytes:ByteArray;

		public function Socket_toc()
		{
			super();
		}
		
		public function get pack_id():int
		{
			return _pack_id;
		}
		public function set pack_id(value:int):void
		{
			_pack_id = value;
		}
		
		public function decode(byte:ByteArray):void
		{
			_bytes = byte;
		}
		
		override public function toString():String
		{
			return "【收到消息号:" + _pack_id + "】" + super.toString();
		}
		
		protected function readString():String
		{
			return _bytes.readUTF();
		}
		
		protected function readByte():int
		{
			return _bytes.readByte();
		}
		
		protected function readShort():int
		{
			return _bytes.readShort();
		}
		
		protected function readInt():int
		{
			if (Asswc.compress) {
				return ByteArrayUtil.readInt(_bytes);
			} else {
				return _bytes.readInt();
			}
		}
		
		protected function readBoolean():Boolean
		{
			return _bytes.readByte() == 1;
		}
		
		protected function readBytes():ByteArray
		{
			var size:uint = _bytes.readUnsignedInt();
			var result:ByteArray = new ByteArray();
			_bytes.readBytes(result, _bytes.position, size);
			return result;
		}
		
		protected function readLong():Number
		{
			var head:int = this.readInt();
			var end:uint = _bytes.readUnsignedInt();
			return head * 4294967296 + end;
		}
	}
}
