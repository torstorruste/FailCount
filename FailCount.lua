local frame = CreateFrame("FRAME", "FailCountFrame");
frame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED");
frame:RegisterEvent("PLAYER_ENTERING_WORLD");
frame:RegisterEvent("PLAYER_REGEN_DISABLED");
frame:RegisterEvent("PLAYER_REGEN_ENABLED");

SLASH_FAILCOUNT1 = '/fc';

fails = {};
currentEncounter = nil;

function FailCount_OnEvent(self, event, ...)
	print("FailCount: " .. event);
end;
frame:SetScript("OnEvent", FailCount_OnEvent);

function SlashCmdList.FAILCOUNT(msg, editbox)
	print("Fails " .. msg);
	for k, v in pairs(fails) do print(k,v); end
end;

function FailCount_AddFail(player, ability)
	if fails[msg] ~= nil then
		fails[msg] = fails[msg] + 1;
	else
		fails[msg] = 1;
	end
	print(fails[msg]);
end;