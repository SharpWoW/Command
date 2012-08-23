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
local wipe = wipe
local pairs = pairs
local ipairs = ipairs
local select = select
local tostring = tostring

-- API Upvalues
local UnitName = UnitName
local IsInGuild = IsInGuild
local UnitInRaid = UnitInRaid
local InviteUnit = InviteUnit
local UninviteUnit = UninviteUnit
local GetNumFriends = GetNumFriends
local GetFriendInfo = GetFriendInfo
local PromoteToLeader = PromoteToLeader
local DemoteAssistant = DemoteAssistant
local BNET_CLIENT_WOW = BNET_CLIENT_WOW
local StaticPopup_Show = StaticPopup_Show
local GetNumGuildMembers = GetNumGuildMembers
local GetGuildRosterInfo = GetGuildRosterInfo
local PromoteToAssistant = PromoteToAssistant

local MODE_BLACKLIST = 0
local MODE_WHITELIST = 1

local C = Command
local L = C.LocaleManager
local CM
local GT = C.GroupTools
local AM = C.AuthManager
local BNT = C.BattleNetTools
local CCM
local CET = C.Extensions.Table
local log

--- Table containing all PlayerManager methods.
-- This is referenced "PM" in PlayerManager.lua.
-- @name Command.PlayerManager
-- @class table
-- @field Access Table containing all available access groups.
--
C.PlayerManager = {
	VarVersion = 1,
	Dialogs = {
		Kick = "COMMAND_CONFIRMKICK"
	},
	Invites = {},
	Access = {
		Min = 0,
		Max = 4,
		Local = -1,
		Groups = {
			Owner = {
				Level = 0,
				Name = "Owner",
				Allow = {},
				Deny = {}
			},
			Admin = {
				Level = 1,
				Name = "Admin",
				Allow = {},
				Deny = {}
			},
			Op = {
				Level = 2,
				Name = "Op",
				Allow = {},
				Deny = {}
			},
			User = {
				Level = 3,
				Name = "User",
				Allow = {},
				Deny = {}
			},
			Banned = {
				Level = 4,
				Name = "Banned",
				Allow = {},
				Deny = {}
			}
		}
	}
}

local Players = {}

local List = {} -- Whitelist/Blacklist

local PM = C.PlayerManager

local Player = {
	Info = {
		Name = nil,
		Group = nil
	},
	Access = {
		Allow = {},
		Deny = {}
	},
	Settings = {
		Invite = true,
		Locked = false
	}
}

local KickName, KickSender, KickReason

local function Kick(name, sender, reason)
	UninviteUnit(name, reason)
	if GT:IsGroup() then
		if type(reason) == "string" then
			local msg
			if CM.LastChannel == "WHISPER" or CM.LastChannel == "BNET" then
				msg = L(PM:GetOrCreatePlayer(sender).Settings.Locale, "PM_KICK_REASON", true):format(name, sender, reason)
			else
				msg = L("PM_KICK_REASON"):format(name, sender, reason)
			end
			CM:SendMessage(msg, CM.LastChannel, CM.LastTarget)
		else
			local msg
			if CM.LastChannel == "WHISPER" or CM.LastChannel == "BNET" then
				msg = L(PM:GetOrCreatePlayer(sender).Settings.Locale, "PM_KICK", true):format(name, sender)
			else
				msg = L("PM_KICK"):format(name, sender)
			end
			CM:SendMessage(msg, CM.LastChannel, CM.LastTarget)
		end
	else
		local msg = L(PM:GetOrCreatePlayer(sender).Settings.Locale, "PM_KICK_NOTIFY", true):format(name)
		CM:SendMessage(msg, "WHISPER", sender)
	end
	local msg = L(PM:GetOrCreatePlayer(name).Settings.Locale, "PM_KICK_TARGET", true):format(sender)
	CM:SendMessage(msg, "WHISPER", name)
end

local function KickCancelled(name, sender)
	local msg
	if CM.LastTarget and (CM.LastChannel == "WHISPER" or CM.LastChannel == "BNET") then
		msg = L(PM:GetOrCreatePlayer(CM.LastTarget).Settings.Locale, "PM_KICK_DENIED", true):format(sender, name)
	else
		msg = L("PM_KICK_DENIED"):format(sender, name)
	end
	CM:SendMessage(msg, CM.LastChannel, CM.LastTarget)
end

