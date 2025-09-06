-- main.lua - Main loader script for Auto Fish v4.2 Modular
-- Execute this single script to load all modules

print("🚀 Loading Auto Fish v4.2 Modular...")

-- ====== GITHUB REPOSITORY CONFIGURATION ======
local GITHUB_USER = "DarylLoudi" -- Change this to your GitHub username
local GITHUB_REPO = "fish-it" -- Change this to your repository name
local BRANCH = "main" -- or "master" depending on your default branch

-- Base URL for raw GitHub content
local BASE_URL = string.format("https://raw.githubusercontent.com/%s/%s/%s/", GITHUB_USER, GITHUB_REPO, BRANCH)

-- Module URLs
local MODULE_URLS = {
    AutoFeatures = BASE_URL .. "AutoFeatures.lua",
    Performance = BASE_URL .. "Performance.lua",
    Teleport = BASE_URL .. "Teleport.lua",
    UIControls = BASE_URL .. "UIControls.lua"
}

-- ====== SERVICES ======
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- ====== NETWORK EVENTS SETUP ======
local function getNetworkEvents()
    local success, result = pcall(function()
        local packages = ReplicatedStorage:WaitForChild("Packages", 10)
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
            fishCaughtEvent = net:WaitForChild("RE/FishCaught", 10)
        }
    end)
    
    if success then
        return result
    else
        warn("Failed to get network events: " .. tostring(result))
        return nil
    end
end

-- ====== SESSION STATS INITIALIZATION ======
local startTime = os.time()
local sessionStats = {
    totalFish = 0,
    totalValue = 0,
    bestFish = {name = "None", value = 0},
    fishTypes = {}
}

-- ====== MODULE LOADER ======
local function loadModule(moduleName, url)
    print("🔍 Checking " .. moduleName .. " at " .. url)
    local success, result = pcall(function()
        return loadstring(game:HttpGet(url))()
    end)
    if success then
        print("✅ " .. moduleName .. " loaded successfully")
        return result
    else
        warn("❌ Failed to load " .. moduleName .. " from " .. url .. ": " .. tostring(result))
        return nil
    end
end

-- ====== FALLBACK LOCAL MODULES ======
local function loadLocalModules()
    warn("🔄 GitHub loading failed, using fallback method...")
    -- Return any successfully loaded modules as fallback
    return {
        AutoFeatures = _G.AutoFishDebug.reloadModule("AutoFeatures") or nil,
        Performance = _G.AutoFishDebug.reloadModule("Performance") or nil,
        Teleport = _G.AutoFishDebug.reloadModule("Teleport") or nil,
        UIControls = _G.AutoFishDebug.reloadModule("UIControls") or nil
    }
end

