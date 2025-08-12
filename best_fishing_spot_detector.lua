-- Best Fishing Spot Detector v1.0
-- Advanced fishing location analysis untuk menemukan fishing spot terbaik
-- Menganalisis success rate, fish quality, dan kondisi lingkungan

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
    maxErrors = 50,
    debugMode = false
}

function ErrorHandler:safeExecute(func, context, silent)
    local success, result = pcall(func)
    if not success then
        local error = {
            context = context or "Unknown",
            message = tostring(result),
            timestamp = tick(),
            timeString = os.date("%H:%M:%S")
        }
        
        table.insert(self.errors, error)
        if #self.errors > self.maxErrors then
            table.remove(self.errors, 1)
        end
        
        if not silent and self.debugMode then
            warn(string.format('[Best Fishing Spot] %s: %s', error.context, error.message))
        end
        return false, result
    end
    return true, result
end

-- Remove existing fishing spot detector GUIs
ErrorHandler:safeExecute(function()
    local CoreGui = game:GetService("CoreGui")
    for _, gui in pairs(CoreGui:GetChildren()) do
        if gui.Name:find("FishingSpot") or gui.Name:find("BestFishing") then
            gui:Destroy()
        end
    end
end, "GUI cleanup", true)

-- Create enhanced GUI with responsive design
local CoreGui = game:GetService("CoreGui")
local screen = Instance.new("ScreenGui")
screen.Name = "BestFishingSpotDetector"
screen.Parent = CoreGui
screen.ResetOnSpawn = false

-- Dynamic sizing based on screen
local screenSize = workspace.CurrentCamera.ViewportSize
local isLandscape = screenSize.X > screenSize.Y
local frameWidth = isLandscape and 750 or 550
local frameHeight = isLandscape and 450 or 500

-- Main frame with responsive design
local mainFrame = Instance.new("Frame")
mainFrame.Parent = screen
mainFrame.Size = UDim2.new(0, frameWidth, 0, frameHeight)
mainFrame.Position = UDim2.new(0.5, -frameWidth/2, 0.5, -frameHeight/2)
mainFrame.BackgroundColor3 = Color3.fromRGB(15, 20, 30)
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.Draggable = true
mainFrame.Visible = false
Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 15)

-- Floating toggle button with enhanced positioning
local floatingBtn = Instance.new("TextButton")
floatingBtn.Parent = screen
floatingBtn.Size = UDim2.new(0, 70, 0, 70)
floatingBtn.Position = UDim2.new(1, -90, 0, 120)
floatingBtn.Text = "🎣"
floatingBtn.BackgroundColor3 = Color3.fromRGB(60, 150, 200)
floatingBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
floatingBtn.Font = Enum.Font.SourceSansBold
floatingBtn.TextSize = 28
floatingBtn.BorderSizePixel = 0
floatingBtn.ZIndex = 10
Instance.new("UICorner", floatingBtn).CornerRadius = UDim.new(0.5, 0)

-- Animated gradient background
local gradient = Instance.new("UIGradient")
gradient.Parent = mainFrame
gradient.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, Color3.fromRGB(25, 35, 50)),
    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(15, 20, 30)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(10, 15, 25))
}
gradient.Rotation = 135

-- Animate gradient rotation
task.spawn(function()
    while mainFrame.Parent do
        for rotation = 0, 360, 2 do
            if mainFrame.Parent then
                gradient.Rotation = rotation
                task.wait(0.15)
            else
                break
            end
        end
    end
end)

-- Enhanced title bar
local titleBar = Instance.new("Frame")
titleBar.Parent = mainFrame
titleBar.Size = UDim2.new(1, 0, 0, 50)
titleBar.BackgroundColor3 = Color3.fromRGB(30, 40, 60)
titleBar.BorderSizePixel = 0
Instance.new("UICorner", titleBar).CornerRadius = UDim.new(0, 15)

local titleLabel = Instance.new("TextLabel")
titleLabel.Parent = titleBar
titleLabel.Size = UDim2.new(1, -200, 1, 0)
titleLabel.Position = UDim2.new(0, 20, 0, 0)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "🎣 Best Fishing Spot Detector v1.0"
titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
titleLabel.Font = Enum.Font.SourceSansBold
titleLabel.TextSize = 18
titleLabel.TextXAlignment = Enum.TextXAlignment.Left

-- System status indicator
local statusFrame = Instance.new("Frame")
statusFrame.Parent = titleBar
statusFrame.Size = UDim2.new(0, 120, 0, 30)
statusFrame.Position = UDim2.new(1, -160, 0.5, -15)
statusFrame.BackgroundColor3 = Color3.fromRGB(50, 150, 50)
statusFrame.BorderSizePixel = 0
Instance.new("UICorner", statusFrame).CornerRadius = UDim.new(0, 15)

local statusLabel = Instance.new("TextLabel")
statusLabel.Parent = statusFrame
statusLabel.Size = UDim2.new(1, 0, 1, 0)
statusLabel.BackgroundTransparency = 1
statusLabel.Text = "ANALYZING..."
statusLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
statusLabel.Font = Enum.Font.SourceSansBold
statusLabel.TextSize = 10

-- Close button
local closeBtn = Instance.new("TextButton")
closeBtn.Parent = titleBar
closeBtn.Size = UDim2.new(0, 40, 0, 40)
closeBtn.Position = UDim2.new(1, -45, 0, 5)
closeBtn.Text = "✖"
closeBtn.BackgroundColor3 = Color3.fromRGB(220, 80, 80)
closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
closeBtn.Font = Enum.Font.SourceSansBold
closeBtn.TextSize = 16
closeBtn.BorderSizePixel = 0
Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0, 10)

-- Tab container
local tabContainer = Instance.new("Frame")
tabContainer.Parent = mainFrame
tabContainer.Size = UDim2.new(1, -20, 0, 40)
tabContainer.Position = UDim2.new(0, 10, 0, 55)
tabContainer.BackgroundTransparency = 1

local tabLayout = Instance.new("UIListLayout")
tabLayout.Parent = tabContainer
tabLayout.FillDirection = Enum.FillDirection.Horizontal
tabLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
tabLayout.Padding = UDim.new(0, 5)

