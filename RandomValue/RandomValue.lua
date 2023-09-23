--Describes a number range weighted in probability for selection.
export type NumberRangeWeight = {
    MinNum: number,
    MaxNum: number,
    Weight: number
}

--Describes a table keyname weighted in probability for selection.
export type TableKeyWeight = {
    Key: any,
    Weight: number
}

--Describes a table of NumberRangeWeight values.
export type NumberRangeWeightTable = {
    [number]: NumberRangeWeight
}

--Describes a table of TableKeyWeight values.
export type TableKeyWeightTable = {
    [number]: TableKeyWeight
}

--The random number generator to use.
local randGenerator: Random = Random.new(tick())

--A set of options for the amount of detail to display when logging RandomValue usage warnings
local WARNING_LOD_OPTIONS = {
    None = 1,
    MessageOnly = 2,
    FunctionTrace = 3,
    FullTraceback = 4
}

--Data Table for private RandomValue module usage.
local RandomValue = {
    WarningLoD = WARNING_LOD_OPTIONS.FunctionTrace,
    WarningLoDOptions = table.clone(WARNING_LOD_OPTIONS)
}

---Log a warning for misuse of the RandomValue functions.Format set by WarningLoD.
---@param warningMsg string
---@param functionName string
local function logWarning(warningMsg: string, functionName: string, ...)

    if RandomValue.WarningLoD == WARNING_LOD_OPTIONS.MessageOnly then
        warn(warningMsg)

    elseif RandomValue.WarningLoD == WARNING_LOD_OPTIONS.FunctionTrace then
        warn(`{functionName}: {warningMsg}`)

    elseif RandomValue.WarningLoD == WARNING_LOD_OPTIONS.FullTraceback then
        warn(debug.traceback(warningMsg))
    end
end

--Module provides a set of functions for generating random values within user-defined restrictions
--with complete random (uniform) chance of selection or weighted chance of selection.
local RandomValueFuncs = {}

