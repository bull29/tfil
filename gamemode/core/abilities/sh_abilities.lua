
local Player = debug.getregistry().Player
local Abilities = {}
Abilities.Skills = {}

function Abilities.Register( name, desc, icon, onequip, onunequip )
	Abilities.Skills[ name ] = { desc, icon, onequip, onunequip }
end

function Player:HasAbility( ability )
	return SERVER and self.Ability == ability or CLIENT and self:GetNW2String("$ability") == ability
end

function Player:GetAbility()
	return SERVER and self.Ability or CLIENT and self:GetNW2String("$ability")
end

function Player:GetAbilityMeter()
	return SERVER and m_CurrentAbilityMeter or self:GetNW2Float("$abilitymeter")
end

function Player:UpdateAbilityMeter()
	if CLIENT then return end

	self.m_CurrentAbilityMeter = self.m_CurrentAbilityMeter or 100
	self.m_OldAbility = self.m_OldAbility or self:GetAbility()
	if self.m_HasUsedUpAbility == nil then
		self.m_HasUsedUpAbility = false
	end

	if self.m_OldAbility ~= self:GetAbility() then
		self.m_HasUsedUpAbility = false
		self.m_CurrentAbilityMeter = 100
		self.m_OldAbility = self:GetAbility()
	end

	if not self:Alive() then
		self.m_CurrentAbilityMeter = 100
	end

	if self.m_HasUsedUpAbility and self.m_CurrentAbilityMeter == 100 then
		self.m_HasUsedUpAbility = false
	end

	if not self.m_HasUsedUpAbility and self.m_CurrentAbilityMeter == 0 then
		self.m_HasUsedUpAbility = true
	end

	self:SetNW2Float( "$abilitymeter", self.m_CurrentAbilityMeter )
	self:SetNW2Bool( "$abilityusedup", self.m_HasUsedUpAbility )
end

function Player:ShiftAbilityMeter( n )
	if CLIENT then return end
	self.m_CurrentAbilityMeter = ( self.m_CurrentAbilityMeter + n ):min( 100 ):max( 0 )
	self:UpdateAbilityMeter()
end

function Player:HasUsedUpAbility()
	return SERVER and self.m_HasUsedUpAbility or self:GetNW2Bool("$abilityusedup")
end

function Player:CanUseAbility()
	return not ( (SERVER and self.m_HasUsedUpAbility) or self:GetNW2Bool("$abilityusedup") ) and ( SERVER and self.m_CurrentAbilityMeter or self:GetNW2Float( "$abilitymeter") ) > 0
end

function Player:SetAbilityInUse( tf )
	self:SetNW2Bool( "$abilityinuse", tf )
end

function Player:IsAbilityInUse()
	return self:GetNW2Bool("$abilityinuse")
end

_G.Abilities = Abilities