--[[
    XSAN's Fish It Pro - Ultimate Edition v1.0 WORKING VERSION
    
    Premium Fish It script with ULTIMATE features:
    • Quick Start Presets & Advanced Analytics
    • Smart Inventory Management & AI Features  
    • Enhanced Fishing & Quality of Life
    • Smart Notifications & Safety Systems
    • Advanced Automation & Much More
    • Ultimate Teleportation System (NEW!)
    
    Developer: XSAN
    Instagram: @_bangicoo
    GitHub: github.com/codeico
    
    Premium Quality • Trusted by Thousands • Ultimate Edition
--]]

print("XSAN: Starting Fish It Pro Ultimate v1.0...")

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local LocalPlayer = Players.LocalPlayer
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")
local TweenService = game:GetService("TweenService")
local SoundService = game:GetService("SoundService")
local StarterGui = game:GetService("StarterGui")

-- Notification system
local function Notify(title, text, duration)
    duration = duration or 3
    pcall(function()
        StarterGui:SetCore("SendNotification", {
            Title = title or "XSAN Fish It Pro",
            Text = text or "Notification", 
            Duration = duration,
            Icon = "rbxassetid://6023426923"
        })
    end)
    print("XSAN:", title, "-", text)
end

-- Check basic requirements
if not LocalPlayer then
    warn("XSAN ERROR: LocalPlayer not found")
    return
end

if not ReplicatedStorage then
    warn("XSAN ERROR: ReplicatedStorage not found")
    return
end

print("XSAN: Basic services OK")

-- XSAN Anti Ghost Touch System
local ButtonCooldowns = {}
local BUTTON_COOLDOWN = 0.5

local function CreateSafeCallback(originalCallback, buttonId)
    return function(...)
        local currentTime = tick()
        if ButtonCooldowns[buttonId] and currentTime - ButtonCooldowns[buttonId] < BUTTON_COOLDOWN then
            return
        end
        ButtonCooldowns[buttonId] = currentTime
        
        local success, result = pcall(originalCallback, ...)
        if not success then
            warn("XSAN Error:", result)
        end
    end
end

-- Load Rayfield with error handling
print("XSAN: Loading UI Library...")

