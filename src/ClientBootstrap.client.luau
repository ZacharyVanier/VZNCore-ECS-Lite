-- Minimal ECS client bootstrap.
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local ECS = ReplicatedStorage.Common.ECS
local World = require(ECS.World)

local world = World.new()

RunService.RenderStepped:Connect(function(dt)
	world:step(dt)
end)
