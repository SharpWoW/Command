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

local C = Command

--- Table containing all String methods.
-- This is referenced "CES" in String.lua.
-- @name Command.Extentions.String
-- @class table
-- @field type No current use.
--
C.Extensions.String = {
	type = "ext" -- For future use
}

local CES = C.Extensions.String

--- Check if a string starts with a specific string.
-- @param s String to be checked.
-- @param target String to search for at beginning of s.
--
function CES:StartsWith(s, target)
	return s:sub(1, target:len()) == target
end

--- Check if a string ends with a specific string.
-- @param s String to be checked.
-- @param target Stromg to search for at end of s.
--
function CES:EndsWith(s, target)
	return target == '' or s:sub(-target:len()) == target
end

--- Trim a string, removing whitespace at the beginning of it.
-- @param s String to be trimmed.
-- @return The trimmed string.
--
function CES:Trim(s)
	return (s:gsub("^%s*(.-)%s*$", "%1"))
end

--- Split a string with space as delimiter.
-- @param s String to be split.
-- @return Table containing the individual words.
--
function CES:Split(s)
	s = s or " "
	local t = {}
	for token in string.gmatch(s, "[^%s]+") do
		table.insert(t, token)
	end
	return t
end

--- Cut a string into parts.
-- @param s The String to cut.
-- @param l Length of each string part.
-- @return Table containing the different parts.
--
function CES:Cut(s, l)
	if type(s) ~= "string" or type(l) ~= "number" then
		error("Invalid parameters passed, expected [string, number], got: [" .. type(s) .. ", " .. type(l) .. "]!")
		return
	end
	if s:len() <= l then return s end
	local c = math.ceil(s:len() / l)
	local pos = 1
	local t = {}
	for i = 1, c do
		local part = s:sub(pos, l * i)
		table.insert(t, part)
		pos = l * i + 1
	end
	return t
end
