package com.coder.utils.geom
{
	import com.coder.core.terrain.TileConst;
	import com.coder.core.terrain.tile.TileUtils;
	
	import flash.geom.Point;

	public class LinearUtils
	{
		public static function lineAttck(startPoint:Point, endPoint:Point, interval:int=80):Array
		{
			if (!startPoint || !endPoint) {
				return [];
			}
			var result:Array = [];
			var distance:Number = Point.distance(startPoint, endPoint);
			var count:int = distance / interval;
			var p:Point = null;
			for (var index:int = 0; index < count; index++) {
				p = Point.interpolate(startPoint, endPoint, 1 - (index / count));
				result.push(p);
			}
			return result;
		}
		
		public static function getReverseDir(dir:int):int
		{
			var dirs:Array = [4, 5, 6, 7, 0, 1, 2, 3];
			return dirs[dir];
		}
		
		public static function pointBetweenPoint(pt1:Point, pt2:Point, dis:int):Point
		{
			if (!pt1 || !pt2) {
				return null;
			}
			var result:Point = null;
			var distance:Number = Point.distance(pt1, pt2);
			if (dis >= distance) {
				result = extensionPoint(pt2, pt1, dis - distance);
			} else {
				result = Point.interpolate(pt1, pt2, dis / distance);
			}
			return result;
		}
		
		public static function extensionPoint(pt1:Point, pt2:Point, dis:int):Point
		{
			if (!pt1 || !pt2) {
				return null;
			}
			var distance:Number = Point.distance(pt1, pt2);
			var dx:Number = pt2.x + (dis / distance) * (pt2.x - pt1.x);
			var dy:Number = pt2.y + (dis / distance) * (pt2.y - pt1.y);
			return new Point(dx, dy);
		}
		
		public static function lineSectorAttack(startPoint:Point, endPoint:Point, area:Number, n:int=3, minRadius:int=200):Array
		{
			if (!startPoint || !endPoint) {
				return [];
			}
			var arr:Array = sectorAttack(startPoint, endPoint, area, n, minRadius);
			var result:Array = [];
			for (var i:int = 0; i < arr.length; i++) {
				result[i] = lineAttck(startPoint, arr[i]);
			}
			return result;
		}
		
		public static function sectorAttack(startPoint:Point, endPoint:Point, area:Number, n:int=3, minRadius:int=200):Array
		{
			var sectorArea:Number = area;
			if (sectorArea <= 0) {
				return [];
			}
			
			if (sectorArea > 360) {
				sectorArea = 360;
			}
			sectorArea = angle2Radian(sectorArea);
			var startX:Number = startPoint.x;
			var startY:Number = startPoint.y;
			var distance:Number = Point.distance(startPoint, endPoint);
			var dx:Number = endPoint.x - startPoint.x;
			var dy:Number = endPoint.y - startPoint.y;
			var lineAngle:Number = radian2Angle( Math.atan2(dy, dx) );
			lineAngle = lineAngle - area / 2;
			var oneRadian:Number = sectorArea / n;
			var step:Number = distance / Math.cos(oneRadian / 2);
			var lineRadian:Number = angle2Radian(lineAngle);
			if (minRadius != -1 && distance < minRadius) {
				distance = minRadius;
				endPoint.x = startX + Math.cos(lineRadian) * distance;
				endPoint.y = startY + Math.sin(lineRadian) * distance;
				dx = endPoint.x - startPoint.x;
				dy = endPoint.y - startPoint.y;
				lineAngle = radian2Angle( Math.atan2(dy, dx) );
				lineAngle = lineAngle - (area / 2);
				oneRadian = sectorArea / n;
				step = distance / Math.cos(oneRadian / 2);
				lineRadian = angle2Radian(lineAngle);
			}
			
			var endX:Number = startX + Math.cos(lineRadian) * distance;
			var endY:Number = startY + Math.sin(lineRadian) * distance;
			var result:Array = [];
			result.push(new Point(endX, endY));
			var p:Point = null;
			for (var i:int = 0; i < n; i++) {
				lineRadian = lineRadian + oneRadian;
				var sx:Number = startX + Math.cos(lineRadian - oneRadian / 2) * step;
				var sy:Number = startY + Math.sin(lineRadian - oneRadian / 2) * step;
				var tx:Number = startX + Math.cos(lineRadian) * distance;
				var ty:Number = startY + Math.sin(lineRadian) * distance;
				p = new Point(tx, ty);
				result.push(p);
			}
			return result;
		}
		
		public static function pointIntr(a:Point, b:Point, c:Point, d:Point):Point
		{
			var aren_abc:Number = (a.x - c.x) * (b.y - c.y) - (a.y - c.y) * (b.x - c.x);
			var area_abd:Number = (a.x - d.x) * (b.y - d.y) - (a.y - d.y) * (b.x - d.x);
			if (aren_abc * area_abd >= 0) {
				return null;
			}
			var area_cda:Number = (c.x - a.x) * (d.y - a.y) - (c.y - a.y) * (d.x - a.x);
			var area_cdb:Number = area_cda + aren_abc - area_abd;
			if (area_cda * area_cdb >= 0) {
				return null;
			}
			var t:Number = area_cda / (area_abd - aren_abc);
			var dx:Number = t * (b.x - a.x);
			var dy:Number = t * (b.y - a.y);
			return new Point(a.x + dx, a.y + dy);
		}
		
		public static function dirExtensionPoint(dir:Number, x:Number, y:Number):Point
		{
			var angle:Number = getAngle(dir);
			var radian:Number = angle2Radian(angle);
			var dx:Number = x + Math.cos(radian);
			var dy:Number = y + Math.sin(radian);
			return new Point(dx, dy);
		}
		
		public static function getTileByDir(tileIndex:Point, dir:uint, size:uint):Point
		{
			if (dir == 0 || dir == 4) {
				size = TileConst.TILE_HEIGHT * size;
			} else {
				if (dir == 2 || dir == 6) {
					size = TileConst.TILE_WIDTH * size;
				} else {
					size = TileConst.Tile_XIE * size;
				}
			}
			var tileP:Point = new Point(tileIndex.x, tileIndex.y);
			tileIndex = TileUtils.tileToPixels(tileIndex, tileIndex);
			var valueP:Point = new Point();
			if (dir == 0) {
				valueP.x = tileIndex.x;
				valueP.y = tileIndex.y - TileConst.HH;
			} else if (dir == 1) {
				TileUtils.getTileTopRightPoint(tileP, valueP);
			} else if (dir == 2) {
				valueP.x = tileIndex.x + TileConst.WH - 2;
				valueP.y = tileIndex.y;
			} else if (dir == 3) {
				TileUtils.getTileBottomRightPoint(tileP, valueP);
			} else if (dir == 4) {
				valueP.x = tileIndex.x;
				valueP.y = tileIndex.y + TileConst.HH - 2;
			} else if (dir == 5) {
				TileUtils.getTileBottomLeftPoint(tileP, valueP);
			} else if (dir == 6) {
				valueP.x = tileIndex.x - TileConst.WH;
				valueP.y = tileIndex.y;
			} else if (dir == 7) {
				TileUtils.getTileTopLeftPoint(tileP, valueP);
			}
			var result:Point = LinearUtils.extensionPoint(tileIndex, valueP, size);
			TileUtils.pixelsAlginTile(result.x, result.y, result);
			return result;
		}
		
		public static function getAngle(dir:int):Number
		{
			switch (dir) {
				case 0:
					return -90;
					break;
				case 1:
					return -45;
					break;
				case 2:
					return 0;
					break;
				case 3:
					return 45;
					break;
				case 4:
					return 90;
					break;
				case 5:
					return 135;
					break;
				case 6:
					return -175;
					break;
				case 7:
					return -135;
					break;
			}
			return 0;
		}
		
		public static function getAnglebyDir(tileIndex:Point, dir:int):Number
		{
			var tileP:Point = new Point(tileIndex.x, tileIndex.y);
			tileIndex = TileUtils.tileToPixels(tileIndex, tileIndex);
			var valueP:Point = new Point();
			if (dir == 0) {
				valueP.x = tileIndex.x;
				valueP.y = tileIndex.y - TileConst.HH;
			} else if (dir == 1) {
				TileUtils.getTileTopRightPoint(tileP, valueP);
			} else if (dir == 2) {
				valueP.x = tileIndex.x + TileConst.WH - 2;
				valueP.y = tileIndex.y;
			} else if (dir == 3) {
				TileUtils.getTileBottomRightPoint(tileP, valueP);
			} else if (dir == 4) {
				valueP.x = tileIndex.x;
				valueP.y = tileIndex.y + TileConst.HH - 2;
			} else if (dir == 5) {
				TileUtils.getTileBottomLeftPoint(tileP, valueP);
			} else if (dir == 6) {
				valueP.x = tileIndex.x - TileConst.WH;
				valueP.y = tileIndex.y;
			} else if (dir == 7) {
				TileUtils.getTileTopLeftPoint(tileP, valueP);
			}
			var minP:Point = TileUtils.getTileMidVertex(tileP);
			var dx:Number = minP.x - valueP.x;
			var dy:Number = minP.y - valueP.y;
			var result:Number = radian2Angle( Math.atan2(dy, dx) );
			return result;
		}
		
		public static function getDirection(curr_x:int, curr_y:int, tar_x:Number, tar_y:Number):int
		{
			var dir:int;
			var dx:Number = curr_x - tar_x;
			var dy:Number = curr_y - tar_y;
			var angle:Number = radian2Angle( Math.atan2(dy, dx) );
			if (angle >= -22 && angle < 22) {
				dir = 6;
			} else if (angle >= 22 && angle < 67) {
				dir = 7;
			} else if (angle >= 67 && angle < 112) {
				dir = 0;
			} else if (angle >= 112 && angle < 157) {
				dir = 1;
			} else if (angle >= 157 || angle < -157) {
				dir = 2;
			} else if (angle >= -157 && angle < -112) {
				dir = 3;
			} else if (angle >= -112 && angle < -67) {
				dir = 4;
			} else if (angle >= -67 && angle < -22) {
				dir = 5;
			}
			return dir;
		}
		
		public static function getCharDir(x:int, y:int, tar_x:int, tar_y:int):int
		{
			return LinearUtils.getDirection(x, y, tar_x, tar_y);
		}

		public static function angle2Radian(angle:Number):Number
		{
			return angle * Math.PI / 180;
		}
		
		public static function radian2Angle(radian:Number):Number
		{
			return radian * 180 / Math.PI;
		}
	}
}
