return function()
	local events = {}
	if game:GetService("RunService"):IsServer() then
		events.UnreliableRemoteEvent = Instance.new("UnreliableRemoteEvent")
		events.UnreliableRemoteEvent.Parent = script

		events.RemoteEvent = Instance.new("RemoteEvent")
		events.RemoteEvent.Parent = script
	else
		events.UnreliableRemoteEvent = script:WaitForChild("UnreliableRemoteEvent", math.huge)
		events.RemoteEvent = script:WaitForChild("RemoteEvent", math.huge)
	end

	return events
end
