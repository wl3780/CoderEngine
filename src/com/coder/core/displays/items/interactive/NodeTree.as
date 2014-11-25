package com.coder.core.displays.items.interactive
{
	import com.coder.core.protos.Proto;
	import com.coder.engine.Asswc;
	import com.coder.interfaces.display.INoder;
	import com.coder.utils.Hash;
	
	import flash.display.DisplayObject;
	import flash.geom.Rectangle;
	import flash.utils.Dictionary;

	public class NodeTree extends Proto
	{
		public static var minWidth:int;
		public static var minHeight:int;
		public static var minSize:int;
		public static var doubleMinWidth:int;
		public static var doubleMinHeight:int;

		public var initialized:Boolean;
		
		private var _scopeRect:Rectangle;
		private var _depth:int;
		private var _rulerValue:int;
		private var _topNode:NodeRect;
		private var _hash:Hash;

		public function NodeTree(id:String)
		{
			this.id = id;
		}
		
		public static function takeDepth(ruler:Number, minSize:int):Number
		{
			var i:int = 1;
			var size:Number;
			while (true) {
				size = Math.round(ruler / Math.pow(2, i));
				if (size <= minSize){
					return i;
				}
			}
			return -1;
		}

		public function reset():void
		{
			_topNode.dispose();
			_topNode = null;
		}
		
		public function get nodes():Hash
		{
			return _hash;
		}
		
		public function build(scopeRect:Rectangle, minSize:int=50, source:Vector.<INoder>=null):void
		{
			NodeTreePool.getInstance().put(this);
			_scopeRect = scopeRect;
			_hash = new Hash();
			(scopeRect.width - scopeRect.height) > 0 ? _rulerValue = scopeRect.width : _rulerValue = scopeRect.height;
			_depth = takeDepth(_rulerValue, minSize);
			var tmpDepth:int = Math.round(Math.pow(2, _depth));
			scopeRect.width = Math.round(scopeRect.width / tmpDepth) * tmpDepth;
			scopeRect.height = Math.round(scopeRect.height / tmpDepth) * tmpDepth;
			NodeTree.minSize = (_rulerValue / tmpDepth);
			minWidth = scopeRect.width / tmpDepth;
			minHeight = scopeRect.height / tmpDepth;
			doubleMinWidth = minWidth * 2;
			doubleMinHeight = minHeight * 2;
			_topNode = new NodeRect();
			if (source) {
				var index:int = 0;
				var len:int = source.length;
				while (index < len) {
					Object(source[index])._tid = this.id;
					_topNode.addChild(source[index].node.id, source[index]);
					index++;
				}
			}
			_topNode.setUp(this.id, null, scopeRect, _depth);
			_topNode.id = (scopeRect.x + scopeRect.width / 2) + Asswc.SIGN + (scopeRect.y + scopeRect.height / 2);
			initialized = true;
		}
		
		public function find(rect:Rectangle, exact:Boolean=false, definition:Number=20):Array
		{
			if (initialized) {
				var result:Array = [];
				var dic:Dictionary = new Dictionary();
				definition <= minSize ? definition = minSize : "";
				var tmpDepth:int = NodeTree.takeDepth(_rulerValue, definition);
				cycleFind(result, dic, _topNode, rect, _depth - tmpDepth + 1, exact);
				return result;
			}
			return null;
		}
		
		private function cycleFind(arr:Array, dic:Dictionary, node:NodeRect, rect:Rectangle, level:int, exact:Boolean):void
		{
			if (!node) {
				return;
			}
			
			var tmpDic:Dictionary = null;
			if (rect.intersects(node.rect) && node.length > 0) {
				if (node._depth_ == level) {
					tmpDic = node.dic;
					for each (var item:INoder in tmpDic) {
						if ((item as DisplayObject).stage) {
							if (exact) {
								if (rect.intersects(item.getBounds(Object(item).parent))) {
									if (dic[item.id] == null){
										dic[item.id] = item;
										arr.push(item);
									}
								}
							} else {
								if (dic[item.id] == null){
									dic[item.id] = item;
									arr.push(item);
								}
							}
						}
					}
				} else {
					if (node.nodeA) {
						cycleFind(arr, dic, node.nodeA, rect, level, exact);
					}
					if (node.nodeB) {
						cycleFind(arr, dic, node.nodeB, rect, level, exact);
					}
					if (node.nodeC) {
						cycleFind(arr, dic, node.nodeC, rect, level, exact);
					}
					if (node.nodeD) {
						cycleFind(arr, dic, node.nodeD, rect, level, exact);
					}
				}
			}
		}
		
		private function project():void
		{
		}
		
		public function addNode(id:String, node:NodeRect):void
		{
			_hash.put(id, node);
		}
		
		public function removeNode(id:String):void
		{
			_hash.remove(id);
		}
		
		public function takeNode(id:String):NodeRect
		{
			return _hash.take(id) as NodeRect;
		}

	}
} 
