local ReplicatedStorage = game:GetService("ReplicatedStorage")
local workspace = game:GetService("Workspace")
local Root = ReplicatedStorage["__DIRECTORY"].Upgrades.Root
local Library = ReplicatedStorage:WaitForChild("Library")
local Client = Library.Client
local network = ReplicatedStorage.Network
local LocalPlayer = game.Players.LocalPlayer
local usedInstantLuckPotion3Amount = 0


local save = require(Client.Save)
local upgradeCmds = require(Client.UpgradeCmds)
local fruitCmds = require(Client.FruitCmds)

local orb = require(Client.OrbCmds.Orb)
local inventory = save.Get().Inventory
local maxFruitQueue = fruitCmds.ComputeFruitQueueLimit()

local localPlayerName = LocalPlayer.Name
local instantLuck3PotionId
local upgradeFruitTimeStart = tick()
local upgradeFruitDelay = 60

-- discord
local doNotResend = {}
local discordId = "973180636959490058"
local httpService = game:GetService("HttpService")
local webhookURL = "https://discord.com/api/webhooks/1293110746204340325/dZizvbUU4LtGv9P-1Qmywgdv7tWFNNXU9WxEsGwo9HDBcs7mKNnqdIOK9n69QcMFVJ5L"

-- gui display
local bestDifficulty = 0
local bestDifficultyDisplay


orb.DefaultPickupDistance = 0  -- slowly comes to player, disable
orb.CollectDistance = 400  -- insane instant magnet
orb.BillboardDistance = 0  -- disables gui showing collected coins
orb.SoundDistance = 0
orb.CombineDelay = 0
orb.CombineDistance = 400


while not upgradeCmds.IsUnlocked(require(Root)) do
    task.wait(1)
    network:WaitForChild("Eggs_Roll"):InvokeServer()
    task.wait(1)
    network:WaitForChild("Tutorial_ClickedUpgrades"):FireServer()
    task.wait(1)
    network:WaitForChild("Upgrades_Purchase"):InvokeServer("Root")
end


local function len(table)
    local count = 0
    for _ in pairs(table) do
        count = count + 1
    end
    return count
end


local function findRelics()
    for i=1, 50 do
        if not save.Get()["Relics"][tostring(i)] then
            require(Client.Network).Invoke("Relic_Found", i)
            task.wait()
            print(i)
        end
    end
    if len(save.Get()["Relics"]) < 39 then
        network["Travel to Trading Plaza"]:InvokeServer()
    end
end


local moreRelics = require(Root["Faster Egg Open"]["Faster Egg Open 2"]["Instant Egg Open"]["Golden Dice"]["Small Coin Piles"]["Large Coin Piles"]["More Breakables"]["Even More Breakables"].Relics["More Relics"])
if upgradeCmds.IsUnlocked(moreRelics) then
    findRelics()
    task.wait(3)
end
if workspace:FindFirstChild("TRADING") then
    while true do
        network["Travel to Main World"]:InvokeServer()
        task.wait(5)
    end
end


workspace.OUTER:Destroy()
network["Move Server"]:Destroy()
game:GetService("Lighting"):ClearAllChildren()
workspace[localPlayerName].HumanoidRootPart.Anchored = true

local platform = Instance.new("Part")
platform.Parent = workspace
platform.Anchored = true
platform.CFrame = workspace.MAP.SPAWNS.Spawn.CFrame + Vector3.new(0, -5.5, 0)
platform.Size = Vector3.new(500, 1, 500)
-- platform.Transparency = 1
workspace[localPlayerName].HumanoidRootPart.Anchored = false



require(Client.PlayerPet).CalculateSpeedMultiplier = function(...)
    return 500
end

require(Client.FriendCmds).HasOnlineFriends = function(...)
    return true
end

require(Client.FriendCmds).GetEffectiveFriendsOnline = function(...)
    return 110
end


-- Function to set all lights to NoLight
local function setAllLightsToNoLight()
    for _, v in ipairs(game:GetDescendants()) do
        -- Check if the object is a light
        if v:IsA("PointLight") or v:IsA("SpotLight") or v:IsA("SurfaceLight") then
            -- Set the light to NoLight by setting its brightness to 0
            v.Brightness = 0
            v.Enabled = false
        end
    end
end

-- Call the function
setAllLightsToNoLight()



-- VVV Optimizer VVV

-- turn off settings

local settingsCmds = require(Client.SettingsCmds)

network:WaitForChild("Slider Setting"):InvokeServer("SFX", 0)
network:WaitForChild("Slider Setting"):InvokeServer("Music", 0)

local toggleSettings = {
    "Notifications",
    "ItemNotifications",
    "GlobalHatchMessages",
    "ServerHatchMessages",
    "GlobalNameDisplay",
    "FireworkShow",
    "ShowOtherPets",
    "PetSFX",
    "PetAuras",
    "Vibrations"
}

for _, settingNames in pairs(toggleSettings) do
    if settingsCmds.Get(settingNames) == "Off" then
        -- turn off and on for it to work
        network:WaitForChild("Toggle Setting"):InvokeServer(settingNames)
        task.wait(1)
        network:WaitForChild("Toggle Setting"):InvokeServer(settingNames)
    else
        network:WaitForChild("Toggle Setting"):InvokeServer(settingNames)
    end
end

for _, v in workspace.MAP:GetChildren() do
    if v.Name ~= "SPAWNS" and v.Name ~= "INTERACT" then
        v:Destroy()
    end
end

for _, v in LocalPlayer.PlayerGui.Main:GetChildren() do
    if v:IsA("Frame") then
        v.Visible = false
    end
end
-- disable annoying xp balls
Client.XPBallCmds:Destroy()
network.XPBalls_BulkCreate:Destroy()
Library.Types.XPBalls:Destroy()

LocalPlayer.PlayerScripts.Scripts.Game["Breakable VFX"]:Destroy()


LocalPlayer.PlayerScripts.Scripts.Core["Idle Tracking"].Disabled = true
if getconnections then
    for _, v in pairs(getconnections(LocalPlayer.Idled)) do
        v:Disable()
    end
