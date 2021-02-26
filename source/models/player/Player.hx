package models.player;

import models.skills.Skill;
import models.skills.SkillFactory;

/** Represents the player itself outside of battle. Characters, inventory, skills, money, etc. **/
class Player
{
	public static var deck:Deck;
	public static var chars:Array<CharacterInfo> = [];
	public static var money:Int;
	public static var inventory:Inventory;
	public static var exp(default, set):Int;
	public static var level(default, set):Int;
	public static var toNextLevel:Int;

	public static function set_exp(val:Int)
	{
		if (val >= toNextLevel)
		{
			level++;
			val -= (toNextLevel - val);
		}
		return exp = val;
	}

	public static function set_level(val:Int)
	{
		toNextLevel = val;
		return level = val;
	}

	/** Get a list of all the skills the player has. **/
	public static function getSkills()
	{
		var skills = new Array<Skill>();
		for (char in chars)
		{
			skills = char.skills.concat(skills);
		}
		return skills;
	}

	public static function gainSkill(skill:Skill)
	{
		inventory.unequippedSkills.push(skill);
	}

	public static function init()
	{
		chars = [CharacterInfo.sampleRyder(), CharacterInfo.sampleKiwi()];
		deck = Deck.sample();
		inventory = new Inventory();
		gainSkill(SkillFactory.ryderSkillsRare.get(revenge)());
		gainSkill(SkillFactory.kiwiSkillsRare.get(fullyPrepared)());

		money = 0;
		exp = 0;
		level = 1;
		toNextLevel = 1;
	}
}
