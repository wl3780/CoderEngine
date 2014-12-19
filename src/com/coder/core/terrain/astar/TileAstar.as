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
		private static const COST_STRAIGHT:int = 10;	// 直线消耗值
		private static const COST_DIAGONAL:int = 14;	// 对角线消耗值
		
		private static const DIR_TC:String = "tc";
		private static const DIR_CL:String = "cl";
		private static const DIR_CR:String = "cr";
		private static const DIR_BC:String = "bc";

		private static var newStartPt:Point;
		private static var keyIndex:Point;

		public var g:Graphics;
		public var mode:int = 1;
		
		private var nonce:TileAstarData;
		private var isFinish:Boolean;
		private var G:int;
		private var source:Dictionary;
		private var startPoint:Point;
		private var _endPoint:Point;
		private var colsePath:Dictionary;
		private var openPath:Dictionary;
		private var colseArray:Array;
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

		public static function loopRect(index_x:int, index_y:int, loopNum:uint, dic:Dictionary, type:int, indexPt:Point):Point
		{
			var loop:int;
			var loop_height:int;
			var px:int;
			var py:int;
			var dir:int;
			var num:int;
			var k:int;
			var isBreak:Boolean;
			var i:int;
			var key:String = null;
			var tile:Tile = null;
			var dirx:int;
			var ok:Boolean;
			var currDir:int;
			var startDepth:int;
			index_x = (index_x - 2);
			index_y = (index_y - 2);
			loopNum = (startDepth + loopNum);
			var pow:int = 2;
			var n:int = startDepth;
			var loop_low:int = ((pow * startDepth) + 1);
			var array:Array = [];
			while (n < loopNum) {
				px = (index_x - (n - 1));
				py = (index_y - (n - 1));
				dir = 1;
				num = 0;
				k = 0;
				loop_height = (loop_low + pow);
				loop = (Math.pow(loop_height, 2) - Math.pow(loop_low, 2));
				isBreak = false;
				i = 0;
				while (i < loop) {
					if ((k % (loop_height - 1)) == 0) {
						num++;
						if ((num % 3) == 0) {
							dir = -(dir);
						}
					}
					(((num % 2))==0) ? px = (px + dir) : py = (py + dir);

					key = ((px + "|") + py);
					tile = dic[key];
					if (((((tile) && (!((tile.type == 0))))) && (!((tile.type == type))))) {
						dirx = LinearUtils.getCharDir(index_x, index_y, px, py);
						ok = false;
						if (((!(Scene.scene.mainChar.isLoopMove)) && (!((Scene.scene.mapData.map_id == 10291))))) {
							ok = true;
						}
						currDir = LinearUtils.getCharDir(Scene.scene.mainChar.x, Scene.scene.mainChar.y, Scene.scene.mouseX, Scene.scene.mouseY);
						if (!newStartPt) {
							array.push({
								tile:tile,
								dis:Point.distance(tile.pt, indexPt)
							});
						} else {
							if (tile.pt.toString() != newStartPt.toString()) {
								if (((findFaceTile(currDir, dirx)) || (ok))) {
									array.push({
										tile:tile,
										dir:dirx,
										dis:Point.distance(tile.pt, indexPt)
									});
									isBreak = true;
								}
							}
						}
					}
					k++;
					i++;
				}
				if (isBreak) {
					if (array.length) {
						array.sortOn(["dis", "dir"], [16, 16]);
						return array[0].tile.pt;
					}
					return null;
				}
				n++;
				loop_low = (loop_low + pow);
			}
			return null;
		}
		
		public static function findFaceTile(faceDir:int, averDir:int):Boolean
		{
			var i:int;
			var v:int;
			var startDir:int = (faceDir - 2);
			var array:Array = [(faceDir - 1), faceDir, (faceDir + 1)];
			i = 0;
			while (i < array.length) {
				v = array[i];
				if (v < 0) {
					array[i] = (8 - v);
				}
				i++;
			}
			if (array.indexOf(averDir) == -1) {
				return false;
			}
			return true;
		}
		
		public static function cleanPath(array:Array):Array
		{
			var i:int;
			var prev_p:Point = null;
			var curr_p:Point = null;
			var next_p:Point = null;
			var k1:Number;
			var k2:Number;
			if (array.length > 2) {
				i = 1;
				while (i < (array.length - 1)) {
					prev_p = array[(i - 1)];
					curr_p = array[i];
					next_p = array[(i + 1)];
					k1 = ((prev_p.y - curr_p.y) / (prev_p.x - curr_p.x));
					k2 = ((curr_p.y - next_p.y) / (curr_p.x - next_p.x));
					if (k1 == k2) {
						array.splice(i, 1);
						i--;
					}
					i++;
				}
			}
			return array;
		}

		public function getPath(source:Dictionary, start_x:int, start_y:int, end_x:int, end_y:int, isFineNear:Boolean=true, breakSetp:int=10000):Array
		{
			var square1:Tile = null;
			var square2:Tile = null;
			var start_p:Point = new Point(start_x, start_y);
			var end_p:Point = new Point(end_x, end_y);
			var key_start:String = ((start_x + "|") + start_y);
			var key_end:String = ((end_x + "|") + end_y);
			if (source[key_start]) {
				square1 = (source[key_start] as Tile);
				square2 = (source[key_end] as Tile);
			}
			var t:Number = getTimer();
			reSet();
			this.startPoint = loopCheck(source, start_p, 8);
			newStartPt = start_p;
			this.endPoint = loopCheck(source, end_p, 8);
			if ((((this.endPoint == null)) || ((start_p == null)))) {
				return [];
			}
			this.source = source;
			this.nonce = new TileAstarData(0, 0, this.startPoint);
			this.nonce.parent = this.nonce;
			this.colsePath[this.nonce.key] = this.nonce;
			while (this.isFinish) {
				getScale9Grid(source, this.nonce, this.endPoint.clone(), breakSetp);
			}
			var array:Array = cleanArray();
			return array;
		}
		
		public function stop():void
		{
			this.isFinish = false;
		}
		
		private function loopCheck(source:Dictionary, indexPt:Point, level:int):Point
		{
			var point:Point = null;
			var type:int = ((mode)==1) ? 2 : 1;
			var key_pt:String = ((indexPt.x + "|") + indexPt.y);
			if ((((((source[key_pt] == null)) || ((source[key_pt].type == 0)))) || ((source[key_pt].type == type)))) {
				keyIndex = indexPt;
				point = loopRect(indexPt.x, indexPt.y, level, source, type, indexPt);
				if (point == null) {
					this.isFinish = false;
				}
				return point;
			}
			return indexPt;
		}
		
		private function getDis(point:Point, endPoint:Point):int
		{
			var dix:int = (endPoint.x - point.x);
			((dix)<0) ? dix = -(dix) : dix;
			var diy:int = (endPoint.y - point.y);
			((diy)<0) ? diy = -(diy) : diy;
			return dix + diy;
		}
		
		private function pass(square:Tile):Boolean
		{
			return square.type>0 ? true : false;
		}
		
		private function stratght(tar:Tile, endPt:Point, type:String):void
		{
			var key:String = null;
			var pt:Point = null;
			var x:int;
			var y:int;
			var dix:int;
			var diy:int;
			var costH:int;
			var costG:int;
			var costF:int;
			var data:TileAstarData = null;
			var openNode:TileAstarData = null;
			var closeNode:TileAstarData = null;
			if (tar != null) {
				if (pass(tar)) {
					key = tar.key;
					pt = tar.pt;
					x = tar.x;
					y = tar.y;
					dix = Math.abs((endPt.x - x));
					diy = Math.abs((endPt.y - y));
					costH = ((dix + diy) * 10);
					costG = (10 + G);
					costF = (costG + costH);
					data = new TileAstarData(costG, costF, pt);
//					((_local4.parent)==null) ? var _local16 = this.nonce;
//_local4.parent = _local16;
//_local16 : "";
					openNode = openPath[key];
					closeNode = colsePath[key];
					if ((((openNode == null)) && ((closeNode == null)))) {
						openPath[key] = data;
						this.openArray.push(data);
					} else {
						if (openNode != null) {
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
		
		private function diagonal(tar:Tile, endPt:Point, can:Boolean):void
		{
			var key:String = null;
			var pt:Point = null;
			var dix:int;
			var diy:int;
			var costH:int;
			var costG:int;
			var data:TileAstarData = null;
			var openNode:TileAstarData = null;
			var closeNode:TileAstarData = null;
			if (((can) && (!((tar == null))))) {
				if (this.pass(tar)) {
					key = tar.key;
					pt = tar.pt;
					dix = Math.abs((endPt.x - tar.x));
					diy = Math.abs((endPoint.y - tar.y));
					costH = ((dix + diy) * 10);
					costG = (14 + G);
					data = new TileAstarData(costG, (costG + costH), pt);
//					((_local7.parent)==null) ? var _local13 = this.nonce;
//_local7.parent = _local13;
//_local13 : "";
					openNode = openPath[key];
					closeNode = colsePath[key];
					if ((((openNode == null)) && ((closeNode == null)))) {
						openPath[key] = data;
						this.openArray.push(data);
					} else {
						if (openNode != null) {
//							((_local7.F)<_local9.F) ? _local13 = _local7;
//openPath[_local12] = _local13;
//_local13 : "";
						}
					}
				}
			}
		}
		private function getScale9Grid(source:Dictionary, data:TileAstarData, endPoint:Point, breakSetp:int):void{
			var tad:TileAstarData = null;
			var i:int;
			var td:TileAstarData = null;
			this.canBL = true;
			this.canBR = true;
			this.canTL = true;
			this.canTR = true;
			this.canTC = true;
			this.canCR = true;
			this.canCL = true;
			this.canBC = true;
			var pt:Point = data.pt;
			var x:int = pt.x;
			var y:int = pt.y;
			var x1:int = (x + 1);
			var y1:int = (y + 1);
			var x2:int = (x - 1);
			var y2:int = (y - 1);
			var tl:Tile = source[((x2 + "|") + y2)];
			var tr:Tile = source[((x1 + "|") + y2)];
			var bl:Tile = source[((x2 + "|") + y1)];
			var br:Tile = source[((x1 + "|") + y1)];
			var tc:Tile = source[((x + "|") + y2)];
			var cl:Tile = source[((x2 + "|") + y)];
			var cr:Tile = source[((x1 + "|") + y)];
			var bc:Tile = source[((x + "|") + y1)];
			if (tc) {
				stratght(tc, endPoint, "tc");
			}
			if (cl) {
				stratght(cl, endPoint, "cl");
			}
			if (cr) {
				stratght(cr, endPoint, "cr");
			}
			if (bc) {
				stratght(bc, endPoint, "bc");
			}
			if (tl) {
				diagonal(tl, endPoint, canTL);
			}
			if (tr) {
				diagonal(tr, endPoint, canTR);
			}
			if (bl) {
				diagonal(bl, endPoint, canBL);
			}
			if (br) {
				diagonal(br, endPoint, canBR);
			}
			var len:int = openArray.length;
			if ((((len == 0)) || ((((((((((((((((tc == null)) && ((cl == null)))) && ((cr == null)))) && ((bc == null)))) && ((tl == null)))) && ((tr == null)))) && ((bl == null)))) && ((br == null)))))) {
				this.isFinish = false;
				return;
			}
			var index:int;
			i = 0;
			while (i < len) {
				td = openArray[i];
				if (i == 0) {
					tad = td;
				} else {
					if (td.F < tad.F) {
						tad = td;
						index = i;
					}
				}
				i++;
			}
			this.nonce = tad;
			this.openArray.splice(index, 1);
			var key:String = this.nonce.key;
			if (this.colsePath[key] == null) {
				this.colsePath[key] = this.nonce;
				this.closeLength = (this.closeLength + 1);
				if (closeLength > breakSetp) {
					this.isFinish = false;
				}
			}
			var key_end:String = ((endPoint.x + "|") + endPoint.y);
			if (this.nonce.key == key_end) {
				this.isFinish = false;
			}
			this.G = this.nonce.G;
		}
		
		public function pathCutter(array:Array, size:int=2):Array
		{
			var tmp:Array = null;
			var i:int;
			var j:int;
			var arr:Array = [];
			i = 0;
			while (i < array.length) {
				if ((i % size) == 0) {
					tmp = [];
					if (arr.length > 0) {
						tmp.push(array[(i - 1)]);
					}
					arr.push(tmp);
				}
				tmp.push(array[i]);
				i++;
			}
			j = 0;
			while (j < arr.length) {
				arr[j] = cleanPath(arr[j]);
				j++;
			}
			return arr;
		}
		
		private function cleanArray():Array
		{
			var min:Number;
			var pt:Point = null;
			var dix:int;
			var diy:int;
			var dis:int;
			var run:Boolean;
			var breakStep:int;
			this.pathArray = [];
			var key:String = ((this.endPoint.x + "|") + endPoint.y);
			if (this.colsePath[key] == null) {
				min = -1;
				for each (var o:TileAstarData in this.colsePath) {
					if (o.pt) {
						pt = o.pt;
						dix = (endPoint.x - pt.x);
						((dix)<0) ? dix = -(dix) : dix;
						diy = (endPoint.y - pt.y);
						((diy)<0) ? diy = -(diy) : diy;
						dis = (dix + diy);
						if (min == -1) {
							min = dis;
							key = ((pt.x + "|") + pt.y);
						} else {
							if (dis < min) {
								min = dis;
								key = ((pt.x + "|") + pt.y);
							}
						}
					}
				}
				if (this.colsePath[key] == null) {
					this.pathArray;
				}
			}
			var co:TileAstarData = this.colsePath[key];
			if (co != null) {
				this.pathArray.unshift(TileUtils.tileToPixels(co.pt));
				this.pathArray.unshift(TileUtils.tileToPixels(co.parent.pt));
				run = true;
				breakStep = 0;
				while (run) {
					key = this.colsePath[key].parent.key;
					if ((((key == ((startPoint.x + "|") + startPoint.y))) || ((breakStep > 10000)))) {
						run = false;
						break;
					}
					this.pathArray.unshift(TileUtils.tileToPixels(this.colsePath[key].parent.pt));
					breakStep++;
				}
			}
			return this.pathArray;
		}
		
		private function reSet():void
		{
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
