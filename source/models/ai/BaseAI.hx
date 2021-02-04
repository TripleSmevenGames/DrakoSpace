package models.ai;

import flixel.math.FlxRandom;
import models.cards.Card;
import models.skills.Skill.SkillPointCombination;
import ui.battle.DeckSprite;
import ui.battle.SkillSprite;
import ui.battle.character.CharacterSprite;
import utils.battleManagerUtils.BattleContext;

/** Base enemy AI "decider." Has handy functions. 
 *
 * To create a custom AI, extend this class and override the functions.
 *
 * Remember this is the AI for the enemy as a whole, not an individual enemy character.
**/
class BaseAI
{
	// skills among all enemy characters
	var skillSprites:Array<SkillSprite>;

	var context:BattleContext;
	var random:FlxRandom;

	function getSkillPointTotal():SkillPointCombination
	{
		var cardSkillPoints = new Array<SkillPointCombination>();
		var cards = context.eDeck.getCardsInHand();
		for (card in cards)
			cardSkillPoints.push(card.skillPoints);
		return SkillPointCombination.sum(cardSkillPoints);
	}

	function canPlaySkill(skillSprite:SkillSprite)
	{
		if (skillSprite.disabled) // no charges left, or owner is dead
			return false;

		var skillPointTotal = getSkillPointTotal();
		if (!skillSprite.skill.canPayWith(skillPointTotal, true)) // or, can't pay even if used whole hand
			return false;

		return true;
	}

	/** Get a list of all the skills this enemy could play right now. **/
	function getPlayableSkills()
	{
		var playableSkills = new Array<SkillSprite>();
		for (skillSprite in skillSprites)
		{
			if (canPlaySkill(skillSprite))
				playableSkills.push(skillSprite);
		}

		return playableSkills;
	}

	/** Decides a random skill. Override this function for a custom decider. Return null if no skills can be played.**/
	public function decideSkill()
	{
		var playableSkills = getPlayableSkills();
		if (playableSkills.length == 0)
			return null;

		var choice = random.int(0, playableSkills.length - 1);
		return playableSkills[choice];
	}

	public function pickCardsForSkill(skillSprite:SkillSprite)
	{
		var cards = context.eDeck.getCardsInHand();
		var pickedCards = new Array<Card>();
		var skillPoints = new SkillPointCombination();

		// For now, we're going to assume enemy skills just have 1 cost.
		var cost = skillSprite.skill.costs[0];

		for (card in cards)
		{
			if (skillSprite.skill.canPayWith(skillPoints))
			{
				break;
			}
			else
			{
				var need = cost.subtract(skillPoints);
				if (card.skillPoints.contributesTo(need))
				{
					pickedCards.push(card);
					skillPoints.add(card.skillPoints);
				}
			}
		}
		return pickedCards;
	}

	/** Override this for a smarter target-er**/
	public function decideTargetsForSkill(skillSprite:SkillSprite)
	{
		var skill = skillSprite.skill;
		var method = skill.targetMethod;
		var targets:Array<CharacterSprite> = [];

		if (method == SELF)
		{
			targets.push(skillSprite.owner);
		}
		else if (method == RANDOM_ENEMY || method == SINGLE_ENEMY)
		{
			var tauntedChars = context.getCharsWithStatus(TAUNT, PLAYER);
			if (tauntedChars.length > 0)
			{
				targets.push(tauntedChars[0]);
			}
			else
			{
				var choice = random.int(0, context.pChars.length - 1);
				targets.push(context.pChars[choice]);
			}
		}
		else if (method == ALL_ENEMY)
		{
			targets = context.pChars;
		}
		else
		{
			var choice = random.int(0, context.pChars.length - 1);
			targets.push(context.pChars[choice]);
		}

		return targets;
	}

	public function new(skillSprites:Array<SkillSprite>, context:BattleContext)
	{
		this.skillSprites = skillSprites;
		this.context = context;
		this.random = new FlxRandom();
	}
}
