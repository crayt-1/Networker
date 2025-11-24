return function()
	local events = {}

	if game:GetService("RunService"):IsServer() then
		events.UnreliableRemoteEvent = script:FindFirstChild("UnreliableRemoteEvent")
			or Instance.new("UnreliableRemoteEvent")
		events.UnreliableRemoteEvent.Parent = script

		events.RemoteEvent = script:FindFirstChild("RemoteEvent") or Instance.new("RemoteEvent")
		events.RemoteEvent.Parent = script

		events.BindableEvent = script:FindFirstChild("BindableEvent") or Instance.new("BindableEvent")
		events.BindableEvent.Parent = script
	else
		events.UnreliableRemoteEvent = script:WaitForChild("UnreliableRemoteEvent", math.huge)
		events.RemoteEvent = script:WaitForChild("RemoteEvent", math.huge)
		events.BindableEvent = script:WaitForChild("BindableEvent", math.huge)
	end

	return events
end
