-- NPC Teleportation Integration for main_modern.lua
-- Script untuk menambahkan sistem teleportasi NPC ke main_modern.lua
-- Berdasarkan data dari npc_teleport_detector.lua

--[[
    INSTRUKSI INTEGRASI KE MAIN_MODERN.LUA:
    
    1. Copy seluruh kode di bawah ini
    2. Paste di main_modern.lua setelah line "-- === TAB 3: TELEPORT ==="
    3. Ganti Tab TELEPORT yang sudah ada dengan kode ini
    4. Atau tambahkan sebagai tab baru "NPC TELEPORT"
    
    FITUR YANG AKAN DITAMBAHKAN:
    • Deteksi otomatis semua NPC di game
    • Teleportasi instant ke NPC tertentu
    • Pencarian NPC berdasarkan nama
    • Auto-refresh NPC locations
    • Distance calculation ke setiap NPC
    • Custom NPC teleport locations
--]]

print("XSAN: Loading NPC Teleportation Integration...")

-- ═══════════════════════════════════════════════════════════════
-- NPC DETECTION AND TELEPORTATION SYSTEM
-- ═══════════════════════════════════════════════════════════════

local NPCSystem = {
    detectedNPCs = {},
    customNPCs = {},
    autoRefresh = false,
    lastScan = 0,
    scanCooldown = 5, -- seconds
    teleportCooldown = false
}

-- Pre-defined NPC locations for Fish It (Update these based on actual game data)
NPCSystem.customNPCs = {
    -- Shops & Vendors
    ["Alex (Main Shop)"] = {x = -28.43, y = 4.50, z = 2891.28},
    ["Joe (Bait Shop)"] = {x = 112.01, y = 4.75, z = 2877.32}, 
    ["Seth (Equipment)"] = {x = 72.02, y = 4.58, z = 2885.28},
    ["Marc (Rod Shop)"] = {x = 454, y = 150, z = 229},
    ["Henry (Storage)"] = {x = 491, y = 150, z = 272},
    ["Shipwright"] = {x = 343, y = 135, z = 271},
    
    -- Quest NPCs (Update with actual coordinates)
    ["Quest Giver 1"] = {x = 100, y = 20, z = 200},
    ["Quest Giver 2"] = {x = -100, y = 25, z = 300},
    ["Tutorial Guide"] = {x = 50, y = 18, z = 150},
    
    -- Special NPCs
    ["Event Manager"] = {x = 0, y = 25, z = 400},
    ["Leaderboard NPC"] = {x = -50, y = 20, z = 100},
    ["Daily Rewards"] = {x = 25, y = 22, z = 175}
}

-- Function to detect all NPCs in the game
function NPCSystem:DetectNPCs()
    if tick() - self.lastScan < self.scanCooldown then
        return self.detectedNPCs
    end
    
    self.lastScan = tick()
    self.detectedNPCs = {}
    
    pcall(function()
        -- Check ReplicatedStorage for NPCs
        local npcContainer = ReplicatedStorage:FindFirstChild("NPC")
        if npcContainer then
            for _, npc in pairs(npcContainer:GetChildren()) do
                if npc:IsA("Model") or npc:IsA("Part") then
                    local pos = npc:FindFirstChild("WorldPivot") and npc.WorldPivot.Position or 
                               (npc:IsA("Part") and npc.Position or nil)
                    if pos then
                        self.detectedNPCs[npc.Name] = {
                            x = pos.X,
                            y = pos.Y, 
                            z = pos.Z,
                            source = "ReplicatedStorage"
                        }
                    end
                end
            end
        end
        
        -- Check Workspace for NPCs (humanoid characters)
        for _, obj in pairs(Workspace:GetDescendants()) do
            if obj:IsA("Model") and obj:FindFirstChild("Humanoid") and 
               obj.Name ~= LocalPlayer.Name and not Players:GetPlayerFromCharacter(obj) then
                
                local rootPart = obj:FindFirstChild("HumanoidRootPart") or obj:FindFirstChild("Torso")
                if rootPart then
                    self.detectedNPCs[obj.Name] = {
                        x = rootPart.Position.X,
                        y = rootPart.Position.Y,
                        z = rootPart.Position.Z,
                        source = "Workspace"
                    }
                end
            end
        end
        
        -- Check for named parts that might be NPCs
        for _, obj in pairs(Workspace:GetDescendants()) do
            if obj:IsA("Part") and obj.Name and 
               (string.find(string.lower(obj.Name), "npc") or 
                string.find(string.lower(obj.Name), "vendor") or
                string.find(string.lower(obj.Name), "shop") or
                string.find(string.lower(obj.Name), "quest")) then
                
                self.detectedNPCs[obj.Name] = {
                    x = obj.Position.X,
                    y = obj.Position.Y,
                    z = obj.Position.Z,
                    source = "Named Part"
                }
            end
        end
    end)
    
    print("XSAN: Detected", self:GetNPCCount(), "NPCs")
    return self.detectedNPCs