StaticPopupDialogs[PM.Dialogs.Kick] = {
	text = "PM_KICK_POPUP",
	button1 = "YES",
	button2 = "NO",
	OnAccept = function() Kick(KickName, KickSender, KickReason) end,
	OnCancel = function() KickCancelled(KickName, KickSender) end,
	timeout = 10,
	whileDead = true,
	hideOnEscape = false
}

--- Initialize the player manager.
--
function PM:Init()
	log = C.Logger
	CM = C.ChatManager
	CCM = C.CommandManager
	self:LoadSavedVars()
end

--- Load saved variables.
--
function PM:LoadSavedVars()
	if type(C.Global["PLAYER_MANAGER"]) ~= "table" then
		C.Global["PLAYER_MANAGER"] = {}
	end
	self.Data = C.Global["PLAYER_MANAGER"]
	if not self.Data.VERSION or self.Data.VERSION < self.VarVersion then
		if type(self.Data.PLAYERS) == "table" and not self.Data.VERSION then
			wipe(self.Data.PLAYERS)
		end
		self.Data.VERSION = self.VarVersion
	end
	if type(self.Data.PLAYERS) ~= "table" then
		self.Data.PLAYERS = {}
	end
	if type(self.Data.PLAYERS[GetRealmName()]) ~= "table" then
		self.Data.PLAYERS[GetRealmName()] = {}
	end
	if type(self.Data.LIST_MODE) ~= "number" then
		self.Data.LIST_MODE = MODE_BLACKLIST
	end
	if type(self.Data.LIST) ~= "table" then
		self.Data.LIST = {}
	end
	if type(self.Data.GROUP_PERMS) ~= "table" then
		self.Data.GROUP_PERMS = {}
		for k,v in pairs(self.Access.Groups) do
			self.Data.GROUP_PERMS[k] = {
				Allow = {},
				Deny = {}
			}
			for _,v in pairs(self.Access.Groups[k].Allow) do
				table.insert(self.Data.GROUP_PERMS[k].Allow, v)
			end
			for _,v in pairs(self.Access.Groups[k].Deny) do
				table.insert(self.Data.GROUP_PERMS[k].Deny, v)
			end
		end
	end
	for k,v in pairs(self.Data.GROUP_PERMS) do
		self.Access.Groups[k].Allow = v.Allow
		self.Access.Groups[k].Deny = v.Deny
	end
	Players = self.Data.PLAYERS[GetRealmName()]
	List = self.Data.LIST

	self:UpdatePlayerData()
end

function PM:UpdatePlayerData()
	for realm,players in pairs(self.Data.PLAYERS) do
		for name,player in pairs(players) do
			if not player.Info.Realm then
				player.Info.Realm = realm
			end
		end
	end
end

function PM:ParseMessage(message)
	local name = message:match(L("PM_MATCH_INVITEACCEPTED_PARTY"))
	if not name then name = message:match(L("PM_MATCH_INVITEACCEPTED_RAID")) end
	if name then
		if not self.Invites[name] then return end
		self.Invites[name] = nil
		return
	end
	name = message:match(L("PM_MATCH_INGROUP"))
	if name then
		if not self.Invites[name] then return end
		CM:SendMessage(L("PM_INVITE_INOTHERGROUP"):format(name), "WHISPER", self.Invites[name][1])
		self.Invites[name] = nil
		return
	end
	name = message:match(L("PM_MATCH_INVITEDECLINED"))
	if name then
		if not self.Invites[name] then return end
		CM:SendMessage(L("PM_INVITE_DECLINED"):format(name), "WHISPER", self.Invites[name][1])
		self.Invites[name] = nil
	end
end

--- Get or create a player.
-- @param name Name of player.
-- @return Player from list of players if exists, otherwise a new player object.
--
function PM:GetOrCreatePlayer(name, realm)
	name = (name or UnitName("player")):lower():gsub("^%l", string.upper)
	realm = realm or GetRealmName()
	if CET:HasKey(self.Data.PLAYERS[realm], name) then
		return self.Data.PLAYERS[realm][name]
	else
		local player = CET:Copy(Player)
		player.Info.Name = name
		player.Info.Realm = realm
		if player.Info.Name == UnitName("player") then
			player.Info.Group = self.Access.Groups.Owner.Name
		else
			player.Info.Group = self.Access.Groups.User.Name
		end
		self.Data.PLAYERS[realm][player.Info.Name] = player
		log:Normal(L("PM_PLAYER_CREATE"):format(player.Info.Name, player.Info.Realm))
		return player
	end
