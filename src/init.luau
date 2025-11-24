local RunService = game:GetService("RunService")

local EventReceiver = require(script.EventReceiver)
local EventRecorder = require(script.EventRecorder)

local Networker = {}
Networker._events = EventReceiver()

function Networker:_handleEvents()
	if RunService:IsServer() then
		self._events.RemoteEvent.OnServerEvent:Connect(
			function(player: Player, serviceName: string, eventName: string, ...: any?)
				print(player, serviceName, eventName, ...)
				local eventType = EventRecorder:getEventType(serviceName, eventName)

				if eventType ~= "Any" and eventType ~= "Default" then
					warn(`event {eventName} can't be called as remoteEvent, it is {eventType}`)
					return
				end

				EventRecorder.events[eventType][serviceName][eventName](player, ...)
			end
		)
		self._events.UnreliableRemoteEvent.OnServerEvent:Connect(
			function(player: Player, serviceName: string, eventName: string, ...: any?)
				local eventType = EventRecorder:getEventType(serviceName, eventName)

				if eventType ~= "Any" and eventType ~= "Unreliable" then
					warn(`event {eventName} can't be called as unreliable remote event, it is {eventType}`)
					return
				end

				EventRecorder.events[eventType][serviceName][eventName](player, ...)
			end
		)
	else
		self._events.RemoteEvent.OnClientEvent:Connect(function(serviceName: string, eventName: string, ...: any?)
			EventRecorder.events[serviceName][eventName](...)
		end)
		self._events.UnreliableRemoteEvent.OnClientEvent:Connect(
			function(serviceName: string, eventName: string, ...: any?)
				EventRecorder.events[serviceName][eventName](...)
			end
		)
	end

	self._events.BindableEvent.Event:Connect(function(serviceName: string, eventName: string, ...: any?)
		EventRecorder.events.Bindable[serviceName][eventName](...)
	end)
end

function Networker.createService(name: string)
	local service = {}

	local client = {}
	client.__newindex = function(_, key: any, value: any)
		if typeof(value) ~= "function" then
			print("not a function")
			return
		end
		EventRecorder:writeEvent(name, key, value)
	end

	local shared = {}
	shared.__newindex = function(_, key: any, value: any)
		if typeof(value) ~= "function" then
			print("not a function")
			return
		end
		EventRecorder:writeEvent(name, key, value)
	end

	service.client = setmetatable({}, client)
	service.shared = { Events = setmetatable({}, shared) }

	function service.shared.fire(serviceName: string, eventName: string, ...: any?)
		script.EventReceiver.BindableEvent.Event:Fire(serviceName, eventName, ...)
	end

	function service.client.fire(player: Player, eventName: string, ...: any?)
		script.EventReceiver.RemoteEvent:FireClient(player, name, eventName, ...)
	end

	function service.client.fireAllClients(eventName: string, ...: any?)
		script.EventReceiver.RemoteEvent:FireAllClients(name, eventName, ...)
	end

	function service.client.fireUnreliable(player: Player, eventName: string, ...: any?)
		script.EventReceiver.UnreliableRemoteEvent:FireClient(player, name, eventName, ...)
	end

	function service.client.fireAllClientsUnreliable(eventName: string, ...: any?)
		script.EventReceiver.UnreliableRemoteEvent:FireAllClients(name, eventName, ...)
	end

	return service
end

function Networker.createController(name: string)
	local controller = {}

	local server = {}

	function server.fire(eventName: string, ...: any?)
		Networker._events.RemoteEvent:FireServer(name, eventName, ...)
	end

	function server.fireUnreliable(eventName: string, ...)
		Networker._events.UnreliableRemoteEvent:FireServer(name, eventName, ...)
	end

	controller.server = server

	local shared = {}
	shared.__newindex = function(_, key: any, value: any)
		if typeof(value) ~= "function" then
			print("not a function")
			return
		end
		EventRecorder:writeEvent(name, key, value)
	end

	local client = {}
	client.__newindex = function(_, key: any, value: any)
		if typeof(value) ~= "function" then
			print("not a function")
			return
		end
		EventRecorder:writeEvent(name, key, value)
	end

	controller.shared = { Events = setmetatable({}, shared) }
	controller.client = setmetatable({}, client)

	function controller.shared.fire(serviceName: string, eventName: string, ...: any?)
		script.EventReceiver.BindableEvent.Event:Fire(serviceName, eventName, ...)
	end

	return controller
end

--[[
local CharacterService = Networker("CharacterService")

function CharacterService:init() end

function CharacterService.client.jumpRequest(dataFromClient: {}) end
--]]

--[[
local CharacterController = Networker("CharacterService")

function CharacterController:init()
    self.server:fire("jumpRequest", {
        data = 123,
    })
end
--]]

Networker:_handleEvents()

return {
	server = Networker.createService,
	client = Networker.createController,
}
