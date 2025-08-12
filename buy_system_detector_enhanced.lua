-- Enhanced Buy System Detector v2.0
-- Advanced shop system analysis dengan better error handling dan modularity
-- Major optimization dari buy_system_detector.lua

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local HttpService = game:GetService("HttpService")
local TweenService = game:GetService("TweenService")

-- Enhanced error handling system
local ErrorHandler = {
    errors = {},
    maxErrors = 50
}

function ErrorHandler:safeExecute(func, context, silent)
    local success, result = pcall(func)
    if not success then
        local error = {
            context = context or "Unknown",
            message = tostring(result),
            timestamp = tick()
        }
        
        table.insert(self.errors, error)
        if #self.errors > self.maxErrors then
            table.remove(self.errors, 1)
        end
        
        if not silent then
            warn(string.format('[Buy System] %s: %s', error.context, error.message))
        end
        return false, result
    end
    return true, result
end

function ErrorHandler:getRecentErrors(count)
    count = count or 5
    local recentErrors = {}
    local startIndex = math.max(1, #self.errors - count + 1)
    
    for i = startIndex, #self.errors do
        table.insert(recentErrors, self.errors[i])
    end
    
    return recentErrors
end

-- Remove existing buy system GUIs
ErrorHandler:safeExecute(function()
    local CoreGui = game:GetService("CoreGui")
    for _, gui in pairs(CoreGui:GetChildren()) do
        if gui.Name:find("BuySystem") or gui.Name:find("ShopDetector") then
            gui:Destroy()
        end
    end
end, "GUI cleanup", true)

-- Create enhanced GUI with responsive design
local CoreGui = game:GetService("CoreGui")
local screen = Instance.new("ScreenGui")
screen.Name = "EnhancedBuySystemDetector"
screen.Parent = CoreGui
screen.ResetOnSpawn = false

-- Dynamic sizing based on screen
local screenSize = workspace.CurrentCamera.ViewportSize
local isLandscape = screenSize.X > screenSize.Y
local frameWidth = isLandscape and 650 or 500
local frameHeight = isLandscape and 350 or 400

-- Main frame with responsive design
local mainFrame = Instance.new("Frame")
mainFrame.Parent = screen
mainFrame.Size = UDim2.new(0, frameWidth, 0, frameHeight)
mainFrame.Position = UDim2.new(0.5, -frameWidth/2, 0.5, -frameHeight/2)
mainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.Draggable = true
mainFrame.Visible = false
Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 12)

-- Floating toggle button with enhanced positioning
local floatingBtn = Instance.new("TextButton")
floatingBtn.Parent = screen
floatingBtn.Size = UDim2.new(0, 60, 0, 60)
floatingBtn.Position = UDim2.new(1, -80, 0, 20)
floatingBtn.Text = "🛒"
floatingBtn.BackgroundColor3 = Color3.fromRGB(70, 130, 180)
floatingBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
floatingBtn.Font = Enum.Font.SourceSansBold
floatingBtn.TextSize = 24
floatingBtn.BorderSizePixel = 0
floatingBtn.ZIndex = 10
Instance.new("UICorner", floatingBtn).CornerRadius = UDim.new(0.5, 0)

-- Enhanced shadow with gradient
local shadow = Instance.new("Frame")
shadow.Parent = screen
shadow.Size = UDim2.new(0, 65, 0, 65)
shadow.Position = UDim2.new(1, -82.5, 0, 22.5)
shadow.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
shadow.BackgroundTransparency = 0.6
shadow.BorderSizePixel = 0
shadow.ZIndex = 9
Instance.new("UICorner", shadow).CornerRadius = UDim.new(0.5, 0)

local shadowGradient = Instance.new("UIGradient")
shadowGradient.Parent = shadow
shadowGradient.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 0, 0)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(20, 20, 20))
}

