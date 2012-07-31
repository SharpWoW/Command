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

local function ParseBNFriendResult(...)
	local argc = select("#", ...)
	if argc ~= FRIEND_RETURN_ARGC then
		error("ParseBNFriendResult expected 15 arguments, got " .. argc)
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
		error("ParseBNToonResult expected 16 arguments, got " .. argc)
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
	if t.Faction == 0 then
		t.FactionString = "Horde"
	elseif t.Faction == 1 then
		t.FactionString = "Alliance"
	end
	return t
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

function BNT:GetFriendByName(name)
	local n = BNGetNumFriends()
	if n <= 0 then return nil end
	for i = 1, n do
		local friend = ParseBNFriendResult(BNGetFriendInfo(i))
		if (friend.ToonName or ""):lower() == name:lower() then
			return friend
		end
	end
	return nil
end

function BNT:GetToon(id)
	return ParseBNToonResult(BNGetToonInfo(id))
end

function BNT:GetToonByName(name)
	local numF = BNGetNumFriends()
	if numF <= 0 then return nil end
	for i = 1, numF do
		for t = 1, BNGetNumFriendToons(i) do
			local toon = ParseBNToonResult(BNGetFriendToonInfo(i, t))
			if not CES:IsNullOrEmpty(toon.Name) and toon.Name:lower() == name:lower() then return toon end
		end
	end
	return nil
end
