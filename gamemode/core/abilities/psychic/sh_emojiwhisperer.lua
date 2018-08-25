
hook.Add("Lava.ESPOverride", "EmojiMoviebySony", function( Player )
	if Player:HasAbility("Emoji Whisperer") then
		return 99
	end
end)

Abilities.Register("Emoji Whisperer", [[Due to your binge watching of the Emoji Movie, you have developed a spiritual connection with Emojis and can sense them for an infinite amount of time.]], "1f441" )
