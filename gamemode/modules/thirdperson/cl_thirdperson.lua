-- Derived from https://github.com/jkralicky/Custom-ULX-Commands/blob/master/CustomCommands_onecategory/lua/ulx/modules/sh/cc_util.lua#L154

local closevar = 1
_ontp, tfov = _ontp or false, 65
local tr = {}
local LerpVector = LerpVector

hook.Add("CalcView", "ThirdPersonView", function(ply, pos, angles, fov)
	if _ontp and ply:Alive() then
		tr = util.TraceLine{
			start = ply:EyePos(),
			endpos = ply:EyePos() - angles:Forward() * 70,
			filter = {LocalPlayer(), LocalPlayer():GetActiveWeapon()}
		}

		closevar = closevar:lerp(1)

		if tr.Hit then
			closevar = (tr.Fraction * 0.2)
		end

		local view = {}
		view.origin = pos - (angles:Forward() * 70 * closevar) + (angles:Right() * 20) + (angles:Up() * 5)
		view.angles = ply:EyeAngles() + Angle(1, 1, 0)
		view.drawviewer = true
		view.fov = fov

		return view
	end
end)

hook.Add("Lava.PopulateWidgetMenu", "Register3PWidget", function(Context)
	Context.NewWidget("Toggle Thirdperson", 835, function()
		_ontp = not _ontp
	end)
end)