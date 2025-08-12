-- Enhanced Location Detector v2.0
-- Advanced location detection system dengan auto-scanning dan export features
-- Menggabungkan dan meningkatkan location_detector.lua + location_detector_new.lua

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local HttpService = game:GetService("HttpService")
local TweenService = game:GetService("TweenService")

-- Safe execution wrapper
local function safeExecute(func, errorMsg)
    local success, result = pcall(func)
    if not success then
        warn('Location Detector Error: ' .. (errorMsg or 'Unknown') .. ' - ' .. tostring(result))
        return false, result
    end
    return true, result
end

-- Remove existing location detector GUIs
safeExecute(function()
    local CoreGui = game:GetService("CoreGui")
    for _, gui in pairs(CoreGui:GetChildren()) do
        if gui.Name:find("LocationDetector") then
            gui:Destroy()
        end
    end
end, "GUI cleanup")

-- Create enhanced GUI
local CoreGui = game:GetService("CoreGui")
local screen = Instance.new("ScreenGui")
screen.Name = "EnhancedLocationDetector"
screen.Parent = CoreGui
screen.ResetOnSpawn = false

-- Main frame (optimized for landscape mobile)
local mainFrame = Instance.new("Frame")
mainFrame.Parent = screen
mainFrame.Size = UDim2.new(0, 700, 0, 400) -- Larger for more features
mainFrame.Position = UDim2.new(0.5, -350, 0.5, -200)
mainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.Draggable = true
mainFrame.Visible = false
Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 12)

-- Floating toggle button
local floatingBtn = Instance.new("TextButton")
floatingBtn.Parent = screen
floatingBtn.Size = UDim2.new(0, 60, 0, 60)
floatingBtn.Position = UDim2.new(1, -80, 0, 180)
floatingBtn.Text = "📍"
floatingBtn.BackgroundColor3 = Color3.fromRGB(80, 160, 120)
floatingBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
floatingBtn.Font = Enum.Font.SourceSansBold
floatingBtn.TextSize = 24
floatingBtn.BorderSizePixel = 0
floatingBtn.ZIndex = 10
Instance.new("UICorner", floatingBtn).CornerRadius = UDim.new(0.5, 0)

-- Title bar
local titleBar = Instance.new("Frame")
titleBar.Parent = mainFrame
titleBar.Size = UDim2.new(1, 0, 0, 40)
titleBar.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
titleBar.BorderSizePixel = 0
Instance.new("UICorner", titleBar).CornerRadius = UDim.new(0, 12)

local titleLabel = Instance.new("TextLabel")
titleLabel.Parent = titleBar
titleLabel.Size = UDim2.new(1, -100, 1, 0)
titleLabel.Position = UDim2.new(0, 10, 0, 0)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "📍 Enhanced Location Detector v2.0"
titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
titleLabel.Font = Enum.Font.SourceSansBold
titleLabel.TextSize = 16
titleLabel.TextXAlignment = Enum.TextXAlignment.Left

-- Close button
local closeBtn = Instance.new("TextButton")
closeBtn.Parent = titleBar
closeBtn.Size = UDim2.new(0, 30, 0, 30)
closeBtn.Position = UDim2.new(1, -35, 0, 5)
closeBtn.Text = "✖"
closeBtn.BackgroundColor3 = Color3.fromRGB(200, 80, 80)
closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
closeBtn.Font = Enum.Font.SourceSansBold
closeBtn.TextSize = 14
closeBtn.BorderSizePixel = 0
Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0, 6)

-- Tab container
local tabContainer = Instance.new("Frame")
tabContainer.Parent = mainFrame
tabContainer.Size = UDim2.new(1, -20, 0, 35)
tabContainer.Position = UDim2.new(0, 10, 0, 45)
tabContainer.BackgroundTransparency = 1

local tabLayout = Instance.new("UIListLayout")
tabLayout.Parent = tabContainer
tabLayout.FillDirection = Enum.FillDirection.Horizontal
tabLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
tabLayout.Padding = UDim.new(0, 5)

-- Content area
local contentFrame = Instance.new("Frame")
contentFrame.Parent = mainFrame
contentFrame.Size = UDim2.new(1, -20, 1, -130)
contentFrame.Position = UDim2.new(0, 10, 0, 85)
contentFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
contentFrame.BorderSizePixel = 0
Instance.new("UICorner", contentFrame).CornerRadius = UDim.new(0, 8)

