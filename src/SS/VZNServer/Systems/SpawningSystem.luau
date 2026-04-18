-- Creates one demo entity + visible workspace Part on first tick.
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local System = require(ReplicatedStorage.VZNCore.Engine.System)

local SpawningSystem = {}

function SpawningSystem.init(world)
	local spawned = false

	world:addSystem(System.new("Spawning", {
		phase = "PreUpdate",
		priority = -100,
		run = function(_entities, _dt)
			if spawned then
				return
			end
			spawned = true

			local part = Instance.new("Part")
			part.Name = "ServerDemoEntity"
			part.Anchored = true
			part.Size = Vector3.new(4, 4, 4)
			part.BrickColor = BrickColor.new("Bright blue")
			part.Position = Vector3.new(0, 10, 0)
			part.Parent = Workspace

			local entity = world:spawn()
			world:addComponent(entity, "Position", { x = 0, y = 10, z = 0 })
			world:addComponent(entity, "Velocity", { x = 4, y = 0, z = 0 })
			world:addComponent(entity, "Renderable", { instance = part })
			world:bindInstance(entity, part)
		end,
	}))
end

return SpawningSystem
