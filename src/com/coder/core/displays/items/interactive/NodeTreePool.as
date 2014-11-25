package com.coder.core.displays.items.interactive
{
	import com.coder.utils.Hash;

	public class NodeTreePool
	{
		private static var _instance:NodeTreePool;

		private var hash:Hash;

		public function NodeTreePool()
		{
			hash = new Hash();
		}
		
		public static function getInstance():NodeTreePool
		{
			if (_instance == null) {
				_instance = new (NodeTreePool)();
			}
			return _instance;
		}

		public function put(value:NodeTree):void
		{
			if (this.hash[value.id] == null) {
				this.hash[value.id] = value;
			}
		}
		
		public function take(id:String):NodeTree
		{
			return this.hash[id];
		}
		
		public function remove(id:String):void
		{
			delete this.hash[id]
		}
	}
} 
