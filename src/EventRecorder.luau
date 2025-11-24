local EventRecorder = {}
EventRecorder.events = {
	Any = {},
	Unreliable = {},
	Bindable = {},
	Default = {},
}
EventRecorder._eventTypes = {}

export type EventRecorder = typeof(EventRecorder)
export type EventType = "Any" | "Unreliable" | "Default" | "Bindable"

function EventRecorder.getEventType(self: EventRecorder, serviceName: string, eventName: string)
	if not self._eventTypes[serviceName] then
		return nil
	end
	return self._eventTypes[serviceName][eventName]
end

function EventRecorder.writeEvent(
	self: EventRecorder,
	serviceName: string,
	eventName: string,
	callback: (Player | any, any?) -> ()
)
	local stringLength = serviceName:len()

	local isRe, reLastIndex = serviceName:find("_RE")
	local isUre, ureLastIndex = serviceName:find("_URE")
	local isBe, beLastIndex = serviceName:find("_BE")

	local eventType: EventType = isRe and reLastIndex == stringLength and "Default"
		or isUre and ureLastIndex == stringLength and "Unreliable"
		or isBe and beLastIndex == stringLength and "Bindable"
		or "Any"

	if eventType ~= "Bindable" then
		if not self.events[eventType][serviceName] then
			self.events[eventType][serviceName] = {}
		end

		if not self._eventTypes[serviceName] then
			self._eventTypes[serviceName] = {}
		end

		self._eventTypes[serviceName][eventName] = eventType
		self.events[eventType][serviceName][eventName] = callback
	else
		script.Parent.EventReceiver.BindableEvent.Event:Connect(
			function(_serviceName: string, _eventName: string, ...: any?)
				if serviceName ~= _serviceName or eventName ~= _eventName then
					return
				end

				callback(...)
			end
		)
	end
end

return EventRecorder :: EventRecorder
