package com.coder.interfaces.display
{

	public interface IChar extends ISceneItem, IInteractiveObject
	{
		function moveTo(x:int, y:int):void;
		
		function moveToTile(index_x:int, index_y:int):void;
	}
}
