-- Game Events Monitor
-- Script untuk memantau event-event penting dalam game
-- Berguna untuk mengembangkan fitur baru di main.lua

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer

-- Create GUI
local CoreGui = game:GetService("CoreGui")
local screen = Instance.new("ScreenGui")
screen.Name = "GameEventsMonitor"
screen.Parent = CoreGui

-- Main frame (landscape optimized)
local frame = Instance.new("Frame")
frame.Parent = screen
frame.Size = UDim2.new(0, 700, 0, 300)
frame.Position = UDim2.new(0, 10, 0, 10)
frame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
frame.BorderSizePixel = 0
frame.Active = true
frame.Draggable = true
frame.Visible = false -- Start hidden
Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 8)

-- Floating toggle button
local floatingBtn = Instance.new("TextButton", screen)
floatingBtn.Size = UDim2.new(0, 60, 0, 60)
floatingBtn.Position = UDim2.new(1, -80, 0, 230)
floatingBtn.Text = "⚡"
floatingBtn.BackgroundColor3 = Color3.fromRGB(150, 100, 200)
floatingBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
floatingBtn.Font = Enum.Font.SourceSansBold
floatingBtn.TextSize = 24
floatingBtn.BorderSizePixel = 0
floatingBtn.ZIndex = 10
Instance.new("UICorner", floatingBtn).CornerRadius = UDim.new(0.5, 0)

-- Floating button functionality
floatingBtn.MouseButton1Click:Connect(function()
    frame.Visible = not frame.Visible
    floatingBtn.BackgroundColor3 = frame.Visible and Color3.fromRGB(180, 70, 70) or Color3.fromRGB(150, 100, 200)
    floatingBtn.Text = frame.Visible and "❌" or "⚡"
end)

-- Title with live indicator
local titleFrame = Instance.new("Frame")
titleFrame.Parent = frame
titleFrame.Size = UDim2.new(1, 0, 0, 35)
titleFrame.BackgroundTransparency = 1

local title = Instance.new("TextLabel")
title.Parent = titleFrame
title.Size = UDim2.new(1, -60, 1, 0)
title.BackgroundTransparency = 1
title.Text = "⚡ Game Events Monitor"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.Font = Enum.Font.SourceSansBold
title.TextSize = 16
title.TextXAlignment = Enum.TextXAlignment.Left

local liveIndicator = Instance.new("Frame")
liveIndicator.Parent = titleFrame
liveIndicator.Size = UDim2.new(0, 15, 0, 15)
liveIndicator.Position = UDim2.new(1, -50, 0.5, -7.5)
liveIndicator.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
liveIndicator.BorderSizePixel = 0
Instance.new("UICorner", liveIndicator).CornerRadius = UDim.new(0.5, 0)

local liveText = Instance.new("TextLabel")
liveText.Parent = titleFrame
liveText.Size = UDim2.new(0, 30, 1, 0)
liveText.Position = UDim2.new(1, -30, 0, 0)
liveText.BackgroundTransparency = 1
liveText.Text = "LIVE"
liveText.TextColor3 = Color3.fromRGB(0, 255, 0)
liveText.Font = Enum.Font.SourceSansBold
liveText.TextSize = 10

-- Stats frame
local statsFrame = Instance.new("Frame")
statsFrame.Parent = frame
statsFrame.Size = UDim2.new(1, -20, 0, 60)
statsFrame.Position = UDim2.new(0, 10, 0, 40)
statsFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
statsFrame.BorderSizePixel = 0
Instance.new("UICorner", statsFrame).CornerRadius = UDim.new(0, 6)

local statsLayout = Instance.new("UIGridLayout")
statsLayout.Parent = statsFrame
statsLayout.CellSize = UDim2.new(0.25, -5, 0.5, -2.5)
statsLayout.CellPadding = UDim2.new(0, 5, 0, 5)

