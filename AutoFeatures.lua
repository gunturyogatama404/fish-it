-- AutoFeatures.lua - Main auto farming features
local AutoFeatures = {}

-- State variables
AutoFeatures.isAutoFarmOn = false
AutoFeatures.isAutoSellOn = false
AutoFeatures.isAutoCatchOn = false
AutoFeatures.isUpgradeOn = false
AutoFeatures.isUpgradeBaitOn = false
AutoFeatures.isAutoWeatherOn = false

-- Delay variables
AutoFeatures.chargeFishingDelay = 0.01
AutoFeatures.autoFishMainDelay = 5
AutoFeatures.autoSellDelay = 5
AutoFeatures.autoCatchDelay = 0.8
AutoFeatures.weatherIdDelay = 3
AutoFeatures.weatherCycleDelay = 300

-- IDs for upgrades
local rodIDs = {79, 76, 85, 76, 78, 4, 80, 6, 7, 5}
local baitIDs = {10, 2, 3, 6, 8, 15, 16}
local WeatherIDs = {"Wind", "Cloudy", "Storm"}

-- Network events (will be set from main script)
local networkEvents = {}

-- Core functions
local function chargeFishingRod()
    pcall(function()
        if networkEvents.chargeEvent then
            networkEvents.chargeEvent:InvokeServer(1755848498.4834)
            task.wait(AutoFeatures.chargeFishingDelay)
        end
        if networkEvents.requestMinigameEvent then
            networkEvents.requestMinigameEvent:InvokeServer(1.2854545116425, 1)
        end
    end)
end

local function cancelFishing()
    pcall(function()
        if networkEvents.cancelFishingEvent then
            networkEvents.cancelFishingEvent:InvokeServer()
        end
    end)
end

local function performAutoCatch()
    pcall(function()
        if networkEvents.fishingEvent then
            networkEvents.fishingEvent:FireServer()
        end
    end)
end

local function equipRod()
    pcall(function() 
        if networkEvents.equipEvent then 
            networkEvents.equipEvent:FireServer(1)
            print("🎣 Rod equipped")
        end 
    end)
end

local function unequipRod()
    pcall(function() 
        if networkEvents.unequipEvent then 
            networkEvents.unequipEvent:FireServer()
            print("🎣 Rod unequipped")
        end 
    end)
end

-- Toggle functions
function AutoFeatures.setAutoFarm(state)
    AutoFeatures.isAutoFarmOn = state
    
    if state then
        equipRod()
        print("🚜 Auto Farm: ENABLED")
    else
        cancelFishing()
        unequipRod()
        print("🚜 Auto Farm: DISABLED")
    end
end

function AutoFeatures.setSell(state)
    AutoFeatures.isAutoSellOn = state
    print("💰 Auto Sell: " .. (state and "ENABLED" or "DISABLED"))
end

function AutoFeatures.setUpgrade(state)
    AutoFeatures.isUpgradeOn = state
    print("⬆️ Auto Upgrade Rod: " .. (state and "ENABLED" or "DISABLED"))
end

function AutoFeatures.setUpgradeBait(state)
    AutoFeatures.isUpgradeBaitOn = state
    print("⬆️ Auto Upgrade Bait: " .. (state and "ENABLED" or "DISABLED"))
end

function AutoFeatures.setAutoCatch(state)
    AutoFeatures.isAutoCatchOn = state
    print("🎯 Auto Catch: " .. (state and "ENABLED" or "DISABLED"))
end

function AutoFeatures.setAutoWeather(state)
    AutoFeatures.isAutoWeatherOn = state
    print("🌤️ Auto Weather: " .. (state and "ENABLED" or "DISABLED"))
end

-- Initialize network events
function AutoFeatures.setNetworkEvents(events)
    networkEvents = events
end

