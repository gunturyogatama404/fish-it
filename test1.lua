-- ====== SCRIPT INITIALIZATION SAFETY CHECK ======
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
    return true
end)
if not success then
    error("âŒ [Auto Fish] Critical dependency check failed: " .. tostring(errorMsg))
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
if not suppressSuccess then
    warn("âš ï¸ [Auto Fish] Error suppression setup failed")
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
end
-- Safe execution of performance optimization
local perfSuccess = pcall(ultimatePerformance)
if not perfSuccess then
    warn("âš ï¸ [Auto Fish] Performance optimization failed, continuing...")
end
-- ====== ANTI-AFK SYSTEM ======
-- Prevents Roblox from disconnecting due to 20 minute idle timeout
local function setupAntiAFK()
    local VirtualUser = game:GetService("VirtualUser")
    local Players = game:GetService("Players")
    local LocalPlayer = Players.LocalPlayer
    -- Method 1: Hook into Roblox's idle detection
    LocalPlayer.Idled:Connect(function()
        VirtualUser:CaptureController()
        VirtualUser:ClickButton2(Vector2.new())
    end)
    -- Method 2: Periodic random movements (every 5 minutes as backup)
    task.spawn(function()
        while true do
            task.wait(300) -- Every 5 minutes
            pcall(function()
                local character = LocalPlayer.Character
                if character and character:FindFirstChild("Humanoid") then
                    -- Small jump to show activity
                    character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
                end
            end)
        end
    end)
end
-- Initialize Anti-AFK
local antiAfkSuccess = pcall(setupAntiAFK)
if not antiAfkSuccess then
    warn("âš ï¸ [Auto Fish] Anti-AFK setup failed, continuing...")
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
ðŸ†• NEW ONLINE STATUS SYSTEM Features:
ðŸŸ¢ SMART MESSAGE EDITING: Each account gets its own message that updates every 8 seconds
ðŸ“ PERSISTENT MESSAGE ID: Message IDs are saved and reused across sessions
â° REAL-TIME UPDATES: Shows uptime, fish count, coins, level with live timestamps
ðŸ”„ AUTO RECOVERY: Creates new message if old one becomes invalid
ðŸ“Š RICH STATUS INFO: Displays comprehensive player statistics
ðŸ”´ OFFLINE DETECTION: Automatically updates message to offline when disconnected
Traditional Connection Features (still active):
âœ… Sends "Player Connected" when script starts successfully
âŒ Sends "Player Disconnected" with detailed reason when issues occur
ðŸ“Š Includes session duration and freeze detection
âš ï¸ Ping monitoring enabled (high ping webhook DISABLED - console log only)
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
        if onCompleteCallback then pcall(onCompleteCallback) end
        isLoading = false
    end
    function LightweightInventory.start(onRefreshCallback)
        if isInventoryHooked then return end
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
                end)
                pcall(function()
                    local fishCaughtEvent = ReplicatedStorage.Packages._Index["sleitnick_net@0.2.0"].net:WaitForChild("RE/FishCaught")
                    fishCaughtEvent.OnClientEvent:Connect(function()
                        task.delay(1, function() refreshInventoryTiles(onRefreshCallback) end)
                    end)
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
            title = "ðŸŽ£ Item Langka Ditemukan!",
            description = string.format("**+%d %s** telah ditambahkan ke inventory.", amount, itemData.fullName),
            color = 3066993,
            fields = {
                { name = "ðŸ‘¤ Player", value = LocalPlayer.Name, inline = true },
                { name = "ðŸ  Fish", value = itemData.fullName, inline = true },
                { name = "âš–ï¸ Weight", value = itemData.weight, inline = true },
                { name = "âœ¨ Mutation", value = itemData.mutation, inline = true },
                { name = "ðŸ•’ Waktu", value = os.date("%H:%M:%S"), inline = false }
            },
            footer = { text = "Inventory Notifier" }
        }
        -- Ambil URL gambar dari konfigurasi menggunakan nama dasar
        local imageUrl = CONFIG.FISH_IMAGES[itemData.baseName]
        if imageUrl and imageUrl ~= "" then
            local rawImageUrl = convertToRawGitHubUrl(imageUrl)
            embed.thumbnail = { url = rawImageUrl }
        end
        local payload = { embeds = {embed} }
        pcall(function()
            local req = (syn and syn.request) or http_request
            if req then
                req({ Url=WEBHOOK_URL, Method="POST", Headers={["Content-Type"]="application/json"}, Body=HttpService:JSONEncode(payload) })
                lastWebhookTime = tick()
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
task.wait(5)
local invSuccess = pcall(function()
    LightweightInventory.start(DiscordNotifier.scanInventory)
end)
if not invSuccess then
    warn("âš ï¸ [Auto Fish] Inventory system failed to load")
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
-- ====== STUCK DETECTION DISABLED ======
-- Removed to reduce complexity and register usage
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
local megalodonLockActive = false
local megalodonLockConnection = nil
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
        else
            warn("[Config] Failed to write config file")
        end
    else
        warn("[Config] Failed to encode config to JSON")
    end
end
local function loadConfig()
    if not readfile or not isfile then
        config = {}
        for key, value in pairs(defaultConfig) do
            config[key] = value
        end
        return
    end
    -- Ensure config folder exists
    ensureConfigFolder()
    local configFile = getConfigFileName()
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
            config = validateConfigStructure(decoded)
        else
            print("[Config] Failed to decode JSON, using defaults")
            config = {}
            for key, value in pairs(defaultConfig) do
                config[key] = value
            end
        end
    else
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
                        end
                    end)
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
end
-- Try to migrate old config first, then load current config
if not migrateOldConfig() then
    loadConfig()
