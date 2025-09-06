-- Teleport.lua - Teleportation functionality
local Teleport = {}

-- Teleport locations data
local teleportLocations = {
    { Name = "Kohana Volcano", CFrame = CFrame.new(-594.971252, 396.65213, 149.10907) },
    { Name = "Sisyphus Statue",  CFrame = CFrame.new(-3733.67651, -135.573914, -1022.72394, 0.990468323, 7.74683961e-09, 0.137740865, -1.29283579e-08, 1, 3.67232289e-08, -0.137740865, -3.81539564e-08, 0.990468323) },
    { Name = "Crater Island",  CFrame = CFrame.new(1010.01001, 252, 5078.45117) },
    { Name = "Tropical Grove",  CFrame = CFrame.new(-2095.34106, 197.199997, 3718.08008) },
    { Name = "Enchant Island",  CFrame = CFrame.new(3257.91504, -1303.10461, 1390.58118) },
    { Name = "Coral Reefs",  CFrame = CFrame.new(-3023.97119, 337.812927, 2195.60913, 1, 0, 0, 0, 1, 0, 0, 0, 1) },
    { Name = "Esoteric Depths",  CFrame = CFrame.new(1944.77881, 393.562927, 1371.35913, 1, 0, 0, 0, 1, 0, 0, 0, 1) },
    { Name = "Lost Isle",  CFrame = CFrame.new(-3618.15698, 240.836655, -1317.45801, 1, 0, 0, 0, 1, 0, 0, 0, 1) },
    { Name = "Weather Machine",  CFrame = CFrame.new(-1488.51196, 83.1732635, 1876.30298, 1, 0, 0, 0, 1, 0, 0, 0, 1) },
    { Name = "Spawn",  CFrame = CFrame.new(45.2788086, 252.562927, 2987.10913, 1, 0, 0, 0, 1, 0, 0, 0, 1) },
    { Name = "Treasure Room",  CFrame = CFrame.new(-3602.42749, -266.574341, -1569.40308, -0.999556541, 0, -0.0297777914, 0, 1, 0, 0.0297777914, 0, -0.999556541) },
    { Name = "Kohana",  CFrame = CFrame.new(-663.904236, 3.04580712, 718.796875, -0.100799225, -2.14183729e-08, -0.994906783, -1.12300391e-08, 1, -2.03902459e-08, 0.994906783, 9.11752096e-09, -0.100799225) }
}

-- Core teleport function
function Teleport.teleportTo(locationName)
    for _, location in ipairs(teleportLocations) do
        if location.Name == locationName then
            pcall(function()
                local player = game.Players.LocalPlayer
                local rootPart = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
                if rootPart then 
                    rootPart.CFrame = location.CFrame 
                    print("🚀 Teleported to: " .. locationName)
                    return true
                else
                    warn("⚠ Character or HumanoidRootPart not found")
                    return false
                end
            end)
            break
        end
    end
end

-- Get all location names for dropdown
function Teleport.getLocationNames()
    local names = {}
    for _, loc in ipairs(teleportLocations) do 
        table.insert(names, loc.Name) 
    end
    return names
end

-- Add new location
function Teleport.addLocation(name, cframe)
    table.insert(teleportLocations, {Name = name, CFrame = cframe})
    print("📍 Added new location: " .. name)
end

-- Create UI section
function Teleport.createUI(Window)
    local TabTeleport = Window:NewTab("Teleport")
    local SecTP = TabTeleport:NewSection("Quick Teleport")
    
    local locationNames = Teleport.getLocationNames()
    
    SecTP:NewDropdown("Pilih Lokasi", "Teleport instan ke lokasi", locationNames, function(chosen)
        Teleport.teleportTo(chosen)
    end)
    
    -- Add current position saver
    SecTP:NewButton("Save Current Position", "Simpan posisi saat ini", function()
        pcall(function()
            local player = game.Players.LocalPlayer
            local rootPart = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
            if rootPart then
                local currentPos = rootPart.CFrame
                local timestamp = os.date("%H:%M:%S")
                Teleport.addLocation("Custom_" .. timestamp, currentPos)
                print("💾 Current position saved as Custom_" .. timestamp)
            end
        end)
    end)
end

return Teleport
