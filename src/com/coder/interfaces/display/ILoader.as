package com.coder.interfaces.display
{
	import com.coder.interfaces.dock.IProto;
	
	import flash.system.LoaderContext;

	public interface ILoader extends IProto
	{
		function get path():String;
		
		function get name():String;
		
		function set name(value:String):void;
		
		function unloadAndStop(gc:Boolean=true):void;
		
		function loadElemt(url:String, successFunc:Function=null, errorFunc:Function=null, progressFunc:Function=null, loaderContext:LoaderContext=null):void;
	}
}