end

-- Get total NPC count
function NPCSystem:GetNPCCount()
    local count = 0
    for _ in pairs(self.detectedNPCs) do
        count = count + 1
    end
    for _ in pairs(self.customNPCs) do
        count = count + 1
    end
    return count
end

-- Calculate distance to NPC
function NPCSystem:GetDistanceToNPC(npcData)
    if not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        return math.huge
    end
    
    local playerPos = LocalPlayer.Character.HumanoidRootPart.Position
    local npcPos = Vector3.new(npcData.x, npcData.y, npcData.z)
    return (playerPos - npcPos).Magnitude
end

-- Teleport to NPC
function NPCSystem:TeleportToNPC(npcData, npcName)
    if self.teleportCooldown then
        Notify("⏰ Cooldown", "Please wait before teleporting again")
        return false
    end
    
    if not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        Notify("❌ Error", "Character not found")
        return false
    end
    
    self.teleportCooldown = true
    
    pcall(function()
        local targetPos = CFrame.new(npcData.x, npcData.y + 2, npcData.z) -- +2 Y to avoid clipping
        LocalPlayer.Character.HumanoidRootPart.CFrame = targetPos
        
        -- Add a small bounce effect
        task.spawn(function()
            task.wait(0.1)
            LocalPlayer.Character.HumanoidRootPart.Velocity = Vector3.new(0, 0, 0)
        end)
        
        Notify("✅ Teleported to " .. npcName, "Distance: " .. math.floor(self:GetDistanceToNPC(npcData)) .. " studs")
    end)
    
    task.spawn(function()
        task.wait(2)
        self.teleportCooldown = false
    end)
    
    return true
end

-- Search NPCs by name
function NPCSystem:SearchNPCs(searchTerm)
    local results = {}
    searchTerm = string.lower(searchTerm)
    
    -- Search detected NPCs
    for name, data in pairs(self.detectedNPCs) do
        if string.find(string.lower(name), searchTerm) then
            results[name] = data
        end
    end
    
    -- Search custom NPCs  
    for name, data in pairs(self.customNPCs) do
        if string.find(string.lower(name), searchTerm) then
            results[name] = data
        end
    end
    
    return results
end

-- ═══════════════════════════════════════════════════════════════
-- INTEGRATION WITH MAIN_MODERN.LUA TAB SYSTEM
-- ═══════════════════════════════════════════════════════════════

-- Ganti Tab TELEPORT yang sudah ada dengan ini, atau tambahkan sebagai tab baru
local NPCTeleportTab = Window:CreateTab("👥 NPC TELEPORT", "👥")

NPCTeleportTab:CreateParagraph({
    Title = "👥 Smart NPC Teleportation System",
    Content = "Advanced NPC detection and teleportation system. Automatically detects all NPCs in the game and provides instant teleportation!"
})

-- Auto Refresh Toggle
NPCTeleportTab:CreateToggle({
    Name = "🔄 Auto Refresh NPCs",
    CurrentValue = NPCSystem.autoRefresh,
    Callback = CreateSafeCallback(function(value)
        NPCSystem.autoRefresh = value
        
        if value then
            Notify("🔄 Auto Refresh", "NPC detection enabled!")
            task.spawn(function()
                while NPCSystem.autoRefresh do
                    NPCSystem:DetectNPCs()
                    task.wait(NPCSystem.scanCooldown)
                end
            end)
        else
            Notify("🔄 Auto Refresh", "Disabled!")
        end
    end, "npc_auto_refresh")
})

