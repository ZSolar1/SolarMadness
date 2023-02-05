package skin;

import flixel.system.FlxAssets.FlxGraphicAsset;
import QMAssets.QMAssets;
import flash.display.BitmapData;

class SkinLoader
{
	public static function getSkinnedImage(path:String):FlxGraphicAsset
	{
		if (Preferences.skin != null)
		{
			if (QMAssets.exists('mods/skins/${Preferences.skin}/$path'))
			{
				return cast(BitmapData.fromFile('mods/skins/${Preferences.skin}/$path'));
			}
			else
			{
				return 'assets/images/$path';
			}
		}
		else
		{
			return 'assets/images/$path';
		}
	}
}
