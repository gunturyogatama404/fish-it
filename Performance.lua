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
    
    -- Fishing stats section
    local fishingFrame = Instance.new("Frame")
    fishingFrame.Size = UDim2.new(0, 280, 0, 150)
    fishingFrame.Position = UDim2.new(0, 50, 0, 250)
    fishingFrame.BackgroundColor3 = Color3.new(0.15, 0.15, 0.15)
    fishingFrame.BorderSizePixel = 0
    fishingFrame.Parent = frame
    
    local fishingCorner = Instance.new("UICorner")
    fishingCorner.CornerRadius = UDim.new(0, 8)
    fishingCorner.Parent = fishingFrame
    
    local fishingTitle = Instance.new("TextLabel")
    fishingTitle.Size = UDim2.new(1, -20, 0, 25)
    fishingTitle.Position = UDim2.new(0, 10, 0, 5)
    fishingTitle.BackgroundTransparency = 1
    fishingTitle.Text = "🎣 Fishing Stats"
    fishingTitle.TextColor3 = Color3.new(1, 1, 1)
    fishingTitle.TextSize = 16
    fishingTitle.Font = Enum.Font.SourceSansBold
    fishingTitle.TextXAlignment = Enum.TextXAlignment.Left
    fishingTitle.Parent = fishingFrame
    
    local fishingContent = Instance.new("TextLabel")
    fishingContent.Name = "FishingContent"
    fishingContent.Size = UDim2.new(1, -20, 1, -30)
    fishingContent.Position = UDim2.new(0, 10, 0, 25)
    fishingContent.BackgroundTransparency = 1
    fishingContent.Text = "Total Fish: 0\nAvg/Hour: 0\nRare Catches: 0"
    fishingContent.TextColor3 = Color3.new(0.9, 0.9, 0.9)
    fishingContent.TextSize = 14
    fishingContent.Font = Enum.Font.SourceSans
    fishingContent.TextXAlignment = Enum.TextXAlignment.Left
    fishingContent.TextYAlignment = Enum.TextYAlignment.Top
    fishingContent.Parent = fishingFrame
    
    -- Auto features section
    local autoFrame = Instance.new("Frame")
    autoFrame.Size = UDim2.new(0, 280, 0, 150)
    autoFrame.Position = UDim2.new(0, 350, 0, 250)
    autoFrame.BackgroundColor3 = Color3.new(0.15, 0.15, 0.15)
    autoFrame.BorderSizePixel = 0
    autoFrame.Parent = frame
    
    local autoCorner = Instance.new("UICorner")
    autoCorner.CornerRadius = UDim.new(0, 8)
    autoCorner.Parent = autoFrame
    
    local autoTitle = Instance.new("TextLabel")
    autoTitle.Size = UDim2.new(1, -20, 0, 25)
    autoTitle.Position = UDim2.new(0, 10, 0, 5)
    autoTitle.BackgroundTransparency = 1
    autoTitle.Text = "🤖 Auto Features"
    autoTitle.TextColor3 = Color3.new(1, 1, 1)
    autoTitle.TextSize = 16
    autoTitle.Font = Enum.Font.SourceSansBold
    autoTitle.TextXAlignment = Enum.TextXAlignment.Left
    autoTitle.Parent = autoFrame
    
    local autoContent = Instance.new("TextLabel")
    autoContent.Name = "AutoContent"
    autoContent.Size = UDim2.new(1, -20, 1, -30)
    autoContent.Position = UDim2.new(0, 10, 0, 25)
    autoContent.BackgroundTransparency = 1
    autoContent.Text = "Farm: ❌\nSell: ❌\nCatch: ❌"
    autoContent.TextColor3 = Color3.new(0.9, 0.9, 0.9)
    autoContent.TextSize = 14
    autoContent.Font = Enum.Font.SourceSans
    autoContent.TextXAlignment = Enum.TextXAlignment.Left
    autoContent.TextYAlignment = Enum.TextYAlignment.Top
    autoContent.Parent = autoFrame
    
    -- Fish types section
    local typesFrame = Instance.new("Frame")
    typesFrame.Size = UDim2.new(0, 280, 0, 150)
    typesFrame.Position = UDim2.new(0, 50, 0, 410)
    typesFrame.BackgroundColor3 = Color3.new(0.15, 0.15, 0.15)
    typesFrame.BorderSizePixel = 0
    typesFrame.Parent = frame
    
    local typesCorner = Instance.new("UICorner")
    typesCorner.CornerRadius = UDim.new(0, 8)
    typesCorner.Parent = typesFrame
    
    local typesTitle = Instance.new("TextLabel")
    typesTitle.Size = UDim2.new(1, -20, 0, 25)
    typesTitle.Position = UDim2.new(0, 10, 0, 5)
    typesTitle.BackgroundTransparency = 1
    typesTitle.Text = "🐟 Fish Types"
    typesTitle.TextColor3 = Color3.new(1, 1, 1)
    typesTitle.TextSize = 16
    typesTitle.Font = Enum.Font.SourceSansBold
    typesTitle.TextXAlignment = Enum.TextXAlignment.Left
    typesTitle.Parent = typesFrame
    
    local typesContent = Instance.new("TextLabel")
    typesContent.Name = "TypesContent"
    typesContent.Size = UDim2.new(1, -20, 1, -30)
    typesContent.Position = UDim2.new(0, 10, 0, 25)
    typesContent.BackgroundTransparency = 1
    typesContent.Text = "Common: 0\nRare: 0\nEpic: 0\nLegendary: 0"
    typesContent.TextColor3 = Color3.new(0.9, 0.9, 0.9)
    typesContent.TextSize = 14
    typesContent.Font = Enum.Font.SourceSans
    typesContent.TextXAlignment = Enum.TextXAlignment.Left
    typesContent.TextYAlignment = Enum.TextYAlignment.Top
    typesContent.Parent = typesFrame
    
    -- Best catches section
    local bestFrame = Instance.new("Frame")
    bestFrame.Size = UDim2.new(0, 280, 0, 150)
    bestFrame.Position = UDim2.new(0, 350, 0, 410)
    bestFrame.BackgroundColor3 = Color3.new(0.15, 0.15, 0.15)
    bestFrame.BorderSizePixel = 0
    bestFrame.Parent = frame
    
    local bestCorner = Instance.new("UICorner")
    bestCorner.CornerRadius = UDim.new(0, 8)
    bestCorner.Parent = bestFrame
    
    local bestTitle = Instance.new("TextLabel")
    bestTitle.Size = UDim2.new(1, -20, 0, 25)
    bestTitle.Position = UDim2.new(0, 10, 0, 5)
    bestTitle.BackgroundTransparency = 1
    bestTitle.Text = "🏆 Best Catches"
    bestTitle.TextColor3 = Color3.new(1, 1, 1)
    bestTitle.TextSize = 16
    bestTitle.Font = Enum.Font.SourceSansBold
    bestTitle.TextXAlignment = Enum.TextXAlignment.Left
    bestTitle.Parent = bestFrame
    
    local bestContent = Instance.new("TextLabel")
    bestContent.Name = "BestContent"
    bestContent.Size = UDim2.new(1, -20, 1, -30)
    bestContent.Position = UDim2.new(0, 10, 0, 25)
    bestContent.BackgroundTransparency = 1
    bestContent.Text = "1: None (0)\n2: None (0)\n3: None (0)"
    bestContent.TextColor3 = Color3.new(0.9, 0.9, 0.9)
    bestContent.TextSize = 14
    bestContent.Font = Enum.Font.SourceSans
    bestContent.TextXAlignment = Enum.TextXAlignment.Left
    bestContent.TextYAlignment = Enum.TextYAlignment.Top
    bestContent.Parent = bestFrame
    
    -- Earnings section
    local earningsFrame = Instance.new("Frame")
    earningsFrame.Size = UDim2.new(0, 580, 0, 100)
    earningsFrame.Position = UDim2.new(0.5, -290, 0, 570)
    earningsFrame.BackgroundColor3 = Color3.new(0.15, 0.15, 0.15)
    earningsFrame.BorderSizePixel = 0
    earningsFrame.Parent = frame
    
    local earningsCorner = Instance.new("UICorner")
    earningsCorner.CornerRadius = UDim.new(0, 8)
    earningsCorner.Parent = earningsFrame
    
    local earningsTitle = Instance.new("TextLabel")
    earningsTitle.Size = UDim2.new(1, -20, 0, 25)
    earningsTitle.Position = UDim2.new(0, 10, 0, 5)
    earningsTitle.BackgroundTransparency = 1
    earningsTitle.Text = "💰 Earnings"
    earningsTitle.TextColor3 = Color3.new(1, 1, 1)
    earningsTitle.TextSize = 16
    earningsTitle.Font = Enum.Font.SourceSansBold
    earningsTitle.TextXAlignment = Enum.TextXAlignment.Left
    earningsTitle.Parent = earningsFrame
    
    local earningsContent = Instance.new("TextLabel")
    earningsContent.Name = "EarningsContent"
    earningsContent.Size = UDim2.new(1, -20, 1, -30)
    earningsContent.Position = UDim2.new(0, 10, 0, 25)
    earningsContent.BackgroundTransparency = 1
    earningsContent.Text = "Total Value: 0\nHourly Rate: 0"
    earningsContent.TextColor3 = Color3.new(0.9, 0.9, 0.9)
    earningsContent.TextSize = 14
    earningsContent.Font = Enum.Font.SourceSans
    earningsContent.TextXAlignment = Enum.TextXAlignment.Left
    earningsContent.TextYAlignment = Enum.TextYAlignment.Top
    earningsContent.Parent = earningsFrame
    
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
                    local hoursElapsed = currentUptime / 3600
                    
                    -- Update session
                    sessionContent.Text = "Uptime: " .. FormatTime(currentUptime) .. "\nStatus: 🟢 Online"
                    
                    -- Update fishing stats
                    local avgPerHour = hoursElapsed > 0 and math.floor(sessionStats.totalFish / hoursElapsed) or 0
                    local rareCount = sessionStats.fishTypes.rare or 0 + sessionStats.fishTypes.epic or 0 + sessionStats.fishTypes.legendary or 0
                    fishingContent.Text = "Total Fish: " .. FormatNumber(sessionStats.totalFish) .. 
                                          "\nAvg/Hour: " .. FormatNumber(avgPerHour) ..
                                          "\nRare Catches: " .. FormatNumber(rareCount)
                    
                    -- Update auto features (assuming these states are accessible; adjust if needed from main module)
                    autoContent.Text = "Farm: " .. (sessionStats.isAutoFarmOn and "✅" or "❌") ..
                                       "\nSell: " .. (sessionStats.isAutoSellOn and "✅" or "❌") ..
                                       "\nCatch: " .. (sessionStats.isAutoCatchOn and "✅" or "❌")
                    
                    -- Update fish types
                    typesContent.Text = "Common: " .. FormatNumber(sessionStats.fishTypes.common or 0) ..
                                        "\nRare: " .. FormatNumber(sessionStats.fishTypes.rare or 0) ..
                                        "\nEpic: " .. FormatNumber(sessionStats.fishTypes.epic or 0) ..
                                        "\nLegendary: " .. FormatNumber(sessionStats.fishTypes.legendary or 0)
                    
                    -- Update best catches (assuming bestFish is a table of top 3)
                    local bestText = ""
                    for i = 1, 3 do
                        local fish = sessionStats.bestFish[i] or {name = "None", value = 0}
                        bestText = bestText .. i .. ": " .. fish.name .. " (" .. FormatNumber(fish.value) .. ")\n"
                    end
                    bestContent.Text = bestText:sub(1, -2)  -- Remove trailing newline
                    
                    -- Update earnings
                    local hourlyRate = hoursElapsed > 0 and math.floor(sessionStats.totalValue / hoursElapsed) or 0
                    earningsContent.Text = "Total Value: " .. FormatNumber(sessionStats.totalValue) ..
                                           "\nHourly Rate: " .. FormatNumber(hourlyRate)
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
