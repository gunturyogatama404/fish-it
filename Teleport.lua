-- Auto Farm GUI - versi UI rapi (Kavo) + MINIMIZE + Custom Delay + Auto Bait Upgrade + GPU Saver Mode + Integrated Fishing Stats Display
-- Version 4.5 with Integrated Fishing Status Display (No Config Save/Load)

-- ====== Bagian asli dengan improved WaitForChild ======
local player = game.Players.LocalPlayer
local replicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local StarterGui = game:GetService("StarterGui")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local leaderstats = player:WaitForChild("leaderstats")
local BestCaught = leaderstats:WaitForChild("Rarest Fish")
local AllTimeCaught = leaderstats:WaitForChild("Caught")

-- ====== FISHING STATS TRACKING VARIABLES ======
local startTime = os.time()
local sessionStats = {
    totalFish = 0,
    totalValue = 0,
    bestFish = {name = "None", value = 0},
    fishTypes = {}
}

-- Database ikan lengkap
local fishDatabase = {
    [163] = {name = "Viperfish", sellPrice = 94},
    [153] = {name = "Dark Eel", sellPrice = 96},
    [161] = {name = "Spotted Lantern Fish", sellPrice = 88},
    [157] = {name = "JellyFish", sellPrice = 402},
    [162] = {name = "Vampire Squid", sellPrice = 3770},
    [160] = {name = "Monk Fish", sellPrice = 3200},
    [149] = {name = "Angler Fish", sellPrice = 3620},
    [152] = {name = "Deep Sea Crab", sellPrice = 4680},
    [150] = {name = "Blob FIsh", sellPrice = 26200},
    [156] = {name = "Giant Squid", sellPrice = 162300},
    [152] = {name = "Deep Sea Crab", sellPrice = 4680},
    [159] = {name = "Robot Kraken", sellPrice = 327500},

    [190] = {name = "Salmon ", sellPrice = 103},
    [202] = {name = "Flat Fish", sellPrice = 58},
    [203] = {name = "Flying fish", sellPrice = 55},
    [211] = {name = "wahoo", sellPrice = 105},
    [30] = {name = "tricolore butterfly", sellPrice = 112},
    [204] = {name = "lion fish", sellPrice = 143},
    [23] = {name = "maze angelfish", sellPrice = 153},
    [28] = {name = "white clownfish", sellPrice = 347},
    [29] = {name = "scissortail dartfish", sellPrice = 369},
    [209] = {name = "starfish", sellPrice = 385},
    [27] = {name = "panther grouper", sellPrice = 1044},
    [26] = {name = "domino damsel", sellPrice = 1444},
    [10] = {name = "enchant stone", sellPrice = 1000},
    [24] = {name = "starjam tang", sellPrice = 4200},
    [207] = {name = "pink dolphin", sellPrice = 3910},
    [25] = {name = "greenbee grouper", sellPrice = 5732},
    [208] = {name = "saw fish", sellPrice = 11250},
    [22] = {name = "blue lobster", sellPrice = 11355},
    [21] = {name = "hawks turtle", sellPrice = 40500},
    [205] = {name = "luminous fish", sellPrice = 31150},

    [50] = {name = "magma goby", sellPrice = 135},
    [87] = {name = "lava butterfly", sellPrice = 153},
    [88] = {name = "rockform cardianl", sellPrice = 347},
    [89] = {name = "volsail tang", sellPrice = 369},
    [49] = {name = "firecoal damsel", sellPrice = 1044},
    [48] = {name = "lavafin tuna", sellPrice = 4500},
    [47] = {name = "blueflame ray", sellPrice = 45000},

    [189] = {name = "rockfish", sellPrice = 92},
    [19] = {name = "coal tang", sellPrice = 74},
    [210] = {name = "dark tentacle", sellPrice = 392},
    [18] = {name = "charmed tang", sellPrice = 393},
    [17] = {name = "astra damsel", sellPrice = 1633},
    [14] = {name = "enchanted anglefish", sellPrice = 4200},
    [218] = {name = "thin armor shark", sellPrice = 91000},
    [225] = {name = "scare", sellPrice = 280000},

    [140] = {name = "pilot fish", sellPrice = 58},
    [188] = {name = "red snaper", sellPrice = 97},
    [186] = {name = "parrot fish", sellPrice = 93},
    [182] = {name = "blackcap", sellPrice = 95},
    [139] = {name = "silver tuna", sellPrice = 62},
    [183] = {name = "catfish", sellPrice = 422},
    [191] = {name = "sheepshead", sellPrice = 412},
    [184] = {name = "coney", sellPrice = 287},
    [138] = {name = "axolotl", sellPrice = 3971},
    [136] = {name = "frostborn shark", sellPrice = 100000},
    [137] = {name = "plasma shark", sellPrice = 94500}

}
-- State variables
local isAutoFarmOn = false
local isAutoSellOn = false
local isAutoCatchOn = false
local isUpgradeOn = false
local isUpgradeBaitOn = false
local isAutoWeatherOn = false
local gpuSaverEnabled = false
local isAutoMegalodonOn = false
local megalodonSavedPosition = nil
local hasTeleportedToMegalodon = false
local currentBodyPosition = nil

-- ====== FUNGSI UNTUK MENDAPATKAN COIN DAN LEVEL ======
local function getCurrentCoins()
    local success, result = pcall(function()
        local playerGui = LocalPlayer:FindFirstChild("PlayerGui")
        if not playerGui then return "0" end
        
        local events = playerGui:FindFirstChild("Events")
        if not events then return "0" end
        
        local frame = events:FindFirstChild("Frame")
        if not frame then return "0" end
        
        local currencyCounter = frame:FindFirstChild("CurrencyCounter")
        if not currencyCounter then return "0" end
        
        local counter = currencyCounter:FindFirstChild("Counter")
        if not counter then return "0" end
        
        return counter.Text or "0"
    end)
    
    return success and result or "0"
end

local function getCurrentLevel()
    local success, result = pcall(function()
        local playerGui = LocalPlayer:FindFirstChild("PlayerGui")
        if not playerGui then return "Lvl 0" end
        
        local xp = playerGui:FindFirstChild("XP")
        if not xp then return "Lvl 0" end
        
        local frame = xp:FindFirstChild("Frame")
        if not frame then return "Lvl 0" end
        
        local levelCount = frame:FindFirstChild("LevelCount")
        if not levelCount then return "Lvl 0" end
        
        return levelCount.Text or "Lvl 0"
    end)
    
    return success and result or "Lvl 0"
end

-- ====== FISHING STATS FUNCTIONS ======
-- Format waktu
local function FormatTime(seconds)
    local hours = math.floor(seconds / 3600)
    local minutes = math.floor((seconds % 3600) / 60)
    local secs = seconds % 60
    return string.format("%02d:%02d:%02d", hours, minutes, secs)
end

-- Format angka dengan koma
local function FormatNumber(num)
    -- Ensure we have a valid number
    local number = tonumber(num) or 0
    local formatted = tostring(math.floor(number))
    local k
    while true do  
        formatted, k = string.gsub(formatted, "^(-?%d+)(%d%d%d)", '%1,%2')
        if k == 0 then break end
    end
    return formatted
end

-- ====== GPU SAVER VARIABLES ======
local originalSettings = {}
local whiteScreenGui = nil
local connections = {}

-- ====== DELAY VARIABLES ======
local chargeFishingDelay = 0.01
local autoFishMainDelay = 0.9
local autoSellDelay = 5
local autoCatchDelay = 0.2
local weatherIdDelay = 3
local weatherCycleDelay = 100

-- ====== AUTO ENCHANT VARIABLES ======
local isAutoEnchantOn = false
local targetEnchantID = 12 -- Default target enchant ID
local enchantFound = false
local enchantAttempts = 0
local HOTBAR_SLOT = 2 -- Slot hotbar untuk equip tool

