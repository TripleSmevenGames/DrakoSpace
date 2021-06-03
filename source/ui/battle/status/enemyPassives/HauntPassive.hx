package ui.battle.status.enemyPassives;

import flixel.math.FlxRandom;
import managers.BattleManager;
import models.skills.SkillAnimations;
import ui.battle.IndicatorIcon.IndicatorIconOptions;
import ui.battle.character.CharacterSprite;
import utils.ViewUtils;
import utils.battleManagerUtils.BattleContext;

class HauntPassive extends Status
{
	override public function onDead(context:BattleContext)
	{
		var effect = (target:CharacterSprite, owner:CharacterSprite, context:BattleContext) ->
		{
			target.addStatus(EXPOSED, stacks);
		}
		// create a 'play', then call it immediately.
		// this will add the animation to the queue.
		SkillAnimations.genericBuffPlay(effect)(context.getAlivePlayers(), this.owner, context);
	}

	public function new(owner:CharacterSprite, initialStacks:Int = 2)
	{
		type = HAUNT;
		name = 'Haunt';
		var desc = 'When ${owner.info.name} dies, all its enemies gain ${initialStacks} Exposed.';
		var options:IndicatorIconOptions = {
			outlined: true,
		};
		var icon = new IndicatorIcon(AssetPaths.Cold1__png, name, desc, options);

		super(owner, icon, initialStacks);
	}
}
