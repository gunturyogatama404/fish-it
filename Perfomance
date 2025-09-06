-- Performance.lua - GPU Saver and performance optimization
local Performance = {}

-- Services
local Lighting = game:GetService("Lighting")
local StarterGui = game:GetService("StarterGui")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- State variables
Performance.gpuSaverEnabled = false
local originalSettings = {}
local whiteScreenGui = nil
local connections = {}

-- Session stats (passed from main)
local sessionStats = nil
local startTime = nil

-- Utility functions
local function FormatTime(seconds)
    local hours = math.floor(seconds / 3600)
    local minutes = math.floor((seconds % 3600) / 60)
    local secs = seconds % 60
    return string.format("%02d:%02d:%02d", hours, minutes, secs)
end

local function FormatNumber(num)
    local formatted = tostring(num)
    local k
    while true do  
        formatted, k = string.gsub(formatted, "^(-?%d+)(%d%d%d)", '%1,%2')
        if k == 0 then break end
    end
    return formatted
end

-- Create integrated fishing stats display
local function createWhiteScreen()
    if whiteScreenGui then return end
    
    whiteScreenGui = Instance.new("ScreenGui")
    whiteScreenGui.Name = "GPUSaverScreen"
    whiteScreenGui.ResetOnSpawn = false
    whiteScreenGui.IgnoreGuiInset = true
    whiteScreenGui.DisplayOrder = 999999
    
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 1, 0)
    frame.Position = UDim2.new(0, 0, 0, 0)
    frame.BackgroundColor3 = Color3.new(0.1, 0.1, 0.1)
    frame.BorderSizePixel = 0
    frame.Parent = whiteScreenGui
    
    -- Main title
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(0, 600, 0, 60)
    titleLabel.Position = UDim2.new(0.5, -300, 0, 20)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = "🟢 " .. LocalPlayer.Name .. " - Live Fishing Status"
    titleLabel.TextColor3 = Color3.new(0, 1, 0)
    titleLabel.TextScaled = false
    titleLabel.TextSize = 28
    titleLabel.Font = Enum.Font.SourceSansBold
    titleLabel.Parent = frame
    
    -- Subtitle
    local subtitleLabel = Instance.new("TextLabel")
    subtitleLabel.Size = UDim2.new(0, 500, 0, 30)
    subtitleLabel.Position = UDim2.new(0.5, -250, 0, 80)
    subtitleLabel.BackgroundTransparency = 1
    subtitleLabel.Text = "Real-time fishing session monitoring"
    subtitleLabel.TextColor3 = Color3.new(0.7, 0.7, 0.7)
    subtitleLabel.TextSize = 18
    subtitleLabel.Font = Enum.Font.SourceSans
    subtitleLabel.Parent = frame
    
    -- Player info section
    local playerInfoFrame = Instance.new("Frame")
    playerInfoFrame.Size = UDim2.new(0, 280, 0, 100)
    playerInfoFrame.Position = UDim2.new(0, 50, 0, 130)
    playerInfoFrame.BackgroundColor3 = Color3.new(0.15, 0.15, 0.15)
    playerInfoFrame.BorderSizePixel = 0
    playerInfoFrame.Parent = frame
    
    local playerInfoCorner = Instance.new("UICorner")
    playerInfoCorner.CornerRadius = UDim.new(0, 8)
    playerInfoCorner.Parent = playerInfoFrame
    
    local playerInfoTitle = Instance.new("TextLabel")
    playerInfoTitle.Size = UDim2.new(1, -20, 0, 25)
    playerInfoTitle.Position = UDim2.new(0, 10, 0, 5)
    playerInfoTitle.BackgroundTransparency = 1
    playerInfoTitle.Text = "👤 Player Info"
    playerInfoTitle.TextColor3 = Color3.new(1, 1, 1)
    playerInfoTitle.TextSize = 16
    playerInfoTitle.Font = Enum.Font.SourceSansBold
    playerInfoTitle.TextXAlignment = Enum.TextXAlignment.Left
    playerInfoTitle.Parent = playerInfoFrame
    
    local playerInfoContent = Instance.new("TextLabel")
    playerInfoContent.Size = UDim2.new(1, -20, 1, -30)
    playerInfoContent.Position = UDim2.new(0, 10, 0, 25)
    playerInfoContent.BackgroundTransparency = 1
    playerInfoContent.Text = "Name: " .. LocalPlayer.Name
    playerInfoContent.TextColor3 = Color3.new(0.9, 0.9, 0.9)
    playerInfoContent.TextSize = 14
    playerInfoContent.Font = Enum.Font.SourceSans
    playerInfoContent.TextXAlignment = Enum.TextXAlignment.Left
    playerInfoContent.TextYAlignment = Enum.TextYAlignment.Top
    playerInfoContent.Parent = playerInfoFrame
    
    -- Session time section
    local sessionFrame = Instance.new("Frame")
    sessionFrame.Size = UDim2.new(0, 280, 0, 100)
    sessionFrame.Position = UDim2.new(0, 350, 0, 130)
    sessionFrame.BackgroundColor3 = Color3.new(0.15, 0.15, 0.15)
    sessionFrame.BorderSizePixel = 0
    sessionFrame.Parent = frame
    
    local sessionCorner = Instance.new("UICorner")
    sessionCorner.CornerRadius = UDim.new(0, 8)
    sessionCorner.Parent = sessionFrame
    
    local sessionTitle = Instance.new("TextLabel")
    sessionTitle.Size = UDim2.new(1, -20, 0, 25)
    sessionTitle.Position = UDim2.new(0, 10, 0, 5)
    sessionTitle.BackgroundTransparency = 1
    sessionTitle.Text = "⏱️ Session Time"
    sessionTitle.TextColor3 = Color3.new(1, 1, 1)
    sessionTitle.TextSize = 16
    sessionTitle.Font = Enum.Font.SourceSansBold
    sessionTitle.TextXAlignment = Enum.TextXAlignment.Left
    sessionTitle.Parent = sessionFrame
    
    local sessionContent = Instance.new("TextLabel")
    sessionContent.Name = "SessionContent"
    sessionContent.Size = UDim2.new(1, -20, 1, -30)
    sessionContent.Position = UDim2.new(0, 10, 0, 25)
    sessionContent.BackgroundTransparency = 1
    sessionContent.Text = "Uptime: 00:00:00\nStatus: 🟢 Online"
    sessionContent.TextColor3 = Color3.new(0.9, 0.9, 0.9)
    sessionContent.TextSize = 14
    sessionContent.Font = Enum.Font.SourceSans
    sessionContent.TextXAlignment = Enum.TextXAlignment.Left
    sessionContent.TextYAlignment = Enum.TextYAlignment.Top
    sessionContent.Parent = sessionFrame
    
    -- Continue with other sections...
    -- (Adding more sections for brevity, but full implementation would include all stats sections)
    
    -- FPS Counter
    local fpsLabel = Instance.new("TextLabel")
    fpsLabel.Size = UDim2.new(0, 200, 0, 50)
    fpsLabel.Position = UDim2.new(1, -220, 0, 20)
    fpsLabel.BackgroundTransparency = 1
    fpsLabel.Text = "FPS: Calculating..."
    fpsLabel.TextColor3 = Color3.new(0, 1, 0)
    fpsLabel.TextSize = 18
    fpsLabel.Font = Enum.Font.SourceSansBold
    fpsLabel.TextXAlignment = Enum.TextXAlignment.Right
    fpsLabel.Parent = frame
    
    -- Update system
    task.spawn(function()
        local lastUpdate = tick()
        local frameCount = 0
        
        connections.fpsConnection = RunService.RenderStepped:Connect(function()
            frameCount = frameCount + 1
            local currentTime = tick()
            
            if currentTime - lastUpdate >= 1 then
                local fps = frameCount / (currentTime - lastUpdate)
                fpsLabel.Text = string.format("FPS: %.0f", fps)
                
                if sessionStats and startTime then
                    local currentUptime = os.time() - startTime
                    sessionContent.Text = "Uptime: " .. FormatTime(currentUptime) .. "\nStatus: 🟢 Online"
                end
                
                frameCount = 0
                lastUpdate = currentTime
            end
        end)
    end)
    
    whiteScreenGui.Parent = game:GetService("CoreGui")