end
applyDelayConfig()
-- Player identification info
-- ====== AUTO UPGRADE STATE & DATA (From Fish v3) ======
-- Convert upgrade system to globals to save local register space
upgradeState = { rod = false, bait = false }
rodIDs = {79, 76, 85, 77, 78, 4, 80, 6, 7, 5, 126}
baitIDs = {10, 2, 3, 17, 6, 8, 15, 16}
rodPrices = {[79]=350,[76]=3000,[85]=1500,[77]=3000,[78]=5000,[4]=15000,[80]=50000,[6]=215000,[7]=437000,[5]=1000000,[126]=2500000}
baitPrices = {[10]=100,[2]=1000,[3]=3000,[17]=83500,[6]=290000,[8]=630000,[15]=1150000,[16]=1000000}
failedRodAttempts, failedBaitAttempts, rodFailedCounts, baitFailedCounts = {}, {}, {}, {}
currentRodTarget, currentBaitTarget = nil, nil
function findNextRodTarget()local a=1;if currentRodTarget then for c=1,#rodIDs do if rodIDs[c]==currentRodTarget then a=c+1;break end end end;for c=a,#rodIDs do local b=rodIDs[c];if rodPrices[b]and(not rodFailedCounts[b]or rodFailedCounts[b]<3)then return b end end;return nil end
function findNextBaitTarget()local a=1;if currentBaitTarget then for c=1,#baitIDs do if baitIDs[c]==currentBaitTarget then a=c+1;break end end end;for c=a,#baitIDs do local b=baitIDs[c];if baitPrices[b]and(not baitFailedCounts[b]or baitFailedCounts[b]<3)then return b end end;return nil end
function getAffordableRod(a)if not currentRodTarget then return end;local b=rodPrices[currentRodTarget];if not b then currentRodTarget=findNextRodTarget();return end;if failedRodAttempts[currentRodTarget]and tick()-failedRodAttempts[currentRodTarget]<30 then return end;if a>=b then return currentRodTarget,b end end
function getAffordableBait(a)if not currentBaitTarget then return end;local b=baitPrices[currentBaitTarget];if not b then currentBaitTarget=findNextBaitTarget();return end;if failedBaitAttempts[currentBaitTarget]and tick()-failedBaitAttempts[currentBaitTarget]<30 then return end;if a>=b then return currentBaitTarget,b end end
-- ====== END AUTO UPGRADE ======
-- ====== SHOP PURCHASE FUNCTIONS (GLOBALS TO SAVE LOCAL REGISTERS) ======
rodDatabase = {luck=79,carbon=76,grass=85,demascus=77,ice=78,lucky=4,midnight=80,steampunk=6,chrome=7,astral=5,ares=126}
baitDatabase = {topwaterbait=10,luckbait=2,midnightbait=3,deepbait=17,chromabait=6,darkmatterbait=8,corruptbait=15,aetherbait=16}
-- Manual purchase functions (globals to reduce local register usage)
function buyRod(a)
end
function buyBait(a)
end
function shopAutoPurchaseOnStartup()
    -- buyRod(rodDatabase.ares) -- Ares Rod
end
--- ====== END SHOP FUNCTIONS ======
-- ====== COIN/LEVEL FUNCTIONS (GLOBAL TO SAVE REGISTERS) ======
function getCurrentCoins()local a="0";local b,c=pcall(function()local d=LocalPlayer:FindFirstChild("PlayerGui")local e=d and d:FindFirstChild("Events")local f=e and e:FindFirstChild("Frame")local g=f and f:FindFirstChild("CurrencyCounter")local h=g and g:FindFirstChild("Counter")return h and h.Text end)if b and c then a=c end;local i=a:gsub(",","")local j=0;if i:lower():find("k")then local k=i:lower():gsub("k","")j=(tonumber(k)or 0)*1000 elseif i:lower():find("m")then local k=i:lower():gsub("m","")j=(tonumber(k)or 0)*1000000 else j=tonumber(i)or 0 end;return j end
function getCurrentLevel()local a,b=pcall(function()local c=LocalPlayer:FindFirstChild("PlayerGui")if not c then return"Lvl 0"end;local d=c:FindFirstChild("XP")if not d then return"Lvl 0"end;local e=d:FindFirstChild("Frame")if not e then return"Lvl 0"end;local f=e:FindFirstChild("LevelCount")if not f then return"Lvl 0"end;return f.Text or"Lvl 0"end)return a and b or"Lvl 0"end
-- ====== HELPER FUNCTIONS (GLOBAL TO SAVE REGISTERS) ======
function getFishCaught()local a,b=pcall(function()if LocalPlayer.leaderstats and LocalPlayer.leaderstats.Caught then return LocalPlayer.leaderstats.Caught.Value end;return 0 end)return a and b or 0 end
function getBestFish()local a,b=pcall(function()if LocalPlayer.leaderstats and LocalPlayer.leaderstats["Rarest Fish"]then return LocalPlayer.leaderstats["Rarest Fish"].Value end;return"None"end)return a and b or"None"end
function getQuestText(a)local b,c=pcall(function()local d=workspace:FindFirstChild("!!! MENU RINGS")if not d then return"Quest not found"end;local e=d:FindFirstChild("Deep Sea Tracker")if not e then return"Quest not found"end;local f=e:FindFirstChild("Board")if not f then return"Quest not found"end;local g=f:FindFirstChild("Gui")if not g then return"Quest not found"end;local h=g:FindFirstChild("Content")if not h then return"Quest not found"end;local i=h:FindFirstChild(a)if not i then return"Quest not found"end;return i.Text or"No data"end)return b and c or"Error fetching quest"end
-- ====== STATS/FORMAT FUNCTIONS (GLOBAL TO SAVE REGISTERS) ======
function FormatTime(a)a=tonumber(a)or 0;a=math.max(0,math.floor(a))local b=math.floor(a/3600)local c=math.floor((a%3600)/60)local d=a%60;return string.format("%02d:%02d:%02d",b,c,d)end
function FormatNumber(a)local b=tonumber(a)or 0;local c=tostring(math.floor(b))local d;while true do c,d=string.gsub(c,"^(-?%d+)(%d%d%d)",'%1,%2')if d==0 then break end end;return c end
-- ====== GPU SAVER VARIABLES ======
local originalSettings = {}
local whiteScreenGui = nil
local connections = {}
local fpsCapConnection = nil
local gpuSaverTargetFPS = 8
local function applyGpuSaverFpsCap()
    pcall(function()
        if setfpscap then
            local target = tonumber(gpuSaverTargetFPS) or 8
            target = math.max(1, math.floor(target + 0.5))
            setfpscap(target)
        end
    end)
