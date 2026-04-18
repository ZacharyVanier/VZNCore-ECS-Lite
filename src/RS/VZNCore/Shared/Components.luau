-- Shared component definitions — loaded by both client and server.
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Component = require(ReplicatedStorage.VZNCore.Engine.Component)

Component.define("Position", {
	x = 0,
	y = 0,
	z = 0,
})

Component.define("Velocity", {
	x = 0,
	y = 0,
	z = 0,
})

Component.define("Health", {
	current = 100,
	max = 100,
})

Component.define("Renderable", {
	instance = nil,
})

return true
