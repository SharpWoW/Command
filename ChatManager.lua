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
local ipairs = ipairs
local unpack = unpack
local tostring = tostring

-- API Upvalues
local BNSendWhisper = BNSendWhisper
local SendChatMessage = SendChatMessage

local C = Command

--- Table holding all ChatManager methods.
-- This is referenced "CM" in ChatManager.lua.
-- @name Command.ChatManager
-- @class table
-- @field Settings Table holding all settings specific to ChatManager.
-- @field Default Table containing default settings (used at initial setup)
-- @field LastChannel Last channel argument passed to HandleMessage.
-- @field LastTarget Last target argument passed to HandleMessage.
--
C.ChatManager = {
	Settings = {},
	Default = {
		CmdChar = "!",
		LocalOnly = false
	},
	LastChannel = nil,
	LastTarget = nil,
	RespondChannel = {
		CHAT_MSG_BATTLEGROUND			= "BATTLEGROUND",
		CHAT_MSG_BATTLEGROUND_LEADER	= "BATTLEGROUND",
		CHAT_MSG_CHANNEL				= "CHANNEL",
		CHAT_MSG_GUILD					= "WHISPER",
		CHAT_MSG_OFFICER				= "WHISPER",
		CHAT_MSG_PARTY					= "PARTY",
		CHAT_MSG_PARTY_LEADER			= "PARTY",
		CHAT_MSG_RAID					= "RAID",
		CHAT_MSG_RAID_LEADER			= "RAID",
		CHAT_MSG_RAID_WARNING			= "RAID_WARNING",
		CHAT_MSG_SAY					= "WHISPER",
		CHAT_MSG_WHISPER				= "WHISPER",
		CHAT_MSG_YELL					= "WHISPER"
	}
}

local CM = C.ChatManager
local PM = C.PlayerManager
local L = C.LocaleManager
local GT = C.GroupTools
local AC = C.AddonComm
local CCM = C.CommandManager
local CES = C.Extensions.String

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

--- Get the channel to be used as a response channel based on event name.
-- @param event Full name of the event.
-- @return The channel to be used as response channel.
--
function CM:GetRespondChannelByEvent(event)
	if self.RespondChannel[event] then
		return self.RespondChannel[event]
	end
	return "SAY"
end

--- Send a chat message.
-- Will echo the msg param locally if LOCAL_ONLY setting is true.
-- @param msg The message to send.
-- @param channel The channel to send to.
-- @param target Player or channel index to send message to.
--
function CM:SendMessage(msg, channel, target, isBN)
	isBN = isBN or false
	if not self.Settings.LOCAL_ONLY then
		-- Sanitize message
		--msg = msg:gsub("|*", "|") -- First make sure every pipe char is alone (This is probably not needed)
		msg = tostring(msg):gsub("|", "||") -- Escape the pipe characters
		msg = ("[%s] %s"):format(C.Name, msg)
		if channel == "SMART" then
			if GT:IsRaid() then
				channel = "RAID"
			elseif GT:IsGroup() then
				channel = "PARTY"
			else
				C.Logger:Normal(msg)
				return
			end
		elseif channel == "RAID_WARNING" then
			if not GT:IsRaidLeaderOrAssistant() then
				self:SendMessage(msg, "SMART", target, isBN)
				return
			end
		end
		if isBN then
			BNSendWhisper(target, msg)
		else
			SendChatMessage(msg, channel, nil, target)
		end
	else
		C.Logger:Normal(msg)
	end
end

--- Parse a message.
-- @param msg The message to parse.
-- @return Table with the individual words.
--
function CM:ParseMessage(msg)
	return CES:Split(msg)
end

--- Parse a command.
-- @param cmd Command to parse.
-- @return Parsed command (without the command char)
--
function CM:ParseCommand(cmd)
	return cmd:sub(self.Settings.CMD_CHAR:len() + 1, cmd:len())
end

--- Check if a string is a command.
-- @param msg String to check.
-- @return True if the string is a command, false otherwise.
--
function CM:IsCommand(msg)
	return CES:StartsWith(msg, self.Settings.CMD_CHAR)
end

function CM:SetCmdChar(char)
	if type(char) ~= "string" then
		return false, "CHAT_ERR_CMDCHAR"
	end
	char = char:lower() --:sub(1, 1)
	self.Settings.CMD_CHAR = char
	return "CHAT_CMDCHAR_SUCCESS", {char}
end

--- Handle a chat message.
-- @param msg The message to handle.
-- @param sender Player object of the player who sent the message.
-- @param channel The channel to which HandleMessage will send the result.
-- @param target Player or channel index.
-- @param sourceChannel The source channel that the message was sent from.
-- @param isBN True if battle.net message, false or nil otherwise.
-- @param pID Player ID (for battle.net messages, this is nil when isBN is false or nil).
--
function CM:HandleMessage(msg, sender, channel, target, sourceChannel, isBN, pID)
	isBN = isBN or false
	pID = pID or nil
	target = target or sender
	local raw = msg
	msg = CES:Trim(msg)
	local args = self:ParseMessage(msg)
	if not self:IsCommand(args[1]) then return end
	self.LastChannel = channel
	self.LastTarget = target
	local cmd = self:ParseCommand(args[1])
	if not CCM:HasCommand(cmd) then return end
	if not AC:IsController(sourceChannel) then
		C.Logger:Normal(L("CHAT_HANDLE_NOTCONTROLLER"):format(sourceChannel:lower()))
		return
	end
	local t = {}
	if #args > 1 then
		for i=2,#args do
			table.insert(t, args[i])
		end
	end
	local player = PM:GetOrCreatePlayer(sender)
	local result, arg, errArg = CCM:HandleCommand(cmd, t, sourceChannel, player)
	if isBN then
		target = pID
		sender = pID
	end
	local l
	if (channel == "WHISPER" or channel == "BNET") or not result then
		l = L:GetLocale(player.Settings.Locale, true)
	else
		l = L:GetActive()
	end
	if result then
		if type(result) == "table" then
			for _,v in ipairs(result) do
				if type(v) == "table" then
					local s = l[v[1]]
					if type(v[2]) == "table" then
						s = s:format(unpack(v[2]))
					end
					self:SendMessage(s, channel, target, isBN)
				end
			end
		elseif result == "RAW_TABLE_OUTPUT" then
			if type(arg) ~= "table" then
				error("Received RAW_TABLE_OUTPUT request, but arg was of type '" .. type(arg) .. "', expected 'table', aborting...")
				return
			end
			for _,v in ipairs(arg) do
				self:SendMessage(tostring(v), channel, target, isBN)
			end
		else
			local s = l[result]
			if type(arg) == "table" then
				s = s:format(unpack(arg))
			end
			self:SendMessage(s, channel, target, isBN)
		end
	elseif arg then
		local s = l[arg]
		if type(errArg) == "table" then
			s = s:format(unpack(errArg))
		end
		self:SendMessage(s, "WHISPER", sender, isBN)
	end
end
