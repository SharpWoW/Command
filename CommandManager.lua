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

--- Table holding all CommandManager methods.
-- This is referenced "CM" in CommandManager.lua.
-- @name Command.CommandManager
-- @class table
-- @field Slash List of slash commands to register.
-- @field Commands Table holding all registered commands.
--
C.CommandManager = {
	Slash = {
		"command",
		"cmd"
	},
	Commands = {}
}

local CM = C.CommandManager
local PM = C.PlayerManager
local QM = C.QueueManager
local RM = C.RollManager
local GT = C.GroupTools
local CES = C.Extensions.String
local CET = C.Extensions.Table

--- Initialize CommandManager.
-- NOTE: Unused.
--
function CM:Init()
	
end

--- Register a new command.
-- @param command Table containing aliases for the command.
-- @param access Number depicting the access level needed to execute command.
-- @param func Function called to execute command. Called with params args, player and isChat.
-- @param help Message describing how the command should be used.
--
function CM:Register(names, access, func, help)
	help = help or "No help available."
	if type(names) == "string" then
		names = {names}
	end
	if names[1] ~= "__DEFAULT__" then
		names[1] = names[1]:lower()
	end
	local entry = {Name=names[1], Access=access, Call=func, Help=help, Alias={}}
	if #names > 1 then
		for i=2,#names do
			table.insert(entry.Alias, names[i]:lower())
		end
	end
	self.Commands[names[1]] = entry
end

--- Check whether or not a command is registered.
-- This does NOT take aliases into account.
-- @param command Command name to check.
--
function CM:HasCommand(command)
	if self.Commands[command] then return true end
	for _,v in pairs(self.Commands) do
		if CET:HasValue(v.Alias, command) then return true end
	end
	return false
end

--- Gets the callback for a command by name.
-- @param command Name of the command to get.
-- @return Callback for the command, nil if no command was found.
--
function CM:GetCommand(command)
	if self.Commands[command] then
		return self.Commands[command]
	end
	for _,v in pairs(self.Commands) do
		if CET:HasValue(v.Alias, command) then return v end
	end
	return self.Commands.__DEFAULT__ or nil -- We don't really need "or nil" here.
end

function CM:GetRealName(name)
	if self.Commands[name] then return name end
	for k,v in pairs(self.Commands) do
		if CET:HasValue(v.Alias, name) then return k end
	end
	return nil
end

function CM:GetCommands(all) -- NOTE: Only returns the NAMES, not the actual command function
	local t = {}
	for k,v in pairs(self.Commands) do
		if k ~= "__DEFAULT__" or all then
			table.insert(t, k)
		end
		if all and #v.Alias > 0 then
			for _,a in pairs(v.Alias) do
				table.insert(t, a)
			end
		end
	end
	return t
end

--- Calls command with supplied args.
-- @param command Command to call (name)
-- @param args Table with arguments for the command.
-- @param isChat Is the command called from chat?
-- @param player Player object of the calling player (if chat)
-- @return If successfull, returns result, otherwise false.
-- @return Error message if not successful, otherwise nil.
--
function CM:HandleCommand(command, args, isChat, player)
	local cmd = self:GetCommand(command)
	if cmd then
		if isChat then
			if not PM:IsCommandAllowed(cmd) and player.Info.Name ~= UnitName("player") then
				return false, ("%s is not allowed to be used, %s."):format(cmd.Name, player.Info.Name)
			elseif not PM:HasAccess(player, cmd) then
				return false, ("You do not have permission to use that command, %s. Required access level: %d. Your access level: %d."):format(player.Info.Name, cmd.Access, PM:GetAccess(player))
			end
		end
		return cmd.Call(args, player, isChat)
	else
		return false, ("%q is not a registered command."):format(tostring(command))
	end
end

--- Prints all command names together with their help messages.
function CM:AutoHelp()
	for k,v in pairs(self.Commands) do
		C.Logger:Normal(("/%s %s"):format(self.Slash[1], k))
		C.Logger:Normal(("      - %s"):format(v.Help))
	end
end

CM:Register({"__DEFAULT__", "help", "h"}, PM.Access.Local, function(args, sender, isChat)
	CM:AutoHelp()
	return "End of help message."
end, "Prints this help message.")

