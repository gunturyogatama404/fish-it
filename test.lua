-- ====== SCRIPT INITIALIZATION SAFETY CHECK ======
print("🚀 [Auto Fish] Script loading initiated...")

-- Critical dependency validation
local success, errorMsg = pcall(function()
    -- Validate critical services
    local services = {
        game = game,
        workspace = workspace,
        Players = game:GetService("Players"),
        RunService = game:GetService("RunService"),
        ReplicatedStorage = game:GetService("ReplicatedStorage"),
        HttpService = game:GetService("HttpService")
    }

    for serviceName, service in pairs(services) do
        if not service then
            error("Critical service missing: " .. serviceName)
        end
    end

    -- Validate LocalPlayer
    local LocalPlayer = game:GetService("Players").LocalPlayer
    if not LocalPlayer then
        error("LocalPlayer not available")
    end

    print("✅ [Auto Fish] Core dependencies validated")
    return true
end)

if not success then
    error("❌ [Auto Fish] Critical dependency check failed: " .. tostring(errorMsg))
    return
end

-- ====== ERROR HANDLING SETUP ======
-- Suppress asset loading errors (like sound approval issues)
local function suppressAssetErrors()
    local oldWarn = warn
    local oldError = error

    warn = function(...)
        local message = tostring(...)
        if string.find(message:lower(), "asset is not approved") or
           string.find(message:lower(), "failed to load sound") or
           string.find(message:lower(), "rbxassetid") then
            return
        end
        oldWarn(...)
    end

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

-- Apply error suppression
local suppressSuccess = pcall(suppressAssetErrors)
if suppressSuccess then
    print("✅ [Auto Fish] Error suppression enabled")
else
    warn("⚠️ [Auto Fish] Error suppression setup failed")
end

-- ====== AUTOMATIC PERFORMANCE OPTIMIZATION ======
local function ultimatePerformance()
    local workspace = game:GetService("Workspace")
    local lighting = game:GetService("Lighting")
    pcall(function()
        local terrain = workspace:FindFirstChild("Terrain")
        if terrain then
            if terrain:FindFirstChild("Clouds") then terrain.Clouds:Destroy() end
            terrain.WaterWaveSize = 0
            terrain.WaterWaveSpeed = 0
            terrain.WaterReflectance = 0
            terrain.WaterTransparency = 0
        end
        lighting.GlobalShadows = false
        lighting.FogEnd = 9e9
        lighting.Brightness = 0
        lighting.Technology = Enum.Technology.Compatibility
        for _, effect in pairs(lighting:GetChildren()) do
            if effect:IsA("PostEffect") or effect:IsA("Atmosphere") or effect:IsA("Sky") or effect:IsA("Clouds") then
                effect:Destroy()
            end
        end
    end)
    print("🚀 [Auto Fish] Graphics optimized for better performance")
end

-- Safe execution of performance optimization
local perfSuccess = pcall(ultimatePerformance)
if perfSuccess then
    print("✅ [Auto Fish] Performance optimization applied")
else
    warn("⚠️ [Auto Fish] Performance optimization failed, continuing...")
end

-- ====================================================================
--                        WEBHOOK CONFIGURATION
-- ====================================================================
--[[
IMPORTANT: Configure your webhooks before running this script!

Required webhook variables (set these in your main.lua or loadstring):
- webhook2: Main webhook for fish notifications and general alerts
- webhook3: Dedicated webhook for connection status (Connect/Disconnect/Online Status)

Example usage in your main.lua:
webhook2 = "https://discord.com/api/webhooks/YOUR_MAIN_WEBHOOK_URL"
webhook3 = "https://discord.com/api/webhooks/YOUR_CONNECTION_WEBHOOK_URL"

Webhook Usage:
- webhook2: Fish notifications, megalodon alerts
- webhook3: Connection status and online monitoring

🆕 NEW ONLINE STATUS SYSTEM Features:
🟢 SMART MESSAGE EDITING: Each account gets its own message that updates every 8 seconds
📝 PERSISTENT MESSAGE ID: Message IDs are saved and reused across sessions
⏰ REAL-TIME UPDATES: Shows uptime, fish count, coins, level with live timestamps
🔄 AUTO RECOVERY: Creates new message if old one becomes invalid
📊 RICH STATUS INFO: Displays comprehensive player statistics
🔴 OFFLINE DETECTION: Automatically updates message to offline when disconnected

Traditional Connection Features (still active):
✅ Sends "Player Connected" when script starts successfully
❌ Sends "Player Disconnected" with detailed reason when issues occur
📊 Includes session duration, ping monitoring, and freeze detection

Note: All status notifications are sent to webhook3 only
--]]

-- ====================================================================
--                        MODUL-MODUL UTAMA
-- ====================================================================

--[[------------------------------------------------------------------
    MODULE: Lightweight Background Inventory v2.0
    Tujuan: Menjaga inventory tiles tetap ada dengan overhead minimal.
--------------------------------------------------------------------]]
local LightweightInventory = {}
do
    local Players = game:GetService("Players")
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local LocalPlayer = Players.LocalPlayer

    local inventoryController = nil
    local originalDestroyTiles = nil
    local isInventoryHooked = false
    local isLoading = false

    local function getInventoryController()
        if inventoryController then return inventoryController end
        local success, result = pcall(function()
            local controllers = ReplicatedStorage:WaitForChild("Controllers", 5)
            local invModule = controllers:WaitForChild("InventoryController", 5)
            return require(invModule)
        end)
        if success then
            inventoryController = result
            return inventoryController
        end
        return nil
    end

    local function hookInventoryController()
        if isInventoryHooked then return true end
        local ctrl = getInventoryController()
        if not ctrl then return false end
        originalDestroyTiles = ctrl.DestroyTiles
        ctrl.DestroyTiles = function() return end
        isInventoryHooked = true
        print("[Inv] Controller hooked. Tile destruction prevented.")
        return true
    end

    local function refreshInventoryTiles(onCompleteCallback)
        if isLoading then return end
        isLoading = true
        local ctrl = getInventoryController()
        if ctrl and ctrl.InventoryStateChanged then
            pcall(function() ctrl.InventoryStateChanged:Fire("Fish") end)
        end
        task.wait()
        if onCompleteCallback then pcall(onCompleteCallback) end
        isLoading = false
    end

    local function initialLoadInventoryTiles(onCompleteCallback)
        if isLoading then return end
        isLoading = true
        local ctrl = getInventoryController()
        if not ctrl then isLoading = false; return end

        local playerGui = LocalPlayer:WaitForChild("PlayerGui")
        local inventoryGUI = playerGui:FindFirstChild("Inventory")
        local mainFrame = inventoryGUI and inventoryGUI:FindFirstChild("Main")

        if not mainFrame then isLoading = false; return end

        local previousEnabled = inventoryGUI.Enabled
        local previousVisible = mainFrame.Visible

        inventoryGUI.Enabled = true
        mainFrame.Visible = true
        task.wait(0.2)

        pcall(function()
            if ctrl.SetPage then ctrl.SetPage(ctrl, "Items") end
            if ctrl.SetCategory then ctrl.SetCategory(ctrl, "Fishes") end
            if ctrl.InventoryStateChanged then ctrl.InventoryStateChanged:Fire("Fish") end
        end)

        task.wait(0.5)
        inventoryGUI.Enabled = previousEnabled
        mainFrame.Visible = previousVisible
        print("[Inv] Initial load complete.")
        if onCompleteCallback then pcall(onCompleteCallback) end
        isLoading = false
    end

    function LightweightInventory.start(onRefreshCallback)
        if isInventoryHooked then return end
        print("[Inv] Starting Background Inventory v2.0...")
        task.spawn(function()
            if hookInventoryController() then
                task.wait(1)
                initialLoadInventoryTiles(onRefreshCallback)

                pcall(function()
                    local GuiControl = require(ReplicatedStorage:WaitForChild("Modules"):WaitForChild("GuiControl"))
                    local invGUI = LocalPlayer.PlayerGui:FindFirstChild("Inventory")
                    GuiControl.GuiUnfocusedSignal:Connect(function(closedGui)
                        if closedGui == invGUI then task.delay(0.5, function() refreshInventoryTiles(onRefreshCallback) end) end
                    end)
                    print("[Inv] Listening for manual-close.")
                end)

                pcall(function()
                    local fishCaughtEvent = ReplicatedStorage.Packages._Index["sleitnick_net@0.2.0"].net:WaitForChild("RE/FishCaught")
                    fishCaughtEvent.OnClientEvent:Connect(function()
                        task.delay(1, function() refreshInventoryTiles(onRefreshCallback) end)
                    end)
                    print("[Inv] Listening for new fish.")
                end)
            end
        end)
    end
end