end
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
local networkEvents = getNetworkEvents()
if not networkEvents then
    error("âŒ [Auto Fish] Failed to initialize network events. Script cannot continue.")
    return
else
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
    titleLabel.Text = "ðŸŸ¢ " .. LocalPlayer.Name .. "\nTotal Caught: " .. totalCaught .. "\nBest Caught: " .. bestCaught
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
    sessionLabel.Text = "â±ï¸ Uptime: 00:00:00"
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
    fpsLabel.Text = "ðŸ“Š FPS: " .. currentFPS
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
    fishStatsLabel.Text = "ðŸŽ£ Fish Caught: " .. FormatNumber(sessionStats.totalFish)
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
    coinLabel.Text = "ðŸ’° Coins: " .. getCurrentCoins()
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
    levelLabel.Text = "â­ " .. getCurrentLevel()
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
    quest1Label.Text = "ðŸ† Quest 1: " .. getQuestText("Label1")
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
    quest2Label.Text = "ðŸ† Quest 2: " .. getQuestText("Label2")
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
    quest3Label.Text = "ðŸ† Quest 3: " .. getQuestText("Label3")
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
    quest4Label.Text = "ðŸ† Quest 4: " .. getQuestText("Label4")
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
    statusLabel.Text = "ðŸ¤– Auto Farm: " .. (isAutoFarmOn and "ðŸŸ¢ ON" or "ðŸ”´ OFF") .. 
                      " | Auto Sell: " .. (isAutoSellOn and "ðŸŸ¢ ON" or "ðŸ”´ OFF") ..
                      " | Auto Catch: " .. (isAutoCatchOn and "ðŸŸ¢ ON" or "ðŸ”´ OFF")
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
    extraStatusLabel.Text = "ðŸ¦ˆ Auto Megalodon: " .. (isAutoMegalodonOn and "ðŸŸ¢ ON" or "ðŸ”´ OFF") ..
                          " | ðŸŒ¤ï¸ Auto Weather: " .. (isAutoWeatherOn and "ðŸŸ¢ ON" or "ðŸ”´ OFF")
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
    closeButton.Text = "âŒ Disable GPU Saver"
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
                        fpsLabel.Text = string.format("ðŸ“Š FPS: %.0f", fps)
                    end
                end)
                -- Safe session time update
                pcall(function()
                    if sessionLabel and sessionLabel.Parent then
                        local currentUptime = math.max(0, os.time() - startTime)
                        sessionLabel.Text = "â±ï¸ Uptime: " .. FormatTime(currentUptime)
                    end
                end)
                -- Safe fishing stats update
                pcall(function()
                    if fishStatsLabel and fishStatsLabel.Parent then
                        local fishCount = math.max(0, sessionStats.totalFish)
                        fishStatsLabel.Text = "ðŸŽ£ Fish Caught: " .. FormatNumber(fishCount)
                    end
                end)
                -- Safe coins update
                pcall(function()
                    if coinLabel and coinLabel.Parent then
                        coinLabel.Text = "ðŸ’° Coins: " .. getCurrentCoins()
                    end
                end)
                -- Safe level update
                pcall(function()
                    if levelLabel and levelLabel.Parent then
                        levelLabel.Text = "â­ " .. getCurrentLevel()
                    end
                end)
                -- Safe quest updates
                pcall(function() if quest1Label and quest1Label.Parent then quest1Label.Text = "ðŸ† Quest 1: " .. getQuestText("Label1") end end)
                pcall(function() if quest2Label and quest2Label.Parent then quest2Label.Text = "ðŸ† Quest 2: " .. getQuestText("Label2") end end)
                pcall(function() if quest3Label and quest3Label.Parent then quest3Label.Text = "ðŸ† Quest 3: " .. getQuestText("Label3") end end)
                pcall(function() if quest4Label and quest4Label.Parent then quest4Label.Text = "ðŸ† Quest 4: " .. getQuestText("Label4") end end)
                -- Safe status update
                pcall(function()
                    if statusLabel and statusLabel.Parent then
                        statusLabel.Text = "ðŸ¤– Auto Farm: " .. (isAutoFarmOn and "ðŸŸ¢ ON" or "ðŸ”´ OFF") .. 
                                         " | Auto Sell: " .. (isAutoSellOn and "ðŸŸ¢ ON" or "ðŸ”´ OFF") ..
                                         " | Auto Catch: " .. (isAutoCatchOn and "ðŸŸ¢ ON" or "ðŸ”´ OFF")
                    end
                    if extraStatusLabel and extraStatusLabel.Parent then
                        extraStatusLabel.Text = "ðŸ¦ˆ Auto Megalodon: " .. (isAutoMegalodonOn and "ðŸŸ¢ ON" or "ðŸ”´ OFF") ..
                                              " | ðŸŒ¤ï¸ Auto Weather: " .. (isAutoWeatherOn and "ðŸŸ¢ ON" or "ðŸ”´ OFF")
                    end
                end)
                -- Safe Total Caught & Best Caught update
                pcall(function()
                    if titleLabel and titleLabel.Parent then
                        local currentCaught = (LocalPlayer.leaderstats and LocalPlayer.leaderstats.Caught and LocalPlayer.leaderstats.Caught.Value) or 0
                        local currentBest = (LocalPlayer.leaderstats and LocalPlayer.leaderstats["Rarest Fish"] and LocalPlayer.leaderstats["Rarest Fish"].Value) or "None"
                        titleLabel.Text = "ðŸŸ¢ " .. LocalPlayer.Name .. "\nTotal Caught: " .. FormatNumber(currentCaught) .. "\nBest Caught: " .. currentBest
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
                titleLabel.Text = "ðŸŸ¢ " .. LocalPlayer.Name .. "\nTotal Caught: " .. newValue .. "\nBest Caught: " .. currentBest
            end
        end)
    end
    if LocalPlayer.leaderstats and LocalPlayer.leaderstats["Rarest Fish"] then
        connections.bestCaughtConnection = LocalPlayer.leaderstats["Rarest Fish"].Changed:Connect(function(newValue)
            if titleLabel then
                local currentCaught = (LocalPlayer.leaderstats.Caught and LocalPlayer.leaderstats.Caught.Value) or 0
                titleLabel.Text = "ðŸŸ¢ " .. LocalPlayer.Name .. "\nTotal Caught: " .. currentCaught .. "\nBest Caught: " .. newValue
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
    updateConfigField("gpuSaver", true)
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
        applyGpuSaverFpsCap() -- Apply target FPS limit
        StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.All, false)
        workspace.CurrentCamera.FieldOfView = 1
    end)
    -- Create FPS cap monitor to ensure it stays at 8 FPS
    if fpsCapConnection then
        fpsCapConnection:Disconnect()
        fpsCapConnection = nil
    end
    fpsCapConnection = RunService.Heartbeat:Connect(function()
        if gpuSaverEnabled then
            applyGpuSaverFpsCap()
        end
    end)
    createWhiteScreen()
