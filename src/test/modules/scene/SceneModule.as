package test.modules.scene
{
	import com.coder.core.controls.dock.Module;
	import com.coder.interfaces.dock.IMessage;
	import com.coder.utils.log.Log;
	
	public class SceneModule extends Module
	{
		public function SceneModule()
		{
			super();
			this.registerSubProxy();
		}
		
		override public function subHandle(message:IMessage):void
		{
			Log.debug(this, "get message: " + message.actionOrder);
		}
	}
}