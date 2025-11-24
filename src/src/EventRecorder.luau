local EventRecorder = {}
EventRecorder.events = {
	Any = {},
	Unreliable = {},
	Default = {},
}
EventRecorder._eventTypes = {}

export type EventRecorder = typeof(EventRecorder)
export type EventType = "Any" | "Unreliable" | "Default"

function EventRecorder.getEventType(self: EventRecorder, serviceName: string, eventName: string)
	return self._eventTypes[serviceName][eventName]
end

function EventRecorder.writeEvent(self: EventRecorder, serviceName: string, eventName: string, callback: (any) -> ())
	local stringLength = serviceName:len()

	local isRe, reLastIndex = serviceName:find("_RE")
	local isUre, ureLastIndex = serviceName:find("_URE")

	local eventType: EventType = isRe and reLastIndex == stringLength and "Default"
		or isUre and ureLastIndex == stringLength and "Unreliable"
		or "Any"

	if not self.events[eventType][serviceName] then
		self.events[eventType][serviceName] = {}
	end

	self._eventTypes[serviceName][eventName] = eventType
	self.events[eventType][serviceName][eventName] = callback
end

return EventRecorder :: EventRecorder