end

--- Update a player and subsequently save them.
-- @param player Player object to update.
--
function PM:UpdatePlayer(player)
	self.Data.PLAYERS[player.Info.Realm][player.Info.Name] = player
	log:Normal(L("PM_PLAYER_UPDATE"):format(player.Info.Name, player.Info.Realm))
end

--- Completely remove a command from a group's access list.
-- Removed from both the allow and deny list.
-- @param group Name of group to modify.
-- @param command Name of command to remove.
-- @return String stating that the command has been removed or false if error.
-- @return Error message is unsuccessful, otherwise nil.
--
function PM:GroupAccessRemove(group, command)
	group = group:gsub("^%l", string.upper)
	if not command then return false, "PM_ERR_NOCOMMAND" end
	for i,v in pairs(self.Access.Groups[k].Allow) do
		if v == command then table.remove(self.Access.Groups[k].Allow, i) end
	end
	for i,v in pairs(self.Access.Groups[k].Deny) do
		if v == command then table.remove(self.Access.Groups[k].Deny, i) end
	end
	return "PM_GA_REMOVED", {command, group}
end

--- Modify the access of a command for a specific group.
-- @param group Name of group to modify.
-- @param command Name of command to allow or deny.
-- @param allow True to allow command, false to deny.
-- @return String stating the result, or false if error.
-- @return Error message if unsuccessful, otherwise nil.
--
function PM:GroupAccess(group, command, allow)
	if not command then return false, "PM_ERR_NOCOMMAND" end
	local mode = true
	if allow then
		if CET:HasValue(self.Access.Groups[group].Deny, command) then
			for i,v in ipairs(player.Access.Deny) do
				if v == command then table.remove(player.Access.Deny, i) end
			end
		end
		if CET:HasValue(self.Access.Groups[group].Allow, command) then
			return false, "PM_GA_EXISTSALLOW", {group}
		end
		table.insert(self.Access.Groups[group].Allow, command)
	else
		if CET:HasValue(self.Access.Groups[group].Allow, command) then
			for i,v in pairs(self.Access.Groups[group].Allow) do
				if v == command then table.remove(self.Access.Groups[group].Allow, i) end
			end
		end
		if CET:HasValue(self.Access.Groups[group].Deny, command) then
			return false, "PM_GA_EXISTSDENY", {group}
		end
		table.insert(self.Access.Groups[group].Deny, command)
		mode = false
	end
	if mode then
		return "PM_ACCESS_ALLOWED", {command, group}
	end
	return "PM_ACCESS_DENIED", {command, group}
end

--- Completely remove a command from a player's access list.
-- Removes from both the allow and deny list.
-- @param player Player object of the player to modify.
-- @param command Name of command to remove.
-- @return String stating that the command has been removed or false if error.
-- @return Error message is unsuccessful, otherwise nil.
--
function PM:PlayerAccessRemove(player, command)
	if not command then return false, "PM_ERR_NOCOMMAND" end
	if self:IsLocked(player) then return false, "PM_ERR_LOCKED" end
	for i,v in pairs(player.Access.Allow) do
		if v == command then table.remove(player.Access.Allow, i) end
	end
	for i,v in pairs(player.Access.Deny) do
		if v == command then table.remove(player.Access.Deny, i) end
	end
	self:UpdatePlayer(player)
	return "PM_PA_REMOVED", {command, player.Info.Name}
end

--- Modify the access of a command for a specific player.
-- @param player Player object of the player to modify.
-- @param command Name of command to allow or deny.
-- @param allow True to allow command, false to deny.
-- @return String stating the result, or false if error.
-- @return Error message if unsuccessful, otherwise nil.
--
function PM:PlayerAccess(player, command, allow)
	if not command then return false, "PM_ERR_NOCOMMAND" end
	if self:IsLocked(player) then return false, "PM_ERR_LOCKED" end
	local mode = true
	if allow then
		if CET:HasValue(player.Access.Deny, command) then
			for i,v in ipairs(player.Access.Deny) do
				if v == command then table.remove(player.Access.Deny, i) end
			end
		end
		if CET:HasValue(player.Access.Allow, command) then
			return false, "PM_PA_EXISTSALLOW", {player.Info.Name}
		end
		table.insert(player.Access.Allow, command)
	else
		if CET:HasValue(player.Access.Allow, command) then
			for i,v in pairs(player.Access.Allow) do
				if v == command then table.remove(player.Access.Allow, i) end
			end
		end
		if CET:HasValue(player.Access.Deny, command) then
			return false, "PM_PA_EXISTSDENY", {player.Info.Name}
		end
		table.insert(player.Access.Deny, command)
		mode = false
	end
	self:UpdatePlayer(player)
	if mode then
		return "PM_ACCESS_ALLOWED", {command, player.Info.Name}
	end
	return "PM_ACCESS_DENIED", {command, player.Info.Name}
