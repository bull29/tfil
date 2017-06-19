local World = Entity(0)
local string = string
local tonumber = tonumber
local util = util
local Fourty = Vector( 0, 0, 40 )
local COLLISION_GROUP_DEBRIS = COLLISION_GROUP_DEBRIS

hook.Add("CalcMainActivity", "ClimbingAnims", function(Player, Velocity)
	if CLIENT and Player:GetNW2String("$climbquery") ~= "" then
		if not Player.RenderOverride then
			Player.RenderOverride = function(self)
				local climbQuery = self:GetNW2String("$climbquery")

				if climbQuery ~= "" then
					climbQuery = string.Split(climbQuery, " ")
					self.LerpedSideClimbVar = self.LerpedSideClimbVar or 0
					self.LerpedSideClimbVar = self.LerpedSideClimbVar:lerp(climbQuery[2] * 90)
					self.SetRenderAngles(self, self:GetRenderAngles():SetYaw(climbQuery[3]):SetRoll(self.LerpedSideClimbVar))
				end


				self:SetupBones()
				self:DrawModel()
			end
		end

		local Query = string.Split(Player:GetNW2String("$climbquery"), " ")

		if Query[1] ~= "0" then
			Player:SetCycle(CurTime() * 2 * (Query[1]))
		elseif Query[2] ~= "0" then
			Player:SetCycle(CurTime() * 1.5 * (Query[2]))
		else
			Player:SetCycle(0.2)
		end

		return ACT_ZOMBIE_CLIMB_UP, -1
	end
end)

hook.Add("SetupMove", "Climbing", function(Player, MoveData, Command)
	local tr = util.TraceLine({
		start = Player:GetShootPos(),
		endpos = Player:GetShootPos() + Player:GetAimVector() * 50,
		filter = Player,
		collisiongroup = COLLISION_GROUP_DEBRIS
	})
	local x = tr.HitNormal:Angle()

	local tr2 = util.TraceLine({
		start = Player:GetPos(),
		endpos = Player:GetPos() - Fourty,
		filter = Player,
		collisiongroup = COLLISION_GROUP_DEBRIS
	})

	if not tr2.Hit and tr.Hit and tr.HitWorld and not tr.HitSky and x.p == 0 and x.r == 0 and Command:KeyDown(2) then
		if SERVER and not Player:IsInWorld() then return end
		if hook.Call("LavaCanClimbBrush", nil, Player, tr.HitTexture ) == false then return end
		Command:ClearMovement()
		Command:ClearButtons()
		Command:SetButtons(2)
		MoveData:SetMoveAngles(Angle(0, x.y + 180, 0))
		MoveData:SetForwardSpeed( 1000 )

		local cNetString = "" -- Way too much shit to use different NWvars for; why not have it done in one go?

		if MoveData:KeyDown(8) then
			cNetString = cNetString .. "1 " .. (MoveData:GetSideSpeed() / 10000 / 2)

			if SERVER and util.IsInWorld(Player:EyePos() + Vector(0, 0, Player:GetRunSpeed() / 40)) or CLIENT then
				MoveData:SetOrigin(MoveData:GetOrigin() + Vector(0, 0, Player:GetRunSpeed() / 40))
			end
		elseif MoveData:KeyDown(16) then
			cNetString = cNetString .. "-1 " .. (-MoveData:GetSideSpeed() / 10000 / 2)
			MoveData:SetOrigin(MoveData:GetOrigin() + Vector(0, 0, -Player:GetRunSpeed() / 40))
		else
			cNetString = cNetString .. "0 " .. (MoveData:GetSideSpeed() / 10000)
		end
		MoveData:SetMaxClientSpeed( 100 )

		Player:SetGroundEntity(World)
		cNetString = cNetString .. " " .. x.y + 180
		Player:SetProperVar("String", "$climbquery", cNetString)
	elseif SERVER then
		Player:SetProperVar("String", "$climbquery", "")
	end
end)
