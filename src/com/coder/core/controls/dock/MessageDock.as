package com.coder.core.controls.dock
{
	import com.coder.engine.Asswc;
	import com.coder.interfaces.dock.IMessage;

    public final class MessageDock
	{
        private static var RecoverMessages:Vector.<IMessage> = new Vector.<IMessage>();
		private static var RecoverSize:int = 50;
		
        private static var _instance:MessageDock;

        internal static function getInstance():MessageDock
		{
            return _instance ||= new MessageDock();
        }
		
        internal static function recover(message:IMessage):void
		{
            if (RecoverMessages.length < RecoverSize) {
                RecoverMessages.push(message);
            } else {
                message.dispose();
            }
        }
		
        internal static function produce():IMessage
		{
            var message:Message;
            if (RecoverMessages.length) {
				message = RecoverMessages.pop() as Message;
                message.revive();
	            message.id = Asswc.getSoleId();
            } else {
				message = new Message();
			}
            return message;
        }

        public function send(message:IMessage):void
		{
			switch (message.messageType) {
				case MessageConst.MODULE_TO_MODULE:
	                ModuleDock.getInstance().sendToModules(message);
					break;
				case MessageConst.MODULE_TO_TOTAL_MODULE:
                    ModuleDock.getInstance().sendToTotalModule(message);
					break;
				case MessageConst.MODULE_TO_SERVICE:
                    ModuleDock.getInstance().sendToService(message);
					break;
				case MessageConst.MODULE_TO_SUB:
                    ModuleDock.getInstance().sendToSubs(message);
					break;
			}
        }

    }
}
