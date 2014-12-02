package test.modules.network.orders
{
	public class NetworkInternalOrder
	{
		/**
		 * 连接
		 */		
		public static const CONNECT:String = "CONNECT";
		
		/**
		 * 断开连接
		 */		
		public static const DISCONNECT:String = "DISCONNECT";
		
		/**
		 * 心跳处理
		 */		
		public static const SERVICE_HEARTBEAT:String = "SERVICE_HEARTBEAT";
		
		/**
		 * 跨天处理
		 */		
		public static const SERVICE_CROSSDAY:String = "SERVICE_CROSSDAY";
	}
}