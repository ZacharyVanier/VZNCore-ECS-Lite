-- Entity storage engine
-- VZNZach | Licensed client use only | Discord @botheringmeagain
-- GitHub-managed: do not modify in Roblox Studio.

--##========== DEPENDENCIES ==========##--

local function tryRequire(robloxPath, relativePath)
	local ok, result = pcall(function()
		return require(robloxPath)
	end)
	if ok then return result end
	return require(relativePath)
end

local Cleanup = tryRequire(script and script.Parent and script.Parent.Cleanup, "./Cleanup")

--##========== PUBLIC API ==========##--

local EntityStore = {} :: EntityStoreMeta
EntityStore.__index = EntityStore

function EntityStore.new(): EntityStore
	local self = setmetatable({}, EntityStore) :: EntityStore

	self._nextId     = 0
	self._alive      = {}
	self._components = {}
	self._dirty      = {}
	self._cleanup    = Cleanup.new()

	return self
end

function EntityStore.spawn(self: EntityStore): Entity
	self._nextId = self._nextId + 1

	local id = self._nextId

	self._alive[id] = true
	self._components[id] = {}

	return id
end

function EntityStore.despawn(self: EntityStore, id: Entity): ()
	self._alive[id] = nil

	self._cleanup:unbindAll(id)

	self._components[id] = nil
end

function EntityStore.isAlive(self: EntityStore, id: Entity): boolean
	return self._alive[id] == true
end

function EntityStore.addComponent(self: EntityStore, id: Entity, name: string, data: { [string]: any }): ()
	assert(self._alive[id], `[Entity] Cannot add component to non-alive entity {id}`)

	self._components[id][name] = data
end

function EntityStore.get(self: EntityStore, id: Entity, name: string): { [string]: any }?
	assert(self._alive[id], `[Entity] Cannot get component from non-alive entity {id}`)

	return self._components[id][name]
end

function EntityStore.set(self: EntityStore, id: Entity, name: string, data: { [string]: any }): ()
	assert(self._alive[id], `[Entity] Cannot set component on non-alive entity {id}`)

	self._components[id][name] = data
end

function EntityStore.removeComponent(self: EntityStore, id: Entity, name: string): ()
	if not self._components[id] then
		return
	end

	self._components[id][name] = nil
end

function EntityStore.hasComponent(self: EntityStore, id: Entity, name: string): boolean
	local entityComponents = self._components[id]
	if not entityComponents then
		return false
	end

	return entityComponents[name] ~= nil
end

function EntityStore.markDirty(self: EntityStore, id: Entity, name: string): ()
	table.insert(self._dirty, { entity = id, name = name })
end

function EntityStore.flushDirty(self: EntityStore): { DirtyEntry }
	local copy = table.clone(self._dirty)

	table.clear(self._dirty)

	return copy
end

function EntityStore.getEntitiesWithComponent(self: EntityStore, name: string): { Entity }
	local result: { Entity } = {}

	for entityId, components in self._components do
		if components[name] ~= nil then
			table.insert(result, entityId)
		end
	end

	return result
end

function EntityStore.bindInstance(self: EntityStore, id: Entity, instance: Instance): ()
	assert(self._alive[id], `[Entity] Cannot bind instance to non-alive entity {id}`)

	self._cleanup:bind(id, instance)
end

function EntityStore.getAllComponents(self: EntityStore, id: Entity): { [string]: { [string]: any } }?
	return self._components[id]
end

return EntityStore