end

local function removeWhiteScreen()
    if whiteScreenGui then
        whiteScreenGui:Destroy()
        whiteScreenGui = nil
    end
    
    if connections.fpsConnection then
        connections.fpsConnection:Disconnect()
        connections.fpsConnection = nil
    end
end

-- GPU Saver functions
function Performance.enableGPUSaver()
    if Performance.gpuSaverEnabled then return end
    Performance.gpuSaverEnabled = true
    
    -- Store original settings
    originalSettings.GlobalShadows = Lighting.GlobalShadows
    originalSettings.FogEnd = Lighting.FogEnd
    originalSettings.Brightness = Lighting.Brightness
    originalSettings.QualityLevel = settings().Rendering.QualityLevel
    
    -- Apply GPU saving settings
    pcall(function()
        settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
        Lighting.GlobalShadows = false
        Lighting.FogEnd = 1
        Lighting.Brightness = 0
        
        for _, v in pairs(Lighting:GetChildren()) do
            if v:IsA("PostEffect") or v:IsA("Atmosphere") or v:IsA("Sky") then
                v.Enabled = false
            end
        end
        
        setfpscap(6)
        StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.All, false)
        workspace.CurrentCamera.FieldOfView = 1
    end)
    
    createWhiteScreen()
    print("⚡ GPU Saver Mode: ENABLED")
