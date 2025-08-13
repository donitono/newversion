-- Enhanced NPC Teleport Detector v2.0
-- Smart NPC detection dengan AI pattern recognition dan distance optimization
-- Major upgrade dari npc_teleport_detector.lua

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

-- Enhanced error handling and performance monitoring
local PerformanceMonitor = {
    scanTimes = {},
    totalScans = 0,
    averageScanTime = 0
}

function PerformanceMonitor:startScan()
    self.currentScanStart = tick()
end

function PerformanceMonitor:endScan()
    if self.currentScanStart then
        local scanTime = tick() - self.currentScanStart
        table.insert(self.scanTimes, scanTime)
        self.totalScans = self.totalScans + 1
        
        -- Keep only last 10 scan times
        if #self.scanTimes > 10 then
            table.remove(self.scanTimes, 1)
        end
        
        -- Calculate average
        local sum = 0
        for _, time in pairs(self.scanTimes) do
            sum = sum + time
        end
        self.averageScanTime = sum / #self.scanTimes
        
        self.currentScanStart = nil
        return scanTime
    end
    return 0
end

local function safeExecute(func, context)
    local success, result = pcall(func)
    if not success then
        warn(string.format('[NPC Detector] %s: %s', context or "Unknown", tostring(result)))
        return false, result
    end
    return true, result
end

-- Remove existing NPC detector GUIs
safeExecute(function()
    local CoreGui = game:GetService("CoreGui")
    for _, gui in pairs(CoreGui:GetChildren()) do
        if gui.Name:find("NPCTeleport") or gui.Name:find("NPCDetector") then
            gui:Destroy()
        end
    end
end, "GUI cleanup")

-- Create enhanced GUI
local CoreGui = game:GetService("CoreGui")
local screen = Instance.new("ScreenGui")
screen.Name = "EnhancedNPCTeleportDetector"
screen.Parent = CoreGui
screen.ResetOnSpawn = false

-- Responsive design
local screenSize = workspace.CurrentCamera.ViewportSize
local isLandscape = screenSize.X > screenSize.Y
local frameWidth = isLandscape and 750 or 600
local frameHeight = isLandscape and 400 or 450

-- Main frame
local mainFrame = Instance.new("Frame")
mainFrame.Parent = screen
mainFrame.Size = UDim2.new(0, frameWidth, 0, frameHeight)
mainFrame.Position = UDim2.new(0.5, -frameWidth/2, 0.5, -frameHeight/2)
mainFrame.BackgroundColor3 = Color3.fromRGB(20, 25, 35)
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.Draggable = true
mainFrame.Visible = false
Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 15)

-- Floating toggle button
local floatingBtn = Instance.new("TextButton")
floatingBtn.Parent = screen
floatingBtn.Size = UDim2.new(0, 65, 0, 65)
floatingBtn.Position = UDim2.new(1, -85, 0, 120)
floatingBtn.Text = "🗺️"
floatingBtn.BackgroundColor3 = Color3.fromRGB(80, 160, 120)
floatingBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
floatingBtn.Font = Enum.Font.SourceSansBold
floatingBtn.TextSize = 26
floatingBtn.BorderSizePixel = 0
floatingBtn.ZIndex = 10
Instance.new("UICorner", floatingBtn).CornerRadius = UDim.new(0.5, 0)

-- Enhanced gradient background
local gradient = Instance.new("UIGradient")
gradient.Parent = mainFrame
gradient.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, Color3.fromRGB(30, 35, 50)),
    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(20, 25, 35)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(15, 20, 30))
}
gradient.Rotation = 135

-- Title bar with performance indicator
local titleBar = Instance.new("Frame")
titleBar.Parent = mainFrame
titleBar.Size = UDim2.new(1, 0, 0, 45)
titleBar.BackgroundColor3 = Color3.fromRGB(40, 45, 65)
titleBar.BorderSizePixel = 0
Instance.new("UICorner", titleBar).CornerRadius = UDim.new(0, 15)

