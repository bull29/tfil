EntityTable = EntityTable or {}
local lEntsTab = EntityTable
lEntsTab.Meta = debug.getregistry().Entity
lEntsTab.PlayerMeta = debug.getregistry().Player

function lEntsTab.Meta.__index(self, value)
	lEntsTab[self] = lEntsTab[self] or {}
	if lEntsTab[self][value] ~= nil then return lEntsTab[self][value] end
	if lEntsTab.Meta[value] then return lEntsTab.Meta[value] end --print( lEntsTab.Meta[ value ] )
	if not lEntsTab[self].CTable then lEntsTab[self].CTable = self:GetTable() or {} end
	if lEntsTab[self].CTable[value] ~= nil then return lEntsTab[self].CTable[value] end
	if value == "Owner" then return lEntsTab.Meta.GetOwner(self) end

	return nil
end

function lEntsTab.Meta.__newindex(self, index, value)
	lEntsTab[self] = lEntsTab[self] or {}
	lEntsTab[self][index] = value
end

function lEntsTab.PlayerMeta.__index(self, value)
	if lEntsTab.PlayerMeta[value] then return lEntsTab.PlayerMeta[value] end

	return lEntsTab.Meta.__index(self, value)
end

function lEntsTab.PlayerMeta.__newindex(self, index, value)
	return lEntsTab.Meta.__newindex(self, index, value)
end

hook.Add("OnEntityCreated", "HandleInLua", function(ent)
	if not lEntsTab[ent] then
		lEntsTab[ent] = {}
		lEntsTab[ent].CTable = ent:GetTable()
	end
end)

hook.Add("EntityRemoved", "HandleInLua", function(ent)
	lEntsTab[ent] = nil
end)

ents.GetCount = ents.GetCount or function() return #ents.GetAll() end

local x = function()
	if oldCount ~= ents.GetCount() then
		oldCount = ents.GetCount()

		for ent in pairs(lEntsTab) do
			if isentity(ent) then
				if not IsValid(ent) then
					lEntsTab[ent] = nil
				end
			end
		end
	end
end

hook.Add("Think", "CleanEntities", x)
timer.Create("ConstantCheck", FrameTime(), 0, x)
hook.CallOld = hook.CallOld or hook.Call
--[[ 
function hook.Call(...)
	print(...)
	hook.CallOld(...)
end

hook.Call = hook.CallOld--]] 
--[[ 
local x = os.clock()
Entity(1):GetTable()["hey"] = 5
for i = 1, 10000000 do
	local y = Entity(1):GetTable()["hey"]
end
print( os.clock() - x )


local x = os.clock()

for i = 1, 10000000 do
	local y = EntityTable[ Entity(1) ].CTable[ "hey" ]
end
print( os.clock() - x )



local x = os.clock()

for i = 1, 10000000 do
	local y = Entity(1).hey
end
print( os.clock() - x )

--]] 