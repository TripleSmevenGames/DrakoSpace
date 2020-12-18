package;

import flixel.FlxG;
import flixel.FlxState;
import flixel.text.FlxText;
import openfl.system.System;
import ui.debug.BAMIndicator;
import ui.debug.MemIndicator;
import utils.GameController;
import utils.SubStateManager;

class PlayState extends FlxState
{
	var memIndicator:MemIndicator;
	var bamIndicator:BAMIndicator;

	override public function create()
	{
		super.create();

		// substates aren't destroyed when closed. This should reduce sub state load time
		// at cost of greater memory.
		destroySubStates = false;

		persistentUpdate = true;
		persistentDraw = true;

		FlxG.fixedTimestep = false;

		GameController.initSSM(this);
		GameController.initBAM();
		GameController.subStateManager.returnToMap();

		FlxG.camera.minScrollX = 0;
		FlxG.camera.maxScrollX = 5000; // arbitrary
		FlxG.camera.minScrollY = 0;
		FlxG.camera.maxScrollY = 1000;

		#if debug
		memIndicator = new MemIndicator();
		add(memIndicator);

		bamIndicator = new BAMIndicator(GameController.battleAnimationManager);
		add(bamIndicator);
		#end
	}

	override public function update(elapsed:Float)
	{
		if (FlxG.keys.anyPressed([ESCAPE]))
			FlxG.switchState(new MenuState());

		super.update(elapsed);
	}

	override public function destroy()
	{
		super.destroy();
		GameController.subStateManager.destroyAll();
	}
}