-- Improved WaitForChild chain with error handling
local EquipItemEvent = replicatedStorage.Packages._Index["sleitnick_net@0.2.0"].net:WaitForChild("RE/EquipItem")
local ActivateEnchantEvent = replicatedStorage.Packages._Index["sleitnick_net@0.2.0"].net:WaitForChild("RE/ActivateEnchantingAltar")
local RollEnchantRemote = replicatedStorage.Packages._Index["sleitnick_net@0.2.0"].net:WaitForChild("RE/RollEnchant")

local function getNetworkEvents()
    local success, result = pcall(function()
        local packages = replicatedStorage:WaitForChild("Packages", 10)
        local net = packages:WaitForChild("_Index", 10):WaitForChild("sleitnick_net@0.2.0", 10):WaitForChild("net", 10)
        
        return {
            fishingEvent = net:WaitForChild("RE/FishingCompleted", 10),
            sellEvent = net:WaitForChild("RF/SellAllItems", 10),
            chargeEvent = net:WaitForChild("RF/ChargeFishingRod", 10),
            requestMinigameEvent = net:WaitForChild("RF/RequestFishingMinigameStarted", 10),
            cancelFishingEvent = net:WaitForChild("RF/CancelFishingInputs", 10),
            equipEvent = net:WaitForChild("RE/EquipToolFromHotbar", 10),
            unequipEvent = net:WaitForChild("RE/UnequipToolFromHotbar", 10),
            purchaseRodEvent = net:WaitForChild("RF/PurchaseFishingRod", 10),
            purchaseBaitEvent = net:WaitForChild("RF/PurchaseBait", 10),
            WeatherEvent = net:WaitForChild("RF/PurchaseWeatherEvent", 10),
            fishCaughtEvent = replicatedStorage.Packages._Index["sleitnick_net@0.2.0"].net:WaitForChild("RE/FishCaught", 10)
        }
    end)
    
    if success then
        return result
    else
        warn("Failed to get network events: " .. tostring(result))
        return nil
    end
end

-- Get all network events with proper error handling
local networkEvents = getNetworkEvents()
if not networkEvents then
    error("Failed to initialize network events. Script cannot continue.")
    return
end

-- Extract events for easier access
local fishingEvent = networkEvents.fishingEvent
local sellEvent = networkEvents.sellEvent
local chargeEvent = networkEvents.chargeEvent
local requestMinigameEvent = networkEvents.requestMinigameEvent
local cancelFishingEvent = networkEvents.cancelFishingEvent
local equipEvent = networkEvents.equipEvent
local unequipEvent = networkEvents.unequipEvent
local purchaseRodEvent = networkEvents.purchaseRodEvent
local purchaseBaitEvent = networkEvents.purchaseBaitEvent
local WeatherEvent = networkEvents.WeatherEvent
local fishCaughtEvent = networkEvents.fishCaughtEvent

-- ====== SIMPLIFIED GPU SAVER WITH CENTER LAYOUT ======
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
    
    -- Main title with Total Caught and Best Caught
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Name = "TitleLabel"
    titleLabel.Size = UDim2.new(0, 600, 0, 100)
    titleLabel.Position = UDim2.new(0.5, -300, 0, 50)
    titleLabel.BackgroundTransparency = 1
    local totalCaught = (LocalPlayer.leaderstats and LocalPlayer.leaderstats.Caught and LocalPlayer.leaderstats.Caught.Value) or 0
    local bestCaught = (LocalPlayer.leaderstats and LocalPlayer.leaderstats["Rarest Fish"] and LocalPlayer.leaderstats["Rarest Fish"].Value) or "None"
    titleLabel.Text = "🟢 " .. LocalPlayer.Name .. "\nTotal Caught: " .. totalCaught .. "\nBest Caught: " .. bestCaught
    titleLabel.TextColor3 = Color3.new(0, 1, 0)
    titleLabel.TextScaled = false
    titleLabel.TextSize = 24
    titleLabel.Font = Enum.Font.SourceSansBold
    titleLabel.TextXAlignment = Enum.TextXAlignment.Center
    titleLabel.TextYAlignment = Enum.TextYAlignment.Center
    titleLabel.Parent = frame
    
    -- Subtitle
    local subtitleLabel = Instance.new("TextLabel")
    subtitleLabel.Size = UDim2.new(0, 500, 0, 30)
    subtitleLabel.Position = UDim2.new(0.5, -250, 0, 170)
    subtitleLabel.BackgroundTransparency = 1
    subtitleLabel.Text = "Real-time fishing session monitoring"
    subtitleLabel.TextColor3 = Color3.new(0.7, 0.7, 0.7)
    subtitleLabel.TextSize = 18
    subtitleLabel.Font = Enum.Font.SourceSans
    subtitleLabel.TextXAlignment = Enum.TextXAlignment.Center
    subtitleLabel.Parent = frame
    
    -- Session time (centered)
    local sessionLabel = Instance.new("TextLabel")
    sessionLabel.Name = "SessionLabel"
    sessionLabel.Size = UDim2.new(0, 400, 0, 40)
    sessionLabel.Position = UDim2.new(0.5, -200, 0, 220)
    sessionLabel.BackgroundTransparency = 1
    sessionLabel.Text = "⏱️ Uptime: 00:00:00"
    sessionLabel.TextColor3 = Color3.new(1, 1, 1)
    sessionLabel.TextSize = 20
    sessionLabel.Font = Enum.Font.SourceSansBold
    sessionLabel.TextXAlignment = Enum.TextXAlignment.Center
    sessionLabel.Parent = frame
    
    -- Fishing stats (centered)
    local fishStatsLabel = Instance.new("TextLabel")
    fishStatsLabel.Name = "FishStatsLabel"
    fishStatsLabel.Size = UDim2.new(0, 400, 0, 40)
    fishStatsLabel.Position = UDim2.new(0.5, -200, 0, 280)
    fishStatsLabel.BackgroundTransparency = 1
    fishStatsLabel.Text = "🎣 Fish Caught: " .. FormatNumber(sessionStats.totalFish)
    fishStatsLabel.TextColor3 = Color3.new(0.9, 0.9, 0.9)
    fishStatsLabel.TextSize = 18
    fishStatsLabel.Font = Enum.Font.SourceSans
    fishStatsLabel.TextXAlignment = Enum.TextXAlignment.Center
    fishStatsLabel.Parent = frame
    
