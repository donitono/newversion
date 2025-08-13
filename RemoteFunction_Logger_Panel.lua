-- RemoteFunction_Logger_Panel.lua
-- Modern dark UI, filter, only-my-actions, replay & loop, save file
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")

local MAX_LOGS = 200
local FILENAME = "RemoteFunctions.txt"

local function ts() return os.date("[%H:%M:%S]") end
local function safe_tostring(v) local ok,res=pcall(function() return tostring(v) end) return ok and res or "<unprintable>" end
local function append_file(name, text)
    if writefile and appendfile then
        if not isfile(name) then writefile(name, "") end
        appendfile(name, text .. "\n")
    end
end

-- UI
local CoreGui = game:GetService("CoreGui")
local screen = Instance.new("ScreenGui"); screen.Name = "RF_Logger_UI"; screen.Parent = CoreGui

-- Floating toggle button
local floatingBtn = Instance.new("TextButton", screen)
floatingBtn.Size = UDim2.new(0, 50, 0, 50)
floatingBtn.Position = UDim2.new(0, 20, 0, 200)
floatingBtn.Text = "🔧"
floatingBtn.TextSize = 20
floatingBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
floatingBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
floatingBtn.BorderSizePixel = 0
floatingBtn.ZIndex = 1000
local floatingCorner = Instance.new("UICorner", floatingBtn)
floatingCorner.CornerRadius = UDim.new(0, 25)

-- Make floating button draggable
local UserInputService = game:GetService("UserInputService")
local isDragging = false
local dragStart = nil
local startPos = nil
local clickStart = 0

floatingBtn.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        clickStart = tick()
        dragStart = input.Position
        startPos = floatingBtn.Position
    end
end)

floatingBtn.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement and dragStart then
        local delta = input.Position - dragStart
        if delta.Magnitude > 5 then
            isDragging = true
            floatingBtn.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end
end)

floatingBtn.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        local clickDuration = tick() - (clickStart or 0)
        task.spawn(function()
            task.wait(0.05)
            if clickDuration < 0.3 and not isDragging then
                local isUIVisible = main.Visible
                isUIVisible = not isUIVisible
                main.Visible = isUIVisible
                floatingBtn.Text = isUIVisible and "🔧" or "👁️"
            end
            isDragging = false
            dragStart = nil
            startPos = nil
        end)
    end
end)

local main = Instance.new("Frame", screen); main.Size = UDim2.new(0,520,0,420); main.Position = UDim2.new(0.14,0,0.14,0)
main.BackgroundColor3 = Color3.fromRGB(22,22,22); main.BorderSizePixel = 0; Instance.new("UICorner", main).CornerRadius = UDim.new(0,10)

local header = Instance.new("Frame", main); header.Size = UDim2.new(1,0,0,42); header.BackgroundColor3 = Color3.fromRGB(30,30,30)
Instance.new("UICorner", header).CornerRadius = UDim.new(0,10)
local title = Instance.new("TextLabel", header); title.Position = UDim2.new(0,12,0,0); title.Size = UDim2.new(0.6,0,1,0)
title.Text = "RemoteFunction Logger (InvokeServer)"; title.BackgroundTransparency = 1; title.TextColor3 = Color3.fromRGB(230,230,230)
title.Font = Enum.Font.SourceSansBold; title.TextSize = 16

local btnMin = Instance.new("TextButton", header); btnMin.Size = UDim2.new(0,36,0,28); btnMin.Position = UDim2.new(1,-44,0,7); btnMin.Text = "—"
btnMin.BackgroundColor3 = Color3.fromRGB(50,50,50); btnMin.TextColor3 = Color3.fromRGB(240,240,240); Instance.new("UICorner", btnMin).CornerRadius = UDim.new(0,6)
local btnCopyAll = Instance.new("TextButton", header); btnCopyAll.Size = UDim2.new(0,86,0,28); btnCopyAll.Position = UDim2.new(1,-140,0,7); btnCopyAll.Text="Copy All"
btnCopyAll.BackgroundColor3 = Color3.fromRGB(60,60,60); btnCopyAll.TextColor3 = Color3.fromRGB(240,240,240); Instance.new("UICorner", btnCopyAll).CornerRadius = UDim.new(0,6)
local filterBox = Instance.new("TextBox", header); filterBox.Size = UDim2.new(0,220,0,28); filterBox.Position = UDim2.new(0.6,0,0,7)
filterBox.PlaceholderText="Filter name (live)"; filterBox.BackgroundColor3 = Color3.fromRGB(40,40,40); filterBox.TextColor3 = Color3.fromRGB(230,230,230); Instance.new("UICorner", filterBox).CornerRadius = UDim.new(0,6)

local left = Instance.new("Frame", main); left.Size = UDim2.new(0.62,-12,1,-56); left.Position = UDim2.new(0,8,0,48); left.BackgroundTransparency = 1
local right = Instance.new("Frame", main); right.Size = UDim2.new(0.36,-12,1,-56); right.Position = UDim2.new(0.62,12,0,48); right.BackgroundTransparency = 1

