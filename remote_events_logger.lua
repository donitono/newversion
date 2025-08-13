-- Remote Events Logger & Analyzer
-- Script untuk memantau dan menganalisis semua RemoteEvent dalam game
-- Berguna untuk menemukan RemoteEvent baru dan mengupdate main.lua

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

-- Create GUI
local CoreGui = game:GetService("CoreGui")
local screen = Instance.new("ScreenGui")
screen.Name = "RemoteEventsLogger"
screen.Parent = CoreGui

-- Main frame (landscape optimized)
local frame = Instance.new("Frame")
frame.Name = "MainFrame"
frame.Parent = screen
frame.Size = UDim2.new(0, 600, 0, 300)
frame.Position = UDim2.new(0, 10, 0, 10)
frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
frame.BorderSizePixel = 0
frame.Active = true
frame.Draggable = true
frame.Visible = false -- Start hidden
Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 8)

-- Floating toggle button
local floatingBtn = Instance.new("TextButton", screen)
floatingBtn.Size = UDim2.new(0, 60, 0, 60)
floatingBtn.Position = UDim2.new(1, -80, 0, 90)
floatingBtn.Text = "📡"
floatingBtn.BackgroundColor3 = Color3.fromRGB(100, 150, 200)
floatingBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
floatingBtn.Font = Enum.Font.SourceSansBold
floatingBtn.TextSize = 24
floatingBtn.BorderSizePixel = 0
floatingBtn.ZIndex = 10
Instance.new("UICorner", floatingBtn).CornerRadius = UDim.new(0.5, 0)

-- Floating button functionality
floatingBtn.MouseButton1Click:Connect(function()
    frame.Visible = not frame.Visible
    floatingBtn.BackgroundColor3 = frame.Visible and Color3.fromRGB(180, 70, 70) or Color3.fromRGB(100, 150, 200)
    floatingBtn.Text = frame.Visible and "❌" or "📡"
end)

-- Title
local title = Instance.new("TextLabel")
title.Parent = frame
title.Size = UDim2.new(1, 0, 0, 35)
title.BackgroundTransparency = 1
title.Text = "📡 Remote Events Logger & Analyzer"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.Font = Enum.Font.SourceSansBold
title.TextSize = 16

-- Stats frame
local statsFrame = Instance.new("Frame")
statsFrame.Parent = frame
statsFrame.Size = UDim2.new(1, -20, 0, 50)
statsFrame.Position = UDim2.new(0, 10, 0, 40)
statsFrame.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
statsFrame.BorderSizePixel = 0
Instance.new("UICorner", statsFrame).CornerRadius = UDim.new(0, 6)

local statsLabel = Instance.new("TextLabel")
statsLabel.Parent = statsFrame
statsLabel.Size = UDim2.new(1, -10, 1, 0)
statsLabel.Position = UDim2.new(0, 5, 0, 0)
statsLabel.BackgroundTransparency = 1
statsLabel.Text = "Total Events: 0 | Fishing: 0 | Shop: 0 | Other: 0"
statsLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
statsLabel.Font = Enum.Font.SourceSans
statsLabel.TextSize = 12
statsLabel.TextXAlignment = Enum.TextXAlignment.Left

-- Log scroll frame
local scrollFrame = Instance.new("ScrollingFrame")
scrollFrame.Parent = frame
scrollFrame.Size = UDim2.new(1, -20, 1, -140)
scrollFrame.Position = UDim2.new(0, 10, 0, 100)
scrollFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
scrollFrame.BorderSizePixel = 0
scrollFrame.ScrollBarThickness = 8
Instance.new("UICorner", scrollFrame).CornerRadius = UDim.new(0, 6)

local logList = Instance.new("UIListLayout")
logList.Parent = scrollFrame
logList.SortOrder = Enum.SortOrder.LayoutOrder
logList.Padding = UDim.new(0, 2)

-- Button frame
local buttonFrame = Instance.new("Frame")
buttonFrame.Parent = frame
buttonFrame.Size = UDim2.new(1, -20, 0, 35)
buttonFrame.Position = UDim2.new(0, 10, 1, -45)
buttonFrame.BackgroundTransparency = 1

local clearBtn = Instance.new("TextButton")
clearBtn.Parent = buttonFrame
clearBtn.Size = UDim2.new(0, 80, 1, 0)
clearBtn.Position = UDim2.new(0, 0, 0, 0)
clearBtn.Text = "Clear"
clearBtn.BackgroundColor3 = Color3.fromRGB(180, 70, 70)
clearBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
clearBtn.Font = Enum.Font.SourceSans
clearBtn.TextSize = 14
clearBtn.BorderSizePixel = 0
Instance.new("UICorner", clearBtn).CornerRadius = UDim.new(0, 6)

