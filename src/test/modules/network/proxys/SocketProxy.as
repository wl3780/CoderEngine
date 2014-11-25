package test.modules.network.proxys
{
	import com.coder.core.controls.dock.MessageConst;
	import com.coder.core.controls.dock.SubProxy;
	import com.coder.core.socket.Socket_tos;
	import com.coder.interfaces.dock.IMessage;
	
	import test.modules.network.orders.NetworkInternalOrder;
	
	public class SocketProxy extends SubProxy
	{
		private var _conn:SocketConnection;
		
		public function SocketProxy()
		{
			super();
			_conn = new SocketConnection();
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
	}
}