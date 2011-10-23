--[[
	* Copyright (c) 2011 by Adam Hellberg.
	* 
	* This file is part of Command.
	* 
	* Command is free software: you can redistribute it and/or modify
	* it under the terms of the GNU General Public License as published by
	* the Free Software Foundation, either version 3 of the License, or
	* (at your option) any later version.
	* 
	* Command is distributed in the hope that it will be useful,
	* but WITHOUT ANY WARRANTY; without even the implied warranty of
	* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
	* GNU General Public License for more details.
	* 
	* You should have received a copy of the GNU General Public License
	* along with Command. If not, see <http://www.gnu.org/licenses/>.
--]]

local C = Command

C.GroupTools = {}

local GT = C.GroupTools

function GT:IsGroup()
	return UnitExists("party1")
end

function GT:IsLFGGroup()
	return (select(1, GetLFGMode())) == "lfgparty"

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
