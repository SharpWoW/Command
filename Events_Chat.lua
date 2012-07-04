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

-- API Upvalues
local BNET_CLIENT_WOW = BNET_CLIENT_WOW

local C = Command
local CM = C.ChatManager
local AC = C.AddonComm
local BNT = C.BattleNetTools

function C.Events.CHAT_MSG_SYSTEM(self, event, ...)
	if C.RollManager.Running then
		C.RollManager:ParseMessage((select(1, ...)))
	end
end

function C.Events.CHAT_MSG_ADDON(self, event, ...)
	local msgType = (select(1, ...))
	local msg = (select(2, ...))
	local channel = (select(3, ...))
	local sender = (select(4, ...))
	AC:Receive(msgType, msg, channel, sender)
end

--[[
function C.Events.CHAT_MSG_BATTLEGROUND(self, event, ...)
	local chan = CM:GetRespondChannelByEvent(event)
	local msg = (select(1, ...))
	local sender = (select(2, ...))
	CM:HandleMessage(msg, sender, chan)
end

function C.Events.CHAT_MSG_BATTLEGROUND_LEADER(self, event, ...)
	local chan = CM:GetRespondChannelByEvent(event)
	local msg = (select(1, ...))
	local sender = (select(2, ...))
	CM:HandleMessage(msg, sender, chan)
end

function C.Events.CHAT_MSG_BN_CONVERSATION(self, event, ...)
end
--]]

--- Event handler for CHAT_MSG_BN_WHISPER.
-- @name Command.Events.CHAT_MSG_BN_WHISPER
-- @param self Reference to Command object.
-- @param event Full name of event.
-- @param ... Event arguments.
--
function C.Events.CHAT_MSG_BN_WHISPER(self, event, ...)
	local chan = "BNET"
	local msg = (select(1, ...))
	local id = (select(13, ...))
	local toon = BNT:GetToon(id)
	if not toon then return end
	if toon.Client ~= BNET_CLIENT_WOW then return end
	if toon.Realm:lower() == GetRealmName():lower() and toon.FactionString:lower() == (select(1, UnitFactionGroup("player"))):lower() then
		CM:HandleMessage(msg, toon.Name, chan, id, chan, true, id)
	end
end

--[[
--- Event handler for CHAT_MSG_CHANNEL.
-- @name Command.Events.CHAT_MSG_CHANNEL
-- @param self Reference to Command object.
-- @param event Full name of event.
-- @param ... Event arguments.
--
function C.Events.CHAT_MSG_CHANNEL(self, event, ...)
	local chan = CM:GetRespondChannelByEvent(event)
	local msg = (select(1, ...))
	local sender = (select(2, ...))
	local target = (select(8, ...))
	CM:HandleMessage(msg, sender, chan, nil, "CHANNEL")
end
--]]

--- Event handler for CHAT_MSG_GUILD.
-- @name Command.Events.CHAT_MSG_GUILD
-- @param self Reference to Command object.
-- @param event Full name of event.
-- @param ... Event arguments.
--
function C.Events.CHAT_MSG_GUILD(self, event, ...)
	local chan = CM:GetRespondChannelByEvent(event)
	local msg = (select(1, ...))
	local sender = (select(2, ...))
	CM:HandleMessage(msg, sender, chan, nil, "GUILD")
end

--- Event handler for CHAT_MSG_OFFICER.
-- @name Command.Events.CHAT_MSG_OFFICER
-- @param self Reference to Command object.
-- @param event Full name of event.
-- @param ... Event arguments.
--
function C.Events.CHAT_MSG_OFFICER(self, event, ...)
	local chan = CM:GetRespondChannelByEvent(event)
	local msg = (select(1, ...))
	local sender = (select(2, ...))
	CM:HandleMessage(msg, sender, chan, nil, "GUILD")
end

