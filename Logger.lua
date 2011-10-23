--[[	* Copyright (c) 2011 by Adam Hellberg.	* 	* This file is part of Command.	* 	* Command is free software: you can redistribute it and/or modify	* it under the terms of the GNU General Public License as published by	* the Free Software Foundation, either version 3 of the License, or	* (at your option) any later version.	* 	* Command is distributed in the hope that it will be useful,	* but WITHOUT ANY WARRANTY; without even the implied warranty of	* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the	* GNU General Public License for more details.	* 	* You should have received a copy of the GNU General Public License	* along with Command. If not, see <http://www.gnu.org/licenses/>.--]]Command.Logger = {	Level = {		Debug = 0,		Normal = 1,		Warning = 2,		Error = 3	},	Settings = {		Debug = false,		Format = "%s%s: %s",		Prefix = {			Main = "\124cff00FF00[Command]\124r",			Debug = " \124cffBBBBFFDebug\124r",			Normal = "",			Warning = " \124cffFFFF00Warning\124r",			Error = " \124cffFF0000ERROR\124r"		}	}}local Logger = Command.Logger-------------------------- MAIN LOGGER MODULE ----------------------------- Print a log message at the specified level.-- @param msg Message to pring.-- @param level One of the levels defined in Logger.Level.--function Logger:Print(msg, level)	local prefix	if level == self.Level.Debug then		if not self.Settings.Debug then return end		prefix = self.Settings.Prefix.Debug	elseif level == self.Level.Normal then		prefix = self.Settings.Prefix.Normal	elseif level == self.Level.Warning then		prefix = self.Settings.Prefix.Warning	elseif level == self.Level.Error then		prefix = self.Settings.Prefix.Error	else		error(("Undefined logger level passed (%q)"):format(tostring(level)))		return	end	DEFAULT_CHAT_FRAME:AddMessage(self.Settings.Format:format(self.Settings.Prefix.Main, prefix, msg))end--- Print a debug message.-- @param msg Message to print.--function Logger:Debug(msg)	self:Print(msg, self.Level.Debug)end--- Print a normal message-- @param msg Message to print.--function Logger:Normal(msg)	self:Print(msg, self.Level.Normal)end--- Print a warning message.-- @param msg Message to pring.--function Logger:Warning(msg)	self:Print(msg, self.Level.Warning)end--- Print an error message.-- @param msg Message to print.--function Logger:Error(msg)	self:Print(msg, self.Level.Error)end--- Control the debug state.-- Setting debugging to enabled will make debug messages able to be printed.-- @param enabled Boolean indicating enabled or disabled state.--function Logger:SetDebug(enabled)	self.Settings.Debug = enabledend--- Enable debugging.--function Logger:EnableDebug()	self:SetDebug(true)end--- Disable debugging.--function Logger:DisableDebug()	self:SetDebug(false)end--- Toggle debugging.--function Logger:ToggleDebug()	self:SetDebug(not self.Settings.Debug)end