end

--- Check if provided player is locked.
-- @param player Player object to check.
--
function PM:IsLocked(player)
	if type(player) == "table" then
		if player.Settings then
			return player.Settings.Locked
		else
			return false
		end
	elseif type(player) == "string" then
		return self:IsLocked(self:GetOrCreatePlayer(player))
	end
	return true
end

--- Set lock status on a player.
-- @param player Player object to change.
-- @param locked True for locked, False for unlocked.
--
function PM:SetLocked(player, locked)
	if type(player) ~= "table" then
		player = self:GetOrCreatePlayer(tostring(player))
	end
	player.Settings.Locked = locked
	local mode = true
	if not locked then mode = false end
	if mode then
		return "PM_LOCKED", {player.Info.Name}
	end
	return "PM_UNLOCKED", {player.Info.Name}
end

--- Check if supplied player is on the player's friends list.
-- @param player Player object of the player to check.
-- @return True if friend, false otherwise.
--
function PM:IsFriend(player)
	if GetNumFriends() <= 0 then return false end
	for i=1,GetNumFriends() do
		local name = (select(1, GetFriendInfo(i)))
		if name == player.Info.Name then return true end
	end
	return false
end

--- Check if supplied player is on the player's BN friends list.
-- Note: If the BN friend is currently offline while his character is online, this will return false regardless.
-- Which means, BN friends that are disconnected from Battle.Net but still in the group are treated as normal users.
-- @param player Player object of the player to check.
-- @return True if BN friend, false otherwise.
--
function PM:IsBNFriend(player)
	local friend = BNT:GetFriendByName(player.Info.Name)
	if not friend then return false end
	if friend.Client == BNET_CLIENT_WOW then return true end
	return false
end

--- Check if the supplied player is in the player's guild.
-- @param player Player object of the player to check.
-- @return True if in guild, false otherwise.
--
function PM:IsInGuild(player)
	if not IsInGuild() then return false end
	if GetNumGuildMembers() <= 1 then return false end
	for i=1,GetNumGuildMembers() do
		local name = (select(1, GetGuildRosterInfo(i)))
		if name == player.Info.Name then return true end
	end
	return false
end

--- Get the current access level of supplied player.
-- @param player Player to check.
-- @return Access level of the player.
--
function PM:GetAccess(player)
	return self.Access.Groups[player.Info.Group].Level
end

--- Check if player has access to command.
-- @param player Player object of the player to check.
-- @param command Command object of the command to check.
-- @return True if player has access, false otherwise.
--
function PM:HasAccess(player, command)
	if player.Info.Name == UnitName("player") then return true end
	if (self:IsInGuild(player) or self:IsBNFriend(player) or GT:IsRaidAssistant(player.Info.Name)) and command.Access >= self.Access.Groups.Op.Level then
		if self:GetAccess(player) >= self.Access.Groups.Banned.Level then
			return false
		end
		return true
	end
	local hasAccess = self:GetAccess(player) <= command.Access
	local auth = AM.Users[player.Info.Name:upper()]
	if auth then
		local authLevel = tonumber(auth.Level)
		if authLevel and auth.Enabled and auth.Authed then
			if authLevel <= command.Access then hasAccess = true end
		end
	end
	local group = self.Access.Groups[player.Info.Group]
	if CET:HasValue(group.Allow, command.Name) then hasAccess = true end
	if CET:HasValue(group.Deny, command.Name) then hasAccess = false end
	if CET:HasValue(player.Access.Allow, command.Name) then hasAccess = true end
	if CET:HasValue(player.Access.Deny, command.Name) then hasAccess = false end
	if not self:IsCommandAllowed(command) then
		hasAccess = false
	end
	return hasAccess
end

function PM:IsCommandAllowed(command)
	local name
	if type(command) == "table" then
		name = command.Name
	elseif type(command) == "string" then
		name = command
	else
		return false
	end
	if (List[command.Name] and self:GetListMode() == MODE_BLACKLIST) or (not List[command.Name] and self:GetListMode() == MODE_WHITELIST) then
		return false
	end
	return true
