--[[
    __      __          _            _       ______       _   _ _            _____                                       __      _____  
    \ \    / /         (_)          ( )     |  ____|     | | (_) |          / ____|                                      \ \    / /__ \ 
     \ \  / /   _ _ __  ___  ___   _|/ ___  | |__   _ __ | |_ _| |_ _   _  | (___  _ __   __ ___      ___ __   ___ _ __   \ \  / /   ) |
     \ \/ / | | | '_ \| \ \/ / | | | / __| |  __| | '_ \| __| | __| | | |  \___ \| '_ \ / _` \ \ /\ / / '_ \ / _ \ '__|   \ \/ /   / / 
      \  /| |_| | | | | |>  <| |_| | \__ \ | |____| | | | |_| | |_| |_| |  ____) | |_) | (_| |\ V  V /| | | |  __/ |       \  /   / /_ 
       \/  \__, |_| |_|_/_/\_\\__,_| |___/ |______|_| |_|\__|_|\__|\__, | |_____/| .__/ \__,_| \_/\_/ |_| |_|\___|_|        \/   |____|
             __/ |                                                   __/ |        | |                                                   
            |___/                                                   |___/         |_|
]]--

if getgenv().VynixuEntitySpawnerV2 then
	return getgenv().VynixuEntitySpawnerV2
end

loadstring(game:HttpGet(
	"https://raw.githubusercontent.com/RegularVynixu/Utilities/main/Functions.lua"
))()

-- \\ Services // --

local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")
local SoundService = game:GetService("SoundService")

-- \\ Variables // --

local ROOT =
	"https://github.com/RegularVynixu/DOORS-Entity-Spawner-V2/raw/main"

local LocalPlayer = Players.LocalPlayer

local Character =
	LocalPlayer.Character
	or LocalPlayer.CharacterAdded:Wait()

local Humanoid =
	Character:WaitForChild("Humanoid")

local RootPart =
	Character.PrimaryPart
	or Character:FindFirstChildWhichIsA("BasePart", true)

local PlayerGui =
	LocalPlayer:WaitForChild("PlayerGui")

local Camera =
	workspace.CurrentCamera

local LastRespawn = tick()

local JumpscarePlayed = false

local Remotes =
	ReplicatedStorage:WaitForChild("RemotesFolder") :: Folder

local GameStats =
	ReplicatedStorage:WaitForChild("GameStats") :: Folder

local CurrentRooms =
	workspace:WaitForChild("CurrentRooms") :: Folder

-- \\ Assets // --

local Assets = {
	Repentance =
		LoadCustomInstance(
			ROOT .. "/Assets/Repentance.rbxm"
		),

	Earthquake =
		LoadCustomInstance(
			ROOT .. "/Assets/Earthquake.rbxm"
		)
}

-- \\ Modules // --

local Modules = {
	Module_Events =
		require(
			ReplicatedStorage.ModulesClient.Module_Events
			:: ModuleScript
		),

	Main_Game =
		require(
			PlayerGui.MainUI.Initiator.Main_Game
			:: ModuleScript
		)
}

-- \\ Storage // --

local Storage = {

	Ambient = {},

	DeathTypes = {
		["Yellow"] = {
			"yellow",
			"curious"
		},

		["Blue"] = {
			"blue",
			"guiding"
		}
	},

	CrucifixTypes = {

		["guiding"] = {
			Color = Color3.fromRGB(
				137,
				207,
				255
			)
		},

		["curious"] = {
			Color = Color3.fromRGB(
				255,
				227,
				137
			)
		}
	}
}

-- \\ Constants // --

local CONST = {

	BASE_ENTITY_SPEED = 65,

	ATTR = {

		ENTITY = {

			Running = false,

			CustomEntity = true,

			Paused = false,

			BeingBanished = false,

			Despawning = false,

			Damage = true,

			LastEnteredRoom = -1
		},

		PLAYER = {

			SpawnProtection = 5
		}
	},

	DEFAULT = {

		CONFIG = {

			Entity = {

				Name = "Template Entity",

				Asset =
					"https://github.com/RegularVynixu/Utilities/raw/refs/heads/main/Doors/Entity%20Spawner/Assets/Entities/Rush.rbxm",

				HeightOffset = 0
			},

			Movement = {

				Speed = 100,

				Delay = 2,

				Reversed = false
			},

			Damage = {

				Enabled = true,

				Range = 40,

				Amount = 125,

				IgnoreHiding = false
			},

			-- \\ Jumpscare // --

			Jumpscare = {

				true,

				{

					Image1 =
						"rbxassetid://11417375410",

					Image2 =
						"rbxassetid://11417375410",

					Shake = true,

					Sound1 = {

						10483790459,

						{
							Volume = 0.5
						}
					},

					Sound2 = {

						5263560566,

						{
							Volume = 0.5
						}
					},

					Flashing = {

						true,

						Color3.fromRGB(
							50,
							115,
							108
						)
					},

					Tease = {

						false,

						Min = 1,

						Max = 5
					}
				}
			},

			Rebounding = {

				Enabled = true,

				Type = "Ambush",

				Min = 2,

				Max = 4,

				Delay = 2
			},

			Lights = {

				Flicker = {

					Enabled = true,

					Duration = 1
				},

				Shatter = true,

				Repair = false
			},

			Earthquake = {

				Enabled = true
			},

			CameraShake = {

				Enabled = true,

				Values = {
					1.5,
					20,
					0.1,
					1
				},

				Range = 100
			},

			Crucifixion = {

				Type = "Guiding",

				Enabled = true,

				Range = 40,

				Resist = false,

				Break = true
			},

			Death = {

				Type = "Guiding",

				Hints = {
					"Death",
					"Hints",
					"Go",
					"Here"
				},

				Cause = ""
			}
		},

		DEBUG = {

			OnSpawned =
				function()
				end,

			OnStartMoving =
				function()
				end,

			OnReachedNode =
				function()
				end,

			OnEnterRoom =
				function()
				end,

			OnLookAt =
				function()
				end,

			OnRebounding =
				function()
				end,

			OnDespawning =
				function()
				end,

			OnDespawned =
				function()
				end,

			OnDamagePlayer =
				function()
				end,

			CrucifixionOverwrite = nil
		}
	}
}

-- \\ Module // --

local Module = {

	ActiveEntities = {},

	Connections = {}
}

-- \\ Functions // --

local function CloneTable(tbl: any): any

	local new = {}

	for key, value in next, tbl do

		if typeof(value) == "table" then

			new[key] =
				CloneTable(value)

		else

			new[key] =
				value

		end
	end

	return new
end

local function ApplyConfigDefaults(
	tbl,
	defaults
)

	local new =
		CloneTable(tbl)

	for key, value in next, defaults do

		if new[key] == nil then

			if typeof(value) == "table" then

				new[key] =
					CloneTable(value)

			else

				new[key] =
					value

			end

		elseif typeof(value) == "table" then

			if typeof(new[key]) ~= "table" then

				new[key] = {}

			end

			new[key] =
				ApplyConfigDefaults(
					new[key],
					value
				)
		end
	end

	return new
end

-- \\ Character // --

local function OnCharacterAdded(
	char: Model
)

	LastRespawn =
		tick()

	JumpscarePlayed =
		false

	Character =
		char

	Humanoid =
		char:WaitForChild(
			"Humanoid"
		)

	RootPart =
		char.PrimaryPart
		or char:FindFirstChildWhichIsA(
			"BasePart",
			true
		)

	Modules.Main_Game =
		require(
			PlayerGui
				:WaitForChild("MainUI")
				.Initiator
				.Main_Game
			:: ModuleScript
		)
