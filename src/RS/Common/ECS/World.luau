-- ECS world container.
-- VZNZach | Licensed client use only | Discord @botheringmeagain
-- GitHub-managed: do not modify in Roblox Studio.

--##========== DEPENDENCIES ==========##--

local function tryRequire(robloxPath: any, relativePath: any): any
	local ok, result = pcall(function()
		return require(robloxPath)
	end)
	if ok then
		return result
	end
	return require(relativePath)
end

local EntityStore = tryRequire(script and script.Parent and script.Parent.Entity, "./Entity")
local System = tryRequire(script and script.Parent and script.Parent.System, "./System")
local Component = tryRequire(script and script.Parent and script.Parent.Component, "./Component")
local ECSTypes = tryRequire(script and script.Parent and script.Parent.Types, "./Types")
local Observer = tryRequire(script and script.Parent and script.Parent.Observer, "./Observer")
local Debugger = tryRequire(script and script.Parent and script.Parent.Debugger, "./Debugger")

--##========== TYPES ==========##--

type Entity = number

type ObserverCallback = (entity: Entity, data: any) -> ()

type ObserverMap = ECSTypes.ObserverMap
type SystemDefinition = ECSTypes.SystemDefinition
type PrefabEntry = ECSTypes.PrefabEntry
type PrefabDefinition = ECSTypes.PrefabDefinition

type WorldImpl = typeof(setmetatable(
	{} :: {
		_entityStore: any,
		_systems: { SystemDefinition },
		_systemErrors: { [string]: number },
		_singletons: { [string]: any },
		_observers: ObserverMap,
		_paused: boolean,
		_destroyed: boolean,
	},
	{} :: WorldMeta
))

type WorldMeta = {
	__index: WorldMeta,
	new: () -> WorldImpl,
	spawn: (self: WorldImpl) -> Entity,
	despawn: (self: WorldImpl, id: Entity) -> (),
	isAlive: (self: WorldImpl, id: Entity) -> boolean,
	addComponent: (self: WorldImpl, id: Entity, name: string, data: { [string]: any }) -> (),
	get: (self: WorldImpl, id: Entity, name: string) -> { [string]: any }?,
	set: (self: WorldImpl, id: Entity, name: string, data: { [string]: any }) -> (),
	removeComponent: (self: WorldImpl, id: Entity, name: string) -> (),
	hasComponent: (self: WorldImpl, id: Entity, name: string) -> boolean,
	markDirty: (self: WorldImpl, id: Entity, name: string) -> (),
	flushDirty: (self: WorldImpl) -> { any },
	setSingleton: (self: WorldImpl, name: string, data: any) -> (),
	getSingleton: (self: WorldImpl, name: string) -> any?,
	addSystem: (self: WorldImpl, systemDef: SystemDefinition) -> (),
	addSystems: (self: WorldImpl, list: { SystemDefinition }) -> (),
	enableSystem: (self: WorldImpl, name: string) -> (),
	disableSystem: (self: WorldImpl, name: string) -> (),
	isSystemEnabled: (self: WorldImpl, name: string) -> boolean,
	step: (self: WorldImpl, dt: number) -> (),
	pause: (self: WorldImpl) -> (),
	resume: (self: WorldImpl) -> (),
	isPaused: (self: WorldImpl) -> boolean,
	bindInstance: (self: WorldImpl, id: Entity, instance: any) -> (),
	onAdd: (self: WorldImpl, name: string, callback: ObserverCallback) -> (),
	onChange: (self: WorldImpl, name: string, callback: ObserverCallback) -> (),
	onRemove: (self: WorldImpl, name: string, callback: ObserverCallback) -> (),
	spawnPrefab: (self: WorldImpl, prefab: PrefabDefinition) -> Entity,
	destroy: (self: WorldImpl) -> (),
}

--##========== PRIVATE STATE ==========##--

local CIRCUIT_BREAKER_THRESHOLD = 10

local World = {} :: WorldMeta
World.__index = World

--##========== PRIVATE FUNCTIONS ==========##--

local function _sortSystems(systems: { SystemDefinition }): ()
	table.sort(systems, function(a: SystemDefinition, b: SystemDefinition): boolean
		local orderA = System.PHASE_ORDER[a.phase]
		local orderB = System.PHASE_ORDER[b.phase]

		if orderA ~= orderB then
			return orderA < orderB
		end

		return a.priority < b.priority
	end)
end

local function _findSystem(systems: { SystemDefinition }, name: string): SystemDefinition?
	for _, sys in systems do
		if sys.name == name then
			return sys
		end
	end

	return nil
end

local function _collectMatchingEntities(entityStore: any, query: any): { Entity }
	local result: { Entity } = {}

	if not query._all or #query._all == 0 then
		return result
	end

	local candidates = entityStore:getEntitiesWithComponent(query._all[1])

	for _, entityId in candidates do
		local components = entityStore:getAllComponents(entityId)

		if not components or not query:matches(components) then
			continue
		end

		table.insert(result, entityId)
	end

	return result
end

--##========== PUBLIC API ==========##--

function World.new(): WorldImpl
	local self = setmetatable({}, World) :: WorldImpl

	self._entityStore  = EntityStore.new()
	self._systems      = {}
	self._systemErrors = {}
	self._singletons   = {}
	self._paused       = false
	self._destroyed    = false
	self._observers    = Observer.new()
	self._frameNumber  = 0

	return self
end

function World.spawn(self: WorldImpl): Entity
	return self._entityStore:spawn()
end

function World.despawn(self: WorldImpl, id: Entity): ()
	local components = self._entityStore:getAllComponents(id)

	if components then
		for name, data in components do
			self._observers:fire("onRemove", name, id, data)
		end
	end

	self._entityStore:despawn(id)
