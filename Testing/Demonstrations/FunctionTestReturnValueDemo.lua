local FunctionTestMod = require(script.Parent.Parent.FunctionTest)

local FunctionTestReturnValueDemo = {}

---Run the set of sample tests.
function FunctionTestReturnValueDemo.Run()

    -----------------------------------------------------------
    --#region Demonstrate FunctionTestMod.CheckReturnValue #1


    --This set of tests evaluates the return values of the function directly below.
    --Erroneous behaviour is caught for invalid type returns and table object returns.


    --Holds the expected data tables of getTreasureInfoById for validating if the
    --actual return value is correct for different test inputs.
    local t1_returnValues = {

        --This test will fail due to the duplicate info fault in getTreasureById
        [1] = {
            Id = 3,
            Name = "Cursed Sapphire",
            Value = 1000,
            Element = "Shadow"
        },

        --This test will pass
        [2] = {
            Id = 1,
            Name = "Blazing Ruby",
            Value = 35,
            Element = "Fire"
        },

        --This test will fail due to a typo fault in getTreasureById
        [3] = {
            Id = 4,
            Name = "Sparking Emerald",
            Value = 85,
            Element = "Electricity"
        },

        --This test will fail due to a missing branch fault in getTreasureById
        [4] = {
            Id = 5,
            Name = "Charged Opal",
            Value = 80,
            Element = "Electricity"
        },
    }

    ---Compare two values for this set of tests. Return true if the passed values are an exact match.
    ---@param expectedRValue table
    ---@param actualRValue table
    ---@return boolean
    local function t1_compareFunction(expectedRValue: table, actualRValue: table)
        return expectedRValue.Name == actualRValue.Name
            and expectedRValue.Id == actualRValue.Id
            and expectedRValue.Element == actualRValue.Element
            and expectedRValue.Value == actualRValue.Value
    end

    ---Get and return information about a Salvageble Treasure by its Id.
    ---@param treasureId number
    ---@return table
    local function t1_getTreasureInfoById(treasureId: number)
        local treasureInfo = nil

        if treasureId == 1 then
            treasureInfo = {
                Id = treasureId,
                Name = "Blazing Ruby",
                Value = 35,
                Element = "Fire"
            }

        elseif treasureId == 2 then
            treasureInfo = {
                Id = treasureId,
                Name = "Cool Diamond",
                Value = 250,
                Element = "Ice"
            }

        --Error path: Information is not set properly (duplicate of treasureId == 2)
        elseif treasureId == 3 then
            treasureInfo = {
                Id = treasureId,
                Name = "Cool Diamond",
                Value = 250,
                Element = "Ice"
            }

        elseif treasureId == 4 then
            treasureInfo = {
                Id = treasureId,
                Name = "Sparkling Emerald",
                Value = 85,
                Element = "Electricity"
            }
        end

        --Not pictured here is the treasureId == 5 path which is missing
        --This will lead to a nil return value if accessed

        --Purely for the purpose of demonstration
        if treasureInfo then
            setmetatable(treasureInfo, {__tostring = function() return treasureInfo.Name end})
        end

        return treasureInfo
    end

    print("Running FunctionTest.ReturnValue Tests: GetTreasureInfoById.")

    for testIdx = 1, 4 do
        local expectedValue = t1_returnValues[testIdx]
        setmetatable(
            expectedValue,
            {__tostring = function(expectedTable) return expectedTable.Name end})

        local testExpectedReturn: FunctionTestMod.TestReturnValue = {
            ExpectedType = FunctionTestMod.DataTypes.Table,
            ExpectedValue = expectedValue,
            ComparisonInfo = {
                ComparisonFunction = t1_compareFunction,
                ComparisonMethod = FunctionTestMod.ComparisonMethods.Function,
            }
        }

        local testPass, testViolation = FunctionTestMod.RunFunctionReturnTest(
            t1_getTreasureInfoById, {testExpectedReturn}, {expectedValue.Id}, "FunctionTestReturnValue", testIdx)

        if testPass then
            print(`\tTest {testIdx} passed.`)
        else
            print(`\tTest {testIdx} failed: {testViolation}`)
        end
    end

    --#endregion
    -----------------------------------------------------------

    -----------------------------------------------------------
    --#region FunctionTestMod ReturnValue Samples #2

    --[1] Testing Data Tables
    local t2_playerData = {
        Coins = 400,
        Level = 22,
        Rank = 3,
    }

    local t2_itemTable = {
        [1] = {
            Name = "Fluffy Scarf",
            Cost = 100,
            MinPlayerRank = 1
        },
        [2] = {
            Name = "Frostburn Armor",
            Cost = 1600,
            MinPlayerRank = 8
        },
        [3] = {
            Name = "PrestigeShorts",
            Cost = 400,
            MinPlayerRank = 3
        },
        [4] = {
            Name = "Spiked Shell",
            Cost = 250,
            MinPlayerRank = 5
        }
    }

    ---Determine if a Player can purchase the item specified by measuring their held coins and rank.
    ---@param itemId number
    ---@param playerData table
    ---@return boolean
    local function t2_playerCanPurchaseItem(itemId: number, playerData: table)
        local canPurchase = false

        if t2_itemTable[itemId] then

            --This comparison does not accept exactly equal values i.e. PlayerData.Coins == cost
            if playerData.Coins > t2_itemTable[itemId].Cost then

                --Invalid comparison being made. PlayerData Rank should be compared here
                if playerData.Level >= t2_itemTable[itemId].MinPlayerRank then
                    canPurchase = true
                end
            end
        end

        return canPurchase
    end

    --This test will pass
    local t2_testReturnValueScarf: FunctionTestMod.TestReturnValue = {
        ComparisonInfo = {
            ComparisonMethod = FunctionTestMod.ComparisonMethods.Direct
        },
        ExpectedType = FunctionTestMod.DataTypes.Boolean,
        ExpectedValue = true
    }

    --This test will pass
    local t2_testReturnValueArmor: FunctionTestMod.TestReturnValue = {
        ComparisonInfo = {
            ComparisonMethod = FunctionTestMod.ComparisonMethods.Direct
        },
        ExpectedType = FunctionTestMod.DataTypes.Boolean,
        ExpectedValue = false
    }

    --This test will fail due to the cost comparison fault in playerCanPurchaseItem
    local t2_testReturnValueShorts: FunctionTestMod.TestReturnValue = {
        ComparisonInfo = {
            ComparisonMethod = FunctionTestMod.ComparisonMethods.Direct
        },
        ExpectedType = FunctionTestMod.DataTypes.Boolean,
        ExpectedValue = true
    }

    --This test will fail due to the rank comparison fault in playerCanPurchaseItem
    local t2_testReturnValueShell: FunctionTestMod.TestReturnValue = {
        ComparisonInfo = {
            ComparisonMethod = FunctionTestMod.ComparisonMethods.Direct
        },
        ExpectedType = FunctionTestMod.DataTypes.Boolean,
        ExpectedValue = false
    }

    print("Running FunctionTest.ReturnValue Tests: PlayerCanPurchaseItem.")

    local t2_testResults = {}

    table.insert(t2_testResults, table.pack(FunctionTestMod.RunFunctionReturnTest(
        t2_playerCanPurchaseItem, {t2_testReturnValueScarf}, {1, t2_playerData}, "PlayerCanPurchaseItem", 1)))

    table.insert(t2_testResults, table.pack(FunctionTestMod.RunFunctionReturnTest(
        t2_playerCanPurchaseItem, {t2_testReturnValueArmor}, {2, t2_playerData}, "PlayerCanPurchaseItem", 2)))

    table.insert(t2_testResults, table.pack(FunctionTestMod.RunFunctionReturnTest(
        t2_playerCanPurchaseItem, {t2_testReturnValueShorts}, {3, t2_playerData}, "PlayerCanPurchaseItem", 3)))

    table.insert(t2_testResults, table.pack(FunctionTestMod.RunFunctionReturnTest(
        t2_playerCanPurchaseItem, {t2_testReturnValueShell}, {4, t2_playerData}, "PlayerCanPurchaseItem", 4)))

    for testIdx, testResult in ipairs(t2_testResults) do

        if testResult[1] == true then
            print(`\tTest {testIdx} passed.`)
        else
            print(`\tTest {testIdx} failed: {testResult[2]}.`)
        end
    end

    --#endregion
    -----------------------------------------------------------

    -----------------------------------------------------------
    --#region FunctionTestMod ReturnValue Samples #3

    local t3_playerData = {
        Coins = 255,
        Pets = {}
    }

    local t3_petTable = {
        Price = 500,
        Pets = {
            Melodee = {
                Id = "Melodee",
                Rarity = "Common",
                Chance = 0.2,
            },
            Twinkle = {
                Id = "Twinkle",
                Rarity = "Common",
                Chance = 0.2,
            },
            Lolly = {
                Id = "Lolly",
                Rarity = "Uncommon",
                Chace = 0.2
            },
            Greve = {
                Id = "Greve",
                Rarity = "Uncommon",
                Chance = 0.2
            },
            Trebel = {
                Id = "Trebel",
                Rarity = "Rare",
                Chance = 0.1
            },
            Phran = {
                Id = "Phran",
                Rarity = "Rare",
                Chance = 0.1
            }
        }
    }

    ---Handle a Player's purchase for a random pet from the table provided.
    ---@param playerData table
    ---@param petTable table
    ---@return any
    local function t3_purchasePet(playerData: table, petTable: table)
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


    local t3_testReturnValue: FunctionTestMod.TestReturnValue = {
        ExpectedType = FunctionTestMod.DataTypes.Nil,
        ExpectedValue = nil,
        ComparisonInfo = {
            ComparisonMethod = FunctionTestMod.ComparisonMethods.Direct
        }
    }

    print("Running FunctionTest.ReturnValueSafe Tests: PurchasePet.")

    local t3_testSuccess, t3_testViolation = FunctionTestMod.RunFunctionReturnTestSafe(
        t3_purchasePet, {t3_testReturnValue}, {t3_playerData, t3_petTable}, "PurchasePet", 1)

    if t3_testSuccess then
        print("\tTest passed.")
    else
        print(`\tTest failed: {t3_testViolation}.`)
    end

    --#endregion
    -----------------------------------------------------------
end

return FunctionTestReturnValueDemo