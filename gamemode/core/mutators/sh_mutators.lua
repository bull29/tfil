--[[
	Round Mutators - Shit to make each and every round more interesting
]]
if SERVER then
	util.AddNetworkString( "mutator_begin" )
	util.AddNetworkString( "mutator_end" )
end

local Mutators = Mutators or {}
if Mutators.CurrentlyActive then
	Mutators.ClearSpecialPlayer()
	Mutators.EndEvent( Mutators.CurrentlyActive )
end
Mutators.Events = Mutators.Events or {}
Mutators.CurrentlyActive = nil

function Mutators.RegisterNewEvent(name, desc, startfunc, endfunc)
	Mutators.Events[name] = Mutators.Events[name] or {}
	Mutators.Events[name]["name"] = name
	Mutators.Events[name]["desc"] = desc
	Mutators.Events[name]["startfn"] = startfunc
	Mutators.Events[name]["endfn"] = endfunc
end

function Mutators.RegisterHooks(eventname, tab)
	Mutators.Events[eventname] = Mutators.Events[eventname] or {}
	Mutators.Events[eventname].hooks = tab
	local HookIndex = 1

	return function(func)
		hook.Add(tab[HookIndex], "mutator_hook_" .. HookIndex, func)
		HookIndex = HookIndex + 1

		return tab[HookIndex], eventname, "mutator_hook_" .. HookIndex, func
	end
end

function Mutators.StartEvent( event )
	Mutators.EndEvent()
	if not Mutators.Events[event] then return end
	local tab = Mutators.Events[event]

	Mutators.CurrentlyActive = event
	if SERVER then
		SetGlobalString("$activemutator", event )

		net.Start("mutator_begin")
		net.WriteString( event )
		net.Broadcast()

		Notification.SendType( "Mutator", "The " .. event .. " mutator has begun!" )
		Notification.SendType( "Mutator", tab.desc:gsub("\t", "" ):gsub( "\n", "") )
	end
	if tab.startfn then
		tab.startfn()
	end
end

function Mutators.EndEvent( event )
	event = event or Mutators.CurrentlyActive

	if not Mutators.Events[event] then return end
	local tab = Mutators.Events[event]

	if SERVER then
		net.Start("mutator_end")
		net.WriteString( event )
		net.Broadcast()
	end

	if tab and tab.hooks then
		for Index, Hook in pairs(tab.hooks) do
			hook.Remove(Hook, "mutator_hook_" .. Index)
		end
	end

	if tab.endfn then
		tab.endfn()
	end

	if SERVER then
		SetGlobalString("$activemutator", "" )
	end
	Mutators.CurrentlyActive = nil
end

function Mutators.GetActive()
	return SERVER and Mutators.CurrentlyActive or ( GetGlobalString("$activemutator", "" ) ~= "" and GetGlobalString("$activemutator", "" ))
end

function Mutators.IsActive( name )
	return Mutators.GetActive() == name
end

hook.Add("Lava.PreroundStart", "DisableMutators", function()
	Mutators.EndEvent()
end)

if SERVER then
	hook.Add("Lava.RoundStart", "ShouldStartaMutator", function()
		FrameDelay( function()
			local A = math.random( 1, 11 )
			Notification.SendType( "Chance", "Should we start a mutator? Let's roll!" )
			timer.Simple( 3, function()
				local B = math.random( 1, 11 )
				if A == B then
					Notification.SendType( "Chance", ("We rolled ${1} and ${2}! Let's start us a mutator!"):fill( A, B ))
					timer.Simple( 2, function()
						local Table, Key = table.Random( Mutators.Events )
						Mutators.StartEvent( Key )
					end)
				else
					Notification.SendType( "Chance", ("We rolled ${1} and ${2}! Sorry chap! no mutator this round."):fill( A, B ))
				end
			end)
		end)
	end)
end

hook.Add("PlayerInitialSpawn", "BroadcastMutator", function( Player )
	if Mutators.CurrentlyActive then
		net.Start("mutator_begin")
		net.WriteString( Mutators.CurrentlyActive )
		net.Send( Player )
	end
end)

if CLIENT then
	net.Receive( "mutator_begin",function()
		local EVENT = net.ReadString()
		Mutators.CurrentlyActive = EVENT
		Mutators.StartEvent( EVENT )
	end)


	net.Receive( "mutator_end",function()
		local EVENT = net.ReadString()
		Mutators.EndEvent( EVENT )
	end)

	hook.RunOnce( "HUDPaint", function()
		if Mutators.GetActive() then
			Mutators.StartEvent( Mutators.GetActive() )
		end
	end)
end

function Mutators.GetRandomPlayerForEvent(event)
	if not hook.Call("Lava.ChooseRandomPlayerForEvent", nil, event) then return table.Random(player.GetAll()) end
end

function Mutators.DesignateSpecialPlayer(Player)
	SetGlobalEntity("$currentmutantplayer", Player)
end

function Mutators.GetSpecialPlayer()
	return IsValid(GetGlobalEntity("$currentmutantplayer", NULL)) and GetGlobalEntity("$currentmutantplayer")
end

function Mutators.ClearSpecialPlayer()
	SetGlobalEntity("$currentmutantplayer", NULL)
end

_G.Mutators = Mutators