-- Enhanced Remote Events Logger v2.0
-- Advanced RemoteEvent monitoring dengan parameter analysis dan hooking
-- Major upgrade dari remote_events_logger.lua

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer

-- Safe execution wrapper
local function safeExecute(func, errorMsg)
    local success, result = pcall(func)
    if not success then
        warn('Remote Events Logger Error: ' .. (errorMsg or 'Unknown') .. ' - ' .. tostring(result))
        return false, result
    end
    return true, result
end

-- Remove existing remote events GUIs
safeExecute(function()
    local CoreGui = game:GetService("CoreGui")
    for _, gui in pairs(CoreGui:GetChildren()) do
        if gui.Name:find("RemoteEvents") or gui.Name:find("EventLogger") then
            gui:Destroy()
        end
    end
end, "GUI cleanup")

-- Create enhanced GUI
local CoreGui = game:GetService("CoreGui")
local screen = Instance.new("ScreenGui")
screen.Name = "EnhancedRemoteEventsLogger"
screen.Parent = CoreGui
screen.ResetOnSpawn = false

-- Main frame (larger for more data)
local mainFrame = Instance.new("Frame")
mainFrame.Parent = screen
mainFrame.Size = UDim2.new(0, 800, 0, 500)
mainFrame.Position = UDim2.new(0.5, -400, 0.5, -250)
mainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.Draggable = true
mainFrame.Visible = false
Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 15)

-- Floating toggle button
local floatingBtn = Instance.new("TextButton")
floatingBtn.Parent = screen
floatingBtn.Size = UDim2.new(0, 65, 0, 65)
floatingBtn.Position = UDim2.new(1, -85, 0, 90)
floatingBtn.Text = "📡"
floatingBtn.BackgroundColor3 = Color3.fromRGB(100, 150, 200)
floatingBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
floatingBtn.Font = Enum.Font.SourceSansBold
floatingBtn.TextSize = 26
floatingBtn.BorderSizePixel = 0
floatingBtn.ZIndex = 10
Instance.new("UICorner", floatingBtn).CornerRadius = UDim.new(0.5, 0)

-- Gradient background
local gradient = Instance.new("UIGradient")
gradient.Parent = mainFrame
gradient.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, Color3.fromRGB(30, 30, 45)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(15, 15, 25))
}
gradient.Rotation = 45

-- Title bar
local titleBar = Instance.new("Frame")
titleBar.Parent = mainFrame
titleBar.Size = UDim2.new(1, 0, 0, 45)
titleBar.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
titleBar.BorderSizePixel = 0
Instance.new("UICorner", titleBar).CornerRadius = UDim.new(0, 15)

local titleLabel = Instance.new("TextLabel")
titleLabel.Parent = titleBar
titleLabel.Size = UDim2.new(1, -120, 1, 0)
titleLabel.Position = UDim2.new(0, 15, 0, 0)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "📡 Enhanced Remote Events Logger v2.0"
titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
titleLabel.Font = Enum.Font.SourceSansBold
titleLabel.TextSize = 18
titleLabel.TextXAlignment = Enum.TextXAlignment.Left

-- Status indicator
local statusIndicator = Instance.new("Frame")
statusIndicator.Parent = titleBar
statusIndicator.Size = UDim2.new(0, 12, 0, 12)
statusIndicator.Position = UDim2.new(1, -90, 0.5, -6)
statusIndicator.BackgroundColor3 = Color3.fromRGB(80, 200, 80)
statusIndicator.BorderSizePixel = 0
Instance.new("UICorner", statusIndicator).CornerRadius = UDim.new(0.5, 0)

local statusLabel = Instance.new("TextLabel")
statusLabel.Parent = titleBar
statusLabel.Size = UDim2.new(0, 70, 1, 0)
statusLabel.Position = UDim2.new(1, -75, 0, 0)
statusLabel.BackgroundTransparency = 1
statusLabel.Text = "LIVE"
statusLabel.TextColor3 = Color3.fromRGB(80, 200, 80)
statusLabel.Font = Enum.Font.SourceSansBold
statusLabel.TextSize = 12
statusLabel.TextXAlignment = Enum.TextXAlignment.Left

