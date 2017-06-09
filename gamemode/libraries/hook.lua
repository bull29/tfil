local hook = hook
local file = file
local tem2 = 0

function hook.RunOnce(event, func)
	tem2 = tem2 + 1
	local c = 'temporary_hook_once_' .. tem2

	hook.Add(event, c, function(...)
		hook.Remove(event, c)

		return func(...)
	end)
end

function hook.Flush(st)
	local h = hook.GetTable()[st]

	for k, v in pairs(h) do
		hook.Remove(st, k)
	end
end