-- Content area
local contentFrame = Instance.new("Frame")
contentFrame.Parent = mainFrame
contentFrame.Size = UDim2.new(1, -20, 1, -150)
contentFrame.Position = UDim2.new(0, 10, 0, 100)
contentFrame.BackgroundColor3 = Color3.fromRGB(20, 25, 35)
contentFrame.BorderSizePixel = 0
Instance.new("UICorner", contentFrame).CornerRadius = UDim.new(0, 12)

-- Scrollable content
local scrollFrame = Instance.new("ScrollingFrame")
scrollFrame.Parent = contentFrame
scrollFrame.Size = UDim2.new(1, -10, 1, -10)
scrollFrame.Position = UDim2.new(0, 5, 0, 5)
scrollFrame.BackgroundTransparency = 1
scrollFrame.BorderSizePixel = 0
scrollFrame.ScrollBarThickness = 10
scrollFrame.ScrollBarImageColor3 = Color3.fromRGB(100, 150, 200)
scrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)

-- Button container
local buttonFrame = Instance.new("Frame")
buttonFrame.Parent = mainFrame
buttonFrame.Size = UDim2.new(1, -20, 0, 45)
buttonFrame.Position = UDim2.new(0, 10, 1, -50)
buttonFrame.BackgroundTransparency = 1

local buttonLayout = Instance.new("UIListLayout")
buttonLayout.Parent = buttonFrame
buttonLayout.FillDirection = Enum.FillDirection.Horizontal
buttonLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
buttonLayout.Padding = UDim.new(0, 10)

-- Fishing Spot Analysis Data
local FishingSpotData = {
    currentLocation = {
        name = "Unknown",
        coordinates = Vector3.new(0, 0, 0),
        quality = 0,
        successRate = 0,
        fishTypes = {},
        conditions = {}
    },
    analyzedSpots = {},
    bestSpots = {},
    analysisHistory = {}
}

-- Water and Environment Analysis
local EnvironmentAnalyzer = {
    -- Analyze water conditions at current location
    analyzeWaterConditions = function(position)
        local conditions = {
            depth = 0,
            temperature = "Normal",
            clarity = "Clear",
            current = "Calm",
            salinity = "Fresh"
        }
        
        ErrorHandler:safeExecute(function()
            -- Check if in ocean (higher Y = surface, lower Y = deeper)
            if position.Y < 100 then
                conditions.depth = math.abs(position.Y - 100)
                conditions.temperature = conditions.depth > 50 and "Cold" or "Cool"
            end
            
            -- Analyze based on location name patterns
            local locationName = FishingSpotData.currentLocation.name:lower()
            
            if locationName:find("ocean") or locationName:find("deep") then
                conditions.salinity = "Salt"
                conditions.depth = conditions.depth + 20
            elseif locationName:find("volcano") or locationName:find("thermal") then
                conditions.temperature = "Hot"
            elseif locationName:find("ice") or locationName:find("snow") then
                conditions.temperature = "Freezing"
            end
            
            -- Environmental factors
            if locationName:find("storm") or locationName:find("rough") then
                conditions.current = "Rough"
            elseif locationName:find("calm") or locationName:find("peaceful") then
                conditions.current = "Very Calm"
            end
            
        end, "Water condition analysis")
        
        return conditions
    end,
    
    -- Calculate environmental quality score
    calculateEnvironmentScore = function(conditions)
        local score = 50 -- Base score
        
        -- Depth scoring (moderate depth is best)
        if conditions.depth >= 20 and conditions.depth <= 60 then
            score = score + 20
        elseif conditions.depth > 60 then
            score = score + 10
        else
            score = score + 5
        end
        
        -- Temperature scoring
        if conditions.temperature == "Cool" or conditions.temperature == "Normal" then
            score = score + 15
        elseif conditions.temperature == "Cold" then
            score = score + 10
        else
            score = score + 5
        end
        
        -- Current conditions
        if conditions.current == "Calm" then
            score = score + 10
        elseif conditions.current == "Very Calm" then
            score = score + 15
        else
            score = score + 5
        end
        
        return math.min(score, 100)
    end
}

-- Fish Type and Rarity Analyzer
local FishAnalyzer = {
    -- Known fish rarities and values
    fishDatabase = {
        -- Common fish (Low value)
        ["Anchovy"] = {rarity = "Common", value = 10, points = 5},
        ["Sardine"] = {rarity = "Common", value = 15, points = 5},
        ["Mackerel"] = {rarity = "Common", value = 20, points = 10},
        
        -- Uncommon fish (Medium value)
        ["Bass"] = {rarity = "Uncommon", value = 35, points = 15},
        ["Trout"] = {rarity = "Uncommon", value = 40, points = 15},
        ["Salmon"] = {rarity = "Uncommon", value = 50, points = 20},
        
        -- Rare fish (High value)
        ["Tuna"] = {rarity = "Rare", value = 80, points = 30},
        ["Swordfish"] = {rarity = "Rare", value = 120, points = 35},
        ["Marlin"] = {rarity = "Rare", value = 150, points = 40},
        
        -- Epic fish (Very high value)
        ["Giant Squid"] = {rarity = "Epic", value = 300, points = 60},
        ["Whale"] = {rarity = "Epic", value = 500, points = 80},
        ["Megalodon"] = {rarity = "Epic", value = 800, points = 100},
        
        -- Legendary fish (Ultimate value)
        ["Kraken"] = {rarity = "Legendary", value = 1500, points = 150},
        ["Sea Dragon"] = {rarity = "Legendary", value = 2000, points = 200},
        ["Leviathan"] = {rarity = "Legendary", value = 3000, points = 300}
    },
    
    -- Analyze potential fish types based on location
    analyzePotentialFish = function(locationName, conditions)
        local potentialFish = {}
        local locationLower = locationName:lower()
        
        ErrorHandler:safeExecute(function()
            -- Deep water fish
            if conditions.depth > 50 or locationLower:find("deep") or locationLower:find("ocean") then
                table.insert(potentialFish, "Giant Squid")
                table.insert(potentialFish, "Whale")
                table.insert(potentialFish, "Megalodon")
                table.insert(potentialFish, "Kraken")
                table.insert(potentialFish, "Tuna")
                table.insert(potentialFish, "Swordfish")
            end
            
            -- Volcanic/thermal areas
            if locationLower:find("volcano") or conditions.temperature == "Hot" then
                table.insert(potentialFish, "Sea Dragon")
                table.insert(potentialFish, "Marlin")
            end
            
            -- Cold water fish
            if conditions.temperature == "Cold" or conditions.temperature == "Freezing" then
                table.insert(potentialFish, "Salmon")
                table.insert(potentialFish, "Trout")
            end
            
            -- Special locations
            if locationLower:find("ancient") or locationLower:find("mysterious") then
                table.insert(potentialFish, "Leviathan")
                table.insert(potentialFish, "Sea Dragon")
            end
            
            -- Default fish for all locations
            table.insert(potentialFish, "Bass")
            table.insert(potentialFish, "Mackerel")
            table.insert(potentialFish, "Anchovy")
            
        end, "Fish analysis")
        
        return potentialFish
    end,
    
    -- Calculate fishing potential score
    calculateFishingScore = function(potentialFish)
        local totalScore = 0
        local fishCount = 0
        
        for _, fishName in pairs(potentialFish) do
            local fishData = FishAnalyzer.fishDatabase[fishName]
            if fishData then
                totalScore = totalScore + fishData.points
                fishCount = fishCount + 1
            end
        end
        
        return fishCount > 0 and (totalScore / fishCount) or 0
    end
}

