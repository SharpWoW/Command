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
local type = type

-- API Upvalues
local UnitName = UnitName
local GetLootMethod = GetLootMethod
local SetLootMethod = SetLootMethod
local GetOptOutOfLoot = GetOptOutOfLoot
local SetOptOutOfLoot = SetOptOutOfLoot
local SetLootThreshold = SetLootThreshold

local C = Command

--- Table holding all LootManager methods.
-- This is referenced "LM" in LootManager.lua.
-- @name Command.LootManager
-- @class table
--
C.LootManager = {}

local L = C.LocaleManager
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

local function PrettyMethod(method)
	if type(method) ~= "string" then return L("LOOT_METHOD_GROUP") end
	method = method:lower()
	if method:match("^f") then
		return L("LOOT_METHOD_FFA")
	elseif method:match("^g") then
		return L("LOOT_METHOD_GROUP")
	elseif method:match("^m") then
		return L("LOOT_METHOD_MASTER")
	elseif method:match("^n") then
		return L("LOOT_METHOD_NEEDGREED")
	elseif method:match("^r") then
		return L("LOOT_METHOD_ROUNDROBIN")
	end
	return method
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
		return L("LOOT_THRESHOLD_UNCOMMON")
	elseif level == 3 then
		return L("LOOT_THRESHOLD_RARE")
	elseif level == 4 then
		return L("LOOT_THRESHOLD_EPIC")
	elseif level == 5 then
		return L("LOOT_THRESHOLD_LEGENDARY")
	elseif level == 6 then
		return L("LOOT_THRESHOLD_ARTIFACT")
	elseif level == 7 then
		return L("LOOT_THRESHOLD_HEIRLOOM")
	end
	return L("LOOT_THRESHOLD_UNKNOWN")
end

function LM:SetLootMethod(method, master)
	if not GT:IsGroupLeader() then
		return false, "LOOT_SM_NOLEAD"
	end
	method = ParseLootMethod(method)
	if method == GetLootMethod() then
		return false, "LOOT_SM_DUPE", {PrettyMethod(method)}
	elseif method == "master" then
		if not master then
			master = UnitName("player")
		elseif not GT:IsInGroup(master) then
			return false, "LOOT_MASTER_NOEXIST", {master}
		end
		SetLootMethod(method, master)
		return "LOOT_SM_SUCCESSMASTER", {PrettyMethod(method), master}
	end
	SetLootMethod(method)
	return "LOOT_SM_SUCCESS", {PrettyMethod(method)}
end

function LM:SetLootMaster(master)
	if not GT:IsGroupLeader() then
		return false, "LOOT_SLM_NOLEAD"
	end
	local method = GetLootMethod()
	if method ~= "master" then
		return false, "LOOT_SLM_METHOD", {method}
	end
	if not master then
		return false, "LOOT_SLM_SPECIFY"
	elseif not GT:IsInGroup(master) then
		return false, "LOOT_MASTER_NOEXIST", {master}
	end
	SetLootMethod("master", master)
	return "LOOT_SLM_SUCCESS", {master}
end

function LM:SetLootThreshold(threshold)
	if not GT:IsGroupLeader() then
		return false, "LOOT_ST_NOLEAD"
	end
	threshold = ParseThreshold(threshold)
	if threshold < 2 or threshold > 7 then
		return false, "LOOT_ST_INVALID"
	end
	SetLootThreshold(threshold)
	return "LOOT_ST_SUCCESS", {PrettyThreshold(threshold)}
end

function LM:SetLootPass(pass)
	local p = false
	if type(pass) == "nil" then
		local current = GetOptOutOfLoot()
		SetOptOutOfLoot(not current)
		if not current then
			p = true
		end
	else
		SetOptOutOfLoot(pass)
		if pass then
			p = true
		end
	end
	if p then
		return "LOOT_SP_PASS", {UnitName("player")}
	end
	return "LOOT_SP_ROLL", {UnitName("player")}
end
