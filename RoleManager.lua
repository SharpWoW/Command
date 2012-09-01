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

-- API Upvalues
local CreateFrame = CreateFrame
local UnitSetRole = UnitSetRole
local UnitGetAvailableRoles = UnitGetAvailableRoles
local UnitGroupRolesAssigned = UnitGroupRolesAssigned

local C = Command

C.RoleManager = {
	Roles = {
		TANK = "CRM_TANK",
		HEALER = "CRM_HEALER",
		DAMAGER = "CRM_DAMAGE",
		NONE = "CRM_UNDEFINED",
		Tank = "TANK",
		Healer = "HEALER",
		Damage = "DAMAGER",
		Undefined = "NONE"
	},
	BlizzRoles = {}
}

local L = C.LocaleManager
local RM = C.RoleManager
local GT = C.GroupTools
local CM
local CEN = C.Extensions.Number

local DEFAULT_DELAY = 5
local MAX_DELAY = 60 -- Arbitrary max delay, unknown if there is an existing delay

local AnnouncePending = false

function RM:Init()
	CM = C.ChatManager
	self:LoadSavedVars()
end

function RM:LoadSavedVars()
	if type(C.Global["ROLE_MANAGER"]) ~= "table" then
		C.Global["ROLE_MANAGER"] = {}
	end

	self.Settings = C.Global["ROLE_MANAGER"]

	if type(self.Settings.ENABLED) ~= "boolean" then
		self.Settings.ENABLED = true
	end

	if type(self.Settings.ANNOUNCE) ~= "boolean" then
		self.Settings.ANNOUNCE = true
	end

	if type(self.Settings.DELAY) ~= "number" then
		self.Settings.DELAY = DEFAULT_DELAY
	end
end

function RM:OnRoleCheck()
	if AnnouncePending then return end
	if self.Settings.DELAY > 0 then
		AnnouncePending = true
		local frame = CreateFrame("Frame")
		frame.Time = 0
		frame.Delay = self.Settings.DELAY
		frame:SetScript("OnUpdate", function(self, elapsed)
			self.Time = self.Time + elapsed
			if self.Time >= self.Delay then
				self:SetScript("OnUpdate", nil)
				AnnouncePending = false
				RM:Announce()
			end
		end)
	else
		self:Announce()
	end
end

function RM:Announce()
	if not self:RolePollActive() or not self.Settings.ANNOUNCE then return end
	local current = self:GetRole()
	local msg
	if current ~= self.Roles.Undefined then
		msg = "CRM_ANNOUNCE_HASROLE"
	else
		msg = "CRM_ANNOUNCE_NOROLE"
	end
	CM:SendMessage(L(msg):format(L(self.Roles[current])), "SMART")
end

function RM:SetRole(role)
	if type(role) ~= "string" then
		error("RoleManager.SetRole: Argument was of type [" .. type(role) .. "], expected [string].")
		return nil
	end
	role = role:lower()
	local result = self.Roles.Damage
	if role:match("^t") then
		result = self.Roles.Tank
	elseif role:match("^h") then
		result = self.Roles.Healer
	end
	if not self:CanBeRole(result) then
		return false, "CRM_SET_INVALID", {L(self.Roles[result])}
	end
	UnitSetRole("player", result)
	if self:RolePollActive() then
		RolePollPopup:Hide()
	end
	return "CRM_SET_SUCCESS", {L(self.Roles[result])}
end

function RM:GetRole()
	local role = UnitGroupRolesAssigned("player")
	if role == "TANK" then
		return self.Roles.Tank
	elseif role == "HEALER" then
		return self.Roles.Healer
	elseif role == "DAMAGER" then
		return self.Roles.Damage
	end
	return self.Roles.Undefined
end

function RM:ConfirmRole()
	local role = self:GetRole()
	if role == self.Roles.Undefined then
		return false, "CRM_CONFIRM_NOROLE"
	end
	return self:SetRole(role)
end

function RM:CanBeRole(role)
	if type(role) ~= "string" then
		error("RoleManager.CanBeRole: Argument was of type [" .. type(role) .. "], expected [string].")
		return nil
	end
	role = role:lower()
	local tank, healer, dps = UnitGetAvailableRoles("player")
	if role:match("^t") then
		return tank
	elseif role:match("^h") then
		return healer
	end
	return dps
end

function RM:RolePollActive()
	return RolePollPopup and RolePollPopup:IsShown()
end

function RM:Start()
	if self:RolePollActive() then
		return false, "CRM_START_ACTIVE"
	elseif (GT:IsParty() and GT:IsGroupLeader()) or (GT:IsRaid() and GT:IsRaidLeaderOrAssistant()) then
		InitiateRolePoll()
		return "CRM_START_SUCCESS"
	elseif not GT:IsGroup() then
		return false, "CRM_START_NOGROUP"
	end
	return false, "CRM_START_NOPRIV"
end

function RM:Enable()
	self.Settings.ENABLED = true
	return "CRM_ENABLED"
end

function RM:Disable()
	self.Settings.ENABLED = false
	return "CRM_DISABLED"
end

function RM:Toggle()
	if self:IsEnabled() then
		return self:Disable()
	end
	return self:Enable()
end

function RM:IsEnabled()
	return self.Settings.ENABLED
end

function RM:EnableAnnounce()

end

function RM:DisableAnnounce()

end

function RM:ToggleAnnounce()

end

function RM:IsAnnounceEnabled()

end

function RM:GetDelay()
	return CEN:FormatSeconds(self:GetRawDelay())
end

function RM:GetRawDelay()
	return self.Settings.DELAY
end

function RM:SetDelay(amount)
	if amount < 0 then
		amount = 0
	elseif amount > MAX_DELAY then
		amount = MAX_DELAY
	end
	self.Settings.DELAY = amount
	if amount > 0 then
		return "CRM_SETDELAY_SUCCESS", {CEN:FormatSeconds(amount)}
	end
	return "CRM_SETDELAY_INSTANT"
end
