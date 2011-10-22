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

if type(Command.Extensions) ~= "table" then
	Command.Extensions = {}
end

Command.Extensions.String = {}

local CES = Command.Extensions.String

function CES:StartsWith(s, target)
	return s:sub(1, target:len()) == target
end

function CES:EndsWith(s, target)
	return target == '' or s:sub(-target:len()) == target
end

function CES:Trim(s)
	return (s:gsub("^%s*(.-)%s*$", "%1"))
end

function CES:Split(s)
	local t = {}
	for token in string.gmatch(s, "[^%s]+") do
		table.insert(t, token)
	end
	return t
end
