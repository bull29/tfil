local next = next

function Values( table )
	local cKey
	return function() cKey, cValue = next( table, cKey ) return cValue, cKey end
end

function Table( t )
	return setmetatable( t or {},{ __index = table })
end

function m_Table( ... )
	local tab = {}
	for obj in Values{ ... } do
		tab[ obj ] = true
	end
	return tab
end