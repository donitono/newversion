-- Feature Analyzer & Updater
-- Script untuk menganalisis fitur yang ada dan memberikan saran update untuk main.lua
-- Membantu menemukan celah dan peluang pengembangan

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")
local LocalPlayer = Players.LocalPlayer

-- Create GUI
local CoreGui = game:GetService("CoreGui")
local screen = Instance.new("ScreenGui")
screen.Name = "FeatureAnalyzer"
screen.Parent = CoreGui

-- Main frame (landscape optimized)
local frame = Instance.new("Frame")
frame.Parent = screen
frame.Size = UDim2.new(0, 750, 0, 350)
frame.Position = UDim2.new(0, 10, 0, 10)
frame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
frame.BorderSizePixel = 0
frame.Active = true
frame.Draggable = true
frame.Visible = false -- Start hidden
Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 10)

-- Floating toggle button
local floatingBtn = Instance.new("TextButton", screen)
floatingBtn.Size = UDim2.new(0, 60, 0, 60)
floatingBtn.Position = UDim2.new(1, -80, 0, 300)
floatingBtn.Text = "🔍"
floatingBtn.BackgroundColor3 = Color3.fromRGB(200, 120, 80)
floatingBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
floatingBtn.Font = Enum.Font.SourceSansBold
floatingBtn.TextSize = 24
floatingBtn.BorderSizePixel = 0
floatingBtn.ZIndex = 10
Instance.new("UICorner", floatingBtn).CornerRadius = UDim.new(0.5, 0)

-- Floating button functionality
floatingBtn.MouseButton1Click:Connect(function()
    frame.Visible = not frame.Visible
    floatingBtn.BackgroundColor3 = frame.Visible and Color3.fromRGB(180, 70, 70) or Color3.fromRGB(200, 120, 80)
    floatingBtn.Text = frame.Visible and "❌" or "🔍"
end)

-- Gradient background
local gradient = Instance.new("UIGradient")
gradient.Parent = frame
gradient.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, Color3.fromRGB(30, 30, 30)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(15, 15, 15))
}
gradient.Rotation = 45

-- Title with icon
local titleFrame = Instance.new("Frame")
titleFrame.Parent = frame
titleFrame.Size = UDim2.new(1, 0, 0, 50)
titleFrame.BackgroundTransparency = 1

local titleIcon = Instance.new("TextLabel")
titleIcon.Parent = titleFrame
titleIcon.Size = UDim2.new(0, 40, 1, 0)
titleIcon.Position = UDim2.new(0, 10, 0, 0)
titleIcon.BackgroundTransparency = 1
titleIcon.Text = "🔍"
titleIcon.TextColor3 = Color3.fromRGB(100, 200, 255)
titleIcon.Font = Enum.Font.SourceSansBold
titleIcon.TextSize = 24

local title = Instance.new("TextLabel")
title.Parent = titleFrame
title.Size = UDim2.new(1, -60, 1, 0)
title.Position = UDim2.new(0, 50, 0, 0)
title.BackgroundTransparency = 1
title.Text = "Feature Analyzer & Updater"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.Font = Enum.Font.SourceSansBold
title.TextSize = 18
title.TextXAlignment = Enum.TextXAlignment.Left

local subtitle = Instance.new("TextLabel")
subtitle.Parent = titleFrame
subtitle.Size = UDim2.new(1, -60, 0, 20)
subtitle.Position = UDim2.new(0, 50, 0, 25)
subtitle.BackgroundTransparency = 1
subtitle.Text = "Analyze current features and suggest improvements for main.lua"
subtitle.TextColor3 = Color3.fromRGB(150, 150, 150)
subtitle.Font = Enum.Font.SourceSans
subtitle.TextSize = 12
subtitle.TextXAlignment = Enum.TextXAlignment.Left

-- Tab system
local tabFrame = Instance.new("Frame")
tabFrame.Parent = frame
tabFrame.Size = UDim2.new(1, -20, 0, 35)
tabFrame.Position = UDim2.new(0, 10, 0, 60)
tabFrame.BackgroundTransparency = 1

local tabs = {"Analysis", "Suggestions", "Updates", "Code Gen"}
local tabButtons = {}

