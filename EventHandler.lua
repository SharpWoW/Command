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

local C = Command
local L = C.LocaleManager
local CES = C.Extensions.String

--- Handles events.
-- @name Command.OnEvent
-- @param frame The frame on which the event was registered.
-- @param event Full name of the event.
-- @param ... Event arguments.
--
function C:OnEvent(frame, event, ...)
	if self.Loaded and not self.Settings.ENABLED then return end
	if not self.Events[event] then return end
	if CES:StartsWith(event, "CHAT_MSG_") then
		self.Events[event](self, event, ...)
	else
		self.Events[event](self, ...)
	end
end

C.Frame = CreateFrame("Frame")
for k,_ in pairs(C.Events) do
	C.Frame:RegisterEvent(k)
end
C.Frame:SetScript("OnEvent", function(frame, event, ...) C:OnEvent(frame, event, ...) end)