-- Title bar with status
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
titleLabel.Text = "🛒 Enhanced Buy System Detector v2.0"
titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
titleLabel.Font = Enum.Font.SourceSansBold
titleLabel.TextSize = 16
titleLabel.TextXAlignment = Enum.TextXAlignment.Left

-- Status indicator
local statusFrame = Instance.new("Frame")
statusFrame.Parent = titleBar
statusFrame.Size = UDim2.new(0, 80, 0, 25)
statusFrame.Position = UDim2.new(1, -90, 0.5, -12.5)
statusFrame.BackgroundColor3 = Color3.fromRGB(60, 150, 60)
statusFrame.BorderSizePixel = 0
Instance.new("UICorner", statusFrame).CornerRadius = UDim.new(0, 12)

local statusLabel = Instance.new("TextLabel")
statusLabel.Parent = statusFrame
statusLabel.Size = UDim2.new(1, 0, 1, 0)
statusLabel.BackgroundTransparency = 1
statusLabel.Text = "ACTIVE"
statusLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
statusLabel.Font = Enum.Font.SourceSansBold
statusLabel.TextSize = 10

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
contentFrame.Size = UDim2.new(1, -20, 1, -125)
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
contentText.Text = "Initializing enhanced buy system detection..."
contentText.TextColor3 = Color3.fromRGB(255, 255, 255)
contentText.Font = Enum.Font.SourceSans
contentText.TextSize = 11
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

-- Enhanced shop detection system
local ShopDetector = {
    shopEvents = {},
    shopNPCs = {},
    shopLocations = {},
    itemCatalogs = {},
    priceData = {},
    statistics = {
        totalShops = 0,
        totalItems = 0,
        avgPrice = 0
    }
}

function ShopDetector:scanShopEvents()
    self.shopEvents = {}
    
    ErrorHandler:safeExecute(function()
        local function deepScan(parent, path)
            for _, obj in pairs(parent:GetChildren()) do
                if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") then
                    local name = obj.Name:lower()
                    
                    if name:find("buy") or name:find("sell") or name:find("shop") or 
                       name:find("purchase") or name:find("store") or name:find("market") then
                        table.insert(self.shopEvents, {
                            name = obj.Name,
                            type = obj.ClassName,
                            path = obj:GetFullName(),
                            category = self:categorizeShopEvent(name)
                        })
                    end
                end
                
                -- Recursive scan with depth limit
                if path:split("/") and #path:split("/") < 4 then
                    deepScan(obj, path .. "/" .. obj.Name)
                end
            end
        end
        
        deepScan(ReplicatedStorage, "ReplicatedStorage")
    end, "Shop events scan")
    
    return self.shopEvents
end

function ShopDetector:categorizeShopEvent(eventName)
    if eventName:find("buy") or eventName:find("purchase") then
        return "buying"
    elseif eventName:find("sell") then
        return "selling"
    elseif eventName:find("rod") or eventName:find("bait") then
        return "fishing_gear"
    elseif eventName:find("boat") or eventName:find("vehicle") then
        return "vehicles"
    else
        return "general"
    end
end

