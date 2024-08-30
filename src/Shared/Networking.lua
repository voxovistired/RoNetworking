--!native
--!optimize 2
local Network = {};

-- Services
local RunService = game:GetService("RunService");

-- Variables
local EventRegistry: { [RemoteEnum]: { [string]: (any) -> any? } } = {
	["RE"] = {};
	["RF"] = {};
	["URE"] = {};	
};

-- Enums
type RemoteEnum = "RE" | "RF" | "URE";

-- Helper Functions
local function getRE(): RemoteEvent
	local r: RemoteEvent = script:FindFirstChild("RE");
	if (r == nil) then
		if (RunService:IsClient()) then
			r = script:WaitForChild("RE", 15)
		else
			r = Instance.new("RemoteEvent");
			r.Name = "RE";
			r.Parent = script;
		end
	end
	return r;
end
local function getRF(): RemoteFunction
	local r: RemoteFunction = script:FindFirstChild("RF");
	if (r == nil) then
		if (RunService:IsClient()) then
			r = script:WaitForChild("RF", 15)
		else
			r = Instance.new("RemoteFunction");
			r.Name = "RF";
			r.Parent = script;
		end
	end
	return r;
end
local function getURE(): UnreliableRemoteEvent
	local r: UnreliableRemoteEvent = script:FindFirstChild("URE");
	if (r == nil) then
		if (RunService:IsClient()) then
			r = script:WaitForChild("URE", 15)
		else
			r = Instance.new("UnreliableRemoteEvent");
			r.Name = "URE";
			r.Parent = script;
		end	
	end
	return r;
end

-- Create subdirectories for client and server.
if (RunService:IsClient()) then
	Network.Client = {};
	local function onEventReached(headerBuf: buffer, ...)
		local _header: { string } = buffer.tostring(headerBuf):split("::");
		local _event: (any) -> any? = EventRegistry[_header[2]][_header[1]];
		if not (_event) then return end;

		local success: boolean, response: any = pcall(_event, ...);
		if not (success) then
			warn(`[Client/Network] Issue with event {_header[1]} with response of: {response}`);
		end

		return success and response or nil;
	end

	-- Setup listeners.
	getRE().OnClientEvent:Connect(onEventReached);
	getURE().OnClientEvent:Connect(onEventReached);
	getRF().OnClientInvoke = onEventReached;

	-- Client Network methods.
	function Network.Client:RegisterEvent(name: string, rType: RemoteEnum, handler: (any) -> any?)
		EventRegistry[rType][name] = handler;
	end

	function Network.Client:FireServer(name: string, rType: RemoteEnum, ...)
		local _headerBuf: buffer = buffer.fromstring(name .. '::' .. rType);
		if (rType == "RE") then
			getRE():FireServer(_headerBuf, ...);
		elseif (rType == "URE") then
			getURE():FireServer(_headerBuf, ...);
		elseif (rType == "RF") then
			return getRF():InvokeServer(_headerBuf, ...);
		end
		return;
	end
	
	if (RunService:IsStudio()) then
		print(`[Client/Network] Initialized Network.`);
	end
else
	Network.Server = {};
	local function onEventReached(plr: Player, headerBuf: buffer, ...)
		local _header: { string } = buffer.tostring(headerBuf):split("::");
		local _event: (any) -> any? = EventRegistry[_header[2]][_header[1]];
		if not (_event) then return end;

		local success: boolean, response: any = pcall(_event, plr, ...);
		if not (success) then
			warn(`[Server/Network] Issue with event {_header[1]} with response of: {response}`);
		end

		return success and response or nil;
	end

	-- Setup listeners.
	getRE().OnServerEvent:Connect(onEventReached);
	getURE().OnServerEvent:Connect(onEventReached);
	getRF().OnServerInvoke = onEventReached;

	-- Server Network methods.
	function Network.Server:RegisterEvent(name: string, rType: RemoteEnum, handler: (any) -> any?)
		EventRegistry[rType][name] = handler;
	end

	function Network.Server:FireActor(plr: Player, name: string, rType: RemoteEnum, ...)
		local _headerBuf: buffer = buffer.fromstring(name .. '::' .. rType);
		if (rType == "RE") then
			getRE():FireClient(plr, _headerBuf, ...);
		elseif (rType == "URE") then
			getURE():FireClient(plr, _headerBuf, ...);
		elseif (rType == "RF") then
			return getRF():InvokeClient(plr, _headerBuf, ...);
		end
		return;
	end

	function Network.Server:FireAllActors(name: string, rType: RemoteEnum, ...)
		local _headerBuf: buffer = buffer.fromstring(name .. '::' .. rType);
		if (rType == "RF") then return end;
		if (rType == "RE") then
			getRE():FireAllClients(_headerBuf, ...);
		elseif (rType == "URE") then
			getURE():FireAllClients(_headerBuf, ...);
		end
	end
	
	if (RunService:IsStudio()) then
		print(`[Server/Network] Initialized Network.`);
	end
end

return Network;