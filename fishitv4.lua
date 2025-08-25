-- Auto Farm GUI - versi UI rapi (Kavo) + MINIMIZE + Custom Delay + Auto Bait Upgrade

-- ====== Bagian asli (tetap) ======
local player = game.Players.LocalPlayer
local replicatedStorage = game:GetService("ReplicatedStorage")
local packages = replicatedStorage:WaitForChild("Packages")
local net = packages:WaitForChild("_Index"):WaitForChild("sleitnick_net@0.2.0"):WaitForChild("net")

local fishingEvent = net:WaitForChild("RE/FishingCompleted")
local sellEvent = net:WaitForChild("RF/SellAllItems")
local chargeEvent = net:WaitForChild("RF/ChargeFishingRod")
local requestMinigameEvent = net:WaitForChild("RF/RequestFishingMinigameStarted")
local cancelFishingEvent = net:WaitForChild("RF/CancelFishingInputs")
local equipEvent = net:WaitForChild("RE/EquipToolFromHotbar")
local unequipEvent = net:WaitForChild("RE/UnequipToolFromHotbar")
local purchaseRodEvent = net:WaitForChild("RF/PurchaseFishingRod")
local purchaseBaitEvent = net:WaitForChild("RF/PurchaseBait")

local isAutoFishOn, isAutoSellOn, isEquipRodOn = false, false, false
local isUpgradeOn = false
local isUpgradeBaitOn = false -- New flag for bait upgrade

-- ====== CUSTOM DELAY VARIABLES ======
local chargeFishingDelay = 0.1  -- Default delay untuk chargeFishingRod
local autoFishMainDelay = 5     -- Default delay untuk main auto fish loop
local autoSellDelay = 5         -- Default delay untuk auto sell

local teleportLocations = {
    { Name = "Kohana Volcano", CFrame = CFrame.new(-594.971252, 396.65213, 149.10907) },
    { Name = "Crater Island",  CFrame = CFrame.new(1010.01001, 252, 5078.45117) },
    { Name = "Tropical Grove",  CFrame = CFrame.new(-2095.34106, 197.199997, 3718.08008) },
    { Name = "Enchant Island",  CFrame = CFrame.new(3257.91504, -1303.10461, 1390.58118) },
    { Name = "Coral Reefs",  CFrame = CFrame.new(-3023.97119, 337.812927, 2195.60913, 1, 0, 0, 0, 1, 0, 0, 0, 1) },
    { Name = "Esoteric Depths",  CFrame = CFrame.new(1944.77881, 393.562927, 1371.35913, 1, 0, 0, 0, 1, 0, 0, 0, 1) },
    { Name = "Lost Isle",  CFrame = CFrame.new(-3618.15698, 240.836655, -1317.45801, 1, 0, 0, 0, 1, 0, 0, 0, 1) },
    { Name = "Tropical Grove",  CFrame = CFrame.new(-2095.34106, 197.199997, 3718.08008, 1, 0, 0, 0, 1, 0, 0, 0, 1) },
    { Name = "Weather Machine",  CFrame = CFrame.new(-1488.51196, 83.1732635, 1876.30298, 1, 0, 0, 0, 1, 0, 0, 0, 1) },
    { Name = "Spawn",  CFrame = CFrame.new(45.2788086, 252.562927, 2987.10913, 1, 0, 0, 0, 1, 0, 0, 0, 1) },
    { Name = "Treasure Room",  CFrame = CFrame.new(-3602.42749, -266.574341, -1569.40308, -0.999556541, 0, -0.0297777914, 0, 1, 0, 0.0297777914, 0, -0.999556541) }
}

-- ====== DAFTAR ROD IDS DARI TERMURAH KE TERMAHAL ======
local rodIDs = {79, 76, 85, 76, 78, 4, 80, 6, 7, 5}

-- ====== DAFTAR BAIT IDS DARI TERMURAH KE TERMAHAL ======
local baitIDs = {10, 2, 3, 6, 8, 15, 16}

-- ====== FUNGSI INTI ======
local function chargeFishingRod()
    pcall(function()
        chargeEvent:InvokeServer(1755848498.4834)
        task.wait(chargeFishingDelay) -- Menggunakan custom delay
        requestMinigameEvent:InvokeServer(1.2854545116425, 1)
    end)
