package test.modules
{
	import flash.utils.getQualifiedClassName;
	
	import test.modules.scene.SceneModule;

	public class ModuleConst
	{
		public static const SCENE_MODULE:String = getQualifiedClassName(SceneModule);
	}
}