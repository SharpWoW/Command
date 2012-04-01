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

local C = Command
local L = C.LocaleManager
local GT = C.GroupTools
local CM
local CES = C.Extensions.String
local CET = C.Extensions.Table

local log

C.RollManager = {
	Running = false,
	Settings = {}
}

local RM = C.RollManager

local Rollers = {}
local RollCount = 0

local RollTimer = {}
RollTimer.Frame = CreateFrame("Frame")
RollTimer.Current = 0

local function RollTimerUpdate(_, elapsed)
	if not RM.Running then
		RollTimer.Frame:SetScript("OnUpdate", nil)
		RollTimer.LastWarning = 0
		RollTimer.Current = 0
	end
	
	RollTimer.Current = RollTimer.Current + elapsed
	
	local left = RollTimer.Time - RollTimer.Current
	if not RollTimer.LastWarning then RollTimer.LastWarning = 0 end
	if (left <= 10 and left > 0) and ceil(RollTimer.Current) - RollTimer.LastWarning >= 5 then
		CM:SendMessage(L("RM_UPDATE_TIMELEFT"):format(ceil(left)), "SMART")
		RollTimer.LastWarning = ceil(RollTimer.Current)
	end
	
	if RollTimer.Current < RollTimer.Time and RollCount < RM.NumGroupMembers then return end
	
	RollTimer.Frame:SetScript("OnUpdate", nil)
	RollTimer.Current = 0
	RollTimer.LastWarning = 0
	
	RM:StopRoll(true, RollCount < RM.NumGroupMembers)
end

function RM:Init()
	log = C.Logger
	CM = C.ChatManager
	self:LoadSavedVars()
end

function RM:LoadSavedVars()
	if type(C.Global["ROLL_MANAGER"]) ~= "table" then
		C.Global["ROLL_MANAGER"] = {}
	end
	self.Settings = C.Global["ROLL_MANAGER"]
	if type(self.Settings.MIN_ROLL) ~= "number" then
		self.Settings.MIN_ROLL = 1
	end
	if type(self.Settings.MAX_ROLL) ~= "number" then
		self.Settings.MAX_ROLL = 100
	end
	if type(self.Settings.DEFAULT_TIME) ~= "number" then
		self.Settings.DEFAULT_TIME = 20
	end
end

function RM:SetMin(amount)
	if type(amount) ~= "number" then
		return false, "RM_ERR_INVALIDAMOUNT", {tostring(amount)}
	end
	if amount > self.Settings.MAX_ROLL then
		return false, "RM_SET_MINFAIL"
	end
	self.Settings.MIN_ROLL = amount
	return "RM_SET_MINSUCCESS", {amount}
end

function RM:SetMax(amount)
	if type(amount) ~= "number" then
		return false, "PM_ERR_INVALIDAMOUNT", {tostring(amount)}
	end
	if amount < self.Settings.MIN_ROLL then
		return false, "PM_SET_MAXFAIL"
	end
	self.Settings.MAX_ROLL = amount
	return "PM_SET_MAXSUCCESS", {amount}
end

function RM:SetTime(amount)
	if type(amount) ~= "number" then
		return false, "RM_ERR_INVALIDAMOUNT", {tostring(amount)}
	end
	if amount <= 0 then
		return false, "RM_SET_TIMEFAIL"
	end
	self.Settings.DEFAULT_TIME = amount
	return "RM_SET_TIMESUCCESS", {amount}
end

function RM:StartRoll(sender, item, time)
	if RM.Running then
		return false, "RM_START_RUNNING"
	end
	time = tonumber(time) or self.Settings.DEFAULT_TIME
	RollTimer.Time = time
	if not sender then
		return false, "RM_START_SENDER", {tostring(sender)}
	end
	self.NumGroupMembers = GT:GetNumGroupMembers()
	if self.NumGroupMembers <= 0 then
		return false, "RM_START_MEMBERS"
	end
	self.Running = true
	self.Sender = sender
	wipe(Rollers)
	RollCount = 0
	if item then
		self.Item = item
		RollTimer.Frame:SetScript("OnUpdate", RollTimerUpdate)
		return "RM_START_SUCCESSITEM", {self.Sender, self.Item, time, self.Settings.MIN_ROLL, self.Settings.MAX_ROLL}
	else
		RollTimer.Frame:SetScript("OnUpdate", RollTimerUpdate)
		return "RM_START_SUCCESS", {self.Sender, time, self.Settings.MIN_ROLL, self.Settings.MAX_ROLL}
	end
