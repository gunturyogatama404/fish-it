--[[
    AUTO FISH V5.7 STABLE WITH ENHANCED PERFORMANCE OPTIMIZATION

    🚀 NEW FEATURES:
    - Automatic graphics optimization for maximum FPS on script start
    - Integrated Low Graphic.lua optimizations
    - Real-time FPS monitoring every 5 seconds
    - Enhanced error suppression for asset loading issues

    📋 OPTIMIZATIONS INCLUDED:
    ✅ Removes clouds and water effects
    ✅ Disables shadows and lighting effects
    ✅ Optimizes all materials to Plastic
    ✅ Disables particle effects and sounds
    ✅ Sets graphics quality to Level 1
    ✅ Optimizes character accessories and textures

    IMPORTANT: SETUP WEBHOOK URLs BEFORE RUNNING!

    1. For Megalodon notifications: Edit line ~1375 and set MEGALODON_WEBHOOK_URL
    2. For fish catch notifications: Edit line ~2340 and set WEBHOOK_URL

    Example webhook URL: "https://discord.com/api/webhooks/1234567890/abcdefghijklmnop"

    To get Discord webhook URL:
    1. Go to your Discord server
    2. Right click on channel → Settings → Integrations → Webhooks
    3. Create New Webhook
    4. Copy webhook URL
    5. Paste it in the webhook variables below
--]]

-- ====== ERROR HANDLING SETUP ======
-- Suppress asset loading errors (like sound approval issues)
local function suppressAssetErrors()
    local oldWarn = warn
    local oldError = error

    warn = function(...)
        local message = tostring(...)
        -- Suppress known asset approval errors
        if string.find(message:lower(), "asset is not approved") or
           string.find(message:lower(), "failed to load sound") or
           string.find(message:lower(), "rbxassetid") then
            -- Silently ignore these errors
            return
        end
        oldWarn(...)
    end

    -- Also wrap error function for safety
    error = function(...)
        local message = tostring(...)
        if string.find(message:lower(), "asset is not approved") or
           string.find(message:lower(), "failed to load sound") then
            warn("[Auto Fish] Asset loading error suppressed: " .. message)
            return
        end
        oldError(...)
    end
end

-- Enable error suppression
suppressAssetErrors()

-- ====== AUTOMATIC PERFORMANCE OPTIMIZATION ======
-- Integrated from Low Graphic.lua for maximum FPS
local function ultimatePerformance()
    local workspace = game:GetService("Workspace")
    local lighting = game:GetService("Lighting")
    local runService = game:GetService("RunService")
    local players = game:GetService("Players")

    print("🚀 STARTING GRAPHICS OPTIMIZATION...")
    print("⚡ Applying Low Graphic settings for maximum FPS...")

    local objectsOptimized = 0
    local effectsDisabled = 0

    -- TERRAIN & CLOUDS REMOVAL
    pcall(function()
        local terrain = workspace:FindFirstChild("Terrain")
        if terrain then
            -- Remove clouds completely
            if terrain:FindFirstChild("Clouds") then
                terrain.Clouds:Destroy()
                print("✅ Removed clouds")
            end

            -- Water optimization
            terrain.WaterWaveSize = 0
            terrain.WaterWaveSpeed = 0
            terrain.WaterReflectance = 0
            terrain.WaterTransparency = 0
        end
    end)

    -- LIGHTING OPTIMIZATION (Maximum Performance)
    pcall(function()
        lighting.GlobalShadows = false
        lighting.FogEnd = 9e9
        lighting.FogStart = 9e9
        lighting.Brightness = 0
        lighting.Technology = Enum.Technology.Compatibility
        lighting.Ambient = Color3.new(1, 1, 1)
        lighting.OutdoorAmbient = Color3.new(1, 1, 1)
        lighting.ShadowSoftness = 0
        lighting.ExposureCompensation = 0

        -- Remove all lighting effects
        for _, effect in pairs(lighting:GetChildren()) do
            if effect:IsA("PostEffect") or effect:IsA("Atmosphere") or
               effect:IsA("Sky") or effect:IsA("Clouds") then
                pcall(function()
                    effect:Destroy()
                    effectsDisabled = effectsDisabled + 1
                end)
            end
        end
        print("✅ Lighting optimized - shadows disabled, fog removed")
    end)

    -- WORKSPACE OPTIMIZATION
    local function optimizeObject(obj)
        if obj:IsA("BasePart") then
            obj.CastShadow = false
            obj.Material = Enum.Material.Plastic
            obj.Reflectance = 0
            objectsOptimized = objectsOptimized + 1

            -- Water parts specific
            if obj.Material == Enum.Material.Water or obj.Name:lower():find("water") then
                obj.Color = Color3.new(0, 0.8, 1)
                obj.Material = Enum.Material.Plastic
                obj.Transparency = 0.2
                obj.Anchored = true
            end

        elseif obj:IsA("ParticleEmitter") or obj:IsA("Fire") or obj:IsA("Smoke") or
               obj:IsA("Sparkles") or obj:IsA("PointLight") or obj:IsA("SpotLight") or
               obj:IsA("SurfaceLight") or obj:IsA("Beam") then
            obj.Enabled = false
            effectsDisabled = effectsDisabled + 1

        elseif obj:IsA("Decal") or obj:IsA("Texture") then
            if obj.Name ~= "face" then
                obj.Transparency = 1
                objectsOptimized = objectsOptimized + 1
            end

        elseif obj:IsA("Sound") then
            obj.Volume = 0
            obj:Stop()
            effectsDisabled = effectsDisabled + 1

        elseif obj:IsA("Script") or obj:IsA("LocalScript") then
            local name = obj.Name:lower()
            if name:find("water") or name:find("wave") or name:find("cloud") or
               name:find("particle") or name:find("effect") then
                obj.Disabled = true
                effectsDisabled = effectsDisabled + 1
            end
        end
    end

    -- Apply to existing objects
    print("⚙️ Scanning workspace for optimization...")
    for _, obj in pairs(workspace:GetDescendants()) do
        optimizeObject(obj)
    end
    print("✅ Workspace scan complete - " .. objectsOptimized .. " objects optimized")

    -- Apply to new objects
    workspace.DescendantAdded:Connect(optimizeObject)

    -- CHARACTER OPTIMIZATION
    local function optimizeCharacter(character)
        if not character then return end

        for _, part in pairs(character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CastShadow = false
                part.Material = Enum.Material.Plastic
                part.Reflectance = 0

            elseif part:IsA("Accessory") then
                local handle = part:FindFirstChild("Handle")
                if handle then
                    handle.CastShadow = false
                    handle.Material = Enum.Material.Plastic
                    local mesh = handle:FindFirstChildOfClass("SpecialMesh")
                    if mesh then mesh.TextureId = "" end
                end

            elseif part:IsA("ParticleEmitter") or part:IsA("Fire") or
                   part:IsA("Smoke") or part:IsA("Sparkles") then
                part.Enabled = false
            end
        end
    end

    -- Apply to all players
    for _, player in pairs(players:GetPlayers()) do
        if player.Character then optimizeCharacter(player.Character) end
        player.CharacterAdded:Connect(optimizeCharacter)
    end
    players.PlayerAdded:Connect(function(player)
        player.CharacterAdded:Connect(optimizeCharacter)
    end)

    -- RENDERING OPTIMIZATION
    pcall(function()
        local camera = workspace.CurrentCamera
        if camera then
            for _, effect in pairs(camera:GetChildren()) do
                if effect:IsA("PostEffect") then effect.Enabled = false end
            end
        end
    end)

    -- GAME SETTINGS (Aggressive optimization)
    pcall(function()
        local gameSettings = UserSettings().GameSettings
        gameSettings.SavedQualityLevel = Enum.SavedQualitySetting.QualityLevel1

        -- Additional performance settings
        local renderSettings = settings():GetService("RenderSettings")
        renderSettings.QualityLevel = Enum.QualityLevel.Level01
        renderSettings.MeshPartDetailLevel = Enum.MeshPartDetailLevel.Level04
        renderSettings.EditQualityLevel = Enum.QualityLevel.Level01

        print("✅ Graphics quality forced to minimum")
    end)

    -- ANIMATION CONNECTION CLEANUP
    pcall(function()
        for _, connection in pairs(getconnections(runService.Heartbeat)) do
            pcall(function()
                local func = connection.Function
                local env = getfenv(func)
                if env.script then
                    local name = env.script.Name:lower()
                    if name:find("water") or name:find("wave") or name:find("cloud") or
                       name:find("particle") or name:find("effect") then
                        connection:Disable()
                    end
                end
            end)
        end
    end)

    print("🚀 ULTIMATE PERFORMANCE ACTIVATED!")
    print("📊 OPTIMIZATION SUMMARY:")
    print("  ✅ Objects optimized: " .. objectsOptimized)
    print("  ✅ Effects disabled: " .. effectsDisabled)
    print("  ✅ Clouds removed")
    print("  ✅ Water optimized")
    print("  ✅ Shadows disabled")
    print("  ✅ Graphics quality set to Level 1")
    print("  ✅ All particle effects disabled")
    print("🎣 Auto Fish ready with maximum FPS!")

    -- Force immediate rendering update
    pcall(function()
        local camera = workspace.CurrentCamera
        if camera then
            camera.FieldOfView = camera.FieldOfView
        end
    end)
end

-- Auto-execute performance optimization on script start
ultimatePerformance()

-- Optional FPS monitor
task.spawn(function()
    while task.wait(5) do
        local fps = workspace:GetRealPhysicsFPS()
        if fps then
            print("📊 Current FPS: " .. math.floor(fps))
        end
    end
end)

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
    [163] = {name = "Viperfish", sellPrice = 94}
}
-- State variables
local isAutoFarmOn = false
local isAutoSellOn = false
local isAutoCatchOn = false
local isUpgradeOn = false
local isUpgradeBaitOn = false
local isAutoWeatherOn = false
local gpuSaverEnabled = false
local renderingOptimized = false
local isAutoMegalodonOn = false
local megalodonSavedPosition = nil
local hasTeleportedToMegalodon = false
local currentBodyPosition = nil

