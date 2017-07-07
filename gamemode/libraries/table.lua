local next = next
local pairs = pairs
local IsValid = IsValid

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

function table.CleanKeys( tab )
	for k in pairs( tab ) do
		if not IsValid( k ) then
			tab[ k ] = nil
		end
	end
end

function table.CleanValues( tab )
	for k, v in pairs( tab ) do
		if not v or not IsValid( v ) then
			tab[ k ] = nil
		end
	end
end