end

function Performance.disableGPUSaver()
    if not Performance.gpuSaverEnabled then return end
    Performance.gpuSaverEnabled = false
    
    -- Restore settings
    pcall(function()
        if originalSettings.QualityLevel then
            settings().Rendering.QualityLevel = originalSettings.QualityLevel
        end
        
        Lighting.GlobalShadows = originalSettings.GlobalShadows or true
        Lighting.FogEnd = originalSettings.FogEnd or 100000
        Lighting.Brightness = originalSettings.Brightness or 1
        
        for _, v in pairs(Lighting:GetChildren()) do
            if v:IsA("PostEffect") or v:IsA("Atmosphere") or v:IsA("Sky") then
                v.Enabled = true
            end
        end
        
        setfpscap(0)
        StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.All, true)
        workspace.CurrentCamera.FieldOfView = 70
    end)
    
    removeWhiteScreen()
    print("⚡ GPU Saver Mode: DISABLED")
end

-- Initialize session stats
function Performance.setSessionStats(stats, time)
    sessionStats = stats
    startTime = time
end

-- Create UI section
function Performance.createUI(Window)
    local TabPerformance = Window:NewTab("Performance")
    local SecGPU = TabPerformance:NewSection("GPU Saver Mode")

    SecGPU:NewToggle("GPU Saver Mode", "Enable white screen to save GPU/battery", function(state)
        if state then
            Performance.enableGPUSaver()
        else
            Performance.disableGPUSaver()
        end
    end)

    SecGPU:NewKeybind("GPU Saver Hotkey", "Quick toggle GPU saver", Enum.KeyCode.RightControl, function()
        if Performance.gpuSaverEnabled then
            Performance.disableGPUSaver()
        else
            Performance.enableGPUSaver()
        end
    end)

    SecGPU:NewButton("Force Remove White Screen", "Emergency remove if stuck", function()
        removeWhiteScreen()
        Performance.gpuSaverEnabled = false
    end)
end

return Performance
