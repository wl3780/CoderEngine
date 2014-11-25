package com.coder.core.controls.dock
{
	import com.coder.interfaces.dock.IMessage;
	import com.coder.interfaces.dock.IModule;
	import com.coder.utils.Hash;
	
	import flash.utils.describeType;
	import flash.utils.getDefinitionByName;
	import flash.utils.getQualifiedClassName;

	/**
	 * 模块仓库
	 */	
    public final class ModuleDock
	{
		/** 默认网络模块名称 */
        public static const NETWORK_MODULE_NAME:String = getQualifiedClassName(INetworkModule);
        /** 发送匿名消息使用模块名称 */
		public static const DEFAULT_MODULE_NAME:String = getQualifiedClassName(DefaultModule);

        private static var _instance:ModuleDock;

        private static var moduleList:Vector.<String> = new Vector.<String>();
        private static var moduleHash:Hash = new Hash();
		
        private static var subscribes:Hash = new Hash();

        internal static function getInstance():ModuleDock
		{
            return _instance ||= new ModuleDock();
        }
		
        internal static function get modules():Vector.<String>
		{
            return moduleList;
        }
		
        public static function setup(moduleConst:Class, networkModule:Class):void
		{
            var netModule:INetworkModule = new networkModule();
            netModule.register();
			
            var kName:String = null;
            var klass:Class = null;
            var module:IModule = null;
            var refXML:XML = describeType(moduleConst);	// 反射获取所有“常量”
            var constItems:XMLList = refXML.child("constant");
			for each (var item:XML in constItems) {
                kName = moduleConst[item.@name];
                klass = getDefinitionByName(kName) as Class;
				module = new klass() as IModule;
				if (module) {
					module.register();
				} else {
					throw new Error("常量" + kName + "不是Module子类定义");
				}
			}
        }

        internal function addModule(module:IModule):void
		{
            if ( !moduleHash.has(module.name) ) {
                moduleHash.put(module.name, module);
                moduleList.push(module.name);
            }
        }
		
        internal function takeModule(module_id:String):IModule
		{
            return moduleHash.take(module_id) as IModule;
        }
		
        internal function removeModule(module_id:String):IModule
		{
            var module:IModule = moduleHash.remove(module_id) as IModule;
            var index:int = moduleList.indexOf(module_id);
            if (index != -1) {
                moduleList.splice(index, 1);
            }
			return module;
        }
		
        internal function addModuleSub(subProxy:SubProxy):void
		{
            var subList:Vector.<SubProxy>;
            if ( !subscribes.has(subProxy.oid) ) {
                subList = new Vector.<SubProxy>();
                subscribes.put(subProxy.oid, subList);
            } else {
                subList = subscribes.take(subProxy.oid) as Vector.<SubProxy>;
            }
			
            var index:int = subList.indexOf(subProxy);
            if (index == -1) {
                subList.push(subProxy);
            }
        }
		
        internal function removeModeleSub(subProxy:SubProxy):void
		{
            var subList:Vector.<SubProxy> = subscribes.take(subProxy.oid) as Vector.<SubProxy>;
            if (subList && subList.length) {
                var index:int = subList.indexOf(subProxy);
                if (index >= 0) {
                    subList.splice(index, 1);
                }
            }
        }
		
        internal function sendToModules(message:IMessage):void
		{
            var module:IModule = null;
            var subList:Vector.<SubProxy>;
            var geters:Vector.<String> = message.geters;
			for each (var item:String in geters) {
				module = takeModule(item);
				if (module && !module.lock && item != NETWORK_MODULE_NAME) {
					module.subHandle(message);
					subList = subscribes.take(item) as Vector.<SubProxy>;
					for each (var proxy:SubProxy in subList) {
						if (!proxy.lock) {
							proxy.subHandle(message);
						}
					}
				}
			}
            MessageDock.recover(message);
        }
		
        internal function sendToSubs(message:IMessage):void
		{
            sendToModules(message);
        }
		
        internal function sendToTotalModule(message:IMessage):void
		{
            sendToModules(message);
        }
		
        internal function sendToService(message:IMessage):void
		{
            var netModule:INetworkModule = takeModule(NETWORK_MODULE_NAME) as INetworkModule;
            if (netModule && !netModule.lock) {
				netModule.subHandle(message);
	            var subList:Vector.<SubProxy> = subscribes.take(NETWORK_MODULE_NAME) as Vector.<SubProxy>;
				for each (var proxy:SubProxy in subList) {
					if (!proxy.lock) {
						proxy.subHandle(message);
					}
				}
            }
        }

    }
}
