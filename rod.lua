--[[
    Fish Detection and Selection System v1.5
    Tujuan: Mendeteksi daftar ikan, rods, baits, dan totems di inventory
    Fitur:
    - GUI untuk melihat nama ikan + mutasi, dengan navigasi berurutan
    - Tab Rods: Deteksi dan equip fishing rods menggunakan UUID
    - Tab Baits: Deteksi dan equip baits menggunakan ID
    - Tab Totems: Deteksi dan equip totems menggunakan UUID (dengan info tier)
    - Auto Trade & Auto Enchant
--]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer

-- State variables
local currentTab = "Fish" -- "Fish", "Players", or "AutoTrade"
local selectedTradePartner = nil
local autoTradeStatus = "Idle" -- "Idle", "Trading", "Success", "Failed", "Error"
local isAutoTrading = false
local tradeQueue = {}
local currentTradeIndex = 1
local tradedFishCount = 0

-- Variables for fish detection
local detectedFish = {}
local currentIndex = 1
local isDetecting = false
local fishDetectionWindow = nil
local selectedFishIndices = {} -- Track which fish are selected
local searchTerm = "" -- Current search term
local displayedFish = {} -- Currently displayed fish (filtered or all)

-- Variables for rod detection
local detectedRods = {}
local currentRodIndex = 1
local selectedRodIndex = nil
local currentCategory = "Fishes" -- "Fishes" or "Items"

-- Variables for bait detection
local detectedBaits = {}
local currentBaitIndex = 1
local selectedBaitIndex = nil

-- Variables for totem detection
local detectedTotems = {}
local currentTotemIndex = 1
local selectedTotemIndex = nil

-- Auto Enchant Variables
local isAutoEnchantOn = false
local targetEnchantID = 12 -- Default: Cursed I
local enchantFound = false
local enchantAttempts = 0
local enchantConnection = nil
local ENCHANT_HOTBAR_SLOT = 2 -- Fixed hotbar slot for enchant stone

-- Enchant Database
local enchantDatabase = {
    ["Cursed I"] = 12,
    ["Leprechaun I"] = 5,
    ["Leprechaun II"] = 6
}

-- Modules for equipping fish
local ItemUtility = require(ReplicatedStorage.Shared.ItemUtility)
local Replion = require(ReplicatedStorage.Packages.Replion)
local PlayerData = Replion.Client:WaitReplion("Data")
local EquipItemEvent = ReplicatedStorage.Packages._Index["sleitnick_net@0.2.0"].net:WaitForChild("RE/EquipItem")
local ActivateEnchantEvent = ReplicatedStorage.Packages._Index["sleitnick_net@0.2.0"].net:WaitForChild("RE/ActivateEnchantingAltar")
local RollEnchantRemote = ReplicatedStorage.Packages._Index["sleitnick_net@0.2.0"].net:WaitForChild("RE/RollEnchant")
local EquipToolFromHotbarEvent = ReplicatedStorage.Packages._Index["sleitnick_net@0.2.0"].net:WaitForChild("RE/EquipToolFromHotbar")

-- Helper function to trim whitespace from a string
local function trim(s)
    if not s then return nil end
    return s:match("^%s*(.-)%s*$")
end

-- Forward declaration for the main UI update function
local updateDisplay
local startAutoTrade
local stopAutoTrade
local processNextTrade

-- ====== AUTO ENCHANT FUNCTIONS ======
-- Enchanting Altar CFrame
local ENCHANT_ALTAR_CFRAME = CFrame.new(3235.87402, -1302.85486, 1397.36438, 0.540208638, -1.06509411e-07, -0.841531157, -4.86407581e-10, 1, -1.26878462e-07, 0.841531157, 6.89501647e-08, 0.540208638)

-- Function to teleport to enchanting altar
local function teleportToEnchantAltar()
    local character = LocalPlayer.Character
    if not character then
        warn("[Auto Enchant] Character not found for teleport")
        return false
    end

    local rootPart = character:FindFirstChild("HumanoidRootPart")
    if not rootPart then
        warn("[Auto Enchant] HumanoidRootPart not found for teleport")
        return false
    end

    print("[Auto Enchant] 🚀 Teleporting to enchanting altar...")
    pcall(function()
        rootPart.CFrame = ENCHANT_ALTAR_CFRAME
    end)
    task.wait(1) -- Wait for teleport to complete
    print("[Auto Enchant] ✅ Teleport complete!")
    return true
end

-- Function to find enchant stone UUID in inventory
local function findEnchantStoneUUID()
    if not PlayerData then return nil end

    local success, result = pcall(function()
        local inventoryItems = PlayerData:GetExpect("Inventory").Items
        for _, item in ipairs(inventoryItems) do
            local itemData = ItemUtility:GetItemData(item.Id)
            if itemData and itemData.Data.Name then
                local itemName = trim(itemData.Data.Name)
                -- Check if it's an enchant stone
                if itemName == "Enchant Stone" or string.find(itemName:lower(), "enchant") then
                    print(string.format("[Auto Enchant] Found enchant stone: %s (UUID: %s)", itemName, item.UUID))
                    return item.UUID
                end
            end
        end
    end)

    if success and result then
        return result
    else
        warn("[Auto Enchant] Failed to find enchant stone in inventory")
        return nil
    end
end

-- Function to find enchant stone in hotbar slots
local function findEnchantStoneHotbarSlot()
    local character = LocalPlayer.Character
    if not character then return nil end

    -- Check backpack for enchant stone tool
    local backpack = LocalPlayer:FindFirstChild("Backpack")
    if backpack then
        for _, tool in ipairs(backpack:GetChildren()) do
            if tool:IsA("Tool") and (tool.Name == "EnchantStones" or string.find(tool.Name:lower(), "enchant")) then
                print("[Auto Enchant] Found enchant stone tool in backpack:", tool.Name)
                return tool
            end
        end
    end

    -- Check if already equipped in character
    for _, tool in ipairs(character:GetChildren()) do
        if tool:IsA("Tool") and (tool.Name == "EnchantStones" or string.find(tool.Name:lower(), "enchant")) then
            print("[Auto Enchant] Enchant stone already equipped in character:", tool.Name)
            return tool
        end
    end

    return nil
end

-- Function to equip enchant stone to hotbar (as tool)
local function equipEnchantStoneToHotbar(slotNumber)
    slotNumber = slotNumber or ENCHANT_HOTBAR_SLOT
    print(string.format("[Auto Enchant] Equipping enchant stone from hotbar slot %d", slotNumber))

    pcall(function()
        EquipToolFromHotbarEvent:FireServer(slotNumber)
    end)
    task.wait(1) -- Reduced from 1.5s

    -- Verify if tool is equipped in character
    local character = LocalPlayer.Character
    if character then
        for _, child in ipairs(character:GetChildren()) do
            if child:IsA("Tool") then
                local childNameLower = child.Name:lower()
                if childNameLower == "enchantstones" or string.find(childNameLower, "enchant") then
                    print("[Auto Enchant] ✅ Enchant stone tool equipped in character from slot", slotNumber)
                    return true
                end
            end
        end
    end

    return false
end

-- Function to auto-equip enchant stone (COMPLETE PROCESS)
local function autoEquipEnchantStone()
    -- Step 1: Find enchant stone UUID in inventory
    local uuid = findEnchantStoneUUID()
    if not uuid then
        print("[Auto Enchant] ❌ No enchant stone found in inventory!")
        return false
    end

    print(string.format("[Auto Enchant] 📦 Step 1: Equipping enchant stone to hotbar (UUID: %s)", uuid))

    -- Step 2: Equip enchant stone from inventory to hotbar
    pcall(function()
        EquipItemEvent:FireServer(uuid, "EnchantStones")
    end)
    task.wait(1.5) -- Reduced from 2s

    -- Step 3: Verify if equipped to hotbar
    local equippedItems = PlayerData:GetExpect("EquippedItems")
    local isInHotbar = false
    for _, equippedUUID in ipairs(equippedItems) do
        if equippedUUID == uuid then
            isInHotbar = true
            print("[Auto Enchant] ✅ Step 1 Complete: Enchant stone in hotbar slot 2!")
            break
        end
    end

    if not isInHotbar then
        warn("[Auto Enchant] ⚠️ Failed to equip enchant stone to hotbar")
        return false
    end

    -- Step 4: Try to find and equip tool directly from backpack first
    print("[Auto Enchant] 🔧 Step 2: Looking for enchant stone tool in backpack...")
    local backpack = LocalPlayer:FindFirstChild("Backpack")
    local enchantTool = nil

    if backpack then
        for _, tool in ipairs(backpack:GetChildren()) do
            if tool:IsA("Tool") then
                local toolNameLower = tool.Name:lower()
                if toolNameLower == "enchantstones" or string.find(toolNameLower, "enchant") then
                    enchantTool = tool
                    print("[Auto Enchant] ✅ Found enchant tool in backpack:", tool.Name)
                    break
                end
            end
        end
    end

    -- If found in backpack, equip it directly
    if enchantTool then
        print("[Auto Enchant] 🎯 Equipping tool directly from backpack...")
        local humanoid = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid")
        if humanoid then
            humanoid:EquipTool(enchantTool)
            task.wait(1) -- Reduced from 1.5s

            -- Check if equipped
            local character = LocalPlayer.Character
            if character and character:FindFirstChild(enchantTool.Name) then
                print("[Auto Enchant] ✅ Step 2 Complete: Enchant stone equipped via backpack!")
                return true
            end
        end
    end

    -- Fallback: Try hotbar slot 2 ONLY
    print(string.format("[Auto Enchant] 🔧 Fallback: Trying hotbar slot %d...", ENCHANT_HOTBAR_SLOT))
    task.wait(0.5) -- Reduced from 1s

    local toolEquipped = equipEnchantStoneToHotbar(ENCHANT_HOTBAR_SLOT)

    if toolEquipped then
        print("[Auto Enchant] ✅ Step 2 Complete: Enchant stone fully equipped!")
        return true
    else
        warn("[Auto Enchant] ⚠️ Verification failed, but enchant stone should be in hotbar")
        print("[Auto Enchant] ⚠️ Continuing anyway - altar activation should still work...")
        -- Return true anyway because the enchant stone is in hotbar (verified in Step 1)
        -- The activation might still work even if we can't verify the tool is equipped
        return true
    end
end

-- Function to activate enchanting altar
local function activateEnchantingAltar()
    print("[Auto Enchant] Activating enchanting altar...")
    pcall(function()
        ActivateEnchantEvent:FireServer()
    end)
    task.wait(1.5) -- Reduced from 2s
end

-- Function to handle enchant roll result
local function onEnchantRoll(...)
    local args = {...}
    local enchantId = args[2]

    enchantAttempts = enchantAttempts + 1
    print(string.format("\n[Auto Enchant] 🎲 RESULT - Attempt #%d: Received enchant ID %d", enchantAttempts, enchantId))

    if enchantId == targetEnchantID then
        print(string.format("[Auto Enchant] 🎉 SUCCESS! Found target enchant ID %d!", targetEnchantID))
        print(string.format("[Auto Enchant] 📊 Total attempts: %d", enchantAttempts))
        enchantFound = true
        -- Don't set isAutoEnchantOn = false here, let the loop handle it
    else
        print(string.format("[Auto Enchant] ❌ Got enchant ID %d (wanted: %d)", enchantId, targetEnchantID))
        print("[Auto Enchant] 🔄 Will retry with next attempt...")
    end
end

-- Main auto enchant loop
local function startAutoEnchant()
    if not isAutoEnchantOn then return end

    print(string.format("[Auto Enchant] 🚀 Starting auto enchant for target ID: %d", targetEnchantID))
    enchantFound = false
    enchantAttempts = 0

    -- Connect to enchant result event
    if RollEnchantRemote and not enchantConnection then
        enchantConnection = RollEnchantRemote.OnClientEvent:Connect(onEnchantRoll)
    end

    -- UI Auto-refresh loop
    task.spawn(function()
        while isAutoEnchantOn and not enchantFound do
            task.wait(3) -- Update UI every 3 seconds
            if fishDetectionWindow and currentTab == "Enchant" then
                updateDisplay()
            end
        end
        -- Final update when done
        if fishDetectionWindow and currentTab == "Enchant" then
            updateDisplay()
        end
    end)

    -- Main enchant loop
    task.spawn(function()
        -- Teleport to enchanting altar first
        print("[Auto Enchant] 📍 Step 0: Teleporting to enchanting altar...")
        local teleported = teleportToEnchantAltar()
        if not teleported then
            warn("[Auto Enchant] ⚠️ Failed to teleport. Continuing anyway...")
        end

        while isAutoEnchantOn and not enchantFound do
            print(string.format("\n[Auto Enchant] ━━━━━━━━ ATTEMPT #%d ━━━━━━━━", enchantAttempts + 1))

            -- Auto-equip enchant stone (FULL PROCESS)
            print("[Auto Enchant] 🔄 Re-equipping enchant stone for this attempt...")
            local equipped = autoEquipEnchantStone()
            if not equipped then
                warn("[Auto Enchant] ⚠️ Failed to equip enchant stone. Retrying in 3 seconds...")
                task.wait(3) -- Reduced from 5s
                -- Don't stop, just retry
                continue
            end

            -- Wait a bit for everything to settle
            task.wait(0.5) -- Reduced from 1s

            -- Activate altar
            activateEnchantingAltar()

            -- Wait for result
            print("[Auto Enchant] ⏳ Waiting for enchant result...")
            task.wait(2) -- Reduced from 3s

            if not enchantFound and isAutoEnchantOn then
                print("[Auto Enchant] 🔁 Enchant not found yet. Preparing for next attempt...")
                task.wait(1) -- Reduced from 2s
            end
        end

        -- Cleanup
        if enchantConnection then
            enchantConnection:Disconnect()
            enchantConnection = nil
        end

        if enchantFound then
            print("[Auto Enchant] ✅ ━━━━━━━━━━━━━━━━━━━━━━━━━━")
            print("[Auto Enchant] ✅ AUTO ENCHANT COMPLETED!")
            print(string.format("[Auto Enchant] ✅ Target enchant ID %d found after %d attempts!", targetEnchantID, enchantAttempts))
            print("[Auto Enchant] ✅ ━━━━━━━━━━━━━━━━━━━━━━━━━━")
        else
            print("[Auto Enchant] ⛔ Auto enchant stopped by user!")
        end
    end)
end

-- Function to stop auto enchant
local function stopAutoEnchant()
    isAutoEnchantOn = false
    enchantFound = true

    if enchantConnection then
        enchantConnection:Disconnect()
        enchantConnection = nil
    end

    print("[Auto Enchant] 🛑 Auto enchant stopped!")
end

-- Helper function to find and equip a fish
local function equipFishByData(fishToEquip)
    if not fishToEquip or not PlayerData then return {success = false, uuid = nil} end

    local result = {success = false, uuid = nil}

    local ok, err = pcall(function()
        local inventoryItems = PlayerData:GetExpect("Inventory").Items
        local equippedItems = PlayerData:GetExpect("EquippedItems")
        for _, item in ipairs(inventoryItems) do
            local itemData = ItemUtility:GetItemData(item.Id)
            if itemData and itemData.Data.Name then
                local inventoryFishName = trim(itemData.Data.Name)
                local targetFishName = trim(fishToEquip.name)
                local targetMutation = fishToEquip.mutation

                -- Check for direct name match first
                local nameMatches = (inventoryFishName == targetFishName)

                -- If no direct match, check if this is a Big/Shiny fish
                if not nameMatches and targetMutation and (targetMutation == "Big" or targetMutation == "Shiny") then
                    local expectedFullName = targetMutation .. " " .. targetFishName
                    nameMatches = (inventoryFishName == expectedFullName)
                    if nameMatches then
                        print(string.format("[equipFishByData] Big/Shiny match found: '%s' == '%s'",
                            inventoryFishName, expectedFullName))
                    end
                end

                if nameMatches then
                    local mutationName = nil
                    if item.Metadata and item.Metadata.VariantId then
                        local variantData = ItemUtility:GetVariantData(item.Metadata.VariantId)
                        if variantData and variantData.Data.Name ~= "Ghoulish" then
                            mutationName = variantData.Data.Name
                        end
                    end

                    -- For Big/Shiny fish, the mutation is in the name, not in variants
                    local fishMutation = fishToEquip.mutation
                    local mutationMatches = false

                    if fishMutation == "Big" or fishMutation == "Shiny" then
                        -- For Big/Shiny, we already matched the full name above, so mutation matches
                        mutationMatches = true
                    else
                        -- For regular mutations, check variant data
                        mutationMatches = (mutationName == fishMutation) or (mutationName == nil and fishMutation == nil)
                    end

                    if mutationMatches then
                        local isEquipped = false
                        for _, equippedUUID in ipairs(equippedItems) do
                            if equippedUUID == item.UUID then
                                isEquipped = true
                                break
                            end
                        end

                        if not isEquipped then
                            print(string.format("[equipFishByData] Found match for '%s' (mutation: %s) -> UUID: %s",
                                fishToEquip.name, tostring(fishToEquip.mutation), item.UUID))
                            EquipItemEvent:FireServer(item.UUID, "Fishes")
                            result.success = true
                            result.uuid = item.UUID
                            return
                        else
                            print(string.format("[equipFishByData] Fish '%s' is already equipped", fishToEquip.name))
                        end
                    end
                end
            end
        end
    end)

    if not ok then
        warn(string.format("[equipFishByData] Pcall failed for '%s': %s", fishToEquip.name, tostring(err)))
    end

    return result
end

-- Function to equip rod by UUID
local function equipRodByUUID(rodUUID)
    if not rodUUID or not PlayerData then return false end

    local equippedItems = PlayerData:GetExpect("EquippedItems")
    for _, equippedUUID in ipairs(equippedItems) do
        if equippedUUID == rodUUID then
            print(string.format("[equipRodByUUID] Rod with UUID '%s' is already equipped.", rodUUID))
            return true -- Already equipped
        end
    end

    print(string.format("[equipRodByUUID] Equipping rod with UUID: %s", rodUUID))
    -- The category for rods is "Fishing Rods"
    EquipItemEvent:FireServer(rodUUID, "Fishing Rods")
    return true
end

-- Function to equip bait by ID (Baits use ID, not UUID)
local function equipBaitByID(baitID)
    if not baitID or not PlayerData then return false end

    local equippedBaitId = PlayerData:GetExpect("EquippedBaitId")
    if equippedBaitId == baitID then
        print(string.format("[equipBaitByID] Bait with ID '%s' is already equipped.", baitID))
        return true -- Already equipped
    end

    print(string.format("[equipBaitByID] Equipping bait with ID: %s", baitID))
    -- Use the EquipBait remote event
    local EquipBaitEvent = ReplicatedStorage.Packages._Index["sleitnick_net@0.2.0"].net:WaitForChild("RE/EquipBait")
    EquipBaitEvent:FireServer(baitID)
    return true
end

-- Function to equip totem by UUID (Totems use UUID like Rods)
local function equipTotemByUUID(totemUUID)
    if not totemUUID or not PlayerData then return false end

    local equippedItems = PlayerData:GetExpect("EquippedItems")
    for _, equippedUUID in ipairs(equippedItems) do
        if equippedUUID == totemUUID then
            print(string.format("[equipTotemByUUID] Totem with UUID '%s' is already equipped.", totemUUID))
            return true -- Already equipped
        end
    end

    print(string.format("[equipTotemByUUID] Equipping totem with UUID: %s", totemUUID))
    -- The category for totems is "Totems"
    EquipItemEvent:FireServer(totemUUID, "Totems")
    return true
end

-- Trading Function
local function selectTradePartner(player)
    if not player.Character then
        print("[Trade] Player character not loaded for: " .. player.Name)
    end

    selectedTradePartner = {
        Name = player.Name,
        UserId = player.UserId,
        CharacterAppearanceId = player.CharacterAppearanceId
    }
    print(string.format("[Trade] Selected partner: %s (UserId: %d, AppearanceId: %s)",
        selectedTradePartner.Name, selectedTradePartner.UserId, tostring(selectedTradePartner.CharacterAppearanceId)))

    updateDisplay() -- Refresh the UI to show the selection
end

-- Auto Trade Functions
startAutoTrade = function()
    if isAutoTrading then return end

    local selectedCount = 0
    for _ in pairs(selectedFishIndices) do selectedCount = selectedCount + 1 end

    if not selectedTradePartner then
        autoTradeStatus = "Error: No player selected."
        updateDisplay()
        return
    end
    if selectedCount == 0 then
        autoTradeStatus = "Error: No fish selected."
        updateDisplay()
        return
    end

    tradeQueue = {}
    for originalIndex, _ in pairs(selectedFishIndices) do
        if detectedFish[originalIndex] then
            table.insert(tradeQueue, detectedFish[originalIndex])
        end
    end
    
    if #tradeQueue == 0 then
        autoTradeStatus = "Error: Could not create trade queue from selected fish."
        updateDisplay()
        return
    end

    isAutoTrading = true
    currentTradeIndex = 1
    tradedFishCount = 0
    autoTradeStatus = "Starting auto trade..."
    updateDisplay()
    
    task.spawn(processNextTrade)
end

stopAutoTrade = function(reason)
    if not isAutoTrading then return end
    isAutoTrading = false
    tradeQueue = {}
    currentTradeIndex = 1
    tradedFishCount = 0
    autoTradeStatus = reason or "Stopped by user."
    updateDisplay()
end

processNextTrade = function()
    if not isAutoTrading then return end

    if currentTradeIndex > #tradeQueue then
        autoTradeStatus = "All selected fish have been traded successfully!"
        isAutoTrading = false
        selectedFishIndices = {}
        updateDisplay()
        return
    end

    local fishToTrade = tradeQueue[currentTradeIndex]
    autoTradeStatus = string.format("Trading %d/%d: Equipping '%s'...", currentTradeIndex, #tradeQueue, fishToTrade.name)
    updateDisplay()

    task.wait(1.5)

    local equipResult = equipFishByData(fishToTrade)
    if not equipResult.success then
        stopAutoTrade(string.format("Error: Failed to find/equip '%s'. It might be equipped already. Stopping.", fishToTrade.name))
        return
    end

    autoTradeStatus = string.format("Trading %d/%d: Waiting for equip confirmation...", currentTradeIndex, #tradeQueue)
    updateDisplay()
    
    local equipConfirmed = false
    local startTime = tick()
    repeat
        task.wait(0.1)
        local equippedItems = PlayerData:GetExpect("EquippedItems")
        for _, equippedUUID in ipairs(equippedItems) do
            if equippedUUID == equipResult.uuid then
                equipConfirmed = true
                break
            end
        end
        if equipConfirmed then break end
    until tick() - startTime > 5

    if not equipConfirmed then
        stopAutoTrade(string.format("Error: Equip of '%s' was not confirmed on client. Stopping.", fishToTrade.name))
        return
    end

    autoTradeStatus = string.format("Trading %d/%d: Item confirmed. Initiating trade...", currentTradeIndex, #tradeQueue)
    updateDisplay()
    task.wait(1.5)

    local success, result = pcall(function()
        local InitiateTradeFunc = ReplicatedStorage.Packages._Index["sleitnick_net@0.2.0"].net["RF/InitiateTrade"]
        return InitiateTradeFunc:InvokeServer(selectedTradePartner.UserId, tostring(equipResult.uuid))
    end)

    if success and result then
        autoTradeStatus = string.format("Trading %d/%d: Request sent. Waiting for response...", currentTradeIndex, #tradeQueue)
    else
        local failReason = (not success) and tostring(result) or "Player busy/far"
        stopAutoTrade("Error: Failed to send trade request. " .. failReason)
    end
    updateDisplay()
end


-- Create the GUI Library (simplified version)
local FishDetectorLib = {}

do
    local function getResponsiveSize()
        local viewport = workspace.CurrentCamera.ViewportSize
        local isMobile = viewport.X < 800 or viewport.Y < 600

        if isMobile then
            return {
                windowWidth = math.min(viewport.X * 0.9, 350),
                windowHeight = math.min(viewport.Y * 0.8, 450),
                titleSize = 16,
                textSize = 13,
                buttonHeight = 35,
                padding = 8
            }
        else
            return {
                windowWidth = 400,
                windowHeight = 500,
                titleSize = 18,
                textSize = 14,
                buttonHeight = 38,
                padding = 12
            }
        end
    end

    local function createWindow(titleText)
        local existingGui = CoreGui:FindFirstChild("FishDetector_UI")
        if existingGui then
            existingGui:Destroy()
        end

        local responsive = getResponsiveSize()

        local screenGui = Instance.new("ScreenGui")
        screenGui.Name = "FishDetector_UI"
        screenGui.ResetOnSpawn = false
        screenGui.IgnoreGuiInset = true
        screenGui.DisplayOrder = 1000
        screenGui.Parent = CoreGui

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

        local topCorner = Instance.new("UICorner")
        topCorner.CornerRadius = UDim.new(0, 12)
        topCorner.Parent = topBar

        local titleLabel = Instance.new("TextLabel")
        titleLabel.Name = "Title"
        titleLabel.BackgroundTransparency = 1
        titleLabel.Size = UDim2.new(1, -60, 1, 0)
        titleLabel.Position = UDim2.new(0, 15, 0, 0)
        titleLabel.Font = Enum.Font.GothamBold
        titleLabel.Text = titleText or "🐟 Fish Detector"
        titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        titleLabel.TextSize = responsive.titleSize
        titleLabel.TextXAlignment = Enum.TextXAlignment.Left
        titleLabel.TextYAlignment = Enum.TextYAlignment.Center
        titleLabel.Parent = topBar

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

        local contentFrame = Instance.new("ScrollingFrame")
        contentFrame.Name = "Content"
        contentFrame.BackgroundTransparency = 1
        contentFrame.Size = UDim2.new(1, -20, 1, -60)
        contentFrame.Position = UDim2.new(0, 10, 0, 50)
        contentFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
        contentFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
        contentFrame.ScrollBarThickness = 6
        contentFrame.ScrollBarImageColor3 = Color3.fromRGB(80, 80, 80)
        contentFrame.Parent = mainFrame

        local contentLayout = Instance.new("UIListLayout")
        contentLayout.FillDirection = Enum.FillDirection.Vertical
        contentLayout.SortOrder = Enum.SortOrder.LayoutOrder
        contentLayout.Padding = UDim.new(0, responsive.padding)
        contentLayout.Parent = contentFrame

        local contentPadding = Instance.new("UIPadding")
        contentPadding.PaddingLeft = UDim.new(0, responsive.padding)
        contentPadding.PaddingRight = UDim.new(0, responsive.padding)
        contentPadding.PaddingTop = UDim.new(0, responsive.padding)
        contentPadding.PaddingBottom = UDim.new(0, responsive.padding * 2)
        contentPadding.Parent = contentFrame

        local dragging = false
        local dragStart, startPos
        topBar.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                dragging = true
                dragStart = input.Position
                startPos = mainFrame.Position
                local changeConn
                changeConn = input.Changed:Connect(function()
                    if input.UserInputState == Enum.UserInputState.End then
                        dragging = false
                        if changeConn then changeConn:Disconnect() end
                    end
                end)
            end
        end)
        UserInputService.InputChanged:Connect(function(input)
            if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                local delta = input.Position - dragStart
                local viewport = workspace.CurrentCamera.ViewportSize
                local newPosX = math.clamp(startPos.X.Offset + delta.X, 0, viewport.X - responsive.windowWidth)
                local newPosY = math.clamp(startPos.Y.Offset + delta.Y, 0, viewport.Y - responsive.windowHeight)
                mainFrame.Position = UDim2.new(0, newPosX, 0, newPosY)
            end
        end)

        local window = {
            _screenGui = screenGui,
            _mainFrame = mainFrame,
            _contentFrame = contentFrame,
            _closeButton = closeButton,
        }

        function window:AddButton(text, callback)
            local button = Instance.new("TextButton")
            button.Name = "Button"
            button.BackgroundColor3 = Color3.fromRGB(50, 130, 245)
            button.TextColor3 = Color3.fromRGB(255, 255, 255)
            button.Font = Enum.Font.GothamSemibold
            button.Text = text
            button.TextSize = responsive.textSize
            button.AutoButtonColor = false
            button.Size = UDim2.new(1, 0, 0, responsive.buttonHeight)
            button.Parent = self._contentFrame
            local corner = Instance.new("UICorner")
            corner.CornerRadius = UDim.new(0, 6)
            corner.Parent = button
            button.MouseEnter:Connect(function() button.BackgroundColor3 = Color3.fromRGB(60, 140, 255) end)
            button.MouseLeave:Connect(function() button.BackgroundColor3 = Color3.fromRGB(50, 130, 245) end)
            button.MouseButton1Click:Connect(function() if callback then pcall(callback) end end)
            return button
        end

        function window:AddLabel(text)
            local label = Instance.new("TextLabel")
            label.Name = "Label"
            label.BackgroundColor3 = Color3.fromRGB(28, 28, 28)
            label.TextColor3 = Color3.fromRGB(255, 255, 255)
            label.Font = Enum.Font.Gotham
            label.Text = text
            label.TextSize = responsive.textSize
            label.AutomaticSize = Enum.AutomaticSize.Y
            label.Size = UDim2.new(1, 0, 0, 0)
            label.TextWrapped = true
            label.TextXAlignment = Enum.TextXAlignment.Left
            label.TextYAlignment = Enum.TextYAlignment.Top
            label.Parent = self._contentFrame
            local labelPadding = Instance.new("UIPadding")
            labelPadding.PaddingLeft = UDim.new(0, responsive.padding)
            labelPadding.PaddingRight = UDim.new(0, responsive.padding)
            labelPadding.PaddingTop = UDim.new(0, responsive.padding / 2)
            labelPadding.PaddingBottom = UDim.new(0, responsive.padding / 2)
            labelPadding.Parent = label
            local labelCorner = Instance.new("UICorner")
            labelCorner.CornerRadius = UDim.new(0, 6)
            labelCorner.Parent = label
            local labelStroke = Instance.new("UIStroke")
            labelStroke.Color = Color3.fromRGB(45, 45, 45)
            labelStroke.Thickness = 1
            labelStroke.Parent = label
            return label
        end

        function window:AddSimpleSearchBar(placeholder, onSearch)
            local searchFrame = Instance.new("Frame")
            searchFrame.Name = "SimpleSearchFrame"
            searchFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
            searchFrame.Size = UDim2.new(1, 0, 0, responsive.buttonHeight)
            searchFrame.Parent = self._contentFrame
            local searchCorner = Instance.new("UICorner")
            searchCorner.CornerRadius = UDim.new(0, 6)
            searchCorner.Parent = searchFrame
            local searchStroke = Instance.new("UIStroke")
            searchStroke.Color = Color3.fromRGB(70, 70, 70)
            searchStroke.Thickness = 1
            searchStroke.Parent = searchFrame
            local searchBox = Instance.new("TextBox")
            searchBox.Name = "SimpleSearchBox"
            searchBox.BackgroundTransparency = 1
            searchBox.Size = UDim2.new(1, -20, 1, 0)
            searchBox.Position = UDim2.new(0, 10, 0, 0)
            searchBox.Font = Enum.Font.Gotham
            searchBox.PlaceholderText = placeholder or "Search fish..."
            searchBox.PlaceholderColor3 = Color3.fromRGB(150, 150, 150)
            searchBox.Text = ""
            searchBox.TextColor3 = Color3.fromRGB(255, 255, 255)
            searchBox.TextSize = responsive.textSize
            searchBox.TextXAlignment = Enum.TextXAlignment.Left
            searchBox.TextYAlignment = Enum.TextYAlignment.Center
            searchBox.ClearTextOnFocus = false
            searchBox.Parent = searchFrame
            searchBox.Focused:Connect(function() searchStroke.Color = Color3.fromRGB(50, 130, 245); searchStroke.Thickness = 2 end)
            searchBox.FocusLost:Connect(function() searchStroke.Color = Color3.fromRGB(70, 70, 70); searchStroke.Thickness = 1 end)
            local debounceTime = 0.3
            local lastChangeTime = 0
            searchBox:GetPropertyChangedSignal("Text"):Connect(function()
                lastChangeTime = tick()
                local currentChangeTime = lastChangeTime
                task.wait(debounceTime)
                if currentChangeTime == lastChangeTime and onSearch then onSearch(searchBox.Text) end
            end)
            return searchBox
        end

        function window:AddFishEntry(fishName, mutation, isCurrent, isSelected, fishIndex)
            -- List of special, high-value fish
            local specialFish = {
                ["Megalodon"] = true, ["Blob Shark"] = true, ["Plasma Shark"] = true,
                ["Frostborn Shark"] = true, ["Giant Squid"] = true, ["Ghost Shark"] = true,
                ["Robot Kraken"] = true
            }

            local entry = Instance.new("TextButton")
            entry.Name = "FishEntry"
            entry.AutoButtonColor = false
            entry.Text = ""
            
            local hasMutation = mutation and mutation ~= ""
            local isSpecial = specialFish[fishName]

            if isSelected then
                entry.BackgroundColor3 = Color3.fromRGB(50, 130, 245)
            elseif isCurrent then
                entry.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
            elseif isSpecial then
                entry.BackgroundColor3 = Color3.fromRGB(60, 20, 80) -- Dark Purple for special fish
            elseif hasMutation then
                entry.BackgroundColor3 = Color3.fromRGB(80, 60, 20) -- Dark gold for mutated item background
            else
                entry.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
            end

            entry.Size = UDim2.new(1, 0, 0, 60)
            entry.Parent = self._contentFrame
            local entryCorner = Instance.new("UICorner")
            entryCorner.CornerRadius = UDim.new(0, 8)
            entryCorner.Parent = entry
            local entryStroke = Instance.new("UIStroke")

            if isSelected then
                entryStroke.Color = Color3.fromRGB(70, 150, 255)
                entryStroke.Thickness = 2
            elseif isCurrent then
                entryStroke.Color = Color3.fromRGB(100, 100, 100)
                entryStroke.Thickness = 2
            elseif isSpecial then
                entryStroke.Color = Color3.fromRGB(170, 80, 255) -- Bright Purple stroke
                entryStroke.Thickness = 1.5
            elseif hasMutation then
                entryStroke.Color = Color3.fromRGB(255, 190, 0) -- Bright gold stroke for mutated item
                entryStroke.Thickness = 1.5
            else
                entryStroke.Color = Color3.fromRGB(55, 55, 55)
                entryStroke.Thickness = 1
            end
            entryStroke.Parent = entry
            local entryPadding = Instance.new("UIPadding")
            entryPadding.PaddingLeft = UDim.new(0, responsive.padding)
            entryPadding.PaddingRight = UDim.new(0, responsive.padding)
            entryPadding.PaddingTop = UDim.new(0, responsive.padding / 2)
            entryPadding.PaddingBottom = UDim.new(0, responsive.padding / 2)
            entryPadding.Parent = entry
            local selectionIndicator = Instance.new("Frame")
            selectionIndicator.Name = "SelectionIndicator"
            selectionIndicator.Size = UDim2.new(0, 4, 1, -10)
            selectionIndicator.Position = UDim2.new(1, -10, 0, 5)
            selectionIndicator.BackgroundColor3 = isSelected and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)
            selectionIndicator.BorderSizePixel = 0
            selectionIndicator.Visible = isSelected
            selectionIndicator.Parent = entry
            local indicatorCorner = Instance.new("UICorner")
            indicatorCorner.CornerRadius = UDim.new(0, 2)
            indicatorCorner.Parent = selectionIndicator
            local fishNameLabel = Instance.new("TextLabel")
            fishNameLabel.Name = "FishName"
            fishNameLabel.BackgroundTransparency = 1
            fishNameLabel.Size = UDim2.new(1, -20, 0, 20)
            fishNameLabel.Position = UDim2.new(0, 0, 0, 0)
            fishNameLabel.Font = Enum.Font.GothamSemibold
            fishNameLabel.Text = (isSelected and "✅ " or "🐟 ") .. tostring(fishName)
            fishNameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
            fishNameLabel.TextSize = responsive.textSize
            fishNameLabel.TextXAlignment = Enum.TextXAlignment.Left
            fishNameLabel.TextYAlignment = Enum.TextYAlignment.Center
            fishNameLabel.Parent = entry
            local mutationLabel = Instance.new("TextLabel")
            mutationLabel.Name = "Mutation"
            mutationLabel.BackgroundTransparency = 1
            mutationLabel.Size = UDim2.new(1, -20, 0, 18)
            mutationLabel.Position = UDim2.new(0, 0, 0, 22)
            mutationLabel.Font = Enum.Font.Gotham
            mutationLabel.Text = mutation and ("✨ " .. tostring(mutation)) or "⚪ No Mutation"
            mutationLabel.TextColor3 = hasMutation and Color3.fromRGB(255, 215, 0) or Color3.fromRGB(150, 150, 150)
            mutationLabel.TextSize = responsive.textSize - 1
            mutationLabel.TextXAlignment = Enum.TextXAlignment.Left
            mutationLabel.TextYAlignment = Enum.TextYAlignment.Center
            mutationLabel.Parent = entry
            entry.MouseButton1Click:Connect(function()
                local wasSelected = selectedFishIndices[fishIndex]
                if wasSelected then selectedFishIndices[fishIndex] = nil
                else selectedFishIndices[fishIndex] = true; end
                updateDisplay()
            end)
            entry.MouseEnter:Connect(function()
                if not isSelected then
                    if isCurrent then
                        entry.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
                    elseif isSpecial then
                        entry.BackgroundColor3 = Color3.fromRGB(80, 40, 100) -- Lighter purple hover
                    elseif hasMutation then
                        entry.BackgroundColor3 = Color3.fromRGB(100, 80, 40) -- Lighter hover for mutated
                    else
                        entry.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
                    end
                end
            end)
            entry.MouseLeave:Connect(function()
                if isSelected then
                    entry.BackgroundColor3 = Color3.fromRGB(50, 130, 245)
                elseif isCurrent then
                    entry.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
                elseif isSpecial then
                    entry.BackgroundColor3 = Color3.fromRGB(60, 20, 80) -- Restore base special color
                elseif hasMutation then
                    entry.BackgroundColor3 = Color3.fromRGB(80, 60, 20) -- Restore base mutated color
                else
                    entry.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
                end
            end)
            return entry
        end

        function window:ClearContent()
            local contentFrame = self._contentFrame
            for _, child in pairs(contentFrame:GetChildren()) do
                if child:IsA("GuiObject") and not child:IsA("UILayout") and not child:IsA("UIPadding") then
                    child:Destroy()
                end
            end
        end

        function window:Toggle(force)
            if typeof(force) == "boolean" then self._screenGui.Enabled = force
            else self._screenGui.Enabled = not self._screenGui.Enabled end
            return self._screenGui.Enabled
        end

        closeButton.MouseButton1Click:Connect(function() window:Toggle(false) end)
        closeButton.MouseEnter:Connect(function() closeButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60) end)
        closeButton.MouseLeave:Connect(function() closeButton.BackgroundColor3 = Color3.fromRGB(40, 40, 40) end)

        return window
    end

    function FishDetectorLib.CreateWindow(titleText)
        return createWindow(titleText)
    end
end

-- ============================================================================
-- LIGHTWEIGHT INVENTORY SYSTEM INTEGRATION
-- ============================================================================
local LightweightInventory = {}
do
    local inventoryController, originalDestroyTiles, isInventoryHooked, isLoading = nil, nil, false, false
    local function getInventoryController()
        if inventoryController then return inventoryController end
        local success, result = pcall(function()
            return require(ReplicatedStorage:WaitForChild("Controllers", 5):WaitForChild("InventoryController", 5))
        end)
        if success then inventoryController = result; return inventoryController
        else warn("[Fish Detector] Failed to load Inventory Controller:", result) return nil end
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
    local function refreshInventoryTiles()
        if isLoading then return end; isLoading = true
        local ctrl = getInventoryController()
        if not ctrl then isLoading = false; return end
        pcall(function() if ctrl.InventoryStateChanged then ctrl.InventoryStateChanged:Fire("Fish") end end)
        task.wait()
        isLoading = false
    end
    local function initialLoadInventoryTiles()
        if isLoading then return end; isLoading = true
        local ctrl = getInventoryController()
        if not ctrl then isLoading = false; return end
        local playerGui = LocalPlayer:WaitForChild("PlayerGui")
        local inventoryGUI = playerGui:FindFirstChild("Inventory")
        local mainFrame = inventoryGUI and inventoryGUI:FindFirstChild("Main")
        if not mainFrame then warn("[Fish Detector] Inventory GUI not found."); isLoading = false; return end
        local previousEnabled, previousVisible = inventoryGUI.Enabled, mainFrame.Visible
        inventoryGUI.Enabled, mainFrame.Visible = true, true
        task.wait(0.2)
        pcall(function()
            if ctrl.SetPage then ctrl.SetPage(ctrl, "Items") end
            if ctrl.SetCategory then ctrl.SetCategory(ctrl, "Fishes") end
            if ctrl.InventoryStateChanged then ctrl.InventoryStateChanged:Fire("Fish") end
        end)
        task.wait(0.5)
        inventoryGUI.Enabled, mainFrame.Visible = previousEnabled, previousVisible
        isLoading = false
    end
    function LightweightInventory.start()
        if isInventoryHooked then return end
        task.spawn(function()
            if hookInventoryController() then
                task.wait(1); initialLoadInventoryTiles()
                pcall(function()
                    local GuiControl = require(ReplicatedStorage:WaitForChild("Modules"):WaitForChild("GuiControl"))
                    local inventoryGUI = LocalPlayer.PlayerGui:FindFirstChild("Inventory")
                    GuiControl.GuiUnfocusedSignal:Connect(function(closedGui)
                        if closedGui == inventoryGUI then task.delay(0.5, refreshInventoryTiles) end
                    end)
                end)
                pcall(function()
                    local fishCaughtEvent = ReplicatedStorage.Packages._Index["sleitnick_net@0.2.0"].net:WaitForChild("RE/FishCaught")
                    fishCaughtEvent.OnClientEvent:Connect(function() task.delay(1, refreshInventoryTiles) end)
                end)
            else warn("[Fish Detector] Could not start inventory system.") end
        end)
    end
    function LightweightInventory.stop()
        if not isInventoryHooked or not inventoryController or not originalDestroyTiles then return end
        inventoryController.DestroyTiles = originalDestroyTiles
        isInventoryHooked, inventoryController, originalDestroyTiles = false, nil, nil
    end
    function LightweightInventory.getController() return getInventoryController() end
end

-- Enhanced search function with better filtering
local function filterFish(search)
    displayedFish = {}
    searchTerm = (search and string.lower(search) or "")
    if searchTerm == "" then
        for i, fish in ipairs(detectedFish) do table.insert(displayedFish, {fish = fish, originalIndex = i}) end
    else
        for i, fish in ipairs(detectedFish) do
            local fishName = string.lower(fish.name or "")
            local fishMutation = string.lower(fish.mutation or "")
            if string.find(fishName, searchTerm, 1, true) or string.find(fishMutation, searchTerm, 1, true) then
                table.insert(displayedFish, {fish = fish, originalIndex = i})
            end
        end
    end
    if currentIndex > #displayedFish then currentIndex = #displayedFish > 0 and 1 or 1 end
end

-- Fish detection functions
local function getInventoryController() return LightweightInventory.getController() end

local function detectFish()
    detectedFish = {}
    isDetecting = true

    local ctrl = getInventoryController()
    if not ctrl then
        warn("[Fish Detector] Inventory Controller not available")
        isDetecting = false
        return false
    end

    local playerGui = LocalPlayer.PlayerGui
    local inventoryContainer = playerGui:FindFirstChild("Inventory")
    if not inventoryContainer then
        warn("[Fish Detector] Inventory GUI not found")
        isDetecting = false
        return false
    end

    local main = inventoryContainer:FindFirstChild("Main")
    if not main then
        warn("[Fish Detector] Inventory Main frame not found")
        isDetecting = false
        return false
    end

    local wasEnabled, wasVisible = inventoryContainer.Enabled, main.Visible
    inventoryContainer.Enabled, main.Visible = true, true

    -- Set the category based on currentCategory variable
    pcall(function()
        if ctrl.SetPage then ctrl.SetPage(ctrl, "Items") end
        if currentCategory == "Fishes" then
            if ctrl.SetCategory then ctrl.SetCategory(ctrl, "Fishes") end
            if ctrl.InventoryStateChanged then ctrl.InventoryStateChanged:Fire("Fish") end
        elseif currentCategory == "Items" then
            if ctrl.SetCategory then ctrl.SetCategory(ctrl, "Items") end
            if ctrl.InventoryStateChanged then ctrl.InventoryStateChanged:Fire("Item") end
        end
    end)

    task.wait(0.5)

    local content = main:FindFirstChild("Content")
    if not content then warn("[Fish Detector] Content not found"); inventoryContainer.Enabled, main.Visible = wasEnabled, wasVisible; isDetecting = false; return false end
    local pages = content:FindFirstChild("Pages")
    if not pages then warn("[Fish Detector] Pages not found"); inventoryContainer.Enabled, main.Visible = wasEnabled, wasVisible; isDetecting = false; return false end
    local inventory = pages:FindFirstChild("Inventory")
    if not inventory then warn("[Fish Detector] Inventory page not found"); inventoryContainer.Enabled, main.Visible = wasEnabled, wasVisible; isDetecting = false; return false end

    local tiles = inventory:GetChildren()
    local itemCount = 0
    for i, tile in ipairs(tiles) do
        if tile.Name == "Tile" and tile:IsA("GuiObject") then
            local itemNameElement = tile:FindFirstChild("ItemName")
            if itemNameElement and itemNameElement.Text and itemNameElement.Text ~= "" then
                local itemName = trim(itemNameElement.Text)
                local mutation = nil

                -- Handle special mutations that are part of the name (for Fishes)
                if currentCategory == "Fishes" then
                    local prefixes = {"Shiny ", "Big "}
                    for _, prefix in ipairs(prefixes) do
                        if string.sub(itemName, 1, #prefix) == prefix then
                            mutation = string.gsub(prefix, " ", "") -- "Shiny" or "Big"
                            itemName = trim(string.sub(itemName, #prefix + 1))
                            break
                        end
                    end

                    -- If no prefix mutation was found, check the variant UI element
                    if not mutation then
                        local variantElement = tile:FindFirstChild("Variant")
                        if variantElement then
                            local mutationElement = variantElement:FindFirstChild("ItemName")
                            if mutationElement and mutationElement.Text and mutationElement.Text ~= "Ghoulish" and mutationElement.Text ~= "" then
                                mutation = mutationElement.Text
                            end
                        end
                    end
                end

                print(string.format("[detectFish] Found %s: '%s' with mutation: '%s'", currentCategory, itemName, tostring(mutation)))
                table.insert(detectedFish, {index = itemCount + 1, name = itemName, mutation = mutation, tileIndex = i, category = currentCategory})
                itemCount = itemCount + 1
            end
        end
    end

    inventoryContainer.Enabled, main.Visible = wasEnabled, wasVisible
    print(string.format("[Fish Detector] Detection complete. Found %d %s.", itemCount, currentCategory))
    filterFish("")
    isDetecting = false
    return true
end

-- Rod Detection Function
local function detectRods()
    detectedRods = {}
    isDetecting = true
    print("[Rod Detector] Starting rod detection from PlayerData...")

    if not PlayerData then
        warn("[Rod Detector] PlayerData is not available.")
        isDetecting = false
        return false
    end

    local success, inventory = pcall(function()
        return PlayerData:Get("Inventory")
    end)

    if not success or not inventory then
        warn("[Rod Detector] Failed to get inventory from PlayerData:", tostring(inventory))
        isDetecting = false
        return false
    end

    -- The category is "Fishing Rods" as seen in InventoryMapping.lua and inventorycontroller.lua
    local fishingRods = inventory["Fishing Rods"]
    if not fishingRods or type(fishingRods) ~= "table" then
        warn("[Rod Detector] 'Fishing Rods' category not found in inventory data.")
        isDetecting = false
        return false
    end

    print(string.format("[Rod Detector] Found %d total items in 'Fishing Rods' category.", #fishingRods))

    for i, rodItem in ipairs(fishingRods) do
        -- rodItem contains Id and UUID
        local rodData = ItemUtility:GetItemData(rodItem.Id)
        if rodData and rodData.Data then
            local rodName = trim(rodData.Data.Name)
            local rodUUID = rodItem.UUID
            print(string.format("[Rod Detector] Found rod: '%s' (UUID: %s)", rodName, rodUUID))
            table.insert(detectedRods, {index = #detectedRods + 1, name = rodName, uuid = rodUUID})
        else
            warn("[Rod Detector] Could not get data for rod with ID:", rodItem.Id)
        end
    end

    print(string.format("[Rod Detector] Detection complete. Found %d rods.", #detectedRods))
    isDetecting = false
    return true
end

-- Bait Detection Function
local function detectBaits()
    detectedBaits = {}
    isDetecting = true
    print("[Bait Detector] Starting bait detection from PlayerData...")

    if not PlayerData then
        warn("[Bait Detector] PlayerData is not available.")
        isDetecting = false
        return false
    end

    local success, inventory = pcall(function()
        return PlayerData:Get("Inventory")
    end)

    if not success or not inventory then
        warn("[Bait Detector] Failed to get inventory from PlayerData:", tostring(inventory))
        isDetecting = false
        return false
    end

    -- The category is "Baits" as seen in InventoryMapping.lua
    local baits = inventory["Baits"]
    if not baits or type(baits) ~= "table" then
        warn("[Bait Detector] 'Baits' category not found in inventory data.")
        isDetecting = false
        return false
    end

    print(string.format("[Bait Detector] Found %d total items in 'Baits' category.", #baits))

    for i, baitItem in ipairs(baits) do
        -- baitItem contains Id (Baits use Id, not UUID like rods)
        local baitData = ItemUtility:GetBaitData(baitItem.Id)
        if baitData and baitData.Data then
            local baitName = trim(baitData.Data.Name)
            local baitID = baitData.Data.Id
            local baitIcon = baitData.Data.Icon or ""
            print(string.format("[Bait Detector] Found bait: '%s' (ID: %s)", baitName, baitID))
            table.insert(detectedBaits, {index = #detectedBaits + 1, name = baitName, id = baitID, icon = baitIcon})
        else
            warn("[Bait Detector] Could not get data for bait with ID:", baitItem.Id)
        end
    end

    print(string.format("[Bait Detector] Detection complete. Found %d baits.", #detectedBaits))
    isDetecting = false
    return true
end

-- Totem Detection Function
local function detectTotems()
    detectedTotems = {}
    isDetecting = true
    print("[Totem Detector] Starting totem detection from PlayerData...")

    if not PlayerData then
        warn("[Totem Detector] PlayerData is not available.")
        isDetecting = false
        return false
    end

    local success, inventory = pcall(function()
        return PlayerData:Get("Inventory")
    end)

    if not success or not inventory then
        warn("[Totem Detector] Failed to get inventory from PlayerData:", tostring(inventory))
        isDetecting = false
        return false
    end

    -- The category is "Totems" as seen in InventoryMapping.lua
    local totems = inventory["Totems"]
    if not totems or type(totems) ~= "table" then
        warn("[Totem Detector] 'Totems' category not found in inventory data.")
        isDetecting = false
        return false
    end

    print(string.format("[Totem Detector] Found %d total items in 'Totems' category.", #totems))

    for i, totemItem in ipairs(totems) do
        -- totemItem contains Id and UUID (Totems use UUID like Rods)
        local totemData = ItemUtility.GetItemDataFromItemType("Totems", totemItem.Id)
        if totemData and totemData.Data then
            local totemName = trim(totemData.Data.Name)
            local totemUUID = totemItem.UUID
            local totemIcon = totemData.Data.Icon or ""
            local totemTier = totemData.Data.Tier or 0
            print(string.format("[Totem Detector] Found totem: '%s' (UUID: %s, Tier: %d)", totemName, totemUUID, totemTier))
            table.insert(detectedTotems, {index = #detectedTotems + 1, name = totemName, uuid = totemUUID, icon = totemIcon, tier = totemTier})
        else
            warn("[Totem Detector] Could not get data for totem with ID:", totemItem.Id)
        end
    end

    print(string.format("[Totem Detector] Detection complete. Found %d totems.", #detectedTotems))
    isDetecting = false
    return true
end

updateDisplay = function()
    if not fishDetectionWindow then return end

    local contentFrame = fishDetectionWindow._contentFrame
    fishDetectionWindow:ClearContent()

    -- Create Tab UI
    local tabContainer = Instance.new("Frame")
    tabContainer.Name = "TabContainer"
    tabContainer.Size = UDim2.new(1, 0, 0, 38)
    tabContainer.BackgroundTransparency = 1
    tabContainer.LayoutOrder = -100
    tabContainer.Parent = contentFrame

    local tabLayout = Instance.new("UIListLayout")
    tabLayout.FillDirection = Enum.FillDirection.Horizontal
    tabLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    tabLayout.VerticalAlignment = Enum.VerticalAlignment.Center
    tabLayout.Padding = UDim.new(0, 5)
    tabLayout.Parent = tabContainer

    local function createTab(text, tabName)
        local tabButton = Instance.new("TextButton")
        tabButton.Name = tabName .. "Tab"
        tabButton.Size = UDim2.new(0.142, -4, 1, 0) -- Adjusted for 7 tabs (1/7 = 0.142)
        tabButton.Font = Enum.Font.GothamSemibold
        tabButton.Text = text
        tabButton.TextSize = 10 -- Slightly smaller to fit better
        tabButton.AutoButtonColor = false
        tabButton.Parent = tabContainer

        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, 6)
        corner.Parent = tabButton

        if currentTab == tabName then
            tabButton.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
            tabButton.TextColor3 = Color3.fromRGB(255, 255, 255)
        else
            tabButton.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
            tabButton.TextColor3 = Color3.fromRGB(150, 150, 150)
        end

        tabButton.MouseButton1Click:Connect(function()
            if currentTab ~= tabName then
                currentTab = tabName
                updateDisplay()
            end
        end)
        return tabButton
    end

    createTab("🐟 Fish", "Fish")
    createTab("🎣 Rods", "Rods")
    createTab("🪝 Baits", "Baits")
    createTab("🗿 Totems", "Totems")
    createTab("👥 Players", "Players")
    createTab("🤖 Auto Trade", "AutoTrade")
    createTab("✨ Enchant", "Enchant")

    -- Render content based on tab
    if currentTab == "Fish" then
        -- Add Category Selection Buttons
        local categoryFrame = Instance.new("Frame")
        categoryFrame.Name = "CategoryFrame"
        categoryFrame.Size = UDim2.new(1, 0, 0, 38)
        categoryFrame.BackgroundTransparency = 1
        categoryFrame.LayoutOrder = -99
        categoryFrame.Parent = contentFrame

        local categoryLayout = Instance.new("UIListLayout")
        categoryLayout.FillDirection = Enum.FillDirection.Horizontal
        categoryLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
        categoryLayout.VerticalAlignment = Enum.VerticalAlignment.Center
        categoryLayout.Padding = UDim.new(0, 5)
        categoryLayout.Parent = categoryFrame

        local function createCategoryButton(text, category)
            local catButton = Instance.new("TextButton")
            catButton.Name = category .. "Category"
            catButton.Size = UDim2.new(0.5, -3, 1, 0)
            catButton.Font = Enum.Font.GothamSemibold
            catButton.Text = text
            catButton.TextSize = 13
            catButton.AutoButtonColor = false
            catButton.Parent = categoryFrame

            local corner = Instance.new("UICorner")
            corner.CornerRadius = UDim.new(0, 6)
            corner.Parent = catButton

            if currentCategory == category then
                catButton.BackgroundColor3 = Color3.fromRGB(50, 130, 245)
                catButton.TextColor3 = Color3.fromRGB(255, 255, 255)
            else
                catButton.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
                catButton.TextColor3 = Color3.fromRGB(150, 150, 150)
            end

            catButton.MouseButton1Click:Connect(function()
                if currentCategory ~= category then
                    currentCategory = category
                    detectedFish = {}
                    selectedFishIndices = {}
                    currentIndex = 1
                    updateDisplay()
                end
            end)

            catButton.MouseEnter:Connect(function()
                if currentCategory ~= category then
                    catButton.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
                end
            end)

            catButton.MouseLeave:Connect(function()
                if currentCategory ~= category then
                    catButton.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
                else
                    catButton.BackgroundColor3 = Color3.fromRGB(50, 130, 245)
                end
            end)

            return catButton
        end

        createCategoryButton("🐟 Fishes", "Fishes")
        createCategoryButton("📦 Items", "Items")

        if #detectedFish == 0 then
            fishDetectionWindow:AddLabel("No " .. string.lower(currentCategory) .. " detected. Try detecting first!")
            fishDetectionWindow:AddButton("🔍 Detect " .. currentCategory, function()
                if isDetecting then return end
                detectFish()
                filterFish("")
                updateDisplay()
            end)
            return
        end

        local searchPlaceholder = currentCategory == "Fishes" and "Search fish by name or mutation..." or "Search items by name..."
        fishDetectionWindow:AddSimpleSearchBar(searchPlaceholder, function(searchText)
            filterFish(searchText)
            updateDisplay()
        end)

        local totalCount, displayCount = #detectedFish, #displayedFish
        local itemLabel = currentCategory == "Fishes" and "fish" or "items"
        local navText = searchTerm ~= "" and string.format("Showing %d of %d %s (search: '%s')", displayCount, totalCount, itemLabel, searchTerm) or string.format("%s %d of %d (Use ← → keys to navigate)", itemLabel:sub(1,1):upper()..itemLabel:sub(2), currentIndex, displayCount)
        fishDetectionWindow:AddLabel(navText)

        for i, displayItem in ipairs(displayedFish) do
            local fish, originalIndex = displayItem.fish, displayItem.originalIndex
            local isCurrent, isSelected = (i == currentIndex), selectedFishIndices[originalIndex] or false
            fishDetectionWindow:AddFishEntry(fish.name, fish.mutation, isCurrent, isSelected, originalIndex)
        end

        fishDetectionWindow:AddButton("🔍 Detect " .. currentCategory .. " Again", function()
            if isDetecting then return end
            detectFish()
            currentIndex = 1
            updateDisplay()
        end)

        if #displayedFish > 0 then
            local itemName = currentCategory == "Fishes" and "Fish" or "Item"
            fishDetectionWindow:AddButton("⬅️ Previous " .. itemName, function()
                if currentIndex > 1 then currentIndex = currentIndex - 1; updateDisplay() end
            end)
            fishDetectionWindow:AddButton("➡️ Next " .. itemName, function()
                if currentIndex < #displayedFish then currentIndex = currentIndex + 1; updateDisplay() end
            end)
            fishDetectionWindow:AddButton("🎯 Toggle Current " .. itemName, function()
                local displayItem = displayedFish[currentIndex]
                if displayItem then
                    local originalIndex = displayItem.originalIndex
                    if selectedFishIndices[originalIndex] then selectedFishIndices[originalIndex] = nil
                    else selectedFishIndices[originalIndex] = true end
                    updateDisplay()
                end
            end)
        end

        local selectedCount = 0
        for _ in pairs(selectedFishIndices) do selectedCount = selectedCount + 1 end

        if selectedCount > 0 then
            local itemLabel = currentCategory == "Fishes" and "Fish" or "Items"
            fishDetectionWindow:AddLabel(string.format("📋 Selected %s: %d", itemLabel, selectedCount))
            fishDetectionWindow:AddButton("🗑️ Clear All Selections", function()
                selectedFishIndices = {}; updateDisplay()
            end)
        end

    elseif currentTab == "Rods" then
        local order = 1
        local function add(inst) inst.LayoutOrder = order; order = order + 1; return inst end

        add(fishDetectionWindow:AddLabel("🎣 Fishing Rods"))

        if #detectedRods == 0 then
            add(fishDetectionWindow:AddLabel("No rods detected. Try detecting first!"))
            add(fishDetectionWindow:AddButton("🔍 Detect Rods", function()
                if isDetecting then return end
                detectRods()
                updateDisplay()
            end))
            return
        end

        add(fishDetectionWindow:AddLabel(string.format("Total Rods: %d", #detectedRods)))

        -- Function to open the inventory to the Rods tab
        local function openRodsInventory()
            local GuiControl = require(ReplicatedStorage.Modules.GuiControl)
            local InventoryController = require(ReplicatedStorage.Controllers.InventoryController)

            if GuiControl:IsOpen("Inventory") then
                GuiControl:Close()
            else
                -- Use the controller to set the page and open it
                InventoryController:SetPage("Fishing Rods")
                InventoryController:SetCategory("Fishing Rods")
                if InventoryController.InventoryStateChanged then
                    -- Fire the event to trigger a redraw
                    InventoryController.InventoryStateChanged:Fire("Rods")
                end
                GuiControl:Open("Inventory", false)
            end
        end
        add(fishDetectionWindow:AddButton("📖 Open Game Inventory to Rods", openRodsInventory))

        -- Display all rods with click-to-equip
        for i, rod in ipairs(detectedRods) do
            local isCurrent = (i == currentRodIndex)
            local buttonText = isCurrent and ("▶ " .. rod.name) or ("  " .. rod.name)

            add(fishDetectionWindow:AddButton(buttonText, function()
                currentRodIndex = i
                -- Equip the rod when clicked, using its UUID
                if rod.uuid then
                    equipRodByUUID(rod.uuid)
                else
                    warn("[UI] Rod has no UUID:", rod.name)
                end
                updateDisplay()
            end))
        end

        add(fishDetectionWindow:AddButton("🔍 Detect Rods Again", function()
            if isDetecting then return end
            detectRods()
            currentRodIndex = 1
            updateDisplay()
        end))

    elseif currentTab == "Baits" then
        local order = 1
        local function add(inst) inst.LayoutOrder = order; order = order + 1; return inst end

        add(fishDetectionWindow:AddLabel("🪝 Baits"))

        if #detectedBaits == 0 then
            add(fishDetectionWindow:AddLabel("No baits detected. Try detecting first!"))
            add(fishDetectionWindow:AddButton("🔍 Detect Baits", function()
                if isDetecting then return end
                detectBaits()
                updateDisplay()
            end))
            return
        end

        add(fishDetectionWindow:AddLabel(string.format("Total Baits: %d", #detectedBaits)))

        -- Function to open the inventory to the Baits tab
        local function openBaitsInventory()
            local GuiControl = require(ReplicatedStorage.Modules.GuiControl)
            local InventoryController = require(ReplicatedStorage.Controllers.InventoryController)

            if GuiControl:IsOpen("Inventory") then
                GuiControl:Close()
            else
                -- Use the controller to set the page and open it
                InventoryController:SetPage("Baits")
                InventoryController:SetCategory("Baits")
                if InventoryController.InventoryStateChanged then
                    -- Fire the event to trigger a redraw
                    InventoryController.InventoryStateChanged:Fire("Baits")
                end
                GuiControl:Open("Inventory", false)
            end
        end
        add(fishDetectionWindow:AddButton("📖 Open Game Inventory to Baits", openBaitsInventory))

        -- Display all baits with click-to-equip
        for i, bait in ipairs(detectedBaits) do
            local isCurrent = (i == currentBaitIndex)
            local buttonText = isCurrent and ("▶ " .. bait.name) or ("  " .. bait.name)

            add(fishDetectionWindow:AddButton(buttonText, function()
                currentBaitIndex = i
                -- Equip the bait when clicked, using its ID
                if bait.id then
                    equipBaitByID(bait.id)
                else
                    warn("[UI] Bait has no ID:", bait.name)
                end
                updateDisplay()
            end))
        end

        add(fishDetectionWindow:AddButton("🔍 Detect Baits Again", function()
            if isDetecting then return end
            detectBaits()
            currentBaitIndex = 1
            updateDisplay()
        end))

    elseif currentTab == "Totems" then
        local order = 1
        local function add(inst) inst.LayoutOrder = order; order = order + 1; return inst end

        add(fishDetectionWindow:AddLabel("🗿 Totems"))

        if #detectedTotems == 0 then
            add(fishDetectionWindow:AddLabel("No totems detected. Try detecting first!"))
            add(fishDetectionWindow:AddButton("🔍 Detect Totems", function()
                if isDetecting then return end
                detectTotems()
                updateDisplay()
            end))
            return
        end

        add(fishDetectionWindow:AddLabel(string.format("Total Totems: %d", #detectedTotems)))

        -- Function to open the inventory to the Totems tab
        local function openTotemsInventory()
            local GuiControl = require(ReplicatedStorage.Modules.GuiControl)
            local InventoryController = require(ReplicatedStorage.Controllers.InventoryController)

            if GuiControl:IsOpen("Inventory") then
                GuiControl:Close()
            else
                -- Use the controller to set the page and open it
                InventoryController:SetPage("Items")
                InventoryController:SetCategory("Totems")
                if InventoryController.InventoryStateChanged then
                    -- Fire the event to trigger a redraw
                    InventoryController.InventoryStateChanged:Fire("Inventory")
                end
                GuiControl:Open("Inventory", false)
            end
        end
        add(fishDetectionWindow:AddButton("📖 Open Game Inventory to Totems", openTotemsInventory))

        -- Display all totems with click-to-equip
        for i, totem in ipairs(detectedTotems) do
            local isCurrent = (i == currentTotemIndex)
            local tierText = totem.tier > 0 and (" [T" .. totem.tier .. "]") or ""
            local buttonText = isCurrent and ("▶ " .. totem.name .. tierText) or ("  " .. totem.name .. tierText)

            add(fishDetectionWindow:AddButton(buttonText, function()
                currentTotemIndex = i
                -- Equip the totem when clicked, using its UUID
                if totem.uuid then
                    equipTotemByUUID(totem.uuid)
                else
                    warn("[UI] Totem has no UUID:", totem.name)
                end
                updateDisplay()
            end))
        end

        add(fishDetectionWindow:AddButton("🔍 Detect Totems Again", function()
            if isDetecting then return end
            detectTotems()
            currentTotemIndex = 1
            updateDisplay()
        end))

    elseif currentTab == "Players" then
        local order = 1
        local function add(inst) inst.LayoutOrder = order; order = order + 1; return inst end

        add(fishDetectionWindow:AddLabel("Select a player to trade with."))

        if selectedTradePartner then
            add(fishDetectionWindow:AddLabel("🤝 Trading with: " .. selectedTradePartner.Name))
            add(fishDetectionWindow:AddButton("❌ Clear Selected Player", function()
                selectedTradePartner = nil
                updateDisplay()
            end))
        end

        local players = Players:GetPlayers()
        if #players <= 1 then
            add(fishDetectionWindow:AddLabel("No other players in the server."))
        else
            for _, player in ipairs(players) do
                if player ~= LocalPlayer then
                    add(fishDetectionWindow:AddButton(player.Name, function()
                        selectTradePartner(player)
                    end))
                end
            end
        end
    
    elseif currentTab == "AutoTrade" then
        local order = 1
        local function add(inst) inst.LayoutOrder = order; order = order + 1; return inst end
        
        add(fishDetectionWindow:AddLabel("Auto Trade Automation"))

        local selectedCount = 0
        for _ in pairs(selectedFishIndices) do selectedCount = selectedCount + 1 end

        if selectedTradePartner then
            add(fishDetectionWindow:AddLabel("🎯 Target: " .. selectedTradePartner.Name))
        else
            add(fishDetectionWindow:AddLabel("🎯 Target: None"))
        end

        local itemLabel = currentCategory == "Fishes" and "Fish" or "Items"
        add(fishDetectionWindow:AddLabel(string.format("🐠 Selected %s: %d", itemLabel, selectedCount)))
        add(fishDetectionWindow:AddLabel(string.format("📦 Traded Fish: %d/%d", tradedFishCount, #tradeQueue)))
        add(fishDetectionWindow:AddLabel("💡 Status: " .. autoTradeStatus))

        if isAutoTrading and #tradeQueue > 0 then
            local fishList = {}
            local title = "Remaining Trades:"
            for i = currentTradeIndex, #tradeQueue do
                local fish = tradeQueue[i]
                local mutation = fish.mutation or "None"
                table.insert(fishList, string.format(" - %s (%s)", fish.name, mutation))
            end
            if #fishList > 0 then
                add(fishDetectionWindow:AddLabel(title .. "\n" .. table.concat(fishList, "\n")))
            end
        end

        if isAutoTrading then
            add(fishDetectionWindow:AddButton("🛑 Stop Auto Trade", function()
                stopAutoTrade("Stopped by user.")
            end))
        else
            add(fishDetectionWindow:AddButton("🚀 Start Auto Trade", startAutoTrade))
            add(fishDetectionWindow:AddButton("🔄 Reset Status", function()
                if isAutoTrading then return end -- Prevent reset while trading
                autoTradeStatus = "Idle"
                tradedFishCount = 0
                updateDisplay()
            end))
        end

    elseif currentTab == "Enchant" then
        local order = 1
        local function add(inst) inst.LayoutOrder = order; order = order + 1; return inst end

        add(fishDetectionWindow:AddLabel("✨ Auto Enchant System"))
        add(fishDetectionWindow:AddLabel("Auto teleport + Auto equip + Auto enchant!"))

        -- Status display
        local statusColor = isAutoEnchantOn and "🟢 RUNNING" or "🔴 STOPPED"
        add(fishDetectionWindow:AddLabel("Status: " .. statusColor))

        -- Get target enchant name
        local targetEnchantName = "Unknown"
        for name, id in pairs(enchantDatabase) do
            if id == targetEnchantID then
                targetEnchantName = name
                break
            end
        end

        add(fishDetectionWindow:AddLabel("🎯 Target: " .. targetEnchantName .. " (ID: " .. targetEnchantID .. ")"))
        add(fishDetectionWindow:AddLabel(string.format("🔄 Attempts: %d", enchantAttempts)))

        if enchantFound then
            add(fishDetectionWindow:AddLabel("✅ Status: Target enchant FOUND!"))
            add(fishDetectionWindow:AddLabel(string.format("🎉 Success after %d attempts!", enchantAttempts)))
        elseif isAutoEnchantOn then
            add(fishDetectionWindow:AddLabel("⏳ Status: Searching for target..."))
            add(fishDetectionWindow:AddLabel("🔄 Loop is running continuously"))
        else
            add(fishDetectionWindow:AddLabel("💤 Status: Idle - Ready to start"))
        end

        -- Enchant selection dropdown (using buttons)
        add(fishDetectionWindow:AddLabel("Select Target Enchant:"))

        local enchantNames = {}
        for name, _ in pairs(enchantDatabase) do
            table.insert(enchantNames, name)
        end
        table.sort(enchantNames)

        for _, enchantName in ipairs(enchantNames) do
            local enchantId = enchantDatabase[enchantName]
            local isSelected = (enchantId == targetEnchantID)
            local buttonText = isSelected and ("✅ " .. enchantName) or ("⚪ " .. enchantName)

            add(fishDetectionWindow:AddButton(buttonText, function()
                targetEnchantID = enchantId
                enchantFound = false
                enchantAttempts = 0
                print(string.format("[Auto Enchant] Target changed to: %s (ID: %d)", enchantName, enchantId))
                updateDisplay()
            end))
        end

        -- Control buttons
        if isAutoEnchantOn then
            add(fishDetectionWindow:AddButton("🛑 Stop Auto Enchant", function()
                stopAutoEnchant()
                updateDisplay()
            end))
        else
            add(fishDetectionWindow:AddButton("🚀 Start Auto Enchant (Auto TP)", function()
                isAutoEnchantOn = true
                startAutoEnchant()
                updateDisplay()
            end))
        end

        -- Teleport button
        add(fishDetectionWindow:AddButton("📍 Teleport to Enchant Altar", function()
            teleportToEnchantAltar()
        end))

        -- Manual enchant button
        add(fishDetectionWindow:AddButton("🔧 Manual Enchant Once", function()
            task.spawn(function()
                print("[Auto Enchant] Manual enchant started...")
                local equipped = autoEquipEnchantStone()
                if equipped then
                    activateEnchantingAltar()
                end
            end)
        end))

        -- Test enchant stone detection
        add(fishDetectionWindow:AddButton("🔍 Test Enchant Stone Detection", function()
            local uuid = findEnchantStoneUUID()
            if uuid then
                print("[Auto Enchant] ✅ Enchant stone found with UUID:", uuid)
            else
                print("[Auto Enchant] ❌ No enchant stone found in inventory!")
            end
        end))

        -- Reset counter
        add(fishDetectionWindow:AddButton("🔄 Reset Attempt Counter", function()
            enchantAttempts = 0
            enchantFound = false
            print("[Auto Enchant] Attempt counter reset!")
            updateDisplay()
        end))
    end
end

-- Initialize the fish detection system
local function initializeFishDetector()
    LightweightInventory.start()
    task.wait(3)

    fishDetectionWindow = FishDetectorLib.CreateWindow("🐟 Fish & Trade + Enchant v1.5")
    updateDisplay()

    -- Event Listeners for Auto Trade
    pcall(function()
        local TextNotificationEvent = ReplicatedStorage.Packages._Index["sleitnick_net@0.2.0"].net:WaitForChild("RE/TextNotification")
        TextNotificationEvent.OnClientEvent:Connect(function(data)
            if not isAutoTrading or not fishDetectionWindow or not fishDetectionWindow._screenGui.Enabled then return end
            
            if data and data.Text then
                if string.find(data.Text, "Trade completed!") then
                    tradedFishCount = tradedFishCount + 1
                    autoTradeStatus = string.format("Trade %d/%d successful!", currentTradeIndex, #tradeQueue)
                    updateDisplay()
                    currentTradeIndex = currentTradeIndex + 1
                    task.delay(4, processNextTrade) -- Wait 4 seconds and trade the next item
                elseif string.find(data.Text, "Trade was declined") then
                    -- Explicitly ignore this notification to prevent the loop from stopping.
                    print("[AutoTrade] 'Trade declined' notification received, ignoring as requested.")
                end
            end
        end)
    end)

    UserInputService.InputBegan:Connect(function(input, gameProcessedEvent)
        if gameProcessedEvent or not fishDetectionWindow._screenGui.Enabled or currentTab ~= "Fish" or #displayedFish == 0 then return end

        if input.KeyCode == Enum.KeyCode.Left or input.KeyCode == Enum.KeyCode.A then
            if currentIndex > 1 then currentIndex = currentIndex - 1; updateDisplay() end
        elseif input.KeyCode == Enum.KeyCode.Right or input.KeyCode == Enum.KeyCode.D then
            if currentIndex < #displayedFish then currentIndex = currentIndex + 1; updateDisplay() end
        elseif input.KeyCode == Enum.KeyCode.Return or input.KeyCode == Enum.KeyCode.Space then
            local displayItem = displayedFish[currentIndex]
            if displayItem then
                local originalIndex = displayItem.originalIndex
                if selectedFishIndices[originalIndex] then
                    selectedFishIndices[originalIndex] = nil
                else
                    selectedFishIndices[originalIndex] = true
                end
                updateDisplay()
            end
        end
    end)

    print("🐟 Fish & Trade + Enchant v1.5 initialized!")
end

-- Global functions for easy access
_G.showFishDetector = function()
    if fishDetectionWindow then fishDetectionWindow:Toggle(true)
    else initializeFishDetector() end
end
_G.hideFishDetector = function()
    if fishDetectionWindow then fishDetectionWindow:Toggle(false) end
end
_G.detectFish = function() detectFish(); updateDisplay() end
_G.getDetectedFish = function() return detectedFish end
_G.getSelectedFish = function()
    local selectedFish = {}
    for index, _ in pairs(selectedFishIndices) do
        if detectedFish[index] then table.insert(selectedFish, detectedFish[index]) end
    end
    return selectedFish
end
_G.clearAllSelections = function() selectedFishIndices = {}; updateDisplay() end
_G.selectAllFish = function()
    for i = 1, #detectedFish do selectedFishIndices[i] = true end
    updateDisplay()
end
_G.stopFishDetectorInventory = function() LightweightInventory.stop() end
_G.startFishDetectorInventory = function() LightweightInventory.start() end

-- Auto-initialize
task.wait(2)
initializeFishDetector()

print("=" .. string.rep("=", 55) .. "=")
print("🐟 FISH & TRADE + ENCHANT v1.5 - READY TO USE!")
print("=" .. string.rep("=", 55) .. "=")
print("   showFishDetector() - Show the UI")
print("   hideFishDetector() - Hide the UI")
print("")
print("   🐟 Fish tab - Detect and select fish/items")
print("   🎣 Rods tab - Detect and equip fishing rods")
print("   🪝 Baits tab - Detect and equip baits")
print("   🗿 Totems tab - Detect and equip totems")
print("   👥 Players tab - Select trade partner")
print("   🤖 Auto Trade tab - Start automatic trading")
print("   ✨ Enchant tab - Auto TP + Auto Equip + Auto Enchant!")
print("")
print("   NEW: Totems detection and auto-equip added!")
print("=" .. string.rep("=", 55) .. "=")
