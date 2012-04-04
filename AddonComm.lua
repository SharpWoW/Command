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
local wipe = wipe
local pairs = pairs
local ipairs = ipairs
local tostring = tostring
local tonumber = tonumber

local C = Command

local L = C.LocaleManager
local GT = C.GroupTools
local CES = C.Extensions.String
local CET = C.Extensions.Table

local log = C.Logger

C.AddonComm = {
	InGroup = false,
	InGuild = false,
	GroupMaster = true,
	GuildMaster = true,
	GroupChecked = false,
	GuildChecked = false,
	GroupRunning = false,
	GuildRunning = false,
	Type = {
		VersionUpdate = "COMM_VU",
		GroupUpdate = "COMM_GU",
		GroupAdd = "COMM_GA",
		GroupRequest = "COMM_GR",
		GuildUpdate = "COMM_UG",
		GuildAdd = "COMM_AG",
		GuildRequest = "COMM_RG"
	},
	Format = {
		VersionUpdate = "%s"
	},
	GroupMembers = {},
	GuildMembers = {}
}

local AC = C.AddonComm

local CONTROLLER_WAIT = 5

local GroupTimer = CreateFrame("Frame")
local GuildTimer = CreateFrame("Frame")
GroupTimer.Time = 0
GuildTimer.Time = 0

local function GroupTimerUpdate(frame, elapsed)
	frame.Time = frame.Time + elapsed
	if frame.Time >= CONTROLLER_WAIT then
		frame.Time = 0
		AC.GroupRunning = false
		frame:SetScript("OnUpdate", nil)
		log:Normal(L("AC_GROUP_NORESP"))
		AC:UpdateGroup()
	end
end

local function GuildTimerUpdate(frame, elapsed)
	frame.Time = frame.Time + elapsed
	if frame.Time >= CONTROLLER_WAIT then
		frame.Time = 0
		AC.GuildRunning = false
		frame:SetScript("OnUpdate", nil)
		log:Normal(L("AC_GUILD_NORESP"))
		AC:UpdateGuild()
	end
end

function AC:Init()
	--self:LoadSavedVars()
	for _,v in pairs(self.Type) do
		if not RegisterAddonMessagePrefix(v) then
			log:Error(L("AC_ERR_PREFIX"):format(tostring(v)))
			error(L("AC_ERR_PREFIX"):format(tostring(v)))
		end
	end
end

function AC:LoadSavedVars()
	
end

function AC:Receive(msgType, msg, channel, sender)
	if sender == UnitName("player") or not msg then return end
	if msgType == self.Type.VersionUpdate then
		local ver = tonumber(msg)
		if type(ver) ~= "number" then return end
		C:CheckVersion(ver)
	elseif msgType == self.Type.GroupUpdate then
		if channel ~= "RAID" and channel ~= "PARTY" then return end
		if self.GroupRunning then
			GroupTimer:SetScript("OnUpdate", nil)
			GroupTimer.Time = 0
			self.GroupRunning = false
		end
		local t = CES:Split(msg, ";")
		wipe(self.GroupMembers)
		for _,v in ipairs(t) do
			if v then
				table.insert(self.GroupMembers, v)
			end
		end
		log:Debug(L("AC_GROUP_R_UPDATE"):format(self.GroupMembers[1]))
		self:UpdateGroup()
	elseif msgType == self.Type.GroupAdd then
		if channel ~= "WHISPER" or not GT:IsGroup() then return end
		if self.GroupMembers[1] ~= UnitName("player") then return end
		if not CET:HasValue(self.GroupMembers, msg) then
			table.insert(self.GroupMembers, msg)
		end
		self:Send(self.Type.GroupUpdate, table.concat(self.GroupMembers, ";"), "RAID")
	elseif msgType == self.Type.GroupRequest then
		if self.GroupMembers[1] == UnitName("player") or self.GroupMaster then
			self:UpdateGroup()
		end
	elseif msgType == self.Type.GuildUpdate then
		if channel ~= "GUILD" then return end
		if self.GuildRunning then
			GuildTimer:SetScript("OnUpdate", nil)
			GuildTimer.Time = 0
			self.GuildRunning = false
		end
		local t = CES:Split(msg, ";")
		wipe(self.GuildMembers)
		for _,v in ipairs(t) do
			if v then
				table.insert(self.GuildMembers, v)
			end
		end
		log:Debug(L("AC_GUILD_R_UPDATE"):format(self.GuildMembers[1]))
		self:UpdateGuild()
	elseif msgType == self.Type.GuildAdd then
		if channel ~= "WHISPER" then return end
		if self.GuildMembers[1] ~= UnitName("player") then return end
		if not CET:HasValue(self.GuildMembers, msg) then
			table.insert(self.GuildMembers, msg)
		end
		self:Send(self.Type.GuildUpdate, table.concat(self.GuildMembers, ";"), "GUILD")
	elseif msgType == self.Type.GuildRequest then
		if self.GuildMembers[1] == UnitName("player") or self.GuildMaster then
			self:UpdateGuild()
		end
	end
end

