local ReplicatedStorage = game:GetService("ReplicatedStorage");
local Networking = require(ReplicatedStorage:WaitForChild("Shared").Networking);

local startBench = tick();
print(Networking.Client:FireServer("TestEvent", "RF"))
print("Time took: " .. tick() - startBench)