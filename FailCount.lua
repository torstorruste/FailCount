SLASH_FAILCOUNT1 = '/fc';

function FailCount_OnLoad()
	print("FailCount initiating");
end

function SlashCmdList.FAILCOUNT(msg, editbox)
	print("FAILSLASH " .. msg);
end;