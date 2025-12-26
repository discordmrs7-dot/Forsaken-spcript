--=====================================
-- FORSAKEN TEST SCRIPT
-- ESP ITEM + INFINITE STAMINA
--=====================================

if game.CoreGui:FindFirstChild("ForsakenTestGui") then
    game.CoreGui.ForsakenTestGui:Destroy()
end

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

--================ GUI ================
local gui = Instance.new("ScreenGui", game.CoreGui)
gui.Name = "ForsakenTestGui"
gui.ResetOnSpawn = false

local main = Instance.new("Frame", gui)
main.Size = UDim2.fromScale(0.25, 0.35)
main.Position = UDim2.fromScale(0.05, 0.3)
main.BackgroundColor3 = Color3.fromRGB(25,25,25)
main.BorderSizePixel = 0
main.Active = true
main.Draggable = true

local title = Instance.new("TextLabel", main)
title.Size = UDim2.fromScale(1,0.15)
title.Text = "Forsaken Test Script"
title.TextColor3 = Color3.new(1,1,1)
title.BackgroundColor3 = Color3.fromRGB(40,40,40)
title.BorderSizePixel = 0
title.TextScaled = true

--================ BUTTON MAKER =================
local function makeButton(text, posY)
    local btn = Instance.new("TextButton", main)
    btn.Size = UDim2.fromScale(0.9,0.15)
    btn.Position = UDim2.fromScale(0.05,posY)
    btn.Text = text
    btn.TextScaled = true
    btn.BackgroundColor3 = Color3.fromRGB(60,60,60)
    btn.TextColor3 = Color3.new(1,1,1)
    btn.BorderSizePixel = 0
    return btn
end

local espBtn = makeButton("Item ESP : OFF", 0.2)
local stamBtn = makeButton("Infinite Stamina : OFF", 0.4)

--================ ESP CORE =================
local ESPObjects = {}
local ESP_ENABLED = false

local function createESP(part, text, color)
    if ESPObjects[part] then return end

    local bill = Instance.new("BillboardGui")
    bill.Size = UDim2.fromScale(5,1)
    bill.AlwaysOnTop = true
    bill.Adornee = part
    bill.Parent = gui

    local label = Instance.new("TextLabel", bill)
    label.Size = UDim2.fromScale(1,1)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = color
    label.TextScaled = true
    label.TextStrokeTransparency = 0

    ESPObjects[part] = bill
end

local function clearESP()
    for _,v in pairs(ESPObjects) do
        v:Destroy()
    end
    ESPObjects = {}
end

--================ ITEM ESP (FORSAKEN) =================
local function enableItemESP()
    clearESP()

    local folder = workspace:FindFirstChild("ItemLocations")
    if not folder then
        warn("ItemLocations not found")
        return
    end

    for _,item in pairs(folder:GetChildren()) do
        local root = item:FindFirstChild("ItemRoot")
        if root and root:IsA("BasePart") then
            createESP(root, item.Name, Color3.fromRGB(0,255,255))
        end
    end

    folder.ChildAdded:Connect(function(item)
        task.wait(0.2)
        if not ESP_ENABLED then return end
        local root = item:FindFirstChild("ItemRoot")
        if root then
            createESP(root, item.Name, Color3.fromRGB(0,255,255))
        end
    end)
end

--================ INFINITE STAMINA =================
local INF_STAMINA = false
local staminaConnection

local function findStamina()
    -- tìm mọi NumberValue / IntValue tên có chữ stamina
    for _,v in pairs(LocalPlayer:GetDescendants()) do
        if (v:IsA("NumberValue") or v:IsA("IntValue")) and
           v.Name:lower():find("stamina") then
            return v
        end
    end
end

local function enableStamina()
    if staminaConnection then staminaConnection:Disconnect() end

    staminaConnection = RunService.Heartbeat:Connect(function()
        local stam = findStamina()
        if stam then
            stam.Value = math.huge
        end
    end)
end

local function disableStamina()
    if staminaConnection then
        staminaConnection:Disconnect()
        staminaConnection = nil
    end
end

--================ BUTTON LOGIC =================
espBtn.MouseButton1Click:Connect(function()
    ESP_ENABLED = not ESP_ENABLED
    espBtn.Text = "Item ESP : " .. (ESP_ENABLED and "ON" or "OFF")

    if ESP_ENABLED then
        enableItemESP()
    else
        clearESP()
    end
end)

stamBtn.MouseButton1Click:Connect(function()
    INF_STAMINA = not INF_STAMINA
    stamBtn.Text = "Infinite Stamina : " .. (INF_STAMINA and "ON" or "OFF")

    if INF_STAMINA then
        enableStamina()
    else
        disableStamina()
    end
end)

print("Forsaken Test Script Loaded")
