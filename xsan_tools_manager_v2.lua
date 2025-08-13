-- XSAN Tools Manager v2.0
-- Unified interface manager - satu kotak dengan tab menu
-- Menggantikan floating button terpisah dengan interface yang lebih clean

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")

-- Remove existing tool GUIs to prevent conflicts
for _, gui in pairs(CoreGui:GetChildren()) do
    if gui.Name:find("Detector") or gui.Name:find("Analyzer") or gui.Name:find("Logger") or gui.Name:find("Monitor") then
        gui:Destroy()
    end
end

local screen = Instance.new("ScreenGui")
screen.Name = "XSANToolsManager"
screen.Parent = CoreGui

-- Master floating button - launches unified interface
local masterBtn = Instance.new("TextButton")
masterBtn.Parent = screen
masterBtn.Size = UDim2.new(0, 80, 0, 80)
masterBtn.Position = UDim2.new(1, -100, 0, 20)
masterBtn.Text = "🔧\nXSAN"
masterBtn.BackgroundColor3 = Color3.fromRGB(60, 120, 200)
masterBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
masterBtn.Font = Enum.Font.SourceSansBold
masterBtn.TextSize = 16
masterBtn.BorderSizePixel = 0
masterBtn.ZIndex = 10
Instance.new("UICorner", masterBtn).CornerRadius = UDim.new(0.5, 0)

-- Shadow effect
local shadow = Instance.new("Frame")
shadow.Parent = screen
shadow.Size = UDim2.new(0, 85, 0, 85)
shadow.Position = UDim2.new(1, -102.5, 0, 22.5)
shadow.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
shadow.BackgroundTransparency = 0.7
shadow.BorderSizePixel = 0
shadow.ZIndex = 5
Instance.new("UICorner", shadow).CornerRadius = UDim.new(0.5, 0)

-- Dragging functionality
local dragging = false
local dragStart = nil
local startPos = nil

masterBtn.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = masterBtn.Position
    end
end)

masterBtn.InputChanged:Connect(function(input)
    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = input.Position - dragStart
        masterBtn.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        shadow.Position = UDim2.new(masterBtn.Position.X.Scale, masterBtn.Position.X.Offset - 2.5, masterBtn.Position.Y.Scale, masterBtn.Position.Y.Offset + 2.5)
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = false
    end
end)

-- Load unified interface
local function loadUnifiedInterface()
    pcall(function()
        -- Remove existing unified interface
        local existing = CoreGui:FindFirstChild("UnifiedToolsInterface")
        if existing then
            existing:Destroy()
        end
        
        -- Load new unified interface
        loadstring(game:HttpGet("https://raw.githubusercontent.com/donitono/part2/main/unified_tools_interface.lua"))()
        print("🔧 Unified Tools Interface loaded successfully!")
    end)
end

-- Button click event
masterBtn.MouseButton1Click:Connect(function()
    if not dragging then
        loadUnifiedInterface()
    end
end)

-- Hotkey support (F12)
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if not gameProcessed and input.KeyCode == Enum.KeyCode.F12 then
        loadUnifiedInterface()
    end
end)

-- Hover effects
masterBtn.MouseEnter:Connect(function()
    local tween = TweenService:Create(masterBtn, TweenInfo.new(0.2), {
        Size = UDim2.new(0, 85, 0, 85),
        BackgroundColor3 = Color3.fromRGB(80, 140, 220)
    })
    tween:Play()
end)

masterBtn.MouseLeave:Connect(function()
    local tween = TweenService:Create(masterBtn, TweenInfo.new(0.2), {
        Size = UDim2.new(0, 80, 0, 80),
        BackgroundColor3 = Color3.fromRGB(60, 120, 200)
    })
    tween:Play()
end)

print("🔧 XSAN Tools Manager v2.0 - Unified Interface")
print("📱 Click master button or press F12 to open unified tools")
print("⚡ All detector tools integrated in one clean interface!")
print("🎮 Tab-based navigation for better organization")