---Get and return a random value selected from the passed array table.
---@param arrayTable table
---@return any
function RandomValueFuncs.GetArrayValueByIndex(arrayTable: {[number]: any})
    return arrayTable[randGenerator:NextInteger(1, #arrayTable)]
end

---Get and return a random boolean value. Probability of a true value is weighted optionally.
---@param weightTrue number The percentage chance [0-1] to generate a true value.
---@return boolean
function RandomValueFuncs.GetBooleanValue(weightTrue: number)
    weightTrue = tonumber(weightTrue) or 0.5
    weightTrue = math.max(0, math.min(weightTrue, 1))

    return randGenerator:NextNumber() < weightTrue
end

---Get and return a random integer of uniform chance distributed within the range specified.
---@param minNum number
---@param maxNum number
---@return number
function RandomValueFuncs.GetIntegerInRange(minNum: number, maxNum: number)
    minNum = tonumber(minNum) or 0
    maxNum = tonumber(maxNum) or 0

    return randGenerator:NextInteger(minNum, maxNum)
end

---Get and return a random integer of uniform chance distributed across one or more number ranges.
---@param minOne number
---@param maxOne number
function RandomValueFuncs.GetIntegerInBrokenRange(minOne, maxOne, ...)
    local rangeParams = {minOne, maxOne, ...}
    local generatedNums = {}

    for paramIdx = 1, #rangeParams, 2 do
        local rangeMin = tonumber(rangeParams[paramIdx])
        local rangeMax = tonumber(rangeParams[paramIdx+1])

        if not rangeMax then

            if rangeMin then
                logWarning(
                    "Integer Range missing Max value to match final Min value.",
                    "GetIntegerInBrokenRange")
            end
            break
        end

        table.insert(generatedNums, randGenerator:NextInteger(rangeMin, rangeMax))
    end

    if #generatedNums == 0 then
        logWarning("No range parameters were provided.", "GetIntegerInBrokenRange")
        return 0
    end

    return generatedNums[randGenerator:NextInteger(1,#generatedNums)]
end

---Get and return a random [0,1] number rounded to numPlaces or 2 decimal places.
---@param numPlaces number
---@return number
function RandomValueFuncs.GetNumber01(numPlaces: number)
    local generatedNum = randGenerator:NextNumber()
    numPlaces = tonumber(numPlaces) or 2
    numPlaces = math.min(math.max(numPlaces, 0), 10)

    return(tonumber(string.format(string.format("%%.%df", numPlaces), generatedNum)))
end

---Get a random value from the passed object table. Uniform selection across the keys is used.
---@param keyValueTable table The key-value table to select from
---@return any
function RandomValueFuncs.GetTableValueByKey(keyValueTable: table)
    local chancePerKey = 1
    local numTableKeys = 0
    local selectedValue = nil
    local totalWeight = 0
    local weightSelectedValue = randGenerator:NextNumber()

    if type(keyValueTable) ~= "table" then
        logWarning("Invalid object passed for random selection.", "GetTableValueByKey")
        return nil
    end

    for _ in keyValueTable do
        numTableKeys += 1
    end

    if numTableKeys == 0 then
        logWarning("Empty key-value table passed for random selection.", "GetTableValueByKey")
        return nil
    end

    chancePerKey = 1 / numTableKeys

    for _, tableValue in keyValueTable do
        totalWeight += chancePerKey

        if weightSelectedValue < totalWeight then
            selectedValue = tableValue
            break
        end
    end

    return selectedValue
end

---Get a random value from the passed array. Weighted selection is used based on probabilities specified.
---@param arrayTable table The array table to select from
---@param indexWeightTable table The weight assigned to each index for selection
---@return any
function RandomValueFuncs.GetWeightedArrayValueByIndex(arrayTable: {[number]: any}, indexWeightTable: table)
    local selectedValue = nil
    local totalWeight = 0
    local weightSelectValue = randGenerator:NextNumber()

    if type(arrayTable) ~= "table" then
        logWarning("Invalid object passed for random selection.", "GetWeightedArrayValueByIndex")
        return nil
    end

    if type(indexWeightTable) ~= "table" then
        logWarning("Invalid object passed for weight table.", "GetWeightedArrayValueByIndex")
        return nil
    end

    for arrayIdx, idxWeight in ipairs(indexWeightTable) do
        totalWeight += tonumber(idxWeight)

        if not selectedValue and weightSelectValue < totalWeight then
            selectedValue = arrayTable[arrayIdx]
        end
    end

    if (totalWeight - 1) > 0.001 then
        logWarning(
            "Weights exceed 1.00. Some values were not considered for selection.",
            "GetWeightedArrayValueByIndex")

    elseif (totalWeight - 1) < -0.001 then
        logWarning(
            "Weights fall short of 1.00. Final value given extra weight.",
            "GetWeightedArrayValueByIndex")
    end

    return selectedValue
end

---Get and return a random integer of weighted chance distributed across one or more number ranges.
---Ranges are expected as being consolidated within the array table passed.
---@param numRanges table The table of NumberRangeWeight objects for consideration.
---@return number
function RandomValueFuncs.GetWeightedIntegerFromRangeTable(numRanges: NumberRangeWeightTable)
    local generatedNum = nil
    local totalRangeWeight = 0

    local weightSelectValue = randGenerator:NextNumber()

    if type(numRanges) ~= "table" then
        logWarning("Invalid object passed for NumberRangeWeightTable.", "_GetWeightedIntegerInBrokenRange")
        return 0
    end

    for _, weightedRange: NumberRangeWeight in ipairs(numRanges) do
        totalRangeWeight += tonumber(weightedRange.Weight) or 0

        if not generatedNum and weightSelectValue < totalRangeWeight then
            generatedNum = RandomValueFuncs.GetIntegerInRange(weightedRange.MinNum, weightedRange.MaxNum)
        end
    end

    if (totalRangeWeight - 1) > 0.001 then
        logWarning(
            "Collective weight for ranges exceed 1.00. Some ranges will not be considered.",
            "GetWeightedIntegerInBrokenRange"
        )

    elseif (totalRangeWeight - 1) < 0.001 then
        logWarning(
            "Collective Range Weight subscedes 1.00. Some ranges have additional weight.",
            "GetWeightedIntegerInBrokenRange"
        )
    end

    return generatedNum
end

---Get and return a random integer of weighted chance distributed across one or more number ranges.
---Reads one or more ranges in 3-tuples of parameters passed as (min, max, weight) pairs.
---@param minOne number
---@param maxOne number
---@param weightOne number
---@return number
function RandomValueFuncs.GetWeightedIntegerFromRanges(
    minOne: number, maxOne: number, weightOne: number, ...)
    local rangeParams = {minOne, maxOne, weightOne, ...}
    local foundNum = false
    local generatedNum = nil
    local totalRangeWeight = 0

    local weightSelectValue = randGenerator:NextNumber()

    for paramIdx = 1, #rangeParams, 3 do
        local rangeMin = tonumber(rangeParams[paramIdx])
        local rangeMax = tonumber(rangeParams[paramIdx+1])
        local rangeWeight = tonumber(rangeParams[paramIdx+2])

        if not rangeWeight then
            logWarning(
                "Integer Range missing weight value to match final range pair.",
                "GetWeightedIntegerInBrokenRange")
            break

        elseif not rangeMax then

            if rangeMin then
                logWarning(
                    "Integer Range missing maximum value in final range pair.",
                    "GetWeightedIntegerInBrokenRange")
            end

            break
        end

        if rangeMax < rangeMin then
            local temp = rangeMin
            rangeMin = rangeMax
            rangeMax = temp
        end

        totalRangeWeight += rangeWeight

        if not generatedNum and weightSelectValue < totalRangeWeight then
            generatedNum = randGenerator:NextInteger(rangeMin, rangeMax)
            foundNum = true
        end
    end

    if (totalRangeWeight - 1) > 0.001 then
        logWarning(
            "Collective Range Weight exceeds 1.00. Some ranges will not be considered.",
            "GetWeightedIntegerInBrokenRange"
        )

    elseif (totalRangeWeight - 1) < 0.001 then
        logWarning(
            "Collective Range Weight fall short of 1.00. Some ranges have additional weight.",
            "GetWeightedIntegerInBrokenRange"
        )
    end

    if not foundNum then
        logWarning(
            "No parameters provided for integer ranges.",
            "GetWeightedIntegerInBrokenRange"
        )

        return generatedNum
    end

    return generatedNum
end

---Get a random value from the passed table. Weighted selection is used based on probabilities specified.
---Table keys not specified in keyWeightTable are not considered for selection.
---@param keyValueTable table The key-value table to select from
---@param keyWeightTable table The weight assigned to each key for selection
---@return any
function RandomValueFuncs.GetWeightedTableValueByKey(keyValueTable: table, keyWeightTable: table)
    local selectedValue = nil
    local weightSelectedValue = randGenerator:NextNumber()

    local totalWeight = 0

    --Maps a loop iteration index value to the associated key in keyValueTable
    local valueIndexToKeyNameMap = {}

    --The weight thresholds applied to each key-value pair in keyValueTable for selection
    local valueWeightTable = {}

    if type(keyValueTable) ~= "table" then
        logWarning("Invalid object passed for random selection.", "GetWeightedTableValueByKey")
        return nil
    end

    if type(keyWeightTable) ~= "table" then
        logWarning("Invalid object passed for weight table.", "GetWeightedTableValueByKey")
        return nil
    end

    --Iterate through the key-weight pairs dictated in keyWeightTable
    --Assign each key with a total weight as a cutoff to compare with weightSelectedValue
    --Number indices are used for valueWeightTable to preserve iteration order
    for weightInfoIdx, weightInfo: TableKeyWeight in keyWeightTable do
        totalWeight += weightInfo.Weight

        valueWeightTable[weightInfoIdx] = totalWeight
        valueIndexToKeyNameMap[weightInfoIdx] = weightInfo.Key
    end

    if (totalWeight - 1) > 0.001 then
        logWarning(
            "Weights exceed 1.00. Some values were not considered for selection.",
            "GetWeightedTableValueByKey")

    elseif (totalWeight - 1) < -0.001 then
        logWarning(
            "Weights fall short of 1.00. Some values were given extra weight in selection.",
            "GetWeightedTableValueByKey")
    end

    --Select the value to be returned
    --Iterate in-order from the smallest key-weight pair threshold to the largest
    --The first threshold larger than the selected random value will be the key-value pair to select
    for keyWeightIndex, keyWeightStep in ipairs(valueWeightTable) do

        if selectedValue and weightSelectedValue < keyWeightStep then
            selectedValue = valueIndexToKeyNameMap[keyWeightIndex]
        end
    end

    return selectedValue
end

---Set the Module's random number generator to use the seed passed.
---@param seed number
function RandomValueFuncs.SetRandomSeed(seed: number)
    randGenerator = Random.new(tonumber(seed) or 0)
end

---Generate a new random seed for the Module's random number generator.
function RandomValueFuncs.SetNewRandomSeed()
    randGenerator = Random.new(tick())
end

---Set the level of detail to use when displaying Module function misuse warnings.
---@param warnLevel number
function RandomValueFuncs.SetWarningLevelOfDetail(warnLevel: number)
    RandomValue.WarningLoD = WARNING_LOD_OPTIONS[warnLevel] or WARNING_LOD_OPTIONS.None
end

return RandomValueFuncs
