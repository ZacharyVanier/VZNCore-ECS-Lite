-- Component definition registry
-- VZNZach | Licensed client use only | Discord @botheringmeagain
-- GitHub-managed: do not modify in Roblox Studio.

--##========== PRIVATE STATE ==========##--

local _definitions: { [string]: ComponentDefinition } = {}

--##========== PRIVATE FUNCTIONS ==========##--

local function _shallowCopy(source: { [string]: any }): { [string]: any }
	local copy: { [string]: any } = {}

	for key, value in source do
		copy[key] = value
	end

	return copy
end

local function _shallowMerge(base: { [string]: any }, overrides: { [string]: any }): { [string]: any }
	local merged = _shallowCopy(base)

	for key, value in overrides do
		merged[key] = value
	end

	return merged
end

--##========== PUBLIC API ==========##--

local Component = {}

function Component.define(name: string, defaults: { [string]: any }, options: ComponentOptions?): ()
	assert(not _definitions[name], `[Component] Component already defined: {name}`)

	local resolvedOptions = options or {}

	_definitions[name] = {
		name = name,
		defaults = defaults,
		singleton = resolvedOptions.singleton or false,
		replicated = resolvedOptions.replicated or false,
	}
end

function Component.getDefinition(name: string): ComponentDefinition?
	return _definitions[name]
end

function Component.createInstance(name: string, overrides: { [string]: any }?): { [string]: any }
	local definition = _definitions[name]
	assert(definition, `[Component] Cannot create instance of undefined component: {name}`)

	if overrides then
		return _shallowMerge(definition.defaults, overrides)
	end

	return _shallowCopy(definition.defaults)
end

function Component.isDefined(name: string): boolean
	return _definitions[name] ~= nil
end

function Component.isReplicated(name: string): boolean
	local definition = _definitions[name]
	if not definition then
		return false
	end

	return definition.replicated
end

function Component.isSingleton(name: string): boolean
	local definition = _definitions[name]
	if not definition then
		return false
	end

	return definition.singleton
end

function Component._reset(): ()
	table.clear(_definitions)
end

return Component