-- Coin display (mengganti earnings)
    local coinLabel = Instance.new("TextLabel")
    coinLabel.Name = "CoinLabel"
    coinLabel.Size = UDim2.new(0, 400, 0, 40)
    coinLabel.Position = UDim2.new(0.5, -200, 0, 330)
    coinLabel.BackgroundTransparency = 1
    coinLabel.Text = "💰 Coins: " .. getCurrentCoins()
    coinLabel.TextColor3 = Color3.new(0.9, 0.9, 0.9)
    coinLabel.TextSize = 18
    coinLabel.Font = Enum.Font.SourceSans
    coinLabel.TextXAlignment = Enum.TextXAlignment.Center
    coinLabel.Parent = frame

    -- Level display (tambahan baru)
    local levelLabel = Instance.new("TextLabel")
    levelLabel.Name = "LevelLabel"
    levelLabel.Size = UDim2.new(0, 400, 0, 40)
    levelLabel.Position = UDim2.new(0.5, -200, 0, 380)
    levelLabel.BackgroundTransparency = 1
    levelLabel.Text = "⭐ " .. getCurrentLevel()
    levelLabel.TextColor3 = Color3.new(0.9, 0.9, 0.9)
    levelLabel.TextSize = 18
    levelLabel.Font = Enum.Font.SourceSans
    levelLabel.TextXAlignment = Enum.TextXAlignment.Center
    levelLabel.Parent = frame
    
    -- Auto features status (centered)
    local statusLabel = Instance.new("TextLabel")
    statusLabel.Name = "StatusLabel"
    statusLabel.Size = UDim2.new(0, 600, 0, 60)
    statusLabel.Position = UDim2.new(0.5, -300, 0, 430)
    statusLabel.BackgroundTransparency = 1
    statusLabel.Text = "🤖 Auto Farm: " .. (isAutoFarmOn and "🟢 ON" or "🔴 OFF") .. 
                      "  |  Auto Sell: " .. (isAutoSellOn and "🟢 ON" or "🔴 OFF") ..
                      "  |  Auto Catch: " .. (isAutoCatchOn and "🟢 ON" or "🔴 OFF")
    statusLabel.TextColor3 = Color3.new(0.9, 0.9, 0.9)
    statusLabel.TextSize = 16
    statusLabel.Font = Enum.Font.SourceSans
    statusLabel.TextXAlignment = Enum.TextXAlignment.Center
    statusLabel.TextYAlignment = Enum.TextYAlignment.Center
    statusLabel.Parent = frame
    
    -- Instructions (centered)
    local instructionsLabel = Instance.new("TextLabel")
    instructionsLabel.Size = UDim2.new(0, 600, 0, 60)
    instructionsLabel.Position = UDim2.new(0.5, -300, 1, -120)
    instructionsLabel.BackgroundTransparency = 1
    instructionsLabel.Text = "💡 Press RightControl to toggle GPU Saver Mode\n🎮 Use the GUI or hotkeys to control auto features"
    instructionsLabel.TextColor3 = Color3.new(0.6, 0.6, 0.6)
    instructionsLabel.TextSize = 16
    instructionsLabel.Font = Enum.Font.SourceSans
    instructionsLabel.TextXAlignment = Enum.TextXAlignment.Center
    instructionsLabel.TextYAlignment = Enum.TextYAlignment.Center
    instructionsLabel.Parent = frame
    
    -- FPS Counter (top right)
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
    
    -- Last update time (top right below FPS)
    local lastUpdateLabel = Instance.new("TextLabel")
    lastUpdateLabel.Size = UDim2.new(0, 200, 0, 30)
    lastUpdateLabel.Position = UDim2.new(1, -220, 0, 70)
    lastUpdateLabel.BackgroundTransparency = 1
    lastUpdateLabel.Text = "Last Update: " .. os.date("%H:%M:%S")
    lastUpdateLabel.TextColor3 = Color3.new(0.7, 0.7, 0.7)
    lastUpdateLabel.TextSize = 14
    lastUpdateLabel.Font = Enum.Font.SourceSans
    lastUpdateLabel.TextXAlignment = Enum.TextXAlignment.Right
    lastUpdateLabel.Parent = frame
    
-- ====== IMPROVED UPDATE SYSTEM ======
    task.spawn(function()
        local lastUpdate = tick()
        local frameCount = 0
        
        connections.fpsConnection = RunService.RenderStepped:Connect(function()
            frameCount = frameCount + 1
            local currentTime = tick()
            
            if currentTime - lastUpdate >= 1 then
                local fps = frameCount / (currentTime - lastUpdate)
                
                -- Safe FPS update
                pcall(function()
                    if fpsLabel and fpsLabel.Parent then
                        fpsLabel.Text = string.format("FPS: %.0f", math.floor(fps))
                    end
                end)
                
                -- Safe session time update
                pcall(function()
                    if sessionLabel and sessionLabel.Parent then
                        local currentUptime = math.max(0, os.time() - startTime)
                        sessionLabel.Text = "⏱️ Uptime: " .. FormatTime(currentUptime)
                    end
                end)
                
                -- Safe fishing stats update
                pcall(function()
                    if fishStatsLabel and fishStatsLabel.Parent then
                        local fishCount = math.max(0, sessionStats.totalFish)
                        fishStatsLabel.Text = "🎣 Fish Caught: " .. FormatNumber(fishCount)
                    end
                end)
                
                -- Safe earnings update
                pcall(function()
                    if coinLabel and coinLabel.Parent then
                        coinLabel.Text = "💰 Coins: " .. getCurrentCoins()
                    end
                end)

                -- Safe earnings update
                pcall(function()
                    if levelLabel and levelLabel.Parent then
                        levelLabel.Text = "⭐ " .. getCurrentLevel()
                    end
                end)
                
                -- Safe status update
                pcall(function()
                    if statusLabel and statusLabel.Parent then
                        statusLabel.Text = "🤖 Auto Farm: " .. (isAutoFarmOn and "🟢 ON" or "🔴 OFF") .. 
                                         "  |  Auto Sell: " .. (isAutoSellOn and "🟢 ON" or "🔴 OFF") ..
                                         "  |  Auto Catch: " .. (isAutoCatchOn and "🟢 ON" or "🔴 OFF") ..
                                         "\nUpgrade Rod: " .. (isUpgradeOn and "🟢 ON" or "🔴 OFF") ..
                                         "  |  Upgrade Bait: " .. (isUpgradeBaitOn and "🟢 ON" or "🔴 OFF") ..
                                         "  |  Auto Megalodon: " .. (isAutoMegalodonOn and "🟢 ON" or "🔴 OFF") ..
                                         "  |  Auto Weather: " .. (isAutoWeatherOn and "🟢 ON" or "🔴 OFF")
                    end
                end)
                
                -- Safe Total Caught & Best Caught update
                pcall(function()
                    if titleLabel and titleLabel.Parent then
                        local currentCaught = 0
                        local currentBest = "None"
                        
                        if LocalPlayer.leaderstats then
                            if LocalPlayer.leaderstats.Caught then
                                currentCaught = tonumber(LocalPlayer.leaderstats.Caught.Value) or 0
                            end
                            if LocalPlayer.leaderstats["Rarest Fish"] then
                                currentBest = tostring(LocalPlayer.leaderstats["Rarest Fish"].Value) or "None"
                            end
                        end
                        
                        titleLabel.Text = "🟢 " .. (LocalPlayer.Name or "Player") .. 
                                        "\nTotal Caught: " .. FormatNumber(currentCaught) .. 
                                        "\nBest Caught: " .. currentBest
                    end
                end)
                
                -- Safe last update time
                pcall(function()
                    if lastUpdateLabel and lastUpdateLabel.Parent then
                        lastUpdateLabel.Text = "Last Update: " .. os.date("%H:%M:%S")
                    end
                end)
                
                frameCount = 0
                lastUpdate = currentTime
            end
        end)
    end)
    
    -- Real-time listeners for Total Caught and Best Caught
    if LocalPlayer.leaderstats and LocalPlayer.leaderstats.Caught then
        connections.caughtConnection = LocalPlayer.leaderstats.Caught.Changed:Connect(function(newValue)
            if titleLabel then
                local currentBest = (LocalPlayer.leaderstats["Rarest Fish"] and LocalPlayer.leaderstats["Rarest Fish"].Value) or "None"
                titleLabel.Text = "🟢 " .. LocalPlayer.Name .. "\nTotal Caught: " .. newValue .. "\nBest Caught: " .. currentBest
            end
        end)
    end
    
    if LocalPlayer.leaderstats and LocalPlayer.leaderstats["Rarest Fish"] then
        connections.bestCaughtConnection = LocalPlayer.leaderstats["Rarest Fish"].Changed:Connect(function(newValue)
            if titleLabel then
                local currentCaught = (LocalPlayer.leaderstats.Caught and LocalPlayer.leaderstats.Caught.Value) or 0
                titleLabel.Text = "🟢 " .. LocalPlayer.Name .. "\nTotal Caught: " .. currentCaught .. "\nBest Caught: " .. newValue
            end
        end)
    end
    
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
    
    if connections.caughtConnection then
        connections.caughtConnection:Disconnect()
        connections.caughtConnection = nil
    end
    
    if connections.bestCaughtConnection then
        connections.bestCaughtConnection:Disconnect()
        connections.bestCaughtConnection = nil
    end
end

function enableGPUSaver()
    if gpuSaverEnabled then return end
    gpuSaverEnabled = true
    
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

function disableGPUSaver()
    if not gpuSaverEnabled then return end
    gpuSaverEnabled = false
    
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

-- ====== FISH CAUGHT EVENT HANDLER ======
local function setupFishTracking()
    print("Fish tracking active - monitoring catch count only")
    
    task.spawn(function()
        task.wait(2)
        if LocalPlayer.leaderstats and LocalPlayer.leaderstats.Caught then
            local lastCaught = LocalPlayer.leaderstats.Caught.Value
            
            LocalPlayer.leaderstats.Caught.Changed:Connect(function(newValue)
                local increase = newValue - lastCaught
                if increase > 0 then
                    sessionStats.totalFish = sessionStats.totalFish + increase
                end
                lastCaught = newValue
            end)
        end
    end)
