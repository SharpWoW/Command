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

--- Table containing all QueueManager methods.
-- This is referenced "QM" in QueueManager.lua.
-- @name Command.QueueManager
-- @class table
-- @field QueuedByCommand True if player has been queued by a command, false otherwise.
-- @field Current The current dungeon for which the group is queued.
-- @field Running True if announce is running, false otherwise.
-- @field Time Total time since Announce was called.
-- @field LastMode Last not-nil value returned by GetLFGMode.
--
C.QueueManager = {
	QueuedByCommand = false,
	Current = nil,
	Running = false,
	Time = 0,
	LastMode = nil,
	Announced = false
}

local QM = C.QueueManager

--- Contains information about various dungeon types.
-- Each entry has an Alias table and an Id field.
-- The Alias table contains names that this dungeon may be referenced by.
-- The Id field is either a number or a function that gives the index for that dungeon type.
-- @name Command.QueueManager.Types
-- @class table
-- @field ClassicRandom Random Classic Dungeon
-- @field TBCRandom Random Burning Crusade Dungeon
-- @field TBCHeroic Random Heroic Burning Crusade Dungeon
-- @field LKRandom Random Wrath of the Lich king Dungeon
-- @field LKHeroic Random Heroic Wrath of the Lich King Dungeon
-- @field CataclysmRandom Random Cataclysm Dungeon
-- @field CataclysmHeroic Random Heroic Cataclysm Dungeon
-- @field Zandalari Random Rise of the Zandalari Dungeon
-- @field Horseman The Headless Horseman Hallow's Eve dungeon
-- @field BestChoice Let the server decide what dungeon is best for the player
--
QM.Types = {
	ClassicRandom = {
		Alias = {
			"classic",
			"vanilla",
			"classicrandom",
			"random"
		},
		Id = 258
	},
	TBCRandom = {
		Alias = {
			"tbc",
			"burningcrusade",
			"tbcrandom",
			"burningcrusaderandom",
			"theburningcrusade",
			"randomtbc"
		},
		Id = 259
	},
	TBCHeroic = {
		Alias = {
			"tbchc",
			"tbcheroic",
			"tbcrandomhc",
			"tbcrandomheroic",
			"randomtbchc",
			"randomtbcheroic"
		},
		Id = 260
	},
	LKRandom = {
		Alias = {
			"lk",
			"wotlk",
			"lkrandom",
			"wotlkrandom",
			"lichking",
			"wrathofthelichking"
		},
		Id = 261
	},
	LKHeroic = {
		Alias = {
			"lkhc",
			"wotlkhc",
			"hclk",
			"hcwotlk",
			"lkhcrandom",
			"hclkrandom",
			"wotlkhcrandom",
			"hcwotlkrandom"
		},
		Id = 262
	},
	CataclysmRandom = {
		Alias = {
			"cata",
			"catanormal",
			"cataclysm"
		},
		Id = 300
	},
	CataclysmHeroic = {
		Alias = {
			"catahc",
			"cataclysmhc",
			"cataheroic",
			"cataclysmheroic",
			"catahcrandom",
			"cataheroicrandom",
			"cataclysmhcrandom",
			"cataclysmheroicrandom"
		},
		Id = 301
	},
	HourOfTwilight = {
		Alias = {
			"twilight",
			"hour",
			"houroftwilight",
			"hourtwilight",
			"twilighthour",
			"twilite",
			"twi",
			"th",
			"hot",
			"ht"
		},
		Id = 434
	},
	Horseman = {
		Alias = {
			"horseman",
			"headless",
			"headlesshorseman",
			"hallowseve",
			"hallows",
			"hallow",
			"halloweve",
			"halloween"
		},
		Id = 285
	},
	BestChoice = {
		Alias = {
			"best",
			"bestchoice",
			"auto",
			"choice"
		},
		Id = function() return GetRandomDungeonBestChoice() end
	}
}

--- Gets the numeric index of a dungoen for use with SetLFGDungeon.
-- @param alias Name/Alias of the dungeon.
-- @return Index of the dungeon if dungeon was found, false otherwise.
--
function QM:GetIndex(alias)
	for _,v in pairs(self.Types) do
		for _,d in pairs(v.Alias) do
			if alias:lower() == d then
				if type(v.Id) == "function" then
					return v.Id()
				end
				return v.Id
			end
		end
	end
	return false
end

--- Queue for the dungeon with supplied index.
-- @param index Index of dungeon to queue for.
-- @return String stating that rolecheck has started.
--
function QM:Queue(index)
	local _, t, h, d = GetLFGRoles()
	if not t and not h and not d then
		d = true
	end
	SetLFGRoles(true, t, h, d)
	SetLFGDungeon(index)
	JoinLFG()
	self.QueuedByCommand = true
	local name = (select(1, GetLFGDungeonInfo(index)))
	HideUIPanel(LFDParentFrame)
	SetCVar("Sound_EnableSFX", 1)
	self.Current = name
	self.Announced = false
	return ("Starting queue for %s, please select your role(s)... Type !cancel to cancel."):format(tostring(QM.Current))
end

--- Cancel the queueing/rolechecking.
-- @return String stating that queue has been cancelled.
--
function QM:Cancel()
	self.QueuedByCommand = false
	self.Announced = false
	LeaveLFG()
	return "Left the LFG queue."
end

--- Causes player to accept a pending LFG invite.
-- @return String stating that the invite was accepted.
--
function QM:Accept()
	self.QueuedByCommand = false
	self.Announced = false
	AcceptProposal()
	return "Accepted LFG invite."
end

--- Announce the current status of LFG to group.
-- @param _ Not used
-- @param elapsed Time elapsed since last time OnUpdate fired.
--
function QM:Announce(_, elapsed)
	self.Time = self.Time + elapsed
	if self.Time >= 0.25 then
		local mode = (select(1, GetLFGMode()))
		if mode ~= nil then self.LastMode = mode end
		if mode == "queued" and not self.Announced then
			Command.ChatManager:SendMessage(("Now queueing for %s, type !cancel to cancel."):format(QM.Current), "PARTY")
			self.Announced = true
		elseif not mode then
			local current = "Role check"
			if self.LastMode ~= "rolecheck" then current = "LFG" end
			Command.ChatManager:SendMessage(current .. " cancelled.", "PARTY")
			self.QueuedByCommand = false
			self.Announced = false
		end
		self.Time = 0
		self.Frame:SetScript("OnUpdate", nil)
		self.Running = false
	end
end

--- Trigger method to announce status.
-- This is because the status of LFG is not available straight after LFG_UPDATE event is fired.
--
function QM:AnnounceStatus()
	if self.Running then return end
	self.Running = true
	if not self.Frame then self.Frame = CreateFrame("Frame") end
	self.Frame:SetScript("OnUpdate", function(_, elapsed) QM:Announce(_, elapsed) end)
end