-- Scrollable content
local scrollFrame = Instance.new("ScrollingFrame")
scrollFrame.Parent = contentFrame
scrollFrame.Size = UDim2.new(1, -10, 1, -10)
scrollFrame.Position = UDim2.new(0, 5, 0, 5)
scrollFrame.BackgroundTransparency = 1
scrollFrame.BorderSizePixel = 0
scrollFrame.ScrollBarThickness = 8
scrollFrame.ScrollBarImageColor3 = Color3.fromRGB(80, 80, 120)
scrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)

local contentText = Instance.new("TextLabel")
contentText.Parent = scrollFrame
contentText.Size = UDim2.new(1, -10, 1, 0)
contentText.Position = UDim2.new(0, 5, 0, 0)
contentText.BackgroundTransparency = 1
contentText.Text = "Loading enhanced location detection..."
contentText.TextColor3 = Color3.fromRGB(255, 255, 255)
contentText.Font = Enum.Font.SourceSans
contentText.TextSize = 12
contentText.TextWrapped = true
contentText.TextXAlignment = Enum.TextXAlignment.Left
contentText.TextYAlignment = Enum.TextYAlignment.Top

-- Button container
local buttonFrame = Instance.new("Frame")
buttonFrame.Parent = mainFrame
buttonFrame.Size = UDim2.new(1, -20, 0, 35)
buttonFrame.Position = UDim2.new(0, 10, 1, -40)
buttonFrame.BackgroundTransparency = 1

local buttonLayout = Instance.new("UIListLayout")
buttonLayout.Parent = buttonFrame
buttonLayout.FillDirection = Enum.FillDirection.Horizontal
buttonLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
buttonLayout.Padding = UDim.new(0, 10)

-- Data storage
local locationData = {
    currentPosition = {x = 0, y = 0, z = 0},
    islandLocations = {},
    namedLocations = {},
    npcLocations = {},
    historyPositions = {},
    shopLocations = {}
}

