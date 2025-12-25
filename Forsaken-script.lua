-- Forsaken ESP GUI v1.0
-- Mobile / Delta
-- Dev: discordmrs7

-- ===== ANTI DUPLICATE =====
if getgenv().ForsakenESP_LOADED then
	warn("Forsaken ESP already loaded")
	return
end
getgenv().ForsakenESP_LOADED = true

warn("Forsaken ESP GUI Loaded")

-- ===== SERVICES =====
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer
local CoreGui = game:GetService("CoreGui")

-- ===== SETTINGS =====
local Settings = {
	KillerESP = true,
	SurvivorESP = true,
	ItemESP = true
}

local ESPObjects = {}

-- ===== GUI =====
local gui = Instance.new("ScreenGui", CoreGui)
gui.Name = "ForsakenESP_GUI"
gui.ResetOnSpawn = false

local main = Instance.new("Frame", gui)
main.Size = UDim2.new(0, 260, 0, 220)
main.Position = UDim2.new(0.5, -130, 0.5, -110)
main.BackgroundColor3 = Color3.fromRGB(25,25,25)
main.Active = true
main.Draggable = true

-- Title
local title = Instance.new("TextLabel", main)
title.Size = UDim2.new(1,0,0,40)
title.BackgroundColor3 = Color3.fromRGB(20,20,20)
title.Text = "Forsaken ESP"
title.TextScaled = true
title.TextColor3 = Color3.fromRGB(255,255,255)

-- Tabs
local tabFrame = Instance.new("Frame", main)
tabFrame.Size = UDim2.new(1,0,0,35)
tabFrame.Position = UDim2.new(0,0,0,40)
tabFrame.BackgroundTransparency = 1

local espTabBtn = Instance.new("TextButton", tabFrame)
espTabBtn.Size = UDim2.new(0.5,0,1,0)
espTabBtn.Text = "ESP"
espTabBtn.BackgroundColor3 = Color3.fromRGB(40,40,40)
espTabBtn.TextColor3 = Color3.new(1,1,1)

-- ESP Tab Content
local espTab = Instance.new("Frame", main)
espTab.Size = UDim2.new(1,0,1,-75)
espTab.Position = UDim2.new(0,0,0,75)
espTab.BackgroundTransparency = 1

-- Toggle creator
local function createToggle(parent, y, text, default, callback)
	local btn = Instance.new("TextButton", parent)
	btn.Size = UDim2.new(0, 220, 0, 35)
	btn.Position = UDim2.new(0,20,0,y)
	btn.BackgroundColor3 = Color3.fromRGB(45,45,45)
	btn.TextColor3 = Color3.new(1,1,1)
	btn.TextScaled = true

	local state = default
	btn.Text = text .. ": " .. (state and "ON" or "OFF")

	btn.MouseButton1Click:Connect(function()
		state = not state
		btn.Text = text .. ": " .. (state and "ON" or "OFF")
		callback(state)
	end)
end

createToggle(espTab, 10, "Killer ESP", true, function(v)
	Settings.KillerESP = v
end)

createToggle(espTab, 55, "Survivor ESP", true, function(v)
	Settings.SurvivorESP = v
end)

createToggle(espTab, 100, "Item ESP", true, function(v)
	Settings.ItemESP = v
end)

-- ===== ESP CORE =====
local function createESP(part, label, color, espType)
	if ESPObjects[part] then return end

	local box = Drawing.new("Square")
	box.Thickness = 1
	box.Filled = false
	box.Color = color

	local text = Drawing.new("Text")
	text.Center = true
	text.Outline = true
	text.Size = 13
	text.Text = label
	text.Color = color

	ESPObjects[part] = {
		box = box,
		text = text,
		type = espType
	}
end

RunService.RenderStepped:Connect(function()
	for part,data in pairs(ESPObjects) do
		if not part or not part.Parent then
			data.box:Remove()
			data.text:Remove()
			ESPObjects[part] = nil
			continue
		end

		local show = false
		if data.type == "KILLER" and Settings.KillerESP then show = true end
		if data.type == "SURVIVOR" and Settings.SurvivorESP then show = true end
		if data.type == "ITEM" and Settings.ItemESP then show = true end

		local pos, onScreen = Camera:WorldToViewportPoint(part.Position)
		if onScreen and show then
			data.box.Size = Vector2.new(36, 52)
			data.box.Position = Vector2.new(pos.X - 18, pos.Y - 26)
			data.box.Visible = true

			data.text.Position = Vector2.new(pos.X, pos.Y - 36)
			data.text.Visible = true
		else
			data.box.Visible = false
			data.text.Visible = false
		end
	end
end)

-- ===== ROLE DETECT =====
local function isKiller(player)
	if player.Character then
		for _,v in pairs(player.Character:GetChildren()) do
			if v:IsA("Tool") and v.Name:lower():find("knife") then
				return true
			end
		end
	end
	return false
end

-- ===== PLAYER ESP =====
local function setupPlayer(plr)
	if plr == LocalPlayer then return end

	plr.CharacterAdded:Connect(function(char)
		local hrp = char:WaitForChild("HumanoidRootPart",5)
		if not hrp then return end
		task.wait(0.4)

		if isKiller(plr) then
			createESP(hrp, "[KILLER] "..plr.Name, Color3.fromRGB(255,0,0), "KILLER")
		else
			createESP(hrp, "[SURVIVOR] "..plr.Name, Color3.fromRGB(0,255,0), "SURVIVOR")
		end
	end)
end

for _,p in pairs(Players:GetPlayers()) do
	setupPlayer(p)
end
Players.PlayerAdded:Connect(setupPlayer)

-- ===== ITEM ESP =====
for _,obj in pairs(workspace:GetDescendants()) do
	if obj:IsA("Tool") or obj:IsA("Model") then
		local part = obj:FindFirstChildWhichIsA("BasePart")
		if part then
			local n = obj.Name:lower()
			if n:find("med") or n:find("cola") then
				createESP(part, obj.Name, Color3.fromRGB(255,255,0), "ITEM")
			end
		end
	end
end
