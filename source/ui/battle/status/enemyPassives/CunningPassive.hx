package ui.battle.status.enemyPassives;

import flixel.math.FlxRandom;
import models.skills.SkillAnimations;
import ui.battle.BattleIndicatorIcon.BattleIndicatorIconOptions;
import ui.battle.character.CharacterSprite;
import utils.BattleManager;
import utils.ViewUtils;
import utils.battleManagerUtils.BattleContext;

class CunningPassive extends Status
{
	override public function onEnemyEndTurn(context:BattleContext)
	{
		// apply carryover to all wisdom cards
		var cards = context.eDeck.getCardsInHand();
		for (card in cards)
		{
			if (card.name == 'Wisdom')
				card.carryOver = true;
		}
	}

	public function new(owner:CharacterSprite, initialStacks:Int = 1)
	{
		type = CUNNING;
		name = 'Cunning';
		var desc = 'Rattle doesn\'t discard Wisdom cards at the end of turn.';
		var options:BattleIndicatorIconOptions = {
			outlined: true,
		};
		var icon = new BattleIndicatorIcon(AssetPaths.Cold1__png, name, desc, options);

		super(owner, icon, initialStacks);
	}
}