function AC:Send(msgType, msg, channel, target)
	channel = channel or "RAID"
	if channel == "RAID" and not GT:IsRaid() then
		if not GT:IsGroup() then return end
		channel = "PARTY"
	end
	if not CET:HasValue(self.Type, msgType) then
		error(L("AC_ERR_MSGTYPE"):format(tostring(msgType)))
		return
	end
	SendAddonMessage(msgType, msg, channel, target)
	if msgType ~= self.Type.VersionUpdate and channel ~= "WHISPER" then
		SendAddonMessage(self.Type.VersionUpdate, self.Format.VersionUpdate:format(C.VersionNum), channel)
	end
end

function AC:UpdateGroup()
	if not GT:IsGroup() then
		if self.InGroup then
			log:Normal(L("AC_GROUP_LEFT"))
		end
		self.InGroup = false
		self.GroupChecked = false
		self.GroupMaster = true
		wipe(self.GroupMembers)
		return
	elseif not self.InGroup then -- Just joined group
		self.GroupMaster = false
		if not self.GroupChecked and not GT:IsGroupLeader() then
			self.GroupChecked = true
			self.GroupRunning = true
			log:Normal(L("AC_GROUP_WAIT"))
			GroupTimer:SetScript("OnUpdate", GroupTimerUpdate)
			self:Send(self.Type.GroupRequest, UnitName("player"), "RAID")
			return
		end
		self.InGroup = true
		if self.GroupMembers[1] == UnitName("player") or not self.GroupMembers[1] then
			self.GroupMaster = true
			self.GroupMembers[1] = UnitName("player")
			self:Send(self.Type.GroupUpdate, table.concat(self.GroupMembers, ";"), "RAID")
		else
			self.GroupMaster = false
			self:CheckGroupMembers()
		end
	else -- Already in group
		self:CheckGroupRoster()
		self:SyncGroup()
		if self.GroupMembers[1] == UnitName("player") then
			self.GroupMaster = true
			self:Send(self.Type.GroupUpdate, table.concat(self.GroupMembers, ";"), "RAID")
		else
			self.GroupMaster = false
			self:CheckGroupMembers()
		end
	end
end

function AC:UpdateGuild()
	if not IsInGuild() then
		self.InGuild = false
		self.GuildChecked = false
		self.GuildMaster = true
		wipe(self.GuildMembers)
		return
	elseif not self.InGuild then -- Probably logged in and is getting guild update for the first time
		self.GuildMaster = false
		if not self.GuildChecked then
			self.GuildChecked = true
			self.GuildRunning = true
			log:Normal(L("AC_GUILD_WAIT"))
			GuildTimer:SetScript("OnUpdate", GuildTimerUpdate)
			return
		end
		self.InGuild = true
		if self.GuildMembers[1] == UnitName("player") or not self.GuildMembers[1] then
			self.GuildMaster = true
			self.GuildMembers[1] = UnitName("player")
			self:Send(self.Type.GuildUpdate, table.concat(self.GuildMembers, ";"), "GUILD")
		else
			self.GuildMaster = false
			self:CheckGuildMembers()
		end
	else -- Already in guild
		self:CheckGuildRoster()
		if self.GuildMembers[1] == UnitName("player") then
			self.GuildMaster = true
			self:Send(self.Type.GuildUpdate, table.concat(self.GuildMembers, ";"), "GUILD")
		else
			self.GuildMaster = false
			self:CheckGuildMembers()
		end
	end
end

function AC:CheckGroupMembers()
	if not CET:HasValue(self.GroupMembers, UnitName("player")) and self.GroupMembers[1] then
		self:Send(self.Type.GroupAdd, UnitName("player"), "WHISPER", self.GroupMembers[1])
	end
end

function AC:CheckGuildMembers()
	if not CET:HasValue(self.GuildMembers, UnitName("player")) and self.GuildMembers[1] then
		self:Send(self.Type.GuildAdd, UnitName("player"), "WHISPER", self.GuildMembers[1])
	end
end

function AC:CheckGroupRoster()
	for i,v in ipairs(self.GroupMembers) do
		if not GT:IsInGroup(v) then
			log:Normal(L("AC_GROUP_REMOVE"):format(v))
			table.remove(self.GroupMembers, i)
			if self.GroupMembers[1] == UnitName("player") then
				self.GroupMaster = true
			end
		end
	end
end

function AC:CheckGuildRoster()
	local g = {}
	for i=1, (select(1, GetNumGuildMembers())) do
		local name = tostring((select(1, GetGuildRosterInfo(i))))
		local online = (select(9, GetGuildRosterInfo(i)))
		g[name] = online
	end
	for i,v in pairs(self.GuildMembers) do
		if not g[v] then
			table.remove(self.GuildMembers, i)
		end
		if self.GuildMembers[1] == UnitName("player") then
			self.GuildMaster = true
		end
	end
end

function AC:SyncGroup()
	if GT:IsInGroup() and GT:IsGroupLeader() then
		if self.GroupMembers[1] ~= UnitName("player") or not self.GroupMaster then
			-- Sync handler table
			log:Normal(L("AC_GROUP_SYNC"))
			wipe(self.GroupMembers)
			self.GroupMembers[1] = UnitName("player")
			self.GroupMaster = true
			self:UpdateGroup()
		end
	end
end

function AC:IsController(channel)
	if channel == "RAID" or channel == "PARTY" then
		self:CheckGroupRoster()
		return self.GroupMembers[1] == UnitName("player")
	elseif channel == "GUILD" then
		self:CheckGuildRoster()
		return self.GuildMembers[1] == UnitName("player")
	end
	return true
end
