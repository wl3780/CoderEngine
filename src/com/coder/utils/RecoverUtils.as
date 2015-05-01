package com.coder.utils
{
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.text.TextFormat;

	/**
	 * 重用资源
	 */	
	public class RecoverUtils
	{
		public static var matrix:Matrix = new Matrix();
		
		public static var point:Point = new Point();
		
		public static var rect:Rectangle = new Rectangle();
		
		public static var textFromat:TextFormat = new TextFormat();
	}
}
