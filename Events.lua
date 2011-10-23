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
