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

-- NOTE: All error() calls use constant strings in english for debugging reasons.
-- NOTE: return after error() shouldn't be needed. Consider remove.

-- Upvalues
local type = type
local pairs = pairs
local tostring = tostring
local setmetatable = setmetatable

-- Custom GetLocale()
local BlizzGetLocale = GetLocale
local GetLocale = function()
	local l = BlizzGetLocale()
	if l == "enGB" then l = "enUS" end
	return l
end

local C = Command

C.LocaleManager = {
	Settings = {},
	Master = "enUS", -- Fallback locale
	Active = GetLocale(),
	Locales = {}
}

local LM = C.LocaleManager

local function l_index(self, k)
	k = tostring(k):upper()
	master = LM:GetMaster()
	if self == master then -- Prevent recursion
		return ("%s"):format(k)
	end
	local val = master[k]
	if val then return val end
end

local s_meta = {
	__call = function(self, arg1, arg2, isPlr)
		if not arg1 and not arg2 then return nil end
		if arg2 then -- (locale, key)
			return self:GetLocale(arg1, isPlr)[tostring(arg2):upper()]
		end
		arg1 = tostring(arg1):upper()
		return self:GetActive()[arg1]
	end
}

-- Initialize LocaleManager
function LM:Init()
	if self.Active == "enGB" then self.Active = "enUS" end
	setmetatable(self, s_meta)
	self:LoadSavedVars()
end

-- Load the saved variables
function LM:LoadSavedVars()
	if type(C.Settings.LOCALE_MANAGER) ~= "table" then
		C.Settings.LOCALE_MANAGER = {}
	end
	self.Settings = C.Settings.LOCALE_MANAGER
	if type(self.Settings.LOCALE) ~= "string" then
		self.Settings.LOCALE = self.Active
	end
	if type(self.Settings.PLAYER_INDEPENDENT) ~= "boolean" then
		self.Settings.PLAYER_INDEPENDENT = true
	end
end

-- Register a new locale (might add a check against master to make sure no keys are missing)
function LM:Register(locale, localeTable)
	if type(locale) ~= "string" or type(localeTable) ~= "table" then
		error("Invalid arguments for Register. Expected [string, table], got ["..type(locale)..", "..type(localeTable).."]!")
		return
	end
	locale = locale:lower()
	if self:LocaleLoaded(locale) then return end
	self.Locales[locale] = {}
	for k,v in pairs(localeTable) do
		if type(v) == "string" then
			self.Locales[locale][k] = v
		end
	end
	setmetatable(self.Locales[locale], {__index = l_index})
end

-- Check if a locale has been loaded/registered
function LM:LocaleLoaded(locale)
	locale = locale:lower()
	if self.Locales[locale] then
		return true
	end
	return false
end

-- Get the locale <locale>
-- Will handle nonexistant locale
-- However, if for some reason the client default or fallback locale is NOT loaded...
-- ^NOTE^ Above should not happen, under any circumstance what-so-ever unless Locales table is modified.
function LM:GetLocale(locale, isPlr)
	if isPlr and not self.Settings.PLAYER_INDEPENDENT then
		locale = self.Settings.LOCALE
	end
	locale = locale or self.Settings.LOCALE
	locale = locale:lower()
	if locale == "engb" then locale = "enus" end
	if not self:LocaleLoaded(locale) then
		if locale ~= self.Settings.LOCALE:lower() then -- Prevent infinite loop...
			return self:GetActive()
		elseif locale ~= self.Master:lower() then
			return self:GetMaster()
		else
			error("FATAL: GetLocale unable to resolve to working locale.")
			return nil
		end
	end
	return self.Locales[locale]
end

-- Returns client locale (or user setting if set)
function LM:GetActive()
	return self:GetLocale(self.Settings.LOCALE)
end

-- Returns master (fallback) locale
function LM:GetMaster()
	if not self:LocaleLoaded(self.Master) then
		error("FATAL! Master locale not loaded, AddOn cannot function!")
		return
	end
	return LM:GetLocale(self.Master)
end

-- Set the locale to use
function LM:SetLocale(locale)
	if locale:lower() == "engb" then locale = "enUS" end
	if not self:LocaleLoaded(locale) then
		return false, "LOCALE_NOT_LOADED"
	end
	self.Settings.LOCALE = locale
	return "LOCALE_UPDATE", {self.Settings.LOCALE}
end

-- Reset locale to client default
function LM:ResetLocale()
	return self:SetLocale(self.Active)
end

-- Set locale to master (fallback) locale
function LM:UseMasterLocale()
	return self:SetLocale(self.Master)
end

function LM:SetPlayerIndependent(active)
	self.Settings.PLAYER_INDEPENDENT = active
	if self.Settings.PLAYER_INDEPENDENT then
		return "LOCALE_PI_ACTIVE"
	end
	return "LOCALE_PI_INACTIVE"
end

function LM:EnablePlayerIndependent()
	return self:SetPlayerIndependent(true)
end

function LM:DisablePlayerIndependent()
	return self:SetPlayerIndependent(false)
end

function LM:TogglePlayerIndependent()
	return self:SetPlayerIndependent(not self.Settings.PLAYER_INDEPENDENT)
end