end
function disableGPUSaver()
    if not gpuSaverEnabled then return end
    gpuSaverEnabled = false
    updateConfigField("gpuSaver", false)
    -- Disconnect FPS cap monitor
    if fpsCapConnection then
        fpsCapConnection:Disconnect()
        fpsCapConnection = nil
    end
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
end
-- ====== FISH CAUGHT EVENT HANDLER ======
local function setupFishTracking()
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
-- ====== STUCK DETECTION REMOVED ======
-- Removed entire stuck detection system to reduce complexity
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
                if isAutoMegalodonOn then
                    setAutoMegalodon(false)
                end
            end)
            table.insert(steps, function()
                if isAutoWeatherOn then
                    setAutoWeather(false)
                end
            end)
            table.insert(steps, function()
                if isAutoCatchOn then
                    setAutoCatch(false)
                end
            end)
            table.insert(steps, function()
                if isAutoSellOn then
                    setSell(false)
                end
            end)
            table.insert(steps, function()
                if isAutoFarmOn then
                    setAutoFarm(false)
                end
            end)
        end
        table.insert(steps, function()
            if not isAutoFarmOn then
                setAutoFarm(true)
            else
                equipRod()
            end
        end)
        table.insert(steps, function()
            if not isAutoSellOn then
                setSell(true)
            end
        end)
        table.insert(steps, function()
            if not isAutoCatchOn then
                setAutoCatch(true)
            end
        end)
        if presetKey ~= "auto3" then
            table.insert(steps, function()
                if not isAutoWeatherOn then
                    setAutoWeather(true)
                end
            end)
            table.insert(steps, function()
                if not isAutoMegalodonOn then
                    setAutoMegalodon(true)
                end
            end)
        end
        table.insert(steps, function()
            enableGPUSaver()
        end)
        table.insert(steps, function()
            setDelaysForPreset(presetKey)
        end)
        runPresetSequence(steps)
        isAutoPreset1On = presetKey == "auto1"
        isAutoPreset2On = presetKey == "auto2"
        isAutoPreset3On = presetKey == "auto3"
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
                if isAutoMegalodonOn then
                    setAutoMegalodon(false)
                end
            end,
            function()
                if isAutoWeatherOn then
                    setAutoWeather(false)
                end
            end,
            function()
                if isAutoCatchOn then
                    setAutoCatch(false)
                end
            end,
            function()
                if isAutoSellOn then
                    setSell(false)
                end
            end,
            function()
                if isAutoFarmOn then
                    setAutoFarm(false)
                end
            end,
            function()
                disableGPUSaver()
            end,
            function()
                setAutoFishMainDelay(defaultConfig.autoFishMainDelay)
                setAutoCatchDelay(defaultConfig.autoCatchDelay)
            end,
        }
        runPresetSequence(steps)
        isAutoPreset1On = false
        isAutoPreset2On = false
        isAutoPreset3On = false
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
        end 
    end)
end
local function unequipRod()
    pcall(function() 
        if unequipEvent then 
            unequipEvent:FireServer()
        end 
    end)