local isAutoPreset1On = false
local isAutoPreset2On = false

-- Megalodon event variables
local megalodonEventActive = false
local megalodonMissingAlertSent = false
local megalodonEventStartedAt = 0

local HttpService = game:GetService("HttpService")

local CONFIG_FILE = "auto_fish_v51_disconnect_config.json"
local defaultConfig = {
    autoFarm = false,
    autoSell = false,
    autoCatch = false,
    autoWeather = false,
    autoMegalodon = false,
    activePreset = "none"
}
local config = {}
for key, value in pairs(defaultConfig) do
    config[key] = value
end

local isApplyingConfig = false

local function saveConfig()
    if not writefile then return end

    local success, encoded = pcall(function()
        return HttpService:JSONEncode(config)
    end)

    if success then
        pcall(writefile, CONFIG_FILE, encoded)
    end
end

local function loadConfig()
    if not readfile or not isfile then
        return
    end

    local success, content = pcall(function()
        if isfile(CONFIG_FILE) then
            return readfile(CONFIG_FILE)
        end

        return nil
    end)

    if success and content and content ~= "" then
        local ok, decoded = pcall(function()
            return HttpService:JSONDecode(content)
        end)

        if ok and type(decoded) == "table" then
            for key, value in pairs(defaultConfig) do
                if decoded[key] ~= nil then
                    config[key] = decoded[key]
                else
                    config[key] = value
                end
            end
        end
    end

    saveConfig()
end

local function updateConfigField(key, value)
    config[key] = value
    if not isApplyingConfig then
        saveConfig()
    end
end

local function syncConfigFromStates()
    config.autoFarm = isAutoFarmOn
    config.autoSell = isAutoSellOn
    config.autoCatch = isAutoCatchOn
    config.autoWeather = isAutoWeatherOn
    config.autoMegalodon = isAutoMegalodonOn
end

loadConfig()

local autoFarmToggle
local autoSellToggle
local autoCatchToggle
local autoWeatherToggle
local autoMegalodonToggle
local autoPreset1Toggle
local autoPreset2Toggle

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

-- fungsi quest

local function getQuestText(labelName)
    local success, result = pcall(function()
        local menuRings = workspace:FindFirstChild("!!! MENU RINGS")
        if not menuRings then return "Quest not found" end
        
        local deepSeaTracker = menuRings:FindFirstChild("Deep Sea Tracker")
        if not deepSeaTracker then return "Quest not found" end
        
        local board = deepSeaTracker:FindFirstChild("Board")
        if not board then return "Quest not found" end
        
        local gui = board:FindFirstChild("Gui")
        if not gui then return "Quest not found" end
        
        local content = gui:FindFirstChild("Content")
        if not content then return "Quest not found" end
        
        local label = content:FindFirstChild(labelName)
        if not label then return "Quest not found" end
        
        return label.Text or "No data"
    end)
    
    return success and result or "Error fetching quest"
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

local HOTBAR_SLOT = 2 -- Slot hotbar untuk equip tool

-- ====== FISH NOTIFICATION CONTROL ======
local isFishNotificationDisabled = false
local destroyedNotifications = {}

