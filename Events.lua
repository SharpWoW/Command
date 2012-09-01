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
local SM = C.SummonManager
local IM = C.InviteManager
local RM = C.RoleManager
local CDM = C.DuelManager
local RCM = C.ReadyCheckManager

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
	RCM:OnReadyCheck(tostring(select(1, ...)))
end

function C.Events.READY_CHECK_FINISHED(self, ...)
	RCM:OnReadyCheckEnd()
end

function C.Events.GROUP_ROSTER_UPDATE(self, ...)
	if StaticPopup_Visible("PARTY_INVITE") then
		StaticPopup_Hide("PARTY_INVITE")
	end
	if AC.GroupRunning then return end
	AC:UpdateGroup()
end

function C.Events.PARTY_INVITE_REQUEST(self, ...)
	if not IM.Settings.GROUP.ANNOUNCE then return end
	local sender = (select(1, ...))
	IM:OnGroupInvite(sender)
end

function C.Events.GUILD_INVITE_REQUEST(self, ...)
	if not IM.Settings.GUILD.ANNOUNCE then return end
	local sender = (select(1, ...))
	IM:OnGuildInvite(sender)
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

function C.Events.CONFIRM_SUMMON(self, ...)
	SM:OnSummon()
end

function C.Events.DUEL_REQUESTED(self, ...)
	CDM:OnDuel((select(1, ...)))
end

function C.Events.ROLE_POLL_BEGIN(self, ...)
	RM:OnRoleCheck()
end
