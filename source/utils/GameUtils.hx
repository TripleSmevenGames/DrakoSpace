package utils;

import flixel.FlxG;
import flixel.math.FlxRandom;
import haxe.Exception;
import models.cards.Card;
import models.player.CharacterInfo;
import models.skills.Skill.SkillPointCombination;

// utility functions and globals for game logic.
class GameUtils
{
	public static var random:FlxRandom = new FlxRandom();

	public static function weightedPick<T>(items:Array<T>, weights:Array<Float>, ?excludes:Array<T>)
	{
		if (items.length != weights.length)
		{
			throw new Exception('items and weights not same length');
		}

		if (excludes == null)
			excludes = [];

		var counter = 0;
		while (true)
		{
			counter += 1;
			if (counter > 10)
				throw new haxe.Exception('weighted pick picked a duplicate 10+ times, something probably wrong.');

			var choice = items[GameController.rng.weightedPick(weights)];
			if (!excludes.contains(choice))
				return choice;
		}

		trace('Exited loop in weightedPick, something wrong');
		return items[0];
	}

	/** Get the total skill point value of the array of Cards.
	 * potential to be slow? 1 loop iterating through cards, another when calling .sum()
	**/
	public static function getSkillPointTotal(cards:Array<Card>)
	{
		var cardSkillPoints = new Array<SkillPointCombination>();
		for (card in cards)
			cardSkillPoints.push(card.skillPoints);
		return SkillPointCombination.sum(cardSkillPoints);
	}

	/** heal 25% of your missing HP + 25% of your max. Returns the amount of hp healed. **/
	public static function healCharFromRestEvent(char:CharacterInfo)
	{
		var amtToHeal = Std.int(((char.maxHp - char.currHp) * .25) + (char.maxHp * .25));
		char.currHp += amtToHeal;
		return amtToHeal;
	}

	public static function getRandomChoice<T>(array:Array<T>, ?excludes:Array<T>)
	{
		if (array.length == 0)
		{
			trace('tried to get a randomChoice but the array was empty');
			return null;
		}
		if (excludes == null)
			excludes = [];

		var counter = 0;
		while (true)
		{
			counter += 1;
			if (counter > 10)
				throw new haxe.Exception('getRandomChoice chose a dup 10+ times, something wrong');

			var choice = array[random.int(0, array.length - 1)];
			if (!excludes.contains(choice))
				return choice;
		}

		trace('getRandomChoice exited loop. Something wrong');
		return array[0];
	}

	public static function smallCameraShake()
	{
		FlxG.camera.shake(0.01, 0.1);
	}

	public static function mediumCameraShake()
	{
		FlxG.camera.shake(0.03, 0.3);
	}

	public static function bigCameraShake()
	{
		FlxG.camera.shake(.05, 0.6);
	}
}