local titleLabel = Instance.new("TextLabel")
titleLabel.Parent = titleBar
titleLabel.Size = UDim2.new(1, -150, 1, 0)
titleLabel.Position = UDim2.new(0, 15, 0, 0)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "🗺️ Enhanced NPC Teleport Detector v2.0"
titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
titleLabel.Font = Enum.Font.SourceSansBold
titleLabel.TextSize = 18
titleLabel.TextXAlignment = Enum.TextXAlignment.Left

-- Performance indicator
local perfLabel = Instance.new("TextLabel")
perfLabel.Parent = titleBar
perfLabel.Size = UDim2.new(0, 100, 1, 0)
perfLabel.Position = UDim2.new(1, -140, 0, 0)
perfLabel.BackgroundTransparency = 1
perfLabel.Text = "Scan: 0.0ms"
perfLabel.TextColor3 = Color3.fromRGB(100, 200, 100)
perfLabel.Font = Enum.Font.SourceSans
perfLabel.TextSize = 12
perfLabel.TextXAlignment = Enum.TextXAlignment.Right

-- Close button
local closeBtn = Instance.new("TextButton")
closeBtn.Parent = titleBar
closeBtn.Size = UDim2.new(0, 35, 0, 35)
closeBtn.Position = UDim2.new(1, -40, 0, 5)
closeBtn.Text = "✖"
closeBtn.BackgroundColor3 = Color3.fromRGB(220, 80, 80)
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
contentFrame.Size = UDim2.new(1, -20, 1, -135)
contentFrame.Position = UDim2.new(0, 10, 0, 95)
contentFrame.BackgroundColor3 = Color3.fromRGB(25, 30, 40)
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
scrollFrame.ScrollBarImageColor3 = Color3.fromRGB(100, 120, 150)
scrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)

local contentText = Instance.new("TextLabel")
contentText.Parent = scrollFrame
contentText.Size = UDim2.new(1, -10, 1, 0)
contentText.Position = UDim2.new(0, 5, 0, 0)
contentText.BackgroundTransparency = 1
contentText.Text = "Initializing smart NPC detection system..."
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

-- Enhanced NPC Detection System
local NPCDetector = {
    npcs = {},
    islands = {},
    importantLocations = {},
    teleportHistory = {},
    filters = {
        maxDistance = 1000,
        includeVendors = true,
        includeQuestGivers = true,
        includeGeneric = false
    },
    statistics = {
        totalNPCs = 0,
        vendorNPCs = 0,
        questNPCs = 0,
        nearbyNPCs = 0
    }
}

-- Smart NPC categorization with AI-like pattern recognition
function NPCDetector:categorizeNPC(npcName, npcModel)
    local name = npcName:lower()
    local category = "generic"
    local confidence = 0
    
    -- Vendor detection patterns
    local vendorPatterns = {
        {"shop", 0.9}, {"merchant", 0.9}, {"trader", 0.8}, {"vendor", 0.9},
        {"alex", 0.95}, {"seller", 0.7}, {"store", 0.8}, {"market", 0.7}
    }
    
    -- Quest giver detection patterns
    local questPatterns = {
        {"quest", 0.9}, {"npc", 0.5}, {"guide", 0.7}, {"captain", 0.8},
        {"fisher", 0.6}, {"old", 0.4}, {"master", 0.6}
    }
    
    -- Check vendor patterns
    for _, pattern in pairs(vendorPatterns) do
        if name:find(pattern[1]) then
            if pattern[2] > confidence then
                category = "vendor"
                confidence = pattern[2]
            end
        end
    end
    
    -- Check quest patterns
    for _, pattern in pairs(questPatterns) do
        if name:find(pattern[1]) then
            if pattern[2] > confidence then
                category = "quest_giver"
                confidence = pattern[2]
            end
        end
    end
    
    -- Advanced heuristics based on model structure
    if npcModel then
        local hasShop = npcModel:FindFirstChild("Shop") or npcModel:FindFirstChild("Store")
        local hasQuest = npcModel:FindFirstChild("Quest") or npcModel:FindFirstChild("Dialog")
        
        if hasShop and confidence < 0.8 then
            category = "vendor"
            confidence = 0.8
        elseif hasQuest and confidence < 0.7 then
            category = "quest_giver"
            confidence = 0.7
        end
    end
    
    return category, confidence
