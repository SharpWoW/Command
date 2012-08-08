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
local floor = floor
local tostring = tostring

-- API Upvalues
local CreateFrame = CreateFrame
local CancelSummon = CancelSummon
local ConfirmSummon = ConfirmSummon
local PlayerCanTeleport = PlayerCanTeleport
local GetSummonConfirmSummoner = GetSummonConfirmSummoner
local GetSummonConfirmAreaName = GetSummonConfirmAreaName
local GetSummonConfirmTimeLeft = GetSummonConfirmTimeLeft

local C = Command

C.SummonManager = {}

local L = C.LocaleManager
local SM = C.SummonManager
local CM

local MAX_TIME = 110 -- 1 minute 50 seconds, summons expire after 2 minutes (usually)

local LastSummoner

function SM:Init()
	CM = C.ChatManager
	LastSummoner = L("UNKNOWN")
	self:LoadSavedVars()
end

function SM:LoadSavedVars()
	if type(C.Global["SUMMON_MANAGER"]) ~= "table" then
		C.Global["SUMMON_MANAGER"] = {}
	end

	self.Settings = C.Global["SUMMON_MANAGER"]

	if type(self.Settings.ENABLED) ~= "boolean" then
		self.Settings.ENABLED = true
	end

	if type(self.Settings.TIME) ~= "number" then
		self.Settings.TIME = 0
	end
end

function SM:OnSummon()
	if self.DelayActive then return end
	if self.Settings.TIME > 0 then
		self.DelayActive = true
		local frame = CreateFrame("Frame")
		frame.Time = 0 -- Current time
		frame.Delay = self.Settings.TIME -- Delay to wait
		frame:SetScript("OnUpdate", function(self, elapsed)
			self.Time = self.Time + elapsed
			if self.Time >= self.Delay then
				self:SetScript("OnUpdate", nil)
				SM.DelayActive = false
				if SM:HasSummon() then SM:Announce() end
			end
		end)
	else
		self:Announce()
	end
end

function SM:Announce()
	if not self:HasSummon() then return end

	local name = GetSummonConfirmSummoner()
	local area = GetSummonConfirmAreaName()
	local left = GetSummonConfirmTimeLeft()

	if left >= 60 then -- Convert to m:s format
		local minutes = floor(left / 60)
		local seconds = tostring(left - minutes * 60)
		if not seconds:match("%d%d") then
			seconds = "0" .. seconds
		end
		left = ("%d:%s"):format(minutes, seconds)
	else
		left = ("%d %s"):format(left, L("SECONDS"):lower())
	end

	if not name or not area or not left then return end

	LastSummoner = name

	CM:SendMessage(L("SM_ONSUMMON"):format(area, name, left), "SMART")
end

function SM:AcceptSummon()
	if not self:HasSummon() then
		return false, "SM_ERR_NOSUMMON"
	end

	ConfirmSummon()

	return "SM_ACCEPTED", {LastSummoner}
end

function SM:DeclineSummon()
	if not self:HasSummon() then
		return false, "SM_ERR_NOSUMMON"
	end

	CancelSummon()

	return "SM_DECLINED", {LastSummoner}
end

function SM:HasSummon()
	return PlayerCanTeleport()
end

function SM:IsEnabled()
	return self.Settings.ENABLED
end

function SM:Enable()
	self.Settings.ENABLED = true
	return "SM_ENABLED"
end

function SM:Disable()
	self.Settings.ENABLED = false
	return "SM_DISABLED"
end

function SM:Toggle()
	if self:IsEnabled() then
		return self:Disable()
	end
	return self:Enable()
end

function SM:GetDelay()
	local total = self:GetRawDelay()
	if total >= 60 then
		local minutes = floor(total / 60)
		local seconds = tostring(total - minutes * 60)
		if not seconds:match("%d%d") then
			seconds = "0" .. seconds
		end
		return ("%d:%s"):format(minutes, seconds)
	end
	return ("%d %s"):format(total, L("SECONDS"))
end

function SM:GetRawDelay()
	return self.Settings.DELAY
end

function SM:SetDelay(amount)
	if amount < 0 then
		amount = 0
	elseif amount > MAX_DELAY then
		amount = MAX_DELAY
	end
	self.Settings.DELAY = amount
	if amount > 0 then
		if amount >= 60 then
			local minutes = floor(amount / 60)
			local seconds = tostring(amount - minutes * 60)
			if not seconds:match("%d%d") then
				seconds = "0" .. seconds
			end
			return "SM_SETDELAY_SUCCESS", {("%d:%s"):format(minutes, seconds)}
		else
			return "SM_SETDELAY_SUCCESS", {("%d %s"):format(amount, L("SECONDS"))}
		end
	end
	return "SM_SETDELAY_INSTANT"
end
