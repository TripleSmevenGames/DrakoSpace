package models.player;

/** Represents the player itself outside of battle. Characters, inventory, skills, money, etc. **/
class Player
{
	public static var deck:Deck;
	public static var chars:Array<CharacterInfo> = [];
	public static var money:Int;
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

	public static function init()
	{
		chars = [CharacterInfo.sampleRyder(), CharacterInfo.sampleKiwi()];
		deck = Deck.sample();

		money = 0;
		exp = 0;
		level = 1;
		toNextLevel = 1;
	}
}
