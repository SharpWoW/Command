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

-- API Upvalues

local C = Command

C.FactsManager = {
	Facts = {},
	UsedFacts = {}
}

local FM = C.FactsManager
local CM
local CES = C.Extensions.String
local CET = C.Extensions.Table

local factMapping = {}

local FactFormat = "%s fact #%d: %s"

function FM:Init()
	for k,_ in pairs(self.Facts) do
		factMapping[k:lower()] = k
		self.UsedFacts[k] = {}
	end

	CM = C.ChatManager

	self:LoadSavedVars()
end

function FM:LoadSavedVars()
	if type(C.Global["FACTS_MANAGER"]) ~= "table" then
		C.Global["FACTS_MANAGER"] = {}
	end
	self.Settings = C.Global["FACTS_MANAGER"]
	if type(self.Settings.ENABLED) ~= "boolean" then
		self.Settings.ENABLED = true
	end
	if type(self.Settings.NODUPE) ~= "boolean" then
		self.Settings.NODUPE = true
	end
end

function FM:GetFact(topic)
	if topic then -- Specific topic
		if not factMapping[topic] then
			return false, "FM_ERR_TOPIC_NOT_FOUND"
		elseif #self.Facts[factMapping[topic]] == 0 then
			return false, "FM_ERR_TOPIC_EMPTY"
		end
		topic = factMapping[topic]
		if self.Settings.NODUPE then
			if #self.UsedFacts[topic] >= #self.Facts[topic] then
				wipe(self.UsedFacts[topic])
			end
			local index = math.random(1, #self.Facts[topic])
			while self.UsedFacts[topic][index] do
				index = math.random(1, #self.Facts[topic])
			end
			self.UsedFacts[topic][index] = true
			return FactFormat:format(topic, index, self.Facts[topic][index])
		end
		local rand = math.random(1, #self.Facts[topic])
		return FactFormat:format(topic, rand, self.Facts[topic][rand])
	end
	local topicIndex = math.random(1, CET:GetRealLength(self.Facts))
	local topicName
	local i = 1
	for k,_ in pairs(self.Facts) do
		topicName = k
		if i == topicIndex then break end
		i = i + 1
	end
	if not topicName then
		return false, "FM_ERR_NO_TOPIC_FOUND"
	elseif #self.Facts[topicName] == 0 then
		return false, "FM_ERR_TOPIC_EMPTY"
	end
	local factIndex = math.random(1, #self.Facts[topicName])
	return FactFormat:format(topicName, factIndex, self.Facts[topicName][factIndex])
end

function FM:AnnounceFact(topic)
	if not self:IsEnabled() then
		return false, "FM_ERR_DISABLED"
	end

	local fact, err, args = self:GetFact(topic)
	if not fact then
		return false, err, args
	end
	if fact:len() > 250 then
		return CM.SpecialOutput.RawTable, CES:Fit(fact, 240)
	end
	return CM.SpecialOutput.Raw, fact
end

function FM:IsEnabled()
	return self.Settings.ENABLED
end

function FM:Enable()
	self.Settings.ENABLED = true
	return "FM_ENABLED"
end

function FM:Disable()
	self.Settings.ENABLED = false
	return "FM_DISABLED"
end

function FM:Toggle()
	if self:IsEnabled() then
		return self:Disable()
	end
	return self:Enable()
end

function FM:IsNoDupeEnabled()
	return self.Settings.NODUPE
end

function FM:EnableNoDupe()
	self.Settings.NODUPE = true
	return "FM_NODUPE_ENABLED"
end

function FM:DisableNoDupe()
	self.Settings.NODUPE = false
	return "FM_NODUPE_DISABLED"
end

function FM:ToggleNoDupe()
	if self:IsNoDupeEnabled() then
		return self:DisableNoDupe()
	end
	return self:EnableNoDupe()
end
