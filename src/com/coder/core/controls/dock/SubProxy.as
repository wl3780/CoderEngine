package com.coder.core.controls.dock
{
	import com.coder.core.protos.Proto;
	import com.coder.interfaces.dock.IMessage;
	import com.coder.interfaces.dock.IProxy;
	import com.coder.interfaces.dock.ISocket_tos;
	
	import flash.utils.getQualifiedClassName;

    public class SubProxy extends Proto implements IProxy
	{
        private var _lock:Boolean;
        private var _name:String;

        public function SubProxy()
		{
			super();
            _name = getQualifiedClassName(this);
        }
		
        public function send(message:IMessage):void
		{
            MessageDock.getInstance().send(message);
        }
		
        public function checkFromat():Boolean
		{
            return false;
        }
		
        public function sendToModule(actionOrder:String, geter:String, data:Object=null):void
		{
            Message.sendToModule(actionOrder, geter, data, this.oid);
        }
		
		public function sendToModules(actionOrder:String, gaters:Vector.<String>, data:Object=null):void
		{
			Message.sendToModules(actionOrder, gaters, data, this.oid);
		}
		
        public function sendToTotalModule(actionOrder:String, data:Object=null):void
		{
            Message.sendToTotalModule(actionOrder, data, this.oid);
        }
		
        public function sendToService(data:ISocket_tos, actionOrder:String=null):void
		{
            Message.sendToService(data, actionOrder, this.oid);
        }
		
        public function sendToSubs(actionOrder:String, data:Object=null):void
		{
            Message.sendToSubs(actionOrder, data, this.oid);
        }
		
        public function subHandle(message:IMessage):void
		{
        }
		
        override public function set oid(value:String):void
		{
            super.oid = value;
            register(value);
        }
		
        public function register(module:String):void
		{
            unregister();
            super.oid = module;
            ModuleDock.getInstance().addModuleSub(this);
        }
		
        public function unregister():void
		{
            ModuleDock.getInstance().removeModeleSub(this);
        }
		
        public function get name():String
		{
            return _name;
        }
        public function get lock():Boolean
		{
            return _lock;
        }
        public function set lock(value:Boolean):void
		{
            _lock = value;
        }

    }
}