--[[------------------------------------------------------------------
    MODULE: Discord Notifier
    Tujuan: Mengirim notifikasi ke Discord untuk item whitelist.
--------------------------------------------------------------------]]
local DiscordNotifier = {}
do
    local HttpService = game:GetService("HttpService")
    local Players = game:GetService("Players")
    local LocalPlayer = Players.LocalPlayer

    -- Use webhook2 from main.lua if available, otherwise use fallback
    local WEBHOOK_URL = webhook2

    local CONFIG = {
        WEBHOOK_URL = WEBHOOK_URL,
        WHITELIST = {
            ["Megalodon"] = true,
            ["Blob Shark"] = true,
            ["Plasma Shark"] = true,
            ["Frostborn Shark"] = true,
            ["Giant Squid"] = true,
            ["Ghost Shark"] = true,
            ["Robot Kraken"] = true,
            ["Thin Armor Shark"] = true
        },
        COOLDOWN_SECONDS = 1,
        
        -- =======================================================================
        -- PENTING: Ganti URL di bawah ini dengan URL gambar dari GitHub Anda!
        -- =======================================================================
        -- Anda BISA menggunakan link GitHub biasa (contoh: https://github.com/user/repo/blob/main/image.png)
        -- Skrip akan otomatis mengubahnya ke format yang benar.
        FISH_IMAGES = {
            ["Megalodon"] = "https://github.com/DarylLoudi/fish-it/blob/main/Megalodon.png",
            ["Blob Shark"] = "https://github.com/DarylLoudi/fish-it/blob/main/blob.png",
            ["Frostborn Shark"] = "https://github.com/DarylLoudi/fish-it/blob/main/frost.png",
            ["Giant Squid"] = "https://github.com/DarylLoudi/fish-it/blob/main/gsquid.png",
            ["Ghost Shark"] = "https://github.com/DarylLoudi/fish-it/blob/main/ghost.png",
            ["Robot Kraken"] = "https://github.com/DarylLoudi/fish-it/blob/main/kraken.png"
        }
    }

    local trackedItemCounts = {}
    local isInitialScan = true
    local lastWebhookTime = 0

    -- Fungsi untuk mengubah link GitHub biasa menjadi link raw
    local function convertToRawGitHubUrl(url)
        if url and type(url) == "string" and url:match("github.com") and url:match("/blob/") then
            local rawUrl = url:gsub("github.com", "raw.githubusercontent.com")
            rawUrl = rawUrl:gsub("/blob/", "/")
            return rawUrl
        end
        -- Kembalikan URL asli jika bukan format yang diharapkan
        return url
    end

    local function sendNotification(itemData, amount)
        if not WEBHOOK_URL or WEBHOOK_URL == "PASTE_YOUR_WEBHOOK_URL_HERE" then return end
        if tick() - lastWebhookTime < CONFIG.COOLDOWN_SECONDS then return end

        local embed = {
            title = "🎣 Item Langka Ditemukan!",
            description = string.format("**+%d %s** telah ditambahkan ke inventory.", amount, itemData.fullName),
            color = 3066993,
            fields = {
                { name = "👤 Player", value = LocalPlayer.Name, inline = true },
                { name = "🐠 Fish", value = itemData.fullName, inline = true },
                { name = "⚖️ Weight", value = itemData.weight, inline = true },
                { name = "✨ Mutation", value = itemData.mutation, inline = true },
                { name = "🕒 Waktu", value = os.date("%H:%M:%S"), inline = false }
            },
            footer = { text = "Inventory Notifier" }
        }

        -- Ambil URL gambar dari konfigurasi menggunakan nama dasar
        local imageUrl = CONFIG.FISH_IMAGES[itemData.baseName]
        if imageUrl and imageUrl ~= "" then
            local rawImageUrl = convertToRawGitHubUrl(imageUrl)
            embed.thumbnail = { url = rawImageUrl }
        else
            print("[Notifier] Peringatan: Tidak ada URL gambar untuk item '" .. itemData.baseName .. "' di CONFIG.FISH_IMAGES.")
        end

        local payload = { embeds = {embed} }
        pcall(function()
            local req = (syn and syn.request) or http_request
            if req then
                req({ Url=WEBHOOK_URL, Method="POST", Headers={["Content-Type"]="application/json"}, Body=HttpService:JSONEncode(payload) })
                lastWebhookTime = tick()
                print("[Notifier] Sent notification for: " .. itemData.fullName)
            end
        end)
    end

    function DiscordNotifier.scanInventory()
        local playerGui = LocalPlayer:FindFirstChild("PlayerGui")
        local invContainer = playerGui and playerGui:FindFirstChild("Inventory")
        invContainer = invContainer and invContainer:FindFirstChild("Main")
        invContainer = invContainer and invContainer:FindFirstChild("Content")
        invContainer = invContainer and invContainer:FindFirstChild("Pages")
        invContainer = invContainer and invContainer:FindFirstChild("Inventory")
        if not invContainer then return end

        local currentItemCounts = {}
        for _, tile in ipairs(invContainer:GetChildren()) do
            if tile.Name == "Tile" and tile:FindFirstChild("ItemName") then
                local fullName = tile.ItemName.Text
                
                -- Lakukan pengecekan parsial terhadap whitelist
                for baseName, _ in pairs(CONFIG.WHITELIST) do
                    if string.find(fullName, baseName) then
                        -- Item ada di whitelist, kumpulkan data lengkap
                        local weight = "N/A"
                        if tile:FindFirstChild("WeightFrame") and tile.WeightFrame:FindFirstChild("Weight") then
                            weight = tile.WeightFrame.Weight.Text
                        end
                        
                        local mutation = "None"
                        if tile:FindFirstChild("Variant") and tile.Variant:FindFirstChild("ItemName") then
                            local mutationText = tile.Variant.ItemName.Text
                            if mutationText ~= "Ghoulish" then
                                mutation = mutationText
                            end
                        end

                        local itemKey = fullName .. "_" .. weight .. "_" .. mutation
                        
                        currentItemCounts[itemKey] = {
                            count = (currentItemCounts[itemKey] and currentItemCounts[itemKey].count or 0) + 1,
                            data = {
                                fullName = fullName,
                                baseName = baseName,
                                weight = weight,
                                mutation = mutation
                            }
                        }
                        break -- Hentikan loop jika sudah ketemu match
                    end
                end
            end
        end

        if isInitialScan then
            trackedItemCounts = currentItemCounts
            isInitialScan = false
            print("[Notifier] Initial scan complete. Monitoring for new items.")
            return
        end

        for itemKey, currentItem in pairs(currentItemCounts) do
            local previousCount = (trackedItemCounts[itemKey] and trackedItemCounts[itemKey].count) or 0
            if currentItem.count > previousCount then
                sendNotification(currentItem.data, currentItem.count - previousCount)
            end
        end

        trackedItemCounts = currentItemCounts
    end
end

-- ====================================================================
--                        INISIALISASI & SISA SCRIPT
-- ====================================================================

-- Initialize inventory and notifier systems after game is ready
print("⏳ [Auto Fish] Initializing inventory system...")
task.wait(5)

local invSuccess = pcall(function()
    LightweightInventory.start(DiscordNotifier.scanInventory)
end)

if invSuccess then
    print("✅ [Auto Fish] Inventory system loaded")
else
    warn("⚠️ [Auto Fish] Inventory system failed to load")
end

-- Sisa script zfish v6.2.lua...
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
local startTime = os.time() -- Using os.time() for stable uptime calculation
local sessionStats = {
    totalFish = 0,
    totalValue = 0,
    bestFish = {name = "None", value = 0},
    fishTypes = {}
}

-- ====== FPS TRACKING VARIABLES ====== 
local RunService = game:GetService("RunService")
local frameCount = 0
local lastFPSUpdate = tick()
local currentFPS = 0

-- FPS Counter function
local function updateFPS()
    frameCount = frameCount + 1
    local currentTime = tick()

    if currentTime - lastFPSUpdate >= 1 then
        currentFPS = frameCount
        frameCount = 0
        lastFPSUpdate = currentTime
    end
end

-- Connect FPS counter to heartbeat
RunService.Heartbeat:Connect(updateFPS)

-- Database ikan lengkap
local fishDatabase = {
    [163] = {name = "Viperfish", sellPrice = 94}
}
-- State variables
local isAutoFarmOn = false
local isAutoSellOn = false
local isAutoCatchOn = false
local isAutoWeatherOn = false
local gpuSaverEnabled = false
local isAutoMegalodonOn = false
local megalodonSavedPosition = nil -- Will store full CFrame (position + orientation)
local hasTeleportedToMegalodon = false
local currentBodyPosition = nil

local isAutoPreset1On = false
local isAutoPreset2On = false
local isAutoPreset3On = false

-- Megalodon event variables
local megalodonEventActive = false
local megalodonMissingAlertSent = false
local megalodonEventStartedAt = 0
local megalodonEventEndAlertSent = false
local megalodonPreEventFarmState = nil

local HttpService = game:GetService("HttpService")

-- Config folder constant
local CONFIG_FOLDER = "ConfigFishIt"

-- Function to ensure config folder exists
local function ensureConfigFolder()
    if not isfolder then
        warn("[Config] Folder functions not available")
        return false
    end

    if not isfolder(CONFIG_FOLDER) then
        local success = pcall(function()
            makefolder(CONFIG_FOLDER)
        end)

        if success then
            print("[Config] Created config folder: " .. CONFIG_FOLDER)
            return true
        else
            warn("[Config] Failed to create config folder")
            return false
        end
    end

    return true
end

-- Dynamic config file based on player username
local function getConfigFileName()
    local playerName = LocalPlayer.Name or "Unknown"
    local userId = LocalPlayer.UserId or 0
    -- Sanitize filename by removing invalid characters
    playerName = playerName:gsub("[<>:\"/\\|?*]", "_")
    -- Use both username and userId for unique identification
    local fileName = "auto_fish_v58_config_" .. playerName .. "_" .. userId .. ".json"
    return CONFIG_FOLDER .. "/" .. fileName
end
local defaultConfig = {
    autoFarm = false,
    autoSell = false,
    autoCatch = false,
    autoWeather = false,
    autoMegalodon = false,
    activePreset = "none",
    gpuSaver = false,
    chargeFishingDelay = 0.01,
    autoFishMainDelay = 0.9,
    autoSellDelay = 45,
    autoCatchDelay = 0.2,
    weatherIdDelay = 33,
    weatherCycleDelay = 100
}
local config = {}
for key, value in pairs(defaultConfig) do
    config[key] = value
end

local isApplyingConfig = false

local function validateConfigStructure(loadedConfig)
    -- Ensure all required fields exist with proper defaults
    local validatedConfig = {}

    for key, defaultValue in pairs(defaultConfig) do
        if loadedConfig[key] ~= nil then
            -- Validate data type matches default
            if type(loadedConfig[key]) == type(defaultValue) then
                validatedConfig[key] = loadedConfig[key]
            else
                print("Warning: Config field '" .. key .. "' has wrong type, using default")
                validatedConfig[key] = defaultValue
            end
        else
            validatedConfig[key] = defaultValue
        end
    end

    return validatedConfig
end

local function saveConfig()
    if not writefile then
        print("[Config] Write function not available")
        return
    end

    -- Ensure config folder exists
    if not ensureConfigFolder() then
        warn("[Config] Cannot create config folder, save aborted")
        return
    end

    local success, encoded = pcall(function()
        return HttpService:JSONEncode(config)
    end)

    if success then
        local configFile = getConfigFileName()
        local writeSuccess = pcall(function()
            writefile(configFile, encoded)
        end)

        if writeSuccess then
            print("[Config] Successfully saved config for player: " .. LocalPlayer.Name)
            print("[Config] Saved to: " .. configFile)
        else
            warn("[Config] Failed to write config file")
        end
    else
        warn("[Config] Failed to encode config to JSON")
    end
end

local function loadConfig()
    if not readfile or not isfile then
        print("[Config] File system not available, using defaults")
        config = {}
        for key, value in pairs(defaultConfig) do
            config[key] = value
        end
        return
    end

    -- Ensure config folder exists
    ensureConfigFolder()

    local configFile = getConfigFileName()
    print("[Config] Loading from: " .. configFile)

    local success, content = pcall(function()
        if isfile(configFile) then
            return readfile(configFile)
        end
        return nil
    end)

    if success and content and content ~= "" then
        local ok, decoded = pcall(function()
            return HttpService:JSONDecode(content)
        end)

        if ok and type(decoded) == "table" then
            print("[Config] Successfully loaded config for player: " .. LocalPlayer.Name)
            config = validateConfigStructure(decoded)
        else
            print("[Config] Failed to decode JSON, using defaults")
            config = {}
            for key, value in pairs(defaultConfig) do
                config[key] = value
            end
        end
    else
        print("[Config] No existing config found for player: " .. LocalPlayer.Name .. ", creating new one")
        config = {}
        for key, value in pairs(defaultConfig) do
            config[key] = value
        end
    end

    -- Always save after loading to ensure file exists and is up to date
    saveConfig()
end

local function migrateOldConfig()
    -- Check for old config file format and migrate if found
    if not readfile or not isfile then return end

    -- Check for old format files (both with and without UserID)
    local playerName = (LocalPlayer.Name or "Unknown"):gsub("[<>:\"/\\|?*]", "_")
    local userId = LocalPlayer.UserId or 0

    local oldConfigFiles = {
        "auto_fish_v58_config_" .. playerName .. ".json", -- Very old format
        "auto_fish_v58_config_" .. playerName .. "_" .. userId .. ".json" -- Previous format (without folder)
    }

    for _, oldConfigFile in ipairs(oldConfigFiles) do
        if isfile(oldConfigFile) then
            print("[Config] Found old config format, migrating: " .. oldConfigFile)

            local success, content = pcall(function()
                return readfile(oldConfigFile)
            end)

            if success and content and content ~= "" then
                local ok, decoded = pcall(function()
                    return HttpService:JSONDecode(content)
                end)

                if ok and type(decoded) == "table" then
                    -- Migrate to new format (with folder)
                    config = validateConfigStructure(decoded)
                    saveConfig()

                    -- Optionally delete old file
                    pcall(function()
                        if delfile then
                            delfile(oldConfigFile)
                            print("[Config] Old config file deleted after migration: " .. oldConfigFile)
                        end
                    end)

                    print("[Config] Migration completed successfully")
                    return true
                end
            end
        end
    end

    return false
end

local function updateConfigField(key, value)
    if defaultConfig[key] == nil then
        warn("[Config] Attempted to set unknown config field: " .. tostring(key))
        return
    end

    if type(value) ~= type(defaultConfig[key]) then
        warn("[Config] Type mismatch for field '" .. tostring(key) .. "'. Expected " .. type(defaultConfig[key]) .. ", got " .. type(value))
        return
    end

    config[key] = value
    if not isApplyingConfig then
        local success = pcall(saveConfig)
        if not success then
            warn("[Config] Failed to save config after updating field: " .. tostring(key))
        end
    end
end

local function syncConfigFromStates()
    config.autoFarm = isAutoFarmOn
    config.autoSell = isAutoSellOn
    config.autoCatch = isAutoCatchOn
    config.autoWeather = isAutoWeatherOn
    config.autoMegalodon = isAutoMegalodonOn
    config.gpuSaver = gpuSaverEnabled
    config.chargeFishingDelay = chargeFishingDelay
    config.autoFishMainDelay = autoFishMainDelay
    config.autoSellDelay = autoSellDelay
    config.autoCatchDelay = autoCatchDelay
    config.weatherIdDelay = weatherIdDelay
    config.weatherCycleDelay = weatherCycleDelay
end

local function applyDelayConfig()
    if not config then
        return
    end

    local previousState = isApplyingConfig
    local updated = false
    isApplyingConfig = true

    local function applyField(field, minValue, defaultValue)
        local value = tonumber(config[field])
        if value == nil then
            value = defaultValue
            updated = true
        end
        local clamped = math.max(minValue, value)
        if clamped ~= value then
            updated = true
        end
        config[field] = clamped
        return clamped
    end

    chargeFishingDelay = applyField("chargeFishingDelay", 0.1, defaultConfig.chargeFishingDelay)
    autoFishMainDelay = applyField("autoFishMainDelay", 0.1, defaultConfig.autoFishMainDelay)
    autoSellDelay = applyField("autoSellDelay", 36, defaultConfig.autoSellDelay)
    autoCatchDelay = applyField("autoCatchDelay", 0.1, defaultConfig.autoCatchDelay)
    weatherIdDelay = applyField("weatherIdDelay", 1, defaultConfig.weatherIdDelay)
    weatherCycleDelay = applyField("weatherCycleDelay", 35, defaultConfig.weatherCycleDelay)

    if updated then
        pcall(saveConfig)
    end

    isApplyingConfig = previousState
    print("[Config] Delay settings applied from config")
end

local function roundDelay(value)
    return math.floor(value * 100 + 0.5) / 100
end

local function setChargeFishingDelay(value)
    local numeric = tonumber(value) or chargeFishingDelay
    local clamped = math.max(0.01, numeric)
    clamped = roundDelay(clamped)
    if math.abs(clamped - chargeFishingDelay) < 0.001 then
        return
    end
    chargeFishingDelay = clamped
    updateConfigField("chargeFishingDelay", clamped)
    print(string.format("[Delays] Charge Fishing Delay: %.2fs", clamped))
end

local function setAutoFishMainDelay(value)
    local numeric = tonumber(value) or autoFishMainDelay
    local clamped = math.max(0.1, numeric)
    clamped = roundDelay(clamped)
    if math.abs(clamped - autoFishMainDelay) < 0.001 then
        return
    end
    autoFishMainDelay = clamped
    updateConfigField("autoFishMainDelay", clamped)
    print(string.format("[Delays] Auto Fish Main Delay: %.2fs", clamped))
end

local function setAutoSellDelay(value)
    local numeric = tonumber(value) or autoSellDelay
    local clamped = math.max(1, numeric)
    clamped = roundDelay(clamped)
    if math.abs(clamped - autoSellDelay) < 0.001 then
        return
    end
    autoSellDelay = clamped
    updateConfigField("autoSellDelay", clamped)
    print(string.format("[Delays] Auto Sell Delay: %.2fs", clamped))
end

local function setAutoCatchDelay(value)
    local numeric = tonumber(value) or autoCatchDelay
    local clamped = math.max(0.1, numeric)
    clamped = roundDelay(clamped)
    if math.abs(clamped - autoCatchDelay) < 0.001 then
        return
    end
    autoCatchDelay = clamped
    updateConfigField("autoCatchDelay", clamped)
    print(string.format("[Delays] Auto Catch Delay: %.2fs", clamped))
end

local function setWeatherIdDelay(value)
    local numeric = tonumber(value) or weatherIdDelay
    local clamped = math.max(1, numeric)
    clamped = roundDelay(clamped)
    if math.abs(clamped - weatherIdDelay) < 0.001 then
        return
    end
    weatherIdDelay = clamped
    updateConfigField("weatherIdDelay", clamped)
    print(string.format("[Delays] Weather ID Delay: %.2fs", clamped))
end

local function setWeatherCycleDelay(value)
    local numeric = tonumber(value) or weatherCycleDelay
    local clamped = math.max(10, numeric)
    clamped = roundDelay(clamped)
    if math.abs(clamped - weatherCycleDelay) < 0.001 then
        return
    end
    weatherCycleDelay = clamped
    updateConfigField("weatherCycleDelay", clamped)
    print(string.format("[Delays] Weather Cycle Delay: %.2fs", clamped))
end

-- Try to migrate old config first, then load current config
if not migrateOldConfig() then
    loadConfig()
end

applyDelayConfig()

-- Player identification info
print("[Config] Player identification:")
print("  Username: " .. (LocalPlayer.Name or "Unknown"))
print("  UserID: " .. (LocalPlayer.UserId or 0))
print("  Config file: " .. getConfigFileName())

local autoMegalodonToggle
local autoPreset1Toggle
local autoPreset2Toggle
local autoPreset3Toggle
local gpuSaverToggle
local chargeFishingSlider
local autoFishMainSlider
local autoSellSlider
local autoCatchSlider
local weatherIdSlider
local weatherCycleSlider
local upgradeRodToggle
local upgradeBaitToggle

-- ====== AUTO UPGRADE STATE & DATA (From Fish v3) ======
-- Convert upgrade system to globals to save local register space
upgradeState = { rod = false, bait = false }
rodIDs = {79, 76, 85, 77, 78, 4, 80, 6, 7, 5}
baitIDs = {10, 2, 3, 17, 6, 8, 15, 16}
rodPrices = {[79]=350,[76]=3000,[85]=1500,[77]=3000,[78]=5000,[4]=15000,[80]=50000,[6]=215000,[7]=437000,[5]=1000000}
baitPrices = {[10]=100,[2]=1000,[3]=3000,[17]=83500,[6]=290000,[8]=630000,[15]=1150000,[16]=1000000}
failedRodAttempts, failedBaitAttempts, rodFailedCounts, baitFailedCounts = {}, {}, {}, {}
currentRodTarget, currentBaitTarget = nil, nil

local function findNextRodTarget()
    local a=1;if currentRodTarget then for c=1,#rodIDs do if rodIDs[c]==currentRodTarget then a=c+1;break end end end;for c=a,#rodIDs do local b=rodIDs[c];if rodPrices[b]and(not rodFailedCounts[b]or rodFailedCounts[b]<3)then return b end end;return nil
end
local function findNextBaitTarget()
    local a=1;if currentBaitTarget then for c=1,#baitIDs do if baitIDs[c]==currentBaitTarget then a=c+1;break end end end;for c=a,#baitIDs do local b=baitIDs[c];if baitPrices[b]and(not baitFailedCounts[b]or baitFailedCounts[b]<3)then return b end end;return nil
end
local function initializeTargets()
    currentRodTarget=findNextRodTarget();currentBaitTarget=findNextBaitTarget()
    if currentRodTarget then print("[AutoUpgrade] Initial rod target: ID "..tostring(currentRodTarget))end
    if currentBaitTarget then print("[AutoUpgrade] Initial bait target: ID "..tostring(currentBaitTarget))end
end
local function getAffordableRod(a)
    if not currentRodTarget then return end;local b=rodPrices[currentRodTarget];if not b then currentRodTarget=findNextRodTarget();return end
    if failedRodAttempts[currentRodTarget]and tick()-failedRodAttempts[currentRodTarget]<30 then return end;if a>=b then return currentRodTarget,b end
end
local function getAffordableBait(a)
    if not currentBaitTarget then return end;local b=baitPrices[currentBaitTarget];if not b then currentBaitTarget=findNextBaitTarget();return end
    if failedBaitAttempts[currentBaitTarget]and tick()-failedBaitAttempts[currentBaitTarget]<30 then return end;if a>=b then return currentBaitTarget,b end
end

local function setUpgradeRod(a)
    if upgradeState.rod==a then return end;upgradeState.rod=a;if upgradeRodToggle then upgradeRodToggle:UpdateToggle(nil,a)end;if a then initializeTargets()end;print("🔧 Auto Upgrade Rod: "..(a and "ENABLED" or "DISABLED"))
end
local function setUpgradeBait(a)
    if upgradeState.bait==a then return end;upgradeState.bait=a;if upgradeBaitToggle then upgradeBaitToggle:UpdateToggle(nil,a)end;if a then initializeTargets()end;print("🔧 Auto Upgrade Bait: "..(a and "ENABLED" or "DISABLED"))
end
-- ====== END AUTO UPGRADE ======

-- ====== FUNGSI UNTUK MENDAPATKAN COIN DAN LEVEL ====== 
local function getCurrentCoins()
    local currencyText = "0"
    local success, result = pcall(function()
        local playerGui = LocalPlayer:FindFirstChild("PlayerGui")
        local events = playerGui and playerGui:FindFirstChild("Events")
        local frame = events and events:FindFirstChild("Frame")
        local currencyCounter = frame and frame:FindFirstChild("CurrencyCounter")
        local counter = currencyCounter and currencyCounter:FindFirstChild("Counter")
        return counter and counter.Text
    end)

    if success and result then
        currencyText = result
    end

    local cleanText = currencyText:gsub(",", "")
    local numResult = 0
    if cleanText:lower():find("k") then
        local numPart = cleanText:lower():gsub("k", "")
        numResult = (tonumber(numPart) or 0) * 1000
    elseif cleanText:lower():find("m") then
        local numPart = cleanText:lower():gsub("m", "")
        numResult = (tonumber(numPart) or 0) * 1000000
    else
        numResult = tonumber(cleanText) or 0
    end
    return numResult
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

-- ====== HELPER FUNCTIONS FOR WEB MONITOR ====== 
local function getFishCaught()
    local success, fishCaught = pcall(function()
        if LocalPlayer.leaderstats and LocalPlayer.leaderstats.Caught then
            return LocalPlayer.leaderstats.Caught.Value
        end
        return 0
    end)

    return success and fishCaught or 0
end

local function getBestFish()
    local success, bestFish = pcall(function()
        if LocalPlayer.leaderstats and LocalPlayer.leaderstats["Rarest Fish"] then
            return LocalPlayer.leaderstats["Rarest Fish"].Value
        end
        return "None"
    end)

    return success and bestFish or "None"
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
    -- Ensure we have a valid number
    seconds = tonumber(seconds) or 0
    seconds = math.max(0, math.floor(seconds))

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
local autoSellDelay = 45
local autoCatchDelay = 0.2
local weatherIdDelay = 33
local weatherCycleDelay = 100

HOTBAR_SLOT = 2 -- Slot hotbar untuk equip tool (global)


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
            WeatherEvent = net:WaitForChild("RF/PurchaseWeatherEvent", 10),
            fishCaughtEvent = replicatedStorage.Packages._Index["sleitnick_net@0.2.0"].net:WaitForChild("RE/FishCaught", 10),
            -- For Auto Upgrade
            purchaseRodEvent = net:WaitForChild("RF/PurchaseFishingRod", 10),
            purchaseBaitEvent = net:WaitForChild("RF/PurchaseBait", 10),
            equipItemEvent = net:WaitForChild("RE/EquipItem", 10),
            equipBaitEvent = net:WaitForChild("RE/EquipBait", 10)
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
print("⏳ [Auto Fish] Initializing network events...")
local networkEvents = getNetworkEvents()
if not networkEvents then
    error("❌ [Auto Fish] Failed to initialize network events. Script cannot continue.")
    return
else
    print("✅ [Auto Fish] Network events initialized")
end

-- Extract events for easier access
local fishingEvent = networkEvents.fishingEvent
local sellEvent = networkEvents.sellEvent
local chargeEvent = networkEvents.chargeEvent
local requestMinigameEvent = networkEvents.requestMinigameEvent
local cancelFishingEvent = networkEvents.cancelFishingEvent
local equipEvent = networkEvents.equipEvent
local unequipEvent = networkEvents.unequipEvent
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

    -- FPS Counter (centered)
    local fpsLabel = Instance.new("TextLabel")
    fpsLabel.Name = "FPSLabel"
    fpsLabel.Size = UDim2.new(0, 400, 0, 40)
    fpsLabel.Position = UDim2.new(0.5, -200, 0, 200)
    fpsLabel.BackgroundTransparency = 1
    fpsLabel.Text = "📊 FPS: " .. currentFPS
    fpsLabel.TextColor3 = Color3.new(1, 1, 1)
    fpsLabel.TextSize = 22
    fpsLabel.Font = Enum.Font.SourceSansBold
    fpsLabel.TextXAlignment = Enum.TextXAlignment.Center
    fpsLabel.Parent = frame
    
    -- Fishing stats (centered)
    local fishStatsLabel = Instance.new("TextLabel")
    fishStatsLabel.Name = "FishStatsLabel"
    fishStatsLabel.Size = UDim2.new(0, 400, 0, 40)
    fishStatsLabel.Position = UDim2.new(0.5, -200, 0, 220)
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
    coinLabel.Position = UDim2.new(0.5, -200, 0, 240)
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
    levelLabel.Position = UDim2.new(0.5, -200, 0, 260)
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
    quest1Label.Position = UDim2.new(0.5, -300, 0, 330)  -- Di bawah level
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
    quest2Label.Position = UDim2.new(0.5, -300, 0, 350)  -- Di bawah level
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
    quest3Label.Position = UDim2.new(0.5, -300, 0, 370)  -- Di bawah level
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
    quest4Label.Position = UDim2.new(0.5, -300, 0, 390)  -- Di bawah level
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
    statusLabel.Size = UDim2.new(0, 600, 0, 40)
    statusLabel.Position = UDim2.new(0.5, -300, 0, 450)
    statusLabel.BackgroundTransparency = 1
    statusLabel.Text = "🤖 Auto Farm: " .. (isAutoFarmOn and "🟢 ON" or "🔴 OFF") .. 
                      " | Auto Sell: " .. (isAutoSellOn and "🟢 ON" or "🔴 OFF") ..
                      " | Auto Catch: " .. (isAutoCatchOn and "🟢 ON" or "🔴 OFF")
    statusLabel.TextColor3 = Color3.new(0.9, 0.9, 0.9)
    statusLabel.TextSize = 16
    statusLabel.Font = Enum.Font.SourceSans
    statusLabel.TextXAlignment = Enum.TextXAlignment.Center
    statusLabel.TextYAlignment = Enum.TextYAlignment.Center
    statusLabel.Parent = frame

    local extraStatusLabel = Instance.new("TextLabel")
    extraStatusLabel.Name = "ExtraStatusLabel"
    extraStatusLabel.Size = UDim2.new(0, 600, 0, 40)
    extraStatusLabel.Position = UDim2.new(0.5, -300, 0, 470)
    extraStatusLabel.BackgroundTransparency = 1
    extraStatusLabel.Text = "🦈 Auto Megalodon: " .. (isAutoMegalodonOn and "🟢 ON" or "🔴 OFF") ..
                          " | 🌤️ Auto Weather: " .. (isAutoWeatherOn and "🟢 ON" or "🔴 OFF")
    extraStatusLabel.TextColor3 = Color3.new(0.9, 0.9, 0.9)
    extraStatusLabel.TextSize = 16
    extraStatusLabel.Font = Enum.Font.SourceSans
    extraStatusLabel.TextXAlignment = Enum.TextXAlignment.Center
    extraStatusLabel.TextYAlignment = Enum.TextYAlignment.Center
    extraStatusLabel.Parent = frame

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
    closeButton.Parent = frame

    closeButton.MouseButton1Click:Connect(function()
        disableGPUSaver()
    end)

    -- ====== IMPROVED UPDATE SYSTEM (from reference) ====== 
    task.spawn(function()
        local lastUpdate = tick()
        local frameCount = 0
        
        connections.renderConnection = RunService.RenderStepped:Connect(function()
            frameCount = frameCount + 1
            local currentTime = tick()
            
            if currentTime - lastUpdate >= 1 then
                local fps = frameCount / (currentTime - lastUpdate)
                
                -- Safe FPS update
                pcall(function()
                    if fpsLabel and fpsLabel.Parent then
                        fpsLabel.Text = string.format("📊 FPS: %.0f", fps)
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
                
                -- Safe coins update
                pcall(function()
                    if coinLabel and coinLabel.Parent then
                        coinLabel.Text = "💰 Coins: " .. getCurrentCoins()
                    end
                end)

                -- Safe level update
                pcall(function()
                    if levelLabel and levelLabel.Parent then
                        levelLabel.Text = "⭐ " .. getCurrentLevel()
                    end
                end)
                
                -- Safe quest updates
                pcall(function() if quest1Label and quest1Label.Parent then quest1Label.Text = "🏆 Quest 1: " .. getQuestText("Label1") end end)
                pcall(function() if quest2Label and quest2Label.Parent then quest2Label.Text = "🏆 Quest 2: " .. getQuestText("Label2") end end)
                pcall(function() if quest3Label and quest3Label.Parent then quest3Label.Text = "🏆 Quest 3: " .. getQuestText("Label3") end end)
                pcall(function() if quest4Label and quest4Label.Parent then quest4Label.Text = "🏆 Quest 4: " .. getQuestText("Label4") end end)
                
                -- Safe status update
                pcall(function()
                    if statusLabel and statusLabel.Parent then
                        statusLabel.Text = "🤖 Auto Farm: " .. (isAutoFarmOn and "🟢 ON" or "🔴 OFF") .. 
                                         " | Auto Sell: " .. (isAutoSellOn and "🟢 ON" or "🔴 OFF") ..
                                         " | Auto Catch: " .. (isAutoCatchOn and "🟢 ON" or "🔴 OFF")
                    end
                    if extraStatusLabel and extraStatusLabel.Parent then
                        extraStatusLabel.Text = "🦈 Auto Megalodon: " .. (isAutoMegalodonOn and "🟢 ON" or "🔴 OFF") ..
                                              " | 🌤️ Auto Weather: " .. (isAutoWeatherOn and "🟢 ON" or "🔴 OFF")
                    end
                end)
                
                -- Safe Total Caught & Best Caught update
                pcall(function()
                    if titleLabel and titleLabel.Parent then
                        local currentCaught = (LocalPlayer.leaderstats and LocalPlayer.leaderstats.Caught and LocalPlayer.leaderstats.Caught.Value) or 0
                        local currentBest = (LocalPlayer.leaderstats and LocalPlayer.leaderstats["Rarest Fish"] and LocalPlayer.leaderstats["Rarest Fish"].Value) or "None"
                        titleLabel.Text = "🟢 " .. LocalPlayer.Name .. "\nTotal Caught: " .. FormatNumber(currentCaught) .. "\nBest Caught: " .. currentBest
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
    
    if connections.renderConnection then
        connections.renderConnection:Disconnect()
        connections.renderConnection = nil
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
        
        pcall(function() setfpscap(5) end) -- Limit FPS to 5
        StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.All, false)
        workspace.CurrentCamera.FieldOfView = 1
    end)
    
    createWhiteScreen()
    print("⚡ GPU Saver Mode: ENABLED")

    -- Update toggle if available
    if gpuSaverToggle and not isApplyingConfig then
        gpuSaverToggle:UpdateToggle(nil, true)
    end
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
        
        pcall(function() setfpscap(0) end) -- Remove FPS limit
        StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.All, true)
        workspace.CurrentCamera.FieldOfView = 70
    end)
    
    removeWhiteScreen()
    print("⚡ GPU Saver Mode: DISABLED")

    -- Update toggle if available
    if gpuSaverToggle and not isApplyingConfig then
        gpuSaverToggle:UpdateToggle(nil, false)
    end
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

        -- Only enable weather and megalodon for auto1 and auto2, not auto3
        if presetKey ~= "auto3" then
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
        end

        table.insert(steps, function()
            enableGPUSaver()
        end)

        -- Set custom delays for each preset
        table.insert(steps, function()
            setDelaysForPreset(presetKey)
        end)

        runPresetSequence(steps)

        if presetKey == "auto1" then
            isAutoPreset1On = true
            isAutoPreset2On = false
            isAutoPreset3On = false
        elseif presetKey == "auto2" then
            isAutoPreset1On = false
            isAutoPreset2On = true
            isAutoPreset3On = false
        elseif presetKey == "auto3" then
            isAutoPreset1On = false
            isAutoPreset2On = false
            isAutoPreset3On = true
        else
            isAutoPreset1On = false
            isAutoPreset2On = true
            isAutoPreset3On = false
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
            elseif presetKey == "auto3" then
                isAutoPreset3On = false
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
            function() 
                disableGPUSaver()
            end,
        }

        -- Reset delays when disabling preset
        table.insert(steps, function()
            -- Reset to default delays
            if autoFishMainSlider then
                autoFishMainSlider:Set(0.9)
            else
                setAutoFishMainDelay(0.9)
            end
            if autoCatchSlider then
                autoCatchSlider:Set(0.2)
            else
                setAutoCatchDelay(0.2)
            end
            print("[Preset] Delays reset to default: Fish=0.9s, Catch=0.2s")
        end)

        runPresetSequence(steps)

        if presetKey == "auto1" then
            isAutoPreset1On = false
        elseif presetKey == "auto2" then
            isAutoPreset2On = false
        elseif presetKey == "auto3" then
            isAutoPreset3On = false
        else
            isAutoPreset2On = false
        end

        config.activePreset = "none"
        saveConfig()
    end)