local Rayfield
local success, error = pcall(function()
    print("XSAN: Attempting to load UI...")
    
    -- Try ui_fixed.lua first (more stable)
    local uiContent = game:HttpGet("https://raw.githubusercontent.com/donitono/part2/main/ui_fixed.lua")
    if uiContent and #uiContent > 0 then
        print("XSAN: Loading stable UI library...")
        print("XSAN: UI content length:", #uiContent)
        local uiFunc, loadError = loadstring(uiContent)
        if uiFunc then
            Rayfield = uiFunc()
            if not Rayfield then
                error("UI function returned nil")
            end
            print("XSAN: Stable UI loaded successfully!")
        else
            error("Failed to compile UI: " .. tostring(loadError))
        end
    else
        error("Failed to fetch UI content")
    end
end)

if not success then
    warn("XSAN Error: Failed to load Rayfield UI Library - " .. tostring(error))
    return
end

if not Rayfield then
    warn("XSAN Error: Rayfield is nil after loading")
    return
end

print("XSAN: UI Library loaded successfully!")

-- Mobile/Android detection and UI scaling
local UserInputService = game:GetService("UserInputService")
local GuiService = game:GetService("GuiService")
local isMobile = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled
local screenSize = workspace.CurrentCamera.ViewportSize

print("XSAN: Platform Detection - Mobile:", isMobile, "Screen Size:", screenSize.X .. "x" .. screenSize.Y)

-- Create Window with mobile-optimized settings
print("XSAN: Creating main window...")
local windowConfig = {
    Name = isMobile and "XSAN Fish It Pro Mobile" or "XSAN Fish It Pro v1.0",
    LoadingTitle = "XSAN Fish It Pro Ultimate",
    LoadingSubtitle = "by XSAN - Mobile Optimized",
    Theme = "DarkBlue",
    ConfigurationSaving = {
        Enabled = true,
        FolderName = "XSAN",
        FileName = "FishItProUltimate"
    },
    KeySystem = false,
    DisableRayfieldPrompts = false,
    DisableBuildWarnings = false
}

-- Mobile specific adjustments
if isMobile then
    -- Detect orientation
    local isLandscape = screenSize.X > screenSize.Y
    
    if isLandscape then
        -- Landscape mode - Much wider UI untuk nama fitur tidak terpotong
        windowConfig.Size = UDim2.new(0, math.min(screenSize.X * 0.60, 500), 0, math.min(screenSize.Y * 0.75, 300))
        print("XSAN: Landscape mode detected - using wider UI for feature names")
    else
        -- Portrait mode - lebih lebar untuk readability
        windowConfig.Size = UDim2.new(0, math.min(screenSize.X * 0.85, 350), 0, math.min(screenSize.Y * 0.70, 420))
        print("XSAN: Portrait mode detected - using wider UI")
    end
end

local Window = Rayfield:CreateWindow(windowConfig)

print("XSAN: Window created successfully!")

-- Fix scrolling issues and mobile scaling for Rayfield UI
print("XSAN: Applying mobile fixes and scrolling fixes...")
task.spawn(function()
    task.wait(1) -- Wait for UI to fully load
    
    local function fixUIForMobile()
        local rayfieldGui = game.Players.LocalPlayer.PlayerGui:FindFirstChild("RayfieldLibrary") or game.CoreGui:FindFirstChild("RayfieldLibrary")
        if rayfieldGui then
            local main = rayfieldGui:FindFirstChild("Main")
            if main and isMobile then
                -- Mobile scaling adjustments - Much wider untuk feature names
                local isLandscape = screenSize.X > screenSize.Y
                
                if isLandscape then
                    -- Landscape mode - Much wider untuk nama fitur tidak terpotong
                    main.Size = UDim2.new(0, math.min(screenSize.X * 0.60, 500), 0, math.min(screenSize.Y * 0.75, 300))
                else
                    -- Portrait mode - lebih lebar untuk readability
                    main.Size = UDim2.new(0, math.min(screenSize.X * 0.85, 350), 0, math.min(screenSize.Y * 0.70, 420))
                end
                
                main.Position = UDim2.new(0.5, -main.Size.X.Offset/2, 0.5, -main.Size.Y.Offset/2)
                
                -- Adjust text scaling for mobile
                for _, descendant in pairs(rayfieldGui:GetDescendants()) do
                    if descendant:IsA("TextLabel") or descendant:IsA("TextButton") then
                        if descendant.TextScaled == false then
                            descendant.TextScaled = true
                        end
                        -- Ensure minimum readable text size on mobile
                        if descendant.TextSize < 14 and isMobile then
                            descendant.TextSize = 16
                        end
                    end
                end
                
                print("XSAN: Applied mobile UI scaling for", isLandscape and "landscape" or "portrait", "mode")
            end
            
            -- Fix scrolling for all platforms with enhanced touch support
            for _, descendant in pairs(rayfieldGui:GetDescendants()) do
                if descendant:IsA("ScrollingFrame") then
                    -- Enable proper scrolling
                    descendant.ScrollingEnabled = true
                    descendant.ScrollBarThickness = isMobile and 15 or 8
                    descendant.ScrollBarImageColor3 = Color3.fromRGB(100, 100, 100)
                    descendant.ScrollBarImageTransparency = 0.2
                    
                    -- Auto canvas size if supported
                    if descendant:FindFirstChild("UIListLayout") then
                        descendant.AutomaticCanvasSize = Enum.AutomaticSize.Y
                        descendant.CanvasSize = UDim2.new(0, 0, 0, 0)
                    end
                    
                    -- Enable touch scrolling for mobile
                    descendant.Active = true
                    descendant.Selectable = true
                    
                    -- Mobile-specific touch improvements
                    if isMobile then
                        descendant.ScrollingDirection = Enum.ScrollingDirection.Y
                        descendant.ElasticBehavior = Enum.ElasticBehavior.WhenScrollable
                        descendant.ScrollBarImageTransparency = 0.1 -- More visible on mobile
                        
                        -- Force enable touch scrolling
                        local UserInputService = game:GetService("UserInputService")
                        if UserInputService.TouchEnabled then
                            -- Create touch scroll detection
                            local touchStartPos = nil
                            local scrollStartPos = nil
                            
                            descendant.InputBegan:Connect(function(input)
                                if input.UserInputType == Enum.UserInputType.Touch then
                                    touchStartPos = input.Position
                                    scrollStartPos = descendant.CanvasPosition
                                end
                            end)
                            
                            descendant.InputChanged:Connect(function(input)
                                if input.UserInputType == Enum.UserInputType.Touch and touchStartPos then
                                    local delta = input.Position - touchStartPos
                                    local newScrollPos = scrollStartPos - Vector2.new(0, delta.Y * 2) -- 2x scroll speed
                                    descendant.CanvasPosition = newScrollPos
                                end
                            end)
                            
                            descendant.InputEnded:Connect(function(input)
                                if input.UserInputType == Enum.UserInputType.Touch then
                                    touchStartPos = nil
                                    scrollStartPos = nil
                                end
                            end)
                        end
                    end
                    
                    print("XSAN: Fixed scrolling for", descendant.Name, "with touch support")
                end
            end
        end
    end
    
    -- Apply fixes multiple times to ensure they stick
    fixUIForMobile()
    task.wait(2)
    fixUIForMobile()
    
    -- Force refresh UI content
    task.wait(1)
    if Window and Window.Refresh then
        Window:Refresh()
    end
end)

-- Ultimate tabs with all features
print("XSAN: Creating tabs...")
local InfoTab = Window:CreateTab("INFO", "crown")
print("XSAN: InfoTab created")
local PresetsTab = Window:CreateTab("PRESETS", "zap")
print("XSAN: PresetsTab created")
local MainTab = Window:CreateTab("AUTO FISH", "fish") 
print("XSAN: MainTab created")
local TeleportTab = Window:CreateTab("TELEPORT", "map-pin")
print("XSAN: TeleportTab created")
local AnalyticsTab = Window:CreateTab("ANALYTICS", "bar-chart")
print("XSAN: AnalyticsTab created")
local InventoryTab = Window:CreateTab("INVENTORY", "package")
print("XSAN: InventoryTab created")
local UtilityTab = Window:CreateTab("UTILITY", "settings")
print("XSAN: UtilityTab created")

print("XSAN: All tabs created successfully!")

-- ═══════════════════════════════════════════════════════════════
-- FLOATING TOGGLE BUTTON - Hide/Show UI
-- ═══════════════════════════════════════════════════════════════

print("XSAN: Creating floating toggle button...")
task.spawn(function()
    task.wait(1) -- Wait for UI to fully load
    
    local Players = game:GetService("Players")
    local UserInputService = game:GetService("UserInputService")
    local TweenService = game:GetService("TweenService")
    local LocalPlayer = Players.LocalPlayer
    local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
    
    -- Create floating button ScreenGui
    local FloatingButtonGui = Instance.new("ScreenGui")
    FloatingButtonGui.Name = "XSAN_FloatingButton"
    FloatingButtonGui.ResetOnSpawn = false
    FloatingButtonGui.IgnoreGuiInset = true
    FloatingButtonGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    
    -- Try to parent to CoreGui first, then fallback to PlayerGui
    local success = pcall(function()
        FloatingButtonGui.Parent = game.CoreGui
    end)
    if not success then
        FloatingButtonGui.Parent = PlayerGui
    end
    
    -- Create floating button
    local FloatingButton = Instance.new("TextButton")
    FloatingButton.Name = "ToggleButton"
    FloatingButton.Size = UDim2.new(0, isMobile and 70 or 60, 0, isMobile and 70 or 60)
    FloatingButton.Position = UDim2.new(0, 20, 0.5, -35)
    FloatingButton.BackgroundColor3 = Color3.fromRGB(70, 130, 200)
    FloatingButton.BorderSizePixel = 0
    FloatingButton.Text = "🎣"
    FloatingButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    FloatingButton.TextScaled = true
    FloatingButton.Font = Enum.Font.SourceSansBold
    FloatingButton.Parent = FloatingButtonGui
    
    -- Add UICorner for rounded button
    local ButtonCorner = Instance.new("UICorner")
    ButtonCorner.CornerRadius = UDim.new(0.5, 0) -- Perfect circle
    ButtonCorner.Parent = FloatingButton
    
    -- Add UIStroke for better visibility
    local ButtonStroke = Instance.new("UIStroke")
    ButtonStroke.Color = Color3.fromRGB(255, 255, 255)
    ButtonStroke.Thickness = 2
    ButtonStroke.Transparency = 0.3
    ButtonStroke.Parent = FloatingButton
    
    -- Add shadow effect
    local ButtonShadow = Instance.new("Frame")
    ButtonShadow.Name = "Shadow"
    ButtonShadow.Size = UDim2.new(1, 4, 1, 4)
    ButtonShadow.Position = UDim2.new(0, 2, 0, 2)
    ButtonShadow.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    ButtonShadow.BackgroundTransparency = 0.7
    ButtonShadow.BorderSizePixel = 0
    ButtonShadow.ZIndex = FloatingButton.ZIndex - 1
    ButtonShadow.Parent = FloatingButton
    
    local ShadowCorner = Instance.new("UICorner")
    ShadowCorner.CornerRadius = UDim.new(0.5, 0)
    ShadowCorner.Parent = ButtonShadow
    
    -- Variables
    local isUIVisible = true
    local dragging = false
    local dragInput
    local dragStart
    local startPos
    
    -- Get Rayfield GUI reference
    local function getRayfieldGui()
        return LocalPlayer.PlayerGui:FindFirstChild("RayfieldLibrary") or game.CoreGui:FindFirstChild("RayfieldLibrary")
    end
    
    -- Toggle UI visibility function
    local function toggleUI()
        local rayfieldGui = getRayfieldGui()
        if rayfieldGui then
            isUIVisible = not isUIVisible
            
            -- Update button appearance
            if isUIVisible then
                FloatingButton.Text = "🎣"
                FloatingButton.BackgroundColor3 = Color3.fromRGB(70, 130, 200)
                rayfieldGui.Enabled = true
                
                -- Animate show
                rayfieldGui.Main.BackgroundTransparency = 1
                TweenService:Create(rayfieldGui.Main, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
                    BackgroundTransparency = 0
                }):Play()
                
                NotifySuccess("UI Toggle", "XSAN Fish It Pro UI shown!")
            else
                FloatingButton.Text = "👁"
                FloatingButton.BackgroundColor3 = Color3.fromRGB(200, 100, 100)
                
                -- Animate hide
                TweenService:Create(rayfieldGui.Main, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
                    BackgroundTransparency = 1
                }):Play()
                
                task.wait(0.3)
                rayfieldGui.Enabled = false
                NotifyInfo("UI Toggle", "UI hidden! Use floating button to show.")
            end
            
            -- Button feedback animation
            TweenService:Create(FloatingButton, TweenInfo.new(0.1, Enum.EasingStyle.Back), {
                Size = UDim2.new(0, (isMobile and 70 or 60) * 1.1, 0, (isMobile and 70 or 60) * 1.1)
            }):Play()
            
            task.wait(0.1)
            TweenService:Create(FloatingButton, TweenInfo.new(0.2, Enum.EasingStyle.Back), {
                Size = UDim2.new(0, isMobile and 70 or 60, 0, isMobile and 70 or 60)
            }):Play()
        end
    end
    
    -- Make button draggable
    local function updateDrag(input)
        local delta = input.Position - dragStart
        FloatingButton.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
    
    FloatingButton.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = FloatingButton.Position
            
            -- Visual feedback for drag start
            TweenService:Create(FloatingButton, TweenInfo.new(0.1), {
                BackgroundColor3 = Color3.fromRGB(100, 160, 230)
            }):Play()
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                    -- Reset color
                    TweenService:Create(FloatingButton, TweenInfo.new(0.2), {
                        BackgroundColor3 = isUIVisible and Color3.fromRGB(70, 130, 200) or Color3.fromRGB(200, 100, 100)
                    }):Play()
                end
            end)
        end
    end)
    
    FloatingButton.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            updateDrag(input)
        end
    end)
    
    -- Click to toggle (only if not dragging significantly)
    FloatingButton.MouseButton1Click:Connect(function()
        if not dragging then
            toggleUI()
        end
    end)
    
    -- Right click or long press to access menu
    FloatingButton.MouseButton2Click:Connect(function()
        if not dragging then
            -- Create mini context menu
            local ContextMenu = Instance.new("Frame")
            ContextMenu.Name = "ContextMenu"
            ContextMenu.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
            ContextMenu.BorderSizePixel = 0
            ContextMenu.Position = UDim2.new(0, FloatingButton.AbsolutePosition.X + 80, 0, FloatingButton.AbsolutePosition.Y)
            ContextMenu.Size = UDim2.new(0, 120, 0, 0)
            ContextMenu.AutomaticSize = Enum.AutomaticSize.Y
            ContextMenu.ZIndex = 20
            ContextMenu.Parent = FloatingButtonGui
            
            -- Add UICorner
            local MenuCorner = Instance.new("UICorner")
            MenuCorner.CornerRadius = UDim.new(0, 8)
            MenuCorner.Parent = ContextMenu
            
            -- Add UIListLayout
            local MenuLayout = Instance.new("UIListLayout")
            MenuLayout.SortOrder = Enum.SortOrder.LayoutOrder
            MenuLayout.Padding = UDim.new(0, 2)
            MenuLayout.Parent = ContextMenu
            
            -- Add UIPadding
            local MenuPadding = Instance.new("UIPadding")
            MenuPadding.PaddingTop = UDim.new(0, 5)
            MenuPadding.PaddingBottom = UDim.new(0, 5)
            MenuPadding.PaddingLeft = UDim.new(0, 8)
            MenuPadding.PaddingRight = UDim.new(0, 8)
            MenuPadding.Parent = ContextMenu
            
            -- Close Button
            local CloseButton = Instance.new("TextButton")
            CloseButton.BackgroundColor3 = Color3.fromRGB(200, 100, 100)
            CloseButton.BorderSizePixel = 0
            CloseButton.Size = UDim2.new(1, 0, 0, 30)
            CloseButton.Font = Enum.Font.SourceSansBold
            CloseButton.Text = "❌ Close Script"
            CloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
            CloseButton.TextScaled = true
            CloseButton.LayoutOrder = 1
            CloseButton.Parent = ContextMenu
            
            local CloseCorner = Instance.new("UICorner")
            CloseCorner.CornerRadius = UDim.new(0, 5)
            CloseCorner.Parent = CloseButton
            
            CloseButton.MouseButton1Click:Connect(function()
                -- Destroy all XSAN GUIs
                if getRayfieldGui() then
                    getRayfieldGui():Destroy()
                end
                FloatingButtonGui:Destroy()
                NotifyInfo("XSAN", "Script closed. Thanks for using XSAN Fish It Pro!")
            end)
            
            -- Minimize Button
            local MinimizeButton = Instance.new("TextButton")
            MinimizeButton.BackgroundColor3 = Color3.fromRGB(100, 150, 200)
            MinimizeButton.BorderSizePixel = 0
            MinimizeButton.Size = UDim2.new(1, 0, 0, 30)
            MinimizeButton.Font = Enum.Font.SourceSans
            MinimizeButton.Text = "➖ Minimize"
            MinimizeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
            MinimizeButton.TextScaled = true
            MinimizeButton.LayoutOrder = 2
            MinimizeButton.Parent = ContextMenu
            
            local MinimizeCorner = Instance.new("UICorner")
            MinimizeCorner.CornerRadius = UDim.new(0, 5)
            MinimizeCorner.Parent = MinimizeButton
            
            MinimizeButton.MouseButton1Click:Connect(function()
                if isUIVisible then
                    toggleUI()
                end
                ContextMenu:Destroy()
            end)
            
            -- Auto-close menu after 3 seconds
            task.spawn(function()
                task.wait(3)
                if ContextMenu.Parent then
                    ContextMenu:Destroy()
                end
            end)
            
            -- Close menu when clicking outside
            UserInputService.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    local mousePos = UserInputService:GetMouseLocation()
                    local menuPos = ContextMenu.AbsolutePosition
                    local menuSize = ContextMenu.AbsoluteSize
                    
                    if mousePos.X < menuPos.X or mousePos.X > menuPos.X + menuSize.X or
                       mousePos.Y < menuPos.Y or mousePos.Y > menuPos.Y + menuSize.Y then
                        if ContextMenu.Parent then
                            ContextMenu:Destroy()
                        end
                    end
                end
            end)
        end
    end)
    
    -- Hover effects for desktop
    if not isMobile then
        FloatingButton.MouseEnter:Connect(function()
            if not dragging then
                TweenService:Create(FloatingButton, TweenInfo.new(0.2), {
                    Size = UDim2.new(0, 65, 0, 65),
                    BackgroundColor3 = isUIVisible and Color3.fromRGB(90, 150, 220) or Color3.fromRGB(220, 120, 120)
                }):Play()
                TweenService:Create(ButtonStroke, TweenInfo.new(0.2), {
                    Transparency = 0.1
                }):Play()
            end
        end)
        
        FloatingButton.MouseLeave:Connect(function()
            if not dragging then
                TweenService:Create(FloatingButton, TweenInfo.new(0.2), {
                    Size = UDim2.new(0, 60, 0, 60),
                    BackgroundColor3 = isUIVisible and Color3.fromRGB(70, 130, 200) or Color3.fromRGB(200, 100, 100)
                }):Play()
                TweenService:Create(ButtonStroke, TweenInfo.new(0.2), {
                    Transparency = 0.3
                }):Play()
            end
        end)
    end
    
    -- Keyboard shortcut for toggle (H key)
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if not gameProcessed and input.KeyCode == Enum.KeyCode.H then
            toggleUI()
        end
    end)
    
    print("XSAN: Floating toggle button created successfully!")
    print("XSAN: - Click button to hide/show UI")
    print("XSAN: - Drag button to move position")
    print("XSAN: - Press 'H' key to toggle UI")
