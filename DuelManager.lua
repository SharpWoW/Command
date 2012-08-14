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
local ceil = math.ceil

-- API Upvalues
local StartDuel = StartDuel
local AcceptDuel = AcceptDuel
local CancelDuel = CancelDuel
local CreateFrame = CreateFrame
local StaticPopup_Hide = StaticPopup_Hide
local StaticPopup_Visible = StaticPopup_Visible

local C = Command

C.DuelManager = {}

local L = C.LocaleManager
local DM = C.DuelManager
local PM
local CM

local DEFAULT_DELAY = 5

local MAX_DELAY = 50

function DM:Init()
	PM = C.PlayerManager
	CM = C.ChatManager
	self:LoadSavedVars()
end

function DM:LoadSavedVars()
	if type(C.Global["DUEL_MANAGER"]) ~= "table" then
		C.Global["DUEL_MANAGER"] = {}
	end

	self.Settings = C.Global["DUEL_MANAGER"]

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

function DM:OnDuel(sender)
	if self.Settings.DELAY > 0 then
		local frame = CreateFrame("Frame")
		frame.Time = 0
		frame.Delay = self.Settings.DELAY
		frame.Sender = sender
		frame:SetScript("OnUpdate", function(self, elapsed)
			self.Time = self.Time + elapsed
			if self.Time >= self.Delay then
				self:SetScript("OnUpdate", nil)
				DM:Announce(self.Sender)
			end
		end)
	else
		self:Announce(sender)
	end
end

function DM:Announce(sender)
	if not self:HasDuel() then return end
	local locale = PM:GetOrCreatePlayer(sender).Settings.locale
	local msg = L(locale, "CDM_ANNOUNCE", true)
	CM:SendMessage(msg, "WHISPER", sender)
end

function DM:AcceptDuel()
	if not self:HasDuel() then
		return false, "CDM_ERR_NODUEL"
	end

	AcceptDuel()

	if StaticPopup_Visible("DUEL_REQUESTED") then
		StaticPopup_Hide("DUEL_REQUESTED")
	end

	return "CDM_ACCEPTED"
end

function DM:DeclineDuel()
	if not DM:HasDuel() then
		return self:CancelDuel()
	end

	CancelDuel()

	if StaticPopup_Visible("DUEL_REQUESTED") then
		StaticPopup_Hide("DUEL_REQUESTED")
	end

	return "CDM_DECLINED"
end

function DM:CancelDuel()
	CancelDuel()

	return "CDM_CANCELLED"
end

function DM:Challenge(target)
	StartDuel(target)

	return "CDM_CHALLENGED", {target}
end

function DM:HasDuel()
	return StaticPopup_Visible("DUEL_REQUESTED")
end

function DM:Enable()
	self.Settings.ENABLED = true
	return "CDM_ENABLED"
end

function DM:Disable()
	self.Settings.ENABLED = false
	return "CDM_DISABLED"
end

function DM:Toggle()
	if self:IsEnabled() then
		return self:Disable()
	end
	return self:Enable()
end

function DM:IsEnabled()
	return self.Settings.ENABLED
end

function DM:EnableAnnounce()
	self.Settings.ANNOUNCE = true
	return "CDM_ANNOUNCE_ENABLED"
end

function DM:DisableAnnounce()
	self.Settings.ANNOUNCE = false
	return "CDM_ANNOUNCE_DISABLED"
end

function DM:ToggleAnnounce()
	if self:IsAnnounceEnabled() then
		return self:DisableAnnounce()
	end
	return self:EnableAnnounce()
end

function DM:IsAnnounceEnabled()
	return self.Settings.ANNOUNCE
end

function DM:SetDelay(delay)
	if type(delay) ~= "number" then
		return false, "CDM_DELAY_NUM"
	end
	delay = ceil(delay)
	if delay < 0 or delay > MAX_DELAY then
		return false, "CDM_DELAY_OUTOFRANGE", {MAX_DELAY}
	end
	self.Settings.DELAY = delay
	if self.Settings.DELAY > 0 then
		return "CDM_DELAY_SET", {self.Settings.DELAY}
	end
	return "CDM_DELAY_DISABLED"
end

function DM:GetDelay()
	return self.Settings.DELAY
end

function DM:DisableDelay()
	return DM:SetDelay(0)
end
