package test.modules.network
{
	import com.coder.core.controls.dock.INetworkModule;
	import com.coder.core.controls.dock.Module;
	import com.coder.core.controls.dock.ModuleDock;
	import com.coder.interfaces.dock.IMessage;
	import com.coder.interfaces.dock.IModule;
	import com.coder.utils.Hash;
	import com.coder.utils.log.Log;
	
	import flash.utils.getQualifiedClassName;
	
	import test.modules.network.proxys.SocketProxy;
	
	public class NetworkModule extends Module implements INetworkModule
	{
		public static var packageHash:Hash = new Hash();
		public static var parserHash:Hash = new Hash();
		
		public function NetworkModule()
		{
			super();
			// 网络模块名字约定为 ModuleDock.NETWORK_MODULE_NAME
			this.id = _name_ = ModuleDock.NETWORK_MODULE_NAME;
		}
		
		override public function register():void
		{
			super.register();
			
			// 不能在构造函数中处理，因为register()后，网络模块才生效
			this.registerSubProxy
				(
					SocketProxy
				);
			this.registerSubPackage
				(
				);
		}
		
		override public function subHandle(message:IMessage):void
		{
			Log.debug(this, "get message: " + message.actionOrder);
		}
		
		public function addPackageHandler(packageId:String, module:IModule):void
		{
			var list:Vector.<String> = packageHash.take(packageId) as Vector.<String>;
			if (list == null) {
				list = new Vector.<String>();
				packageHash.put(packageId, list);
			}
			var index:int = list.indexOf(module.name);
			if (index == -1) {
				list.push(module.name);
			}
		}
		
		public function addPackageParser(pClass:Class):void
		{
			var kName:String = getQualifiedClassName(pClass);
			kName = kName.split("::").pop();
			// 约定解释器的命名规则（模块名_数据包id_描述信息_toc）
			var packID:String = kName.split("_")[1];
			parserHash.put(packID, pClass);
		}
	}
}