local frame = CreateFrame("FRAME", "FailCountFrame");
frame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED");
frame:RegisterEvent("PLAYER_ENTERING_WORLD");
frame:RegisterEvent("PLAYER_REGEN_DISABLED");
frame:RegisterEvent("PLAYER_REGEN_ENABLED");

SLASH_FAILCOUNT1 = '/fc';

spells = {}
fails = {};
currentEncounter = nil;

function printMessage(msg)
	SendChatMessage(msg, "SAY");
end

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
		printFails(msg);
	elseif msg == "total" then
		printTotals();
	else
		print("FailCount encounters");
		for k, v in pairs(fails) do print(k); end
	end
end;

function printTotals()
	local players = {};
	for timestamp, encounter in pairs(fails) do
		for player, failTable in pairs(encounter) do
			if players[player] == nil then
				players[player] = {};
			end
		end
	end
	
	for player,_ in pairs(players) do
		for timestamp, encounter in pairs(fails) do
			for p, failTable in pairs(encounter) do
				if(p==player) then
					for spell, amount in pairs(failTable) do
						if players[player][spell] == nil then
							players[player][spell] = amount
						else
							players[player][spell] = players[player][spell] + amount;
						end
					end
				end
			end
		end
	end
	
	for player, failTable in pairs(players) do
		local failString = "";
		local separator = "";
		for spell, amount in pairs(failTable) do
			failString = failString .. separator .. spell .. ": " .. amount;
			separator = ", ";
		end
		
		printMessage(player .. " " .. failString);
	end
	
end;

function printFails(encounter)
	if encounter and fails[encounter] then
		for player, failTable in pairs(fails[encounter]) do 
			local failString = "";
			local separator = "";
			for spell, amount in pairs(failTable) do
				failString = failString .. separator .. spell .. ": " .. amount;
				separator = ", ";
			end
			
			printMessage(player .. " " .. failString); 
		end
	end
end;

function FailCount_SetUp()
	spells[143701] = "SPELL_AURA_APPLIED"; -- Whirling
	spells[143240] = "SPELL_PERIODIC_DAMAGE"; -- Rapid Fire
	spells[143735] = "SPELL_AURA_APPLIED"; -- Caustic Amber
	spells[143980] = "SPELL_DAMAGE"; -- Vicious Assault
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
	if table.empty(fails[enc]) then
		fails[enc] = nil;
	else
		printFails(enc);
	end;
end;

function table.empty(t)
	for _,_ in pairs(t) do
		return false;
	end
	return true;
end

function FailCount_CombatEvent(Event, ...)
	local timestamp, combatEvent, hideCaster, sourceGUID, sourceName, sourceFlags, sourceRaidFlags, destGUID, destName, destFlags = ...;
	local eventPrefix, eventSuffix = combatEvent:match("^(.-)_?([^_]*)$");
	
	if currentEncounter ~= nil and eventPrefix:match("^SPELL") then
		local spellId, spellName, spellSchool = select(12, ...);	
		if FailCount_IsFail(event, combatEvent, spellId) then
			print(destName .. ": " .. spellName);
			if fails[currentEncounter][destName] == nil then
				fails[currentEncounter][destName] = {};
			end;
			
			if fails[currentEncounter][destName][spellName] ~= nil then
				fails[currentEncounter][destName][spellName] = fails[currentEncounter][destName][spellName]+1;
			else
				fails[currentEncounter][destName][spellName] = 1;
			end
		end
	end
end;

function FailCount_IsFail(event, combatEvent, spellId)
	if spells[spellId] == combatEvent then
		return true;
	end
	return false;
end