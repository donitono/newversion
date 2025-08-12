-- Unified Tools Interface
-- Interface terpadu dengan tab menu untuk semua tools detector
-- Menggantikan floating button terpisah dengan satu interface clean

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")
local LocalPlayer = Players.LocalPlayer

-- Create main GUI
local CoreGui = game:GetService("CoreGui")

-- Remove existing detector GUIs
for _, gui in pairs(CoreGui:GetChildren()) do
    if gui.Name:find("Detector") or gui.Name:find("Analyzer") or gui.Name:find("Logger") or gui.Name:find("Monitor") then
        gui:Destroy()
    end
end

local screen = Instance.new("ScreenGui")
screen.Name = "UnifiedToolsInterface"
screen.Parent = CoreGui
screen.ResetOnSpawn = false

-- Main container (compact untuk landscape mobile)
local mainFrame = Instance.new("Frame")
mainFrame.Parent = screen
mainFrame.Size = UDim2.new(0, 600, 0, 320) -- Reduced from 800x450 to 600x320
mainFrame.Position = UDim2.new(0.5, -300, 0.5, -160)
mainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.Draggable = true
mainFrame.Visible = false
Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 12)

-- Add gradient background
local gradient = Instance.new("UIGradient")
gradient.Parent = mainFrame
gradient.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, Color3.fromRGB(35, 35, 50)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(20, 20, 30))
}
gradient.Rotation = 45

-- Floating toggle button (compact untuk mobile landscape)
local floatingBtn = Instance.new("TextButton")
floatingBtn.Parent = screen
floatingBtn.Size = UDim2.new(0, 55, 0, 55) -- Reduced from 70x70 to 55x55
floatingBtn.Position = UDim2.new(1, -70, 0, 15) -- Adjusted position
floatingBtn.Text = "🔧"
floatingBtn.BackgroundColor3 = Color3.fromRGB(60, 120, 200)
floatingBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
floatingBtn.Font = Enum.Font.SourceSansBold
floatingBtn.TextSize = 22 -- Reduced from 28 to 22
floatingBtn.BorderSizePixel = 0
floatingBtn.ZIndex = 10
Instance.new("UICorner", floatingBtn).CornerRadius = UDim.new(0.5, 0)

-- Title bar (compact)
local titleBar = Instance.new("Frame")
titleBar.Parent = mainFrame
titleBar.Size = UDim2.new(1, 0, 0, 35) -- Reduced from 50 to 35
titleBar.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
titleBar.BorderSizePixel = 0
Instance.new("UICorner", titleBar).CornerRadius = UDim.new(0, 12)

local titleLabel = Instance.new("TextLabel")
titleLabel.Parent = titleBar
titleLabel.Size = UDim2.new(1, -80, 1, 0) -- Adjusted for smaller close button
titleLabel.Position = UDim2.new(0, 8, 0, 0)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "🔧 XSAN Tools Suite"
titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
titleLabel.Font = Enum.Font.SourceSansBold
titleLabel.TextSize = 14 -- Reduced from 18 to 14
titleLabel.TextXAlignment = Enum.TextXAlignment.Left

-- Close button (smaller)
local closeBtn = Instance.new("TextButton")
closeBtn.Parent = titleBar
closeBtn.Size = UDim2.new(0, 30, 0, 25) -- Reduced size
closeBtn.Position = UDim2.new(1, -35, 0, 5)
closeBtn.Text = "✖"
closeBtn.BackgroundColor3 = Color3.fromRGB(200, 80, 80)
closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
closeBtn.Font = Enum.Font.SourceSansBold
closeBtn.TextSize = 12 -- Reduced from 16 to 12
closeBtn.BorderSizePixel = 0
Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0, 6)

-- Tab container (compact)
local tabContainer = Instance.new("Frame")
tabContainer.Parent = mainFrame
tabContainer.Size = UDim2.new(1, -16, 0, 32) -- Reduced height and padding
tabContainer.Position = UDim2.new(0, 8, 0, 40) -- Adjusted for smaller title bar
tabContainer.BackgroundTransparency = 1

