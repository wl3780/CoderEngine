package com.coder.utils
{
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.Graphics;
	import flash.geom.Matrix;

	public class GraphicsUtils
	{
		private static var matrix:Matrix = new Matrix();

		public static function draw(graphics:Graphics, bitmapData:BitmapData, pox:int, poy:int, width:int, height:int):void
		{
			var mat:Matrix = matrix;
			mat.identity();
			mat.tx = pox;
			mat.ty = poy;
			graphics.beginBitmapFill(bitmapData, mat);
			graphics.drawRect(pox, poy, width, height);
		}
		
		public static function drawTransformBitmap(target:DisplayObject, containerWidth:Number, containerHeight:Number, noScale:Boolean=false):BitmapData
		{
			var mat:Matrix = getFitMatrix(containerWidth, containerHeight, target.width, target.height, noScale);
			var result:BitmapData = new BitmapData(containerWidth, containerHeight, true, 0);
			result.draw(target, mat, null, null, null, true);
			return result;
		}
		
		public static function getFitMatrix(containerWidth:Number, containerHeight:Number, targetWidth:Number, targetHeight:Number, noScale:Boolean=false):Matrix
		{
			var scale:Number = getScale(containerWidth, containerHeight, targetWidth, targetHeight);
			if (noScale) {
				scale = 1;
			}
			matrix.identity();
			matrix.scale(scale, scale);
			var dx:Number = (containerWidth - (targetWidth * scale)) / 2;
			var dy:Number = (containerHeight - (targetHeight * scale)) / 2;
			matrix.tx = matrix.tx + dx;
			matrix.ty = matrix.ty + dy;
			return matrix;
		}
		
		public static function getScale(width:Number, height:Number, targetWidth:Number, targetHeight:Number):Number
		{
			var minSize:Number = width < height ? width : height;
			var result:Number = targetWidth > targetHeight ? (minSize / targetWidth) : (minSize / targetHeight);
			return result;
		}
	}
}
