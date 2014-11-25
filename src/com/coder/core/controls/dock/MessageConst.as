package com.coder.core.controls.dock
{

	public final class MessageConst
	{
		/**
		 * 发送消息给多个模块
		 */		
		public static const MODULE_TO_MODULE:String = "module_to_module";
		
		/**
		 * 发送消息给所有模块
		 */		
		public static const MODULE_TO_TOTAL_MODULE:String = "module_to_total_module";
		
		/**
		 * 发送消息给网络模块
		 */		
		public static const MODULE_TO_SERVICE:String = "module_to_service";
		
		/**
		 * 发送消息给自身
		 */		
		public static const MODULE_TO_SUB:String = "module_to_sub";
		
		/**
		 * 网络模块专用
		 */		
		public static const SEND_TO_SOCKET:String = "send_to_socket";

	}
}