end

-- Call this function
setupFishTracking()

local teleportLocations = {
    { Name = "Kohana Volcano", CFrame = CFrame.new(-572.879456, 22.4521465, 148.355331, -0.995764792, -6.67705606e-08, 0.0919371247, -5.74611505e-08, 1, 1.03905414e-07, -0.0919371247, 9.81825394e-08, -0.995764792) },
    { Name = "Sisyphus Statue",  CFrame = CFrame.new(-3728.21606, -135.074417, -1012.12744, -0.977224171, 7.74980258e-09, -0.212209702, 1.566994e-08, 1, -3.5640408e-08, 0.212209702, -3.81539813e-08, -0.977224171) },
    { Name = "Coral Reefs",  CFrame = CFrame.new(-3114.78198, 1.32066584, 2237.52295, -0.304758579, 1.6556676e-08, -0.952429652, -8.50574935e-08, 1, 4.46003305e-08, 0.952429652, 9.46036067e-08, -0.304758579) },
    { Name = "Esoteric Depths",  CFrame = CFrame.new(3248.37109, -1301.53027, 1403.82727, -0.920208454, 7.76270355e-08, 0.391428679, 4.56261056e-08, 1, -9.10549289e-08, -0.391428679, -6.5930152e-08, -0.920208454) },
    { Name = "Enchant Island",  CFrame = CFrame.new(3232.24927, -1302.85486, 1401.76367, 0.383588433, -6.71329943e-08, -0.923504174, 9.6923408e-08, 1, -3.2435473e-08, 0.923504174, -7.70672983e-08, 0.383588433) },
    { Name = "Crater Island",  CFrame = CFrame.new(1016.49072, 20.0919304, 5069.27295, 0.838976264, 3.30379857e-09, -0.544168055, 2.63538391e-09, 1, 1.01344115e-08, 0.544168055, -9.93662219e-09, 0.838976264) },
    { Name = "Spawn",  CFrame = CFrame.new(45.2788086, 252.562927, 2987.10913, 1, 0, 0, 0, 1, 0, 0, 0, 1) },
    { Name = "Lost Isle",  CFrame = CFrame.new(-3618.15698, 240.836655, -1317.45801, 1, 0, 0, 0, 1, 0, 0, 0, 1) },
    { Name = "Weather Machine",  CFrame = CFrame.new(-1488.51196, 83.1732635, 1876.30298, 1, 0, 0, 0, 1, 0, 0, 0, 1) },
    { Name = "Tropical Grove",  CFrame = CFrame.new(-2095.34106, 197.199997, 3718.08008) },
    { Name = "Treasure Room",  CFrame = CFrame.new(-3606.34985, -266.57373, -1580.97339, 0.998743415, 1.12141152e-13, -0.0501160324, -1.56847693e-13, 1, -8.88127842e-13, 0.0501160324, 8.94872392e-13, 0.998743415) },
    { Name = "Kohana",  CFrame = CFrame.new(-663.904236, 3.04580712, 718.796875, -0.100799225, -2.14183729e-08, -0.994906783, -1.12300391e-08, 1, -2.03902459e-08, 0.994906783, 9.11752096e-09, -0.100799225) }
}

-- ====== DAFTAR IDS ======
local rodIDs = {79, 76, 85, 76, 78, 4, 80, 6, 7, 5}
local baitIDs = {10, 2, 3, 6, 8, 15, 16}
local WeatherIDs = {"Cloudy", "Storm","Wind"}
local rodDatabase = {
    luck = 79,
    carbon = 76,
    grass = 85,
    demascus = 76,
    ice = 78,
    lucky = 4,
    midnight = 80,
    steampunk = 6,
    chrome = 7,
    astral = 5
}
local BaitDatabase = {
    topwaterbait = 10,
    luckbait = 2,
    midnightbait = 3,
    chromabait = 6,
    darkmatterbait = 8,
    corruptbait = 15,
    aetherbait = 16
}
-- Database ID Enchant
local enchantDatabase = {
    ["Cursed I"] = 12,
    ["Leprechaun I"] = 5,
    ["Leprechaun II"] = 6
}

-- ====== CORE FUNCTIONS ======
local function chargeFishingRod()
    pcall(function()
        if chargeEvent then
            chargeEvent:InvokeServer(1755848498.4834)
            task.wait(chargeFishingDelay)
        end
        if requestMinigameEvent then
            requestMinigameEvent:InvokeServer(1.2854545116425, 1)
        end
    end)
end

local function cancelFishing()
    pcall(function()
        if cancelFishingEvent then
            cancelFishingEvent:InvokeServer()
        end
    end)
end

local function performAutoCatch()
    pcall(function()
        if fishingEvent then
            fishingEvent:FireServer()
        end
    end)
end

local function equipRod()
    pcall(function() 
        if equipEvent then 
            equipEvent:FireServer(1)
            print("🎣 Rod equipped")
        end 
    end)
end

local function unequipRod()
    pcall(function() 
        if unequipEvent then 
            unequipEvent:FireServer()
            print("🎣 Rod unequipped")
        end 
    end)
end

-- buy luck rod
local function buyRod(rodDatabase)
    if purchaseRodEvent then
        pcall(function()
            purchaseRodEvent:InvokeServer(rodDatabase)
        end)
    else
        pcall(function()
            local directEvent = game:GetService("ReplicatedStorage").Packages._Index["sleitnick_net@0.2.0"].net["RF/PurchaseFishingRod"]
            directEvent:InvokeServer(rodDatabase)
        end)
    end
end

-- buy bait
local function buyBait(BaitDatabase)
    if purchaseBaitEvent then
        pcall(function()
            purchaseBaitEvent:InvokeServer(BaitDatabase)
        end)
    else
        pcall(function()
            local directEvent = game:GetService("ReplicatedStorage").Packages._Index["sleitnick_net@0.2.0"].net["RF/PurchaseBait"]
            directEvent:InvokeServer(BaitDatabase)
        end)
    end
end

-- ====== MEGALODON HUNT FUNCTIONS ======
local function teleportToMegalodon(position, isEventTeleport)
    if player.Character and player.Character:FindFirstChild("HumanoidRootPart") and player.Character:FindFirstChild("Humanoid") then
        local humanoid = player.Character.Humanoid
        local rootPart = player.Character.HumanoidRootPart

        -- Save position before teleport to event
        if isEventTeleport and not hasTeleportedToMegalodon then
            megalodonSavedPosition = rootPart.Position
            hasTeleportedToMegalodon = true
        end

        -- Remove lock before teleport if exists
        if currentBodyPosition then
            currentBodyPosition:Destroy()
            currentBodyPosition = nil
        end

        -- Teleport to position
        rootPart.CFrame = CFrame.new(position + Vector3.new(0, 5, 0))
        task.wait(0.1)

        -- Jump once
        humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
        task.wait(0.5)

        -- Enable floating/lock position
        currentBodyPosition = Instance.new("BodyPosition")
        currentBodyPosition.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
        currentBodyPosition.Position = position + Vector3.new(0, 5, 0)
        currentBodyPosition.P = 10000
        currentBodyPosition.D = 1000
        currentBodyPosition.Parent = rootPart
    end
end

local function disableMegalodonLock()
    if currentBodyPosition then
        currentBodyPosition:Destroy()
        currentBodyPosition = nil
    end
end

local function autoDetectMegalodon()
    local eventFound = false
    local eventPosition = nil

    -- Search for Megalodon event in Workspace
    for _, child in ipairs(workspace:GetChildren()) do
        if child.Name == "Props" and child:FindFirstChild("Megalodon Hunt") and child["Megalodon Hunt"]:FindFirstChild("Color") then
            eventPosition = child["Megalodon Hunt"].Color.Position
            eventFound = true
            break
        end
    end

    if eventFound and eventPosition then
        if not hasTeleportedToMegalodon then
            teleportToMegalodon(eventPosition, true)
            task.wait(0.5)
            disableMegalodonLock()
        end
    else
        -- Return to saved position when event ends
        if hasTeleportedToMegalodon and megalodonSavedPosition then
            teleportToMegalodon(megalodonSavedPosition, false)
            megalodonSavedPosition = nil
            hasTeleportedToMegalodon = false
        end
    end