end
-- ====== MEGALODON HUNT FUNCTIONS (JUMP + CFRAME FREEZE) ======
local megalodonLockedCFrame = nil
function teleportToMegalodon(pos, isEvent)
    local char = player.Character
    if not char then return end
    local root = char:FindFirstChild("HumanoidRootPart")
    local hum = char:FindFirstChild("Humanoid")
    if not root or not hum then return end
    -- Calculate teleport position
    local tPos = pos
    if type(pos) == "userdata" and pos.X then
        tPos = pos + Vector3.new(0, 5, 0)
    elseif type(pos) == "userdata" and pos.Position then
        tPos = pos.Position + Vector3.new(0, 5, 0)
    end
    if isEvent then
        -- Teleport to position
        root.CFrame = CFrame.new(tPos)
        -- Wait a moment for teleport to settle
        task.wait(0.1)
        -- Jump once to get above water
        hum:ChangeState(Enum.HumanoidStateType.Jumping)
        -- Wait for jump to reach peak
        task.wait(0.35)
        -- Store locked position at peak (above water)
        megalodonLockedCFrame = root.CFrame + Vector3.new(0, 2, 0)
        -- Disable existing lock if any
        if megalodonLockConnection then
            megalodonLockConnection:Disconnect()
            megalodonLockConnection = nil
        end
        megalodonLockActive = true
        -- Lock using CFrame reset loop (allows fishing activities)
        -- This method only resets position when player moves too far
        megalodonLockConnection = RunService.Heartbeat:Connect(function()
            if not root or not root.Parent or not megalodonLockActive then
                if megalodonLockConnection then
                    megalodonLockConnection:Disconnect()
                    megalodonLockConnection = nil
                end
                return
            end
            -- Only reset position if player drifted too far (> 3 studs)
            -- This allows small movements needed for fishing animations
            if (root.Position - megalodonLockedCFrame.Position).Magnitude > 3 then
                root.CFrame = megalodonLockedCFrame
            end
        end)
    else
        -- Manual teleport without lock
        root.CFrame = CFrame.new(tPos)
    end
end
function disableMegalodonLock()
    megalodonLockActive = false
    megalodonLockedCFrame = nil
    if megalodonLockConnection then
        megalodonLockConnection:Disconnect()
        megalodonLockConnection = nil
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
        task.wait(1) -- Wait a moment before resuming
        -- Check which preset was active
        local activePreset = config.activePreset        if activePreset == "auto1" then
            enablePreset("auto1", "Crater Island")
        elseif activePreset == "auto2" then
            enablePreset("auto2", "Sisyphus State")
        elseif activePreset == "auto3" then
            enablePreset("auto3", "Kohana Volcano")
        else
            -- No preset active, just resume farming if it was on
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
local UNIFIED_WEBHOOK_URL = type(webhook2) == "string" and webhook2 or ""
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
                { name = "ðŸ‘¤ Player", value = (player.DisplayName or player.Name or "Unknown"), inline = true },
                { name = "ðŸ•’ Time", value = os.date("%H:%M:%S"), inline = true }
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
            title = "ðŸŽ£ SECRET Fish Found",
            description = data.description or "Fish detected in inventory",
            color = 3066993, -- Blue-green
            fields = {
                { name = "ðŸ•’ Waktu",  value = os.date("%H:%M:%S"), inline = true },
                { name = "ðŸ‘¤ Player", value = player.DisplayName or player.Name or "Unknown", inline = true },
                { name = "ðŸ“¦ Total (whitelist)", value = tostring(data.totalWhitelistCount or 0) .. " fish", inline = true },
            },
            footer = { text = "Inventory Notifier â€¢ Auto Fish" }
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
                break
            else
                warn('[Webhook] ' .. webhookType .. ' attempt ' .. attempt .. ' failed: ' .. tostring(err))
                -- Handle specific rate limiting errors
                if string.find(tostring(err):lower(), "429") or string.find(tostring(err):lower(), "rate") then
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
                    local huntFolder = propsFolder:FindFirstChild("Megalodon Hunt")
                    if huntFolder then
                        local colorPart = huntFolder:FindFirstChild("Color")
                        if colorPart and colorPart.Position then
                            eventPosition = colorPart.Position
                            eventFound = true
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
                local megalodonHunt = child:FindFirstChild("Megalodon Hunt") or
                                    child:FindFirstChild("megalodon hunt") or
                                    child:FindFirstChild("Megalodon_Hunt") or
                                    child:FindFirstChild("megalodon_hunt") or
                                    child:FindFirstChild("MegalodonHunt") or
                                    child:FindFirstChild("megalodonh hunt")
                if megalodonHunt and megalodonHunt:FindFirstChild("Color") and megalodonHunt.Color.Position then
                    eventPosition = megalodonHunt.Color.Position
                    eventFound = true
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
        teleportToMegalodon(eventPosition, true)
    else
        -- Handle event end or missing props
        local wasActive = megalodonEventActive
        if wasActive then
            megalodonEventActive = false
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
        disableMegalodonLock()
        megalodonMissingAlertSent = false
        megalodonEventActive = false
        megalodonEventStartedAt = 0
        megalodonEventEndAlertSent = false
        megalodonPreEventFarmState = nil
    end
end
-- ====== CONNECTION STATUS WEBHOOK SYSTEM ======
-- Webhook khusus untuk status connect/disconnect
-- PENTING: Pastikan webhook3 dan discordid sudah dikonfigurasi di main.lua sebelum menjalankan script ini!
-- Contoh konfigurasi di main.lua:
-- webhook3 = "https://discord.com/api/webhooks/YOUR_WEBHOOK_ID/YOUR_WEBHOOK_TOKEN"
-- discordid = "123456789012345678"  -- Discord User ID (18 digit number)
local CONNECTION_WEBHOOK_URL = type(webhook3) == "string" and webhook3 or ""  -- URL webhook khusus untuk status koneksi
local hasSentDisconnectWebhook = false  -- Flag to avoid sending multiple notifications
local PING_THRESHOLD = 1000  -- ms, ping monitoring (webhook disabled, console log only)
local FREEZE_THRESHOLD = 3  -- seconds, if delta > this = game freeze
-- DISCORD USER ID untuk tag saat disconnect (ganti dengan ID Discord Anda)
local DISCORD_USER_ID = type(discordid) == "string" and discordid or "701247227959574567"  -- Fallback jika discordid tidak terdefinisi
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
        title = "ðŸŸ¢ " .. (LocalPlayer.DisplayName or LocalPlayer.Name) .. " - ONLINE",
        description = "**Status**: Auto Fish Active ðŸŽ£",
        color = 65280,
        fields = {
            { name = "â° Last Update", value = os.date("%H:%M:%S"), inline = true },
            { name = "âŒ› Uptime", value = FormatTime(uptime), inline = true },
            { name = "ðŸ  Total Fish", value = FormatNumber(fishCount), inline = true },
            { name = "ðŸ† Best Fish", value = bestFish, inline = true },
            { name = "ðŸ’° Coins", value = FormatNumber(getCurrentCoins()), inline = true },
            { name = "â­ Level", value = getCurrentLevel(), inline = true },
        },
        footer = { text = "Auto Fish Status â€¢ Updates every " .. ONLINE_STATUS_UPDATE_INTERVAL .. "s" },
        timestamp = os.date("!%Y-%m-%dT%H:%M:%S.000Z")
    }
    local messageId = getStoredMessageId(accountId)
    if messageId then
        local success = editDiscordMessage(messageId, embed, "")
        if success then
            return true
        end
        MESSAGE_ID_STORAGE[accountId] = nil
    end
    messageId = sendNewStatusMessage(embed, "")
    if messageId then
        saveMessageId(accountId, messageId)
        onlineStatusMessageId = messageId
        return true
    end
    return false