CM:Register({"commands", "cmds", "cmdlist", "listcmds", "listcommands", "commandlist"}, PM.Access.Groups.User.Level, function(args, sender, isChat)
	local all
	if #args > 0 then
		all = args[1] == "all"
	end
	local cmds = CM:GetCommands(all)
	local msg = ""
	for _,v in pairs(cmds) do
		msg = msg .. v .. ", "
	end
	return CES:Cut(msg, 240)
end, "Print all registered commands.")

CM:Register({"version", "ver", "v"}, PM.Access.Groups.User.Level, function(args, sender, isChat)
	return C.Version
end, "Print the version of Command")

CM:Register({"lock", "lockdown"}, PM.Access.Groups.Admin.Level, function(args, sender, isChat)
	if #args <= 0 then
		return false, "Too few arguments. Usage: lock <player>"
	end
	local player = PM:GetOrCreatePlayer(args[1])
	return PM:SetLocked(player, true)
end, "Lock a player.")

CM:Register({"unlock", "open"}, PM.Access.Groups.Admin.Level, function(args, sender, isChat)
	if #args <= 0 then
		return false, "Too few arguments. Usage: lock <player>"
	end
	local player = PM:GetOrCreatePlayer(args[1])
	return PM:SetLocked(player, false)
end, "Unlock a player.")

CM:Register({"getaccess"}, PM.Access.Groups.User.Level, function(args, sender, isChat)
	if #args <= 0 then
		return false, "Too few arguments. Usage: getaccess <player>"
	end
	local player = PM:GetOrCreatePlayer(args[1])
	return tostring(PM.Access.Groups[player.Info.Group].Level) .. " (" .. tostring(player.Info.Group) .. ")"
end, "Get the access level of a user.")

CM:Register({"setaccess"}, PM.Access.Local, function(args, sender, isChat)
	if #args <= 1 then
		return false, "Too few arguments. Usage: setaccess <player> <group>"
	end
	local player = PM:GetOrCreatePlayer(args[1])
	return PM:SetAccessGroup(player, args[2])
end, "Set the access level of a user.")

CM:Register({"owner"}, PM.Access.Local, function(args, sender, isChat)
	if isChat then
		return false, "This command is not allowed to be used from the chat."
	end
	local player = PM:GetOrCreatePlayer(UnitName("player"))
	return PM:SetOwner(player)
end, "Promote a player to owner rank.")

CM:Register({"admin"}, PM.Access.Groups.Owner.Level, function(args, sender, isChat)
	if #args <= 0 then
		return false, "Missing argument: name"
	end
	if isChat then
		return false, "This command is not allowed to be used from the chat."
	end
	local player = PM:GetOrCreatePlayer(args[1])
	return PM:SetAdmin(player)
end, "Promote a player to admin rank.")

CM:Register({"op"}, PM.Access.Groups.Admin.Level, function(args, sender, isChat)
	if #args <= 0 then
		return false, "Missing argument: name"
	end
	local player = PM:GetOrCreatePlayer(args[1])
	return PM:SetOp(player)
end, "Promote a player to op rank.")

CM:Register({"user"}, PM.Access.Groups.Op.Level, function(args, sender, isChat)
	if #args <= 0 then
		return false, "Missing argument: name"
	end
	local player = PM:GetOrCreatePlayer(args[1])
	return PM:SetUser(player)
end, "Promote a player to user rank.")

CM:Register({"ban"}, PM.Access.Groups.Admin.Level, function(args, sender, isChat)
	if #args <= 0 then
		return false, "Missing argument: name"
	end
	local player = PM:GetOrCreatePlayer(args[1])
	return PM:BanUser(player)
end, "Ban a player.")

CM:Register({"invite", "inv"}, PM.Access.Groups.User.Level, function(args, sender, isChat)
	if #args <= 0 then
		return false, "Missing argument: name"
	end
	local player = PM:GetOrCreatePlayer(args[1])
	return PM:Invite(player, sender)
end, "Invite a player to group.")

CM:Register({"inviteme", "invme"}, PM.Access.Groups.User.Level, function(args, sender, isChat)
	if not isChat then
		return false, "This command can only be used from the chat."
	end
	return PM:Invite(sender, sender)
end, "Player who issued the command will be invited to group.")

