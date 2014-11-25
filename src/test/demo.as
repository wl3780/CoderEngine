package test
{
	import com.coder.engine.Engine;
	
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageQuality;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	
	import test.modules.ModuleConst;
	import test.modules.network.NetworkModule;
	
	public class demo extends Sprite
	{
		public function demo()
		{
			super();
			if (this.stage) {
				this.init(null);
			} else {
				this.addEventListener(Event.ADDED_TO_STAGE, init);
			}
		}
		
		private function init(evt:Event):void
		{
			this.removeEventListener(Event.ADDED_TO_STAGE, init);
			
			this.stage.align = StageAlign.TOP_LEFT;
			this.stage.scaleMode = StageScaleMode.NO_SCALE;
			this.stage.quality = StageQuality.MEDIUM;
			
			Engine.instance.setup(this, ModuleConst, "", NetworkModule, trace);
		}
	}
}