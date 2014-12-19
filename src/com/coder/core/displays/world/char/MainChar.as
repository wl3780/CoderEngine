package com.coder.core.displays.world.char
{
	import com.coder.core.displays.world.SceneConst;
	import com.coder.core.terrain.tile.TileUtils;
	import com.coder.utils.geom.LinearUtils;
	
	import flash.geom.Point;

	public class MainChar extends Char
	{
		public function MainChar()
		{
			super();
			_isMainChar_ = true;
			this.isCharMode = true;
			this.type = SceneConst.MAIN_CHAR;
			this.allwayShowName = true;
			unit.isCharMode = true;
		}
		
		override public function stopMove(playStand:Boolean=false, playAction:Boolean=true):void
		{
			stopMoveNow(playStand, playAction);
		}
		
		override public function tarMoveTo(value:Array):void
		{
			super.tarMoveTo(value);
		}
		
		override public function set x(value:Number):void
		{
			super.x = value;
		}
		
		override public function set speciaState(value:String):void
		{
			super.speciaState = value;
		}
		
		override public function play(act:String, renderType:int=0, playEndFunc:Function=null, stopFrame:int=-1):void
		{
			super.play(act, renderType, playEndFunc, stopFrame);
		}
		
		override public function set dir(value:int):void
		{
			if (lockSkill) {
				return;
			}
			super.dir = value;
		}
		
		override protected function checkAndSetDir(now:Boolean=false):void
		{
			if (!_tarPoint_) {
				return;
			}
			var currP:Point = TileUtils.pixelsToTile(this.x, this.y);
			var tarP:Point = TileUtils.pixelsToTile(_tarPoint_.x, _tarPoint_.y);
			if ((currP.toString() != tarP.toString()) && !(this.x == point.x && this.y == point.y) && (!isLoopMove || now)) {
				this.dir = LinearUtils.getCharDir(this.x, this.y, _tarPoint_.x, _tarPoint_.y);
			}
		}
		
		override public function _ChangeTileFunc_():void
		{
			super._ChangeTileFunc_();
		}
		
		override public function _tarMove_():void
		{
			super._tarMove_();
		}

	}
} 