-- ====== MAIN INITIALIZATION ======
local function main()
    print("🔧 Initializing network events...")
    local networkEvents = getNetworkEvents()
    if not networkEvents then
        error("❌ Failed to initialize network events. Script cannot continue.")
        return
    end
    print("✅ Network events initialized")

    print("📥 Loading modules from GitHub...")
    
    -- Load all modules
    local modules = {}
    local loadSuccess = true
    
    for moduleName, url in pairs(MODULE_URLS) do
        modules[moduleName] = loadModule(moduleName, url)
        if not modules[moduleName] then
            loadSuccess = false
        end
    end
    
    -- If any module failed to load, try fallback
    if not loadSuccess then
        print("⚠ Some modules failed to load from GitHub, attempting fallback...")
        local fallbackModules = loadLocalModules()
        
        for moduleName, module in pairs(fallbackModules) do
            if not modules[moduleName] and module then
                modules[moduleName] = module
                print("✅ " .. moduleName .. " loaded from fallback")
            end
        end
    end
    
    -- Check if all required modules are loaded
    local requiredModules = {"AutoFeatures", "Performance", "Teleport", "UIControls"}
    for _, moduleName in ipairs(requiredModules) do
        if not modules[moduleName] then
            error("❌ Required module " .. moduleName .. " failed to load. Cannot continue.")
            return
        end
    end
    
    print("✅ All modules loaded successfully!")
    
    -- ====== INITIALIZE MODULES ======
    print("🔧 Initializing modules...")
    
    -- Initialize modules with dependencies
    modules.AutoFeatures.setNetworkEvents(networkEvents)
    modules.AutoFeatures.setSessionStats(sessionStats, startTime)
    modules.Performance.setSessionStats(sessionStats, startTime)
    
    -- Setup fish tracking
    modules.AutoFeatures.setupFishTracking()
    
    print("✅ Modules initialized!")
    
    -- ====== CREATE UI ======
    print("🎨 Creating user interface...")
    
    -- Load Kavo UI Library
    local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/xHeptc/Kavo-UI-Library/main/source.lua"))()
    local Window = Library.CreateLib("Auto Fish v4.2 - Modular", "DarkTheme")
    
    -- Initialize UI Controls first
    modules.UIControls.init(Library)
    
    -- Create UI sections for each module
    modules.AutoFeatures.createUI(Window)
    modules.Performance.createUI(Window)
    modules.Teleport.createUI(Window)
    modules.UIControls.createUI(Window)
    
    print("✅ User interface created!")
    
    -- ====== START AUTO LOOPS ======
    print("🔄 Starting automation loops...")
    modules.AutoFeatures.startAutoLoops()
    print("✅ Automation loops started!")
    
    -- ====== ADDITIONAL SETUP ======
    -- Add minimize button to main UI
    modules.UIControls.addMinimizeButtonToMainUI()
    
    -- Start status update loop for minimize button
    modules.UIControls.startStatusUpdateLoop(function()
        return {
            isAutoFarmOn = modules.AutoFeatures.isAutoFarmOn,
            isAutoSellOn = modules.AutoFeatures.isAutoSellOn,
            isAutoCatchOn = modules.AutoFeatures.isAutoCatchOn
        }
    end)
    
    print("🎉 Auto Fish v4.2 Modular loaded successfully!")
    print("📋 Available features:")
    print("   🚜 Auto Farm - Automated fishing")
    print("   💰 Auto Sell - Automatic selling")
    print("   🎯 Auto Catch - Auto catch fish")
    print("   ⬆ Auto Upgrades - Rod and bait upgrades")
    print("   🌤️ Auto Weather - Weather events")
    print("   🚀 Teleport - Quick location travel")
    print("   ⚡ GPU Saver - Performance mode")
    print("   📱 UI Controls - Interface management")
    print("💡 Use RightShift to minimize/restore UI")
    print("💡 Use RightControl to toggle GPU Saver")
end

-- ====== ERROR HANDLING WRAPPER ======
local function safeMain()
    local success, error = pcall(main)
    if not success then
        warn("❌ Auto Fish initialization failed:")
        warn(tostring(error))
        warn("🔧 Please check your GitHub configuration or network connection")
        print("💡 You can still try loading individual modules manually")
    end
end

-- ====== EXECUTION ======
safeMain()

-- ====== UTILITY FUNCTIONS FOR DEBUGGING ======
_G.AutoFishDebug = {
    reloadModule = function(moduleName)
        if MODULE_URLS[moduleName] then
            local module = loadModule(moduleName, MODULE_URLS[moduleName])
            if module then
                print("🔄 " .. moduleName .. " reloaded successfully")
                return module
            end
        else
            warn("❌ Unknown module: " .. moduleName)
        end
    end,
    
    listModules = function()
        print("📋 Available modules:")
        for moduleName, url in pairs(MODULE_URLS) do
            print("   • " .. moduleName .. " - " .. url)
        end
    end,
    
    getSessionStats = function()
        return sessionStats
    end,
    
    resetSessionStats = function()
        sessionStats = {
            totalFish = 0,
            totalValue = 0,
            bestFish = {name = "None", value = 0},
            fishTypes = {}
        }
        startTime = os.time()
        print("🔄 Session stats reset")
    end
}