-- Close button
local closeBtn = Instance.new("TextButton")
closeBtn.Parent = titleBar
closeBtn.Size = UDim2.new(0, 35, 0, 35)
closeBtn.Position = UDim2.new(1, -40, 0, 5)
closeBtn.Text = "✖"
closeBtn.BackgroundColor3 = Color3.fromRGB(200, 80, 80)
closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
closeBtn.Font = Enum.Font.SourceSansBold
closeBtn.TextSize = 16
closeBtn.BorderSizePixel = 0
Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0, 8)

-- Tab container
local tabContainer = Instance.new("Frame")
tabContainer.Parent = mainFrame
tabContainer.Size = UDim2.new(1, -20, 0, 40)
tabContainer.Position = UDim2.new(0, 10, 0, 50)
tabContainer.BackgroundTransparency = 1

local tabLayout = Instance.new("UIListLayout")
tabLayout.Parent = tabContainer
tabLayout.FillDirection = Enum.FillDirection.Horizontal
tabLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
tabLayout.Padding = UDim.new(0, 5)

-- Content area
local contentFrame = Instance.new("Frame")
contentFrame.Parent = mainFrame
contentFrame.Size = UDim2.new(1, -20, 1, -140)
contentFrame.Position = UDim2.new(0, 10, 0, 95)
contentFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
contentFrame.BorderSizePixel = 0
Instance.new("UICorner", contentFrame).CornerRadius = UDim.new(0, 10)

-- Scrollable content
local scrollFrame = Instance.new("ScrollingFrame")
scrollFrame.Parent = contentFrame
scrollFrame.Size = UDim2.new(1, -10, 1, -10)
scrollFrame.Position = UDim2.new(0, 5, 0, 5)
scrollFrame.BackgroundTransparency = 1
scrollFrame.BorderSizePixel = 0
scrollFrame.ScrollBarThickness = 10
scrollFrame.ScrollBarImageColor3 = Color3.fromRGB(100, 100, 150)
scrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)

local contentText = Instance.new("TextLabel")
contentText.Parent = scrollFrame
contentText.Size = UDim2.new(1, -10, 1, 0)
contentText.Position = UDim2.new(0, 5, 0, 0)
contentText.BackgroundTransparency = 1
contentText.Text = "Initializing enhanced remote events monitoring..."
contentText.TextColor3 = Color3.fromRGB(255, 255, 255)
contentText.Font = Enum.Font.SourceSans
contentText.TextSize = 11
contentText.TextWrapped = true
contentText.TextXAlignment = Enum.TextXAlignment.Left
contentText.TextYAlignment = Enum.TextYAlignment.Top

-- Button container
local buttonFrame = Instance.new("Frame")
buttonFrame.Parent = mainFrame
buttonFrame.Size = UDim2.new(1, -20, 0, 40)
buttonFrame.Position = UDim2.new(0, 10, 1, -45)
buttonFrame.BackgroundTransparency = 1

local buttonLayout = Instance.new("UIListLayout")
buttonLayout.Parent = buttonFrame
buttonLayout.FillDirection = Enum.FillDirection.Horizontal
buttonLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
buttonLayout.Padding = UDim.new(0, 10)

-- Enhanced data storage
local remoteData = {
    events = {},
    functions = {},
    eventLog = {},
    patterns = {},
    categories = {
        fishing = {},
        selling = {},
        buying = {},
        teleport = {},
        ui = {},
        other = {}
    },
    hooks = {},
    statistics = {
        totalEvents = 0,
        totalFunctions = 0,
        categoryCounts = {}
    }
}

-- Advanced categorization function
local function categorizeRemote(remoteName, remoteType)
    local name = remoteName:lower()
    local category = "other"
    
    if name:find("fish") or name:find("catch") or name:find("rod") or name:find("bait") then
        category = "fishing"
    elseif name:find("sell") or name:find("shop") or name:find("merchant") then
        category = "selling"
    elseif name:find("buy") or name:find("purchase") or name:find("store") then
        category = "buying"
    elseif name:find("teleport") or name:find("tp") or name:find("travel") then
        category = "teleport"
    elseif name:find("ui") or name:find("gui") or name:find("menu") or name:find("button") then
        category = "ui"
    end
    
    return category