local scroll = Instance.new("ScrollingFrame", left); scroll.Size = UDim2.new(1,0,1,0); scroll.CanvasSize = UDim2.new(0,0,0,0); scroll.ScrollBarThickness = 8
local uilist = Instance.new("UIListLayout", scroll); uilist.SortOrder = Enum.SortOrder.LayoutOrder; uilist.Padding = UDim.new(0,6)
local template = Instance.new("TextButton"); template.Size = UDim2.new(1,-10,0,28); template.BackgroundColor3 = Color3.fromRGB(36,36,36)
template.TextColor3 = Color3.fromRGB(230,230,230); template.AutoButtonColor = true; template.TextXAlignment = Enum.TextXAlignment.Left; template.Visible = false
Instance.new("UICorner", template).CornerRadius = UDim.new(0,6)

local lblSelected = Instance.new("TextLabel", right); lblSelected.Size = UDim2.new(1,0,0,26); lblSelected.BackgroundTransparency = 1; lblSelected.Text="Selected: (klik entri)"
lblSelected.TextColor3 = Color3.fromRGB(220,220,220); lblSelected.Font = Enum.Font.SourceSans; lblSelected.TextSize = 14

local argsBox = Instance.new("TextBox", right); argsBox.Size = UDim2.new(1,0,0,120); argsBox.Position = UDim2.new(0,0,0,32)
argsBox.MultiLine = true; argsBox.ClearTextOnFocus = false; argsBox.TextWrapped = true; argsBox.BackgroundColor3 = Color3.fromRGB(35,35,35); argsBox.TextColor3 = Color3.fromRGB(230,230,230)
Instance.new("UICorner", argsBox).CornerRadius = UDim.new(0,6)
local btnReplay = Instance.new("TextButton", right); btnReplay.Size = UDim2.new(1,0,0,32); btnReplay.Position = UDim2.new(0,0,0,160); btnReplay.Text="Replay Once"
btnReplay.BackgroundColor3 = Color3.fromRGB(70,130,180); Instance.new("UICorner", btnReplay).CornerRadius = UDim.new(0,6)

local loopFrame = Instance.new("Frame", right); loopFrame.Size = UDim2.new(1,0,0,32); loopFrame.Position = UDim2.new(0,0,0,200); loopFrame.BackgroundTransparency = 1
local loopToggle = Instance.new("TextButton", loopFrame); loopToggle.Size = UDim2.new(0.5,-6,1,0); loopToggle.Position = UDim2.new(0,0,0,0); loopToggle.Text="Loop: OFF"; loopToggle.BackgroundColor3 = Color3.fromRGB(90,90,90)
Instance.new("UICorner", loopToggle).CornerRadius = UDim.new(0,6)
local delayBox = Instance.new("TextBox", loopFrame); delayBox.Size = UDim2.new(0.5,-6,1,0); delayBox.Position = UDim2.new(0.5,6,0,0); delayBox.PlaceholderText="Delay s"; delayBox.Text="1"
delayBox.BackgroundColor3 = Color3.fromRGB(35,35,35); delayBox.TextColor3 = Color3.fromRGB(230,230,230); Instance.new("UICorner", delayBox).CornerRadius = UDim.new(0,6)

local onlyMeCB = Instance.new("TextButton", right); onlyMeCB.Size = UDim2.new(1,0,0,28); onlyMeCB.Position = UDim2.new(0,0,0,240); onlyMeCB.Text="Only My Actions: OFF"; onlyMeCB.BackgroundColor3 = Color3.fromRGB(60,60,60)
Instance.new("UICorner", onlyMeCB).CornerRadius = UDim.new(0,6)

local btnClear = Instance.new("TextButton", right); btnClear.Size = UDim2.new(1,0,0,28); btnClear.Position = UDim2.new(0,0,0,275); btnClear.Text="Clear UI Logs"; btnClear.BackgroundColor3 = Color3.fromRGB(120,60,60)
Instance.new("UICorner", btnClear).CornerRadius = UDim.new(0,6)
local statusLbl = Instance.new("TextLabel", right); statusLbl.Size = UDim2.new(1,0,0,40); statusLbl.Position = UDim2.new(0,0,0,310)
statusLbl.Text = "Status: Ready"; statusLbl.BackgroundTransparency = 1; statusLbl.TextColor3 = Color3.fromRGB(180,180,180)

-- state
local logs = {}
local uiButtons = {}
local selectedIndex = nil
local loopState = false

