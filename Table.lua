--[[
	{OUTPUT_LICENSE_SHORT}
--]]

if type(Command.Extensions) ~= "table" then
	Command.Extensions = {}
end

Command.Extensions.Table = {}

local CET = Command.Extensions.Table

function CET:HasKey(tbl, key)
	for k,_ in pairs(tbl) do
		if k == key then return true end
	end
	return false
end

function CET:HasValue(tbl, value)
	for _,v in pairs(tbl) do
		if v == value then return true end
	end
	return false
end

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