end
-- Fungsi untuk mengirim status koneksi ke webhook khusus (modified)
local function sendConnectionStatusWebhook(status, reason)
    -- Check if webhook URL is configured
    if not CONNECTION_WEBHOOK_URL or CONNECTION_WEBHOOK_URL == "" then
        warn('[Connection Status] Webhook URL not configured! Please set CONNECTION_WEBHOOK_URL variable.')
        return
    end
    local embed = {}
    -- NOTE: "connected" status removed to reduce webhook spam
    -- Only "reconnected" and "disconnected" will send notifications
    if status == "reconnected" then
        embed = {
            title = "ðŸ”„ Player Reconnected",
            description = reason or "Player has successfully reconnected to the server",
            color = 3066993, -- Blue-green
            fields = {
                { name = "ðŸ‘¤ Player", value = LocalPlayer.DisplayName or LocalPlayer.Name or "Unknown", inline = true },
                { name = "ðŸ•’ Time", value = os.date("%H:%M:%S"), inline = true },
                { name = "ðŸ”„ Reconnect Info", value = reason or "Reconnection detected", inline = false },
                { name = "ðŸ“± Status", value = "Auto Fish Resumed", inline = true }
            },
            footer = { text = "Reconnect Monitor â€¢ Auto Fish Script" },
            timestamp = os.date("!%Y-%m-%dT%H:%M:%S.000Z")
        }
    elseif status == "disconnected" then
        embed = {
            title = "ðŸ”´ Player Disconnected",
            description = reason or "Player has disconnected from the server",
            color = 16711680, -- Red
            fields = {
                { name = "ðŸ‘¤ Player", value = LocalPlayer.DisplayName or LocalPlayer.Name or "Unknown", inline = true },
                { name = "ðŸ•’ Time", value = os.date("%H:%M:%S"), inline = true },
                { name = "ðŸ”Œ Reason", value = reason or "Unknown", inline = false },
                { name = "â±ï¸ Session Duration", value = FormatTime(os.time() - startTime), inline = true },
                { name = "ðŸ“± Game", value = "ðŸ  Fish It", inline = true },
                { name = "ðŸ†” User ID", value = tostring(LocalPlayer.UserId), inline = true }
            },
            footer = { text = "Disconnect Alert â€¢ Auto Fish Script" },
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
        payload.content = "<@" .. userIdStr .. "> ðŸ”´ **ALERT: " .. playerName .. " TELAH DISCONNECT!** ðŸš¨"
    elseif status == "reconnected" then
        -- Always include mention for reconnect notifications
        payload.content = "<@" .. userIdStr .. "> ðŸŸ¡ **" .. playerName .. " TELAH RECONNECT!** âœ…"
    else
        -- Unknown status or "connected" (which is now disabled)
        warn('[Connection Status] Unknown or disabled status: ' .. tostring(status))
        return
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
        else
            -- No allowed_mentions if no user mention in content
            payload.allowed_mentions = {
                parse = {},
                users = {},
                roles = {}
            }
        end
    end
    local body = HttpService:JSONEncode(payload)
    -- DEBUG: Print full payload before sending
    -- Additional validation debug
    if payload.allowed_mentions then
    end
    -- Send webhook with retry logic
    task.spawn(function()
        local attempt = 1
        local maxAttempts = 3
        local success = false
        while attempt <= maxAttempts and not success do
            local retryDelay = 2 * attempt -- Progressive delay
            if attempt > 1 then
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
                if response then
                end
                return response
            end)
            if success then
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
            if isfile(sessionFile) then
                local content = readfile(sessionFile)
                local data = HttpService:JSONDecode(content)
                return data.sessionId, data.disconnectTime
            else
            end
        else
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
    local success, err = pcall(function()
        local encoded = HttpService:JSONEncode(sessionData)
        writefile(sessionFile, encoded)
    end)
    if success then
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
    -- Load previous session data
    lastSessionId, lastDisconnectTime = loadSessionData()
    if lastSessionId and lastDisconnectTime then
        local timeDiff = currentTime - lastDisconnectTime
        -- NEW LOGIC: If offline > 1 minute, treat as reconnect (not new connection)
        if timeDiff > NEW_SESSION_THRESHOLD then
            local success, err = pcall(function()
                sendConnectionStatusWebhook("reconnected", "Reconnected after " .. math.floor(timeDiff/60) .. " minute(s) offline")
            end)
            if not success then
                print("[Reconnect] Error sending reconnect webhook: " .. tostring(err))
            end
        else
            -- Within 1 minute threshold - check reconnect type
            if currentSessionId == lastSessionId then
                -- Same server session
                local sessionPreview = string.sub(tostring(currentSessionId or "unknown"), 1, 8)
                local success, err = pcall(function()
                    sendConnectionStatusWebhook("reconnected", "Quick reconnect detected (Session: " .. sessionPreview .. "..., Time: " .. tostring(timeDiff) .. "s)")
                end)
                if not success then
                    print("[Reconnect] Error sending quick reconnect webhook: " .. tostring(err))
                end
            else
                -- Different server session within threshold
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
        -- No previous session data = fresh start (no webhook sent to avoid spam)
        -- Webhook "connected" disabled to reduce spam
        -- Only reconnect and disconnect will send notifications
    end
    -- Save current session as the new baseline
    lastSessionId = currentSessionId
    lastDisconnectTime = nil  -- Reset disconnect time since we're connected
end
-- Send connection status notification when script starts
task.spawn(function()
    -- Wait a bit to ensure all services are loaded
    task.wait(2)
    -- Debug: Check if function exists
    initializeReconnectDetection()
    -- NOTE: Online status updates are disabled to reduce webhook spam
    -- Only connect/disconnect/reconnect notifications will be sent
end)
local function sendDisconnectWebhook(username, reason)
    if hasSentDisconnectWebhook then
        return
    end
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
end
local function setupDisconnectNotifier()
    local username = LocalPlayer.Name or "Unknown"
    local GuiService = game:GetService("GuiService")
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
        task.spawn(function()
            sendDisconnectWebhook(username, reason)
        end)
    end)
    -- Monitor for player removal (enhanced)
    Players.PlayerRemoving:Connect(function(removedPlayer)
        if removedPlayer == LocalPlayer then
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
            if not hasSentDisconnectWebhook then
                task.spawn(function()
                    sendDisconnectWebhook(username, "Game Leaving: " .. message)
                end)
            end
        end
    end)
    -- Monitor network ping for connection issues (HIGH PING WEBHOOK DISABLED)
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
                end
                -- HIGH PING DETECTION DISABLED - No webhook sent for high ping
                -- Just log it to console
                if ping > PING_THRESHOLD then
                end
            end
            task.wait(10) -- Check every 10 seconds (reduced frequency for better performance)
        end
    end)
    -- Monitor for game freezes using Stepped delta
    RunService.Stepped:Connect(function(_, deltaTime)
        if deltaTime > FREEZE_THRESHOLD then
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
end
-- Initialize Discord mention validation
local discordValid = pcall(validateDiscordMention)
if discordValid then
else
    warn("âš ï¸ [Auto Fish] Discord configuration validation failed")
end
-- Initialize disconnect notifier
local monitorSuccess = pcall(setupDisconnectNotifier)
if monitorSuccess then
else
    warn("âš ï¸ [Auto Fish] Disconnect monitor setup failed")
end
-- Auto-run test untuk memastikan sistem berfungsi (uncomment untuk testing)
-- task.spawn(function()
--     task.wait(5) -- Wait 5 seconds after startup
--     testDisconnectNotification()
-- end)
-- ====== ONLINE STATUS TIMER SYSTEM ======
-- Timer untuk update status online setiap 8 detik
local function startOnlineStatusTimer()
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
-- DISABLED: Online status system is turned off to reduce webhook spam
local function stopOnlineStatusTimer()
    isOnlineStatusActive = false
    -- No message editing needed since online status is disabled
end
-- DISABLED: Online status timer to reduce webhook spam
-- Only connect/disconnect/reconnect notifications will be sent
-- startOnlineStatusTimer()
-- ====== TEST FUNCTIONS & ERROR HANDLING ======
-- TEST FUNCTIONS untuk testing sistem online status baru
local function testOnlineStatusUpdate()
    local success = updateOnlineStatus()
    if success then
    else
        print("[TEST] âŒ Online status update test FAILED")
    end
end
local function testOfflineStatusUpdate()
    stopOnlineStatusTimer()
end
-- TEST FUNCTIONS untuk testing notification dengan tags
local function testDisconnectNotification()
    sendConnectionStatusWebhook("disconnected", "TEST: Manual disconnect test - Tag system check for User ID " .. tostring(DISCORD_USER_ID))
end
local function testReconnectNotification()
    sendConnectionStatusWebhook("reconnected", "TEST: Manual reconnect test - Tag system check for User ID " .. tostring(DISCORD_USER_ID))
end
-- Test function untuk validasi Discord mention format
local function validateDiscordMention()
    local userIdStr = tostring(DISCORD_USER_ID)
    local mentionFormat = "<@" .. userIdStr .. ">"
    -- Test allowed_mentions structure
    local testAllowedMentions = {
        parse = {},
        users = {userIdStr},
        roles = {}
    }
    return userIdStr
end
-- ERROR HANDLING untuk webhook failures
local function handleWebhookError(errorType, error)
    print("[Error Handler] " .. errorType .. " failed: " .. tostring(error))
    -- Online status updates are disabled, no retry needed
    -- Only reconnect/disconnect webhooks are active
end
-- Debug function untuk check message IDs
local function debugMessageStorage()
    for accountId, data in pairs(MESSAGE_ID_STORAGE) do
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
    testOnlineStatusUpdate()
    task.wait(5)
    debugMessageStorage()
end)
--]]
-- Quick test untuk verify optimizations worked
local function setAutoFarm(state)
    isAutoFarmOn = state
    updateConfigField("autoFarm", state)
    if state then
        equipRod() -- Auto equip rod when starting
    else
        cancelFishing()
        unequipRod() -- Auto unequip when stopping
    end
