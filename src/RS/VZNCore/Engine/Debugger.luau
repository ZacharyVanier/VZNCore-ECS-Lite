-- Debug logging for ECS systems
-- VZNZach | Licensed client use only | Discord @botheringmeagain
-- GitHub-managed: do not modify in Roblox Studio.

--##========== PUBLIC API ==========##--

local Debugger = {}

Debugger._enabled = false
Debugger._systemLogs = {} :: { SystemLog }
Debugger._mutationCounts = {} :: { [string]: number }

function Debugger.enable(): ()
	Debugger._enabled = true
end

function Debugger.disable(): ()
	Debugger._enabled = false
end

function Debugger.isEnabled(): boolean
	return Debugger._enabled
end

function Debugger.logSystemRun(name: string, durationMs: number, entityCount: number): ()
	if not Debugger._enabled then
		return
	end

	table.insert(Debugger._systemLogs, {
		name = name,
		executionTimeMs = durationMs,
		entityCount = entityCount,
	})
end

function Debugger.logMutation(componentName: string): ()
	if not Debugger._enabled then
		return
	end

	Debugger._mutationCounts[componentName] = (Debugger._mutationCounts[componentName] or 0) + 1
end

function Debugger.flush(frameNumber: number, systemCount: number, disabledCount: number, entityCount: number): ()
	if not Debugger._enabled then
		return
	end

	print(`[VZNCore Debug] Frame {frameNumber}`)
	print(`  Systems: {systemCount} active, {disabledCount} disabled`)
	print(`  Entities: {entityCount}`)

	for _, log in Debugger._systemLogs do
		print(`  [{log.name}] {string.format("%.2f", log.executionTimeMs)}ms | {log.entityCount} entities`)
	end

	for name, count in Debugger._mutationCounts do
		print(`  Mutations: {name} x{count}`)
	end

	table.clear(Debugger._systemLogs)
	table.clear(Debugger._mutationCounts)
end

function Debugger._reset(): ()
	Debugger._enabled = false

	table.clear(Debugger._systemLogs)
	table.clear(Debugger._mutationCounts)
end

return Debugger
