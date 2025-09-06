-- UIControls.lua - UI management and controls
local UIControls = {}

-- Services
local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")

-- State variables
local isMinimized = false
local MiniGui = nil
local MiniBtn = nil
local Library = nil

-- Initialize UI controls
function UIControls.init(libraryInstance)
    Library = libraryInstance
    UIControls.createMinimizeSystem()
end

-- Create minimize system
function UIControls.createMinimizeSystem()
    if MiniGui then return end
    
    MiniGui = Instance.new("ScreenGui")
    MiniGui.Name = "AF_Minibar"
    MiniGui.ResetOnSpawn = false
    MiniGui.IgnoreGuiInset = true
    MiniGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    MiniGui.Parent = CoreGui

    MiniBtn = Instance.new("TextButton")
    MiniBtn.Name = "RestoreButton"
    MiniBtn.Size = UDim2.new(0, 200, 0, 40)
    MiniBtn.Position = UDim2.new(0, 20, 0, 80)
    MiniBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    MiniBtn.BorderSizePixel = 0
    MiniBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    MiniBtn.TextSize = 14
    MiniBtn.Font = Enum.Font.GothamSemibold
    MiniBtn.Text = "🚜 Auto Fish v4.2 (Show)"
    MiniBtn.AutoButtonColor = true
    MiniBtn.Visible = false
    MiniBtn.Parent = MiniGui

    -- Add status indicator
    local statusFrame = Instance.new("Frame")
    statusFrame.Size = UDim2.new(1, 0, 0, 3)
    statusFrame.Position = UDim2.new(0, 0, 1, -3)
    statusFrame.BorderSizePixel = 0
    statusFrame.Parent = MiniBtn

    local statusGradient = Instance.new("UIGradient")
    statusGradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 255, 0)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 0, 0))
    }
    statusGradient.Parent = statusFrame

    -- Make draggable
    UIControls.makeDraggable(MiniBtn)
    
    -- Connect restore functionality
    MiniBtn.MouseButton1Click:Connect(function()
        UIControls.restoreUI()
    end)
end

-- Make element draggable
function UIControls.makeDraggable(element)
    local dragging = false
    local dragStart, startPos
    
    element.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = element.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then 
                    dragging = false 
                end
            end)
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            element.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + delta.X,
                startPos.Y.Scale, startPos.Y.Offset + delta.Y
            )
        end
    end)
end

-- Update status indicator
function UIControls.updateStatus(autoStates)
    if not MiniBtn then return end
    
    local activeCount = 0
    local statusText = ""
    
    if autoStates.isAutoFarmOn then 
        activeCount = activeCount + 1
        statusText = statusText .. "🚜"
    end
    if autoStates.isAutoSellOn then 
        activeCount = activeCount + 1
        statusText = statusText .. "💰"
    end
    if autoStates.isAutoCatchOn then 
        activeCount = activeCount + 1
        statusText = statusText .. "🎯"
    end
    
    -- Update gradient based on activity
    local statusFrame = MiniBtn:FindFirstChild("Frame")
    if statusFrame then
        local gradient = statusFrame:FindFirstChild("UIGradient")
        if gradient then
            local intensity = math.min(activeCount / 3, 1)
            gradient.Offset = Vector2.new(-intensity, 0)
        end
    end
    
    MiniBtn.Text = "Auto Fish v4.2 " .. statusText .. " (Show)"
end

-- Minimize UI
function UIControls.minimizeUI()
    if not isMinimized and Library then
        isMinimized = true
        if MiniBtn then MiniBtn.Visible = true end
        Library:ToggleUI()
        print("📱 UI minimized")
    end
end

-- Restore UI
function UIControls.restoreUI()
    if isMinimized and Library then
        isMinimized = false
        if MiniBtn then MiniBtn.Visible = false end
        Library:ToggleUI()
        print("📱 UI restored")
    end
end

-- Toggle UI state
function UIControls.toggleUI()
    if isMinimized then
        UIControls.restoreUI()
    else
        UIControls.minimizeUI()
    end
end

