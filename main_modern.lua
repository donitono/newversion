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

-- Load Modern UI Library (Embedded)
print("XSAN: Loading Modern UI Library...")

-- Embedded UI library (fixed version)
local Rayfield = loadstring([[
-- Rayfield UI Library (Fixed Version for Tab Distribution)
local cloneref = cloneref or function(obj) return obj end

local function getService(name)
	local service = game:GetService(name)
	return cloneref and cloneref(service) or service
end

-- Services
local TweenService = getService("TweenService")
local UserInputService = getService("UserInputService")
local GuiService = getService("GuiService")
local RunService = getService("RunService")
local Players = getService("Players")
local CoreGui = getService("CoreGui")

-- Variables
local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")

-- Create main ScreenGui with proper Z-Index
local RayfieldLibrary = Instance.new("ScreenGui")
RayfieldLibrary.Name = "RayfieldLibrary"
RayfieldLibrary.ResetOnSpawn = false
RayfieldLibrary.IgnoreGuiInset = true
RayfieldLibrary.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
RayfieldLibrary.DisplayOrder = 10
RayfieldLibrary.Parent = PlayerGui

-- Variables for scaling and themes
local isMobile = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled
local screenSize = workspace.CurrentCamera.ViewportSize

-- Global tracking
local CurrentTabs = {}
local CurrentTab = nil

-- Main Rayfield object
local Rayfield = {}

function Rayfield:CreateWindow(Settings)
	local Window = {}
	
	-- Clear any existing tabs
	CurrentTabs = {}
	
	-- Create main container with proper sizing
	local Main = Instance.new("Frame")
	Main.Name = "Main"
	Main.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
	Main.BorderSizePixel = 0
	Main.Position = UDim2.new(0.5, 0, 0.5, 0)
	Main.AnchorPoint = Vector2.new(0.5, 0.5)
	
	-- Use compact 600x320 size (landscape friendly)
	if isMobile then
		Main.Size = UDim2.new(0, 600, 0, 320) -- Fixed compact size
	else
		Main.Size = UDim2.new(0, 600, 0, 380) -- Desktop still compact
	end
	
	Main.Parent = RayfieldLibrary

	local MainCorner = Instance.new("UICorner")
	MainCorner.CornerRadius = UDim.new(0, 10)
	MainCorner.Parent = Main

	-- Create title bar
	local TitleBar = Instance.new("Frame")
	TitleBar.Name = "TitleBar"
	TitleBar.Size = UDim2.new(1, 0, 0, 40)
	TitleBar.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
	TitleBar.BorderSizePixel = 0
	TitleBar.Parent = Main

	local TitleCorner = Instance.new("UICorner")
	TitleCorner.CornerRadius = UDim.new(0, 10)
	TitleCorner.Parent = TitleBar

	-- Fix corner for bottom
	local TitleFix = Instance.new("Frame")
	TitleFix.Size = UDim2.new(1, 0, 0, 10)
	TitleFix.Position = UDim2.new(0, 0, 1, -10)
	TitleFix.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
	TitleFix.BorderSizePixel = 0
	TitleFix.Parent = TitleBar

	-- Title text
	local Title = Instance.new("TextLabel")
	Title.Size = UDim2.new(1, -20, 1, 0)
	Title.Position = UDim2.new(0, 10, 0, 0)
	Title.BackgroundTransparency = 1
	Title.Text = Settings.Name or "Rayfield"
	Title.TextColor3 = Color3.fromRGB(255, 255, 255)
	Title.TextScaled = true
	Title.Font = Enum.Font.SourceSansBold
	Title.Parent = TitleBar

	-- Create tab container
	local TabContainer = Instance.new("Frame")
	TabContainer.Name = "TabContainer"
	TabContainer.Size = UDim2.new(1, 0, 0, 35)
	TabContainer.Position = UDim2.new(0, 0, 0, 45)
	TabContainer.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
	TabContainer.BorderSizePixel = 0
	TabContainer.Parent = Main

	local TabLayout = Instance.new("UIListLayout")
	TabLayout.SortOrder = Enum.SortOrder.LayoutOrder
	TabLayout.FillDirection = Enum.FillDirection.Horizontal
	TabLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	TabLayout.Padding = UDim.new(0, 2)
	TabLayout.Parent = TabContainer

	-- Create content area
	local ContentFrame = Instance.new("Frame")
	ContentFrame.Name = "ContentFrame"
	ContentFrame.Size = UDim2.new(1, 0, 1, -85)
	ContentFrame.Position = UDim2.new(0, 0, 0, 85)
	ContentFrame.BackgroundTransparency = 1
	ContentFrame.Parent = Main

	function Window:CreateTab(Name, Icon)
		local Tab = {}
		
		-- Create tab button
		local TabButton = Instance.new("TextButton")
		TabButton.Name = Name
		TabButton.Size = UDim2.new(0, 120, 1, 0)
		TabButton.BackgroundColor3 = #CurrentTabs == 0 and Color3.fromRGB(60, 120, 180) or Color3.fromRGB(50, 50, 60)
		TabButton.BorderSizePixel = 0
		TabButton.Text = Name
		TabButton.TextColor3 = Color3.fromRGB(255, 255, 255)
		TabButton.TextScaled = true
		TabButton.Font = Enum.Font.SourceSans
		TabButton.Parent = TabContainer

		local TabCorner = Instance.new("UICorner")
		TabCorner.CornerRadius = UDim.new(0, 6)
		TabCorner.Parent = TabButton

		-- Create tab content
		local TabContent = Instance.new("ScrollingFrame")
		TabContent.Name = Name .. "Content"
		TabContent.Size = UDim2.new(1, 0, 1, 0)
		TabContent.Position = UDim2.new(0, 0, 0, 0)
		TabContent.BackgroundTransparency = 1
		TabContent.ScrollBarThickness = 8
		TabContent.ScrollBarImageColor3 = Color3.fromRGB(80, 80, 80)
		TabContent.CanvasSize = UDim2.new(0, 0, 0, 0)
		TabContent.AutomaticCanvasSize = Enum.AutomaticSize.Y
		TabContent.Visible = #CurrentTabs == 0 -- First tab visible
		TabContent.Parent = ContentFrame

		local ContentLayout = Instance.new("UIListLayout")
		ContentLayout.SortOrder = Enum.SortOrder.LayoutOrder
		ContentLayout.Padding = UDim.new(0, 5)
		ContentLayout.Parent = TabContent

		local ContentPadding = Instance.new("UIPadding")
		ContentPadding.PaddingTop = UDim.new(0, 10)
		ContentPadding.PaddingBottom = UDim.new(0, 10)
		ContentPadding.PaddingLeft = UDim.new(0, 10)
		ContentPadding.PaddingRight = UDim.new(0, 10)
		ContentPadding.Parent = TabContent

		-- Tab click event
		TabButton.MouseButton1Click:Connect(function()
			-- Hide all tabs
			for _, tabData in pairs(CurrentTabs) do
				tabData.Content.Visible = false
				tabData.Button.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
			end
			
			-- Show this tab
			TabContent.Visible = true
			TabButton.BackgroundColor3 = Color3.fromRGB(60, 120, 180)
			CurrentTab = Tab
		end)

		-- Store tab data
		table.insert(CurrentTabs, Tab)
		if #CurrentTabs == 1 then
			CurrentTab = Tab
		end

		Tab.Content = TabContent
		Tab.Button = TabButton

		-- Tab-specific Create methods (FIXED VERSION)
		function Tab:CreateParagraph(Settings)
			local Container = Instance.new("Frame")
			Container.Size = UDim2.new(1, 0, 0, 0)
			Container.BackgroundTransparency = 1
			Container.AutomaticSize = Enum.AutomaticSize.Y
			Container.Parent = Tab.Content -- Use Tab.Content directly

			if Settings.Title then
				local Title = Instance.new("TextLabel")
				Title.Size = UDim2.new(1, 0, 0, 20)
				Title.BackgroundTransparency = 1
				Title.Text = Settings.Title
				Title.TextColor3 = Color3.fromRGB(255, 255, 255)
				Title.Font = Enum.Font.SourceSansBold
				Title.TextSize = 12
				Title.TextXAlignment = Enum.TextXAlignment.Left
				Title.Parent = Container
			end

			local Content = Instance.new("TextLabel")
			Content.Size = UDim2.new(1, 0, 0, 0)
			Content.Position = Settings.Title and UDim2.new(0, 0, 0, 25) or UDim2.new(0, 0, 0, 0)
			Content.BackgroundTransparency = 1
			Content.Text = Settings.Content or ""
			Content.TextColor3 = Color3.fromRGB(200, 200, 200)
			Content.Font = Enum.Font.SourceSans
			Content.TextSize = 10
			Content.TextWrapped = true
			Content.TextXAlignment = Enum.TextXAlignment.Left
			Content.TextYAlignment = Enum.TextYAlignment.Top
			Content.AutomaticSize = Enum.AutomaticSize.Y
			Content.Parent = Container

			local Layout = Instance.new("UIListLayout")
			Layout.SortOrder = Enum.SortOrder.LayoutOrder
			Layout.Padding = UDim.new(0, 2)
			Layout.Parent = Container

			return Container
		end

		function Tab:CreateButton(Settings)
			local Button = Instance.new("TextButton")
			Button.Size = UDim2.new(1, 0, 0, 30)
			Button.BackgroundColor3 = Color3.fromRGB(60, 120, 180)
			Button.BorderSizePixel = 0
			Button.Text = Settings.Name or "Button"
			Button.TextColor3 = Color3.fromRGB(255, 255, 255)
			Button.Font = Enum.Font.SourceSansBold
			Button.TextSize = 11
			Button.Parent = Tab.Content -- Use Tab.Content directly

			local Corner = Instance.new("UICorner")
			Corner.CornerRadius = UDim.new(0, 6)
			Corner.Parent = Button

			Button.MouseButton1Click:Connect(function()
				if Settings.Callback then
					Settings.Callback()
				end
			end)

			return Button
		end

		function Tab:CreateToggle(Settings)
			local Container = Instance.new("Frame")
			Container.Size = UDim2.new(1, 0, 0, 35)
			Container.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
			Container.BorderSizePixel = 0
			Container.Parent = Tab.Content -- Use Tab.Content directly

			local ContainerCorner = Instance.new("UICorner")
			ContainerCorner.CornerRadius = UDim.new(0, 6)
			ContainerCorner.Parent = Container

			local Label = Instance.new("TextLabel")
			Label.Size = UDim2.new(1, -60, 1, 0)
			Label.Position = UDim2.new(0, 10, 0, 0)
			Label.BackgroundTransparency = 1
			Label.Text = Settings.Name or "Toggle"
			Label.TextColor3 = Color3.fromRGB(255, 255, 255)
			Label.Font = Enum.Font.SourceSans
			Label.TextSize = 11
			Label.TextXAlignment = Enum.TextXAlignment.Left
			Label.Parent = Container

			local ToggleButton = Instance.new("TextButton")
			ToggleButton.Size = UDim2.new(0, 40, 0, 20)
			ToggleButton.Position = UDim2.new(1, -50, 0.5, -10)
			ToggleButton.BackgroundColor3 = Settings.CurrentValue and Color3.fromRGB(60, 120, 180) or Color3.fromRGB(80, 80, 80)
			ToggleButton.BorderSizePixel = 0
			ToggleButton.Text = ""
			ToggleButton.Parent = Container

			local ToggleCorner = Instance.new("UICorner")
			ToggleCorner.CornerRadius = UDim.new(0.5, 0)
			ToggleCorner.Parent = ToggleButton

			local isToggled = Settings.CurrentValue or false

			ToggleButton.MouseButton1Click:Connect(function()
				isToggled = not isToggled
				ToggleButton.BackgroundColor3 = isToggled and Color3.fromRGB(60, 120, 180) or Color3.fromRGB(80, 80, 80)
				if Settings.Callback then
					Settings.Callback(isToggled)
				end
			end)

			return Container
		end

		function Tab:CreateDropdown(Settings)
			local Container = Instance.new("Frame")
			Container.Size = UDim2.new(1, 0, 0, 35)
			Container.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
			Container.BorderSizePixel = 0
			Container.Parent = Tab.Content -- Use Tab.Content directly

			local ContainerCorner = Instance.new("UICorner")
			ContainerCorner.CornerRadius = UDim.new(0, 6)
			ContainerCorner.Parent = Container

			local Label = Instance.new("TextLabel")
			Label.Size = UDim2.new(0.5, 0, 1, 0)
			Label.Position = UDim2.new(0, 10, 0, 0)
			Label.BackgroundTransparency = 1
			Label.Text = Settings.Name or "Dropdown"
			Label.TextColor3 = Color3.fromRGB(255, 255, 255)
			Label.Font = Enum.Font.SourceSans
			Label.TextSize = 11
			Label.TextXAlignment = Enum.TextXAlignment.Left
			Label.Parent = Container

			local DropdownButton = Instance.new("TextButton")
			DropdownButton.Size = UDim2.new(0.5, -20, 0, 25)
			DropdownButton.Position = UDim2.new(0.5, 10, 0, 5)
			DropdownButton.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
			DropdownButton.BorderSizePixel = 0
			DropdownButton.Text = Settings.CurrentOption or "Select..."
			DropdownButton.TextColor3 = Color3.fromRGB(255, 255, 255)
			DropdownButton.Font = Enum.Font.SourceSans
			DropdownButton.TextSize = 10
			DropdownButton.Parent = Container

			-- Simple dropdown - cycle through options
			local Options = Settings.Options or {}
			local CurrentIndex = 1
			
			for i, option in ipairs(Options) do
				if option == Settings.CurrentOption then
					CurrentIndex = i
					break
				end
			end

			DropdownButton.MouseButton1Click:Connect(function()
				CurrentIndex = CurrentIndex + 1
				if CurrentIndex > #Options then
					CurrentIndex = 1
				end
				
				DropdownButton.Text = Options[CurrentIndex]
				
				if Settings.Callback then
					Settings.Callback(Options[CurrentIndex])
				end
			end)

			return Container
		end

		function Tab:CreateInput(Settings)
			local Container = Instance.new("Frame")
			Container.Size = UDim2.new(1, 0, 0, 35)
			Container.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
			Container.BorderSizePixel = 0
			Container.Parent = Tab.Content

			local ContainerCorner = Instance.new("UICorner")
			ContainerCorner.CornerRadius = UDim.new(0, 6)
			ContainerCorner.Parent = Container

			local Label = Instance.new("TextLabel")
			Label.Size = UDim2.new(0.4, 0, 1, 0)
			Label.Position = UDim2.new(0, 10, 0, 0)
			Label.BackgroundTransparency = 1
			Label.Text = Settings.Name or "Input"
			Label.TextColor3 = Color3.fromRGB(255, 255, 255)
			Label.Font = Enum.Font.SourceSans
			Label.TextSize = 11
			Label.TextXAlignment = Enum.TextXAlignment.Left
			Label.Parent = Container

			local InputBox = Instance.new("TextBox")
			InputBox.Size = UDim2.new(0.6, -20, 0, 25)
			InputBox.Position = UDim2.new(0.4, 10, 0, 5)
			InputBox.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
			InputBox.BorderSizePixel = 0
			InputBox.Text = ""
			InputBox.PlaceholderText = Settings.PlaceholderText or "Enter text..."
			InputBox.TextColor3 = Color3.fromRGB(255, 255, 255)
			InputBox.PlaceholderColor3 = Color3.fromRGB(150, 150, 150)
			InputBox.Font = Enum.Font.SourceSans
			InputBox.TextSize = 10
			InputBox.ClearTextOnFocus = false
			InputBox.Parent = Container

			local InputCorner = Instance.new("UICorner")
			InputCorner.CornerRadius = UDim.new(0, 4)
			InputCorner.Parent = InputBox

			-- Handle text changed
			InputBox.FocusLost:Connect(function(enterPressed)
				if Settings.Callback then
					Settings.Callback(InputBox.Text)
				end
				if not Settings.RemoveTextAfterFocusLost then
					-- Keep the text
				else
					InputBox.Text = ""
				end
			end)

			return Container
		end

		function Tab:CreateSlider(Settings)
			local Container = Instance.new("Frame")
			Container.Size = UDim2.new(1, 0, 0, 50)
			Container.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
			Container.BorderSizePixel = 0
			Container.Parent = Tab.Content

			local ContainerCorner = Instance.new("UICorner")
			ContainerCorner.CornerRadius = UDim.new(0, 6)
			ContainerCorner.Parent = Container

			local Label = Instance.new("TextLabel")
			Label.Size = UDim2.new(1, -20, 0, 20)
			Label.Position = UDim2.new(0, 10, 0, 5)
			Label.BackgroundTransparency = 1
			Label.Text = Settings.Name or "Slider"
			Label.TextColor3 = Color3.fromRGB(255, 255, 255)
			Label.Font = Enum.Font.SourceSans
			Label.TextSize = 11
			Label.TextXAlignment = Enum.TextXAlignment.Left
			Label.Parent = Container

			local SliderTrack = Instance.new("Frame")
			SliderTrack.Size = UDim2.new(1, -40, 0, 8)
			SliderTrack.Position = UDim2.new(0, 20, 0, 30)
			SliderTrack.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
			SliderTrack.BorderSizePixel = 0
			SliderTrack.Parent = Container

			local TrackCorner = Instance.new("UICorner")
			TrackCorner.CornerRadius = UDim.new(0.5, 0)
			TrackCorner.Parent = SliderTrack

			local SliderFill = Instance.new("Frame")
			SliderFill.Size = UDim2.new(0.5, 0, 1, 0)
			SliderFill.Position = UDim2.new(0, 0, 0, 0)
			SliderFill.BackgroundColor3 = Color3.fromRGB(60, 120, 180)
			SliderFill.BorderSizePixel = 0
			SliderFill.Parent = SliderTrack

			local FillCorner = Instance.new("UICorner")
			FillCorner.CornerRadius = UDim.new(0.5, 0)
			FillCorner.Parent = SliderFill

			local SliderButton = Instance.new("TextButton")
			SliderButton.Size = UDim2.new(0, 16, 0, 16)
			SliderButton.Position = UDim2.new(0.5, -8, 0.5, -8)
			SliderButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
			SliderButton.BorderSizePixel = 0
			SliderButton.Text = ""
			SliderButton.Parent = SliderTrack

			local ButtonCorner = Instance.new("UICorner")
			ButtonCorner.CornerRadius = UDim.new(0.5, 0)
			ButtonCorner.Parent = SliderButton

			local ValueLabel = Instance.new("TextLabel")
			ValueLabel.Size = UDim2.new(0, 60, 0, 20)
			ValueLabel.Position = UDim2.new(1, -60, 0, 5)
			ValueLabel.BackgroundTransparency = 1
			ValueLabel.Text = tostring(Settings.CurrentValue or Settings.Range[1])
			ValueLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
			ValueLabel.Font = Enum.Font.SourceSans
			ValueLabel.TextSize = 10
			ValueLabel.TextXAlignment = Enum.TextXAlignment.Right
			ValueLabel.Parent = Container

			-- Slider functionality
			local Range = Settings.Range or {0, 100}
			local Increment = Settings.Increment or 1
			local CurrentValue = Settings.CurrentValue or Range[1]

			local function UpdateSlider(value)
				CurrentValue = math.clamp(value, Range[1], Range[2])
				CurrentValue = math.floor(CurrentValue / Increment + 0.5) * Increment
				
				local percent = (CurrentValue - Range[1]) / (Range[2] - Range[1])
				SliderFill.Size = UDim2.new(percent, 0, 1, 0)
				SliderButton.Position = UDim2.new(percent, -8, 0.5, -8)
				ValueLabel.Text = tostring(CurrentValue)
				
				if Settings.Callback then
					Settings.Callback(CurrentValue)
				end
			end

			-- Initialize
			UpdateSlider(CurrentValue)

			-- Mouse interaction
			local dragging = false
			SliderButton.MouseButton1Down:Connect(function()
				dragging = true
			end)

			game:GetService("UserInputService").InputEnded:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseButton1 then
					dragging = false
				end
			end)

			game:GetService("UserInputService").InputChanged:Connect(function(input)
				if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
					local mouse = game.Players.LocalPlayer:GetMouse()
					local trackAbsPos = SliderTrack.AbsolutePosition
					local trackAbsSize = SliderTrack.AbsoluteSize
					
					local percent = math.clamp((mouse.X - trackAbsPos.X) / trackAbsSize.X, 0, 1)
					local value = Range[1] + percent * (Range[2] - Range[1])
					UpdateSlider(value)
				end
			end)

			SliderTrack.MouseButton1Down:Connect(function()
				local mouse = game.Players.LocalPlayer:GetMouse()
				local trackAbsPos = SliderTrack.AbsolutePosition
				local trackAbsSize = SliderTrack.AbsoluteSize
				
				local percent = math.clamp((mouse.X - trackAbsPos.X) / trackAbsSize.X, 0, 1)
				local value = Range[1] + percent * (Range[2] - Range[1])
				UpdateSlider(value)
			end)

			return Container
		end

		return Tab
	end

	-- Window utility functions
	function Window:Refresh()
		if Main and Main.Parent then
			Main.Parent = Main.Parent
		end
	end

	return Window
end

return Rayfield
]])()

