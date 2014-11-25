package com.coder.utils.log
{
	/**
	 * Log输出级别
	 */
	public class LogLevel
	{
		/**
		 *  Designates events that are very
		 *  harmful and will eventually lead to application failure.
		 */
		public static const FATAL:int = 1000;
		
		/**
		 *  Designates error events that might
		 *  still allow the application to continue running.
		 */
		public static const ERROR:int = 8;
		
		/**
		 *  Designates events that could be
		 *  harmful to the application operation.
		 */
		public static const WARN:int = 6;
		
		/**
		 *  Designates informational messages that
		 *  highlight the progress of the application at coarse-grained level.
		 */
		public static const INFO:int = 4;
		
		/**
		 *  Designates informational level
		 *  messages that are fine grained and most helpful when debugging an
		 *  application.
		 */
		public static const DEBUG:int = 2;
		
		/**
		 *  Tells a target to process all messages.
		 */
		public static const ALL:int = 0;
		
		public static function LogDesc(logLevel:int):String
		{
			var desc:String = null;
			switch (logLevel) {
				case FATAL:
					desc = "FATAL";
					break;
				case ERROR:
					desc = "ERROR";
					break;
				case WARN:
					desc = "WARN";
					break;
				case INFO:
					desc = "INFO";
					break;
				case DEBUG:
					desc = "DEBUG";
					break;
				case ALL:
					desc = "ALL";
					break;
				default:
					desc = "ALL";
			}
			return desc;
		}
	}
}