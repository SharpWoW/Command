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
	if not s then return false end
	return s:sub(1, target:len()) == target
end

--- Check if a string ends with a specific string.
-- @param s String to be checked.
-- @param target String to search for at end of s.
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
-- @param d Delimiter
-- @return Table containing the individual words.
--
function CES:Split(s, d)
	if not s then return nil end
	local t = {}
	if not d then
		for token in s:gmatch("[^%s]+") do
			table.insert(t, token)
		end
	else
		if not s:find(d) then return {s} end
		local pattern = "(.-)" .. d .. "()"
		local num = 0
		local lastPos
		for part,pos in s:gmatch(pattern) do
			num = num + 1
			t[num] = part
			lastPos = pos
		end
		t[num + 1] = s:sub(lastPos)
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

--- Split a string into parts to fit the length specified.
-- Works like Cut() except keeps words together to make it more pretty.
-- @param s The string to fit.
-- @param l Max length of each part.
-- @param d Delimiter to separate each word with.
-- @return Table containing the parts.
--
function CES:Fit(s, l, d)
	if (type(s) ~= "string" and type(s) ~= "table") or type(l) ~= "number" then
		error("Invalid parameters passed, expected [string, number], got: [" .. type(s) .. ", " .. type(l) .. "]!")
		return
	end
	d = d or " "
	if type(s) == "table" then s = C.Extensions.Table:Join(s) end
	if s:len() <= l then return s end
	local words = self:Split(s)
	local parts = {}
	local part = ""
	for i=1, #words do
		part = part .. words[i]
		if i >= #words then
			table.insert(parts, part)
			break
		elseif (part .. words[i + 1]):len() >= l then
			table.insert(parts, part)
			part = ""
		else
			part = part .. d
		end
	end
	return parts
end

function CES:IsNullOrEmpty(s)
	return s == nil or s == ""
end
