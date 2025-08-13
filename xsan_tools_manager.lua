-- XSAN Tools Manager
-- Central floating button manager untuk semua tools
-- Optimized untuk mode landscape dengan floating buttons yang dapat di-drag

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer

-- Create main GUI
local CoreGui = game:GetService("CoreGui")
local screen = Instance.new("ScreenGui")
screen.Name = "XSANToolsManager"
screen.Parent = CoreGui

-- Main floating button (master button)
local masterBtn = Instance.new("TextButton", screen)
masterBtn.Size = UDim2.new(0, 70, 0, 70)
masterBtn.Position = UDim2.new(1, -90, 0.5, -35)
masterBtn.Text = "🔧"
masterBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
masterBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
masterBtn.Font = Enum.Font.SourceSansBold
masterBtn.TextSize = 28
masterBtn.BorderSizePixel = 0
masterBtn.ZIndex = 15
Instance.new("UICorner", masterBtn).CornerRadius = UDim.new(0.5, 0)

-- Add gradient effect
local gradient = Instance.new("UIGradient", masterBtn)
gradient.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, Color3.fromRGB(70, 70, 70)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(30, 30, 30))
}
gradient.Rotation = 45

-- Shadow for master button
local masterShadow = Instance.new("Frame", screen)
masterShadow.Size = UDim2.new(0, 72, 0, 72)
masterShadow.Position = UDim2.new(1, -91, 0.5, -34)
masterShadow.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
masterShadow.BackgroundTransparency = 0.8
masterShadow.BorderSizePixel = 0
masterShadow.ZIndex = 14
Instance.new("UICorner", masterShadow).CornerRadius = UDim.new(0.5, 0)

-- Tools data
local tools = {
    {
        name = "Buy System Detector",
        icon = "🛒",
        color = Color3.fromRGB(70, 130, 180),
        url = "https://raw.githubusercontent.com/donitono/part2/main/buy_system_detector.lua",
        description = "Detect buy/sell systems and NPCs"
    },
    {
        name = "Remote Events Logger",
        icon = "📡",
        color = Color3.fromRGB(100, 150, 200),
        url = "https://raw.githubusercontent.com/donitono/part2/main/remote_events_logger.lua",
        description = "Monitor all RemoteEvent calls"
    },
    {
        name = "NPC & Teleport Detector",
        icon = "🗺️",
        color = Color3.fromRGB(80, 160, 120),
        url = "https://raw.githubusercontent.com/donitono/part2/main/npc_teleport_detector.lua",
        description = "Find NPCs and teleportation points"
    },
    {
        name = "Game Events Monitor",
        icon = "⚡",
        color = Color3.fromRGB(150, 100, 200),
        url = "https://raw.githubusercontent.com/donitono/part2/main/game_events_monitor.lua",
        description = "Real-time game events monitoring"
    },
    {
        name = "Feature Analyzer",
        icon = "🔍",
        color = Color3.fromRGB(200, 120, 80),
        url = "https://raw.githubusercontent.com/donitono/part2/main/feature_analyzer.lua",
        description = "Analyze features and suggest improvements"
    }
}

-- Variables
local isExpanded = false
local toolButtons = {}
local loadedTools = {}

