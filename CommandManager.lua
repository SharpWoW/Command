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
local CES = C.Extensions.String

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
local GT = C.GroupTools

function CM:Init()
	
end

--- Register a new command.
-- @param command Table containing aliases for the command.
-- @param access Number depicting the access level needed to execute command.
-- @param func Function called to execute command. Called with params args, player and isChat.
--
function CM:Register(command, access, func)
	if type(command) == "string" then
		command = {command}
	end
	for _,v in pairs(command) do
		if not self:GetCommand(v) then
			if v ~= "__DEFAULT__" then v = v:lower() end
			self.Commands[v] = {Name=v, Access=access, Call=func}
		end
	end
end

--- Gets the callback for a command by name.
-- @param command Name of the command to get.
-- @returns Callback for the command.
--
function CM:GetCommand(command)
	if self.Commands[command] then
		return self.Commands[command]
	end
	return self.Commands.__DEFAULT__
end

--- Calls command with supplied args.
-- @param command Command to call (name)
-- @param args Table with arguments for the command.
-- @param isChat Is the command called from chat?
-- @param player Player object of the calling player (if chat)
-- @returns If successfull, returns result, otherwise false.
-- @returns Error message if not successful, otherwise nil.
--
function CM:HandleCommand(command, args, isChat, player)
	local cmd = self:GetCommand(command)
	if cmd then
		if isChat then
			if not PM:HasAccess(player, cmd) then
				return false, ("You do not have permission to use that command, %s. Required access level: %d. Your access level: %d."):format(player.Info.Name, cmd.Access, PM:GetAccess(player))
			end
		end
		return cmd.Call(args, player, isChat)
	else
		return false, ("%q is not a registered command."):format(tostring(command))
	end
end

CM:Register({"version", "ver", "v"}, PM.Access.Groups.User.Level, function(args, sender, isChat)
	if args then
		if #args > 0 then
			return false, "This is a test error"
		end
	end
	return C.Version, nil
end)

CM:Register({"setaccess"}, PM.Access.Local, function(args, sender, isChat)
	if #args <= 1 then
		return false, "Too few arguments. Usage: setaccess <player> <group>"
	end
	local player = PM:GetOrCreatePlayer(args[1])
	return PM:SetAccessGroup(player, args[2])
end)

CM:Register({"owner"}, PM.Access.Local, function(args, sender, isChat)
	if isChat then
		return false, "This command is not allowed to be used from the chat."
	end
	local player = PM:GetOrCreatePlayer(UnitName("player"))
	return PM:SetOwner(player)
end)

CM:Register({"admin"}, PM.Access.Groups.Owner.Level, function(args, sender, isChat)
	if #args <= 0 then
		return false, "Missing argument: name"
	end
	if isChat then
		return false, "This command is not allowed to be used from the chat."
	end
	local player = PM:GetOrCreatePlayer(args[1])
	return PM:SetAdmin(player)
end)

CM:Register({"op"}, PM.Access.Groups.Admin.Level, function(args, sender, isChat)
	if #args <= 0 then
		return false, "Missing argument: name"
	end
	local player = PM:GetOrCreatePlayer(args[1])
	return PM:SetOp(player)
end)

CM:Register({"user"}, PM.Access.Groups.Op.Level, function(args, sender, isChat)
	if #args <= 0 then
		return false, "Missing argument: name"
	end
	local player = PM:GetOrCreatePlayer(args[1])
	return PM:SetUser(player)
end)

CM:Register({"ban"}, PM.Access.Groups.Admin.Level, function(args, sender, isChat)
	if #args <= 0 then
		return false, "Missing argument: name"
	end
	local player = PM:GetOrCreatePlayer(args[1])
	return PM:BanUser(player)
end)

CM:Register({"invite", "inv"}, PM.Access.Groups.User.Level, function(args, sender, isChat)
	if #args <= 0 then
		return false, "Missing argument: name"
	end
	local player = PM:GetOrCreatePlayer(args[1])
	return PM:Invite(player)
end)

CM:Register({"inviteme", "invme"}, PM.Access.Groups.User.Level, function(args, sender, isChat)
	if not isChat then
		return false, "This command can only be used from the chat."
	end
	return PM:Invite(sender, true)
end)

CM:Register({"kick"}, PM.Access.Groups.Op.Level, function(args, sender, isChat)
	if #args <= 0 then
		return false, "Missing argument: name"
	end
	local player = PM:GetOrCreatePlayer(args[1])
	return PM:Kick(player)
end)

CM:Register({"kingme", "givelead"}, PM.Access.Groups.Op.Level, function(args, sender, isChat)
	if not isChat then
		return false, "This command can only be used from the chat."
	end
	return PM:PromoteToLeader(sender)
end)

CM:Register({"opme", "assistant", "assist"}, PM.Access.Groups.Op.Level, function(args, sender, isChat)
	if not isChat then
		return false, "This command can only be used from the chat."
	end
	return PM:PromoteToAssistant(sender)
end)

CM:Register({"leader", "lead"}, PM.Access.Groups.Op.Level, function(args, sender, isChat)
	if #args <= 0 then
		return false, "Missing argument: name"
	end
	local player = PM:GetOrCreatePlayer(args[1])
	return PM:PromoteToLeader(player)
end)

CM:Register({"promote"}, PM.Access.Groups.Op.Level, function(args, sender, isChat)
	if #args <= 0 then
		return false, "Missing argument: name"
	end
	local player = PM:GetOrCreatePlayer(args[1])
	return PM:PromoteToAssistant(player)
end)

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
		return false, ("No such dungeon type: %q"):format(args[1])
	end
	return QM:Queue(index)
end)

CM:Register({"leavelfg", "cancellfg", "cancel"}, PM.Access.Groups.User.Level, function(args, sender, isChat)
	if not QM.QueuedByCommand then
		return false, "Not queued by command, unable to cancel."
	end
	return QM:Cancel()
end)

CM:Register({"acceptlfg", "accept", "join"}, PM.Access.Groups.User.Level, function(args, sender, isChat)
	if not QM.QueuedByCommand then
		return false, "Not currently queued by command."
	end
	return QM:Accept()
end)

CM:Register({"convert", "conv"}, PM.Access.Groups.Op.Level, function(args, sender, isChat)
	if GT:IsLFGGroup() then
		return false, "LFG groups cannot be converted."
	end
	if not GT:IsGroup() then
		return false, "Cannot convert if not in a group."
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
end)

CM:Register({"toggle", "t"}, PM.Access.Local, function(args, sender, isChat)
	if isChat then
		return false, "This command is not allowed to be used from the chat."
	end
	return C:Toggle()
end)

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
	local result, err = CM:HandleCommand(cmd, t, false, nil)
	if result then
		C.Logger:Normal(tostring(result))
	else
		C.Logger:Error(tostring(err))
	end
end
