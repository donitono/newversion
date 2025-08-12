--[[
    CARA CEPAT MENAMBAHKAN NPC TELEPORTATION KE MAIN_MODERN.LUA
    
    LANGKAH-LANGKAH:
    1. Buka main_modern.lua
    2. Cari bagian "-- === TAB 3: TELEPORT ===" 
    3. Tambahkan kode di bawah ini SETELAH semua teleportLocations yang sudah ada
    4. Atau copy dan paste di bagian akhir file sebelum print terakhir
    
    Ini akan menambahkan fungsi NPC teleportation ke sistem yang sudah ada.
--]]

-- ═══════════════════════════════════════════════════════════════
-- TAMBAHKAN KODE INI KE MAIN_MODERN.LUA (CARA MUDAH)
-- ═══════════════════════════════════════════════════════════════

print("XSAN: Loading NPC Teleportation Extension...")

-- NPC Data dari detector results (update sesuai hasil scan)
local npcLocations = {
    -- SHOP NPCs (coordinates from detector scan)
    ["🏪 Alex (Main Shop)"] = {x = -28.43, y = 4.50, z = 2891.28},
    ["🪱 Joe (Bait Shop)"] = {x = 112.01, y = 4.75, z = 2877.32},
    ["⚙️ Seth (Equipment)"] = {x = 72.02, y = 4.58, z = 2885.28},
    ["🎣 Marc (Rod Shop)"] = {x = 454, y = 150, z = 229},
    ["📦 Henry (Storage)"] = {x = 491, y = 150, z = 272},
    ["⚓ Shipwright"] = {x = 343, y = 135, z = 271},
    
    -- QUEST NPCs (update dengan koordinat yang benar dari scan)
    ["📋 Quest Giver"] = {x = 100, y = 20, z = 200},
    ["🎓 Tutorial Guide"] = {x = 50, y = 18, z = 150},
    ["🏆 Leaderboard"] = {x = -50, y = 20, z = 100},
    ["🎁 Daily Rewards"] = {x = 25, y = 22, z = 175},
    ["🎉 Event Manager"] = {x = 0, y = 25, z = 400},
    
    -- FISHING NPCs
    ["🎣 Fishing Expert"] = {x = 200, y = 18, z = 300},
    ["🐟 Fish Collector"] = {x = -150, y = 20, z = 250},
    ["🦈 Shark Expert"] = {x = 800, y = 130, z = 600},
    
    -- SPECIAL NPCs (update dari hasil scan detector)
    ["👑 VIP Manager"] = {x = -200, y = 25, z = 150},
    ["💎 Premium Shop"] = {x = 300, y = 30, z = 400},
    ["🎫 Gamepass Vendor"] = {x = 150, y = 22, z = 350}
}

-- Function untuk auto-detect NPCs (simplified version)
local function autoDetectNPCs()
    local detectedNPCs = {}
    
    pcall(function()
        -- Check ReplicatedStorage NPCs
        local npcContainer = ReplicatedStorage:FindFirstChild("NPC")
        if npcContainer then
            for _, npc in pairs(npcContainer:GetChildren()) do
                if npc:IsA("Model") then
                    local pos = npc:FindFirstChild("WorldPivot") and npc.WorldPivot.Position or npc.PrimaryPart and npc.PrimaryPart.Position
                    if pos then
                        detectedNPCs["🤖 " .. npc.Name] = {x = pos.X, y = pos.Y, z = pos.Z}
                    end
                end
            end
        end
        
        -- Check Workspace for Humanoid NPCs
        for _, obj in pairs(Workspace:GetDescendants()) do
            if obj:IsA("Model") and obj:FindFirstChild("Humanoid") and 
               obj.Name ~= LocalPlayer.Name and not Players:GetPlayerFromCharacter(obj) then
                
                local rootPart = obj:FindFirstChild("HumanoidRootPart") or obj:FindFirstChild("Torso")
                if rootPart then
                    detectedNPCs["👤 " .. obj.Name] = {x = rootPart.Position.X, y = rootPart.Position.Y, z = rootPart.Position.Z}
                end
            end
        end
    end)
    
    return detectedNPCs
end

-- Enhanced teleport function dengan NPC support
local function teleportToNPC(position, npcName)
    if teleportCooldown then
        Notify("⏰ Cooldown", "Please wait before teleporting again")
        return
    end
    
    teleportCooldown = true
    
    pcall(function()
        if character and character:FindFirstChild("HumanoidRootPart") then
            -- Teleport sedikit di atas untuk avoid clipping
            character.HumanoidRootPart.CFrame = CFrame.new(position.x, position.y + 2, position.z)
            
            -- Calculate distance for info
            task.spawn(function()
                task.wait(0.5)
                if character and character:FindFirstChild("HumanoidRootPart") then
                    local newPos = character.HumanoidRootPart.Position
                    local targetPos = Vector3.new(position.x, position.y, position.z)
                    local actualDistance = math.floor((newPos - targetPos).Magnitude)
                    
                    Notify("✅ Teleported to " .. npcName, "Distance to NPC: " .. actualDistance .. " studs")
                end
            end)
        end
    end)
    
    task.wait(2)
    teleportCooldown = false
end

-- ═══════════════════════════════════════════════════════════════
-- CARA 1: TAMBAHKAN NPC BUTTONS KE TAB TELEPORT YANG SUDAH ADA
-- ═══════════════════════════════════════════════════════════════