-- Function to disable fish notifications
local function disableFishNotifications()
    if isFishNotificationDisabled then return end

    pcall(function()
        local replicatedStorage = game:GetService("ReplicatedStorage")
        local packages = replicatedStorage:FindFirstChild("Packages")
        if packages then
            local index = packages:FindFirstChild("_Index")
            if index then
                local net = index:FindFirstChild("sleitnick_net@0.2.0")
                if net then
                    local netFolder = net:FindFirstChild("net")
                    if netFolder then
                        local notificationEvents = {
                            "RE/ObtainedNewFishNotification",
                            "RE/ShowNotification",
                            "RE/PlaySound"
                        }

                        for _, eventName in pairs(notificationEvents) do
                            local event = netFolder:FindFirstChild(eventName)
                            if event then
                                -- Store reference before destroying
                                destroyedNotifications[eventName] = {
                                    parent = netFolder,
                                    className = event.ClassName
                                }
                                event:Destroy()
                                print("🔇 Disabled " .. eventName .. " notification")
                            end
                        end
                    end
                end
            end
        end
    end)

    isFishNotificationDisabled = true
    print("🔇 Fish notifications: DISABLED")
end

-- Function to restore fish notifications (if needed)
local function enableFishNotifications()
    if not isFishNotificationDisabled then return end

    -- Note: Once destroyed, remote events cannot be restored easily
    -- This function exists for UI consistency but notifications will remain disabled until script restart
    isFishNotificationDisabled = false
    print("🔊 Fish notifications: ENABLED (requires script restart to fully restore)")
end

-- Improved WaitForChild chain with error handling
local EquipItemEvent = replicatedStorage.Packages._Index["sleitnick_net@0.2.0"].net:WaitForChild("RE/EquipItem")

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
    titleLabel.TextSize = 32
    titleLabel.Font = Enum.Font.SourceSansBold
    titleLabel.TextXAlignment = Enum.TextXAlignment.Center
    titleLabel.TextYAlignment = Enum.TextYAlignment.Center
    titleLabel.Parent = frame
    
    -- Session time (centered)
    local sessionLabel = Instance.new("TextLabel")
    sessionLabel.Name = "SessionLabel"
    sessionLabel.Size = UDim2.new(0, 400, 0, 40)
    sessionLabel.Position = UDim2.new(0.5, -200, 0, 180)
    sessionLabel.BackgroundTransparency = 1
    sessionLabel.Text = "⏱️ Uptime: 00:00:00"
    sessionLabel.TextColor3 = Color3.new(1, 1, 1)
    sessionLabel.TextSize = 22
    sessionLabel.Font = Enum.Font.SourceSansBold
    sessionLabel.TextXAlignment = Enum.TextXAlignment.Center
    sessionLabel.Parent = frame
    
    -- Fishing stats (centered)
    local fishStatsLabel = Instance.new("TextLabel")
    fishStatsLabel.Name = "FishStatsLabel"
    fishStatsLabel.Size = UDim2.new(0, 400, 0, 40)
    fishStatsLabel.Position = UDim2.new(0.5, -200, 0, 200)
    fishStatsLabel.BackgroundTransparency = 1
    fishStatsLabel.Text = "🎣 Fish Caught: " .. FormatNumber(sessionStats.totalFish)
    fishStatsLabel.TextColor3 = Color3.new(0.9, 0.9, 0.9)
    fishStatsLabel.TextSize = 22
    fishStatsLabel.Font = Enum.Font.SourceSans
    fishStatsLabel.TextXAlignment = Enum.TextXAlignment.Center
    fishStatsLabel.Parent = frame
    
