package com.coder.utils
{
	import com.coder.engine.Asswc;
	import com.coder.interfaces.dock.IProto;
	
	import flash.utils.Dictionary;

    public dynamic class Hash extends Dictionary implements IProto
	{
        private var _id:String;
        private var _oid:String;
        private var _proto:Object;
        private var _className:String;
        private var _length:int;

        public function Hash()
		{
            super(false);
            _id = Asswc.getSoleId();
        }
		
        public function take(key:Object):Object
		{
            return this[key];
        }
		
        public function put(key:Object, value:Object, replace:Boolean=false):void
		{
            var isContain:Boolean = has(key);
            if (!replace && !isContain) {
                this[key] = value;
            } else {
                if (replace) {
                    if (key != "length" && key != "proto" && key != "id" && key != "oid" && key != "className") {
                        this[key] = value;
                    } else {
                        throw new Error("存储key值:\"" + key + "\"与对象固有属性名冲突！");
                    }
                }
            }
			
            if (!isContain) {
                _length ++;
            }
        }
		
        public function has(key:Object):Boolean
		{
            return this[key] ? true : false;
        }
		
        public function remove(key:Object):Object
		{
            var isHas:Boolean = has(key);
            var result:Object = this[key];
            delete this[key];
            if (isHas) {
                _length --;
            }
            return result;
        }
		
        public function get length():int
		{
            return _length;
        }
		
        public function get id():String
		{
            return _id;
        }
        public function set id(value:String):void
		{
            _id = value;
        }
		
        public function get oid():String
		{
            return _oid;
        }
        public function set oid(value:String):void
		{
            _oid = value;
        }
		
        public function get proto():Object
		{
            return _proto;
        }
        public function set proto(value:Object):void
		{
            _proto = value;
        }
		
        public function clone():Object
		{
            var newOne:Hash = new Hash();
            for (var key:String in this) {
                newOne.put(key, this[key]);
            }
            return newOne;
        }
		
        public function dispose():void
		{
            _proto = null;
            _oid = null;
            _id = null;
            _length = 0;
            for (var key:String in this) {
                delete this[key];
            }
        }
		
        public function reset():void
		{
            this.dispose();
            _id = Asswc.getSoleId();
        }
		
        public function get className():String
		{
            return _className;
        }
		
		public function toString():String
		{
			return super.toString();
		}

    }
}
