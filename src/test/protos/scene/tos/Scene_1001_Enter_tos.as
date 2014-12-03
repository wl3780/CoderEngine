package test.protos.scene.tos
{
	import com.coder.core.socket.Socket_tos;
	
	import flash.utils.ByteArray;

	public class Scene_1001_Enter_tos extends Socket_tos
	{
		public function Scene_1001_Enter_tos()
		{
			super();
			this.pack_id = 1001;
		}
		
		override public function encode():ByteArray
		{
			return _bytes;
		}
	}
}