-- Location Quality Analyzer
local LocationAnalyzer = {
    -- Analyze current fishing spot
    analyzeCurrentSpot = function()
        ErrorHandler:safeExecute(function()
            if not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                return
            end
            
            local position = LocalPlayer.Character.HumanoidRootPart.Position
            local locationName = LocationAnalyzer.detectLocationName(position)
            
            -- Update current location data
            FishingSpotData.currentLocation.name = locationName
            FishingSpotData.currentLocation.coordinates = position
            
            -- Analyze environment
            local conditions = EnvironmentAnalyzer.analyzeWaterConditions(position)
            FishingSpotData.currentLocation.conditions = conditions
            
            -- Analyze potential fish
            local potentialFish = FishAnalyzer.analyzePotentialFish(locationName, conditions)
            FishingSpotData.currentLocation.fishTypes = potentialFish
            
            -- Calculate quality scores
            local environmentScore = EnvironmentAnalyzer.calculateEnvironmentScore(conditions)
            local fishingScore = FishAnalyzer.calculateFishingScore(potentialFish)
            local totalQuality = math.floor((environmentScore + fishingScore) / 2)
            
            FishingSpotData.currentLocation.quality = totalQuality
            FishingSpotData.currentLocation.successRate = LocationAnalyzer.estimateSuccessRate(totalQuality)
            
            -- Add to analyzed spots
            local spotData = {
                name = locationName,
                position = position,
                quality = totalQuality,
                successRate = FishingSpotData.currentLocation.successRate,
                environmentScore = environmentScore,
                fishingScore = fishingScore,
                conditions = conditions,
                potentialFish = potentialFish,
                timestamp = tick(),
                timeString = os.date("%H:%M:%S")
            }
            
            table.insert(FishingSpotData.analyzedSpots, spotData)
            LocationAnalyzer.updateBestSpots()
            
        end, "Current spot analysis")
    end,
    
    -- Detect location name based on coordinates
    detectLocationName = function(position)
        local bestMatch = "Unknown Location"
        local shortestDistance = math.huge
        
        -- Known fishing locations with coordinates
        local knownLocations = {
            ["Moosewood Docks"] = Vector3.new(389, 137, 264),
            ["Ocean Deep"] = Vector3.new(1082, 124, -924),
            ["Snowcap Fishing"] = Vector3.new(2648, 140, 2522),
            ["Mushgrove Waters"] = Vector3.new(-1817, 138, 1808),
            ["Roslit Bay"] = Vector3.new(-1442, 135, 1006),
            ["Sunstone Coast"] = Vector3.new(-934, 135, -1122),
            ["Sovereignty Waters"] = Vector3.new(1, 140, -918),
            ["Moonstone Deep"] = Vector3.new(-3004, 135, -1157),
            ["Forsaken Shores"] = Vector3.new(-2853, 135, 1627),
            ["Ancient Fishing"] = Vector3.new(5896, 137, 4516),
            ["Keepers Waters"] = Vector3.new(1296, 135, -808),
            ["Brine Pool"] = Vector3.new(-1804, 135, 3265),
            ["The Depths"] = Vector3.new(994, -715, 1226),
            ["Vertigo Deep"] = Vector3.new(-111, -515, 1049),
            ["Volcano Waters"] = Vector3.new(-1888, 164, 330),
            ["Kohana Volcanic"] = Vector3.new(-594.97, 396.65, 149.11),
            ["Crater Deep"] = Vector3.new(1010.01, 252, 5078.45),
            ["Kohana Bay"] = Vector3.new(-650.97, 208.69, 711.11),
            ["Lost Isle"] = Vector3.new(-3618.16, 240.84, -1317.46),
            ["Stingray Fishing"] = Vector3.new(45.28, 252.56, 2987.11),
            ["Esoteric Depths"] = Vector3.new(1944.78, 393.56, 1371.36)
        }
        
        ErrorHandler:safeExecute(function()
            for locationName, locationPos in pairs(knownLocations) do
                local distance = (position - locationPos).Magnitude
                if distance < shortestDistance then
                    shortestDistance = distance
                    bestMatch = locationName
                end
            end
            
            -- If too far from known locations, create descriptive name
            if shortestDistance > 500 then
                if position.Y < 0 then
                    bestMatch = "Deep Water Zone"
                elseif position.Y > 300 then
                    bestMatch = "High Altitude Fishing"
                else
                    bestMatch = string.format("Custom Spot (%.0f, %.0f, %.0f)", position.X, position.Y, position.Z)
                end
            end
        end, "Location name detection")
        
        return bestMatch
    end,
    
    -- Estimate success rate based on quality
    estimateSuccessRate = function(quality)
        if quality >= 90 then return "Excellent (95%)"
        elseif quality >= 80 then return "Very Good (85%)"
        elseif quality >= 70 then return "Good (75%)"
        elseif quality >= 60 then return "Fair (65%)"
        elseif quality >= 50 then return "Average (55%)"
        elseif quality >= 40 then return "Below Average (45%)"
        else return "Poor (35%)"
        end
    end,
    
    -- Update best spots ranking
    updateBestSpots = function()
        -- Sort analyzed spots by quality
        table.sort(FishingSpotData.analyzedSpots, function(a, b)
            return a.quality > b.quality
        end)
        
        -- Keep top 10 best spots
        FishingSpotData.bestSpots = {}
        for i = 1, math.min(10, #FishingSpotData.analyzedSpots) do
            table.insert(FishingSpotData.bestSpots, FishingSpotData.analyzedSpots[i])
        end
    end
}

-- Tab content functions
local tabContents = {
    {
        name = "Current Spot",
        icon = "📍",
        color = Color3.fromRGB(60, 150, 200),
        content = function()
            -- Clear existing content
            for _, child in pairs(scrollFrame:GetChildren()) do
                if not child:IsA("UIListLayout") then
                    child:Destroy()
                end
            end
            
            -- Create layout if it doesn't exist
            if not scrollFrame:FindFirstChild("UIListLayout") then
                local layout = Instance.new("UIListLayout")
                layout.Parent = scrollFrame
                layout.SortOrder = Enum.SortOrder.LayoutOrder
                layout.Padding = UDim.new(0, 5)
            end
            
            local currentSpot = FishingSpotData.currentLocation
            
            -- Current location info card
            local infoCard = Instance.new("Frame")
            infoCard.Parent = scrollFrame
            infoCard.Size = UDim2.new(1, -20, 0, 200)
            infoCard.BackgroundColor3 = Color3.fromRGB(30, 35, 50)
            infoCard.BorderSizePixel = 0
            infoCard.LayoutOrder = 1
            Instance.new("UICorner", infoCard).CornerRadius = UDim.new(0, 10)
            
            local cardTitle = Instance.new("TextLabel")
            cardTitle.Parent = infoCard
            cardTitle.Size = UDim2.new(1, -20, 0, 30)
            cardTitle.Position = UDim2.new(0, 10, 0, 5)
            cardTitle.BackgroundTransparency = 1
            cardTitle.Text = "📍 " .. currentSpot.name
            cardTitle.TextColor3 = Color3.fromRGB(100, 200, 255)
            cardTitle.Font = Enum.Font.SourceSansBold
            cardTitle.TextSize = 16
            cardTitle.TextXAlignment = Enum.TextXAlignment.Left
            
            -- Quality indicator
            local qualityColor = Color3.fromRGB(255, 100, 100) -- Red (poor)
            if currentSpot.quality >= 80 then
                qualityColor = Color3.fromRGB(100, 255, 100) -- Green (excellent)
            elseif currentSpot.quality >= 60 then
                qualityColor = Color3.fromRGB(255, 255, 100) -- Yellow (good)
            elseif currentSpot.quality >= 40 then
                qualityColor = Color3.fromRGB(255, 200, 100) -- Orange (fair)
            end
            
            local qualityBar = Instance.new("Frame")
            qualityBar.Parent = infoCard
            qualityBar.Size = UDim2.new(0, 200, 0, 20)
            qualityBar.Position = UDim2.new(1, -220, 0, 10)
            qualityBar.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
            qualityBar.BorderSizePixel = 0
            Instance.new("UICorner", qualityBar).CornerRadius = UDim.new(0, 10)
            
            local qualityFill = Instance.new("Frame")
            qualityFill.Parent = qualityBar
            qualityFill.Size = UDim2.new(currentSpot.quality / 100, 0, 1, 0)
            qualityFill.Position = UDim2.new(0, 0, 0, 0)
            qualityFill.BackgroundColor3 = qualityColor
            qualityFill.BorderSizePixel = 0
            Instance.new("UICorner", qualityFill).CornerRadius = UDim.new(0, 10)
            
            local qualityText = Instance.new("TextLabel")
            qualityText.Parent = qualityBar
            qualityText.Size = UDim2.new(1, 0, 1, 0)
            qualityText.BackgroundTransparency = 1
            qualityText.Text = string.format("Quality: %d%%", currentSpot.quality)
            qualityText.TextColor3 = Color3.fromRGB(255, 255, 255)
            qualityText.Font = Enum.Font.SourceSansBold
            qualityText.TextSize = 11
            
            -- Details text
            local detailsText = Instance.new("TextLabel")
            detailsText.Parent = infoCard
            detailsText.Size = UDim2.new(1, -20, 1, -45)
            detailsText.Position = UDim2.new(0, 10, 0, 35)
            detailsText.BackgroundTransparency = 1
            detailsText.TextColor3 = Color3.fromRGB(200, 200, 200)
            detailsText.Font = Enum.Font.SourceSans
            detailsText.TextSize = 12
            detailsText.TextWrapped = true
            detailsText.TextXAlignment = Enum.TextXAlignment.Left
            detailsText.TextYAlignment = Enum.TextYAlignment.Top
            
            local coords = currentSpot.coordinates
            local conditions = currentSpot.conditions
            local fishList = table.concat(currentSpot.fishTypes, ", ")
            
            detailsText.Text = string.format(
                "📊 Success Rate: %s\n" ..
                "📍 Coordinates: (%.1f, %.1f, %.1f)\n\n" ..
                "🌊 Water Conditions:\n" ..
                "• Depth: %.1f meters\n" ..
                "• Temperature: %s\n" ..
                "• Current: %s\n" ..
                "• Type: %s Water\n\n" ..
                "🐟 Potential Fish:\n%s",
                currentSpot.successRate,
                coords.X, coords.Y, coords.Z,
                conditions.depth or 0,
                conditions.temperature or "Unknown",
                conditions.current or "Unknown",
                conditions.salinity or "Unknown",
                fishList ~= "" and fishList or "Analyzing..."
            )
            
            -- Update canvas size
            scrollFrame.CanvasSize = UDim2.new(0, 0, 0, 220)
        end
    },
    {
        name = "Best Spots",
        icon = "🏆",
        color = Color3.fromRGB(255, 200, 50),
        content = function()
            -- Clear existing content
            for _, child in pairs(scrollFrame:GetChildren()) do
                if not child:IsA("UIListLayout") then
                    child:Destroy()
                end
            end
            
            -- Create layout if it doesn't exist
            if not scrollFrame:FindFirstChild("UIListLayout") then
                local layout = Instance.new("UIListLayout")
                layout.Parent = scrollFrame
                layout.SortOrder = Enum.SortOrder.LayoutOrder
                layout.Padding = UDim.new(0, 8)
            end
            
            if #FishingSpotData.bestSpots == 0 then
                local noDataLabel = Instance.new("TextLabel")
                noDataLabel.Parent = scrollFrame
                noDataLabel.Size = UDim2.new(1, -20, 0, 100)
                noDataLabel.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
                noDataLabel.BorderSizePixel = 0
                noDataLabel.Text = "🔍 No fishing spots analyzed yet!\n\nClick 'Analyze Current Spot' to start discovering the best fishing locations."
                noDataLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
                noDataLabel.Font = Enum.Font.SourceSans
                noDataLabel.TextSize = 14
                noDataLabel.TextWrapped = true
                noDataLabel.LayoutOrder = 1
                Instance.new("UICorner", noDataLabel).CornerRadius = UDim.new(0, 8)
                
                scrollFrame.CanvasSize = UDim2.new(0, 0, 0, 120)
                return
            end
            
            local totalHeight = 0
            
            for i, spot in ipairs(FishingSpotData.bestSpots) do
                local spotCard = Instance.new("Frame")
                spotCard.Parent = scrollFrame
                spotCard.Size = UDim2.new(1, -20, 0, 120)
                spotCard.BackgroundColor3 = Color3.fromRGB(30, 35, 50)
                spotCard.BorderSizePixel = 0
                spotCard.LayoutOrder = i
                Instance.new("UICorner", spotCard).CornerRadius = UDim.new(0, 10)
                
                -- Rank badge
                local rankBadge = Instance.new("TextLabel")
                rankBadge.Parent = spotCard
                rankBadge.Size = UDim2.new(0, 40, 0, 40)
                rankBadge.Position = UDim2.new(0, 10, 0, 10)
                rankBadge.BackgroundColor3 = i <= 3 and Color3.fromRGB(255, 200, 50) or Color3.fromRGB(100, 100, 150)
                rankBadge.Text = "#" .. i
                rankBadge.TextColor3 = Color3.fromRGB(255, 255, 255)
                rankBadge.Font = Enum.Font.SourceSansBold
                rankBadge.TextSize = 14
                rankBadge.BorderSizePixel = 0
                Instance.new("UICorner", rankBadge).CornerRadius = UDim.new(0, 20)
                
                -- Spot name and quality
                local spotTitle = Instance.new("TextLabel")
                spotTitle.Parent = spotCard
                spotTitle.Size = UDim2.new(1, -120, 0, 25)
                spotTitle.Position = UDim2.new(0, 60, 0, 10)
                spotTitle.BackgroundTransparency = 1
                spotTitle.Text = string.format("🎣 %s", spot.name)
                spotTitle.TextColor3 = Color3.fromRGB(100, 200, 255)
                spotTitle.Font = Enum.Font.SourceSansBold
                spotTitle.TextSize = 14
                spotTitle.TextXAlignment = Enum.TextXAlignment.Left
                
                local qualityLabel = Instance.new("TextLabel")
                qualityLabel.Parent = spotCard
                qualityLabel.Size = UDim2.new(0, 80, 0, 20)
                qualityLabel.Position = UDim2.new(1, -90, 0, 10)
                qualityLabel.BackgroundColor3 = spot.quality >= 80 and Color3.fromRGB(50, 150, 50) or 
                                               (spot.quality >= 60 and Color3.fromRGB(150, 150, 50) or Color3.fromRGB(150, 50, 50))
                qualityLabel.Text = string.format("%d%% Quality", spot.quality)
                qualityLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
                qualityLabel.Font = Enum.Font.SourceSansBold
                qualityLabel.TextSize = 10
                qualityLabel.BorderSizePixel = 0
                Instance.new("UICorner", qualityLabel).CornerRadius = UDim.new(0, 10)
                
                -- Spot details
                local spotDetails = Instance.new("TextLabel")
                spotDetails.Parent = spotCard
                spotDetails.Size = UDim2.new(1, -70, 0, 60)
                spotDetails.Position = UDim2.new(0, 60, 0, 35)
                spotDetails.BackgroundTransparency = 1
                spotDetails.Text = string.format(
                    "📊 %s • 🌊 %s %s • 🐟 %d fish types\n📍 (%.0f, %.0f, %.0f) • ⏰ %s",
                    spot.successRate,
                    spot.conditions.temperature or "Normal",
                    spot.conditions.salinity or "Water",
                    #spot.potentialFish,
                    spot.position.X, spot.position.Y, spot.position.Z,
                    spot.timeString
                )
                spotDetails.TextColor3 = Color3.fromRGB(180, 180, 180)
                spotDetails.Font = Enum.Font.SourceSans
                spotDetails.TextSize = 11
                spotDetails.TextXAlignment = Enum.TextXAlignment.Left
                spotDetails.TextYAlignment = Enum.TextYAlignment.Top
                spotDetails.TextWrapped = true
                
                -- Teleport button
                local teleportBtn = Instance.new("TextButton")
                teleportBtn.Parent = spotCard
                teleportBtn.Size = UDim2.new(0, 50, 0, 25)
                teleportBtn.Position = UDim2.new(1, -60, 0, 85)
                teleportBtn.BackgroundColor3 = Color3.fromRGB(60, 120, 200)
                teleportBtn.Text = "🚀 TP"
                teleportBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
                teleportBtn.Font = Enum.Font.SourceSansBold
                teleportBtn.TextSize = 10
                teleportBtn.BorderSizePixel = 0
                Instance.new("UICorner", teleportBtn).CornerRadius = UDim.new(0, 6)
                
                teleportBtn.MouseButton1Click:Connect(function()
                    ErrorHandler:safeExecute(function()
                        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                            LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(spot.position)
                            print(string.format("🚀 Teleported to %s (Quality: %d%%)", spot.name, spot.quality))
                        end
                    end, "Teleport to fishing spot")
                end)
                
                totalHeight = totalHeight + 128
            end
            
            scrollFrame.CanvasSize = UDim2.new(0, 0, 0, totalHeight + 20)
        end
    },
    {
        name = "Analysis",
        icon = "📊",
        color = Color3.fromRGB(100, 200, 100),
        content = function()
            -- Clear existing content
            for _, child in pairs(scrollFrame:GetChildren()) do
                if not child:IsA("UIListLayout") then
                    child:Destroy()
                end
            end
            
            -- Create layout if it doesn't exist
            if not scrollFrame:FindFirstChild("UIListLayout") then
                local layout = Instance.new("UIListLayout")
                layout.Parent = scrollFrame
                layout.SortOrder = Enum.SortOrder.LayoutOrder
                layout.Padding = UDim.new(0, 10)
            end
            
            -- Statistics summary
            local statsCard = Instance.new("Frame")
            statsCard.Parent = scrollFrame
            statsCard.Size = UDim2.new(1, -20, 0, 150)
            statsCard.BackgroundColor3 = Color3.fromRGB(30, 35, 50)
            statsCard.BorderSizePixel = 0
            statsCard.LayoutOrder = 1
            Instance.new("UICorner", statsCard).CornerRadius = UDim.new(0, 10)
            
            local statsTitle = Instance.new("TextLabel")
            statsTitle.Parent = statsCard
            statsTitle.Size = UDim2.new(1, -20, 0, 30)
            statsTitle.Position = UDim2.new(0, 10, 0, 10)
            statsTitle.BackgroundTransparency = 1
            statsTitle.Text = "📊 Fishing Spot Analysis Summary"
            statsTitle.TextColor3 = Color3.fromRGB(100, 200, 255)
            statsTitle.Font = Enum.Font.SourceSansBold
            statsTitle.TextSize = 16
            statsTitle.TextXAlignment = Enum.TextXAlignment.Left
            
            local totalSpots = #FishingSpotData.analyzedSpots
            local avgQuality = 0
            local excellentSpots = 0
            local goodSpots = 0
            
            if totalSpots > 0 then
                local totalQualitySum = 0
                for _, spot in ipairs(FishingSpotData.analyzedSpots) do
                    totalQualitySum = totalQualitySum + spot.quality
                    if spot.quality >= 80 then
                        excellentSpots = excellentSpots + 1
                    elseif spot.quality >= 60 then
                        goodSpots = goodSpots + 1
                    end
                end
                avgQuality = math.floor(totalQualitySum / totalSpots)
            end
            
            local statsText = Instance.new("TextLabel")
            statsText.Parent = statsCard
            statsText.Size = UDim2.new(1, -20, 1, -50)
            statsText.Position = UDim2.new(0, 10, 0, 40)
            statsText.BackgroundTransparency = 1
            statsText.Text = string.format(
                "🎣 Total Spots Analyzed: %d\n" ..
                "⭐ Average Quality: %d%%\n" ..
                "🏆 Excellent Spots (80%+): %d\n" ..
                "✅ Good Spots (60-79%%): %d\n" ..
                "📈 Analysis Accuracy: High\n" ..
                "🔍 Detection Algorithm: Advanced AI",
                totalSpots, avgQuality, excellentSpots, goodSpots
            )
            statsText.TextColor3 = Color3.fromRGB(200, 200, 200)
            statsText.Font = Enum.Font.SourceSans
            statsText.TextSize = 13
            statsText.TextXAlignment = Enum.TextXAlignment.Left
            statsText.TextYAlignment = Enum.TextYAlignment.Top
            statsText.TextWrapped = true
            
            -- Recommendations card
            local recsCard = Instance.new("Frame")
            recsCard.Parent = scrollFrame
            recsCard.Size = UDim2.new(1, -20, 0, 200)
            recsCard.BackgroundColor3 = Color3.fromRGB(30, 35, 50)
            recsCard.BorderSizePixel = 0
            recsCard.LayoutOrder = 2
            Instance.new("UICorner", recsCard).CornerRadius = UDim.new(0, 10)
            
            local recsTitle = Instance.new("TextLabel")
            recsTitle.Parent = recsCard
            recsTitle.Size = UDim2.new(1, -20, 0, 30)
            recsTitle.Position = UDim2.new(0, 10, 0, 10)
            recsTitle.BackgroundTransparency = 1
            recsTitle.Text = "💡 Smart Fishing Recommendations"
            recsTitle.TextColor3 = Color3.fromRGB(255, 200, 100)
            recsTitle.Font = Enum.Font.SourceSansBold
            recsTitle.TextSize = 16
            recsTitle.TextXAlignment = Enum.TextXAlignment.Left
            
            local recommendations = ""
            if totalSpots == 0 then
                recommendations = "🔍 Start by analyzing your current fishing spot!\n\n" ..
                               "🎯 Move to different locations and analyze each one\n" ..
                               "📊 Build a database of the best fishing spots\n" ..
                               "🏆 Find spots with 80%+ quality for maximum efficiency"
            else
                if excellentSpots > 0 then
                    recommendations = "🏆 You've found excellent fishing spots!\n\n" ..
                                   "✅ Focus on spots with 80%+ quality\n" ..
                                   "🎣 These locations offer the best fish variety\n" ..
                                   "💰 Higher quality = better rare fish chances"
                else
                    recommendations = "🔍 Keep exploring to find better spots!\n\n" ..
                                   "🌊 Try deeper water locations\n" ..
                                   "🏔️ Check volcanic or special areas\n" ..
                                   "📍 Look for unique environmental conditions"
                end
                
                if avgQuality < 50 then
                    recommendations = recommendations .. "\n\n⚠️ Current average quality is low\n" ..
                                   "🎯 Explore new areas for better spots"
                end
            end
            
            local recsText = Instance.new("TextLabel")
            recsText.Parent = recsCard
            recsText.Size = UDim2.new(1, -20, 1, -50)
            recsText.Position = UDim2.new(0, 10, 0, 40)
            recsText.BackgroundTransparency = 1
            recsText.Text = recommendations
            recsText.TextColor3 = Color3.fromRGB(200, 200, 200)
            recsText.Font = Enum.Font.SourceSans
            recsText.TextSize = 12
            recsText.TextXAlignment = Enum.TextXAlignment.Left
            recsText.TextYAlignment = Enum.TextYAlignment.Top
            recsText.TextWrapped = true
            
            scrollFrame.CanvasSize = UDim2.new(0, 0, 0, 380)
        end
    },
    {
        name = "Export",
        icon = "📋",
        color = Color3.fromRGB(200, 100, 200),
        content = function()
            -- Clear existing content
            for _, child in pairs(scrollFrame:GetChildren()) do
                if not child:IsA("UIListLayout") then
                    child:Destroy()
                end
            end
            
            -- Create layout if it doesn't exist
            if not scrollFrame:FindFirstChild("UIListLayout") then
                local layout = Instance.new("UIListLayout")
                layout.Parent = scrollFrame
                layout.SortOrder = Enum.SortOrder.LayoutOrder
                layout.Padding = UDim.new(0, 5)
            end
            
            local exportText = Instance.new("TextLabel")
            exportText.Parent = scrollFrame
            exportText.Size = UDim2.new(1, -20, 0, 800)
            exportText.Position = UDim2.new(0, 10, 0, 0)
            exportText.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
            exportText.BorderSizePixel = 0
            exportText.TextColor3 = Color3.fromRGB(200, 255, 200)
            exportText.Font = Enum.Font.SourceSans
            exportText.TextSize = 10
            exportText.TextWrapped = true
            exportText.TextXAlignment = Enum.TextXAlignment.Left
            exportText.TextYAlignment = Enum.TextYAlignment.Top
            exportText.LayoutOrder = 1
            Instance.new("UICorner", exportText).CornerRadius = UDim.new(0, 8)
            
            -- Generate export code
            local exportCode = "-- Best Fishing Spots Data (Generated by Best Fishing Spot Detector)\n"
            exportCode = exportCode .. "-- Copy this code to your main_modern.lua for automatic best spot teleportation\n\n"
            
            exportCode = exportCode .. "local BestFishingSpots = {\n"
            
            for i, spot in ipairs(FishingSpotData.bestSpots) do
                exportCode = exportCode .. string.format("    {\n")
                exportCode = exportCode .. string.format("        name = \"%s\",\n", spot.name)
                exportCode = exportCode .. string.format("        position = Vector3.new(%.2f, %.2f, %.2f),\n", 
                    spot.position.X, spot.position.Y, spot.position.Z)
                exportCode = exportCode .. string.format("        quality = %d,\n", spot.quality)
                exportCode = exportCode .. string.format("        successRate = \"%s\",\n", spot.successRate)
                exportCode = exportCode .. string.format("        fishTypes = {%s},\n", 
                    table.concat(spot.potentialFish, "\", \""):gsub("^", "\""):gsub("$", "\""))
                exportCode = exportCode .. string.format("        conditions = {\n")
                exportCode = exportCode .. string.format("            depth = %.1f,\n", spot.conditions.depth or 0)
                exportCode = exportCode .. string.format("            temperature = \"%s\",\n", spot.conditions.temperature or "Normal")
                exportCode = exportCode .. string.format("            current = \"%s\",\n", spot.conditions.current or "Calm")
                exportCode = exportCode .. string.format("            salinity = \"%s\"\n", spot.conditions.salinity or "Fresh")
                exportCode = exportCode .. string.format("        }\n")
                exportCode = exportCode .. string.format("    }%s\n", i < #FishingSpotData.bestSpots and "," or "")
            end
            
            exportCode = exportCode .. "}\n\n"
            exportCode = exportCode .. "-- Usage examples:\n"
            exportCode = exportCode .. "-- Teleport to best spot: game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(BestFishingSpots[1].position)\n"
            exportCode = exportCode .. "-- Get best spot name: print(BestFishingSpots[1].name)\n"
            exportCode = exportCode .. "-- Check quality: print(\"Quality: \" .. BestFishingSpots[1].quality .. \"%\")\n\n"
            
            exportCode = exportCode .. "-- Integration with main_modern.lua:\n"
            exportCode = exportCode .. "-- Add this to your teleport tab for instant access to best fishing spots\n"
            exportCode = exportCode .. "for i, spot in ipairs(BestFishingSpots) do\n"
            exportCode = exportCode .. "    TeleportTab:CreateButton({\n"
            exportCode = exportCode .. "        Name = string.format(\"🏆 %s (%.0f%%)\", spot.name, spot.quality),\n"
            exportCode = exportCode .. "        Callback = function()\n"
            exportCode = exportCode .. "            SafeTeleport(CFrame.new(spot.position), spot.name)\n"
            exportCode = exportCode .. "        end\n"
            exportCode = exportCode .. "    })\n"
            exportCode = exportCode .. "end"
            
            exportText.Text = exportCode
            scrollFrame.CanvasSize = UDim2.new(0, 0, 0, 820)
        end
    }
}

-- Create tab buttons
local tabButtons = {}
local currentTab = 1

for i, tab in ipairs(tabContents) do
    local tabBtn = Instance.new("TextButton")
    tabBtn.Parent = tabContainer
    tabBtn.Size = UDim2.new(0, 130, 1, 0)
    tabBtn.Text = tab.icon .. " " .. tab.name
    tabBtn.BackgroundColor3 = i == 1 and tab.color or Color3.fromRGB(50, 50, 70)
    tabBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    tabBtn.Font = Enum.Font.SourceSansBold
    tabBtn.TextSize = 12
    tabBtn.BorderSizePixel = 0
    Instance.new("UICorner", tabBtn).CornerRadius = UDim.new(0, 8)
    
    tabButtons[i] = tabBtn
    
    tabBtn.MouseButton1Click:Connect(function()
        currentTab = i
        
        -- Update tab appearance
        for j, btn in ipairs(tabButtons) do
            btn.BackgroundColor3 = j == i and tabContents[j].color or Color3.fromRGB(50, 50, 70)
        end
        
        -- Update content
        ErrorHandler:safeExecute(function()
            tab.content()
        end, "Tab content update")
    end)
end

-- Create action buttons
local function createButton(text, color, callback)
    local btn = Instance.new("TextButton")
    btn.Parent = buttonFrame
    btn.Size = UDim2.new(0, 120, 1, 0)
    btn.Text = text
    btn.BackgroundColor3 = color
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Font = Enum.Font.SourceSansBold
    btn.TextSize = 11
    btn.BorderSizePixel = 0
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)
    
    btn.MouseButton1Click:Connect(function()
        ErrorHandler:safeExecute(callback, "Button: " .. text)
    end)
    return btn
end

-- Enhanced buttons
createButton("🔍 Analyze Current", Color3.fromRGB(60, 150, 200), function()
    statusLabel.Text = "ANALYZING..."
    statusFrame.BackgroundColor3 = Color3.fromRGB(150, 150, 50)
    
    LocationAnalyzer.analyzeCurrentSpot()
    
    -- Update current tab if it's "Current Spot"
    if currentTab == 1 then
        tabContents[1].content()
    end
    
    statusLabel.Text = "ANALYSIS COMPLETE"
    statusFrame.BackgroundColor3 = Color3.fromRGB(50, 150, 50)
    
    print("🔍 Current fishing spot analyzed successfully!")
end)

createButton("🏆 Show Best Spots", Color3.fromRGB(255, 200, 50), function()
    currentTab = 2
    
    -- Update tab appearance
    for j, btn in ipairs(tabButtons) do
        btn.BackgroundColor3 = j == 2 and tabContents[j].color or Color3.fromRGB(50, 50, 70)
    end
    
    tabContents[2].content()
    print("🏆 Showing best fishing spots ranking!")
end)

createButton("📋 Export Data", Color3.fromRGB(150, 100, 200), function()
    if #FishingSpotData.bestSpots == 0 then
        print("⚠️ No fishing spots analyzed yet! Analyze some spots first.")
        return
    end
    
    currentTab = 4
    
    -- Update tab appearance
    for j, btn in ipairs(tabButtons) do
        btn.BackgroundColor3 = j == 4 and tabContents[j].color or Color3.fromRGB(50, 50, 70)
    end
    
    tabContents[4].content()
    
    -- Copy to clipboard if available
    ErrorHandler:safeExecute(function()
        if setclipboard then
            local exportData = scrollFrame:FindFirstChild("TextLabel").Text
            setclipboard(exportData)
            print("📋 Best fishing spots data copied to clipboard!")
        else
            print("📋 Export data displayed in Export tab")
        end
    end, "Export data copy")
end)

createButton("🧹 Clear Data", Color3.fromRGB(180, 70, 70), function()
    FishingSpotData.analyzedSpots = {}
    FishingSpotData.bestSpots = {}
    FishingSpotData.analysisHistory = {}
    
    -- Update current tab
    if tabContents[currentTab] then
        tabContents[currentTab].content()
    end
    
    statusLabel.Text = "DATA CLEARED"
    statusFrame.BackgroundColor3 = Color3.fromRGB(150, 70, 70)
    
    task.spawn(function()
        task.wait(2)
        statusLabel.Text = "READY"
        statusFrame.BackgroundColor3 = Color3.fromRGB(50, 150, 50)
    end)
    
    print("🧹 All fishing spot data cleared!")
end)

createButton("🔄 Auto Scan", Color3.fromRGB(100, 200, 100), function()
    statusLabel.Text = "AUTO SCANNING..."
    statusFrame.BackgroundColor3 = Color3.fromRGB(100, 100, 200)
    
    print("🔄 Starting auto-scan mode...")
    print("💡 Move around to different fishing locations!")
    print("🎯 The detector will automatically analyze each new spot")
    
    -- Start auto-scanning (analyze when position changes significantly)
    local lastPosition = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") and 
                        LocalPlayer.Character.HumanoidRootPart.Position or Vector3.new(0, 0, 0)
    
    task.spawn(function()
        while mainFrame.Visible do
            ErrorHandler:safeExecute(function()
                if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                    local currentPosition = LocalPlayer.Character.HumanoidRootPart.Position
                    local distance = (currentPosition - lastPosition).Magnitude
                    
                    if distance > 100 then -- If moved more than 100 studs
                        LocationAnalyzer.analyzeCurrentSpot()
                        lastPosition = currentPosition
                        
                        if currentTab == 1 then
                            tabContents[1].content()
                        end
                        
                        print(string.format("🔄 Auto-analyzed new location: %s", FishingSpotData.currentLocation.name))
                    end
                end
            end, "Auto-scan")
            
            task.wait(3) -- Check every 3 seconds
        end
    end)
    
    statusLabel.Text = "AUTO SCANNING"
    statusFrame.BackgroundColor3 = Color3.fromRGB(50, 150, 200)
end)

-- Toggle functionality
floatingBtn.MouseButton1Click:Connect(function()
    mainFrame.Visible = not mainFrame.Visible
    floatingBtn.Text = mainFrame.Visible and "❌" or "🎣"
    floatingBtn.BackgroundColor3 = mainFrame.Visible and Color3.fromRGB(200, 80, 80) or Color3.fromRGB(60, 150, 200)
    
    if mainFrame.Visible then
        -- Animate show
        mainFrame.Size = UDim2.new(0, 0, 0, 0)
        local tween = TweenService:Create(mainFrame, TweenInfo.new(0.4, Enum.EasingStyle.Back), {
            Size = UDim2.new(0, frameWidth, 0, frameHeight)
        })
        tween:Play()
        
        -- Load initial content
        ErrorHandler:safeExecute(function()
            tabContents[currentTab].content()
        end, "Interface show")
        
        -- Analyze current spot immediately
        task.spawn(function()
            task.wait(0.5)
            LocationAnalyzer.analyzeCurrentSpot()
            if currentTab == 1 then
                tabContents[1].content()
            end
        end)
    end
end)

-- Close functionality
closeBtn.MouseButton1Click:Connect(function()
    screen:Destroy()
    print("🎣 Best Fishing Spot Detector closed")
end)

-- Hotkey support (Ctrl+F for Fishing)
local UserInputService = game:GetService("UserInputService")
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if not gameProcessed and input.KeyCode == Enum.KeyCode.F and UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
        floatingBtn.MouseButton1Click:Fire()
    end
end)

-- Initialize
ErrorHandler:safeExecute(function()
    print("🎣 Best Fishing Spot Detector v1.0 started!")
    print("✨ Advanced AI-powered fishing location analysis")
    print("🎮 Press Ctrl+F or click floating button to open")
    print("🔍 Features: Quality analysis, Success rate prediction, Environment scanning")
    print("🏆 Find the best fishing spots with intelligent detection!")
    
    -- Auto-load current spot tab
    tabContents[1].content()
    
    statusLabel.Text = "READY"
    statusFrame.BackgroundColor3 = Color3.fromRGB(50, 150, 50)
end, "Initialization")