CM:Register({"denyinvite", "blockinvite", "denyinvites", "blockinvites"}, PM.Access.Groups.User.Level, function(args, sender, isChat)
	if not isChat then
		return false, "This command can only be used from the chat."
	end
	return PM:DenyInvites(sender)
end, "Player issuing this command will no longer be sent invites from this AddOn.")

CM:Register({"allowinvite", "allowinvites"}, PM.Access.Groups.User.Level, function(args, sender, isChat)
	if not isChat then
		return false, "This command can only be used from the chat."
	end
	return PM:AllowInvites(sender)
end, "Player issuing this command will receive invites sent from this AddOn.")

CM:Register({"kick"}, PM.Access.Groups.Op.Level, function(args, sender, isChat)
	if #args <= 0 then
		return false, "Usage: kick <player> [reason]"
	end
	local player = PM:GetOrCreatePlayer(args[1])
	return PM:Kick(player, sender, args[2])
end, "Kick a player from group with optional reason (Requires confirmation).")

CM:Register({"kingme", "givelead"}, PM.Access.Groups.Op.Level, function(args, sender, isChat)
	if not isChat then
		return false, "This command can only be used from the chat."
	end
	return PM:PromoteToLeader(sender)
end, "Player issuing this command will be promoted to group leader.")

CM:Register({"opme", "assistant", "assist"}, PM.Access.Groups.Op.Level, function(args, sender, isChat)
	if not isChat then
		return false, "This command can only be used from the chat."
	end
	return PM:PromoteToAssistant(sender)
end, "Player issuing this command will be promoted to raid assistant.")

CM:Register({"deopme", "deassistant", "deassist"}, PM.Access.Groups.Op.Level, function(args, sender, isChat)
	if not isChat then
		return false, "This command can only be used from the chat."
	end
	return PM:DemoteAssistant(sender)
end, "Player issuing this command will be demoted from assistant status.")

CM:Register({"leader", "lead"}, PM.Access.Groups.Op.Level, function(args, sender, isChat)
	if #args <= 0 then
		return false, "Missing argument: name"
	end
	local player = PM:GetOrCreatePlayer(args[1])
	return PM:PromoteToLeader(player)
end, "Promote a player to group leader.")

CM:Register({"promote"}, PM.Access.Groups.Op.Level, function(args, sender, isChat)
	if #args <= 0 then
		return false, "Missing argument: name"
	end
	local player = PM:GetOrCreatePlayer(args[1])
	return PM:PromoteToAssistant(player)
end, "Promote a player to raid assistant.")

CM:Register({"demote"}, PM.Access.Groups.Op.Level, function(args, sender, isChat)
	if #args <= 0 then
		return false, "Missing argument: name"
	end
	local player = PM:GetOrCreatePlayer(args[1])
	return PM:DemoteAssistant(player)
end, "Demote a player from assistant status.")

CM:Register({"queue", "q"}, PM.Access.Groups.User.Level, function(args, sender, isChat)
	if #args <= 0 then
		return false, "Missing argument: LFD type"
	end
	ClearAllLFGDungeons()
	SetCVar("Sound_EnableSFX", 0)
	ShowUIPanel(LFDParentFrame)
	local index
	if args[1] == "current" then
		index = LFDQueueFrame.type
	else
		index = QM:GetIndex(args[1])
	end
	if not index then
		HideUIPanel(LFDParentFrame)
		SetCVar("Sound_EnableSFX", 1)
		return false, ("No such dungeon type: %q"):format(args[1])
	end
	return QM:Queue(index)
end, "Enter the LFG queue for the specified category.")

CM:Register({"leavelfg", "cancellfg", "cancel", "leavelfd", "cancellfd"}, PM.Access.Groups.User.Level, function(args, sender, isChat)
	if not QM.QueuedByCommand then
		return false, "Not queued by command, unable to cancel."
	end
	return QM:Cancel()
end, "Leave the LFG queue.")

CM:Register({"acceptlfg", "accept", "join", "acceptlfd"}, PM.Access.Groups.User.Level, function(args, sender, isChat)
	if not QM.QueuedByCommand then
		return false, "Not currently queued by command."
	end
	return QM:Accept()
end, "Causes you to accept the LFG invite.")