-- Create stat cards
local function createStatCard(name, value, color)
    local card = Instance.new("Frame")
    card.Parent = statsFrame
    card.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    card.BorderSizePixel = 0
    Instance.new("UICorner", card).CornerRadius = UDim.new(0, 4)
    
    local nameLabel = Instance.new("TextLabel")
    nameLabel.Parent = card
    nameLabel.Size = UDim2.new(1, -10, 0.6, 0)
    nameLabel.Position = UDim2.new(0, 5, 0, 0)
    nameLabel.BackgroundTransparency = 1
    nameLabel.Text = name
    nameLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    nameLabel.Font = Enum.Font.SourceSans
    nameLabel.TextSize = 10
    nameLabel.TextXAlignment = Enum.TextXAlignment.Left
    nameLabel.TextYAlignment = Enum.TextYAlignment.Bottom
    
    local valueLabel = Instance.new("TextLabel")
    valueLabel.Parent = card
    valueLabel.Size = UDim2.new(1, -10, 0.4, 0)
    valueLabel.Position = UDim2.new(0, 5, 0.6, 0)
    valueLabel.BackgroundTransparency = 1
    valueLabel.Text = tostring(value)
    valueLabel.TextColor3 = color
    valueLabel.Font = Enum.Font.SourceSansBold
    valueLabel.TextSize = 12
    valueLabel.TextXAlignment = Enum.TextXAlignment.Left
    valueLabel.TextYAlignment = Enum.TextYAlignment.Top
    
    return valueLabel
end

-- Event monitoring variables
local eventStats = {
    fishingEvents = 0,
    playerEvents = 0,
    systemEvents = 0,
    totalEvents = 0
}

local fishingLabel = createStatCard("Fishing Events", 0, Color3.fromRGB(100, 200, 255))
local playerLabel = createStatCard("Player Events", 0, Color3.fromRGB(255, 200, 100))
local systemLabel = createStatCard("System Events", 0, Color3.fromRGB(200, 255, 100))
local totalLabel = createStatCard("Total Events", 0, Color3.fromRGB(255, 255, 255))

-- Event log frame
local logFrame = Instance.new("Frame")
logFrame.Parent = frame
logFrame.Size = UDim2.new(1, -20, 1, -140)
logFrame.Position = UDim2.new(0, 10, 0, 110)
logFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
logFrame.BorderSizePixel = 0
Instance.new("UICorner", logFrame).CornerRadius = UDim.new(0, 6)

local logTitle = Instance.new("TextLabel")
logTitle.Parent = logFrame
logTitle.Size = UDim2.new(1, 0, 0, 25)
logTitle.BackgroundTransparency = 1
logTitle.Text = "📊 Real-Time Event Log"
logTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
logTitle.Font = Enum.Font.SourceSansBold
logTitle.TextSize = 12

local scrollFrame = Instance.new("ScrollingFrame")
scrollFrame.Parent = logFrame
scrollFrame.Size = UDim2.new(1, -10, 1, -30)
scrollFrame.Position = UDim2.new(0, 5, 0, 25)
scrollFrame.BackgroundTransparency = 1
scrollFrame.BorderSizePixel = 0
scrollFrame.ScrollBarThickness = 6

local logList = Instance.new("UIListLayout")
logList.Parent = scrollFrame
logList.SortOrder = Enum.SortOrder.LayoutOrder
logList.Padding = UDim.new(0, 1)

-- Control buttons frame
local controlFrame = Instance.new("Frame")
controlFrame.Parent = frame
controlFrame.Size = UDim2.new(1, -20, 0, 25)
controlFrame.Position = UDim2.new(0, 10, 1, -35)
controlFrame.BackgroundTransparency = 1

local clearBtn = Instance.new("TextButton")
clearBtn.Parent = controlFrame
clearBtn.Size = UDim2.new(0, 60, 1, 0)
clearBtn.Position = UDim2.new(0, 0, 0, 0)
clearBtn.Text = "Clear"
clearBtn.BackgroundColor3 = Color3.fromRGB(180, 70, 70)
clearBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
clearBtn.Font = Enum.Font.SourceSans
clearBtn.TextSize = 11
clearBtn.BorderSizePixel = 0
Instance.new("UICorner", clearBtn).CornerRadius = UDim.new(0, 4)

