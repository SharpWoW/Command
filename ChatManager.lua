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

C.ChatManager = {
	Settings = {},
	Default = {
		CmdChar = "!",
		LocalOnly = false
	}
}

local CM = C.ChatManager
local PM = C.PlayerManager
local CCM = C.CommandManager
local CES = C.Extensions.String

--- Get the channel to be used as a response channel based on event name.
-- @param event Full name of the event.
-- @returns The channel to be used as response channel.
--
function CM:GetRespondChannelByEvent(event)
	local respondChannel = "SAY"
	if event == "CHAT_MSG_BATTLEGROUND" then
		respondChannel = "BATTLEGROUND"
	elseif event == "CHAT_MSG_BATTLEGROUND_LEADER" then
		respondChannel = "BATTLEGROUND"
	elseif event == "CHAT_MSG_CHANNEL" then
		respondChannel = "CHANNEL"
	elseif event == "CHAT_MSG_GUILD" then
		respondChannel = "WHISPER"
	elseif event == "CHAT_MSG_OFFICER" then
		respondChannel = "WHISPER"
	elseif event == "CHAT_MSG_PARTY" then
		respondChannel = "PARTY"
	elseif event == "CHAT_MSG_PARTY_LEADER" then
		respondChannel = "PARTY"
	elseif event == "CHAT_MSG_RAID" then
		respondChannel = "RAID"
	elseif event == "CHAT_MSG_RAID_LEADER" then
		respondChannel = "RAID"
	elseif event == "CHAT_MSG_RAID_WARNING" then
		if GT:IsRaidLeaderOrAssistant() then
			respondChannel = "RAID_WARNING"
		else
			respondChannel = "RAID"
		end
	elseif event == "CHAT_MSG_SAY"then
		respondChannel = "SAY"
	elseif event == "CHAT_MSG_WHISPER" then
		respondChannel = "WHISPER"
	elseif event == "CHAT_MSG_YELL" then
		respondChannel = "YELL"
	end
	return respondChannel
end

--- Initialize ChatManager.
--
function CM:Init()
	self:LoadSavedVars()
end

--- Load saved variables.
--
function CM:LoadSavedVars()
	if type(C.Settings.CHAT) ~= "table" then
		C.Settings.CHAT = {}
	end
	self.Settings = C.Settings.CHAT
	if type(self.Settings.CMD_CHAR) ~= "string" then
		self.Settings.CMD_CHAR = self.Default.CmdChar
	end
	if type(self.Settings.LOCAL_ONLY) ~= "boolean" then
		self.Settings.LOCAL_ONLY = self.Default.LocalOnly
	end
end

--- Send a chat message.
-- Will echo the msg param locally if LOCAL_ONLY setting is true.
-- @param msg The message to send.
-- @param channel The channel to send to.
-- @param target Player or channel index to send message to.
--
function CM:SendMessage(msg, channel, target)
	if not self.Settings.LOCAL_ONLY then
		msg = ("[%s] %s"):format(C.Name, msg)
		SendChatMessage(msg, channel, nil, target)
	else
		C.Logger:Normal(msg)
	end
end

--- Parse a message.
-- @param msg The message to parse.
-- @returns Table with the individual words.
--
function CM:ParseMessage(msg)
	return CES:Split(msg)
end

--- Parse a command.
-- @param cmd Command to parse.
-- @returns Parsed command (without the command char)
--
function CM:ParseCommand(cmd)
	return cmd:sub(2, cmd:len())
end

--- Check if a string is a command.
-- @param msg String to check.
-- @returns True if the string is a command, false otherwise.
--
function CM:IsCommand(msg)
	return CES:StartsWith(msg, self.Settings.CMD_CHAR)
end

--- Handle a chat message.
-- @param msg The message to handle.
-- @param sender Player object of the player who sent the message.
-- @param channel Channel the message was sent from.
-- @param target Player or channel index.
-- @param isBN True if battle.net message, false or nil otherwise.
--
function CM:HandleMessage(msg, sender, channel, target, isBN)
	isBN = isBN or false
	target = target or sender
	if isBN then
		C.Logger:Normal("Battle.Net convos/whispers are not supported yet")
		return
	end
	msg = CES:Trim(msg)
	local args = self:ParseMessage(msg)
	if not self:IsCommand(args[1]) then return end
	local cmd = self:ParseCommand(args[1])
	local t = {}
	if #args > 1 then
		for i=2,#args do
			table.insert(t, args[i])
		end
	end
	local player = PM:GetOrCreatePlayer(sender)
	local result, err = CCM:HandleCommand(cmd, t, true, player)
	if result then
		self:SendMessage(tostring(result), channel, target)
	else
		self:SendMessage(tostring(err), "WHISPER", sender)
	end
end
