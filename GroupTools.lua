--[[
	{OUTPUT_LICENSE_SHORT}
--]]

local C = Command

C.GroupTools = {}

local GT = C.GroupTools

function GT:IsGroup()
	return UnitExists("party1")
end

function GT:IsRaid()
	return UnitInRaid("player")
end

function GT:IsGroupLeader(name)
	name = name or "player"
	return UnitIsPartyLeader(name) -- or (name == "player" and not self:IsGroup())
end

function GT:IsGroupFull()
	local num = 0
	local max = 40
	if self:IsRaid() then
		num = GetNumRaidMembers()
	elseif self:IsGroup() then
		num = GetNumPartyMembers()
		max = 5
	end
	if num >= max then return true end
	return false
end

function GT:IsRaidLeaderOrAssistant(name)
	name = name or "player"
	if not self:IsRaid() then return false end
	for i=1,GetNumRaidMembers() do
		local name, rank = (select(1, GetRaidRosterInfo(i))), (select(2, GetRaidRosterInfo(i)))
		if name:lower() == UnitName("player"):lower() then
			if rank >= 1 then return true end
		end
	end
	return false
end

function GT:IsRaidAssistant(name)
	name = name or "player"
	return UnitIsRaidOfficer(name)
end

function GT:IsInGroup(name)
	if self:IsRaid() then
		for i=1,GetNumRaidMembers() do
			local n = (select(1, GetRaidRosterInfo(i)))
			if n == name then return true end
		end
	elseif self:IsGroup() then
		return UnitInParty(name)
	end
	return false
end
