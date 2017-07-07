
hook.RunOnce("Tick", function()
	if GlobalFogController then
		GlobalFogController:Remove()
		GlobalFogController = nil
	end
	GlobalFogController = ents.Create("env_fog_controller")
end)

hook.RunOnce("Tick", function()
    local x = ents.FindByClass("sky_camera")[1]

    if x then
        SetGlobalVector("$skycampos", x:GetPos())
    end
end)
