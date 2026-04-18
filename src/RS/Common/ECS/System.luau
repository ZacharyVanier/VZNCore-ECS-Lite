-- System definition and validation
-- VZNZach | Licensed client use only | Discord @botheringmeagain
-- GitHub-managed: do not modify in Roblox Studio.

--##========== PUBLIC API ==========##--

local System = {}

System.PHASE_ORDER = {
	PreUpdate = 1,
	Update = 2,
	PostUpdate = 3,
	PreRender = 4,
	Render = 5,
	PostRender = 6,
}

function System.isValidPhase(phase: string): boolean
	return System.PHASE_ORDER[phase] ~= nil
end

function System.new(name: string, config: SystemConfig): SystemDefinition
	assert(type(name) == "string", `[System] name must be a string, got {type(name)}`)
	assert(type(config.phase) == "string", `[System] phase is required for system "{name}"`)
	assert(System.isValidPhase(config.phase), `[System] invalid phase "{config.phase}" for system "{name}"`)
	assert(type(config.run) == "function", `[System] run function is required for system "{name}"`)

	local definition: SystemDefinition = {
		name = name,
		phase = config.phase :: Phase,
		priority = config.priority or 0,
		query = config.query,
		run = config.run,
		enabled = true,
	}

	return definition
end

return System
