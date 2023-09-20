local RandomValueMod = require(script.Parent.Parent.RandomValue)

local RandomValueDemo = {}

---Run the set of sample tests.
function RandomValueDemo.Run()

    -----------------------------------------------------------
    --#region Uniform Array Index Selection

    print("Testing Uniform Chance Array Index Selection.")

    for iterIdx = 1, 3 do
        local ctA, ctB, ctC, ctD, ctE = 0,0,0,0,0

        for _ = 1, 100 do
            local uniformRand = RandomValueMod.GetArrayValueByIndex({"A","B","C","D","E"})

            if uniformRand == "A" then
                ctA += 1
            elseif uniformRand == "B" then
                ctB += 1
            elseif uniformRand == "C" then
                ctC += 1
            elseif uniformRand == "D" then
                ctD += 1
            elseif uniformRand == "E" then
                ctE += 1
            end
        end

        print(`> Iter {iterIdx}: `, ctA, ctB, ctC, ctD, ctE)
    end

    --#endregion
    -----------------------------------------------------------

    -----------------------------------------------------------
    --#region Weighted Array Index Selection
    local index_wt_table = {0.1,0.05,0.05,0.2,0.6}


    print("Testing Weighted Chance Array Index Selection.")
    print(`Weights used: {index_wt_table[1]} {index_wt_table[2]} {index_wt_table[3]} {index_wt_table[4]} {index_wt_table[5]}`)

    for iterIdx = 1, 3 do
        local wtA, wtB, wtC, wtD, wtE = 0, 0, 0, 0, 0

        for _ = 1, 100 do
            local weightedRand = RandomValueMod.GetWeightedArrayValueByIndex({"A","B","C","D","E"}, index_wt_table)

            if weightedRand == "A" then
                wtA += 1
            elseif weightedRand == "B" then
                wtB += 1
            elseif weightedRand == "C" then
                wtC += 1
            elseif weightedRand == "D" then
                wtD += 1
            elseif weightedRand == "E" then
                wtE += 1
            end
        end

        print(`> Iter {iterIdx}: `, wtA, wtB, wtC, wtD, wtE)
    end

    --#endregion
    -----------------------------------------------------------

    -----------------------------------------------------------
    --#region Weighted Boolean Selection

    local wt_true = 0.9

    print("Testing Weighted Chance Boolean Value Selection.")
    print(`Weight True: {wt_true}.`)

    for iterIdx = 1, 3 do
        local wtTrue, wtFalse = 0,0

        for _ = 1, 50 do
            local weightedRand = RandomValueMod.GetBooleanValue(wt_true)

            if weightedRand == true then
                wtTrue += 1
            else
                wtFalse += 1
            end
        end

        print(`> Iter {iterIdx}: `, wtTrue, wtFalse)
    end

    --#endregion
    -----------------------------------------------------------

    -----------------------------------------------------------
    --#region Uniform Table Key Selection
    local key_table = {
        TShirt = "TShirt",
        Pants = "Pants",
        Shirt = "Shirt",
        Hat = "Hat",
        FaceAccessory = "FaceAccessory"
    }

    print("Testing Uniform Chance Table Key Selection.")

    for iterIdx = 1, 3 do
        local ctTShirt, ctPants, ctShirt, ctHat, ctFaceAccessory = 0,0,0,0,0

        for _ = 1, 100 do
            local uniformRand = RandomValueMod.GetTableValueByKey(key_table)

            if uniformRand == key_table.TShirt then
                ctTShirt += 1
            elseif uniformRand == key_table.Shirt then
                ctShirt += 1
            elseif uniformRand == key_table.Pants then
                ctPants += 1
            elseif uniformRand == key_table.Hat then
                ctHat += 1
            elseif uniformRand == key_table.FaceAccessory then
                ctFaceAccessory += 1
            end
        end

        print(`> Iter {iterIdx}: `, ctTShirt, ctPants, ctShirt, ctHat, ctFaceAccessory)
    end

    --#endregion
    -----------------------------------------------------------

    -----------------------------------------------------------

    --#region Weighted Table Key Selection

    local tkWt1: RandomValueMod.TableKeyWeight = {Key = "TShirt", Weight = 0.05}
    local tkWt2: RandomValueMod.TableKeyWeight = {Key = "Pants", Weight = 0.05}
    local tkWt3: RandomValueMod.TableKeyWeight = {Key = "Shirt", Weight = 0.1}
    local tkWt4: RandomValueMod.TableKeyWeight = {Key = "Hat", Weight = 0.55}
    local tkWt5: RandomValueMod.TableKeyWeight = {Key = "FaceAccessory", Weight = 0.25}

    local key_weight_table = {tkWt1,tkWt2,tkWt3,tkWt4,tkWt5}

    print("Testing Weighted Table Key Selection.")
    print(`Weights used: {tkWt1.Weight} {tkWt2.Weight} {tkWt3.Weight} {tkWt4.Weight} {tkWt5.Weight}`)

    for iterIdx = 1, 5 do
        local ctTShirt, ctPants, ctShirt, ctHat, ctFaceAccessory = 0,0,0,0,0

        for _ = 1, 100 do
            local uniformRand = RandomValueMod.GetWeightedTableValueByKey(key_table, key_weight_table)

            if uniformRand == key_table.TShirt then
                ctTShirt += 1
            elseif uniformRand == key_table.Shirt then
                ctShirt += 1
            elseif uniformRand == key_table.Pants then
                ctPants += 1
            elseif uniformRand == key_table.Hat then
                ctHat += 1
            elseif uniformRand == key_table.FaceAccessory then
                ctFaceAccessory += 1
            end
        end

        print(`> Iter {iterIdx}: `, ctTShirt, ctPants, ctShirt, ctHat, ctFaceAccessory)
    end

    --#endregion
    -----------------------------------------------------------

    -----------------------------------------------------------
    --#region Uniform Integer Broken Range Selection

    print("Testing Getting Integer in Broken Range. Including invalid inputs.")

    print(RandomValueMod.GetIntegerInBrokenRange(1,10,20,30,100,110))
    print(RandomValueMod.GetIntegerInBrokenRange(1))
    print(RandomValueMod.GetIntegerInBrokenRange(1,10,20))

    --#endregion
    -----------------------------------------------------------
end

return RandomValueDemo