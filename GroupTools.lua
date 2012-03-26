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

--- Table containing all GroupTools methods.
-- This is referenced "GT" in GroupTools.lua.
-- @name Command.GroupTools
-- @class table
-- @field PartyMax Defined max value for party members.
-- @field RaidMax Defined max value for raid members.
--
C.GroupTools = {
	PartyMax = 5,
	RaidMax = 40
}

local GT = C.GroupTools

--- Check if player is in a group.
-- @return True if player is in group, false otherwise.
--
function GT:IsGroup()
	return UnitExists("party1") or GT:IsRaid() or self:IsLFGGroup()
end

--- Check if the player is in an LFG group.
-- @return True if the player is in an LFG group, false otherwise.
--
function GT:IsLFGGroup()
	local status, _ = GetLFGMode()
	if status == "abandonedInDungeon" or status == "lfgparty" then
		return true
	end
	return false
end

--- Check if player is in a raid.
-- @return True if the player is in a raid, false otherwise.
--
function GT:IsRaid()
	return UnitInRaid("player")
end

--- Check if the unit is the group leader.
-- @param name Name/Unit to check, defaults to player.
-- @return True if unit is group leader, false otherwise.
--
function GT:IsGroupLeader(name)
	name = name or "player"
	return UnitIsPartyLeader(name) -- or (name == "player" and not self:IsGroup())
end

--- Get the number of group members in the current party or raid (including the player).
-- @return Number of group members.
--
function GT:GetNumGroupMembers()
	if not self:IsGroup() then return 0 end
	if UnitInRaid("player") then
		return GetNumRaidMembers()
	else
		return GetNumPartyMembers() + 1 -- We need to add one because it won't count the player
	end
end

--- Check if the group is full.
-- NOTE: Only checks for 5 players in a party and 40 players in a raid.
-- DOES NOT respect 10 and 25 man raids.
-- @return True if the group is full, false otherwise.
--
function GT:IsGroupFull()
	-- We need to add 1 to the number because it doesn't count the player.
	local num = 0
	local max = self.RaidMax
	if self:IsRaid() then
		num = GetNumRaidMembers()
	elseif self:IsGroup() then
		num = GetNumPartyMembers() + 1
		max = self.PartyMax
	end
	if num >= max then return true end
	return false
end

--- Check if the unit is raid leader or assistant.
-- @param name Unit to check, defaults to player.
-- @return True if the unit is raid leader or assistant, false otherwise.
--
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

--- Check if unit is raid assistant.
-- @param name Unit to check, defaults to player.
-- @return True if assistant, false otherwise.
--
function GT:IsRaidAssistant(name)
	name = name or "player"
	return UnitIsRaidOfficer(name)
end

--- Check if the unit is in the player's group.
-- @param name Unit/Player Name to check.
-- @return True if the unit is in group, false otherwise.
--
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