end

local function setAutoMegalodon(state)
    isAutoMegalodonOn = state
    if not state then
        disableMegalodonLock()
        megalodonSavedPosition = nil
        hasTeleportedToMegalodon = false
    end
    print("🦈 Auto Megalodon Hunt: " .. (state and "ENABLED" or "DISABLED"))
end

-- ====== AUTO ENCHANT FUNCTIONS ======
-- Function untuk mendapatkan UUID enchant stone
local function getEnchantStoneUUID()
    local player = Players.LocalPlayer
    local backpack = player:WaitForChild("Backpack")
    
    for _, item in pairs(backpack:GetChildren()) do
        if item.Name == "EnchantStones" or string.find(item.Name:lower(), "enchant") then
            if item:GetAttribute("UUID") then
                return item:GetAttribute("UUID")
            end
        end
    end
    
    return nil
end

-- Function untuk equip enchant stone
local function equipEnchantStone()
    local uuid = getEnchantStoneUUID()
    if uuid then
        print("Equipping enchant stone with UUID:", uuid)
        pcall(function()
            EquipItemEvent:FireServer(uuid, "EnchantStones")
        end)
        task.wait(1)
    else
        print("Enchant stone tidak ditemukan di backpack!")
    end
end

-- Function untuk equip tool dari hotbar
local function equipToolFromHotbar()
    print("Equipping tool from hotbar slot:", HOTBAR_SLOT)
    pcall(function()
        if equipEvent then
            equipEvent:FireServer(HOTBAR_SLOT)
        end
    end)
    task.wait(1)
end

-- Function untuk aktivasi enchanting altar
local function activateEnchantingAltar()
    print("Activating enchanting altar...")
    pcall(function()
        ActivateEnchantEvent:FireServer()
    end)
    task.wait(2)
end

-- Function untuk handle incoming enchant result
local function onEnchantRoll(...)
    local args = {...}
    local enchantId = args[2]
    
    enchantAttempts = enchantAttempts + 1
    print(string.format("Enchant attempt #%d - Received enchant ID: %d", enchantAttempts, enchantId))
    
    if enchantId == targetEnchantID then
        print(string.format("SUCCESS! Found target enchant ID %d after %d attempts!", targetEnchantID, enchantAttempts))
        enchantFound = true
        isAutoEnchantOn = false -- Stop auto enchant
    else
        print(string.format("Not the target enchant (wanted: %d, got: %d). Continuing...", targetEnchantID, enchantId))
    end
end

-- Connection untuk enchant result
local enchantConnection = nil

-- Function utama untuk auto enchant
local function startAutoEnchant()
    if not isAutoEnchantOn then return end
    
    print(string.format("Starting auto enchant for ID: %d", targetEnchantID))
    enchantFound = false
    enchantAttempts = 0
    
    -- Connect ke enchant result event
    if RollEnchantRemote and not enchantConnection then
        enchantConnection = RollEnchantRemote.OnClientEvent:Connect(onEnchantRoll)
    end
    
    -- Main enchant loop
    task.spawn(function()
        while isAutoEnchantOn and not enchantFound do
            print(string.format("\n--- Starting enchant attempt #%d ---", enchantAttempts + 1))
            
            equipEnchantStone()
            equipToolFromHotbar()
            activateEnchantingAltar()
            
            if not enchantFound and isAutoEnchantOn then
                print("Waiting before next attempt...")
                task.wait(3)
            end
        end
        
        if enchantConnection then
            enchantConnection:Disconnect()
            enchantConnection = nil
        end
        
        if enchantFound then
            print("Auto enchant completed successfully!")
        else
            print("Auto enchant stopped!")
        end
    end)
end

-- Function untuk stop auto enchant
local function stopAutoEnchant()
    isAutoEnchantOn = false
    enchantFound = true
    
    if enchantConnection then
        enchantConnection:Disconnect()
        enchantConnection = nil
    end
    
    print("Auto enchant stopped!")
end

-- ====== ENHANCED TOGGLE FUNCTIONS ======
local function setAutoFarm(state)
    isAutoFarmOn = state
    
    if state then
        equipRod() -- Auto equip rod when starting
        print("🚜 Auto Farm: ENABLED")
    else
        cancelFishing()
        unequipRod() -- Auto unequip when stopping
        print("🚜 Auto Farm: DISABLED")
    end
end

local function setSell(state)
    isAutoSellOn = state
    print("💰 Auto Sell: " .. (state and "ENABLED" or "DISABLED"))
end

local function setUpgrade(state)
    isUpgradeOn = state
    print("⬆️ Auto Upgrade Rod: " .. (state and "ENABLED" or "DISABLED"))
end

local function setUpgradeBait(state)
    isUpgradeBaitOn = state
    print("⬆️ Auto Upgrade Bait: " .. (state and "ENABLED" or "DISABLED"))
end

local function setAutoCatch(state)
    isAutoCatchOn = state
    print("🎯 Auto Catch: " .. (state and "ENABLED" or "DISABLED"))
end

local function setAutoWeather(state)
    isAutoWeatherOn = state
    print("🌤️ Auto Weather: " .. (state and "ENABLED" or "DISABLED"))
end

-- ====== UI Kavo ======
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/xHeptc/Kavo-UI-Library/main/source.lua"))()
local Window  = Library.CreateLib("Auto Fish v4.5 - Simplified", "DarkTheme")

-- TAB: Auto
local TabAuto      = Window:NewTab("Auto Features")
local SecMain      = TabAuto:NewSection("Main Features")
local SecOther     = TabAuto:NewSection("Other Features")
local SecDelays    = TabAuto:NewSection("Delay Settings")

-- Main toggles with new Auto Farm feature
SecMain:NewToggle("Auto Farm", "Auto equip rod + fishing (kombinasi)", function(state) 
    setAutoFarm(state) 
end)

SecMain:NewToggle("Auto Sell", "Auto jual hasil", function(state) 
    setSell(state) 
end)

SecMain:NewToggle("Auto Catch", "Auto catch fish", function(state) 
    setAutoCatch(state) 
end)

-- Other features
SecOther:NewToggle("Auto Upgrade Rod", "Auto upgrade rod", function(state) 
    setUpgrade(state) 
end)

SecOther:NewToggle("Auto Upgrade Bait", "Auto upgrade bait", function(state) 
    setUpgradeBait(state) 
end)

SecOther:NewToggle("Auto Weather", "Auto weather events", function(state) 
    setAutoWeather(state) 
end)

-- ====== DELAY SETTINGS ======
SecDelays:NewSlider("Charge Rod Delay", "Delay setelah charge fishing rod (detik)", 10, 0.01, function(s)
    chargeFishingDelay = s
end)

SecDelays:NewSlider("Auto Fish Delay", "Delay loop utama auto fish (detik)", 20, 1, function(s)
    autoFishMainDelay = s
end)

SecDelays:NewSlider("Auto Sell Delay", "Delay auto sell (detik)", 30, 1, function(s)
    autoSellDelay = s
end)

SecDelays:NewSlider("Auto Catch Delay", "Delay auto catch (detik)", 10, 0.1, function(s)
    autoCatchDelay = s
end)

-- Quick teleport locations
local TabTeleport = Window:NewTab("Teleport")
local SecTP = TabTeleport:NewSection("Quick Teleport")

local tpNames = {}
for _, loc in ipairs(teleportLocations) do table.insert(tpNames, loc.Name) end

