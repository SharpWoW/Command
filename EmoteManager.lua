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
local pairs = pairs

-- API Upvalues
local DoEmote = DoEmote
local IsFlying = IsFlying
local GetUnitSpeed = GetUnitSpeed
local UnitAffectingCombat = UnitAffectingCombat

local C = Command
local L = C.LocaleManager

C.EmoteManager = {
	Emotes = {
		Sit = "sit"
	},
	EmoteValidators = {}
}

local EM = C.EmoteManager

local emoteMapping

EM.EmoteValidators[EM.Emotes.Sit] = function()
	if GetUnitSpeed("player") > 0 then
		return false, "EM_VALIDATOR_ERR_MOVEMENT"
	elseif IsFlying() then
		return false, "EM_VALIDATOR_ERR_FLYING"
	elseif UnitAffectingCombat("player") then
		return false, "EM_VALIDATOR_ERR_COMBAT"
	end
	return true
end

function EM:Init()

end

function EM:HasEmote(emote)
	emote = emote:lower()
	if not emoteMapping then -- Build emote mapping for faster checking
		emoteMapping = {}
		for k,v in pairs(self.Emotes) do
			emoteMapping[v] = k
		end
	end

	return self.Emotes[emoteMapping[emote]] == emote
end

function EM:CanEmote(emote)
	return self.EmoteValidators[emote]()
end

-- Simple wrapper func
function EM:RawDoEmote(emote)
	DoEmote(emote)
end

function EM:DoEmote(emote)
	emote = emote:lower()
	if not self:HasEmote(emote) then
		return false, "EM_ERR_UNKNOWN", {emote}
	end

	local can, err = self:CanEmote(emote)

	if not can then
		return false, "EM_ERR_CANNOT", {L(err)}
	end

	self:RawDoEmote(emote)

	return "EM_SUCCESS", {emote}
end
