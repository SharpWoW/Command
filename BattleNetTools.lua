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

C.BattleNetTools = {

}

local BNT = C.BattleNetTools
local CET = C.Extensions.Table

local Friend = {
	PresenceID = 0,
	GivenName = "",
	SurName = "",
	ToonName = "",
	ToonID = 0,
	Client = "",
	IsOnline = false,
	LastOnline = 0,
	IsAFK = false,
	IsDND = false,
	BroadcastText = "",
	NoteText = "",
	IsFriend = false,
	BroadcastTime = 0,
	Unknown = false
}

local Toon = {
	Unknown = false,
	Name = "",
	Client = "",
	Realm = "",
	RealmID = "",
	Faction = -1,
	FactionString = "",
	Race = "",
	Class = "",
	Unknown2 = "",
	Zone = "",
	Level = 0,
	GameText = "",
	BroadcastText = "",
	BroadcastTime = "",
	Unknown3 = false,
	Unknown4 = 0
}

local function ParseBNFriendResult(...)
	local argc = select("#", ...)
	if argc ~= 15 then
		error("ParseBNFriendResult expected 15 arguments, got " .. argc)
		return nil
	end
	local id, gName, sName, tName, tId, client, online, last, afk, dnd, bText, note, friend, bTime, u = ...
	local f = CET:Copy(Friend)
	f.PresenceID = id
	f.GivenName = gName
	f.SurName = sName
	f.ToonName = tName
	f.ToonID = tID
	f.Client = client
	f.IsOnline = online
	f.LastOnline = last
	f.IsAFK = afk
	f.IsDND = dnd
	f.BroadcastText = bText
	f.NoteText = note
	f.IsFriend = friend
	f.BroadcastTime = bTime
	f.Unknown = u
	return f
end

local function ParseBNToonResult(...)
	local argc = select("#", ...)
	if argc ~= 16 then
		error("ParseBNToonResult expected 16 arguments, got " .. argc)
		return nil
	end
	local u, name, client, realm, realmId, faction, race, class, u2, zone, lvl, text, bText, bTime, u3, u4 = ...
	local t = CET:Copy(Toon)
	t.Unknown = u
	t.Name = name
	t.Client = client
	t.Realm = realm
	t.RealmID = realmId
	t.Faction = faction
	if t.Faction == 0 then
		t.FactionString = "Horde"
	elseif t.Faction == 1 then
		t.FactionString = "Alliance"
	end
	t.Race = race
	t.Class = class
	t.Unknown2 = u2
	t.Zone = zone
	t.Level = tonumber(lvl)
	t.GameText = text
	t.BroadcastText = bText
	t.BroadcastTime = bTime
	t.Unknown3 = u3
	t.Unknown4 = u4
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
		if friend.ToonName:lower() == name:lower() then
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
			if toon.Name:lower() == name:lower() then return toon end
		end
	end
	return nil
end