end

--- Set the access group of supplied player.
-- @param player Player to modify.
-- @param group Group name to set the player to.
-- @return String stating the result of the operation, false if error.
-- @return Error message if unsuccessful, nil otherwise.
--
function PM:SetAccessGroup(player, group)
	group = group:gsub("^%l", string.upper)
	if player.Info.Name == UnitName("player") then
		return false, "PM_SAG_SELF"
	end
	if not CET:HasKey(self.Access.Groups, group) then
		return false, "PM_SAG_NOEXIST", {group}
	end
	if self:IsLocked(player) then return false, "PM_ERR_LOCKED" end
	player.Info.Group = group
	self:UpdatePlayer(player)
	return "PM_SAG_SET", {player.Info.Name, PM:GetAccess(player), player.Info.Group}
end

--- Give player Owner access.
-- @param player Player to modify.
-- @return String stating the result of the operation, false if error.
-- @return Error message if unsuccessful, nil otherwise.
--
function PM:SetOwner(player)
	return self:SetAccessGroup(player, self.Access.Groups.Owner.Name)
end

--- Give player Admin access.
-- @param player Player to modify.
-- @return String stating the result of the operation, false if error.
-- @return Error message if unsuccessful, nil otherwise.
--
function PM:SetAdmin(player)
	return self:SetAccessGroup(player, self.Access.Groups.Admin.Name)
end

--- Give player Op access.
-- @param player Player to modify.
-- @return String stating the result of the operation, false if error.
-- @return Error message if unsuccessful, nil otherwise.
--
function PM:SetOp(player)
	return self:SetAccessGroup(player, self.Access.Groups.Op.Name)
end

--- Give player User access.
-- @param player Player to modify.
-- @return String stating the result of the operation, false if error.
-- @return Error message if unsuccessful, nil otherwise.
--
function PM:SetUser(player)
	return self:SetAccessGroup(player, self.Access.Groups.User.Name)
end

--- Ban player.
-- What this really does is set the access level to "Banned", effectively blocking the player from using any commands.
-- Unless there is a command that requires access level "Banned". (Could be used for appeal commands).
-- @param player Player to modify.
-- @return String stating the result of the operation, false if error.
-- @return Error message if unsuccessful, nil otherwise.
--
function PM:BanUser(player)
	return self:SetAccessGroup(player, self.Access.Groups.Banned.Name)
end

--- Invite a player to group.
-- Also sends a message to the invited player about the event.
-- @param player Player object of player to invite.
-- @param sender Player object of the inviting player.
-- @param pID Presence ID if this was an Invite(Me) command from B.Net chat
-- @return String stating the result of the invite, false if error.
-- @return Error message if unsuccessful, nil otherwise.
--
function PM:Invite(player, sender, pID)
	if not sender then sender = self:GetOrCreatePlayer(UnitName("player")) end
	if player.Info.Name == UnitName("player") then
		return false, "PM_INVITE_SELF"
	elseif GT:IsInGroup(player.Info.Name) then
		return false, "PM_INVITE_INGROUP", {player.Info.Name}
	elseif GT:IsGroupFull() then
		return false, "PM_INVITE_FULL"
	end
	if GT:IsGroupLeader() or GT:IsRaidLeaderOrAssistant() or not GT:IsGroup() then
		if self.Invites[player.Info.Name] then
			return false, "PM_INVITE_ACTIVE", {player.Info.Name}
		elseif player.Info.Name == sender.Info.Name then
			if player.Info.Realm == GetRealmName() or not pID then
				InviteUnit(player.Info.Name)
			else -- Invite(Me) command sent from B.Net chat
				BNInviteFriend(pID)
			end
			return "PM_INVITE_NOTIFYTARGET"
		elseif player.Settings.Invite then
			InviteUnit(player.Info.Name)
			local msg = L(player.Settings.Locale, "PM_INVITE_NOTIFY", true):format(sender.Info.Name, player.Info.Name)
			CM:SendMessage(msg, "WHISPER", player.Info.Name)
			self.Invites[player.Info.Name] = {sender.Info.Name}
			return "PM_INVITE_SUCCESS", {player.Info.Name}
		else
			return false, "PM_INVITE_BLOCKED", {player.Info.Name}
		end
	end
	return false, "PM_INVITE_NOPRIV", {player.Info.Name}