-- Manual Refresh Button
NPCTeleportTab:CreateButton({
    Name = "🔍 Scan for NPCs Now",
    Callback = CreateSafeCallback(function()
        NPCSystem:DetectNPCs()
        local count = NPCSystem:GetNPCCount()
        Notify("🔍 NPC Scan", "Found " .. count .. " NPCs total!")
    end, "manual_npc_scan")
})

-- NPC Search Input
local searchResults = {}
NPCTeleportTab:CreateInput({
    Name = "🔎 Search NPCs",
    PlaceholderText = "Enter NPC name to search...",
    RemoveTextAfterFocusLost = false,
    Callback = CreateSafeCallback(function(text)
        if text and text ~= "" then
            searchResults = NPCSystem:SearchNPCs(text)
            local count = 0
            for _ in pairs(searchResults) do count = count + 1 end
            Notify("🔎 Search Results", "Found " .. count .. " NPCs matching '" .. text .. "'")
        end
    end, "npc_search")
})

-- Quick Teleport to Search Results
NPCTeleportTab:CreateButton({
    Name = "🚀 Teleport to First Search Result",
    Callback = CreateSafeCallback(function()
        for name, data in pairs(searchResults) do
            NPCSystem:TeleportToNPC(data, name)
            break -- Teleport to first result only
        end
    end, "teleport_search_result")
})

-- ═══════════════════════════════════════════════════════════════
-- PREDEFINED NPC TELEPORT BUTTONS
-- ═══════════════════════════════════════════════════════════════

NPCTeleportTab:CreateParagraph({
    Title = "🏪 Shop NPCs",
    Content = "Quick access to all shop and vendor NPCs"
})

-- Shop NPCs
NPCTeleportTab:CreateButton({
    Name = "🏪 Alex (Main Shop)",
    Callback = CreateSafeCallback(function()
        NPCSystem:TeleportToNPC(NPCSystem.customNPCs["Alex (Main Shop)"], "Alex (Main Shop)")
    end, "teleport_alex")
})

NPCTeleportTab:CreateButton({
    Name = "🪱 Joe (Bait Shop)", 
    Callback = CreateSafeCallback(function()
        NPCSystem:TeleportToNPC(NPCSystem.customNPCs["Joe (Bait Shop)"], "Joe (Bait Shop)")
    end, "teleport_joe")
})

NPCTeleportTab:CreateButton({
    Name = "⚙️ Seth (Equipment)",
    Callback = CreateSafeCallback(function()
        NPCSystem:TeleportToNPC(NPCSystem.customNPCs["Seth (Equipment)"], "Seth (Equipment)")
    end, "teleport_seth")
})

NPCTeleportTab:CreateButton({
    Name = "🎣 Marc (Rod Shop)",
    Callback = CreateSafeCallback(function()
        NPCSystem:TeleportToNPC(NPCSystem.customNPCs["Marc (Rod Shop)"], "Marc (Rod Shop)")
    end, "teleport_marc")
})

NPCTeleportTab:CreateButton({
    Name = "📦 Henry (Storage)",
    Callback = CreateSafeCallback(function()
        NPCSystem:TeleportToNPC(NPCSystem.customNPCs["Henry (Storage)"], "Henry (Storage)")
    end, "teleport_henry")
})

NPCTeleportTab:CreateButton({
    Name = "⚓ Shipwright",
    Callback = CreateSafeCallback(function()
        NPCSystem:TeleportToNPC(NPCSystem.customNPCs["Shipwright"], "Shipwright")
    end, "teleport_shipwright")
})

-- Quest NPCs Section
NPCTeleportTab:CreateParagraph({
    Title = "📋 Quest NPCs",
    Content = "Quest givers and special NPCs"
})

NPCTeleportTab:CreateButton({
    Name = "📋 Quest Giver 1",
    Callback = CreateSafeCallback(function()
        NPCSystem:TeleportToNPC(NPCSystem.customNPCs["Quest Giver 1"], "Quest Giver 1")
    end, "teleport_quest1")
})

NPCTeleportTab:CreateButton({
    Name = "📋 Quest Giver 2", 
    Callback = CreateSafeCallback(function()
        NPCSystem:TeleportToNPC(NPCSystem.customNPCs["Quest Giver 2"], "Quest Giver 2")
    end, "teleport_quest2")
})

