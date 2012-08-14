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
local CreateFrame = CreateFrame
local AcceptGroup = AcceptGroup
local AcceptGuild = AcceptGuild
local DeclineGroup = DeclineGroup
local DeclineGuild = DeclineGuild
local StaticPopup_Show = StaticPopup_Show
local StaticPopup_Hide = StaticPopup_Hide
local StaticPopup_Visible = StaticPopup_Visible
local GetGuildFactionInfo = GetGuildFactionInfo

local C = Command

C.InviteManager = {
	Dialogs = {
		ConfirmGuildOverride = "COMMAND_GUILD_CONFIRM_OVERRIDE"
	}
}

local L = C.LocaleManager
local IM = C.InviteManager
local GT = C.GroupTools
local CM
local PM
local log = C.Logger

local DEFAULT_GROUP_DELAY = 5
local DEFAULT_GUILD_DELAY = 5

local GROUP_MAX_DELAY = 50
local GUILD_MAX_DELAY = 50

-- Static Popup Dialogs
StaticPopupDialogs[IM.Dialogs.ConfirmGuildOverride] = {
	text = "IM_GUILD_CONFIRM_OVERRIDE_POPUP",
	button1 = "YES",
	button2 = "NO",
	OnAccept = function() log:Normal(L(IM:EnableGuildOverride(true))) end,
	OnCancel = function() log:Normal(L(IM:DisableGuildOverride())) end,
	timeout = 20,
	whileDead = true,
	hideOnEscape = false
}

local function CloseGuildInvite()
	local frame = CreateFrame("Frame")
	frame.Time = 0
	frame:SetScript("OnUpdate", function(self, elapsed)
		self.Time = self.Time + elapsed
		if self.Time >= 0.5 then
			self:SetScript("OnUpdate", nil)
			if GuildInviteFrame and GuildInviteFrame:IsShown() then
				GuildInviteFrame:Hide()
			end
		end
	end)
end

function IM:Init()
	CM = C.ChatManager
	PM = C.PlayerManager
	self:LoadSavedVars()
end

function IM:LoadSavedVars()
	if type(C.Global["INVITE_MANAGER"]) ~= "table" then
		C.Global["INVITE_MANAGER"] = {}
	end

	self.Settings = C.Global["INVITE_MANAGER"]

	if type(self.Settings.ENABLED) ~= "boolean" then
		self.Settings.ENABLED = true
	end

	if type(self.Settings.GROUP) ~= "table" then
		self.Settings.GROUP = {}
	end
	if type(self.Settings.GROUP.ENABLED) ~= "boolean" then
		self.Settings.GROUP.ENABLED = true
	end
	if type(self.Settings.GROUP.ANNOUNCE) ~= "boolean" then
		self.Settings.GROUP.ANNOUNCE = true
	end
	if type(self.Settings.GROUP.DELAY) ~= "number" then
		self.Settings.GROUP.DELAY = DEFAULT_GROUP_DELAY
	end

	if type(self.Settings.GUILD) ~= "table" then
		self.Settings.GUILD = {}
	end
	if type(self.Settings.GUILD.ENABLED) ~= "boolean" then
		self.Settings.GUILD.ENABLED = true
	end
	if type(self.Settings.GUILD.ANNOUNCE) ~= "boolean" then
		self.Settings.GUILD.ANNOUNCE = true
	end
	if type(self.Settings.GUILD.DELAY) ~= "number" then
		self.Settings.GUILD.DELAY = DEFAULT_GUILD_DELAY
	end
	if type(self.Settings.GUILD.OVERRIDE) ~= "boolean" then
		self.Settings.GUILD.OVERRIDE = false
	end
end

function IM:OnGroupInvite(sender)
	if self.Settings.GROUP.DELAY > 0 then
		local frame = CreateFrame("Frame")
		frame.Time = 0
		frame.Delay = self.Settings.GROUP.DELAY
		frame.Sender = sender
		frame:SetScript("OnUpdate", function(self, elapsed)
			self.Time = self.Time + elapsed
			if self.Time >= self.Delay then
				self:SetScript("OnUpdate", nil)
				IM:AnnounceGroupInvite(self.Sender)
			end
		end)
	else
		self:AnnounceGroupInvite(sender)
	end
end