end

--- Stop sending Command invites to player.
-- @param player Player object of the player.
-- @return String stating the result of the operation, false if error.
-- @return Error message if unsuccessful, nil otherwise.
--
function PM:DenyInvites(player, isWhisper)
	if player.Settings.Invite then
		player.Settings.Invite = false
		self:UpdatePlayer(player)
		if isWhisper then
			return "PM_DI_BLOCKING"
		end
		local msg = L(player.Settings.Locale, "PM_DI_BLOCKING", true)
		CM:SendMessage(msg, "WHISPER", player.Info.Name)
		return "PM_DI_SUCCESS", {player.Info.Name}
	end
	return false, "PM_DI_FAIL"
end

--- Allow sending Command invites to player.
-- @param player Player object of the player.
-- @return String stating the result of the operation, false if error.
-- @return Error message if unsuccessful, nil otherwise.
--
function PM:AllowInvites(player, isWhisper)
	if player.Settings.Invite then
		return false, "PM_AI_FAIL"
	end
	player.Settings.Invite = true
	self:UpdatePlayer(player)
	if isWhisper then
		return "PM_AI_ALLOWING"
	end
	local msg = L(player.Settings.Locale, "PM_AI_ALLOWING", true)
	CM:SendMessage(msg, "WHISPER", player.Info.Name)
	return "PM_AI_SUCCESS", {player.Info.Name}
end

--- Kick a player from the group.
-- @param player Player object of the player to kick.
-- @param sender Player object of the player who requested the kick.
-- @param reason Optional reason for the kick.
-- @param override True to kick even if target is friend.
-- @return String stating the result of the kick, false if error.
-- @return Error message if unsuccessful, nil otherwise.
--
function PM:Kick(player, sender, reason, override)
	if player.Info.Name == UnitName("player") then
		return false, "PM_KICK_SELF"
	elseif (self:IsFriend(player) or self:IsBNFriend(player)) and not override then
		return false, "PM_KICK_FRIEND"
	elseif not GT:IsInGroup(player.Info.Name) then
		return false, "PM_ERR_NOTINGROUP", {player.Info.Name}
	end
	if GT:IsGroupLeader() or GT:IsRaidLeaderOrAssistant() then
		if GT:IsRaidAssistant() and GT:IsRaidAssistant(player.Info.Name) then
			return false, "PM_KICK_TARGETASSIST", {player.Info.Name}
		end
		KickName = player.Info.Name
		KickSender = sender.Info.Name
		KickReason = reason or L("PM_KICK_DEFAULTREASON"):format(KickSender)
		StaticPopupDialogs[self.Dialogs.Kick].text = L("PM_KICK_POPUP")
		StaticPopupDialogs[self.Dialogs.Kick].button1 = L("YES")
		StaticPopupDialogs[self.Dialogs.Kick].button2 = L("NO")
		StaticPopup_Show(self.Dialogs.Kick, KickSender, KickName)
		return "PM_KICK_WAIT", {KickName}
	end
	return false, "PM_KICK_NOPRIV", {player.Info.Name}
end

--- Promote a player to group leader.
-- @param player Player object of the player to promote.
-- @return String stating the result of the promotion, false if error.
-- @return Error message if unsuccessful, nil otherwise.
--
function PM:PromoteToLeader(player)
	if player.Info.Name == UnitName("player") then
		return false, "PM_LEADER_SELF"
	elseif GT:IsGroupLeader(player.Info.Name) then
		return false, "PM_LEADER_DUPE", {player.Info.Name}
	elseif not GT:IsInGroup(player.Info.Name) then
		return false, "PM_ERR_NOTINGROUP", {player.Info.Name}
	end
	if GT:IsGroupLeader() then
		if self:IsLocked(player) then return false, "PM_ERR_LOCKED" end
		PromoteToLeader(player.Info.Name)
		return "PM_LEADER_SUCCESS", {player.Info.Name}
	else
		return false, "PM_LEADER_NOPRIV", {player.Info.Name}
	end
end

