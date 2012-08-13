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
local floor = math.floor
local tostring = tostring

-- API Upvalues
local CreateFrame = CreateFrame
local CancelSummon = CancelSummon
local ConfirmSummon = ConfirmSummon
local StaticPopup_Hide = StaticPopup_Hide
local StaticPopup_Visible = StaticPopup_Visible
local GetSummonConfirmSummoner = GetSummonConfirmSummoner
local GetSummonConfirmAreaName = GetSummonConfirmAreaName
local GetSummonConfirmTimeLeft = GetSummonConfirmTimeLeft


local C = Command

C.SummonManager = {}

local L = C.LocaleManager
local SM = C.SummonManager
local CM
local GT = C.GroupTools

local MAX_DELAY = 110 -- 1 minute 50 seconds, summons expire after 2 minutes (usually)

local LastSummoner

local function FormatSeconds(seconds)
	-- Return plain seconds if less than 60 seconds
	if seconds < 60 then return ("%d %s"):format(seconds, L("SECONDS"):lower()) end
	local minutes = floor(seconds / 60) -- Get number of minutes
	local secs = tostring(seconds - minutes * 60) -- Get number of remaining seconds
	if not secs:match("%d%d") then -- Check if seconds > 9
		secs = "0" .. secs -- Prefix a zero to make it look better
	end
	return ("%d:%s"):format(minutes, secs) -- Return in m:ss format
end

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

	if not name or not area or not left or left <= 0 then return end

	left = FormatSeconds(left)

	LastSummoner = name

	local channel = "SMART"
	if not GT:IsGroup() then channel = "WHISPER" end
	CM:SendMessage(L("SM_ONSUMMON"):format(area, name, left), channel, name)
end

function SM:AcceptSummon()
	if not self:HasSummon() then
		return false, "SM_ERR_NOSUMMON"
	end

	ConfirmSummon()

	if StaticPopup_Visible("CONFIRM_SUMMON") then
		StaticPopup_Hide("CONFIRM_SUMMON")
	end

	return "SM_ACCEPTED", {LastSummoner}
end

function SM:DeclineSummon()
	if not self:HasSummon() then
		return false, "SM_ERR_NOSUMMON"
	end

	CancelSummon()

	if StaticPopup_Visible("CONFIRM_SUMMON") then
		StaticPopup_Hide("CONFIRM_SUMMON")
	end

	return "SM_DECLINED", {LastSummoner}
end

function SM:HasSummon()
	return GetSummonConfirmTimeLeft() > 0
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
	return FormatSeconds(self:GetRawDelay())
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
		return "SM_SETDELAY_SUCCESS", {FormatSeconds(amount)}
	end
	return "SM_SETDELAY_INSTANT"
end
