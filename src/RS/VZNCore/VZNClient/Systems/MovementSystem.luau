-- Integrates Position += Velocity * dt on the client.
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Query = require(ReplicatedStorage.VZNCore.Engine.Query)
local System = require(ReplicatedStorage.VZNCore.Engine.System)

local MovementSystem = {}

function MovementSystem.init(world)
	world:addSystem(System.new("ClientMovement", {
		phase = "Update",
		priority = 0,
		query = Query.all("Position", "Velocity"),
		run = function(entities, dt)
			for _, entity in entities do
				local pos = world:get(entity, "Position")
				local vel = world:get(entity, "Velocity")
				world:set(entity, "Position", {
					x = pos.x + vel.x * dt,
					y = pos.y + vel.y * dt,
					z = pos.z + vel.z * dt,
				})
			end
		end,
	}))
end

return MovementSystem