SecTP:NewDropdown("Pilih Lokasi", "Teleport instan ke lokasi", tpNames, function(chosen)
    for _, location in ipairs(teleportLocations) do
        if location.Name == chosen then
            pcall(function()
                local rootPart = game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                if rootPart then 
                    rootPart.CFrame = location.CFrame 
                    print("🚀 Teleported to: " .. chosen)
                else
                    warn("⚠ Character or HumanoidRootPart not found")
                end
            end)
            break
        end
    end
end)

-- ====== Shop TAB ======
local TabShop = Window:NewTab("Shop")
local SecShop = TabShop:NewSection("Fishing Rods")
local SecBait = TabShop:NewSection("Bait")

SecShop:NewButton("Luck Rod - 300", "Purchase Luck Rod", function()
    buyRod(rodDatabase.luck)
end)

SecShop:NewButton("Carbon Rod - 900", "Purchase Carbon Rod", function()
    buyRod(rodDatabase.carbon)
end)

SecShop:NewButton("Grass Rod - 1500", "Purchase Grass Rod", function()
    buyRod(rodDatabase.grass)
end)

SecShop:NewButton("Demascus Rod - 3000", "Purchase Demascus Rod", function()
    buyRod(rodDatabase.demascus)
end)

SecShop:NewButton("Ice Rod - 5000", "Purchase Ice Rod", function()
    buyRod(rodDatabase.ice)
end)

SecShop:NewButton("Lucky Rod - 15k", "Purchase Lucky Rod", function()
    buyRod(rodDatabase.lucky)
end)

SecShop:NewButton("Midnight Rod - 50k", "Purchase Midnight Rod", function()
    buyRod(rodDatabase.midnight)
end)

SecShop:NewButton("Steampunk Rod - 215k", "Purchase Steampunk Rod", function()
    buyRod(rodDatabase.steampunk)
end)

SecShop:NewButton("Chrome Rod - 437k", "Purchase Chrome Rod", function()
    buyRod(rodDatabase.chrome)
end)

SecShop:NewButton("Astral Rod - 1m", "Purchase Astral Rod", function()
    buyRod(rodDatabase.astral)
end)

--------- BAIT SHOP
SecBait:NewButton("TopWater Bait", "Buy Bait", function()
    buyBait(BaitDatabase.topwaterbait)
end)
SecBait:NewButton("Luck Bait 1k", "Buy Bait", function()
    buyBait(BaitDatabase.luckbait)
end)
SecBait:NewButton("Midnight Bait 3k", "Buy Bait", function()
    buyBait(BaitDatabase.midnightbait)
end)
SecBait:NewButton("Chroma Bait 290k", "Buy Bait", function()
    buyBait(BaitDatabase.chromabait)
end)
SecBait:NewButton("DarkMatter Bait 630k", "Buy Bait", function()
    buyBait(BaitDatabase.darkmatterbait)
end)
SecBait:NewButton("Corrupt Bait 1.15m", "Buy Bait", function()
    buyBait(BaitDatabase.corruptbait)
end)
SecBait:NewButton("Aether Bait 3.7m", "Buy Bait", function()
    buyBait(BaitDatabase.aetherbait)
end)

-- Add this in SecOther section after Auto Weather toggle
SecOther:NewToggle("Auto Megalodon Hunt", "Auto teleport to Megalodon events", function(state) 
    setAutoMegalodon(state) 
end)

-- ====== ENCHANT TAB UI ======
local TabEnchant = Window:NewTab("Enchant")
local SecEnchant = TabEnchant:NewSection("Auto Enchant")

-- Main auto enchant toggle
SecEnchant:NewToggle("Auto Enchant", "Otomatis enchant hingga mendapat target enchant", function(state)
    isAutoEnchantOn = state
    if state then
        startAutoEnchant()
    else
        stopAutoEnchant()
    end
end)

-- Quick select enchants - ini yang akan set target ID otomatis
local enchantNames = {}
for name, _ in pairs(enchantDatabase) do
    table.insert(enchantNames, name)
end
table.sort(enchantNames)

SecEnchant:NewDropdown("Target Enchant", "Pilih enchant yang ingin didapat", enchantNames, function(chosen)
    local enchantId = enchantDatabase[chosen]
    if enchantId then
        targetEnchantID = enchantId
        enchantFound = false
        enchantAttempts = 0
        print("Target enchant: " .. chosen .. " (ID: " .. enchantId .. ")")
    end
end)

-- Hotbar slot setting untuk tool
SecEnchant:NewSlider("Tool Hotbar Slot", "Slot hotbar dimana fishing rod berada", 9, 1, function(s)
    HOTBAR_SLOT = s
    print("Tool hotbar slot changed to:", s)
end)

-- Manual enchant controls
SecEnchant:NewButton("Manual Enchant Once", "Lakukan enchant sekali saja", function()
    task.spawn(function()
        print("Manual enchant started...")
        equipEnchantStone()
        equipToolFromHotbar() 
        activateEnchantingAltar()
    end)
end)

-- Test enchant stone detection
SecEnchant:NewButton("Test Enchant Stone", "Cek apakah enchant stone terdeteksi", function()
    local uuid = getEnchantStoneUUID()
    if uuid then
        print("Enchant stone found with UUID:", uuid)
    else
        print("Enchant stone tidak ditemukan di backpack!")
        print("Pastikan ada enchant stone di backpack Anda")
    end
end)

-- Reset enchant attempts counter
SecEnchant:NewButton("Reset Attempt Counter", "Reset counter percobaan enchant", function()
    enchantAttempts = 0
    enchantFound = false
    print("Enchant attempts counter reset!")
end)

-- ====== PERFORMANCE TAB ======
local TabPerformance = Window:NewTab("Performance")
local SecGPU = TabPerformance:NewSection("GPU Saver Mode")

SecGPU:NewToggle("GPU Saver Mode", "Enable white screen to save GPU/battery", function(state)
    if state then
        enableGPUSaver()
    else
        disableGPUSaver()
    end
end)

SecGPU:NewKeybind("GPU Saver Hotkey", "Quick toggle GPU saver", Enum.KeyCode.RightControl, function()
    if gpuSaverEnabled then
        disableGPUSaver()
    else
        enableGPUSaver()
    end
end)

SecGPU:NewButton("Force Remove White Screen", "Emergency remove if stuck", function()
    removeWhiteScreen()
    gpuSaverEnabled = false
end)

-- ====== UI CONTROLS ======
local TabUI = Window:NewTab("UI Controls")
local SecUI = TabUI:NewSection("Interface Controls")

-- ====== MINIMIZE SYSTEM ======
local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")

local MiniGui = Instance.new("ScreenGui")
MiniGui.Name = "AF_Minibar"
MiniGui.ResetOnSpawn = false
MiniGui.IgnoreGuiInset = true
MiniGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
MiniGui.Parent = CoreGui

local MiniBtn = Instance.new("TextButton")
MiniBtn.Name = "RestoreButton"
MiniBtn.Size = UDim2.new(0, 200, 0, 40)
MiniBtn.Position = UDim2.new(0, 20, 0, 80)
MiniBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
MiniBtn.BorderSizePixel = 0
MiniBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
MiniBtn.TextSize = 14
MiniBtn.Font = Enum.Font.GothamSemibold
MiniBtn.Text = "🚜 Auto Fish v4.5 (Show)"
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

-- Update status bar color based on active features
task.spawn(function()
    while true do
        if MiniBtn.Visible then
            local activeCount = 0
            if isAutoFarmOn then activeCount = activeCount + 1 end
            if isAutoSellOn then activeCount = activeCount + 1 end
            if isAutoCatchOn then activeCount = activeCount + 1 end
            
            local intensity = math.min(activeCount / 3, 1)
            statusGradient.Offset = Vector2.new(-intensity, 0)
            
            -- Update button text with status
            local statusText = ""
            if isAutoFarmOn then statusText = statusText .. "🚜" end
            if isAutoSellOn then statusText = statusText .. "💰" end
            if isAutoCatchOn then statusText = statusText .. "🎯" end
            
            MiniBtn.Text = "Auto Fish v4.5 " .. statusText .. " (Show)"
        end
        task.wait(1)
    end
end)