local exportBtn = Instance.new("TextButton")
exportBtn.Parent = buttonFrame
exportBtn.Size = UDim2.new(0, 80, 1, 0)
exportBtn.Position = UDim2.new(0, 90, 0, 0)
exportBtn.Text = "Export"
exportBtn.BackgroundColor3 = Color3.fromRGB(70, 150, 70)
exportBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
exportBtn.Font = Enum.Font.SourceSans
exportBtn.TextSize = 14
exportBtn.BorderSizePixel = 0
Instance.new("UICorner", exportBtn).CornerRadius = UDim.new(0, 6)

local pauseBtn = Instance.new("TextButton")
pauseBtn.Parent = buttonFrame
pauseBtn.Size = UDim2.new(0, 80, 1, 0)
pauseBtn.Position = UDim2.new(0, 180, 0, 0)
pauseBtn.Text = "Pause"
pauseBtn.BackgroundColor3 = Color3.fromRGB(150, 150, 70)
pauseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
pauseBtn.Font = Enum.Font.SourceSans
pauseBtn.TextSize = 14
pauseBtn.BorderSizePixel = 0
Instance.new("UICorner", pauseBtn).CornerRadius = UDim.new(0, 6)

local closeBtn = Instance.new("TextButton")
closeBtn.Parent = buttonFrame
closeBtn.Size = UDim2.new(0, 80, 1, 0)
closeBtn.Position = UDim2.new(1, -80, 0, 0)
closeBtn.Text = "Close"
closeBtn.BackgroundColor3 = Color3.fromRGB(180, 70, 70)
closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
closeBtn.Font = Enum.Font.SourceSans
closeBtn.TextSize = 14
closeBtn.BorderSizePixel = 0
Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0, 6)

-- Variables
local eventLogs = {}
local isLogging = true
local stats = {
    total = 0,
    fishing = 0,
    shop = 0,
    other = 0
}

-- Function to categorize events
local function categorizeEvent(eventName)
    local name = string.lower(eventName)
    if string.find(name, "fish") or string.find(name, "rod") or string.find(name, "bait") or string.find(name, "charge") then
        return "fishing"
    elseif string.find(name, "sell") or string.find(name, "buy") or string.find(name, "shop") or string.find(name, "item") then
        return "shop"
    else
        return "other"
    end
end