for i, tabName in pairs(tabs) do
    local tab = Instance.new("TextButton")
    tab.Parent = tabFrame
    tab.Size = UDim2.new(0.25, -5, 1, 0)
    tab.Position = UDim2.new((i-1) * 0.25, (i-1) * 5, 0, 0)
    tab.Text = tabName
    tab.BackgroundColor3 = i == 1 and Color3.fromRGB(60, 120, 180) or Color3.fromRGB(40, 40, 40)
    tab.TextColor3 = Color3.fromRGB(255, 255, 255)
    tab.Font = Enum.Font.SourceSansBold
    tab.TextSize = 12
    tab.BorderSizePixel = 0
    Instance.new("UICorner", tab).CornerRadius = UDim.new(0, 6)
    
    tabButtons[tabName] = tab
end

-- Content area
local contentFrame = Instance.new("ScrollingFrame")
contentFrame.Parent = frame
contentFrame.Size = UDim2.new(1, -20, 1, -140)
contentFrame.Position = UDim2.new(0, 10, 0, 105)
contentFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
contentFrame.BorderSizePixel = 0
contentFrame.ScrollBarThickness = 8
Instance.new("UICorner", contentFrame).CornerRadius = UDim.new(0, 8)

local contentText = Instance.new("TextLabel")
contentText.Parent = contentFrame
contentText.Size = UDim2.new(1, -15, 1, 0)
contentText.Position = UDim2.new(0, 10, 0, 0)
contentText.BackgroundTransparency = 1
contentText.Text = "Loading analysis..."
contentText.TextColor3 = Color3.fromRGB(255, 255, 255)
contentText.Font = Enum.Font.SourceSans
contentText.TextSize = 11
contentText.TextWrapped = true
contentText.TextXAlignment = Enum.TextXAlignment.Left
contentText.TextYAlignment = Enum.TextYAlignment.Top

-- Control buttons
local buttonFrame = Instance.new("Frame")
buttonFrame.Parent = frame
buttonFrame.Size = UDim2.new(1, -20, 0, 30)
buttonFrame.Position = UDim2.new(0, 10, 1, -40)
buttonFrame.BackgroundTransparency = 1

local analyzeBtn = Instance.new("TextButton")
analyzeBtn.Parent = buttonFrame
analyzeBtn.Size = UDim2.new(0, 80, 1, 0)
analyzeBtn.Position = UDim2.new(0, 0, 0, 0)
analyzeBtn.Text = "🔄 Analyze"
analyzeBtn.BackgroundColor3 = Color3.fromRGB(50, 150, 50)
analyzeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
analyzeBtn.Font = Enum.Font.SourceSansBold
analyzeBtn.TextSize = 11
analyzeBtn.BorderSizePixel = 0
Instance.new("UICorner", analyzeBtn).CornerRadius = UDim.new(0, 6)

local exportBtn = Instance.new("TextButton")
exportBtn.Parent = buttonFrame
exportBtn.Size = UDim2.new(0, 80, 1, 0)
exportBtn.Position = UDim2.new(0, 90, 0, 0)
exportBtn.Text = "📋 Export"
exportBtn.BackgroundColor3 = Color3.fromRGB(70, 130, 180)
exportBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
exportBtn.Font = Enum.Font.SourceSansBold
exportBtn.TextSize = 11
exportBtn.BorderSizePixel = 0
Instance.new("UICorner", exportBtn).CornerRadius = UDim.new(0, 6)

local generateBtn = Instance.new("TextButton")
generateBtn.Parent = buttonFrame
generateBtn.Size = UDim2.new(0, 80, 1, 0)
generateBtn.Position = UDim2.new(0, 180, 0, 0)
generateBtn.Text = "⚡ Generate"
generateBtn.BackgroundColor3 = Color3.fromRGB(150, 70, 150)
generateBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
generateBtn.Font = Enum.Font.SourceSansBold
generateBtn.TextSize = 11
generateBtn.BorderSizePixel = 0
Instance.new("UICorner", generateBtn).CornerRadius = UDim.new(0, 6)

