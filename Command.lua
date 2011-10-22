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

Command = {
	Logger = nil,
	Name = "Command",
	Version = GetAddOnMetadata("Command", "Version"),
	VarVersion = 1,
	Enabled = true,
	Global = {},
	Settings = {},
	Events = {},
	Modules = {}
}

local C = Command
local Cmd
local CM
local PM
local log

function C:Init()
	Cmd = self.CommandManager
	CM = self.ChatManager
	PM = self.PlayerManager
	log = self.Logger
	self:LoadSavedVars()
	log.Settings.Debug = self.Settings.DEBUG
end

function C:LoadSavedVars()
	if type(_G["COMMAND"]) ~= "table" then
		_G["COMMAND"] = {}
	elseif type(_G["COMMAND"]["VERSION"]) == "number" then
		if _G["COMMAND"]["VERSION"] < self.VarVersion then
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
	CM:Init()
	PM:Init()
	Cmd:Init()
	self.Global.VERSION = self.VarVersion
end

function C:SetEnabled(enabled)
	self.Enabled = enabled
end

function C:Enable()
	self:SetEnabled(true)
end

function C:Disable()
	self:SetEnabled(false)
end

function C:Toggle()
	self:SetEnabled(not self.Enabled)
end

function C:SetDebug(enabled)
	self.Settings.DEBUG = enabled
	log:SetDebug(enabled)
end

function C:EnableDebug()
	self:SetDebug(true)
end

function C:DisableDebug()
	self:SetDebug(false)
end

function C:ToggleDebug()
	self:SetDebug(not self.Settings.DEBUG)
end
