-- ECS framework type definitions
-- VZNZach | Licensed client use only | Discord @botheringmeagain
-- GitHub-managed: do not modify in Roblox Studio.

export type Entity = number

export type Phase = "PreUpdate" | "Update" | "PostUpdate" | "PreRender" | "Render" | "PostRender"

export type ComponentDefinition = {
	name: string,
	defaults: { [string]: any },
	replicated: boolean?,
	singleton: boolean?,
}

export type QueryFilter = {
	all: { string }?,
	any: { string }?,
	none: { string }?,
}

export type Query = {
	filter: QueryFilter,
	all: (self: Query, ...string) -> Query,
	any: (self: Query, ...string) -> Query,
	none: (self: Query, ...string) -> Query,
	evaluate: (self: Query, entityComponents: { [string]: any }) -> boolean,
}

export type ObserverCallback = (entity: Entity, data: any) -> ()

export type ObserverType = "onAdd" | "onChange" | "onRemove"

export type Observer = {
	componentName: string,
	observerType: ObserverType,
	callback: ObserverCallback,
}

export type PrefabComponent = string | { string | { [string]: any } }

export type PrefabDefinition = {
	name: string,
	components: { PrefabComponent },
}

export type SystemDefinition = {
	name: string,
	phase: Phase,
	priority: number,
	query: Query?,
	run: (entities: { Entity }, dt: number) -> (),
	enabled: boolean,
}

export type CleanupBinding = {
	entity: Entity,
	instance: Instance,
}

export type DebugSystemInfo = {
	name: string,
	executionTimeMs: number,
	entityCount: number,
	enabled: boolean,
}

export type DebugFrameInfo = {
	frameNumber: number,
	activeSystems: number,
	disabledSystems: number,
	entityCount: number,
	systems: { DebugSystemInfo },
	mutatedComponents: { [string]: number },
}

export type WorldConfig = {
	debugEnabled: boolean?,
}

export type Optional<T> = T | nil
export type Dictionary<K, V> = { [K]: V }
export type Array<T> = { T }
export type Set<T> = { [T]: boolean }
export type Callback<T> = (value: T) -> ()
export type Predicate<T> = (value: T) -> boolean
export type Factory<T> = () -> T
export type Result<T> = { ok: true, value: T } | { ok: false, error: string }

return nil
