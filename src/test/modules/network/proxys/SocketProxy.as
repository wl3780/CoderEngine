package test.modules.network.proxys
{
	import com.coder.core.controls.dock.MessageConst;
	import com.coder.core.controls.dock.SubProxy;
	import com.coder.core.socket.Socket_toc;
	import com.coder.core.socket.Socket_tos;
	import com.coder.interfaces.dock.IMessage;
	
	import flash.utils.ByteArray;
	import flash.utils.Timer;
	
	import test.modules.network.NetworkModule;
	import test.modules.network.orders.NetworkInternalOrder;
	import test.modules.network.others.SocketEvent;
	
	public class SocketProxy extends SubProxy
	{
		private var _conn:SocketConnection;
		private var _heartTimer:Timer;
		
		public function SocketProxy()
		{
			super();
			_conn = new SocketConnection();
			_conn.addEventListener(SocketEvent.SERVER_CONNECT_FAIL, onConnectFail);
			_conn.addEventListener(SocketEvent.SERVER_CONNECT_SUCCESS, onConnectSuccess);
			_conn.addEventListener(SocketEvent.SERVER_DISCONNECT, onDisconnect);
			
			_conn.addEventListener(SocketEvent.SERVER_ERROR_PARSE, onErrorParse);
			_conn.addEventListener(SocketEvent.SERVER_SUCCESS_PARSE, onSuccessParse);
		}
		
		override public function subHandle(message:IMessage):void
		{
			switch (message.actionOrder) {
				case NetworkInternalOrder.CONNECT:
					var param:Object = message.proto;
					_conn.connect(param.host, param.prot);
					break;
				case NetworkInternalOrder.DISCONNECT:
					_conn.disconnect();
					break;
				case MessageConst.SEND_TO_SOCKET:
					var tos:Socket_tos = message.proto as Socket_tos;
					_conn.sendMessage(tos.pack_id, tos.encode());
					tos.clear();
					break;
			}
		}
		
		private function onConnectFail(evt:SocketEvent):void
		{
		}
		
		private function onConnectSuccess(evt:SocketEvent):void
		{
		}
		
		private function onDisconnect(evt:SocketEvent):void
		{
		}
		
		private function onErrorParse(evt:SocketEvent):void
		{
		}
		
		private function onSuccessParse(evt:SocketEvent):void
		{
			var packID:int = evt.params.packID;
			var packData:ByteArray = evt.params.packData;
			var cls:Class = NetworkModule.parserHash.take(packID) as Class;
			var data:Socket_toc = new cls;
			data.decode(packData);
			
			var geters:Vector.<String> = NetworkModule.packageHash.take(packID) as Vector.<String>;
			if (geters) {
				this.sendToModules(packID+"", geters, data);
			}
		}
	}
}