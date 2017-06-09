local debug = debug
local func = {}

function func:info()
	return debug.getinfo(self)
end

function func:dump()
	PrintTable(debug.getinfo(self))
end

function func:source( np )
	return debug.getinfo(self, "S").source
end

debug.setmetatable( function() end, { __index = func })