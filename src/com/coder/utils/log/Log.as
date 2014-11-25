package com.coder.utils.log
{
	import flash.utils.getQualifiedClassName;

	/**
	 * Log 输出记录
	 */
	public class Log
	{
		public static var arrLog:Vector.<String> = new Vector.<String>();
		
		private static var _logLevel:int = LogLevel.ERROR;
		private static var _logCallFun:Function;
		private static var _logIndex:int=0;
		
		public function Log()
		{
		}
		
		public static function debug(cla:*, msg:String, ... args):void
		{
			logTrace(LogLevel.DEBUG, cla, msg);
		}
		
		public static function error(cla:*,msg:String, ... args):void
		{
			logTrace(LogLevel.ERROR, cla, msg);
		}
		
		public static function info(cla:*, msg:String, ... args):void
		{
			logTrace(LogLevel.INFO, cla, msg);
		}
		
		public static function warn(cla:*, msg:String, ... args):void
		{
			logTrace(LogLevel.WARN, cla, msg);
		}
		
		public static function fatal(cla:*, msg:String, ... args):void
		{
			logTrace(LogLevel.FATAL, cla, msg);
		}
		
		public static function all(cla:*, msg:String, ... args):void
		{
			logTrace(LogLevel.ALL, cla, msg);
		}
		
		/**
		 * 日志输 
		 * @param logLevel
		 * @param cla
		 * @param msg
		 * 
		 */
		protected static function logTrace(logLevel:int, cla:*, msg:String, ... args):void
		{
			if(logLevel >= _logLevel && msg) {
				var infoDesc:String = "";
				if(cla) {
					infoDesc = getQualifiedClassName(cla).replace("::", ".");
				}
				var date:Date = new Date();
				var timeStr:String= date.hours+":"+date.minutes+":"+date.seconds+":"+date.milliseconds;
				var msg:String = "【"+LogLevel.LogDesc(logLevel)+"】"+ timeStr + " : " + infoDesc + " :: " + msg;
				trace(msg);
				
				addLog(msg);
				if(_logCallFun != null) {
					_logCallFun(msg);
				}
			}
		} 
		
		/**
		 * 设置Log 输出级别
		 * 
		 * @param logLevel Log级别
		 * 
		 */
		public static function setLogLevel(logLevel:int):void
		{
			_logLevel = logLevel;
		}
		
		/**
		 * 设置log输出时， 
		 * @param logCallFun
		 * 
		 */
		public static function setLogCallFun(logCallFun:Function):void
		{
			_logCallFun = logCallFun;
		}
		
		/**
		 *	把log加入数组 
		 * @param msg
		 * 
		 */		
		private static function addLog(msg:String):void
		{
			if(arrLog.length > 80) {
				arrLog.shift();
			}
			arrLog.push(msg);
			_logIndex ++;
			if(_logIndex >= 100) {
				_logIndex = 0;
			}
		}
	}
}