end


-- ====== DAFTAR IDS ====== 
local WeatherIDs = {"Cloudy", "Storm","Wind"}


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


-- ====== MEGALODON HUNT FUNCTIONS ====== 
local function teleportToMegalodon(position, isEventTeleport)
    if player.Character and player.Character:FindFirstChild("HumanoidRootPart") and player.Character:FindFirstChild("Humanoid") then
        local humanoid = player.Character.Humanoid
        local rootPart = player.Character.HumanoidRootPart

        -- Save FULL CFrame (position + orientation) before teleport to event
        if isEventTeleport and not hasTeleportedToMegalodon then
            megalodonSavedPosition = rootPart.CFrame -- Save full CFrame, not just position
            hasTeleportedToMegalodon = true
            print("[Megalodon] Saved player CFrame before event teleport")
        end

        -- Remove lock before teleport if exists
        if currentBodyPosition then
            currentBodyPosition:Destroy()
            currentBodyPosition = nil
        end

        -- Teleport to position with proper orientation
        if type(position) == "userdata" and position.X then
            -- If position is a Vector3, create new CFrame with default orientation
            rootPart.CFrame = CFrame.new(position + Vector3.new(0, 5, 0))
        elseif type(position) == "userdata" and position.Position then
            -- If position is already a CFrame, use it directly
            rootPart.CFrame = position + Vector3.new(0, 5, 0)
        else
            -- Fallback
            rootPart.CFrame = CFrame.new(position + Vector3.new(0, 5, 0))
        end
        task.wait(0.1)

        -- Jump once
        humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
        task.wait(0.5)

        -- Enable floating/lock position only for event teleports
        if isEventTeleport then
            currentBodyPosition = Instance.new("BodyPosition")
            currentBodyPosition.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
            currentBodyPosition.Position = (type(position) == "userdata" and position.Position and position.Position or position) + Vector3.new(0, 5, 0)
            currentBodyPosition.P = 10000
            currentBodyPosition.D = 1000
            currentBodyPosition.Parent = rootPart
        end
    end
end

local function disableMegalodonLock()
    if currentBodyPosition then
        currentBodyPosition:Destroy()
        currentBodyPosition = nil
    end
end

local function formatDuration(seconds)
    if not seconds or seconds <= 0 then
        return "Unavailable"
    end

    seconds = math.floor(seconds)
    local hours = math.floor(seconds / 3600)
    local minutes = math.floor((seconds % 3600) / 60)
    local remainingSeconds = seconds % 60

    if hours > 0 then
        return string.format("%dh %dm %ds", hours, minutes, remainingSeconds)
    elseif minutes > 0 then
        return string.format("%dm %ds", minutes, remainingSeconds)
    else
        return string.format("%ds", remainingSeconds)
    end
end

local function resumeFarmingAfterMegalodon(previousAutoFarmState)
    task.spawn(function()
        local shouldResume = previousAutoFarmState
        if shouldResume == nil then
            shouldResume = config.autoFarm
        end

        if shouldResume then
            if not isAutoFarmOn then
                setAutoFarm(true)
            else
                equipRod()
            end
        end
    end)
end

-- ====== MEGALODON WEBHOOK ====== 
local lastWebhookTime = 0
local WEBHOOK_COOLDOWN = 15 -- 15 seconds cooldown between webhooks to prevent rate limiting
local webhookRetryDelay = 5 -- Base retry delay in seconds
local maxRetryAttempts = 3

