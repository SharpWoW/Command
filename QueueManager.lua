--[[
	{OUTPUT_LICENSE_SHORT}
--]]

local C = Command

C.QueueManager = {
	QueuedByCommand = false,
	Current = nil,
	Running = false,
	Time = 0,
	LastMode = nil
}

local types = {
	ClassicRandom = {
		Alias = {
			
		}
	}
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
	Zandalari = {
		Alias = {
			"zanda",
			"zandalari",
			"troll",
			"zan"
		},
		Id = 341
	},
	Horseman = {
		Alias = {
			"horseman",
			"headless",
			"headlesshorseman",
			"hallowseve",
			"hallows",
			"hallow",
			"halloweve"
		},
		Id = 285
	}
}

local QM = C.QueueManager

function QM:GetIndex(alias)
	for _,v in pairs(types) do
		for _,d in pairs(v.Alias) do
			if alias:lower() == d then
				return v.Id
			end
		end
	end
	return false
end

function QM:Queue(index)
	_, t, h, d = GetLFGRoles()
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
	return ("Starting queue for %s, please select your role(s)... Type !cancel to cancel."):format(tostring(QM.Current))
end

function QM:Cancel()
	self.QueuedByCommand = false
	LeaveLFG()
	return "Left the LFG queue."
end

function QM:Accept()
	self.QueuedByCommand = false
	AcceptProposal()
	return "Accepted LFG invite."
end

function QM:Announce(_, elapsed)
	self.Time = self.Time + elapsed
	if self.Time >= 0.25 then
		local mode = (select(1, GetLFGMode()))
		if mode ~= nil then self.LastMode = mode end
		print("Last mode set to: " .. tostring(self.LastMode))
		if mode == "queued" then
			Command.ChatManager:SendMessage(("Now queueing for %s, type !cancel to cancel."):format(QM.Current), "PARTY")
		elseif not mode then
			print("LastMode is: " .. tostring(self.LastMode))
			local current = "Role check"
			if self.LastMode ~= "rolecheck" then current = "LFG" end
			Command.ChatManager:SendMessage(current .. " cancelled.", "PARTY")
			self.QueuedByCommand = false
		end
		self.Time = 0
		self.Frame:SetScript("OnUpdate", nil)
		self.Running = false
	end
end

function QM:AnnounceStatus()
	if self.Running then return end
	self.Running = true
	if not self.Frame then self.Frame = CreateFrame("Frame") end
	self.Frame:SetScript("OnUpdate", function(_, elapsed) QM:Announce(_, elapsed) end)
end
