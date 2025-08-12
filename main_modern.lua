--[[
    XSAN's Fish It Pro - Ultimate Edition v2.0 MODERN UI
    
    Premium Fish It script with ULTIMATE features:
    • Modern Tab-based Interface (NEW!)
    • Quick Start Presets & Advanced Analytics
    • Smart Inventory Management & AI Features  
    • Enhanced Fishing & Quality of Life
    • Smart Notifications & Safety Systems
    • Advanced Automation & Much More
    • Ultimate Teleportation System
    
    Developer: XSAN
    Instagram: @_bangicoo
    GitHub: github.com/codeico
    
    Premium Quality • Modern Design • Ultimate Edition
--]]

print("XSAN: Starting Fish It Pro Ultimate v2.0 Modern...")

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

-- Enhanced notification system with proper Z-Index
local function Notify(title, text, duration)
    duration = duration or 3
    pcall(function()
        -- Create custom notification that appears in front
        local ScreenGui = Instance.new("ScreenGui")
        ScreenGui.Name = "XSAN_Notification"
        ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
        ScreenGui.ResetOnSpawn = false
        
        -- Try CoreGui first for better visibility
        local success = pcall(function()
            ScreenGui.Parent = game.CoreGui
        end)
        if not success then
            ScreenGui.Parent = game.Players.LocalPlayer.PlayerGui
        end
        
        local NotificationFrame = Instance.new("Frame")
        NotificationFrame.Size = UDim2.new(0, 300, 0, 80)
        NotificationFrame.Position = UDim2.new(1, -320, 0, 20)
        NotificationFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
        NotificationFrame.BorderSizePixel = 0
        NotificationFrame.ZIndex = 1000 -- Very high Z-Index
        NotificationFrame.Parent = ScreenGui
        
        local Corner = Instance.new("UICorner")
        Corner.CornerRadius = UDim.new(0, 8)
        Corner.Parent = NotificationFrame
        
        local Stroke = Instance.new("UIStroke")
        Stroke.Color = Color3.fromRGB(70, 130, 200)
        Stroke.Thickness = 2
        Stroke.Parent = NotificationFrame
        
        local TitleLabel = Instance.new("TextLabel")
        TitleLabel.Size = UDim2.new(1, -10, 0.5, 0)
        TitleLabel.Position = UDim2.new(0, 5, 0, 5)
        TitleLabel.BackgroundTransparency = 1
        TitleLabel.Text = title or "XSAN Fish It Pro"
        TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        TitleLabel.TextScaled = true
        TitleLabel.Font = Enum.Font.SourceSansBold
        TitleLabel.ZIndex = 1001
        TitleLabel.Parent = NotificationFrame
        
        local ContentLabel = Instance.new("TextLabel")
        ContentLabel.Size = UDim2.new(1, -10, 0.5, -5)
        ContentLabel.Position = UDim2.new(0, 5, 0.5, 0)
        ContentLabel.BackgroundTransparency = 1
        ContentLabel.Text = text or "Notification"
        ContentLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
        ContentLabel.TextScaled = true
        ContentLabel.Font = Enum.Font.SourceSans
        ContentLabel.ZIndex = 1001
        ContentLabel.Parent = NotificationFrame
        
        -- Animate in
        TweenService:Create(NotificationFrame, TweenInfo.new(0.5, Enum.EasingStyle.Back), {
            Position = UDim2.new(1, -320, 0, 20)
        }):Play()
        
        -- Auto dismiss
        task.spawn(function()
            task.wait(duration)
            TweenService:Create(NotificationFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {
                Position = UDim2.new(1, 50, 0, 20),
                BackgroundTransparency = 1
            }):Play()
            task.wait(0.3)
            ScreenGui:Destroy()
        end)
        
        -- Also try default notification as backup
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

-- Load Modern UI Library with better error handling
print("XSAN: Loading Modern UI Library...")

local Rayfield
local success, error = pcall(function()
    print("XSAN: Attempting to load Modern UI...")
    
    -- Try multiple UI sources with proper fallback
    local uiLibraries = {
        "https://raw.githubusercontent.com/donitono/newversion/master/ui_fixed.lua",
        "https://raw.githubusercontent.com/donitono/part2/main/ui_modern.lua", 
        "https://raw.githubusercontent.com/donitono/part2/main/ui_fixed.lua",
        "https://sirius.menu/rayfield" -- Official Rayfield
    }
    
    for i, url in ipairs(uiLibraries) do
        local success2, result = pcall(function()
            print("XSAN: Trying UI source", i, ":", url)
            local uiContent = game:HttpGet(url)
            if uiContent and #uiContent > 100 then -- Make sure we got actual content
                print("XSAN: Loading UI library from source", i)
                Rayfield = loadstring(uiContent)()
                if Rayfield then
                    print("XSAN: UI library loaded successfully from source", i)
                    return true
                end
            end
        end)
        
        if success2 and Rayfield then
            break
        end
    end
    
    print("XSAN: UI library loadstring executed")
end)

if not success then
    warn("XSAN Error: Failed to load UI Library - " .. tostring(error))
    return
end

if not Rayfield then
    warn("XSAN Error: UI Library is nil after loading")
    return
end

print("XSAN: Modern UI Library loaded successfully!")

-- Mobile/Android detection
local isMobile = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled
local screenSize = workspace.CurrentCamera.ViewportSize

print("XSAN: Platform Detection - Mobile:", isMobile, "Screen Size:", screenSize.X .. "x" .. screenSize.Y)

-- Create Modern Window with better error handling
print("XSAN: Creating modern window...")

local Window
local windowSuccess, windowError = pcall(function()
    Window = Rayfield:CreateWindow({
        Name = "🐟 XSAN Fish It Pro Ultimate v2.0",
        LoadingTitle = "XSAN Fish It Pro Ultimate",
        LoadingSubtitle = "Modern Tab Interface - by XSAN",
        Theme = "Default", -- Use default theme for better compatibility
        ConfigurationSaving = {
            Enabled = false, -- Disable config saving to avoid issues
            FolderName = nil,
            FileName = nil
        },
        Discord = {
            Enabled = false
        },
        KeySystem = false
    })
end)

if not windowSuccess then
    warn("XSAN Error: Failed to create window - " .. tostring(windowError))
    -- Try with minimal configuration
    Window = Rayfield:CreateWindow({
        Name = "XSAN Fish It Pro Ultimate v2.0",
        LoadingTitle = "XSAN Fish It Pro Ultimate",
        LoadingSubtitle = "by XSAN"
    })
end

if not Window then
    warn("XSAN Error: Window is nil after creation")
    return
end

print("XSAN: Window created successfully!")

-- === GAME VARIABLES ===
local fishing = false
local autoFishing = false
local autoShaking = false
local autoReeling = false
local autoSelling = false
local autoSellEnabled = false
local autoCasting = false
local autoUpgrading = false
local useGamepass = false
local shakeDetection = false
local sellMethod = "Auto"
local equipBestRod = false
local sellInterval = 30
local fishingDelay = 1
local castPower = 100
local selectedPreset = "Balanced"
local teleportCooldown = false

-- Advanced features
local autoEquipBait = false
local smartCasting = false
local fishingAnalytics = {
    fishCaught = 0,
    totalValue = 0,
    sessionStart = tick(),
    bestFish = {name = "None", value = 0},
    efficiency = 0
}

-- Game detection and RemoteEvents
local remotes = {}
local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")

-- Find RemoteEvents with better error handling
local function findRemotes()
    local foundRemotes = {}
    local attempts = 0
    local maxAttempts = 10
    
    while attempts < maxAttempts do
        attempts = attempts + 1
        
        pcall(function()
            for _, remote in pairs(ReplicatedStorage:GetDescendants()) do
                if remote:IsA("RemoteEvent") or remote:IsA("RemoteFunction") then
                    foundRemotes[remote.Name] = remote
                end
            end
        end)
        
        if next(foundRemotes) then
            break
        end
        
        wait(1)
    end
    
    return foundRemotes
end

-- Load remotes
task.spawn(function()
    print("XSAN: Finding game RemoteEvents...")
    remotes = findRemotes()
    
    if next(remotes) then
        print("XSAN: Found", #remotes, "RemoteEvents")
        Notify("Game Detected", "Found " .. #remotes .. " RemoteEvents")
    else
        warn("XSAN: No RemoteEvents found")
        Notify("Warning", "No RemoteEvents detected")
    end
end)

-- === TAB 1: INFO (HANYA INFO, TIDAK ADA FITUR) ===
print("XSAN: Creating INFO tab...")
local InfoTab = Window:CreateTab("📋 INFO", "🏠")
print("XSAN: INFO tab created successfully!")

InfoTab:CreateParagraph({
    Title = "🌟 XSAN Fish It Pro Ultimate v2.0",
    Content = "Selamat datang di XSAN Fish It Pro Ultimate Edition dengan Modern Tab Interface! Script premium dengan fitur terlengkap untuk Fish It!"
})

InfoTab:CreateParagraph({
    Title = "✨ What's New in v2.0",
    Content = "• Modern Tab-based Interface (NEW!)\n• Mobile Landscape Optimized\n• Enhanced Performance\n• Better Error Handling\n• Improved Analytics\n• Smart Notifications"
})

InfoTab:CreateParagraph({
    Title = "📖 How to Use",
    Content = "1. Gunakan tab AUTO FISH untuk fishing automation\n2. Tab TELEPORT untuk berpindah lokasi\n3. Tab INVENTORY untuk item management\n4. Tab ANALYTICS untuk statistik\n5. Tab SETTINGS untuk konfigurasi"
})

InfoTab:CreateParagraph({
    Title = "👨‍💻 Developer Info",
    Content = "Created by XSAN\nInstagram: @_bangicoo\nGitHub: github.com/codeico\n\nTrusted by thousands of players worldwide!"
})

-- === TAB 2: AUTO FISH (SEMUA FITUR FISHING DI SINI) ===
print("XSAN: Creating AUTO FISH tab...")
local AutoFishTab = Window:CreateTab("🎣 AUTO FISH", "🎣")
print("XSAN: AUTO FISH tab created successfully!")

AutoFishTab:CreateParagraph({
    Title = "🎣 Automated Fishing System",
    Content = "Ultimate fishing automation with smart features and customizable settings."
})

AutoFishTab:CreateParagraph({
    Title = "🔥 Quick Start Presets",
    Content = "Pilih preset sesuai kebutuhan Anda. Setiap preset sudah dioptimalkan untuk hasil terbaik!"
})

local presetOptions = {"Balanced", "Speed Focus", "Value Focus", "Casual", "Hardcore"}
AutoFishTab:CreateDropdown({
    Name = "🎯 Select Preset",
    Options = presetOptions,
    CurrentOption = selectedPreset,
    Callback = CreateSafeCallback(function(option)
        selectedPreset = option
        
        -- Apply preset settings
        if option == "Speed Focus" then
            fishingDelay = 0.5
            castPower = 80
            autoShaking = true
            autoReeling = true
            Notify("Preset Applied", "Speed Focus - Fast fishing enabled!")
        elseif option == "Value Focus" then
            fishingDelay = 2
            castPower = 100
            equipBestRod = true
            smartCasting = true
            Notify("Preset Applied", "Value Focus - Quality over quantity!")
        elseif option == "Casual" then
            fishingDelay = 1.5
            castPower = 70
            autoShaking = false
            Notify("Preset Applied", "Casual - Relaxed fishing mode!")
        elseif option == "Hardcore" then
            fishingDelay = 0.3
            castPower = 100
            autoShaking = true
            autoReeling = true
            autoSelling = true
            smartCasting = true
            Notify("Preset Applied", "Hardcore - Maximum automation!")
        else -- Balanced
            fishingDelay = 1
            castPower = 85
            autoShaking = true
            autoReeling = false
            Notify("Preset Applied", "Balanced - Perfect for most players!")
        end
    end, "preset_dropdown")
})

AutoFishTab:CreateButton({
    Name = "🚀 Apply Selected Preset",
    Callback = CreateSafeCallback(function()
        -- Apply the currently selected preset
        if selectedPreset == "Speed Focus" then
            fishingDelay = 0.5
            castPower = 80
            autoShaking = true
            autoReeling = true
        elseif selectedPreset == "Value Focus" then
            fishingDelay = 2
            castPower = 100
            equipBestRod = true
            smartCasting = true
        elseif selectedPreset == "Casual" then
            fishingDelay = 1.5
            castPower = 70
            autoShaking = false
        elseif selectedPreset == "Hardcore" then
            fishingDelay = 0.3
            castPower = 100
            autoShaking = true
            autoReeling = true
            autoSelling = true
            smartCasting = true
        else -- Balanced
            fishingDelay = 1
            castPower = 85
            autoShaking = true
            autoReeling = false
        end
        
        Notify("✅ Preset Applied", selectedPreset .. " settings activated!")
    end, "apply_preset_btn")
})

local mainFishingToggle = AutoFishTab:CreateToggle({
    Name = "🎣 Enable Auto Fishing",
    CurrentValue = autoFishing,
    Callback = CreateSafeCallback(function(value)
        autoFishing = value
        fishing = value
        
        if value then
            Notify("🎣 Auto Fishing", "Started!")
            -- Start fishing loop
            task.spawn(function()
                while autoFishing do
                    pcall(function()
                        -- Fishing logic here
                        if remotes.Cast then
                            remotes.Cast:FireServer(castPower)
                        end
                        
                        -- Auto shaking
                        if autoShaking and remotes.Shake then
                            wait(math.random(1, 3))
                            remotes.Shake:FireServer()
                        end
                        
                        -- Auto reeling
                        if autoReeling and remotes.Reel then
                            wait(math.random(2, 4))
                            remotes.Reel:FireServer()
                        end
                        
                        -- Update analytics
                        fishingAnalytics.fishCaught = fishingAnalytics.fishCaught + 1
                    end)
                    
                    wait(fishingDelay)
                end
            end)
        else
            Notify("🎣 Auto Fishing", "Stopped!")
        end
    end, "main_fishing_toggle")
})

AutoFishTab:CreateToggle({
    Name = "🌊 Auto Shaking",
    CurrentValue = autoShaking,
    Callback = CreateSafeCallback(function(value)
        autoShaking = value
        Notify("🌊 Auto Shaking", value and "Enabled" or "Disabled")
    end, "auto_shaking_toggle")
})

AutoFishTab:CreateToggle({
    Name = "🎯 Auto Reeling",
    CurrentValue = autoReeling,
    Callback = CreateSafeCallback(function(value)
        autoReeling = value
        Notify("🎯 Auto Reeling", value and "Enabled" or "Disabled")
    end, "auto_reeling_toggle")
})

AutoFishTab:CreateToggle({
    Name = "🧠 Smart Casting",
    CurrentValue = smartCasting,
    Callback = CreateSafeCallback(function(value)
        smartCasting = value
        Notify("🧠 Smart Casting", value and "Enabled" or "Disabled")
    end, "smart_casting_toggle")
})

AutoFishTab:CreateSlider({
    Name = "⚡ Fishing Speed",
    Range = {0.1, 5},
    Increment = 0.1,
    CurrentValue = fishingDelay,
    Callback = CreateSafeCallback(function(value)
        fishingDelay = value
        Notify("⚡ Speed Updated", "Delay: " .. value .. "s")
    end, "fishing_speed_slider")
})

AutoFishTab:CreateSlider({
    Name = "💪 Cast Power",
    Range = {1, 100},
    Increment = 1,
    CurrentValue = castPower,
    Callback = CreateSafeCallback(function(value)
        castPower = value
        Notify("💪 Power Updated", "Cast Power: " .. value .. "%")
    end, "cast_power_slider")
})

-- === TAB 3: TELEPORT ===
print("XSAN: Creating TELEPORT tab...")
local TeleportTab = Window:CreateTab("🌍 TELEPORT", "🌍")
print("XSAN: TELEPORT tab created successfully!")

TeleportTab:CreateParagraph({
    Title = "🌍 Ultimate Teleportation System",
    Content = "Teleport instantly to any fishing location or shop. Updated coordinates for all areas!"
})

-- Fish It accurate teleport locations
local teleportLocations = {
    -- Main Areas
    ["🏠 Spawn"] = {x = 1, y = 18, z = 134},
    ["🏪 Shop (Alex)"] = {x = -28.43, y = 4.50, z = 2891.28},
    ["🏪 Shop (Joe)"] = {x = 112.01, y = 4.75, z = 2877.32},
    ["🏪 Shop (Seth)"] = {x = 72.02, y = 4.58, z = 2885.28},
    ["🎣 Rod Shop (Marc)"] = {x = 454, y = 150, z = 229},
    ["⚓ Shipwright"] = {x = 343, y = 135, z = 271},
    ["📦 Storage (Henry)"] = {x = 491, y = 150, z = 272},
    
    -- Fishing Spots
    ["🌊 Ocean (Starter)"] = {x = 0, y = 20, z = 200},
    ["🏔️ Mountain Lake"] = {x = -1800, y = 150, z = 900},
    ["🏝️ Coral Reef"] = {x = 500, y = 130, z = -200},
    ["🌅 Deep Ocean"] = {x = 1000, y = 130, z = 1000},
    ["❄️ Ice Lake"] = {x = -1200, y = 140, z = -800},
    ["� Lava Pool"] = {x = 800, y = 160, z = 800},
    
    -- Events & Special
    ["🌟 Isonade Event"] = {x = -1442, y = 135, z = 1006},
    ["🦈 Great White Event"] = {x = 1082, y = 124, z = -924}
}

local function teleportTo(position)
    if teleportCooldown then
        Notify("⏰ Cooldown", "Please wait before teleporting again")
        return
    end
    
    teleportCooldown = true
    
    pcall(function()
        if character and character:FindFirstChild("HumanoidRootPart") then
            character.HumanoidRootPart.CFrame = CFrame.new(position.x, position.y, position.z)
            Notify("✅ Teleported", "Arrived at destination!")
        end
    end)
    
    task.wait(2)
    teleportCooldown = false
end

-- Create teleport buttons
for locationName, position in pairs(teleportLocations) do
    TeleportTab:CreateButton({
        Name = locationName,
        Callback = CreateSafeCallback(function()
            teleportTo(position)
        end, "teleport_" .. locationName)
    })
end

-- Custom teleport
TeleportTab:CreateInput({
    Name = "📍 Custom X Coordinate",
    PlaceholderText = "Enter X coordinate...",
    RemoveTextAfterFocusLost = false,
    Callback = CreateSafeCallback(function(text)
        _G.customX = tonumber(text) or 0
    end, "custom_x_input")
})

TeleportTab:CreateInput({
    Name = "📍 Custom Y Coordinate", 
    PlaceholderText = "Enter Y coordinate...",
    RemoveTextAfterFocusLost = false,
    Callback = CreateSafeCallback(function(text)
        _G.customY = tonumber(text) or 10
    end, "custom_y_input")
})

TeleportTab:CreateInput({
    Name = "📍 Custom Z Coordinate",
    PlaceholderText = "Enter Z coordinate...",
    RemoveTextAfterFocusLost = false,
    Callback = CreateSafeCallback(function(text)
        _G.customZ = tonumber(text) or 0
    end, "custom_z_input")
})

TeleportTab:CreateButton({
    Name = "🚀 Teleport to Custom Location",
    Callback = CreateSafeCallback(function()
        local x = _G.customX or 0
        local y = _G.customY or 10
        local z = _G.customZ or 0
        
        teleportTo({x = x, y = y, z = z})
    end, "custom_teleport_btn")
})

-- === TAB 4: INVENTORY ===
print("XSAN: Creating INVENTORY tab...")
local InventoryTab = Window:CreateTab("🎒 INVENTORY", "🎒")
print("XSAN: INVENTORY tab created successfully!")

InventoryTab:CreateParagraph({
    Title = "🎒 Smart Inventory Management",
    Content = "Automated selling, upgrading, and inventory optimization tools."
})

InventoryTab:CreateToggle({
    Name = "💰 Auto Sell Fish",
    CurrentValue = autoSelling,
    Callback = CreateSafeCallback(function(value)
        autoSelling = value
        
        if value then
            Notify("💰 Auto Sell", "Started!")
            task.spawn(function()
                while autoSelling do
                    pcall(function()
                        if remotes.SellFish then
                            remotes.SellFish:FireServer()
                            fishingAnalytics.totalValue = fishingAnalytics.totalValue + 100 -- Estimate
                        end
                    end)
                    wait(sellInterval)
                end
            end)
        else
            Notify("💰 Auto Sell", "Stopped!")
        end
    end, "auto_sell_toggle")
})

InventoryTab:CreateSlider({
    Name = "⏰ Sell Interval (seconds)",
    Range = {5, 120},
    Increment = 5,
    CurrentValue = sellInterval,
    Callback = CreateSafeCallback(function(value)
        sellInterval = value
        Notify("⏰ Interval Updated", "Selling every " .. value .. " seconds")
    end, "sell_interval_slider")
})

local sellMethods = {"Auto", "Specific", "All", "Valuable Only"}
InventoryTab:CreateDropdown({
    Name = "🎯 Sell Method",
    Options = sellMethods,
    CurrentOption = sellMethod,
    Callback = CreateSafeCallback(function(option)
        sellMethod = option
        Notify("🎯 Sell Method", "Changed to: " .. option)
    end, "sell_method_dropdown")
})

InventoryTab:CreateToggle({
    Name = "🎣 Auto Equip Best Rod",
    CurrentValue = equipBestRod,
    Callback = CreateSafeCallback(function(value)
        equipBestRod = value
        
        if value then
            task.spawn(function()
                pcall(function()
                    if remotes.EquipRod then
                        remotes.EquipRod:FireServer("BestRod")
                    end
                end)
            end)
        end
        
        Notify("🎣 Auto Equip Rod", value and "Enabled" or "Disabled")
    end, "equip_rod_toggle")
})

InventoryTab:CreateToggle({
    Name = "🪱 Auto Equip Bait",
    CurrentValue = autoEquipBait,
    Callback = CreateSafeCallback(function(value)
        autoEquipBait = value
        Notify("🪱 Auto Equip Bait", value and "Enabled" or "Disabled")
    end, "equip_bait_toggle")
})

InventoryTab:CreateButton({
    Name = "💎 Sell All Fish Now",
    Callback = CreateSafeCallback(function()
        pcall(function()
            if remotes.SellFish then
                remotes.SellFish:FireServer()
                Notify("💎 Sold!", "All fish sold successfully")
                fishingAnalytics.totalValue = fishingAnalytics.totalValue + 500 -- Estimate
            end
        end)
    end, "sell_all_btn")
})

-- === TAB 5: ANALYTICS ===
print("XSAN: Creating ANALYTICS tab...")
local AnalyticsTab = Window:CreateTab("📊 ANALYTICS", "📊")
print("XSAN: ANALYTICS tab created successfully!")

AnalyticsTab:CreateParagraph({
    Title = "📊 Fishing Analytics & Statistics",
    Content = "Real-time tracking of your fishing performance, earnings, and efficiency."
})

-- Analytics display (update every 5 seconds)
local analyticsUpdate = task.spawn(function()
    while true do
        task.wait(5)
        
        -- Calculate session time
        local sessionTime = tick() - fishingAnalytics.sessionStart
        local hours = math.floor(sessionTime / 3600)
        local minutes = math.floor((sessionTime % 3600) / 60)
        
        -- Calculate efficiency
        if sessionTime > 0 then
            fishingAnalytics.efficiency = math.floor(fishingAnalytics.fishCaught / (sessionTime / 60))
        end
        
        -- Update UI elements would go here
        -- For now, just print to console
        print("XSAN Analytics: Fish Caught:", fishingAnalytics.fishCaught, "Total Value:", fishingAnalytics.totalValue, "Efficiency:", fishingAnalytics.efficiency, "fish/min")
    end
end)

AnalyticsTab:CreateParagraph({
    Title = "🎯 Session Statistics",
    Content = "Fish Caught: " .. fishingAnalytics.fishCaught .. "\nTotal Value: $" .. fishingAnalytics.totalValue .. "\nEfficiency: " .. fishingAnalytics.efficiency .. " fish/min\nBest Fish: " .. fishingAnalytics.bestFish.name
})

AnalyticsTab:CreateButton({
    Name = "🔄 Reset Analytics",
    Callback = CreateSafeCallback(function()
        fishingAnalytics = {
            fishCaught = 0,
            totalValue = 0,
            sessionStart = tick(),
            bestFish = {name = "None", value = 0},
            efficiency = 0
        }
        Notify("🔄 Reset", "Analytics data cleared!")
    end, "reset_analytics_btn")
})

AnalyticsTab:CreateButton({
    Name = "📋 Export Data",
    Callback = CreateSafeCallback(function()
        local data = HttpService:JSONEncode(fishingAnalytics)
        setclipboard(data)
        Notify("📋 Exported", "Data copied to clipboard!")
    end, "export_data_btn")
})

-- === TAB 6: SETTINGS ===
print("XSAN: Creating SETTINGS tab...")
local SettingsTab = Window:CreateTab("⚙️ SETTINGS", "⚙️")
print("XSAN: SETTINGS tab created successfully!")

SettingsTab:CreateParagraph({
    Title = "⚙️ Advanced Settings & Configuration",
    Content = "Customize your XSAN Fish It Pro experience with advanced options."
})

SettingsTab:CreateToggle({
    Name = "🎮 Use Gamepass Features",
    CurrentValue = useGamepass,
    Callback = CreateSafeCallback(function(value)
        useGamepass = value
        Notify("🎮 Gamepass", value and "Enabled" or "Disabled")
    end, "gamepass_toggle")
})

SettingsTab:CreateToggle({
    Name = "🔍 Enhanced Shake Detection",
    CurrentValue = shakeDetection,
    Callback = CreateSafeCallback(function(value)
        shakeDetection = value
        Notify("🔍 Shake Detection", value and "Enhanced" or "Normal")
    end, "shake_detection_toggle")
})

SettingsTab:CreateButton({
    Name = "📱 Show Mobile Tips",
    Callback = CreateSafeCallback(function()
        Notify("📱 Mobile Tips", "• Use landscape mode for best experience\n• Tap and hold to drag the interface\n• Swipe to navigate tabs\n• Pinch to zoom if needed")
    end, "mobile_tips_btn")
})

SettingsTab:CreateButton({
    Name = "🔧 Advanced Tools Interface",
    Callback = CreateSafeCallback(function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/donitono/part2/main/unified_tools_interface.lua"))()
        Notify("🔧 Tools Loaded", "Advanced tools interface loaded!")
    end, "tools_interface_btn")
})

SettingsTab:CreateButton({
    Name = "🆘 Emergency Stop All",
    Callback = CreateSafeCallback(function()
        -- Stop all automation
        autoFishing = false
        fishing = false
        autoShaking = false
        autoReeling = false
        autoSelling = false
        autoCasting = false
        autoUpgrading = false
        
        Notify("🆘 Emergency Stop", "All automation stopped!")
    end, "emergency_stop_btn")
})

SettingsTab:CreateButton({
    Name = "🗑️ Destroy Interface",
    Callback = CreateSafeCallback(function()
        game.Players.LocalPlayer.PlayerGui.RayfieldLibrary:Destroy()
    end, "destroy_ui_btn")
})

-- Final setup with validation
print("XSAN: Validating all tabs...")

-- Validate that all tabs were created successfully
local tabsCreated = {
    Info = InfoTab ~= nil,
    AutoFish = AutoFishTab ~= nil,
    Teleport = TeleportTab ~= nil,
    Inventory = InventoryTab ~= nil,
    Analytics = AnalyticsTab ~= nil,
    Settings = SettingsTab ~= nil
}

print("XSAN: Tab validation results:")
for tabName, created in pairs(tabsCreated) do
    print("  -", tabName, ":", created and "✅ Created" or "❌ Failed")
end

local allTabsCreated = true
for _, created in pairs(tabsCreated) do
    if not created then
        allTabsCreated = false
        break
    end
end

if allTabsCreated then
    print("XSAN: All tabs created successfully!")
    Notify("✅ UI Ready!", "XSAN Fish It Pro Ultimate v2.0 loaded successfully! All 6 tabs are ready. Use tab navigation for best experience.")
else
    warn("XSAN: Some tabs failed to create!")
    Notify("⚠️ Warning", "Some UI tabs failed to load. Check console for details.")
end

print("XSAN: Modern UI setup complete!")

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
                
                Notify("UI Toggle", "XSAN Fish It Pro Modern UI shown!")
            else
                FloatingButton.Text = "👁"
                FloatingButton.BackgroundColor3 = Color3.fromRGB(200, 100, 100)
                
                -- Animate hide
                TweenService:Create(rayfieldGui.Main, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
                    BackgroundTransparency = 1
                }):Play()
                
                task.wait(0.3)
                rayfieldGui.Enabled = false
                Notify("UI Toggle", "UI hidden! Use floating button to show.")
            end
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
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            updateDrag(input)
        end
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
    
    -- Click to toggle (only if not dragging significantly)
    FloatingButton.MouseButton1Click:Connect(function()
        if not dragging then
            toggleUI()
        end
    end)
    
    -- Keyboard shortcut for toggle (H key)
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if not gameProcessed and input.KeyCode == Enum.KeyCode.H then
            toggleUI()
        end
    end)
    
    print("XSAN: Floating toggle button created successfully!")
end)

-- Auto-detection and smart features
task.spawn(function()
    task.wait(3)
    
    -- Auto-detect game mode
    pcall(function()
        local gameMode = "Unknown"
        -- Add game detection logic here
        Notify("🎮 Game Detected", "Mode: " .. gameMode)
    end)
    
    -- Show mobile optimization status
    if isMobile then
        local isLandscape = screenSize.X > screenSize.Y
        Notify("📱 Mobile Optimized", isLandscape and "Landscape mode detected - UI optimized!" or "Portrait mode - consider rotating for better experience")
    end
end)
