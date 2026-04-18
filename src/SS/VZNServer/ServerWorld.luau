-- Server-side ECS world manager.
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local World = require(ReplicatedStorage.VZNCore.Engine.World)

local _world: any = nil
local _heartbeat: RBXScriptConnection? = nil

local ServerWorld = {}

function ServerWorld.getWorld()
	return _world
end

function ServerWorld.start()
	local world = World.new()
	_world = world

	_heartbeat = RunService.Heartbeat:Connect(function(dt)
		world:step(dt)
	end)

	print("[VZNCore-Lite] Server world started")
	return world
end

function ServerWorld.stop()
	if _heartbeat then
		_heartbeat:Disconnect()
		_heartbeat = nil
	end
	if _world then
		_world:destroy()
		_world = nil
	end
end

return ServerWorld
