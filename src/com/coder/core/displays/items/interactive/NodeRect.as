package com.coder.core.displays.items.interactive
{
	import com.coder.core.protos.Proto;
	import com.coder.engine.Asswc;
	import com.coder.interfaces.display.INodeRect;
	import com.coder.interfaces.display.INoder;
	import com.coder.utils.Hash;
	
	import flash.display.Graphics;
	import flash.geom.Rectangle;
	import flash.utils.Dictionary;

	public class NodeRect extends Proto implements INodeRect
	{
		public var _tid_:String;
		public var _depth_:int;
		public var _rect:Rectangle;
		
		private var _nodeA:NodeRect;
		private var _nodeB:NodeRect;
		private var _nodeC:NodeRect;
		private var _nodeD:NodeRect;
		private var _nodes:Dictionary;
		private var _length:int;
		private var _tree:NodeTree;

		public function NodeRect()
		{
			_nodes = new Dictionary();
		}
		
		public function get rect():Rectangle
		{
			return _rect;
		}
		
		public function setUp(tid:String, oid:String, rect:Rectangle, depth:int):void
		{
			_depth_ = depth;
			_tid_ = tid;
			_rect = rect;
			var nextRect:Rectangle = null;
			var nextDepth:int = depth - 1;
			var rectX:int = rect.x;
			var rectY:int = rect.y;
			var rectW:Number = rect.width;
			var rectH:Number = rect.height;
			var rectHW:int = rectW / 2;
			var rectHH:int = rectH / 2;
			_id_ = (rectX + rectHW) + Asswc.SIGN + (rectY + rectHH);
			_oid_ = oid;
			_tree = NodeTreePool.getInstance().take(tid) as NodeTree;
			_tree.addNode(_id_, this);
			if (nextDepth > 0) {
				if (_nodeA == null){
					_nodeA = new NodeRect();
					nextRect = new Rectangle(rectX, rectY, rectHW, rectHH);
					_nodeA.setUp(tid, _id_, nextRect, nextDepth);
				}
				if (_nodeB == null) {
					_nodeB = new NodeRect();
					nextRect = new Rectangle(rectX, (rectY + rectHH), rectHW, rectHH);
					_nodeB.setUp(tid, _id_, nextRect, nextDepth);
				}
				if (_nodeC == null) {
					_nodeC = new NodeRect();
					nextRect = new Rectangle((rectX + rectHW), rectY, rectHW, rectHH);
					_nodeC.setUp(tid, _id_, nextRect, nextDepth);
				}
				if (_nodeD == null) {
					_nodeD = new NodeRect();
					nextRect = new Rectangle((rectX + rectHW), (rectY + rectHH), rectHW, rectHH);
					_nodeD.setUp(tid, _id_, nextRect, nextDepth);
				}
				project();
			}
		}
		
		private function project():void
		{
			var noder:INoder = null;
			if (_depth_ > 0) {
				for each (noder in _nodes) {
					if (_nodeA._rect.contains(noder.x, noder.y)) {
						_nodeA.addChild(noder.id, noder);
					} else {
						if (_nodeB._rect.contains(noder.x, noder.y)) {
							_nodeB.addChild(noder.id, noder);
						} else {
							if (_nodeC._rect.contains(noder.x, noder.y)) {
								_nodeC.addChild(noder.id, noder);
							} else {
								if (_nodeD._rect.contains(noder.x, noder.y)) {
									_nodeD.addChild(noder.id, noder);
								}
							}
						}
					}
				}
			}
		}
		
		public function reFree():void
		{
			if (_depth_ >= 1){
				_nodes = null;
				_nodes = new Dictionary();
				if (_nodeA){
					_nodeA.reFree();
				}
				if (_nodeB){
					_nodeB.reFree();
				}
				if (_nodeC){
					_nodeC.reFree();
				}
				if (_nodeD){
					_nodeD.reFree();
				}
			}
		}
		
		override public function dispose():void
		{
			_nodes = null;
			_tree = null;
			super.dispose();
		}
		
		public function treeNodes():Hash
		{
			return _tree.nodes;
		}
		
		public function get parent():NodeRect
		{
			if (this.oid == null) {
				return null;
			}
			return _tree.nodes.take(this.oid) as NodeRect;
		}
		
		public function addChild(id:String, noder:INoder):void
		{
			if (_nodes[id] == null) {
				_nodes[id] = noder;
				_length ++;
			}
		}
		
		public function get nodeA():NodeRect
		{
			return _nodeA;
		}
		
		public function get nodeB():NodeRect
		{
			return _nodeB;
		}
		
		public function get nodeC():NodeRect
		{
			return _nodeC;
		}
		
		public function get nodeD():NodeRect
		{
			return _nodeD;
		}
		
		public function get length():int
		{
			return _length;
		}
		
		public function get dic():Dictionary
		{
			return _nodes;
		}
		
		public function removeChild(id:String):void
		{
			if (_nodes[id]) {
				delete _nodes[id];
				_length --;
			}
		}
		
		public function drawBound(g:Graphics, rect:Rectangle, color:uint, f:Boolean=false):void
		{
			if (rect && g) {
				g.lineStyle(1, color);
				if (f) {
					g.beginFill(0, 0.2);
				}
				g.drawRect(rect.topLeft.x, rect.topLeft.y, rect.width, rect.height);
			}
		}

	}
} 
