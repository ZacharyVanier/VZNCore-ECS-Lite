-- Client-side ECS world manager.
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local World = require(ReplicatedStorage.VZNCore.Engine.World)

local _world: any = nil
local _renderConn: RBXScriptConnection? = nil
local _heartbeatConn: RBXScriptConnection? = nil

local ClientWorld = {}

function ClientWorld.getWorld()
	return _world
end

function ClientWorld.start()
	local world = World.new()
	_world = world

	_renderConn = RunService.RenderStepped:Connect(function(dt)
		world:step(dt)
	end)

	_heartbeatConn = RunService.Heartbeat:Connect(function(_dt)
		world:flushDirty()
	end)

	print("[VZNCore-Lite] Client world started")
	return world
end

function ClientWorld.stop()
	if _renderConn then
		_renderConn:Disconnect()
		_renderConn = nil
	end
	if _heartbeatConn then
		_heartbeatConn:Disconnect()
		_heartbeatConn = nil
	end
	if _world then
		_world:destroy()
		_world = nil
	end
end

return ClientWorld
