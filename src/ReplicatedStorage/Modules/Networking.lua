--!native
--!optimize 2
local Network = {};

-- Services
local RunService = game:GetService("RunService");

-- Variables
local EventRegistry: { [RemoteEnum]: { [string]: (any) -> any?} } = {
	["REMOTE_EVENT"] = {};
	["REMOTE_FUNCTION"] = {};
	["UREMOTE_EVENT"] = {};	
};

-- Enums.
type RemoteEnum = "REMOTE_EVENT" | "REMOTE_FUNCTION" | "UREMOTE_EVENT";

-- Functions
-- Access various different remotes.
local function getRE(): RemoteEvent
	local r: RemoteEvent = script:FindFirstChild("RE");
	if (r == nil) then
		r = Instance.new("RemoteEvent");
		r.Name = "RE";
		r.Parent = script;
	end
	return r;
end
local function getRF(): RemoteFunction
	local r: RemoteFunction = script:FindFirstChild("RF");
	if (r == nil) then
		r = Instance.new("RemoteFunction");
		r.Name = "RF";
		r.Parent = script;
	end
	return r;
end
local function getURE(): UnreliableRemoteEvent
	local r: UnreliableRemoteEvent = script:FindFirstChild("URE");
	if (r == nil) then
		r = Instance.new("UnreliableRemoteEvent");
		r.Name = "URE";
		r.Parent = script;
	end
	return r;
end

-- Create subdirectories for client and server.
if (RunService:IsClient()) then
	Network.Client = {};
	local function onEventReached(name: string, rType: RemoteEnum, ...)
		if not (EventRegistry[rType][name]) then return end;

		local success: boolean, response: any = pcall(EventRegistry[rType][name], ...);
		if not (success) then
			warn(`[Client/Network] Issue with event {name} with response of: {response}`);
		end

		if (rType == "REMOTE_FUNCTION") then
			return success and response or nil;
		end
	end

	-- Setup listeners.
	getRE().OnClientEvent:Connect(onEventReached);
	getURE().OnClientEvent:Connect(onEventReached);
	getRF().OnClientInvoke = onEventReached;

	-- Client Network methods.
	function Network.Client:RegisterEvent(name: string, rType: RemoteEnum, handler: (any) -> any?)
		EventRegistry[rType][name] = handler;
	end

	function Network.Client:FireServer(rType: RemoteEnum, name: string, ...)
		if (rType == "REMOTE_EVENT") then
			getRE():FireServer(name, rType, ...);
		elseif (rType == "UREMOTE_EVENT") then
			getURE():FireServer(name, rType, ...);
		elseif (rType == "REMOTE_FUNCTION") then
			return getRF():InvokeServer(name, rType, ...);
		end
	end
else
	Network.Server = {};
	local function onEventReached(plr: Player, name: string, rType: RemoteEnum, ...)
		if not (EventRegistry[rType][name]) then return end;

		local success: boolean, response: any = pcall(EventRegistry[rType][name], plr, ...);
		if not (success) then
			warn(`[Server/Network] Issue with event {name} with response of: {response}`);
		end

		if (rType == "REMOTE_FUNCTION") then
			return success and response or nil;
		end
	end

	-- Setup listeners.
	getRE().OnServerEvent:Connect(onEventReached);
	getURE().OnServerEvent:Connect(onEventReached);
	getRF().OnServerInvoke = onEventReached;

	-- Server Network methods.
	function Network.Server:RegisterEvent(name: string, rType: RemoteEnum, handler: (any) -> any?)
		EventRegistry[rType][name] = handler;
		print(EventRegistry)
	end

	function Network.Server:FireActor(plr: Player, name: string, rType: RemoteEnum, ...)
		if (rType == "REMOTE_EVENT") then
			getRE():FireClient(plr, name, rType, ...);
		elseif (rType == "UREMOTE_EVENT") then
			getURE():FireClient(plr, name, rType, ...);
		elseif (rType == "REMOTE_FUNCTION") then
			return getRF():InvokeClient(plr, name, rType, ...);
		end
	end

	function Network.Server:FireAllActors(name: string, rType: RemoteEnum, ...)
		if (rType == "REMOTE_FUNCTION") then return end;
		if (rType == "REMOTE_EVENT") then
			getRE():FireAllClients(name, rType, ...);
		elseif (rType == "UREMOTE_EVENT") then
			getURE():FireAllClients(name, rType, ...);
		end
	end
end

return Network;