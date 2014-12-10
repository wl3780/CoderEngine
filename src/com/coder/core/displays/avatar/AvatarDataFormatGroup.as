package com.coder.core.displays.avatar
{
	import com.coder.core.protos.Proto;
	import com.coder.engine.Asswc;
	import com.coder.utils.Hash;

	public class AvatarDataFormatGroup extends Proto
	{
		private static var _instanceHash_:Hash = new Hash();
		private static var _recoverQueue_:Vector.<AvatarDataFormatGroup> = new Vector.<AvatarDataFormatGroup>();
		private static var _recoverIndex_:int = 50;

		public var isCreateWarn:Boolean = true;
		public var owner:String;
		public var type:String;
		public var isLoaded:Boolean;
		public var isPend:Boolean;
		public var isDisposed:Boolean = false;
		public var quoteQueue:Vector.<String>;
		public var idName:String;
		public var wealth_path:String;
		public var wealth_id:String;
		
		private var actionGroup:Hash;

		public function AvatarDataFormatGroup()
		{
			super();
			actionGroup = new Hash();
			quoteQueue = new Vector.<String>();
		}
		
		public static function takeAvatarDataFormatGroup(id:String):AvatarDataFormatGroup
		{
			return AvatarDataFormatGroup._instanceHash_.take(id) as AvatarDataFormatGroup;
		}
		
		public static function removeAvatarDataFormatGroup(id:String):void
		{
			AvatarDataFormatGroup._instanceHash_.remove(id);
		}
		
		public static function createAvatarActionDataGroup():AvatarDataFormatGroup
		{
			var result:AvatarDataFormatGroup = null;
			if (_recoverQueue_.length) {
				result = _recoverQueue_.pop();
				result._id_ = Asswc.getSoleId();
			} else {
				result = new AvatarDataFormatGroup();
			}
			AvatarDataFormatGroup._instanceHash_.put(result.id, result);
			return result;
		}

		public function takeAction(action:String):AvatarDataFormat
		{
			return actionGroup.take(action) as AvatarDataFormat;
		}
		
		public function removeAction(action:String):AvatarDataFormat
		{
			return actionGroup.remove(action) as AvatarDataFormat;
		}
		
		public function addAction(action:String, dataFormat:AvatarDataFormat):void
		{
			actionGroup.put(action, dataFormat);
		}
		
		public function hasAction(action:String):Boolean
		{
			return actionGroup.has(action);
		}
		
		public function noticeAvatarActionData():void
		{
			if (this.isLoaded) {
				var data:AvatarActionData = null;
				var index:int = 0;
				while (index < quoteQueue.length) {
					data = AvatarActionData.takeAvatarData(quoteQueue[index]);
					if (data) {
						data.onSetupReady();
					}
					index++;
				}
				quoteQueue = new Vector.<String>();
			}
		}
		
		public function recover():void
		{
			if (isDisposed) {
				return;
			}
			this.dispose();
			if (_recoverQueue_.length < _recoverIndex_) {
				_recoverQueue_.push(this);
			}
		}
		
		override public function dispose():void
		{
			AvatarDataFormatGroup._instanceHash_.remove(this.id);
			super.dispose();
			isDisposed = true;
		}

	}
} 
