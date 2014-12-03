package test.protos.network.tos
{
	import com.coder.core.socket.Socket_tos;
	
	import flash.utils.ByteArray;
	
	public class Network_1001_Heartbeat_tos extends Socket_tos
	{
		public function Network_1001_Heartbeat_tos()
		{
			super();
		}
		
		override public function encode():ByteArray
		{
			return _bytes;
		}
	}
}