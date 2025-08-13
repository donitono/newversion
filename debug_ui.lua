-- Debug UI Test
print("DEBUG: Starting UI test...")

local success, result = pcall(function()
    local uiContent = game:HttpGet("https://raw.githubusercontent.com/donitono/part2/main/ui_modern.lua")
    print("DEBUG: UI content loaded, length:", #uiContent)
    
    local uiFunc, loadError = loadstring(uiContent)
    if not uiFunc then
        error("Compilation failed: " .. tostring(loadError))
    end
    print("DEBUG: UI compiled successfully")
    
    local Rayfield = uiFunc()
    if not Rayfield then
        error("UI function returned nil")
    end
    print("DEBUG: Rayfield object created:", type(Rayfield))
    
    local Window = Rayfield:CreateWindow({
        Name = "Debug Test Window",
        LoadingTitle = "Debug Test",
        LoadingSubtitle = "Testing UI",
    })
    
    if not Window then
        error("CreateWindow returned nil")
    end
    print("DEBUG: Window created successfully:", type(Window))
    
    local Tab = Window:CreateTab("Test Tab", "gear")
    if not Tab then
        error("CreateTab returned nil")
    end
    print("DEBUG: Tab created successfully:", type(Tab))
    
    print("DEBUG: All tests passed!")
    return true
end)

if not success then
    print("DEBUG ERROR:", result)
end