end

function RM:StopRoll(finished, expire)
	if finished then
		self:AnnounceResult(expire)
	else
		if not self.Running then
			return false, "RM_ERR_NOTRUNNING"
		end
	end
	self.Running = false
	self.Sender = nil
	self.Item = nil
	wipe(Rollers)
	return "RM_STOP_SUCCESS"
end

function RM:DoRoll(min, max)
	min = min or self.Settings.MIN_ROLL
	max = max or self.Settings.MAX_ROLL
	RandomRoll(min, max)
	return "RM_DO_SUCCESS", {min, max}
end

function RM:AddRoll(name, roll)
	if CET:HasKey(Rollers, name) then
		CM:SendMessage(L("RM_ROLLEXISTS"):format(name, Rollers[name]), "SMART")
		return
	end
	Rollers[name] = tonumber(roll)
	RollCount = RollCount + 1
	CM:SendMessage(L("RM_ROLLPROGRESS"):format(RollCount, self.NumGroupMembers), "SMART")
end

function RM:PassRoll(name)
	name = name or UnitName("player")
	if CET:HasKey(Rollers, name) then
		return false, "RM_ROLLEXISTS", {name, Rollers[name]}
	end
	Rollers[name] = -1
	RollCount = RollCount + 1
	return "RM_PASS_SUCCESS", {name}
end

function RM:GetTime()
	if self.Running then
		return "RM_TIME_LEFT", {max(ceil(RollTimer.Time - RollTimer.Current), 0)}
	else
		return false, "RM_ERR_NOTRUNNING"
	end
end

function RM:AnnounceResult(expire)
	if expire then
		CM:SendMessage(L("RM_ANNOUNCE_EXPIRE"), "SMART")
	else
		CM:SendMessage(L("RM_ANNOUNCE_FINISH"), "SMART")
	end
	if RollCount <= 0 then
		CM:SendMessage(L("RM_ANNOUNCE_EMPTY"), "SMART")
		return
	end
	local name
	local roll = -1 -- Minimum roll is 0
	local additional = {}
	local numAdditional = 0
	for k,v in pairs(Rollers) do
		local r = tonumber(v)
		if r > roll then
			roll = r
			name = k
			wipe(additional)
		elseif r == roll and r ~= -1 then
			additional[k] = r
			numAdditional = numAdditional + 1
		end
	end
	local msg
	if roll == -1 then
		if self.Item then
			msg = L("RM_ANNOUNCE_PASSITEM"):format(self.Item)
		else
			msg = L("RM_ANNOUNCE_PASS")
		end
		CM:SendMessage(msg, "SMART")
	elseif numAdditional <= 0 then
		if self.Item then
			msg = L("RM_ANNOUNCE_WINITEM"):format(name, roll, self.Item)
		else
			msg = L("RM_ANNOUNCE_WIN"):format(name, roll)
		end
		CM:SendMessage(msg, "SMART")
	else
		if self.Item then
			msg = L("RM_ANNOUNCE_MULTIPLEITEM"):format(self.Item)
		else
			msg = L("RM_ANNOUNCE_MULTIPLE")
		end
		CM:SendMessage(msg, "SMART")
		CM:SendMessage(L("RM_ANNOUNCE_WINNER"):format(name, roll), "SMART")
		for k,v in pairs(additional) do
			CM:SendMessage(L("RM_ANNOUNCE_WINNER"):format(k, v), "SMART")
		end
	end
end

function RM:ParseMessage(msg)
	if not string.match(msg, L("RM_MATCH")) then return end
	local name, roll, minRoll, maxRoll = msg:match(L("RM_MATCH"))
	roll = tonumber(roll)
	minRoll = tonumber(minRoll)
	maxRoll = tonumber(maxRoll)
	print(name, roll, minRoll, maxRoll)
	if minRoll ~= self.Settings.MIN_ROLL or maxRoll ~= self.Settings.MAX_ROLL then
		CM:SendMessage(L("RM_ERR_INVALIDROLL"):format(name), "SMART")
		return
	end
	self:AddRoll(name, roll)
end