end)

-- Load Remotes
print("XSAN: Loading remotes...")
local net, rodRemote, miniGameRemote, finishRemote, equipRemote

local function initializeRemotes()
    local success, error = pcall(function()
        net = ReplicatedStorage:WaitForChild("Packages"):WaitForChild("_Index"):WaitForChild("sleitnick_net@0.2.0"):WaitForChild("net")
        print("XSAN: Net found")
        rodRemote = net:WaitForChild("RF/ChargeFishingRod")
        print("XSAN: Rod remote found")
        miniGameRemote = net:WaitForChild("RF/RequestFishingMinigameStarted") 
        print("XSAN: MiniGame remote found")
        finishRemote = net:WaitForChild("RE/FishingCompleted")
        print("XSAN: Finish remote found")
        equipRemote = net:WaitForChild("RE/EquipToolFromHotbar")
        print("XSAN: Equip remote found")
    end)
    
    if not success then
        warn("XSAN: Error loading remotes:", error)
        Notify("XSAN Error", "Failed to load game remotes. Some features may not work.", 5)
        return false
    end
    
    return true
end

local remotesLoaded = initializeRemotes()
print("XSAN: Remotes loading completed! Status:", remotesLoaded)

-- State Variables
print("XSAN: Initializing variables...")
local autofish = false
local perfectCast = false
local safeMode = false  -- Safe Mode for random perfect cast
local safeModeChance = 70  -- 70% chance for perfect cast in safe mode
local hybridMode = false  -- Hybrid Mode for ultimate security
local hybridPerfectChance = 70  -- Hybrid mode perfect cast chance
local hybridMinDelay = 1.0  -- Hybrid mode minimum delay
local hybridMaxDelay = 2.5  -- Hybrid mode maximum delay
local hybridAutoFish = nil  -- Hybrid auto fish instance
local autoRecastDelay = 0.5
local fishCaught = 0
local itemsSold = 0
local autoSellThreshold = 10
local autoSellOnThreshold = false
local sessionStartTime = tick()
local perfectCasts = 0
local normalCasts = 0  -- Track normal casts for analytics
local currentPreset = "None"
local globalAutoSellEnabled = true  -- Global auto sell control

-- Feature states
local featureState = {
    AutoSell = false,
    SmartInventory = false,
    Analytics = true,
    Safety = true,
}

print("XSAN: Variables initialized successfully!")

-- ═══════════════════════════════════════════════════════════════
-- WALKSPEED SYSTEM
-- ═══════════════════════════════════════════════════════════════
local walkspeedEnabled = false
local currentWalkspeed = 16
local defaultWalkspeed = 16

local function setWalkSpeed(speed)
    local success, error = pcall(function()
        local humanoid = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid")
        if humanoid then
            humanoid.WalkSpeed = speed
            currentWalkspeed = speed
            NotifySuccess("Walk Speed", "Walk speed set to " .. speed)
        else
            NotifyError("Walk Speed", "Character or Humanoid not found")
        end
    end)
    
    if not success then
        NotifyError("Walk Speed", "Failed to set walk speed: " .. tostring(error))
    end
end

local function resetWalkSpeed()
    setWalkSpeed(defaultWalkspeed)
    walkspeedEnabled = false
end

-- Auto-restore walkspeed when character spawns
LocalPlayer.CharacterAdded:Connect(function()
    task.wait(1) -- Wait for character to fully load
    if walkspeedEnabled and currentWalkspeed ~= defaultWalkspeed then
        setWalkSpeed(currentWalkspeed)
    end
end)

print("XSAN: Walkspeed system initialized!")

-- XSAN Ultimate Teleportation System
print("XSAN: Initializing teleportation system...")

-- Dynamic Teleportation Data (like old.lua)
local TeleportLocations = {
    Islands = {},
    NPCs = {},
    Events = {}
}

-- Get island locations dynamically from workspace (same as old.lua)
local tpFolder = workspace:FindFirstChild("!!!! ISLAND LOCATIONS !!!!")
if tpFolder then
    for _, island in ipairs(tpFolder:GetChildren()) do
        if island:IsA("BasePart") then
            TeleportLocations.Islands[island.Name] = island.CFrame
            print("XSAN: Found island - " .. island.Name)
        end
    end
