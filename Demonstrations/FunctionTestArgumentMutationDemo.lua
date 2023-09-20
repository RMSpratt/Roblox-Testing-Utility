local FunctionTestMod = require(script.Parent.Parent.FunctionTest)

local FunctionTestArgumentMutationDemo = {}

function FunctionTestArgumentMutationDemo.Run()

    -----------------------------------------------------------
    --#region FunctionTestMod ArgumentMutation Samples #1

    local t1_playerData = {
        Agility = 25,
        Defense = 33,
        JumpHeight = 10,
        MaxHealth = 100,
        MaxStamina = 50,
        Strength = 18,
    }

    local t1_potionTable = {
        [1] = {
            Name = "Quickstep Solution",
            Buffs = {
                Agility = 12,
                MaxStamina = 10
            }
        },
        [2] = {
            Name = "Ironskin Potion",
            Buffs = {
                Strength = 8
            }
        },
        [3] = {
            Name = "BunnyHop Elixir",
            Buffs = {
                JumpHeight = 10,
                MaxStamina = 5
            }
        }
    }

    ---Apply the effects of a potion to the Player's stats.
    ---@param potionId number
    ---@param playerStatData table
    ---@return boolean
    local function t1_drinkPotion(potionId: number, playerStatData: table)

        if t1_potionTable[potionId] then

            --Fault found here. Player stats should be augmented according to a potion's buffs
            --This will effectively double all of the player's stats instead
            for statName, statValue in playerStatData do
                playerStatData[statName] += statValue
            end
        end
    end

    local t1_expectedPlayerStats = {
        Agility = 25,
        Defense = 41,
        JumpHeight = 10,
        MaxHealth = 100,
        MaxStamina = 50,
        Strength = 26,
    }

    local expectedPotionMutation: FunctionTestMod.TestArgumentMutation = {
        ArgumentIdx = 2,
        ExpectedValue = t1_expectedPlayerStats,
        ComparisonInfo = {
            ComparisonMethod = FunctionTestMod.ComparisonMethods.KeyTable,
        }
    }

    print("Running FunctionTest.ArgumentMutation Tests: PlayerCanPurchaseItem.")

    local testSuccess, testViolation = FunctionTestMod.RunFunctionMutationTest(
        t1_drinkPotion, {expectedPotionMutation}, {3, t1_playerData}, "DrinkPotion", 1)

    if testSuccess then
        print("\tTest passed.")
    else
        print(`\tTest failed: {testViolation}.`)
    end

    --#endregion
    -----------------------------------------------------------

    -----------------------------------------------------------
    --#region FunctionTestMod ArgumentMutation Samples #2

    local t2_playerData = {
        Coins = 255,
        Pets = {}
    }

    local t2_petTable = {
        Cost = 200,
        Pets = {
            Jingo = {
                Id = "Jingo",
                Rarity = "Common",
            },
            Booky = {
                Id = "Booky",
                Rarity = "Common",
            },
            Mezzo = {
                Id = "Mezzo",
                Rarity = "Common",
            },
            Bluee = {
                Id = "Bluee",
                Rarity = "Uncommon",
            },
            Swiley = {
                Id = "Swiley",
                Rarity = "Uncommon",
            },
            Pete = {
                Id = "Pete",
                Rarity = "Rare",
            }
        }
    }

    --The expected changes to t2_playerData after t2_purchasePet is run
    local t2_expectedPlayerData = {
        Coins = 55,
    }


    ---Handle a Player's purchase for a random pet from the table provided.
    ---@param playerData table
    ---@param petTable table
    ---@return any
    local function t2_purchasePet(playerData: table, petTable: table)
        local purchasedPet = nil

        --This errors out with petTable1 as it is missing the Cost key
        if playerData.Coins > petTable.Cost then
            local generatedValue = Random.new(tick()):NextNumber()
            local totalWeight = 0

            for petName in petTable do

                --This errors out with petTable 2 as its entries are missing the Chance key
                totalWeight += petTable[petName].Chance

                if generatedValue < totalWeight then
                    purchasedPet = petTable[petName]
                    playerData.Coins -= petTable.Cost
                    break
                end
            end
        end

        return purchasedPet
    end

    local t2_testArgumentMutation: FunctionTestMod.TestArgumentMutation = {
        ArgumentIdx = 1,
        ExpectedValue = t2_expectedPlayerData,
        ComparisonInfo = {
            ComparisonMethod = FunctionTestMod.ComparisonMethods.KeyTable,
        }
    }

    print("Running FunctionTest.ArgumentMutation Tests: PetPurchase.")

    local t2_testSuccess, t2_testViolation = FunctionTestMod.RunFunctionMutationTestSafe(
        t2_purchasePet, {t2_testArgumentMutation}, {t2_playerData, t2_petTable}, "PurchasePet", 1)

    if t2_testSuccess then
        print("\tTest passed.")
    else
        print(`\tTest failed: {t2_testViolation}.`)
    end

    --#endregion
    -----------------------------------------------------------
end

return FunctionTestArgumentMutationDemo