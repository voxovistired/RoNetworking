local ReplicatedStorage = game:GetService("ReplicatedStorage");
local Networking = require(ReplicatedStorage:WaitForChild("Modules").Networking);

Networking.Server:RegisterEvent("TestEvent", "REMOTE_FUNCTION", function() 
	return "Testing remote function!";
end);