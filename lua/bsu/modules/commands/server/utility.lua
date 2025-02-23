local function teleportPlayer(ply, pos)
	ply.bsu_oldPos = ply:GetPos() -- used for return cmd
	ply:SetPos(pos)
end

--[[
	Name: teleport
	Desc: Teleport players to a target player
	Arguments:
		1. Targets (players)
		2. Target (player)
]]
BSU.SetupCommand("teleport", function(cmd)
	cmd:SetDescription("Teleports players to a target player")
	cmd:SetCategory("utility")
	cmd:SetAccess(BSU.CMD_ADMIN)
	cmd:SetFunction(function(self)
		local targetA, targetB

		local teleported = {}

		targetA = self:GetPlayerArg(1)
		if targetA then
			self:CheckCanTarget(targetA, true)

			targetB = self:GetPlayerArg(2, true)
			if targetA == targetB then error("Cannot teleport target to same target") end
			self:CheckCanTarget(targetB, true)

			if self:CheckExclusive(targetA, true) then
				teleportPlayer(targetA, targetB:GetPos())
				table.insert(teleported, targetA)
			end
		else
			targetA = self:FilterTargets(self:GetPlayersArg(1, true), true, true)

			targetB = self:GetPlayerArg(2, true)
			self:CheckCanTarget(targetB, true)

			local pos = targetB:GetPos()
			for _, v in ipairs(targetA) do
				if self:CheckExclusive(v, true) then
					teleportPlayer(v, pos)
					table.insert(teleported, v)
				end
			end
		end

		if next(teleported) ~= nil then
			self:BroadcastActionMsg("%caller% teleported %teleported% to %target%", { teleported = teleported, target = targetB })
		end
	end)
end)
BSU.AliasCommand("tp", "teleport")

--[[
	Name: goto
	Desc: Teleport yourself to a player
	Arguments:
		1. Target (player)
]]
BSU.SetupCommand("goto", function(cmd)
	cmd:SetDescription("Teleports yourself to a player")
	cmd:SetCategory("utility")
	cmd:SetAccess(BSU.CMD_ADMIN)
	cmd:SetFunction(function(self)
		local target = self:GetPlayerArg(1, true)
		self:CheckCanTarget(target, true)

		local ply = self:GetCaller(true)
		if self:CheckExclusive(ply, true) then
			teleportPlayer(ply, target:GetPos())
			self:BroadcastActionMsg("%caller% teleported to %target%", { target = target })
		end
	end)
end)

--[[
	Name: bring
	Desc: Teleport players to yourself
	Arguments:
		1. Targets (players)
]]
BSU.SetupCommand("bring", function(cmd)
	cmd:SetDescription("Teleports yourself to a player")
	cmd:SetCategory("utility")
	cmd:SetAccess(BSU.CMD_ADMIN)
	cmd:SetFunction(function(self)
		local targets = self:FilterTargets(self:GetPlayersArg(1, true), true, true)

		local pos = self:GetCaller(true):GetPos()
		local teleported = {}
		for _, v in ipairs(targets) do
			if self:CheckExclusive(v, true) then
				teleportPlayer(v, pos)
				table.insert(teleported, v)
			end
		end

		if next(teleported) ~= nil then
			self:BroadcastActionMsg("%caller% brought %teleported%", { teleported = teleported })
		end
	end)
end)

--[[
	Name: return
	Desc: Return players to their original position
	Arguments:
		1. Targets (players, default: self)
]]
BSU.SetupCommand("return", function(cmd)
	cmd:SetDescription("Return a player or multiple players to their original position")
	cmd:SetCategory("utility")
	cmd:SetAccess(BSU.CMD_ADMIN)
	cmd:SetFunction(function(self)
		local targets = self:GetPlayersArg(1)
		if targets then
			targets = self:FilterTargets(targets, nil, true)
		else
			targets = { self:GetCaller(true) }
		end

		local returned = {}
		for _, v in ipairs(targets) do
			if self:CheckExclusive(v, true) and v.bsu_oldPos then
				v:SetPos(v.bsu_oldPos)
				v.bsu_oldPos = nil
				table.insert(returned, v)
			end
		end

		if next(returned) ~= nil then
			self:BroadcastActionMsg("%caller% returned %returned%", { returned = returned })
		end
	end)
end)
