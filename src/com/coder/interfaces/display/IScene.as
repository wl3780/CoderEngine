package com.coder.interfaces.display
{
    public interface IScene
	{
		function addItem(value:ISceneItem, layer:String):void;
		
		function removeItem(value:ISceneItem):void;
		
		function takeItem(char_id:String):ISceneItem;
		
		function sceneMoveTo(x:Number, y:Number):void;
		
		function changeScene(scene_id:int):void;
		
		function dispose():void;
    }
}
