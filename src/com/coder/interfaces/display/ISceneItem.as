package com.coder.interfaces.display
{

	public interface ISceneItem extends IDisplay
	{

		function get layer():String;
		function set layer(value:String):void;
		function set char_id(value:String):void;
		function get char_id():String;
		function get stageIntersects():Boolean;
		function get scene_id():String;

	}
}
