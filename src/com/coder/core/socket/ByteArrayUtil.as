package com.coder.core.socket
{
	import flash.utils.ByteArray;

	public class ByteArrayUtil
	{
		public function ByteArrayUtil()
		{
		}
		
		public static function readInt(bytes:ByteArray):int
		{
			var temp:uint = readVarint32(bytes);
			return decodeZigZag32(temp);
		}
		public static function writeInt(bytes:ByteArray, value:int):void
		{
			var temp:uint = encodeZigZag32(value);
			writeVarint32(bytes, temp);
		}
		
		private static function readVarint32(bytes:ByteArray):uint
		{
			var result:int = 0;
			var next:int = 0;
			for (var i:int = 0; i < 5; i++) {
				next = bytes.readByte();
				result |= (next & 127) << (7 * i);
				if (!(next & 128)) {
					break;
				}
			}
			return result;
			
			// 枚举版本
			next = bytes.readByte();
			if (next >= 0) {
				return next;
			}
			result = next & 127;
			next = bytes.readByte();
			if (next >= 0) {
				result |= next << 7;
			} else {
				result |= (next & 127) << 7;
				next = bytes.readByte();
				if (next >= 0) {
					result |= next << 14;
				} else {
					result |= (next & 127) << 14;
					next = bytes.readByte();
					if (next >= 0) {
						result |= next << 21;
					} else {
						result |= (next & 127) << 21;
						next = bytes.readByte();
						if (next >= 0) {
							result |= next << 28;
						}
					}
				}
			}
			return result;
		}
		private static function writeVarint32(bytes:ByteArray, value:uint):void
		{
			while (value > 127) {
				bytes.writeByte((value & 127) | 128);
				value = value >>> 7;
			}
			bytes.writeByte(value & 127);
			
			// 枚举版本
			if (value < (1 << 7)) {
				bytes.writeByte(value);
			} else if (value < (1 << 14)) {
				bytes.writeByte(value | 128);
				bytes.writeByte(value >>> 7);
			} else if (value < (1 << 21)) {
				bytes.writeByte(value | 128);
				bytes.writeByte((value >>> 7) | 128);
				bytes.writeByte(value >>> 14);
			} else if (value < (1 << 28)) {
				bytes.writeByte(value | 128);
				bytes.writeByte((value >>> 7) | 128);
				bytes.writeByte((value >>> 14) | 128);
				bytes.writeByte(value >>> 21);
			} else {
				bytes.writeByte(value | 128);
				bytes.writeByte((value >>> 7) | 128);
				bytes.writeByte((value >>> 14) | 128);
				bytes.writeByte((value >>> 21) | 128);
				bytes.writeByte(value >>> 28);
			}
		}
		
		public static function encodeZigZag32(value:int):uint
		{
			return (value << 1) ^ (value >> 31);
		}
		public static function decodeZigZag32(value:uint):int
		{
			return (value >>> 1) ^ -(value & 1);
		}
	}
}