-- Coin display (mengganti earnings)
    local coinLabel = Instance.new("TextLabel")
    coinLabel.Name = "CoinLabel"
    coinLabel.Size = UDim2.new(0, 400, 0, 40)
    coinLabel.Position = UDim2.new(0.5, -200, 0, 220)
    coinLabel.BackgroundTransparency = 1
    coinLabel.Text = "💰 Coins: " .. getCurrentCoins()
    coinLabel.TextColor3 = Color3.new(0.9, 0.9, 0.9)
    coinLabel.TextSize = 22
    coinLabel.Font = Enum.Font.SourceSans
    coinLabel.TextXAlignment = Enum.TextXAlignment.Center
    coinLabel.Parent = frame

    -- Level display (tambahan baru)
    local levelLabel = Instance.new("TextLabel")
    levelLabel.Name = "LevelLabel"
    levelLabel.Size = UDim2.new(0, 400, 0, 40)
    levelLabel.Position = UDim2.new(0.5, -200, 0, 240)
    levelLabel.BackgroundTransparency = 1
    levelLabel.Text = "⭐ " .. getCurrentLevel()
    levelLabel.TextColor3 = Color3.new(0.9, 0.9, 0.9)
    levelLabel.TextSize = 22
    levelLabel.Font = Enum.Font.SourceSans
    levelLabel.TextXAlignment = Enum.TextXAlignment.Center
    levelLabel.Parent = frame

        local quest1Label = Instance.new("TextLabel")
    quest1Label.Name = "Quest1Label"
    quest1Label.Size = UDim2.new(0, 600, 0, 30)  -- Lebar lebih untuk 2 quests, height compact
    quest1Label.Position = UDim2.new(0.5, -300, 0, 310)  -- Di bawah level
    quest1Label.BackgroundTransparency = 1
    quest1Label.Text = "🏆 Quest 1: " .. getQuestText("Label1")
    quest1Label.TextColor3 = Color3.new(0.9, 0.9, 0.9)
    quest1Label.TextSize = 20  -- Tetap pas seperti sekarang
    quest1Label.Font = Enum.Font.SourceSans
    quest1Label.TextXAlignment = Enum.TextXAlignment.Center
    quest1Label.TextWrapped = true  -- Wrap jika panjang
    quest1Label.Parent = frame

    local quest2Label = Instance.new("TextLabel")
    quest2Label.Name = "Quest2Label"
    quest2Label.Size = UDim2.new(0, 600, 0, 30)  -- Lebar lebih untuk 2 quests, height compact
    quest2Label.Position = UDim2.new(0.5, -300, 0, 330)  -- Di bawah level
    quest2Label.BackgroundTransparency = 1
    quest2Label.Text = "🏆 Quest 2: " .. getQuestText("Label2")
    quest2Label.TextColor3 = Color3.new(0.9, 0.9, 0.9)
    quest2Label.TextSize = 20  -- Tetap pas seperti sekarang
    quest2Label.Font = Enum.Font.SourceSans
    quest2Label.TextXAlignment = Enum.TextXAlignment.Center
    quest2Label.TextWrapped = true  -- Wrap jika panjang
    quest2Label.Parent = frame

    local quest3Label = Instance.new("TextLabel")
    quest3Label.Name = "Quest3Label"
    quest3Label.Size = UDim2.new(0, 600, 0, 30)  -- Lebar lebih untuk 2 quests, height compact
    quest3Label.Position = UDim2.new(0.5, -300, 0, 350)  -- Di bawah level
    quest3Label.BackgroundTransparency = 1
    quest3Label.Text = "🏆 Quest 3: " .. getQuestText("Label3")
    quest3Label.TextColor3 = Color3.new(0.9, 0.9, 0.9)
    quest3Label.TextSize = 20  -- Tetap pas seperti sekarang
    quest3Label.Font = Enum.Font.SourceSans
    quest3Label.TextXAlignment = Enum.TextXAlignment.Center
    quest3Label.TextWrapped = true  -- Wrap jika panjang
    quest3Label.Parent = frame

    local quest4Label = Instance.new("TextLabel")
    quest4Label.Name = "Quest4Label"
    quest4Label.Size = UDim2.new(0, 600, 0, 30)  -- Lebar lebih untuk 2 quests, height compact
    quest4Label.Position = UDim2.new(0.5, -300, 0, 370)  -- Di bawah level
    quest4Label.BackgroundTransparency = 1
    quest4Label.Text = "🏆 Quest 4: " .. getQuestText("Label4")
    quest4Label.TextColor3 = Color3.new(0.9, 0.9, 0.9)
    quest4Label.TextSize = 20  -- Tetap pas seperti sekarang
    quest4Label.Font = Enum.Font.SourceSans
    quest4Label.TextXAlignment = Enum.TextXAlignment.Center
    quest4Label.TextWrapped = true  -- Wrap jika panjang
    quest4Label.Parent = frame
    
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

    -- Close button for Android/mobile users
    local closeButton = Instance.new("TextButton")
    closeButton.Size = UDim2.new(0, 200, 0, 40)
    closeButton.Position = UDim2.new(1, -220, 0, 100)
    closeButton.BackgroundColor3 = Color3.new(0.2, 0.2, 0.2)
    closeButton.BorderSizePixel = 0
    closeButton.Text = "❌ Disable GPU Saver"
    closeButton.TextColor3 = Color3.new(1, 0, 0)
    closeButton.TextSize = 16
    closeButton.Font = Enum.Font.SourceSansBold
    closeButton.TextXAlignment = Enum.TextXAlignment.Center
    closeButton.Parent = frame

    closeButton.MouseButton1Click:Connect(function()
        disableGPUSaver()
    end)
    
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

                -- Safe quest
                pcall(function()
                    if quest1Label and quest1Label.Parent then
                        quest1Label.Text = "🏆 Quest 1: " .. getQuestText("Label1")
                    end
                end)

                pcall(function()
                    if quest2Label and quest2Label.Parent then
                        quest2Label.Text = "🏆 Quest 2: " .. getQuestText("Label2")
                    end
                end)
                
                pcall(function()
                    if quest3Label and quest3Label.Parent then
                        quest3Label.Text = "🏆 Quest 3: " .. getQuestText("Label3")
                    end
                end)

                pcall(function()
                    if quest4Label and quest4Label.Parent then
                        quest4Label.Text = "🏆 Quest 4: " .. getQuestText("Label4")
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
    { Name = "Crater Island",  CFrame = CFrame.new(1016.49072, 20.0919304, 5069.27295, 0.838976264, 3.30379857e-09, -0.544168055, 2.63538391e-09, 1, 1.01344115e-08, 0.544168055, -9.93662219e-09, 0.838976264) },
    { Name = "Spawn",  CFrame = CFrame.new(45.2788086, 252.562927, 2987.10913, 1, 0, 0, 0, 1, 0, 0, 0, 1) },
    { Name = "Lost Isle",  CFrame = CFrame.new(-3618.15698, 240.836655, -1317.45801, 1, 0, 0, 0, 1, 0, 0, 0, 1) },
    { Name = "Weather Machine",  CFrame = CFrame.new(-1488.51196, 83.1732635, 1876.30298, 1, 0, 0, 0, 1, 0, 0, 0, 1) },
    { Name = "Tropical Grove",  CFrame = CFrame.new(-2095.34106, 197.199997, 3718.08008) },
    { Name = "Treasure Room",  CFrame = CFrame.new(-3606.34985, -266.57373, -1580.97339, 0.998743415, 1.12141152e-13, -0.0501160324, -1.56847693e-13, 1, -8.88127842e-13, 0.0501160324, 8.94872392e-13, 0.998743415) },
    { Name = "Kohana",  CFrame = CFrame.new(-663.904236, 3.04580712, 718.796875, -0.100799225, -2.14183729e-08, -0.994906783, -1.12300391e-08, 1, -2.03902459e-08, 0.994906783, 9.11752096e-09, -0.100799225) }
}

local function teleportToNamedLocation(targetName)
    if not targetName then
        return
    end

    if targetName == "Sisyphus State" then
        targetName = "Sisyphus Statue"
    end

    pcall(function()
        local character = player.Character or player.CharacterAdded:Wait()
        local rootPart = character and character:FindFirstChild("HumanoidRootPart")
        if not rootPart then
            return
        end

        for _, location in ipairs(teleportLocations) do
            if location.Name == targetName and location.CFrame then
                rootPart.CFrame = location.CFrame
                print("[AutoFish] Teleported to: " .. targetName)
                break
            end
        end
    end)
end

local PRESET_DELAY = 0.5
local presetActionLock = false

local function runPresetSequence(steps)
    if type(steps) ~= "table" or #steps == 0 then
        return
    end

    while presetActionLock do
        task.wait(0.05)
    end

    presetActionLock = true
    isApplyingConfig = true

    local success, err = pcall(function()
        for index, step in ipairs(steps) do
            step()
            if index < #steps then
                task.wait(PRESET_DELAY)
            end
        end
    end)

    isApplyingConfig = false
    syncConfigFromStates()
    presetActionLock = false

    if not success then
        warn("[AutoFish] Preset sequence error:", err)
    end
end

local function enablePreset(presetKey, locationName)
    task.spawn(function()
        local steps = {}

        if config.activePreset and config.activePreset ~= "none" and config.activePreset ~= presetKey then
            table.insert(steps, function()
                if autoMegalodonToggle then
                    autoMegalodonToggle:UpdateToggle(nil, false)
                end
            end)
            table.insert(steps, function()
                if autoWeatherToggle then
                    autoWeatherToggle:UpdateToggle(nil, false)
                end
            end)
            table.insert(steps, function()
                if autoCatchToggle then
                    autoCatchToggle:UpdateToggle(nil, false)
                end
            end)
            table.insert(steps, function()
                if autoSellToggle then
                    autoSellToggle:UpdateToggle(nil, false)
                end
            end)
            table.insert(steps, function()
                if autoFarmToggle then
                    autoFarmToggle:UpdateToggle(nil, false)
                end
            end)
        end

        table.insert(steps, function()
            if autoFarmToggle then
                autoFarmToggle:UpdateToggle(nil, true)
            end
        end)
        table.insert(steps, function()
            if autoSellToggle then
                autoSellToggle:UpdateToggle(nil, true)
            end
        end)
        table.insert(steps, function()
            if autoCatchToggle then
                autoCatchToggle:UpdateToggle(nil, true)
            end
        end)
        table.insert(steps, function()
            if autoWeatherToggle then
                autoWeatherToggle:UpdateToggle(nil, true)
            end
        end)
        table.insert(steps, function()
            if autoMegalodonToggle then
                autoMegalodonToggle:UpdateToggle(nil, true)
            end
        end)

        runPresetSequence(steps)

        if presetKey == "auto1" then
            isAutoPreset1On = true
            isAutoPreset2On = false
        else
            isAutoPreset1On = false
            isAutoPreset2On = true
        end

        config.activePreset = presetKey
        saveConfig()
        teleportToNamedLocation(locationName)
    end)
