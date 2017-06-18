--[[
	Round Mutators - Shit to make each and every round more interesting
]]
Mutators = Mutators or {}
Mutators.Events = Mutators.Events or {}

function Mutators.RegisterNewEvent(name, desc, startfunc, endfunc)
	Mutators.Events[name] = {
		["Name"] = name,
		["Description"] = desc,
		["StartFunction"] = startfunc,
		["EndFunction"] = endfunc
	}
end

function Mutators.StartEvent(event)
	if SERVER then
		SetGlobalString("$activemutator", event)
	end

	if CLIENT then
		GAMEMODE.CreateNotification(([[Round Mutator: <??>

				<??>]]):fill(event, Mutators.Events[event].Description), 5)
	end
end

hook.RunOnce("HUDPaint", function()
	if GetGlobalString("$activemutator") ~= "" then
		Mutators.StartEvent(GetGlobalString("$activemutator"))
	end
end)

hook.Add("PostRound", "EndMutator", function()
	SetGlobalString("$activemutator", nil)
end)