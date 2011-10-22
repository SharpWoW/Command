--[[
	{OUTPUT_LICENSE_SHORT}
--]]

local C = Command

C.ChatManager = {
	Settings = {},
	Default = {
		CmdChar = "!",
		LocalOnly = false
	}
}

local CM = C.ChatManager
local PM = C.PlayerManager
local CCM = C.CommandManager
local CES = C.Extensions.String

function CM:GetRespondChannelByEvent(event)
	local respondChannel = "SAY"
	if event == "CHAT_MSG_BATTLEGROUND" then
		respondChannel = "BATTLEGROUND"
	elseif event == "CHAT_MSG_BATTLEGROUND_LEADER" then
		respondChannel = "BATTLEGROUND"
	elseif event == "CHAT_MSG_CHANNEL" then
		respondChannel = "CHANNEL"
	elseif event == "CHAT_MSG_GUILD" then
		respondChannel = "WHISPER"
	elseif event == "CHAT_MSG_OFFICER" then
		respondChannel = "WHISPER"
	elseif event == "CHAT_MSG_PARTY" then
		respondChannel = "PARTY"
	elseif event == "CHAT_MSG_PARTY_LEADER" then
		respondChannel = "PARTY"
	elseif event == "CHAT_MSG_RAID" then
		respondChannel = "RAID"
	elseif event == "CHAT_MSG_RAID_LEADER" then
		respondChannel = "RAID"
	elseif event == "CHAT_MSG_RAID_WARNING" then
		if GT:IsRaidLeaderOrAssistant() then
			respondChannel = "RAID_WARNING"
		else
			respondChannel = "RAID"
		end
	elseif event == "CHAT_MSG_SAY"then
		respondChannel = "SAY"
	elseif event == "CHAT_MSG_WHISPER" then
		respondChannel = "WHISPER"
	elseif event == "CHAT_MSG_YELL" then
		respondChannel = "YELL"
	end
	return respondChannel
end

function CM:Init()
	self:LoadSavedVars()
end

function CM:LoadSavedVars()
	if type(C.Settings.CHAT) ~= "table" then
		C.Settings.CHAT = {}
	end
	self.Settings = C.Settings.CHAT
	if type(self.Settings.CMD_CHAR) ~= "string" then
		self.Settings.CMD_CHAR = self.Default.CmdChar
	end
	if type(self.Settings.LOCAL_ONLY) ~= "boolean" then
		self.Settings.LOCAL_ONLY = self.Default.LocalOnly
	end
end

function CM:SendMessage(msg, channel, target)
	if not self.Settings.LOCAL_ONLY then
		msg = ("[%s] %s"):format(C.Name, msg)
		SendChatMessage(msg, channel, nil, target)
	else
		C.Logger:Normal(msg)
	end
end

function CM:ParseMessage(msg)
	return CES:Split(msg)
end

function CM:ParseCommand(cmd)
	return cmd:sub(2, cmd:len())
end

function CM:IsCommand(msg)
	return CES:StartsWith(msg, self.Settings.CMD_CHAR)
end

function CM:HandleMessage(msg, sender, channel, target, isBN)
	isBN = isBN or false
	target = target or sender
	if isBN then
		C.Logger:Normal("Battle.Net convos/whispers are not supported yet")
		return
	end
	msg = CES:Trim(msg)
	local args = self:ParseMessage(msg)
	if not self:IsCommand(args[1]) then return end
	local cmd = self:ParseCommand(args[1])
	local t = {}
	if #args > 1 then
		for i=2,#args do
			table.insert(t, args[i])
		end
	end
	local player = PM:GetOrCreatePlayer(sender)
	local result, err = CCM:HandleCommand(cmd, t, true, player)
	if result then
		self:SendMessage(tostring(result), channel, target)
	else
		self:SendMessage(tostring(err), "WHISPER", sender)
	end
end
