local frame = CreateFrame("FRAME", "FailCountFrame");
frame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED");
frame:RegisterEvent("PLAYER_ENTERING_WORLD");
frame:RegisterEvent("PLAYER_REGEN_DISABLED");
frame:RegisterEvent("PLAYER_REGEN_ENABLED");

SLASH_FAILCOUNT1 = '/fc';

spells = {}
fails = {};
currentEncounter = nil;

function FailCount_OnEvent(self, event, ...)
	if event == "PLAYER_REGEN_DISABLED" then
		FailCount_StartCombat(event, ...);
	elseif event == "PLAYER_REGEN_ENABLED" then
		FailCount_EndCombat(event, ...);
	elseif currentEncounter ~= nil then
		FailCount_CombatEvent(Event, ...);
	else
		FailCount_SetUp();
	end
end;
frame:SetScript("OnEvent", FailCount_OnEvent);

function SlashCmdList.FAILCOUNT(msg, editbox)
	if msg and fails[msg] then
		for k, v in pairs(fails[msg]) do print(k, v); end
	else
		for k, v in pairs(fails) do print(k); end
	end
end;

function printFails(encounter)
	for k, v in pairs(fails[encounter]) do print(k,v); end
end;

function FailCount_AddFail(player, ability)
	if fails[msg] ~= nil then
		fails[msg] = fails[msg] + 1;
	else
		fails[msg] = 1;
	end
	print(fails[msg]);
end;

function FailCount_SetUp()
	spells[100780] = "Jab";
end;

function FailCount_StartCombat(event, ...)
	print("Starting combat at " .. date("%H:%M:%S"));
	currentEncounter = date("%H:%M:%S");
	fails[currentEncounter] = {};
end;

function FailCount_EndCombat(event, ...)
	print("Ending combat at " .. date("%H:%M:%S"));
	local enc = currentEncounter;
	currentEncounter = nil;
	printFails(enc);
end;

function FailCount_CombatEvent(Event, ...)
	local timestamp, combatEvent, hideCaster, sourceGUID, sourceName, sourceFlags, destGUID, destName, destFlags = ...;
	local eventPrefix, eventSuffix = combatEvent:match("^(.-)_?([^_]*)$");
	
	if currentEncounter ~= nil and eventPrefix:match("^SPELL") then
		local spellId, spellName, spellSchool = select(12, ...);
		
		print(spellId .. ": " .. spellName);
	
		if spells[spellId] then
			if fails[currentEncounter][sourceName] ~= nil then
				fails[currentEncounter][sourceName] = fails[currentEncounter][sourceName]+1;
			else
				fails[currentEncounter][sourceName] = 1;
			end
		end
	end
end;