end

function NPCDetector:scanNPCs()
    PerformanceMonitor:startScan()
    self.npcs = {}
    self.statistics = {totalNPCs = 0, vendorNPCs = 0, questNPCs = 0, nearbyNPCs = 0}
    
    safeExecute(function()
        if not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            return
        end
        
        local playerPos = LocalPlayer.Character.HumanoidRootPart.Position
        
        local function scanArea(parent, depth)
            if depth > 4 then return end
            
            for _, obj in pairs(parent:GetChildren()) do
                if obj:IsA("Model") and obj:FindFirstChild("Humanoid") then
                    local humanoidRootPart = obj:FindFirstChild("HumanoidRootPart")
                    local head = obj:FindFirstChild("Head")
                    
                    if humanoidRootPart and head then
                        local distance = (humanoidRootPart.Position - playerPos).Magnitude
                        
                        if distance <= self.filters.maxDistance then
                            local category, confidence = self:categorizeNPC(obj.Name, obj)
                            
                            -- Apply filters
                            local shouldInclude = false
                            if category == "vendor" and self.filters.includeVendors then
                                shouldInclude = true
                                self.statistics.vendorNPCs = self.statistics.vendorNPCs + 1
                            elseif category == "quest_giver" and self.filters.includeQuestGivers then
                                shouldInclude = true
                                self.statistics.questNPCs = self.statistics.questNPCs + 1
                            elseif category == "generic" and self.filters.includeGeneric then
                                shouldInclude = true
                            end
                            
                            if shouldInclude then
                                table.insert(self.npcs, {
                                    name = obj.Name,
                                    category = category,
                                    confidence = confidence,
                                    position = humanoidRootPart.CFrame,
                                    distance = distance,
                                    model = obj
                                })
                                
                                self.statistics.totalNPCs = self.statistics.totalNPCs + 1
                                if distance <= 100 then
                                    self.statistics.nearbyNPCs = self.statistics.nearbyNPCs + 1
                                end
                            end
                        end
                    end
                end
                
                scanArea(obj, depth + 1)
            end
        end
        
        scanArea(Workspace, 0)
        
        -- Sort by relevance (category confidence + distance)
        table.sort(self.npcs, function(a, b)
            local scoreA = a.confidence - (a.distance / 1000)
            local scoreB = b.confidence - (b.distance / 1000)
            return scoreA > scoreB
        end)
        
    end, "NPC scanning")
    
    local scanTime = PerformanceMonitor:endScan()
    perfLabel.Text = string.format("Scan: %.1fms", scanTime * 1000)
    
    return self.npcs
end

function NPCDetector:scanIslands()
    self.islands = {}
    
    safeExecute(function()
        local islandFolder = Workspace:FindFirstChild("!!!! ISLAND LOCATIONS !!!!")
        
        if islandFolder then
            for _, island in pairs(islandFolder:GetChildren()) do
                if island:IsA("BasePart") then
                    table.insert(self.islands, {
                        name = island.Name,
                        position = island.CFrame,
                        type = "island"
                    })
                end
            end
        else
            -- Default islands from database
            local defaultIslands = {
                {name = "Kohana Volcano", pos = CFrame.new(-594.97, 396.65, 149.11)},
                {name = "Crater Island", pos = CFrame.new(1010.01, 252.00, 5078.45)},
                {name = "Kohana", pos = CFrame.new(-650.97, 208.69, 711.11)},
                {name = "Lost Isle", pos = CFrame.new(-3618.16, 240.84, -1317.46)},
                {name = "Stingray Shores", pos = CFrame.new(45.28, 252.56, 2987.11)},
                {name = "Esoteric Depths", pos = CFrame.new(1944.78, 393.56, 1371.36)},
                {name = "Weather Machine", pos = CFrame.new(-1488.51, 83.17, 1876.30)},
                {name = "Tropical Grove", pos = CFrame.new(-2095.34, 197.20, 3718.08)}
            }
            
            for _, island in pairs(defaultIslands) do
                table.insert(self.islands, {
                    name = island.name,
                    position = island.pos,
                    type = "island"
                })
            end
        end
    end, "Island scanning")
    
    return self.islands