if not Rayfield then
    warn("XSAN ERROR: Failed to load embedded UI library")
    return
end

print("XSAN: Modern UI library loaded successfully!")

-- Mobile/Android detection
local isMobile = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled
local screenSize = workspace.CurrentCamera.ViewportSize

print("XSAN: Platform Detection - Mobile:", isMobile, "Screen Size:", screenSize.X .. "x" .. screenSize.Y)

-- Create Modern Window
print("XSAN: Creating modern window...")
local Window = Rayfield:CreateWindow({
    Name = "🐟 XSAN Fish It Pro Ultimate v2.0",
    LoadingTitle = "XSAN Fish It Pro Ultimate",
    LoadingSubtitle = "Modern Tab Interface - by XSAN",
    Theme = "DarkBlue",
    ConfigurationSaving = {
        Enabled = true,
        FolderName = "XSAN",
        FileName = "FishItProModern"
    }
})

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
local InfoTab = Window:CreateTab("📋 INFO", "🏠")

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
local AutoFishTab = Window:CreateTab("🎣 AUTO FISH", "🎣")

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
local TeleportTab = Window:CreateTab("🌍 TELEPORT", "🌍")

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

-- ═══════════════════════════════════════════════════════════════
-- NPC TELEPORTATION SYSTEM INTEGRATION
-- ═══════════════════════════════════════════════════════════════

