-- Entity prefab registry
-- VZNZach | Licensed client use only | Discord @botheringmeagain
-- GitHub-managed: do not modify in Roblox Studio.

--##========== PRIVATE STATE ==========##--

local _definitions: { [string]: PrefabDefinition } = {}

--##========== PUBLIC API ==========##--

local Prefab = {}

function Prefab.define(name: string, componentList: { PrefabEntry }): ()
	assert(_definitions[name] == nil, `[Prefab] Prefab "{name}" already defined`)

	_definitions[name] = {
		name = name,
		components = componentList,
	}
end

function Prefab.getDefinition(name: string): PrefabDefinition?
	return _definitions[name]
end

function Prefab.isDefined(name: string): boolean
	return _definitions[name] ~= nil
end

function Prefab._reset(): ()
	table.clear(_definitions)
end

return Prefab
