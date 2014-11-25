package com.coder.utils
{
	import flash.utils.ByteArray;

    public class ObjectUtils {

		/**
		 * 对象深拷贝
		 * @param value
		 * @return 
		 */		
        public static function copy(value:Object):Object
		{
            var bytes:ByteArray = new ByteArray();
            bytes.writeObject(value);
            bytes.position = 0;
            var result:Object = bytes.readObject();
            return result;
        }

    }
}