local pauseBtn = Instance.new("TextButton")
pauseBtn.Parent = controlFrame
pauseBtn.Size = UDim2.new(0, 60, 1, 0)
pauseBtn.Position = UDim2.new(0, 70, 0, 0)
pauseBtn.Text = "Pause"
pauseBtn.BackgroundColor3 = Color3.fromRGB(150, 150, 70)
pauseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
pauseBtn.Font = Enum.Font.SourceSans
pauseBtn.TextSize = 11
pauseBtn.BorderSizePixel = 0
Instance.new("UICorner", pauseBtn).CornerRadius = UDim.new(0, 4)

local exportBtn = Instance.new("TextButton")
exportBtn.Parent = controlFrame
exportBtn.Size = UDim2.new(0, 60, 1, 0)
exportBtn.Position = UDim2.new(0, 140, 0, 0)
exportBtn.Text = "Export"
exportBtn.BackgroundColor3 = Color3.fromRGB(70, 130, 180)
exportBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
exportBtn.Font = Enum.Font.SourceSans
exportBtn.TextSize = 11
exportBtn.BorderSizePixel = 0
Instance.new("UICorner", exportBtn).CornerRadius = UDim.new(0, 4)

local filterBtn = Instance.new("TextButton")
filterBtn.Parent = controlFrame
filterBtn.Size = UDim2.new(0, 60, 1, 0)
filterBtn.Position = UDim2.new(0, 210, 0, 0)
filterBtn.Text = "Filter: All"
filterBtn.BackgroundColor3 = Color3.fromRGB(100, 70, 150)
filterBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
filterBtn.Font = Enum.Font.SourceSans
filterBtn.TextSize = 11
filterBtn.BorderSizePixel = 0
Instance.new("UICorner", filterBtn).CornerRadius = UDim.new(0, 4)

local closeBtn = Instance.new("TextButton")
closeBtn.Parent = controlFrame
closeBtn.Size = UDim2.new(0, 60, 1, 0)
closeBtn.Position = UDim2.new(1, -60, 0, 0)
closeBtn.Text = "Close"
closeBtn.BackgroundColor3 = Color3.fromRGB(180, 70, 70)
closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
closeBtn.Font = Enum.Font.SourceSans
closeBtn.TextSize = 11
closeBtn.BorderSizePixel = 0
Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0, 4)

-- Monitoring variables
local isMonitoring = true
local currentFilter = "all"
local eventLog = {}
local maxLogEntries = 100

