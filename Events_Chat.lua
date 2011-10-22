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
local CM = C.ChatManager

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

function T.Events.CHAT_MSG_BN_CONVERSATION(self, event, ...)
end

function T.Events.CHAT_MSG_BN_WHISPER(self, event, ...)
end

function C.Events.CHAT_MSG_CHANNEL(self, event, ...)
	local chan = CM:GetRespondChannelByEvent(event)
	local msg = (select(1, ...))
	local sender = (select(2, ...))
	local target = (select(8, ...))
	CM:HandleMessage(msg, sender, chan, target)
end
--]]

function C.Events.CHAT_MSG_GUILD(self, event, ...)
	local chan = CM:GetRespondChannelByEvent(event)
	local msg = (select(1, ...))
	local sender = (select(2, ...))
	CM:HandleMessage(msg, sender, chan)
end

function C.Events.CHAT_MSG_OFFICER(self, event, ...)
	local chan = CM:GetRespondChannelByEvent(event)
	local msg = (select(1, ...))
	local sender = (select(2, ...))
	CM:HandleMessage(msg, sender, chan)
end


function C.Events.CHAT_MSG_PARTY(self, event, ...)
	local chan = CM:GetRespondChannelByEvent(event)
	local msg = (select(1, ...))
	local sender = (select(2, ...))
	CM:HandleMessage(msg, sender, chan)
end

function C.Events.CHAT_MSG_PARTY_LEADER(self, event, ...)
	local chan = CM:GetRespondChannelByEvent(event)
	local msg = (select(1, ...))
	local sender = (select(2, ...))
	CM:HandleMessage(msg, sender, chan)
end

function C.Events.CHAT_MSG_RAID(self, event, ...)
	local chan = CM:GetRespondChannelByEvent(event)
	local msg = (select(1, ...))
	local sender = (select(2, ...))
	CM:HandleMessage(msg, sender, chan)
end

function C.Events.CHAT_MSG_RAID_LEADER(self, event, ...)
	local chan = CM:GetRespondChannelByEvent(event)
	local msg = (select(1, ...))
	local sender = (select(2, ...))
	CM:HandleMessage(msg, sender, chan)
end

function C.Events.CHAT_MSG_RAID_WARNING(self, event, ...)
	local chan = CM:GetRespondChannelByEvent(event)
	local msg = (select(1, ...))
	local sender = (select(2, ...))
	CM:HandleMessage(msg, sender, chan)
end

--[[
function C.Events.CHAT_MSG_SAY(self, event, ...)
	local chan = CM:GetRespondChannelByEvent(event)
	local msg = (select(1, ...))
	local sender = (select(2, ...))
	CM:HandleMessage(msg, sender, chan)
end
--]]

function C.Events.CHAT_MSG_WHISPER(self, event, ...)
	local chan = CM:GetRespondChannelByEvent(event)
	local msg = (select(1, ...))
	local sender = (select(2, ...))
	local target = sender
	CM:HandleMessage(msg, sender, chan, target)
end

--[[
function C.Events.CHAT_MSG_YELL(self, event, ...)
	local chan = CM:GetRespondChannelByEvent(event)
	local msg = (select(1, ...))
	local sender = (select(2, ...))
	CM:HandleMessage(msg, sender, chan)
end
--]]