-- Drag functionality
do
    local dragging = false
    local dragStart, startPos
    MiniBtn.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = MiniBtn.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            MiniBtn.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + delta.X,
                startPos.Y.Scale, startPos.Y.Offset + delta.Y
            )
        end
    end)
end

local isMinimized = false
local function minimizeUI()
    if not isMinimized then
        isMinimized = true
        if MiniBtn then MiniBtn.Visible = true end
        Library:ToggleUI()
    end
end

local function restoreUI()
    if isMinimized then
        isMinimized = false
        if MiniBtn then MiniBtn.Visible = false end
        Library:ToggleUI()
    end
end

MiniBtn.MouseButton1Click:Connect(restoreUI)

SecUI:NewKeybind("Minimize/Restore (RightShift)", "Toggle UI cepat", Enum.KeyCode.RightShift, function()
    if isMinimized then restoreUI() else minimizeUI() end
end)

SecUI:NewButton("Force Show UI", "Paksa tampilkan UI jika tersembunyi", function()
    restoreUI()
end)

-- Custom minimize button
task.spawn(function()
    task.wait(2) -- Wait longer for UI to fully load
    
    local possibleNames = {"Kavo UI", "KavoLibrary", "UI", "MainUI"}
    local kavoGui = nil
    
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
        warn("❌ Kavo GUI tidak ditemukan untuk minimize button")
        return
    end
    
    local mainFrame = kavoGui:FindFirstChild("Main") or kavoGui:FindFirstChildOfClass("Frame")
    if not mainFrame then return end
    
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
        warn("❌ Title bar tidak ditemukan")
        return
    end
    
    local closeBtn = nil
    for _, child in pairs(titleBar:GetDescendants()) do
        if child:IsA("TextButton") and (child.Text == "X" or child.Text == "✕" or child.Text:find("close")) then
            closeBtn = child
            break
        end
    end
    
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
    
    minimizeBtn.MouseEnter:Connect(function()
        minimizeBtn.BackgroundColor3 = Color3.fromRGB(65, 65, 65)
    end)
    
    minimizeBtn.MouseLeave:Connect(function()
        minimizeBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    end)
    
    minimizeBtn.MouseButton1Click:Connect(function()
        minimizeUI()
    end)
    
    print("✅ Custom minimize button added successfully!")
end)

-- ====== AUTO LOOPS WITH ENHANCED LOGIC ======

-- Enhanced Auto Farm Loop (combines equip + fishing)
task.spawn(function()
    while true do
        if isAutoFarmOn then
            pcall(function()
                -- Check if rod is equipped by looking for tool in character
                local character = player.Character
                if character then
                    local tool = character:FindFirstChildOfClass("Tool")
                    if not tool then
                        equipRod()
                        task.wait(1) -- Wait for rod to equip
                    end
                end
                
                -- Perform fishing sequence
                chargeFishingRod()
                task.wait(autoFishMainDelay)
                
                if fishingEvent then 
                    fishingEvent:FireServer() 
                end
            end)
        end
        task.wait(0.1)
    end
end)

-- Auto Sell Loop
task.spawn(function()
    while true do
        if isAutoSellOn then
            pcall(function()
                if sellEvent then 
                    sellEvent:InvokeServer() 
                end
            end)
        end
        task.wait(autoSellDelay)
    end
end)

-- Auto Upgrade Rod Loop
task.spawn(function()
    while true do
        if isUpgradeOn then
            for _, id in ipairs(rodIDs) do
                if not isUpgradeOn then break end
                pcall(function()
                    if purchaseRodEvent then
                        purchaseRodEvent:InvokeServer(id)
                    end
                end)
                task.wait(2)
            end
        end
        task.wait(0.1)
    end
end)

task.spawn(function()
    while true do
        task.wait(1) -- biar nggak error
    end
end)

-- Auto Upgrade Bait Loop
task.spawn(function()
    while true do
        if isUpgradeBaitOn then
            for _, id in ipairs(baitIDs) do
                if not isUpgradeBaitOn then break end
                pcall(function()
                    if purchaseBaitEvent then
                        purchaseBaitEvent:InvokeServer(id)
                    end
                end)
                task.wait(2)
            end
        end
        task.wait(0.1)
    end
end)

-- Auto Weather Loop
task.spawn(function()
    while true do
        if isAutoWeatherOn then
            for _, id in ipairs(WeatherIDs) do
                if not isAutoWeatherOn then break end
                pcall(function()
                    if WeatherEvent then
                        WeatherEvent:InvokeServer(id)
                    end
                end)
                local waited = 0
                while isAutoWeatherOn and waited < weatherIdDelay do
                    task.wait(0.1)
                    waited = waited + 0.1
                end
            end
            
            local waitedCycle = 0
            while isAutoWeatherOn and waitedCycle < weatherCycleDelay do
                task.wait(0.1)
                waitedCycle = waitedCycle + 0.1
            end
        end
        task.wait(0.1)
    end
end)

-- Auto Catch Loop
task.spawn(function()
    while true do
        if isAutoCatchOn then
            performAutoCatch()
        end
        task.wait(autoCatchDelay)
    end
end)

-- Auto Megalodon Hunt Loop
task.spawn(function()
    while true do
        if isAutoMegalodonOn then
            pcall(function()
                autoDetectMegalodon()
            end)
        end
        task.wait(5) -- Check every 5 seconds
    end
end)

-- Inventory Whitelist Notifier (mutations-aware, single message per loop)
-- Counts by species (Tile.ItemName), shows pretty display (Variant + Base when available)

-- ============ CONFIG ============
local WEBHOOK_URL = "https://discord.com/api/webhooks/1378767185643831326/b0mB-z4r5YTQGeQnX7EwyvXoo1yiO7UcZzeOKeS9JKcKn-6AWVnicplzs6duT6Jt80kK"

-- Whitelist pakai NAMA SPECIES (tanpa prefix varian)
local WHITELIST = {"Robot Kraken", "Giant Squid", "Thin Armor Shark", "Frostborn Shark", "Plasma Shark", "Eerie Shark", "Scare", "Ghost Shark", "Blob Shark", "Megalodon", "Lochness Monster"}

local SCAN_WAIT    = 3     -- detik tunggu setelah buka agar tile render
local COOLDOWN     = 10    -- detik jeda antar loop
local OPEN_TIMEOUT = 6     -- detik max tunggu container/tile
local SEND_ONLY_ON_CHANGES = true -- true: kirim hanya jika ada kenaikan
local DEBUG = false

-- ============ SERVICES ============
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local player = Players.LocalPlayer

-- ============ UTIL ============
local function trim(s) return (s or ""):gsub("^%s+",""):gsub("%s+$","") end
local function normSpaces(s) return trim((s or ""):gsub("%s+"," ")) end
local function toKey(s) return string.lower(normSpaces(s or "")) end
local WL = {}; for _, n in ipairs(WHITELIST) do WL[toKey(n)] = true end
local function dprint(...) if DEBUG then print("[INV-DEBUG]", ...) end end

-- ============ WEBHOOK ============
local function sendDiscordEmbed(description, totalWhitelistCount)
    local embed = {
        title = "🎣 SECRET Fish Found",
        description = description,
        color = 3066993,
        fields = {
            { name = "🕒 Waktu",  value = os.date("%H:%M:%S"), inline = true },
            { name = "👤 Player", value = (player.DisplayName or player.Name or "Unknown"), inline = true },
            { name = "📦 Total (whitelist)", value = tostring(totalWhitelistCount) .. " fish", inline = true },
        },
        footer = { text = "Inventory Notifier • loop" }
    }
    local body = HttpService:JSONEncode({ embeds = {embed} })

    local ok, err = pcall(function()
        if syn and syn.request then
            syn.request({ Url=WEBHOOK_URL, Method="POST", Headers={["Content-Type"]="application/json"}, Body=body })
        elseif http_request then
            http_request({ Url=WEBHOOK_URL, Method="POST", Headers={["Content-Type"]="application/json"}, Body=body })
        elseif fluxus and fluxus.request then
            fluxus.request({ Url=WEBHOOK_URL, Method="POST", Headers={["Content-Type"]="application/json"}, Body=body })
        elseif request then
            request({ Url=WEBHOOK_URL, Method="POST", Headers={["Content-Type"]="application/json"}, Body=body })
        else
            error("Executor tidak support HTTP requests")
        end
    end)
    if not ok then warn("❌ Gagal kirim webhook:", err) else dprint("✅ Webhook terkirim") end
