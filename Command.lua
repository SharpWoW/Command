--[[
	{OUTPUT_LICENSE_SHORT}
	
	----------
	
	{OUTPUT_DESC_SHORT}
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
