package test.modules.worker
{
	import com.coder.core.controls.dock.Module;
	import com.coder.interfaces.dock.IMessage;
	
	public class WorkerModule extends Module
	{
		public function WorkerModule()
		{
			super();
			this.registerSubProxy
				(
				);
		}
		
		override public function subHandle(message:IMessage):void
		{
			
		}
	}
}