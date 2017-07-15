function GM:CalcView(Player, _, _, fov)
	if Player:InVehicle() then return end
	if GetViewEntity() ~= Player then return end
	

	if not Player.FOVEase then
		Player.FOVEase = fov
	end

	Player.FOVEase = Player.FOVEase:lerp( fov + ( Player:OnGround() and Player:GetVelocity():Length2D() * 0.03 or 0 ), FrameTime() * 10 )

	return {
		fov = Player.FOVEase:Clamp(50, fov + 500)
	}
end