package com.coder.core.controls.wealth
{
	import com.coder.core.displays.avatar.AvatarRequestElisor;
	import com.coder.core.displays.items.unit.DisplayLoader;
	import com.coder.core.protos.Proto;
	import com.coder.engine.Asswc;
	import com.coder.interfaces.display.ILoader;
	import com.coder.utils.Hash;
	
	import flash.display.BitmapData;

	public final class WealthStoragePort extends Proto
	{
		private static var _symbolIntanceHash_:Hash = new Hash();
		private static var _loaderInstanceHash_:Hash = new Hash();

		public static function removeWealth(path:String):void
		{
			var loader_id:String = _loaderInstanceHash_.remove(path) as String;
			for (var key:String in _symbolIntanceHash_) {
				if (key.indexOf(path) != -1) {
					_symbolIntanceHash_.remove(key);
				}
			}
		}
		
		public static function depositWealth(path:String, loader_id:String):void
		{
			_loaderInstanceHash_.put(path, loader_id);
		}
		
		public static function takeLoaderByWealth(path:String):ILoader
		{
			var loader_id:String = _loaderInstanceHash_.take(path) as String;
			var loader:ILoader = WealthElisor.loaderInstanceHash.take(loader_id) as ILoader;
			return loader;
		}
		
		public static function disposeLoaderByWealth(path:String):void
		{
			var loader_id:String = _loaderInstanceHash_.take(path) as String;
			var loader:ILoader = WealthElisor.loaderInstanceHash.remove(loader_id) as ILoader;
			if (loader) {
				loader.dispose();
			}
		}
		
		public static function hasWealth(path:String):Boolean
		{
			for (var key:String in _symbolIntanceHash_) {
				if (key.indexOf(path) != -1) {
					return true;
				}
			}
			return false;
		}
		
		public static function getSymbolIntance(path:String, symbol:String=null):Object
		{
			var key:String = symbol ? path + Asswc.SIGN + symbol : path;
			var result:Object = _symbolIntanceHash_.take(key);
			if (result) {
				return result;
			}
			
			var cls:Class = getClass(path, symbol);
			if (cls) {
				result = new cls();
				_symbolIntanceHash_.put(key, result);
				return result;
			}
			return null;
		}
		
		public static function getClass(path:String, symbol:String):Class
		{
			var loader:DisplayLoader = takeLoaderByWealth(path) as DisplayLoader;
			if (loader) {
				return loader.contentLoaderInfo.applicationDomain.getDefinition(symbol) as Class;
			}
			return null;
		}
		
		public static function clear():void
		{
			AvatarRequestElisor.getInstance().clear();
		}
		
		public static function clean(idName:String):void
		{
			var resource:*;
			for (var key:String in _symbolIntanceHash_) {
				if (key.indexOf(idName) != -1) {
					resource = _symbolIntanceHash_.remove(key);
					if (resource is BitmapData) {
						(resource as BitmapData).dispose();
					}
				}
			}
		}

	}
}