end

local function disablePreset(presetKey)
    task.spawn(function()
        if config.activePreset ~= presetKey then
            if presetKey == "auto1" then
                isAutoPreset1On = false
            elseif presetKey == "auto2" then
                isAutoPreset2On = false
            end
            return
        end

        local steps = {
            function()
                if autoMegalodonToggle then
                    autoMegalodonToggle:UpdateToggle(nil, false)
                end
            end,
            function()
                if autoWeatherToggle then
                    autoWeatherToggle:UpdateToggle(nil, false)
                end
            end,
            function()
                if autoCatchToggle then
                    autoCatchToggle:UpdateToggle(nil, false)
                end
            end,
            function()
                if autoSellToggle then
                    autoSellToggle:UpdateToggle(nil, false)
                end
            end,
            function()
                if autoFarmToggle then
                    autoFarmToggle:UpdateToggle(nil, false)
                end
            end,
        }

        runPresetSequence(steps)

        if presetKey == "auto1" then
            isAutoPreset1On = false
        else
            isAutoPreset2On = false
        end

        config.activePreset = "none"
        saveConfig()
    end)
end


-- ====== DAFTAR IDS ======
local rodIDs = {79, 76, 85, 76, 78, 4, 80, 6, 7, 5}
local baitIDs = {10, 2, 3, 6, 8, 15, 16}
local WeatherIDs = {"Cloudy", "Storm","Wind"}
local rodDatabase = {luck = 79,carbon = 76,grass = 85,demascus = 76,ice = 78,lucky = 4,midnight = 80,steampunk = 6,chrome = 7,astral = 5}
local BaitDatabase = {topwaterbait = 10,luckbait = 2,midnightbait = 3,chromabait = 6,darkmatterbait = 8,corruptbait = 15,aetherbait = 16}

-- ====== GRAPHICS OPTIMIZATION ======
local function optimizeGraphics()
    if renderingOptimized then
        print("🎨 Graphics already optimized, skipping...")
        return
    end

    print("🎨 Starting graphics optimization...")

    local success = pcall(function()
        -- Wait for services to be ready
        local RunService = game:GetService("RunService")
        local UserSettings = UserSettings()

        -- Set quality level to 1 (lowest)
        local renderSettings = settings().Rendering
        renderSettings.QualityLevel = Enum.QualityLevel.Level01
        print("  📊 Quality Level set to 1")

        -- Disable global shadows
        Lighting.GlobalShadows = false
        print("  🌑 Global Shadows disabled")

        -- Additional lighting optimizations
        Lighting.FogEnd = 9e9
        Lighting.FogStart = 9e9
        Lighting.Brightness = 0
        Lighting.Technology = Enum.Technology.Compatibility
        Lighting.ShadowSoftness = 0
        Lighting.EnvironmentDiffuseScale = 0
        Lighting.EnvironmentSpecularScale = 0
        print("  💡 Lighting optimized")

        -- Remove/disable lighting effects
        local effectsRemoved = 0
        for _, effect in pairs(Lighting:GetChildren()) do
            if effect:IsA("PostEffect") or effect:IsA("Atmosphere") or
               effect:IsA("Sky") or effect:IsA("Clouds") then
                pcall(function()
                    effect.Enabled = false
                    effectsRemoved = effectsRemoved + 1
                end)
            end
        end
        print("  🎭 " .. effectsRemoved .. " lighting effects disabled")

        -- Optimize terrain if available
        pcall(function()
            local terrain = workspace:FindFirstChild("Terrain")
            if terrain then
                terrain.WaterWaveSize = 0
                terrain.WaterWaveSpeed = 0
                terrain.WaterReflectance = 0
                terrain.WaterTransparency = 0
                print("  🌊 Water effects optimized")
            end
        end)

        -- Try to set FPS cap higher for better performance feedback
        pcall(function()
            if setfpscap then
                setfpscap(0) -- Unlimited FPS for better performance
                print("  ⚡ FPS cap removed")
            end
        end)

        renderingOptimized = true
        print("✅ Graphics optimization completed successfully!")

        return true
    end)

    if not success then
        warn("❌ Graphics optimization failed")
        renderingOptimized = false
    end
end

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
        local success, err = pcall(function()
            local replicatedStorage = game:GetService("ReplicatedStorage")
            if replicatedStorage then
                local directEvent = replicatedStorage.Packages._Index["sleitnick_net@0.2.0"].net["RF/PurchaseFishingRod"]
                if directEvent then
                    task.wait(0.5) -- Add delay to prevent rate limiting
                    directEvent:InvokeServer(rodDatabase)
                end
            end
        end)

        if not success then
            -- Check if it's an asset or network error
            if string.find(tostring(err):lower(), "asset is not approved") or
               string.find(tostring(err):lower(), "failed to load") or
               string.find(tostring(err):lower(), "network") then
                -- Silently continue
            else
                warn("[Purchase Rod] Error: " .. tostring(err))
            end
        end
    end
end

-- buy bait
local function buyBait(BaitDatabase)
    if purchaseBaitEvent then
        pcall(function()
            purchaseBaitEvent:InvokeServer(BaitDatabase)
        end)
    else
        local success, err = pcall(function()
            local replicatedStorage = game:GetService("ReplicatedStorage")
            if replicatedStorage then
                local directEvent = replicatedStorage.Packages._Index["sleitnick_net@0.2.0"].net["RF/PurchaseBait"]
                if directEvent then
                    task.wait(0.5) -- Add delay to prevent rate limiting
                    directEvent:InvokeServer(BaitDatabase)
                end
            end
        end)

        if not success then
            -- Check if it's an asset or network error
            if string.find(tostring(err):lower(), "asset is not approved") or
               string.find(tostring(err):lower(), "failed to load") or
               string.find(tostring(err):lower(), "network") then
                -- Silently continue
            else
                warn("[Purchase Bait] Error: " .. tostring(err))
            end
        end
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

-- ====== MEGALODON WEBHOOK ======
local lastWebhookTime = 0
local WEBHOOK_COOLDOWN = 15 -- 15 seconds cooldown between webhooks to prevent rate limiting
local webhookRetryDelay = 5 -- Base retry delay in seconds
local maxRetryAttempts = 3

-- ====== UNIFIED WEBHOOK CONFIGURATION ======
-- Set your Discord webhook URL here for all notifications (fish, megalodon, disconnect)
-- Example: "https://discord.com/api/webhooks/1234567890/abcdefghijklmnop"
local UNIFIED_WEBHOOK_URL = webhook2  -- PASTE YOUR DISCORD WEBHOOK URL HERE

