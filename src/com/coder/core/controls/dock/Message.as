package com.coder.core.controls.dock
{
	import com.coder.core.protos.Proto;
	import com.coder.interfaces.dock.IMessage;
	import com.coder.interfaces.dock.ISocket_tos;
	
	import flash.utils.getQualifiedClassName;

	public final class Message extends Proto implements IMessage
	{
		private var _sender:String;
		private var _actionOrder:String;
		private var _messageType:String;
		private var _geters:Vector.<String>;
		
		private var _isDisposed:Boolean;
		private var _isRevived:Boolean;

		public function Message()
		{
			super();
		}

		public function send():Boolean
		{
			if ( this.checkFormat() ) {
				MessageDock.getInstance().send(this);
				return true;
			}
			return false;
		}
		
		public function get geters():Vector.<String>
		{
			return _geters;
		}
		
		public function get sender():String
		{
			return _sender;
		}
		
		public function get actionOrder():String
		{
			return _actionOrder;
		}
		
		public function get messageType():String
		{
			return _messageType;
		}
		
		public function checkFormat():Boolean
		{
			if (_actionOrder == null || _geters == null || _geters.length == 0) {
				return false;
			}
			return true;
		}
		
		public function setup(actionOrder:String, geters:Vector.<String>, data:Object=null, sender:String=null, messageType:String=MessageConst.MODULE_TO_MODULE):void
		{
			if (sender == null) {
				sender = ModuleDock.DEFAULT_MODULE_NAME;
			}
			_actionOrder = actionOrder;
			_geters = geters;
			_messageType = messageType;
			_sender = sender;
			this.proto = data;
		}
		
		public function recover():void
		{
			MessageDock.recover(this);
		}
		
		override public function dispose():void
		{
			super.dispose();
			_actionOrder = null;
			_geters = null;
			_messageType = null;
			_sender = null;
			
			_isDisposed = true;
			_isRevived = false;
		}
		
		public function revive():void
		{
			_actionOrder = null;
			_geters = null;
			_messageType = null;
			_sender = null;
			
			_isDisposed = false;
			_isRevived = true;
		}
		
		public function get isDisposed():Boolean
		{
			return _isDisposed;
		}
		
		public function get isRevived():Boolean
		{
			return _isRevived;
		}
		
		override public function toString():String
		{
			var kName:String = getQualifiedClassName(this);
			var result:String = "";
			result = result + "[" + kName.substr((kName.indexOf("::") + 2), kName.length) + " " + id + "] \n{\n";
			result = result + " messageType=" + this.messageType + " \n";
			result = result + " actionOrder=" + this.actionOrder + " \n";
			result = result + " sender=" + this.sender + " \n";
			if (messageType != MessageConst.MODULE_TO_TOTAL_MODULE) {
				result = result + " geters=" + this.geters + " \n}\n";
			} else {
				result = result + " geters=total_module \n}\n";
			}
			return result;
		}

		// ---------------------消息发送----------------------
		public static function sendToModule(actionOrder:String, geter:String, data:Object=null, sender:String=null):void
		{
			sendToModules(actionOrder, new <String>[geter], data, sender);
		}
		
		public static function sendToModules(actionOrder:String, geters:Vector.<String>, data:Object=null, sender:String=null):void
		{
			var message:Message = MessageDock.produce() as Message;
			message.setup(actionOrder, geters, data, sender, MessageConst.MODULE_TO_MODULE);
			MessageDock.getInstance().send(message);
		}
		
		public static function sendToTotalModule(actionOrder:String, data:Object=null, sender:String=null):void
		{
			var message:Message = MessageDock.produce() as Message;
			message.setup(actionOrder, ModuleDock.modules, data, sender, MessageConst.MODULE_TO_TOTAL_MODULE);
			MessageDock.getInstance().send(message);
		}
		
		public static function sendToService(data:ISocket_tos, actionOrder:String=null, sender:String=null):void
		{
			var message:Message = MessageDock.produce() as Message;
			if (actionOrder == null) {
				actionOrder = MessageConst.SEND_TO_SOCKET;
			}
			message.setup(actionOrder, new <String>[ModuleDock.NETWORK_MODULE_NAME], data, sender, MessageConst.MODULE_TO_SERVICE);
			MessageDock.getInstance().send(message);
		}
		
		public static function sendToSubs(actionOrder:String, data:Object=null, sender:String=null):void
		{
			if (sender && ModuleDock.modules.indexOf(sender) >= 0) {
				sendToModule(actionOrder, sender, data, sender);
			}
		}
		// ---------------------消息发送----------------------
		
	}
}
