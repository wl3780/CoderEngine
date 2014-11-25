package com.coder.core.displays
{
	import com.coder.core.displays.avatar.AvatarEffect;
	import com.coder.core.displays.avatar.AvatarRenderElisor;
	import com.coder.interfaces.display.IInteractiveObject;
	import com.coder.utils.geom.LinearUtils;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.geom.Point;
	import flash.utils.getTimer;
	
	public class InteractiveEffect extends AvatarEffect implements IInteractiveObject
	{
		private static var objectQueue:Vector.<InteractiveEffect> = new Vector.<InteractiveEffect>();
		private static var _Point_:Point = new Point();

		public var dirMode:Boolean = false;
		public var isBezierMove:Boolean;
		public var mode:int = 0;
		public var scaleSpeed:Number = 0.005;
		public var moveEndAndDospose:Boolean = true;
		public var _movePath_:Array;
		
		protected var _speed_:Number = 200;
		protected var _tarPoint_:Point;
		protected var _totalTime_:Number;
		protected var _moveEndFunc_:Function;
		protected var _updateFunc_:Function;
		protected var _isRuning_:Boolean;
		protected var _stopMove_:Boolean;
		protected var _dir_:int;
		
		private var _loopMoveTime:int;
		private var timer:int;

		public function InteractiveEffect()
		{
			InteractiveManager.addObject(this);
		}
		
		public static function createEffect():InteractiveEffect
		{
			var result:InteractiveEffect = null;
			if (objectQueue.length) {
				result = objectQueue.pop();
				result.reset();
			} else {
				result = new InteractiveEffect();
			}
			return result;
		}

		override public function reset():void
		{
			_speed_ = 200;
			_tarPoint_ = null;
			_movePath_ = [];
			_totalTime_ = 0;
			_moveEndFunc_ = null;
			_updateFunc_ = null;
			_isRuning_ = false;
			_loopMoveTime = 0;
			_stopMove_ = false;
			super.reset();
		}
		
		override public function recover():void
		{
			if (_isDisposed_) {
				return;
			}
			if (this.parent) {
				parent.removeChild(this);
			}
			_layer_ = null;
			_char_id_ = null;
			if (bmd_eid && bmd_eid.parent) {
				bmd_eid.parent.removeChild(bmd_eid);
			}
			bmd_eid = null;
			_ActionPlayEndFunc_ = null;
			playEndFunc = null;
			removeChildren();
			if (unit) {
				AvatarRenderElisor.getInstance().removeUnit(unit.id);
			}
			_unit_.dispose();
			_unit_ = null;
			if (objectQueue.length <= 50) {
				objectQueue.push(this);
			}
		}
		
		public function stopMove():void
		{
			_isRuning_ = false;
			_stopMove_ = true;
			_tarPoint_ = null;
			_movePath_ = [];
		}
		
		public function loopMove():void
		{
			var tmpTime:int;
			if (_tarPoint_ && _isRuning_ && !_stopMove_) {
				tmpTime = getTimer();
				_totalTime_ = _totalTime_ + tmpTime - _loopMoveTime;
				if (_totalTime_ > 0 && _tarPoint_) {
					_tarMove_();
				}
				_loopMoveTime = getTimer();
			}
		}
		
		public function get speed():Number
		{
			return _speed_;
		}
		public function set speed(value:Number):void
		{
			_speed_ = value;
		}
		
		public function get moveEndFunc():Function
		{
			return _moveEndFunc_;
		}
		public function set moveEndFunc(value:Function):void
		{
			_moveEndFunc_ = value;
		}
		
		public function get updateFunc():Function
		{
			return _updateFunc_;
		}
		public function set updateFunc(value:Function):void
		{
			_updateFunc_ = value;
		}
		
		public function tarMoveTo(value:Array):void
		{
			_tarPoint_ = value.shift();
			_stopMove_ = false;
			_movePath_ = value;
			_isRuning_ = true;
			_loopMoveTime = getTimer();
			this.scaleY = this.scaleX = 1;
		}
		
		public function get dir():int
		{
			return _dir_;
		}
		public function set dir(value:int):void
		{
			if (!dirMode) {
				this.rotation = LinearUtils.getAngle(value);
			}
		}
		
		public function setAngle(tar_x:Number, tar_y:Number):void
		{
			if (dirMode) {
				unit.dir = LinearUtils.getDirection(x, y, tar_x, tar_y);
			} else {
				var dx:Number = tar_x - this.x;
				var dy:Number = tar_y - this.y;
				var rad:Number = Math.atan2(dy, dx);
				this.rotation = rad * 180 / Math.PI + 90;
			}
		}
		
		public function getDirPoint(dir:int, grid:int=1):Point
		{
			return LinearUtils.getTileByDir(tilePoint, dir, grid);
		}
		
		override public function setBitmapValue(bitmap:Bitmap, bitmapData:BitmapData, vx:int, vy:int):void
		{
			super.setBitmapValue(bitmap, bitmapData, vx, vy);
		}
		
		public function _tarMove_():void
		{
			if (_stopMove_) {
				return;
			}
			if (_tarPoint_ == null) {
				_MoveEndFunc_();
				return;
			}
			if (_speed_ == 0) {
				throw new Error("移动速度为0 ！");
				_MoveEndFunc_();
				return;
			}
			
			var currPoint:Point = new Point(this.x, this.y);
			var distance:Number = Point.distance(currPoint, _tarPoint_);
			var passTime:Number = (distance / _speed_) * 1000;
			if (mode >= 1) {
				this.scaleX = this.scaleX - scaleSpeed;
				this.scaleY = this.scaleY - scaleSpeed;
				if (this.scaleX < 0) {
					this.scaleX = 0;
				}
				if (this.scaleY < 0) {
					this.scaleY = 0;
				}
			}
			if (_totalTime_ >= passTime) {
				_totalTime_ = _totalTime_ - passTime;
			} else {
				passTime = _totalTime_;
				_totalTime_ = 0;
			}
			if (passTime > 0){
				var movDistance:Number = (_speed_ * passTime) / 1000;
				var scale:Number = movDistance / distance;
				var midPoint:Point = Point.interpolate(_tarPoint_, currPoint, scale);
				this.x = midPoint.x;
				this.y = midPoint.y;
			}
			currPoint.x = this.x;
			currPoint.y = this.y;
			
			distance = Point.distance(currPoint, _tarPoint_);
			if (_tarPoint_) {
				setAngle(_tarPoint_.x, _tarPoint_.y);
			}
			if (updateFunc != null && !isBezierMove) {
				updateFunc(this);
			}
			if (distance <= 1) {
				_totalTime_ = 0;
				if (_movePath_.length > 0) {
					_tarPoint_ = _movePath_.shift();
					var dur:int = 0;
					if (isBezierMove) {
						dur = 300;
					}
					if ((getTimer() - timer) > dur) {
						timer = getTimer();
						if (updateFunc != null) {
							updateFunc(this);
						}
					}
				} else {
					_MoveEndFunc_();
				}
			}
			if (_totalTime_ > 0) {
				_tarMove_();
			}
		}
		
		protected function _MoveEndFunc_():void
		{
			_isRuning_ = false;
			if (moveEndFunc != null) {
				moveEndFunc();
			}
			if (moveEndAndDospose) {
				this.dispose();
			}
		}
		
		override public function dispose():void
		{
			if (this.parent) {
				parent.removeChild(this);
			}
			_layer_ = null;
			_char_id_ = null;
			if (bmd_eid && bmd_eid.parent) {
				bmd_eid.parent.removeChild(bmd_eid);
			}
			bmd_eid = null;
			_ActionPlayEndFunc_ = null;
			playEndFunc = null;
			this.removeChildren();
			if (unit) {
				AvatarRenderElisor.getInstance().removeUnit(unit.id);
				_unit_.dispose();
			}
			_unit_ = null;
			InteractiveManager.removeObject(this);
			_tarPoint_ = null;
			_movePath_ = [];
			_totalTime_ = 0;
			_moveEndFunc_ = null;
			_updateFunc_ = null;
			_isRuning_ = false;
			_loopMoveTime = 0;
			_stopMove_ = false;
			_isDisposed_ = true;
			super.dispose();
		}
		
		override public function resetForDisposed():void
		{
			dirMode = false;
			_speed_ = 200;
			_tarPoint_ = null;
			_movePath_ = [];
			_totalTime_ = 0;
			_moveEndFunc_ = null;
			_updateFunc_ = null;
			_isRuning_ = false;
			_loopMoveTime = 0;
			_stopMove_ = false;
			_dir_ = 0;
			isBezierMove = false;
			timer = 0;
			mode = 0;
			scaleSpeed = 0.01;
			moveEndAndDospose = true;
			_isDisposed_ = false;
			InteractiveManager.addObject(this);
			super.resetForDisposed();
		}

	}
} 