-- ====== UNIFIED WEBHOOK FUNCTION ======
local function sendUnifiedWebhook(webhookType, data)
    -- Check if webhook URL is configured
    if not UNIFIED_WEBHOOK_URL or UNIFIED_WEBHOOK_URL == "" then
        warn('[Webhook] URL not configured! Please set UNIFIED_WEBHOOK_URL variable.')
        return
    end

    -- Rate limiting check
    local currentTime = tick()
    if currentTime - lastWebhookTime < WEBHOOK_COOLDOWN then
        print('[Webhook] Cooldown active, skipping...')
        return
    end

    local embed = {}

    -- Configure embed based on webhook type
    if webhookType == "megalodon_missing" then
        embed = {
            title = '[Megalodon] Event Missing',
            description = 'No Megalodon Hunt props detected in this server.',
            color = 16711680, -- Red
            fields = {
                { name = "👤 Player", value = (player.DisplayName or player.Name or "Unknown"), inline = true },
                { name = "🕒 Time", value = os.date("%H:%M:%S"), inline = true }
            },
            footer = { text = 'Megalodon Watch - Auto Fish' }
        }
    elseif webhookType == "fish_found" then
        embed = {
            title = "🎣 SECRET Fish Found",
            description = data.description or "Fish detected in inventory",
            color = 3066993, -- Blue-green
            fields = {
                { name = "🕒 Waktu",  value = os.date("%H:%M:%S"), inline = true },
                { name = "👤 Player", value = (player.DisplayName or player.Name or "Unknown"), inline = true },
                { name = "📦 Total (whitelist)", value = tostring(data.totalWhitelistCount or 0) .. " fish", inline = true },
            },
            footer = { text = "Inventory Notifier • Auto Fish" }
        }
    elseif webhookType == "disconnect" then
        embed = {
            title = "⚠️ Player Disconnected",
            description = data.reason or "Player has disconnected from the server",
            color = 16776960, -- Yellow
            fields = {
                { name = "👤 Player", value = (player.DisplayName or player.Name or "Unknown"), inline = true },
                { name = "🕒 Time", value = os.date("%H:%M:%S"), inline = true },
                { name = "🔌 Reason", value = data.reason or "Unknown", inline = false }
            },
            footer = { text = "Disconnect Notifier • Auto Fish Script" }
        }
    else
        warn('[Webhook] Unknown webhook type: ' .. tostring(webhookType))
        return
    end

    local body = HttpService:JSONEncode({ embeds = {embed} })

    -- Send webhook with exponential backoff retry logic
    task.spawn(function()
        local attempt = 1
        local success = false

        while attempt <= maxRetryAttempts and not success do
            local currentRetryDelay = webhookRetryDelay * (2 ^ (attempt - 1)) -- Exponential backoff

            if attempt > 1 then
                print('[Webhook] Retry attempt ' .. attempt .. ' after ' .. currentRetryDelay .. ' seconds...')
                task.wait(currentRetryDelay)
            end

            success, err = pcall(function()
                if syn and syn.request then
                    syn.request({ Url=UNIFIED_WEBHOOK_URL, Method="POST", Headers={["Content-Type"]="application/json"}, Body=body })
                elseif http_request then
                    http_request({ Url=UNIFIED_WEBHOOK_URL, Method="POST", Headers={["Content-Type"]="application/json"}, Body=body })
                elseif fluxus and fluxus.request then
                    fluxus.request({ Url=UNIFIED_WEBHOOK_URL, Method="POST", Headers={["Content-Type"]="application/json"}, Body=body })
                elseif request then
                    request({ Url=UNIFIED_WEBHOOK_URL, Method="POST", Headers={["Content-Type"]="application/json"}, Body=body })
                else
                    error("Executor tidak support HTTP requests")
                end
            end)

            if success then
                lastWebhookTime = tick()
                print('[Webhook] ' .. webhookType .. ' sent successfully on attempt ' .. attempt)
                break
            else
                warn('[Webhook] ' .. webhookType .. ' attempt ' .. attempt .. ' failed: ' .. tostring(err))

                -- Handle specific rate limiting errors
                if string.find(tostring(err):lower(), "429") or string.find(tostring(err):lower(), "rate") then
                    print('[Webhook] Rate limited detected, extending cooldown...')
                    lastWebhookTime = tick() + 60 -- Block webhooks for 60 seconds on rate limit
                    task.wait(60) -- Wait longer for rate limit recovery
                    break -- Don't retry immediately on rate limit
                elseif string.find(tostring(err):lower(), "network") or string.find(tostring(err):lower(), "timeout") then
                    print('[Webhook] Network error detected, will retry...')
                end

                attempt = attempt + 1
            end
        end

        if not success then
            warn('[Webhook] All ' .. webhookType .. ' attempts failed')
        end
    end)
end

-- Legacy function for compatibility
local sendMegalodonEventWebhook = function(status, data)
    if status == "missing" then
        sendUnifiedWebhook("megalodon_missing", data)
    end
end

local function autoDetectMegalodon()
    local eventFound = false
    local eventPosition = nil
    local debugMode = false -- Set to true for troubleshooting

    -- Search for Megalodon event in Workspace (handle multiple Props folders)
    for _, child in ipairs(workspace:GetChildren()) do
        -- Only check children named "Props" or "props" (case insensitive)
        if string.lower(child.Name) == "props" then
            if debugMode then
                print("[Megalodon Debug] Checking Props folder: " .. child.Name)
                for _, subChild in ipairs(child:GetChildren()) do
                    print("[Megalodon Debug] - Found: " .. subChild.Name)
                end
            end
            -- Try different variations of megalodon hunt naming
            local megalodonHunt = child:FindFirstChild("Megalodon Hunt") or
                                child:FindFirstChild("megalodon hunt") or
                                child:FindFirstChild("Megalodon_Hunt") or
                                child:FindFirstChild("megalodon_hunt") or
                                child:FindFirstChild("MegalodonHunt") or
                                child:FindFirstChild("megalodonh hunt")

            if megalodonHunt and megalodonHunt:FindFirstChild("Color") then
                eventPosition = megalodonHunt.Color.Position
                eventFound = true
                print("[Megalodon] Event found in: " .. child.Name .. "/" .. megalodonHunt.Name)
                break
            end
        end
    end

    -- Fallback: Search all children for any megalodon-related folders
    if not eventFound then
        for _, child in ipairs(workspace:GetChildren()) do
            if string.lower(child.Name) == "props" then
                -- Search all children of Props for megalodon-related items
                for _, subChild in ipairs(child:GetChildren()) do
                    if string.find(string.lower(subChild.Name), "megalodon") then
                        if subChild:FindFirstChild("Color") then
                            eventPosition = subChild.Color.Position
                            eventFound = true
                            print("[Megalodon] Fallback detection found in: " .. child.Name .. "/" .. subChild.Name)
                            break
                        end
                    end
                end
                if eventFound then break end
            end
        end
    end

    if eventFound and eventPosition then
        -- Mark event as active if not already
        if not megalodonEventActive then
            megalodonEventActive = true
            megalodonMissingAlertSent = false
            megalodonEventStartedAt = os.time()
            -- Event found - no webhook needed, just track it silently
        end

        if not hasTeleportedToMegalodon then
            teleportToMegalodon(eventPosition, true)
            task.wait(0.5)
            disableMegalodonLock()
        end
    else
        -- Handle event end
        local wasActive = megalodonEventActive
        if wasActive then
            megalodonEventActive = false
        end

        -- Return to saved position when event ends
        if hasTeleportedToMegalodon and megalodonSavedPosition then
            teleportToMegalodon(megalodonSavedPosition, false)
            megalodonSavedPosition = nil
            hasTeleportedToMegalodon = false

            -- Event ended - no webhook needed, just reset state silently
            if wasActive and not megalodonMissingAlertSent then
                megalodonMissingAlertSent = true
                megalodonEventStartedAt = 0
            end
        elseif not megalodonMissingAlertSent then
            -- Send webhook about missing event only once per session
            megalodonMissingAlertSent = true
            sendMegalodonEventWebhook("missing")
        end
    end
