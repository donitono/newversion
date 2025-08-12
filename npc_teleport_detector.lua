-- NPC & Teleportation Detector
-- Script untuk mendeteksi semua NPC, lokasi, dan sistem teleportasi
-- Berguna untuk mengupdate teleportation system di main.lua

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer

-- Create GUI
local CoreGui = game:GetService("CoreGui")
local screen = Instance.new("ScreenGui")
screen.Name = "NPCTeleportDetector"
screen.Parent = CoreGui

-- Main frame (landscape optimized - positioned higher)
local frame = Instance.new("Frame")
frame.Parent = screen
frame.Size = UDim2.new(0, 650, 0, 280) -- Reduced height for better landscape fit
frame.Position = UDim2.new(0, 10, 0, 60) -- Moved higher from top
frame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
frame.BorderSizePixel = 0
frame.Active = true
frame.Draggable = true
frame.Visible = false -- Start hidden
Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 8)

-- Floating toggle button (positioned better for landscape)
local floatingBtn = Instance.new("TextButton", screen)
floatingBtn.Size = UDim2.new(0, 60, 0, 60)
floatingBtn.Position = UDim2.new(1, -80, 0, 120) -- Moved higher up
floatingBtn.Text = "🗺️"
floatingBtn.BackgroundColor3 = Color3.fromRGB(80, 160, 120)
floatingBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
floatingBtn.Font = Enum.Font.SourceSansBold
floatingBtn.TextSize = 24
floatingBtn.BorderSizePixel = 0
floatingBtn.ZIndex = 10
Instance.new("UICorner", floatingBtn).CornerRadius = UDim.new(0.5, 0)

-- Floating button functionality
floatingBtn.MouseButton1Click:Connect(function()
    frame.Visible = not frame.Visible
    floatingBtn.BackgroundColor3 = frame.Visible and Color3.fromRGB(180, 70, 70) or Color3.fromRGB(80, 160, 120)
    floatingBtn.Text = frame.Visible and "❌" or "🗺️"
end)

-- Title
local title = Instance.new("TextLabel")
title.Parent = frame
title.Size = UDim2.new(1, 0, 0, 35)
title.BackgroundTransparency = 1
title.Text = "🗺️ NPC & Teleportation Detector"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.Font = Enum.Font.SourceSansBold
title.TextSize = 16

-- Tab frame
local tabFrame = Instance.new("Frame")
tabFrame.Parent = frame
tabFrame.Size = UDim2.new(1, -20, 0, 30)
tabFrame.Position = UDim2.new(0, 10, 0, 40)
tabFrame.BackgroundTransparency = 1

local npcTab = Instance.new("TextButton")
npcTab.Parent = tabFrame
npcTab.Size = UDim2.new(0.25, -5, 1, 0)
npcTab.Position = UDim2.new(0, 0, 0, 0)
npcTab.Text = "👥 NPCs"
npcTab.BackgroundColor3 = Color3.fromRGB(70, 130, 180)
npcTab.TextColor3 = Color3.fromRGB(255, 255, 255)
npcTab.Font = Enum.Font.SourceSans
npcTab.TextSize = 12
npcTab.BorderSizePixel = 0
Instance.new("UICorner", npcTab).CornerRadius = UDim.new(0, 6)

local islandTab = Instance.new("TextButton")
islandTab.Parent = tabFrame
islandTab.Size = UDim2.new(0.25, -5, 1, 0)
islandTab.Position = UDim2.new(0.25, 5, 0, 0)
islandTab.Text = "🏝️ Islands"
islandTab.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
islandTab.TextColor3 = Color3.fromRGB(255, 255, 255)
islandTab.Font = Enum.Font.SourceSans
islandTab.TextSize = 12
islandTab.BorderSizePixel = 0
Instance.new("UICorner", islandTab).CornerRadius = UDim.new(0, 6)

local locationTab = Instance.new("TextButton")
locationTab.Parent = tabFrame
locationTab.Size = UDim2.new(0.25, -5, 1, 0)
locationTab.Position = UDim2.new(0.5, 10, 0, 0)
locationTab.Text = "📍 Locations"
locationTab.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
locationTab.TextColor3 = Color3.fromRGB(255, 255, 255)
locationTab.Font = Enum.Font.SourceSans
locationTab.TextSize = 12
locationTab.BorderSizePixel = 0
Instance.new("UICorner", locationTab).CornerRadius = UDim.new(0, 6)

local playerTab = Instance.new("TextButton")
playerTab.Parent = tabFrame
playerTab.Size = UDim2.new(0.25, -5, 1, 0)
playerTab.Position = UDim2.new(0.75, 15, 0, 0)
playerTab.Text = "👤 Player"
playerTab.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
playerTab.TextColor3 = Color3.fromRGB(255, 255, 255)
playerTab.Font = Enum.Font.SourceSans
playerTab.TextSize = 12
playerTab.BorderSizePixel = 0
Instance.new("UICorner", playerTab).CornerRadius = UDim.new(0, 6)

