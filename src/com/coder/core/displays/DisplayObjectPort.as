package com.coder.core.displays
{
	import com.coder.interfaces.system.IOrderDispatcher;
	import com.coder.utils.Hash;

	public class DisplayObjectPort extends Object
	{
		private static var hash:Hash = new Hash();

		public static function addTarget(value:IOrderDispatcher):void
		{
			var kName:String = value.className;
			var sub:Hash = hash.has(kName) ? hash[kName] as Hash : new Hash();
			sub.put(value.id, value);
			hash.put(kName, sub);
		}
		
		public static function hasTargetByClassName(className:String, id:String):Boolean
		{
			if (hash.has(className) == false) {
				return false;
			}
			return (hash[className] as Hash).has(id);
		}
		
		public static function removeTargetByClassName(className:String, id:String):IOrderDispatcher
		{
			if ( hash.has(className) ) {
				return (hash[className] as Hash).remove(id) as IOrderDispatcher;
			}
			return null;
		}
		
		public static function takeTargetByClassName(className:String, id:String):IOrderDispatcher
		{
			if ( hash.has(className) ) {
				return (hash[className] as Hash).take(id) as IOrderDispatcher;
			}
			return null;
		}
		
		public static function hasTarget(tar:IOrderDispatcher):Boolean
		{
			var kName:String = tar.className;
			if (kName == null) {
				return false;
			}
			return hasTargetByClassName(kName, tar.id);
		}
		
		public static function removeTarget(tar:IOrderDispatcher):void
		{
			var kName:String = tar.className;
			if (kName) {
				removeTargetByClassName(kName, tar.id);
			}
		}

	}
}