end

function NPCDetector:scanImportantLocations()
    self.importantLocations = {}
    
    safeExecute(function()
        local locationKeywords = {"spawn", "shop", "dock", "pier", "lighthouse", "cave", "bridge"}
        
        local function findLocations(parent, depth)
            if depth > 3 then return end
            
            for _, obj in pairs(parent:GetChildren()) do
                if obj:IsA("BasePart") then
                    local objName = obj.Name:lower()
                    
                    for _, keyword in pairs(locationKeywords) do
                        if objName:find(keyword) then
                            table.insert(self.importantLocations, {
                                name = obj.Name,
                                position = obj.CFrame,
                                type = "location",
                                keyword = keyword
                            })
                            break
                        end
                    end
                end
                
                findLocations(obj, depth + 1)
            end
        end
        
        findLocations(Workspace, 0)
    end, "Location scanning")
    
    return self.importantLocations
end

-- Tab definitions
local tabs = {
    {
        name = "NPCs",
        icon = "👥",
        color = Color3.fromRGB(80, 160, 120),
        content = function()
            NPCDetector:scanNPCs()
            local result = "=== SMART NPC DETECTION ===\n\n"
            
            result = result .. string.format("📊 Total NPCs Found: %d\n", NPCDetector.statistics.totalNPCs)
            result = result .. string.format("🛒 Vendor NPCs: %d\n", NPCDetector.statistics.vendorNPCs)
            result = result .. string.format("❓ Quest NPCs: %d\n", NPCDetector.statistics.questNPCs)
            result = result .. string.format("📍 Nearby (<100 studs): %d\n\n", NPCDetector.statistics.nearbyNPCs)
            
            if #NPCDetector.npcs == 0 then
                result = result .. "❌ No NPCs found matching current filters!\n"
                result = result .. "💡 Try adjusting filters or moving to populated areas.\n"
                return result
            end
            
            result = result .. "🎯 DETECTED NPCs (Smart sorted):\n\n"
            
            for i, npc in pairs(NPCDetector.npcs) do
                if i <= 15 then -- Limit display
                    local icon = "👤"
                    if npc.category == "vendor" then icon = "🛒"
                    elseif npc.category == "quest_giver" then icon = "❓"
                    end
                    
                    result = result .. string.format("%d. %s %s (%.0f%% confidence)\n", 
                        i, icon, npc.name, npc.confidence * 100)
                    result = result .. string.format("   Distance: %.1f studs\n", npc.distance)
                    result = result .. string.format("   CFrame.new(%.2f, %.2f, %.2f)\n\n", 
                        npc.position.X, npc.position.Y, npc.position.Z)
                end
            end
            
            if #NPCDetector.npcs > 15 then
                result = result .. string.format("... and %d more NPCs\n", #NPCDetector.npcs - 15)
            end
            
            return result
        end
    },
    {
        name = "Islands",
        icon = "🏝️",
        color = Color3.fromRGB(60, 140, 200),
        content = function()
            NPCDetector:scanIslands()
            local result = "=== ISLAND TELEPORTATION ===\n\n"
            
            result = result .. string.format("🏝️ Islands Available: %d\n\n", #NPCDetector.islands)
            
            for i, island in pairs(NPCDetector.islands) do
                result = result .. string.format("%d. 🏝️ %s\n", i, island.name)
                result = result .. string.format("   CFrame.new(%.2f, %.2f, %.2f)\n\n", 
                    island.position.X, island.position.Y, island.position.Z)
            end
            
            result = result .. "💡 Use these coordinates for teleportation in main.lua!"
            
            return result
        end
    },
    {
        name = "Locations",
        icon = "📍",
        color = Color3.fromRGB(120, 80, 160),
        content = function()
            NPCDetector:scanImportantLocations()
            local result = "=== IMPORTANT LOCATIONS ===\n\n"
            
            result = result .. string.format("📍 Locations Found: %d\n\n", #NPCDetector.importantLocations)
            
            -- Group by type
            local groupedLocations = {}
            for _, location in pairs(NPCDetector.importantLocations) do
                if not groupedLocations[location.keyword] then
                    groupedLocations[location.keyword] = {}
                end
                table.insert(groupedLocations[location.keyword], location)
            end
            
            for keyword, locations in pairs(groupedLocations) do
                result = result .. string.format("🎯 %s LOCATIONS:\n", keyword:upper())
                for _, location in pairs(locations) do
                    result = result .. string.format("  📍 %s: CFrame.new(%.2f, %.2f, %.2f)\n", 
                        location.name, location.position.X, location.position.Y, location.position.Z)
                end
                result = result .. "\n"
            end
            
            return result
        end
    },
    {
        name = "Filters",
        icon = "⚙️",
        color = Color3.fromRGB(150, 100, 200),
        content = function()
            local result = "=== DETECTION FILTERS ===\n\n"
            
            result = result .. "🔧 CURRENT SETTINGS:\n\n"
            result = result .. string.format("📏 Max Distance: %d studs\n", NPCDetector.filters.maxDistance)
            result = result .. string.format("🛒 Include Vendors: %s\n", NPCDetector.filters.includeVendors and "✅" or "❌")
            result = result .. string.format("❓ Include Quest Givers: %s\n", NPCDetector.filters.includeQuestGivers and "✅" or "❌")
            result = result .. string.format("👤 Include Generic NPCs: %s\n\n", NPCDetector.filters.includeGeneric and "✅" or "❌")
            
            result = result .. "📊 PERFORMANCE STATS:\n\n"
            result = result .. string.format("⏱️ Total Scans: %d\n", PerformanceMonitor.totalScans)
            result = result .. string.format("⚡ Average Scan Time: %.1fms\n", PerformanceMonitor.averageScanTime * 1000)
            result = result .. string.format("💾 Memory Usage: Optimized\n\n")
            
            result = result .. "💡 Use toggle buttons below to adjust filters!"
            
            return result
        end
    },
    {
        name = "Export",
        icon = "💾",
        color = Color3.fromRGB(200, 120, 80),
        content = function()
            local result = "=== EXPORT FOR MAIN.LUA ===\n\n"
            
            result = result .. "🔧 Enhanced teleportation data:\n\n"
            result = result .. "-- Auto-Generated Teleport Data\n"
            result = result .. "local TeleportData = {\n"
            
            -- Export NPCs
            if #NPCDetector.npcs > 0 then
                result = result .. "    npcs = {\n"
                for _, npc in pairs(NPCDetector.npcs) do
                    result = result .. string.format('        ["%s"] = {pos = CFrame.new(%.2f, %.2f, %.2f), type = "%s"},\n', 
                        npc.name, npc.position.X, npc.position.Y, npc.position.Z, npc.category)
                end
                result = result .. "    },\n"
            end
            
            -- Export islands
            if #NPCDetector.islands > 0 then
                result = result .. "    islands = {\n"
                for _, island in pairs(NPCDetector.islands) do
                    result = result .. string.format('        ["%s"] = CFrame.new(%.2f, %.2f, %.2f),\n', 
                        island.name, island.position.X, island.position.Y, island.position.Z)
                end
                result = result .. "    },\n"
            end
            
            result = result .. "}\n\n"
            result = result .. "-- Smart teleport function:\n"
            result = result .. "-- game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = TeleportData.npcs['Alex'].pos\n\n"
            result = result .. "📋 Click 'Copy Export' to copy to clipboard!"
            
            return result
        end
    }
}

-- Create tab buttons and functionality...
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
        
        for j, btn in ipairs(tabButtons) do
            btn.BackgroundColor3 = j == i and tabs[j].color or Color3.fromRGB(50, 50, 60)
        end
        
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
    btn.Size = UDim2.new(0, 110, 1, 0)
    btn.Text = text
    btn.BackgroundColor3 = color
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Font = Enum.Font.SourceSansBold
    btn.TextSize = 11
    btn.BorderSizePixel = 0
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)
    
    btn.MouseButton1Click:Connect(function()
        safeExecute(callback, "Button: " .. text)
    end)
    return btn
end

-- Enhanced buttons
createButton("🔄 Smart Scan", Color3.fromRGB(60, 150, 60), function()
    NPCDetector:scanNPCs()
    NPCDetector:scanIslands()
    NPCDetector:scanImportantLocations()
    
    contentText.Text = tabs[currentTab].content()
    scrollFrame.CanvasSize = UDim2.new(0, 0, 0, contentText.TextBounds.Y + 20)
    print("🔄 Smart scan completed!")
end)

createButton("📋 Copy Export", Color3.fromRGB(200, 120, 80), function()
    if currentTab == 5 then
        local exportData = contentText.Text
        if setclipboard then
            setclipboard(exportData)
            print("📋 NPC data copied to clipboard!")
        else
            print("📋 NPC data printed to console")
            print(exportData)
        end
    else
        print("💡 Switch to Export tab first!")
    end
end)

createButton("⚙️ Toggle Vendors", Color3.fromRGB(100, 150, 200), function()
    NPCDetector.filters.includeVendors = not NPCDetector.filters.includeVendors
    if currentTab == 4 then
        contentText.Text = tabs[currentTab].content()
        scrollFrame.CanvasSize = UDim2.new(0, 0, 0, contentText.TextBounds.Y + 20)
    end
    print(string.format("⚙️ Vendor filter: %s", NPCDetector.filters.includeVendors and "ON" or "OFF"))
end)

createButton("⚙️ Toggle Generic", Color3.fromRGB(150, 100, 150), function()
    NPCDetector.filters.includeGeneric = not NPCDetector.filters.includeGeneric
    if currentTab == 4 then
        contentText.Text = tabs[currentTab].content()
        scrollFrame.CanvasSize = UDim2.new(0, 0, 0, contentText.TextBounds.Y + 20)
    end
    print(string.format("⚙️ Generic NPCs filter: %s", NPCDetector.filters.includeGeneric and "ON" or "OFF"))
end)

-- Toggle functionality
floatingBtn.MouseButton1Click:Connect(function()
    mainFrame.Visible = not mainFrame.Visible
    floatingBtn.Text = mainFrame.Visible and "❌" or "🗺️"
    floatingBtn.BackgroundColor3 = mainFrame.Visible and Color3.fromRGB(200, 80, 80) or Color3.fromRGB(80, 160, 120)
    
    if mainFrame.Visible then
        mainFrame.Size = UDim2.new(0, 0, 0, 0)
        local tween = TweenService:Create(mainFrame, TweenInfo.new(0.4, Enum.EasingStyle.Back), {
            Size = UDim2.new(0, frameWidth, 0, frameHeight)
        })
        tween:Play()
        
        safeExecute(function()
            contentText.Text = tabs[currentTab].content()
            scrollFrame.CanvasSize = UDim2.new(0, 0, 0, contentText.TextBounds.Y + 20)
        end, "Interface show")
    end
end)

-- Close functionality
closeBtn.MouseButton1Click:Connect(function()
    screen:Destroy()
    print("🗺️ Enhanced NPC Teleport Detector closed")
end)

-- Hotkey support (Ctrl+N)
local UserInputService = game:GetService("UserInputService")
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if not gameProcessed and input.KeyCode == Enum.KeyCode.N and UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
        floatingBtn.MouseButton1Click:Fire()
    end
end)

-- Initialize
print("🗺️ Enhanced NPC Teleport Detector v2.0 started!")
print("✨ New features: Smart AI categorization, Performance monitoring, Advanced filters")
print("🎮 Press Ctrl+N or click floating button to open")
print("🚀 Major upgrade with intelligent NPC pattern recognition!")