-- Add custom minimize button to main UI
function UIControls.addMinimizeButtonToMainUI()
    task.spawn(function()
        task.wait(2) -- Wait for UI to load
        
        local possibleNames = {"Kavo UI", "KavoLibrary", "UI", "MainUI"}
        local kavoGui = nil
        
        -- Find Kavo GUI
        for _, name in pairs(possibleNames) do
            kavoGui = CoreGui:FindFirstChild(name)
            if kavoGui then break end
        end
        
        if not kavoGui then
            for _, gui in pairs(CoreGui:GetChildren()) do
                if gui:IsA("ScreenGui") and gui.Name ~= "AF_Minibar" and gui.Name ~= "GPUSaverScreen" then
                    local frame = gui:FindFirstChildOfClass("Frame")
                    if frame and frame:FindFirstChild("Main") then
                        kavoGui = gui
                        break
                    end
                end
            end
        end
        
        if not kavoGui then
            warn("⚠ Kavo GUI not found for minimize button")
            return
        end
        
        local mainFrame = kavoGui:FindFirstChild("Main") or kavoGui:FindFirstChildOfClass("Frame")
        if not mainFrame then return end
        
        -- Find title bar
        local titleBar = nil
        for _, child in pairs(mainFrame:GetChildren()) do
            if child:IsA("Frame") and (child.Name:lower():find("top") or child.Name:lower():find("title") or child.Size.Y.Offset < 40) then
                titleBar = child
                break
            end
        end
        
        if not titleBar then
            local topMost = nil
            local smallestY = math.huge
            
            for _, child in pairs(mainFrame:GetChildren()) do
                if child:IsA("Frame") and child.Position.Y.Offset < smallestY then
                    smallestY = child.Position.Y.Offset
                    topMost = child
                end
            end
            titleBar = topMost
        end
        
        if not titleBar then
            warn("⚠ Title bar not found")
            return
        end
        
        -- Find close button for positioning
        local closeBtn = nil
        for _, child in pairs(titleBar:GetDescendants()) do
            if child:IsA("TextButton") and (child.Text == "X" or child.Text == "✕" or child.Text:find("close")) then
                closeBtn = child
                break
            end
        end
        
        -- Create minimize button
        local minimizeBtn = Instance.new("TextButton")
        minimizeBtn.Name = "CustomMinimizeButton"
        minimizeBtn.Size = UDim2.new(0, 20, 0, 20)
        
        if closeBtn then
            minimizeBtn.Position = UDim2.new(0, closeBtn.Position.X.Offset - 25, 0, closeBtn.Position.Y.Offset)
        else
            minimizeBtn.Position = UDim2.new(1, -45, 0, 5)
        end
        
        minimizeBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
        minimizeBtn.BorderSizePixel = 0
        minimizeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        minimizeBtn.TextSize = 12
        minimizeBtn.Font = Enum.Font.GothamBold
        minimizeBtn.Text = "−"
        minimizeBtn.TextYAlignment = Enum.TextYAlignment.Center
        minimizeBtn.ZIndex = 10
        minimizeBtn.Parent = titleBar
        
        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, 2)
        corner.Parent = minimizeBtn
        
        -- Button hover effects
        minimizeBtn.MouseEnter:Connect(function()
            minimizeBtn.BackgroundColor3 = Color3.fromRGB(65, 65, 65)
        end)
        
        minimizeBtn.MouseLeave:Connect(function()
            minimizeBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
        end)
        
        minimizeBtn.MouseButton1Click:Connect(function()
            UIControls.minimizeUI()
        end)
        
        print("✅ Custom minimize button added successfully!")
    end)
end

-- Create UI section
function UIControls.createUI(Window)
    local TabUI = Window:NewTab("UI Controls")
    local SecUI = TabUI:NewSection("Interface Controls")

    SecUI:NewKeybind("Minimize/Restore (RightShift)", "Toggle UI cepat", Enum.KeyCode.RightShift, function()
        UIControls.toggleUI()
    end)

    SecUI:NewButton("Force Show UI", "Paksa tampilkan UI jika tersembunyi", function()
        UIControls.restoreUI()
    end)
    
    SecUI:NewButton("Reset UI Position", "Reset posisi UI ke default", function()
        if MiniBtn then
            MiniBtn.Position = UDim2.new(0, 20, 0, 80)
            print("🔄 UI position reset")
        end
    end)
end

-- Status update loop
function UIControls.startStatusUpdateLoop(getAutoStates)
    task.spawn(function()
        while true do
            if MiniBtn and MiniBtn.Visible then
                local autoStates = getAutoStates()
                UIControls.updateStatus(autoStates)
            end
            task.wait(1)
        end
    end)
end

-- Cleanup function
function UIControls.cleanup()
    if MiniGui then
        MiniGui:Destroy()
        MiniGui = nil
        MiniBtn = nil
    end
end

-- Check if minimized
function UIControls.isMinimized()
    return isMinimized
end

return UIControls