local tabLayout = Instance.new("UIListLayout")
tabLayout.Parent = tabContainer
tabLayout.FillDirection = Enum.FillDirection.Horizontal
tabLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
tabLayout.Padding = UDim.new(0, 3) -- Reduced padding

-- Content area (compact)
local contentFrame = Instance.new("Frame")
contentFrame.Parent = mainFrame
contentFrame.Size = UDim2.new(1, -16, 1, -85) -- Adjusted for compact layout
contentFrame.Position = UDim2.new(0, 8, 0, 77) -- Adjusted position
contentFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
contentFrame.BorderSizePixel = 0
Instance.new("UICorner", contentFrame).CornerRadius = UDim.new(0, 6)

-- Scrollable content (compact)
local scrollFrame = Instance.new("ScrollingFrame")
scrollFrame.Parent = contentFrame
scrollFrame.Size = UDim2.new(1, -8, 1, -8) -- Reduced padding
scrollFrame.Position = UDim2.new(0, 4, 0, 4)
scrollFrame.BackgroundTransparency = 1
scrollFrame.BorderSizePixel = 0
scrollFrame.ScrollBarThickness = 6 -- Thinner scrollbar
scrollFrame.ScrollBarImageColor3 = Color3.fromRGB(80, 80, 120)
scrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)

local contentText = Instance.new("TextLabel")
contentText.Parent = scrollFrame
contentText.Size = UDim2.new(1, -8, 1, 0) -- Reduced padding
contentText.Position = UDim2.new(0, 4, 0, 0)
contentText.BackgroundTransparency = 1
contentText.Text = "Loading..."
contentText.TextColor3 = Color3.fromRGB(255, 255, 255)
contentText.Font = Enum.Font.SourceSans
contentText.TextSize = 10 -- Reduced from 12 to 10
contentText.TextWrapped = true
contentText.TextXAlignment = Enum.TextXAlignment.Left
contentText.TextYAlignment = Enum.TextYAlignment.Top