end

local function cancelFishing()
    pcall(function()
        cancelFishingEvent:InvokeServer()
    end)
end

local function setFish(state)
    isAutoFishOn = state
    if not state then cancelFishing() end
end

local function setSell(state)
    isAutoSellOn = state
end

local function setEquip(state)
    isEquipRodOn = state
    if state then
        pcall(function() equipEvent:FireServer(1) end)
    else
        pcall(function() unequipEvent:FireServer() end)
    end)
end

local function setUpgrade(state)
    isUpgradeOn = state
end

local function setUpgradeBait(state)
    isUpgradeBaitOn = state
end

-- ====== UI Kavo ======
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/xHeptc/Kavo-UI-Library/main/source.lua"))()
local Window  = Library.CreateLib("Auto Farm", "DarkTheme")

-- TAB: Auto
local TabAuto      = Window:NewTab("Auto")
local SecToggles   = TabAuto:NewSection("Toggles")
local SecDelays    = TabAuto:NewSection("Delay Settings")
local SecUI        = TabAuto:NewSection("UI Controls")

SecToggles:NewToggle("Fish", "Auto memancing", function(state) setFish(state) end)
SecToggles:NewToggle("Sell", "Auto jual",       function(state) setSell(state) end)
SecToggles:NewToggle("Equip Rod", "Auto equip", function(state) setEquip(state) end)

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

-- ====== MINIMIZE SYSTEM ======
-- Mini bar terpisah dari Kavo, tetap terlihat saat UI dimininize
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
MiniBtn.Size = UDim2.new(0, 170, 0, 36)
MiniBtn.Position = UDim2.new(0, 20, 0, 80)
MiniBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
MiniBtn.BorderSizePixel = 0
MiniBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
MiniBtn.TextSize = 14
MiniBtn.Font = Enum.Font.GothamSemibold
MiniBtn.Text = "⤢  Auto Farm (Show)"
MiniBtn.AutoButtonColor = true
MiniBtn.Visible = false
MiniBtn.Parent = MiniGui

-- drag sederhana untuk mini button
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
        Library:ToggleUI() -- hide semua window Kavo
    end
end

local function restoreUI()
    if isMinimized then
        isMinimized = false
        if MiniBtn then MiniBtn.Visible = false end
        Library:ToggleUI() -- tampilkan kembali
    end
end

MiniBtn.MouseButton1Click:Connect(restoreUI)

SecUI:NewKeybind("Minimize/Restore (RightShift)", "Toggle UI cepat", Enum.KeyCode.RightShift, function()
    if isMinimized then restoreUI() else minimizeUI() end
end)

-- Custom minimize button sistem - menggunakan pendekatan berbeda
task.spawn(function()
    task.wait(1) -- Tunggu UI terbentuk sempurna
    
    -- Method 1: Coba dengan nama yang mungkin berbeda
    local possibleNames = {"Kavo UI", "KavoLibrary", "UI", "MainUI"}
    local kavoGui = nil
    
    for _, name in pairs(possibleNames) do
        kavoGui = CoreGui:FindFirstChild(name)
        if kavoGui then break end
    end
    
    -- Method 2: Jika tidak ketemu, cari berdasarkan children
    if not kavoGui then
        for _, gui in pairs(CoreGui:GetChildren()) do
            if gui:IsA("ScreenGui") and gui.Name ~= "AF_Minibar" then
                -- Cek apakah ini Kavo GUI dengan mencari structure yang khas
                local frame = gui:FindFirstChildOfClass("Frame")
                if frame and frame:FindFirstChild("Main") then
                    kavoGui = gui
                    break
                end
            end
        end
    end
    
    if not kavoGui then
        warn("Kavo GUI tidak ditemukan, menggunakan tombol di UI Controls")
        return
    end
    
    -- Cari struktur Kavo yang sebenarnya
    local mainFrame = kavoGui:FindFirstChild("Main") or kavoGui:FindFirstChildOfClass("Frame")
    if not mainFrame then return end
    
    -- Cari title bar dengan lebih spesifik
    local titleBar = nil
    for _, child in pairs(mainFrame:GetChildren()) do
        if child:IsA("Frame") and (child.Name:lower():find("top") or child.Name:lower():find("title") or child.Size.Y.Offset < 40) then
            titleBar = child
            break
        end
    end
    
    -- Jika masih tidak ketemu, cari frame dengan posisi paling atas
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
        warn("Title bar tidak ditemukan")
        return
    end
    
    -- Cari tombol close (X) sebagai referensi posisi
    local closeBtn = nil
    for _, child in pairs(titleBar:GetDescendants()) do
        if child:IsA("TextButton") and (child.Text == "X" or child.Text == "✕" or child.Text:find("close")) then
            closeBtn = child
            break
        end
    end
    
    -- Buat minimize button
    local minimizeBtn = Instance.new("TextButton")
    minimizeBtn.Name = "CustomMinimizeButton"
    minimizeBtn.Size = UDim2.new(0, 20, 0, 20)
    
    -- Posisikan berdasarkan close button jika ada
    if closeBtn then
        minimizeBtn.Position = UDim2.new(0, closeBtn.Position.X.Offset - 25, 0, closeBtn.Position.Y.Offset)
    else
        -- Default position
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
    
    -- Styling
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 2)
    corner.Parent = minimizeBtn
    
    -- Hover effects
    minimizeBtn.MouseEnter:Connect(function()
        minimizeBtn.BackgroundColor3 = Color3.fromRGB(65, 65, 65)
    end)
    
    minimizeBtn.MouseLeave:Connect(function()
        minimizeBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    end)
    
    -- Click action
    minimizeBtn.MouseButton1Click:Connect(function()
        minimizeUI()
    end)
    
    print("Custom minimize button created successfully!")