-- Function to add event log
local function addEventLog(eventType, eventName, details)
    if not isMonitoring then return end
    
    -- Update stats
    eventStats.totalEvents = eventStats.totalEvents + 1
    if eventType == "fishing" then
        eventStats.fishingEvents = eventStats.fishingEvents + 1
    elseif eventType == "player" then
        eventStats.playerEvents = eventStats.playerEvents + 1
    else
        eventStats.systemEvents = eventStats.systemEvents + 1
    end
    
    -- Update stat displays
    fishingLabel.Text = tostring(eventStats.fishingEvents)
    playerLabel.Text = tostring(eventStats.playerEvents)
    systemLabel.Text = tostring(eventStats.systemEvents)
    totalLabel.Text = tostring(eventStats.totalEvents)
    
    -- Check filter
    if currentFilter ~= "all" and currentFilter ~= eventType then
        return
    end
    
    -- Create log entry
    local timestamp = os.date("%H:%M:%S")
    local entry = {
        type = eventType,
        name = eventName,
        details = details,
        timestamp = timestamp
    }
    
    table.insert(eventLog, entry)
    if #eventLog > maxLogEntries then
        table.remove(eventLog, 1)
    end
    
    -- Create visual log entry
    local logEntry = Instance.new("Frame")
    logEntry.Parent = scrollFrame
    logEntry.Size = UDim2.new(1, -5, 0, 20)
    logEntry.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    logEntry.BorderSizePixel = 0
    logEntry.LayoutOrder = eventStats.totalEvents
    Instance.new("UICorner", logEntry).CornerRadius = UDim.new(0, 3)
    
    local timeLabel = Instance.new("TextLabel")
    timeLabel.Parent = logEntry
    timeLabel.Size = UDim2.new(0, 60, 1, 0)
    timeLabel.BackgroundTransparency = 1
    timeLabel.Text = timestamp
    timeLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
    timeLabel.Font = Enum.Font.SourceSans
    timeLabel.TextSize = 9
    timeLabel.TextXAlignment = Enum.TextXAlignment.Left
    
    local typeLabel = Instance.new("TextLabel")
    typeLabel.Parent = logEntry
    typeLabel.Size = UDim2.new(0, 60, 1, 0)
    typeLabel.Position = UDim2.new(0, 65, 0, 0)
    typeLabel.BackgroundTransparency = 1
    typeLabel.Text = string.upper(eventType)
    typeLabel.Font = Enum.Font.SourceSansBold
    typeLabel.TextSize = 9
    typeLabel.TextXAlignment = Enum.TextXAlignment.Left
    
    if eventType == "fishing" then
        typeLabel.TextColor3 = Color3.fromRGB(100, 200, 255)
    elseif eventType == "player" then
        typeLabel.TextColor3 = Color3.fromRGB(255, 200, 100)
    else
        typeLabel.TextColor3 = Color3.fromRGB(200, 255, 100)
    end
    
    local nameLabel = Instance.new("TextLabel")
    nameLabel.Parent = logEntry
    nameLabel.Size = UDim2.new(1, -130, 1, 0)
    nameLabel.Position = UDim2.new(0, 130, 0, 0)
    nameLabel.BackgroundTransparency = 1
    nameLabel.Text = eventName .. (details and (" - " .. details) or "")
    nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    nameLabel.Font = Enum.Font.SourceSans
    nameLabel.TextSize = 9
    nameLabel.TextXAlignment = Enum.TextXAlignment.Left
    nameLabel.TextTruncate = Enum.TextTruncate.AtEnd
    
    -- Auto-scroll to bottom
    scrollFrame.CanvasSize = UDim2.new(0, 0, 0, #scrollFrame:GetChildren() * 21)
    scrollFrame.CanvasPosition = Vector2.new(0, scrollFrame.CanvasSize.Y.Offset)
    
    -- Remove old entries if too many
    if #scrollFrame:GetChildren() > maxLogEntries + 1 then -- +1 for UIListLayout
        for i, child in pairs(scrollFrame:GetChildren()) do
            if child:IsA("Frame") and i <= #scrollFrame:GetChildren() - maxLogEntries then
                child:Destroy()
            end
        end
    end
end

-- Monitor RemoteEvents
local oldNamecall
oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
    local method = getnamecallmethod()
    local args = {...}
    
    if (method == "FireServer" or method == "InvokeServer") and self.Name then
        local eventName = self.Name
        local eventType = "system"
        local details = method .. " with " .. #args .. " args"
        
        -- Categorize event
        local lowerName = string.lower(eventName)
        if string.find(lowerName, "fish") or string.find(lowerName, "rod") or string.find(lowerName, "bait") then
            eventType = "fishing"
        elseif string.find(lowerName, "player") or string.find(lowerName, "character") or string.find(lowerName, "humanoid") then
            eventType = "player"
        end
        
        addEventLog(eventType, eventName, details)
    end
    
    return oldNamecall(self, ...)
end)

-- Monitor player events
local function monitorPlayerEvents()
    if LocalPlayer.Character then
        local humanoid = LocalPlayer.Character:FindFirstChild("Humanoid")
        if humanoid then
            humanoid.Died:Connect(function()
                addEventLog("player", "Player Died", "Character died")
            end)
            
            humanoid.HealthChanged:Connect(function(health)
                if health < 20 then
                    addEventLog("player", "Low Health", "Health: " .. math.floor(health))
                end
            end)
        end
    end
