local RunService = game:GetService("RunService")

local EventReceiver = require(script.EventReceiver)
local EventRecorder = require(script.EventRecorder)

local Networker = {}
Networker._events = EventReceiver()

function Networker:_handleEvents()
	self._events.RemoteEvent.OnServerEvent:Connect(function(serviceName: string, eventName: string, ...: any?)
		local eventType = EventRecorder:getEventType(serviceName, eventName)

		if eventType ~= "Any" and eventType ~= "Default" then
			warn(`event {eventName} can't be called as remoteEvent, it is {eventType}`)
			return
		end

		EventRecorder.events[eventType][serviceName][eventName](...)
	end)

	self._events.UnreliableRemoteEvent.OnServerEvent:Connect(function(serviceName: string, eventName: string, ...: any?)
		local eventType = EventRecorder:getEventType(serviceName, eventName)

		if eventType ~= "Any" and eventType ~= "Unreliable" then
			warn(`event {eventName} can't be called as unreliable remote event, it is {eventType}`)
			return
		end

		EventRecorder.events[eventType][serviceName][eventName](...)
	end)
end

function Networker.createService(name: string)
	local service = {}

	local meta = {}
	meta.__newIndex = function(_, key: any, value: any)
		if typeof(value) ~= "function" then
			return
		end
		EventRecorder.writeEvent(name, key, value)
	end

	service.client = setmetatable({}, meta)

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

if RunService:IsServer() then
	Networker:_handleEvents()
end

if RunService:IsServer() then
	return Networker.createService
else
	return Networker.createController
end