-- Create tool buttons
for i, tool in ipairs(tools) do
    local toolBtn = Instance.new("TextButton", screen)
    toolBtn.Size = UDim2.new(0, 55, 0, 55)
    toolBtn.Position = UDim2.new(1, -90, 0.5, -35) -- Start at master button position
    toolBtn.Text = tool.icon
    toolBtn.BackgroundColor3 = tool.color
    toolBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    toolBtn.Font = Enum.Font.SourceSansBold
    toolBtn.TextSize = 20
    toolBtn.BorderSizePixel = 0
    toolBtn.ZIndex = 12
    toolBtn.Visible = false
    Instance.new("UICorner", toolBtn).CornerRadius = UDim.new(0.5, 0)
    
    -- Tool button shadow
    local toolShadow = Instance.new("Frame", screen)
    toolShadow.Size = UDim2.new(0, 57, 0, 57)
    toolShadow.Position = UDim2.new(1, -91, 0.5, -34)
    toolShadow.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    toolShadow.BackgroundTransparency = 0.8
    toolShadow.BorderSizePixel = 0
    toolShadow.ZIndex = 11
    toolShadow.Visible = false
    Instance.new("UICorner", toolShadow).CornerRadius = UDim.new(0.5, 0)
    
    -- Add hover effect
    toolBtn.MouseEnter:Connect(function()
        local tween = TweenService:Create(toolBtn, TweenInfo.new(0.2), {Size = UDim2.new(0, 60, 0, 60)})
        tween:Play()
    end)
    
    toolBtn.MouseLeave:Connect(function()
        local tween = TweenService:Create(toolBtn, TweenInfo.new(0.2), {Size = UDim2.new(0, 55, 0, 55)})
        tween:Play()
    end)
    
    -- Tool button click handler
    toolBtn.MouseButton1Click:Connect(function()
        if not loadedTools[tool.name] then
            -- Load the tool
            local success, result = pcall(function()
                return loadstring(game:HttpGet(tool.url))()
            end)
            
            if success then
                loadedTools[tool.name] = true
                toolBtn.BackgroundColor3 = Color3.fromRGB(50, 200, 50)
                print("✅ " .. tool.name .. " loaded successfully!")
                
                -- Reset color after 2 seconds
                task.spawn(function()
                    task.wait(2)
                    toolBtn.BackgroundColor3 = tool.color
                end)
            else
                toolBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
                warn("❌ Failed to load " .. tool.name .. ": " .. tostring(result))
                
                -- Reset color after 2 seconds
                task.spawn(function()
                    task.wait(2)
                    toolBtn.BackgroundColor3 = tool.color
                end)
            end
        else
            print("ℹ️ " .. tool.name .. " is already loaded!")
        end
    end)
    
    table.insert(toolButtons, {
        button = toolBtn,
        shadow = toolShadow,
        tool = tool,
        index = i
    })
end

-- Animation functions
local function expandTools()
    isExpanded = true
    masterBtn.Text = "❌"
    masterBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    
    for _, toolData in ipairs(toolButtons) do
        toolData.button.Visible = true
        toolData.shadow.Visible = true
        
        local targetY = 0.5 + (toolData.index - 3) * 0.12 -- Spread vertically
        
        local tween = TweenService:Create(toolData.button, 
            TweenInfo.new(0.3 + toolData.index * 0.05, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
            {Position = UDim2.new(1, -90, targetY, -27.5)}
        )
        tween:Play()
        
        local shadowTween = TweenService:Create(toolData.shadow,
            TweenInfo.new(0.3 + toolData.index * 0.05, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
            {Position = UDim2.new(1, -91, targetY, -26.5)}
        )
        shadowTween:Play()
    end
end

local function collapseTools()
    isExpanded = false
    masterBtn.Text = "🔧"
    masterBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    
    for _, toolData in ipairs(toolButtons) do
        local tween = TweenService:Create(toolData.button,
            TweenInfo.new(0.2, Enum.EasingStyle.Back, Enum.EasingDirection.In),
            {Position = UDim2.new(1, -90, 0.5, -35)}
        )
        tween:Play()
        
        local shadowTween = TweenService:Create(toolData.shadow,
            TweenInfo.new(0.2, Enum.EasingStyle.Back, Enum.EasingDirection.In),
            {Position = UDim2.new(1, -91, 0.5, -34)}
        )
        shadowTween:Play()
        
        tween.Completed:Connect(function()
            toolData.button.Visible = false
            toolData.shadow.Visible = false
        end)
    end
end

-- Master button click handler
masterBtn.MouseButton1Click:Connect(function()
    if isExpanded then
        collapseTools()
    else
        expandTools()
    end
end)

-- Make master button draggable
local isDragging = false
local dragStart = nil
local startPos = nil

masterBtn.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        isDragging = true
        dragStart = input.Position
        startPos = masterBtn.Position
    end
end)

masterBtn.InputChanged:Connect(function(input)
    if isDragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = input.Position - dragStart
        local newPos = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, 
                                 startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        masterBtn.Position = newPos
        masterShadow.Position = UDim2.new(newPos.X.Scale, newPos.X.Offset - 1, 
                                         newPos.Y.Scale, newPos.Y.Offset + 1)
        
        -- Update tool buttons position when dragging
        if isExpanded then
            for _, toolData in ipairs(toolButtons) do
                local toolY = newPos.Y.Scale + (toolData.index - 3) * 0.12
                toolData.button.Position = UDim2.new(newPos.X.Scale, newPos.X.Offset, toolY, -27.5)
                toolData.shadow.Position = UDim2.new(newPos.X.Scale, newPos.X.Offset - 1, toolY, -26.5)
            end
        end
    end
end)

masterBtn.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        isDragging = false
    end
end)

