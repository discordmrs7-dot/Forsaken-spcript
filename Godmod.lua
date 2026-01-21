-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
 
local lp = Players.LocalPlayer
 
-- Configuration
local AutoMode = "Automatic" -- "Always", "Automatic", "Hold"
local HoldKey = Enum.KeyCode.G
local AutoDistance = 166
local ActiveEntities = {}
 
-- === Godmode Logic ===
local function setGodmode(state)
    local char = lp.Character
    if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    local root = char:FindFirstChild("HumanoidRootPart")
    local collision = char:FindFirstChild("Collision")
    if not (hum and root and collision) then return end
 
    local crouch = collision:FindFirstChild("CollisionCrouch")
 
    if state then
        ReplicatedStorage.RemotesFolder.Crouch:FireServer(true)
        collision.Size = Vector3.new(1, 0.001, 3)
        if crouch then
            crouch.Size = Vector3.new(1, 0.001, 3)
            crouch.Position = root.Position - Vector3.new(0,1,0)
        end
        hum.HipHeight = 0.0001
    else
        ReplicatedStorage.RemotesFolder.Crouch:FireServer(false)
        collision.Size = Vector3.new(5.5,3,3)
        if crouch then
            crouch.Size = Vector3.new(3,3,3)
            crouch.Position = root.Position - Vector3.new(0,1,0)
        end
        hum.HipHeight = 2.4
    end
end
 
local function safeDisableGod()
    if AutoMode == "Always" then return end
    setGodmode(false)
end
 
-- === Entity Detection ===
local EntList = {"a60","ambushmoving","backdoorrush","rushmoving","mandrake"}
local function IsValidEntity(entity)
    return table.find(EntList, entity.Name:lower()) ~= nil
end
 
workspace.DescendantAdded:Connect(function(entity)
    if not IsValidEntity(entity) then return end
    local part = entity:FindFirstChildWhichIsA("BasePart")
    if part then ActiveEntities[entity] = part end
end)
 
-- === GUI On/Off ===
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "GodmodeToggleGUI"
screenGui.Parent = lp:WaitForChild("PlayerGui")
 
local button = Instance.new("TextButton")
button.Size = UDim2.new(0, 80, 0, 40)
button.Position = UDim2.new(0, 20, 0, 20)
button.Text = "Off"
button.BackgroundColor3 = Color3.fromRGB(255,85,85)
button.TextColor3 = Color3.fromRGB(255,255,255)
button.Parent = screenGui
 
local GodmodeActive = false
 
button.Activated:Connect(function()
    GodmodeActive = not GodmodeActive
    if GodmodeActive then
        button.Text = "On"
        button.BackgroundColor3 = Color3.fromRGB(0,170,255)
    else
        button.Text = "Off"
        button.BackgroundColor3 = Color3.fromRGB(255,85,85)
    end
end)
 
-- Drag GUI (PC & HP)
local dragging = false
local dragInput
 
button.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragInput = input
    end
end)
 
button.InputEnded:Connect(function(input)
    if input == dragInput then
        dragging = false
    end
end)
 
UserInputService.InputChanged:Connect(function(input)
    if dragging and input == dragInput then
        button.Position = UDim2.new(
            0,
            input.Position.X - button.AbsoluteSize.X/2,
            0,
            input.Position.Y - button.AbsoluteSize.Y/2
        )
    end
end)
 
-- === Mode Logic + RenderStepped ===
RunService.RenderStepped:Connect(function()
    local char = lp.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if not root then return end
 
    local collision = char and char:FindFirstChild("Collision")
    if collision then
        local crouch = collision:FindFirstChild("CollisionCrouch")
        if crouch then
            crouch.Position = root.Position - Vector3.new(0,1,0)
        end
    end
 
    if GodmodeActive then
        setGodmode(true)
        return
    end
 
    if AutoMode == "Always" then
        setGodmode(true)
    elseif AutoMode == "Automatic" then
        local shouldEnable = false
        for entity, part in pairs(ActiveEntities) do
            if not entity.Parent then
                ActiveEntities[entity] = nil
            elseif part then
                local dist = (root.Position - part.Position).Magnitude
                if dist < AutoDistance then
                    shouldEnable = true
                    break
                end
            end
        end
        if shouldEnable then
            setGodmode(true)
        else
            safeDisableGod()
        end
    elseif AutoMode == "Hold" then
        if UserInputService:IsKeyDown(HoldKey) then
            setGodmode(true)
        else
            safeDisableGod()
        end
    end
end)
