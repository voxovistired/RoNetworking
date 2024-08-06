local ReplicatedStorage = game:GetService("ReplicatedStorage");
local Networking = require(ReplicatedStorage:WaitForChild("Modules").Networking);

local startBench = tick();
print(Networking.Client:FireServer("REMOTE_FUNCTION", "TestEvent"))
print("Time took: " .. tick() - startBench)