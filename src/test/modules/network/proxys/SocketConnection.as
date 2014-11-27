package test.modules.network.proxys
{
	import com.coder.utils.log.Log;
	
	import flash.errors.IOError;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.Socket;
	import flash.utils.ByteArray;
	
	import test.modules.network.others.SocketEvent;

	/**
	 * 与服务器通讯类
	 */
	public class SocketConnection extends Socket
	{
		public var packList:Vector.<Array> = new Vector.<Array>();
		
		/**
		 * 是否和服务器保持连接在
		 */
		private var _connected:Boolean = false;

		/**
		 * 服务器地址
		 */
		private var _serverHost:String;

		/**
		 * 服务器端口
		 */
		private var _serverPort:int;

		/**
		 * 读取的二进制数据缓冲区
		 */
		private var _buf:ByteArray;

		/**
		 * 数据头长度（定义了对象直接流大小）
		 */
		private const HEADER_LEN:int = 8;

		/**
		 * 最大重发指令次数
		 */
		private const MAX_SEND:int = 2;
		
		private const MAX_BUFSIZE:int = 200000;

		/**
		 * 顶部包头
		 */
		private const PACKAGE_HEAD:int = -1860168940;

		public function SocketConnection(host:String=null, port:int=0)
		{
			super(host, port);
			_buf = new ByteArray();
			
			this.addEventListener(IOErrorEvent.IO_ERROR, onIOError);
			this.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onIOError);
			this.addEventListener(Event.CONNECT, onConnect);
		}
		
		public function get host():String
		{
			return _serverHost;
		}
		public function get port():int
		{
			return _serverPort;
		}

		/**
		 * 与服务端建立连接
		 */
		override public function connect(host:String, port:int):void
		{
			_serverHost = host;
			_serverPort = port;
			super.connect(host, port);
		}

		/**
		 * socket连接
		 */
		private function onConnect(e:Event):void
		{
			Log.info(this, "SERVER [" + _serverHost + ":" + _serverPort + "] CONNECTED...");
			// 侦听数据
			if (this.hasEventListener(ProgressEvent.SOCKET_DATA)) {
				this.removeEventListener(ProgressEvent.SOCKET_DATA, onSocketData);
			}
			this.addEventListener(ProgressEvent.SOCKET_DATA, onSocketData, false, 0, true);
			if (this.hasEventListener(Event.CLOSE)) {
				this.removeEventListener(Event.CLOSE, onDisconnect);
			}
			this.addEventListener(Event.CLOSE, onDisconnect);
			_connected = true;
			this.dispatchEvent(new SocketEvent(SocketEvent.SERVER_CONNECT_SUCCESS));
		}

		/**
		 * 断开socket连接回调
		 */
		private function onDisconnect(evt:Event):void
		{
			_connected = false;
			this.dispatchEvent(new SocketEvent(SocketEvent.SERVER_DISCONNECT));
		}

		/**
		 * 连接IO错误
		 * @param evt
		 *
		 */
		private function onIOError(evt:Event):void
		{
			if (evt is IOErrorEvent) {
				Log.error(this, IOErrorEvent(evt).text);
			} else if (evt is SecurityErrorEvent) {
				Log.error(this, SecurityErrorEvent(evt).text);
			}
			this.dispatchEvent(new SocketEvent(SocketEvent.SERVER_CONNECT_FAIL));
		}

		/**
		 * 关闭当前连接
		 */
		public function disconnect():void
		{
			_connected = false;
			this.close();
		}

		/**
		 * 获得服务器的数据
		 * @param evt
		 */
		private function onSocketData(evt:ProgressEvent):void
		{
			this.readBytes(_buf, _buf.length, this.bytesAvailable);
			if (_buf.length >= MAX_BUFSIZE && _buf.position) {
				var tmpBuf:ByteArray = new ByteArray();
				_buf.readBytes(tmpBuf, _buf.position, _buf.bytesAvailable);
				_buf.clear();
				_buf = tmpBuf;
			}
//			parseResponse();
		}

		private function parseResponse():Boolean
		{
			if (_buf.bytesAvailable >= 10) {
//				var packHead:String = _buf.readByte() + "" + _buf.readByte() + "" + _buf.readByte() + "" + _buf.readByte();
//				if (packHead != "5120") {
//					return false;
//				}
				var logPosition:int = _buf.position;
				_buf.position += 4;
				var packLen:int = _buf.readInt();
				if (packLen > _buf.bytesAvailable) {
					_buf.position = logPosition;
					return false;
				}
				var packID:int = _buf.readShort();
				var packData:ByteArray = new ByteArray();
				packLen -= 2;
				_buf.readBytes(packData, 0, packLen);
				return true;
			}
			return false;
		}
		
		private var _readFlag:int;
		private var _packID:int;
		private var _packLen:int;
		public static const PREV_READ:int = 6;
		private function onSocketData2(evt:ProgressEvent):void
		{
			var bytesRest:int = this.bytesAvailable;
			while (bytesRest) {
				if (_readFlag == 0) {
					if (bytesRest >= PREV_READ) {
						this.readBytes(_buf, _buf.length, PREV_READ);
						_packLen = _buf.readInt();
						_packID = _buf.readShort();
						_packLen -= PREV_READ;
						_readFlag = 1;
						bytesRest = this.bytesAvailable;
					} else {
						break;
					}
				}
				if (_readFlag == 1) {
					if (_packLen) {
						if (bytesRest <= _packLen) {
							this.readBytes(_buf, _buf.length, bytesRest);
							_packLen -= bytesRest;
						} else {
							this.readBytes(_buf, _buf.length, _packLen);
							_packLen = 0;
						}
					}
					if (_packLen == 0) {
						_readFlag = 0;
						this.handleMessage(_packID, _buf);
						_buf.clear();
					}
					bytesRest = this.bytesAvailable;
				}
			}
		}
		private function handleMessage(packID:int, packData:ByteArray):void
		{
			
		}

		/**
		 * 发送信息
		 */
		public function sendMessage(packID:int, packData:ByteArray):void
		{
			if (_connected) {
				this.writeToSocket(packID, packData);				
			}
		}

		/**
		 * 写进Socket
		 * @param request
		 */
		private function writeToSocket(packID:int, packData:ByteArray):void {
			var byte:ByteArray = new ByteArray();
			// 协议头，用于校验（节省资源可以忽略）
			byte.writeByte(5);
			byte.writeByte(1);
			byte.writeByte(2);
			byte.writeByte(0);
			
			var packLen:int = packData.length + 2 + 4;
			byte.writeInt(packLen);
			byte.writeShort(packID);
			byte.writeBytes(packData);
			
			try {
				this.writeBytes(byte);
				this.flush();
			} catch (e:IOError) {
				Log.error(this, e.message);
			}
		}
	}
}