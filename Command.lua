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

--- Table containing all Command methods.
-- This is referenced "C" in Command.lua
-- @name Command
-- @class table
-- @field Name AddOn name.
-- @field Version AddOn version.
-- @field VarVersion SavedVariables version.
-- @field Enabled Enabled state.
-- @field Global Contains the saved variables.
-- @field Settings Contains settings specific to Command.
-- @field Events Contains all registered event handlers.
--
Command = {
	Name = "Command",
	Version = GetAddOnMetadata("Command", "Version"),
	VersionNum = 7, -- Increment on every release
	VersionChecked = false, -- Prevent spam of "New Version" notice
	Loaded = false,
	VarVersion = 2,
	Global = {},
	Settings = {},
	Events = {},
	Data = {}
}

local C = Command
local Cmd
local CM
local PM
local RM
local AC
local log

--- Initialize Command.
--
function C:Init()
	if self.Version == "@" .. "project-version" .. "@" then
		self.Version = "Dev"
	end
	Cmd = self.CommandManager
	CM = self.ChatManager
	PM = self.PlayerManager
	RM = self.RollManager
	AC = self.AddonComm
	log = self.Logger
	self:LoadSavedVars()
	log:Normal("AddOn loaded! Use /cmd help or !help for help. !!NYI!!")
	self.Loaded = true
end

--- Load the saved variables.
-- Also call Init() on modules that need it.
--
function C:LoadSavedVars()
	if type(_G["COMMAND"]) ~= "table" then
		_G["COMMAND"] = {}
	elseif type(_G["COMMAND"]["VERSION"]) == "number" then
		if _G["COMMAND"]["VERSION"] < self.VarVersion then
			log:Normal("Saved Variables out of date, resetting...")
			wipe(_G["COMMAND"])
			_G["COMMAND"] = {}
		end
	end
	self.Global = _G["COMMAND"]
	if type(self.Global.SETTINGS) ~= "table" then
		self.Global.SETTINGS = {}
	end
	self.Settings = self.Global.SETTINGS
	if type(self.Settings.DEBUG) ~= "boolean" then
		self.Settings.DEBUG = false
	end
	if type(self.Settings.ENABLED) ~= "bolean" then
		self.Settings.ENABLED = true
	end
	if type(self.Settings.GROUP_INVITE_ANNOUNCE) ~= "boolean" then
		self.Settings.GROUP_INVITE_ANNOUNCE = false
	end
	if type(self.Settings.GROUP_INVITE_ANNOUNCE_DELAY) ~= "number" then
		self.Settings.GROUP_INVITE_ANNOUNCE_DELAY = 0
	end
	CM:Init()
	PM:Init()
	RM:Init()
	AC:Init()
	Cmd:Init()
	log:SetDebug(self.Settings.DEBUG)
	self.Global.VERSION = self.VarVersion
end

function C:CheckVersion(ver)
	if self.VersionChecked then return end
	ver = ver or 0
	if ver > self.VersionNum then
		log:Normal("\124cffFF0000A new version of \124cff00FFFF" .. self.Name .. "\124cffFF0000 is available! \124cffFFFF00Check the site you downloaded from for the updated version.")
		self.VersionChecked = true
	end
end

--- Control AddOn state.
-- @param enabled Boolean indicating enabled or disabled state.
--
function C:SetEnabled(enabled)
	self.Settings.ENABLED = enabled
	if self.Settings.ENABLED then
		return "AddOn \124cff00FF00enabled\124r."
	end
	return "AddOn \124cffFF0000disabled\124r."
end

--- Enable AddOn.
--
function C:Enable()
	return self:SetEnabled(true)
end

--- Disable AddOn.
--
function C:Disable()
	return self:SetEnabled(false)
end

--- Toggle AddOn on and off.
--
function C:Toggle()
	return self:SetEnabled(not self.Settings.ENABLED)
end

--- Control debugging state.
-- @param enabled Boolean indicating enabled or disabled state.
--
function C:SetDebug(enabled)
	self.Settings.DEBUG = enabled
	log:SetDebug(enabled)
	if self.Settings.DEBUG then
		return "Debugging \124cff00FF00enabled\124r."
	end
	return "Debugging \124cffFF0000disabled\124r."
end

--- Enable debugging.
--
function C:EnableDebug()
	return self:SetDebug(true)
end

--- Disable debugging.
--
function C:DisableDebug()
	return self:SetDebug(false)
end

--- Toggle debugging.
--
function C:ToggleDebug()
	return self:SetDebug(not self.Settings.DEBUG)
end

function C:SetGroupInvite(enabled)
	self.Settings.GROUP_INVITE_ANNOUNCE = enabled
	if self.Settings.GROUP_INVITE_ANNOUNCE then
		return "Group Invite (Announce) enabled."
	end
	return "Group Invite (Announce) disabled."
end

function C:EnableGroupInvite()
	return self:SetGroupInvite(true)
end

function C:DisableGroupInvite()
	return self:SetGroupInvite(false)
end

function C:ToggleGroupInvite()
	return self:SetGroupInvite(not self.Settings.GROUP_INVITE_ANNOUNCE)
end

function C:SetGroupInviteDelay(time)
	if type(time) ~= "number" then
		return false, "Delay has to be a number."
	end
	time = math.ceil(time)
	if time > 50 then
		return false, "Delay cannot be greater than 50 seconds."
	end
	self.Settings.GROUP_INVITE_ANNOUNCE_DELAY = time
	if self.Settings.GROUP_INVITE_ANNOUNCE_DELAY > 0 then
		return "Group Invite (Announce) delay set to " .. self.Settings.GROUP_INVITE_ANNOUNCE_DELAY .. " seconds."
	end
	return "Group Invite (Announce) delay disabled."
end

function C:DisableGroupInviteDelay()
	return self:SetGroupInviteDelay(0)
end