end

-- ============ INVENTORY CONTROL ============
local function getInventoryGui()
    return Players.LocalPlayer.PlayerGui:FindFirstChild("Inventory")
end

local function getInventoryContainer()
    local inv = getInventoryGui(); if not inv then return nil end
    local main = inv:FindFirstChild("Main")
    local content = main and main:FindFirstChild("Content")
    local pages = content and content:FindFirstChild("Pages")
    return pages and pages:FindFirstChild("Inventory") or nil
end

local function openInventory()
    local inv = getInventoryGui()

    -- Kick controller agar tile di-render (aman dipanggil berulang)
    pcall(function()
        local controllers = ReplicatedStorage:FindFirstChild("Controllers")
        if controllers then
            local invModule = controllers:FindFirstChild("InventoryController")
            if invModule then
                local ctrl = require(invModule)
                if ctrl.SetPage          then pcall(ctrl.SetPage, "Fish") end
                if ctrl.SetCategory      then pcall(ctrl.SetCategory, "Fish") end
                if ctrl._bindFishes      then pcall(ctrl._bindFishes) end
                if ctrl.RefreshInventory then pcall(ctrl.RefreshInventory) end
                if ctrl.UpdateInventory  then pcall(ctrl.UpdateInventory) end
                if ctrl.LoadInventory    then pcall(ctrl.LoadInventory) end
            end
        end
    end)

    -- Fallback tampilkan GUI
    if inv then
        if inv:IsA("ScreenGui") then inv.Enabled = true end
        local main = inv:FindFirstChild("Main")
        if main then
            main.Visible = true
            local content = main:FindFirstChild("Content")
            if content then content.Visible = true end
        end
        dprint("Inventory opened")
        return true
    end
    return false
end

local function closeInventory()
    local inv = getInventoryGui()
    if inv then
        local main = inv:FindFirstChild("Main"); if main then main.Visible = false end
        if inv:IsA("ScreenGui") then inv.Enabled = false end
    end
end

-- ============ SCAN (VARIANT-AWARE) ============
-- return: displayName (varian+base bila ada), speciesName (base)
local function getNamesFromTile(tile)
    if not tile or not tile:IsA("GuiObject") then return nil, nil end

    -- base/species dari Tile.ItemName (BUKAN search descendant supaya gak ketukar)
    local baseLabel = tile:FindFirstChild("ItemName")
    local base = baseLabel and baseLabel:IsA("TextLabel") and normSpaces(baseLabel.Text) or nil

    -- varian/prefix (Shiny/Big/Ghoulish/...) dari Tile.Variant.ItemName (kalau ada)
    local variantName
    local variant = tile:FindFirstChild("Variant")
    if variant then
        local vItem = variant:FindFirstChild("ItemName")
        if vItem and vItem:IsA("TextLabel") then
            local t = normSpaces(vItem.Text)
            if t ~= "" then variantName = t end
        end
    end

    -- Kadang label varian SUDAH berisi nama lengkap (mis. "Shiny Big Boar Fish")
    -- Jika ya dan base ada di dalamnya, pakai yang varian sebagai display.
    local display
    if variantName and base then
        local vlow, blow = toKey(variantName), toKey(base)
        if string.find(vlow, blow, 1, true) then
            display = variantName
        else
            -- gabungkan: "Variant Base"  (hindari duplikasi)
            display = variantName .. " " .. base
        end
    else
        display = variantName or base
    end

    -- Fallback terakhir: ambil text label terpanjang di tile
    if not display then
        local longest
        for _, d in ipairs(tile:GetDescendants()) do
            if d:IsA("TextLabel") then
                local t = normSpaces(d.Text)
                if t ~= "" and (not longest or #t > #longest) then longest = t end
            end
        end
        display = longest
    end

    -- speciesName: prioritaskan base (Tile.ItemName)
    local species = base or display
    return display, species
end

-- returns: speciesCounts (key->count), speciesPretty (key->display species), totalWhitelist
local function countTilesBySpecies(timeoutSec)
    local counts, pretty, totalWL = {}, {}, 0
    local t0 = os.clock()
    repeat
        local container = getInventoryContainer()
        if container then
            local tiles = container:GetChildren()
            local hasTile = false
            for _,ch in ipairs(tiles) do if ch.Name == "Tile" then hasTile = true break end end
            if hasTile and (os.clock() - t0) >= SCAN_WAIT then break end
        end
        RunService.Heartbeat:Wait()
    until (os.clock() - t0) >= (timeoutSec or OPEN_TIMEOUT)

    local container = getInventoryContainer()
    if not container then dprint("container NOT FOUND"); return counts, pretty, 0 end

    local tiles = container:GetChildren()
    dprint("Tiles:", #tiles)
    for _, child in ipairs(tiles) do
        if child.Name == "Tile" and child:IsA("GuiObject") then
            local displayName, speciesName = getNamesFromTile(child)
            if speciesName and speciesName ~= "" then
                local key = toKey(speciesName)
                if WL[key] then
                    counts[key] = (counts[key] or 0) + 1
                    pretty[key] = pretty[key] or speciesName -- simpan nama species yg cantik
                    totalWL = totalWL + 1
                    dprint("Tile ->", displayName or speciesName, " | species:", speciesName, " | key:", key)
                end
            end
        end
    end
    return counts, pretty, totalWL
end

-- ============ STATE & BUILDERS ============
local seenCounts = {}   -- key -> last count
local prettyCache = {}  -- key -> species display

local function buildTotalsLines(counts)
    local lines = {}
    for key, cnt in pairs(counts) do
        local pretty = prettyCache[key] or key
        table.insert(lines, string.format("• %dx %s", cnt, pretty))
    end
    table.sort(lines)
    return lines
end

local function buildDiffLines(counts)
    local diffs = {}
    for key, cnt in pairs(counts) do
        local last = seenCounts[key] or 0
        local inc = cnt - last
        if inc > 0 then
            local pretty = prettyCache[key] or key
            table.insert(diffs, string.format("+%d %s !New", inc, pretty))
        end
    end
    table.sort(diffs)
    return diffs
end

-- ============ BASELINE ============
local function baselineNow()
    if not openInventory() then warn("❌ Gagal buka Inventory (baseline)"); return end
    local t0 = os.clock(); while os.clock() - t0 < SCAN_WAIT do RunService.Heartbeat:Wait() end
    local counts, pretty = countTilesBySpecies(OPEN_TIMEOUT)
    seenCounts = counts
    for k,v in pairs(pretty) do prettyCache[k] = v end
    closeInventory()
end

-- ============ SCAN & SEND (single webhook) ============
local function scanAndNotifySingle()
    if not openInventory() then warn("❌ Gagal buka Inventory (scan)"); return end
    local t0 = os.clock(); while os.clock() - t0 < SCAN_WAIT do RunService.Heartbeat:Wait() end

    local counts, pretty, totalWL = countTilesBySpecies(OPEN_TIMEOUT)
    for k,v in pairs(pretty) do prettyCache[k] = v end

    local totalLines = buildTotalsLines(counts)
    local diffLines  = buildDiffLines(counts)

    if SEND_ONLY_ON_CHANGES and #diffLines == 0 then
        dprint("No whitelist changes; skip send")
        seenCounts = counts
        closeInventory()
        return
    end

    local description = table.concat(totalLines, "\n")
    if #diffLines > 0 then
        description = description .. "\n\n" .. table.concat(diffLines, "\n")
    end
    sendDiscordEmbed(description, totalWL)

    seenCounts = counts
    closeInventory()
end

-- ============ LOOP ============
print("🚀 Inventory Whitelist Notifier (mutation-aware) start...")
baselineNow()

while true do
    scanAndNotifySingle()
    task.wait(COOLDOWN)
end
