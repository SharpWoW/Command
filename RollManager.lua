--[[
	* Copyright (c) 2011 by Adam Hellberg.
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

local RollFormat = "%s rolls %d (%d-%d)" -- Not Used
local RollMatch = "(%w+) rolls (%d+) %((%d+)-(%d+)%)" -- Thanks to ITSBTH for the pattern string

local Rollers = {}
local RollCount = 0

local RollTimer = {}
RollTimer.Frame = CreateFrame("Frame")
RollTimer.Current = 0

local function RollTimerUpdate(_, elapsed)
	if not RM.Running then
		RollTimer.Frame:SetScript("OnUpdate", nil)
	end
	
	RollTimer.Current = RollTimer.Current + elapsed
	
	local left = RollTimer.Time - RollTimer.Current
	if not RollTimer.LastWarning then RollTimer.LastWarning = 0 end
	if (left <= 10 and left > 0) and ceil(RollTimer.Current) - RollTimer.LastWarning >= 5 then
		CM:SendMessage(ceil(left) .. " seconds left to roll!", "SMART")
		RollTimer.LastWarning = ceil(RollTimer.Current)
	end
	
	if RollTimer.Current < RollTimer.Time then return end
	
	RollTimer.Frame:SetScript("OnUpdate", nil)
	RollTimer.Current = 0
	
	RM:StopRoll(true, true)
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
	if type(self.Settings["MIN_ROLL"]) ~= "number" then
		self.Settings["MIN_ROLL"] = 1
	end
	if type(self.Settings["MAX_ROLL"]) ~= "number" then
		self.Settings["MAX_ROLL"] = 100
	end
	if type(self.Settings["DEFAULT_TIME"]) ~= "number" then
		self.Settings["DEFAULT_TIME"] = 20
	end
end

function RM:SetMin(amount)
	if type(amount) ~= "number" then
		return false, "Invalid amount passed: " .. tostring(amount)
	end
	if amount > self.Settings.MAX_ROLL then
		return false, "Minimum roll number cannot be higher than maximum roll number!"
	end
	self.Settings.MIN_ROLL = amount
	return "Sucessfully set minimum roll number to " .. amount .. "!"
end

function RM:SetMax(amount)
	if type(amount) ~= "number" then
		return false, "Invalid amount passed: " .. tostring(amount)
	end
	if amount < self.Settings.MIN_ROLL then
		return false, "Maximum roll number cannot be higher than minimum roll number!"
	end
	self.Settings.MAX_ROLL = amount
	return "Sucessfully set maximum roll number to " .. amount .. "!"
end

function RM:SetTime(amount)
	if type(amount) ~= "number" then
		return false, "Invalid amount passed: " .. tostring(amount)
	end
	if amount <= 0 then
		return false, "Amount must be larger than zero (0)."
	end
	self.Settings.DEFAULT_TIME = amount
	return "Successfully set default roll time to " .. amount .. "!"
end

function RM:StartRoll(sender, item, time)
	time = tonumber(time) or self.Settings.DEFAULT_TIME
	RollTimer.Time = time
	if not sender then
		return false, "Could not identify sender: " .. tostring(sender) .. ". Aborting roll..."
	end
	self.NumGroupMembers = GT:GetNumGroupMembers()
	if self.NumGroupMembers <= 0 then
		return false, "Could not start roll, not enough group members!"
	end
	self.Running = true
	self.Sender = sender
	wipe(Rollers)
	RollCount = 0
	if item then
		self.Item = item
		RollTimer.Frame:SetScript("OnUpdate", RollTimerUpdate)
		return ("%s started a roll for %s, ends in %d seconds! Type /roll %d %d"):format(self.Sender, self.Item, time, self.Settings.MIN_ROLL, self.Settings.MAX_ROLL)
	else
		RollTimer.Frame:SetScript("OnUpdate", RollTimerUpdate)
		return ("%s started a roll, ends in %d seconds! Type /roll %d %d"):format(self.Sender, time, self.Settings.MIN_ROLL, self.Settings.MAX_ROLL)
	end
	-- We shouldn't reach this place
	self.Running = false
	self.Sender = nil
	self.Item = nil
	return false, "Unknown error occurred"
end

function RM:StopRoll(finished, expire)
	
	if finished then
		self:AnnounceResult(expire)
	else
		if not self.Running then
			return false, "No roll is currently in progress!"
		end
	end
	self.Running = false
	self.Sender = nil
	self.Item = nil
	wipe(Rollers)
	return "Roll has been stopped."
end

function RM:DoRoll(min, max)
	min = min or self.Settings.MIN_ROLL
	max = max or self.Settings.MAX_ROLL
	RandomRoll(min, max)
	return "Done! Executed RandomRoll(" .. min .. ", " .. max .. ")"
end

function RM:AddRoll(name, roll)
	if CET:HasKey(Rollers, name) then
		CM:SendMessage(name .. " has already rolled! (" .. Rollers[name] .. ")", "SMART")
		return
	end
	Rollers[name] = tonumber(roll)
	RollCount = RollCount + 1
	CM:SendMessage(("%d/%d players have rolled!"):format(RollCount, self.NumGroupMembers), "SMART")
	if RollCount >= self.NumGroupMembers then RM:StopRoll(true) end
end

function RM:GetTime()
	if self.Running then
		return ("%d seconds remaining!"):format(max(ceil(RollTimer.Time - RollTimer.Current), 0))
	else
		return false, "No roll is currently in progress!"
	end
end

function RM:AnnounceResult(expire)
	if expire then
		CM:SendMessage("Roll time expired! Results...", "SMART")
	else
		CM:SendMessage("Everyone has rolled! Results...", "SMART")
	end
	if RollCount <= 0 then
		CM:SendMessage("Noone rolled, there is no winner!", "SMART")
		return
	end
	local name
	local roll = 0
	local additional = {}
	local numAdditional = 0
	for k,v in pairs(Rollers) do
		if tonumber(v) > roll then
			roll = tonumber(v)
			name = k
			wipe(additional)
			numAdditional = 0
		elseif tonumber(v) == roll then
			additional[k] = tonumber(v)
			numAdditional = numAdditional + 1
		end
	end
	local msg
	if numAdditional <= 0 then
		msg = "The winner is: " .. name .. "! With a roll of " .. roll
		if self.Item then
			msg = msg .. " for " .. self.Item
		end
		msg = msg .. "."
		CM:SendMessage(msg, "SMART")
	else
		msg = "There are multiple winners"
		if self.Item then
			msg = msg .. " for " .. self.Item
		end
		msg = msg .. ":"
		CM:SendMessage(msg, "SMART")
		CM:SendMessage(name .. " with a roll of " .. roll, "SMART")
		for k,v in pairs(additional) do
			CM:SendMessage(k .. " with a roll of " .. v, "SMART")
		end
	end
end

function RM:ParseMessage(msg)
	if not string.match(msg, RollMatch) then return end
	local name, roll, minRoll, maxRoll = msg:match(RollMatch)
	roll = tonumber(roll)
	minRoll = tonumber(minRoll)
	maxRoll = tonumber(maxRoll)
	print(name, roll, minRoll, maxRoll)
	if minRoll ~= self.Settings.MIN_ROLL or maxRoll ~= self.Settings.MAX_ROLL then
		CM:SendMessage(name .. " specified too high or low roll region, not including their roll!", "SMART")
		return
	end
	self:AddRoll(name, roll)
end