end)

-- TAB: Teleport
local TabTP    = Window:NewTab("Teleport")
local SecTP    = TabTP:NewSection("Lokasi")

local tpNames = {}
for _, loc in ipairs(teleportLocations) do table.insert(tpNames, loc.Name) end

SecTP:NewDropdown("Pilih Lokasi", "Teleport instan", tpNames, function(chosen)
    for _, location in ipairs(teleportLocations) do
        if location.Name == chosen then
            pcall(function()
                local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
                if root then root.CFrame = location.CFrame end
            end)
            break
        end
    end
end)

-- TAB: Upgrades
local Upgrades    = Window:NewTab("Auto Upgrade")
local AutoRod     = Upgrades:NewSection("Auto Upgrade Rod")
local AutoBait    = Upgrades:NewSection("Auto Upgrade Bait")
AutoRod:NewToggle("Upgrade Rod", "Auto upgrade rod", function(state) setUpgrade(state) end)
AutoBait:NewToggle("Upgrade Bait", "Auto upgrade bait", function(state) setUpgradeBait(state) end)

-- ====== LOOP AUTO ======
-- Auto Fish
task.spawn(function()
    while true do
        if isAutoFishOn then
            pcall(function()
                chargeFishingRod()
                task.wait(autoFishMainDelay) -- Menggunakan custom delay
                fishingEvent:FireServer()
            end)
        end
        task.wait(0.01) -- minimal delay untuk mencegah script lag
    end
end)

-- Auto Sell
task.spawn(function()
    while true do
        if isAutoSellOn then
            pcall(function()
                sellEvent:InvokeServer()
            end)
        end
        task.wait(autoSellDelay) -- Menggunakan custom delay
    end
end)

-- Auto Upgrade Rod
task.spawn(function()
    while true do
        if isUpgradeOn then
            for _, id in ipairs(rodIDs) do
                if not isUpgradeOn then break end  -- Cek flag untuk stop jika dimatikan di tengah loop
                pcall(function()
                    purchaseRodEvent:InvokeServer(id)
                end)
                task.wait(2)  -- Delay 2 detik per rod
            end
        end
        task.wait(0.01)  -- Minimal delay saat off
    end
end)

-- Auto Upgrade Bait
task.spawn(function()
    while true do
        if isUpgradeBaitOn then
            for _, id in ipairs(baitIDs) do
                if not isUpgradeBaitOn then break end  -- Cek flag untuk stop jika dimatikan di tengah loop
                pcall(function()
                    purchaseBaitEvent:InvokeServer(id)
                end)
                task.wait(2)  -- Delay 2 detik per bait
            end
        end
        task.wait(0.01)  -- Minimal delay saat off
    end
end)
