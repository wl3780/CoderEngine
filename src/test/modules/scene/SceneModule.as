package test.modules.scene
{
	import com.coder.core.controls.dock.Module;
	import com.coder.interfaces.dock.IMessage;
	import com.coder.utils.log.Log;
	
	import test.protos.scene.toc.Scene_1001_Enter_toc;
	
	public class SceneModule extends Module
	{
		public function SceneModule()
		{
			super();
			this.registerSubProxy
				(
				);
			this.registerPackParser
				(
					Scene_1001_Enter_toc
				);
		}
		
		override public function subHandle(message:IMessage):void
		{
			Log.debug(this, "get message: " + message.actionOrder);
		}
	}
}