--- Event handler for CHAT_MSG_PARTY.
-- @name Command.Events.CHAT_MSG_PARTY
-- @param self Reference to Command object.
-- @param event Full name of event.
-- @param ... Event arguments.
--
function C.Events.CHAT_MSG_PARTY(self, event, ...)
	local chan = CM:GetRespondChannelByEvent(event)
	local msg = (select(1, ...))
	local sender = (select(2, ...))
	CM:HandleMessage(msg, sender, chan, nil, "PARTY")
end

--- Event handler for CHAT_MSG_PARTY_LEADER.
-- @name Command.Events.CHAT_MSG_PARTY_LEADER
-- @param self Reference to Command object.
-- @param event Full name of event.
-- @param ... Event arguments.
--
function C.Events.CHAT_MSG_PARTY_LEADER(self, event, ...)
	local chan = CM:GetRespondChannelByEvent(event)
	local msg = (select(1, ...))
	local sender = (select(2, ...))
	CM:HandleMessage(msg, sender, chan, nil, "PARTY")
end

--- Event handler for CHAT_MSG_RAID.
-- @name Command.Events.CHAT_MSG_RAID
-- @param self Reference to Command object.
-- @param event Full name of event.
-- @param ... Event arguments.
--
function C.Events.CHAT_MSG_RAID(self, event, ...)
	local chan = CM:GetRespondChannelByEvent(event)
	local msg = (select(1, ...))
	local sender = (select(2, ...))
	CM:HandleMessage(msg, sender, chan, nil, "RAID")
end

--- Event handler for CHAT_MSG_RAID_LEADER.
-- @name Command.Events.CHAT_MSG_RAID_LEADER
-- @param self Reference to Command object.
-- @param event Full name of event.
-- @param ... Event arguments.
--
function C.Events.CHAT_MSG_RAID_LEADER(self, event, ...)
	local chan = CM:GetRespondChannelByEvent(event)
	local msg = (select(1, ...))
	local sender = (select(2, ...))
	CM:HandleMessage(msg, sender, chan, nil, "RAID")
end

--- Event handler for CHAT_MSG_RAID_WARNING.
-- @name Command.Events.CHAT_MSG_RAID_WARNING
-- @param self Reference to Command object.
-- @param event Full name of event.
-- @param ... Event arguments.
--
function C.Events.CHAT_MSG_RAID_WARNING(self, event, ...)
	local chan = CM:GetRespondChannelByEvent(event)
	local msg = (select(1, ...))
	local sender = (select(2, ...))
	CM:HandleMessage(msg, sender, chan, nil, "RAID")
end

--- Event handler for CHAT_MSG_SAY.
-- @name Command.Events.CHAT_MSG_SAY
-- @param self Reference to Command object.
-- @param event Full name of event.
-- @param ... Event arguments.
--
function C.Events.CHAT_MSG_SAY(self, event, ...)
	local chan = CM:GetRespondChannelByEvent(event)
	local msg = (select(1, ...))
	local sender = (select(2, ...))
	CM:HandleMessage(msg, sender, chan, nil, "SAY")
end

--- Event handler for CHAT_MSG_WHISPER.
-- @name Command.Events.CHAT_MSG_WHISPER
-- @param self Reference to Command object.
-- @param event Full name of event.
-- @param ... Event arguments.
--
function C.Events.CHAT_MSG_WHISPER(self, event, ...)
	local chan = CM:GetRespondChannelByEvent(event)
	local msg = (select(1, ...))
	local sender = (select(2, ...))
	local target = sender
	CM:HandleMessage(msg, sender, chan, target, "WHISPER")
end

--- Event handler for CHAT_MSG_YELL.
-- @name Command.Events.CHAT_MSG_YELL
-- @param self Reference to Command object.
-- @param event Full name of event.
-- @param ... Event arguments.
--
function C.Events.CHAT_MSG_YELL(self, event, ...)
	local chan = CM:GetRespondChannelByEvent(event)
	local msg = (select(1, ...))
	local sender = (select(2, ...))
	CM:HandleMessage(msg, sender, chan, nil, "YELL")
end