end

function World.isAlive(self: WorldImpl, id: Entity): boolean
	return self._entityStore:isAlive(id)
end

function World.addComponent(self: WorldImpl, id: Entity, name: string, data: { [string]: any }): ()
	self._entityStore:addComponent(id, name, data)

	self._observers:fire("onAdd", name, id, data)
end

function World.get(self: WorldImpl, id: Entity, name: string): { [string]: any }?
	return self._entityStore:get(id, name)
end

function World.set(self: WorldImpl, id: Entity, name: string, data: { [string]: any }): ()
	self._entityStore:set(id, name, data)
	self._entityStore:markDirty(id, name)

	self._observers:fire("onChange", name, id, data)
end

function World.removeComponent(self: WorldImpl, id: Entity, name: string): ()
	local existingData = self._entityStore:get(id, name)

	self._observers:fire("onRemove", name, id, existingData)

	self._entityStore:removeComponent(id, name)
end

function World.hasComponent(self: WorldImpl, id: Entity, name: string): boolean
	return self._entityStore:hasComponent(id, name)
end

function World.markDirty(self: WorldImpl, id: Entity, name: string): ()
	self._entityStore:markDirty(id, name)

	local data = self._entityStore:get(id, name)

	self._observers:fire("onChange", name, id, data)
end

function World.flushDirty(self: WorldImpl): { any }
	return self._entityStore:flushDirty()
end

function World.setSingleton(self: WorldImpl, name: string, data: any): ()
	self._singletons[name] = data
end

function World.getSingleton(self: WorldImpl, name: string): any?
	return self._singletons[name]
end

function World.addSystem(self: WorldImpl, systemDef: SystemDefinition): ()
	table.insert(self._systems, systemDef)
	self._systemErrors[systemDef.name] = 0

	_sortSystems(self._systems)
end

function World.addSystems(self: WorldImpl, list: { SystemDefinition }): ()
	for _, systemDef in list do
		table.insert(self._systems, systemDef)
		self._systemErrors[systemDef.name] = 0
	end

	_sortSystems(self._systems)
end

function World.enableSystem(self: WorldImpl, name: string): ()
	local sys = _findSystem(self._systems, name)
	if not sys then
		return
	end

	sys.enabled = true
	self._systemErrors[name] = 0
end

function World.disableSystem(self: WorldImpl, name: string): ()
	local sys = _findSystem(self._systems, name)
	if not sys then
		return
	end

	sys.enabled = false
end

function World.isSystemEnabled(self: WorldImpl, name: string): boolean
	local sys = _findSystem(self._systems, name)
	if not sys then
		return false
	end

	return sys.enabled
end

function World.step(self: WorldImpl, dt: number): ()
	if self._paused or self._destroyed then
		return
	end

	self._frameNumber += 1

	local disabledCount = 0

	for _, sys in self._systems do
		if not sys.enabled then
			disabledCount += 1
			continue
		end

		local entities: { Entity } = {}

		if sys.query then
			entities = _collectMatchingEntities(self._entityStore, sys.query)
		end

		local startTime = os.clock()
		local ok, err   = pcall(sys.run, entities, dt)
		local duration  = (os.clock() - startTime) * 1000

		if ok then
			self._systemErrors[sys.name] = 0
			Debugger.logSystemRun(sys.name, duration, #entities)
			continue
		end

		local errorCount = (self._systemErrors[sys.name] or 0) + 1
		self._systemErrors[sys.name] = errorCount

		warn(`[World] System "{sys.name}" errored: {err}`)

		if errorCount >= CIRCUIT_BREAKER_THRESHOLD then
			sys.enabled = false
			warn(`[World] System "{sys.name}" auto-disabled after {CIRCUIT_BREAKER_THRESHOLD} consecutive errors`)
		end
	end

	local activeCount = #self._systems - disabledCount
	local entityCount = 0

	for _ in self._entityStore._alive do
		entityCount += 1
	end

	Debugger.flush(self._frameNumber, activeCount, disabledCount, entityCount)
end

function World.pause(self: WorldImpl): ()
	self._paused = true
end

function World.resume(self: WorldImpl): ()
	self._paused = false
end

function World.isPaused(self: WorldImpl): boolean
	return self._paused
end

function World.bindInstance(self: WorldImpl, id: Entity, instance: any): ()
	self._entityStore:bindInstance(id, instance)
end

function World.getBoundInstances(self: WorldImpl, id: Entity): { any }?
	return self._entityStore._cleanup._bindings[id]
end

function World.onAdd(self: WorldImpl, name: string, callback: ObserverCallback): ()
	self._observers:register("onAdd", name, callback)
end

function World.onChange(self: WorldImpl, name: string, callback: ObserverCallback): ()
	self._observers:register("onChange", name, callback)
end

function World.onRemove(self: WorldImpl, name: string, callback: ObserverCallback): ()
	self._observers:register("onRemove", name, callback)
end

function World.spawnPrefab(self: WorldImpl, prefab: PrefabDefinition): Entity
	local id = self:spawn()

	for _, entry in prefab.components do
		local componentName = entry[1] :: string
		local overrides = entry[2] :: { [string]: any }?

		local data: { [string]: any }

		if Component.isDefined(componentName) then
			data = Component.createInstance(componentName, overrides)
		elseif overrides then
			data = overrides
		else
			data = {}
		end

		self:addComponent(id, componentName, data)
	end

	return id
end

function World.destroy(self: WorldImpl): ()
	self._destroyed = true
	self._paused = true

	table.clear(self._systems)
	table.clear(self._systemErrors)
	table.clear(self._singletons)

	self._observers:clear()
end

return World