end
local function setSell(state)
    isAutoSellOn = state
    updateConfigField("autoSell", state)
end
local function setAutoCatch(state)
    isAutoCatchOn = state
    updateConfigField("autoCatch", state)
end
local function setAutoWeather(state)
    isAutoWeatherOn = state
    updateConfigField("autoWeather", state)
end
local function setAutoFishDelayForKohana()
    setAutoFishMainDelay(5)
    setAutoCatchDelay(0.6)
end
end
local function setDelaysForPreset(presetKey)
    if presetKey == "auto1" or presetKey == "auto2" then
        setAutoFishMainDelay(0.1)
        setAutoCatchDelay(0.1)
    elseif presetKey == "auto3" then
        setAutoFishMainDelay(5)
        setAutoCatchDelay(0.6)
    end
end
end
        else
            setAutoCatchDelay(0.1)
        end
    elseif presetKey == "auto3" then
        -- Auto 3: Auto Fish Delay 5s, Auto Catch Delay 0.6s
        else
            setAutoFishMainDelay(5)
        end
        else
            setAutoCatchDelay(0.6)
        end
    end
end
-- ====== SCRIPT CONFIGURATION (NO UI) ======
local presetLocationMap = {
    auto1 = "Crater Island",
    auto2 = "Sisyphus State",
    auto3 = "Kohana Volcano"
}
function setUpgradeRod(state)
    upgradeState.rod = state and true or false
    if upgradeState.rod and not currentRodTarget then
        currentRodTarget = findNextRodTarget()
    end
