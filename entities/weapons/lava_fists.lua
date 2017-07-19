AddCSLuaFile()

SWEP.PrintName = "Fists"
SWEP.Author = "Kilburn, robotboy655, MaxOfS2D & Tenrys"
SWEP.Purpose = "Well we sure as hell didn't use guns! We would just wrestle Hunters to the ground with our bare hands! I used to kill ten, twenty a day, just using my fists."
SWEP.Slot = 0
SWEP.SlotPos = 4
SWEP.Spawnable = true
SWEP.ViewModel = "models/v_me_fists.mdl"
SWEP.WorldModel = ""
SWEP.ViewModelFOV = 70
SWEP.UseHands = true
SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Automatic = true
SWEP.Primary.Ammo = "none"
SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = true
SWEP.Secondary.Ammo = "none"
SWEP.DrawCrosshair = true
SWEP.DrawAmmo = false
SWEP.HitDistance = 48
local SwingSound = Sound("WeaponFrag.Throw")
local HitSound = Sound("Flesh.ImpactHard")
local tVal
local math = math

function SWEP:Initialize()
	self:SetHoldType("normal")
end

function SWEP:SetupDataTables()
	self:NetworkVar("Float", 0, "NextMeleeAttack")
	self:NetworkVar("Float", 1, "NextSprint")
end

function SWEP:UpdateNextSprint()
	local vm = self.Owner:GetViewModel()
	self:SetNextSprint(CurTime() + vm:SequenceDuration() / vm:GetPlaybackRate())
end


function SWEP:PrimaryAttack()
	self.Owner:SetAnimation(PLAYER_ATTACK1)
	local anim = "Shove"
	tVal = true
	local vm = self.Owner:GetViewModel()
	vm:SendViewModelMatchingSequence(vm:LookupSequence(anim))

	self:EmitSound(SwingSound)
	self:UpdateNextSprint()

	self:SetNextMeleeAttack(CurTime() + 0.2)
	self:SetNextPrimaryFire(CurTime() + 0.6)
	self:SetNextSecondaryFire(CurTime() + 0.6)

	if SERVER then
		self.Owner:SetNW2Int( "$fist_attack_index", self.Owner:GetNW2Int( "$fist_attack_index" ) + 1 )
	end

	local tR_v = self.Owner:GetEyeTrace()

	if IsValid( tR_v.Entity ) then
		tR_v.Entity:SetVelocity( self.Owner:GetAimVector():SetZ( tR_v.Entity:OnGround() and 0.2 or -0.2	 ) * 500 )
	end
end

function SWEP:Reload()
	if not self.Owner:HasAbility("Limpy Larry") then return end
	self.NextRagdollTime = self.NextRagdollTime or CurTime() + 1
	if SERVER and self.NextRagdollTime < CurTime() then
		Ragdoll.Enable( self.Owner )
		self.Owner.m_NextRagdollifcationTime = CurTime() + 1
	end
end

function SWEP:SecondaryAttack()
	self:PrimaryAttack()
end

function SWEP:OnDrop()
	self:Remove()
end

function SWEP:Deploy()
	local vm = self.Owner:GetViewModel()
	vm:SendViewModelMatchingSequence(vm:LookupSequence("Draw"))
	vm:SetPlaybackRate(1)
	self:SetNextPrimaryFire(CurTime() + vm:SequenceDuration() / 1)
	self:SetNextSecondaryFire(CurTime() + vm:SequenceDuration() / 1)
	self:UpdateNextSprint()

	return true
end

function SWEP:Think()
	local owner = self:GetOwner()
	local vm = owner:GetViewModel()
	local anim = vm:GetSequenceName(vm:GetSequence())
	local curtime = CurTime()
	local Sprinttime = self:GetNextSprint()

	if (Sprinttime > 0 and curtime > Sprinttime) and owner:GetVelocity():Length2D() > owner:GetRunSpeed() - 10 and owner:OnGround() then
		vm:SendViewModelMatchingSequence(vm:LookupSequence("Sprint"))
		self:UpdateNextSprint()
	elseif owner:GetNW2String("$climbquery", "") ~= "" and anim ~= "Shove" then
		self:SendWeaponAnim(191)
		self:SetCycle(0)
		vm:SetCycle(0)
		self:SetPlaybackRate(0)
	elseif not owner:OnGround() then
		vm:SendViewModelMatchingSequence(vm:LookupSequence("Attack_Charge_Idle"))
	elseif owner:OnGround() and anim == "Attack_Charge_Idle" then
		vm:SendViewModelMatchingSequence(vm:LookupSequence("Idle"))
	end

	if not owner:OnGround() and not owner.m_FistsHasJumped then
		owner.m_FistsHasJumped = true
		owner:ViewPunch(Angle(-5, math.random(-1, 1), math.random(-1, 1)))
	elseif owner:OnGround() and owner.m_FistsHasJumped then
		owner.m_FistsHasJumped = nil
		owner:ViewPunch(Angle(-2, math.random(-1, 1), math.random(-1, 1)))
	end

	if owner:OnGround() and (owner:KeyDown(4) or owner:Crouching()) and not owner.m_FistHasCrouched then
		owner:ViewPunch(Angle(-3.5, math.random(-0.5, 0.5), math.random(-0.5, 0.5)))
		owner.m_FistHasCrouched = true
	elseif (not owner:KeyDown(4) and not owner:Crouching()) and owner.m_FistHasCrouched then
		owner:ViewPunch(Angle(-2, math.random(-0.5, 0.5), math.random(-0.5, 0.5)))
		owner.m_FistHasCrouched = nil
	end
end

function SWEP:PreDrawViewModel(View, Weapon, Player)
	View.RenderOverride = function() end
end

if SERVER then return end
local surface = surface
local draw = draw
local c_CValue = 1
local pColor = pColor
local vgui = vgui

function SWEP:DrawHUD()
	if vgui.CursorVisible() then return end
	local tr = LocalPlayer():GetEyeTrace()
	local tosc

	cam.Wrap3D(function()
		tosc = tr.HitPos:ToScreen()
	end)

	c_CValue = c_CValue:lerp(LocalPlayer():GetVelocity():Length() / 5)

	if tVal then
		c_CValue = c_CValue + ScrH() / 20
		tVal = nil
	end

	if LocalPlayer():ShouldDrawLocalPlayer() then
		c_CValue = c_CValue:max(15)
	end

	local xE, xT = (ScrH() / 100 + c_CValue), (c_CValue * ScrH() / 300)
	draw.WebImage(WebElements.QuadCircle, tosc.x, tosc.y, xE / 2 + (CurTime() * 10):sin() * 5, xE / 2 + (CurTime() * 10):sin() * 5, pColor():Alpha(255 - c_CValue), (c_CValue / 5):sin() * 180)
	draw.WebImage(WebElements.CircleOutline, tosc.x, tosc.y, xT + (CurTime() * 10):sin() * 5, xT + (CurTime() * 10):sin() * 5, pColor():Alpha(255 - c_CValue), 0)
end