-- Info panel
local infoPanel = Instance.new("Frame", screen)
infoPanel.Size = UDim2.new(0, 300, 0, 200)
infoPanel.Position = UDim2.new(0, 20, 1, -220)
infoPanel.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
infoPanel.BorderSizePixel = 0
infoPanel.ZIndex = 13
infoPanel.Visible = false
Instance.new("UICorner", infoPanel).CornerRadius = UDim.new(0, 8)

local infoTitle = Instance.new("TextLabel", infoPanel)
infoTitle.Size = UDim2.new(1, -20, 0, 30)
infoTitle.Position = UDim2.new(0, 10, 0, 10)
infoTitle.Text = "🔧 XSAN Tools Manager"
infoTitle.BackgroundTransparency = 1
infoTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
infoTitle.Font = Enum.Font.SourceSansBold
infoTitle.TextSize = 14
infoTitle.TextXAlignment = Enum.TextXAlignment.Left

local infoText = Instance.new("TextLabel", infoPanel)
infoText.Size = UDim2.new(1, -20, 1, -80)
infoText.Position = UDim2.new(0, 10, 0, 40)
infoText.Text = "🎯 Welcome to XSAN Tools Manager!\n\n• Click the main button (🔧) to expand tools\n• Click any tool icon to load it\n• Tools are optimized for landscape mode\n• All interfaces have floating buttons\n• Drag the main button to reposition"
infoText.BackgroundTransparency = 1
infoText.TextColor3 = Color3.fromRGB(200, 200, 200)
infoText.Font = Enum.Font.SourceSans
infoText.TextSize = 11
infoText.TextWrapped = true
infoText.TextXAlignment = Enum.TextXAlignment.Left
infoText.TextYAlignment = Enum.TextYAlignment.Top

local hideInfoBtn = Instance.new("TextButton", infoPanel)
hideInfoBtn.Size = UDim2.new(0, 60, 0, 25)
hideInfoBtn.Position = UDim2.new(1, -70, 1, -35)
hideInfoBtn.Text = "Hide"
hideInfoBtn.BackgroundColor3 = Color3.fromRGB(180, 70, 70)
hideInfoBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
hideInfoBtn.Font = Enum.Font.SourceSans
hideInfoBtn.TextSize = 11
hideInfoBtn.BorderSizePixel = 0
Instance.new("UICorner", hideInfoBtn).CornerRadius = UDim.new(0, 4)

hideInfoBtn.MouseButton1Click:Connect(function()
    infoPanel.Visible = false
end)

-- Show info panel initially
task.spawn(function()
    task.wait(1)
    infoPanel.Visible = true
    task.wait(5)
    infoPanel.Visible = false
end)

-- Pulse animation for master button
local function pulseAnimation()
    while masterBtn.Parent do
        local tween = TweenService:Create(masterBtn, TweenInfo.new(1, Enum.EasingStyle.Sine), 
            {Size = UDim2.new(0, 75, 0, 75)})
        tween:Play()
        tween.Completed:Wait()
        
        local tween2 = TweenService:Create(masterBtn, TweenInfo.new(1, Enum.EasingStyle.Sine), 
            {Size = UDim2.new(0, 70, 0, 70)})
        tween2:Play()
        tween2.Completed:Wait()
    end
end

-- Start pulse animation
task.spawn(pulseAnimation)

-- Keyboard shortcut to toggle tools (F12)
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if not gameProcessed and input.KeyCode == Enum.KeyCode.F12 then
        if isExpanded then
            collapseTools()
        else
            expandTools()
        end
    end
end)

print("🔧 XSAN Tools Manager loaded!")
print("📱 Optimized for landscape mode with floating buttons")
print("⌨️ Press F12 to quickly toggle tools menu")
print("🎯 Click the floating gear button to access all tools")
