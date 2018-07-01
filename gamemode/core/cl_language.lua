local gmodLanguage = GetConVar( "gmod_language" ):GetString()
if lang_data[ gmodLanguage ] then --if player's language is suportted
	lang = lang_data[ gmodLanguage ]
else
	if IsValid(lang_data[ "en" ]) then
		lang = lang_data[ "en" ]
	else
		lang = nil
	end
end