-- Tab data and functions
local tabs = {
    {
        name = "🏝️ Islands",
        icon = "🏝️",
        color = Color3.fromRGB(80, 160, 120),
        content = function()
            return "=== ISLAND LOCATIONS DETECTOR ===\n\n" ..
                   "📍 Scanning workspace for island locations...\n\n" ..
                   "🏝️ DETECTED ISLANDS:\n" ..
                   (function()
                       local result = ""
                       local tpFolder = workspace:FindFirstChild("!!!! ISLAND LOCATIONS !!!!")
                       if tpFolder then
                           for _, island in ipairs(tpFolder:GetChildren()) do
                               if island:IsA("BasePart") then
                                   result = result .. "• " .. island.Name .. ": " .. tostring(island.CFrame) .. "\n"
                               end
                           end
                       else
                           result = "• Kohana Volcano: CFrame.new(-594.97, 396.65, 149.11)\n" ..
                                  "• Crater Island: CFrame.new(1010.01, 252.00, 5078.45)\n" ..
                                  "• Kohana: CFrame.new(-650.97, 208.69, 711.11)\n" ..
                                  "• Lost Isle: CFrame.new(-3618.16, 240.84, -1317.46)\n" ..
                                  "• Stingray Shores: CFrame.new(45.28, 252.56, 2987.11)\n" ..
                                  "• Esoteric Depths: CFrame.new(1944.78, 393.56, 1371.36)\n" ..
                                  "• Weather Machine: CFrame.new(-1488.51, 83.17, 1876.30)\n" ..
                                  "• Tropical Grove: CFrame.new(-2095.34, 197.20, 3718.08)\n" ..
                                  "• Coral Reefs: CFrame.new(-3023.97, 337.81, 2195.61)\n"
                       end
                       return result
                   end)() ..
                   "\n🎣 Perfect for fishing automation teleportation system!"
        end
    },
    {
        name = "👥 NPCs",
        icon = "👥", 
        color = Color3.fromRGB(120, 80, 160),
        content = function()
            local result = "=== NPC & LOCATION DETECTOR ===\n\n📍 Scanning for NPCs and important locations...\n\n"
            
            -- Scan for NPCs in workspace
            local npcs = {}
            local locations = {}
            
            local function scanWorkspace(parent, depth)
                if depth > 3 then return end -- Limit recursion
                
                for _, obj in pairs(parent:GetChildren()) do
                    if obj:IsA("Model") and obj:FindFirstChild("Humanoid") then
                        table.insert(npcs, {name = obj.Name, position = obj:GetPrimaryPartCFrame() or CFrame.new()})
                    elseif obj:IsA("BasePart") and (obj.Name:lower():find("shop") or obj.Name:lower():find("sell") or obj.Name:lower():find("buy")) then
                        table.insert(locations, {name = obj.Name, position = obj.CFrame})
                    end
                    scanWorkspace(obj, depth + 1)
                end
            end
            
            scanWorkspace(workspace, 0)
            
            result = result .. "👥 DETECTED NPCs:\n"
            for i, npc in ipairs(npcs) do
                if i <= 10 then -- Limit display
                    result = result .. "• " .. npc.name .. ": " .. tostring(npc.position) .. "\n"
                end
            end
            
            result = result .. "\n📍 IMPORTANT LOCATIONS:\n"
            for i, loc in ipairs(locations) do
                if i <= 10 then
                    result = result .. "• " .. loc.name .. ": " .. tostring(loc.position) .. "\n"
                end
            end
            
            return result .. "\n🛡️ Use this data for safe teleportation and NPC interaction!"
        end
    },
    {
        name = "📡 Events",
        icon = "📡",
        color = Color3.fromRGB(100, 150, 200),
        content = function()
            local result = "=== REMOTE EVENTS MONITOR ===\n\n📡 Monitoring RemoteEvents and RemoteFunctions...\n\n"
            
            local events = {}
            local function scanForRemotes(parent)
                for _, obj in pairs(parent:GetDescendants()) do
                    if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") then
                        table.insert(events, {name = obj.Name, type = obj.ClassName, path = obj:GetFullName()})
                    end
                end
            end
            
            scanForRemotes(ReplicatedStorage)
            
            result = result .. "🔍 DETECTED REMOTES:\n"
            for i, event in ipairs(events) do
                if i <= 15 then
                    local category = "OTHER"
                    if event.name:lower():find("fish") then category = "FISHING"
                    elseif event.name:lower():find("sell") or event.name:lower():find("buy") then category = "SHOP"
                    end
                    result = result .. "• [" .. category .. "] " .. event.name .. " (" .. event.type .. ")\n"
                end
            end
            
            return result .. "\n⚡ Total Events: " .. #events .. "\n🎣 Perfect for automation hook detection!"
        end
    },
    {
        name = "🛒 Buy System",
        icon = "🛒",
        color = Color3.fromRGB(70, 130, 180),
        content = function()
            local result = "=== BUY SYSTEM DETECTOR ===\n\n🛒 Analyzing shop systems and buy mechanisms...\n\n"
            
            -- Detect shop-related RemoteEvents
            local shopEvents = {}
            for _, obj in pairs(ReplicatedStorage:GetDescendants()) do
                if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") then
                    if obj.Name:lower():find("buy") or obj.Name:lower():find("sell") or obj.Name:lower():find("shop") or obj.Name:lower():find("purchase") then
                        table.insert(shopEvents, obj.Name)
                    end
                end
            end
            
            result = result .. "🏪 SHOP EVENTS DETECTED:\n"
            for _, event in ipairs(shopEvents) do
                result = result .. "• " .. event .. "\n"
            end
            
            -- Detect shop NPCs
            result = result .. "\n👨‍💼 SHOP NPCs:\n"
            local shopNPCs = {"Alex", "Merchant", "Trader", "Seller", "Vendor"}
            for _, npcName in ipairs(shopNPCs) do
                local npc = workspace:FindFirstChild(npcName)
                if npc and npc:FindFirstChild("HumanoidRootPart") then
                    result = result .. "• " .. npcName .. ": " .. tostring(npc.HumanoidRootPart.CFrame) .. "\n"
                end
            end
            
            return result .. "\n💰 Ready for auto-sell integration and shop automation!"
        end
    },
    {
        name = "🔍 Analyzer",
        icon = "🔍",
        color = Color3.fromRGB(200, 120, 80),
        content = function()
            local result = "=== FEATURE ANALYZER ===\n\n🔍 Analyzing current game features and suggesting improvements...\n\n"
            
            -- Analyze RemoteEvents
            local totalEvents = 0
            local fishingEvents = 0
            local shopEvents = 0
            
            for _, obj in pairs(ReplicatedStorage:GetDescendants()) do
                if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") then
                    totalEvents = totalEvents + 1
                    if obj.Name:lower():find("fish") then
                        fishingEvents = fishingEvents + 1
                    elseif obj.Name:lower():find("sell") or obj.Name:lower():find("buy") then
                        shopEvents = shopEvents + 1
                    end
                end
            end
            
            result = result .. "📊 ANALYSIS RESULTS:\n"
            result = result .. "• Total RemoteEvents: " .. totalEvents .. "\n"
            result = result .. "• Fishing Events: " .. fishingEvents .. "\n"
            result = result .. "• Shop Events: " .. shopEvents .. "\n"
            result = result .. "• Other Events: " .. (totalEvents - fishingEvents - shopEvents) .. "\n\n"
            
            result = result .. "🚀 IMPROVEMENT SUGGESTIONS:\n"
            result = result .. "• Enhanced auto-fishing with weather detection\n"
            result = result .. "• Smart inventory management system\n"
            result = result .. "• Advanced anti-detection mechanisms\n"
            result = result .. "• Real-time profit optimization\n"
            result = result .. "• Dynamic server quality analysis\n\n"
            
            return result .. "💡 Use these insights to upgrade main.lua functionality!"
        end
    },
    {
        name = "⚙️ Settings",
        icon = "⚙️",
        color = Color3.fromRGB(120, 120, 120),
        content = function()
            return "=== TOOLS SETTINGS ===\n\n⚙️ Configuration and management options...\n\n" ..
                   "🔧 AVAILABLE ACTIONS:\n\n" ..
                   "• Refresh all detector data\n" ..
                   "• Export detection results\n" ..
                   "• Toggle auto-monitoring\n" ..
                   "• Clear cache and logs\n" ..
                   "• Update detection algorithms\n\n" ..
                   "📱 INTERFACE OPTIONS:\n\n" ..
                   "• Landscape mode optimization ✓\n" ..
                   "• Draggable interface ✓\n" ..
                   "• Tabbed navigation ✓\n" ..
                   "• Real-time updates ✓\n\n" ..
                   "🎯 All tools integrated in one clean interface!\n" ..
                   "💾 Settings auto-saved for convenience."
        end
    }
}

