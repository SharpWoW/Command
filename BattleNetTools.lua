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
local tinsert = table.insert
local tonumber = tonumber

-- API Upvalues
local BNGetToonInfo = BNGetToonInfo
local BNGetNumFriends = BNGetNumFriends
local BNGetFriendInfo = BNGetFriendInfo
local BNGetFriendInfoByID = BNGetFriendInfoByID
local BNGetFriendToonInfo = BNGetFriendToonInfo
local BNGetNumFriendToons = BNGetNumFriendToons

local C = Command

C.BattleNetTools = {}

local BNT = C.BattleNetTools
local CET = C.Extensions.Table
local CES = C.Extensions.String

local FRIEND_RETURN_ARGC = 16
local TOON_RETURN_ARGC = 16
local FRIENDTOON_RETURN_ARGC = 17

local function ParseBNFriendResult(...)
	local argc = select("#", ...)

	if argc ~= FRIEND_RETURN_ARGC then
		error("ParseBNFriendResult expected " .. FRIEND_RETURN_ARGC .. " arguments, got " .. argc)
		return nil
	end

	local id, pName, bTag, isBTagPresence, tName, tId, client, online, last, afk, dnd, bText, note, friend, bTime, sor = ...
	local f = {
		PresenceID = id,
		PresenceName = pName,
		BattleTag = bTag,
		IsBattleTagPresence = isBTagPresence,
		ToonName = tName,
		ToonID = tID,
		Client = client,
		IsOnline = online,
		LastOnline = last,
		IsAFK = afk,
		IsDND = dnd,
		BroadcastText = bText,
		NoteText = note,
		IsFriend = friend,
		BroadcastTime = bTime,
		CanSoR = sor
	}

	return f
end

local function ParseBNToonResult(...)
	local argc = select("#", ...)

	if argc ~= TOON_RETURN_ARGC then
		error("ParseBNToonResult expected " .. TOON_RETURN_ARGC .. " arguments, got " .. argc)
		return nil
	end

	local focus, name, client, realm, realmId, faction, race, class, guild, zone, lvl, text, bText, bTime, online, id = ...
	local t = {
		HasFocus = focus,
		Name = name,
		Client = client,
		Realm = realm,
		RealmID = realmId,
		Faction = faction,
		Race = race,
		Class = class,
		Guild = guild,
		Zone = zone,
		Level = tonumber(lvl),
		GameText = text,
		BroadcastText = bText,
		BroadcastTime = bTime,
		IsOnline = online,
		PresenceID = id
	}

	if t.Faction == FACTION_HORDE then
		t.FactionID = 0
	elseif t.Faction == FACTION_ALLIANCE then
		t.FactionID = 1
	else
		t.FactionID = -1
	end
	return t
end

local function ParseBNFriendToonResult(...)
	local argc = select("#", ...)

	if argc ~= FRIENDTOON_RETURN_ARGC then
		error("ParseBNFriendToonResult expected " .. FRIENDTOON_RETURN_ARGC .. " arguments, got " .. argc)
		return nil
	end

	local focus, name, client, realm, realmId, faction, race, class, guild, zone, lvl, text, bText, unknown, bTime, canSoR, id = ...
	local ft = {
		HasFocus = focus,
		Name = name,
		Client = client,
		Realm = realm,
		RealmID = realmId,
		Faction = faction,
		Race = race,
		Class = class,
		Guild = guild,
		Zone = zone,
		Level = lvl,
		GameText = text,
		BroadcastText = bText,
		Unknown = unknown,
		BroadcastTime = bTime,
		CanSoR = canSoR,
		ToonID = id
	}

	if ft.Faction == FACTION_HORDE then
		ft.FactionID = 0
	elseif ft.Faction == FACTION_ALLIANCE then
		ft.FactionID = 1
	else
		ft.FactionID = -1
	end
end

function BNT:GetFriend(index)
	if index < 1 or index > BNGetNumFriends() then
		return nil
	end
	return ParseBNFriendResult(BNGetFriendInfo(index))
end

function BNT:GetFriendById(id)
	return ParseBNFriendResult(BNGetFriendInfoByID(id))
end

function BNT:GetFriendByName(name, startIndex)
	local n = BNGetNumFriends()
	if n <= 0 then return nil end
	for i = startIndex or 1, n do
		local friend = ParseBNFriendResult(BNGetFriendInfo(i))
		if (friend.ToonName or ""):lower() == name:lower() then
			return friend, i
		end
	end
	return nil
end

function BNT:GetAllFriendsByName(name)
	local result = {}
	local friend, lastIndex
	repeat
		friend, lastIndex = self:GetFriendByName(name, (lastIndex or 0) + 1)
		if friend then tinsert(result, friend) end
	until friend == nil
	return result
end

function BNT:GetToon(id)
	return ParseBNToonResult(BNGetToonInfo(id))
end

function BNT:GetToonByName(name, startIndex)
	local numF = BNGetNumFriends()
	if numF <= 0 then return nil end
	for i = startIndex or 1, numF do
		for t = 1, BNGetNumFriendToons(i) do
			local toon = ParseBNToonResult(BNGetFriendToonInfo(i, t))
			if not CES:IsNullOrEmpty(toon.Name) and toon.Name:lower() == name:lower() then return toon, i end
		end
	end
	return nil
end

function BNT:GetAllToonsByName(name)
	local result = {}
	local toon, lastIndex
	repeat
		toon, lastIndex = self:GetToonByName(name, (lastIndex or 0) + 1)
		if toon then tinsert(result, toon) end
	until toon == nil
	return result
end
