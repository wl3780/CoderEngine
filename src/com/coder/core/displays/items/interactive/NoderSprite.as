package com.coder.core.displays.items.interactive
{
	import com.coder.core.displays.DisplaySprite;
	import com.coder.engine.Asswc;
	import com.coder.interfaces.display.INodeRect;
	import com.coder.interfaces.display.INoderDisplay;

	public class NoderSprite extends DisplaySprite implements INoderDisplay
	{
		public var _tid:String;
		
		private var _node:NodeRect;
		private var _tree:NodeTree;
		private var _initialized:Boolean;
		private var _isActivate:Boolean;

		public function NoderSprite()
		{
			this.mouseChildren = false;
			this.mouseEnabled = false;
			this.tabEnabled = false;
			this.tabChildren = false;
		}
		
		public function registerNodeTree(tid:String):void
		{
			_tid = tid;
			_tree = NodeTreePool.getInstance().take(tid);
			_initialized = true;
			this.activate();
		}
		
		override public function set x(value:Number):void
		{
			if (value == super.x) {
				return;
			}
			super.x = value;
			updata(value, y, this.nodeKey);
		}
		
		override public function set y(value:Number):void
		{
			if (value == super.y) {
				return;
			}
			super.y = value;
			updata(x, value, this.nodeKey);
		}
		
		public function updata(x:Number, y:Number, key:String):void
		{
			if (_isActivate == false){
				return;
			}
			if (_initialized == false){
				return;
			}
			
			if (_tree.initialized) {
				if (_node == null) {
					_node = _tree.nodes.take(key) as NodeRect;
				}
				if (!_node._rect.contains(x, y)) {
					var newNode:NodeRect = _tree.nodes.take(key) as NodeRect;
					this.resetNode(_node, newNode);
					if (newNode != null) {
						_node = newNode;
					}
				}
			}
		}
		
		private function resetNode(node:NodeRect, newNode:NodeRect):void
		{
			if (node && newNode) {
				if (node != newNode) {
					node.removeChild(this.id);
					newNode.addChild(this.id, this);
					_node = newNode;
					resetNode(node.parent, newNode.parent);
				}
			}
		}
		
		public function get node():INodeRect
		{
			return _node;
		}
		
		private function get nodeKey():String
		{
			var subX:int = this.x / NodeTree.doubleMinWidth * NodeTree.doubleMinWidth + NodeTree.minWidth;
			var subY:int = this.y / NodeTree.doubleMinHeight * NodeTree.doubleMinHeight + NodeTree.minHeight;
			return subX + Asswc.SIGN + subY;
		}
		
		public function activate():void
		{
			if (_tree.initialized) {
				_isActivate = true;
				var newNode:NodeRect = _tree.nodes.take(nodeKey) as NodeRect;
				_node = newNode;
				push(newNode);
			}
		}
		
		public function unactivate():void
		{
			_isActivate = false;
			if (_node) {
				this.remove(_node);
				_node = null;
			}
		}
		
		public function get isActivate():Boolean
		{
			return _isActivate;
		}
		
		public function get tid():String
		{
			return _tid;
		}
		
		public function push(node:NodeRect):void
		{
			if (node == null) {
				return;
			}
			node.addChild(this.id, this);
			var pNode:NodeRect = node.parent;
			if (pNode) {
				push(pNode);
			}
		}
		
		private function remove(node:NodeRect):void
		{
			if (node == null) {
				return;
			}
			node.removeChild(this.id);
			var pNode:NodeRect = node.parent;
			if (pNode) {
				remove(pNode);
			}
		}
		
		override public function resetForDisposed():void
		{
			super.resetForDisposed();
			_node = null;
			_initialized = false;
			_isActivate = false;
			this.mouseChildren = false;
			this.mouseEnabled = false;
			this.tabEnabled = false;
			this.tabChildren = false;
		}
		
		override public function dispose():void
		{
			_isActivate = false;
			remove(_node);
			_node = null;
			_tree = null;
			super.dispose();
		}

	}
} 
