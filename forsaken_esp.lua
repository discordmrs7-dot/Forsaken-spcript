
-- Forsaken ESP (Mobile / Delta)
-- Toggle bằng nút on-screen
-- Dev friendly
warn("Forsaken ESP Loaded")

if getgenv().ForsakenESP then return end
getgenv().ForsakenESP = true

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer
local CoreGui = game:GetService("CoreGui")

local ESP_ENABLED = true
local ESP_LIST = {}

-- ===== UI TOGGLE =====
local gui = Instance.new("ScreenGui")
gui.Name = "ForsakenESP_UI"
gui.Parent = CoreGui

local btn = Instance.new("TextButton")
btn.Size = UDim2.new(0, 140, 0, 45)
btn.Position = UDim2.new(0, 15, 0.5, -22)
btn.BackgroundColor3 = Color3.fromRGB(25,25,25)
btn.TextColor3 = Color3.fromRGB(255,255,255)
btn.TextScaled = true
btn.Text = "ESP : ON"
btn.Parent = gui

btn.MouseButton1Click:Connect(function()
	ESP_ENABLED = not ESP_ENABLED
	btn.Text = ESP_ENABLED and "ESP : ON" or "ESP : OFF"
end)

-- ===== ESP FUNCTION =====
local function createESP(part, textLabel, color)
	if not part then return end

	local box = Drawing.new("Square")
	box.Thickness = 1
	box.Filled = false
	box.Color = color

	local text = Drawing.new("Text")
	text.Center = true
	text.Outline = true
	text.Size = 13
	text.Text = textLabel
	text.Color = color

	ESP_LIST[part] = {box = box, text = text}

	RunService.RenderStepped:Connect(function()
		if not part or not part.Parent then
			box:Remove()
			text:Remove()
			ESP_LIST[part] = nil
			return
		end

		local pos, onScreen = Camera:WorldToViewportPoint(part.Position)
		if onScreen and ESP_ENABLED then
			box.Size = Vector2.new(40, 60)
			box.Position = Vector2.new(pos.X - 20, pos.Y - 30)
			box.Visible = true

			text.Position = Vector2.new(pos.X, pos.Y - 40)
			text.Visible = true
		else
			box.Visible = false
			text.Visible = false
		end
	end)
end

-- ===== PLAYER ESP =====
local function setupPlayer(plr)
	if plr == LocalPlayer then return end

	plr.CharacterAdded:Connect(function(char)
		local hrp = char:WaitForChild("HumanoidRootPart", 5)
		if not hrp then return end

		-- ⚠️ Nếu Forsaken dùng role khác, chỉnh chỗ này
		if plr.Team and plr.Team.Name == "Killer" then
			createESP(hrp, "[KILLER] "..plr.Name, Color3.fromRGB(255,0,0))
		else
			createESP(hrp, "[SURVIVOR] "..plr.Name, Color3.fromRGB(0,255,0))
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
			if n:find("med") then
				createESP(part, "MEDKIT", Color3.fromRGB(0,200,255))
			elseif n:find("cola") then
				createESP(part, "BLOXY COLA", Color3.fromRGB(255,255,0))
			end
		end
	end
end