end

local function setAutoMegalodon(state)
    isAutoMegalodonOn = state
    updateConfigField("autoMegalodon", state)
    if not state then
        -- Reset megalodon state
        megalodonMissingAlertSent = false
        disableMegalodonLock()
        megalodonSavedPosition = nil
        hasTeleportedToMegalodon = false
        megalodonEventActive = false
        megalodonMissingAlertSent = false
        megalodonEventStartedAt = 0
    end
    print("🦈 Auto Megalodon Hunt: " .. (state and "ENABLED" or "DISABLED"))
end


-- ====== ENHANCED TOGGLE FUNCTIONS ======
local function setAutoFarm(state)
    isAutoFarmOn = state
    updateConfigField("autoFarm", state)
    
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
    updateConfigField("autoSell", state)
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
    updateConfigField("autoCatch", state)
    print("🎯 Auto Catch: " .. (state and "ENABLED" or "DISABLED"))
end

local function setAutoWeather(state)
    isAutoWeatherOn = state
    updateConfigField("autoWeather", state)
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
autoFarmToggle = SecMain:NewToggle("Auto Farm", "Auto equip rod + fishing (kombinasi)", function(state) 
    setAutoFarm(state) 
end)

autoSellToggle = SecMain:NewToggle("Auto Sell", "Auto jual hasil", function(state) 
    setSell(state) 
end)

autoCatchToggle = SecMain:NewToggle("Auto Catch", "Auto catch fish", function(state) 
    setAutoCatch(state) 
end)

autoPreset1Toggle = SecMain:NewToggle("Auto 1 (Auto Crater)", "Enable core auto features with 0.5s stagger then teleport to Crater Island", function(state)
    if state then
        enablePreset("auto1", "Crater Island")
    else
        disablePreset("auto1")
    end
end)

autoPreset2Toggle = SecMain:NewToggle("Auto 2 (Auto Sisyphus)", "Enable core auto features with 0.5s stagger then teleport to Sisyphus State", function(state)
    if state then
        enablePreset("auto2", "Sisyphus State")
    else
        disablePreset("auto2")
    end
end)

-- Other features
SecOther:NewToggle("Auto Upgrade Rod", "Auto upgrade rod", function(state) 
    setUpgrade(state) 
end)

SecOther:NewToggle("Auto Upgrade Bait", "Auto upgrade bait", function(state) 
    setUpgradeBait(state) 
end)