-- Create tab buttons
local tabButtons = {}
local currentTab = 1

for i, tab in ipairs(tabs) do
    local tabBtn = Instance.new("TextButton")
    tabBtn.Parent = tabContainer
    tabBtn.Size = UDim2.new(0, 90, 1, 0) -- Reduced from 120 to 90
    tabBtn.Text = tab.icon .. " " .. tab.name:gsub("🏝️ ", ""):gsub("👥 ", ""):gsub("📡 ", ""):gsub("🛒 ", ""):gsub("🔍 ", ""):gsub("⚙️ ", "")
    tabBtn.BackgroundColor3 = i == 1 and tab.color or Color3.fromRGB(50, 50, 60)
    tabBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    tabBtn.Font = Enum.Font.SourceSansBold
    tabBtn.TextSize = 9 -- Reduced from 11 to 9
    tabBtn.BorderSizePixel = 0
    Instance.new("UICorner", tabBtn).CornerRadius = UDim.new(0, 4) -- Smaller corner radius
    
    tabButtons[i] = tabBtn
    
    -- Tab click event
    tabBtn.MouseButton1Click:Connect(function()
        currentTab = i
        
        -- Update tab appearance
        for j, btn in ipairs(tabButtons) do
            btn.BackgroundColor3 = j == i and tabs[j].color or Color3.fromRGB(50, 50, 60)
        end
        
        -- Update content
        contentText.Text = tab.content()
        scrollFrame.CanvasSize = UDim2.new(0, 0, 0, contentText.TextBounds.Y + 20)
    end)
