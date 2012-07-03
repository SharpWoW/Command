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
local tostring = tostring
local tonumber = tonumber
local math = math

local C = Command

C.AuthManager = {
	Users = {}
}

local AM = C.AuthManager
local CES = C.Extensions.String
local CET = C.Extensions.Table

local function GeneratePassword(user, pass)
	local pass = ("%s:%s"):format(tostring(user):upper(), tostring(pass))
	-- TODO: Make generation better
	return pass
end

local function Verify(user, pass)
	user = tostring(user):upper()
	if not AM.Users[user] then return false end
	if not AM.Users[user].Enabled then return false end
	if AM.Users[user].Authed then return true end
	if not pass:match("^%w+:%w+$") then
		pass = ("%s:%s"):format(user, pass)
	end
	local uPass = tostring(AM.Users[user].Pass)
	local split = CES:Split(pass, ":")
	local u = tostring(split[1])
	local p = tostring(split[2])
	pass = ("%s:%s"):format(u:upper(), p)
	return pass == uPass
end

function AM:Authenticate(user, pass)
	user = tostring(user):upper()
	if not self.Users[user] then
		return false, "AM_ERR_NOEXISTS", {user}
	elseif not self.Users[user].Enabled then
		return false, "AM_ERR_DISABLED", {user}
	elseif self.Users[user].Authed then
		return false, "AM_ERR_AUTHED", {user}
	end
	if Verify(user, pass) then
		self.Users[user].Authed = true
		return "AM_AUTH_SUCCESS", {user, self.Users[user].Level}
	end
	self.Users[user].Authed = false
	return false, "AM_AUTH_ERR_INVALIDPASS"
end

function AM:Add(user, level, pass, notify)
	user = tostring(user):upper()
	level = tonumber(level)
	if self.Users[user] then
		return false, "AM_ERR_USEREXISTS", {user}
	elseif not level then
		return false, "AM_ERR_NOLEVEL"
	end
	pass = pass or tostring(math.random(123, 9999)) -- Lame default password
	pass = GeneratePassword(user, pass)
	local userTable = {
		Name = user,
		Pass = pass,
		Enabled = true,
		Authed = false,
		Level = level
	}
	self.Users[user] = CET:Copy(userTable)
	if notify then
		C.ChatManager:SendMessage(C.LocaleManager("AM_ADD_WHISPER"):format(level, pass), "WHISPER", user)
	end
	return "AM_ADD_SUCCESS", {user, level, pass}
end

function AM:Remove(user)
	user = tostring(user):upper()
	if not self.Users[user] then return false, "AM_ERR_NOEXISTS", {user} end
	self.Users[user] = nil
	return "AM_REMOVE_SUCCESS", {user}
end

function AM:Enable(user)
	user = tostring(user):upper()
	if not self.Users[user] then return false, "AM_ERR_NOEXISTS", {user} end
	self.Users[user].Enabled = true
	return "AM_ENABLE_SUCCESS", {user}
end

function AM:Disable(user)
	user = tostring(user):upper()
	if not self.Users[user] then return false, "AM_ERR_NOEXISTS", {user} end
	self.Users[user].Enabled = false
	return "AM_DISABLE_SUCCESS", {user}
end