CM:Register({"convert", "conv"}, PM.Access.Groups.Op.Level, function(args, sender, isChat)
	if GT:IsLFGGroup() then
		return false, "LFG groups cannot be converted."
	end
	if not GT:IsGroup() then
		return false, "Cannot convert if not in a group."
	end
	if not GT:IsGroupLeader() then
		return false, "Cannot convert group, not leader."
	end
	if #args <= 0 then
		return false, "Usage: convert party||raid."
	end
	args[1] = args[1]:lower()
	if args[1] ~= "party" and args[1] ~= "raid" then
		return false, "Invalid group type, only \"party\" or \"raid\" allowed."
	end
	if args[1] == "party" then
		if GT:IsRaid() then
			ConvertToParty()
			return "Converted raid to party."
		else
			return false, "Group is already a party."
		end
	else
		if GT:IsRaid() then
			return false, "Group is already a raid."
		else
			ConvertToRaid()
			return "Converted party to raid."
		end
	end
end, "Convert group to party or raid.")

CM:Register({"list"}, PM.Access.Groups.Admin.Level, function(args, sender, isChat)
	if not args[1] then
		return false, "Missing argument: command name"
	end
	return PM:ListToggle(args[1]:lower())
end, "Toggle status of a command on the blacklist/whitelist.")

CM:Register({"listmode", "lm", "lmode"}, PM.Access.Groups.Admin.Level, function(args, sender, isChat)
	return PM:ToggleListMode()
end, "Toggle list between being a blacklist and being a whitelist.")

CM:Register({"groupallow", "gallow"}, PM.Access.Groups.Admin.Level, function(args, sender, isChat)
	if #args <= 1 then
		return false, "Usage: groupallow <groupname> <commandname>"
	end
	local group = args[1]:gsub("^%l", string.upper)
	local cmd = args[2]:lower()
	return PM:GroupAccess(group, cmd, true)
end, "Allow a group to use a specific command.")

CM:Register({"groupdeny", "gdeny", "deny"}, PM.Access.Groups.Admin.Level, function(args, sender, isChat)
	if #args <= 1 then
		return false, "Usage: groupdeny <groupname> <commandname>"
	end
	local group = args[1]:gsub("^%1", string.upper)
	local cmd = args[2]:lower()
	return PM:GroupAccess(group, cmd, false)
end, "Deny a group to use a specific command.")

CM:Register({"resetgroupaccess", "groupaccessreset", "removegroupaccess", "groupaccessremove", "rga", "gar"}, PM.Access.Groups.Admin.Level, function(args, sender, isChat)
	if #args <= 1 then
		return false, "Usage: resetgroupaccess <groupname> <commandname>"
	end
	local group = args[1]:gsub("^%1", string.upper)
	local cmd = args[2]:lower()
	return PM:GroupAccessRemove(group, cmd)
end, "Reset the group's access to a specific command.")

CM:Register({"userallow", "uallow"}, PM.Access.Groups.Admin.Level, function(args, sender, isChat)
	if #args <= 1 then
		return false, "Usage: userallow <playername> <commandname>"
	end
	local player = PM:GetOrCreatePlayer(args[1])
	local cmd = args[2]:lower()
	return PM:PlayerAccess(player, cmd, true)
end, "Allow a user to use a specific command.")

CM:Register({"userdeny", "udeny"}, PM.Access.Groups.Admin.Level, function(args, sender, isChat)
	if #args <= 1 then
		return false, "Usage: userdeny <playername> <commandname>"
	end
	local player = PM:GetOrCreatePlayer(args[1])
	local cmd = args[2]:lower()
	return PM:PlayerAccess(player, cmd, false)
end, "Deny a user to use a specific command.")

CM:Register({"resetuseraccess", "useraccessreset", "removeuseraccess", "useraccessremove", "rua", "uar"}, PM.Access.Groups.Admin.Level, function(args, sender, isChat)
	if #args <= 1 then
		return false, "Usage: resetuseraccess <playername> <commandname>."
	end
	local player = PM:GetOrCreatePlayer(args[1])
	local cmd = args[2]:lower()
	return PM:PlayerAccessRemove(player, cmd)
end, "Reset the user's access to a specific command.")

CM:Register({"toggle", "t"}, PM.Access.Local, function(args, sender, isChat)
	if isChat then
		return false, "This command is not allowed to be used from the chat."
	end
	return C:Toggle()
end, "Toggle AddOn on and off.")