end

-- \\ Rooms // --

local function GetCurrentRoom(
	latest: boolean
): Model?

	if latest then

		local rooms =
			CurrentRooms:GetChildren()

		return rooms[#rooms]
	end

	return CurrentRooms:FindFirstChild(
		LocalPlayer:GetAttribute(
			"CurrentRoom"
		)
	)
end

local function GetRoomAtPoint(
	vector3: Vector3
): Model?

	local whitelist = {}

	for _, room in next,
		CurrentRooms:GetChildren()
	do

		local p =
			room:FindFirstChild(
				room.Name
			)

		if p then

			whitelist[#whitelist + 1] =
				p

		end
	end

	if #whitelist > 0 then

		local params =
			RaycastParams.new()

		params.FilterType =
			Enum.RaycastFilterType.Include

		params.FilterDescendantsInstances =
			whitelist

		params.CollisionGroup =
			"BaseCheck"

		local result =
			workspace:Raycast(
				vector3,
				Vector3.new(
					0,
					-100,
					0
				),
				params
			)

		if result then

			for _, room in next,
				CurrentRooms:GetChildren()
			do

				if result.Instance.Parent ==
					room
				then

					return room

				end
			end
		end
	end

	return nil
end

local function FixRoomLights(
	room: Model
)

	local roomEntrance =
		room:FindFirstChild(
			"RoomEntrance"
		)

	if not roomEntrance then
		return
	end

	-- Clear shards

	for _, c in next,
		Camera:GetChildren()
	do

		if c.Name == "Piece" then

			c:Destroy()

		end
	end

	-- Set room ambient

	Modules.Module_Events.toggle(
		room,
		true,
		Storage.Ambient[room]
	)

	-- Fix lights

	local stuff = {}

	for _, d in next,
		room:GetDescendants()
	do

		if
			d:IsA("Model")
			and (
				d.Name == "LightStand"
				or d.Name == "Chandelier"
			)
		then

			table.insert(
				stuff,
				d
			)
		end
	end

	local random =
		Random.new(
			math.floor(tick())
		)

	for _, v in next,
		stuff
	do

		if v:GetAttribute(
			"Shattered"
		) then

			local r1 =
				random:NextInteger(
					-10,
					10
				) / 50

			local r2 =
				random:NextInteger(
					5,
					20
				) / 100

			task.delay(

				(
					roomEntrance.Position
					-
					v.PrimaryPart.Position
				).Magnitude
				/ 150
				+ r1,

				function()

					local neon =
						v:FindFirstChild(
							"Neon",
							true
						)

					for _, d in next,
						v:GetDescendants()
					do

						if d:IsA("Light") then

							TweenService:Create(

								d,

								TweenInfo.new(
									r2,
									Enum.EasingStyle.Quad,
									Enum.EasingDirection.InOut
								),

								{
									Brightness =
										d:GetAttribute(
											"OGBrightness"
										)
								}

							):Play()

						elseif d:IsA("Sound") then

							TweenService:Create(

								d,

								TweenInfo.new(
									r2,
									Enum.EasingStyle.Quad,
									Enum.EasingDirection.InOut
								),

								{
									Volume =
										d:GetAttribute(
											"OGVolume"
										)
								}

							):Play()
						end
					end

					if neon then

						neon.Transparency =
							0.9

						neon.Material =
							Enum.Material.Neon

						TweenService:Create(

							neon,

							TweenInfo.new(
								r2,
								Enum.EasingStyle.Quart,
								Enum.EasingDirection.InOut
							),

							{
								Transparency = 0.2
							}

						):Play()

						task.wait(r2)
					end

					v:SetAttribute(
						"Shattered",
						nil
					)
				end
			)
		end
	end
end

-- \\ Equipped Tool // --

local function HasEquipped(
	name: string
): boolean

	local tool =
		Character:FindFirstChildOfClass(
			"Tool"
		)

	if tool then

		if tool.Name == name then
			return true, tool
		end

		local success, tagged =
			pcall(
				function()
					return tool:HasTag(name)
				end
			)

		if success and tagged then
			return true, tool
		end
	end

	return false
end

-- \\ Jumpscare // --

local function PlayJumpscare(
	config
)

	-- Prevent duplicate jumpscares

	if JumpscarePlayed then
		return
	end

	if typeof(config) ~= "table"
		or config[1] ~= true
	then
		return
	end

	local s =
		config[2]

	if typeof(s) ~= "table" then
		return
	end

	JumpscarePlayed =
		true

	-- \\ GUI // --

	local gui =
		Instance.new("ScreenGui")

	gui.Name =
		"VynixuJumpscare"

	gui.IgnoreGuiInset =
		true

	gui.ResetOnSpawn =
		false

	gui.DisplayOrder =
		999999

	gui.ZIndexBehavior =
		Enum.ZIndexBehavior.Sibling

	local bg =
		Instance.new("Frame")

	bg.Name =
		"Background"

	bg.Size =
		UDim2.fromScale(
			1,
			1
		)

	bg.Position =
		UDim2.fromScale(
			0,
			0
		)

	bg.BackgroundColor3 =
		Color3.new(
			0,
			0,
			0
		)

	bg.BorderSizePixel =
		0

	bg.ZIndex =
		999

	bg.Parent =
		gui

	local face =
		Instance.new("ImageLabel")

	face.Name =
		"Face"

	face.AnchorPoint =
		Vector2.new(
			0.5,
			0.5
		)

	face.Position =
		UDim2.fromScale(
			0.5,
			0.5
		)

	face.Size =
		UDim2.fromOffset(
			150,
			150
		)

	face.BackgroundTransparency =
		1

	face.ImageTransparency =
		0

	face.ScaleType =
		Enum.ScaleType.Fit

	face.ZIndex =
		1000

	pcall(function()

		face.ResampleMode =
			Enum.ResamplerMode.Pixelated

	end)

	face.Parent =
		bg

	-- Parent GUI

	local guiParented =
		pcall(function()

			gui.Parent =
				CoreGui

		end)

	if not guiParented then

		gui.Parent =
			PlayerGui

	end

	-- \\ Image loading // --

	local image1 = nil
	local image2 = nil

	if s.Image1 then

		local success, result =
			pcall(
				LoadCustomAsset,
				s.Image1
			)

		if success then
			image1 = result
		end
	end

	if image1 then

		face.Image =
			image1

	end

	if s.Image2 then

		local success, result =
			pcall(
				LoadCustomAsset,
				s.Image2
			)

		if success then
			image2 = result
		end
	end

	-- \\ Sound loader // --

	local function LoadJumpscareSound(
		data
	)

		if typeof(data) ~= "table"
			or data[1] == nil
		then
			return nil
		end

		local sound =
			Instance.new("Sound")

		local soundId =
			tostring(data[1])

		if soundId:find(
			"rbxasset://"
		) then

			sound.SoundId =
				soundId

		elseif soundId:find(
			"rbxassetid://"
		) then

			sound.SoundId =
				soundId

		else

			sound.SoundId =
				"rbxassetid://"
				.. soundId:gsub(
					"%D",
					""
				)

		end

		if typeof(data[2]) == "table" then

			for property, value in
				next,
				data[2]
			do

				pcall(function()

					sound[property] =
						value

				end)
			end
		end

		sound.Parent =
			SoundService

		return sound
	end

	local sound1 =
		LoadJumpscareSound(
			s.Sound1
		)

	local sound2 =
		LoadJumpscareSound(
			s.Sound2
		)

	-- \\ Screen size // --

	local camera =
		workspace.CurrentCamera

	local screenHeight =
		camera
		and camera.ViewportSize.Y
		or 720

	if screenHeight <= 0 then
		screenHeight = 720
	end

	local minTeaseSize =
		screenHeight / 5

	local maxTeaseSize =
		screenHeight / 2.5

	-- \\ Tease // --

	local teaseConfig =
		s.Tease

	if typeof(teaseConfig) == "table"
		and teaseConfig[1] == true
	then

		local min =
			math.max(
				1,
				math.floor(
					tonumber(
						teaseConfig.Min
					)
					or 1
				)
			)

		local max =
			math.max(
				min,
				math.floor(
					tonumber(
						teaseConfig.Max
					)
					or 5
				)
			)

		local teaseAmount =
			math.random(
				min,
				max
			)

		if sound1 then
			sound1:Play()
		end

		for _ = 1,
			teaseAmount
		do

			if not gui.Parent then
				return
			end

			task.wait(
				math.random(
					100,
					200
				) / 100
			)

			if not gui.Parent then
				return
			end

			local progress =
				_ / teaseAmount

			local size =
				minTeaseSize
				+
				(
					maxTeaseSize
					-
					minTeaseSize
				)
				*
				progress

			face.Size =
				UDim2.fromOffset(
					size,
					size
				)
		end

		task.wait(
			math.random(
				100,
				200
			) / 100
		)
	end

	-- \\ Flashing // --

	local flashThread

	if typeof(s.Flashing) == "table"
		and s.Flashing[1] == true
	then

		flashThread =
			task.spawn(function()

				while gui.Parent do

					bg.BackgroundColor3 =
						s.Flashing[2]
						or Color3.fromRGB(
							50,
							115,
							108
						)

					task.wait(
						math.random(
							25,
							100
						) / 1000
					)

					if not gui.Parent then
						break
					end

					bg.BackgroundColor3 =
						Color3.new(
							0,
							0,
							0
						)

					task.wait(
						math.random(
							25,
							100
						) / 1000
					)
				end
			end)
	end

	-- \\ Shake // --

	local shakeConnection

	if s.Shake == true then

		shakeConnection =
			RunService.RenderStepped:Connect(
				function()

					if not face.Parent then
						return
					end

					face.Position =
						UDim2.new(

							0.5,

							math.random(
								-35,
								35
							),

							0.5,

							math.random(
								-20,
								20
							)
						)

					face.Rotation =
						math.random(
							-5,
							5
						)
				end
			)
	end

	-- \\ Final image // --

	if image2 then

		face.Image =
			image2

	elseif image1 then

		face.Image =
			image1

	else

		face.Image =
			""

	end

	face.Size =
		UDim2.fromOffset(
			maxTeaseSize,
			maxTeaseSize
		)

	face.ImageTransparency =
		0

	-- \\ Sound 2 // --

	if sound2 then
		sound2:Play()
	end

	-- \\ Zoom // --

	local zoomSize =
		screenHeight * 3

	local zoomTween =
		TweenService:Create(

			face,

			TweenInfo.new(

				0.75,

				Enum.EasingStyle.Quad,

				Enum.EasingDirection.Out
			),

			{
				Size =
					UDim2.fromOffset(
						zoomSize,
						zoomSize
					),

				ImageTransparency =
					0.5
			}
		)

	zoomTween:Play()

	-- Keep jumpscare visible

	task.wait(2)

	-- \\ Cleanup // --

	if shakeConnection then

		shakeConnection:Disconnect()

		shakeConnection =
			nil
	end

	if flashThread then

		task.cancel(
			flashThread
		)

		flashThread =
			nil
	end

	if sound1 then

		pcall(function()
			sound1:Stop()
		end)

		sound1:Destroy()

	end

	if sound2 then

		pcall(function()
			sound2:Stop()
		end)

		sound2:Destroy()

	end

	if gui then
		gui:Destroy()
	end
end

-- \\ Crucifix // --

local function CrucifixEntity(
	entity: any
)

	local model =
		entity.Model

	local config =
		entity.Config

	local resist =
		config.Crucifixion.Resist

	-- \\ Setup // --

	local entityPivot =
		model:GetPivot()

	local params =
		RaycastParams.new()

	params.FilterType =
		Enum.RaycastFilterType.Exclude

	params.FilterDescendantsInstances = {
		Character,
		model
	}

	local result =
		workspace:Raycast(

			entityPivot.Position,

			Vector3.new(
				0,
				-1000,
				0
			),

			params
		)

	if not result then
		return
	end

	model:SetAttribute(
		"BeingBanished",
		true
	)

	-- \\ Variables // --

	local MainGame =
		require(
			PlayerGui.MainUI.Initiator.Main_Game
			:: ModuleScript
		)

	local CamShaker =
		MainGame.camShaker

	local TheShake =
		CamShaker:StartShake(
			5,
			20,
			2,
			Vector3.zero
		)

	local Repentance =
		Assets.Repentance:Clone()

	local Crucifix =
		Repentance.Crucifix

	local Handle =
		Crucifix.Handle

	local Pentagram =
		Repentance.Pentagram

	local EntityPart =
		Repentance.Entity

	local Sound =
		Handle[
			resist
			and "SoundFail"
			or "Sound"
		]

	-- \\ Repentance setup // --

	Repentance:PivotTo(
		CFrame.new(
			result.Position
		)
	)

	Crucifix:PivotTo(
		Character:GetPivot()
	)

	EntityPart.CFrame =
		entityPivot

	Repentance.Parent =
		workspace

	Sound:Play()

	local function waitUntil(
		t: number
	)

		repeat

			RunService.RenderStepped:Wait()

		until Sound.TimePosition >= t
	end

	local function fadeOut()

		for _, v in Pentagram:GetChildren() do

			if v.Name == "BeamFlat" then

				task.delay(

					v:GetAttribute(
						"Delay"
					)
					or 0,

					function()

						TweenService:Create(

							v,

							TweenInfo.new(

								1.5,

								Enum.EasingStyle.Sine,

								Enum.EasingDirection.In
							),

							{
								Brightness = 0
							}

						):Play()
					end
				)

			elseif v.Name == "BeamChain" then

				TweenService:Create(

					v,

					TweenInfo.new(

						1.5,

						Enum.EasingStyle.Sine,

						Enum.EasingDirection.In
					),

					{
						Brightness = 0
					}

				):Play()
			end
		end
	end

	-- \\ Pentagram color // --

	local crucifixType =
		Storage.CrucifixTypes[
			config.Crucifixion.Type:lower()
		]

	local Color =
		crucifixType
		and crucifixType.Color
		or Color3.fromRGB(
			137,
			207,
			255
		)

	for _, v in next,
		Repentance:QueryDescendants(
			".GiveMeColor"
		)
	do

		if
			v:IsA("Light")
			or v:IsA("BasePart")
		then

			v.Color =
				Color

		elseif
			v:IsA("ParticleEmitter")
			or v:IsA("Beam")
		then

			v.Color =
				ColorSequence.new({

					ColorSequenceKeypoint.new(
						0,
						Color
					),

					ColorSequenceKeypoint.new(
						1,
						Color
					)
				})
		end
	end

	-- \\ Lock entity // --

	task.spawn(function()

		if not resist then

			while EntityPart.Parent do

				if not model.Parent then
					break
				end

				model:PivotTo(
					EntityPart.CFrame
				)

				RunService.RenderStepped:Wait()
			end

			if model.Parent then
				model:Destroy()
			end
		end
	end)

	-- \\ Pentagram animation // --

	TweenService:Create(

		Pentagram.Circle,

		TweenInfo.new(

			2,

			Enum.EasingStyle.Exponential,

			Enum.EasingDirection.Out
		),

		{
			CFrame =
				Pentagram.Circle.CFrame
				-
				Vector3.new(
					0,
					25,
					0
				)
		}

	):Play()

	task.delay(
		2,
		Pentagram.Circle.Destroy,
		Pentagram.Circle
	)

	-- \\ Crucifix hover // --

	Handle.BodyPosition.Position =
		(
			Character:GetPivot()
			*
			CFrame.new(
				1,
				4,
				-6
			)
		).Position

	TweenService:Create(

		Handle.BodyAngularVelocity,

		TweenInfo.new(

			4,

			Enum.EasingStyle.Cubic,

			Enum.EasingDirection.In
		),

		{
			AngularVelocity =
				Vector3.new(
					0,
					40,
					0
				)
		}

	):Play()

	task.delay(
		3,
		function()

			for _, shard in next,
				Handle.Shards:GetChildren()
			do

				shard.CollisionGroup =
					"NoPlayer"

				shard.CanCollide =
					true

				if shard:FindFirstChild(
					"Weld"
				) then

					shard.Weld:Destroy()

				end

				shard.AssemblyAngularVelocity =
					Vector3.zero
			end
		end
	)

	-- \\ Start raising entity // --

	if not resist then

		TweenService:Create(

			EntityPart,

			TweenInfo.new(

				3,

				Enum.EasingStyle.Elastic,

				Enum.EasingDirection.In
			),

			{
				CFrame =
					EntityPart.CFrame
					+
					Vector3.new(
						0,
						2,
						0
					)
			}

		):Play()
	end

	-- \\ Ritual animation // --

	task.spawn(function()

		waitUntil(
			2.625
		)

		TweenService:Create(

			Pentagram.Base.LightAttach.LightBright,

			TweenInfo.new(

				1.5,

				Enum.EasingStyle.Circular,

				Enum.EasingDirection.InOut
			),

			{
				Brightness = 5,
				Range = 40
			}

		):Play()

		TweenService:Create(

			Handle.Light,

			TweenInfo.new(

				1.5,

				Enum.EasingStyle.Circular,

				Enum.EasingDirection.InOut
			),

			{
				Brightness = 11.25,
				Range = 30
			}

		):Play()

		task.wait(
			1.5
		)

		TweenService:Create(

			Pentagram.Base.LightAttach.LightBright,

			TweenInfo.new(

				1.5,

				Enum.EasingStyle.Circular,

				Enum.EasingDirection.InOut
			),

			{
				Brightness = 0,
				Range = 0
			}

		):Play()

		TweenService:Create(

			Handle.Light,

			TweenInfo.new(

				1.5,

				Enum.EasingStyle.Circular,

				Enum.EasingDirection.InOut
			),

			{
				Brightness = 0,
				Range = 0
			}

		):Play()

		if not resist then

			TweenService:Create(

				Handle.Light,

				TweenInfo.new(

					1,

					Enum.EasingStyle.Circular,

					Enum.EasingDirection.InOut
				),

				{
					Brightness = 15,
					Range = 40
				}

			):Play()

			TheShake:StartFadeOut(
				3
			)

			fadeOut()

			TweenService:Create(

				Handle.BodyAngularVelocity,

				TweenInfo.new(

					3,

					Enum.EasingStyle.Cubic,

					Enum.EasingDirection.Out
				),

				{
					AngularVelocity =
						Vector3.zero
				}

			):Play()
		end
	end)

	-- \\ Crucifix actions // --

	if not resist then

		waitUntil(
			2.5
		)

		TweenService:Create(

			EntityPart,

			TweenInfo.new(

				3,

				Enum.EasingStyle.Back,

				Enum.EasingDirection.In
			),

			{
				CFrame =
					EntityPart.CFrame
					-
					Vector3.new(
						0,
						50,
						0
					)
			}

		):Play()

		for _, s in next,
			model:QueryDescendants(
				"Sound"
			)
		do

			if s:GetAttribute(
				"VolumeIgnore"
			) then

				continue

			end

			TweenService:Create(

				s,

				TweenInfo.new(

					3,

					Enum.EasingStyle.Back,

					Enum.EasingDirection.In
				),

				{
					Volume = 0
				}

			):Play()
		end

		waitUntil(
			6.75
		)

	else

		waitUntil(
			4
		)

		TweenService:Create(

			Handle.BodyAngularVelocity,

			TweenInfo.new(

				3,

				Enum.EasingStyle.Sine,

				Enum.EasingDirection.Out
			),

			{
				AngularVelocity =
					Vector3.zero
			}

		):Play()

		TweenService:Create(

			Pentagram.Base.LightAttach.LightBright,

			TweenInfo.new(

				1.5,

				Enum.EasingStyle.Circular,

				Enum.EasingDirection.InOut
			),

			{
				Brightness = 0,
				Range = 0,
				Color =
					Color3.fromRGB(
						255,
						116,
						130
					)
			}

		):Play()

		TweenService:Create(

			Handle.Light,

			TweenInfo.new(

				1.5,

				Enum.EasingStyle.Circular,

				Enum.EasingDirection.InOut
			),

			{
				Brightness = 0,
				Range = 0,
				Color =
					Color3.fromRGB(
						255,
						116,
						130
					)
			}

		):Play()

		TheShake:StartFadeOut(
			3
		)

		task.spawn(function()

			local color =
				Instance.new(
					"Color3Value"
				)

			color.Value =
				Color3.fromRGB(
					137,
					207,
					255
				)

			local tween =
				TweenService:Create(

					color,

					TweenInfo.new(
						0.5,
						Enum.EasingStyle.Sine
					),

					{
						Value =
							Color3.fromRGB(
								255,
								116,
								130
							)
					}
				)

			tween:Play()

			while
				tween.PlaybackState
				==
				Enum.PlaybackState.Playing
			do

				for _, d in next,
					Repentance:GetDescendants()
				do

					if d.ClassName ==
						"Beam"
					then

						d.Color =
							ColorSequence.new({

								ColorSequenceKeypoint.new(
									0,
									color.Value
								),

								ColorSequenceKeypoint.new(
									1,
									color.Value
								)
							})

					elseif d.Name ==
						"Glow"
					then

						d.Color =
							color.Value
					end
				end

				task.wait()
			end

			color:Destroy()
		end)

		waitUntil(
			9.625
		)
	end

	-- \\ Crucifix glow explode // --

	TweenService:Create(

		Handle.Glow,

		TweenInfo.new(1),

		{
			Size =
				Handle.Glow.Size * 3,

			Transparency = 1
		}

	):Play()

	TweenService:Create(

		Pentagram.Base.LightAttach.LightBright,

		TweenInfo.new(1),

		{
			Brightness = 0,
			Range = 0
		}

	):Play()

	TweenService:Create(

		Handle.Light,

		TweenInfo.new(1),

		{
			Brightness = 0,
			Range = 0
		}

	):Play()

	if not resist then

		Handle.ExplodeParticle:Emit(
			math.random(
				20,
				30
			)
		)

		CamShaker:ShakeOnce(
			7.5,
			7.5,
			0.25,
			1.5
		)

	else

		model:SetAttribute(
			"BeingBanished",
			false
		)

		model:SetAttribute(
			"Paused",
			false
		)

		fadeOut()
	end

	task.delay(
		5,
		Repentance.Destroy,
		Repentance
	)
end

-- \\ Damage // --

local function IsPlayerProtected(): boolean

	return (
		tick()
		-
		LastRespawn
	)
	<=
	(LocalPlayer:GetAttribute(
		"SpawnProtection"
	) or 5)
end

local function DamagePlayer(
	entity: any
)

	if
		Humanoid.Health <= 0
		or IsPlayerProtected()
	then

		return
	end

	local config =
		entity.Config

	local newHealth =
		math.clamp(

			Humanoid.Health
			-
			config.Damage.Amount,

			0,

			Humanoid.MaxHealth
		)

	Humanoid.Health =
		newHealth

	task.spawn(
		entity.RunCallback,
		entity,
		"OnDamagePlayer",
		newHealth
	)

	if newHealth == 0 then

		-- \\ Jumpscare // --

		task.spawn(function()

			PlayJumpscare(
				config.Jumpscare
			)

		end)

		-- \\ Death hints // --

		if #config.Death.Hints > 0 then

			PlayerGui.MainUI.Death
				:GetPropertyChangedSignal(
					"Visible"
				)
				:Wait()

			local colour

			for name, values in next,
				Storage.DeathTypes
			do

				if table.find(
					values,
					config.Death.Type:lower()
				) then

					colour =
						name

				end
			end

			if not colour then

				for _, c in next,
					PlayerGui.MainUI.Initiator.Main_Game.Health.Music:GetChildren()
				do

					if c.Name:lower()
						==
						config.Death.Type:lower()
					then

						colour =
							c.Name

					end
				end
			end

			if not colour then
				colour = "Blue"
			end

			if firesignal then

				firesignal(

					Remotes.DeathHint.OnClientEvent,

					config.Death.Hints,

					colour
				)

			else

				warn(
					debug.traceback(
						"function 'firesignal' not supported by exploit, ignoring death hints"
					)
				)
			end
		end

		-- \\ Death cause // --

		local cause =
			config.Death.Cause

		-- Fixed condition:
		-- use entity name when Cause is empty/invalid

		if typeof(cause) ~= "string"
			or cause == ""
		then

			cause =
				config.Entity.Name
		end

		local playerStats =
			GameStats:FindFirstChild(
				"Player_" .. LocalPlayer.Name
			)

		if playerStats then

			local total =
				playerStats:FindFirstChild(
					"Total"
				)

			if total then

				local deathCause =
					total:FindFirstChild(
						"DeathCause"
					)

				if deathCause then

					deathCause.Value =
						cause
				end
			end
		end
	end
end

-- \\ Nodes // --

local function GetNodesFromRoom(
	room: Model,
	reversed: boolean
): { BasePart }

	local nodes = {}

	local roomEntrance =
		room:FindFirstChild(
			"RoomEntrance"
		)

	if roomEntrance then

		local n =
			roomEntrance:Clone()

		n.Name =
			"0"

		n.CFrame -=
			Vector3.new(
				0,
				3,
				0
			)

		nodes[1] =
			n
	end

	local nodesFolder =
		room:FindFirstChild(
			"PathfindNodes"
		)

	if nodesFolder then

		for _, n in next,
			nodesFolder:GetChildren()
		do

			nodes[#nodes + 1] =
				n

		end
	end

	local roomExit =
		room:FindFirstChild(
			"RoomExit"
		)

	if roomExit then

		local index =
			#nodes + 1

		local n =
			roomExit:Clone()

		n.Name =
			tostring(index)

		n.CFrame -=
			Vector3.new(
				0,
				3,
				0
			)

		nodes[index] =
			n
	end

	table.sort(

		nodes,

		function(
			a: BasePart,
			b: BasePart
		)

			local aNumber =
				tonumber(a.Name)
				or 0

			local bNumber =
				tonumber(b.Name)
				or 0

			if reversed then

				return aNumber >
					bNumber

			else

				return aNumber <
					bNumber

			end
		end
	)

	return nodes
end

local function GetPathfindNodesAmbush(
	config: any
): { BasePart }

	local pathfindNodes = {}

	local rooms =
		CurrentRooms:GetChildren()

	if config.Movement.Reversed ==
		false
	then

		for i = 1,
			#rooms,
			1
		do

			local room =
				rooms[i]

			local roomNodes =
				GetNodesFromRoom(
					room,
					false
				)

			for _, node in next,
				roomNodes
			do

				pathfindNodes[#pathfindNodes + 1] =
					node
			end
		end

	else

		for i = #rooms,
			1,
			-1
		do

			local room =
				rooms[i]

			local roomNodes =
				GetNodesFromRoom(
					room,
					true
				)

			for _, node in next,
				roomNodes
			do

				pathfindNodes[#pathfindNodes + 1] =
					node
			end
		end
	end

	return pathfindNodes
end

local function GetPathfindNodesBlitz(
	config: any
): ({ BasePart }, { BasePart })

	local nodesToCurrent = {}

	local nodesToEnd = {}

	local currentRoomIndex =
		tonumber(
			LocalPlayer:GetAttribute(
				"CurrentRoom"
			)
		)
		or 0

	local rooms =
		CurrentRooms:GetChildren()

	if config.Movement.Reversed ==
		false
	then

		for _, room in next,
			rooms
		do

			local roomNodes =
				GetNodesFromRoom(
					room,
					false
				)

			local roomIndex =
				tonumber(
					room.Name
				)
				or 0

			for _, node in next,
				roomNodes
			do

				if roomIndex <=
					currentRoomIndex
				then

					nodesToCurrent[
						#nodesToCurrent + 1
					] =
						node

				else

					nodesToEnd[
						#nodesToEnd + 1
					] =
						node

				end
			end
		end

	else

		for i = #rooms,
			1,
			-1
		do

			local room =
				rooms[i]

			local roomNodes =
				GetNodesFromRoom(
					room,
					true
				)

			local roomIndex =
				tonumber(
					room.Name
				)
				or 0

			for _, node in next,
				roomNodes
			do

				if roomIndex >=
					currentRoomIndex
				then

					nodesToCurrent[
						#nodesToCurrent + 1
					] =
						node

				else

					nodesToEnd[
						#nodesToEnd + 1
					] =
						node

				end
			end
		end
	end

	return nodesToCurrent,
		nodesToEnd
end

-- \\ Entity movement // --

local function EntityMoveTo(
	model: Model,
	cframe: CFrame,
	speed: number
)

	if not model
		or not model.Parent
	then

		return
	end

	local reached =
		false

	local connection

	connection =
		RunService.Stepped:Connect(

			function(
				_,
				step
			)

				if not model.Parent then

					connection:Disconnect()

					reached =
						true

					return
				end

				if not model:GetAttribute(
					"Paused"
				) then

					local pivot =
						model:GetPivot()

					local difference =
						cframe.Position
						-
						pivot.Position

					local magnitude =
						difference.Magnitude

					if magnitude > 0.1 then

						local unit =
							difference.Unit

						model:PivotTo(

							pivot
							+
							unit
							*
							math.min(
								step * speed,
								magnitude
							)
						)

					else

						connection:Disconnect()

						reached =
							true
					end
				end
			end
		)

	repeat

		RunService.Stepped:Wait()

	until reached
end

-- \\ Earthquake // --

local function Earthquake()

	if not Assets.Earthquake then
		return
	end

	pcall(function()

		Modules.Main_Game.camShaker:ShakeOnce(
			4,
			12,
			1,
			5
		)

		Modules.Main_Game.camShaker:ShakeOnce(
			10,
			2,
			3,
			3
		)

		Assets.Earthquake.SoundEarthquake:Play()
	end)

	local tagged =
		CollectionService:GetTagged(
			"PartCeiling"
		)

	local particles = {}

	for _, ceiling in next,
		tagged
	do

		if not ceiling:IsA(
			"BasePart"
		) then

			continue

		end

		local amount =
			math.clamp(
				ceiling.Size.Magnitude
				*
				0.7,
				0,
				150
			)

		for _, particle in
			Assets.Earthquake.Particles:GetChildren()
		do

			local clone =
				particle:Clone()

			clone.Parent =
				ceiling

			clone:Emit(
				amount / 10
			)

			clone.Enabled =
				true

			table.insert(
				particles,
				clone
			)
		end
	end

	task.wait(4)

	for _, particle in next,
		particles
	do

		if particle.Parent then

			particle.Enabled =
				false

		end
	end
end

-- \\ Setup // --

for name, value in next,
	CONST.ATTR.PLAYER
do

	LocalPlayer:SetAttribute(
		name,
		value
	)
end

LastRespawn =
	tick()
	-
	(
		LocalPlayer:GetAttribute(
			"SpawnProtection"
		)
		or 5
	)

LocalPlayer.CharacterAdded:Connect(
	OnCharacterAdded
)

-- \\ Main Create // --

Module.Create =
	function(
		self,
		config: any
	): any?

		if typeof(config) ~= "table" then
			return
		end

		local newConfig =
			ApplyConfigDefaults(
				config,
				CONST.DEFAULT.CONFIG
			)

		newConfig.Movement.Speed =
			CONST.BASE_ENTITY_SPEED
			/
			100
			*
			(
				tonumber(
					newConfig.Movement.Speed
				)
				or 100
			)

		-- \\ Fetch entity model // --

		local asset =
			newConfig.Entity.Asset

		local success =
			false

		local entityModel =
			nil

		if typeof(asset) ==
			"Instance"
		then

			success =
				true

			entityModel =
				asset

		elseif typeof(asset) ==
			"string"
		then

			success,
			entityModel =
				pcall(function()

					local instance =
						LoadCustomInstance(
							asset
						)

					if typeof(instance) ~=
						"Instance"
					then

						error(
							"Failed to fetch entity model."
						)
					end

					if not instance:IsA(
						"Model"
					) then

						error(

							string.format(

								"Entity model invalid, expected Model but got '%s'",

								instance.ClassName
							)
						)
					end

					return instance
				end)
		end

		if not (
			success
			and entityModel
		) then

			warn(
				"Failed to load entity model:",
				newConfig.Entity.Name
			)

			return
		end

		-- \\ Model setup // --

		local rootPart =
			entityModel.PrimaryPart
			or entityModel:FindFirstChildWhichIsA(
				"BasePart",
				true
			)

		if not rootPart then

			warn(
				"No BasePart found for entity:",
				newConfig.Entity.Name
			)

			return
		end

		rootPart.Anchored =
			true

		entityModel.PrimaryPart =
			rootPart

		local name =
			newConfig.Entity.Name

		if typeof(name) ==
			"string"
			and name ~= ""
		then

			entityModel.Name =
				name
		end

		for attr, val in next,
			CONST.ATTR.ENTITY
		do

			entityModel:SetAttribute(
				attr,
				val
			)
		end

		local roomsEntered =
			Instance.new(
				"Configuration"
			)

		roomsEntered.Name =
			"RoomsEntered"

		roomsEntered.Parent =
			entityModel

		local entity = {

			Model =
				entityModel,

			Config =
				newConfig,

			Debug =
				CloneTable(
					CONST.DEFAULT.DEBUG
				)
		}

		entity.SetCallback =
			function(
				self,
				key: string,
				callback: any
			)

				assert(

					typeof(key) ==
						"string"
						and
						self.Debug[key],

					debug.traceback(
						"Callback key is invalid."
					)
				)

				assert(

					typeof(callback) ==
						"function",

					debug.traceback(
						"Callback must be a function."
					)
				)

				self.Debug[key] =
					callback
			end

		entity.RunCallback =
			function(
				self,
				key: string,
				...: any?
			)

				local callback =
					self.Debug[key]

				if typeof(callback) ==
					"function"
				then

					local success,
						result =
						pcall(
							callback,
							...
						)

					if not success then

						warn(

							string.format(

								"Error in callback '%s' for entity '%s':\n%s",

								key,

								self.Config.Entity.Name,

								result
							)
						)
					end
				end
			end

		entity.IsAlive =
			function(
				self
			): boolean

				return
					self.Model
					and
					self.Model.Parent ~= nil
			end

		entity.Pause =
			function(
				self
			)

				if self:IsAlive() then

					self.Model:SetAttribute(
						"Paused",
						true
					)
				end
			end

		entity.Resume =
			function(
				self
			)

				if self:IsAlive() then

					self.Model:SetAttribute(
						"Paused",
						false
					)
				end
			end

		entity.Run =
			function(
				self,
				copyEntity: boolean
			)

				Module:Run(
					self,
					copyEntity
				)
			end

		entity.Despawn =
			function(
				self
			)

				if self:IsAlive() then

					self.Model:Destroy()

				end

				local i =
					table.find(
						Module.ActiveEntities,
						self
					)

				if i then

					table.remove(
						Module.ActiveEntities,
						i
					)
				end

				task.spawn(
					self.RunCallback,
					self,
					"OnDespawned"
				)
			end

		return entity
	end

-- \\ Main Run // --

Module.Run =
	function(
		self,
		entity: any,
		copyEntity: boolean
	)

	-- \\ Copy // --

	if copyEntity == true then

		local copy =
			self:Create(
				entity.Config
			)

		if copy then
			self:Run(
				copy,
				false
			)
		end

		return
	end

	-- \\ Pre-run checks // --

	if not entity
		or not entity.Model
		or not entity.Model.Parent
	then

		return
	end

	if entity.Model:GetAttribute(
		"Running"
	) then

		return
	end

	local rebounding =
		entity.Config.Rebounding

	if
		rebounding.Enabled
		and
		(
			rebounding.Min <= 0
			or rebounding.Max <= 0
			or rebounding.Min >
				rebounding.Max
		)
	then

		error(

			string.format(

				"Invalid rebounding minmax values: %s - %s",

				rebounding.Min,

				rebounding.Max
			)
		)
	end

	-- \\ Setup // --

	local model =
		entity.Model

	local config =
		entity.Config

	local debug =
		entity.Debug

	model:SetAttribute(
		"Running",
		true
	)

	self.ActiveEntities[
		#self.ActiveEntities + 1
	] =
		entity

	-- \\ Spawning // --

	local spawnPoint: BasePart? =
		nil

	do

		local rooms =
			CurrentRooms:GetChildren()

		if #rooms == 0 then
			return
		end

		if config.Movement.Reversed then

			spawnPoint =
				rooms[#rooms]:FindFirstChild(
					"RoomExit"
				)

		else

			spawnPoint =
				rooms[1]:FindFirstChild(
					"RoomEntrance"
				)
		end
	end

	if not spawnPoint then

		warn(

			string.format(

				"Failed to find spawn point for entity: '%s'",

				config.Entity.Name
			)
		)

		entity:Despawn()

		return
	end

	model:PivotTo(

		spawnPoint.CFrame
		+
		Vector3.new(
			0,
			config.Entity.HeightOffset,
			0
		)
	)

	model.Parent =
		workspace

	task.spawn(
		entity.RunCallback,
		entity,
		"OnSpawned"
	)

	local currentRoom =
		GetCurrentRoom(false)

	if currentRoom then

		-- Flickering

		if config.Lights.Flicker.Enabled then

			Modules.Module_Events.flicker(

				currentRoom,

				config.Lights.Flicker.Duration
			)
		end

		-- Earthquake

		if config.Earthquake.Enabled then

			task.spawn(
				Earthquake
			)
		end
	end

	task.wait(
		config.Movement.Delay
	)

	-- \\ Movement / detection // --

	task.spawn(
		entity.RunCallback,
		entity,
		"OnStartMoving"
	)

	task.spawn(function()

		while entity:IsAlive()
			and task.wait()
		do

			if model:GetAttribute(
				"Paused"
			) then

				continue
			end

			if not RootPart
				or not RootPart.Parent
			then

				continue
			end

			local origin =
				model:GetPivot().Position

			local charOrigin =
				RootPart.Position

			-- \\ Sight // --

			local inSight =
				false

			if
				(
					charOrigin
					-
					origin
				).Magnitude
				<=
				config.Damage.Range
			then

				local params =
					RaycastParams.new()

				params.FilterType =
					Enum.RaycastFilterType.Exclude

				params.FilterDescendantsInstances = {

					Character,

					model,

					CollectionService:GetTagged(
						"HidingSpot"
					)
				}

				inSight =
					workspace:Raycast(

						origin,

						charOrigin
						-
						origin,

						params

					) == nil
			end

			-- \\ Look detection // --

			if Humanoid.Health > 0 then

				local _, isVisible =
					Camera:WorldToViewportPoint(
						origin
					)

				if isVisible then

					task.spawn(

						entity.RunCallback,

						entity,

						"OnLookAt",

						inSight
					)
				end
			end

			-- \\ Room detection // --

			do

				local room =
					GetRoomAtPoint(
						origin
					)

				if room then

					local index =
						tonumber(
							room.Name
						)

					if
						index
						and index >= 0
						and index ~=
							model:GetAttribute(
								"LastEnteredRoom"
							)
					then

						model:SetAttribute(
							"LastEnteredRoom",
							index
						)

						local entered =
							model:FindFirstChild(
								"RoomsEntered"
							)

						if entered then

							local firstTime =
								entered:GetAttribute(
									room.Name
								) == nil

							task.spawn(

								entity.RunCallback,

								entity,

								"OnEnterRoom",

								room,

								firstTime
							)

							if firstTime then

								entered:SetAttribute(
									room.Name,
									true
								)
							end

							local latestRoom =
								GetCurrentRoom(true)

							if room ~=
								latestRoom
							then

								if config.Lights.Shatter then

									Modules.Module_Events.shatter(
										room
									)

								elseif config.Lights.Repair then

									FixRoomLights(
										room
									)
								end
							end
						end
					end
				end
			end

			-- \\ Crucifix detection // --

			local usedCrucifix =
				false

			do

				local crucifixion =
					config.Crucifixion

				if

					crucifixion.Enabled
					and crucifixion.Range > 0
					and (
						charOrigin
						-
						origin
					).Magnitude
					<=
					crucifixion.Range
					and inSight

				then

					local hasTool,
						tool =
						HasEquipped(
							"Crucifix"
						)

					if
						hasTool
						and tool
						and not model:GetAttribute(
							"BeingBanished"
						)
					then

						if typeof(
							debug.CrucifixionOverwrite
						)
						==
						"function"
						then

							entity:RunCallback(
								"CrucifixionOverwrite"
							)

						else

							tool:Destroy()

							model:SetAttribute(
								"Paused",
								true
							)

							CrucifixEntity(
								entity
							)
						end

						usedCrucifix =
							true
					end
				end
			end

			-- \\ Damage detection // --

			if
				not model:GetAttribute(
					"Paused"
				)
				and not usedCrucifix
			then

				local damage =
					config.Damage

				if

					damage.Enabled
					and damage.Range > 0
					and Humanoid.Health > 0
					and (
						not Character:GetAttribute(
							"Hiding"
						)
						or
						damage.IgnoreHiding
					)
					and model:GetAttribute(
						"Damage"
					)
					and not model:GetAttribute(
						"BeingBanished"
					)
					and (
						charOrigin
						-
						origin
					).Magnitude
					<=
					damage.Range
					and inSight

				then

					model:SetAttribute(
						"Damage",
						false
					)

					DamagePlayer(
						entity
					)
				end
			end

			-- \\ Camera shake // --

			do

				local camShake =
					config.CameraShake

				if camShake.Enabled then

					local mag =
						(
							charOrigin
							-
							origin
						).Magnitude

					if mag <=
						camShake.Range
					then

						local cloned = {}

						for i, v in next,
							camShake.Values
						do

							cloned[i] =
								v
						end

						cloned[1] =
							camShake.Values[1]
							/
							camShake.Range
							*
							(
								camShake.Range
								-
								mag
							)

						cloned[2] =
							camShake.Values[2]
							/
							camShake.Range
							*
							(
								camShake.Range
								-
								mag
							)

						Modules.Main_Game.camShaker:
							ShakeOnce(
								table.unpack(
									cloned
								)
							)
					end
				end
			end
		end
	end)

	-- \\ Pathfinding // --

	task.spawn(function()

		local reboundType =
			config.Rebounding.Type:upper()

		-- \\ Ambush // --

		if reboundType ==
			"AMBUSH"
		then

			local pathfindNodes =
				GetPathfindNodesAmbush(
					config
				)

			for _, v in next,
				pathfindNodes
			do

				if not entity:IsAlive() then
					return
				end

				local cframe =
					v.CFrame
					+
					Vector3.new(
						0,
						3
						+
						config.Entity.HeightOffset,
						0
					)

				EntityMoveTo(
					model,
					cframe,
					config.Movement.Speed
				)

				task.spawn(

					entity.RunCallback,

					entity,

					"OnReachedNode",

					v
				)
			end

			-- \\ Rebounding // --

			if config.Rebounding.Enabled then

				local reboundsCount =
					math.random(
						config.Rebounding.Min,
						config.Rebounding.Max
					)

				for i = 1,
					reboundsCount
				do

					if not entity:IsAlive() then
						return
					end

					task.wait(
						config.Rebounding.Delay
					)

					model:SetAttribute(
						"Damage",
						true
					)

					task.spawn(

						entity.RunCallback,

						entity,

						"OnRebounding",

						true
					)

					-- Backwards

					for i = #pathfindNodes,
						1,
						-1
					do

						if not entity:IsAlive() then
							return
						end

						local v =
							pathfindNodes[i]

						local cframe =
							v.CFrame
							+
							Vector3.new(
								0,
								3
								+
								config.Entity.HeightOffset,
								0
							)

						EntityMoveTo(
							model,
							cframe,
							config.Movement.Speed
						)

						task.spawn(

							entity.RunCallback,

							entity,

							"OnReachedNode",

							v
						)
					end

					task.spawn(

						entity.RunCallback,

						entity,

						"OnRebounding",

						false
					)

					task.wait(
						config.Rebounding.Delay
					)

					model:SetAttribute(
						"Damage",
						true
					)

					task.spawn(

						entity.RunCallback,

						entity,

						"OnRebounding",

						true
					)

					pathfindNodes =
						GetPathfindNodesAmbush(
							config
						)

					-- Forwards

					for _, v in next,
						pathfindNodes
					do

						if not entity:IsAlive() then
							return
						end

						local cframe =
							v.CFrame
							+
							Vector3.new(
								0,
								3
								+
								config.Entity.HeightOffset,
								0
							)

						EntityMoveTo(
							model,
							cframe,
							config.Movement.Speed
						)

						task.spawn(

							entity.RunCallback,

							entity,

							"OnReachedNode",

							v
						)
					end

					task.spawn(

						entity.RunCallback,

						entity,

						"OnRebounding",

						false
					)

					if i < reboundsCount then

						task.wait(
							config.Rebounding.Delay
						)
					end
				end
			end

		-- \\ Blitz // --

		elseif reboundType ==
			"BLITZ"
		then

			local nodesToCurrent =
				GetPathfindNodesBlitz(
					config
				)

			for _, n in next,
				nodesToCurrent
			do

				if not entity:IsAlive() then
					return
				end

				local cframe =
					n.CFrame
					+
					Vector3.new(
						0,
						3
						+
						config.Entity.HeightOffset,
						0
					)

				EntityMoveTo(
					model,
					cframe,
					config.Movement.Speed
				)

				task.spawn(

					entity.RunCallback,

					entity,

					"OnReachedNode",

					n
				)
			end

			-- \\ Rebounding // --

			if config.Rebounding.Enabled then

				local currentRoom =
					GetCurrentRoom(false)

				if not currentRoom then

					warn(
						"Failed to obtain current room."
					)

					return
				end

				local roomNodes =
					GetNodesFromRoom(
						currentRoom,
						config.Movement.Reversed
					)

				if #roomNodes <= 1 then

					warn(
						"Failed to obtain enough current room nodes."
					)

					return
				end

				local randomNode

				if config.Movement.Reversed ==
					false
				then

					randomNode =
						roomNodes[
							math.random(
								1,
								#roomNodes - 1
							)
						]

				else

					randomNode =
						roomNodes[
							math.random(
								2,
								#roomNodes
							)
						]
				end

				if not randomNode then
					return
				end

				for _ = 1,
					math.random(
						config.Rebounding.Min,
						config.Rebounding.Max
					)
				do

					if not entity:IsAlive() then
						return
					end

					model:SetAttribute(
						"Damage",
						true
					)

					task.spawn(

						entity.RunCallback,

						entity,

						"OnRebounding",

						true
					)

					local nodeIndex =
						tonumber(
							randomNode.Name
						)
						or 1

					for i = #roomNodes,
						nodeIndex,
						-1
					do

						local index =
							math.clamp(
								i,
								1,
								#roomNodes
							)

						local node =
							roomNodes[index]

						local cframe =
							node.CFrame
							+
							Vector3.new(
								0,
								3
								+
								config.Entity.HeightOffset,
								0
							)

						EntityMoveTo(
							model,
							cframe,
							config.Movement.Speed
						)

						task.spawn(

							entity.RunCallback,

							entity,

							"OnReachedNode",

							node
						)
					end

					task.wait(
						config.Rebounding.Delay
					)

					model:SetAttribute(
						"Damage",
						true
					)

					task.spawn(

						entity.RunCallback,

						entity,

						"OnRebounding",

						false
					)

					for i = nodeIndex,
						#roomNodes
					do

						local index =
							math.clamp(
								i,
								1,
								#roomNodes
							)

						local node =
							roomNodes[index]

						local cframe =
							node.CFrame
							+
							Vector3.new(
								0,
								3
								+
								config.Entity.HeightOffset,
								0
							)

						EntityMoveTo(
							model,
							cframe,
							config.Movement.Speed
						)

						task.spawn(

							entity.RunCallback,

							entity,

							"OnReachedNode",

							node
						)
					end
				end
			end

			local _,
				updatedToEnd =
				GetPathfindNodesBlitz(
					config
				)

			for _, n in next,
				updatedToEnd
			do

				if not entity:IsAlive() then
					return
				end

				local cframe =
					n.CFrame
					+
					Vector3.new(
						0,
						3
						+
						config.Entity.HeightOffset,
						0
					)

				EntityMoveTo(
					model,
					cframe,
					config.Movement.Speed
				)

				task.spawn(

					entity.RunCallback,

					entity,

					"OnReachedNode",

					n
				)
			end
		end

		-- \\ Despawn // --

		if
			model.Parent
			and
			not model:GetAttribute(
				"Despawning"
			)
		then

			model:SetAttribute(
				"Despawning",
				true
			)

			task.spawn(

				entity.RunCallback,

				entity,

				"OnDespawning"
			)

			if model.Parent then

				EntityMoveTo(

					model,

					model:GetPivot()
					-
					Vector3.new(
						0,
						300,
						0
					),

					config.Movement.Speed
				)

			end

			entity:Despawn()
		end
	end)
end

-- \\ Internal setup // --

if not getgenv()._internal_vynixu_entity_spawner then

	getgenv()._internal_vynixu_entity_spawner =
		true

	local function GetAmbient(
		room: Model
	): Color3

		return

			room:GetAttribute(
				"AmbientOriginal"
			)

			or

			room:GetAttribute(
				"Ambient"
			)

			or

			Color3.fromRGB(
				67,
				51,
				56
			)
	end

	for _, room in next,
		CurrentRooms:GetChildren()
	do

		Storage.Ambient[room] =
			GetAmbient(room)
	end

	Module.Connections[
		#Module.Connections + 1
	] =
		CurrentRooms.ChildAdded:Connect(
			function(room: Model)

				Storage.Ambient[room] =
					GetAmbient(room)
			end
		)

	Module.Connections[
		#Module.Connections + 1
	] =
		workspace.DescendantRemoving:Connect(
			function(instance: Instance)

				if instance.Name ==
					"PathfindNodes"
				then

					local latestRoom =
						GetCurrentRoom(true)

					if latestRoom
						and not latestRoom:FindFirstChild(
							"PathfindNodes"
						)
					then

						local clone =
							instance:Clone()

						clone.Parent =
							latestRoom
					end
				end
			end
		)
end

-- \\ Clear // --

Module.Clear =
	function(self)

		local entities = {}

		for _, entity in next,
			self.ActiveEntities
		do

			entities[
				#entities + 1
			] =
				entity
		end

		for _, entity in next,
			entities
		do

			if entity:IsAlive() then

				entity:Despawn()

			end
		end
	end

-- \\ Unload // --

Module.Unload =
	function(self)

		self:Clear()

		for i, connection in next,
			self.Connections
		do

			if connection then

				connection:Disconnect()

			end

			self.Connections[i] =
				nil
		end

		for i in next,
			self
		do

			self[i] =
				nil
		end
	end

-- \\ Export // --

getgenv().VynixuEntitySpawnerV2 =
	Module

return Module