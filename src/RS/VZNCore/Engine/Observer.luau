-- ECS observer registry for component lifecycle events
-- VZNZach | Licensed client use only | Discord @botheringmeagain
-- GitHub-managed: do not modify in Roblox Studio.

--##========== TYPES ==========##--

type ObserverCallback = (entity: number, data: any) -> ()

type EventMap = {
	[string]: { ObserverCallback },
}

--##========== PUBLIC API ==========##--

local Observer = {}
Observer.__index = Observer

export type Observer = typeof(setmetatable({} :: {
	onAdd:    EventMap,
	onChange: EventMap,
	onRemove: EventMap,
}, Observer))

function Observer.new(): Observer
	local self = setmetatable({}, Observer) :: Observer

	self.onAdd    = {}
	self.onChange  = {}
	self.onRemove = {}

	return self
end

function Observer.register(self: Observer, eventType: string, componentName: string, callback: ObserverCallback): ()
	local group = (self :: any)[eventType] :: EventMap?
	if not group then return end

	if not group[componentName] then
		group[componentName] = {}
	end

	table.insert(group[componentName], callback)
end

function Observer.fire(self: Observer, eventType: string, componentName: string, entity: number, data: any): ()
	local group = (self :: any)[eventType] :: EventMap?
	if not group then return end

	local callbacks = group[componentName]
	if not callbacks then return end

	for _, callback in callbacks do
		callback(entity, data)
	end
end

function Observer.clear(self: Observer): ()
	table.clear(self.onAdd)
	table.clear(self.onChange)
	table.clear(self.onRemove)
end

return Observer
