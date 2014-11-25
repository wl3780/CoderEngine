package com.coder.engine
{
	/**
	 * 常用正则表达式
	 */	
	public class RegExpInfo
	{
		public static const NUMBER:RegExp = /\[number]/g;
		public static const NUMBER1:RegExp = /\[number1]/g;
		public static const NUMBER2:RegExp = /\[number2]/g;
		public static const NUMBER3:RegExp = /\[number3]/g;
		public static const NUMBER4:RegExp = /\[number4]/g;
		public static const NUMBER5:RegExp = /\[number5]/g;
		public static const NUMBER6:RegExp = /\[number6]/g;
		public static const PLAYER_ID:RegExp = /\[playerId]/g;
		public static const USER_NAME:RegExp = /\[userName]/g;
		public static const USER_NAME2:RegExp = /\[userName2]/g;
		public static const USER_VOCATION:RegExp = /\[vocation]/g;
		public static const NAME:RegExp = /\[name]/g;
		public static const PAGE:RegExp = /{pageIndex}/;
		public static const WIN_USER_NAME:RegExp = /\[winUserName]/g;
		public static const FAIL_USER_NAME:RegExp = /\[failUserName]/g;
		public static const EQUIP_NAME:RegExp = /\[equipName]/g;
		public static const GILLY_POSITION:RegExp = /\[gillyPosition]/g;
		public static const GILLY_ARENA:RegExp = /\[gillyArena]/g;
		public static const FIGHT_CUST_FRAMEACT:RegExp = /\[CustFrameAct]/g;
		public static const FIGHT_FRAME_NUM_REG:RegExp = /\[frameNum\+\d*]/g;
		public static const FIGHT_HITHARM_PER:RegExp = /\[HitHarmPer]/g;
		public static const FIGHT_SPECIAL_PROPERTY:RegExp = /\[SpecialProperty]/g;
		public static const FIGHT_AGAIN_COUNT:RegExp = /\[AgainCount]/g;
		public static const ALLIANCE_NAME:RegExp = /\[allianceName]/g;
		public static const MASTER_NAME:RegExp = /\[masterName]/g;
		public static const TIMERSTR:RegExp = /\[timerStr]/g;
		public static const TIMERSTR1:RegExp = /\[timerStr1]/g;
		public static const MONSTER_NAME:RegExp = /\[monsterName]/g;
		public static const REWARD:RegExp = /\[reward]/g;
		public static const LEVEL:RegExp = /\[level]/g;
		public static const PETNAME:RegExp = /\[petName]/g;
		public static const PETNAME1:RegExp = /\[petName1]/g;
		public static const NAME1:RegExp = /\[name1]/g;
		public static const NAME2:RegExp = /\[name2]/g;
		public static const EXP:RegExp = /\[exp]/g;
		public static const STRING:RegExp = /\[string]/g;
		public static const DESCRIBE:RegExp = /\[describe]/g;
		public static const SEX:RegExp = /\[sex]/g;
		public static const BUFFARG:RegExp = /\[buffString]/;
		public static const COUNT:RegExp = /\[count]/;
		public static const XIAOLAOSHU:RegExp = /\@/;
		public static const POS:RegExp = /\[pos]/g;
		public static const REPLACE_SPACE:RegExp = /\[space]/g;
		public static const TEXT_BR:RegExp = new RegExp(/\#BR/g);
		public static const TEXT_RE_1:RegExp = new RegExp(/(\$.*?\$)/g);
		public static const TEXT_LINK_RE_1:RegExp = new RegExp(/(\$\%.*?\%\$)/g);
		public static const TEXT_LINK_RE_2:RegExp = new RegExp(/(\[.*?\])/g);
		public static const COLOR_RE:RegExp = new RegExp(/C\d{2}/g);
		public static const DOLLAR_RE:RegExp = new RegExp(/\$/g);
		public static const SPACE:RegExp = /\s/g;
		public static const TIME:RegExp = /\[time]/g;
		public static const END:RegExp = /\@END/g;
		public static const END2:RegExp = /\#END/g;
	}
}
