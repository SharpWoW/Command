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
local select = select
local tostring = tostring

-- API Upvalues
local UnitName = UnitName
local StaticPopup_Hide = StaticPopup_Hide
local GetNumGuildMembers = GetNumGuildMembers
local StaticPopup_Visible = StaticPopup_Visible

local C = Command

local L = C.LocaleManager
local CM = C.ChatManager
local QM = C.QueueManager
local AC = C.AddonComm
local DM = C.DeathManager

--- Event handler for ADDON_LOADED
-- @name Command.Events.ADDON_LOADED
-- @param self Reference to Command object.
-- @param ... Event arguments.
--
function C.Events.ADDON_LOADED(self, ...)
	local name = (select(1, ...))
	if name:lower() ~= self.Name:lower() then return end
	self:Init()
	self.Frame:UnregisterEvent("ADDON_LOADED")
end

--- Event handler for LFG_UPDATE
-- @name Command.Events.LFG_UPDATE
-- @param self Reference to Command object.
-- @param ... Event arguments.
--
function C.Events.LFG_UPDATE(self, ...)
	if not QM.QueuedByCommand then return end
	QM:AnnounceStatus()
end

--- Event handler for LFG_PROPOSAL_SHOW
-- @name Command.Events.LFG_PROPOSAL_SHOW
-- @param self Reference to Command object.
-- @param ... Event arguments.
--
function C.Events.LFG_PROPOSAL_SHOW(self, ...)
	if not QM.QueuedByCommand then return end
	CM:SendMessage(L("E_LFGPROPOSAL"), "PARTY")
end

--- Event handler for LFG_PROPOSAL_FAILED
-- @name Command.Events.LFG_PROPOSAL_FAILED
-- @param self Reference to Command object.
-- @param ... Event arguments.
--
function C.Events.LFG_PROPOSAL_FAILED(self, ...)
	if not QM.QueuedByCommand then return end
	QM.QueuedByCommand = false
	CM:SendMessage(L("E_LFGFAIL"), "PARTY")
end

function C.Events.READY_CHECK(self, ...)
	if C.Data.ReadyCheckRunning then return end
	local name = tostring(select(1, ...))
	if name == UnitName("player") then return end
	C.Data.ReadyCheckRunning = true
	CM:SendMessage(L("E_READYCHECK"):format(name), "SMART")
end

function C.Events.READY_CHECK_FINISHED(self, ...)
	C.Data.ReadyCheckRunning = false
end

function C.Events.RAID_ROSTER_UPDATE(self, ...)
	if AC.GroupRunning then return end
	AC:UpdateGroup()
end

function C.Events.PARTY_INVITE_REQUEST(self, ...)
	if not self.Settings.GROUP_INVITE_ANNOUNCE then return end
	local sender = (select(1, ...))
	local locale = C.PlayerManager:GetOrCreatePlayer(sender).Settings.Locale
	local msg = C.LocaleManager:GetLocale(locale, true)["E_GROUPINVITE"]
	if self.Settings.GROUP_INVITE_ANNOUNCE_DELAY > 0 then
		local f=CreateFrame("Frame")f.T=0;f.L=self.Settings.GROUP_INVITE_ANNOUNCE_DELAY;f.S=sender;f.M=msg
		f:SetScript("OnUpdate",function(s,e)s.T=s.T+e;if(s.T>s.L)then s:SetScript("OnUpdate",nil)if(StaticPopup_Visible("PARTY_INVITE"))then CM:SendMessage(s.M,"WHISPER",s.S)end;end;end)
	else
		CM:SendMessage(msg, "WHISPER", sender)
	end
end

function C.Events.PARTY_MEMBERS_CHANGED(self, ...)
	if StaticPopup_Visible("PARTY_INVITE") then
		StaticPopup_Hide("PARTY_INVITE")
	end
	if AC.GroupRunning then return end
	AC:UpdateGroup()
end

function C.Events.PARTY_LEADER_CHANGED(self, ...)
	if AC.GroupRunning then return end
	AC:UpdateGroup()
end

local numGuildMembers = 0
function C.Events.GUILD_ROSTER_UPDATE(self, ...)
	if AC.GuildRunning then return end
	local _, tmpGuildMembers = GetNumGuildMembers()
	if numGuildMembers ~= tmpGuildMembers then
		numGuildMembers = tmpGuildMembers
		AC:UpdateGuild()
	end
end

function C.Events.PLAYER_DEAD(self, ...)
	DM:OnDeath()
end

function C.Events.RESURRECT_REQUEST(self, ...)
	DM:OnResurrect(select(1, ...))
end

function C.Events.PLAYER_ALIVE(self, ...)
	if not UnitIsDeadOrGhost("player") then return end -- Return if player released to graveyard
	-- Player has accepted a ress before releasing spirit
	DM.Dead = false
	DM.Resurrection = false
end

function C.Events.PLAYER_UNGHOST(self, ...)
	DM.Dead = false
	DM.Resurrection = false
end