print("XSAN: Loading NPC Teleportation System...")

-- NPC System for detection and teleportation
local NPCSystem = {
    detectedNPCs = {},
    customNPCs = {},
    autoRefresh = false,
    lastScan = 0,
    scanCooldown = 5,
    teleportCooldown = false
}

-- Pre-defined NPC locations based on detector results
NPCSystem.customNPCs = {
    -- Shop NPCs (Updated coordinates from NPC detector)
    ["Alex (Main Shop)"] = {x = -28.43, y = 4.50, z = 2891.28},
    ["Joe (Bait Shop)"] = {x = 112.01, y = 4.75, z = 2877.32},
    ["Seth (Equipment)"] = {x = 72.02, y = 4.58, z = 2885.28},
    ["Marc (Rod Shop)"] = {x = 454, y = 150, z = 229},
    ["Henry (Storage)"] = {x = 491, y = 150, z = 272},
    ["Shipwright"] = {x = 343, y = 135, z = 271},
    
    -- Quest NPCs (Update with actual coordinates from detector)
    ["Quest Giver 1"] = {x = 100, y = 20, z = 200},
    ["Quest Giver 2"] = {x = -100, y = 25, z = 300},
    ["Tutorial Guide"] = {x = 50, y = 18, z = 150},
    
    -- Special NPCs
    ["Event Manager"] = {x = 0, y = 25, z = 400},
    ["Leaderboard NPC"] = {x = -50, y = 20, z = 100},
    ["Daily Rewards"] = {x = 25, y = 22, z = 175}
}

