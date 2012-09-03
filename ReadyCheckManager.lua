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
local UnitName = UnitName
local CreateFrame = CreateFrame
local DoReadyCheck = DoReadyCheck
local ConfirmReadyCheck = ConfirmReadyCheck
local GetReadyCheckStatus = GetReadyCheckStatus
local GetReadyCheckTimeLeft = GetReadyCheckTimeLeft

local C = Command

C.ReadyCheckManager = {}

local L = C.LocaleManager
local RCM = C.ReadyCheckManager
local CM

local MAX_DELAY = 55
local DEFAULT_DELAY = 5

local AnnouncePending = false

function RCM:Init()
	CM = C.ChatManager
	self:LoadSavedVars()
end

function RCM:LoadSavedVars()
	if type(C.Global["READYCHECK_MANAGER"]) ~= "table" then
		C.Global["READYCHECK_MANAGER"] = {}
	end

	self.Settings = C.Global["READYCHECK_MANAGER"]

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

function RCM:OnReadyCheck(sender)
	if not self.Settings.ANNOUNCE or AnnouncePending or not self.Settings.ENABLED then return end
	if sender == UnitName("player") then return end
	self.Active = true
	if self.Settings.DELAY > 0 then
		AnnouncePending = true
		local frame = CreateFrame("Frame")
		frame.Time = 0
		frame.Delay = self.Settings.DELAY
		frame.Sender = sender
		frame:SetScript("OnUpdate", function(self, elapsed)
			self.Time = self.Time + elapsed
			if self.Time >= self.Delay then
				self:SetScript("OnUpdate", nil)
				AnnouncePending = false
				RCM:Announce(self.Sender)
			end
		end)
	else
		self:Announce(sender)
	end
end

function RCM:OnReadyCheckEnd()
	self.Active = false
end

function RCM:Announce(sender)
	if not self:ReadyCheckPending() then return end
	CM:SendMessage(L("RCM_ANNOUNCE"):format(sender), "SMART")
end

function RCM:ReadyCheckPending()
	return GetReadyCheckTimeLeft() > 0 or (ReadyCheckFrame and ReadyCheckFrame:IsShown())
end

function RCM:HasResponded()
	local status = GetReadyCheckStatus("player")
	return status ~= "waiting" and status ~= nil
end

function RCM:Accept()
	if not self:ReadyCheckPending() then
		return false, "RCM_INACTIVE"
	elseif self:HasResponded() then
		return false, "RCM_RESPONDED"
	end
	ConfirmReadyCheck(true)
	self:HidePopup()
	return "RCM_ACCEPTED"
end

function RCM:Decline()
	if not self:ReadyCheckPending() then
		return false, "RCM_INACTIVE"
	elseif self:HasResponded() then
		return false, "RCM_RESPONDED"
	end
	ConfirmReadyCheck(false)
	self:HidePopup()
	return "RCM_DECLINED"
end

function RCM:Start(sender)
	if GT:IsGroupLeader() or GT:IsRaidLeaderOrAssistant() then
		DoReadyCheck()
		return "RCM_START_ISSUED", {sender}
	end
	return false, "RCM_START_NOPRIV"
end

function RCM:HidePopup()
	if ReadyCheckFrame and ReadyCheckFrame:IsShown() then
		ReadyCheckFrame:Hide()
	end
end

function RCM:Enable()
	self.Settings.ENABLED = true
	return "RCM_ENABLED"
end

function RCM:Disable()
	self.Settings.ENABLED = false
	-- We have to reset the active state in case this was called during a ready check
	self.Active = false
	return "RCM_DISABLED"
end

function RCM:Toggle()
	if self:IsEnabled() then
		return self:Disable()
	end
	return self:Enable()
end

function RCM:IsEnabled()
	return self.Settings.ENABLED
end

function RCM:EnableAnnounce()
	self.Settings.ANNOUNCE = true
	return "RCM_ANNOUNCE_ENABLED"
end

function RCM:DisableAnnounce()
	self.Settings.ANNOUNCE = false
	return "RCM_ANNOUNCE_DISABLED"
end

function RCM:ToggleAnnounce()
	if self:IsAnnounceEnabled() then
		return self:DisableAnnounce()
	end
	return self:EnableAnnounce()
end

function RCM:IsAnnounceEnabled()
	return self.Settings.ANNOUNCE
end

function RCM:SetDelay(amount)
	if amount < 0 then
		amount = 0
	elseif amount > MAX_DELAY then
		amount = MAX_DELAY
	end
	self.Settings.DELAY = amount
	if amount > 0 then
		return "RCM_SETDELAY_SUCCESS", {self:GetDelay()}
	end
	return "RCM_SETDELAY_INSTANT"
end

function RCM:GetDelay()
	return self.Settings.DELAY
end
