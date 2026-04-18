-- Syncs Position components to bound Part CFrames (server-authoritative).
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Query = require(ReplicatedStorage.VZNCore.Engine.Query)
local System = require(ReplicatedStorage.VZNCore.Engine.System)

local RenderSystem = {}

function RenderSystem.init(world)
	world:addSystem(System.new("RenderSync", {
		phase = "PostUpdate",
		priority = 100,
		query = Query.all("Position", "Renderable"),
		run = function(entities, _dt)
			for _, entity in entities do
				local pos = world:get(entity, "Position")
				local renderable = world:get(entity, "Renderable")
				local inst = renderable.instance

				if inst and inst:IsA("BasePart") then
					inst.CFrame = CFrame.new(pos.x, pos.y, pos.z)
				end
			end
		end,
	}))
end

return RenderSystem
