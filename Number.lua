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

local C = Command

if type(C.Extensions) ~= "table" then
	C.Extensions = {}
end

C.Extensions.Number = {
	type = "ext" -- For future use
}

local L = C.LocaleManager
local CEN = C.Extensions.Number

function CEN:FormatSeconds(seconds)
	-- Return plain seconds if less than 60 seconds
	if seconds < 60 then return ("%d %s"):format(seconds, L("SECONDS"):lower()) end
	local minutes = floor(seconds / 60) -- Get number of minutes
	local secs = tostring(seconds - minutes * 60) -- Get number of remaining seconds
	if not secs:match("%d%d") then -- Check if seconds <= 9
		secs = "0" .. secs -- Prefix a zero to make it look better
	end
	return ("%d:%s"):format(minutes, secs) -- Return in m:ss format
end
