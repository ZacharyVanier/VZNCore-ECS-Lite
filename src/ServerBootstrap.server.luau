-- Minimal ECS server bootstrap.
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local ECS = ReplicatedStorage.Common.ECS
local World = require(ECS.World)
local Query = require(ECS.Query)
local System = require(ECS.System)

local world = World.new()

world:addSystem(System.new("Movement", {
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

local demo = world:spawn()
world:addComponent(demo, "Position", { x = 0, y = 0, z = 0 })
world:addComponent(demo, "Velocity", { x = 1, y = 0, z = 0 })

RunService.Heartbeat:Connect(function(dt)
	world:step(dt)
end)