-- Content frame
local contentFrame = Instance.new("ScrollingFrame")
contentFrame.Parent = frame
contentFrame.Size = UDim2.new(1, -20, 1, -120)
contentFrame.Position = UDim2.new(0, 10, 0, 80)
contentFrame.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
contentFrame.BorderSizePixel = 0
contentFrame.ScrollBarThickness = 8
Instance.new("UICorner", contentFrame).CornerRadius = UDim.new(0, 6)

local contentText = Instance.new("TextLabel")
contentText.Parent = contentFrame
contentText.Size = UDim2.new(1, -10, 1, 0)
contentText.Position = UDim2.new(0, 5, 0, 0)
contentText.BackgroundTransparency = 1
contentText.Text = "Loading..."
contentText.TextColor3 = Color3.fromRGB(255, 255, 255)
contentText.Font = Enum.Font.SourceSans
contentText.TextSize = 11
contentText.TextWrapped = true
contentText.TextXAlignment = Enum.TextXAlignment.Left
contentText.TextYAlignment = Enum.TextYAlignment.Top

-- Button frame
local buttonFrame = Instance.new("Frame")
buttonFrame.Parent = frame
buttonFrame.Size = UDim2.new(1, -20, 0, 30)
buttonFrame.Position = UDim2.new(0, 10, 1, -40)
buttonFrame.BackgroundTransparency = 1

local refreshBtn = Instance.new("TextButton")
refreshBtn.Parent = buttonFrame
refreshBtn.Size = UDim2.new(0, 80, 1, 0)
refreshBtn.Position = UDim2.new(0, 0, 0, 0)
refreshBtn.Text = "Refresh"
refreshBtn.BackgroundColor3 = Color3.fromRGB(70, 150, 70)
refreshBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
refreshBtn.Font = Enum.Font.SourceSans
refreshBtn.TextSize = 12
refreshBtn.BorderSizePixel = 0
Instance.new("UICorner", refreshBtn).CornerRadius = UDim.new(0, 6)

local exportBtn = Instance.new("TextButton")
exportBtn.Parent = buttonFrame
exportBtn.Size = UDim2.new(0, 80, 1, 0)
exportBtn.Position = UDim2.new(0, 90, 0, 0)
exportBtn.Text = "Export"
exportBtn.BackgroundColor3 = Color3.fromRGB(70, 130, 180)
exportBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
exportBtn.Font = Enum.Font.SourceSans
exportBtn.TextSize = 12
exportBtn.BorderSizePixel = 0
Instance.new("UICorner", exportBtn).CornerRadius = UDim.new(0, 6)

local teleportBtn = Instance.new("TextButton")
teleportBtn.Parent = buttonFrame
teleportBtn.Size = UDim2.new(0, 80, 1, 0)
teleportBtn.Position = UDim2.new(0, 180, 0, 0)
teleportBtn.Text = "Teleport"
teleportBtn.BackgroundColor3 = Color3.fromRGB(150, 70, 150)
teleportBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
teleportBtn.Font = Enum.Font.SourceSans
teleportBtn.TextSize = 12
teleportBtn.BorderSizePixel = 0
Instance.new("UICorner", teleportBtn).CornerRadius = UDim.new(0, 6)

local closeBtn = Instance.new("TextButton")
closeBtn.Parent = buttonFrame
closeBtn.Size = UDim2.new(0, 80, 1, 0)
closeBtn.Position = UDim2.new(1, -80, 0, 0)
closeBtn.Text = "Close"
closeBtn.BackgroundColor3 = Color3.fromRGB(180, 70, 70)
closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
closeBtn.Font = Enum.Font.SourceSans
closeBtn.TextSize = 12
closeBtn.BorderSizePixel = 0
Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0, 6)

-- Variables
local currentTab = "npcs"
local detectedData = {}
local selectedLocation = nil

