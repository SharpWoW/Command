--[[
	{OUTPUT_LICENSE_SHORT}
--]]

local C = Command

local CM = C.ChatManager
local QM = C.QueueManager

--[[
function T.Events.CHAT_MSG_ADDON(event, ...)
	
end
--]]

function C.Events.ADDON_LOADED(self, ...)
	local name = (select(1, ...))
	if name:lower() ~= self.Name:lower() then return end
	self:Init()
end

function C.Events.LFG_UPDATE(self, ...)
	if not QM.QueuedByCommand then return end
	QM:AnnounceStatus()
end

function C.Events.LFG_PROPOSAL_SHOW(self, ...)
	if not QM.QueuedByCommand then return end
	CM:SendMessage("Group has been found, type !accept to make me accept the invite.", "PARTY")
end

function C.Events.LFG_PROPOSAL_FAILED(self, ...)
	if not QM.QueuedByCommand then return end
	QM.QueuedByCommand = false
	CM:SendMessage("LFG failed, use !queue <type> to requeue.", "PARTY")
end
