local RemoteListener = require(script.Modules:FindFirstChild("RemoteListener"));
local Remotes = game:GetService("ReplicatedStorage"):FindFirstChild("Remotes");

local test1 = RemoteListener.new(5, Remotes);

local theConnection: RemoteListener.Connection? = test1:SetConnection("AddPoint", "REMOTE_EVENT", function(player: Player, ...)
    print(`Oh cool! We are adding on a point to {player.Name}`);
end)

print(theConnection);
print(test1:GetProperty("Size"));

task.wait(2);

test1:Destroy();