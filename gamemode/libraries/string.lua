



function string.fill( str, ... )
	local args = { ... }
	for i = 1, #args do
		str = str:gsub("<%?%?>", args[ i ], 1)
	end
	return str
end