function IM:OnGuildInvite(sender)
	if self.Settings.GROUP.DELAY > 0 then
		local frame = CreateFrame("Frame")
		frame.Time = 0
		frame.Delay = self.Settings.GUILD.DELAY
		frame.Sender = sender
		frame:SetScript("OnUpdate", function(self, elapsed)
			self.Time = self.Time + elapsed
			if self.Time >= self.Delay then
				self:SetScript("OnUpdate", nil)
				IM:AnnounceGuildInvite(self.Sender)
			end
		end)
	else
		self:AnnounceGuildInvite(sender)
	end
end

function IM:AnnounceGroupInvite(sender)
	if not self:HasGroupInvite() then return end
	local locale = PM:GetOrCreatePlayer(sender).Settings.Locale
	local msg = L(locale, "IM_GROUP_ANNOUNCE", true)
	CM:SendMessage(msg, "WHISPER", sender)
end

function IM:AnnounceGuildInvite(sender)
	if not self:HasGuildInvite() then return end
	local locale = PM:GetOrCreatePlayer(sender).Settings.Locale
	local msg = L(locale, "IM_GUILD_ANNOUNCE", true)
	CM:SendMessage(msg, "WHISPER", sender)
end

function IM:AcceptGroupInvite()
	if not self:HasGroupInvite() then
		return false, "IM_GROUP_NOINVITE"
	end

	AcceptGroup()

	if StaticPopup_Visible("PARTY_INVTIE") then
		StaticPopup_Hide("PARTY_INVITE")
	end

	return "IM_GROUP_ACCEPTED"
end

function IM:DeclineGroupInvite()
	if not self:HasGroupInvite() then
		return false, "IM_GROUP_NOINVITE"
	end

	DeclineGroup()

	if StaticPopup_Visible("PARTY_INVTIE") then
		StaticPopup_Hide("PARTY_INVITE")
	end

	return "IM_GROUP_DECLINED"
end

function IM:AcceptGuildInvite()
	if not self:HasGuildInvite() then
		return false, "IM_GUILD_NOINVITE"
	elseif self:HasGuildRep() and not self:IsGuildOverrideEnabled() then
		return false, "IM_GUILD_HASREP"
	end

	AcceptGuild()

	CloseGuildInvite()

	return "IM_GUILD_ACCEPTED"
end

function IM:DeclineGuildInvite()
	if not self:HasGuildInvite() then
		return false, "IM_GUILD_NOINVITE"
	end

	DeclineGuild()

	CloseGuildInvite()

	return "IM_GUILD_DECLINED"
end

function IM:HasGroupInvite()
	return StaticPopup_Visible("PARTY_INVITE")
end

function IM:HasGuildInvite()
	return GuildInviteFrame and GuildInviteFrame:IsShown()
end

function IM:HasGuildRep()
	local _, _, standingID, _, _, value = GetGuildFactionInfo()
	if value > 0 or standingID ~= 4 then -- More than 0 rep or higher than Neutral status
		return true
	end
	return false
end

function IM:Enable()
	self.Settings.ENABLED = true
	return "IM_ENABLED"
end

function IM:Disable()
	self.Settings.ENABLED = false
	return "IM_DISABLED"
end

function IM:Toggle()
	if self:IsEnabled() then
		return self:Disable()
	end
	return self:Enable()
end

function IM:IsEnabled()
	return self.Settings.ENABLED
end

function IM:EnableGroup()
	self.Settings.GROUP.ENABLED = true
	return "IM_GROUP_ENABLED"
end

function IM:DisableGroup()
	self.Settings.GROUP.ENABLED = false
	return "IM_GROUP_DISABLED"
end

function IM:ToggleGroup()
	if self:IsGroupEnabled() then
		return self:DisableGroup()
	end
	return self:EnableGroup()
end

function IM:IsGroupEnabled()
	return self.Settings.GROUP.ENABLED
end

function IM:EnableGroupAnnounce()
	self.Settings.GROUP.ANNOUNCE = true
	return "IM_GROUPANNOUNCE_ENABLED"
end

function IM:DisableGroupAnnounce()
	self.Settings.GROUP.ANNOUNCE = false
	return "IM_GROUPANNOUNCE_DISABLED"
end

function IM:ToggleGroupAnnounce()
	if self:IsGroupAnnounceEnabled() then
		return self:DisableGroupAnnounce()
	end
	return self:EnableGroupAnnounce()
end

function IM:IsGroupAnnounceEnabled()
	return self.Settings.GROUP.ANNOUNCE
end

