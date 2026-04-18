-- ECS instance binding and cleanup registry
-- VZNZach | Licensed client use only | Discord @botheringmeagain
-- GitHub-managed: do not modify in Roblox Studio.

--##========== TYPES ==========##--

type BindingMap = {
	[number]: { any },
}

--##========== PUBLIC API ==========##--

local Cleanup = {}
Cleanup.__index = Cleanup

export type Cleanup = typeof(setmetatable({} :: {
	_bindings: BindingMap,
}, Cleanup))

function Cleanup.new(): Cleanup
	local self = setmetatable({}, Cleanup) :: Cleanup

	self._bindings = {}

	return self
end

function Cleanup.bind(self: Cleanup, entityId: number, instance: any): ()
	if not self._bindings[entityId] then
		self._bindings[entityId] = {}
	end

	table.insert(self._bindings[entityId], instance)
end

function Cleanup.unbindAll(self: Cleanup, entityId: number): ()
	local bound = self._bindings[entityId]
	if not bound then return end

	for _, instance in bound do
		if not instance or not instance.Parent then continue end
		instance:Destroy()
	end

	self._bindings[entityId] = nil
end

function Cleanup.clear(self: Cleanup): ()
	table.clear(self._bindings)
end

return Cleanup
