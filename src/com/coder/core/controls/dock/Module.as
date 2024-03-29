﻿package com.coder.core.controls.dock
{
	import com.coder.core.protos.Proto;
	import com.coder.interfaces.dock.IMessage;
	import com.coder.interfaces.dock.IModule;
	import com.coder.interfaces.dock.ISocket_tos;
	
	import flash.utils.getQualifiedClassName;

	public class Module extends Proto implements IModule
	{
		protected var _name_:String;
		protected var _lock_:Boolean;
		
		public function Module()
		{
			super();
			this.id = _name_ = getQualifiedClassName(this);
		}
		
		public function register():void
		{
			ModuleDock.getInstance().addModule(this);
		}
		
		public function unregister():void
		{
			ModuleDock.getInstance().removeModule(this.name);
		}
		
		public function send(message:IMessage):void
		{
			MessageDock.getInstance().send(message);
		}
		
		public function subHandle(message:IMessage):void
		{
		}
		
		/**
		 * 注册处理器
		 * @param args
		 */		
		public function registerSubProxy(... args):void
		{
			var proxy:SubProxy;
			for each (var sub:* in args) {
				if (sub is Class) {
					proxy = new sub();
					if (!proxy) {
						throw new Error("参数" + sub + "不是SubProxy子类");
					}
				} else {
					if (sub is SubProxy) {
						proxy = sub;
					} else {
						throw new Error("参数" + sub + "不是SubProxy子对象");
					}
				}
				if (proxy.checkFromat()) {
					proxy.oid = this.name;
					ModuleDock.getInstance().addModuleSub(proxy);
				}
			}
		}
		
		/**
		 * 注册订阅器
		 * @param args
		 */		
		public function registerSubPackage(... args):void
		{
			var module:INetworkModule = ModuleDock.getInstance().takeModule(ModuleDock.NETWORK_MODULE_NAME) as INetworkModule;
			for each (var packageId:String in args) {
				module.addPackageHandler(packageId, this);
			}
		}
		
		/**
		 * 注册包解释器
		 * @param args
		 */		
		public function registerPackParser(... args):void
		{
			var module:INetworkModule = ModuleDock.getInstance().takeModule(ModuleDock.NETWORK_MODULE_NAME) as INetworkModule;
			for each (var pClass:Class in args) {
				module.addPackageParser(pClass);
			}
		}
		
		public function get name():String
		{
			return _name_;
		}
		
		public function get lock():Boolean
		{
			return _lock_;
		}
		public function set lock(value:Boolean):void
		{
			_lock_ = value;
		}
		
		// ------------------辅助方法------------------
		public function sendToModule(actionOrder:String, geter:String, data:Object=null):void
		{
			Message.sendToModule(actionOrder, geter, data, this.name);
		}
		
		public function sendToModules(actionOrder:String, geters:Vector.<String>, data:Object=null):void
		{
			Message.sendToModules(actionOrder, geters, data, this.name);
		}
		
		public function sendToTotalModule(actionOrder:String, data:Object=null):void
		{
			Message.sendToTotalModule(actionOrder, data, this.name);
		}
		
		public function sendToService(data:ISocket_tos, actionOrder:String):void
		{
			Message.sendToService(data, actionOrder, this.name);
		}
		
		public function sendToSubs(actionOrder:String, data:Object=null):void
		{
			Message.sendToSubs(actionOrder, data, this.name);
		}

	}
}