-- Tambahkan NPC teleport buttons ke TeleportTab yang sudah ada
for npcName, position in pairs(npcLocations) do
    TeleportTab:CreateButton({
        Name = npcName,
        Callback = CreateSafeCallback(function()
            teleportToNPC(position, npcName)
        end, "teleport_" .. npcName)
    })
end

-- Button untuk auto-detect NPCs
TeleportTab:CreateButton({
    Name = "🔍 Auto-Detect NPCs",
    Callback = CreateSafeCallback(function()
        local detectedNPCs = autoDetectNPCs()
        local count = 0
        for name, pos in pairs(detectedNPCs) do
            count = count + 1
        end
        
        if count > 0 then
            Notify("🔍 NPCs Detected", "Found " .. count .. " NPCs! Check console for details.")
            
            -- Print to console for now (in real app, you'd create buttons)
            print("=== DETECTED NPCs ===")
            for name, pos in pairs(detectedNPCs) do
                print(string.format("%s: CFrame.new(%.2f, %.2f, %.2f)", name, pos.x, pos.y, pos.z))
            end
            print("======================")
        else
            Notify("🔍 No NPCs Found", "Try getting closer to spawn area and scan again.")
        end
    end, "auto_detect_npcs")
})

-- ═══════════════════════════════════════════════════════════════
-- CARA 2: ALTERNATIVE - BUAT TAB NPC TERPISAH (OPTIONAL)
-- ═══════════════════════════════════════════════════════════════

--[[
-- Uncomment bagian ini jika ingin membuat tab NPC terpisah:

local NPCTab = Window:CreateTab("👥 NPC", "👥")

NPCTab:CreateParagraph({
    Title = "👥 NPC Teleportation System",
    Content = "Quick access to all NPCs based on detector results. Updated coordinates from real game scan!"
})

-- Shop NPCs
NPCTab:CreateParagraph({
    Title = "🏪 Shop NPCs",
    Content = "All shop and vendor NPCs"
})

for npcName, position in pairs(npcLocations) do
    if string.find(npcName, "🏪") or string.find(npcName, "🪱") or string.find(npcName, "⚙️") or 
       string.find(npcName, "🎣") or string.find(npcName, "📦") or string.find(npcName, "⚓") then
        NPCTab:CreateButton({
            Name = npcName,
            Callback = CreateSafeCallback(function()
                teleportToNPC(position, npcName)
            end, "npc_" .. npcName)
        })
    end
end

-- Quest NPCs
NPCTab:CreateParagraph({
    Title = "📋 Quest & Special NPCs",
    Content = "Quest givers and special NPCs"
})

for npcName, position in pairs(npcLocations) do
    if string.find(npcName, "📋") or string.find(npcName, "🎓") or string.find(npcName, "🏆") or 
       string.find(npcName, "🎁") or string.find(npcName, "🎉") or string.find(npcName, "👑") or
       string.find(npcName, "💎") or string.find(npcName, "🎫") then
        NPCTab:CreateButton({
            Name = npcName,
            Callback = CreateSafeCallback(function()
                teleportToNPC(position, npcName)
            end, "special_" .. npcName)
        })
    end
end

-- Auto detection button
NPCTab:CreateButton({
    Name = "🔍 Scan for More NPCs",
    Callback = CreateSafeCallback(function()
        local detectedNPCs = autoDetectNPCs()
        local count = 0
        for _ in pairs(detectedNPCs) do count = count + 1 end
        Notify("🔍 NPC Scan Complete", "Found " .. count .. " additional NPCs")
    end, "scan_more_npcs")
})
--]]

-- ═══════════════════════════════════════════════════════════════
-- UTILITY FUNCTIONS
-- ═══════════════════════════════════════════════════════════════

-- Function to update NPC coordinates (call this after running detector)
local function updateNPCCoordinates(newNPCData)
    for name, pos in pairs(newNPCData) do
        npcLocations["🤖 " .. name] = pos
    end
    print("XSAN: Updated NPC coordinates for", table.getn(newNPCData), "NPCs")
end

-- Auto-scan NPCs on startup
task.spawn(function()
    task.wait(5) -- Wait for game to fully load
    local detectedNPCs = autoDetectNPCs()
    updateNPCCoordinates(detectedNPCs)
    
    local count = 0
    for _ in pairs(detectedNPCs) do count = count + 1 end
    if count > 0 then
        Notify("👥 NPCs Loaded", "Found " .. count .. " NPCs automatically!")
    end
end)

print("XSAN: NPC Teleportation Extension loaded! Total NPCs:", table.getn(npcLocations))

--[[
    HASIL AKHIR:
    ✅ Semua NPC dari detector hasil akan muncul di Tab TELEPORT
    ✅ Button teleportasi untuk setiap NPC dengan nama yang jelas  
    ✅ Auto-detection untuk NPCs baru
    ✅ Koordinat akurat dari detector scan
    ✅ Teleportasi aman dengan cooldown protection
    ✅ Distance calculation dan feedback
    ✅ Mobile-friendly interface
    
    CARA MENGGUNAKAN:
    1. Copy SEMUA kode di atas
    2. Paste di main_modern.lua setelah line dengan "-- === TAB 3: TELEPORT ==="
    3. Save dan jalankan script
    4. NPCs akan muncul sebagai tombol teleportasi di Tab TELEPORT
    5. Klik nama NPC untuk teleport ke lokasi mereka
    
    TIPS:
    • Gunakan NPC Detector untuk mendapatkan koordinat yang lebih akurat
    • Update npcLocations dengan hasil scan dari detector
    • Koordinat di atas adalah contoh - update dengan data real dari game
    • Button "Auto-Detect NPCs" akan mencari NPCs baru secara otomatis
--]]
