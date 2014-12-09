package com.coder.core.protos
{
	import com.coder.engine.Asswc;
	import com.coder.interfaces.dock.IProto;
	import com.coder.utils.ObjectUtils;
	
	import flash.net.registerClassAlias;
	import flash.utils.getQualifiedClassName;
	
	public class Proto implements IProto
	{
		protected var _id_:String;
		protected var _oid_:String;
		protected var _proto_:Object;
		protected var _className_:String;
		
		public function Proto()
		{
			registerClassAlias("com.coder.Proto", Proto);
			_className_ = getQualifiedClassName(this);
			_id_ = Asswc.getSoleId();
		}
		
		/**
		 * 唯一id，通常是自读的（特殊情况下可以修改）
		 * @return 
		 */		
		public function get id():String
		{
			return _id_;
		}
		public function set id(value:String):void
		{
			_id_ = value;
		}
		
		/**
		 * 拥有者id
		 * @return 
		 */		
		public function get oid():String
		{
			return _oid_;
		}
		public function set oid(value:String):void
		{
			_oid_ = value;
		}
		
		/**
		 * 绑定数据
		 * @return 
		 */		
		public function get proto():Object
		{
			return _proto_;
		}
		public function set proto(value:Object):void
		{
			_proto_ = value;
		}
		
		public function clone():Object
		{
			return ObjectUtils.copy(this);
		}
		
		public function dispose():void
		{
			_proto_ = null;
			_oid_ = null;
			_id_ = null;
		}
		
		public function toString():String
		{
			return "[" + _className_ + Asswc.SIGN + _id_ + "]";
		}
		
		public function get className():String
		{
			return _className_;
		}
	}
}