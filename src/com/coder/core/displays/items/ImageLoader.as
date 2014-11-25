package com.coder.core.displays.items
{
	import flash.display.Loader;

	public class ImageLoader extends Loader
	{
		public var data:Object;

		public function dispose():void
		{
			this.unloadAndStop(true);
			this.data = null;
		}

	}
}
