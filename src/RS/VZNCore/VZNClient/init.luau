-- Client bootstrap: register components, start world, install systems.
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ClientWorld = require(script.ClientWorld)

require(ReplicatedStorage.VZNCore.Shared.Components)

local world = ClientWorld.start()

require(script.Systems.SpawningSystem).init(world)
require(script.Systems.InputSystem).init(world)
require(script.Systems.MovementSystem).init(world)
require(script.Systems.RenderSystem).init(world)

print("[VZNCore-Lite] Client initialized")
return true
