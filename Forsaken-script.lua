-- Forsaken ESP + Infinite Stamina
-- Made for Forsaken (Players/Killers/Survivors structure)

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LP = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- ================= GUI =================
local ScreenGui = Instance.new("ScreenGui", game.CoreGui)
ScreenGui.Name = "ForsakenGUI"

local Main = Instance.new("Frame", ScreenGui)
Main.Size = UDim2.fromOffset(320, 260)
Main.Position = UDim2.fromScale(0.05, 0.25)
Main.BackgroundColor3 = Color3.fromRGB(25,25,25)
Main.Active, Main.Draggable = true, true

local Title = Instance.new("TextLabel", Main)
Title.Size = UDim2.fromScale(1, 0.18)
Title.Text = "Forsaken Test Script"
Title.TextSize = 18
Title.TextColor3 = Color3.new(1,1,1)
Title.BackgroundTransparency = 1

local function makeButton(text, y)
    local b = Instance.new("TextButton", Main)
    b.Size = UDim2.fromScale(0.9, 0.14)
    b.Position = UDim2.fromScale(0.05, y)
    b.Text = text
    b.TextColor3 = Color3.new(1,1,1)
    b.BackgroundColor3 = Color3.fromRGB(45,45,45)
    return b
end

local killerBtn = makeButton("Killer ESP : OFF", 0.22)
local survivorBtn = makeButton("Survivor ESP : OFF", 0.38)
local itemBtn = makeButton("Item ESP : OFF", 0.54)
local staminaBtn = makeButton("Infinite Stamina : OFF", 0.70)

-- ================= ESP CORE =================
local ESP = {}
local function clearESP()
    for _,v in pairs(ESP) do
        if v then v:Remove() end
    end
    table.clear(ESP)
end

local function boxESP(model, color)
    if not model:FindFirstChild("HumanoidRootPart") then return end
    local box = Drawing.new("Square")
    box.Thickness = 2
    box.Color = color
    box.Filled = false
    ESP[#ESP+1] = box

    RunService.RenderStepped:Connect(function()
        if not model or not model.Parent then
            box:Remove()
            return
        end
        local pos, vis = Camera:WorldToViewportPoint(model.HumanoidRootPart.Position)
        if vis then
            box.Size = Vector2.new(45, 65)
            box.Position = Vector2.new(pos.X - 22, pos.Y - 32)
            box.Visible = true
        else
            box.Visible = false
        end
    end)
end

-- ================= TOGGLES =================
local killerESP = false
killerBtn.MouseButton1Click:Connect(function()
    killerESP = not killerESP
    killerBtn.Text = "Killer ESP : "..(killerESP and "ON" or "OFF")
    clearESP()

    if killerESP then
        for _,plr in pairs(Players.Killers:GetChildren()) do
            if plr.Character then
                boxESP(plr.Character, Color3.fromRGB(255,0,0))
            end
        end
    end
end)

local survivorESP = false
survivorBtn.MouseButton1Click:Connect(function()
    survivorESP = not survivorESP
    survivorBtn.Text = "Survivor ESP : "..(survivorESP and "ON" or "OFF")
    clearESP()

    if survivorESP then
        for _,plr in pairs(Players.Survivors:GetChildren()) do
            if plr.Character then
                boxESP(plr.Character, Color3.fromRGB(0,255,0))
            end
        end
    end
end)

-- ================= ITEM ESP =================
local itemESP = false
itemBtn.MouseButton1Click:Connect(function()
    itemESP = not itemESP
    itemBtn.Text = "Item ESP : "..(itemESP and "ON" or "OFF")
    clearESP()

    if itemESP and workspace:FindFirstChild("ItemLocations") then
        for _,item in pairs(workspace.ItemLocations:GetDescendants()) do
            if item:IsA("BasePart") then
                local hl = Instance.new("Highlight", item)
                hl.FillColor = Color3.fromRGB(0,170,255)
                ESP[#ESP+1] = hl
            end
        end
    end
end)

-- ================= INFINITE STAMINA =================
local staminaON = false
staminaBtn.MouseButton1Click:Connect(function()
    staminaON = not staminaON
    staminaBtn.Text = "Infinite Stamina : "..(staminaON and "ON" or "OFF")
end)

RunService.Heartbeat:Connect(function()
    if staminaON then
        local ui = LP.PlayerGui:FindFirstChild("PlayerInfoDisplay", true)
        if ui and ui:FindFirstChild("Bars", true) then
            local bar = ui.Bars:FindFirstChild("Stamina", true)
            if bar then
                bar.Size = UDim2.fromScale(1, bar.Size.Y.Scale)
            end
        end
    end
end)