end

-- Hook function for monitoring calls
local function hookRemote(remote, remoteType)
    if not remote or remoteData.hooks[remote] then return end
    
    safeExecute(function()
        if remoteType == "RemoteEvent" then
            local originalFireServer = remote.FireServer
            remote.FireServer = function(self, ...)
                local args = {...}
                local logEntry = {
                    name = remote.Name,
                    type = "RemoteEvent",
                    action = "FireServer",
                    args = args,
                    timestamp = tick()
                }
                table.insert(remoteData.eventLog, logEntry)
                
                -- Limit log size
                if #remoteData.eventLog > 1000 then
                    table.remove(remoteData.eventLog, 1)
                end
                
                return originalFireServer(self, ...)
            end
        elseif remoteType == "RemoteFunction" then
            local originalInvokeServer = remote.InvokeServer
            remote.InvokeServer = function(self, ...)
                local args = {...}
                local logEntry = {
                    name = remote.Name,
                    type = "RemoteFunction",
                    action = "InvokeServer",
                    args = args,
                    timestamp = tick()
                }
                table.insert(remoteData.eventLog, logEntry)
                
                -- Limit log size
                if #remoteData.eventLog > 1000 then
                    table.remove(remoteData.eventLog, 1)
                end
                
                return originalInvokeServer(self, ...)
            end
        end
        
        remoteData.hooks[remote] = true
    end, "Hook setup for " .. remote.Name)
end

-- Scan function with enhanced detection
local function scanRemotes()
    remoteData.events = {}
    remoteData.functions = {}
    
    local function deepScan(parent, path)
        safeExecute(function()
            for _, obj in pairs(parent:GetChildren()) do
                local fullPath = path .. "/" .. obj.Name
                
                if obj:IsA("RemoteEvent") then
                    local category = categorizeRemote(obj.Name, "RemoteEvent")
                    local remoteInfo = {
                        name = obj.Name,
                        fullName = obj:GetFullName(),
                        path = fullPath,
                        category = category,
                        object = obj
                    }
                    
                    table.insert(remoteData.events, remoteInfo)
                    table.insert(remoteData.categories[category], remoteInfo)
                    
                    -- Hook the remote
                    hookRemote(obj, "RemoteEvent")
                    
                elseif obj:IsA("RemoteFunction") then
                    local category = categorizeRemote(obj.Name, "RemoteFunction")
                    local remoteInfo = {
                        name = obj.Name,
                        fullName = obj:GetFullName(),
                        path = fullPath,
                        category = category,
                        object = obj
                    }
                    
                    table.insert(remoteData.functions, remoteInfo)
                    table.insert(remoteData.categories[category], remoteInfo)
                    
                    -- Hook the remote
                    hookRemote(obj, "RemoteFunction")
                end
                
                -- Recursive scan
                deepScan(obj, fullPath)
            end
        end, "Deep scan of " .. parent.Name)
    end
    
    -- Scan ReplicatedStorage
    deepScan(ReplicatedStorage, "ReplicatedStorage")
    
    -- Update statistics
    remoteData.statistics.totalEvents = #remoteData.events
    remoteData.statistics.totalFunctions = #remoteData.functions
    
    for category, items in pairs(remoteData.categories) do
        remoteData.statistics.categoryCounts[category] = #items
    end
end

