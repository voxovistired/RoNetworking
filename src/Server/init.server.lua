local ReplicatedStorage = game:GetService("ReplicatedStorage");
local Networking = require(ReplicatedStorage:WaitForChild("Shared").Networking);

Networking.Server:RegisterEvent("TestEvent", "RF", function() 
	return "Testing remote function!";
end);