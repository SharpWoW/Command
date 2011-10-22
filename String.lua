--[[
	{OUTPUT_LICENSE_SHORT}
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
