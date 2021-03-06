package models.events;

import managers.GameController;
import models.events.Choice;
import models.events.GameEvent.GameEventType;
import models.events.battleEvents.BattleEventFactory;

class HomeEvent extends GameEvent
{
	static function getTrainingDummyChoice()
	{
		var text = 'Spar with the training dummy';
		var effect = (choice:Choice) ->
		{
			GameController.subStateManager.ess.goToSubEvent(BattleEventFactory.trainingDummy());
		}
		return new Choice(text, effect);
	}

	public function new()
	{
		var name = 'Base';
		var desc = 'Your mission is to figure out what is causing the disturbance in the forest. The monsters are hostile, '
			+ 'and ancient machines from the ruins are activating. Take some time to prepare.';
		var choices:Array<Choice> = [getTrainingDummyChoice(), Choice.getLeave()];
		super(name, desc, HOME, choices);
	}
}
