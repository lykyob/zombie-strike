local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local Mouse = require(ReplicatedStorage.RuddevModules.Mouse)

local Abilities = script.Parent.Main.Abilities
local LocalPlayer = Players.LocalPlayer

local COOLDOWN = 10
local COOLDOWN_TEXT = "%.1fs"
local GRENADE_SPEED = 50

local function abilityButton(keyboardCode, keyboardName, gamepadCode, gamepadName, frame, remote, callback)
	local cooldown = frame.Cooldown
	local label = frame.Label

	local using = false

	local function updateLabel()
		if UserInputService:GetLastInputType() == Enum.UserInputType.Gamepad1 then
			label.Text = gamepadName
		else
			label.Text = keyboardName
		end
	end

	local function use()
		local character = LocalPlayer.Character

		if not character or character.Humanoid.Health <= 0 then return end
		if using then return end

		using = true
		if callback() == false then
			using = false
		end
	end

	remote.OnClientEvent:connect(function()
		local dt = COOLDOWN

		while dt > 0 do
			cooldown.Text = COOLDOWN_TEXT:format(dt)
			dt = dt - RunService.Heartbeat:wait()
		end

		cooldown.Text = ""
		using = false
	end)

	frame.MouseButton1Click:connect(use)

	UserInputService.InputBegan:connect(function(inputObject, processed)
		if processed then return end

		if inputObject.KeyCode == keyboardCode or inputObject.KeyCode == gamepadCode then
			use()
		end
	end)

	UserInputService.LastInputTypeChanged:connect(updateLabel)

	updateLabel()
end

abilityButton(
	Enum.KeyCode.Q,
	"Q",
	Enum.KeyCode.ButtonL1,
	"L1",
	Abilities.Q,
	ReplicatedStorage.Remotes.HealthPack,
	function()
		if not ReplicatedStorage.HubWorld.Value then
			local humanoid = LocalPlayer.Character.Humanoid
			if humanoid.Health == humanoid.MaxHealth then return end
		end

		ReplicatedStorage.Remotes.HealthPack:FireServer()
	end
)

abilityButton(
	Enum.KeyCode.E,
	"E",
	Enum.KeyCode.ButtonR1,
	"R1",
	Abilities.E,
	ReplicatedStorage.Remotes.GrenadeCooldown,
	function()
		local grenade = ReplicatedStorage.Remotes.FireGrenade:InvokeServer()
		if not grenade then
			warn("no grenade")
			return false
		end

		local primaryCFrame = LocalPlayer.Character.PrimaryPart.CFrame
		grenade.CFrame = primaryCFrame + primaryCFrame.RightVector
		grenade.Velocity = (
			Mouse.WorldPosition - LocalPlayer.Character.PrimaryPart.Position
		).Unit * GRENADE_SPEED + Vector3.new(0, 15, 0)
	end
)