-- Auto loops
function AutoFeatures.startAutoLoops()
    -- Enhanced Auto Farm Loop
    task.spawn(function()
        while true do
            if AutoFeatures.isAutoFarmOn then
                pcall(function()
                    local player = game.Players.LocalPlayer
                    local character = player.Character
                    if character then
                        local tool = character:FindFirstChildOfClass("Tool")
                        if not tool then
                            equipRod()
                            task.wait(1)
                        end
                    end
                    
                    chargeFishingRod()
                    task.wait(AutoFeatures.autoFishMainDelay)
                    
                    if networkEvents.fishingEvent then 
                        networkEvents.fishingEvent:FireServer() 
                    end
                end)
            end
            task.wait(0.1)
        end
    end)

    -- Auto Sell Loop
    task.spawn(function()
        while true do
            if AutoFeatures.isAutoSellOn then
                pcall(function()
                    if networkEvents.sellEvent then 
                        networkEvents.sellEvent:InvokeServer() 
                    end
                end)
            end
            task.wait(AutoFeatures.autoSellDelay)
        end
    end)

    -- Auto Upgrade Rod Loop
    task.spawn(function()
        while true do
            if AutoFeatures.isUpgradeOn then
                for _, id in ipairs(rodIDs) do
                    if not AutoFeatures.isUpgradeOn then break end
                    pcall(function()
                        if networkEvents.purchaseRodEvent then
                            networkEvents.purchaseRodEvent:InvokeServer(id)
                        end
                    end)
                    task.wait(2)
                end
            end
            task.wait(0.1)
        end
    end)

    -- Auto Upgrade Bait Loop
    task.spawn(function()
        while true do
            if AutoFeatures.isUpgradeBaitOn then
                for _, id in ipairs(baitIDs) do
                    if not AutoFeatures.isUpgradeBaitOn then break end
                    pcall(function()
                        if networkEvents.purchaseBaitEvent then
                            networkEvents.purchaseBaitEvent:InvokeServer(id)
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
            if AutoFeatures.isAutoWeatherOn then
                for _, id in ipairs(WeatherIDs) do
                    if not AutoFeatures.isAutoWeatherOn then break end
                    pcall(function()
                        if networkEvents.WeatherEvent then
                            networkEvents.WeatherEvent:InvokeServer(id)
                        end
                    end)
                    local waited = 0
                    while AutoFeatures.isAutoWeatherOn and waited < AutoFeatures.weatherIdDelay do
                        task.wait(0.1)
                        waited = waited + 0.1
                    end
                end
                
                local waitedCycle = 0
                while AutoFeatures.isAutoWeatherOn and waitedCycle < AutoFeatures.weatherCycleDelay do
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
            if AutoFeatures.isAutoCatchOn then
                performAutoCatch()
            end
            task.wait(AutoFeatures.autoCatchDelay)
        end
    end)
end

-- Create UI section
function AutoFeatures.createUI(Window)
    local TabAuto = Window:NewTab("Auto Features")
    local SecMain = TabAuto:NewSection("Main Features")
    local SecOther = TabAuto:NewSection("Other Features")
    local SecDelays = TabAuto:NewSection("Delay Settings")

    -- Main toggles
    SecMain:NewToggle("Auto Farm", "Auto equip rod + fishing (kombinasi)", function(state) 
        AutoFeatures.setAutoFarm(state) 
    end)

    SecMain:NewToggle("Auto Sell", "Auto jual hasil", function(state) 
        AutoFeatures.setSell(state) 
    end)

    SecMain:NewToggle("Auto Catch", "Auto catch fish", function(state) 
        AutoFeatures.setAutoCatch(state) 
    end)

    -- Other features
    SecOther:NewToggle("Auto Upgrade Rod", "Auto upgrade rod", function(state) 
        AutoFeatures.setUpgrade(state) 
    end)

    SecOther:NewToggle("Auto Upgrade Bait", "Auto upgrade bait", function(state) 
        AutoFeatures.setUpgradeBait(state) 
    end)

    SecOther:NewToggle("Auto Weather", "Auto weather events", function(state) 
        AutoFeatures.setAutoWeather(state) 
    end)

    -- Delay settings
    SecDelays:NewSlider("Charge Rod Delay", "Delay setelah charge fishing rod (detik)", 10, 0.01, function(s)
        AutoFeatures.chargeFishingDelay = s
    end)

    SecDelays:NewSlider("Auto Fish Delay", "Delay loop utama auto fish (detik)", 20, 1, function(s)
        AutoFeatures.autoFishMainDelay = s
    end)

    SecDelays:NewSlider("Auto Sell Delay", "Delay auto sell (detik)", 30, 1, function(s)
        AutoFeatures.autoSellDelay = s
    end)

    SecDelays:NewSlider("Auto Catch Delay", "Delay auto catch (detik)", 10, 0.1, function(s)
        AutoFeatures.autoCatchDelay = s
    end)
end

return AutoFeatures