-- Detection functions
local function detectNPCs()
    local results = {"=== NPC DETECTION ===", ""}
    local npcs = {}
    
    -- Check ReplicatedStorage NPCs
    local npcContainer = ReplicatedStorage:FindFirstChild("NPC")
    if npcContainer then
        results[#results + 1] = "📦 ReplicatedStorage NPCs:"
        for _, npc in pairs(npcContainer:GetChildren()) do
            local pos = npc:FindFirstChild("WorldPivot") and npc.WorldPivot.Position or Vector3.new(0,0,0)
            npcs[npc.Name] = pos
            results[#results + 1] = string.format("  • %s: CFrame.new(%.2f, %.2f, %.2f)", npc.Name, pos.X, pos.Y, pos.Z)
        end
        results[#results + 1] = ""
    end
    
    -- Check Workspace NPCs
    local workspaceNPCs = {}
    for _, obj in pairs(Workspace:GetDescendants()) do
        if obj:IsA("Model") and obj:FindFirstChild("Humanoid") and obj.Name ~= LocalPlayer.Name then
            local rootPart = obj:FindFirstChild("HumanoidRootPart") or obj:FindFirstChild("Torso")
            if rootPart then
                table.insert(workspaceNPCs, {name = obj.Name, position = rootPart.Position})
            end
        end
    end
    
    if #workspaceNPCs > 0 then
        results[#results + 1] = "🌍 Workspace NPCs:"
        for _, npc in pairs(workspaceNPCs) do
            results[#results + 1] = string.format("  • %s: CFrame.new(%.2f, %.2f, %.2f)", npc.name, npc.position.X, npc.position.Y, npc.position.Z)
        end
        results[#results + 1] = ""
    end
    
    -- Generate Lua table format
    results[#results + 1] = "💾 Lua Table Format (for main.lua):"
    results[#results + 1] = "local npcs = {"
    for name, pos in pairs(npcs) do
        results[#results + 1] = string.format("    [\"%s\"] = CFrame.new(%.2f, %.2f, %.2f),", name, pos.X, pos.Y, pos.Z)
    end
    results[#results + 1] = "}"
    
    detectedData.npcs = npcs
    return table.concat(results, "\n")
end

local function detectIslands()
    local results = {"=== ISLAND DETECTION ===", ""}
    local islands = {}
    
    -- Check for island folder
    local islandFolder = Workspace:FindFirstChild("!!!! ISLAND LOCATIONS !!!!")
    if islandFolder then
        results[#results + 1] = "🏝️ Island Locations Folder Found!"
        results[#results + 1] = ""
        
        for _, island in pairs(islandFolder:GetChildren()) do
            local pos = island.Position
            islands[island.Name] = pos
            results[#results + 1] = string.format("📍 %s: CFrame.new(%.2f, %.2f, %.2f)", island.Name, pos.X, pos.Y, pos.Z)
        end
        results[#results + 1] = ""
    end
    
    -- Check for spawn locations
    local spawnFolder = Workspace:FindFirstChild("SpawnLocation") or Workspace:FindFirstChild("Spawns")
    if spawnFolder then
        results[#results + 1] = "🎯 Spawn Locations:"
        local spawn = spawnFolder:IsA("SpawnLocation") and spawnFolder or spawnFolder:FindFirstChildOfClass("SpawnLocation")
        if spawn then
            local pos = spawn.Position
            results[#results + 1] = string.format("  • Spawn: CFrame.new(%.2f, %.2f, %.2f)", pos.X, pos.Y, pos.Z)
        end
        results[#results + 1] = ""
    end
    
    -- Generate Lua format
    results[#results + 1] = "💾 Lua Table Format:"
    results[#results + 1] = "local islands = {"
    for name, pos in pairs(islands) do
        results[#results + 1] = string.format("    [\"%s\"] = CFrame.new(%.2f, %.2f, %.2f),", name, pos.X, pos.Y, pos.Z)
    end
    results[#results + 1] = "}"
    
    detectedData.islands = islands
    return table.concat(results, "\n")
end

local function detectLocations()
    local results = {"=== SPECIAL LOCATIONS ===", ""}
    local locations = {}
    
    -- Search for fishing spots
    results[#results + 1] = "🎣 Fishing Related Locations:"
    local fishingSpots = {}
    for _, obj in pairs(Workspace:GetDescendants()) do
        if obj.Name and (string.find(string.lower(obj.Name), "fish") or 
                        string.find(string.lower(obj.Name), "water") or
                        string.find(string.lower(obj.Name), "pond") or
                        string.find(string.lower(obj.Name), "lake")) then
            if obj:IsA("Part") or obj:IsA("Model") then
                local pos = obj:IsA("Part") and obj.Position or (obj.PrimaryPart and obj.PrimaryPart.Position)
                if pos then
                    fishingSpots[obj.Name] = pos
                    results[#results + 1] = string.format("  • %s: CFrame.new(%.2f, %.2f, %.2f)", obj.Name, pos.X, pos.Y, pos.Z)
                end
            end
        end
    end
    results[#results + 1] = ""
    
    -- Search for shops/vendors
    results[#results + 1] = "🛒 Shop/Vendor Locations:"
    for _, obj in pairs(Workspace:GetDescendants()) do
        if obj.Name and (string.find(string.lower(obj.Name), "shop") or 
                        string.find(string.lower(obj.Name), "store") or
                        string.find(string.lower(obj.Name), "vendor")) then
            if obj:IsA("Part") or obj:IsA("Model") then
                local pos = obj:IsA("Part") and obj.Position or (obj.PrimaryPart and obj.PrimaryPart.Position)
                if pos then
                    results[#results + 1] = string.format("  • %s: CFrame.new(%.2f, %.2f, %.2f)", obj.Name, pos.X, pos.Y, pos.Z)
                end
            end
        end
    end
    
    return table.concat(results, "\n")
end

local function getPlayerInfo()
    local results = {"=== PLAYER INFORMATION ===", ""}
    
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        local pos = LocalPlayer.Character.HumanoidRootPart.Position
        local cf = LocalPlayer.Character.HumanoidRootPart.CFrame
        
        results[#results + 1] = "👤 Current Player Position:"
        results[#results + 1] = string.format("Position: Vector3.new(%.2f, %.2f, %.2f)", pos.X, pos.Y, pos.Z)
        results[#results + 1] = string.format("CFrame: CFrame.new(%.2f, %.2f, %.2f)", pos.X, pos.Y, pos.Z)
        results[#results + 1] = ""
        
        -- Check distance to known locations
        results[#results + 1] = "📏 Distance to Known Locations:"
        if detectedData.npcs then
            for name, npcPos in pairs(detectedData.npcs) do
                local distance = (pos - npcPos).Magnitude
                results[#results + 1] = string.format("  • %s: %.2f studs", name, distance)
            end
        end
        results[#results + 1] = ""
        
        -- Player stats
        results[#results + 1] = "📊 Player Stats:"
        results[#results + 1] = "Name: " .. LocalPlayer.Name
        results[#results + 1] = "UserId: " .. LocalPlayer.UserId
        if LocalPlayer.Character:FindFirstChild("Humanoid") then
            local humanoid = LocalPlayer.Character.Humanoid
            results[#results + 1] = string.format("Health: %.0f/%.0f", humanoid.Health, humanoid.MaxHealth)
            results[#results + 1] = string.format("WalkSpeed: %.0f", humanoid.WalkSpeed)
            results[#results + 1] = string.format("JumpPower: %.0f", humanoid.JumpPower or humanoid.JumpHeight)
        end
    else
        results[#results + 1] = "❌ Player character not found or not spawned"
    end
    
    return table.concat(results, "\n")
end

-- Tab switching function
local function switchTab(tabName)
    -- Reset all tab colors
    npcTab.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    islandTab.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    locationTab.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    playerTab.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    
    currentTab = tabName
    
    if tabName == "npcs" then
        npcTab.BackgroundColor3 = Color3.fromRGB(70, 130, 180)
        contentText.Text = detectNPCs()
    elseif tabName == "islands" then
        islandTab.BackgroundColor3 = Color3.fromRGB(70, 130, 180)
        contentText.Text = detectIslands()
    elseif tabName == "locations" then
        locationTab.BackgroundColor3 = Color3.fromRGB(70, 130, 180)
        contentText.Text = detectLocations()
    elseif tabName == "player" then
        playerTab.BackgroundColor3 = Color3.fromRGB(70, 130, 180)
        contentText.Text = getPlayerInfo()
    end
    
    -- Update scroll size
    contentFrame.CanvasSize = UDim2.new(0, 0, 0, contentText.TextBounds.Y)
end

-- Button events
npcTab.MouseButton1Click:Connect(function() switchTab("npcs") end)
islandTab.MouseButton1Click:Connect(function() switchTab("islands") end)
locationTab.MouseButton1Click:Connect(function() switchTab("locations") end)
playerTab.MouseButton1Click:Connect(function() switchTab("player") end)

refreshBtn.MouseButton1Click:Connect(function()
    switchTab(currentTab)
    refreshBtn.Text = "Updated!"
    task.spawn(function()
        task.wait(1)
        refreshBtn.Text = "Refresh"
    end)
end)

exportBtn.MouseButton1Click:Connect(function()
    local exportText = contentText.Text
    if setclipboard then
        setclipboard(exportText)
        exportBtn.Text = "Copied!"
    else
        print(exportText)
        exportBtn.Text = "Printed"
    end
    task.spawn(function()
        task.wait(1)
        exportBtn.Text = "Export"
    end)
end)

teleportBtn.MouseButton1Click:Connect(function()
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        -- Simple teleport to first detected NPC for demo
        if detectedData.npcs then
            for name, pos in pairs(detectedData.npcs) do
                LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(pos)
                teleportBtn.Text = "Teleported!"
                task.spawn(function()
                    task.wait(1)
                    teleportBtn.Text = "Teleport"
                end)
                break
            end
        end
    end
end)

closeBtn.MouseButton1Click:Connect(function()
    screen:Destroy()
    print("NPC & Teleportation Detector closed")
end)

-- Initialize
switchTab("npcs")

print("🗺️ NPC & Teleportation Detector started!")
print("📍 Detecting all NPCs, islands, and teleportation points...")
print("💡 Use this data to update teleportation systems in main.lua")