else
    LocalPlayer.Idled:Connect(function()
        virtualUser:Button2Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
        task.wait(1)
        virtualUser:Button2Up(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
    end)
end
print("[Anti-AFK Activated!]")


local function clearTextures(v)
    if v:IsA("BasePart") and not v:IsA("MeshPart") then
        v.Material = "Plastic"
        v.Reflectance = 0
        v.Transparency = 1
    elseif v:IsA("MeshPart") and tostring(v.Parent) == "Orbs" then
        v.Transparency = 1
    elseif (v:IsA("Decal") or v:IsA("Texture")) then
        v.Transparency = 1
    elseif v:IsA("ParticleEmitter") or v:IsA("Trail") then
        v.Lifetime = NumberRange.new(0)
    elseif v:IsA("Explosion") then
        v.BlastPressure = 1
        v.BlastRadius = 1
    elseif v:IsA("Fire") or v:IsA("SpotLight") or v:IsA("Smoke") or v:IsA("Sparkles") then
        v.Enabled = false
    elseif v:IsA("MeshPart") then
        v.Material = "Plastic"
        v.Reflectance = 0
        v.TextureID = 10385902758728957
        v.Transparency = 1
    elseif v:IsA("SpecialMesh") then
        v.TextureId = 0
    elseif v:IsA("ShirtGraphic") then
        v.Graphic = 1
    elseif (v:IsA("Shirt") or v:IsA("Pants")) then
        v[v.ClassName .. "Template"] = 1
    end
end

for _, v in pairs(game:GetDescendants()) do
    clearTextures(v)
end


-- make player invis
for _, v in pairs(game.Players:GetChildren()) do
    for _, v2 in pairs(v.Character:GetDescendants()) do
        if v2:IsA("BasePart") or v2:IsA("Decal") then
            v2.Transparency = 1
        end
    end
end
-- make joining players invis
game.Players.DescendantAdded:Connect(function(v)
    if v:IsA("BasePart") or v:IsA("Decal") then
        v.Transparency = 1
    end
end)

-- make pets letter invis
for _, v in pairs(workspace.__THINGS.Pets:GetDescendants()) do
    if v.Name == "PetBillboard" then
        v.Enabled = false
    end
end

workspace.__THINGS.Pets.DescendantAdded:Connect(function(v)
    if v.Name == "PetBillboard" then
        v.Enabled = false
    end
end)

for _, v in pairs(workspace.MAP.INTERACT:GetChildren()) do
    if v.Name ~= "Machines" and v.Name ~= "Items" then
        v:Destroy()
    end
end

LocalPlayer.PlayerGui.Notifications:Destroy()

hookfunction(getsenv(LocalPlayer.PlayerScripts.Scripts.Game["Breakables Frontend"]).updateBreakable, function()
    return
end)

hookfunction(require(Client.WorldFX).RewardBillboard, function()
    return
end)

hookfunction(require(Client.OrbCmds.Orb).RenderParticles, function()
    return
end)

hookfunction(require(Client.OrbCmds.Orb).SimulatePhysics, function()
    return
end)

hookfunction(require(Client.GUIFX.Confetti).Play, function()
    return
end)

for _, v in pairs(ReplicatedStorage.Assets:GetChildren()) do
    if v.Name ~= "Cutscenes" and v.Name ~= "Particles" and v.Name ~= "UI" and v.Name ~= "Models" then
        v:Destroy()
    end    
end

local worldFXList = {"Confetti", "RewardImage", "QuestGlow", "Damage", "SpinningChests", "RewardItem", "Sparkles", "AnimatePad", "PlayerTeleport", "AnimateChest", "Poof",
"SmallPuff", "Flash", "Arrow3D", "ArrowPointer3D", "RainbowGlow"}

for x, y in pairs(worldFXList) do
    hookfunction(require(Client.WorldFX[y]), function()
        return
    end)
end

for _, v in pairs(workspace:GetDescendants()) do
    if v:IsA("Part") or v:IsA("BasePart") then
        v.Transparency = 1
    end
end


workspace.DescendantAdded:Connect(function(v)
    clearTextures(v)
end)


-- Lower FOV and Set Camera to First-Person
game.Workspace.CurrentCamera.FieldOfView = 1
LocalPlayer.CameraMode = Enum.CameraMode.LockFirstPerson

-- Disable Particle Effects
for _, v in pairs(game.Workspace:GetDescendants()) do
    if v:IsA("ParticleEmitter") or v:IsA("Trail") or v:IsA("Smoke") then
        v.Enabled = false
    end
end

-- Disable Shadows
game.Lighting.GlobalShadows = false

-- Lower Lighting Quality
game.Lighting.Brightness = 0
game.Lighting.OutdoorAmbient = Color3.new(0, 0, 0) -- Set to black for minimal lighting
game.Lighting.TimeOfDay = "14:00:00" -- Keep it in daytime for simpler lighting

-- Disable Textures
for _, v in pairs(game.Workspace:GetDescendants()) do
    if v:IsA("Texture") or v:IsA("Decal") then
        v:Destroy() -- or set Texture to nil
    end
end

-- Disconnect Unnecessary Events
local connections = getconnections or get_signal_cons
for _, connection in pairs(connections(game:GetService("RunService").RenderStepped)) do
    connection:Disable()
end


-- ^^^ Optimizer ^^^


local function findChest()
    for _, v in workspace["__THINGS"].Breakables:GetChildren() do
        if v:FindFirstChild("Top") then
            return tonumber(v.Name)
        end
    end
end


local function findNormal()
    local normal = {}
    for _, v in workspace["__THINGS"].Breakables:GetChildren() do
        if v:FindFirstChild("1") or v:FindFirstChild("2") or v:FindFirstChild("3") then
            table.insert(normal, tonumber(v.Name))
        end
    end
    return normal
end


local function findFruitCrate()
    for _, v in workspace["__THINGS"].Breakables:GetChildren() do
        if v:FindFirstChild("Apple") or v:FindFirstChild("Banana") or v:FindFirstChild("Pineapple") then
            return tonumber(v.Name)
        end
    end
end


local function petTargetChestAndBreakables()
    local chestNum = findChest()
    local fruitCrateNum
    local normalNum  -- table

    if not chestNum then
        fruitCrateNum = findFruitCrate()
    end
    if not chestNum or not fruitCrateNum then
        normal = findNormal()
    end
    
    local normalIndex = 0
    local args = {
        [1] = {}
    }
    for petId, _ in pairs(require(Client.PlayerPet).GetAll()) do
        normalIndex = normalIndex + 1
        if chestNum then 
            args[1][petId] = chestNum
        elseif fruitCrateNum then
            args[1][petId] = fruitCrateNum
        else
            pcall(function()
                args[1][petId] = normal[normalIndex]
            end)
        end
    end

    network:WaitForChild("Breakables_JoinPetBulk"):FireServer(unpack(args))
end


local function tapChestAndBreakables()
    local target = findChest()

    if not target then  -- target is assigned to chest first, if failed, assign fruit crate
        target = findFruitCrate()
    end
    if not target then  -- if fruit crate failed, then assign normal breakable
        for _, v in workspace["__THINGS"].Breakables:GetChildren() do
            if v:FindFirstChild("1") or v:FindFirstChild("2") or v:FindFirstChild("3") then
                target = tonumber(v.Name)
                break
            end
        end
    end

    for _, v in workspace["__THINGS"].Breakables:GetChildren() do
        if v:FindFirstChild("base") then
            target = tonumber(v.Name)
            break
        end
    end

    network["Breakables_PlayerDealDamage"]:FireServer(target)
end


local function traverseModules(module)
    for _, child in ipairs(module:GetChildren()) do
        if upgradeCmds.IsUnlocked(child.Name) then
            traverseModules(child)
        elseif upgradeCmds.CanAfford(child.Name) then
            -- if child.Name ~= "Trading Booths" and child.Name ~= "More Pet Details" and child.Name ~= "Hoverboard" and child.Name ~= "Faster Pets" then
            upgradeCmds.Unlock(child.Name)
            print("Bought affordable upgrade: " .. child.Name)
            -- end
        end
    end
end


local function checkAndConsumeFruits()
    for fruitId, tbl in pairs(inventory.Fruit) do
        task.wait(0.5)
        if fruitCmds.GetActiveFruits()[tbl.id] ~= nil then
            if (#fruitCmds.GetActiveFruits()[tbl.id]["Normal"] < maxFruitQueue) and (tbl._am ~= nil) then
                -- print("Continue consuming ", tbl.id)
                if tbl._am < fruitCmds.GetMaxConsume(fruitId) then
                    fruitCmds.Consume(fruitId, tonumber(tbl._am))
                else
                    fruitCmds.Consume(fruitId, fruitCmds.GetMaxConsume(fruitId))
                end
            end
        else
            fruitCmds.Consume(fruitId)
        end
    end
end


local function collectHiddenGift()
    for _, v in workspace["__THINGS"].HiddenGifts:GetChildren() do
        for _, v2 in v:GetChildren() do
            task.wait(0.5)
            workspace[localPlayerName].HumanoidRootPart.CFrame = v2.CFrame + Vector3.new(10, 0, 0)

            local character = game.Players.LocalPlayer.Character

            if character and character:FindFirstChild("Humanoid") then
                local humanoid = character.Humanoid
                local targetPosition = v2.Position

                humanoid:MoveTo(targetPosition)
                task.wait(1)
            end
        end
    end
end


local function teleportToDig()
    for _, v in workspace["__THINGS"].Digging:GetChildren() do
        task.wait(2)
        workspace[localPlayerName].HumanoidRootPart.CFrame = v.CFrame
    end
end


local function teleportToMachine(machineName)    
    -- print("Teleporting To", machineName)
    workspace[localPlayerName].HumanoidRootPart.CFrame = workspace.MAP.INTERACT.Machines[machineName].PadGlow.CFrame + Vector3.new(0, -10, 0)
    task.wait(1)
end


-- local function buyIndexShop()
--     for i=1, 3 do
--         for i=1, 6 do
--             task.wait(0.5)
--             network:WaitForChild("Merchant_RequestPurchase"):InvokeServer("AdvancedIndexMerchant", i)
--         end
--     end
-- end


local function consumeBestPotion()
    local cocktailConsumed
    local potionNames = {"Effects_Breakables Potion", "Effects_Coins Potion", "Effects_Faster Rolls Potion", "Effects_Items Potion", "Effects_Lucky Potion"}
    -- local dicePotion = {"Effects_Golden Dice Potion", "Effects_Rainbow Dice Potion", "Effects_Instant Luck Potion", "Effects_The Cocktail"}
    
    for _, potionName in pairs(potionNames) do
        local hasBeenConsumed
        for _, v in game:GetService("Players")[localPlayerName].PlayerGui.Main.Boosts.Inner:GetChildren() do
            if potionName == v.Name then
                hasBeenConsumed = true
                break
            end
        end
        if not hasBeenConsumed then
            local highestTierPotion = 0
            local highestTierPotionId
            for itemId, tbl in pairs(save.Get().Inventory.Consumable) do
                -- sub removes
                if tbl.id == potionName:sub(9) and tbl.tn > highestTierPotion then
                    highestTierPotion = tbl.tn
                    highestTierPotionId = itemId
                    -- print("Consumed:", highestTierPotion)
                end
            end
            pcall(function() network:WaitForChild("Consumables_Consume"):InvokeServer(highestTierPotionId, 1) end)
            task.wait(0.5)
        end
    end

    if instantLuck3PotionId then
        -- check if cocktail been consumed
        for _, v in game:GetService("Players")[localPlayerName].PlayerGui.Main.Boosts.Inner:GetChildren() do
            if "Effects_The Cocktail" == v.Name then
                cocktailConsumed = true
                break
            end
        end

        if not cocktailConsumed then
            for itemId, tbl in pairs(save.Get().Inventory.Consumable) do
                -- sub removes
                if tbl.id == ("Effects_The Cocktail"):sub(9) then
                    pcall(function() network:WaitForChild("Consumables_Consume"):InvokeServer(itemId, 1) end)
                    cocktailConsumed = true
                    task.wait(1)
                    break
                end
            end
        end

        if cocktailConsumed then
            for itemId, tbl in pairs(save.Get().Inventory.Consumable) do
                if tbl.id == "Golden Dice Potion" then
                    pcall(function() network:WaitForChild("Consumables_Consume"):InvokeServer(itemId, 1) end)
                    task.wait(1)
                    break
                end
            end
            print("Using Gold & Instant Luck 3 Potion")
            pcall(function()  
                local success, _ = network:WaitForChild("Consumables_Consume"):InvokeServer(instantLuck3PotionId, 1)
                if success then
                    usedInstantLuckPotion3Amount = usedInstantLuckPotion3Amount + 1
                end
            end)
            task.wait(0.5)
            pcall(function() network:WaitForChild("Consumables_Consume"):InvokeServer(instantLuck3PotionId, 1) end)
            task.wait(0.5)
        end
        instantLuck3PotionId = nil
    end
end


local function smartPotionUpgrade()
    for itemId, tbl in pairs(save.Get().Inventory.Consumable) do
        task.wait()
        if tbl.id == "Lucky Potion" then
            if tbl.tn == 1 and tbl._am ~= nil and tbl._am >= 3 then
                -- print("Crafted Lucky Tier 2")
                for i=1, math.floor(tbl._am / 3) do
                    network:WaitForChild("CraftingMachine_Craft"):InvokeServer("PotionCraftingMachine", 1)
                    task.wait(0.5)
                end
    
            elseif tbl.tn == 2 and tbl._am ~= nil and tbl._am >= 4 then
                -- print("Crafted Lucky Tier 3")
                for i=1, math.floor(tbl._am / 4) do
                    network:WaitForChild("CraftingMachine_Craft"):InvokeServer("PotionCraftingMachine", 2)
                    task.wait(0.5)
                end
    
            elseif tbl.tn == 3 and tbl._am ~= nil and tbl._am >= 5 then
                local stopCraftingTier4Lucky
                local lucky4Amount = 0
                for _, tbl2 in pairs(save.Get().Inventory.Consumable) do
                    if tbl2.id == "Lucky Potion" and tbl2.tn == 4 and tbl2._am ~= nil then
                        if tbl2._am >= 143 then
                            stopCraftingTier4Lucky = true
                            -- print("stop crafting tier 4 lucky")
                            break
                        else
                            lucky4Amount = tbl2._am
                        end
                    end
                end
                if not stopCraftingTier4Lucky then
                    local amountToCraft
                    if math.floor(tbl._am / 4) >= (143 - lucky4Amount) then
                        amountToCraft = (143 - lucky4Amount)
                    else
                        amountToCraft = math.floor(tbl._am / 4)
                    end

                    for i=1, amountToCraft do
                        -- print("Crafted Lucky Tier 4")
                        network:WaitForChild("CraftingMachine_Craft"):InvokeServer("PotionCraftingMachine", 3)
                        task.wait(0.5)
                    end
                end
    
            elseif tbl.tn == 4 and tbl._am ~= nil and tbl._am >= 5 then
                local stopCraftingTier5Lucky
                local lucky5Amount = 0
                for _, tbl2 in pairs(save.Get().Inventory.Consumable) do
                    if tbl2.id == "Lucky Potion" and tbl2.tn == 5 and tbl2._am ~= nil then
                        if tbl2._am >= 19 then
                            stopCraftingTier5Lucky = true
                            -- print("stop crafting tier 5 lucky")
                            break
                        else
                            lucky5Amount = tbl2._am
                        end
                    end
                end
                if not stopCraftingTier5Lucky then
                    local amountToCraft
                    if math.floor(tbl._am / 5) >= (19 - lucky5Amount) then
                        amountToCraft = (19 - lucky5Amount)
                    else 
                        amountToCraft = math.floor(tbl._am / 5)
                    end

                    for i=1, amountToCraft do
                        for _, tbl2 in pairs(save.Get().Inventory.Fruit) do
                            if tbl2.id == "Orange" and tbl2._am ~= nil and tbl2._am >= 12 then
                                -- print("Crafted Lucky Tier 5")
                                network:WaitForChild("CraftingMachine_Craft"):InvokeServer("PotionCraftingMachine", 4)
                                task.wait(0.5)
                                break
                            end
                        end
                    end
                end
            end
        end
    
    
        if tbl.id == "Coins Potion" then
            if tbl.tn == 1 and tbl._am ~= nil and tbl._am >= 3 then
                -- print("Crafted Coins Potion 2")
                for i=1, math.floor(tbl._am / 3) do
                    network:WaitForChild("CraftingMachine_Craft"):InvokeServer("PotionCraftingMachine", 5)
                    task.wait(0.5)
                end
    
            elseif tbl.tn == 2 and tbl._am ~= nil and tbl._am >= 4 then
                -- print("Crafted Coins Potion 3")
                for i=1, math.floor(tbl._am / 4) do
                    network:WaitForChild("CraftingMachine_Craft"):InvokeServer("PotionCraftingMachine", 6)
                    task.wait(0.5)
                end
    
            elseif tbl.tn == 3 and tbl._am ~= nil and tbl._am >= 5 then
                -- print("Crafted Coins Potion 4")
                for i=1, math.floor(tbl._am / 5) do
                    network:WaitForChild("CraftingMachine_Craft"):InvokeServer("PotionCraftingMachine", 7)
                    task.wait(0.5)
                end
    
            elseif tbl.tn == 4 and tbl._am ~= nil and tbl._am >= 5 then
                for _, tbl2 in pairs(save.Get().Inventory.Fruit) do
                    if tbl2.id == "Banana" and tbl2._am >= 12 then
                        -- print("Crafted Coins Potion 5 (BEST)")
                        network:WaitForChild("CraftingMachine_Craft"):InvokeServer("PotionCraftingMachine", 8)
                        task.wait(0.5)
                    end
                end
            end
        end
    
    
        if tbl.id == "Breakables Potion" then
            if tbl.tn == 1 and tbl._am ~= nil and tbl._am >= 3 then
                -- print("Crafted Breakables Potion 2 (BEST)")
                for i=1, math.floor(tbl._am / 3) do
                    network:WaitForChild("CraftingMachine_Craft"):InvokeServer("PotionCraftingMachine", 10)
                    task.wait(0.5)
                end
            end
        end
    
    
        if tbl.id == "Items Potion" then
            if tbl.tn == 1 and tbl._am ~= nil and tbl._am >= 3 then
                -- print("Crafted Items Potion 2")
                for i=1, math.floor(tbl._am / 3) do
                    network:WaitForChild("CraftingMachine_Craft"):InvokeServer("PotionCraftingMachine", 13)
                    task.wait(0.5)
                end
    
            elseif tbl.tn == 2 and tbl._am ~= nil and tbl._am >= 4 then
                -- print("Crafted Items Potion 3 (BEST)")
                for i=1, math.floor(tbl._am / 4) do
                    network:WaitForChild("CraftingMachine_Craft"):InvokeServer("PotionCraftingMachine", 14)
                    task.wait(0.5)
                end
            end
        end
    end
end


-- Get potion and fruit amounts from the player's inventory
local function getInventoryAmounts()
    local amounts = {
        instantLuck2Amount = 0,
        instantLuck1Amount = 0,
        rainbowDiceAmount = 0,
        goldenDiceAmount = 0,
        lucky5Amount = 0,
        lucky4Amount = 0,
        lucky3Amount = 0,
        rainbowFruitAmount = 0,
        orangeAmount = 0,
    }

    -- Get potions amount
    for itemId, tbl in pairs(save.Get().Inventory.Consumable) do
        if tbl.id == "Instant Luck Potion" and tbl.tn == 2 and tbl._am ~= nil then
            amounts.instantLuck2Amount = tbl._am
        elseif tbl.id == "Instant Luck Potion" and tbl.tn == 1 and tbl._am ~= nil then
            amounts.instantLuck1Amount = tbl._am
        elseif tbl.id == "Rainbow Dice Potion" and tbl._am ~= nil then
            amounts.rainbowDiceAmount = tbl._am
        elseif tbl.id == "Golden Dice Potion" and tbl._am ~= nil then
            amounts.goldenDiceAmount = tbl._am
        elseif tbl.id == "Lucky Potion" and tbl.tn == 5 and tbl._am ~= nil then
            amounts.lucky5Amount = tbl._am
        elseif tbl.id == "Lucky Potion" and tbl.tn == 4 and tbl._am ~= nil then
            amounts.lucky4Amount = tbl._am
        elseif tbl.id == "Lucky Potion" and tbl.tn == 3 and tbl._am ~= nil then
            amounts.lucky3Amount = tbl._am
        end
    end

    -- Get orange and rainbow fruit amount
    for itemId, tbl in pairs(save.Get().Inventory.Fruit) do
        if tbl.id == "Orange" and tbl._am ~= nil then
            amounts.orangeAmount = tbl._am
        elseif tbl.id == "Rainbow" and tbl._am ~= nil then
            amounts.rainbowFruitAmount = tbl._am
        end
    end

    return amounts
end

-- Function to craft potions using server invokes
local function craft(potion)
    local amounts = getInventoryAmounts()

    if potion == "instantLuck3" then
        if amounts.instantLuck2Amount >= 3 and amounts.rainbowDiceAmount >= 2 then
            amounts.instantLuck2Amount = amounts.instantLuck2Amount - 3
            amounts.rainbowDiceAmount = amounts.rainbowDiceAmount - 2
            network:WaitForChild("CraftingMachine_Craft"):InvokeServer("PotionCraftingMachine", 22)
            task.wait(0.5)
            print("Crafted: Instant Luck 3")
        else
            while amounts.instantLuck2Amount < 3 or amounts.rainbowDiceAmount < 2 do
                task.wait() -- Default wait before trying again
                amounts = getInventoryAmounts()  -- Re-check inventory
                if amounts.instantLuck2Amount < 3 then
                    craft("instantLuck2")
                end
                if amounts.rainbowDiceAmount < 2 then
                    craft("rainbowDice")
                end
            end
            amounts.instantLuck2Amount = amounts.instantLuck2Amount - 3
            amounts.rainbowDiceAmount = amounts.rainbowDiceAmount - 2
            network:WaitForChild("CraftingMachine_Craft"):InvokeServer("PotionCraftingMachine", 22)
            task.wait(0.5)
            print("Crafted: Instant Luck 3")
        end
    elseif potion == "instantLuck2" then
        if amounts.instantLuck1Amount < 3 then
            error("Not enough Instant Luck 1 potions to craft Instant Luck 2, quitting process.")
        else
            while amounts.rainbowDiceAmount < 2 do
                task.wait() -- Default wait before trying again
                amounts = getInventoryAmounts()  -- Re-check inventory
                if amounts.rainbowDiceAmount < 2 then
                    craft("rainbowDice")
                end
            end
            amounts.instantLuck1Amount = amounts.instantLuck1Amount - 3
            amounts.rainbowDiceAmount = amounts.rainbowDiceAmount - 2
            network:WaitForChild("CraftingMachine_Craft"):InvokeServer("PotionCraftingMachine", 21)
            task.wait(0.5)
            print("Crafted: Instant Luck 2")
        end
    elseif potion == "rainbowDice" then
        if amounts.lucky4Amount >= 2 and amounts.rainbowFruitAmount >= 4 then
            amounts.lucky4Amount = amounts.lucky4Amount - 2
            amounts.rainbowFruitAmount = amounts.rainbowFruitAmount - 4
            network:WaitForChild("CraftingMachine_Craft"):InvokeServer("PotionCraftingMachine", 19)
            task.wait(0.5)
            print("Crafted: Rainbow Dice")
        else
            error("Not enough materials to craft Rainbow Dice, quitting process.")
        end
    end
end


local function upgradeFruits()
    teleportToMachine("UpgradeFruitsMachine")
    local rainbowFruitAmount
    for _, tbl in pairs(save.Get().Inventory.Fruit) do
        if tbl.id == "Rainbow" then
            rainbowFruitAmount = tbl._am
            break
        end
    end
    
    for fruitId, tbl in pairs(save.Get().Inventory.Fruit) do
        if tbl._am ~= nil and tbl._am >= 425 and rainbowFruitAmount <= 2000 then  -- keep 400, use 25 to make rainbow fruit
            local args = {
                [1] = {
                    [fruitId] = (tbl._am - 400)
                }
            }
            network:WaitForChild("UpgradeFruitsMachine_Activate"):InvokeServer(unpack(args))
            task.wait(1)
        end
    end
end


local function sendWebhook(content)
    local messageContent = {
        ["content"] = "<@" .. discordId .. ">" .. "\n```" .. content .. "\nAccount Name: " .. localPlayerName .. "```",
        ["username"] = "Ello What's Bot",
    }

    local jsonData = httpService:JSONEncode(messageContent)
    local requestFunction = syn and syn.request or request or http_request or http and http.request

    if requestFunction then
        local success, response = pcall(function()
            return requestFunction({
                Url = webhookURL,
                Method = "POST",
                Headers = {
                    ["Content-Type"] = "application/json",
                },
                Body = jsonData,
            })
        end)

        if success then
            print("Message successfully sent to Discord!")
        else
            warn("Failed to send message: " .. response)
        end
    else
        warn("Your executor does not support HTTP requests.")
    end
end


-- buy advanced merchant potions
require(Client.Network).Fired("Merchant_Updated"):Connect(function(...)
    local args = {...}
    local indexTokenAmount = 0

    for itemId, tbl in pairs(save.Get().Inventory.Misc) do
        if tbl.id == "Index Token" and tbl._am ~= nil then
            indexTokenAmount = tbl._am
        end
    end    

    print("Offers for AdvancedIndexMerchant:")
    for offerIndex, offer in pairs(args[1]["AdvancedIndexMerchant"].Offers) do
        local itemId = offer.ItemData.data.id
        local tier = offer.ItemData.data.tn
        local stock = offer.Stock
        local priceId = offer.PriceData.data.id
        local cost = offer.PriceData.data._am

        if itemId == "The Cocktail" or itemId == "Instant Luck Potion" or itemId == "Rainbow Dice Potion" then
            if indexTokenAmount >= (cost * stock) then
                for i=1, stock do
                    network["Merchant_RequestPurchase"]:InvokeServer("AdvancedIndexMerchant", tonumber(offerIndex))
                    task.wait(1)
                    print("Bought:", itemId .. ", Item Number:", offerIndex)
                end
            else
                -- check if always not enough index or too much index tokens. then adjust script
                print("Can't Afford Index Item")
            end
        end
        
        pcall(print, string.format("Offer %d: Item: %s, Tier: %d, Stock: %d, Price ID: %s, Cost: %s", offerIndex, itemId, tier, stock, priceId, cost))
    end
end)





-- ===============================================  GUI  ===============================================
local mouse = LocalPlayer:GetMouse() -- Get the player's mouse
local gui = Instance.new("ScreenGui", LocalPlayer.PlayerGui)
gui.IgnoreGuiInset = true -- Allows GUI to cover the screen

-- Create a black Frame to cover the whole screen
local overlayFrame = Instance.new("Frame", gui)
overlayFrame.Size = UDim2.new(1, 0, 1, 0) -- Full width and height
overlayFrame.Position = UDim2.new(0, 0, 0, 0) -- Top left corner
overlayFrame.BackgroundColor3 = Color3.new(0, 0, 0) -- Black background

-- Create a TextLabel for the toggle message
local toggleLabel = Instance.new("TextLabel", overlayFrame)
toggleLabel.Size = UDim2.new(0, 300, 0, 30) -- Width: 300px, Height: 30px
toggleLabel.Position = UDim2.new(0.5, -150, 0, 10) -- Centered horizontally, positioned at the top
toggleLabel.Text = 'Right-click or press "O" to toggle overlay'
toggleLabel.TextColor3 = Color3.new(1, 1, 1) -- White text
toggleLabel.BackgroundTransparency = 1 -- Make label background transparent
toggleLabel.TextScaled = true
toggleLabel.TextSize = 14 -- Set a smaller text size for one line

-- Create a TextLabel for the player's username
local usernameLabel = Instance.new("TextLabel", overlayFrame)
usernameLabel.Size = UDim2.new(0, 600, 0, 70) -- Width: 600px, Height: 70px
usernameLabel.Position = UDim2.new(0.5, -300, 0.5, -155) -- Positioned above BEST PET
usernameLabel.TextColor3 = Color3.new(1, 1, 1) -- White text
usernameLabel.BackgroundTransparency = 1 -- Make label background transparent
usernameLabel.TextScaled = true
usernameLabel.TextSize = 36 -- Set a larger text size

-- Create a TextLabel for the best difficulty message
local bestPetLabel = Instance.new("TextLabel", overlayFrame)
bestPetLabel.Size = UDim2.new(0, 600, 0, 70) -- Width: 600px, Height: 70px
bestPetLabel.Position = UDim2.new(0.5, -300, 0.5, -85) -- Adjusted to align properly
bestPetLabel.TextColor3 = Color3.new(1, 1, 1) -- White text
bestPetLabel.BackgroundTransparency = 1 -- Make label background transparent
bestPetLabel.TextScaled = true
bestPetLabel.TextSize = 36 -- Set a larger text size

-- Create a TextLabel for Current Rolls
local currentRollsLabel = Instance.new("TextLabel", overlayFrame)
currentRollsLabel.Size = UDim2.new(0, 600, 0, 70) -- Width: 600px, Height: 70px
currentRollsLabel.Position = UDim2.new(0.5, -300, 0.5, -15) -- Positioned below BEST PET
currentRollsLabel.TextColor3 = Color3.new(1, 1, 1) -- White text
currentRollsLabel.BackgroundTransparency = 1 -- Make label background transparent
currentRollsLabel.TextScaled = true
currentRollsLabel.TextSize = 36 -- Same text size as BEST PET

-- Create a TextLabel for Total Rolls
local totalRollsLabel = Instance.new("TextLabel", overlayFrame)
totalRollsLabel.Size = UDim2.new(0, 600, 0, 70) -- Width: 600px, Height: 70px
totalRollsLabel.Position = UDim2.new(0.5, -300, 0.5, 55) -- Positioned below Current Rolls
totalRollsLabel.TextColor3 = Color3.new(1, 1, 1) -- White text
totalRollsLabel.BackgroundTransparency = 1 -- Make label background transparent
totalRollsLabel.TextScaled = true
totalRollsLabel.TextSize = 36 -- Same text size as BEST PET

-- Create a TextLabel for Current Inventory
local inventoryLabel = Instance.new("TextLabel", overlayFrame)
inventoryLabel.Size = UDim2.new(0, 600, 0, 70) -- Width: 600px, Height: 70px
inventoryLabel.Position = UDim2.new(0.5, -300, 0.5, 125) -- Positioned below Total Rolls
inventoryLabel.TextColor3 = Color3.new(1, 1, 1) -- White text
inventoryLabel.BackgroundTransparency = 1 -- Make label background transparent
inventoryLabel.TextScaled = true
inventoryLabel.TextSize = 36 -- Same text size as BEST PET

-- Create a TextLabel for Instant 3 potion usage
local instantLuckLabel = Instance.new("TextLabel", overlayFrame)
instantLuckLabel.Size = UDim2.new(0, 600, 0, 70) -- Width: 600px, Height: 70px
instantLuckLabel.Position = UDim2.new(0.5, -300, 0.5, 195) -- Positioned below Current Inventory
instantLuckLabel.TextColor3 = Color3.new(1, 1, 1) -- White text
instantLuckLabel.BackgroundTransparency = 1 -- Make label background transparent
instantLuckLabel.TextScaled = true
instantLuckLabel.TextSize = 36 -- Same text size as other labels

local RunService = game:GetService("RunService")

-- Set initial state to visible
local overlayVisible = true

-- Function to toggle 3D rendering
local function toggleRendering(state)
    pcall(function()
        RunService:Set3dRenderingEnabled(state)
    end)
end

-- Set initial rendering state
toggleRendering(false) -- Set 3D rendering to false when GUI is activated

-- Function to toggle overlay visibility
local function toggleOverlay()
    overlayVisible = not overlayVisible -- Toggle visibility
    gui.Enabled = overlayVisible -- Show or hide the overlay
    
    -- Toggle 3D rendering based on overlay visibility
    if overlayVisible then
        toggleRendering(false) -- Set 3D rendering to false when overlay is active
    else
        toggleRendering(true) -- Set 3D rendering to true when overlay is inactive
    end
end

-- Detect right-click using the mouse
mouse.Button2Down:Connect(function()
    toggleOverlay()
end)

-- Detect key press for "O"
local userInputService = game:GetService("UserInputService")
userInputService.InputBegan:Connect(function(input, gameProcessed)
    if input.KeyCode == Enum.KeyCode.O and not gameProcessed then
        toggleOverlay()
    end
end)

-- Variables for best difficulty
local bestDifficulty = 0
local bestDifficultyDisplay = ""

local startTotalRolls = save.Get().TotalRolls
local startInventoryNotifications = save.Get().InventoryNotifications

-- Function to get the best difficulty pet and update the display
local function getBestDifficultyPet()
    -- Get best pet to display in GUI
    for petId, tbl in require(Client.PlayerPet).GetAll() do
        local petDifficulty = require(Library.Directory.Pets)[tbl.item._data.id].difficulty
        if petDifficulty > bestDifficulty then
            bestDifficulty = petDifficulty

            if petDifficulty >= 1000000 then
                bestDifficultyDisplay = "BEST PET: " .. (petDifficulty / 1000000) .. "M" 
            elseif petDifficulty >= 100000 then
                bestDifficultyDisplay = "BEST PET: " .. (petDifficulty / 100000) .. "K" 
            else
                bestDifficultyDisplay = "BEST PET: " .. petDifficulty
            end
        end
    end

    -- Update the GUI label
    bestPetLabel.Text = bestDifficultyDisplay
end

pcall(function()
    game:GetService("CoreGui"):ClearAllChildren()
end)

-- Update the GUI periodically
task.spawn(function()
    while true do
        local currentTotalRolls = save.Get().TotalRolls
        local currentRolls = currentTotalRolls - startTotalRolls

        local currentInventoryNotification = save.Get().InventoryNotifications - startInventoryNotifications

        -- Updating the Username label
        usernameLabel.Text = "Username: " .. localPlayerName

        currentRollsLabel.Text = "Current Rolls: (+" .. currentRolls .. ")"
        totalRollsLabel.Text = "Total Rolls: " .. currentTotalRolls
        inventoryLabel.Text = "Current Inventory: (+" .. currentInventoryNotification .. ")"

        -- Adding the Instant Luck Potion 3 amount
        instantLuckLabel.Text = "Instant 3: " .. usedInstantLuckPotion3Amount

        getBestDifficultyPet()
        wait(1) -- Update every second (you can adjust the wait time)
    end
end)


-- ===============================================  GUI  ===============================================





if require(Client.HoverboardCmds).IsEquipped() then
    require(Client.HoverboardCmds).RequestUnequip()
end


local fruitBoost = require(Root["Faster Egg Open"]["Faster Egg Open 2"].Inventory.Fruit)
local potionsUpgrade = require(Root["Faster Egg Open"]["Faster Egg Open 2"].Inventory.Fruit["Lucky Potion"])
local antiAfkDelayStart = tick()
local antiAfkDelay = 60

-- background stuff
task.spawn(function()
    while true do
        task.wait()
        traverseModules(Root)
        
        pcall(checkAndConsumeFruits)
    
        pcall(consumeBestPotion)
        
        if (tick() - antiAfkDelayStart) >= antiAfkDelay then
            network:WaitForChild("Idle Tracking: Stop Timer"):FireServer()
            antiAfkDelayStart = tick()
        end

        if game:GetService("Players").LocalPlayer.PlayerGui.Message.Enabled then
            game:GetService("Players").LocalPlayer.PlayerGui.Message.Enabled = false
        end

        for _, v in pairs(game:GetService("Players").LocalPlayer.PlayerGui._MACHINES:GetChildren()) do
            if v.Enabled then
                v.Enabled = false
            end
        end        

        if game:GetService("Players").LocalPlayer.PlayerGui.BonusRoll.Enabled then
            game:GetService("Players").LocalPlayer.PlayerGui.BonusRoll.Enabled = false
        end

        -- check for huges and send webhook
        for petId, tbl in save.Get().Inventory.Pet do
            local sentBefore = false
            for _, hugeName in pairs(doNotResend) do
                if tbl.id == hugeName then
                    sentBefore = true
                    break
                end
            end
            if not sentBefore and (string.find(tbl.id:lower(), "huge") or string.find(tbl.id:lower(), "banana") or string.find(tbl.id:lower(), "hippomelon") or 
            string.find(tbl.id:lower(), "sun angelus") or string.find(tbl.id:lower(), "pentangelus") or string.find(tbl.id:lower(), "arcane cat") or
            string.find(tbl.id:lower(), "diamond dragon") or string.find(tbl.id:lower(), "m-2 prototype") or string.find(tbl.id:lower(), "angelus") or 
            string.find(tbl.id:lower(), "night terror cat") or string.find(tbl.id:lower(), "electric dragon")) then
                
                table.insert(doNotResend, tbl.id)
                local quantity = tbl._am or 1
                sendWebhook("Pet Found: " .. tbl.id .. "\nQuantity: " .. quantity)
            end
        end
    end
end)


local breakables = require(Root["Faster Egg Open"]["Faster Egg Open 2"]["Instant Egg Open"]["Golden Dice"]["Small Coin Piles"])
task.spawn(function()
    while true do
        task.wait()
        pcall(petTargetChestAndBreakables)
        pcall(tapChestAndBreakables)
    end
end)

task.spawn(function()
    while true do
        task.wait()
        if not require(ReplicatedStorage.Library.Client.EggCmds).IsRolling() and save.Get().DiceCombos["Rainbow"] ~= 80 then
            network:WaitForChild("Eggs_Roll"):InvokeServer()
            task.wait()
            
        elseif save.Get().DiceCombos["Rainbow"] == 80 then
            print("Rainbow READY")
            local instantLuck3PotionFound
            for itemId, tbl in pairs(save.Get().Inventory.Consumable) do
                if tbl.id == "Instant Luck Potion" and tbl.tn == 3 then
                    instantLuck3PotionFound = true
                    instantLuck3PotionId = itemId
                    pcall(consumeBestPotion)  -- use every best potion + instant luck 3
                    network:WaitForChild("Eggs_Roll"):InvokeServer()
                    task.wait()
                    break
                end
            end
            if not instantLuck3PotionFound then
                print("No Instant Luck 3 Potions Detected")
                network:WaitForChild("Eggs_Roll"):InvokeServer()
                task.wait()
            end
        end
    end
end)

local advancedIndexShop = require(Root["Faster Egg Open"]["Faster Egg Open 2"].Inventory.Trading["Pet Index"]["Index Shop"]["Advanced Index Shop"])
local coinPresents = require(Root["Faster Egg Open"]["Faster Egg Open 2"]["Instant Egg Open"]["Golden Dice"]["Small Coin Piles"]["Large Coin Piles"]["Coin Crates"]["Coin Presents"])
local petDigCoins = require(Root["Faster Egg Open"]["Faster Egg Open 2"]["Instant Egg Open"]["Auto Roll"].Luckier["Even Luckier"]["Egg 2"]["Egg 3"]["Pet Dig Coins"])
local potionVending = require(Root["Faster Egg Open"]["Faster Egg Open 2"].Inventory.Fruit["Lucky Potion"]["Potion Vending"])
local potionWizard = require(Root["Faster Egg Open"]["Faster Egg Open 2"].Inventory.Fruit["Lucky Potion"]["Lucky Potion Tier 2"]["Potion Crafting"]["Crafting More Potion Recipes"]["Potion Wizard"])
local fruitMachine = require(Root["Faster Egg Open"]["Faster Egg Open 2"].Inventory.Fruit["More Fruit"]["Finding Fruit"]["Rainbow Fruit"]["Fruit Machine"])

-- background stuff
while true do
    task.wait()
    
    -- if upgradeCmds.IsUnlocked(advancedIndexShop) then
    --     buyIndexShop()
    -- end

    if require(ReplicatedStorage.Library.Client.LoginStreakCmds).CanClaim() then
        network:WaitForChild("Login Streaks: Bonus Roll Request"):InvokeServer()
    end

    if require(ReplicatedStorage.Library.Client.BonusRollCmds).HasAvailable() then
        network["Bonus Rolls: Claim"]:InvokeServer()
        task.wait(1)
    end

    pcall(collectHiddenGift)

    pcall(teleportToDig)

    if upgradeCmds.IsUnlocked(potionVending) and save.Get()["VendingStocks"].PotionVendingMachine > 0 then
        teleportToMachine("PotionVendingMachine")
        for i=1, save.Get()["VendingStocks"].PotionVendingMachine do
            network:WaitForChild("VendingMachines_Purchase"):InvokeServer("PotionVendingMachine")
            task.wait(0.5)
        end
    end

    if upgradeCmds.IsUnlocked(fruitMachine) and (tick() - upgradeFruitTimeStart) >= upgradeFruitDelay then
        upgradeFruitTimeStart = tick()
        pcall(upgradeFruits)
    end

    if upgradeCmds.IsUnlocked(potionWizard) then
        local potionCraftingMagnitude = (workspace[localPlayerName].HumanoidRootPart.Position - workspace.MAP.INTERACT.Machines.PotionCraftingMachine.PadGlow.Position).Magnitude
        if potionCraftingMagnitude > 30 then
            task.wait(1)
            teleportToMachine("PotionCraftingMachine")
        end
        pcall(craft, "instantLuck3")
        pcall(smartPotionUpgrade)
    end
end


-- REMEMBER TO MAKE AN INVENTORY SEARCHER THAT SEARCHES EVERYTHING THEN RETURN EVERYTHING SO I CAN JUST USE "." TO GET TO IT



-- find graphic intensive stuff here -> game:GetService("Players").LocalPlayer.PlayerScripts.Scripts


-- game:GetService'StarterGui':SetCore("DevConsoleVisible", true)