function ShopDetector:scanShopNPCs()
    self.shopNPCs = {}
    
    ErrorHandler:safeExecute(function()
        local shopKeywords = {"shop", "merchant", "trader", "vendor", "seller", "alex", "store"}
        
        local function findNPCs(parent, depth)
            if depth > 3 then return end
            
            for _, obj in pairs(parent:GetChildren()) do
                if obj:IsA("Model") and obj:FindFirstChild("Humanoid") then
                    local humanoidRootPart = obj:FindFirstChild("HumanoidRootPart")
                    
                    if humanoidRootPart then
                        local npcName = obj.Name:lower()
                        local isShopNPC = false
                        
                        for _, keyword in pairs(shopKeywords) do
                            if npcName:find(keyword) then
                                isShopNPC = true
                                break
                            end
                        end
                        
                        if isShopNPC then
                            table.insert(self.shopNPCs, {
                                name = obj.Name,
                                position = humanoidRootPart.CFrame,
                                distance = (humanoidRootPart.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude
                            })
                        end
                    end
                end
                
                findNPCs(obj, depth + 1)
            end
        end
        
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            findNPCs(Workspace, 0)
        end
    end, "Shop NPCs scan")
    
    -- Sort by distance
    table.sort(self.shopNPCs, function(a, b) return a.distance < b.distance end)
    
    return self.shopNPCs
end

function ShopDetector:scanShopLocations()
    self.shopLocations = {}
    
    ErrorHandler:safeExecute(function()
        local shopKeywords = {"shop", "store", "market", "merchant", "trader"}
        
        local function findShopLocations(parent, depth)
            if depth > 3 then return end
            
            for _, obj in pairs(parent:GetChildren()) do
                if obj:IsA("BasePart") then
                    local objName = obj.Name:lower()
                    
                    for _, keyword in pairs(shopKeywords) do
                        if objName:find(keyword) then
                            table.insert(self.shopLocations, {
                                name = obj.Name,
                                position = obj.CFrame,
                                size = obj.Size
                            })
                            break
                        end
                    end
                end
                
                findShopLocations(obj, depth + 1)
            end
        end
        
        findShopLocations(Workspace, 0)
    end, "Shop locations scan")
    
    return self.shopLocations
end

function ShopDetector:generateReport()
    self.statistics.totalShops = #self.shopNPCs + #self.shopLocations
    self.statistics.totalItems = #self.shopEvents
    
    return {
        events = #self.shopEvents,
        npcs = #self.shopNPCs,
        locations = #self.shopLocations,
        errors = #ErrorHandler.errors
    }
end

-- Tab definitions
local tabs = {
    {
        name = "Overview",
        icon = "📊",
        color = Color3.fromRGB(70, 130, 180),
        content = function()
            local report = ShopDetector:generateReport()
            local result = "=== BUY SYSTEM OVERVIEW ===\n\n"
            
            result = result .. string.format("🛒 Shop Events Found: %d\n", report.events)
            result = result .. string.format("👨‍💼 Shop NPCs Found: %d\n", report.npcs)
            result = result .. string.format("🏪 Shop Locations: %d\n", report.locations)
            result = result .. string.format("⚠️ Errors Logged: %d\n\n", report.errors)
            
            result = result .. "📈 SYSTEM STATUS:\n"
            result = result .. "✅ Auto-scanning enabled\n"
            result = result .. "✅ Error handling active\n"
            result = result .. "✅ Distance calculation ready\n"
            result = result .. "✅ Export system ready\n\n"
            
            if report.errors > 0 then
                result = result .. "⚠️ RECENT ERRORS:\n"
                local recentErrors = ErrorHandler:getRecentErrors(3)
                for _, error in pairs(recentErrors) do
                    result = result .. string.format("• %s: %s\n", error.context, error.message)
                end
                result = result .. "\n"
            end
            
            result = result .. "💡 Switch to other tabs for detailed analysis!"
            
            return result
        end
    },
    {
        name = "Events",
        icon = "📡",
        color = Color3.fromRGB(80, 160, 120),
        content = function()
            ShopDetector:scanShopEvents()
            local result = "=== SHOP EVENTS ANALYSIS ===\n\n"
            
            if #ShopDetector.shopEvents == 0 then
                result = result .. "❌ No shop events detected!\n"
                result = result .. "💡 Try refreshing or check game loading status.\n"
                return result
            end
            
            -- Group by category
            local categories = {}
            for _, event in pairs(ShopDetector.shopEvents) do
                if not categories[event.category] then
                    categories[event.category] = {}
                end
                table.insert(categories[event.category], event)
            end
            
            for category, events in pairs(categories) do
                result = result .. string.format("🎯 %s (%d):\n", category:upper(), #events)
                for _, event in pairs(events) do
                    result = result .. string.format("  %s %s: %s\n", 
                        event.type == "RemoteEvent" and "📡" or "🔧", 
                        event.name, event.path)
                end
                result = result .. "\n"
            end
            
            return result
        end
    },
    {
        name = "NPCs",
        icon = "👨‍💼",
        color = Color3.fromRGB(120, 80, 160),
        content = function()
            ShopDetector:scanShopNPCs()
            local result = "=== SHOP NPCs ANALYSIS ===\n\n"
            
            if #ShopDetector.shopNPCs == 0 then
                result = result .. "❌ No shop NPCs detected nearby!\n"
                result = result .. "💡 Try moving to different areas or shops.\n"
                return result
            end
            
            result = result .. "👨‍💼 DETECTED SHOP NPCs (sorted by distance):\n\n"
            for i, npc in pairs(ShopDetector.shopNPCs) do
                if i <= 10 then -- Limit display
                    result = result .. string.format("%d. %s\n", i, npc.name)
                    result = result .. string.format("   Distance: %.1f studs\n", npc.distance)
                    result = result .. string.format("   Position: CFrame.new(%.2f, %.2f, %.2f)\n\n", 
                        npc.position.X, npc.position.Y, npc.position.Z)
                end
            end
            
            if #ShopDetector.shopNPCs > 10 then
                result = result .. string.format("... and %d more NPCs\n", #ShopDetector.shopNPCs - 10)
            end
            
            return result
        end
    },
    {
        name = "Export",
        icon = "💾",
        color = Color3.fromRGB(200, 120, 80),
        content = function()
            local result = "=== EXPORT FOR MAIN.LUA ===\n\n"
            
            result = result .. "🔧 Enhanced shop data for automation:\n\n"
            result = result .. "-- Auto-Generated Shop System Data\n"
            result = result .. "local ShopData = {\n"
            
            -- Export events by category
            if #ShopDetector.shopEvents > 0 then
                result = result .. "    events = {\n"
                for _, event in pairs(ShopDetector.shopEvents) do
                    result = result .. string.format('        %s = game:GetService("ReplicatedStorage"):WaitForChild("%s"),\n', 
                        event.name, event.name)
                end
                result = result .. "    },\n"
            end
            
            -- Export NPCs
            if #ShopDetector.shopNPCs > 0 then
                result = result .. "    npcs = {\n"
                for _, npc in pairs(ShopDetector.shopNPCs) do
                    result = result .. string.format('        ["%s"] = CFrame.new(%.2f, %.2f, %.2f),\n', 
                        npc.name, npc.position.X, npc.position.Y, npc.position.Z)
                end
                result = result .. "    },\n"
            end
            
            result = result .. "}\n\n"
            result = result .. "-- Usage examples:\n"
            result = result .. "-- ShopData.events.BuyRod:FireServer(args)\n"
            result = result .. "-- game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = ShopData.npcs['Alex']\n\n"
            result = result .. "📋 Click 'Copy Export' to copy to clipboard!"
            
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
        ErrorHandler:safeExecute(function()
            contentText.Text = tab.content()
            scrollFrame.CanvasSize = UDim2.new(0, 0, 0, contentText.TextBounds.Y + 20)
        end, "Tab content update")
    end)
end

-- Enhanced dragging system for floating button
local dragModule = {
    dragging = false,
    dragStart = nil,
    startPos = nil
}

floatingBtn.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragModule.dragging = true
        dragModule.dragStart = input.Position
        dragModule.startPos = floatingBtn.Position
    end
end)

floatingBtn.InputChanged:Connect(function(input)
    if dragModule.dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        ErrorHandler:safeExecute(function()
            local delta = input.Position - dragModule.dragStart
            local newPos = UDim2.new(
                dragModule.startPos.X.Scale, 
                dragModule.startPos.X.Offset + delta.X, 
                dragModule.startPos.Y.Scale, 
                dragModule.startPos.Y.Offset + delta.Y
            )
            floatingBtn.Position = newPos
            shadow.Position = UDim2.new(newPos.X.Scale, newPos.X.Offset - 2.5, newPos.Y.Scale, newPos.Y.Offset + 2.5)
        end, "Drag update", true)
    end
end)

floatingBtn.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragModule.dragging = false
    end
end)

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
    
    btn.MouseButton1Click:Connect(function()
        ErrorHandler:safeExecute(callback, "Button: " .. text)
    end)
    return btn
end

-- Enhanced buttons
createButton("🔄 Refresh", Color3.fromRGB(60, 150, 60), function()
    contentText.Text = tabs[currentTab].content()
    scrollFrame.CanvasSize = UDim2.new(0, 0, 0, contentText.TextBounds.Y + 20)
    print("🔄 Shop system scan completed!")
end)

createButton("📋 Copy Export", Color3.fromRGB(200, 120, 80), function()
    if currentTab == 4 then
        local exportData = contentText.Text
        if setclipboard then
            setclipboard(exportData)
            print("📋 Shop data copied to clipboard!")
        else
            print("📋 Shop data printed to console")
            print(exportData)
        end
    else
        print("💡 Switch to Export tab first!")
    end
end)

createButton("🗑️ Clear Errors", Color3.fromRGB(180, 70, 70), function()
    ErrorHandler.errors = {}
    if currentTab == 1 then
        contentText.Text = tabs[currentTab].content()
        scrollFrame.CanvasSize = UDim2.new(0, 0, 0, contentText.TextBounds.Y + 20)
    end
    print("🗑️ Error log cleared!")
end)

createButton("🎯 Quick Scan", Color3.fromRGB(100, 150, 200), function()
    -- Force all scans
    ShopDetector:scanShopEvents()
    ShopDetector:scanShopNPCs()
    ShopDetector:scanShopLocations()
    
    contentText.Text = tabs[currentTab].content()
    scrollFrame.CanvasSize = UDim2.new(0, 0, 0, contentText.TextBounds.Y + 20)
    print("🎯 Complete shop scan finished!")
end)

-- Toggle functionality with animation
floatingBtn.MouseButton1Click:Connect(function()
    if not dragModule.dragging then
        mainFrame.Visible = not mainFrame.Visible
        floatingBtn.Text = mainFrame.Visible and "❌" or "🛒"
        floatingBtn.BackgroundColor3 = mainFrame.Visible and Color3.fromRGB(200, 80, 80) or Color3.fromRGB(70, 130, 180)
        
        if mainFrame.Visible then
            -- Animate show
            mainFrame.Size = UDim2.new(0, 0, 0, 0)
            local tween = TweenService:Create(mainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Back), {
                Size = UDim2.new(0, frameWidth, 0, frameHeight)
            })
            tween:Play()
            
            -- Load initial content
            ErrorHandler:safeExecute(function()
                contentText.Text = tabs[currentTab].content()
                scrollFrame.CanvasSize = UDim2.new(0, 0, 0, contentText.TextBounds.Y + 20)
            end, "Interface show")
        end
    end
end)

-- Close functionality
closeBtn.MouseButton1Click:Connect(function()
    screen:Destroy()
    print("🛒 Enhanced Buy System Detector closed")
end)

-- Hotkey support (Ctrl+B)
local UserInputService = game:GetService("UserInputService")
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if not gameProcessed and input.KeyCode == Enum.KeyCode.B and UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
        floatingBtn.MouseButton1Click:Fire()
    end
end)

-- Initialize with enhanced error handling
ErrorHandler:safeExecute(function()
    print("🛒 Enhanced Buy System Detector v2.0 started!")
    print("✨ New features: Advanced error handling, Responsive design, Modular structure")
    print("🎮 Press Ctrl+B or click floating button to open")
    print("🚀 Major optimization with comprehensive shop analysis!")
    
    -- Initial quick scan
    ShopDetector:scanShopEvents()
end, "Initialization")