--- Promote player to assistant.
-- @param player Player object of the player to promote.
-- @return String stating the result of the promotion, false if error.
-- @return Error message if unsuccessful, nil otherwise.
--
function PM:PromoteToAssistant(player)
	if player.Info.Name == UnitName("player") then
		return false, "PM_ASSIST_SELF"
	elseif GT:IsRaidAssistant(player.Info.Name) then
		return false, "PM_ASSIST_DUPE", {player.Info.Name}
	elseif not GT:IsInGroup(player.Info.Name) then
		return false, "PM_ERR_NOTINGROUP", {player.Info.Name}
	elseif not UnitInRaid("player") then
		return false, "PM_ASSIST_NORAID"
	end
	if GT:IsGroupLeader() then
		if self:IsLocked(player) then return false, "PM_ERR_LOCKED" end
		PromoteToAssistant(player.Info.Name)
		return "PM_ASSIST_SUCCESS", {player.Info.Name}
	else
		return false, "PM_ASSIST_NOPRIV", {player.Info.Name}
	end
end

function PM:DemoteAssistant(player)
	if player.Info.Name == UnitName("player") then
		return false, "PM_DEMOTE_SELF"
	elseif not GT:IsRaidAssistant(player.Info.Name) then
		return false, "PM_DEMOTE_INVALID", {player.Info.Name}
	elseif not GT:IsInGroup(player.Info.Name) then
		return false, "PM_ERR_NOTINGROUP", {player.Info.Name}
	elseif not UnitInRaid("player") then
		return false, "PM_DEMOTE_NORAID"
	end
	if GT:IsGroupLeader() then
		if self:IsLocked(player) then return false, "PM_ERR_LOCKED" end
		DemoteAssistant(player.Info.Name)
		return "PM_DEMOTE_SUCCESS", {player.Info.Name}
	else
		return false, "PM_DEMOTE_NOPRIV", {player.Info.Name}
	end
end

--- Check if a certain command is on the blacklist/whitelist.
-- @param command Name of command to check.
--
function PM:IsListed(command)
	return List[command]
end

--- Set the state of an item on the list.
-- @param command Command name to modify.
-- @param list True to list it, false to not list it.
-- @return String stating that the command was added or removed, false if error.
-- @return Error message if unsuccessful, nil otherwise.
--
function PM:List(command, list)
	if not CCM:HasCommand(command) then
		return false, "CM_ERR_NOTREGGED", {command}
	end
	command = CCM:GetRealName(command)
	local mode = self:GetListMode()
	if list then
		List[command] = true
		if mode == MODE_WHITELIST then
			return "PM_LIST_ADDWHITE", {command}
		end
		return "PM_LIST_ADDBLACK", {command}
	end
	List[command] = false
	if mode == MODE_WHITELIST then
		return "PM_LIST_REMOVEWHITE", {command}
	end
	return "PM_LIST_REMOVEBLACK", {command}
end

--- Dynamically add or remove an item from the list.
-- @param command Name of command to list.
-- @return String stating that the command was added or removed, false if error.
-- @return Error message if unsuccessful, nil otherwise.
--
function PM:ListToggle(command)
	return self:List(command, not self:IsListed(command))
end

--- Add a command to the blacklist/whitelist.
-- @param command Name of command to add.
-- @return String stating that the command was added, false if error.
-- @return Error message if unsuccessful, nil otherwise.
--
function PM:ListAdd(command)
	return self:List(command, true)
end

--- Remove a command from the blacklist/whitelist.
-- @param command Name of command to remove.
-- @return String stating that the command was removed, false if error.
-- @return Error message if unsuccessful, nil otherwise.
--
function PM:ListRemove(command)
	return self:List(command, false)
end

--- Toggle the list between being a blacklist and being a whitelist.
-- @return String stating what mode the list is in.
--
function PM:ToggleListMode()
	if self:GetListMode() == MODE_BLACKLIST then
		return self:SetListMode(MODE_WHITELIST)
	else
		return self:SetListMode(MODE_BLACKLIST)
	end
end

--- Set the mode of the list.
-- @param mode Mode to change to, MODE_WHITELIST for whitelist and MODE_BLACKLIST for blacklist.
-- @return String stating what mode the list is in.
--
function PM:SetListMode(mode)
	if mode == MODE_WHITELIST then
		self.Data.LIST_MODE = MODE_WHITELIST
		return "PM_LIST_SETWHITE"
	else
		self.Data.LIST_MODE = MODE_BLACKLIST
		return "PM_LIST_SETBLACK"
	end
end

--- Gets the current mode of the list.
-- @return List mode, possible values: 0/1, as set by MODE_BLACKLIST and MODE_WHITELIST.
--
function PM:GetListMode()
	return self.Data.LIST_MODE
end
