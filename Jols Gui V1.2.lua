-- Optimized Roblox Graphics Menu
-- LocalScript in StarterPlayerScripts

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local Workspace = game:GetService("Workspace")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Remove old GUI
local oldGui = playerGui:FindFirstChild("GraphicsMenu")
if oldGui then oldGui:Destroy() end

-- ScreenGui
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "GraphicsMenu"
screenGui.ResetOnSpawn = false
screenGui.Parent = playerGui

-- Main frame
local frame = Instance.new("Frame")
frame.Name = "MainFrame"
frame.Size = UDim2.new(0, 300, 0, 400)
frame.Position = UDim2.new(0, 20, 0, 20)
frame.BackgroundColor3 = Color3.fromRGB(30,30,30)
frame.BorderColor3 = Color3.fromRGB(80,80,80)
frame.BorderSizePixel = 2
frame.Parent = screenGui

-- Title
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -40, 0, 30)
title.Position = UDim2.new(0, 10, 0, 10)
title.BackgroundTransparency = 1
title.Text = "Graphics Menu"
title.TextColor3 = Color3.fromRGB(230,230,230)
title.Font = Enum.Font.SourceSansBold
title.TextSize = 20
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = frame

-- Close button
local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0,30,0,30)
closeBtn.Position = UDim2.new(1,-35,0,5)
closeBtn.Text = "X"
closeBtn.Font = Enum.Font.SourceSansBold
closeBtn.TextSize = 20
closeBtn.BackgroundColor3 = Color3.fromRGB(180,50,50)
closeBtn.TextColor3 = Color3.new(1,1,1)
closeBtn.BorderSizePixel = 1
closeBtn.Parent = frame

-- Helper functions
local function createButton(text, yPos, bgColor)
	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(1, -20, 0, 35)
	btn.Position = UDim2.new(0, 10, 0, yPos)
	btn.Text = text
	btn.Font = Enum.Font.SourceSansBold
	btn.TextSize = 18
	btn.BackgroundColor3 = bgColor
	btn.TextColor3 = Color3.new(1,1,1)
	btn.BorderSizePixel = 1
	btn.Parent = frame
	return btn
end

local function createRGBSlider(labelText, yPos, initialValue)
	local lbl = Instance.new("TextLabel")
	lbl.Size = UDim2.new(0,260,0,20)
	lbl.Position = UDim2.new(0,10,0,yPos)
	lbl.BackgroundTransparency = 1
	lbl.Text = labelText..": "..initialValue
	lbl.TextColor3 = Color3.fromRGB(230,230,230)
	lbl.Font = Enum.Font.SourceSans
	lbl.TextSize = 14
	lbl.TextXAlignment = Enum.TextXAlignment.Left
	lbl.Parent = frame

	local slider = Instance.new("Frame")
	slider.Size = UDim2.new(1,-20,0,15)
	slider.Position = UDim2.new(0,10,0,yPos+20)
	slider.BackgroundColor3 = Color3.fromRGB(180,180,180)
	slider.BorderSizePixel = 0
	slider.Parent = frame

	local sliderFill = Instance.new("Frame")
	sliderFill.Size = UDim2.new(initialValue/255,0,1,0)
	sliderFill.BackgroundColor3 = Color3.fromRGB(100,100,255)
	sliderFill.BorderSizePixel = 0
	sliderFill.Parent = slider

	local draggingSlider = false

	local function update(x)
		local localX = math.clamp(x - slider.AbsolutePosition.X, 0, slider.AbsoluteSize.X)
		local percent = localX / slider.AbsoluteSize.X
		sliderFill.Size = UDim2.new(percent,0,1,0)
		local value = math.floor(percent*255)
		lbl.Text = labelText..": "..value
		return value
	end

	slider.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			draggingSlider = true
			update(input.Position.X)
			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					draggingSlider = false
				end
			end)
		end
	end)

	UserInputService.InputChanged:Connect(function(input)
		if draggingSlider and input.UserInputType == Enum.UserInputType.MouseMovement then
			update(input.Position.X)
		end
	end)

	return sliderFill
end

-- Buttons
local potatoButton = createButton("Enable Potato", 50, Color3.fromRGB(80,160,80))
local fpsButton = createButton("Show FPS", 95, Color3.fromRGB(180,0,180))
local shaderButton = createButton("Enable Shaders", 140, Color3.fromRGB(150,75,0))