else
    -- Fallback to hardcoded coordinates if workspace folder not found
    print("XSAN: Island folder not found, using updated fallback coordinates")
    TeleportLocations.Islands = {
        -- Updated island coordinates from detector
        ["Kohana Volcano"] = CFrame.new(-594.97, 396.65, 149.11),
        ["Crater Island"] = CFrame.new(1010.01, 252.00, 5078.45),
        ["Kohana"] = CFrame.new(-650.97, 208.69, 711.11),
        ["Lost Isle"] = CFrame.new(-3618.16, 240.84, -1317.46),
        ["Stingray Shores"] = CFrame.new(45.28, 252.56, 2987.11),
        ["Esoteric Depths"] = CFrame.new(1944.78, 393.56, 1371.36),
        ["Weather Machine"] = CFrame.new(-1488.51, 83.17, 1876.30),
        ["Tropical Grove"] = CFrame.new(-2095.34, 197.20, 3718.08),
        ["Coral Reefs"] = CFrame.new(-3023.97, 337.81, 2195.61),
        -- Legacy coordinates (backup)
        ["Moosewood"] = CFrame.new(389, 137, 264),
        ["Ocean"] = CFrame.new(1082, 124, -924),
        ["Snowcap Island"] = CFrame.new(2648, 140, 2522),
        ["Mushgrove Swamp"] = CFrame.new(-1817, 138, 1808),
        ["Roslit Bay"] = CFrame.new(-1442, 135, 1006),
        ["Sunstone Island"] = CFrame.new(-934, 135, -1122),
        ["Statue Of Sovereignty"] = CFrame.new(1, 140, -918),
        ["Moonstone Island"] = CFrame.new(-3004, 135, -1157),
        ["Forsaken Shores"] = CFrame.new(-2853, 135, 1627),
        ["Ancient Isle"] = CFrame.new(5896, 137, 4516),
        ["Keepers Altar"] = CFrame.new(1296, 135, -808),
        ["Brine Pool"] = CFrame.new(-1804, 135, 3265),
        ["The Depths"] = CFrame.new(994, -715, 1226),
        ["Vertigo"] = CFrame.new(-111, -515, 1049),
        ["Volcano"] = CFrame.new(-1888, 164, 330)
    }
end

-- NPCs and Events (keeping some hardcoded for important locations)
TeleportLocations.NPCs = {
    ["🛒 Shop (Alex)"] = CFrame.new(-28.43, 4.50, 2891.28),
    ["🛒 Shop (Joe)"] = CFrame.new(112.01, 4.75, 2877.32),
    ["🛒 Shop (Seth)"] = CFrame.new(72.02, 4.58, 2885.28),
    ["🎣 Rod Shop (Marc)"] = CFrame.new(454, 150, 229),
    ["⚓ Shipwright"] = CFrame.new(343, 135, 271),
    ["📦 Storage (Henry)"] = CFrame.new(491, 150, 272),
    ["🏆 Angler"] = CFrame.new(484, 150, 331)
}

TeleportLocations.Events = {
    ["🌟 Isonade Event"] = CFrame.new(-1442, 135, 1006),
    ["🦈 Great White Event"] = CFrame.new(1082, 124, -924),
    ["❄️ Whale Event"] = CFrame.new(2648, 140, 2522),
    ["🔥 Volcano Event"] = CFrame.new(-1888, 164, 330)
}

-- Safe Teleportation Function
local function SafeTeleport(targetCFrame, locationName)
    pcall(function()
        if not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            NotifyError("Teleport", "Character not found! Cannot teleport.")
            return
        end
        
        local humanoidRootPart = LocalPlayer.Character.HumanoidRootPart
        
        -- Smooth teleportation with fade effect
        local originalCFrame = humanoidRootPart.CFrame
        
        -- Teleport with slight offset to avoid collision
        local safePosition = targetCFrame.Position + Vector3.new(0, 5, 0)
        humanoidRootPart.CFrame = CFrame.new(safePosition) * CFrame.Angles(0, math.rad(math.random(-180, 180)), 0)
        
        wait(0.1)
        
        -- Lower to ground
        humanoidRootPart.CFrame = targetCFrame
        
        NotifySuccess("Teleport", "Successfully teleported to: " .. locationName)
        
        -- Log teleportation for analytics
        print("XSAN Teleport: " .. LocalPlayer.Name .. " -> " .. locationName)
    end)
end

-- Player Teleportation Function (improved like old.lua)
local function TeleportToPlayer(targetPlayerName)
    pcall(function()
        -- Try to find in workspace Characters folder first (like old.lua)
        local charFolder = workspace:FindFirstChild("Characters")
        local targetCharacter = nil
        
        if charFolder then
            targetCharacter = charFolder:FindFirstChild(targetPlayerName)
        end
        
        -- Fallback to Players service
        if not targetCharacter then
            local targetPlayer = game.Players:FindFirstChild(targetPlayerName)
            if targetPlayer then
                targetCharacter = targetPlayer.Character
            end
        end
        
        if not targetCharacter then
            NotifyError("Player TP", "Player '" .. targetPlayerName .. "' not found!")
            return
        end
        
        local targetHRP = targetCharacter:FindFirstChild("HumanoidRootPart")
        if not targetHRP then
            NotifyError("Player TP", "Target player's character not found!")
            return
        end
        
        SafeTeleport(targetHRP.CFrame, targetPlayerName .. "'s location")
    end)
end

print("XSAN: Teleportation system initialized successfully!")

-- Count islands and print debug info
local islandCount = 0
for _ in pairs(TeleportLocations.Islands) do
    islandCount = islandCount + 1
end

print("XSAN: Found " .. islandCount .. " islands for teleportation")
print("XSAN: Using dynamic location system like old.lua for accuracy")

-- Notification Functions
local function NotifySuccess(title, message)
	Notify("XSAN - " .. title, message, 3)
end

local function NotifyError(title, message)
	Notify("XSAN ERROR - " .. title, message, 4)
end

local function NotifyInfo(title, message)
	Notify("XSAN INFO - " .. title, message, 3)
end

-- Analytics Functions
local function CalculateFishPerHour()
    local timeElapsed = (tick() - sessionStartTime) / 3600
    if timeElapsed > 0 then
        return math.floor(fishCaught / timeElapsed)
    end
    return 0
end

local function CalculateProfit()
    local avgFishValue = 50
    return fishCaught * avgFishValue
end

-- Quick Start Presets
local function ApplyPreset(presetName)
    currentPreset = presetName
    
    if presetName == "Beginner" then
        autoRecastDelay = 2.0
        perfectCast = false
        safeMode = false
        autoSellThreshold = 5
        autoSellOnThreshold = globalAutoSellEnabled  -- Use global setting
        NotifySuccess("Preset Applied", "Beginner mode activated - Safe and easy settings" .. (globalAutoSellEnabled and " (Auto Sell: ON)" or " (Auto Sell: OFF)"))
        
    elseif presetName == "Speed" then
        autoRecastDelay = 0.5
        perfectCast = true
        safeMode = false
        autoSellThreshold = 20
        autoSellOnThreshold = globalAutoSellEnabled  -- Use global setting
        NotifySuccess("Preset Applied", "Speed mode activated - Maximum fishing speed" .. (globalAutoSellEnabled and " (Auto Sell: ON)" or " (Auto Sell: OFF)"))
        
    elseif presetName == "Profit" then
        autoRecastDelay = 1.0
        perfectCast = true
        safeMode = false
        autoSellThreshold = 15
        autoSellOnThreshold = globalAutoSellEnabled  -- Use global setting
        NotifySuccess("Preset Applied", "Profit mode activated - Optimized for maximum earnings" .. (globalAutoSellEnabled and " (Auto Sell: ON)" or " (Auto Sell: OFF)"))
        
    elseif presetName == "AFK" then
        autoRecastDelay = 1.5
        perfectCast = true
        safeMode = false
        autoSellThreshold = 25
        autoSellOnThreshold = globalAutoSellEnabled  -- Use global setting
        NotifySuccess("Preset Applied", "AFK mode activated - Safe for long sessions" .. (globalAutoSellEnabled and " (Auto Sell: ON)" or " (Auto Sell: OFF)"))
        
    elseif presetName == "Safe" then
        autoRecastDelay = 1.2
        perfectCast = false
        safeMode = true
        safeModeChance = 70
        autoSellThreshold = 18
        autoSellOnThreshold = globalAutoSellEnabled
        NotifySuccess("Preset Applied", "Safe mode activated - Smart random casting (70% perfect, 30% normal)" .. (globalAutoSellEnabled and " (Auto Sell: ON)" or " (Auto Sell: OFF)"))
        
    elseif presetName == "Hybrid" then
        autoRecastDelay = 1.5
        perfectCast = false
        safeMode = false
        hybridMode = true
        hybridPerfectChance = 75
        hybridMinDelay = 1.0
        hybridMaxDelay = 2.8
        autoSellThreshold = 20
        autoSellOnThreshold = globalAutoSellEnabled
        NotifySuccess("Preset Applied", "🔒 HYBRID ULTIMATE MODE ACTIVATED!\n✅ Server Time Sync\n✅ Human-like AI Patterns\n✅ Anti-Detection Technology\n✅ Maximum Security" .. (globalAutoSellEnabled and "\n💰 Auto Sell: ON" or "\n💰 Auto Sell: OFF"))
        
    elseif presetName == "AutoSellOn" then
        globalAutoSellEnabled = true
        autoSellOnThreshold = true
        NotifySuccess("Auto Sell", "Global Auto Sell activated - Will apply to all future presets at " .. autoSellThreshold .. " fish")
        
    elseif presetName == "AutoSellOff" then
        globalAutoSellEnabled = false
        autoSellOnThreshold = false
        NotifySuccess("Auto Sell", "Global Auto Sell deactivated - Manual selling only for all presets")
    end
