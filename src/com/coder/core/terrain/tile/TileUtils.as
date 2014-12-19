package com.coder.core.terrain.tile
{
	import com.coder.core.terrain.TileConst;
	import com.coder.engine.Engine;
	import com.coder.utils.geom.LinearUtils;
	
	import flash.display.Graphics;
	import flash.display.GraphicsPathWinding;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	public class TileUtils
	{
		public static var loop_break:Boolean;

		public static function loopRect(index_x:int, index_y:int, loopNum:uint, startDepth:uint, loopFunc:Function, levelFunc:Function=null):void
		{
			var loop:int;
			var loop_height:int;
			var px:int;
			var py:int;
			var dir:int;
			var num:int;
			var k:int;
			var array:Array = null;
			var i:int;
			var j:int;
			var m:int;
			if (loopNum <= 0) {
				throw new Error("loopNum 属性必须大于等于1！");
			}
			if (startDepth < 0) {
				throw new Error("startDepth 属性必须大于等于1！");
			}
			loop_break = false;
			if (startDepth == 0 && loopNum > 0) {
				loopFunc(index_x, index_y);
				if (levelFunc != null) {
					levelFunc(1);
				}
			}
			var startDepth2:Boolean;
			if (startDepth == 0) {
				startDepth2 = true;
				loopNum = loopNum - 1;
			} else {
				startDepth = startDepth - 1;
			}
			index_x = index_x - 2;
			index_y = index_y - 2;
			if (loopNum < 1) {
				return;
			}
			loopNum = startDepth + loopNum;
			var pow:int = 2;
			var n:int = startDepth;
			var loop_low:int = pow * startDepth + 1;
			while (n < loopNum) {
				px = (index_x - (n - 1));
				py = (index_y - (n - 1));
				dir = 1;
				num = 0;
				k = 0;
				loop_height = (loop_low + pow);
				loop = (Math.pow(loop_height, 2) - Math.pow(loop_low, 2));
				array = [];
				i = 0;
				while (i < loop) {
					if ((k % (loop_height - 1)) == 0) {
						num++;
						if ((num % 3) == 0) {
							dir = -(dir);
						}
					}
					(((num % 2))==0) ? px = (px + dir) : py = (py + dir);

					array.push(px);
					array.push(py);
					k++;
					i++;
				}
				py = array.pop();
				px = array.pop();
				array.unshift(py);
				array.unshift(px);
				j = 0;
				while (j < array.length) {
					if (loop_break) {
						return;
					}
					if (loopFunc != null) {
						loopFunc(array[j], array[(j + 1)]);
					}
					j = (j + 2);
				}
				n++;
				loop_low = (loop_low + pow);
				if (startDepth == 0) {
					m = n;
					(startDepth2) ? m = (n + 1) : m = n;

					if (levelFunc != null) {
						levelFunc(m);
					}
				} else {
					if (levelFunc != null) {
						levelFunc((((n + 1) - startDepth) - 1));
					}
				}
			}
		}
		
		public static function getPtDis(pt1:Point, pt2:Point):int
		{
			var indexX:int = Math.abs(pt1.x - pt2.x);
			var indexY:int = Math.abs(pt1.y - pt2.y);
			return Math.max(indexX, indexY);
		}
		
		public static function checkPointSameTileDir(star_point:Point, tar_point:Point):Boolean
		{
			star_point = TileUtils.pixelsAlginTile(star_point.x, star_point.y, star_point);
			tar_point = TileUtils.pixelsAlginTile(tar_point.x, tar_point.y, tar_point);
			var p1:Point = TileUtils.pixelsToTile(star_point.x, star_point.y);
			var p2:Point = TileUtils.pixelsToTile(tar_point.x, tar_point.y);
			var k:Number = ((tar_point.y - star_point.y) / (tar_point.x - star_point.x));
			var dir1:int = LinearUtils.getDirection(p1.x, p1.y, p2.x, p2.y);
			var dir2:int = LinearUtils.getDirection(p2.x, p2.y, p1.x, p1.y);
			if ((((((((p1.x == p2.x)) || ((p1.y == p2.y)))) || ((k == 0.5)))) || ((k == -0.5)))) {
				return (true);
			}
			return (false);
		}
		
		public static function getFitPt(curr_pt:Point, tar_pt:Point, size:int=2):Point
		{
			var k:Number = (tar_pt.y - curr_pt.y) / (tar_pt.x - curr_pt.x);
			var indexX:int = curr_pt.x - tar_pt.x;
			var indexY:int = curr_pt.y - tar_pt.y;
			if (curr_pt.x == tar_pt.x && curr_pt.y == tar_pt.y) {
				return curr_pt;
			}
			if (curr_pt.x == tar_pt.x) {
				return (indexY>0) ? LinearUtils.getTileByDir(curr_pt, 0, size) : LinearUtils.getTileByDir(curr_pt, 4, size);
			}
			if (curr_pt.y == tar_pt.y) {
				return (indexX>0) ? LinearUtils.getTileByDir(curr_pt, 6, size) : LinearUtils.getTileByDir(curr_pt, 2, size);
			}
			if (k == 0.5) {
				return (indexX>0) ? LinearUtils.getTileByDir(curr_pt, 7, size) : LinearUtils.getTileByDir(curr_pt, 3, size);
			}
			if (k == -0.5) {
				return (indexX>0) ? LinearUtils.getTileByDir(curr_pt, 5, size) : LinearUtils.getTileByDir(curr_pt, 1, size);
			}
			return get16Grids(curr_pt, tar_pt);
		}
		
		public static function get16Grids(pt:Point, tarPt:Point):Point
		{
			var i:int;
			var p:Point = null;
			var j:int;
			var pp:Point = null;
			var tile:Tile = null;
			var array:Array = [];
			var arr:Array = TileGroup.instance.get8Grids(pt, TileUtils.getPtDis(pt, tarPt));
			i = 0;
			while (i < arr.length) {
				p = arr[i];
				if (checkPointSameTileDir(p, TileUtils.tileToPixels(tarPt))) {
					array.push(p);
				}
				i++;
			}
			var sx:int = ((pt.x)<tarPt.x) ? pt.x : tarPt.x;
			var sy:int = ((pt.y)<tarPt.y) ? pt.y : tarPt.y;
			var ex:int = ((pt.x)>=tarPt.x) ? pt.x : tarPt.x;
			var ey:int = ((pt.y)>=tarPt.y) ? pt.y : tarPt.y;
			var arrx:Array = [];
			var rect:Rectangle = new Rectangle(sx, sy, Math.abs((pt.x - tarPt.x)), Math.abs((pt.y - tarPt.y)));
			var arr2:Array = [];
			j = 0;
			while (j < array.length) {
				pp = TileUtils.pixelsToTile(array[j].x, array[j].y);
				tile = (TileGroup.instance.take(((pp.x + "|") + pp.y)) as Tile);
				if ((((((((((((pp.x >= sx)) && ((pp.x <= ex)))) && ((pp.y >= sy)))) && ((pp.y <= ey)))) && (tile))) && ((tile.type > 0)))) {
					if (checkPointSameTileDir(array[j], TileUtils.tileToPixels(pt))) {
						arrx.push({
							point:array[j],
							dis1:getPtDis(tarPt, pp),
							dis2:getPtDis(pt, pp)
						});
					} else {
						arr2.push({
							point:array[j],
							dis1:getPtDis(tarPt, pp),
							dis2:getPtDis(pt, pp)
						});
					}
				}
				j++;
			}
			arrx.sortOn(["dis1", "dis2"], [Array.NUMERIC, Array.NUMERIC]);
			if (arrx.length) {
				return (arrx[0].point);
			}
			if ((((arrx.length == 0)) && (arr2.length))) {
				return (arr2[0].point);
			}
			return (TileUtils.tileToPixels(tarPt));
		}
		
		public static function getDepthLoopSun(loopNum:int=1, startDepth:uint=0):int
		{
			loopNum -= 1;
			var startIndex:int = startDepth;
			var endIndex:int = startDepth + loopNum;
			var value:int;
			var i:int = startIndex;
			while (i <= endIndex) {
				value += getDepthLoopValue(i);
				i++;
			}
			return value;
		}
		
		public static function getDepthLoopValue(depth:uint):int
		{
			if (depth == 0) {
				return 1;
			}
			var loop:int = Math.pow(depth * 2 + 1, 2) - Math.pow(depth * 2 + 1 - 2, 2);
			if (loop == 0) {
				return 1;
			}
			return loop;
		}
		
		public static function pixelsToTile(x:Number, y:Number, resultValue:Point=null):Point
		{
			var x2:int = x / TileConst.TILE_WIDTH;
			var y2:int = y / TileConst.TILE_HEIGHT;
			if (resultValue) {
				resultValue.x = x2;
				resultValue.y = y2;
				return resultValue;
			}
			var result:Point = Engine.getPoint();
			result.x = x2;
			result.y = y2;
			return result;
		}
		
		public static function pixelsAlginTile(x:Number, y:Number, resultValue:Point=null):Point
		{
			var x2:int = (x / TileConst.TILE_WIDTH) * TileConst.TILE_WIDTH + TileConst.WH;
			var y2:int = (y / TileConst.TILE_HEIGHT) * TileConst.TILE_HEIGHT + TileConst.HH;
			if (resultValue) {
				resultValue.x = x2;
				resultValue.y = y2;
				return resultValue;
			}
			var result:Point = Engine.getPoint();
			result.x = x2;
			result.y = y2;
			return result;
		}
		
		public static function tileToPixels(tile:Point, resultValue:Point=null):Point
		{
			var x:Number = tile.x * TileConst.TILE_WIDTH + TileConst.WH;
			var y:Number = tile.y * TileConst.TILE_HEIGHT + TileConst.HH;
			if (resultValue) {
				resultValue.x = x;
				resultValue.y = y;
				return resultValue;
			}
			var result:Point = Engine.getPoint();
			result.x = x;
			result.y = y;
			return result;
		}
		
		public static function getGridBoundsPointByDir(point:Point, dir:int):Point
		{
			var pt:Point = TileUtils.pixelsToTile(point.x, point.y);
			var p:Point = new Point();
			if (dir == 0) {
				p.x = point.x;
				p.y = (point.y - TileConst.HH);
			} else if (dir == 1) {
				TileUtils.getTileTopRightPoint(pt, p);
			} else if (dir == 2) {
				p.x = point.x + TileConst.WH - 2;
				p.y = point.y;
			} else if (dir == 3) {
				TileUtils.getTileBottomRightPoint(pt, p);
			} else if (dir == 4) {
				p.x = point.x;
				p.y = point.y + TileConst.HH - 2;
			} else if (dir == 5) {
				TileUtils.getTileBottomLeftPoint(pt, p);
			} else if (dir == 6) {
				p.x = point.x - TileConst.WH;
				p.y = point.y;
			} else if (dir == 7) {
				TileUtils.getTileTopLeftPoint(pt, p);
			}
			return p;
		}
		
		public static function getTileTopLeftPoint(tile:Point, valuePoint:Point=null):Point
		{
			var top_left_x:Number = (TileConst.TILE_WIDTH * tile.x);
			var top_left_y:Number = (TileConst.TILE_HEIGHT * tile.y);
			if (valuePoint) {
				valuePoint.x = top_left_x;
				valuePoint.y = top_left_y;
			}
			return new Point(top_left_x, top_left_y);
		}
		
		public static function getTileTopRightPoint(tile:Point, valuePoint:Point=null):Point
		{
			var top_right_x:Number = (TileConst.TILE_WIDTH * (tile.x + 1));
			var top_right_y:Number = (TileConst.TILE_HEIGHT * tile.y);
			if (valuePoint) {
				valuePoint.x = top_right_x;
				valuePoint.y = top_right_y;
			}
			return new Point(top_right_x, top_right_y);
		}
		
		public static function getTileBottomRightPoint(tile:Point, valuePoint:Point=null):Point
		{
			var bottom_right_x:Number = (TileConst.TILE_WIDTH * (tile.x + 1));
			var bottom_right_y:Number = (TileConst.TILE_HEIGHT * (tile.y + 1));
			if (valuePoint) {
				valuePoint.x = bottom_right_x;
				valuePoint.y = bottom_right_y;
			}
			return new Point(bottom_right_x, bottom_right_y);
		}
		
		public static function getTileBottomLeftPoint(tile:Point, valuePoint:Point=null):Point
		{
			var bottom_left_x:Number = (TileConst.TILE_WIDTH * tile.x);
			var bottom_left_y:Number = (TileConst.TILE_HEIGHT * (tile.y + 1));
			if (valuePoint) {
				valuePoint.x = bottom_left_x;
				valuePoint.y = bottom_left_y;
			}
			return new Point(bottom_left_x, bottom_left_y);
		}
		
		public static function getTileMidVertex(tile:Point, valuePoint:Point=null):Point
		{
			return tileToPixels(tile, valuePoint);
		}
		
		public static function getTileLeftVertex(tile:Point, valuePoint:Point=null):Point
		{
			var p:Point = tileToPixels(tile);
			if (valuePoint == null) {
				valuePoint = p;
			}
			valuePoint.x = p.x - TileConst.WH;
			valuePoint.y = p.y;
			return valuePoint;
		}
		
		public static function getTileTopVertex(tile:Point, valuePoint:Point=null):Point
		{
			var p:Point = tileToPixels(tile);
			if (valuePoint == null) {
				valuePoint = p;
			}
			valuePoint.x = p.x;
			valuePoint.y = p.y - TileConst.HH;
			return valuePoint;
		}
		
		public static function getTileRightVertex(tile:Point, valuePoint:Point=null):Point
		{
			var p:Point = tileToPixels(tile);
			if (valuePoint == null) {
				valuePoint = p;
			}
			valuePoint.x = p.x + TileConst.WH;
			valuePoint.y = p.y;
			return valuePoint;
		}
		
		public static function getTileBottomVertex(tile:Point, valuePoint:Point=null):Point
		{
			var p:Point = tileToPixels(tile);
			if (valuePoint == null) {
				valuePoint = p;
			}
			valuePoint.x = p.x;
			valuePoint.y = p.y + TileConst.HH;
			return valuePoint;
		}
		
		public static function drawTile(graphics:Graphics, x:Number, y:Number, lineColor:uint, fill:Boolean=false, fillColor:uint=0, fillAlpha:Number=0.5):void
		{
			var p:Point = pixelsToTile(x, y);
			x = p.x;
			y = p.y;
			var top_left_x:Number = TileConst.TILE_WIDTH * x;
			var top_left_y:Number = TileConst.TILE_HEIGHT * y;
			var top_right_x:Number = TileConst.TILE_WIDTH * (x + 1);
			var top_right_y:Number = TileConst.TILE_HEIGHT * y;
			var bottom_right_x:Number = TileConst.TILE_WIDTH * (x + 1);
			var bottom_right_y:Number = TileConst.TILE_HEIGHT * (y + 1);
			var bottom_left_x:Number = TileConst.TILE_WIDTH * x;
			var bottom_left_y:Number = TileConst.TILE_HEIGHT * (y + 1);
			
			var commands:Vector.<int> = new Vector.<int>();
			commands.push(1);
			commands.push(2);
			commands.push(2);
			commands.push(2);
			commands.push(2);
			graphics.lineStyle(1, lineColor, 0.3);
			if (fill) {
				graphics.beginFill(fillColor, fillAlpha);
			}
			var array:Vector.<Number> = new Vector.<Number>();
			array.push(top_left_x, top_left_y);
			array.push(top_right_x, top_right_y);
			array.push(bottom_right_x, bottom_right_y);
			array.push(bottom_left_x, bottom_left_y);
			array.push(top_left_x, top_left_y);
			graphics.drawPath(commands, array, GraphicsPathWinding.NON_ZERO);
		}

	}
} 
