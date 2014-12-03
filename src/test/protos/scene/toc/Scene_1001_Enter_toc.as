package test.protos.scene.toc
{
	import com.coder.core.socket.Socket_toc;
	
	import flash.utils.ByteArray;
	
	public class Scene_1001_Enter_toc extends Socket_toc
	{
		public function Scene_1001_Enter_toc()
		{
			super();
			this.pack_id = 1001;
		}
		
		override public function decode(byte:ByteArray):void
		{
			super.decode(byte);
		}
	}
}