end

LocalPlayer.CharacterAdded:Connect(function(character)
    addEventLog("player", "Character Spawned", "New character loaded")
    task.wait(1)
    monitorPlayerEvents()
end)

-- Monitor game events
RunService.Heartbeat:Connect(function()
    -- Animate live indicator
    local time = tick()
    local pulse = math.sin(time * 4) * 0.5 + 0.5
    liveIndicator.BackgroundColor3 = Color3.fromRGB(0, 255 * pulse, 0)
end)

-- Button functions
clearBtn.MouseButton1Click:Connect(function()
    for _, child in pairs(scrollFrame:GetChildren()) do
        if child:IsA("Frame") then
            child:Destroy()
        end
    end
    eventLog = {}
    eventStats = {fishingEvents = 0, playerEvents = 0, systemEvents = 0, totalEvents = 0}
    fishingLabel.Text = "0"
    playerLabel.Text = "0"
    systemLabel.Text = "0"
    totalLabel.Text = "0"
    scrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
end)

pauseBtn.MouseButton1Click:Connect(function()
    isMonitoring = not isMonitoring
    pauseBtn.Text = isMonitoring and "Pause" or "Resume"
    pauseBtn.BackgroundColor3 = isMonitoring and Color3.fromRGB(150, 150, 70) or Color3.fromRGB(70, 150, 70)
    liveText.Text = isMonitoring and "LIVE" or "PAUSED"
    liveText.TextColor3 = isMonitoring and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 150, 0)
end)

exportBtn.MouseButton1Click:Connect(function()
    local exportData = {"=== GAME EVENTS LOG EXPORT ===", "Timestamp: " .. os.date(), ""}
    table.insert(exportData, "Statistics:")
    table.insert(exportData, "Total Events: " .. eventStats.totalEvents)
    table.insert(exportData, "Fishing Events: " .. eventStats.fishingEvents)
    table.insert(exportData, "Player Events: " .. eventStats.playerEvents)
    table.insert(exportData, "System Events: " .. eventStats.systemEvents)
    table.insert(exportData, "")
    table.insert(exportData, "Event Log:")
    
    for _, entry in pairs(eventLog) do
        table.insert(exportData, string.format("[%s] %s: %s - %s", 
            entry.timestamp, string.upper(entry.type), entry.name, entry.details or ""))
    end
    
    local result = table.concat(exportData, "\n")
    
    if setclipboard then
        setclipboard(result)
        exportBtn.Text = "Copied!"
    else
        print(result)
        exportBtn.Text = "Printed"
    end
    
    task.spawn(function()
        task.wait(1)
        exportBtn.Text = "Export"
    end)
end)

local filters = {"all", "fishing", "player", "system"}
local filterIndex = 1

filterBtn.MouseButton1Click:Connect(function()
    filterIndex = filterIndex + 1
    if filterIndex > #filters then filterIndex = 1 end
    
    currentFilter = filters[filterIndex]
    filterBtn.Text = "Filter: " .. string.upper(currentFilter)
    
    -- Clear and refresh display based on filter
    for _, child in pairs(scrollFrame:GetChildren()) do
        if child:IsA("Frame") then
            child:Destroy()
        end
    end
    
    for _, entry in pairs(eventLog) do
        if currentFilter == "all" or entry.type == currentFilter then
            addEventLog(entry.type, entry.name, entry.details)
        end
    end
end)

closeBtn.MouseButton1Click:Connect(function()
    screen:Destroy()
    print("Game Events Monitor closed")
end)

-- Initialize monitoring
monitorPlayerEvents()
addEventLog("system", "Events Monitor Started", "Monitoring initialized")

print("⚡ Game Events Monitor started!")
print("📊 Real-time monitoring of fishing, player, and system events")
print("💡 Use this data to develop new features and improve main.lua")