local function addEntry(fullPath, argsTbl)
    local line = string.format("%s FUNCTION: %s | Args: %s", ts(), fullPath, table.concat((function()
        local s={}
        for i,v in ipairs(argsTbl) do table.insert(s, safe_tostring(v)) end
        return s
    end)(), ", "))
    table.insert(logs, {time=os.time(), full=fullPath, text=line, args=argsTbl})
    append_file(FILENAME, line)
    if #logs > MAX_LOGS then table.remove(logs,1) end
    -- rebuild UI
    for _,b in ipairs(uiButtons) do if b and b.Parent then b:Destroy() end end; uiButtons = {}
    for i,entry in ipairs(logs) do
        local b = template:Clone(); b.Visible = true; b.Parent = scroll; b.Text = entry.text
        b.MouseButton1Click:Connect(function() selectedIndex = i; lblSelected.Text = "Selected: "..entry.full; local tmp={}; for _,v in ipairs(entry.args) do table.insert(tmp, safe_tostring(v)) end; argsBox.Text = table.concat(tmp,", ") end)
        table.insert(uiButtons, b)
    end
    scroll.CanvasSize = UDim2.new(0,0,0, uilist.AbsoluteContentSize.Y + 12)
end

local function passesFilter(name)
    local f = filterBox.Text
    if not f or f=="" then return true end
    return string.find(string.lower(name), string.lower(f), 1, true) ~= nil
end

local function onlyMy(args)
    if not onlyMeCB._on then return true end
    local a1 = args[1]
    if typeof(a1)=="Instance" and a1:IsA("Player") then return a1==LocalPlayer end
    if type(a1)=="string" then return a1==LocalPlayer.Name end
    for _,v in ipairs(args) do
        if typeof(v)=="Instance" and v:IsA("Player") and v==LocalPlayer then return true end
        if type(v)=="string" and v==LocalPlayer.Name then return true end
    end
    return false
end

-- hook via __namecall for InvokeServer
local function tryHookInvoke()
    local ok, mt = pcall(function() return getrawmetatable(game) end)
    if not ok or not mt then statusLbl.Text = "Status: cannot access metamethods" return end
    local old = mt.__namecall
    pcall(function() setreadonly(mt,false) end)
    mt.__namecall = newcclosure(function(self, ...)
        local method = getnamecallmethod()
        if method == "InvokeServer" and typeof(self)=="Instance" and self:IsA("RemoteFunction") then
            local args = {...}
            if passesFilter(self.Name) and onlyMy(args) then
                addEntry((pcall(function() return self:GetFullName() end) and self:GetFullName() or tostring(self)), args)
            end
        end
        return old(self, ...)
    end)
    pcall(function() setreadonly(mt,true) end)
end

-- initial
tryHookInvoke()

-- UI handlers
btnMin.MouseButton1Click:Connect(function() main.Size = (main.Size.Y.Offset>60) and UDim2.new(0,520,0,46) or UDim2.new(0,520,0,420) end)
btnCopyAll.MouseButton1Click:Connect(function()
    local all = {}
    for _,e in ipairs(logs) do table.insert(all, e.text) end
    local combined = table.concat(all, "\n")
    if pcall(function() return setclipboard end) then pcall(function() setclipboard(combined) end); statusLbl.Text="Copied all to clipboard" else statusLbl.Text="setclipboard not available" end
end)
btnClear.MouseButton1Click:Connect(function() logs={}; for _,b in ipairs(uiButtons) do if b and b.Parent then b:Destroy() end end; uiButtons={}; selectedIndex=nil; lblSelected.Text="Selected: (klik entri)"; argsBox.Text = "" end)
onlyMeCB.MouseButton1Click:Connect(function() onlyMeCB._on = not onlyMeCB._on; onlyMeCB.Text = "Only My Actions: "..(onlyMeCB._on and "ON" or "OFF") end)

btnReplay.MouseButton1Click:Connect(function()
    if not selectedIndex or not logs[selectedIndex] then statusLbl.Text="Pilih entri dulu" return end
    local entry = logs[selectedIndex]
    local txt = argsBox.Text
    local parts = {}
    for s in string.gmatch(txt, "([^,]+)") do
        local t = s:match("^%s*(.-)%s*$")
        local num = tonumber(t)
        if num then table.insert(parts,num) else
            t = t:gsub('^"%s*', ''):gsub('%s*"$','')
            table.insert(parts, t)
        end
    end
    -- try find remote instance
    local ok, remote = pcall(function() return game:FindFirstChild(entry.full, true) end)
    if ok and remote and remote:IsA("RemoteFunction") then
        local success, ret = pcall(function() return remote:InvokeServer(unpack(parts)) end)
        if success then statusLbl.Text = "Invoked: "..entry.full else statusLbl.Text = "Invoke failed: "..tostring(ret) end
    else
        statusLbl.Text = "RemoteFunction not found"
    end
end)

loopToggle.MouseButton1Click:Connect(function()
    loopState = not loopState
    loopToggle.Text = "Loop: "..(loopState and "ON" or "OFF")
    if loopState then
        task.spawn(function()
            while loopState do
                if selectedIndex and logs[selectedIndex] then
                    btnReplay.MouseButton1Click:Wait()
                end
                local d = tonumber(delayBox.Text) or 1
                task.wait(d)
            end
        end)
    end
end)

statusLbl.Text = "Status: Listening InvokeServer. Saved -> "..FILENAME
append_file(FILENAME, ts() .. " RemoteFunction Logger Started")
