-- Reads WASD and writes Velocity onto every entity that has one.
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

local Query = require(ReplicatedStorage.VZNCore.Engine.Query)
local System = require(ReplicatedStorage.VZNCore.Engine.System)

local SPEED = 20

local InputSystem = {}

function InputSystem.init(world)
	world:addSystem(System.new("Input", {
		phase = "PreUpdate",
		priority = 0,
		query = Query.all("Velocity"),
		run = function(entities, _dt)
			local vx, vz = 0, 0
			if UserInputService:IsKeyDown(Enum.KeyCode.W) then
				vz -= SPEED
			end
			if UserInputService:IsKeyDown(Enum.KeyCode.S) then
				vz += SPEED
			end
			if UserInputService:IsKeyDown(Enum.KeyCode.A) then
				vx -= SPEED
			end
			if UserInputService:IsKeyDown(Enum.KeyCode.D) then
				vx += SPEED
			end

			for _, entity in entities do
				world:set(entity, "Velocity", { x = vx, y = 0, z = vz })
			end
		end,
	}))
end

return InputSystem
