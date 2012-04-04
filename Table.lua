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
local pairs = pairs
local tostring = tostring

local C = Command

if type(C.Extensions) ~= "table" then
	C.Extensions = {}
end

--- Table containing all Table methods.
-- This is referenced "CET" in Table.lua.
-- @name Command.Extensions.Table
-- @class table
-- @field type No current use.
--
C.Extensions.Table = {
	type = "ext"
}

local CET = C.Extensions.Table

--- Check if a table has the supplied key.
-- @param tbl Table to check.
-- @param key Key to search for.
-- @return True if the key was found, false otherwise.
--
function CET:HasKey(tbl, key)
	for k,_ in pairs(tbl) do
		if k == key then return true end
	end
	return false
end

--- Check if a table contains the supplied value.
-- @param tbl Table to check.
-- @param value Value to search for.
-- @return True if the value was found, false otherwise.
function CET:HasValue(tbl, value)
	for _,v in pairs(tbl) do
		if v == value then return true end
	end
	return false
end

-- Thanks to ITSBTH for the table copy function
--- Create a copy of a table.
-- @param tbl Table to copy.
-- @param cache Cache used for recursion.
-- @return A copy of the supplied table without references.
--
function CET:Copy(tbl, cache)
	if type(tbl) ~= "table" then return tbl end
	cache = cache or {}
	if cache[tbl] then return cache[tbl] end
	local copy = {}
	cache[tbl] = copy
	for k, v in pairs(tbl) do
		copy[self:Copy(k, cache)] = self:Copy(v, cache)
	end
	return copy
end

--- Join table values together to create a string.
-- @param tbl Table to join.
-- @param d Delimiter to use between values.
-- @return String containing the joined values of the table.
--
function CET:Join(tbl, d)
	if type(tbl) ~= "table" then
		error("Expected argument of type [table], got [" .. type(tbl) .. "]!")
		return
	end
	d = d or " "
	if #tbl <= 0 then return "" end
	local s = tostring(tbl[1])
	if #tbl > 1 then
		for i=2, #tbl do
			s = s .. d .. tostring(tbl[i])
		end
	end
	return s
end
