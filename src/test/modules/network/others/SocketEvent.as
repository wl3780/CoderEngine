package test.modules.network.others
{
	import flash.events.Event;

	/**
	 * 服务器通讯事件类
	 */
	public class SocketEvent extends Event
	{

		/**
		 *  掉线
		 */
		public static const SERVER_DISCONNECT:String='server_disconnect';

		/**
		 * 连线成功
		 */
		public static const SERVER_CONNECT_SUCCESS:String="server_connect_success";

		/**
		 * 连线失败
		 */
		public static const SERVER_CONNECT_FAIL:String="server_connect_fail";

		/**
		 * 命令解析错误
		 */
		public static const SERVER_ERROR_PARSE:String="server_error_parse";

		/**
		 * 服务端权限错误
		 */
		public static const SERVER_ERROR_POWER:String="server_error_power";

		/**
		 * 验证码错误
		 */
		public static const SERVER_ERROR_CODE_AUTH_ERROR:String="server_error_code_auth_error";
		
		/**
		 * 登录人数过多
		 * */
		public static const SERVER_ERROR_USER_TOO_MANY:String="server_error_user_too_many";
		
		/**
		 * 未知错误
		 */
		public static const SERVER_ERROR_NO:String="server_error_no";

		/**
		 * construct
		 * @param type		事件类型
		 */
		public function SocketEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
	}
}