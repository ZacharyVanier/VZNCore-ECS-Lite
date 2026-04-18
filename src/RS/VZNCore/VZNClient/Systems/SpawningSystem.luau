-- Spawns a client-local demo entity with its own red Part.
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local System = require(ReplicatedStorage.VZNCore.Engine.System)

local SpawningSystem = {}

function SpawningSystem.init(world)
	local spawned = false

	world:addSystem(System.new("ClientSpawning", {
		phase = "PreUpdate",
		priority = -100,
		run = function(_entities, _dt)
			if spawned then
				return
			end
			spawned = true

			local part = Instance.new("Part")
			part.Name = "ClientDemoEntity"
			part.Anchored = true
			part.CanCollide = false
			part.Size = Vector3.new(3, 3, 3)
			part.BrickColor = BrickColor.new("Bright red")
			part.Position = Vector3.new(0, 16, 0)
			part.Parent = Workspace

			local entity = world:spawn()
			world:addComponent(entity, "Position", { x = 0, y = 16, z = 0 })
			world:addComponent(entity, "Velocity", { x = 0, y = 0, z = 0 })
			world:addComponent(entity, "Renderable", { instance = part })
			world:bindInstance(entity, part)
		end,
	}))
end

return SpawningSystem
