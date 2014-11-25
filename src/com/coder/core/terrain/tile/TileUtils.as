package com.coder.core.terrain.tile
{
	import com.coder.core.terrain.TileConst;
	import com.coder.engine.Engine;
	import com.coder.utils.geom.LinearUtils;
	
	import flash.display.Graphics;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	public class TileUtils {

		public static var loop_break:Boolean;

		public static function loopRect(index_x:int, index_y:int, loopNum:uint, startDepth:uint, loopFunc:Function, levelFunc:Function=null):void{
			var _local20:int;
			var _local19:int;
			var _local16:int;
			var _local18:int;
			var _local17:int;
			var _local15:int;
			var _local13:int;
			var _local21 = null;
			var _local14:int;
			var _local12:int;
			var _local11:int;
			if (loopNum <= 0) {
				throw (new Error("loopNum 属性必须大于等于1！"));
			}
			if (startDepth < 0) {
				throw (new Error("startDepth 属性必须大于等于1！"));
			}
			loop_break = false;
			if ((((startDepth == 0)) && ((loopNum > 0)))) {
				loopFunc(index_x, index_y);
				if (levelFunc != null) {
					levelFunc(1);
				}
			}
			var _local9:Boolean;
			if (startDepth == 0) {
				_local9 = true;
				loopNum = (loopNum - 1);
			} else {
				startDepth = (startDepth - 1);
			}
			index_x = (index_x - 2);
			index_y = (index_y - 2);
			if (loopNum < 1) {
				return;
			}
			loopNum = (startDepth + loopNum);
			var _local8 = 2;
			var _local10:int = startDepth;
			var _local7:int = ((_local8 * startDepth) + 1);
			while (_local10 < loopNum) {
				_local16 = (index_x - (_local10 - 1));
				_local18 = (index_y - (_local10 - 1));
				_local17 = 1;
				_local15 = 0;
				_local13 = 0;
				_local19 = (_local7 + _local8);
				_local20 = (Math.pow(_local19, 2) - Math.pow(_local7, 2));
				_local21 = [];
				_local14 = 0;
				while (_local14 < _local20) {
					if ((_local13 % (_local19 - 1)) == 0) {
						_local15++;
						if ((_local15 % 3) == 0) {
							_local17 = -(_local17);
						}
					}
					(((_local15 % 2))==0) ? _local16 = (_local16 + _local17) : _local18 = (_local18 + _local17);

					_local21.push(_local16);
					_local21.push(_local18);
					_local13++;
					_local14++;
				}
				_local18 = _local21.pop();
				_local16 = _local21.pop();
				_local21.unshift(_local18);
				_local21.unshift(_local16);
				_local12 = 0;
				while (_local12 < _local21.length) {
					if (loop_break) {
						return;
					}
					if (loopFunc != null) {
						loopFunc(_local21[_local12], _local21[(_local12 + 1)]);
					}
					_local12 = (_local12 + 2);
				}
				_local10++;
				_local7 = (_local7 + _local8);
				if (startDepth == 0) {
					_local11 = _local10;
					(_local9) ? _local11 = (_local10 + 1) : _local11 = _local10;

					if (levelFunc != null) {
						levelFunc(_local11);
					}
				} else {
					if (levelFunc != null) {
						levelFunc((((_local10 + 1) - startDepth) - 1));
					}
				}
			}
		}
		public static function getPtDis(pt1:Point, pt2:Point):int{
			var _local3:int = Math.abs((pt1.x - pt2.x));
			var _local4:int = Math.abs((pt1.y - pt2.y));
			return (Math.max(_local3, _local4));
		}
		public static function checkPointSameTileDir(star_point:Point, tar_point:Point):Boolean{
			star_point = TileUtils.pixelsAlginTile(star_point.x, star_point.y, star_point);
			tar_point = TileUtils.pixelsAlginTile(tar_point.x, tar_point.y, tar_point);
			var _local6:Point = TileUtils.pixelsToTile(star_point.x, star_point.y);
			var _local5:Point = TileUtils.pixelsToTile(tar_point.x, tar_point.y);
			var _local7:Number = ((tar_point.y - star_point.y) / (tar_point.x - star_point.x));
			var _local3:int = LinearUtils.getDirection(_local6.x, _local6.y, _local5.x, _local5.y);
			var _local4:int = LinearUtils.getDirection(_local5.x, _local5.y, _local6.x, _local6.y);
			if ((((((((_local6.x == _local5.x)) || ((_local6.y == _local5.y)))) || ((_local7 == 0.5)))) || ((_local7 == -0.5)))) {
				return (true);
			}
			return (false);
		}
		public static function getFitPt(curr_pt:Point, tar_pt:Point, size:int=2):Point{
			var _local6:Number = ((tar_pt.y - curr_pt.y) / (tar_pt.x - curr_pt.x));
			var _local4:int = (curr_pt.x - tar_pt.x);
			var _local5:int = (curr_pt.y - tar_pt.y);
			if ((((curr_pt.x == tar_pt.x)) && ((curr_pt.y == tar_pt.y)))) {
				return (curr_pt);
			}
			if (curr_pt.x == tar_pt.x) {
				return (((_local5)>0) ? LinearUtils.getTileByDir(curr_pt, 0, size) : LinearUtils.getTileByDir(curr_pt, 4, size));
			}
			if (curr_pt.y == tar_pt.y) {
				return (((_local4)>0) ? LinearUtils.getTileByDir(curr_pt, 6, size) : LinearUtils.getTileByDir(curr_pt, 2, size));
			}
			if (_local6 == 0.5) {
				return (((_local4)>0) ? LinearUtils.getTileByDir(curr_pt, 7, size) : LinearUtils.getTileByDir(curr_pt, 3, size));
			}
			if (_local6 == -0.5) {
				return (((_local4)>0) ? LinearUtils.getTileByDir(curr_pt, 5, size) : LinearUtils.getTileByDir(curr_pt, 1, size));
			}
			return (get16Grids(curr_pt, tar_pt));
		}
		public static function get16Grids(pt:Point, tarPt:Point):Point{
			var _local9:int;
			var _local11 = null;
			var _local7:int;
			var _local13 = null;
			var _local10 = null;
			var _local15:Array = [];
			var _local4:Array = TileGroup.instance.get8Grids(pt, TileUtils.getPtDis(pt, tarPt));
			_local9 = 0;
			while (_local9 < _local4.length) {
				_local11 = _local4[_local9];
				if (checkPointSameTileDir(_local11, TileUtils.tileToPixels(tarPt))) {
					_local15.push(_local11);
				}
				_local9++;
			}
			var _local16:int = ((pt.x)<tarPt.x) ? pt.x : tarPt.x;
			var _local14:int = ((pt.y)<tarPt.y) ? pt.y : tarPt.y;
			var _local3:int = ((pt.x)>=tarPt.x) ? pt.x : tarPt.x;
			var _local5:int = ((pt.y)>=tarPt.y) ? pt.y : tarPt.y;
			var _local6:Array = [];
			var _local8:Rectangle = new Rectangle(_local16, _local14, Math.abs((pt.x - tarPt.x)), Math.abs((pt.y - tarPt.y)));
			var _local12:Array = [];
			_local7 = 0;
			while (_local7 < _local15.length) {
				_local13 = TileUtils.pixelsToTile(_local15[_local7].x, _local15[_local7].y);
				_local10 = (TileGroup.instance.take(((_local13.x + "|") + _local13.y)) as Tile);
				if ((((((((((((_local13.x >= _local16)) && ((_local13.x <= _local3)))) && ((_local13.y >= _local14)))) && ((_local13.y <= _local5)))) && (_local10))) && ((_local10.type > 0)))) {
					if (checkPointSameTileDir(_local15[_local7], TileUtils.tileToPixels(pt))) {
						_local6.push({
							point:_local15[_local7],
							dis1:getPtDis(tarPt, _local13),
							dis2:getPtDis(pt, _local13)
						});
					} else {
						_local12.push({
							point:_local15[_local7],
							dis1:getPtDis(tarPt, _local13),
							dis2:getPtDis(pt, _local13)
						});
					}
				}
				_local7++;
			}
			_local6.sortOn(["dis1", "dis2"], [16, 16]);
			if (_local6.length) {
				return (_local6[0].point);
			}
			if ((((_local6.length == 0)) && (_local12.length))) {
				return (_local12[0].point);
			}
			return (TileUtils.tileToPixels(tarPt));
		}
		public static function getDepthLoopSun(loopNum:int=1, startDepth:uint=0):int{
			var _local6:int;
			loopNum = (loopNum - 1);
			var _local3:int = startDepth;
			var _local5:int = (startDepth + loopNum);
			var _local4:int;
			_local6 = _local3;
			while (_local6 <= _local5) {
				_local4 = (_local4 + getDepthLoopValue(_local6));
				_local6++;
			}
			return (_local4);
		}
		public static function getDepthLoopValue(depth:uint):int{
			if (depth == 0) {
				return (1);
			}
			var _local2:int = (Math.pow(((depth * 2) + 1), 2) - Math.pow((((depth * 2) + 1) - 2), 2));
			if (_local2 == 0) {
				return (1);
			}
			return (_local2);
		}
		public static function pixelsToTile(x:Number, y:Number, resultValue:Point=null):Point{
			var _local5:int = (x / TileConst.TILE_WIDTH);
			var _local4:int = (y / TileConst.TILE_HEIGHT);
			if (resultValue) {
				resultValue.x = _local5;
				resultValue.y = _local4;
				return (resultValue);
			}
			return (new Point(_local5, _local4));
		}
		public static function pixelsAlginTile(x:Number, y:Number, resultValue:Point=null):Point{
			var _local6:int = (((x / TileConst.TILE_WIDTH) * TileConst.TILE_WIDTH) + TileConst.WH);
			var _local5:int = (((y / TileConst.TILE_HEIGHT) * TileConst.TILE_HEIGHT) + TileConst.HH);
			if (resultValue) {
				resultValue.x = _local6;
				resultValue.y = _local5;
				return (resultValue);
			}
			var _local4:Point = Engine.getPoint();
			_local4.x = _local6;
			_local4.y = _local5;
			return (_local4);
		}
		public static function tileToPixels(tile:Point, resultValue:Point=null):Point{
			var _local4:Number = ((tile.x * TileConst.TILE_WIDTH) + TileConst.WH);
			var _local3:Number = ((tile.y * TileConst.TILE_HEIGHT) + TileConst.HH);
			if (resultValue) {
				resultValue.x = _local4;
				resultValue.y = _local3;
				return (resultValue);
			}
			return (new Point(_local4, _local3));
		}
		public static function getGridBoundsPointByDir(point:Point, dir:int):Point{
			var _local4:Point = TileUtils.pixelsToTile(point.x, point.y);
			var _local3:Point = new Point();
			if (dir == 0) {
				_local3.x = point.x;
				_local3.y = (point.y - TileConst.HH);
			} else {
				if (dir == 1) {
					TileUtils.getTileTopRightPoint(_local4, _local3);
				} else {
					if (dir == 2) {
						_local3.x = ((point.x + TileConst.WH) - 2);
						_local3.y = point.y;
					} else {
						if (dir == 3) {
							TileUtils.getTileBottomRightPoint(_local4, _local3);
						} else {
							if (dir == 4) {
								_local3.x = point.x;
								_local3.y = ((point.y + TileConst.HH) - 2);
							} else {
								if (dir == 5) {
									TileUtils.getTileBottomLeftPoint(_local4, _local3);
								} else {
									if (dir == 6) {
										_local3.x = (point.x - TileConst.WH);
										_local3.y = point.y;
									} else {
										if (dir == 7) {
											TileUtils.getTileTopLeftPoint(_local4, _local3);
										}
									}
								}
							}
						}
					}
				}
			}
			return (_local3);
		}
		public static function getTileTopLeftPoint(tile:Point, valuePoint:Point=null):Point{
			var _local4:Number = (TileConst.TILE_WIDTH * tile.x);
			var _local3:Number = (TileConst.TILE_HEIGHT * tile.y);
			if (valuePoint) {
				valuePoint.x = _local4;
				valuePoint.y = _local3;
			}
			return (new Point(_local4, _local3));
		}
		public static function getTileTopRightPoint(tile:Point, valuePoint:Point=null):Point{
			var _local4:Number = (TileConst.TILE_WIDTH * (tile.x + 1));
			var _local3:Number = (TileConst.TILE_HEIGHT * tile.y);
			if (valuePoint) {
				valuePoint.x = _local4;
				valuePoint.y = _local3;
			}
			return (new Point(_local4, _local3));
		}
		public static function getTileBottomRightPoint(tile:Point, valuePoint:Point=null):Point{
			var _local4:Number = (TileConst.TILE_WIDTH * (tile.x + 1));
			var _local3:Number = (TileConst.TILE_HEIGHT * (tile.y + 1));
			if (valuePoint) {
				valuePoint.x = _local4;
				valuePoint.y = _local3;
			}
			return (new Point(_local4, _local3));
		}
		public static function getTileBottomLeftPoint(tile:Point, valuePoint:Point=null):Point{
			var _local3:Number = (TileConst.TILE_WIDTH * tile.x);
			var _local4:Number = (TileConst.TILE_HEIGHT * (tile.y + 1));
			if (valuePoint) {
				valuePoint.x = _local3;
				valuePoint.y = _local4;
			}
			return (new Point(_local3, _local4));
		}
		public static function getTileMidVertex(tile:Point, valuePoint:Point=null):Point{
			return (tileToPixels(tile, valuePoint));
		}
		public static function getTileLeftVertex(tile:Point, valuePoint:Point=null):Point{
			var _local3:Point = tileToPixels(tile);
			if (valuePoint == null) {
				valuePoint = _local3;
			}
			valuePoint.x = (_local3.x - TileConst.WH);
			valuePoint.y = _local3.y;
			return (valuePoint);
		}
		public static function getTileTopVertex(tile:Point, valuePoint:Point=null):Point{
			var _local3:Point = tileToPixels(tile);
			if (valuePoint == null) {
				valuePoint = _local3;
			}
			valuePoint.x = _local3.x;
			valuePoint.y = (_local3.y - TileConst.HH);
			return (valuePoint);
		}
		public static function getTileRightVertex(tile:Point, valuePoint:Point=null):Point{
			var _local3:Point = tileToPixels(tile);
			if (valuePoint == null) {
				valuePoint = _local3;
			}
			valuePoint.x = (_local3.x + TileConst.WH);
			valuePoint.y = _local3.y;
			return (valuePoint);
		}
		public static function getTileBottomVertex(tile:Point, valuePoint:Point=null):Point{
			var _local3:Point = tileToPixels(tile);
			if (valuePoint == null) {
				valuePoint = _local3;
			}
			valuePoint.x = _local3.x;
			valuePoint.y = (_local3.y + TileConst.HH);
			return (valuePoint);
		}
		public static function drawTile(graphics:Graphics, x:Number, y:Number, lineColor:uint, fill:Boolean=false, fillColor:uint=0, fillAlpha:Number=0.5):void{
			var _local8:Point = pixelsToTile(x, y);
			x = _local8.x;
			y = _local8.y;
			var _local17:Number = (TileConst.TILE_WIDTH * x);
			var _local16:Number = (TileConst.TILE_HEIGHT * y);
			var _local10:Number = (TileConst.TILE_WIDTH * (x + 1));
			var _local9:Number = (TileConst.TILE_HEIGHT * y);
			var _local15:Number = (TileConst.TILE_WIDTH * (x + 1));
			var _local14:Number = (TileConst.TILE_HEIGHT * (y + 1));
			var _local12:Number = (TileConst.TILE_WIDTH * x);
			var _local13:Number = (TileConst.TILE_HEIGHT * (y + 1));
			var _local11:Vector.<int> = new Vector.<int>();
			_local11.push(1);
			_local11.push(2);
			_local11.push(2);
			_local11.push(2);
			_local11.push(2);
			graphics.lineStyle(1, lineColor, 0.3);
			if (fill) {
				graphics.beginFill(fillColor, fillAlpha);
			}
			var _local18:Vector.<Number> = new Vector.<Number>();
			_local18.push(_local17, _local16);
			_local18.push(_local10, _local9);
			_local18.push(_local15, _local14);
			_local18.push(_local12, _local13);
			_local18.push(_local17, _local16);
			graphics.drawPath(_local11, _local18, "nonZero");
		}

	}
} 