-- Tab definitions with enhanced content
local tabs = {
    {
        name = "Overview",
        icon = "📊",
        color = Color3.fromRGB(100, 150, 200),
        content = function()
            local result = "=== REMOTE EVENTS OVERVIEW ===\n\n"
            
            result = result .. string.format("📡 Total RemoteEvents: %d\n", remoteData.statistics.totalEvents)
            result = result .. string.format("🔧 Total RemoteFunctions: %d\n", remoteData.statistics.totalFunctions)
            result = result .. string.format("📋 Event Log Entries: %d\n\n", #remoteData.eventLog)
            
            result = result .. "📈 CATEGORY BREAKDOWN:\n"
            for category, count in pairs(remoteData.statistics.categoryCounts) do
                if count > 0 then
                    local icon = "🔹"
                    if category == "fishing" then icon = "🎣"
                    elseif category == "selling" then icon = "💰"
                    elseif category == "buying" then icon = "🛒"
                    elseif category == "teleport" then icon = "🌀"
                    elseif category == "ui" then icon = "🖥️"
                    end
                    
                    result = result .. string.format("%s %s: %d\n", icon, category:upper(), count)
                end
            end
            
            result = result .. "\n🔍 SCAN STATUS:\n"
            result = result .. "✅ ReplicatedStorage scanned\n"
            result = result .. "✅ Remote hooking active\n"
            result = result .. "✅ Parameter monitoring enabled\n"
            result = result .. "✅ Real-time logging active\n\n"
            
            result = result .. "💡 Switch to other tabs for detailed analysis!"
            
            return result
        end
    },
    {
        name = "Events",
        icon = "📡",
        color = Color3.fromRGB(80, 160, 120),
        content = function()
            local result = "=== REMOTE EVENTS DETAILED ===\n\n"
            
            if #remoteData.events == 0 then
                result = result .. "❌ No RemoteEvents detected!\n"
                result = result .. "💡 Try refreshing or check if game is fully loaded.\n"
                return result
            end
            
            -- Group by category
            for category, events in pairs(remoteData.categories) do
                if #events > 0 then
                    local categoryEvents = {}
                    for _, event in pairs(events) do
                        if event.object:IsA("RemoteEvent") then
                            table.insert(categoryEvents, event)
                        end
                    end
                    
                    if #categoryEvents > 0 then
                        result = result .. string.format("🎯 %s EVENTS (%d):\n", category:upper(), #categoryEvents)
                        for _, event in pairs(categoryEvents) do
                            result = result .. string.format("  📡 %s\n     Path: %s\n\n", event.name, event.fullName)
                        end
                    end
                end
            end
            
            return result
        end
    },
    {
        name = "Functions",
        icon = "🔧",
        color = Color3.fromRGB(120, 80, 160),
        content = function()
            local result = "=== REMOTE FUNCTIONS DETAILED ===\n\n"
            
            if #remoteData.functions == 0 then
                result = result .. "❌ No RemoteFunctions detected!\n"
                result = result .. "💡 Try refreshing or check if game is fully loaded.\n"
                return result
            end
            
            -- Group by category
            for category, functions in pairs(remoteData.categories) do
                if #functions > 0 then
                    local categoryFunctions = {}
                    for _, func in pairs(functions) do
                        if func.object:IsA("RemoteFunction") then
                            table.insert(categoryFunctions, func)
                        end
                    end
                    
                    if #categoryFunctions > 0 then
                        result = result .. string.format("🎯 %s FUNCTIONS (%d):\n", category:upper(), #categoryFunctions)
                        for _, func in pairs(categoryFunctions) do
                            result = result .. string.format("  🔧 %s\n     Path: %s\n\n", func.name, func.fullName)
                        end
                    end
                end
            end
            
            return result
        end
    },
    {
        name = "Live Log",
        icon = "📋",
        color = Color3.fromRGB(200, 120, 80),
        content = function()
            local result = "=== LIVE EVENT LOG ===\n\n"
            
            if #remoteData.eventLog == 0 then
                result = result .. "📋 No events logged yet.\n"
                result = result .. "💡 Interact with the game to see RemoteEvent calls!\n"
                return result
            end
            
            result = result .. string.format("📊 Showing last %d events:\n\n", math.min(#remoteData.eventLog, 20))
            
            -- Show last 20 events
            local startIndex = math.max(1, #remoteData.eventLog - 19)
            for i = startIndex, #remoteData.eventLog do
                local entry = remoteData.eventLog[i]
                local timeStr = os.date("%H:%M:%S", entry.timestamp)
                
                result = result .. string.format("[%s] %s %s:%s\n", 
                    timeStr, entry.type, entry.name, entry.action)
                
                -- Show arguments if present
                if entry.args and #entry.args > 0 then
                    result = result .. "  Args: "
                    for j, arg in pairs(entry.args) do
                        if j > 1 then result = result .. ", " end
                        result = result .. tostring(arg)
                        if j >= 3 then 
                            result = result .. "..."
                            break
                        end
                    end
                    result = result .. "\n"
                end
                result = result .. "\n"
            end
            
            return result
        end
    },
    {
        name = "Export",
        icon = "💾",
        color = Color3.fromRGB(150, 100, 200),
        content = function()
            local result = "=== EXPORT FOR MAIN.LUA ===\n\n"
            
            result = result .. "🔧 Enhanced RemoteEvent data for automation:\n\n"
            result = result .. "-- Auto-Generated Remote Events Data\n"
            result = result .. "local RemoteEvents = {\n"
            
            -- Export by category
            for category, events in pairs(remoteData.categories) do
                if #events > 0 then
                    result = result .. string.format("    %s = {\n", category)
                    for _, event in pairs(events) do
                        result = result .. string.format('        %s = game:GetService("ReplicatedStorage"):WaitForChild("%s"),\n', 
                            event.name, event.name)
                    end
                    result = result .. "    },\n"
                end
            end
            
            result = result .. "}\n\n"
            result = result .. "-- Usage examples:\n"
            result = result .. "-- RemoteEvents.fishing.CastRod:FireServer(args)\n"
            result = result .. "-- RemoteEvents.selling.SellFish:FireServer(args)\n\n"
            
            result = result .. "📋 Click 'Copy Export' to copy to clipboard!\n"
            result = result .. "🎯 This data is auto-categorized for easy automation!"
            
            return result
        end
    }
}

-- Create tab buttons
local tabButtons = {}
local currentTab = 1

for i, tab in ipairs(tabs) do
    local tabBtn = Instance.new("TextButton")
    tabBtn.Parent = tabContainer
    tabBtn.Size = UDim2.new(0, 130, 1, 0)
    tabBtn.Text = tab.icon .. " " .. tab.name
    tabBtn.BackgroundColor3 = i == 1 and tab.color or Color3.fromRGB(50, 50, 60)
    tabBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    tabBtn.Font = Enum.Font.SourceSansBold
    tabBtn.TextSize = 12
    tabBtn.BorderSizePixel = 0
    Instance.new("UICorner", tabBtn).CornerRadius = UDim.new(0, 8)
    
    tabButtons[i] = tabBtn
    
    tabBtn.MouseButton1Click:Connect(function()
        currentTab = i
        
        -- Update tab appearance
        for j, btn in ipairs(tabButtons) do
            btn.BackgroundColor3 = j == i and tabs[j].color or Color3.fromRGB(50, 50, 60)
        end
        
        -- Update content
        safeExecute(function()
            contentText.Text = tab.content()
            scrollFrame.CanvasSize = UDim2.new(0, 0, 0, contentText.TextBounds.Y + 20)
        end, "Tab content update")
    end)
end

-- Create action buttons
local function createButton(text, color, callback)
    local btn = Instance.new("TextButton")
    btn.Parent = buttonFrame
    btn.Size = UDim2.new(0, 120, 1, 0)
    btn.Text = text
    btn.BackgroundColor3 = color
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Font = Enum.Font.SourceSansBold
    btn.TextSize = 12
    btn.BorderSizePixel = 0
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)
    
    btn.MouseButton1Click:Connect(callback)
    return btn
end

-- Refresh/Scan button
createButton("🔄 Refresh Scan", Color3.fromRGB(60, 150, 60), function()
    safeExecute(function()
        scanRemotes()
        contentText.Text = tabs[currentTab].content()
        scrollFrame.CanvasSize = UDim2.new(0, 0, 0, contentText.TextBounds.Y + 20)
        print("🔄 Remote events scan completed!")
    end, "Refresh scan")
end)

-- Copy export button
createButton("📋 Copy Export", Color3.fromRGB(200, 120, 80), function()
    if currentTab == 5 then -- Export tab
        local exportData = contentText.Text
        if setclipboard then
            setclipboard(exportData)
            print("📋 Remote events data copied to clipboard!")
        else
            print("📋 Remote events data printed to console")
            print(exportData)
        end
    else
        print("💡 Switch to Export tab first!")
    end
end)

-- Clear log button
createButton("🗑️ Clear Log", Color3.fromRGB(180, 70, 70), function()
    remoteData.eventLog = {}
    if currentTab == 4 then -- Live Log tab
        contentText.Text = tabs[currentTab].content()
        scrollFrame.CanvasSize = UDim2.new(0, 0, 0, contentText.TextBounds.Y + 20)
    end
    print("🗑️ Event log cleared!")
end)

-- Auto-refresh toggle
local autoRefresh = false
local autoRefreshConnection

createButton("⚡ Auto Refresh", Color3.fromRGB(100, 150, 200), function()
    autoRefresh = not autoRefresh
    
    if autoRefresh then
        autoRefreshConnection = task.spawn(function()
            while autoRefresh do
                task.wait(5) -- Refresh every 5 seconds
                if mainFrame.Visible then
                    safeExecute(function()
                        contentText.Text = tabs[currentTab].content()
                        scrollFrame.CanvasSize = UDim2.new(0, 0, 0, contentText.TextBounds.Y + 20)
                    end, "Auto refresh")
                end
            end
        end)
        print("⚡ Auto-refresh enabled (5s interval)")
    else
        if autoRefreshConnection then
            task.cancel(autoRefreshConnection)
        end
        print("⚡ Auto-refresh disabled")
    end
end)

-- Live log update
local liveLogConnection

local function startLiveUpdates()
    if liveLogConnection then
        liveLogConnection:Disconnect()
    end
    
    liveLogConnection = RunService.Heartbeat:Connect(function()
        if currentTab == 4 and mainFrame.Visible then -- Live Log tab
            safeExecute(function()
                contentText.Text = tabs[4].content()
                -- Auto-scroll to bottom
                scrollFrame.CanvasPosition = Vector2.new(0, scrollFrame.CanvasSize.Y.Offset)
            end, "Live log update")
        end
    end)
end

-- Toggle functionality
floatingBtn.MouseButton1Click:Connect(function()
    mainFrame.Visible = not mainFrame.Visible
    floatingBtn.Text = mainFrame.Visible and "❌" or "📡"
    floatingBtn.BackgroundColor3 = mainFrame.Visible and Color3.fromRGB(200, 80, 80) or Color3.fromRGB(100, 150, 200)
    
    if mainFrame.Visible then
        -- Animate show
        mainFrame.Size = UDim2.new(0, 0, 0, 0)
        local tween = TweenService:Create(mainFrame, TweenInfo.new(0.4, Enum.EasingStyle.Back), {
            Size = UDim2.new(0, 800, 0, 500)
        })
        tween:Play()
        
        -- Initial scan and load content
        safeExecute(function()
            scanRemotes()
            contentText.Text = tabs[currentTab].content()
            scrollFrame.CanvasSize = UDim2.new(0, 0, 0, contentText.TextBounds.Y + 20)
            startLiveUpdates()
        end, "Interface show")
    else
        if liveLogConnection then
            liveLogConnection:Disconnect()
        end
    end
end)

-- Close functionality
closeBtn.MouseButton1Click:Connect(function()
    if liveLogConnection then
        liveLogConnection:Disconnect()
    end
    if autoRefreshConnection then
        task.cancel(autoRefreshConnection)
    end
    screen:Destroy()
    print("📡 Enhanced Remote Events Logger closed")
end)

-- Hotkey support (Ctrl+R)
local UserInputService = game:GetService("UserInputService")
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if not gameProcessed and input.KeyCode == Enum.KeyCode.R and UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
        floatingBtn.MouseButton1Click:Fire()
    end
end)

-- Initialize
print("📡 Enhanced Remote Events Logger v2.0 started!")
print("✨ New features: Parameter monitoring, Auto-categorization, Live hooking")
print("🎮 Press Ctrl+R or click floating button to open")
print("🚀 Major upgrade with advanced analysis capabilities!")
