package ui.battle;

import flixel.FlxSprite;
import flixel.group.FlxSpriteGroup;
import models.skills.Skill;
import utils.ViewUtils;

using utils.ViewUtils;

/** Combines the skill art and its border. Centered. **/
class SkillTile extends FlxSpriteGroup
{
	public function new(skill:Null<Skill>)
	{
		super();

		if (skill != null)
		{
			var art = new FlxSprite(0, 0, skill.spritePath);
			var border = ViewUtils.getBorderForType(skill.type);

			art.scale3x();
			art.centerSprite();
			add(art);

			border.scale3x();
			border.centerSprite();
			add(border);
		}
		else
		{
			var tile = new FlxSprite(0, 0, AssetPaths.unknownSkill__png);
			tile.scale3x();
			tile.centerSprite();
			add(tile);
		}
	}
}