-- Tab data
local tabs = {
    {
        name = "Current",
        icon = "📍",
        color = Color3.fromRGB(80, 160, 120),
        content = function()
            if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                local part = LocalPlayer.Character.HumanoidRootPart
                local pos = part.Position
                local cf = part.CFrame
                
                locationData.currentPosition = {
                    x = math.floor(pos.X * 100) / 100,
                    y = math.floor(pos.Y * 100) / 100,
                    z = math.floor(pos.Z * 100) / 100
                }
                
                local result = "=== CURRENT POSITION ===\n\n"
                result = result .. string.format("📍 Coordinates:\nX: %.2f\nY: %.2f\nZ: %.2f\n\n", 
                    locationData.currentPosition.x, locationData.currentPosition.y, locationData.currentPosition.z)
                
                result = result .. "🔧 For main.lua (Vector3):\n"
                result = result .. string.format("Vector3.new(%.2f, %.2f, %.2f)\n\n", 
                    locationData.currentPosition.x, locationData.currentPosition.y, locationData.currentPosition.z)
                
                result = result .. "🔧 For main.lua (CFrame):\n"
                result = result .. string.format("CFrame.new(%.2f, %.2f, %.2f)\n\n", 
                    locationData.currentPosition.x, locationData.currentPosition.y, locationData.currentPosition.z)
                
                result = result .. "🎯 Real-time tracking active!\nMove around to see coordinates update."
                
                return result
            else
                return "❌ Character not found!\nMake sure you're spawned in game."
            end
        end
    },
    {
        name = "Islands",
        icon = "🏝️",
        color = Color3.fromRGB(60, 140, 200),
        content = function()
            local result = "=== ISLAND LOCATIONS ===\n\n"
            
            -- Scan for island folder
            local islandFolder = Workspace:FindFirstChild("!!!! ISLAND LOCATIONS !!!!")
            locationData.islandLocations = {}
            
            if islandFolder then
                result = result .. "✅ Island Locations Folder Found!\n\n"
                for _, island in pairs(islandFolder:GetChildren()) do
                    if island:IsA("BasePart") then
                        local pos = island.CFrame
                        local x, y, z = pos.X, pos.Y, pos.Z
                        locationData.islandLocations[island.Name] = {x = x, y = y, z = z}
                        result = result .. string.format("🏝️ %s:\nCFrame.new(%.2f, %.2f, %.2f)\n\n", 
                            island.Name, x, y, z)
                    end
                end
            else
                result = result .. "❌ Island Locations Folder Not Found!\n\n"
                result = result .. "📝 Default Locations (from database):\n\n"
                local defaultIslands = {
                    ["Kohana Volcano"] = {x = -594.97, y = 396.65, z = 149.11},
                    ["Crater Island"] = {x = 1010.01, y = 252.00, z = 5078.45},
                    ["Kohana"] = {x = -650.97, y = 208.69, z = 711.11},
                    ["Lost Isle"] = {x = -3618.16, y = 240.84, z = -1317.46},
                    ["Stingray Shores"] = {x = 45.28, y = 252.56, z = 2987.11},
                    ["Esoteric Depths"] = {x = 1944.78, y = 393.56, z = 1371.36}
                }
                
                for name, pos in pairs(defaultIslands) do
                    locationData.islandLocations[name] = pos
                    result = result .. string.format("🏝️ %s:\nCFrame.new(%.2f, %.2f, %.2f)\n\n", 
                        name, pos.x, pos.y, pos.z)
                end
            end
            
            result = result .. string.format("📊 Total Islands: %d", 
                #locationData.islandLocations > 0 and #locationData.islandLocations or 6)
            
            return result
        end
    },
    {
        name = "NPCs",
        icon = "👥",
        color = Color3.fromRGB(120, 80, 160),
        content = function()
            local result = "=== NPC LOCATIONS ===\n\n"
            locationData.npcLocations = {}
            
            -- Scan for NPCs
            local function scanForNPCs(parent, depth)
                if depth > 3 then return end
                
                safeExecute(function()
                    for _, obj in pairs(parent:GetChildren()) do
                        if obj:IsA("Model") and obj:FindFirstChild("Humanoid") then
                            local humanoidRootPart = obj:FindFirstChild("HumanoidRootPart")
                            if humanoidRootPart then
                                local pos = humanoidRootPart.CFrame
                                locationData.npcLocations[obj.Name] = {
                                    x = pos.X, y = pos.Y, z = pos.Z,
                                    type = "NPC"
                                }
                            end
                        end
                        scanForNPCs(obj, depth + 1)
                    end
                end, "NPC scanning")
            end
            
            scanForNPCs(Workspace, 0)
            
            if next(locationData.npcLocations) then
                for name, data in pairs(locationData.npcLocations) do
                    result = result .. string.format("👥 %s:\nCFrame.new(%.2f, %.2f, %.2f)\n\n", 
                        name, data.x, data.y, data.z)
                end
            else
                result = result .. "❌ No NPCs detected in current area.\n\n"
                result = result .. "💡 Try moving to different locations or check if NPCs are loaded."
            end
            
            result = result .. string.format("\n📊 Total NPCs Found: %d", 
                table.getn and table.getn(locationData.npcLocations) or 0)
            
            return result
        end
    },
    {
        name = "Export",
        icon = "📋",
        color = Color3.fromRGB(200, 120, 80),
        content = function()
            local result = "=== EXPORT FOR MAIN.LUA ===\n\n"
            
            result = result .. "🔧 Copy this code to your main.lua:\n\n"
            result = result .. "-- Enhanced Location Data (Auto-Generated)\n"
            result = result .. "local LocationData = {\n"
            
            -- Export islands
            if next(locationData.islandLocations) then
                result = result .. "    islands = {\n"
                for name, pos in pairs(locationData.islandLocations) do
                    result = result .. string.format('        ["%s"] = CFrame.new(%.2f, %.2f, %.2f),\n', 
                        name, pos.x, pos.y, pos.z)
                end
                result = result .. "    },\n"
            end
            
            -- Export NPCs
            if next(locationData.npcLocations) then
                result = result .. "    npcs = {\n"
                for name, data in pairs(locationData.npcLocations) do
                    result = result .. string.format('        ["%s"] = CFrame.new(%.2f, %.2f, %.2f),\n', 
                        name, data.x, data.y, data.z)
                end
                result = result .. "    },\n"
            end
            
            result = result .. "}\n\n"
            result = result .. "-- Usage example:\n"
            result = result .. "-- game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = LocationData.islands['Kohana']\n\n"
            result = result .. "📋 Click 'Copy Export' button to copy to clipboard!"
            
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
    tabBtn.Size = UDim2.new(0, 120, 1, 0)
    tabBtn.Text = tab.icon .. " " .. tab.name
    tabBtn.BackgroundColor3 = i == 1 and tab.color or Color3.fromRGB(50, 50, 60)
    tabBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    tabBtn.Font = Enum.Font.SourceSansBold
    tabBtn.TextSize = 12
    tabBtn.BorderSizePixel = 0
    Instance.new("UICorner", tabBtn).CornerRadius = UDim.new(0, 6)
    
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
    btn.Size = UDim2.new(0, 100, 1, 0)
    btn.Text = text
    btn.BackgroundColor3 = color
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Font = Enum.Font.SourceSansBold
    btn.TextSize = 11
    btn.BorderSizePixel = 0
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
    
    btn.MouseButton1Click:Connect(callback)
    return btn
end

-- Refresh button
createButton("🔄 Refresh", Color3.fromRGB(60, 150, 60), function()
    safeExecute(function()
        contentText.Text = tabs[currentTab].content()
        scrollFrame.CanvasSize = UDim2.new(0, 0, 0, contentText.TextBounds.Y + 20)
    end, "Refresh button")
end)

-- Copy current position button
createButton("📍 Copy Pos", Color3.fromRGB(80, 160, 120), function()
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        local pos = LocalPlayer.Character.HumanoidRootPart.Position
        local posString = string.format("Vector3.new(%.2f, %.2f, %.2f)", pos.X, pos.Y, pos.Z)
        
        if setclipboard then
            setclipboard(posString)
            print("📍 Position copied to clipboard: " .. posString)
        else
            print("📍 Current position: " .. posString)
        end
    end
end)

-- Copy export button
createButton("📋 Copy Export", Color3.fromRGB(200, 120, 80), function()
    if currentTab == 4 then -- Export tab
        local exportData = contentText.Text
        if setclipboard then
            setclipboard(exportData)
            print("📋 Export data copied to clipboard!")
        else
            print("📋 Export data printed to console")
            print(exportData)
        end
    else
        print("💡 Switch to Export tab first!")
    end
end)

-- Auto-scan button
createButton("🔍 Auto Scan", Color3.fromRGB(100, 150, 200), function()
    safeExecute(function()
        -- Force refresh all tabs data
        for i = 1, #tabs do
            tabs[i].content()
        end
        
        -- Update current tab display
        contentText.Text = tabs[currentTab].content()
        scrollFrame.CanvasSize = UDim2.new(0, 0, 0, contentText.TextBounds.Y + 20)
        
        print("🔍 Auto-scan completed! All location data refreshed.")
    end, "Auto scan")
end)

-- Real-time position update
local updateConnection
local function startPositionTracking()
    if updateConnection then
        updateConnection:Disconnect()
    end
    
    updateConnection = RunService.Heartbeat:Connect(function()
        if currentTab == 1 and mainFrame.Visible then -- Only update if Current tab is active
            safeExecute(function()
                contentText.Text = tabs[1].content()
            end, "Position tracking")
        end
    end)
end

-- Toggle functionality
floatingBtn.MouseButton1Click:Connect(function()
    mainFrame.Visible = not mainFrame.Visible
    floatingBtn.Text = mainFrame.Visible and "❌" or "📍"
    floatingBtn.BackgroundColor3 = mainFrame.Visible and Color3.fromRGB(200, 80, 80) or Color3.fromRGB(80, 160, 120)
    
    if mainFrame.Visible then
        -- Animate show
        mainFrame.Size = UDim2.new(0, 0, 0, 0)
        local tween = TweenService:Create(mainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Back), {
            Size = UDim2.new(0, 700, 0, 400)
        })
        tween:Play()
        
        -- Load initial content and start tracking
        safeExecute(function()
            contentText.Text = tabs[currentTab].content()
            scrollFrame.CanvasSize = UDim2.new(0, 0, 0, contentText.TextBounds.Y + 20)
            startPositionTracking()
        end, "Interface show")
    else
        if updateConnection then
            updateConnection:Disconnect()
        end
    end
end)

-- Close button functionality
closeBtn.MouseButton1Click:Connect(function()
    if updateConnection then
        updateConnection:Disconnect()
    end
    screen:Destroy()
    print("📍 Enhanced Location Detector closed")
end)

-- Hotkey support (Ctrl+L)
local UserInputService = game:GetService("UserInputService")
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if not gameProcessed and input.KeyCode == Enum.KeyCode.L and UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
        floatingBtn.MouseButton1Click:Fire()
    end
end)

-- Initialize
print("📍 Enhanced Location Detector v2.0 started!")
print("✨ New features: Auto-scanning, Export system, Real-time tracking")
print("🎮 Press Ctrl+L or click floating button to open")
print("🚀 Merged location_detector.lua + location_detector_new.lua with major enhancements!")
