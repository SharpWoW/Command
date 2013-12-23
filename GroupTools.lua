--[[
	* Copyright (c) 2011-2012 by Adam Hellberg.
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

-- Upvalues
local select = select

-- API Upvalues
local IsInRaid = IsInRaid
local IsInGroup = IsInGroup
local UnitExists = UnitExists
local GetLFGMode = GetLFGMode
local UnitInRaid = UnitInRaid
local UnitInParty = UnitInParty
local UnitIsConnected = UnitIsConnected
local GetRaidDifficultyID = GetRaidDifficultyID
local SetRaidDifficultyID = SetRaidDifficultyID
local GetRaidRosterInfo = GetRaidRosterInfo
local UnitIsGroupLeader = UnitIsGroupLeader
local GetNumGroupMembers = GetNumGroupMembers
local UnitIsGroupAssistant = UnitIsGroupAssistant
local GetNumSubGroupMembers = GetNumSubgroupMembers
local GetDungeonDifficultyID = GetDungeonDifficultyID
local SetDungeonDifficultyID = SetDungeonDifficultyID

local C = Command
local L = C.LocaleManager

--- Table containing all GroupTools methods.
-- This is referenced "GT" in GroupTools.lua.
-- @name Command.GroupTools
-- @class table
-- @field PartyMax Defined max value for party members.
-- @field RaidMax Defined max value for raid members.
--
C.GroupTools = {
	PartyMax = 5,
	RaidMax = 40,
	Difficulty = {
		Dungeon = {
			[DIFFICULTY_DUNGEON_NORMAL] = "GT_DUNGEON_NORMAL",
			[DIFFICULTY_DUNGEON_HEROIC] = "GT_DUNGEON_HEROIC",
			[DIFFICULTY_DUNGEON_CHALLENGE] = "GT_DUNGEON_CHALLENGE",
			Normal = DIFFICULTY_DUNGEON_NORMAL,
			Heroic = DIFFICULTY_DUNGEON_HEROIC,
			Challenge = DIFFICULTY_DUNGEON_CHALLENGE
		},
		Raid = {
			[DIFFICULTY_RAID10_NORMAL] = "GT_RAID_N10",
			[DIFFICULTY_RAID25_NORMAL] = "GT_RAID_N25",
			[DIFFICULTY_RAID10_HEROIC] = "GT_RAID_H10",
			[DIFFICULTY_RAID25_HEROIC] = "GT_RAID_H25",
			Normal10 = DIFFICULTY_RAID10_NORMAL,
			Normal25 = DIFFICULTY_RAID25_NORMAL,
			Heroic10 = DIFFICULTY_RAID10_HEROIC,
			Heroic25 = DIFFICULTY_RAID25_HEROIC
		}
	}
}

local GT = C.GroupTools
local CET = C.Extensions.Table

--- Check if player is in a group.
-- @return True if player is in group, false otherwise.
--
function GT:IsGroup()
	return UnitExists("party1") or self:IsRaid() or self:IsLFGGroup()
end

--- Check if the player is in an LFG group.
-- @return True if the player is in an LFG group, false otherwise.
--
function GT:IsLFGGroup()
	if IsPartyLFG() then return true end
	for k,_ in pairs(LFG_CATEGORY_NAMES) do
		if type(k) ~= "number" then -- Safety check, you never know with blizzard
			k = tonumber(k) or LE_LFG_CATEGORY_LFD
		end
		local status, _ = GetLFGMode(k)
		if status == "abandonedInDungeon" or status == "lfgparty" then
			return true
		end
	end
	return false
end

--- Check if player is in a party.
-- (Returns false if raid)
-- @return True if player is in a party, false otherwise.
--
function GT:IsParty()
	return IsInGroup() and not self:IsRaid() and not self:IsLFGGroup() --UnitExists("party1")
end

--- Check if player is in a raid.
-- @return True if the player is in a raid, false otherwise.
--
function GT:IsRaid()
	return IsInRaid() --UnitInRaid("player")
end

function GT:IsInstance()
	return IsInGroup(LE_PARTY_CATEGORY_INSTANCE)
end

--- Check if the unit is the group leader.
-- @param name Name/Unit to check, defaults to player.
-- @return True if unit is group leader, false otherwise.
--
function GT:IsGroupLeader(name)
	name = name or "player"
	return UnitIsGroupLeader(name) -- or (name == "player" and not self:IsGroup())
end

--- Get the number of group members in the current party or raid (including the player).
-- @return Number of group members.
--
function GT:GetNumGroupMembers()
	if not self:IsGroup() then return 0 end
	if self:IsRaid() then
		return GetNumGroupMembers()
	else
		return GetNumSubgroupMembers() + 1 -- We need to add one because it won't count the player
	end
end

--- Check if the group is full.
-- NOTE: Only checks for 5 players in a party and 40 players in a raid.
-- DOES NOT respect 10 and 25 man raids.
-- @return True if the group is full, false otherwise.
--
function GT:IsGroupFull()
	-- We need to add 1 to the number because it doesn't count the player.
	local num = self:GetNumGroupMembers()
	local max = self.PartyMax
	if self:IsRaid() then max = self.RaidMax end
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
	for i=1,GetNumGroupMembers() do
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
	return UnitIsGroupAssistant(name)
end

--- Check if the unit is in the player's group.
-- @param name Unit/Player Name to check.
-- @return True if the unit is in group, false otherwise.
--
function GT:IsInGroup(name)
	if self:IsRaid() then
		for i=1,GetNumGroupMembers() do
			local n = (select(1, GetRaidRosterInfo(i)))
			if n == name then return true end
		end
	elseif self:IsGroup() then
		return UnitInParty(name)
	end
	return false
end

--- Check if unit is online.
-- @param unit Uint/Player Name to check.
-- @return 1 if online, nil if not.
--
function GT:IsOnline(unit)
	return UnitIsConnected(unit)
end

--- Set the dungeon difficulty.
-- @param diff (number) Difficulty to change to.
-- @return String representing outcome.
--
function GT:SetDungeonDifficulty(diff)
	diff = tonumber(diff)
	if not diff then return false, "GT_DIFF_INVALID", {tostring(diff)} end
	if not CET:HasValue(self.Difficulty.Dungeon, diff) then return false, "GT_DIFF_INVALID", {tostring(diff)} end
	if diff == GetDungeonDifficultyID() then return false, "GT_DD_DUPE", {self:GetFriendlyDungeonDifficulty(diff)} end
	SetDungeonDifficultyID(diff)
	return "GT_DD_SUCCESS", {self:GetFriendlyDungeonDifficulty(diff)}
end

function GT:GetDungeonDifficultyString(diff)
	return self.Difficulty.Dungeon[tonumber(diff) or GetDungeonDifficultyID()]
end

--- Get a string representation of the dungeon difficulty.
-- @param diff (number) Difficulty to parse, defaults to current difficulty.
-- @return String representation of dungeon difficulty.
--
function GT:GetFriendlyDungeonDifficulty(diff)
	return L(self.Difficulty.Dungeon[tonumber(diff) or GetDungeonDifficultyID()])
end

--- Set the raid difficulty.
-- @param diff (number) Difficulty to change to.
-- @return String representing outcome.
--
function GT:SetRaidDifficulty(diff)
	diff = tonumber(diff)
	if not diff then return false, "GT_DIFF_INVALID", {tostring(diff)} end
	if not CET:HasValue(self.Difficulty.Raid, diff) then return false, "GT_DIFF_INVALID", {tostring(diff)} end
	if diff == GetRaidDifficultyID() then return false, "GT_RD_DUPE", {self:GetFriendlyRaidDifficulty(diff)} end
	SetRaidDifficultyID(diff)
	return "GT_RD_SUCCESS", {self:GetFriendlyRaidDifficulty(diff)}
end

--- Get a string representation of the raid difficulty.
-- @param diff (number) Difficulty to parse, defaults to current difficulty.
-- @return String representation of raid difficulty.
--
function GT:GetRaidDifficultyString(diff)
	return self.Difficulty.Raid[tonumber(diff) or GetRaidDifficultyID()]
end

--- Get a string representation of the raid difficulty.
-- @param diff (number) Difficulty to parse, defaults to current difficulty.
-- @return String representation of raid difficulty.
--
function GT:GetFriendlyRaidDifficulty(diff)
	return L(self.Difficulty.Raid[tonumber(diff) or GetRaidDifficultyID()])
end
