--!native
--!optimize 2
local RemoteListener = {}
RemoteListener.__index = RemoteListener;

local RE: RemoteEvent?;
local RF: RemoteFunction?;
local URE: UnreliableRemoteEvent?;

local function onConnection(Connections: { Connection }, player: Player, Type: RemoteConnection, Name: string, ...): any
    local LocalConnection: any;

    for i = 1, #Connections do
        if (Connections[i].Name == Name and Connections[i].Type == Type) then
            LocalConnection = Connections[i].Callback(player, ...);
        end
    end

    if (Type == "REMOTE_FUNCTION") then
        return LocalConnection;
    end

    return;
end

-- Creates a new RemoteListener
-- size: number is used to detail how many connections can be held at once.
function RemoteListener.new(location: Instance, size: number)
    assert(location, "There is no location present to look for remotes, try again.");
    local self = {};

    RE = location:FindFirstChildOfClass("RemoteEvent") or nil;
    RF = location:FindFirstChildOfClass("RemoteFunction") or nil;
    URE = location:FindFirstAncestorOfClass("UnreliableRemoteEvent") or nil;

    self.Size = size and size or -1;
    self.Connections = {};
    self.Signals = {
        RemoteEvent = RE and RE.OnServerEvent:Connect(function(player, ...) onConnection(self.Connections, player, "REMOTE_EVENT", ...) end);
        UnreliableRemoteEvent = URE and URE.OnServerEvent:Connect(function(player, ...) onConnection(self.Connections, player, "UREMOTE_EVENT",...) end);
    }

    if (RF) then
        RF.OnServerInvoke = function(player, ...) return onConnection(self.Connections, player, "REMOTE_FUNCTION", ...) end;
    end
    setmetatable(self, RemoteListener);
    return self;
end

function RemoteListener:SetConnection(ConnectionName: string, ConnectionType: RemoteConnection, Callback: ( Player, any ) -> ()): Connection | nil
    if (#self.Connections + 1) > self.Size then return end;
    if not (ConnectionName and ConnectionType and Callback) then return end;

    local NewConnection: Connection = {
        Name = ConnectionName;
        Type = ConnectionType;
        Callback = Callback;
    };
    table.insert(self.Connections, table.freeze(NewConnection))

    return NewConnection;
end

function RemoteListener:RemoveConnection(ConnectionName: string, ConnectionType: RemoteConnection): Connection | nil
    local removedConnection: Connection;

    for i = 1, #self.Connections do
        if (self.Connections[i].Name == ConnectionName and self.Connections[i].Type == ConnectionType) then
            removedConnection = self.Connections[i];
            table.clear(self.Connections[i]);
        end
    end

    if removedConnection then
        return removedConnection;
    end
    return;
end

function RemoteListener:Destroy(): nil
    self.Size = 0;
    table.clear(self.Connections);
    
    for i = 1, #self.Signals do
        if self.Signals[i] then
            self.Signals[i].OnServerEvent:Disconnect();
        end
    end

    -- Hate how there is no better alternative to this, but it will do.
    if (RF) then
        RF.OnServerInvoke = function() end;
    end

    return;
end

-- Get a property that is inside of the RemoteListener that you want to get
function RemoteListener:GetProperty(property: string): any
    local success: boolean, response: any = pcall(function()
        return self[property];
    end)

    return success and response or nil;
end

export type Connection = {
    Name: string;
    Type: RemoteConnection;
    Callback: ( Player, any ) -> ( any? );
}
export type RemoteConnection = "REMOTE_EVENT" | "REMOTE_FUNCTION" | "UREMOTE_EVENT";

return RemoteListener;