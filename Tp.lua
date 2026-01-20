--// SERVICES
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer

--// GUI
local gui = Instance.new("ScreenGui", player.PlayerGui)
gui.Name = "SimpleESP_TP_GUI"
gui.ResetOnSpawn = false

local main = Instance.new("Frame", gui)
main.Size = UDim2.fromScale(0.35, 0.45)
main.Position = UDim2.fromScale(0.33, 0.25)
main.BackgroundColor3 = Color3.fromRGB(25,25,25)
main.Active = true
main.Draggable = true

--// TITLE
local title = Instance.new("TextLabel", main)
title.Size = UDim2.fromScale(1, 0.15)
title.Text = "ESP + TP SCRIPT"
title.TextScaled = true
title.BackgroundColor3 = Color3.fromRGB(40,40,40)
title.TextColor3 = Color3.new(1,1,1)

--// TABS
local espTab = Instance.new("Frame", main)
local tpTab = Instance.new("Frame", main)

espTab.Size = UDim2.fromScale(1, 0.85)
espTab.Position = UDim2.fromScale(0, 0.15)
tpTab.Size = espTab.Size
tpTab.Position = espTab.Position
tpTab.Visible = false

--// TAB BUTTONS
local btnESP = Instance.new("TextButton", main)
btnESP.Size = UDim2.fromScale(0.5, 0.08)
btnESP.Position = UDim2.fromScale(0, 0.15)
btnESP.Text = "ESP TAB"

local btnTP = Instance.new("TextButton", main)
btnTP.Size = UDim2.fromScale(0.5, 0.08)
btnTP.Position = UDim2.fromScale(0.5, 0.15)
btnTP.Text = "TP TAB"

btnESP.MouseButton1Click:Connect(function()
	espTab.Visible = true
	tpTab.Visible = false
end)

btnTP.MouseButton1Click:Connect(function()
	espTab.Visible = false
	tpTab.Visible = true
end)

------------------------------------------------
-- 🔴 ESP PART
------------------------------------------------
local espEnabled = false
local espObjects = {}

local function clearESP()
	for _,v in pairs(espObjects) do
		if v then v:Destroy() end
	end
	espObjects = {}
end

local function createESP()
	clearESP()
	for _,obj in pairs(workspace:GetDescendants()) do
		if obj:IsA("BasePart") and obj.Name == "AFK HEAD" then
			local box = Instance.new("BoxHandleAdornment")
			box.Size = obj.Size
			box.Adornee = obj
			box.Color3 = Color3.new(1,0,0)
			box.Transparency = 0.5
			box.AlwaysOnTop = true
			box.Parent = obj
			table.insert(espObjects, box)
		end
	end
end

local espBtn = Instance.new("TextButton", espTab)
espBtn.Size = UDim2.fromScale(0.8, 0.15)
espBtn.Position = UDim2.fromScale(0.1, 0.1)
espBtn.Text = "ESP: OFF"

espBtn.MouseButton1Click:Connect(function()
	espEnabled = not espEnabled
	espBtn.Text = espEnabled and "ESP: ON" or "ESP: OFF"
	if espEnabled then
		createESP()
	else
		clearESP()
	end
end)

------------------------------------------------
-- 🔵 TP PART
------------------------------------------------
local function tpTo(x,y,z)
	local char = player.Character
	if char and char:FindFirstChild("HumanoidRootPart") then
		char.HumanoidRootPart.CFrame = CFrame.new(x,y,z)
	end
end

local function CreateTPButton(name, yPos, x, y, z)
	local btn = Instance.new("TextButton", tpTab)
	btn.Size = UDim2.fromScale(0.8, 0.12)
	btn.Position = UDim2.fromScale(0.1, yPos)
	btn.Text = name
	btn.MouseButton1Click:Connect(function()
		tpTo(x,y,z)
	end)
end

-- 🔽 DÁN VỊ TRÍ TP Ở ĐÂY 🔽

CreateTPButton("TP Vị Trí 1", 0.1,
	-90.03816986083984,
	2.284198760986328,
	83.40685272216797
)

-- COPY THÊM NÚT BÊN DƯỚI NẾU MUỐN
-- CreateTPButton("TP Vị Trí 2", 0.25, X, Y, Z)