function IM:SetGroupDelay(delay)
	if type(delay) ~= "number" then
		return false, "IM_GROUPDELAY_NUM"
	end
	delay = ceil(delay)
	if delay < 0 or delay > GROUP_MAX_DELAY then
		return false, "IM_GROUPDELAY_OUTOFRANGE", {GROUP_MAX_DELAY}
	end
	self.Settings.GROUP.DELAY = delay
	if self.Settings.GROUP.DELAY > 0 then
		return "IM_GROUPDELAY_SET", {self.Settings.GROUP.DELAY}
	end
	return "IM_GROUPDELAY_DISABLED"
end

function IM:GetGroupDelay()
	return self.Settings.GROUP.DELAY
end

function IM:DisableGroupDelay()
	return self:SetGroupDelay(0)
end

function IM:EnableGuild()
	self.Settings.GUILD.ENABLED = true
	return "IM_GUILD_ENABLED"
end

function IM:DisableGuild()
	self.Settings.GUILD.ENABLED = false
	return "IM_GUILD_DISABLED"
end

function IM:ToggleGuild()
	if self:IsGuildEnabled() then
		return self:DisableGuild()
	end
	return self:EnableGuild()
end

function IM:IsGuildEnabled()
	return self.Settings.GUILD.ENABLED
end

function IM:EnableGuildAnnounce()
	self.Settings.GUILD.ANNOUNCE = true
	return "IM_GUILDANNOUNCE_ENABLED"
end

function IM:DisableGuildAnnounce()
	self.Settings.GUILD.ANNOUNCE = false
	return "IM_GUILDANNOUNCE_DISABLED"
end

function IM:ToggleGuildAnnounce()
	if self:IsGuildAnnounceEnabled() then
		return self:DisableGuildAnnounce()
	end
	return self.EnableGuildAnnounce()
end

function IM:IsGuildAnnounceEnabled()
	return self.Settings.GUILD.ANNOUNCE
end

function IM:EnableGuildOverride(confirm)
	if StaticPopup_Visible(self.Dialogs.ConfirmGuildOverride) and not confirm then
		return false, "IM_GUILDOVERRIDE_PENDING"
	end
	if not confirm then
		StaticPopupDialogs[self.Dialogs.ConfirmGuildOverride].text = L("IM_GUILD_CONFIRM_OVERRIDE_POPUP")
		StaticPopupDialogs[self.Dialogs.ConfirmGuildOverride].button1 = L("YES")
		StaticPopupDialogs[self.Dialogs.ConfirmGuildOverride].button2 = L("NO")
		StaticPopup_Show(self.Dialogs.ConfirmGuildOverride)
		return "IM_GUILDOVERRIDE_WAITING"
	end
	if StaticPopup_Visible(self.Dialogs.ConfirmGuildOverride) then
		StaticPopup_Hide(self.Dialogs.ConfirmGuildOverride)
	end
	self.Settings.GUILD.OVERRIDE = true
	return "IM_GUILDOVERRIDE_ENABLED"
end

function IM:DisableGuildOverride()
	if StaticPopup_Visible(self.Dialogs.ConfirmGuildOverride) then
		return false, "IM_GUILDOVERRIDE_PENDING"
	end
	self.Settings.GUILD.OVERRIDE = false
	return "IM_GUILDOVERRIDE_DISABLED"
end

function IM:ToggleGuildOverride()
	if self:IsGuildOverrideEnabled() then
		return self:DisableGuildOverride()
	end
	return self:EnableGuildOverride()
end

function IM:IsGuildOverrideEnabled()
	return self.Settings.GUILD.OVERRIDE
end

function IM:SetGuildDelay(delay)
	if type(delay) ~= "number" then
		return false, "IM_GUILDDELAY_NUM"
	end
	delay = ceil(delay)
	if delay < 0 or delay > GUILD_MAX_DELAY then
		return false, "IM_GUILDDELAY_OUTOFRANGE", {GUILD_MAX_DELAY}
	end
	self.Settings.GUILD.DELAY = delay
	if self.Settings.GUILD.DELAY > 0 then
		return "IM_GUILDDELAY_SET", {self.Settings.GUILD.DELAY}
	end
	return "IM_GUILDDELAY_DISABLED"
end

function IM:GetGuildDelay()
	return self.Settings.GUILD.DELAY
end

function IM:DisableGuildDelay()
	return self:SetGuildDelay(0)
end
