-- Simple Location Detector
-- Display current player position coordinates for manual update to main.lua

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")

-- Create simple GUI
local CoreGui = game:GetService("CoreGui")
local screen = Instance.new("ScreenGui")
screen.Name = "LocationDetector"
screen.Parent = CoreGui

-- Main frame
local frame = Instance.new("Frame", screen)
frame.Size = UDim2.new(0, 350, 0, 200)
frame.Position = UDim2.new(0, 10, 0, 10)
frame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
frame.BorderSizePixel = 0
Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 8)

-- Title
local title = Instance.new("TextLabel", frame)
title.Size = UDim2.new(1, 0, 0, 30)
title.Position = UDim2.new(0, 0, 0, 0)
title.Text = "📍 Current Position Detector"
title.BackgroundTransparency = 1
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.Font = Enum.Font.SourceSansBold
title.TextSize = 16

-- Position label
local posLabel = Instance.new("TextLabel", frame)
posLabel.Size = UDim2.new(1, -20, 0, 80)
posLabel.Position = UDim2.new(0, 10, 0, 35)
posLabel.Text = "Position: Waiting..."
posLabel.BackgroundTransparency = 1
posLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
posLabel.Font = Enum.Font.SourceSans
posLabel.TextSize = 12
posLabel.TextWrapped = true
posLabel.TextXAlignment = Enum.TextXAlignment.Left

-- Copy button
local copyBtn = Instance.new("TextButton", frame)
copyBtn.Size = UDim2.new(0, 100, 0, 30)
copyBtn.Position = UDim2.new(0, 10, 0, 125)
copyBtn.Text = "Copy Vector3"
copyBtn.BackgroundColor3 = Color3.fromRGB(70, 130, 180)
copyBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
copyBtn.Font = Enum.Font.SourceSans
copyBtn.TextSize = 14
Instance.new("UICorner", copyBtn).CornerRadius = UDim.new(0, 6)

-- Copy CFrame button
local copyCFrameBtn = Instance.new("TextButton", frame)
copyCFrameBtn.Size = UDim2.new(0, 100, 0, 30)
copyCFrameBtn.Position = UDim2.new(0, 120, 0, 125)
copyCFrameBtn.Text = "Copy CFrame"
copyCFrameBtn.BackgroundColor3 = Color3.fromRGB(70, 150, 70)
copyCFrameBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
copyCFrameBtn.Font = Enum.Font.SourceSans
copyCFrameBtn.TextSize = 14
Instance.new("UICorner", copyCFrameBtn).CornerRadius = UDim.new(0, 6)

-- Close button
local closeBtn = Instance.new("TextButton", frame)
closeBtn.Size = UDim2.new(0, 80, 0, 30)
closeBtn.Position = UDim2.new(0, 230, 0, 125)
closeBtn.Text = "Close"
closeBtn.BackgroundColor3 = Color3.fromRGB(180, 70, 70)
closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
closeBtn.Font = Enum.Font.SourceSans
closeBtn.TextSize = 14
Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0, 6)

-- Current position variables
local currentVector3 = ""
local currentCFrame = ""

-- Update position function
local function updatePosition()
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        local part = LocalPlayer.Character.HumanoidRootPart
        local pos = part.Position
        local cf = part.CFrame
        
        local x = math.floor(pos.X * 100) / 100
        local y = math.floor(pos.Y * 100) / 100
        local z = math.floor(pos.Z * 100) / 100
        
        currentVector3 = string.format("Vector3.new(%.2f, %.2f, %.2f)", x, y, z)
        currentCFrame = string.format("CFrame.new(%.2f, %.2f, %.2f)", x, y, z)
        
        posLabel.Text = string.format("Current Position:\nX: %.2f, Y: %.2f, Z: %.2f\n\nVector3 format:\n%s\n\nCFrame format:\n%s", 
            x, y, z, currentVector3, currentCFrame)
    else
        posLabel.Text = "Position: Character not found\nMake sure you're spawned in game"
    end
end

-- Update position every frame
local connection = RunService.Heartbeat:Connect(updatePosition)

-- Copy Vector3 button functionality
copyBtn.MouseButton1Click:Connect(function()
    if currentVector3 ~= "" then
        if setclipboard then
            setclipboard(currentVector3)
            copyBtn.Text = "Copied!"
            task.spawn(function()
                task.wait(1)
                copyBtn.Text = "Copy Vector3"
            end)
        else
            copyBtn.Text = "No clipboard"
            task.spawn(function()
                task.wait(1)
                copyBtn.Text = "Copy Vector3"
            end)
        end
    end
end)

-- Copy CFrame button functionality
copyCFrameBtn.MouseButton1Click:Connect(function()
    if currentCFrame ~= "" then
        if setclipboard then
            setclipboard(currentCFrame)
            copyCFrameBtn.Text = "Copied!"
            task.spawn(function()
                task.wait(1)
                copyCFrameBtn.Text = "Copy CFrame"
            end)
        else
            copyCFrameBtn.Text = "No clipboard"
            task.spawn(function()
                task.wait(1)
                copyCFrameBtn.Text = "Copy CFrame"
            end)
        end
    end
end)

-- Close button functionality
closeBtn.MouseButton1Click:Connect(function()
    connection:Disconnect()
    screen:Destroy()
    print("Location Detector closed")
end)

print("Simple Location Detector started!")
print("Walk to any location and use Copy buttons to get coordinates for main.lua")