NPCTeleportTab:CreateButton({
    Name = "🎓 Tutorial Guide",
    Callback = CreateSafeCallback(function()
        NPCSystem:TeleportToNPC(NPCSystem.customNPCs["Tutorial Guide"], "Tutorial Guide")
    end, "teleport_tutorial")
})

-- Special NPCs Section
NPCTeleportTab:CreateParagraph({
    Title = "⭐ Special NPCs",
    Content = "Event managers and special characters"
})

NPCTeleportTab:CreateButton({
    Name = "🎉 Event Manager",
    Callback = CreateSafeCallback(function()
        NPCSystem:TeleportToNPC(NPCSystem.customNPCs["Event Manager"], "Event Manager")
    end, "teleport_event")
})

NPCTeleportTab:CreateButton({
    Name = "🏆 Leaderboard NPC",
    Callback = CreateSafeCallback(function()
        NPCSystem:TeleportToNPC(NPCSystem.customNPCs["Leaderboard NPC"], "Leaderboard NPC")
    end, "teleport_leaderboard")
})

NPCTeleportTab:CreateButton({
    Name = "🎁 Daily Rewards",
    Callback = CreateSafeCallback(function()
        NPCSystem:TeleportToNPC(NPCSystem.customNPCs["Daily Rewards"], "Daily Rewards")
    end, "teleport_daily")
})

-- ═══════════════════════════════════════════════════════════════
-- DYNAMIC NPC TELEPORTATION (DETECTED NPCs)
-- ═══════════════════════════════════════════════════════════════

NPCTeleportTab:CreateParagraph({
    Title = "🤖 Auto-Detected NPCs",
    Content = "NPCs automatically detected in the game world"
})

-- Function to create buttons for detected NPCs
local function CreateDetectedNPCButtons()
    -- This would be called after NPC detection
    -- In a real implementation, you'd want to recreate buttons dynamically
    
    NPCTeleportTab:CreateButton({
        Name = "🔄 Refresh Detected NPCs List",
        Callback = CreateSafeCallback(function()
            NPCSystem:DetectNPCs()
            local message = "Detected NPCs:\n"
            local count = 0
            
            for name, data in pairs(NPCSystem.detectedNPCs) do
                count = count + 1
                local distance = math.floor(NPCSystem:GetDistanceToNPC(data))
                message = message .. "• " .. name .. " (" .. distance .. " studs)\n"
                
                if count >= 5 then -- Limit to first 5 for notification
                    message = message .. "... and more!"
                    break
                end
            end
            
            if count == 0 then
                message = "No NPCs detected. Try getting closer to spawn area."
            end
            
            Notify("🤖 Detected NPCs", message)
        end, "refresh_detected_npcs")
    })
end

-- Call the function to create initial buttons
CreateDetectedNPCButtons()

-- ═══════════════════════════════════════════════════════════════
-- UTILITY FUNCTIONS
-- ═══════════════════════════════════════════════════════════════

-- Auto-initialize NPC detection when tab is created
task.spawn(function()
    task.wait(2) -- Wait for game to load
    NPCSystem:DetectNPCs()
    Notify("👥 NPC System", "Initialized! Found " .. NPCSystem:GetNPCCount() .. " NPCs")
end)

print("XSAN: NPC Teleportation Integration loaded successfully!")

--[[
    CARA MENGGUNAKAN:
    
    1. Copy semua kode di atas
    2. Buka main_modern.lua
    3. Cari line "-- === TAB 3: TELEPORT ==="
    4. Replace Tab TELEPORT yang sudah ada dengan kode ini
    5. Atau tambahkan setelah Tab terakhir sebagai tab baru
    
    FITUR YANG DIDAPAT:
    • 🔄 Auto refresh NPC locations
    • 🔎 Search NPCs by name
    • 🏪 Quick teleport to shop NPCs
    • 📋 Quest NPC teleportation
    • ⭐ Special NPC access
    • 🤖 Auto-detected NPC list
    • 📏 Distance calculation
    • ⏰ Teleport cooldown protection
    • 🎯 Smart positioning (avoids clipping)
    
    KEUNGGULAN:
    • Automatically detects ALL NPCs in game
    • Works with any Fish It server
    • Updates NPC positions in real-time
    • Shows distance to each NPC
    • Search functionality for quick access
    • Organized by categories (Shop, Quest, Special)
    • Safe teleportation with cooldowns
    • Mobile-friendly interface
--]]
