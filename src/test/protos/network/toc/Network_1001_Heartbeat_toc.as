package test.protos.network.toc
{
	import com.coder.core.socket.Socket_toc;
	
	import flash.utils.ByteArray;
	
	public class Network_1001_Heartbeat_toc extends Socket_toc
	{
		public var sysTime:Number;
		
		public function Network_1001_Heartbeat_toc()
		{
			super();
			this.pack_id = 1001;
		}
		
		override public function decode(byte:ByteArray):void
		{
			super.decode(byte);
			sysTime = readLong();
		}
	}
}