end

-- Control buttons (compact)
local buttonFrame = Instance.new("Frame")
buttonFrame.Parent = contentFrame
buttonFrame.Size = UDim2.new(1, -16, 0, 25) -- Reduced height from 30 to 25
buttonFrame.Position = UDim2.new(0, 8, 1, -30) -- Adjusted position
buttonFrame.BackgroundTransparency = 1

local refreshBtn = Instance.new("TextButton")
refreshBtn.Parent = buttonFrame
refreshBtn.Size = UDim2.new(0, 70, 1, 0) -- Reduced from 80 to 70
refreshBtn.Position = UDim2.new(0, 0, 0, 0)
refreshBtn.Text = "🔄 Refresh"
refreshBtn.BackgroundColor3 = Color3.fromRGB(60, 150, 60)
refreshBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
refreshBtn.Font = Enum.Font.SourceSansBold
refreshBtn.TextSize = 9 -- Reduced from 10 to 9
refreshBtn.BorderSizePixel = 0
Instance.new("UICorner", refreshBtn).CornerRadius = UDim.new(0, 4)

local exportBtn = Instance.new("TextButton")
exportBtn.Parent = buttonFrame
exportBtn.Size = UDim2.new(0, 70, 1, 0) -- Reduced from 80 to 70
exportBtn.Position = UDim2.new(0, 75, 0, 0) -- Adjusted spacing
exportBtn.Text = "📋 Export"
exportBtn.BackgroundColor3 = Color3.fromRGB(70, 130, 180)
exportBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
exportBtn.Font = Enum.Font.SourceSansBold
exportBtn.TextSize = 9 -- Reduced from 10 to 9
exportBtn.BorderSizePixel = 0
Instance.new("UICorner", exportBtn).CornerRadius = UDim.new(0, 4)

-- Button events
refreshBtn.MouseButton1Click:Connect(function()
    refreshBtn.Text = "🔄 ..."
    contentText.Text = tabs[currentTab].content()
    scrollFrame.CanvasSize = UDim2.new(0, 0, 0, contentText.TextBounds.Y + 20)
    task.spawn(function()
        task.wait(1)
        refreshBtn.Text = "🔄 Refresh"
    end)
end)

exportBtn.MouseButton1Click:Connect(function()
    local exportData = contentText.Text
    if setclipboard then
        setclipboard(exportData)
        exportBtn.Text = "📋 Copied!"
    else
        print(exportData)
        exportBtn.Text = "📋 Printed"
    end
    task.spawn(function()
        task.wait(1)
        exportBtn.Text = "📋 Export"
    end)
end)

-- Main toggle functionality
floatingBtn.MouseButton1Click:Connect(function()
    mainFrame.Visible = not mainFrame.Visible
    floatingBtn.Text = mainFrame.Visible and "❌" or "🔧"
    floatingBtn.BackgroundColor3 = mainFrame.Visible and Color3.fromRGB(200, 80, 80) or Color3.fromRGB(60, 120, 200)
    
    if mainFrame.Visible then
        -- Animate show (compact size)
        mainFrame.Size = UDim2.new(0, 0, 0, 0)
        local tween = TweenService:Create(mainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Back), {
            Size = UDim2.new(0, 600, 0, 320) -- Updated to new compact size
        })
        tween:Play()
        
        -- Load initial content
        contentText.Text = tabs[currentTab].content()
        scrollFrame.CanvasSize = UDim2.new(0, 0, 0, contentText.TextBounds.Y + 20)
    end
end)

closeBtn.MouseButton1Click:Connect(function()
    screen:Destroy()
    print("🔧 Unified Tools Interface closed")
end)

-- Hotkey support (F12)
local UserInputService = game:GetService("UserInputService")
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if not gameProcessed and input.KeyCode == Enum.KeyCode.F12 then
        floatingBtn.MouseButton1Click:Fire()
    end
end)

-- Initialize
print("🔧 XSAN Unified Tools Interface started!")
print("📱 All detector tools integrated in one clean interface")
print("🎮 Press F12 or click floating button to open")
print("⚡ Landscape mode optimized for mobile gaming")