end

-- Auto Sell Function
local function CheckAndAutoSell()
    if autoSellOnThreshold and fishCaught >= autoSellThreshold then
        pcall(function()
            if not (LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")) then return end

            local npcContainer = ReplicatedStorage:FindFirstChild("NPC")
            local alexNpc = npcContainer and npcContainer:FindFirstChild("Alex")

            if not alexNpc then
                NotifyError("Auto Sell", "NPC 'Alex' not found! Cannot auto sell.")
                return
            end

            local originalCFrame = LocalPlayer.Character.HumanoidRootPart.CFrame
            local npcPosition = alexNpc.WorldPivot.Position

            LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(npcPosition)
            wait(1)

            ReplicatedStorage.Packages._Index["sleitnick_net@0.2.0"].net["RF/SellAllItems"]:InvokeServer()
            wait(1)

            LocalPlayer.Character.HumanoidRootPart.CFrame = originalCFrame
            itemsSold = itemsSold + 1
            fishCaught = 0
            
            NotifySuccess("Auto Sell", "Automatically sold items! Fish count: " .. autoSellThreshold .. " reached.")
        end)
    end
end

-- ═══════════════════════════════════════════════════════════════
-- INFO TAB - XSAN Branding Section
-- ═══════════════════════════════════════════════════════════════

print("XSAN: Creating INFO tab content...")
InfoTab:CreateParagraph({
    Title = "XSAN Fish It Pro Ultimate v1.0",
    Content = "The most advanced Fish It script ever created with AI-powered features, smart analytics, and premium automation systems.\n\nCreated by XSAN - Trusted by thousands of users worldwide!"
})

InfoTab:CreateParagraph({
    Title = "Ultimate Features",
    Content = "Quick Start Presets • Advanced Analytics • Smart Inventory Management • AI Fishing Assistant • Enhanced Safety Systems • Premium Automation • Quality of Life Features • Walk Speed Control • And Much More!"
})

InfoTab:CreateParagraph({
    Title = "Follow XSAN",
    Content = "Stay updated with the latest scripts and features!\n\nInstagram: @_bangicoo\nGitHub: github.com/codeico\n\nYour support helps us create better tools!"
})

InfoTab:CreateButton({ 
    Name = "Copy Instagram Link", 
    Callback = CreateSafeCallback(function() 
        if setclipboard then
            setclipboard("https://instagram.com/_bangicoo") 
            NotifySuccess("Social Media", "Instagram link copied! Follow for updates and support!")
        else
            NotifyInfo("Social Media", "Instagram: @_bangicoo")
        end
    end, "instagram")
})

InfoTab:CreateButton({ 
    Name = "Copy GitHub Link", 
    Callback = CreateSafeCallback(function() 
        if setclipboard then
            setclipboard("https://github.com/codeico") 
            NotifySuccess("Social Media", "GitHub link copied! Check out more premium scripts!")
        else
            NotifyInfo("Social Media", "GitHub: github.com/codeico")
        end
    end, "github")
})

InfoTab:CreateButton({ 
    Name = "Fix UI Scrolling", 
    Callback = CreateSafeCallback(function() 
        local function fixScrollingFrames()
            local rayfieldGui = game.Players.LocalPlayer.PlayerGui:FindFirstChild("RayfieldLibrary") or game.CoreGui:FindFirstChild("RayfieldLibrary")
            if rayfieldGui then
                local fixed = 0
                for _, descendant in pairs(rayfieldGui:GetDescendants()) do
                    if descendant:IsA("ScrollingFrame") then
                        -- Enable proper scrolling
                        descendant.ScrollingEnabled = true
                        descendant.ScrollBarThickness = 8
                        descendant.ScrollBarImageColor3 = Color3.fromRGB(80, 80, 80)
                        descendant.ScrollBarImageTransparency = 0.3
                        
                        -- Auto canvas size if supported
                        if descendant:FindFirstChild("UIListLayout") then
                            descendant.AutomaticCanvasSize = Enum.AutomaticSize.Y
                            descendant.CanvasSize = UDim2.new(0, 0, 0, 0)
                        end
                        
                        -- Enable mouse wheel scrolling
                        descendant.Active = true
                        descendant.Selectable = true
                        
                        fixed = fixed + 1
                    end
                end
                NotifySuccess("UI Fix", "Fixed scrolling for " .. fixed .. " elements. You can now scroll through tabs!")
            else
                NotifyError("UI Fix", "Rayfield GUI not found")
            end
        end
        
        fixScrollingFrames()
    end, "fix_scrolling")
})

print("XSAN: INFO tab completed successfully!")

-- ═══════════════════════════════════════════════════════════════
-- PRESETS TAB - Quick Start Configurations
-- ═══════════════════════════════════════════════════════════════

print("XSAN: Creating PRESETS tab content...")
PresetsTab:CreateParagraph({
    Title = "XSAN Quick Start Presets",
    Content = "Instantly configure the script with optimal settings for different use cases. Perfect for beginners or quick setup!"
})

PresetsTab:CreateButton({
    Name = "Beginner Mode",
    Callback = CreateSafeCallback(function()
        ApplyPreset("Beginner")
    end, "preset_beginner")
})

PresetsTab:CreateButton({
    Name = "Speed Mode",
    Callback = CreateSafeCallback(function()
        ApplyPreset("Speed")
    end, "preset_speed")
})

PresetsTab:CreateButton({
    Name = "Profit Mode", 
    Callback = CreateSafeCallback(function()
        ApplyPreset("Profit")
    end, "preset_profit")
})

PresetsTab:CreateButton({
    Name = "AFK Mode",
    Callback = CreateSafeCallback(function()
        ApplyPreset("AFK") 
    end, "preset_afk")
})

PresetsTab:CreateButton({
    Name = "🛡️ Safe Mode",
    Callback = CreateSafeCallback(function()
        ApplyPreset("Safe") 
    end, "preset_safe")
})

PresetsTab:CreateButton({
    Name = "🔒 HYBRID MODE (Ultimate)",
    Callback = CreateSafeCallback(function()
        ApplyPreset("Hybrid") 
    end, "preset_hybrid")
})

PresetsTab:CreateParagraph({
    Title = "Auto Sell Global Controls",
    Content = "Global auto sell control - When you set Auto Sell ON/OFF, it will apply to ALL preset modes. This gives you master control over auto selling."
})

PresetsTab:CreateButton({
    Name = "🟢 Global Auto Sell ON",
    Callback = CreateSafeCallback(function()
        ApplyPreset("AutoSellOn")
    end, "preset_autosell_on")
})

PresetsTab:CreateButton({
    Name = "🔴 Global Auto Sell OFF",
    Callback = CreateSafeCallback(function()
        ApplyPreset("AutoSellOff")
    end, "preset_autosell_off")
})

print("XSAN: PRESETS tab completed successfully!")

-- ═══════════════════════════════════════════════════════════════
-- TELEPORT TAB - Ultimate Teleportation System
-- ═══════════════════════════════════════════════════════════════

print("XSAN: Creating TELEPORT tab content...")
TeleportTab:CreateParagraph({
    Title = "XSAN Ultimate Teleport System",
    Content = "Instant teleportation to any location with smart safety features. The most advanced teleportation system for Fish It!"
})

-- Islands Section
TeleportTab:CreateParagraph({
    Title = "🏝️ Island Teleportation",
    Content = "Quick access to all fishing locations and islands. Perfect for exploring and finding the best fishing spots!"
})

-- Create buttons for each island (dynamic like old.lua)
for locationName, cframe in pairs(TeleportLocations.Islands) do
    -- Add emoji prefix if not already present with more specific icons
    local displayName = locationName
    if not string.find(locationName, "🏝️") and not string.find(locationName, "🌊") and not string.find(locationName, "🏔️") and not string.find(locationName, "🌋") and not string.find(locationName, "❄️") and not string.find(locationName, "🏛️") then
        -- Add specific icons based on location names
        if string.find(locationName:lower(), "volcano") or string.find(locationName:lower(), "crater") then
            displayName = "� " .. locationName
        elseif string.find(locationName:lower(), "snow") or string.find(locationName:lower(), "ice") then
            displayName = locationName
        elseif string.find(locationName:lower(), "depth") or string.find(locationName:lower(), "ocean") then
            displayName = locationName
        elseif string.find(locationName:lower(), "ancient") or string.find(locationName:lower(), "statue") or string.find(locationName:lower(), "altar") then
            displayName = locationName
        elseif string.find(locationName:lower(), "mountain") or string.find(locationName:lower(), "peak") then
            displayName = locationName
        elseif string.find(locationName:lower(), "swamp") or string.find(locationName:lower(), "grove") then
            displayName = locationName
        elseif string.find(locationName:lower(), "reef") or string.find(locationName:lower(), "coral") then
            displayName = locationName
        else
            displayName = "�🏝️ " .. locationName
        end
    end
    
    TeleportTab:CreateButton({
        Name = displayName,
        Callback = CreateSafeCallback(function()
            SafeTeleport(cframe, locationName)
        end, "tp_island_" .. locationName)
    })
end

-- NPCs Section
TeleportTab:CreateParagraph({
    Title = "🛒 NPC Teleportation",
    Content = "Instantly teleport to important NPCs for trading, upgrades, and services. Save time with quick access!"
})

-- Create buttons for each NPC
for npcName, cframe in pairs(TeleportLocations.NPCs) do
    TeleportTab:CreateButton({
        Name = npcName,
        Callback = CreateSafeCallback(function()
            SafeTeleport(cframe, npcName)
        end, "tp_npc_" .. npcName)
    })
end

-- Events Section
TeleportTab:CreateParagraph({
    Title = "🌟 Event Teleportation",
    Content = "Quick access to event locations and special fishing spots. Never miss an event again!"
})

-- Create buttons for each event location
for eventName, cframe in pairs(TeleportLocations.Events) do
    TeleportTab:CreateButton({
        Name = eventName,
        Callback = CreateSafeCallback(function()
            SafeTeleport(cframe, eventName)
        end, "tp_event_" .. eventName)
    })
end

-- Player Teleportation Section
TeleportTab:CreateParagraph({
    Title = "👥 Player Teleportation",
    Content = "Teleport to other players in the server. Great for meeting friends or following experienced fishers!"
})

TeleportTab:CreateButton({
    Name = "🔄 Refresh Player List",
    Callback = CreateSafeCallback(function()
        local playerCount = 0
        local playerList = ""
        
        -- Check Characters folder first (like old.lua)
        local charFolder = workspace:FindFirstChild("Characters")
        if charFolder then
            for _, playerModel in pairs(charFolder:GetChildren()) do
                if playerModel:IsA("Model") and playerModel.Name ~= LocalPlayer.Name and playerModel:FindFirstChild("HumanoidRootPart") then
                    playerCount = playerCount + 1
                    playerList = playerList .. "👤 " .. playerModel.Name .. " • "
                end
            end
        end
        
        -- Fallback to Players service
        if playerCount == 0 then
            for _, player in pairs(game.Players:GetPlayers()) do
                if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                    playerCount = playerCount + 1
                    playerList = playerList .. "👤 " .. player.Name .. " • "
                end
            end
        end
        
        if playerCount > 0 then
            NotifyInfo("Player List", "Players in server (" .. playerCount .. "):\n\n" .. playerList:sub(1, -3) .. "\n\n✅ Fixed teleportation system - Now using accurate locations!")
        else
            NotifyInfo("Player List", "❌ No other players found in the server!")
        end
    end, "refresh_players")
})

-- Create dropdown/buttons for players
local playerDropdown
spawn(function()
    while true do
        wait(5) -- Update every 5 seconds
        pcall(function()
            if TeleportTab then
                local players = {}
                for _, player in pairs(game.Players:GetPlayers()) do
                    if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                        table.insert(players, player.Name)
                    end
                end
                
                if #players > 0 then
                    -- Update player list (if dropdown exists, recreate it)
                    -- For now, we'll use buttons since Rayfield dropdown might not support dynamic updates
                end
            end
        end)
    end
end)

-- Manual Player Teleport
local targetPlayerName = ""

TeleportTab:CreateInput({
    Name = "📝 Enter Player Name",
    PlaceholderText = "Type player name here...",
    RemoveTextAfterFocusLost = false,
    Callback = function(text)
        targetPlayerName = text
    end
})

TeleportTab:CreateButton({
    Name = "🎯 Teleport to Player",
    Callback = CreateSafeCallback(function()
        if targetPlayerName and targetPlayerName ~= "" then
            TeleportToPlayer(targetPlayerName)
        else
            NotifyError("Player TP", "Please enter a player name first!")
        end
    end, "tp_to_player")
})

-- Utility Teleportation
TeleportTab:CreateParagraph({
    Title = "🔧 Teleport Utilities",
    Content = "Additional teleportation features and safety options."
})

TeleportTab:CreateButton({
    Name = "📍 Save Current Position",
    Callback = CreateSafeCallback(function()
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            _G.XSANSavedPosition = LocalPlayer.Character.HumanoidRootPart.CFrame
            NotifySuccess("Position Saved", "📍 Current position saved! Use 'Return to Saved Position' to come back here.")
        else
            NotifyError("Save Position", "❌ Character not found!")
        end
    end, "save_position")
})

TeleportTab:CreateButton({
    Name = "🔙 Return to Saved Position",
    Callback = CreateSafeCallback(function()
        if _G.XSANSavedPosition then
            SafeTeleport(_G.XSANSavedPosition, "Saved Position")
        else
            NotifyError("Return Position", "❌ No saved position found! Save a position first.")
        end
    end, "return_position")
})

TeleportTab:CreateButton({
    Name = "🏠 Teleport to Spawn",
    Callback = CreateSafeCallback(function()
        -- Try to use dynamic location first
        local spawnCFrame = TeleportLocations.Islands["Moosewood"] or CFrame.new(389, 137, 264)
        SafeTeleport(spawnCFrame, "Moosewood Spawn")
    end, "tp_spawn")
})

print("XSAN: TELEPORT tab completed successfully!")

-- ═══════════════════════════════════════════════════════════════
-- AUTO FISH TAB - Enhanced Fishing System
-- ═══════════════════════════════════════════════════════════════

print("XSAN: Creating AUTO FISH tab content...")
MainTab:CreateParagraph({
    Title = "XSAN Ultimate Auto Fish System",
    Content = "Advanced auto fishing with AI assistance, smart detection, and premium features for the ultimate fishing experience."
})

MainTab:CreateToggle({
    Name = "Enable Auto Fishing",
    CurrentValue = false,
    Callback = CreateSafeCallback(function(val)
        autofish = val
        if val then
            if hybridMode then
                -- Initialize hybrid auto fish
                if not hybridAutoFish then
                    hybridAutoFish = Rayfield.CreateSafeAutoFish({
                        safeMode = true,
                        perfectChance = hybridPerfectChance,
                        minDelay = hybridMinDelay,
                        maxDelay = hybridMaxDelay,
                        useServerTime = true
                    })
                end
                hybridAutoFish.toggle(true)
                NotifySuccess("Hybrid Auto Fish", "HYBRID SECURITY MODE ACTIVATED!\n🔒 Maximum Safety\n⚡ Server Time Sync\n🎯 Human-like Patterns")
            else
                -- Traditional auto fishing
                NotifySuccess("Auto Fish", "XSAN Ultimate auto fishing started! AI systems activated.")
                spawn(function()
                    while autofish do
                        pcall(function()
                            if equipRemote then equipRemote:FireServer(1) end
                            wait(0.1)

                            -- Safe Mode Logic: Random between perfect and normal cast
                            local usePerfectCast = perfectCast
                            if safeMode then
                                usePerfectCast = math.random(1, 100) <= safeModeChance
                            end

                            local timestamp = usePerfectCast and 9999999999 or (tick() + math.random())
                            if rodRemote then rodRemote:InvokeServer(timestamp) end
                            wait(0.1)

                            local x = usePerfectCast and -1.238 or (math.random(-1000, 1000) / 1000)
                            local y = usePerfectCast and 0.969 or (math.random(0, 1000) / 1000)

                            if miniGameRemote then miniGameRemote:InvokeServer(x, y) end
                            wait(1.3)
                            if finishRemote then finishRemote:FireServer() end
                            
                            fishCaught = fishCaught + 1
                            
                            -- Track cast types for analytics
                            if usePerfectCast then
                                perfectCasts = perfectCasts + 1
                            else
                                normalCasts = normalCasts + 1
                            end
                            
                            CheckAndAutoSell()
                        end)
                        wait(autoRecastDelay)
                    end
                end)
            end
        else
            if hybridMode and hybridAutoFish then
                hybridAutoFish.toggle(false)
                NotifyInfo("Hybrid Auto Fish", "Hybrid auto fishing stopped by user.")
            else
                NotifyInfo("Auto Fish", "Auto fishing stopped by user.")
            end
        end
    end, "autofish")
})

MainTab:CreateToggle({
    Name = "Perfect Cast Mode",
    CurrentValue = false,
    Callback = CreateSafeCallback(function(val)
        perfectCast = val
        if val then
            safeMode = false  -- Disable safe mode when perfect cast is manually enabled
            hybridMode = false  -- Disable hybrid mode
        end
        NotifySuccess("Perfect Cast", "Perfect cast mode " .. (val and "activated" or "deactivated") .. "!")
    end, "perfectcast")
})

MainTab:CreateToggle({
    Name = "🛡️ Safe Mode (Smart Random)",
    CurrentValue = false,
    Callback = CreateSafeCallback(function(val)
        safeMode = val
        if val then
            perfectCast = false  -- Disable perfect cast when safe mode is enabled
            hybridMode = false   -- Disable hybrid mode
            NotifySuccess("Safe Mode", "Safe mode activated - Smart random casting for better stealth!")
        else
            NotifyInfo("Safe Mode", "Safe mode deactivated - Manual control restored")
        end
    end, "safemode")
})

MainTab:CreateToggle({
    Name = "🔒 HYBRID MODE (Ultimate Security)",
    CurrentValue = false,
    Callback = CreateSafeCallback(function(val)
        hybridMode = val
        if val then
            perfectCast = false  -- Disable other modes
            safeMode = false
            NotifySuccess("Hybrid Mode", "HYBRID SECURITY ACTIVATED!\n✅ Server Time Sync\n✅ Human-like Patterns\n✅ Anti-Detection\n✅ Maximum Safety")
        else
            NotifyInfo("Hybrid Mode", "Hybrid mode deactivated - Back to manual control")
        end
    end, "hybridmode")
})

MainTab:CreateSlider({
    Name = "Safe Mode Perfect %",
    Range = {50, 85},
    Increment = 5,
    CurrentValue = safeModeChance,
    Callback = function(val)
        safeModeChance = val
        if safeMode then
            NotifyInfo("Safe Mode", "Perfect cast chance set to: " .. val .. "%")
        end
    end
})

MainTab:CreateSlider({
    Name = "Hybrid Perfect %",
    Range = {60, 80},
    Increment = 5,
    CurrentValue = 70,
    Callback = function(val)
        hybridPerfectChance = val
        if hybridMode and hybridAutoFish then
            hybridAutoFish.updateConfig({perfectChance = val})
            NotifyInfo("Hybrid Mode", "Perfect cast chance updated to: " .. val .. "%")
        end
    end
})

MainTab:CreateSlider({
    Name = "Hybrid Min Delay",
    Range = {1.0, 2.0},
    Increment = 0.1,
    CurrentValue = 1.0,
    Callback = function(val)
        hybridMinDelay = val
        if hybridMode and hybridAutoFish then
            hybridAutoFish.updateConfig({minDelay = val})
            NotifyInfo("Hybrid Mode", "Minimum delay updated to: " .. val .. "s")
        end
    end
})

MainTab:CreateSlider({
    Name = "Hybrid Max Delay", 
    Range = {2.0, 3.5},
    Increment = 0.1,
    CurrentValue = 2.5,
    Callback = function(val)
        hybridMaxDelay = val
        if hybridMode and hybridAutoFish then
            hybridAutoFish.updateConfig({maxDelay = val})
            NotifyInfo("Hybrid Mode", "Maximum delay updated to: " .. val .. "s")
        end
    end
})

MainTab:CreateSlider({
    Name = "Auto Recast Delay",
    Range = {0.5, 3.0},
    Increment = 0.1,
    CurrentValue = autoRecastDelay,
    Callback = function(val)
        autoRecastDelay = val
    end
})

MainTab:CreateToggle({
    Name = "Auto Sell on Fish Count",
    CurrentValue = false,
    Callback = CreateSafeCallback(function(val)
        autoSellOnThreshold = val
        if val then
            NotifySuccess("Auto Sell Threshold", "Auto sell on threshold activated! Will sell when " .. autoSellThreshold .. " fish caught.")
        else
            NotifyInfo("Auto Sell Threshold", "Auto sell on threshold disabled.")
        end
    end, "autosell_threshold")
})

MainTab:CreateSlider({
    Name = "Fish Threshold",
    Range = {5, 50},
    Increment = 1,
    CurrentValue = autoSellThreshold,
    Callback = function(val)
        autoSellThreshold = val
        if autoSellOnThreshold then
            NotifyInfo("Threshold Updated", "Auto sell threshold set to: " .. val .. " fish")
        end
    end
})

print("XSAN: AUTO FISH tab completed successfully!")

-- ═══════════════════════════════════════════════════════════════
-- ANALYTICS TAB - Advanced Statistics & Monitoring
-- ═══════════════════════════════════════════════════════════════

print("XSAN: Creating ANALYTICS tab content...")
AnalyticsTab:CreateParagraph({
    Title = "XSAN Advanced Analytics",
    Content = "Real-time monitoring, performance tracking, and intelligent insights for optimal fishing performance."
})

AnalyticsTab:CreateButton({
    Name = "Show Detailed Statistics",
    Callback = CreateSafeCallback(function()
        local sessionTime = (tick() - sessionStartTime) / 60
        local fishPerHour = CalculateFishPerHour()
        local estimatedProfit = CalculateProfit()
        local totalCasts = perfectCasts + normalCasts
        local perfectEfficiency = totalCasts > 0 and (perfectCasts / totalCasts * 100) or 0
        local castingMode = safeMode and "Safe Mode" or (perfectCast and "Perfect Cast" or "Normal Cast")
        
        local stats = string.format("XSAN Ultimate Analytics:\n\nSession Time: %.1f minutes\nFish Caught: %d\nFish/Hour: %d\n\n=== CASTING STATS ===\nMode: %s\nPerfect Casts: %d (%.1f%%)\nNormal Casts: %d\nTotal Casts: %d\n\n=== EARNINGS ===\nItems Sold: %d\nEstimated Profit: %d coins\nActive Preset: %s", 
            sessionTime, fishCaught, fishPerHour, castingMode, perfectCasts, perfectEfficiency, normalCasts, totalCasts, itemsSold, estimatedProfit, currentPreset
        )
        NotifyInfo("Advanced Stats", stats)
    end, "detailed_stats")
})

AnalyticsTab:CreateButton({
    Name = "Reset Statistics",
    Callback = CreateSafeCallback(function()
        sessionStartTime = tick()
        fishCaught = 0
        itemsSold = 0
        perfectCasts = 0
        normalCasts = 0
        NotifySuccess("Analytics", "All statistics have been reset!")
    end, "reset_stats")
})

print("XSAN: ANALYTICS tab completed successfully!")

-- ═══════════════════════════════════════════════════════════════
-- INVENTORY TAB - Smart Inventory Management
-- ═══════════════════════════════════════════════════════════════

print("XSAN: Creating INVENTORY tab content...")
InventoryTab:CreateParagraph({
    Title = "XSAN Smart Inventory Manager",
    Content = "Intelligent inventory management with auto-drop, space monitoring, and priority item protection."
})

InventoryTab:CreateButton({
    Name = "Check Inventory Status",
    Callback = CreateSafeCallback(function()
        local backpack = LocalPlayer:FindFirstChild("Backpack")
        if backpack then
            local items = #backpack:GetChildren()
            local itemNames = {}
            for _, item in pairs(backpack:GetChildren()) do
                table.insert(itemNames, item.Name)
            end
            
            local status = string.format("Inventory Status:\n\nTotal Items: %d/20\nSpace Available: %d slots\n\nItems: %s", 
                items, 20 - items, table.concat(itemNames, ", "))
            NotifyInfo("Inventory", status)
        else
            NotifyError("Inventory", "Could not access backpack!")
        end
    end, "check_inventory")
})

print("XSAN: INVENTORY tab completed successfully!")

-- ═══════════════════════════════════════════════════════════════
-- UTILITY TAB - System Management & Advanced Features
-- ═══════════════════════════════════════════════════════════════

print("XSAN: Creating UTILITY tab content...")
UtilityTab:CreateParagraph({
    Title = "XSAN Ultimate Utility System",
    Content = "Advanced system management, quality of life features, and premium utilities."
})

UtilityTab:CreateButton({
    Name = "Show Ultimate Session Stats",
    Callback = CreateSafeCallback(function()
        local sessionTime = (tick() - sessionStartTime) / 60
        local fishPerHour = CalculateFishPerHour()
        local estimatedProfit = CalculateProfit()
        local efficiency = fishCaught > 0 and (perfectCasts / fishCaught * 100) or 0
        local thresholdStatus = autoSellOnThreshold and ("Active (" .. autoSellThreshold .. " fish)") or "Inactive"
        
        local ultimateStats = string.format("XSAN ULTIMATE SESSION REPORT:\n\n=== PERFORMANCE ===\nSession Time: %.1f minutes\nFish Caught: %d\nFish/Hour Rate: %d\nPerfect Casts: %d (%.1f%%)\n\n=== EARNINGS ===\nItems Sold: %d\nEstimated Profit: %d coins\n\n=== AUTOMATION ===\nAuto Fish: %s\nThreshold Auto Sell: %s\nActive Preset: %s", 
            sessionTime, fishCaught, fishPerHour, perfectCasts, efficiency,
            itemsSold, estimatedProfit,
            autofish and "Active" or "Inactive",
            thresholdStatus, currentPreset
        )
        NotifyInfo("Ultimate Stats", ultimateStats)
    end, "ultimate_stats")
})

UtilityTab:CreateParagraph({
    Title = "🎯 Performance & Settings",
    Content = "Advanced script performance controls and system management options."
})

-- ═══════════════════════════════════════════════════════════════
-- WALKSPEED CONTROLS
-- ═══════════════════════════════════════════════════════════════

UtilityTab:CreateParagraph({
    Title = "🏃 Walk Speed System",
    Content = "Control your character's movement speed with XSAN walkspeed system."
})

UtilityTab:CreateSlider({
    Name = "Walk Speed",
    Range = {16, 60},
    Increment = 1,
    CurrentValue = defaultWalkspeed,
    Flag = "WalkSpeedSlider",
    Callback = CreateSafeCallback(function(value)
        currentWalkspeed = value
        if walkspeedEnabled then
            setWalkSpeed(value)
        else
            NotifyInfo("Walk Speed", "Walk speed set to " .. value .. ". Enable to apply.")
        end
    end, "walkspeed_slider")
})

UtilityTab:CreateToggle({
    Name = "Enable Walk Speed",
    CurrentValue = walkspeedEnabled,
    Flag = "WalkSpeedToggle",
    Callback = CreateSafeCallback(function(value)
        walkspeedEnabled = value
        if value then
            setWalkSpeed(currentWalkspeed)
            NotifySuccess("Walk Speed", "Walk speed enabled: " .. currentWalkspeed)
        else
            resetWalkSpeed()
            NotifyInfo("Walk Speed", "Walk speed disabled (reset to default)")
        end
    end, "walkspeed_toggle")
})

UtilityTab:CreateButton({
    Name = "Quick Speed: 45",
    Callback = CreateSafeCallback(function()
        currentWalkspeed = 45
        if walkspeedEnabled then
            setWalkSpeed(45)
        else
            walkspeedEnabled = true
            setWalkSpeed(45)
        end
        -- Update the slider and toggle if they exist
        if Rayfield.Flags["WalkSpeedSlider"] then
            Rayfield.Flags["WalkSpeedSlider"]:Set(45)
        end
        if Rayfield.Flags["WalkSpeedToggle"] then
            Rayfield.Flags["WalkSpeedToggle"]:Set(true)
        end
    end, "quick_speed_45")
})

UtilityTab:CreateButton({
    Name = "Reset Walk Speed",
    Callback = CreateSafeCallback(function()
        resetWalkSpeed()
        -- Update the slider and toggle if they exist
        if Rayfield.Flags["WalkSpeedSlider"] then
            Rayfield.Flags["WalkSpeedSlider"]:Set(defaultWalkspeed)
        end
        if Rayfield.Flags["WalkSpeedToggle"] then
            Rayfield.Flags["WalkSpeedToggle"]:Set(false)
        end
        NotifyInfo("Walk Speed", "Walk speed reset to default (" .. defaultWalkspeed .. ")")
    end, "reset_walkspeed")
})

UtilityTab:CreateButton({ 
    Name = "Rejoin Server", 
    Callback = CreateSafeCallback(function() 
        NotifyInfo("Server", "Rejoining current server...")
        wait(1)
        TeleportService:Teleport(game.PlaceId, LocalPlayer) 
    end, "rejoin_server")
})

UtilityTab:CreateButton({ 
    Name = "Emergency Stop All",
    Callback = CreateSafeCallback(function()
        autofish = false
        featureState.AutoSell = false
        autoSellOnThreshold = false
        
        NotifyError("Emergency Stop", "All automation systems stopped immediately!")
    end, "emergency_stop")
})

UtilityTab:CreateButton({ 
    Name = "Unload Ultimate Script", 
    Callback = CreateSafeCallback(function()
        NotifyInfo("XSAN", "Thank you for using XSAN Fish It Pro Ultimate v1.0! The most advanced fishing script ever created.\n\nScript will unload in 3 seconds...")
        wait(3)
        if game:GetService("CoreGui"):FindFirstChild("Rayfield") then
            game:GetService("CoreGui").Rayfield:Destroy()
        end
    end, "unload_script")
})

print("XSAN: UTILITY tab completed successfully!")

-- Hotkey System
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    if input.KeyCode == Enum.KeyCode.F1 then
        autofish = not autofish
        NotifyInfo("Hotkey", "Auto fishing " .. (autofish and "started" or "stopped") .. " (F1)")
    elseif input.KeyCode == Enum.KeyCode.F2 then
        perfectCast = not perfectCast
        NotifyInfo("Hotkey", "Perfect cast " .. (perfectCast and "enabled" or "disabled") .. " (F2)")
    elseif input.KeyCode == Enum.KeyCode.F3 then
        autoSellOnThreshold = not autoSellOnThreshold
        NotifyInfo("Hotkey", "Auto sell threshold " .. (autoSellOnThreshold and "enabled" or "disabled") .. " (F3)")
    elseif input.KeyCode == Enum.KeyCode.F4 then
        -- Quick teleport to spawn
        SafeTeleport(CFrame.new(389, 137, 264), "Moosewood Spawn")
        NotifyInfo("Hotkey", "Quick teleport to spawn (F4)")
    elseif input.KeyCode == Enum.KeyCode.F5 then
        -- Save current position
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            _G.XSANSavedPosition = LocalPlayer.Character.HumanoidRootPart.CFrame
            NotifyInfo("Hotkey", "Position saved (F5)")
        end
    elseif input.KeyCode == Enum.KeyCode.F6 then
        -- Return to saved position
        if _G.XSANSavedPosition then
            SafeTeleport(_G.XSANSavedPosition, "Saved Position")
            NotifyInfo("Hotkey", "Returned to saved position (F6)")
        end
    elseif input.KeyCode == Enum.KeyCode.F7 then
        -- Toggle walkspeed
        walkspeedEnabled = not walkspeedEnabled
        if walkspeedEnabled then
            setWalkSpeed(currentWalkspeed)
            -- Update UI if available
            if Rayfield.Flags["WalkSpeedToggle"] then
                Rayfield.Flags["WalkSpeedToggle"]:Set(true)
            end
        else
            resetWalkSpeed()
            -- Update UI if available
            if Rayfield.Flags["WalkSpeedToggle"] then
                Rayfield.Flags["WalkSpeedToggle"]:Set(false)
            end
        end
        NotifyInfo("Hotkey", "Walk speed " .. (walkspeedEnabled and "enabled" or "disabled") .. " (F7)")
    end
end)

