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

local MODE_BLACKLIST = 0
local MODE_WHITELIST = 1

local C = Command
local CM
local GT = C.GroupTools
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
	},
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
			CM:SendMessage(("%s has been kicked on %s's request. (Reason: %s)"):format(name, sender, reason), CM.LastChannel, CM.LastTarget)
		else
			CM:SendMessage(("%s has been kicked on %s's request."):format(name, sender), CM.LastChannel, CM.LastTarget)
		end
	else
		CM:SendMessage(("%s was kicked on your request."):format(name), "WHISPER", sender)
	end
	CM:SendMessage(("You have been kicked out of the group by %s."):format(sender), "WHISPER", name)
end

local function KickCancelled(name, sender)
	CM:SendMessage(("%s's request to kick %s has been denied."):format(sender, name), CM.LastChannel, CM.LastTarget)
end

StaticPopupDialogs["COMMAND_CONFIRMKICK"] = {
	text = "%s wants to kick %s. Confirm?",
	button1 = "Yes",
	button2 = "No",
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
	if type(C.Global["PLAYER_MANAGER"]["PLAYERS"]) ~= "table" then
		C.Global["PLAYER_MANAGER"]["PLAYERS"] = {}
	end
	if type(C.Global["PLAYER_MANAGER"]["LIST_MODE"]) ~= "number" then
		C.Global["PLAYER_MANAGER"]["LIST_MODE"] = MODE_BLACKLIST
	end
	if type(C.Global["PLAYER_MANAGER"]["LIST"]) ~= "table" then
		C.Global["PLAYER_MANAGER"]["LIST"] = {}
	end
	if type(C.Global["PLAYER_MANAGER"]["GROUP_PERMS"]) ~= "table" then
		C.Global["PLAYER_MANAGER"]["GROUP_PERMS"] = {}
		for k,v in pairs(self.Access.Groups) do
			C.Global["PLAYER_MANAGER"]["GROUP_PERMS"][k] = {
				Allow = {},
				Deny = {}
			}
			for _,v in pairs(self.Access.Groups[k].Allow) do
				table.insert(C.Global["PLAYER_MANAGER"]["GROUP_PERMS"][k].Allow, v)
			end
			for _,v in pairs(self.Access.Groups[k].Deny) do
				table.insert(C.Global["PLAYER_MANAGER"]["GROUP_PERMS"][k].Deny, v)
			end
		end
	end
	for k,v in pairs(C.Global["PLAYER_MANAGER"]["GROUP_PERMS"]) do
		self.Access.Groups[k].Allow = v.Allow
		self.Access.Groups[k].Deny = v.Deny
	end
	Players = C.Global["PLAYER_MANAGER"]["PLAYERS"]
	List = C.Global["PLAYER_MANAGER"]["LIST"]
end

--- Get or create a player.
-- @param name Name of player.
-- @return Player from list of players if exists, otherwise a new player object.
--
function PM:GetOrCreatePlayer(name)
	name = name:lower():gsub("^%l", string.upper)
	if CET:HasKey(Players, name) then
		return Players[name]
	else
		local player = CET:Copy(Player)
		player.Info.Name = name
		if player.Info.Name == UnitName("player") then
			player.Info.Group = self.Access.Groups.Owner.Name
		else
			player.Info.Group = self.Access.Groups.User.Name
		end
		Players[player.Info.Name] = player
		log:Normal(("Created player %q with default settings."):format(player.Info.Name))
		return player
	end
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
	if not command then return false, "No Command specified" end
	for i,v in pairs(self.Access.Groups[k].Allow) do
		if v == command then table.remove(self.Access.Groups[k].Allow, i) end
	end
	for i,v in pairs(self.Access.Groups[k].Deny) do
		if v == command then table.remove(self.Access.Groups[k].Deny, i) end
	end
	return ("%q removed from group %s."):format(command, group)
end

--- Modify the access of a command for a specific group.
-- @param group Name of group to modify.
-- @param command Name of command to allow or deny.
-- @param allow True to allow command, false to deny.
-- @return String stating the result, or false if error.
-- @return Error message if unsuccessful, otherwise nil.
--
function PM:GroupAccess(group, command, allow)
	if not command then return false, "No command specified" end
	local mode = "allowed"
	if allow then
		if CET:HasValue(self.Access.Groups[group].Deny, command) then
			for i,v in ipairs(player.Access.Deny) do
				if v == command then table.remove(player.Access.Deny, i) end
			end
		end
		if CET:HasValue(self.Access.Groups[group].Allow, command) then
			return false, ("%q already has that command on the allow list."):format(group)
		end
		table.insert(self.Access.Groups[group].Allow, command)
		mode = "allowed"
	else
		if CET:HasValue(self.Access.Groups[group].Allow, command) then
			for i,v in pairs(self.Access.Groups[group].Allow) do
				if v == command then table.remove(self.Access.Groups[group].Allow, i) end
			end
		end
		if CET:HasValue(self.Access.Groups[group].Deny, command) then
			return false, ("%q already has that command on the deny list."):format(group)
		end
		table.insert(self.Access.Groups[group].Deny, command)
		mode = "denied"
	end
	return ("%q is now %s for %s"):format(command, mode, group)
end

--- Completely remove a command from a player's access list.
-- Removes from both the allow and deny list.
-- @param player Player object of the player to modify.
-- @param command Name of command to remove.
-- @return String stating that the command has been removed or false if error.
-- @return Error message is unsuccessful, otherwise nil.
--
function PM:PlayerAccessRemove(player, command)
	if not command then return false, "No command specified" end
	if self:IsLocked(player) then return false, "Target player is locked and cannot be modified." end
	for i,v in pairs(player.Access.Allow) do
		if v == command then table.remove(player.Access.Allow, i) end
	end
	for i,v in pairs(player.Access.Deny) do
		if v == command then table.remove(player.Access.Deny, i) end
	end
	self:UpdatePlayer(player)
	return ("%q removed from %s"):format(command, player.Info.Name)
end

--- Modify the access of a command for a specific player.
-- @param player Player object of the player to modify.
-- @param command Name of command to allow or deny.
-- @param allow True to allow command, false to deny.
-- @return String stating the result, or false if error.
-- @return Error message if unsuccessful, otherwise nil.
--
function PM:PlayerAccess(player, command, allow)
	if not command then return false, "No command specified" end
	if self:IsLocked(player) then return false, "Target player is locked and cannot be modified." end
	local mode = "allowed"
	if allow then
		if CET:HasValue(player.Access.Deny, command) then
			for i,v in ipairs(player.Access.Deny) do
				if v == command then table.remove(player.Access.Deny, i) end
			end
		end
		if CET:HasValue(player.Access.Allow, command) then
			return false, ("%q already has that command on the allow list."):format(player.Info.Name)
		end
		table.insert(player.Access.Allow, command)
		mode = "allowed"
	else
		if CET:HasValue(player.Access.Allow, command) then
			for i,v in pairs(player.Access.Allow) do
				if v == command then table.remove(player.Access.Allow, i) end
			end
		end
		if CET:HasValue(player.Access.Deny, command) then
			return false, ("%q already has that command on the deny list."):format(player.Info.Name)
		end
		table.insert(player.Access.Deny, command)
		mode = "denied"
	end
	self:UpdatePlayer(player)
	return ("%q is now %s for %s"):format(command, mode, player.Info.Name)
end

--- Update a player and subsequently save them.
-- @param player Player object to update.
--
function PM:UpdatePlayer(player)
	Players[player.Info.Name] = player
	log:Normal(("Updated player %q."):format(player.Info.Name))
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
	local mode = "locked"
	if not locked then mode = "unlocked" end
	return ("Player %s has been %s."):format(player.Info.Name, mode)
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
	local group = self.Access.Groups[player.Info.Group]
	if CET:HasValue(group.Allow, command.Name) then hasAccess = true end
	if CET:HasValue(group.Deny, command.Name) then hasAccess = false end
	if CET:HasValue(player.Access.Allow, command.Name) then hasAccess = true end
	if CET:HasValue(player.Access.Deny, command.Name) then hasAccess = false end
	if (List[command.Name] and self:GetListMode() == MODE_BLACKLIST) or (not List[command.Name] and self:GetListMode() == MODE_WHITELIST) then
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
		return false, "Cannot modify my own access level."
	end
	if not CET:HasKey(self.Access.Groups, group) then
		return false, ("No such access group: %q"):format(group)
	end
	if self:IsLocked(player) then return false, "Target player is locked and cannot be modified." end
	player.Info.Group = group
	self:UpdatePlayer(player)
	return ("Set the access level of %q to %d (%s)"):format(player.Info.Name, PM:GetAccess(player), player.Info.Group)
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
-- @return String stating the result of the invite, false if error.
-- @return Error message if unsuccessful, nil otherwise.
--
function PM:Invite(player, sender)
	if not sender then sender = self:GetOrCreatePlayer(UnitName("player")) end
	if player.Info.Name == UnitName("player") then
		return false, "Cannot invite myself to group."
	elseif GT:IsInGroup(player.Info.Name) then
		return false, ("%s is already in the group."):format(player.Info.Name)
	elseif GT:IsGroupFull() then
		return false, "The group is already full."
	end
	if GT:IsGroupLeader() or GT:IsRaidLeaderOrAssistant() or not GT:IsGroup() then
		if player.Info.Name == sender.Info.Name then
			InviteUnit(player.Info.Name)
			return "Invited you to the group."
		elseif player.Settings.Invite then
			InviteUnit(player.Info.Name)
			CM:SendMessage(("%s invited you to the group, %s. Whisper !denyinvite to block these invites."):format(sender.Info.Name, player.Info.Name), "WHISPER", player.Info.Name)
			return ("Invited %s to group."):format(player.Info.Name)
		else
			return false, ("%s does not wish to be invited."):format(player.Info.Name)
		end
	end
	return false, ("Unable to invite %s to group. Not group leader or assistant."):format(player.Info.Name)
end

--- Stop sending Command invites to player.
-- @param player Player object of the player.
-- @return String stating the result of the operation, false if error.
-- @return Error message if unsuccessful, nil otherwise.
--
function PM:DenyInvites(player)
	if player.Settings.Invite then
		player.Settings.Invite = false
		self:UpdatePlayer(player)
		CM:SendMessage("You are now blocking invites, whisper !allowinvite to receive them.", "WHISPER", player.Info.Name)
		return ("%s is no longer receiving invites."):format(player.Info.Name)
	end
	return false, "You are already blocking invites."
end

--- Allow sending Command invites to player.
-- @param player Player object of the player.
-- @return String stating the result of the operation, false if error.
-- @return Error message if unsuccessful, nil otherwise.
--
function PM:AllowInvites(player)
	if player.Settings.Invite then
		return false, "You are already allowing invites."
	end
	player.Settings.Invite = true
	self:UpdatePlayer(player)
	CM:SendMessage("You are now allowing invites, whisper !blockinvite to block them.", "WHISPER", player.Info.Name)
	return ("%s is now receiving invites."):format(player.Info.Name)
end

--- Kick a player from the group.
-- @param player Player object of the player to kick.
-- @param sender Player object of the player who requested the kick.
-- @return String stating the result of the kick, false if error.
-- @return Error message if unsuccessful, nil otherwise.
--
function PM:Kick(player, sender, reason)
	if player.Info.Name == UnitName("player") then
		return false, "Cannot kick myself."
	elseif self:IsFriend(player) or self:IsBNFriend(player) then
		return false, "Cannot kick my friend."
	elseif not GT:IsInGroup(player.Info.Name) then
		return false, ("%s is not in the group."):format(player.Info.Name)
	end
	if GT:IsGroupLeader() or GT:IsRaidLeaderOrAssistant() then
		KickName = player.Info.Name
		KickSender = sender.Info.Name
		KickReason = reason or ("%s used !kick command."):format(KickSender)
		StaticPopup_Show("COMMAND_CONFIRMKICK", KickSender, KickName)
		return ("Awaiting confirmation to kick %s..."):format(KickName)
	end
	return false, ("Unable to kick %s from group. Not group leader or assistant."):format(player.Info.Name)
end

--- Promote a player to group leader.
-- @param player Player object of the player to promote.
-- @return String stating the result of the promotion, false if error.
-- @return Error message if unsuccessful, nil otherwise.
--
function PM:PromoteToLeader(player)
	if player.Info.Name == UnitName("player") then
		return false, "Cannot promote myself to leader."
	elseif GT:IsGroupLeader(player.Info.Name) then
		return false, ("%s is already leader."):format(player.Info.Name)
	elseif not GT:IsInGroup(player.Info.Name) then
		return false, ("%s is not in the group."):format(player.Info.Name)
	end
	if GT:IsGroupLeader() then
		if self:IsLocked(player) then return false, "Target player is locked and cannot be modified." end
		PromoteToLeader(player.Info.Name)
		return ("Promoted %s to group leader."):format(player.Info.Name)
	else
		return false, ("Cannot promote %s to group leader, insufficient permissions."):format(player.Info.Name)
	end
	return false, "Unknown error occurred."
end

--- Promote player to assistant.
-- @param player Player object of the player to promote.
-- @return String stating the result of the promotion, false if error.
-- @return Error message if unsuccessful, nil otherwise.
--
function PM:PromoteToAssistant(player)
	if player.Info.Name == UnitName("player") then
		return false, "Cannot promote myself to assistant."
	elseif GT:IsRaidAssistant(player.Info.Name) then
		return false, ("%s is already assistant."):format(player.Info.Name)
	elseif not GT:IsInGroup(player.Info.Name) then
		return false, ("%s is not in the group."):format(player.Info.Name)
	elseif not UnitInRaid("player") then
		return false, "Cannot promote to assistant when not in a raid."
	end
	if GT:IsGroupLeader() then
		if self:IsLocked(player) then return false, "Target player is locked and cannot be modified." end
		PromoteToAssistant(player.Info.Name)
		return ("Promoted %s to assistant."):format(player.Info.Name)
	else
		return false, ("Cannot promote %s to assistant, insufficient permissions."):format(player.Info.Name)
	end
	return false, "Unknown error occurred."
end

function PM:DemoteAssistant(player)
	if player.Info.Name == UnitName("player") then
		return false, "Cannot demote myself."
	elseif not GT:IsRaidAssistant(player.Info.Name) then
		return false, ("%s is not an assistant, can only demote assistants."):format(player.Info.Name)
	elseif not GT:IsInGroup(player.Info.Name) then
		return false, ("%s is not in the group."):format(player.Info.Name)
	elseif not UnitInRaid("player") then
		return false, "Cannot demote when not in a raid."
	end
	if GT:IsGroupLeader() then
		if self:IsLocked(player) then return false, "Target player is locked and cannot be modified." end
		DemoteAssistant(player.Info.Name)
		return ("Demoted %s."):format(player.Info.Name)
	else
		return false, ("Cannot demote %s, insufficient permissions."):format(player.Info.Name)
	end
	return false, "Unknown error occurred."
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
		return false, ("%q is not a registered command."):format(command)
	end
	command = CCM:GetRealName(command)
	if list then
		List[command] = true
		local mode = "blacklist"
		if self:GetListMode() == MODE_WHITELIST then
			mode = "whitelist"
		end
		return ("Added %s to %s."):format(command, mode)
	end
	List[command] = false
	local mode = "blacklist"
	if self:GetListMode() == MODE_WHITELIST then
		mode = "whitelist"
	end
	return ("Removed %s from %s."):format(command, mode)
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
		C.Global["PLAYER_MANAGER"]["LIST_MODE"] = MODE_WHITELIST
		return "Now using list as whitelist."
	else
		C.Global["PLAYER_MANAGER"]["LIST_MODE"] = MODE_BLACKLIST
		return "Now using list as blacklist."
	end
end

--- Gets the current mode of the list.
-- @return List mode, possible values: 0/1, as set by MODE_BLACKLIST and MODE_WHITELIST.
--
function PM:GetListMode()
	return C.Global["PLAYER_MANAGER"]["LIST_MODE"]
end
