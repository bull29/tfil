local AddHook = Mutators.RegisterHooks("Eggheads", {
	"Lava.PostPlayerRagdolled"
})
local Vectors = {
	Big = Vector(5, 5, 5),
	Normal = Vector(1, 1, 1)
}

hook.Add("Lava.PostPlayerSpawn", "Eggheads", function(Player)
	Player:OnBoneExisting("ValveBiped.Bip01_Head1", function(bid)
		if Mutators.IsActive("Eggheads") then
			Player:ManipulateBoneScale(bid, Vectors.Big)
		elseif not Mutators.IsActive("Eggheads") then
			Player:ManipulateBoneScale(bid, Vectors.Normal)
		end
	end)
end)

Mutators.RegisterNewEvent("Eggheads", "Do to the amount of KNAWLEDGE consumed recently as a result of various mentors, everyone has big heads.", function()
	for Player in Values(player.GetAll()) do
		Player:OnBoneExisting("ValveBiped.Bip01_Head1", function(bid)
			Player:ManipulateBoneScale(bid, Vectors.Big)
		end)
	end

	AddHook(function(Player, Ragdoll)
		Ragdoll:OnBoneExisting("ValveBiped.Bip01_Head1", function(bid)
			Ragdoll:ManipulateBoneScale(bid, Vectors.Big)
		end)
	end)
end, function()
	for Player in Values(player.GetAll()) do
		Player:OnBoneExisting("ValveBiped.Bip01_Head1", function(bid)
			Player:ManipulateBoneScale(bid, Vectors.Normal)
		end)
	end
end)