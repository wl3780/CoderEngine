package com.coder.core.controls.dock
{
	import com.coder.interfaces.dock.IModule;

	/**
	 * 网络模块接口（网络模块必须实现）
	 */	
    public interface INetworkModule extends IModule
	{
		/**
		 * 订阅与服务器相关信息
		 * @param packageId
		 * @param module
		 */			
		function addPackageHandler(packageId:String, module:IModule):void
    }
}
