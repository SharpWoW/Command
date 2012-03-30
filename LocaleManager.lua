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

local C = Command

C.LocaleManager = {
	Settings = {},
	Master = "enUS", -- Fallback locale
	Active = GetLocale(),
	Locales = {}
}

local LM = C.LocaleManager

local function l_index(t, k) -- Wait with metatable stuff til we know everything else works properly :P
	local master = LM:GetMaster()[k]
	if master then return master end
	return ("%%%s%%"):format(k)
end

-- Initialize LocaleManager
function LM:Init()
	if self.Active == "enGB" then self.Active = "enUS" end
	--setmetatable(self.Locales, {__index = function(t, k) error("FATAL: __index meta LocaleManager.Locales report to addon author.") end})
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
	--setmetatable(self.Locales[locale], {__index = l_index})
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
		locale = self.Active
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
