package com.coder.core.displays.items.interactive
{
	import com.coder.utils.Hash;

	public class NodeTreePool
	{
		private static var _instance:NodeTreePool;

		private var hash:Hash;

		public function NodeTreePool()
		{
			this.hash = new Hash();
		}
		
		public static function getInstance():NodeTreePool
		{
			if (_instance == null) {
				_instance = new NodeTreePool();
			}
			return _instance;
		}

		public function put(value:NodeTree):void
		{
			this.hash.put(value.id, value);
		}
		
		public function take(id:String):NodeTree
		{
			return this.hash.take(id) as NodeTree;
		}
		
		public function remove(id:String):void
		{
			this.hash.remove(id);
		}
	}
} 
