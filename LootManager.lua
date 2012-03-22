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

--- Table holding all LootManager methods.
-- This is referenced "LM" in LootManager.lua.
-- @name Command.LootManager
-- @class table
--
C.LootManager = {
}

local LM = C.LootManager
local GT = C.GroupTools

local function ParseLootMethod(method)
	if type(method) ~= "string" then return "group" end
	method = method:lower()
	if method:match("^f") then
		return "freeforall"
	elseif method:match("^g") then
		return "group"
	elseif method:match("^m") then
		return "master"
	elseif method:match("^n") then
		return "needbeforegreed"
	elseif method:match("^r") then
		return "roundrobin"
	end
	return "group"
end

local function ParseThreshold(threshold)
	if type(threshold) == "string" then
		threshold = threshold:lower()
		if threshold:match("^[ug]") then -- Uncommon/Green
			return 2
		elseif threshold:match("^[rsb]") then -- Rare/Superior/Blue
			return 3
		elseif threshold:match("^[ep]") then -- Epic/Purple
			return 4
		elseif threshold:match("^[lo]") then -- Legendary/Orange
			return 5
		elseif threshold:match("^a") then -- Artifact
			return 6
		elseif threshold:match("^h") then -- Heirloom
			return 7
		end
	elseif type(threshold) == "number" then
		return threshold
	end
	return 0
end

local function PrettyThreshold(level)
	if level == 2 then
		return "Uncommon"
	elseif level == 3 then
		return "Rare"
	elseif level == 4 then
		return "Epic"
	elseif level == 5 then
		return "Legendary"
	elseif level == 6 then
		return "Artifact"
	elseif level == 7 then
		return "Heirloom"
	end
	return "Unknown"
end

function LM:SetLootMethod(method, master)
	if not GT:IsGroupLeader() then
		return false, "Unable to change loot method, not group leader."
	end
	method = ParseLootMethod(method)
	if method == GetLootMethod() then
		return false, "The loot method is already set to " .. method .. "!"
	elseif method == "master" then
		if not master then
			master = UnitName("player")
			--return false, "A master looter must be specified when setting loot method to Master Loot."
		elseif not GT:IsInGroup(master) then
			return false, ("%q is not in the group and cannot be set as the master looter."):format(master)
		end
		SetLootMethod(method, master)
		return ("Successfully set the loot method to %s (%s)!"):format(method, master)
	end
	SetLootMethod(method)
	return ("Successfully set the loot method to %s!"):format(method)
end

function LM:SetLootMaster(master)
	if not GT:IsGroupLeader() then
		return false, "Unable to change master looter, not group leader."
	end
	local method = GetLootMethod()
	if method ~= "master" then
		return false, "Cannot set master looter when loot method is set to " .. method
	end
	if not master then
		return false, "Master looter not specified."
	elseif not GT:IsInGroup(master) then
		return false, ("%q is not in the group and cannot be set as the master looter."):format(master)
	end
	SetLootMethod("master", master)
	return ("Successfully set %s as the master looter!"):format(master)
end

function LM:SetLootThreshold(threshold)
	if not GT:IsGroupLeader() then
		return false, "Unable to change loot threshold, not group leader."
	end
	threshold = ParseThreshold(threshold)
	if threshold < 2 or threshold > 7 then
		return false, "Invalid loot threshold specified, please specify a loot threshold between 2 and 7 (inclusive)."
	end
	SetLootThreshold(threshold)
	return "Successfully set the loot threshold to " .. PrettyThreshold(threshold) .. "!"
end

function LM:SetLootPass(pass)
	local msg = UnitName("player") .. " is %s passing on loot."
	if type(pass) == "nil" then
		local current = GetOptOutOfLoot()
		SetOptOutOfLoot(not current)
		if current then
			msg = msg:format("not")
		else
			msg = msg:format("now")
		end
	else
		SetOptOutOfLoot(pass)
		if pass then
			msg = msg:format("now")
		else
			msg = msg:format("not")
		end
	end
	return msg
end