CM:Register({"toggledebug", "td", "debug", "d"}, PM.Access.Local, function(args, sender, isChat)
	if isChat then
		return false, "This command is not allowed to be used from the chat."
	end
	return C:ToggleDebug()
end, "Toggle debugging mode on and off.")

CM:Register({"readycheck", "rc"}, PM.Access.Groups.Op.Level, function(args, sender, isChat)
	if #args <= 0 then
		if GT:IsGroupLeader() or GT:IsRaidLeaderOrAssistant() then
			C.Data.ReadyCheckRunning = true
			local name = tostring(sender.Info.Name)
			DoReadyCheck()
			return name .. " issued a ready check!"
		else
			return false, "Can't initiate ready check when not leader or assistant."
		end
	end
	local status = GetReadyCheckStatus("player")
	if (status ~= "waiting" and status ~= nil) or GetReadyCheckTimeLeft() <= 0 or not C.Data.ReadyCheckRunning then
		return false, "Ready check not running or I have already responded."
	end
	local arg = tostring(args[1]):lower()
	if arg == "accept" or arg == "yes" then
		C.Data.ReadyCheckRunning = false
		if ReadyCheckFrameYesButton then
			ReadyCheckFrameYesButton:Click()
		end
		ConfirmReadyCheck(true)
		status = GetReadyCheckStatus("player")
		return "Accepted ready check."
	elseif arg == "decline" or arg == "no" then
		C.Data.ReadyCheckRunning = false
		if ReadyCheckFrameNoButton then
			ReadyCheckFrameNoButton:Click()
		end
		ConfirmReadyCheck(false)
		status = GetReadyCheckStatus("player")
		return "Declined ready check."
	else
		return false, "Invalid argument: " .. arg
	end
	return false, "Failed to accept or decline ready check."
end, "Respond to ready check or initate a new one.")

CM:Register({"roll", "r"}, PM.Access.Groups.Op.Level, function(args, sender, isChat)
	if #args <= 0 then
		return RM:StartRoll(sender.Info.Name)
	end
	args[1] = args[1]:lower()
	if args[1] == "start" then
		if #args < 2 then
			return false, "Usage: roll start <[time] [item]>"
		end
		local time = tonumber(args[2])
		local item
		if not time then
			item = args[2]
		end
		if #args >= 3 then
			if item then
				item = item .. " " .. args[3]
			else
				item = args[3]
			end
			if #args > 3 then
				for i = 4, #args do
					item = item .. " " .. args[i]
				end
			end
		end
		return RM:StartRoll(sender.Info.Name, item, time)
	elseif args[1] == "pass" then
		return RM:PassRoll(sender.Info.Name)
	elseif args[1] == "stop" then
		return RM:StopRoll()
	elseif args[1] == "time" then
		return RM:GetTime()
	elseif args[1] == "do" then
		local min, max
		if #args >= 3 then
			min = tonumber(args[2])
			max = tonumber(args[3])
		end
		if not min and (args[2] == "pass" or args[2] == "p" or args[2] == "skip") then
			return RM:PassRoll()
		else
			return RM:DoRoll(min, max)
		end
	elseif args[1] == "set" then
		if #args < 3 then
			return false, "Usage: roll set <min||max> <amount>"
		end
		args[2] = args[2]:lower()
		if args[2] == "min" then
			return RM:SetMin(tonumber(args[3]))
		elseif args[2] == "max" then
			return RM:SetMax(tonumber(args[3]))
		elseif args[2] == "time" then
			return RM:SetTime(tonumber(args[3]))
		else
			return false, "Usage: roll set <min||max> <amount>"
		end
	end
	return false, "Usage: roll [start||stop||time||do||set]"
end, "Provides tools for managing or starting/stopping rolls.")

for i,v in ipairs(CM.Slash) do
	_G["SLASH_" .. C.Name:upper() .. i] = "/" .. v
end

SlashCmdList[C.Name:upper()] = function(msg, editBox)
	msg = CES:Trim(msg)
	local args = CES:Split(msg)
	local cmd = args[1]
	local t = {}
	if #args > 1 then
		for i=2,#args do
			table.insert(t, args[i])
		end
	end
	local result, err = CM:HandleCommand(cmd, t, false, PM:GetOrCreatePlayer(UnitName("player")))
	if result then
		C.Logger:Normal(tostring(result))
	else
		C.Logger:Error(tostring(err))
	end
end
