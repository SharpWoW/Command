--[[
	{OUTPUT_LICENSE_SHORT}
--]]

local C = Command
local CES = C.Extensions.String

function C:OnEvent(frame, event, ...)
	if not self.Events[event] then return end
	if CES:StartsWith(event, "CHAT_MSG_") then
		self.Events[event](self, event, ...)
	else
		self.Events[event](self, ...)
	end
end

C.Frame = CreateFrame("Frame")
for k,_ in pairs(C.Events) do
	C.Frame:RegisterEvent(k)
	C.Logger:Debug(("%q registered."):format(k))
end
C.Frame:SetScript("OnEvent", function(frame, event, ...) C:OnEvent(frame, event, ...) end)
