--[[
	Round Mutators - Shit to make each and every round more interesting
]]

local Mutators = Mutators or {}
Mutators.Events = Mutators.Events or {}
Mutators.LastActiveMutator = ""

function Mutators.RegisterNewEvent(name, desc, startfunc, endfunc)
	Mutators.Events[name] = Mutators.Events[name] or {}
	Mutators.Events[name]["name"] = name
	Mutators.Events[name]["desc"] = desc
	Mutators.Events[name]["startfn"] = startfunc
	Mutators.Events[name]["endfn"] = endfunc
end

function Mutators.StartEvent(event)
	if hook.Call("Lava.MutatorStart", nil, event, Mutators.Events[ event ] ) == false then return end

	if not Mutators.Events[ event ] then return end

	Mutators.LastActiveMutator = event
	Mutators.Events[ event ].startfn()

	if SERVER then
		SetGlobalString("$activemutator", event)
	end

end

function Mutators.RegisterHooks( eventname, tab )
	Mutators.Events[eventname] = Mutators.Events[eventname] or {}
	Mutators.Events[eventname].hooks = tab
	local HookIndex = 1

	return function( func )
		hook.Add( tab[ HookIndex ], "mutator_hook_" .. HookIndex, func )
		HookIndex = HookIndex + 1
		return tab[ HookIndex ], eventname, "mutator_hook_" .. HookIndex, func
	end
end

function Mutators.EndEvent()
	local tab = Mutators.Events[ Mutators.LastActiveMutator ]
	if not tab then return end
	if tab.endfn then
		tab.endfn()
	end

	if Mutators.Events[ Mutators.LastActiveMutator ] and Mutators.Events[ Mutators.LastActiveMutator ].hooks then
		for Index, Hook in pairs( Mutators.Events[ Mutators.LastActiveMutator ].hooks ) do
			hook.Remove( Hook, "mutator_hook_" .. Index )
		end
	end

	SetGlobalString("$activemutator", "" )
	Mutators.LastActiveMutator = nil
end

function Mutators.IsActive( name )
	if not name then return GetGlobalString("$activemutator") ~= "" end
	return GetGlobalString("$activemutator") == name
end

function Mutators.GetActive()
	return GetGlobalString("$activemutator", false )
end

hook.RunOnce("HUDPaint", function()
	if Mutators.IsActive() then
		Mutators.StartEvent(GetGlobalString("$activemutator"))
	end
end)

hook.Add("Lava.PostRound", "EndMutator", function()
	if Mutators.GetActive() then
		Mutators.EndEvent()
	end
end)

function Mutators.GetRandomPlayerForEvent( event )
	if not hook.Call( "Lava.ChooseRandomPlayerForEvent", nil, event ) then
		return table.Random( player.GetAll() )
	end
end

function Mutators.DesignateSpecialPlayer( Player )
	SetGlobalEntity("$currentmutantplayer", Player )
end

function Mutators.GetSpecialPlayer()
	return IsValid( GetGlobalEntity("$currentmutantplayer", NULL ) ) and GetGlobalEntity("$currentmutantplayer")
end

function Mutators.ClearSpecialPlayer()
	SetGlobalEntity("$currentmutantplayer", NULL )
end

_G.Mutators = Mutators