local closeBtn = Instance.new("TextButton")
closeBtn.Parent = buttonFrame
closeBtn.Size = UDim2.new(0, 80, 1, 0)
closeBtn.Position = UDim2.new(1, -80, 0, 0)
closeBtn.Text = "❌ Close"
closeBtn.BackgroundColor3 = Color3.fromRGB(180, 70, 70)
closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
closeBtn.Font = Enum.Font.SourceSansBold
closeBtn.TextSize = 11
closeBtn.BorderSizePixel = 0
Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0, 6)

-- Analysis data
local analysisData = {}
local currentTab = "Analysis"

-- Feature analysis functions
local function analyzeCurrentFeatures()
    local analysis = {"=== FEATURE ANALYSIS REPORT ===", "Generated: " .. os.date(), ""}
    
    -- Analyze RemoteEvents
    analysis[#analysis + 1] = "🔍 REMOTE EVENTS ANALYSIS:"
    local remoteEvents = {}
    if ReplicatedStorage:FindFirstChild("Packages") then
        local net = ReplicatedStorage.Packages._Index:FindFirstChild("sleitnick_net@0.2.0")
        if net and net:FindFirstChild("net") then
            for _, remote in pairs(net.net:GetChildren()) do
                table.insert(remoteEvents, remote.Name)
            end
        end
    end
    
    analysis[#analysis + 1] = "📊 Total RemoteEvents detected: " .. #remoteEvents
    
    -- Count fishing events
    local fishingEvents = 0
    for _, name in pairs(remoteEvents) do
        if string.find(string.lower(name), "fish") or string.find(string.lower(name), "rod") then
            fishingEvents = fishingEvents + 1
        end
    end
    analysis[#analysis + 1] = "🎣 Fishing events: " .. fishingEvents
    
    -- Count shop events
    local shopEvents = 0
    for _, name in pairs(remoteEvents) do
        if string.find(string.lower(name), "sell") or string.find(string.lower(name), "buy") then
            shopEvents = shopEvents + 1
        end
    end
    analysis[#analysis + 1] = "🛒 Shop events: " .. shopEvents
    analysis[#analysis + 1] = ""
    
    -- Analyze game structure
    analysis[#analysis + 1] = "🏗️ GAME STRUCTURE ANALYSIS:"
    analysis[#analysis + 1] = "📦 ReplicatedStorage structure: " .. (ReplicatedStorage:FindFirstChild("Packages") and "✅ Standard" or "❌ Non-standard")
    analysis[#analysis + 1] = "👥 NPC system: " .. (ReplicatedStorage:FindFirstChild("NPC") and "✅ Detected" or "❌ Not found")
    analysis[#analysis + 1] = "🗺️ Island locations: " .. (workspace:FindFirstChild("!!!! ISLAND LOCATIONS !!!!") and "✅ Available" or "❌ Not found")
    analysis[#analysis + 1] = ""
    
    -- Security analysis
    analysis[#analysis + 1] = "🔒 SECURITY ANALYSIS:"
    analysis[#analysis + 1] = "🛡️ Anti-detection methods needed: HIGH"
    analysis[#analysis + 1] = "⏱️ Delay randomization: RECOMMENDED"
    analysis[#analysis + 1] = "👀 Admin detection: CRITICAL"
    analysis[#analysis + 1] = "📍 Safe mode features: ESSENTIAL"
    analysis[#analysis + 1] = ""
    
    -- Performance analysis
    analysis[#analysis + 1] = "⚡ PERFORMANCE ANALYSIS:"
    analysis[#analysis + 1] = "🎯 Auto-fishing efficiency: OPTIMIZABLE"
    analysis[#analysis + 1] = "💰 Auto-sell integration: GOOD"
    analysis[#analysis + 1] = "🔄 Resource usage: MODERATE"
    analysis[#analysis + 1] = "📈 Scalability: HIGH"
    
    analysisData.analysis = analysis
    return table.concat(analysis, "\n")
end

local function generateSuggestions()
    local suggestions = {"=== IMPROVEMENT SUGGESTIONS ===", ""}
    
    suggestions[#suggestions + 1] = "🚀 HIGH PRIORITY IMPROVEMENTS:"
    suggestions[#suggestions + 1] = "1. 🎣 Advanced Fishing AI"
    suggestions[#suggestions + 1] = "   - Implement weather-based fishing strategies"
    suggestions[#suggestions + 1] = "   - Add time-of-day optimization"
    suggestions[#suggestions + 1] = "   - Dynamic difficulty adjustment"
    suggestions[#suggestions + 1] = ""
    
    suggestions[#suggestions + 1] = "2. 🛡️ Enhanced Security System"
    suggestions[#suggestions + 1] = "   - Real-time admin detection"
    suggestions[#suggestions + 1] = "   - Automatic feature disabling"
    suggestions[#suggestions + 1] = "   - Suspicious activity alerts"
    suggestions[#suggestions + 1] = ""
    
    suggestions[#suggestions + 1] = "3. 📊 Advanced Analytics"
    suggestions[#suggestions + 1] = "   - Profit per hour tracking"
    suggestions[#suggestions + 1] = "   - Efficiency optimization"
    suggestions[#suggestions + 1] = "   - Performance benchmarking"
    suggestions[#suggestions + 1] = ""
    
    suggestions[#suggestions + 1] = "🔄 MEDIUM PRIORITY FEATURES:"
    suggestions[#suggestions + 1] = "4. 🤖 Smart Inventory Management"
    suggestions[#suggestions + 1] = "   - Automatic item categorization"
    suggestions[#suggestions + 1] = "   - Value-based keeping/selling"
    suggestions[#suggestions + 1] = "   - Inventory space optimization"
    suggestions[#suggestions + 1] = ""
    
    suggestions[#suggestions + 1] = "5. 🗺️ Dynamic Teleportation"
    suggestions[#suggestions + 1] = "   - Auto-location detection"
    suggestions[#suggestions + 1] = "   - Optimal fishing spot finder"
    suggestions[#suggestions + 1] = "   - Safe teleportation routes"
    suggestions[#suggestions + 1] = ""
    
    suggestions[#suggestions + 1] = "💡 INNOVATIVE FEATURES:"
    suggestions[#suggestions + 1] = "6. 🧠 Machine Learning Integration"
    suggestions[#suggestions + 1] = "   - Pattern recognition for optimal timing"
    suggestions[#suggestions + 1] = "   - Adaptive behavior based on game updates"
    suggestions[#suggestions + 1] = "   - Predictive anti-detection"
    suggestions[#suggestions + 1] = ""
    
    suggestions[#suggestions + 1] = "7. 🌐 Multi-Server Support"
    suggestions[#suggestions + 1] = "   - Server quality analysis"
    suggestions[#suggestions + 1] = "   - Automatic server hopping"
    suggestions[#suggestions + 1] = "   - Load balancing optimization"
    
    analysisData.suggestions = suggestions
    return table.concat(suggestions, "\n")
end

local function generateUpdates()
    local updates = {"=== RECOMMENDED UPDATES ===", ""}
    
    updates[#updates + 1] = "🔄 CODE IMPROVEMENTS:"
    updates[#updates + 1] = ""
    updates[#updates + 1] = "1. Enhanced Error Handling:"
    updates[#updates + 1] = "```lua"
    updates[#updates + 1] = "local function safeExecute(func, errorMsg)"
    updates[#updates + 1] = "    local success, result = pcall(func)"
    updates[#updates + 1] = "    if not success then"
    updates[#updates + 1] = "        warn('XSAN Error: ' .. (errorMsg or 'Unknown') .. ' - ' .. result)"
    updates[#updates + 1] = "        return false"
    updates[#updates + 1] = "    end"
    updates[#updates + 1] = "    return true, result"
    updates[#updates + 1] = "end"
    updates[#updates + 1] = "```"
    updates[#updates + 1] = ""
    
    updates[#updates + 1] = "2. Smart Delay System:"
    updates[#updates + 1] = "```lua"
    updates[#updates + 1] = "local function getSmartDelay(baseDelay, variance)"
    updates[#updates + 1] = "    local multiplier = 1 + (math.random(-variance, variance) / 100)"
    updates[#updates + 1] = "    local humanFactor = 1 + (math.sin(tick()) * 0.1)"
    updates[#updates + 1] = "    return baseDelay * multiplier * humanFactor"
    updates[#updates + 1] = "end"
    updates[#updates + 1] = "```"
    updates[#updates + 1] = ""
    
    updates[#updates + 1] = "3. Advanced Admin Detection:"
    updates[#updates + 1] = "```lua"
    updates[#updates + 1] = "local function isPlayerAdmin(player)"
    updates[#updates + 1] = "    local adminIds = {1, 2, 3} -- Add known admin IDs"
    updates[#updates + 1] = "    return table.find(adminIds, player.UserId) or"
    updates[#updates + 1] = "           player.Name:match('[Aa]dmin') or"
    updates[#updates + 1] = "           player.MembershipType == Enum.MembershipType.Premium"
    updates[#updates + 1] = "end"
    updates[#updates + 1] = "```"
    updates[#updates + 1] = ""
    
    updates[#updates + 1] = "📈 PERFORMANCE OPTIMIZATIONS:"
    updates[#updates + 1] = ""
    updates[#updates + 1] = "4. Memory Management:"
    updates[#updates + 1] = "```lua"
    updates[#updates + 1] = "local function cleanupMemory()"
    updates[#updates + 1] = "    collectgarbage('collect')"
    updates[#updates + 1] = "    if #eventLog > 1000 then"
    updates[#updates + 1] = "        for i = 1, 500 do"
    updates[#updates + 1] = "            table.remove(eventLog, 1)"
    updates[#updates + 1] = "        end"
    updates[#updates + 1] = "    end"
    updates[#updates + 1] = "end"
    updates[#updates + 1] = "```"
    
    analysisData.updates = updates
    return table.concat(updates, "\n")
end

local function generateCode()
    local code = {"=== GENERATED CODE SNIPPETS ===", ""}
    
    code[#code + 1] = "🔧 READY-TO-USE FUNCTIONS:"
    code[#code + 1] = ""
    code[#code + 1] = "1. Smart Auto-Sell Function:"
    code[#code + 1] = "```lua"
    code[#code + 1] = "local function smartAutoSell()"
    code[#code + 1] = "    local currentTime = os.time()"
    code[#code + 1] = "    local timeSinceLastSell = currentTime - (lastSellTime or 0)"
    code[#code + 1] = "    "
    code[#code + 1] = "    if timeSinceLastSell < 60 then return end -- Cooldown"
    code[#code + 1] = "    "
    code[#code + 1] = "    if fishCaught >= autoSellThreshold then"
    code[#code + 1] = "        safeExecute(function()"
    code[#code + 1] = "            -- Teleport to Alex"
    code[#code + 1] = "            local originalPos = LocalPlayer.Character.HumanoidRootPart.CFrame"
    code[#code + 1] = "            LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(-28.43, 4.50, 2891.28)"
    code[#code + 1] = "            wait(getSmartDelay(1, 20))"
    code[#code + 1] = "            "
    code[#code + 1] = "            -- Sell items"
    code[#code + 1] = "            ReplicatedStorage.Packages._Index['sleitnick_net@0.2.0'].net['RF/SellAllItems']:InvokeServer()"
    code[#code + 1] = "            wait(getSmartDelay(1, 20))"
    code[#code + 1] = "            "
    code[#code + 1] = "            -- Return to original position"
    code[#code + 1] = "            LocalPlayer.Character.HumanoidRootPart.CFrame = originalPos"
    code[#code + 1] = "            "
    code[#code + 1] = "            fishCaught = 0"
    code[#code + 1] = "            lastSellTime = currentTime"
    code[#code + 1] = "            NotifySuccess('Smart Auto Sell', 'Items sold successfully!')"
    code[#code + 1] = "        end, 'Smart Auto Sell')"
    code[#code + 1] = "    end"
    code[#code + 1] = "end"
    code[#code + 1] = "```"
    code[#code + 1] = ""
    
    code[#code + 1] = "2. Advanced Security Monitor:"
    code[#code + 1] = "```lua"
    code[#code + 1] = "local function initSecurityMonitor()"
    code[#code + 1] = "    Players.PlayerAdded:Connect(function(player)"
    code[#code + 1] = "        if isPlayerAdmin(player) then"
    code[#code + 1] = "            NotifyWarning('Security Alert', 'Admin detected: ' .. player.Name)"
    code[#code + 1] = "            -- Auto-disable features"
    code[#code + 1] = "            autofish = false"
    code[#code + 1] = "            autoSellOnThreshold = false"
    code[#code + 1] = "        end"
    code[#code + 1] = "    end)"
    code[#code + 1] = "end"
    code[#code + 1] = "```"
    code[#code + 1] = ""
    
    code[#code + 1] = "3. Performance Monitor:"
    code[#code + 1] = "```lua"
    code[#code + 1] = "local function monitorPerformance()"
    code[#code + 1] = "    local startTime = tick()"
    code[#code + 1] = "    local fishPerHour = 0"
    code[#code + 1] = "    "
    code[#code + 1] = "    RunService.Heartbeat:Connect(function()"
    code[#code + 1] = "        local runtime = tick() - startTime"
    code[#code + 1] = "        if runtime > 0 then"
    code[#code + 1] = "            fishPerHour = math.floor((fishCaught / runtime) * 3600)"
    code[#code + 1] = "        end"
    code[#code + 1] = "    end)"
    code[#code + 1] = "    "
    code[#code + 1] = "    return function() return fishPerHour end"
    code[#code + 1] = "end"
    code[#code + 1] = "```"
    
    analysisData.code = code
    return table.concat(code, "\n")
end

-- Tab switching function
local function switchTab(tabName)
    if not tabButtons or not contentText then
        warn("Feature Analyzer: UI components not ready")
        return
    end
    
    for name, button in pairs(tabButtons) do
        if button and button.BackgroundColor3 then
            button.BackgroundColor3 = name == tabName and Color3.fromRGB(60, 120, 180) or Color3.fromRGB(40, 40, 40)
        end
    end
    
    currentTab = tabName
    
    pcall(function()
        if tabName == "Analysis" then
            contentText.Text = analyzeCurrentFeatures()
        elseif tabName == "Suggestions" then
            contentText.Text = generateSuggestions()
        elseif tabName == "Updates" then
            contentText.Text = generateUpdates()
        elseif tabName == "Code Gen" then
            contentText.Text = generateCode()
        end
        
        if contentFrame and contentFrame.CanvasSize then
            contentFrame.CanvasSize = UDim2.new(0, 0, 0, contentText.TextBounds.Y + 20)
        end
    end)
end

-- Button events
for tabName, button in pairs(tabButtons or {}) do
    if button and button.MouseButton1Click then
        button.MouseButton1Click:Connect(function()
            pcall(function()
                switchTab(tabName)
            end)
        end)
    end
end

if analyzeBtn and analyzeBtn.MouseButton1Click then
    analyzeBtn.MouseButton1Click:Connect(function()
        pcall(function()
            analyzeBtn.Text = "🔄 Analyzing..."
            switchTab(currentTab)
            task.spawn(function()
                task.wait(1)
                if analyzeBtn then
                    analyzeBtn.Text = "🔄 Analyze"
                end
            end)
        end)
    end)
end

if exportBtn and exportBtn.MouseButton1Click then
    exportBtn.MouseButton1Click:Connect(function()
        pcall(function()
            local exportText = contentText and contentText.Text or "No content"
            if setclipboard then
                setclipboard(exportText)
                exportBtn.Text = "📋 Copied!"
            else
                print(exportText)
                exportBtn.Text = "📋 Printed"
            end
            task.spawn(function()
                task.wait(1)
                if exportBtn then
                    exportBtn.Text = "📋 Export"
                end
            end)
        end)
    end)
end

if generateBtn and generateBtn.MouseButton1Click then
    generateBtn.MouseButton1Click:Connect(function()
        pcall(function()
            generateBtn.Text = "⚡ Generating..."
            switchTab("Code Gen")
            task.spawn(function()
                task.wait(1)
                if generateBtn then
                    generateBtn.Text = "⚡ Generate"
                end
            end)
        end)
    end)
end

if closeBtn and closeBtn.MouseButton1Click then
    closeBtn.MouseButton1Click:Connect(function()
        pcall(function()
            if screen then
                screen:Destroy()
            end
            print("Feature Analyzer closed")
        end)
    end)
end

-- Initialize with error protection
pcall(function()
    task.wait(0.1) -- Small delay to ensure UI is ready
    switchTab("Analysis")
end)

print("🔍 Feature Analyzer & Updater started!")
print("📊 Analyzing current features and generating improvement suggestions")
print("💡 Use generated code to enhance main.lua functionality")
