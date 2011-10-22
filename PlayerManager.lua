--[[
	{OUTPUT_LICENSE_SHORT}
--]]

local MODE_BLACKLIST = 0
local MODE_WHITELIST = 1

local C = Command
local CM
local GT = C.GroupTools
local CET = C.Extensions.Table
local log

C.PlayerManager = {
	Access = {
		Min = 0,
		Max = 4,
		Local = -1,
		Groups = {
			Owner = {
				Level = 0,
				Name = "Owner",
				Allow = {"*"},
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
				Deny = {"*"}
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
	}
}

function PM:Init()
	log = C.Logger
	CM = C.ChatManager
	self:LoadSavedVars()
end

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
	Players = C.Global["PLAYER_MANAGER"]["PLAYERS"]
	List = C.Global["PLAYER_MANAGER"]["LIST"]
end

function PM:GetOrCreatePlayer(name)
	name = name:gsub("^%l", string.upper)
	if CET:HasKey(Players, name) then
		return Players[name]
	else
		local player = CET:Copy(Player)
		player.Info.Name = name
		player.Info.Group = self.Access.Groups.User.Name
		Players[player.Info.Name] = player
		log:Normal(("Created player %q with default settings."):format(player.Info.Name))
		return player
	end
end

function PM:PlayerAccessRemove(player, command)
	if not command then return false, "No command specified" end
	for i,v in pairs(player.Access.Allow) do
		if v == command then table.remove(player.Access.Allow, i) end
	end
	for i,v in pairs(player.Access.Deny) do
		if v == command then table.remove(player.Access.Deny, i) end
	end
	self:UpdatePlayer(player)
	return ("%q removed from %s"):format(command, player.Info.Name)
end

function PM:PlayerAccess(player, command, allow)
	if not command then return false, "No command specified" end
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
	return ("%q is now %s for %q"):format(command, mode, player.Info.Name)
end

function PM:UpdatePlayer(player)
	Players[player.Info.Name] = player
	log:Normal(("Updated player %q."):format(player.Info.Name))
end

function PM:IsFriend(player)
	if GetNumFriends() <= 0 then return false end
	for i=1,GetNumFriends() do
		local name = (select(1, GetFriendInfo(i)))
		if name == player.Info.Name then return true end
	end
	return false
end

function PM:IsBNFriend(player)
	if BNGetNumFriends() <= 0 then return false end
	for i=1,BNGetNumFriends() do
		local char, client = (select(4, BNGetFriendInfo(i))), (select(6, BNGetFriendInfo(i)))
		if char == player.Info.Name and client == "WoW" then return true end
	end
	return false
end

function PM:IsInGuild(player)
	if not IsInGuild() then return false end
	if GetNumGuildMembers() <= 1 then return false end
	for i=1,GetNumGuildMembers() do
		local name = (select(1, GetGuildRosterInfo(i)))
		if name == player.Info.Name then return true end
	end
	return false
end

function PM:GetAccess(player)
	return self.Access.Groups[player.Info.Group].Level
end

function PM:HasAccess(player, command)
	if player.Info.Name == UnitName("player") then return true end
	if (self:IsInGuild(player) or self:IsBNFriend(player) or GT:IsRaidAssistant(player.Info.Name)) and command.Access >= self.Access.Groups.Op.Level then
		return true
	end
	local hasAccess = self:GetAccess(player) <= command.Access
	local group = self.Access.Groups[player.Info.Group]
	if CET:HasValue(group.Allow, command.Name) or CET:HasValue(player.Access.Allow, command.Name) then hasAccess = true end
	if CET:HasValue(group.Deny, command.Name) or CET:HasValue(player.Access.Deny, command.Name) then hasAccess = false end
	if CET:HasKey(List, command.Name) then
		if (List[command.Name] and self:GetListMode() == MODE_BLACKLIST) or (not List[command.Name] and self:GetListMode() == MODE_WHITELIST) then
			hasAccess = false
		else
			hasAccess = true
		end
	end
	if player.Info.Name == UnitName("player") then hasAccess = true end
	return hasAccess
end

function PM:SetAccessGroup(player, group)
	group = group:gsub("^%l", string.upper)
	if player.Info.Name == UnitName("player") then
		return false, "Cannot modify my own access level."
	end
	if not CET:HasKey(self.Access.Groups, group) then
		return false, ("No such access group: %q"):format(group)
	end
	player.Info.Group = group
	self:UpdatePlayer(player)
	return ("Set the access level of %q to %d (%s)"):format(player.Info.Name, PM:GetAccess(player), player.Info.Group)
end

function PM:SetOwner(player)
	return self:SetAccessGroup(player, self.Access.Groups.Owner.Name)
end

function PM:SetAdmin(player)
	return self:SetAccessGroup(player, self.Access.Groups.Admin.Name)
end

function PM:SetOp(player)
	return self:SetAccessGroup(player, self.Access.Groups.Op.Name)
end

function PM:SetUser(player)
	return self:SetAccessGroup(player, self.Access.Groups.User.Name)
end

function PM:BanUser(player)
	return self:SetAccessGroup(player, self.Access.Groups.Banned.Name)
end

function PM:Invite(player)
	if player.Info.Name == UnitName("player") then
		return false, "Cannot invite myself to group."
	elseif GT:IsInGroup(player.Info.Name) then
		return false, ("%s is already in the group."):format(player.Info.Name)
	elseif GT:IsGroupFull() then
		return false, "The group is already full."
	end
	if GT:IsGroupLeader() or GT:IsRaidLeaderOrAssistant() or not GT:IsGroup() then
		InviteUnit(player.Info.Name)
		CM:SendMessage(("You have been invited to the group, %s."):format(player.Info.Name), "WHISPER", player.Info.Name)
		return ("Invited %s to group."):format(player.Info.Name)
	end
	return false, ("Unable to invite %s to group. Not group leader or assistant."):format(player.Info.Name)
end

function PM:Kick(player)
	if player.Info.Name == UnitName("player") then
		return false, "Cannot kick myself."
	elseif self:IsFriend(player) or self:IsBNFriend(player) then
		return false, "Cannot kick my friend."
	elseif not GT:IsInGroup(player.Info.Name) then
		return false, ("%s is not in the group."):format(player.Info.Name)
	end
	if GT:IsGroupLeader() or GT:IsRaidLeaderOrAssistant() then
		UninviteUnit(player.Info.Name, "Command AddOn kick command.")
		return ("Kicked %s from group."):format(player.Info.Name)
	end
	return false, ("Unable to kick %s from group. Not group leader or assistant."):format(player.Info.Name)
end

function PM:PromoteToLeader(player)
	if player.Info.Name == UnitName("player") then
		return false, "Cannot promote myself to leader."
	elseif GT:IsGroupLeader(player.Info.Name) then
		return false, ("%s is already leader."):format(player.Info.Name)
	elseif not GT:IsInGroup(player.Info.Name) then
		return false, ("%s is not in the group."):format(player.Info.Name)
	end
	if GT:IsGroupLeader() or GT:IsRaidLeaderOrAssistant() then
		PromoteToLeader(player.Info.Name)
		return ("Promoted %s to group leader."):format(player.Info.Name)
	end
	return false, "Unknown error occurred."
end

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
		PromoteToAssistant(player.Info.Name)
		return ("Promoted %s to assistant."):format(player.Info.Name)
	end
	return false, "Unknown error occurred"
end

function PM:ListAdd(command)
	List[command] = true
end

function PM:ListRemove(command)
	List[command] = false
end

function PM:ToggleListMode()
	if self:GetListMode() == MODE_BLACKLIST then
		return self:SetListMode(MODE_WHITELIST)
	else
		return self:SetListMode(MODE_BLACKLIST)
	end
end

function PM:SetListMode(mode)
	if mode == MODE_WHITELIST then
		C.Global["PLAYER_MANAGER"]["LIST_MODE"] = MODE_WHITELIST
		return "Now using list as whitelist."
	else
		C.Global["PLAYER_MANAGER"]["LIST_MODE"] = MODE_BLACKLIST
		return "Now using list as blacklist."
	end
end

function PM:GetListMode()
	return C.Global["PLAYER_MANAGER"]["LIST_MODE"]
end