-- ====== UNIFIED WEBHOOK CONFIGURATION ======
-- Use webhook2 from main.lua if available, otherwise use empty fallback
local UNIFIED_WEBHOOK_URL = webhook2  -- Uses webhook2 from loadstring

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
    elseif webhookType == "megalodon_ended" then
        local endedAt = data and data.endedAt or os.time()
        local startedAt = data and data.startedAt or 0
        local duration = data and data.duration
        if (not duration or duration <= 0) and startedAt > 0 then
            duration = math.max(0, endedAt - startedAt)
        end

        embed = {
            title = '[Megalodon] Event Ended',
            description = 'Megalodon Hunt props removed. Resuming farming routine.',
            color = 3447003, -- Blue
            fields = {
                { name = "Player", value = (player.DisplayName or player.Name or "Unknown"), inline = true },
                { name = "Ended At", value = os.date("%H:%M:%S", endedAt), inline = true },
                { name = "Duration", value = formatDuration(duration), inline = true },
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
                { name = "👤 Player", value = player.DisplayName or player.Name or "Unknown", inline = true },
                { name = "📦 Total (whitelist)", value = tostring(data.totalWhitelistCount or 0) .. " fish", inline = true },
            },
            footer = { text = "Inventory Notifier • Auto Fish" }
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
    elseif status == "ended" then
        sendUnifiedWebhook("megalodon_ended", data)
    end
end

local function autoDetectMegalodon()
    local eventFound = false
    local eventPosition = nil
    local debugMode = false -- Set to true for troubleshooting

    -- New, more robust path detection to handle multiple "Props" children
    pcall(function()
        local menuRings = workspace:FindFirstChild("!!! MENU RINGS")
        if menuRings then
            -- Iterate through all children of "!!! MENU RINGS" to find the correct "Props" folder
            for _, propsFolder in ipairs(menuRings:GetChildren()) do
                if propsFolder.Name == "Props" then
                    if debugMode then print("[Megalodon Debug] Checking Props folder: " .. propsFolder:GetFullName()) end
                    local huntFolder = propsFolder:FindFirstChild("Megalodon Hunt")
                    if huntFolder then
                        local colorPart = huntFolder:FindFirstChild("Color")
                        if colorPart and colorPart.Position then
                            eventPosition = colorPart.Position
                            eventFound = true
                            print("[Megalodon] Event found at new path: " .. colorPart:GetFullName())
                            break -- Exit the loop once found
                        end
                    end
                end
            end
        end
    end)

    -- Fallback to old detection method if new one fails
    if not eventFound then
        if debugMode then print("[Megalodon Debug] New path failed, trying old detection method...") end
        
        -- Search for Megalodon event directly in Workspace (handle multiple Props folders)
        for _, child in ipairs(workspace:GetChildren()) do
            if string.lower(child.Name) == "props" then
                if debugMode then print("[Megalodon Debug] Checking root Props folder: " .. child.Name) end

                local megalodonHunt = child:FindFirstChild("Megalodon Hunt") or
                                    child:FindFirstChild("megalodon hunt") or
                                    child:FindFirstChild("Megalodon_Hunt") or
                                    child:FindFirstChild("megalodon_hunt") or
                                    child:FindFirstChild("MegalodonHunt") or
                                    child:FindFirstChild("megalodonh hunt")

                if megalodonHunt and megalodonHunt:FindFirstChild("Color") and megalodonHunt.Color.Position then
                    eventPosition = megalodonHunt.Color.Position
                    eventFound = true
                    print("[Megalodon] Event found via fallback in: " .. child.Name .. "/" .. megalodonHunt.Name)
                    break
                end
            end
        end
    end
    
    -- Fallback 2: Deeper search if still not found
    if not eventFound then
        if debugMode then print("[Megalodon Debug] Standard fallback failed, trying deep search...") end
        for _, child in ipairs(workspace:GetChildren()) do
            if string.lower(child.Name) == "props" then
                for _, subChild in ipairs(child:GetChildren()) do
                    if string.find(string.lower(subChild.Name), "megalodon") then
                        if subChild:FindFirstChild("Color") and subChild.Color.Position then
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
            megalodonEventEndAlertSent = false
            megalodonPreEventFarmState = isAutoFarmOn
            megalodonEventStartedAt = os.time()
        end

        if not hasTeleportedToMegalodon then
            teleportToMegalodon(eventPosition, true)
            task.wait(0.5)
            disableMegalodonLock()
        end
    else
        -- Handle event end or missing props
        local wasActive = megalodonEventActive
        if wasActive then
            megalodonEventActive = false
        end

        if hasTeleportedToMegalodon and megalodonSavedPosition then
            -- Restore player to saved CFrame (position + orientation)
            if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                player.Character.HumanoidRootPart.CFrame = megalodonSavedPosition
                print("[Megalodon] Restored player to original CFrame")
            end
            megalodonSavedPosition = nil
            hasTeleportedToMegalodon = false
            disableMegalodonLock()
        end

        if wasActive then
            if not megalodonEventEndAlertSent then
                megalodonEventEndAlertSent = true
                megalodonMissingAlertSent = true

                local eventEndedAt = os.time()
                local duration = nil
                if megalodonEventStartedAt and megalodonEventStartedAt > 0 then
                    duration = math.max(0, eventEndedAt - megalodonEventStartedAt)
                end

                sendMegalodonEventWebhook("ended", {
                    endedAt = eventEndedAt,
                    startedAt = megalodonEventStartedAt,
                    duration = duration,
                })
            end

            megalodonEventStartedAt = 0
            resumeFarmingAfterMegalodon(megalodonPreEventFarmState)
            megalodonPreEventFarmState = nil
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
        megalodonEventEndAlertSent = false
        megalodonPreEventFarmState = nil
    end
    print("🦈 Auto Megalodon Hunt: " .. (state and "ENABLED" or "DISABLED"))
end

-- ====== CONNECTION STATUS WEBHOOK SYSTEM ======
-- Webhook khusus untuk status connect/disconnect
-- PENTING: Pastikan webhook3 dan discordid sudah dikonfigurasi di main.lua sebelum menjalankan script ini!
-- Contoh konfigurasi di main.lua:
-- webhook3 = "https://discord.com/api/webhooks/YOUR_WEBHOOK_ID/YOUR_WEBHOOK_TOKEN"
-- discordid = "123456789012345678"  -- Discord User ID (18 digit number)
local CONNECTION_WEBHOOK_URL = webhook3 or ""  -- URL webhook khusus untuk status koneksi

local hasSentDisconnectWebhook = false  -- Flag to avoid sending multiple notifications
local PING_THRESHOLD = 1000  -- ms, if ping > this = poor connection
local FREEZE_THRESHOLD = 3  -- seconds, if delta > this = game freeze

-- DISCORD USER ID untuk tag saat disconnect (ganti dengan ID Discord Anda)
local DISCORD_USER_ID = discordid or "701247227959574567"  -- Fallback jika discordid tidak terdefinisi

-- QUEUE SYSTEM untuk multiple accounts (mencegah rate limiting)
local webhookQueue = {}
local isProcessingQueue = false
local WEBHOOK_DELAY = 2  -- seconds between webhook sends
local lastWebhookSent = 0

-- ====== MESSAGE EDITING SYSTEM ======
-- Sistem untuk edit message alih-alih kirim pesan baru
MESSAGE_ID_STORAGE = {}  -- Store message IDs per account (global)
ONLINE_STATUS_UPDATE_INTERVAL = 8  -- Update setiap 8 detik
lastOnlineStatusUpdate = 0
isOnlineStatusActive = false
onlineStatusMessageId = nil

-- Compact message storage functions
function saveMessageId(accountId, messageId)
    MESSAGE_ID_STORAGE[accountId] = MESSAGE_ID_STORAGE[accountId] or {}
    MESSAGE_ID_STORAGE[accountId].statusMessageId = messageId
    if writefile and ensureConfigFolder() then
        pcall(function()
            writefile(CONFIG_FOLDER .. "/message_ids_" .. accountId .. ".json",
                HttpService:JSONEncode({statusMessageId = messageId, lastUpdate = os.time(), playerName = LocalPlayer.Name}))
        end)
    end
end

function loadMessageId(accountId)
    if not readfile or not isfile then return nil end
    local file = CONFIG_FOLDER .. "/message_ids_" .. accountId .. ".json"
    if not isfile(file) then return nil end
    local success, result = pcall(function()
        return HttpService:JSONDecode(readfile(file)).statusMessageId
    end)
    if success and result then
        MESSAGE_ID_STORAGE[accountId] = MESSAGE_ID_STORAGE[accountId] or {}
        MESSAGE_ID_STORAGE[accountId].statusMessageId = result
        return result
    end
    return nil
end

function getStoredMessageId(accountId)
    return (MESSAGE_ID_STORAGE[accountId] and MESSAGE_ID_STORAGE[accountId].statusMessageId) or loadMessageId(accountId)
end

-- ====== RECONNECT DETECTION SYSTEM ======
local lastSessionId = nil
local lastDisconnectTime = nil
local RECONNECT_THRESHOLD = 60  -- seconds, if reconnect within this time = quick reconnect
local NEW_SESSION_THRESHOLD = 60  -- seconds, if offline > 1 minute = treat as new connection

-- Compact Discord message edit function
function editDiscordMessage(messageId, embed, content)
    if not CONNECTION_WEBHOOK_URL or CONNECTION_WEBHOOK_URL == "" or not messageId then
        return false, "Invalid config"
    end

    local webhookId, webhookToken = CONNECTION_WEBHOOK_URL:match("https://discord%.com/api/webhooks/(%d+)/([%w%-_]+)")
    if not webhookId or not webhookToken then return false, "Invalid URL" end

    local payload = { embeds = {embed} }
    if content and content ~= "" then
        payload.content = content
        payload.allowed_mentions = {users = {tostring(DISCORD_USER_ID)}}
    end

    local success, err = pcall(function()
        local req = syn and syn.request or http_request or (fluxus and fluxus.request) or request
        if not req then error("No HTTP support") end
        req({
            Url = string.format("https://discord.com/api/webhooks/%s/%s/messages/%s", webhookId, webhookToken, messageId),
            Method = "PATCH",
            Headers = {["Content-Type"] = "application/json"},
            Body = HttpService:JSONEncode(payload)
        })
    end)
    return success, err
end

-- Compact new message sender
function sendNewStatusMessage(embed, content)
    if not CONNECTION_WEBHOOK_URL or CONNECTION_WEBHOOK_URL == "" then
        return nil, "No webhook URL"
    end

    local payload = { embeds = {embed}, wait = true }
    if content and content ~= "" then
        payload.content = content
        payload.allowed_mentions = {users = {tostring(DISCORD_USER_ID)}}
    end

    local success, response = pcall(function()
        local req = syn and syn.request or http_request or (fluxus and fluxus.request) or request
        if not req then error("No HTTP support") end
        return req({
            Url = CONNECTION_WEBHOOK_URL,
            Method = "POST",
            Headers = {["Content-Type"] = "application/json"},
            Body = HttpService:JSONEncode(payload)
        })
    end)

    if success and response and response.Body then
        local data = HttpService:JSONDecode(response.Body)
        if data and data.id then return data.id, nil end
    end
    return nil, response or "Send failed"
end

-- Compact online status updater
function updateOnlineStatus()
    local accountId = tostring(LocalPlayer.UserId)
    local uptime = os.time() - startTime
    local stats = LocalPlayer.leaderstats
    local fishCount = (stats and stats.Caught and stats.Caught.Value) or 0
    local bestFish = (stats and stats["Rarest Fish"] and stats["Rarest Fish"].Value) or "None"

    local embed = {
        title = "🟢 " .. (LocalPlayer.DisplayName or LocalPlayer.Name) .. " - ONLINE",
        description = "**Status**: Auto Fish Active 🎣",
        color = 65280,
        fields = {
            { name = "⏰ Last Update", value = os.date("%H:%M:%S"), inline = true },
            { name = "⌛ Uptime", value = FormatTime(uptime), inline = true },
            { name = "🐠 Total Fish", value = FormatNumber(fishCount), inline = true },
            { name = "🏆 Best Fish", value = bestFish, inline = true },
            { name = "💰 Coins", value = FormatNumber(getCurrentCoins()), inline = true },
            { name = "⭐ Level", value = getCurrentLevel(), inline = true },
        },
        footer = { text = "Auto Fish Status • Updates every " .. ONLINE_STATUS_UPDATE_INTERVAL .. "s" },
        timestamp = os.date("!%Y-%m-%dT%H:%M:%S.000Z")
    }

    local messageId = getStoredMessageId(accountId)
    if messageId then
        local success = editDiscordMessage(messageId, embed, "")
        if success then
            print("[Online Status] Updated message for account: " .. accountId)
            return true
        end
        MESSAGE_ID_STORAGE[accountId] = nil
    end

    messageId = sendNewStatusMessage(embed, "")
    if messageId then
        saveMessageId(accountId, messageId)
        onlineStatusMessageId = messageId
        print("[Online Status] Created new status message: " .. messageId)
        return true
    end
    return false
end

-- Fungsi untuk mengirim status koneksi ke webhook khusus (modified)
local function sendConnectionStatusWebhook(status, reason)
    print("[Connection Status] Attempting to send webhook - Status: " .. tostring(status) .. ", Reason: " .. tostring(reason or "none"))

    -- Check if webhook URL is configured
    if not CONNECTION_WEBHOOK_URL or CONNECTION_WEBHOOK_URL == "" then
        warn('[Connection Status] Webhook URL not configured! Please set CONNECTION_WEBHOOK_URL variable.')
        print("[Connection Status] Current webhook3 value: " .. tostring(webhook3 or "nil"))
        return
    end

    print("[Connection Status] Webhook URL configured, proceeding to send...")

    local embed = {}

    if status == "connected" then
        embed = {
            title = "🟢 Player Connected",
            description = "Auto Fish script has been successfully started",
            color = 65280, -- Green
            fields = {
                { name = "👤 Player", value = LocalPlayer.DisplayName or LocalPlayer.Name or "Unknown", inline = true },
                { name = "🕒 Time", value = os.date("%H:%M:%S"), inline = true },
                { name = "🎮 Game", value = "🐠 Fish It", inline = true },
                { name = "📱 Status", value = "Auto Fish Active", inline = false }
            },
            footer = { text = "Connection Monitor • Auto Fish Script" },
            timestamp = os.date("!%Y-%m-%dT%H:%M:%S.000Z")
        }
    elseif status == "reconnected" then
        embed = {
            title = "🔄 Player Reconnected",
            description = reason or "Player has successfully reconnected to the server",
            color = 3066993, -- Blue-green
            fields = {
                { name = "👤 Player", value = LocalPlayer.DisplayName or LocalPlayer.Name or "Unknown", inline = true },
                { name = "🕒 Time", value = os.date("%H:%M:%S"), inline = true },
                { name = "🔄 Reconnect Info", value = reason or "Reconnection detected", inline = false },
                { name = "📱 Status", value = "Auto Fish Resumed", inline = true }
            },
            footer = { text = "Reconnect Monitor • Auto Fish Script" },
            timestamp = os.date("!%Y-%m-%dT%H:%M:%S.000Z")
        }
    elseif status == "disconnected" then
        embed = {
            title = "🔴 Player Disconnected",
            description = reason or "Player has disconnected from the server",
            color = 16711680, -- Red
            fields = {
                { name = "👤 Player", value = LocalPlayer.DisplayName or LocalPlayer.Name or "Unknown", inline = true },
                { name = "🕒 Time", value = os.date("%H:%M:%S"), inline = true },
                { name = "🔌 Reason", value = reason or "Unknown", inline = false },
                { name = "⏱️ Session Duration", value = FormatTime(os.time() - startTime), inline = true },
                { name = "📱 Game", value = "🐠 Fish It", inline = true },
                { name = "🆔 User ID", value = tostring(LocalPlayer.UserId), inline = true }
            },
            footer = { text = "Disconnect Alert • Auto Fish Script" },
            timestamp = os.date("!%Y-%m-%dT%H:%M:%S.000Z")
        }
    else
        warn('[Connection Status] Unknown status type: ' .. tostring(status))
        return
    end

    -- Prepare payload with mentions for disconnect and reconnect status
    local payload = { embeds = {embed} }

    -- Prepare content with Discord mentions
    local userIdStr = tostring(DISCORD_USER_ID)
    local playerName = LocalPlayer.DisplayName or LocalPlayer.Name or "Player"

    if status == "disconnected" then
        -- Always include mention for disconnect notifications
        payload.content = "<@" .. userIdStr .. "> 🔴 **ALERT: " .. playerName .. " TELAH DISCONNECT!** 🚨"

    elseif status == "reconnected" then
        -- Always include mention for reconnect notifications
        payload.content = "<@" .. userIdStr .. "> 🟡 **" .. playerName .. " TELAH RECONNECT!** ✅"

    elseif status == "connected" then
        -- No mention for normal connection
        payload.content = "🟢 **" .. playerName .. " telah terhubung** ✅"
    end

    -- Always add allowed_mentions if content has mentions
    if payload.content and payload.content ~= "" then
        -- Check if content contains user mention
        if string.find(payload.content, "<@" .. userIdStr .. ">") then
            -- CRITICAL: Make sure allowed_mentions format is correct
            payload.allowed_mentions = {
                parse = {},  -- Don't parse @everyone, @here, or @role
                users = {userIdStr},  -- Allow mention for this specific user ID
                roles = {}  -- No role mentions
            }

            print("[Connection Status] ✅ Discord mention configured:")
            print("[Connection Status] - UserID: " .. userIdStr)
            print("[Connection Status] - Mention format: <@" .. userIdStr .. ">")
            print("[Connection Status] - Allowed mentions: " .. HttpService:JSONEncode(payload.allowed_mentions))
        else
            -- No allowed_mentions if no user mention in content
            payload.allowed_mentions = {
                parse = {},
                users = {},
                roles = {}
            }
        end

        print("[Connection Status] 📤 Sending webhook:")
        print("[Connection Status] - Status: " .. status)
        print("[Connection Status] - Content: " .. payload.content)
        print("[Connection Status] - Player: " .. playerName)
        print("[Connection Status] - UserID: " .. userIdStr)
    end

    local body = HttpService:JSONEncode(payload)

    -- DEBUG: Print full payload before sending
    print("[Connection Status] 🔍 DEBUG - Full payload JSON:")
    print(body)

    -- Additional validation debug
    print("[Connection Status] 🔍 Payload validation:")
    print("  - Has embeds: " .. tostring(payload.embeds ~= nil))
    print("  - Has content: " .. tostring(payload.content ~= nil))
    print("  - Has allowed_mentions: " .. tostring(payload.allowed_mentions ~= nil))
    if payload.allowed_mentions then
        print("  - Allowed users count: " .. tostring(#(payload.allowed_mentions.users or {})))
        print("  - First allowed user: " .. tostring((payload.allowed_mentions.users or {})[1]))
    end

    -- Send webhook with retry logic
    task.spawn(function()
        local attempt = 1
        local maxAttempts = 3
        local success = false

        while attempt <= maxAttempts and not success do
            local retryDelay = 2 * attempt -- Progressive delay

            if attempt > 1 then
                print('[Connection Status] Retry attempt ' .. attempt .. ' after ' .. retryDelay .. ' seconds...')
                task.wait(retryDelay)
            end

            success, err = pcall(function()
                local httpMethod = nil
                local response = nil

                if syn and syn.request then
                    httpMethod = "syn.request"
                    response = syn.request({
                        Url = CONNECTION_WEBHOOK_URL,
                        Method = "POST",
                        Headers = {["Content-Type"] = "application/json"},
                        Body = body
                    })
                elseif http_request then
                    httpMethod = "http_request"
                    response = http_request({
                        Url = CONNECTION_WEBHOOK_URL,
                        Method = "POST",
                        Headers = {["Content-Type"] = "application/json"},
                        Body = body
                    })
                elseif fluxus and fluxus.request then
                    httpMethod = "fluxus.request"
                    response = fluxus.request({
                        Url = CONNECTION_WEBHOOK_URL,
                        Method = "POST",
                        Headers = {["Content-Type"] = "application/json"},
                        Body = body
                    })
                elseif request then
                    httpMethod = "request"
                    response = request({
                        Url = CONNECTION_WEBHOOK_URL,
                        Method = "POST",
                        Headers = {["Content-Type"] = "application/json"},
                        Body = body
                    })
                else
                    error("Executor does not support HTTP requests")
                end

                print("[Connection Status] 📡 HTTP Request Info:")
                print("  - Method used: " .. tostring(httpMethod))
                print("  - Response received: " .. tostring(response ~= nil))

                if response then
                    print("  - Response status: " .. tostring(response.StatusCode or "N/A"))
                    print("  - Response body: " .. tostring(response.Body or "N/A"))
                end

                return response
            end)

            if success then
                print('[Connection Status] ' .. status .. ' notification sent successfully on attempt ' .. attempt)
                break
            else
                warn('[Connection Status] ' .. status .. ' attempt ' .. attempt .. ' failed: ' .. tostring(err))
                attempt = attempt + 1
            end
        end

        if not success then
            warn('[Connection Status] All ' .. status .. ' attempts failed')
        end
    end)
end

-- Load previous session data (if available)
local function loadSessionData()
    local success, sessionId, disconnectTime = pcall(function()
        if readfile and isfile then
            local sessionFile = CONFIG_FOLDER .. "/last_session_" .. LocalPlayer.UserId .. ".json"
            print("[Reconnect] CONFIG_FOLDER: " .. tostring(CONFIG_FOLDER))
            print("[Reconnect] LocalPlayer.UserId: " .. tostring(LocalPlayer.UserId))
            print("[Reconnect] Checking session file: " .. sessionFile)

            if isfile(sessionFile) then
                local content = readfile(sessionFile)
                print("[Reconnect] Session file found, content length: " .. #content)

                local data = HttpService:JSONDecode(content)
                print("[Reconnect] Loaded session data - SessionID: " .. string.sub(tostring(data.sessionId or "unknown"), 1, 8) .. "..., DisconnectTime: " .. tostring(data.disconnectTime))

                return data.sessionId, data.disconnectTime
            else
                print("[Reconnect] No session file found")
            end
        else
            print("[Reconnect] File operations not available")
        end
        return nil, nil
    end)

    if success then
        return sessionId, disconnectTime
    else
        print("[Reconnect] Error loading session data: " .. tostring(sessionId))
        return nil, nil
    end
end

-- Save session data
local function saveSessionData(sessionId, disconnectTime)
    if not writefile then
        print("[Reconnect] writefile not available")
        return
    end

    if not ensureConfigFolder() then
        print("[Reconnect] Failed to create config folder")
        return
    end

    local sessionFile = CONFIG_FOLDER .. "/last_session_" .. LocalPlayer.UserId .. ".json"
    local sessionData = {
        sessionId = sessionId,
        disconnectTime = disconnectTime,
        playerName = LocalPlayer.Name,
        userId = LocalPlayer.UserId
    }

    print("[Reconnect] Saving session data - SessionID: " .. string.sub(tostring(sessionId or "unknown"), 1, 8) .. "..., DisconnectTime: " .. tostring(disconnectTime))

    local success, err = pcall(function()
        local encoded = HttpService:JSONEncode(sessionData)
        writefile(sessionFile, encoded)
    end)

    if success then
        print("[Reconnect] Session data saved to: " .. sessionFile)
    else
        print("[Reconnect] Failed to save session data: " .. tostring(err))
    end
end

-- Initialize reconnect detection
local function initializeReconnectDetection()
    -- Verify that the webhook function is available
    if not sendConnectionStatusWebhook or type(sendConnectionStatusWebhook) ~= "function" then
        warn("[Reconnect] ERROR: sendConnectionStatusWebhook function not available!")
        warn("[Reconnect] Aborting reconnect detection initialization")
        return
    end

    local currentSessionId = game.JobId
    local currentTime = os.time()

    print("[Reconnect] Initializing reconnect detection...")
    print("[Reconnect] Current SessionID: " .. string.sub(tostring(currentSessionId or "unknown"), 1, 8) .. "...")
    print("[Reconnect] Current Time: " .. tostring(currentTime))

    -- Load previous session data
    lastSessionId, lastDisconnectTime = loadSessionData()
    print("[Reconnect] Loaded - lastSessionId: " .. tostring(lastSessionId and string.sub(tostring(lastSessionId or "unknown"), 1, 8) .. "..." or "nil") .. ", lastDisconnectTime: " .. tostring(lastDisconnectTime or "nil"))

    if lastSessionId and lastDisconnectTime then
        local timeDiff = currentTime - lastDisconnectTime
        print("[Reconnect] Time difference: " .. timeDiff .. " seconds")

        -- NEW LOGIC: If offline > 1 minute, treat as new session
        if timeDiff > NEW_SESSION_THRESHOLD then
            print("[Reconnect] Offline > 1 minute (" .. timeDiff .. "s) - treating as new connection")
            local success, err = pcall(function()
                sendConnectionStatusWebhook("connected", "New connection after " .. math.floor(timeDiff/60) .. " minute(s) offline")
            end)
            if not success then
                print("[Reconnect] Error sending new connection webhook: " .. tostring(err))
            end
        else
            -- Within 1 minute threshold - check reconnect type
            if currentSessionId == lastSessionId then
                -- Same server session
                print("[Reconnect] Same server detected!")
                print("[Reconnect] Quick reconnect detected - sending webhook")
                local sessionPreview = string.sub(tostring(currentSessionId or "unknown"), 1, 8)
                local success, err = pcall(function()
                    sendConnectionStatusWebhook("reconnected", "Quick reconnect detected (Session: " .. sessionPreview .. "..., Time: " .. tostring(timeDiff) .. "s)")
                end)
                if not success then
                    print("[Reconnect] Error sending quick reconnect webhook: " .. tostring(err))
                end
            else
                -- Different server session within threshold
                print("[Reconnect] Different server detected!")
                print("[Reconnect] Server change reconnect detected - sending webhook")
                local sessionPreview = string.sub(tostring(currentSessionId or "unknown"), 1, 8)
                local success, err = pcall(function()
                    sendConnectionStatusWebhook("reconnected", "Reconnected to different server (New Session: " .. sessionPreview .. "..., Time: " .. tostring(timeDiff) .. "s)")
                end)
                if not success then
                    print("[Reconnect] Error sending server change webhook: " .. tostring(err))
                end
            end
        end
    else
        -- No previous session data = fresh start
        print("[Reconnect] No previous session data found - fresh start")
        local success, err = pcall(function()
            sendConnectionStatusWebhook("connected")
        end)
        if not success then
            print("[Reconnect] Error sending fresh start webhook: " .. tostring(err))
        end
    end

    -- Save current session as the new baseline
    lastSessionId = currentSessionId
    lastDisconnectTime = nil  -- Reset disconnect time since we're connected
    print("[Reconnect] Initialization complete!")
end

-- Send connection status notification when script starts
task.spawn(function()
    -- Wait a bit to ensure all services are loaded
    print("[Reconnect] Starting initialization after 2 second delay...")
    task.wait(2)

    -- Debug: Check if function exists
    print("[Reconnect] Function check - sendConnectionStatusWebhook exists: " .. tostring(sendConnectionStatusWebhook ~= nil))
    print("[Reconnect] Function check - sendConnectionStatusWebhook type: " .. tostring(type(sendConnectionStatusWebhook)))

    initializeReconnectDetection()
    print("✅ Auto Fish script fully initialized and connected!")
end)

local function sendDisconnectWebhook(username, reason)
    if hasSentDisconnectWebhook then
        print("[Disconnect] Webhook already sent, skipping...")
        return
    end

    print("[Disconnect] Sending disconnect webhook - Username: " .. tostring(username) .. ", Reason: " .. tostring(reason))
    hasSentDisconnectWebhook = true

    -- Stop online status timer and update to offline
    pcall(stopOnlineStatusTimer)

    -- Save session data before disconnect for reconnect detection
    pcall(function()
        saveSessionData(game.JobId, os.time())
    end)

    -- Send disconnect notification with user tag
    pcall(function()
        sendConnectionStatusWebhook("disconnected", reason or "Unknown disconnect reason")
    end)

    print("[Disconnect] Disconnect webhook processing completed")
end

local function setupDisconnectNotifier()
    local username = LocalPlayer.Name or "Unknown"
    local GuiService = game:GetService("GuiService")

    print("[Disconnect Monitor] Setting up disconnect notifier for player: " .. username)
    print("[Disconnect Monitor] Discord ID configured: " .. tostring(DISCORD_USER_ID))
    print("[Disconnect Monitor] Webhook3 URL configured: " .. tostring(webhook3 ~= nil and "Yes" or "No"))

    -- Monitor error messages for disconnect reasons
    GuiService.ErrorMessageChanged:Connect(function(message)
        if hasSentDisconnectWebhook then return end -- Prevent multiple sends

        print("[Disconnect Monitor] Error message detected: " .. tostring(message))
        local lowerMessage = string.lower(tostring(message))
        local reason = "Unknown"

        if lowerMessage:find("disconnect") or lowerMessage:find("connection lost") or lowerMessage:find("lost connection") then
            reason = "Connection Lost: " .. message
        elseif lowerMessage:find("kick") or lowerMessage:find("banned") or lowerMessage:find("removed") then
            reason = "Kicked/Banned: " .. message
        elseif lowerMessage:find("timeout") or lowerMessage:find("timed out") then
            reason = "Connection Timeout: " .. message
        elseif lowerMessage:find("server") and lowerMessage:find("full") then
            reason = "Server Full: " .. message
        elseif lowerMessage:find("shut") or lowerMessage:find("restart") then
            reason = "Server Shutdown/Restart: " .. message
        elseif lowerMessage:find("network") then
            reason = "Network Error: " .. message
        else
            -- For debugging, log all errors but don't send webhook
            print("[Disconnect Monitor] Non-disconnect error ignored: " .. message)
            return
        end

        print("[Disconnect Monitor] Triggering disconnect webhook with reason: " .. reason)
        task.spawn(function()
            sendDisconnectWebhook(username, reason)
        end)
    end)

    -- Monitor for player removal (enhanced)
    Players.PlayerRemoving:Connect(function(removedPlayer)
        if removedPlayer == LocalPlayer then
            print("[Disconnect Monitor] LocalPlayer removal detected!")
            if not hasSentDisconnectWebhook then
                task.spawn(function()
                    sendDisconnectWebhook(username, "Player Removed from Game (Clean Disconnect)")
                end)
            end
        end
    end)

    -- Monitor for game leaving
    game:GetService("GuiService").ErrorMessageChanged:Connect(function(message)
        if message and (message:find("Leaving") or message:find("Disconnecting")) then
            print("[Disconnect Monitor] Game leaving message detected: " .. message)
            if not hasSentDisconnectWebhook then
                task.spawn(function()
                    sendDisconnectWebhook(username, "Game Leaving: " .. message)
                end)
            end
        end
    end)

    -- Monitor network ping for connection issues
    task.spawn(function()
        local consecutiveFailures = 0
        local maxConsecutiveFailures = 3  -- Fail 3 times before disconnect

        while true do
            local success, ping = pcall(function()
                return LocalPlayer:GetNetworkPing() * 1000 -- Convert to milliseconds
            end)

            if not success then
                consecutiveFailures = consecutiveFailures + 1
                print("[Disconnect Monitor] Ping check failed (" .. consecutiveFailures .. "/" .. maxConsecutiveFailures .. ")")

                if consecutiveFailures >= maxConsecutiveFailures then
                    task.spawn(function()
                        sendDisconnectWebhook(username, "Connection Lost - Multiple ping failures detected")
                    end)
                    break -- Stop monitoring after sending notification
                end
            else
                -- Reset failure counter on successful ping
                if consecutiveFailures > 0 then
                    consecutiveFailures = 0
                    print("[Disconnect Monitor] Connection recovered")
                end

                if ping > PING_THRESHOLD then
                    print("[Disconnect Monitor] High ping detected: " .. math.floor(ping) .. "ms")
                    task.spawn(function()
                        sendDisconnectWebhook(username, "High Ping Detected (" .. math.floor(ping) .. "ms) - Possible connection issue")
                    end)
                    break -- Stop monitoring after sending notification
                end
            end

            task.wait(10) -- Check every 10 seconds (reduced frequency for better performance)
        end
    end)

    -- Monitor for game freezes using Stepped delta
    RunService.Stepped:Connect(function(_, deltaTime)
        if deltaTime > FREEZE_THRESHOLD then
            print("[Disconnect Monitor] Game freeze detected! Delta: " .. string.format("%.2f", deltaTime) .. "s")
            task.spawn(function()
                sendDisconnectWebhook(username, "Game Freeze Detected (Delta: " .. string.format("%.2f", deltaTime) .. "s)")
            end)
        end
    end)

    -- Monitor for Roblox core errors
    local ScriptContext = game:GetService("ScriptContext")
    ScriptContext.Error:Connect(function(message, stack, script)
        if hasSentDisconnectWebhook then return end

        local lowerMessage = string.lower(tostring(message))
        if lowerMessage:find("disconnect") or lowerMessage:find("network") or
           lowerMessage:find("timeout") or lowerMessage:find("connection") then
            print("[Disconnect Monitor] Script error suggests disconnect: " .. tostring(message))
            task.spawn(function()
                sendDisconnectWebhook(username, "Script Error (Network/Connection): " .. tostring(message))
            end)
        end
    end)

    -- Heartbeat monitoring for complete game freeze
    local lastHeartbeat = tick()
    local heartbeatFailureCount = 0

    RunService.Heartbeat:Connect(function()
        lastHeartbeat = tick()
        heartbeatFailureCount = 0 -- Reset on successful heartbeat
    end)

    -- Check for heartbeat failures
    task.spawn(function()
        while true do
            task.wait(5) -- Check every 5 seconds
            local currentTime = tick()
            local timeSinceLastHeartbeat = currentTime - lastHeartbeat

            if timeSinceLastHeartbeat > 10 then -- If no heartbeat for 10 seconds
                heartbeatFailureCount = heartbeatFailureCount + 1
                print("[Disconnect Monitor] Heartbeat failure detected! Count: " .. heartbeatFailureCount .. ", Time since last: " .. string.format("%.2f", timeSinceLastHeartbeat) .. "s")

                if heartbeatFailureCount >= 2 and not hasSentDisconnectWebhook then
                    task.spawn(function()
                        sendDisconnectWebhook(username, "Heartbeat Failure - Game Unresponsive (" .. string.format("%.2f", timeSinceLastHeartbeat) .. "s)")
                    end)
                    break
                end
            end
        end
    end)

    -- Emergency disconnect detection via workspace monitoring
    local workspaceConnection
    workspaceConnection = workspace.ChildAdded:Connect(function()
        -- This connection will be severed on disconnect
        -- If we lose connection, this won't fire
    end)

    -- Monitor workspace connection loss
    task.spawn(function()
        task.wait(10) -- Wait for initialization
        local lastWorkspaceCheck = tick()

        while true do
            task.wait(15) -- Check every 15 seconds

            pcall(function()
                -- Try to access workspace - this will fail on disconnect
                local _ = workspace.Name
                lastWorkspaceCheck = tick()
            end)

            local currentTime = tick()
            if currentTime - lastWorkspaceCheck > 30 and not hasSentDisconnectWebhook then
                print("[Disconnect Monitor] Workspace access failure detected!")
                task.spawn(function()
                    sendDisconnectWebhook(username, "Workspace Access Failure - Likely Disconnected")
                end)
                break
            end
        end
    end)

    print("🚨 Advanced disconnect notifier setup complete")
    print("[Disconnect Monitor] All monitoring systems active:")
    print("  - Error message monitoring: ✅")
    print("  - Player removal monitoring: ✅")
    print("  - Network ping monitoring: ✅")
    print("  - Game freeze detection: ✅")
    print("  - Script error monitoring: ✅")
    print("  - Heartbeat monitoring: ✅")
    print("  - Workspace monitoring: ✅")
end

-- Initialize Discord mention validation
print("⏳ [Auto Fish] Validating Discord configuration...")
local discordValid = pcall(validateDiscordMention)
if discordValid then
    print("✅ [Auto Fish] Discord configuration validated")
else
    warn("⚠️ [Auto Fish] Discord configuration validation failed")
end

-- Initialize disconnect notifier
print("⏳ [Auto Fish] Setting up disconnect monitor...")
local monitorSuccess = pcall(setupDisconnectNotifier)
if monitorSuccess then
    print("✅ [Auto Fish] Disconnect monitor ready")
else
    warn("⚠️ [Auto Fish] Disconnect monitor setup failed")
end

-- Auto-run test untuk memastikan sistem berfungsi (uncomment untuk testing)
-- task.spawn(function()
--     task.wait(5) -- Wait 5 seconds after startup
--     print("[AUTO TEST] Running disconnect notification test...")
--     testDisconnectNotification()
-- end)

-- ====== ONLINE STATUS TIMER SYSTEM ======
-- Timer untuk update status online setiap 8 detik
local function startOnlineStatusTimer()
    print("[Online Status] Starting timer system...")
    isOnlineStatusActive = true

    -- Initial status message
    task.spawn(function()
        task.wait(3) -- Wait for everything to load
        updateOnlineStatus()
    end)

    -- Regular updates every 8 seconds
    task.spawn(function()
        while isOnlineStatusActive do
            task.wait(ONLINE_STATUS_UPDATE_INTERVAL)

            if isOnlineStatusActive then
                local currentTime = tick()
                if currentTime - lastOnlineStatusUpdate >= ONLINE_STATUS_UPDATE_INTERVAL then
                    local success = updateOnlineStatus()
                    if success then
                        lastOnlineStatusUpdate = currentTime
                    end
                end
            end
        end
    end)
end

-- Function untuk stop online status updates (saat disconnect)
local function stopOnlineStatusTimer()
    print("[Online Status] Stopping timer system...")
    isOnlineStatusActive = false

    -- Update message to show offline status
    local accountId = tostring(LocalPlayer.UserId)
    local existingMessageId = getStoredMessageId(accountId)

    if existingMessageId then
        local uptime = os.time() - startTime
        local fishCount = (LocalPlayer.leaderstats and LocalPlayer.leaderstats.Caught and LocalPlayer.leaderstats.Caught.Value) or 0
        local bestFish = (LocalPlayer.leaderstats and LocalPlayer.leaderstats["Rarest Fish"] and LocalPlayer.leaderstats["Rarest Fish"].Value) or "None"

        local offlineEmbed = {
            title = "🔴 " .. (LocalPlayer.DisplayName or LocalPlayer.Name) .. " - OFFLINE",
            description = "**Status**: Disconnected from game",
            color = 16711680, -- Red
            fields = {
                { name = "⏰ Disconnected At", value = os.date("%H:%M:%S"), inline = true },
                { name = "⌛ Session Duration", value = FormatTime(uptime), inline = true },
                { name = "🐠 Total Fish", value = FormatNumber(fishCount), inline = true },
                { name = "🏆 Best Fish", value = bestFish, inline = true },
                { name = "💰 Final Coins", value = FormatNumber(getCurrentCoins()), inline = true },
                { name = "⭐ Final Level", value = getCurrentLevel(), inline = true },
            },
            footer = { text = "Auto Fish Status • Player Disconnected" },
            timestamp = os.date("!%Y-%m-%dT%H:%M:%S.000Z")
        }

        local success, err = editDiscordMessage(existingMessageId, offlineEmbed, "")
        if success then
            print("[Online Status] Updated message to offline status")
        else
            print("[Online Status] Failed to update offline status: " .. tostring(err))
        end
    end
end

-- Start the online status timer
startOnlineStatusTimer()

-- ====== TEST FUNCTIONS & ERROR HANDLING ======
-- TEST FUNCTIONS untuk testing sistem online status baru
local function testOnlineStatusUpdate()
    print("[TEST] Testing online status update...")
    local success = updateOnlineStatus()
    if success then
        print("[TEST] ✅ Online status update test PASSED")
    else
        print("[TEST] ❌ Online status update test FAILED")
    end
end

local function testOfflineStatusUpdate()
    print("[TEST] Testing offline status update...")
    stopOnlineStatusTimer()
    print("[TEST] ✅ Offline status update test completed")
end

-- TEST FUNCTIONS untuk testing notification dengan tags
local function testDisconnectNotification()
    print("[TEST] 🧪 Testing disconnect notification with tags...")
    print("[TEST] - Discord User ID: " .. tostring(DISCORD_USER_ID))
    print("[TEST] - Webhook3 URL: " .. tostring(CONNECTION_WEBHOOK_URL ~= "" and "Configured" or "NOT CONFIGURED"))
    sendConnectionStatusWebhook("disconnected", "TEST: Manual disconnect test - Tag system check for User ID " .. tostring(DISCORD_USER_ID))
end

local function testReconnectNotification()
    print("[TEST] 🧪 Testing reconnect notification with tags...")
    print("[TEST] - Discord User ID: " .. tostring(DISCORD_USER_ID))
    print("[TEST] - Webhook3 URL: " .. tostring(CONNECTION_WEBHOOK_URL ~= "" and "Configured" or "NOT CONFIGURED"))
    sendConnectionStatusWebhook("reconnected", "TEST: Manual reconnect test - Tag system check for User ID " .. tostring(DISCORD_USER_ID))
end

-- Test function untuk validasi Discord mention format
local function validateDiscordMention()
    local userIdStr = tostring(DISCORD_USER_ID)
    local mentionFormat = "<@" .. userIdStr .. ">"

    print("[VALIDATION] 🔍 Discord Mention Validation:")
    print("  - Raw User ID: " .. userIdStr)
    print("  - User ID Length: " .. string.len(userIdStr))
    print("  - Mention Format: " .. mentionFormat)
    print("  - Is Numeric: " .. tostring(tonumber(userIdStr) ~= nil))
    print("  - Valid Length (should be 17-19): " .. tostring(string.len(userIdStr) >= 17 and string.len(userIdStr) <= 19))

    -- Test allowed_mentions structure
    local testAllowedMentions = {
        parse = {},
        users = {userIdStr},
        roles = {}
    }
    print("  - Test allowed_mentions JSON: " .. HttpService:JSONEncode(testAllowedMentions))

    return userIdStr
end

-- ERROR HANDLING untuk webhook failures
local function handleWebhookError(errorType, error)
    print("[Error Handler] " .. errorType .. " failed: " .. tostring(error))

    -- Retry logic untuk critical errors
    if errorType == "online_status" then
        task.spawn(function()
            task.wait(30) -- Wait 30 seconds before retry
            print("[Error Handler] Retrying online status update...")
            updateOnlineStatus()
        end)
    end
end

-- Debug function untuk check message IDs
local function debugMessageStorage()
    print("[DEBUG] Current message storage:")
    for accountId, data in pairs(MESSAGE_ID_STORAGE) do
        print("  Account " .. accountId .. ": " .. tostring(data.statusMessageId))
    end
end

-- ====== OPTIMIZATIONS SUMMARY ======
-- Optimizations made to fix "Out of local registers" error:
-- 1. Converted local variables to global: MESSAGE_ID_STORAGE, upgradeState, etc.
-- 2. Compacted functions: editDiscordMessage, sendNewStatusMessage, updateOnlineStatus
-- 3. Added createInstance helper to reduce Instance.new() local variables
-- 4. Simplified conditionals and reduced temporary variables
-- 5. Converted function declarations from local to global where possible

-- ENABLE untuk test functions (uncomment untuk testing):
--[[ DISABLED - Remove test functions untuk production
task.spawn(function()
    task.wait(10)
    print("[TEST] Starting online status tests in 10 seconds...")
    testOnlineStatusUpdate()
    task.wait(5)
    debugMessageStorage()
end)
--]]

-- Quick test untuk verify optimizations worked
print("✅ Script optimizations loaded successfully - Local register usage reduced")


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

local function setAutoFishDelayForKohana()
    if autoFishMainSlider then
        autoFishMainSlider:Set(5)
    else
        setAutoFishMainDelay(5)
    end
    print("[Preset] Auto Fish Delay set to 5 seconds for Kohana")
end

local function setDelaysForPreset(presetKey)
    if presetKey == "auto1" or presetKey == "auto2" then
        -- Auto 1 dan Auto 2: Auto Fish Delay 0.1s, Auto Catch Delay 0.1s
        if autoFishMainSlider then
            autoFishMainSlider:Set(0.1)
        else
            setAutoFishMainDelay(0.1)
        end
        if autoCatchSlider then
            autoCatchSlider:Set(0.1)
        else
            setAutoCatchDelay(0.1)
        end
        print("[Preset] Set delays for " .. presetKey .. ": Fish=0.1s, Catch=0.1s")
    elseif presetKey == "auto3" then
        -- Auto 3: Auto Fish Delay 5s, Auto Catch Delay 0.6s
        if autoFishMainSlider then
            autoFishMainSlider:Set(5)
        else
            setAutoFishMainDelay(5)
        end
        if autoCatchSlider then
            autoCatchSlider:Set(0.6)
        else
            setAutoCatchDelay(0.6)
        end
        print("[Preset] Set delays for " .. presetKey .. ": Fish=5s, Catch=0.6s")
    end
end


-- ====== ENHANCED MOBILE UI LIBRARY ======
-- Helper function to create instances efficiently
function createInstance(className, properties, parent)
    local obj = Instance.new(className)
    for prop, value in pairs(properties or {}) do
        obj[prop] = value
    end
    if parent then obj.Parent = parent end
    return obj
end

local Library = {}
do
    -- Get screen size for responsive design
    local function getScreenSize()
        local viewport = workspace.CurrentCamera.ViewportSize
        return viewport.X, viewport.Y
    end

    -- Responsive sizing based on screen
    local function getResponsiveSize()
        local screenX, screenY = getScreenSize()
        local isMobile = screenX < 800 or screenY < 600

        if isMobile then
            return {
                windowWidth = math.min(screenX * 0.95, 400),
                windowHeight = math.min(screenY * 0.85, 500),
                titleSize = 16,
                textSize = 13,
                buttonHeight = 35,
                padding = 8
            }
        else
            return {
                windowWidth = 480,
                windowHeight = 580,
                titleSize = 18,
                textSize = 14,
                buttonHeight = 38,
                padding = 12
            }
        end
    end

    local function createRow(sectionFrame, titleText, descriptionText)
        local responsive = getResponsiveSize()

        local row = Instance.new("Frame")
        row.Name = ("Row_%s"):format(titleText:gsub("%s", ""))
        row.BackgroundColor3 = Color3.fromRGB(28, 28, 28)
        row.BackgroundTransparency = 0
        row.AutomaticSize = Enum.AutomaticSize.Y
        row.Size = UDim2.new(1, 0, 0, math.max(50, responsive.buttonHeight + 20))
        row.Parent = sectionFrame
        row.ClipsDescendants = false

        local rowCorner = Instance.new("UICorner")
        rowCorner.CornerRadius = UDim.new(0, 8)
        rowCorner.Parent = row

        local rowStroke = Instance.new("UIStroke")
        rowStroke.Color = Color3.fromRGB(45, 45, 45)
        rowStroke.Thickness = 1
        rowStroke.Parent = row

        local padding = Instance.new("UIPadding")
        padding.PaddingLeft = UDim.new(0, responsive.padding)
        padding.PaddingRight = UDim.new(0, responsive.padding)
        padding.PaddingTop = UDim.new(0, responsive.padding)
        padding.PaddingBottom = UDim.new(0, responsive.padding)
        padding.Parent = row

        local infoFrame = Instance.new("Frame")
        infoFrame.Name = "Info"
        infoFrame.BackgroundTransparency = 1
        infoFrame.Size = UDim2.new(1, -120, 1, 0)
        infoFrame.Position = UDim2.new(0, 0, 0, 0)
        infoFrame.Parent = row

        local infoLayout = Instance.new("UIListLayout")
        infoLayout.FillDirection = Enum.FillDirection.Vertical
        infoLayout.SortOrder = Enum.SortOrder.LayoutOrder
        infoLayout.Padding = UDim.new(0, 2)
        infoLayout.VerticalAlignment = Enum.VerticalAlignment.Center
        infoLayout.Parent = infoFrame

        local title = Instance.new("TextLabel")
        title.Name = "Title"
        title.BackgroundTransparency = 1
        title.AutomaticSize = Enum.AutomaticSize.Y
        title.Size = UDim2.new(1, 0, 0, 0)
        title.Font = Enum.Font.GothamSemibold
        title.Text = titleText
        title.TextColor3 = Color3.fromRGB(255, 255, 255)
        title.TextSize = responsive.textSize + 1
        title.TextWrapped = true
        title.TextXAlignment = Enum.TextXAlignment.Left
        title.TextYAlignment = Enum.TextYAlignment.Top
        title.Parent = infoFrame

        if descriptionText and descriptionText ~= "" then
            local description = Instance.new("TextLabel")
            description.Name = "Description"
            description.BackgroundTransparency = 1
            description.AutomaticSize = Enum.AutomaticSize.Y
            description.Size = UDim2.new(1, 0, 0, 0)
            description.Font = Enum.Font.Gotham
            description.Text = descriptionText
            description.TextColor3 = Color3.fromRGB(180, 180, 180)
            description.TextSize = responsive.textSize - 1
            description.TextWrapped = true
            description.TextXAlignment = Enum.TextXAlignment.Left
            description.TextYAlignment = Enum.TextYAlignment.Top
            description.Parent = infoFrame
        end

        local actionContainer = Instance.new("Frame")
        actionContainer.Name = "Action"
        actionContainer.BackgroundTransparency = 1
        actionContainer.Size = UDim2.new(0, 110, 0, responsive.buttonHeight)
        actionContainer.AnchorPoint = Vector2.new(1, 0.5)
        actionContainer.Position = UDim2.new(1, 0, 0.5, 0)
        actionContainer.Parent = row

        return row, actionContainer
    end

    local function createWindow(titleText)
        local coreGui = game:GetService("CoreGui")
        local userInputService = game:GetService("UserInputService")
        local responsive = getResponsiveSize()

        -- Clean up any existing UI
        local existingGui = coreGui:FindFirstChild("AF_MobileUI")
        if existingGui then
            existingGui:Destroy()
        end

        local screenGui = Instance.new("ScreenGui")
        screenGui.Name = "AF_MobileUI"
        screenGui.ResetOnSpawn = false
        screenGui.IgnoreGuiInset = true
        screenGui.DisplayOrder = 1000
        screenGui.Parent = coreGui

        local mainFrame = Instance.new("Frame")
        mainFrame.Name = "MainFrame"
        mainFrame.Size = UDim2.new(0, responsive.windowWidth, 0, responsive.windowHeight)
        mainFrame.Position = UDim2.new(0.5, -responsive.windowWidth/2, 0.5, -responsive.windowHeight/2)
        mainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
        mainFrame.Parent = screenGui
        mainFrame.Active = true
        mainFrame.ClipsDescendants = true

        local mainCorner = Instance.new("UICorner")
        mainCorner.CornerRadius = UDim.new(0, 12)
        mainCorner.Parent = mainFrame

        local mainStroke = Instance.new("UIStroke")
        mainStroke.Color = Color3.fromRGB(50, 50, 50)
        mainStroke.Thickness = 2
        mainStroke.Parent = mainFrame

        local topBar = Instance.new("Frame")
        topBar.Name = "TopBar"
        topBar.Size = UDim2.new(1, 0, 0, 45)
        topBar.BackgroundColor3 = Color3.fromRGB(22, 22, 22)
        topBar.Parent = mainFrame
        topBar.Active = true

        local topCorner = Instance.new("UICorner")
        topCorner.CornerRadius = UDim.new(0, 12)
        topCorner.Parent = topBar

        local topStroke = Instance.new("UIStroke")
        topStroke.Color = Color3.fromRGB(60, 60, 60)
        topStroke.Thickness = 1
        topStroke.Parent = topBar

        local topPadding = Instance.new("UIPadding")
        topPadding.PaddingLeft = UDim.new(0, 15)
        topPadding.PaddingRight = UDim.new(0, 15)
        topPadding.PaddingTop = UDim.new(0, 8)
        topPadding.PaddingBottom = UDim.new(0, 8)
        topPadding.Parent = topBar

        local titleLabel = Instance.new("TextLabel")
        titleLabel.Name = "Title"
        titleLabel.BackgroundTransparency = 1
        titleLabel.Size = UDim2.new(1, -60, 1, 0)
        titleLabel.Position = UDim2.new(0, 0, 0, 0)
        titleLabel.Font = Enum.Font.GothamBold
        titleLabel.Text = titleText or "Auto Fish v6.2"
        titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        titleLabel.TextSize = responsive.titleSize
        titleLabel.TextXAlignment = Enum.TextXAlignment.Left
        titleLabel.TextYAlignment = Enum.TextYAlignment.Center
        titleLabel.Parent = topBar

        -- Minimize button
        local minimizeButton = Instance.new("TextButton")
        minimizeButton.Name = "MinimizeButton"
        minimizeButton.Size = UDim2.new(0, 30, 0, 30)
        minimizeButton.Position = UDim2.new(1, -70, 0.5, -15)
        minimizeButton.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
        minimizeButton.Text = "−"
        minimizeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
        minimizeButton.TextSize = 18
        minimizeButton.Font = Enum.Font.GothamBold
        minimizeButton.Parent = topBar

        local minimizeCorner = Instance.new("UICorner")
        minimizeCorner.CornerRadius = UDim.new(0, 6)
        minimizeCorner.Parent = minimizeButton

        -- Close button
        local closeButton = Instance.new("TextButton")
        closeButton.Name = "CloseButton"
        closeButton.Size = UDim2.new(0, 30, 0, 30)
        closeButton.Position = UDim2.new(1, -35, 0.5, -15)
        closeButton.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
        closeButton.Text = "×"
        closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
        closeButton.TextSize = 18
        closeButton.Font = Enum.Font.GothamBold
        closeButton.Parent = topBar

        local closeCorner = Instance.new("UICorner")
        closeCorner.CornerRadius = UDim.new(0, 6)
        closeCorner.Parent = closeButton

        local tabContainer = Instance.new("Frame")
        tabContainer.Name = "TabContainer"
        tabContainer.BackgroundTransparency = 1
        tabContainer.Size = UDim2.new(1, 0, 0, 40)
        tabContainer.Position = UDim2.new(0, 0, 0, 45)
        tabContainer.Parent = mainFrame

        local tabBar = Instance.new("Frame")
        tabBar.Name = "TabBar"
        tabBar.BackgroundTransparency = 1
        tabBar.Size = UDim2.new(1, -20, 1, 0)
        tabBar.Position = UDim2.new(0, 10, 0, 0)
        tabBar.Parent = tabContainer

        local tabScrollFrame = Instance.new("ScrollingFrame")
        tabScrollFrame.Name = "TabScroll"
        tabScrollFrame.BackgroundTransparency = 1
        tabScrollFrame.Size = UDim2.new(1, 0, 1, 0)
        tabScrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
        tabScrollFrame.AutomaticCanvasSize = Enum.AutomaticSize.X
        tabScrollFrame.ScrollingDirection = Enum.ScrollingDirection.X
        tabScrollFrame.ScrollBarThickness = 0
        tabScrollFrame.Parent = tabBar

        local tabLayout = Instance.new("UIListLayout")
        tabLayout.FillDirection = Enum.FillDirection.Horizontal
        tabLayout.SortOrder = Enum.SortOrder.LayoutOrder
        tabLayout.Padding = UDim.new(0, 5)
        tabLayout.Parent = tabScrollFrame

        local contentFrame = Instance.new("Frame")
        contentFrame.Name = "Content"
        contentFrame.BackgroundTransparency = 1
        contentFrame.Size = UDim2.new(1, -20, 1, -95)
        contentFrame.Position = UDim2.new(0, 10, 0, 85)
        contentFrame.Parent = mainFrame

        local pageLayout = Instance.new("UIPageLayout")
        pageLayout.FillDirection = Enum.FillDirection.Horizontal
        pageLayout.SortOrder = Enum.SortOrder.LayoutOrder
        pageLayout.TweenTime = 0.15
        pageLayout.EasingStyle = Enum.EasingStyle.Quad
        pageLayout.EasingDirection = Enum.EasingDirection.Out
        pageLayout.Parent = contentFrame

        local window = {
            _screenGui = screenGui,
            _mainFrame = mainFrame,
            _pageLayout = pageLayout,
            _tabButtons = {},
            _tabPages = {},
            _currentTab = nil,
            _tabScrollFrame = tabScrollFrame,
            _closeButton = closeButton,
            _minimizeButton = minimizeButton,
            _contentFrame = contentFrame,
            _tabContainer = tabContainer,
            _isMinimized = false,
            _originalHeight = responsive.windowHeight,
        }

        -- Enhanced drag system
        local dragging = false
        local dragStart, startPos

        local function beginDrag(input)
            if input.Position.X > minimizeButton.AbsolutePosition.X then
                return -- Don't drag if clicking minimize or close button
            end

            dragging = true
            dragStart = input.Position
            startPos = mainFrame.Position

            local changeConn
            changeConn = input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                    if changeConn then
                        changeConn:Disconnect()
                    end
                end
            end)
        end

        topBar.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                beginDrag(input)
            end
        end)

        userInputService.InputChanged:Connect(function(input)
            if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                local delta = input.Position - dragStart
                local newPosX = math.clamp(startPos.X.Offset + delta.X, 0, getScreenSize() - responsive.windowWidth)
                local newPosY = math.clamp(startPos.Y.Offset + delta.Y, 0, getScreenSize() - responsive.windowHeight)

                mainFrame.Position = UDim2.new(0, newPosX, 0, newPosY)
            end
        end)

        -- Close button functionality
        closeButton.MouseButton1Click:Connect(function()
            window:ToggleUI(false)
        end)

        closeButton.MouseEnter:Connect(function()
            closeButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
        end)

        closeButton.MouseLeave:Connect(function()
            closeButton.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
        end)

        -- Minimize button functionality
        minimizeButton.MouseButton1Click:Connect(function()
            window:MinimizeUI()
        end)

        minimizeButton.MouseEnter:Connect(function()
            minimizeButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
        end)

        minimizeButton.MouseLeave:Connect(function()
            minimizeButton.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
        end)

        local function highlightTab(tabName)
            for name, button in pairs(window._tabButtons) do
                if name == tabName then
                    button.BackgroundColor3 = Color3.fromRGB(50, 130, 245)
                    button.TextColor3 = Color3.fromRGB(255, 255, 255)
                    -- Add selection indicator
                    if not button:FindFirstChild("SelectionIndicator") then
                        local indicator = Instance.new("Frame")
                        indicator.Name = "SelectionIndicator"
                        indicator.Size = UDim2.new(1, 0, 0, 2)
                        indicator.Position = UDim2.new(0, 0, 1, -2)
                        indicator.BackgroundColor3 = Color3.fromRGB(70, 150, 255)
                        indicator.BorderSizePixel = 0
                        indicator.Parent = button
                    end
                else
                    button.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
                    button.TextColor3 = Color3.fromRGB(180, 180, 180)
                    -- Remove selection indicator
                    local indicator = button:FindFirstChild("SelectionIndicator")
                    if indicator then
                        indicator:Destroy()
                    end
                end
            end
        end

        function window:ShowTab(tabName)
            local targetPage = self._tabPages[tabName]
            if not targetPage then return end
            self._pageLayout:JumpTo(targetPage)
            highlightTab(tabName)
            self._currentTab = tabName
        end

        function window:ToggleUI(force)
            if typeof(force) == "boolean" then
                self._screenGui.Enabled = force
            else
                self._screenGui.Enabled = not self._screenGui.Enabled
            end
            return self._screenGui.Enabled
        end

        function window:MinimizeUI(force)
            if typeof(force) == "boolean" then
                self._isMinimized = force
            else
                self._isMinimized = not self._isMinimized
            end

            if self._isMinimized then
                -- Minimize: hide content and resize to just title bar
                self._contentFrame.Visible = false
                self._tabContainer.Visible = false
                self._mainFrame.Size = UDim2.new(0, self._mainFrame.Size.X.Offset, 0, 45)
                self._minimizeButton.Text = "+"
            else
                -- Restore: show content and restore original size
                self._contentFrame.Visible = true
                self._tabContainer.Visible = true
                self._mainFrame.Size = UDim2.new(0, self._mainFrame.Size.X.Offset, 0, self._originalHeight)
                self._minimizeButton.Text = "−"
            end

            return self._isMinimized
        end

        function window:NewTab(tabName)
            local responsive = getResponsiveSize()

            local tabButton = Instance.new("TextButton")
            tabButton.Name = ("Tab_%s"):format(tabName:gsub("%s", ""))
            tabButton.Size = UDim2.new(0, math.max(100, #tabName * 8 + 20), 0, 32)
            tabButton.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
            tabButton.TextColor3 = Color3.fromRGB(180, 180, 180)
            tabButton.Font = Enum.Font.GothamSemibold
            tabButton.TextSize = responsive.textSize
            tabButton.AutoButtonColor = false
            tabButton.Text = tabName
            tabButton.Parent = tabScrollFrame

            local tabCorner = Instance.new("UICorner")
            tabCorner.CornerRadius = UDim.new(0, 6)
            tabCorner.Parent = tabButton

            local tabStroke = Instance.new("UIStroke")
            tabStroke.Color = Color3.fromRGB(55, 55, 55)
            tabStroke.Thickness = 1
            tabStroke.Parent = tabButton

            -- Tab hover effects
            tabButton.MouseEnter:Connect(function()
                if window._currentTab ~= tabName then
                    tabButton.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
                end
            end)

            tabButton.MouseLeave:Connect(function()
                if window._currentTab ~= tabName then
                    tabButton.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
                end
            end)

            local page = Instance.new("ScrollingFrame")
            page.Name = ("Page_%s"):format(tabName)
            page.Active = true
            page.AutomaticCanvasSize = Enum.AutomaticSize.Y
            page.CanvasSize = UDim2.new(0, 0, 0, 0)
            page.ScrollBarThickness = responsive.padding / 2
            page.ScrollingDirection = Enum.ScrollingDirection.Y
            page.BackgroundTransparency = 1
            page.BorderSizePixel = 0
            page.TopImage = "rbxasset://textures/ui/Scroll/scroll-middle.png"
            page.BottomImage = "rbxasset://textures/ui/Scroll/scroll-middle.png"
            page.MidImage = "rbxasset://textures/ui/Scroll/scroll-middle.png"
            page.ScrollBarImageColor3 = Color3.fromRGB(80, 80, 80)
            page.Size = UDim2.new(1, 0, 1, 0)
            page.Parent = contentFrame

            local pagePadding = Instance.new("UIPadding")
            pagePadding.PaddingLeft = UDim.new(0, responsive.padding)
            pagePadding.PaddingRight = UDim.new(0, responsive.padding)
            pagePadding.PaddingTop = UDim.new(0, responsive.padding)
            pagePadding.PaddingBottom = UDim.new(0, responsive.padding * 2)
            pagePadding.Parent = page

            local pageLayoutList = Instance.new("UIListLayout")
            pageLayoutList.FillDirection = Enum.FillDirection.Vertical
            pageLayoutList.SortOrder = Enum.SortOrder.LayoutOrder
            pageLayoutList.Padding = UDim.new(0, responsive.padding)
            pageLayoutList.Parent = page

            self._tabButtons[tabName] = tabButton
            self._tabPages[tabName] = page

            tabButton.MouseButton1Click:Connect(function()
                self:ShowTab(tabName)
            end)

            local tab = {}

            function tab:NewSection(sectionName)
                local responsive = getResponsiveSize()

                local sectionFrame = Instance.new("Frame")
                sectionFrame.Name = ("Section_%s"):format(sectionName:gsub("%s", ""))
                sectionFrame.AutomaticSize = Enum.AutomaticSize.Y
                sectionFrame.Size = UDim2.new(1, 0, 0, 0)
                sectionFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
                sectionFrame.Parent = page

                local sectionCorner = Instance.new("UICorner")
                sectionCorner.CornerRadius = UDim.new(0, 8)
                sectionCorner.Parent = sectionFrame

                local sectionStroke = Instance.new("UIStroke")
                sectionStroke.Color = Color3.fromRGB(40, 40, 40)
                sectionStroke.Thickness = 1
                sectionStroke.Parent = sectionFrame

                local sectionPadding = Instance.new("UIPadding")
                sectionPadding.PaddingLeft = UDim.new(0, responsive.padding)
                sectionPadding.PaddingRight = UDim.new(0, responsive.padding)
                sectionPadding.PaddingTop = UDim.new(0, responsive.padding)
                sectionPadding.PaddingBottom = UDim.new(0, responsive.padding)
                sectionPadding.Parent = sectionFrame

                local sectionLayout = Instance.new("UIListLayout")
                sectionLayout.FillDirection = Enum.FillDirection.Vertical
                sectionLayout.SortOrder = Enum.SortOrder.LayoutOrder
                sectionLayout.Padding = UDim.new(0, responsive.padding / 2)
                sectionLayout.Parent = sectionFrame

                local header = Instance.new("TextLabel")
                header.Name = "Header"
                header.BackgroundTransparency = 1
                header.AutomaticSize = Enum.AutomaticSize.Y
                header.Size = UDim2.new(1, 0, 0, 0)
                header.Font = Enum.Font.GothamBold
                header.Text = sectionName
                header.TextColor3 = Color3.fromRGB(255, 255, 255)
                header.TextSize = responsive.titleSize - 1
                header.TextXAlignment = Enum.TextXAlignment.Left
                header.TextYAlignment = Enum.TextYAlignment.Top
                header.TextWrapped = true
                header.Parent = sectionFrame

                local section = {}
                function section:NewToggle(title, description, callback)
                    local responsive = getResponsiveSize()
                    local _, actionContainer = createRow(sectionFrame, title, description)

                    local toggleButton = Instance.new("TextButton")
                    toggleButton.Name = "ToggleButton"
                    toggleButton.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
                    toggleButton.TextColor3 = Color3.fromRGB(220, 220, 220)
                    toggleButton.Font = Enum.Font.GothamSemibold
                    toggleButton.TextSize = responsive.textSize
                    toggleButton.Text = "OFF"
                    toggleButton.Size = UDim2.new(1, 0, 1, 0)
                    toggleButton.AutoButtonColor = false
                    toggleButton.Parent = actionContainer

                    local corner = Instance.new("UICorner")
                    corner.CornerRadius = UDim.new(0, 6)
                    corner.Parent = toggleButton

                    local stroke = Instance.new("UIStroke")
                    stroke.Color = Color3.fromRGB(65, 65, 65)
                    stroke.Thickness = 1
                    stroke.Parent = toggleButton

                    local toggler = { state = false }

                    local function updateVisual(state)
                        toggleButton.Text = state and "ON" or "OFF"
                        if state then
                            toggleButton.BackgroundColor3 = Color3.fromRGB(50, 130, 245)
                            stroke.Color = Color3.fromRGB(70, 150, 255)
                        else
                            toggleButton.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
                            stroke.Color = Color3.fromRGB(65, 65, 65)
                        end
                    end

                    -- Add hover effects
                    toggleButton.MouseEnter:Connect(function()
                        if toggler.state then
                            toggleButton.BackgroundColor3 = Color3.fromRGB(60, 140, 255)
                        else
                            toggleButton.BackgroundColor3 = Color3.fromRGB(55, 55, 55)
                        end
                    end)

                    toggleButton.MouseLeave:Connect(function()
                        updateVisual(toggler.state)
                    end)

                    function toggler:SetState(state, skipCallback)
                        state = not not state
                        if self.state == state then return end
                        self.state = state
                        updateVisual(state)
                        if not skipCallback and callback then
                            local ok, err = pcall(callback, state)
                            if not ok then
                                warn("[Auto Fish UI] Toggle callback error: " .. tostring(err))
                            end
                        end
                    end

                    toggleButton.MouseButton1Click:Connect(function()
                        toggler:SetState(not toggler.state)
                    end)

                    function toggler:UpdateToggle(_, state)
                        self:SetState(state)
                    end

                    updateVisual(false)
                    return toggler
                end

                function section:NewButton(title, description, callback)
                    local responsive = getResponsiveSize()
                    local _, actionContainer = createRow(sectionFrame, title, description)

                    local button = Instance.new("TextButton")
                    button.Name = "ActionButton"
                    button.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
                    button.TextColor3 = Color3.fromRGB(255, 255, 255)
                    button.Font = Enum.Font.GothamSemibold
                    button.Text = "RUN"
                    button.TextSize = responsive.textSize
                    button.AutoButtonColor = false
                    button.Size = UDim2.new(1, 0, 1, 0)
                    button.Parent = actionContainer

                    local corner = Instance.new("UICorner")
                    corner.CornerRadius = UDim.new(0, 6)
                    corner.Parent = button

                    local stroke = Instance.new("UIStroke")
                    stroke.Color = Color3.fromRGB(80, 80, 80)
                    stroke.Thickness = 1
                    stroke.Parent = button

                    -- Button hover effects
                    button.MouseEnter:Connect(function()
                        button.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
                    end)

                    button.MouseLeave:Connect(function()
                        button.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
                    end)

                    button.MouseButton1Click:Connect(function()
                        if not callback then return end
                        local ok, err = pcall(callback)
                        if not ok then
                            warn("[Auto Fish UI] Button callback error: " .. tostring(err))
                        end
                    end)

                    return button
                end

                function section:NewDropdown(title, description, options, callback)
                    local responsive = getResponsiveSize()
                    local row, actionContainer = createRow(sectionFrame, title, description)

                    local dropdownButton = Instance.new("TextButton")
                    dropdownButton.Name = "DropdownButton"
                    dropdownButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
                    dropdownButton.TextColor3 = Color3.fromRGB(255, 255, 255)
                    dropdownButton.Font = Enum.Font.GothamSemibold
                    dropdownButton.TextSize = responsive.textSize
                    dropdownButton.Text = (options and options[1]) or "Select"
                    dropdownButton.AutoButtonColor = false
                    dropdownButton.Size = UDim2.new(1, 0, 1, 0)
                    dropdownButton.Parent = actionContainer

                    local corner = Instance.new("UICorner")
                    corner.CornerRadius = UDim.new(0, 6)
                    corner.Parent = dropdownButton

                    local stroke = Instance.new("UIStroke")
                    stroke.Color = Color3.fromRGB(70, 70, 70)
                    stroke.Thickness = 1
                    stroke.Parent = dropdownButton

                    -- Dropdown arrow indicator
                    local arrow = Instance.new("TextLabel")
                    arrow.Name = "Arrow"
                    arrow.BackgroundTransparency = 1
                    arrow.Size = UDim2.new(0, 20, 1, 0)
                    arrow.Position = UDim2.new(1, -20, 0, 0)
                    arrow.Text = "▼"
                    arrow.TextColor3 = Color3.fromRGB(180, 180, 180)
                    arrow.TextSize = responsive.textSize - 2
                    arrow.Font = Enum.Font.Gotham
                    arrow.TextXAlignment = Enum.TextXAlignment.Center
                    arrow.Parent = dropdownButton

                    local optionsFrame = Instance.new("Frame")
                    optionsFrame.Name = "Options"
                    optionsFrame.Visible = false
                    optionsFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
                    optionsFrame.Position = UDim2.new(1, -5, 1, 5)
                    optionsFrame.AnchorPoint = Vector2.new(1, 0)
                    optionsFrame.AutomaticSize = Enum.AutomaticSize.Y
                    optionsFrame.Size = UDim2.new(0, 150, 0, 0)
                    optionsFrame.Parent = row
                    optionsFrame.ZIndex = 10

                    local optionsCorner = Instance.new("UICorner")
                    optionsCorner.CornerRadius = UDim.new(0, 6)
                    optionsCorner.Parent = optionsFrame

                    local optionsStroke = Instance.new("UIStroke")
                    optionsStroke.Color = Color3.fromRGB(60, 60, 60)
                    optionsStroke.Thickness = 1
                    optionsStroke.Parent = optionsFrame

                    local optionsLayout = Instance.new("UIListLayout")
                    optionsLayout.FillDirection = Enum.FillDirection.Vertical
                    optionsLayout.SortOrder = Enum.SortOrder.LayoutOrder
                    optionsLayout.Padding = UDim.new(0, 2)
                    optionsLayout.Parent = optionsFrame

                    local optionsPadding = Instance.new("UIPadding")
                    optionsPadding.PaddingLeft = UDim.new(0, 6)
                    optionsPadding.PaddingRight = UDim.new(0, 6)
                    optionsPadding.PaddingTop = UDim.new(0, 6)
                    optionsPadding.PaddingBottom = UDim.new(0, 6)
                    optionsPadding.Parent = optionsFrame

                    -- Hover effects for dropdown button
                    dropdownButton.MouseEnter:Connect(function()
                        dropdownButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
                    end)

                    dropdownButton.MouseLeave:Connect(function()
                        dropdownButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
                    end)

                    local function setSelection(value, skipCallback)
                        dropdownButton.Text = value
                        optionsFrame.Visible = false
                        arrow.Text = "▼"
                        if not skipCallback and callback then
                            local ok, err = pcall(callback, value)
                            if not ok then
                                warn("[Auto Fish UI] Dropdown callback error: " .. tostring(err))
                            end
                        end
                    end

                    dropdownButton.MouseButton1Click:Connect(function()
                        optionsFrame.Visible = not optionsFrame.Visible
                        arrow.Text = optionsFrame.Visible and "▲" or "▼"
                    end)

                    if options then
                        for _, option in ipairs(options) do
                            local optionButton = Instance.new("TextButton")
                            optionButton.Name = "Option"
                            optionButton.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
                            optionButton.TextColor3 = Color3.fromRGB(255, 255, 255)
                            optionButton.TextSize = responsive.textSize
                            optionButton.AutoButtonColor = false
                            optionButton.Font = Enum.Font.Gotham
                            optionButton.Text = option
                            optionButton.Size = UDim2.new(1, 0, 0, 28)
                            optionButton.Parent = optionsFrame

                            local optionCorner = Instance.new("UICorner")
                            optionCorner.CornerRadius = UDim.new(0, 4)
                            optionCorner.Parent = optionButton

                            optionButton.MouseEnter:Connect(function()
                                optionButton.BackgroundColor3 = Color3.fromRGB(50, 130, 245)
                            end)

                            optionButton.MouseLeave:Connect(function()
                                optionButton.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
                            end)

                            optionButton.MouseButton1Click:Connect(function()
                                setSelection(option)
                            end)
                        end
                    end

                    if options and options[1] and callback then
                        local ok, err = pcall(callback, options[1])
                        if not ok then
                            warn("[Auto Fish UI] Dropdown callback error: " .. tostring(err))
                        end
                    end

                    return {
                        Set = function(_, value) 
                            setSelection(value, true)
                        end
                    }
                end

                function section:NewSlider(title, description, maxValue, minValue, callback)
                    local responsive = getResponsiveSize()
                    local _, actionContainer = createRow(sectionFrame, title, description)

                    local textBox = Instance.new("TextBox")
                    textBox.Name = "SliderBox"
                    textBox.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
                    textBox.TextColor3 = Color3.fromRGB(255, 255, 255)
                    textBox.Font = Enum.Font.GothamSemibold
                    textBox.TextSize = responsive.textSize
                    textBox.ClearTextOnFocus = false
                    textBox.Size = UDim2.new(1, 0, 1, 0)
                    textBox.Text = tostring(minValue)
                    textBox.PlaceholderText = string.format("%s - %s", tostring(minValue), tostring(maxValue))
                    textBox.PlaceholderColor3 = Color3.fromRGB(120, 120, 120)
                    textBox.TextXAlignment = Enum.TextXAlignment.Center
                    textBox.Parent = actionContainer

                    local corner = Instance.new("UICorner")
                    corner.CornerRadius = UDim.new(0, 6)
                    corner.Parent = textBox

                    local stroke = Instance.new("UIStroke")
                    stroke.Color = Color3.fromRGB(65, 65, 65)
                    stroke.Thickness = 1
                    stroke.Parent = textBox

                    -- Focus effects
                    textBox.Focused:Connect(function()
                        stroke.Color = Color3.fromRGB(50, 130, 245)
                    end)

                    textBox.FocusLost:Connect(function()
                        stroke.Color = Color3.fromRGB(65, 65, 65)
                    end)

                    local currentValue = tonumber(minValue) or 0
                    if callback then
                        local ok, err = pcall(callback, currentValue)
                        if not ok then
                            warn("[Auto Fish UI] Slider callback error: " .. tostring(err))
                        end
                    end

                    local function commitValue(raw)
                        local value = tonumber(raw)
                        if not value then
                            textBox.Text = tostring(currentValue)
                            return
                        end
                        local minClamp = tonumber(minValue)
                        local maxClamp = tonumber(maxValue)
                        if minClamp and maxClamp then
                            value = math.clamp(value, minClamp, maxClamp)
                        end
                        if value ~= currentValue then
                            currentValue = value
                            if callback then
                                local ok, err = pcall(callback, value)
                                if not ok then
                                    warn("[Auto Fish UI] Slider callback error: " .. tostring(err))
                                end
                            end
                        end
                        textBox.Text = tostring(value)
                    end

                    -- Auto-save on text change with debounce
                    local lastChanged = 0
                    local debounceTime = 0.5 -- seconds
                    textBox.Changed:Connect(function(property)
                        if property == "Text" then
                            lastChanged = tick()
                            task.delay(debounceTime, function()
                                if tick() - lastChanged >= debounceTime then
                                    commitValue(textBox.Text)
                                end
                            end)
                        end
                    end)

                    textBox.FocusLost:Connect(function()
                        commitValue(textBox.Text)
                    end)

                    textBox.InputEnded:Connect(function(input)
                        if input.UserInputType == Enum.UserInputType.Touch then
                            commitValue(textBox.Text)
                        end
                    end)

                    return {
                        Set = function(_, value) 
                            commitValue(value)
                        end
                    }
                end

                function section:NewKeybind(title, description, defaultKey, callback)
                    local responsive = getResponsiveSize()
                    local _, actionContainer = createRow(sectionFrame, title, description)

                    local keyButton = Instance.new("TextButton")
                    keyButton.Name = "KeybindButton"
                    keyButton.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
                    keyButton.TextColor3 = Color3.fromRGB(255, 255, 255)
                    keyButton.Font = Enum.Font.GothamSemibold
                    keyButton.TextSize = responsive.textSize
                    keyButton.AutoButtonColor = false
                    keyButton.Size = UDim2.new(1, 0, 1, 0)
                    keyButton.Parent = actionContainer

                    local corner = Instance.new("UICorner")
                    corner.CornerRadius = UDim.new(0, 6)
                    corner.Parent = keyButton

                    local stroke = Instance.new("UIStroke")
                    stroke.Color = Color3.fromRGB(65, 65, 65)
                    stroke.Thickness = 1
                    stroke.Parent = keyButton

                    -- Hover effects
                    keyButton.MouseEnter:Connect(function()
                        keyButton.BackgroundColor3 = Color3.fromRGB(55, 55, 55)
                    end)

                    keyButton.MouseLeave:Connect(function()
                        keyButton.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
                    end)

                    local userInput = game:GetService("UserInputService")
                    local listening = false
                    local currentKey = defaultKey or Enum.KeyCode.RightShift
                    keyButton.Text = currentKey.Name

                    local activationConn
                    local function bindKeybind(keyCode)
                        currentKey = keyCode
                        keyButton.Text = currentKey.Name
                        if activationConn then
                            activationConn:Disconnect()
                        end
                        activationConn = userInput.InputBegan:Connect(function(input, gpe)
                            if gpe then return end
                            if input.KeyCode == currentKey then
                                if callback then
                                    local ok, err = pcall(callback)
                                    if not ok then
                                        warn("[Auto Fish UI] Keybind callback error: " .. tostring(err))
                                    end
                                end
                            end
                        end)
                    end

                    bindKeybind(currentKey)

                    keyButton.MouseButton1Click:Connect(function()
                        if listening then return end
                        listening = true
                        keyButton.Text = "Press key"

                        local connection
                        connection = userInput.InputBegan:Connect(function(input, gpe)
                            if gpe then return end
                            if input.UserInputType == Enum.UserInputType.Keyboard then
                                listening = false
                                if connection then
                                    connection:Disconnect()
                                end
                                bindKeybind(input.KeyCode)
                            end
                        end)
                    end)

                    return {
                        Set = function(_, keyCode) 
                            bindKeybind(keyCode)
                        end
                    }
                end

                return section
            end

            if not window._currentTab then
                window:ShowTab(tabName)
            end

            return tab
        end

        return window
    end

    function Library.CreateLib(titleText)
        local window = createWindow(titleText)
        Library._lastWindow = window
        return window
    end

    function Library:ToggleUI(force)
        if self._lastWindow then
            return self._lastWindow:ToggleUI(force)
        end
    end

    function Library:MinimizeUI(force)
        if self._lastWindow then
            return self._lastWindow:MinimizeUI(force)
        end
    end

end

print("⏳ [Auto Fish] Creating user interface...")
local Window = Library.CreateLib("🎣 Auto Fish v6.2 Enhanced")
if Window then
    print("✅ [Auto Fish] User interface created")
else
    warn("⚠️ [Auto Fish] UI creation failed")
end

--TAB: Auto
local TabAuto      = Window:NewTab("Auto Features")
local SecMain      = TabAuto:NewSection("Main Features")
local SecOther     = TabAuto:NewSection("Other Features")
local SecDelays    = TabAuto:NewSection("Delay Settings")

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

autoPreset3Toggle = SecMain:NewToggle("Auto 3 (Auto Kohana)", "Enable core auto features with 5s delay then teleport to Kohana Volcano", function(state)
    if state then
        enablePreset("auto3", "Kohana Volcano")
    else
        disablePreset("auto3")
    end
end)



autoWeatherToggle = SecOther:NewToggle("Auto Weather", "Auto weather events", function(state)
    setAutoWeather(state)
end)

chargeFishingSlider = SecDelays:NewSlider("Charge Rod Delay", "Delay setelah charge fishing rod (detik, min: 0.01)", 10, 0.1, function(value)
    setChargeFishingDelay(value)
end)

autoFishMainSlider = SecDelays:NewSlider("Auto Fish Delay", "Delay loop utama auto fish (detik, min: 0.1)", 20, 0.1, function(value)
    setAutoFishMainDelay(value)
end)

autoSellSlider = SecDelays:NewSlider("Auto Sell Delay", "Delay auto sell (detik, min: 1)", 180, 1, function(value)
    setAutoSellDelay(value)
end)

autoCatchSlider = SecDelays:NewSlider("Auto Catch Delay", "Delay auto catch (detik, min: 0.1)", 10, 0.1, function(value)
    setAutoCatchDelay(value)
end)

weatherIdSlider = SecDelays:NewSlider("Weather ID Delay", "Delay antar weather ID (detik, min: 1)", 60, 1, function(value)
    setWeatherIdDelay(value)
end)

weatherCycleSlider = SecDelays:NewSlider("Weather Cycle Delay", "Delay siklus weather (detik, min: 10)", 600, 30, function(value)
    setWeatherCycleDelay(value)
end)

task.defer(function()
    task.wait(1)
    if chargeFishingSlider then
        chargeFishingSlider:Set(config.chargeFishingDelay or chargeFishingDelay)
    end
    if autoFishMainSlider then
        autoFishMainSlider:Set(config.autoFishMainDelay or autoFishMainDelay)
    end
    if autoSellSlider then
        autoSellSlider:Set(config.autoSellDelay or autoSellDelay)
    end
    if autoCatchSlider then
        autoCatchSlider:Set(config.autoCatchDelay or autoCatchDelay)
    end
    if weatherIdSlider then
        weatherIdSlider:Set(config.weatherIdDelay or weatherIdDelay)
    end
    if weatherCycleSlider then
        weatherCycleSlider:Set(config.weatherCycleDelay or weatherCycleDelay)
    end
    print("[UI] Delay sliders initialized from config")
end)

local TabTeleport = Window:NewTab("Teleport")
local SecTP = TabTeleport:NewSection("All Locations")

-- Function to safely teleport
local function teleportTo(locationName, cframe)
    pcall(function()
        local character = game.Players.LocalPlayer.Character
        if character and character:FindFirstChild("HumanoidRootPart") then
            character.HumanoidRootPart.CFrame = cframe
            print("[Teleport] ✅ Successfully teleported to: " .. locationName)
        else
            warn("[Teleport] ❌ Character or HumanoidRootPart not found!")
        end
    end)
end

-- Create individual teleport buttons for better UX
SecTP:NewButton("🏠 Spawn", "Return to spawn area", function()
    teleportTo("Spawn", CFrame.new(45.2788086, 252.562927, 2987.10913, 1, 0, 0, 0, 1, 0, 0, 0, 1))
end)

-- Popular fishing locations section
local SecPopular = TabTeleport:NewSection("Popular Fishing Spots")

SecPopular:NewButton("🌋 Kohana Volcano", "Active volcano area with rare fish", function()
    teleportTo("Kohana Volcano", CFrame.new(-572.879456, 22.4521465, 148.355331, -0.995764792, -6.67705606e-08, 0.0919371247, -5.74611505e-08, 1, 1.03905414e-07, -0.0919371247, 9.81825394e-08, -0.995764792))
end)

SecPopular:NewButton("🗿 Sisyphus Statue", "Deep sea location near the ancient statue", function()
    teleportTo("Sisyphus Statue", CFrame.new(-3728.21606, -135.074417, -1012.12744, -0.977224171, 7.74980258e-09, -0.212209702, 1.566994e-08, 1, -3.5640408e-08, 0.212209702, -3.81539813e-08, -0.977224171))
end)

SecPopular:NewButton("🏝️ Crater Island", "Isolated crater island with unique catches", function()
    teleportTo("Crater Island", CFrame.new(1016.49072, 20.0919304, 5069.27295, 0.838976264, 3.30379857e-09, -0.544168055, 2.63538391e-09, 1, 1.01344115e-08, 0.544168055, -9.93662219e-09, 0.838976264))
end)

-- Deep sea locations section
local SecDeep = TabTeleport:NewSection("Deep Sea Areas")

SecDeep:NewButton("🌊 Esoteric Depths", "Deepest area with mysterious fish", function()
    teleportTo("Esoteric Depths", CFrame.new(3248.37109, -1301.53027, 1403.82727, -0.920208454, 7.76270355e-08, 0.391428679, 4.56261056e-08, 1, -9.10549289e-08, -0.391428679, -6.5930152e-08, -0.920208454))
end)

SecDeep:NewButton("🪸 Coral Reefs", "Colorful reef system", function()
    teleportTo("Coral Reefs", CFrame.new(-3114.78198, 1.32066584, 2237.52295, -0.304758579, 1.6556676e-08, -0.952429652, -8.50574935e-08, 1, 4.46003305e-08, 0.952429652, 9.46036067e-08, -0.304758579))
end)

-- Special locations section
local SecSpecial = TabTeleport:NewSection("Special Areas")

SecSpecial:NewButton("🏝️ Lost Isle", "Mysterious lost island", function()
    teleportTo("Lost Isle", CFrame.new(-3618.15698, 240.836655, -1317.45801, 1, 0, 0, 0, 1, 0, 0, 0, 1))
end)

SecSpecial:NewButton("🌴 Tropical Grove", "Lush tropical area", function()
    teleportTo("Tropical Grove", CFrame.new(-2095.34106, 197.199997, 3718.08008))
end)

SecSpecial:NewButton("💎 Treasure Room", "Hidden treasure chamber", function()
    teleportTo("Treasure Room", CFrame.new(-3606.34985, -266.57373, -1580.97339, 0.998743415, 1.12141152e-13, -0.0501160324, -1.56847693e-13, 1, -8.88127842e-13, 0.0501160324, 8.94872392e-13, 0.998743415))
end)

-- Utility locations section
local SecUtility = TabTeleport:NewSection("Utility Locations")

SecUtility:NewButton("🌤️ Weather Machine", "Control weather patterns", function()
    teleportTo("Weather Machine", CFrame.new(-1488.51196, 83.1732635, 1876.30298, 1, 0, 0, 0, 1, 0, 0, 0, 1))
end)

SecUtility:NewButton("🏘️ Kohana Village", "Main village area", function()
    teleportTo("Kohana", CFrame.new(-663.904236, 3.04580712, 718.796875, -0.100799225, -2.14183729e-08, -0.994906783, -1.12300391e-08, 1, -2.03902459e-08, 0.994906783, 9.11752096e-09, -0.100799225))
end)

-- Quick dropdown for legacy support
local SecQuick = TabTeleport:NewSection("Quick Select (Legacy)")
local tpNames = {}
for _, loc in ipairs(teleportLocations) do
    table.insert(tpNames, loc.Name)
end

SecQuick:NewDropdown("Location Selector", "Choose location from dropdown", tpNames, function(chosen)
    for _, location in ipairs(teleportLocations) do
        if location.Name == chosen then
            teleportTo(chosen, location.CFrame)
            break
        end
    end
end)


autoMegalodonToggle = SecOther:NewToggle("Auto Megalodon Hunt", "Auto teleport to Megalodon events", function(state)
    setAutoMegalodon(state)
end)

upgradeRodToggle = SecOther:NewToggle("Auto Upgrade Rod", "Otomatis beli rod pancing selanjutnya", function(state)
    setUpgradeRod(state)
end)

upgradeBaitToggle = SecOther:NewToggle("Auto Upgrade Bait", "Otomatis beli umpan selanjutnya", function(state)
    setUpgradeBait(state)
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
        if config.gpuSaver then
            enableGPUSaver()
        end
        if config.gpuSaver and gpuSaverToggle then
            gpuSaverToggle:UpdateToggle(nil, true)
        end

        isApplyingConfig = false
        syncConfigFromStates()
        saveConfig()
    end

    if config.activePreset == "auto1" and autoPreset1Toggle then
        autoPreset1Toggle:UpdateToggle(nil, true)
    elseif config.activePreset == "auto2" and autoPreset2Toggle then
        autoPreset2Toggle:UpdateToggle(nil, true)
    elseif config.activePreset == "auto3" and autoPreset3Toggle then
        autoPreset3Toggle:UpdateToggle(nil, true)
    end
end

task.defer(applyLoadedConfig)


-- ====== PERFORMANCE TAB ====== 
local TabPerformance = Window:NewTab("Performance")
local SecGPU = TabPerformance:NewSection("GPU Saver Mode")

gpuSaverToggle = SecGPU:NewToggle("GPU Saver Mode", "Enable white screen to save GPU/battery", function(state)
    if state then
        enableGPUSaver()
    else
        disableGPUSaver()
    end
    updateConfigField("gpuSaver", state)
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



-- The "Advanced Modules" tab and its contents have been removed as per instructions.

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
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = MiniBtn.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
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
print("⏳ [Auto Fish] Starting automation loops...")

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


task.spawn(function()
    while true do
        task.wait(1) -- biar nggak error
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
        task.wait(12) -- Check every 12 seconds
    end
end)


-- The "Disconnect Notifier" section has been removed due to compatibility issues.

-- ============ SCRIPT INITIALIZATION ============
print("⏳ [Auto Fish] Starting auto upgrade systems...")

-- ====== AUTO UPGRADE LOOPS (From Fish v3) ======
task.spawn(function()
    while true do
        if upgradeState.rod then
            pcall(function()
                local currentCurrency = getCurrentCoins()
                local affordableRodId, rodPrice = getAffordableRod(currentCurrency)
                if not affordableRodId then return end
                
                print("[AutoUpgrade] Attempting to purchase rod " .. affordableRodId)
                local wasAutoFarm = isAutoFarmOn
                if wasAutoFarm then setAutoFarm(false) task.wait(1) end
                
                local success, guid = pcall(networkEvents.purchaseRodEvent.InvokeServer, networkEvents.purchaseRodEvent, affordableRodId)
                
                if success and guid and type(guid) == 'string' and #guid > 0 then
                    print("[AutoUpgrade] Rod " .. affordableRodId .. " purchased. Equipping...")
                    pcall(networkEvents.equipItemEvent.FireServer, networkEvents.equipItemEvent, guid, "Fishing Rods")
                    task.wait(1)
                    failedRodAttempts[affordableRodId] = nil
                    rodFailedCounts[affordableRodId] = 0
                    currentRodTarget = findNextRodTarget()
                else
                    print("[AutoUpgrade] Rod " .. affordableRodId .. " purchase failed, marking as owned/failed.")
                    rodFailedCounts[affordableRodId] = (rodFailedCounts[affordableRodId] or 0) + 1
                    failedRodAttempts[affordableRodId] = tick()
                    if (rodFailedCounts[affordableRodId] or 0) >= 3 then
                        currentRodTarget = findNextRodTarget()
                    end
                end
                
                if wasAutoFarm then setAutoFarm(true) end
            end)
        end
        task.wait(15) -- Check every 15 seconds
    end
end)

task.spawn(function()
    while true do
        if upgradeState.bait then
            pcall(function()
                local currentCurrency = getCurrentCoins()
                local affordableBaitId, baitPrice = getAffordableBait(currentCurrency)
                if not affordableBaitId then return end

                print("[AutoUpgrade] Attempting to purchase bait " .. affordableBaitId)
                local wasAutoFarm = isAutoFarmOn
                if wasAutoFarm then setAutoFarm(false) task.wait(1) end

                local success, result = pcall(networkEvents.purchaseBaitEvent.InvokeServer, networkEvents.purchaseBaitEvent, affordableBaitId)

                if success and result then
                    print("[AutoUpgrade] Bait " .. affordableBaitId .. " purchased. Equipping...")
                    pcall(networkEvents.equipBaitEvent.FireServer, networkEvents.equipBaitEvent, affordableBaitId)
                    task.wait(1)
                    failedBaitAttempts[affordableBaitId] = nil
                    baitFailedCounts[affordableBaitId] = 0
                    currentBaitTarget = findNextBaitTarget()
                else
                    print("[AutoUpgrade] Bait " .. affordableBaitId .. " purchase failed, marking as owned/failed.")
                    baitFailedCounts[affordableBaitId] = (baitFailedCounts[affordableBaitId] or 0) + 1
                    failedBaitAttempts[affordableBaitId] = tick()
                    if (baitFailedCounts[affordableBaitId] or 0) >= 3 then
                        currentBaitTarget = findNextBaitTarget()
                    end
                end

                if wasAutoFarm then setAutoFarm(true) end
            end)
        end
        task.wait(15) -- Check every 15 seconds
    end
end)

-- ====== SCRIPT COMPLETION & HEALTH CHECK ======
-- Validate all critical systems are ready
local function performHealthCheck()
    local healthStatus = {}

    -- Check critical variables
    healthStatus.autoFarmToggle = autoFarmToggle ~= nil
    healthStatus.networkEvents = networkEvents ~= nil
    healthStatus.discordMonitor = setupDisconnectNotifier ~= nil
    healthStatus.uiSystem = Library ~= nil
    healthStatus.webhookSystem = CONNECTION_WEBHOOK_URL ~= nil

    -- Check LocalPlayer
    healthStatus.localPlayer = (game:GetService("Players").LocalPlayer ~= nil)

    return healthStatus
end

local health = performHealthCheck()
local allSystemsReady = true

print("🔍 [Auto Fish] System Health Check:")
for system, status in pairs(health) do
    local icon = status and "✅" or "❌"
    print("  " .. icon .. " " .. system .. ": " .. (status and "Ready" or "Failed"))
    if not status then
        allSystemsReady = false
    end
end

if allSystemsReady then
    print("✅ [Auto Fish] All systems operational!")
    print("📋 Auto Fish Enhanced Edition v6.2 fully loaded!")
    print("")
    print("🎯 Available Features:")
    print("  🎣 Auto Farm System")
    print("  💰 Auto Sell System")
    print("  🎯 Auto Catch System")
    print("  🌤️ Auto Weather System")
    print("  🦈 Auto Megalodon Hunt")
    print("  🔧 Auto Upgrade System")
    print("  📡 Advanced Disconnect Monitor")
    print("  💻 GPU Saver Mode")
    print("  🎮 Mobile-Optimized UI")
    print("")
    print("🎮 Controls:")
    print("  📱 Press RightShift to toggle UI")
    print("  🔧 Press RightControl for GPU Saver")
    print("")
    print("🎉 Script ready! Happy fishing! 🎣")

    -- Show Discord monitor status
    if DISCORD_USER_ID and DISCORD_USER_ID ~= "YOUR_DISCORD_USER_ID_HERE" then
        print("📡 Discord notifications enabled for User ID: " .. DISCORD_USER_ID)
    else
        print("⚠️ Discord notifications disabled (no User ID configured)")
    end

else
    warn("⚠️ [Auto Fish] Some systems failed health check. Script may not function properly.")
    warn("⚠️ Check the error messages above and ensure all dependencies are available.")
end
