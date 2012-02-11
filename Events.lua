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
local QM = C.QueueManager
local AC = C.AddonComm

--[[
function T.Events.CHAT_MSG_ADDON(event, ...)
	
end
--]]

--- Event handler for ADDON_LOADED
-- @name Command.Events.ADDON_LOADED
-- @param self Reference to Command object.
-- @param ... Event arguments.
--
function C.Events.ADDON_LOADED(self, ...)
	local name = (select(1, ...))
	if name:lower() ~= self.Name:lower() then return end
	self:Init()
end

--- Event handler for LFG_UPDATE
-- @name Command.Events.LFG_UPDATE
-- @param self Reference to Command object.
-- @param ... Event arguments.
--
function C.Events.LFG_UPDATE(self, ...)
	if not QM.QueuedByCommand then return end
	QM:AnnounceStatus()
end

--- Event handler for LFG_PROPOSAL_SHOW
-- @name Command.Events.LFG_PROPOSAL_SHOW
-- @param self Reference to Command object.
-- @param ... Event arguments.
--
function C.Events.LFG_PROPOSAL_SHOW(self, ...)
	if not QM.QueuedByCommand then return end
	CM:SendMessage("Group has been found, type !accept to make me accept the invite.", "PARTY")
end

--- Event handler for LFG_PROPOSAL_FAILED
-- @name Command.Events.LFG_PROPOSAL_FAILED
-- @param self Reference to Command object.
-- @param ... Event arguments.
--
function C.Events.LFG_PROPOSAL_FAILED(self, ...)
	if not QM.QueuedByCommand then return end
	QM.QueuedByCommand = false
	CM:SendMessage("LFG failed, use !queue <type> to requeue.", "PARTY")
end

function C.Events.READY_CHECK(self, ...)
	if C.Data.ReadyCheckRunning then return end
	C.Data.ReadyCheckRunning = true
	local name = tostring(select(1, ...))
	CM:SendMessage(name .. " issued a ready check, type !rc accept to make me accept it or !rc deny to deny it.", "SMART")
end

function C.Events.READY_CHECK_FINISHED(self, ...)
	C.Data.ReadyCheckRunning = false
end

function C.Events.RAID_ROSTER_UPDATE(self, ...)
	if AC.GroupRunning then return end
	AC:UpdateGroup()
end

function C.Events.PARTY_MEMBERS_CHANGED(self, ...)
	if AC.GroupRunning then return end
	AC:UpdateGroup()
end

function C.Events.PARTY_LEADER_CHANGED(self, ...)
	if AC.GroupRunning then return end
	AC:UpdateGroup()
end

function C.Events.GUILD_ROSTER_UPDATE(self, ...)
	if AC.GuildRunning then return end
	AC:UpdateGuild()
end