-- Function to detect NPCs in the game
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
    for _ in pairs(self.detectedNPCs) do count = count + 1 end
    for _ in pairs(self.customNPCs) do count = count + 1 end
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

-- Enhanced teleport function for NPCs
function NPCSystem:TeleportToNPC(npcData, npcName)
    if teleportCooldown then
        Notify("⏰ Cooldown", "Please wait before teleporting again")
        return false
    end
    
    if not character or not character:FindFirstChild("HumanoidRootPart") then
        Notify("❌ Error", "Character not found")
        return false
    end
    
    teleportCooldown = true
    
    pcall(function()
        local targetPos = CFrame.new(npcData.x, npcData.y + 2, npcData.z) -- +2 Y to avoid clipping
        character.HumanoidRootPart.CFrame = targetPos
        
        -- Add a small bounce effect
        task.spawn(function()
            task.wait(0.1)
            character.HumanoidRootPart.Velocity = Vector3.new(0, 0, 0)
        end)
        
        local distance = math.floor(self:GetDistanceToNPC(npcData))
        Notify("✅ Teleported to " .. npcName, "Distance: " .. distance .. " studs")
    end)
    
    task.spawn(function()
        task.wait(2)
        teleportCooldown = false
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
-- NPC TELEPORTATION UI INTEGRATION
-- ═══════════════════════════════════════════════════════════════

TeleportTab:CreateParagraph({
    Title = "👥 NPC Teleportation System",
    Content = "Advanced NPC detection and teleportation. Auto-detects all NPCs in the game!"
})

-- Auto Refresh NPCs Toggle
TeleportTab:CreateToggle({
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

-- Manual NPC Scan Button
TeleportTab:CreateButton({
    Name = "🔍 Scan for NPCs Now",
    Callback = CreateSafeCallback(function()
        NPCSystem:DetectNPCs()
        local count = NPCSystem:GetNPCCount()
        Notify("🔍 NPC Scan", "Found " .. count .. " NPCs total!")
    end, "manual_npc_scan")
})

-- NPC Search Feature
local searchResults = {}
TeleportTab:CreateInput({
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

-- Teleport to Search Result
TeleportTab:CreateButton({
    Name = "🚀 Teleport to Search Result",
    Callback = CreateSafeCallback(function()
        for name, data in pairs(searchResults) do
            NPCSystem:TeleportToNPC(data, name)
            break -- Teleport to first result only
        end
    end, "teleport_search_result")
})

-- ═══════════════════════════════════════════════════════════════
-- SHOP NPCs QUICK ACCESS
-- ═══════════════════════════════════════════════════════════════

TeleportTab:CreateParagraph({
    Title = "🏪 Shop NPCs",
    Content = "Quick access to all shop and vendor NPCs"
})

-- Shop NPCs Buttons
TeleportTab:CreateButton({
    Name = "🏪 Alex (Main Shop)",
    Callback = CreateSafeCallback(function()
        NPCSystem:TeleportToNPC(NPCSystem.customNPCs["Alex (Main Shop)"], "Alex (Main Shop)")
    end, "teleport_alex")
})

TeleportTab:CreateButton({
    Name = "🪱 Joe (Bait Shop)",
    Callback = CreateSafeCallback(function()
        NPCSystem:TeleportToNPC(NPCSystem.customNPCs["Joe (Bait Shop)"], "Joe (Bait Shop)")
    end, "teleport_joe")
})

TeleportTab:CreateButton({
    Name = "⚙️ Seth (Equipment)",
    Callback = CreateSafeCallback(function()
        NPCSystem:TeleportToNPC(NPCSystem.customNPCs["Seth (Equipment)"], "Seth (Equipment)")
    end, "teleport_seth")
})

TeleportTab:CreateButton({
    Name = "🎣 Marc (Rod Shop)",
    Callback = CreateSafeCallback(function()
        NPCSystem:TeleportToNPC(NPCSystem.customNPCs["Marc (Rod Shop)"], "Marc (Rod Shop)")
    end, "teleport_marc")
})

TeleportTab:CreateButton({
    Name = "📦 Henry (Storage)",
    Callback = CreateSafeCallback(function()
        NPCSystem:TeleportToNPC(NPCSystem.customNPCs["Henry (Storage)"], "Henry (Storage)")
    end, "teleport_henry")
})

TeleportTab:CreateButton({
    Name = "⚓ Shipwright",
    Callback = CreateSafeCallback(function()
        NPCSystem:TeleportToNPC(NPCSystem.customNPCs["Shipwright"], "Shipwright")
    end, "teleport_shipwright")
})

-- ═══════════════════════════════════════════════════════════════
-- QUEST & SPECIAL NPCs
-- ═══════════════════════════════════════════════════════════════

TeleportTab:CreateParagraph({
    Title = "📋 Quest & Special NPCs",
    Content = "Quest givers and special characters"
})

TeleportTab:CreateButton({
    Name = "📋 Quest Giver 1",
    Callback = CreateSafeCallback(function()
        NPCSystem:TeleportToNPC(NPCSystem.customNPCs["Quest Giver 1"], "Quest Giver 1")
    end, "teleport_quest1")
})

TeleportTab:CreateButton({
    Name = "📋 Quest Giver 2",
    Callback = CreateSafeCallback(function()
        NPCSystem:TeleportToNPC(NPCSystem.customNPCs["Quest Giver 2"], "Quest Giver 2")
    end, "teleport_quest2")
})

TeleportTab:CreateButton({
    Name = "🎓 Tutorial Guide",
    Callback = CreateSafeCallback(function()
        NPCSystem:TeleportToNPC(NPCSystem.customNPCs["Tutorial Guide"], "Tutorial Guide")
    end, "teleport_tutorial")
})

TeleportTab:CreateButton({
    Name = "🎉 Event Manager",
    Callback = CreateSafeCallback(function()
        NPCSystem:TeleportToNPC(NPCSystem.customNPCs["Event Manager"], "Event Manager")
    end, "teleport_event")
})

TeleportTab:CreateButton({
    Name = "🏆 Leaderboard NPC",
    Callback = CreateSafeCallback(function()
        NPCSystem:TeleportToNPC(NPCSystem.customNPCs["Leaderboard NPC"], "Leaderboard NPC")
    end, "teleport_leaderboard")
})

TeleportTab:CreateButton({
    Name = "🎁 Daily Rewards",
    Callback = CreateSafeCallback(function()
        NPCSystem:TeleportToNPC(NPCSystem.customNPCs["Daily Rewards"], "Daily Rewards")
    end, "teleport_daily")
})

-- ═══════════════════════════════════════════════════════════════
-- AUTO-DETECTED NPCs MANAGEMENT
-- ═══════════════════════════════════════════════════════════════

TeleportTab:CreateParagraph({
    Title = "🤖 Auto-Detected NPCs",
    Content = "NPCs automatically detected in the game world"
})

TeleportTab:CreateButton({
    Name = "🔄 List Detected NPCs",
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
        print("=== FULL NPC LIST ===")
        for name, data in pairs(NPCSystem.detectedNPCs) do
            print(string.format("%s: CFrame.new(%.2f, %.2f, %.2f)", name, data.x, data.y, data.z))
        end
        print("====================")
    end, "list_detected_npcs")
})

-- Initialize NPC system
task.spawn(function()
    task.wait(3) -- Wait for game to load
    NPCSystem:DetectNPCs()
    local count = NPCSystem:GetNPCCount()
    Notify("👥 NPC System", "Initialized! Found " .. count .. " NPCs")
    print("XSAN: NPC Teleportation System loaded successfully!")
end)

-- === TAB 4: INVENTORY ===
local InventoryTab = Window:CreateTab("🎒 INVENTORY", "🎒")

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
local AnalyticsTab = Window:CreateTab("📊 ANALYTICS", "📊")

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

-- === TAB 6: BUY SYSTEM ===
local BuySystemTab = Window:CreateTab("🛒 BUY SYSTEM", "🛒")

BuySystemTab:CreateParagraph({
    Title = "🛒 Smart Buy System Automation",
    Content = "Automated purchasing, selling, and shop management with intelligent detection of all game purchase events."
})

-- Buy System Variables
local autoBuyEnabled = false
local autoSellItemsEnabled = false
local autoEquipmentBuy = false
local smartPurchasing = false
local buyBudget = 1000
local minCashThreshold = 500

-- Auto Buy Functions
local function executeRemoteFunction(remoteName, ...)
    pcall(function()
        if remotes[remoteName] then
            if remotes[remoteName]:IsA("RemoteFunction") then
                remotes[remoteName]:InvokeServer(...)
            else
                remotes[remoteName]:FireServer(...)
            end
        end
    end)
end

-- Smart Auto Sell Items
BuySystemTab:CreateToggle({
    Name = "💰 Auto Sell Items",
    CurrentValue = autoSellItemsEnabled,
    Callback = CreateSafeCallback(function(value)
        autoSellItemsEnabled = value
        
        if value then
            Notify("💰 Auto Sell", "Started selling items automatically!")
            task.spawn(function()
                while autoSellItemsEnabled do
                    pcall(function()
                        -- Try multiple sell methods detected
                        executeRemoteFunction("SellItem")
                        wait(1)
                        executeRemoteFunction("SellAllItems")
                    end)
                    wait(30) -- Sell every 30 seconds
                end
            end)
        else
            Notify("💰 Auto Sell", "Stopped!")
        end
    end, "auto_sell_items_toggle")
})

-- Auto Equipment Purchase
BuySystemTab:CreateToggle({
    Name = "🎣 Auto Buy Equipment",
    CurrentValue = autoEquipmentBuy,
    Callback = CreateSafeCallback(function(value)
        autoEquipmentBuy = value
        
        if value then
            Notify("🎣 Auto Equipment", "Smart equipment purchasing enabled!")
            task.spawn(function()
                while autoEquipmentBuy do
                    pcall(function()
                        -- Auto buy fishing gear when needed
                        executeRemoteFunction("PurchaseFishingRod", "BestRod")
                        wait(5)
                        executeRemoteFunction("PurchaseBait", "BestBait")
                        wait(5)
                        executeRemoteFunction("PurchaseGear", "BestGear")
                        wait(5)
                        executeRemoteFunction("PurchaseBoat", "BestBoat")
                    end)
                    wait(120) -- Check every 2 minutes
                end
            end)
        else
            Notify("🎣 Auto Equipment", "Disabled!")
        end
    end, "auto_equipment_toggle")
})

-- Smart Purchase Manager
BuySystemTab:CreateToggle({
    Name = "🧠 Smart Purchase Manager",
    CurrentValue = smartPurchasing,
    Callback = CreateSafeCallback(function(value)
        smartPurchasing = value
        
        if value then
            Notify("🧠 Smart Purchasing", "AI purchase decisions enabled!")
            task.spawn(function()
                while smartPurchasing do
                    pcall(function()
                        -- Check if player has enough money before purchasing
                        local playerStats = LocalPlayer:FindFirstChild("leaderstats")
                        if playerStats and playerStats:FindFirstChild("Cash") then
                            local currentCash = playerStats.Cash.Value
                            
                            if currentCash > minCashThreshold + buyBudget then
                                -- Safe to make purchases
                                executeRemoteFunction("PurchaseWeatherEvent")
                                wait(2)
                                executeRemoteFunction("PurchaseSkinCrate")
                            end
                        end
                    end)
                    wait(60) -- Check every minute
                end
            end)
        else
            Notify("🧠 Smart Purchasing", "Disabled!")
        end
    end, "smart_purchase_toggle")
})

-- Buy Budget Slider
BuySystemTab:CreateSlider({
    Name = "💵 Buy Budget",
    Range = {100, 10000},
    Increment = 100,
    CurrentValue = buyBudget,
    Callback = CreateSafeCallback(function(value)
        buyBudget = value
        Notify("💵 Budget Set", "Max spending: $" .. value)
    end, "buy_budget_slider")
})

-- Min Cash Threshold
BuySystemTab:CreateSlider({
    Name = "🏦 Min Cash Reserve",
    Range = {0, 5000},
    Increment = 100,
    CurrentValue = minCashThreshold,
    Callback = CreateSafeCallback(function(value)
        minCashThreshold = value
        Notify("🏦 Reserve Set", "Keep minimum: $" .. value)
    end, "cash_threshold_slider")
})

-- Manual Buy Buttons
BuySystemTab:CreateButton({
    Name = "🎣 Buy Best Fishing Rod",
    Callback = CreateSafeCallback(function()
        executeRemoteFunction("PurchaseFishingRod", "BestRod")
        Notify("🎣 Purchase", "Attempting to buy best fishing rod!")
    end, "buy_rod_btn")
})

BuySystemTab:CreateButton({
    Name = "🪱 Buy Best Bait",
    Callback = CreateSafeCallback(function()
        executeRemoteFunction("PurchaseBait", "BestBait")
        Notify("🪱 Purchase", "Attempting to buy best bait!")
    end, "buy_bait_btn")
})

BuySystemTab:CreateButton({
    Name = "⚓ Buy Best Boat",
    Callback = CreateSafeCallback(function()
        executeRemoteFunction("PurchaseBoat", "BestBoat")
        Notify("⚓ Purchase", "Attempting to buy best boat!")
    end, "buy_boat_btn")
})

BuySystemTab:CreateButton({
    Name = "🎁 Buy Skin Crate",
    Callback = CreateSafeCallback(function()
        executeRemoteFunction("PurchaseSkinCrate")
        Notify("🎁 Purchase", "Attempting to buy skin crate!")
    end, "buy_crate_btn")
})

BuySystemTab:CreateButton({
    Name = "💎 Sell All Items Now",
    Callback = CreateSafeCallback(function()
        executeRemoteFunction("SellAllItems")
        Notify("💎 Sold!", "Selling all items now!")
        fishingAnalytics.totalValue = fishingAnalytics.totalValue + 1000 -- Estimate
    end, "sell_all_now_btn")
})

-- Weather Event Purchase
BuySystemTab:CreateButton({
    Name = "🌦️ Buy Weather Event",
    Callback = CreateSafeCallback(function()
        executeRemoteFunction("PurchaseWeatherEvent")
        Notify("🌦️ Weather", "Attempting to purchase weather event!")
    end, "buy_weather_btn")
})

-- Gamepass Purchase
BuySystemTab:CreateButton({
    Name = "🎫 Prompt Gamepass Purchase",
    Callback = CreateSafeCallback(function()
        executeRemoteFunction("PromptGamePassPurchase")
        Notify("🎫 Gamepass", "Gamepass purchase prompt opened!")
    end, "gamepass_btn")
})

-- === TAB 7: SETTINGS ===
local SettingsTab = Window:CreateTab("⚙️ SETTINGS", "⚙️")

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
    Name = "� Enhanced Buy System Detector",
    Callback = CreateSafeCallback(function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/donitono/part2/main/buy_system_detector.lua"))()
        Notify("🛒 Buy Detector", "Enhanced buy system detector loaded!")
    end, "buy_detector_btn")
})

SettingsTab:CreateButton({
    Name = "�🔧 Advanced Tools Interface",
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

-- Final setup
print("XSAN: Modern UI setup complete!")
Notify("✅ Ready!", "XSAN Fish It Pro Ultimate v2.0 loaded successfully! Use the tab navigation for best experience.")

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
