
hook.RunOnce("Tick", function()
	if GlobalFogController then
		GlobalFogController:Remove()
		GlobalFogController = nil
	end
	GlobalFogController = ents.Create("env_fog_controller")
end)