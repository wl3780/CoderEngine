package com.coder.core.terrain.astar
{
	import com.coder.core.displays.world.Scene;
	import com.coder.core.terrain.tile.Tile;
	import com.coder.core.terrain.tile.TileUtils;
	import com.coder.utils.geom.LinearUtils;
	
	import flash.display.Graphics;
	import flash.geom.Point;
	import flash.utils.Dictionary;
	import flash.utils.getTimer;

	public class TileAstar
	{
		private static const COST_STRAIGHT:int = 10;
		private static const COST_DIAGONAL:int = 14;
		private static const DIR_TC:String = "tc";
		private static const DIR_CL:String = "cl";
		private static const DIR_CR:String = "cr";
		private static const DIR_BC:String = "bc";

		private static var newStartPt:Point;
		private static var keyIndex:Point;

		public var g:Graphics;
		private var nonce:TileAstarData;
		private var isFinish:Boolean;
		private var G:int;
		private var source:Dictionary;
		private var startPoint:Point;
		private var _endPoint:Point;
		private var colsePath:Dictionary;
		private var colseArray:Array;
		private var openPath:Dictionary;
		private var openArray:Array;
		private var pathArray:Array;
		private var canTL:Boolean;
		private var canTR:Boolean;
		private var canBL:Boolean;
		private var canBR:Boolean;
		private var canTC:Boolean;
		private var canCL:Boolean;
		private var canCR:Boolean;
		private var canBC:Boolean;
		private var closeLength:int;
		public var mode:int = 1;

		public static function loopRect(index_x:int, index_y:int, loopNum:uint, dic:Dictionary, type:int, indexPt:Point):Point{
			var _local11:int;
			var _local21:int;
			var _local20:int;
			var _local22:int;
			var _local10:int;
			var _local19:int;
			var _local16:int;
			var _local17:Boolean;
			var _local18:int;
			var _local13:String = null;
			var _local24:Tile = null;
			var _local9:int;
			var _local12:Boolean;
			var _local23:int;
			var _local14:int;
			index_x = (index_x - 2);
			index_y = (index_y - 2);
			loopNum = (_local14 + loopNum);
			var _local8:int = 2;
			var _local15:int = _local14;
			var _local7:int = ((_local8 * _local14) + 1);
			var _local25:Array = [];
			while (_local15 < loopNum) {
				_local20 = (index_x - (_local15 - 1));
				_local22 = (index_y - (_local15 - 1));
				_local10 = 1;
				_local19 = 0;
				_local16 = 0;
				_local21 = (_local7 + _local8);
				_local11 = (Math.pow(_local21, 2) - Math.pow(_local7, 2));
				_local17 = false;
				_local18 = 0;
				while (_local18 < _local11) {
					if ((_local16 % (_local21 - 1)) == 0) {
						_local19++;
						if ((_local19 % 3) == 0) {
							_local10 = -(_local10);
						}
					}
					(((_local19 % 2))==0) ? _local20 = (_local20 + _local10) : _local22 = (_local22 + _local10);

					_local13 = ((_local20 + "|") + _local22);
					_local24 = dic[_local13];
					if (((((_local24) && (!((_local24.type == 0))))) && (!((_local24.type == type))))) {
						_local9 = LinearUtils.getCharDir(index_x, index_y, _local20, _local22);
						_local12 = false;
						if (((!(Scene.scene.mainChar.isLoopMove)) && (!((Scene.scene.mapData.map_id == 10291))))) {
							_local12 = true;
						}
						_local23 = LinearUtils.getCharDir(Scene.scene.mainChar.x, Scene.scene.mainChar.y, Scene.scene.mouseX, Scene.scene.mouseY);
						if (!newStartPt) {
							_local25.push({
								tile:_local24,
								dis:Point.distance(_local24.pt, indexPt)
							});
						} else {
							if (_local24.pt.toString() != newStartPt.toString()) {
								if (((fineFaceTile(_local23, _local9)) || (_local12))) {
									_local25.push({
										tile:_local24,
										dir:_local9,
										dis:Point.distance(_local24.pt, indexPt)
									});
									_local17 = true;
								}
							}
						}
					}
					_local16++;
					_local18++;
				}
				if (_local17) {
					if (_local25.length) {
						_local25.sortOn(["dis", "dir"], [16, 16]);
						return _local25[0].tile.pt;
					}
					return null;
				}
				_local15++;
				_local7 = (_local7 + _local8);
			}
			return null;
		}
		public static function fineFaceTile(faceDir:int, averDir:int):Boolean{
			var _local5:int;
			var _local3:int;
			var _local4:int = (faceDir - 2);
			var _local6:Array = [(faceDir - 1), faceDir, (faceDir + 1)];
			_local5 = 0;
			while (_local5 < _local6.length) {
				_local3 = _local6[_local5];
				if (_local3 < 0) {
					_local6[_local5] = (8 - _local3);
				}
				_local5++;
			}
			if (_local6.indexOf(averDir) == -1) {
				return false;
			}
			return true;
		}
		public static function cleanPath(array:Array):Array{
			var _local7:int;
			var _local5:Point = null;
			var _local2:Point = null;
			var _local3:Point = null;
			var _local4:Number;
			var _local6:Number;
			if (array.length > 2) {
				_local7 = 1;
				while (_local7 < (array.length - 1)) {
					_local5 = array[(_local7 - 1)];
					_local2 = array[_local7];
					_local3 = array[(_local7 + 1)];
					_local4 = ((_local5.y - _local2.y) / (_local5.x - _local2.x));
					_local6 = ((_local2.y - _local3.y) / (_local2.x - _local3.x));
					if (_local4 == _local6) {
						array.splice(_local7, 1);
						_local7--;
					}
					_local7++;
				}
			}
			return array;
		}

		public function getPath(source:Dictionary, start_x:int, start_y:int, end_x:int, end_y:int, isFineNear:Boolean=true, breakSetp:int=10000):Array{
			var _local13:Tile = null;
			var _local12:Tile = null;
			var _local15:Point = new Point(start_x, start_y);
			var _local11:Point = new Point(end_x, end_y);
			var _local8:String = ((start_x + "|") + start_y);
			var _local9:String = ((end_x + "|") + end_y);
			if (source[_local8]) {
				_local13 = (source[_local8] as Tile);
				_local12 = (source[_local9] as Tile);
			}
			var _local10:Number = getTimer();
			reSet();
			this.startPoint = loopCheck(source, _local15, 8);
			newStartPt = _local15;
			this.endPoint = loopCheck(source, _local11, 8);
			if ((((this.endPoint == null)) || ((_local15 == null)))) {
				return [];
			}
			this.source = source;
			this.nonce = new TileAstarData(0, 0, this.startPoint);
			this.nonce.parent = this.nonce;
			this.colsePath[this.nonce.key] = this.nonce;
			while (this.isFinish) {
				getScale9Grid(source, this.nonce, this.endPoint.clone(), breakSetp);
			}
			var _local14:Array = cleanArray();
			return _local14;
		}
		public function stop():void{
			this.isFinish = false;
		}
		private function loopCheck(source:Dictionary, indexPt:Point, level:int):Point{
			var _local4:Point = null;
			var _local6:int = ((mode)==1) ? 2 : 1;
			var _local5:String = ((indexPt.x + "|") + indexPt.y);
			if ((((((source[_local5] == null)) || ((source[_local5].type == 0)))) || ((source[_local5].type == _local6)))) {
				keyIndex = indexPt;
				_local4 = loopRect(indexPt.x, indexPt.y, level, source, _local6, indexPt);
				if (_local4 == null) {
					this.isFinish = false;
				}
				return _local4;
			}
			return indexPt;
		}
		private function getDis(point:Point, endPoint:Point):int{
			var _local3:int = (endPoint.x - point.x);
			((_local3)<0) ? _local3 = -(_local3) : _local3;
			var _local4:int = (endPoint.y - point.y);
			((_local4)<0) ? _local4 = -(_local4) : _local4;
			return _local3 + _local4;
		}
		private function pass(square:Tile):Boolean{
			return square.type>0 ? true : false;
		}
		private function stratght(tar:Tile, endPt:Point, type:String):void{
			var _local14:String = null;
			var _local11:Point = null;
			var _local15:int;
			var _local13:int;
			var _local5:int;
			var _local6:int;
			var _local9:int;
			var _local10:int;
			var _local8:int;
			var _local4:TileAstarData = null;
			var _local12 = null;
			var _local7 = null;
			if (tar != null) {
				if (pass(tar)) {
					_local14 = tar.key;
					_local11 = tar.pt;
					_local15 = tar.x;
					_local13 = tar.y;
					_local5 = Math.abs((endPt.x - _local15));
					_local6 = Math.abs((endPt.y - _local13));
					_local9 = ((_local5 + _local6) * 10);
					_local10 = (10 + G);
					_local8 = (_local10 + _local9);
					_local4 = new TileAstarData(_local10, _local8, _local11);
//					((_local4.parent)==null) ? var _local16 = this.nonce;
//_local4.parent = _local16;
//_local16 : "";
					_local12 = openPath[_local14];
					_local7 = colsePath[_local14];
					if ((((_local12 == null)) && ((_local7 == null)))) {
						openPath[_local14] = _local4;
						this.openArray.push(_local4);
					} else {
						if (_local12 != null) {
//							((_local4.F)<_local12.F) ? _local16 = _local4;
//openPath[_local14] = _local16;
//_local16 : "";
						}
					}
				} else {
					if (type == "tc") {
						this.canTC = false;
					} else {
						if (type == "cl") {
							this.canCL = false;
						} else {
							if (type == "cr") {
								this.canCR = false;
							} else {
								if (type == "bc") {
									this.canBC = false;
								}
							}
						}
					}
				}
			} else {
				if (type == "tc") {
					this.canTC = false;
				} else {
					if (type == "cl") {
						this.canCL = false;
					} else {
						if (type == "cr") {
							this.canCR = false;
						} else {
							if (type == "bc") {
								this.canBC = false;
							}
						}
					}
				}
			}
		}
		private function diagonal(tar:Tile, endPt:Point, can:Boolean):void{
			var _local12 = null;
			var _local8 = null;
			var _local10:int;
			var _local11:int;
			var _local5:int;
			var _local6:int;
			var _local7 = null;
			var _local9 = null;
			var _local4 = null;
			if (((can) && (!((tar == null))))) {
				if (this.pass(tar)) {
					_local12 = tar.key;
					_local8 = tar.pt;
					_local10 = Math.abs((endPt.x - tar.x));
					_local11 = Math.abs((endPoint.y - tar.y));
					_local5 = ((_local10 + _local11) * 10);
					_local6 = (14 + G);
					_local7 = new TileAstarData(_local6, (_local6 + _local5), _local8);
//					((_local7.parent)==null) ? var _local13 = this.nonce;
//_local7.parent = _local13;
//_local13 : "";
					_local9 = openPath[_local12];
					_local4 = colsePath[_local12];
					if ((((_local9 == null)) && ((_local4 == null)))) {
						openPath[_local12] = _local7;
						this.openArray.push(_local7);
					} else {
						if (_local9 != null) {
//							((_local7.F)<_local9.F) ? _local13 = _local7;
//openPath[_local12] = _local13;
//_local13 : "";
						}
					}
				}
			}
		}
		private function getScale9Grid(source:Dictionary, data:TileAstarData, endPoint:Point, breakSetp:int):void{
			var _local7 = null;
			var _local21:int;
			var _local8 = null;
			this.canBL = true;
			this.canBR = true;
			this.canTL = true;
			this.canTR = true;
			this.canTC = true;
			this.canCR = true;
			this.canCL = true;
			this.canBC = true;
			var _local24:Point = data.pt;
			var _local26:int = _local24.x;
			var _local25:int = _local24.y;
			var _local11:int = (_local26 + 1);
			var _local20:int = (_local25 + 1);
			var _local12:int = (_local26 - 1);
			var _local18:int = (_local25 - 1);
			var _local5:Tile = source[((_local12 + "|") + _local18)];
			var _local6:Tile = source[((_local11 + "|") + _local18)];
			var _local14:Tile = source[((_local12 + "|") + _local20)];
			var _local9:Tile = source[((_local11 + "|") + _local20)];
			var _local13:Tile = source[((_local26 + "|") + _local18)];
			var _local23:Tile = source[((_local12 + "|") + _local25)];
			var _local22:Tile = source[((_local11 + "|") + _local25)];
			var _local15:Tile = source[((_local26 + "|") + _local20)];
			if (_local13) {
				stratght(_local13, endPoint, "tc");
			}
			if (_local23) {
				stratght(_local23, endPoint, "cl");
			}
			if (_local22) {
				stratght(_local22, endPoint, "cr");
			}
			if (_local15) {
				stratght(_local15, endPoint, "bc");
			}
			if (_local5) {
				diagonal(_local5, endPoint, canTL);
			}
			if (_local6) {
				diagonal(_local6, endPoint, canTR);
			}
			if (_local14) {
				diagonal(_local14, endPoint, canBL);
			}
			if (_local9) {
				diagonal(_local9, endPoint, canBR);
			}
			var _local19:int = openArray.length;
			if ((((_local19 == 0)) || ((((((((((((((((_local13 == null)) && ((_local23 == null)))) && ((_local22 == null)))) && ((_local15 == null)))) && ((_local5 == null)))) && ((_local6 == null)))) && ((_local14 == null)))) && ((_local9 == null)))))) {
				this.isFinish = false;
				return;
			}
			var _local17:int;
			_local21 = 0;
			while (_local21 < _local19) {
				_local8 = openArray[_local21];
				if (_local21 == 0) {
					_local7 = _local8;
				} else {
					if (_local8.F < _local7.F) {
						_local7 = _local8;
						_local17 = _local21;
					}
				}
				_local21++;
			}
			this.nonce = _local7;
			this.openArray.splice(_local17, 1);
			var _local16:String = this.nonce.key;
			if (this.colsePath[_local16] == null) {
				this.colsePath[_local16] = this.nonce;
				this.closeLength = (this.closeLength + 1);
				if (closeLength > breakSetp) {
					this.isFinish = false;
				}
			}
			var _local10:String = ((endPoint.x + "|") + endPoint.y);
			if (this.nonce.key == _local10) {
				this.isFinish = false;
			}
			this.G = this.nonce.G;
		}
		public function pathCutter(array:Array, size:int=2):Array{
			var _local4:Array = null;
			var _local5:int;
			var _local6:int;
			var _local3:Array = [];
			_local5 = 0;
			while (_local5 < array.length) {
				if ((_local5 % size) == 0) {
					_local4 = [];
					if (_local3.length > 0) {
						_local4.push(array[(_local5 - 1)]);
					}
					_local3.push(_local4);
				}
				_local4.push(array[_local5]);
				_local5++;
			}
			_local6 = 0;
			while (_local6 < _local3.length) {
				_local3[_local6] = cleanPath(_local3[_local6]);
				_local6++;
			}
			return _local3;
		}
		private function cleanArray():Array{
			var _local1:Number;
			var _local4 = null;
			var _local6:int;
			var _local8:int;
			var _local3:int;
			var _local7:Boolean;
			var _local9:int;
			this.pathArray = [];
			var _local10:String = ((this.endPoint.x + "|") + endPoint.y);
			if (this.colsePath[_local10] == null) {
				_local1 = -1;
				for each (var _local5:TileAstarData in this.colsePath) {
					if (_local5.pt) {
						_local4 = _local5.pt;
						_local6 = (endPoint.x - _local4.x);
						((_local6)<0) ? _local6 = -(_local6) : _local6;
						_local8 = (endPoint.y - _local4.y);
						((_local8)<0) ? _local8 = -(_local8) : _local8;
						_local3 = (_local6 + _local8);
						if (_local1 == -1) {
							_local1 = _local3;
							_local10 = ((_local4.x + "|") + _local4.y);
						} else {
							if (_local3 < _local1) {
								_local1 = _local3;
								_local10 = ((_local4.x + "|") + _local4.y);
							}
						}
					}
				}
				if (this.colsePath[_local10] == null) {
					this.pathArray;
				}
			}
			var _local2:TileAstarData = this.colsePath[_local10];
			if (_local2 != null) {
				this.pathArray.unshift(TileUtils.tileToPixels(_local2.pt));
				this.pathArray.unshift(TileUtils.tileToPixels(_local2.parent.pt));
				_local7 = true;
				_local9 = 0;
				while (_local7) {
					_local10 = this.colsePath[_local10].parent.key;
					if ((((_local10 == ((startPoint.x + "|") + startPoint.y))) || ((_local9 > 10000)))) {
						_local7 = false;
						break;
					}
					this.pathArray.unshift(TileUtils.tileToPixels(this.colsePath[_local10].parent.pt));
					_local9++;
				}
			}
			return this.pathArray;
		}
		private function reSet():void{
			this.pathArray = [];
			this.source = new Dictionary();
			this.colsePath = new Dictionary();
			this.colseArray = [];
			this.openPath = new Dictionary();
			this.openArray = [];
			this.G = 0;
			this.nonce = null;
			this.canTL = true;
			this.canTR = true;
			this.canBL = true;
			this.canBR = true;
			this.isFinish = true;
			this.closeLength = 0;
		}
		
		public function get endPoint():Point
		{
			return _endPoint;
		}
		public function set endPoint(value:Point):void
		{
			_endPoint = value;
		}

	}
} 