-- Welcome Messages
spawn(function()
    wait(2)
    NotifySuccess("Welcome!", "XSAN Fish It Pro ULTIMATE v1.0 loaded successfully!\n\nULTIMATE FEATURES ACTIVATED:\nAI-Powered Analytics • Smart Automation • Advanced Safety • Premium Quality • Ultimate Teleportation • And Much More!\n\nReady to dominate Fish It like never before!")
    
    wait(4)
    NotifyInfo("Hotkeys Active!", "HOTKEYS ENABLED:\nF1 - Toggle Auto Fishing\nF2 - Toggle Perfect Cast\nF3 - Toggle Auto Sell Threshold\nF4 - Quick TP to Spawn\nF5 - Save Position\nF6 - Return to Saved Position\nF7 - Toggle Walk Speed\n\nCheck PRESETS tab for quick setup!")
    
    wait(3)
    NotifyInfo("📱 Smart UI!", "RAYFIELD UI SYSTEM:\nRayfield automatically handles UI sizing and responsiveness for all devices!\n\nUI management is now handled by the Rayfield library (css.lua)!")
    
    wait(3)
    NotifySuccess("� Teleportation Fixed!", "TELEPORTATION SYSTEM FIXED:\n✅ Now uses dynamic locations like old.lua\n✅ Accurate coordinates from workspace\n✅ Better player detection\n✅ More reliable teleportation\n\nCheck TELEPORT tab for perfect locations!")
    
    wait(3)
    NotifyInfo("Follow XSAN!", "Instagram: @_bangicoo\nGitHub: codeico\n\nThe most advanced Fish It script ever created! Follow us for more premium scripts and exclusive updates!")
end)

-- Console Branding
print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
print("XSAN FISH IT PRO ULTIMATE v1.0")
print("THE MOST ADVANCED FISH IT SCRIPT EVER CREATED")
print("Premium Script with AI-Powered Features & Ultimate Automation")
print("Instagram: @_bangicoo | GitHub: codeico")
print("Professional Quality • Trusted by Thousands • Ultimate Edition")
print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
print("XSAN: Script loaded successfully! All systems operational!")

-- Performance Enhancements
pcall(function()
    local Modifiers = require(game:GetService("ReplicatedStorage").Shared.FishingRodModifiers)
    for key in pairs(Modifiers) do
        Modifiers[key] = 999999999
    end

    local bait = require(game:GetService("ReplicatedStorage").Baits["Luck Bait"])
    bait.Luck = 999999999
    
    print("XSAN: Performance enhancements applied!")
end)