-- RGB sliders
local rFill = createRGBSlider("Red", 185, 255)
local gFill = createRGBSlider("Green", 215, 220)
local bFill = createRGBSlider("Blue", 245, 200)

-- FPS Label
local fpsLabel = Instance.new("TextLabel")
fpsLabel.Size = UDim2.new(0, 260, 0, 20)
fpsLabel.Position = UDim2.new(0,10,0,355)
fpsLabel.BackgroundTransparency = 1
fpsLabel.TextColor3 = Color3.fromRGB(230,230,230)
fpsLabel.Font = Enum.Font.SourceSans
fpsLabel.TextSize = 14
fpsLabel.TextXAlignment = Enum.TextXAlignment.Left
fpsLabel.Text = "FPS: 0"
fpsLabel.Parent = frame

-- Frame dragging
local draggingFrame = false
local dragStartPos, frameStartPos = Vector2.new(), Vector2.new()
local function isDraggableTarget(guiObj)
	if not guiObj then return true end
	if guiObj:IsA("TextButton") or guiObj:IsA("Frame") or guiObj:IsA("TextLabel") then
		return false
	end
	return true
end

frame.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		local mousePos = UserInputService:GetMouseLocation()
		if isDraggableTarget(input.Target) then
			draggingFrame = true
			dragStartPos = mousePos
			frameStartPos = Vector2.new(frame.Position.X.Offset, frame.Position.Y.Offset)
		end
	end
end)

frame.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		draggingFrame = false
	end
end)

UserInputService.InputChanged:Connect(function(input)
	if draggingFrame and input.UserInputType == Enum.UserInputType.MouseMovement then
		local mousePos = UserInputService:GetMouseLocation()
		local delta = mousePos - dragStartPos
		frame.Position = UDim2.new(0, frameStartPos.X + delta.X, 0, frameStartPos.Y + delta.Y)
	end
end)

-- === Potato Mode (Async) ===
local original = {lighting={}, instances={}}
local function recordProperty(inst, prop, val)
	if not inst or not inst:IsDescendantOf(game) then return end
	original.instances[inst] = original.instances[inst] or {}
	if original.instances[inst][prop] == nil then
		local ok,v = pcall(function() return inst[prop] end)
		if ok then original.instances[inst][prop] = v end
	end
	pcall(function() inst[prop] = val end)
end

local function processInstance(inst)
	if inst:IsA("BasePart") then
		recordProperty(inst,"Material",Enum.Material.Plastic)
		recordProperty(inst,"CastShadow",false)
		recordProperty(inst,"Reflectance",0)
		recordProperty(inst,"TopSurface",Enum.SurfaceType.Smooth)
		recordProperty(inst,"BottomSurface",Enum.SurfaceType.Smooth)
	elseif inst:IsA("MeshPart") then
		recordProperty(inst,"Material",Enum.Material.Plastic)
		recordProperty(inst,"CastShadow",false)
		recordProperty(inst,"Reflectance",0)
		recordProperty(inst,"LocalTransparencyModifier",0)
	elseif inst:IsA("SpecialMesh") then
		recordProperty(inst,"LocalTransparencyModifier",0)
	elseif inst:IsA("Decal") or inst:IsA("Texture") then
		recordProperty(inst,"Transparency",1)
	elseif inst:IsA("ParticleEmitter") or inst:IsA("Trail") or inst:IsA("Beam")
	    or inst:IsA("Fire") or inst:IsA("Smoke") or inst:IsA("Sparkles") then
		recordProperty(inst,"Enabled",false)
	elseif inst:IsA("PointLight") or inst:IsA("SpotLight") or inst:IsA("SurfaceLight") then
		recordProperty(inst,"Enabled",false)
	elseif inst:IsA("Sound") then
		recordProperty(inst,"Volume",0)
	end
end

