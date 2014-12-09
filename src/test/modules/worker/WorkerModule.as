package test.modules.worker
{
	import com.coder.core.controls.dock.Module;
	import com.coder.interfaces.dock.IMessage;
	
	import flash.events.Event;
	import flash.system.MessageChannel;
	import flash.system.Worker;
	import flash.system.WorkerDomain;
	import flash.utils.ByteArray;
	
	public class WorkerModule extends Module
	{
		private var worker:Worker;
		private var worker2Main:MessageChannel;
		private var main2Worker:MessageChannel;
		
		public function WorkerModule()
		{
			super();
			this.registerSubProxy
				(
				);
			
			worker = WorkerDomain.current.createWorker(null);
			
			worker2Main = worker.createMessageChannel(Worker.current);
			worker2Main.addEventListener(Event.CHANNEL_MESSAGE, onMessageFromWorker);
			worker.setSharedProperty("worker2Main", worker2Main);
			
			main2Worker = Worker.current.createMessageChannel(worker);
			worker.setSharedProperty("main2Worker", main2Worker);
			
			worker.start();
		}
		
		override public function subHandle(message:IMessage):void
		{
			
		}
		
		private function onMessageFromWorker(evt:Event):void
		{
			var bytes:ByteArray;
			var type:int;
			var tmp:* = worker2Main.receive();
			if (tmp is ByteArray) {
				bytes = tmp as ByteArray;
				type = bytes.readByte();
			} else {
				type = tmp as int;
			}
			switch (type) {
				
			}
		}
	}
}