end
function setUpgradeBait(state)
    upgradeState.bait = state and true or false
    if upgradeState.bait and not currentBaitTarget then
        currentBaitTarget = findNextBaitTarget()
    end
end
local function applyLoadedConfig()
    isApplyingConfig = true
    setAutoFarm(config.autoFarm)
    setSell(config.autoSell)
    setAutoCatch(config.autoCatch)
    setAutoWeather(config.autoWeather)
    setAutoMegalodon(config.autoMegalodon)
    if config.gpuSaver then
        enableGPUSaver()
    else
        disableGPUSaver()
    end
    isApplyingConfig = false
    local presetKey = config.activePreset
    if presetKey and presetKey ~= "none" then
        enablePreset(presetKey, presetLocationMap[presetKey])
    end
    syncConfigFromStates()
    saveConfig()
end
local function applyScriptOverrides()
    if type(CHARGE_ROD_DELAY) == "number" then
        setChargeFishingDelay(CHARGE_ROD_DELAY)
    end
    if type(AUTO_FISH_DELAY) == "number" then
        setAutoFishMainDelay(AUTO_FISH_DELAY)
    end
    if type(AUTO_SELL_DELAY) == "number" then
        setAutoSellDelay(AUTO_SELL_DELAY)
    end
    if type(AUTO_CATCH_DELAY) == "number" then
        setAutoCatchDelay(AUTO_CATCH_DELAY)
    end
    if type(WEATHER_ID_DELAY) == "number" then
        setWeatherIdDelay(WEATHER_ID_DELAY)
    end
    if type(WEATHER_CYCLE_DELAY) == "number" then
        setWeatherCycleDelay(WEATHER_CYCLE_DELAY)
    end
    if type(GPU_FPS_LIMIT) == "number" then
        local numeric = math.max(1, math.floor(GPU_FPS_LIMIT + 0.5))
        gpuSaverTargetFPS = numeric
        if gpuSaverEnabled then
            applyGpuSaverFpsCap()
        end
    end
    if type(AUTO_UPGRADE_ROD) == "boolean" then
        setUpgradeRod(AUTO_UPGRADE_ROD)
    end
    if type(AUTO_UPGRADE_BAIT) == "boolean" then
        setUpgradeBait(AUTO_UPGRADE_BAIT)
    end
    if type(AUTO) == "number" then
        local presetLookup = { [1] = "auto1", [2] = "auto2", [3] = "auto3" }
        local presetKey = presetLookup[AUTO]
        if presetKey then
            enablePreset(presetKey, presetLocationMap[presetKey])
        end
    end
end
task.defer(function()
    applyLoadedConfig()
    applyScriptOverrides()
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
-- Initialize shop system
shopAutoPurchaseOnStartup()
-- ====== AUTO UPGRADE LOOPS (From Fish v3) ======
task.spawn(function()
    while true do
        if upgradeState.rod then
            pcall(function()
                local currentCurrency = getCurrentCoins()
                local affordableRodId, rodPrice = getAffordableRod(currentCurrency)
                if not affordableRodId then return end
                local wasAutoFarm = isAutoFarmOn
                if wasAutoFarm then setAutoFarm(false) task.wait(1) end
                local success, guid = pcall(networkEvents.purchaseRodEvent.InvokeServer, networkEvents.purchaseRodEvent, affordableRodId)
                if success and guid and type(guid) == 'string' and #guid > 0 then
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
                local wasAutoFarm = isAutoFarmOn
                if wasAutoFarm then setAutoFarm(false) task.wait(1) end
                local success, result = pcall(networkEvents.purchaseBaitEvent.InvokeServer, networkEvents.purchaseBaitEvent, affordableBaitId)
                if success and result then
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
    healthStatus.automationSystem = type(setAutoFarm) == "function"
    healthStatus.networkEvents = networkEvents ~= nil
    healthStatus.discordMonitor = setupDisconnectNotifier ~= nil
    healthStatus.configuration = config ~= nil
    healthStatus.webhookSystem = CONNECTION_WEBHOOK_URL ~= nil
    -- Check LocalPlayer
    healthStatus.localPlayer = (game:GetService("Players").LocalPlayer ~= nil)
    return healthStatus
end
local health = performHealthCheck()
local allSystemsReady = true
for system, status in pairs(health) do
    if not status then
        allSystemsReady = false
    end
end
if allSystemsReady then
    -- Show Discord monitor status
    if DISCORD_USER_ID and DISCORD_USER_ID ~= "YOUR_DISCORD_USER_ID_HERE" then
    else
        print("âš ï¸ Discord notifications disabled (no User ID configured)")
    end
else
    warn("[Auto Fish] Some systems failed health check. Script may not function properly.")
    warn("Check the error messages above and ensure all dependencies are available.")
end
