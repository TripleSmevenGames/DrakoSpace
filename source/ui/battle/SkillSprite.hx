package ui.battle;

import constants.Fonts;
import constants.UIMeasurements;
import flixel.FlxSprite;
import flixel.group.FlxSpriteGroup;
import flixel.input.mouse.FlxMouseEventManager;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import managers.BattleManager;
import managers.GameController;
import models.skills.Skill;
import ui.TooltipLayer;
import ui.battle.character.CharacterSprite;
import ui.skillTile.SkillTile;
import utils.ViewUtils;
import utils.battleManagerUtils.BattleContext;

using utils.ViewUtils;

/** A sprite representing a skill during battle. This is not the Skill itself, but it should always have a reference to
	the Skill it represents. This should not exist outside the context of a battle.
	*
	* During battle, you should pretty much ALWAYS be interacting and modifying the SkillSprite, not the Skill itself.
 */
class SkillSprite extends FlxSpriteGroup
{
	public var skill:Skill;
	public var tile:SkillTile;
	public var cooldownCountdownSprite:FlxText;
	public var disabledFilter:FlxSprite;
	public var priority:Int = 0;
	public var owner:CharacterSprite;

	// cooldown of x means the you must wait x turns before it can be used again.
	// cooldown of 0 means this skill can be used this turn.
	public var cooldownTimer(default, set):Int = 1;
	public var currentCharges(default, set):Int = 1;
	public var disabled(default, set):Bool;

	public var mouseOverCallbacks:Array<FlxSprite->Void> = [];
	public var mouseOutCallbacks:Array<FlxSprite->Void> = [];

	public function set_cooldownTimer(val:Int)
	{
		if (val == 0) // refund charges on this skill when cooldown hits 0;
		{
			currentCharges += skill.chargesPerCD;
			if (currentCharges < skill.maxCharges) // and if there are still charges to restore, put the skill on cooldown again.
				return cooldownTimer = skill.cooldown;
		}

		if (val < 0)
			val = 0;

		this.cooldownCountdownSprite.text = Std.string(val);
		return cooldownTimer = val;
	}

	public function set_currentCharges(val:Int)
	{
		if (val > skill.maxCharges)
			val = skill.maxCharges;

		if (val < 0)
			val = 0;

		currentCharges = val;
		checkDisabled();

		return currentCharges;
	}

	/** Disable this skill, greying it out and stopping all click handlers. 
		Happens if it goes on cooldown, is disabled by an affect, or owner dies
	**/
	public function set_disabled(val:Bool)
	{
		if (owner != null && owner.dead)
			this.disabled = true;

		// depending on why we are disabling the skill, we might show a number (cooldown),
		// or just a slash (stunned/dead);
		if (val)
		{
			this.cooldownCountdownSprite.visible = true;
			disabledFilter.visible = true;

			if (owner.getStatus(STUN) > 0 || owner.dead || (currentCharges == 0 && skill.chargesPerCD == 0))
				this.cooldownCountdownSprite.text = '/';
			else
				this.cooldownCountdownSprite.text = Std.string(cooldownTimer);
		}
		else // if we are enabling it, reset everything
		{
			this.cooldownCountdownSprite.visible = false;
			disabledFilter.visible = false;
		}
		return this.disabled = val;
	}

	/** Check if this skill should be disabled, and disable it if so.
	 * Is automatically called at certain points, but can be manually called too.
	**/
	public function checkDisabled()
	{
		disabled = (currentCharges == 0) || owner.getStatus(STUN) != 0 || owner.dead;
	}

	/** Sets the click callback, which will fire when clicked if the skill is not disabled. **/
	public function setOnClick(onClick:SkillSprite->Void)
	{
		FlxMouseEventManager.setMouseClickCallback(tile, (_) ->
		{
			if (disabled)
				return;
			else
				onClick(this);
		});
	}

	public function addHoverCallback(over:FlxSprite->Void, out:FlxSprite->Void)
	{
		mouseOverCallbacks.push(over);
		mouseOutCallbacks.push(out);
	}

	public function play(targets:Array<CharacterSprite>, context:BattleContext)
	{
		if (this.disabled)
			return;

		skill.play(targets, this.owner, context);
		this.currentCharges -= 1;
		this.cooldownTimer += skill.cooldown;
	}

	public function onNewRound()
	{
		this.cooldownTimer -= 1;
		checkDisabled();
	}

	public function new(skill:Skill, owner:CharacterSprite)
	{
		super(0, 0);
		this.skill = skill;
		this.owner = owner;

		tile = new SkillTile(skill);
		add(tile);

		// setup a grey filter, which will be applied over the tile (but under the cooldown counter) when the skill is disabled.
		disabledFilter = new FlxSprite();
		disabledFilter.makeGraphic(Std.int(tile.width), Std.int(tile.height), FlxColor.fromRGB(0, 0, 0, 128));
		disabledFilter.centerSprite();
		add(disabledFilter);
		disabledFilter.visible = false;

		// setup the cooldown counter, which will appear on the tile when its on cooldown.
		cooldownCountdownSprite = new FlxText(0, 0, 0, '/');
		cooldownCountdownSprite.setFormat(Fonts.STANDARD_FONT, UIMeasurements.BATTLE_UI_FONT_SIZE_LG);
		cooldownCountdownSprite.setBorderStyle(FlxTextBorderStyle.OUTLINE, FlxColor.BLACK, 2);
		cooldownCountdownSprite.centerSprite();
		add(cooldownCountdownSprite);
		cooldownCountdownSprite.visible = false;

		this.cooldownTimer = 0;
		this.currentCharges = skill.maxCharges;
		this.priority = skill.priority;

		// setup the cost indicator under the tile.
		var costTextOptions = {bodyWidth: 72.0, fontSize: 12, font: Fonts.STANDARD_FONT2};
		var costTextSprite = new FlxTextWithReplacements(skill.getCostStringCompact(), null, null, costTextOptions);
		costTextSprite.centerSprite(0, tile.height / 2 + 8);
		add(costTextSprite);

		// setup the mouse events
		// PixelPerfect arg must be false, for the manager to respect the scaled up sprite's new hitbox.
		FlxMouseEventManager.add(tile, null, null, null, null, false, true, false);
		FlxMouseEventManager.setMouseOverCallback(tile, (sprite:FlxSprite) ->
		{
			for (callback in mouseOverCallbacks)
				callback(sprite);
		});
		FlxMouseEventManager.setMouseOutCallback(tile, (sprite:FlxSprite) ->
		{
			for (callback in mouseOutCallbacks)
				callback(sprite);
		});

		// setup the hover effect
		var darken = (_) -> tile.color = FlxColor.fromRGB(200, 200, 200);
		var undarken = (_) -> tile.color = FlxColor.WHITE;
		addHoverCallback(darken, undarken);

		// setup the tooltip (which is also a hover effect)
		GameController.battleTooltipLayer.createTooltipForSkill(this);

		disabled = false;
	}
}
