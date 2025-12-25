-- Forsaken Enhanced ESP (Mobile / Delta)
if getgenv().ForsakenESP_LOADED then return end
getgenv().ForsakenESP_LOADED = true-- Show Killer, Survivor, Items, Objectives

if getgenv().ForsakenESPLoaded then return end
getgenv().ForsakenESPLoaded = true

local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

-- Settings
local settings = {
    killerESP = true,
    survivorESP = true,
    itemESP = true,
    objESP = true
}

-- UI
local screenGui = Instance.new("ScreenGui", game:GetService("CoreGui"))
local mainFrame = Instance.new("Frame", screenGui)
mainFrame.Size = UDim2.new(0, 160,0,180)
mainFrame.Position = UDim2.new(0,10,0,150)
mainFrame.BackgroundColor3 = Color3.fromRGB(25,25,25)

local function createButton(y, text, callback)
    local btn = Instance.new("TextButton", mainFrame)
    btn.Size = UDim2.new(0, 150,0,30)
    btn.Position = UDim2.new(0,5,0,y)
    btn.Text = text
    btn.BackgroundColor3 = Color3.fromRGB(45,45,45)
    btn.TextColor3 = Color3.fromRGB(255,255,255)
    btn.MouseButton1Click:Connect(callback)
end

createButton(5, "Toggle Killer ESP", function()
    settings.killerESP = not settings.killerESP
end)
createButton(45, "Toggle Survivor ESP", function()
    settings.survivorESP = not settings.survivorESP
end)
createButton(85, "Toggle Item ESP", function()
    settings.itemESP = not settings.itemESP
end)
createButton(125, "Toggle Obj ESP", function()
    settings.objESP = not settings.objESP
end)

-- Create drawing
local espObjects = {}

local function newESP(part, label, color, typeKey)
    local box = Drawing.new("Square")
    box.Thickness = 1
    box.Filled = false
    box.Color = color

    local txt = Drawing.new("Text")
    txt.Center = true
    txt.Size = 14
    txt.Color = color
    txt.Text = label

    espObjects[part] = {box=box, txt=txt, type=typeKey}
end

-- Update loop
RunService.RenderStepped:Connect(function()
    for part, data in pairs(espObjects) do
        if not part or not part.Parent then
            data.box:Remove()
            data.txt:Remove()
            espObjects[part] = nil
        else
            local pos, onScreen = Camera:WorldToViewportPoint(part.Position)
            if onScreen then
                local show = false
                if data.type=="killer" and settings.killerESP then show=true end
                if data.type=="survivor" and settings.survivorESP then show=true end
                if data.type=="item" and settings.itemESP then show=true end
                if data.type=="objective" and settings.objESP then show=true end

                data.box.Visible = show
                data.txt.Visible = show

                data.box.Position = Vector2.new(pos.X-20, pos.Y-25)
                data.box.Size = Vector2.new(40,50)

                data.txt.Position = Vector2.new(pos.X, pos.Y-40)
            else
                data.box.Visible = false
                data.txt.Visible = false
            end
        end
    end
end)

-- Player ESP
for _, plr in pairs(Players:GetPlayers()) do
    if plr ~= LocalPlayer then
        plr.CharacterAdded:Connect(function(char)
            local hrp = char:WaitForChild("HumanoidRootPart",5)
            if hrp then
                local team = plr.Team and plr.Team.Name or "Unknown"
                if team=="Killer" then
                    newESP(hrp, "[KILLER] "..plr.Name, Color3.fromRGB(255,0,0), "killer")
                else
                    newESP(hrp, "[SURVIVOR] "..plr.Name, Color3.fromRGB(0,255,0), "survivor")
                end
            end
        end)
    end
end

Players.PlayerAdded:Connect(function(plr)
    plr.CharacterAdded:Connect(function(char)
        local hrp = char:WaitForChild("HumanoidRootPart",5)
        if hrp then
            local team = plr.Team and plr.Team.Name or "Unknown"
            if team=="Killer" then
                newESP(hrp, "[KILLER] "..plr.Name, Color3.fromRGB(255,0,0), "killer")
            else
                newESP(hrp, "[SURVIVOR] "..plr.Name, Color3.fromRGB(0,255,0), "survivor")
            end
        end
    end)
end)

-- Items & Objectives ESP
for _, obj in pairs(workspace:GetDescendants()) do
    if obj:IsA("Model") or obj:IsA("Tool") then
        local base = obj:FindFirstChildWhichIsA("BasePart")
        if base then
            local name = obj.Name:lower()
            if name:find("med") or name:find("cola") then
                newESP(base, obj.Name, Color3.fromRGB(255,255,0), "item")
            end
        end
    elseif obj.Name:lower():find("generator") or obj.Name:lower():find("exit") then
        if obj:IsA("BasePart") then
            newESP(obj, obj.Name, Color3.fromRGB(0,200,255), "objective")
        end
    end
end
