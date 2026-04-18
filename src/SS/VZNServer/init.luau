-- Server bootstrap: register components, start world, install systems.
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ServerWorld = require(script.ServerWorld)

require(ReplicatedStorage.VZNCore.Shared.Components)

local world = ServerWorld.start()

require(script.Systems.SpawningSystem).init(world)
require(script.Systems.MovementSystem).init(world)
require(script.Systems.RenderSystem).init(world)

print("[VZNCore-Lite] Server initialized")
return true
