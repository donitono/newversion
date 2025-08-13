--[[
	XSAN Modern UI Suite
	Tab-based interface optimized for mobile landscape
	Based on Rayfield with modern enhancements
	Created by XSAN
]]

if debugX then
	warn('Initialising XSAN Modern UI')
end

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
RayfieldLibrary.DisplayOrder = 10 -- Lower display order so notifications appear on top

-- Try to parent to CoreGui first, then fallback to PlayerGui
local success = pcall(function()
	RayfieldLibrary.Parent = CoreGui
end)

if not success then
	RayfieldLibrary.Parent = PlayerGui
end

-- Rayfield Object
local Rayfield = {}
local CurrentWindow = nil
local CurrentTabs = {}
local CurrentTab = nil

-- Functions
function Rayfield:CreateWindow(Settings)
	local WindowSettings = {
		Name = Settings.Name or "XSAN Modern Interface",
		LoadingTitle = Settings.LoadingTitle or "XSAN Modern Interface",
		LoadingSubtitle = Settings.LoadingSubtitle or "by XSAN",
		Theme = Settings.Theme or "DarkBlue",
		ConfigurationSaving = {
			Enabled = Settings.ConfigurationSaving and Settings.ConfigurationSaving.Enabled or false,
			FolderName = Settings.ConfigurationSaving and Settings.ConfigurationSaving.FolderName or "XSAN",
			FileName = Settings.ConfigurationSaving and Settings.ConfigurationSaving.FileName or "Config"
		}
	}

	-- Detect mobile and orientation
	local isMobile = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled
	local screenSize = workspace.CurrentCamera.ViewportSize
	local isLandscape = screenSize.X > screenSize.Y

	-- Create Main Container (compact untuk landscape)
	local Main = Instance.new("Frame")
	Main.Name = "Main"
	Main.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
	Main.BorderSizePixel = 0
	Main.Active = true
	Main.Draggable = true
	
	-- Ukuran yang lebih kecil dan proporsional
	if isMobile and isLandscape then
		Main.Size = UDim2.new(0, 580, 0, 340) -- Lebih kecil untuk landscape
		Main.Position = UDim2.new(0.5, -290, 0.5, -170) -- Centered
	elseif isMobile then
		Main.Size = UDim2.new(0, 320, 0, 420) -- Kecil untuk portrait
		Main.Position = UDim2.new(0.5, -160, 0.5, -210)
	else
		Main.Size = UDim2.new(0, 600, 0, 400) -- Desktop normal size
		Main.Position = UDim2.new(0.5, -300, 0.5, -200)
	end
	
	Main.Parent = RayfieldLibrary
	
	-- Add corner rounding
	local MainCorner = Instance.new("UICorner")
	MainCorner.CornerRadius = UDim.new(0, 12)
	MainCorner.Parent = Main

	-- Add gradient background
	local Gradient = Instance.new("UIGradient")
	Gradient.Color = ColorSequence.new{
		ColorSequenceKeypoint.new(0, Color3.fromRGB(35, 35, 50)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(20, 20, 30))
	}
	Gradient.Rotation = 45
	Gradient.Parent = Main

	-- Title Bar (compact)
	local TitleBar = Instance.new("Frame")
	TitleBar.Name = "TitleBar"
	TitleBar.Size = UDim2.new(1, 0, 0, 35) -- Compact height
	TitleBar.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
	TitleBar.BorderSizePixel = 0
	TitleBar.Parent = Main
	
	local TitleBarCorner = Instance.new("UICorner")
	TitleBarCorner.CornerRadius = UDim.new(0, 12)
	TitleBarCorner.Parent = TitleBar

	-- Title Label
	local TitleLabel = Instance.new("TextLabel")
	TitleLabel.Size = UDim2.new(1, -80, 1, 0)
	TitleLabel.Position = UDim2.new(0, 8, 0, 0)
	TitleLabel.BackgroundTransparency = 1
	TitleLabel.Text = WindowSettings.Name
	TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	TitleLabel.Font = Enum.Font.SourceSansBold
	TitleLabel.TextSize = 14 -- Compact text size
	TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
	TitleLabel.Parent = TitleBar

	-- Close Button
	local CloseButton = Instance.new("TextButton")
	CloseButton.Size = UDim2.new(0, 30, 0, 25)
	CloseButton.Position = UDim2.new(1, -35, 0, 5)
	CloseButton.BackgroundColor3 = Color3.fromRGB(200, 80, 80)
	CloseButton.BorderSizePixel = 0
	CloseButton.Text = "✖"
	CloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
	CloseButton.Font = Enum.Font.SourceSansBold
	CloseButton.TextSize = 12
	CloseButton.Parent = TitleBar
	
	local CloseCorner = Instance.new("UICorner")
	CloseCorner.CornerRadius = UDim.new(0, 6)
	CloseCorner.Parent = CloseButton

	CloseButton.MouseButton1Click:Connect(function()
		RayfieldLibrary:Destroy()
	end)

	-- Tab Container (compact)
	local TabContainer = Instance.new("Frame")
	TabContainer.Name = "TabContainer"
	TabContainer.Size = UDim2.new(1, -16, 0, 32) -- Compact height
	TabContainer.Position = UDim2.new(0, 8, 0, 40)
	TabContainer.BackgroundTransparency = 1
	TabContainer.Parent = Main

	local TabLayout = Instance.new("UIListLayout")
	TabLayout.FillDirection = Enum.FillDirection.Horizontal
	TabLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
	TabLayout.Padding = UDim.new(0, 3)
	TabLayout.Parent = TabContainer

	-- Content Area (compact)
	local ContentFrame = Instance.new("Frame")
	ContentFrame.Name = "ContentFrame"
	ContentFrame.Size = UDim2.new(1, -16, 1, -85) -- Adjusted for compact layout
	ContentFrame.Position = UDim2.new(0, 8, 0, 77)
	ContentFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
	ContentFrame.BorderSizePixel = 0
	ContentFrame.Parent = Main
	
	local ContentCorner = Instance.new("UICorner")
	ContentCorner.CornerRadius = UDim.new(0, 6)
	ContentCorner.Parent = ContentFrame

	-- Scrollable Content (improved scrolling)
	local ScrollFrame = Instance.new("ScrollingFrame")
	ScrollFrame.Name = "ScrollFrame"
	ScrollFrame.Size = UDim2.new(1, -8, 1, -8)
	ScrollFrame.Position = UDim2.new(0, 4, 0, 4)
	ScrollFrame.BackgroundTransparency = 1
	ScrollFrame.BorderSizePixel = 0
	ScrollFrame.ScrollBarThickness = isMobile and 12 or 8
	ScrollFrame.ScrollBarImageColor3 = Color3.fromRGB(80, 80, 120)
	ScrollFrame.ScrollBarImageTransparency = 0.2
	ScrollFrame.ScrollingEnabled = true
	ScrollFrame.Active = true
	ScrollFrame.Selectable = true
	ScrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
	ScrollFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
	ScrollFrame.Parent = ContentFrame

	-- Window Object
	local Window = {}
	CurrentWindow = Window
	CurrentTabs = {}
	
	-- Tab Management
	function Window:CreateTab(Name, Icon)
		local TabButton = Instance.new("TextButton")
		TabButton.Name = Name .. "Tab"
		TabButton.Size = UDim2.new(0, 90, 1, 0) -- Compact width
		TabButton.BackgroundColor3 = #CurrentTabs == 0 and Color3.fromRGB(60, 120, 180) or Color3.fromRGB(50, 50, 60)
		TabButton.BorderSizePixel = 0
		TabButton.Text = (Icon and Icon .. " " or "") .. Name
		TabButton.TextColor3 = Color3.fromRGB(255, 255, 255)
		TabButton.Font = Enum.Font.SourceSansBold
		TabButton.TextSize = 9 -- Compact text
		TabButton.Parent = TabContainer
		
		local TabCorner = Instance.new("UICorner")
		TabCorner.CornerRadius = UDim.new(0, 4)
		TabCorner.Parent = TabButton

		-- Tab Content Container
		local TabContent = Instance.new("Frame")
		TabContent.Name = Name .. "Content"
		TabContent.Size = UDim2.new(1, 0, 1, 0)
		TabContent.BackgroundTransparency = 1
		TabContent.Visible = #CurrentTabs == 0 -- First tab visible
		TabContent.Parent = ScrollFrame

		local TabContentLayout = Instance.new("UIListLayout")
		TabContentLayout.SortOrder = Enum.SortOrder.LayoutOrder
		TabContentLayout.Padding = UDim.new(0, 5)
		TabContentLayout.Parent = TabContent

		-- Tab Object
		local Tab = {
			Name = Name,
			Button = TabButton,
			Content = TabContent,
			Layout = TabContentLayout
		}

		-- Tab Click Event
		TabButton.MouseButton1Click:Connect(function()
			-- Hide all tabs
			for _, tabData in pairs(CurrentTabs) do
				tabData.Content.Visible = false
				tabData.Button.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
			end
			
			-- Show selected tab
			TabContent.Visible = true
			TabButton.BackgroundColor3 = Color3.fromRGB(60, 120, 180)
			CurrentTab = Tab
		end)

		table.insert(CurrentTabs, Tab)
		if #CurrentTabs == 1 then
			CurrentTab = Tab
		end

		-- Add methods to Tab
		function Tab:CreateParagraph(Settings)
			return Window:CreateParagraph(Settings)
		end
		
		function Tab:CreateButton(Settings)
			return Window:CreateButton(Settings)
		end
		
		function Tab:CreateToggle(Settings)
			return Window:CreateToggle(Settings)
		end
		
		function Tab:CreateSlider(Settings)
			return Window:CreateSlider(Settings)
		end
		
		function Tab:CreateInput(Settings)
			return Window:CreateInput(Settings)
		end
		
		function Tab:CreateDropdown(Settings)
			return Window:CreateDropdown(Settings)
		end

		return Tab
	end

	-- Window Methods
	function Window:CreateParagraph(Settings)
		if not CurrentTab then return end
		
		local Container = Instance.new("Frame")
		Container.Size = UDim2.new(1, 0, 0, 0)
		Container.BackgroundTransparency = 1
		Container.AutomaticSize = Enum.AutomaticSize.Y
		Container.Parent = CurrentTab.Content

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

	-- Button
	function Window:CreateButton(Settings)
		if not CurrentTab then return end
		
		local Button = Instance.new("TextButton")
		Button.Size = UDim2.new(1, 0, 0, 30)
		Button.BackgroundColor3 = Color3.fromRGB(60, 120, 180)
		Button.BorderSizePixel = 0
		Button.Text = Settings.Name or "Button"
		Button.TextColor3 = Color3.fromRGB(255, 255, 255)
		Button.Font = Enum.Font.SourceSansBold
		Button.TextSize = 11
		Button.Parent = CurrentTab.Content

		local Corner = Instance.new("UICorner")
		Corner.CornerRadius = UDim.new(0, 6)
		Corner.Parent = Button

		Button.MouseButton1Click:Connect(function()
			if Settings.Callback then
				Settings.Callback()
			end
			
			-- Button feedback
			TweenService:Create(Button, TweenInfo.new(0.1), {
				BackgroundColor3 = Color3.fromRGB(80, 140, 200)
			}):Play()
			
			wait(0.1)
			TweenService:Create(Button, TweenInfo.new(0.1), {
				BackgroundColor3 = Color3.fromRGB(60, 120, 180)
			}):Play()
		end)

		return Button
	end

	-- Toggle
	function Window:CreateToggle(Settings)
		if not CurrentTab then return end
		
		local Container = Instance.new("Frame")
		Container.Size = UDim2.new(1, 0, 0, 35)
		Container.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
		Container.BorderSizePixel = 0
		Container.Parent = CurrentTab.Content

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

		local ToggleCircle = Instance.new("Frame")
		ToggleCircle.Size = UDim2.new(0, 16, 0, 16)
		ToggleCircle.Position = Settings.CurrentValue and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)
		ToggleCircle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		ToggleCircle.BorderSizePixel = 0
		ToggleCircle.Parent = ToggleButton

		local CircleCorner = Instance.new("UICorner")
		CircleCorner.CornerRadius = UDim.new(0.5, 0)
		CircleCorner.Parent = ToggleCircle

		local isToggled = Settings.CurrentValue or false

		ToggleButton.MouseButton1Click:Connect(function()
			isToggled = not isToggled
			
			-- Animate toggle
			TweenService:Create(ToggleButton, TweenInfo.new(0.2), {
				BackgroundColor3 = isToggled and Color3.fromRGB(60, 120, 180) or Color3.fromRGB(80, 80, 80)
			}):Play()
			
			TweenService:Create(ToggleCircle, TweenInfo.new(0.2), {
				Position = isToggled and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)
			}):Play()

			if Settings.Callback then
				Settings.Callback(isToggled)
			end
		end)

		return Container
	end

	-- Slider
	function Window:CreateSlider(Settings)
		if not CurrentTab then return end
		
		local Container = Instance.new("Frame")
		Container.Size = UDim2.new(1, 0, 0, 50)
		Container.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
		Container.BorderSizePixel = 0
		Container.Parent = CurrentTab.Content

		local ContainerCorner = Instance.new("UICorner")
		ContainerCorner.CornerRadius = UDim.new(0, 6)
		ContainerCorner.Parent = Container

		local Label = Instance.new("TextLabel")
		Label.Size = UDim2.new(1, 0, 0, 20)
		Label.Position = UDim2.new(0, 10, 0, 5)
		Label.BackgroundTransparency = 1
		Label.Text = Settings.Name or "Slider"
		Label.TextColor3 = Color3.fromRGB(255, 255, 255)
		Label.Font = Enum.Font.SourceSans
		Label.TextSize = 11
		Label.TextXAlignment = Enum.TextXAlignment.Left
		Label.Parent = Container

		local ValueLabel = Instance.new("TextLabel")
		ValueLabel.Size = UDim2.new(0, 50, 0, 20)
		ValueLabel.Position = UDim2.new(1, -60, 0, 5)
		ValueLabel.BackgroundTransparency = 1
		ValueLabel.Text = tostring(Settings.CurrentValue or Settings.Range[1])
		ValueLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
		ValueLabel.Font = Enum.Font.SourceSans
		ValueLabel.TextSize = 10
		ValueLabel.TextXAlignment = Enum.TextXAlignment.Right
		ValueLabel.Parent = Container

		local SliderFrame = Instance.new("Frame")
		SliderFrame.Size = UDim2.new(1, -20, 0, 4)
		SliderFrame.Position = UDim2.new(0, 10, 1, -15)
		SliderFrame.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
		SliderFrame.BorderSizePixel = 0
		SliderFrame.Parent = Container

		local SliderCorner = Instance.new("UICorner")
		SliderCorner.CornerRadius = UDim.new(0.5, 0)
		SliderCorner.Parent = SliderFrame

		local SliderButton = Instance.new("TextButton")
		SliderButton.Size = UDim2.new(0, 12, 0, 12)
		SliderButton.Position = UDim2.new(0, -6, 0.5, -6)
		SliderButton.BackgroundColor3 = Color3.fromRGB(60, 120, 180)
		SliderButton.BorderSizePixel = 0
		SliderButton.Text = ""
		SliderButton.Parent = SliderFrame

		local ButtonCorner = Instance.new("UICorner")
		ButtonCorner.CornerRadius = UDim.new(0.5, 0)
		ButtonCorner.Parent = SliderButton

		local Range = Settings.Range or {0, 100}
		local Increment = Settings.Increment or 1
		local CurrentValue = Settings.CurrentValue or Range[1]

		-- Set initial position
		local InitialPercentage = (CurrentValue - Range[1]) / (Range[2] - Range[1])
		SliderButton.Position = UDim2.new(InitialPercentage, -6, 0.5, -6)

		local dragging = false

		SliderButton.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
				dragging = true
			end
		end)

		UserInputService.InputEnded:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
				dragging = false
			end
		end)

		UserInputService.InputChanged:Connect(function(input)
			if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
				local SliderPosition = SliderFrame.AbsolutePosition.X
				local SliderSize = SliderFrame.AbsoluteSize.X
				local MousePosition = input.Position.X

				local RelativePosition = math.clamp((MousePosition - SliderPosition) / SliderSize, 0, 1)
				local Value = Range[1] + (Range[2] - Range[1]) * RelativePosition
				Value = math.floor(Value / Increment + 0.5) * Increment
				Value = math.clamp(Value, Range[1], Range[2])

				CurrentValue = Value
				ValueLabel.Text = tostring(Value)
				SliderButton.Position = UDim2.new(RelativePosition, -6, 0.5, -6)

				if Settings.Callback then
					Settings.Callback(Value)
				end
			end
		end)

		return Container
	end

	-- Input
	function Window:CreateInput(Settings)
		if not CurrentTab then return end
		
		local Container = Instance.new("Frame")
		Container.Size = UDim2.new(1, 0, 0, 60)
		Container.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
		Container.BorderSizePixel = 0
		Container.Parent = CurrentTab.Content

		local ContainerCorner = Instance.new("UICorner")
		ContainerCorner.CornerRadius = UDim.new(0, 6)
		ContainerCorner.Parent = Container

		local Label = Instance.new("TextLabel")
		Label.Size = UDim2.new(1, 0, 0, 20)
		Label.Position = UDim2.new(0, 10, 0, 5)
		Label.BackgroundTransparency = 1
		Label.Text = Settings.Name or "Input"
		Label.TextColor3 = Color3.fromRGB(255, 255, 255)
		Label.Font = Enum.Font.SourceSans
		Label.TextSize = 11
		Label.TextXAlignment = Enum.TextXAlignment.Left
		Label.Parent = Container

		local InputBox = Instance.new("TextBox")
		InputBox.Size = UDim2.new(1, -20, 0, 25)
		InputBox.Position = UDim2.new(0, 10, 0, 30)
		InputBox.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
		InputBox.BorderSizePixel = 0
		InputBox.Text = ""
		InputBox.PlaceholderText = Settings.PlaceholderText or "Enter text..."
		InputBox.TextColor3 = Color3.fromRGB(255, 255, 255)
		InputBox.PlaceholderColor3 = Color3.fromRGB(150, 150, 150)
		InputBox.Font = Enum.Font.SourceSans
		InputBox.TextSize = 10
		InputBox.TextXAlignment = Enum.TextXAlignment.Left
		InputBox.ClearTextOnFocus = false
		InputBox.Parent = Container

		local InputCorner = Instance.new("UICorner")
		InputCorner.CornerRadius = UDim.new(0, 4)
		InputCorner.Parent = InputBox

		InputBox.FocusLost:Connect(function(enterPressed)
			if Settings.Callback then
				Settings.Callback(InputBox.Text)
			end
			
			if Settings.RemoveTextAfterFocusLost then
				InputBox.Text = ""
			end
		end)

		return Container
	end

	-- Dropdown
	function Window:CreateDropdown(Settings)
		if not CurrentTab then return end
		
		local Container = Instance.new("Frame")
		Container.Size = UDim2.new(1, 0, 0, 35)
		Container.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
		Container.BorderSizePixel = 0
		Container.Parent = CurrentTab.Content

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

		local DropdownCorner = Instance.new("UICorner")
		DropdownCorner.CornerRadius = UDim.new(0, 4)
		DropdownCorner.Parent = DropdownButton

		-- Simple dropdown - for now just cycle through options
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

	-- Additional utility functions for window
	-- Additional utility functions for window
	function Window:Refresh()
		-- Refresh function
		if Main and Main.Parent then
			Main.Parent = Main.Parent -- Force refresh
		end
	end

	return Window
end

-- Return the Rayfield object
return Rayfield
