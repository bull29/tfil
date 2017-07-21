local lp = Lerp
local closevar = 1
local mulvar = 1
_ontp, tfov = _ontp or false, 65
local tr = {}
local tpsma = 0
local OldPos = IsValid( LocalPlayer() ) and LocalPlayer():EyePos() or Vector(0, 0, 0)
local LerpVector = LerpVector

hook.Add("CalcView", "ThirdPersonView", function(ply, pos, angles, fov)
	if _ontp and ply:Alive() then
		local view = {}
		view.origin = OldPos -- ply:EyePos() - (angles:Forward() * 70) + (angles:Right() * 20) + (angles:Up() * 5)
		view.angles = angles --+ Angle(1, 10, 0)
		view.drawviewer = true
		local vec = ply:EyePos() - (angles:Forward() * 90 * (closevar == 1 and 1 or closevar)) + (angles:Up() * 10) --(angles:Right() * 20) +
		OldPos = LerpVector(FrameTime() * 3 * mulvar,OldPos, vec)
		tpsma = tpsma:lerp(ply:GetVelocity():Length() / 50)

		tr = util.TraceLine{
			start = ply:EyePos(),
			endpos = view.origin - angles:Forward() * 10,
			filter = {LocalPlayer(), LocalPlayer():GetActiveWeapon()}
		}

		closevar = closevar:lerp(1)

		if tr.Hit then
			closevar = (tr.Fraction * 0.2)
			mulvar = 5
		else
			mulvar = 1
		end

		view.fov = tfov + tpsma

		return view --GAMEMODE:CalcView(ply, view.origin, view.angles, view.fov)
	end
end)

hook.Add( "Lava.PopulateWidgetMenu", "Register3PWidget", function( Context )
	Context.NewWidget( "Toggle Thirdperson", 835, function()
		_ontp = not _ontp
	end)
end)