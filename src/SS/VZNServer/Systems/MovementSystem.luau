-- Integrates Position += Velocity * dt each frame. Bounces at x=±40.
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Query = require(ReplicatedStorage.VZNCore.Engine.Query)
local System = require(ReplicatedStorage.VZNCore.Engine.System)

local MovementSystem = {}

function MovementSystem.init(world)
	world:addSystem(System.new("Movement", {
		phase = "Update",
		priority = 0,
		query = Query.all("Position", "Velocity"),
		run = function(entities, dt)
			for _, entity in entities do
				local pos = world:get(entity, "Position")
				local vel = world:get(entity, "Velocity")

				local nx = pos.x + vel.x * dt
				local ny = pos.y + vel.y * dt
				local nz = pos.z + vel.z * dt

				local newVx = vel.x
				if nx > 40 or nx < -40 then
					newVx = -vel.x
					nx = math.clamp(nx, -40, 40)
				end

				world:set(entity, "Position", { x = nx, y = ny, z = nz })
				if newVx ~= vel.x then
					world:set(entity, "Velocity", { x = newVx, y = vel.y, z = vel.z })
				end
			end
		end,
	}))
end

return MovementSystem