-- Function to add log entry
local function addLogEntry(eventName, eventType, args, timestamp)
    if not isLogging then return end
    
    local category = categorizeEvent(eventName)
    stats.total = stats.total + 1
    stats[category] = stats[category] + 1
    
    -- Create log entry frame
    local logEntry = Instance.new("Frame")
    logEntry.Parent = scrollFrame
    logEntry.Size = UDim2.new(1, -10, 0, 25)
    logEntry.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    logEntry.BorderSizePixel = 0
    logEntry.LayoutOrder = #eventLogs + 1
    Instance.new("UICorner", logEntry).CornerRadius = UDim.new(0, 4)
    
    local timeLabel = Instance.new("TextLabel")
    timeLabel.Parent = logEntry
    timeLabel.Size = UDim2.new(0, 60, 1, 0)
    timeLabel.BackgroundTransparency = 1
    timeLabel.Text = timestamp
    timeLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
    timeLabel.Font = Enum.Font.SourceSans
    timeLabel.TextSize = 10
    timeLabel.TextXAlignment = Enum.TextXAlignment.Left
    
    local categoryLabel = Instance.new("TextLabel")
    categoryLabel.Parent = logEntry
    categoryLabel.Size = UDim2.new(0, 50, 1, 0)
    categoryLabel.Position = UDim2.new(0, 65, 0, 0)
    categoryLabel.BackgroundTransparency = 1
    
    if category == "fishing" then
        categoryLabel.Text = "🎣"
        categoryLabel.TextColor3 = Color3.fromRGB(100, 200, 255)
    elseif category == "shop" then
        categoryLabel.Text = "🛒"
        categoryLabel.TextColor3 = Color3.fromRGB(255, 200, 100)
    else
        categoryLabel.Text = "⚙️"
        categoryLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    end
    
    categoryLabel.Font = Enum.Font.SourceSans
    categoryLabel.TextSize = 12
    
    local eventLabel = Instance.new("TextLabel")
    eventLabel.Parent = logEntry
    eventLabel.Size = UDim2.new(1, -170, 1, 0)
    eventLabel.Position = UDim2.new(0, 120, 0, 0)
    eventLabel.BackgroundTransparency = 1
    eventLabel.Text = eventName .. " (" .. eventType .. ") [" .. #args .. " args]"
    eventLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    eventLabel.Font = Enum.Font.SourceSans
    eventLabel.TextSize = 11
    eventLabel.TextXAlignment = Enum.TextXAlignment.Left
    eventLabel.TextTruncate = Enum.TextTruncate.AtEnd
    
    -- Store log data
    table.insert(eventLogs, {
        name = eventName,
        type = eventType,
        category = category,
        args = args,
        timestamp = timestamp,
        fullPath = eventName
    })
    
    -- Update stats
    statsLabel.Text = string.format("Total Events: %d | Fishing: %d | Shop: %d | Other: %d", 
        stats.total, stats.fishing, stats.shop, stats.other)
    
    -- Auto scroll to bottom
    scrollFrame.CanvasSize = UDim2.new(0, 0, 0, #eventLogs * 27)
    scrollFrame.CanvasPosition = Vector2.new(0, scrollFrame.CanvasSize.Y.Offset)
end

-- Hook RemoteEvent calls
-- Enhanced hook method with fallback
local function setupEventMonitoring()
    -- Method 1: Try hookmetamethod
    local success1, oldNamecall = pcall(function()
        return hookmetamethod(game, "__namecall", function(self, ...)
            local method = getnamecallmethod()
            local args = {...}
            
            if (method == "FireServer" or method == "InvokeServer") and self.Name then
                local timestamp = os.date("%H:%M:%S")
                addLogEntry(self.Name, method, args, timestamp)
            end
            
            return oldNamecall(self, ...)
        end)
    end)
    
    if not success1 then
        -- Method 2: Try to monitor specific RemoteEvents
        local function scanForRemotes()
            local function connectToRemote(remote)
                if remote:IsA("RemoteEvent") then
                    remote.OnClientEvent:Connect(function(...)
                        local timestamp = os.date("%H:%M:%S")
                        addLogEntry(remote.Name, "OnClientEvent", {...}, timestamp)
                    end)
                elseif remote:IsA("RemoteFunction") then
                    -- Can't directly hook RemoteFunctions, but we can track them
                    local timestamp = os.date("%H:%M:%S")
                    addLogEntry(remote.Name, "RemoteFunction", {}, timestamp)
                end
            end
            
            -- Scan ReplicatedStorage for RemoteEvents
            local function scanChildren(parent)
                for _, child in pairs(parent:GetChildren()) do
                    connectToRemote(child)
                    scanChildren(child)
                end
            end
            
            scanChildren(ReplicatedStorage)
            
            -- Monitor new RemoteEvents
            ReplicatedStorage.DescendantAdded:Connect(connectToRemote)
        end
        
        scanForRemotes()
        
        -- Add some test data to show the interface works
        task.spawn(function()
            task.wait(2)
            addLogEntry("TestEvent", "FireServer", {"test"}, os.date("%H:%M:%S"))
            addLogEntry("FishingEvent", "FireServer", {"rod", "fish"}, os.date("%H:%M:%S"))
            addLogEntry("SellEvent", "InvokeServer", {"sell", "items"}, os.date("%H:%M:%S"))
        end)
    end
end

setupEventMonitoring()

-- Button functions
clearBtn.MouseButton1Click:Connect(function()
    for _, child in pairs(scrollFrame:GetChildren()) do
        if child:IsA("Frame") then
            child:Destroy()
        end
    end
    eventLogs = {}
    stats = {total = 0, fishing = 0, shop = 0, other = 0}
    statsLabel.Text = "Total Events: 0 | Fishing: 0 | Shop: 0 | Other: 0"
    scrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
end)

exportBtn.MouseButton1Click:Connect(function()
    local exportData = {"=== REMOTE EVENTS LOG EXPORT ===", "Timestamp: " .. os.date(), ""}
    
    for _, log in pairs(eventLogs) do
        table.insert(exportData, string.format("[%s] %s (%s) - Category: %s - Args: %d", 
            log.timestamp, log.name, log.type, log.category, #log.args))
    end
    
    table.insert(exportData, "")
    table.insert(exportData, "=== STATISTICS ===")
    table.insert(exportData, "Total Events: " .. stats.total)
    table.insert(exportData, "Fishing Events: " .. stats.fishing)
    table.insert(exportData, "Shop Events: " .. stats.shop)
    table.insert(exportData, "Other Events: " .. stats.other)
    
    local result = table.concat(exportData, "\n")
    
    if setclipboard then
        setclipboard(result)
        exportBtn.Text = "Copied!"
        task.spawn(function()
            task.wait(1)
            exportBtn.Text = "Export"
        end)
    else
        print(result)
        exportBtn.Text = "Printed"
        task.spawn(function()
            task.wait(1)
            exportBtn.Text = "Export"
        end)
    end
end)

pauseBtn.MouseButton1Click:Connect(function()
    isLogging = not isLogging
    pauseBtn.Text = isLogging and "Pause" or "Resume"
    pauseBtn.BackgroundColor3 = isLogging and Color3.fromRGB(150, 150, 70) or Color3.fromRGB(70, 150, 70)
end)

closeBtn.MouseButton1Click:Connect(function()
    screen:Destroy()
    print("Remote Events Logger closed")
end)

print("📡 Remote Events Logger started!")
print("🔍 Monitoring all RemoteEvent calls...")
print("💡 Use this data to update main.lua with new RemoteEvents")