local potatoEnabled = false
local function applyPotato()
	if potatoEnabled then return end
	potatoEnabled = true

	-- Lighting
	original.lighting.GlobalShadows = Lighting.GlobalShadows
	original.lighting.Brightness = Lighting.Brightness
	original.lighting.OutdoorAmbient = Lighting.OutdoorAmbient
	original.lighting.Ambient = Lighting.Ambient
	original.lighting.FogStart = Lighting.FogStart
	original.lighting.FogEnd = Lighting.FogEnd
	Lighting.GlobalShadows = false
	Lighting.Brightness = 2
	Lighting.OutdoorAmbient = Color3.fromRGB(128,128,128)
	Lighting.Ambient = Color3.fromRGB(100,100,100)
	Lighting.FogStart = 1e5
	Lighting.FogEnd = 1e6

	-- Async processing
	local descendants = Workspace:GetDescendants()
	local batchSize = 50
	local index = 1
	spawn(function()
		while index <= #descendants do
			for i = index, math.min(index+batchSize-1,#descendants) do
				processInstance(descendants[i])
			end
			index = index + batchSize
			RunService.RenderStepped:Wait()
		end
	end)

	potatoButton.Text = "Disable Potato"
	potatoButton.BackgroundColor3 = Color3.fromRGB(180,80,80)
end

local function restoreGraphics()
	if not potatoEnabled then return end
	potatoEnabled = false

	if original.lighting then
		pcall(function()
			Lighting.GlobalShadows = original.lighting.GlobalShadows
			Lighting.Brightness = original.lighting.Brightness
			Lighting.OutdoorAmbient = original.lighting.OutdoorAmbient
			Lighting.Ambient = original.lighting.Ambient
			Lighting.FogStart = original.lighting.FogStart
			Lighting.FogEnd = original.lighting.FogEnd
		end)
	end

	for inst,props in pairs(original.instances) do
		if inst and inst.Parent then
			for prop,val in pairs(props) do
				pcall(function() inst[prop] = val end)
			end
		end
	end
	original.instances = {}

	potatoButton.Text = "Enable Potato"
	potatoButton.BackgroundColor3 = Color3.fromRGB(80,160,80)
end

potatoButton.MouseButton1Click:Connect(function()
	if potatoEnabled then restoreGraphics() else applyPotato() end
end)

-- === Shaders ===
local shadersEnabled = false
local bloomEffect, dofEffect, colorCorrection
local defaultFocusDistance = 30
local rValue,gValue,bValue = 1,0.86,0.78 -- your original colors

local function applyShaders()
	if shadersEnabled then return end
	shadersEnabled = true
	if bloomEffect then bloomEffect:Destroy() end
	if dofEffect then dofEffect:Destroy() end
	if colorCorrection then colorCorrection:Destroy() end

	bloomEffect = Instance.new("BloomEffect")
	bloomEffect.Intensity = 0.25
	bloomEffect.Threshold = 0.9
	bloomEffect.Size = 24
	bloomEffect.Parent = Lighting

	dofEffect = Instance.new("DepthOfFieldEffect")
	dofEffect.FocusDistance = defaultFocusDistance
	dofEffect.InFocusRadius = 50
	dofEffect.Parent = Lighting

	colorCorrection = Instance.new("ColorCorrectionEffect")
	colorCorrection.Saturation = 0.5
	colorCorrection.TintColor = Color3.new(rValue,gValue,bValue)
	colorCorrection.Parent = Lighting

	shaderButton.Text = "Disable Shaders"
end

local function disableShaders()
	if not shadersEnabled then return end
	shadersEnabled = false
	if bloomEffect then bloomEffect:Destroy() end
	if dofEffect then dofEffect:Destroy() end
	if colorCorrection then colorCorrection:Destroy() end
	shaderButton.Text = "Enable Shaders"
end

shaderButton.MouseButton1Click:Connect(function()
	if shadersEnabled then disableShaders() else applyShaders() end
end)

-- Update shaders color every frame
RunService.RenderStepped:Connect(function()
	if shadersEnabled and colorCorrection then
		colorCorrection.TintColor = Color3.new(rFill.Size.X.Scale, gFill.Size.X.Scale, bFill.Size.X.Scale)
	end
end)

-- FPS
local fpsEnabled = false
local lastTime = tick()
local frameCount = 0
RunService.RenderStepped:Connect(function()
	frameCount = frameCount + 1
	local now = tick()
	if now - lastTime >= 1 then
		if fpsEnabled then
			fpsLabel.Text = "FPS: "..frameCount
		else
			fpsLabel.Text = ""
		end
		frameCount = 0
		lastTime = now
	end
end)

fpsButton.MouseButton1Click:Connect(function()
	fpsEnabled = not fpsEnabled
end)

-- === Close button: restore all ===
closeBtn.MouseButton1Click:Connect(function()
	if potatoEnabled then restoreGraphics() end
	if shadersEnabled then disableShaders() end
	fpsEnabled = false
	fpsLabel.Text = ""
	frame.Visible = false
end)

print("Optimized Graphics Menu loaded for player:", player.Name)
