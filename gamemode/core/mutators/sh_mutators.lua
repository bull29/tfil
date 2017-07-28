--[[
	Round Mutators - Shit to make each and every round more interesting
]]
local Mutators = Mutators or {}
Mutators.Events = Mutators.Events or {}

function Mutators.RegisterNewEvent(name, desc, startfunc, endfunc)
	Mutators.Events[name] = {
		["name"] = name,
		["desc"] = desc,
		["startfn"] = startfunc,
		["endfn"] = endfunc
	}
end

function Mutators.StartEvent(event)
	if hook.Call("Lava.MutatorStart", nil, Mutators.Events[ event ] ) == false then return end

	if not Mutators.Events[ event ] then return end

	Mutators.Events[ event ].startfn()

	if SERVER then
		SetGlobalString("$activemutator", event)
	end

end

function Mutators.EndEvent()
	local tab = Mutators.Events[ GetGlobalString("$activemutator") ]
	if not tab then return end

	if tab.endfn then
		tab.endfn()
	end

	SetGlobalString("$activemutator", "" )
end

function Mutators.IsActive( name )
	if not name then return GetGlobalString("$activemutator") ~= "" end
	return GetGlobalString("$activemutator") == name
end

hook.RunOnce("HUDPaint", function()
	if Mutators.IsActive() then
		Mutators.StartEvent(GetGlobalString("$activemutator"))
	end
end)

hook.Add("Lava.PostRound", "EndMutator", function()
	if GetGlobalString("$activemutator", "" ) ~= "" then
		Mutators.EndEvent()
	end
end)

function Mutators.GetRandomPlayerForEvent( event )
	if not hook.Call( "Lava.ChooseRandomPlayerForEvent", event ) then
		return table.Random( player.GetAll() )
	end
end

_G.Mutators = Mutators