autoWeatherToggle = SecOther:NewToggle("Auto Weather", "Auto weather events", function(state) 
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
autoMegalodonToggle = SecOther:NewToggle("Auto Megalodon Hunt", "Auto teleport to Megalodon events", function(state) 
    setAutoMegalodon(state) 
end)

local function applyLoadedConfig()
    if config.activePreset == "none" then
        isApplyingConfig = true

        if config.autoFarm and autoFarmToggle then
            autoFarmToggle:UpdateToggle(nil, true)
        end
        if config.autoSell and autoSellToggle then
            autoSellToggle:UpdateToggle(nil, true)
        end
        if config.autoCatch and autoCatchToggle then
            autoCatchToggle:UpdateToggle(nil, true)
        end
        if config.autoWeather and autoWeatherToggle then
            autoWeatherToggle:UpdateToggle(nil, true)
        end
        if config.autoMegalodon and autoMegalodonToggle then
            autoMegalodonToggle:UpdateToggle(nil, true)
        end

        isApplyingConfig = false
        syncConfigFromStates()
        saveConfig()
    end

    if config.activePreset == "auto1" and autoPreset1Toggle then
        autoPreset1Toggle:UpdateToggle(nil, true)
    elseif config.activePreset == "auto2" and autoPreset2Toggle then
        autoPreset2Toggle:UpdateToggle(nil, true)
    end
end

task.defer(applyLoadedConfig)


-- ====== PERFORMANCE TAB ======
local TabPerformance = Window:NewTab("Performance")
local SecGPU = TabPerformance:NewSection("GPU Saver Mode")
local SecNotif = TabPerformance:NewSection("Notification Control")

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

-- Add graphics optimization controls
SecGPU:NewButton("Optimize Graphics Now", "Manually trigger graphics optimization", function()
    renderingOptimized = false -- Reset flag to allow re-optimization
    optimizeGraphics()
end)

SecGPU:NewButton("Check Graphics Status", "Show current graphics optimization status", function()
    if renderingOptimized then
        print("✅ Graphics are optimized")
        print("📊 Current Quality Level: " .. tostring(settings().Rendering.QualityLevel))
        print("🌑 Global Shadows: " .. tostring(Lighting.GlobalShadows))
    else
        print("❌ Graphics are not optimized")
        print("💡 Click 'Optimize Graphics Now' to optimize")
    end
end)

-- Fish notification controls
SecNotif:NewToggle("Disable Fish Notifications", "Remove new fish notification popups", function(state)
    if state then
        disableFishNotifications()
    else
        enableFishNotifications()
    end
end)

SecNotif:NewButton("Check Notification Status", "Show current notification status", function()
    if isFishNotificationDisabled then
        print("🔇 Fish notifications are DISABLED")
        print("📋 Destroyed events: " .. table.concat({"RE/ObtainedNewFishNotification", "RE/ShowNotification", "RE/PlaySound"}, ", "))
    else
        print("🔊 Fish notifications are ENABLED")
        print("💡 Toggle 'Disable Fish Notifications' to remove popups")
    end
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

SecUI:NewButton("Minimize UI", "Hide the interface", function()
    minimizeUI()
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

-- Enhanced Auto Farm Loop (combines equip + fishing) with asset error protection
task.spawn(function()
    while true do
        if isAutoFarmOn then
            local success, err = pcall(function()
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

            if not success then
                -- Check if it's an asset loading error
                if string.find(tostring(err):lower(), "asset is not approved") or
                   string.find(tostring(err):lower(), "failed to load sound") or
                   string.find(tostring(err):lower(), "rbxassetid") then
                    -- Silently continue, don't spam console
                else
                    warn("[Auto Farm] Loop error: " .. tostring(err))
                end
            end
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

-- Auto Megalodon Hunt Loop with enhanced error protection
task.spawn(function()
    while true do
        if isAutoMegalodonOn then
            local success, err = pcall(function()
                autoDetectMegalodon()
            end)

            if not success then
                -- Check if it's an asset loading error
                if string.find(tostring(err):lower(), "asset is not approved") or
                   string.find(tostring(err):lower(), "failed to load sound") then
                    -- Silently continue, don't spam console
                else
                    warn("[Megalodon] Loop error: " .. tostring(err))
                end
            end
        end
        task.wait(8) -- Check every 8 seconds
    end
end)


-- Inventory Whitelist Notifier (mutations-aware, single message per loop)
-- Counts by species (Tile.ItemName), shows pretty display (Variant + Base when available)

-- ============ CONFIG ============
-- Note: Now using unified webhook system - no separate URL needed

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
local GuiService = game:GetService("GuiService")


local hasSentDisconnectWebhook = false  -- Flag untuk avoid kirim berulang
local PING_THRESHOLD = 1000  -- ms, jika > ini = poor connection
local FREEZE_THRESHOLD = 3  -- detik, jika delta > ini = freeze

local hasSentDisconnectWebhook = false  -- Flag untuk avoid kirim berulang
local player = Players.LocalPlayer
-- ============ UTIL ============
local function trim(s) return (s or ""):gsub("^%s+",""):gsub("%s+$","") end
local function normSpaces(s) return trim((s or ""):gsub("%s+"," ")) end
local function toKey(s) return string.lower(normSpaces(s or "")) end
local WL = {}; for _, n in ipairs(WHITELIST) do WL[toKey(n)] = true end
local function dprint(...) if DEBUG then print("[INV-DEBUG]", ...) end end

-- ============ WEBHOOK ============
local function sendDiscordEmbed(description, totalWhitelistCount)
    sendUnifiedWebhook("fish_found", {
        description = description,
        totalWhitelistCount = totalWhitelistCount
    })
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

    -- Kick controller agar tile di-render (aman dipanggil berulang) dengan network error protection
    pcall(function()
        local controllers = ReplicatedStorage:FindFirstChild("Controllers")
        if controllers then
            local invModule = controllers:FindFirstChild("InventoryController")
            if invModule then
                local success, ctrl = pcall(require, invModule)
                if success and ctrl then
                    -- Add delays between calls to prevent rate limiting cascade failures
                    if ctrl.SetPage then
                        pcall(ctrl.SetPage, "Fish")
                        task.wait(0.1) -- Small delay to prevent overwhelming requests
                    end
                    if ctrl.SetCategory then
                        pcall(ctrl.SetCategory, "Fish")
                        task.wait(0.1)
                    end
                    if ctrl._bindFishes then
                        pcall(ctrl._bindFishes)
                        task.wait(0.1)
                    end
                    if ctrl.RefreshInventory then
                        pcall(ctrl.RefreshInventory)
                        task.wait(0.1)
                    end
                    if ctrl.UpdateInventory then
                        pcall(ctrl.UpdateInventory)
                        task.wait(0.1)
                    end
                    if ctrl.LoadInventory then
                        pcall(ctrl.LoadInventory)
                    end
                else
                    warn("[Auto Fish] Failed to require InventoryController - network issues may be present")
                end
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

-- ============ DISCONNECT NOTIFIER ============

local function sendDisconnectWebhook(username, reason)
    if hasSentDisconnectWebhook then return end
    hasSentDisconnectWebhook = true

    sendUnifiedWebhook("disconnect", {
        reason = reason or "Unknown"
    })
end

local function setupDisconnectNotifier()
    local username = Players.LocalPlayer.Name  -- Atau DisplayName jika mau
    
    -- Kode lama: Error message dan PlayerRemoving
    GuiService.ErrorMessageChanged:Connect(function(message)
        local lowerMessage = string.lower(message)
        local reason = "Unknown"
        if lowerMessage:find("disconnect") or lowerMessage:find("connection lost") then
            reason = "Connection Lost: " .. message
        elseif lowerMessage:find("kick") or lowerMessage:find("banned") then
            reason = "Kicked: " .. message
        elseif lowerMessage:find("timeout") then
            reason = "Timeout: " .. message
        elseif lowerMessage:find("error") then
            reason = "General Error: " .. message
        else
            return
        end
        task.spawn(function() sendDisconnectWebhook(username, reason) end)
    end)
    
    Players.PlayerRemoving:Connect(function(removedPlayer)
        if removedPlayer == Players.LocalPlayer and not hasSentDisconnectWebhook then
            task.spawn(function() sendDisconnectWebhook(username, "Disconnected (Player Removed)") end)
        end
    end)
    
    -- Baru: Loop check ping untuk internet loss
    task.spawn(function()
        while true do
            local success, ping = pcall(function()
                return Players.LocalPlayer:GetNetworkPing()
            end)
            if not success or ping > PING_THRESHOLD then
                local reason = not success and "Connection Lost (Ping Failed)" or "High Ping Detected (" .. ping .. "ms)"
                task.spawn(function() sendDisconnectWebhook(username, reason) end)
                break  -- Stop loop setelah kirim
            end
            task.wait(5)  -- Check setiap 5 detik
        end
    end)
    
    -- Baru: Detect freeze via Stepped delta
    local lastTime = tick()
    RunService.Stepped:Connect(function(_, delta)
        if delta > FREEZE_THRESHOLD then
            task.spawn(function() sendDisconnectWebhook(username, "Game Freeze Detected (Delta: " .. delta .. "s)") end)
        end
        lastTime = tick()
    end)
    
    print("🚨 Advanced disconnect notifier setup complete")
end

-- Panggil setup
setupDisconnectNotifier()

-- ============ SCRIPT INITIALIZATION ============
print("🚀 Auto Fish v5.1.1 - Enhanced Edition Starting...")

-- Optimize graphics immediately when script starts
print("🎨 Initializing graphics optimization...")
task.spawn(function()
    -- Wait for game to fully load
    local Players = game:GetService("Players")
    local LocalPlayer = Players.LocalPlayer

    -- Wait for character to spawn
    if LocalPlayer.Character then
        task.wait(1)
    else
        LocalPlayer.CharacterAdded:Wait()
        task.wait(2)
    end

    -- Now optimize graphics
    optimizeGraphics()
end)

-- ============ LOOP ============
print("🚀 Inventory Whitelist Notifier (mutation-aware) start...")
baselineNow()

while true do
    scanAndNotifySingle()
    task.wait(COOLDOWN)
end
