package com.coder.utils
{
	import com.coder.core.displays.world.char.Char;
	
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.filters.ColorMatrixFilter;
	import flash.geom.ColorTransform;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	public class HitTest
	{
		private static var pixel:BitmapData = new BitmapData(1, 1, true, 0);
		private static var pixelRect:Rectangle = new Rectangle(0, 0, 1, 1);
		private static var colorTransform:ColorTransform = new ColorTransform(0, 0, 0, 0);
		private static var matrix:Matrix = new Matrix();
		private static var bitmapData:BitmapData = new BitmapData(1, 1, true, 0);

		private static function replacColor(bmd:BitmapData, replaceColor:uint):BitmapData
		{
			var clone:BitmapData = new BitmapData(bmd.width, bmd.height);
			var threshold:int = 0x22000000;
			replaceColor = 0xFFFF0000;
			clone.threshold(bmd, bmd.rect, RecoverUtils.point, ">=", threshold, replaceColor, 4294967295, true);
			return clone;
		}
		
		public static function getChildUnderPoint(parent:DisplayObjectContainer, point:Point, items:Array=null, unHits:Array=null, className:Class=null, alpha:int=10):DisplayObject
		{
			var result:DisplayObject = null;
			var child:*;
			var boundsRect:Rectangle = null;
			var tmpData:BitmapData = null;
			var hitRect:Rectangle = null;
			var tmpAlpha:int;
			if (items) {
				items.sortOn(["type", "y"], [Array.DESCENDING, Array.NUMERIC]);
			}
			if (className == null) {
				className = DisplayObject;
			}
			if (unHits == null) {
				unHits = [];
			}
			for (var i:int = items.length - 1; i >= 0; i--) {
				child = items[i];
				if (child is className && child.type != null) {
					boundsRect = items[i].getBounds(parent);
					hitRect = Char(child).hitTestArea.clone();
					hitRect.x = hitRect.x + child.x;
					hitRect.y = hitRect.y + child.y;
					if (unHits.indexOf(child) == -1 && child.type != "effect" && Char(child).isDeath == false && Char(child).stage) {
						tmpData = bitmapData;
						tmpData.setPixel32(0, 0, 0);
						matrix.tx = -child.mouseX;
						matrix.ty = -child.mouseY;
						tmpData.draw(child, matrix, null, null, pixelRect);
						tmpAlpha = (tmpData.getPixel32(0, 0) >> 24) & 0xFF;
						if (boundsRect.containsPoint(point)) {
							if (tmpAlpha >= alpha) {
								result = child;
								break;
							}
							if (hitRect.containsPoint(point) && tmpAlpha >= 0) {
								result = child;
								break;
							}
						}
					}
				}
			}
			return result;
		}
		
		public static function getChildUnderPointWithDifferentLayer(parent:DisplayObjectContainer, point:Point, items:Array=null, className:Class=null):DisplayObject{
			if (items == null) {
				return null;
			}
			if (className == null) {
				className = DisplayObject;
			}
			var result:DisplayObject = null;
			var child:DisplayObject = null;
			var infos:Array = [];
			for (var i:int = 0; i < items.length; i++) {
				child = items[i];
				if (child is className) {
					var pIndex:int = child.parent.parent.getChildIndex(child.parent) * 1000000;
					infos.push({
						target:child,
						depth:pIndex + child.y
					});
				}
			}
			infos.sortOn("depth", (Array.NUMERIC | Array.DESCENDING));
			
			var tmpData:BitmapData = null;
			var mtx:Matrix = null;
			for (i = infos.length - 1; i >= 0; i--) {
				child = infos[i].target;
				tmpData = new BitmapData(1, 1, true, 0);
				mtx = new Matrix();
				mtx.tx = -(child.mouseX);
				mtx.ty = -(child.mouseY);
				tmpData.draw(child, mtx, null, null, pixelRect);
				var targetAlpha:int = (tmpData.getPixel32(0, 0) >> 24) & 0xFF;
				if (targetAlpha > 40) {
					result = child;
					break;
				}
			}
			return result;
		}
		
		public static function getChildAtPoint(targetParent:DisplayObjectContainer, point:Point, elements:Array=null):DisplayObject
		{
			if (elements == null) {
				elements = targetParent.getObjectsUnderPoint(point);
			}
			var tmpList:Array = [];
			var bounds:Rectangle = null;
			for each (var item:DisplayObject in elements) {
				bounds = item.getBounds(targetParent);
				if (bounds.containsPoint(point)) {
					tmpList.push(item);
				}
			}
			elements = tmpList;
			
			tmpList = [];
			var index:int = 0;
			var cf:ColorTransform = new ColorTransform();
			// 设置颜色，getPixel时需要使用
			for (index = 0; index < elements.length; index++) {
				cf.color = index;
				tmpList.push(elements[index].transform.colorTransform);
				elements[index].transform.colorTransform = cf;
			}
			
			var mtx:Matrix = new Matrix();
			mtx.tx = -point.x;
			mtx.ty = -point.y;
			var tmpData:BitmapData = new BitmapData(1, 1);
			var orgRect:Rectangle = new Rectangle(0, 0, tmpData.width, tmpData.height);
			tmpData.draw(targetParent, mtx, null, null, orgRect);
			var colorIndex:int = tmpData.getPixel(0, 0);
			// 颜色重置回去
			for (index = 0; index < elements.length; index++) {
				elements[index].transform.colorTransform = tmpList[index];
			}
			return elements[colorIndex];
		}
		
		private static function setfilter(index:int):ColorMatrixFilter
		{
			var params:Array = [];
			params = params.concat([1, 0, 0, 2, 0]);
			params = params.concat([1, 0, 0, 2, 0]);
			params = params.concat([1, 0, 0, 2, 0]);
			params = params.concat([1, 0, 0, 1, 0]);
			return new ColorMatrixFilter(params);
		}

	}
}
