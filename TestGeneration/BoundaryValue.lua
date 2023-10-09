--Type definition for variables to be used for BVA input pair generation
export type VariableBoundDefinition = {
    MinValue: number,
    MaxValue: number,
    NominalValue: number,
    OffsetIncrement: number,
}

--A set of functions for generating test cases according to Boundary Value Analysis methods.
local BoundaryValueTestFuncs = {}

---Create a set of value pairs according to Normal BVA test generation for the passed variables.
function BoundaryValueTestFuncs.CreateNormalBVAInputs(...)
    local variableBoundDefinitions: {[number]: VariableBoundDefinition} = table.pack(...)
    local testInputPairs = {}
    local nominalPair = {}

    for i = 1, #variableBoundDefinitions, 1 do
        local offset = variableBoundDefinitions[i].OffsetIncrement or 1

        --#region Testing
        if not variableBoundDefinitions[i].MinValue then
            error(debug.info(2,"ln") .. ` Argument {i} missing MinValue param.`)
        end

        if not variableBoundDefinitions[i].MaxValue then
            error(debug.info(2,"ln") .. ` Argument {i} missing MaxValue param.`)
        end

        if type(variableBoundDefinitions[i].MinValue) ~= "number" then
            error(debug.info(2,"ln") .. ` Unexpected type for Argument {i} MinValue param.`)
        end

        if type(variableBoundDefinitions[i].MaxValue) ~= "number" then
            error(debug.info(2,"ln") .. ` Unexpected type for Argument {i} MaxValue param.`)
        end

        if not variableBoundDefinitions[i].NominalValue then
            variableBoundDefinitions[i].NominalValue =
                (variableBoundDefinitions[i].MinValue + variableBoundDefinitions[i].MaxValue) / 2
        end
        --#endregion

        table.insert(testInputPairs, {variableBoundDefinitions[i].MinValue})
        table.insert(testInputPairs, {variableBoundDefinitions[i].MinValue+offset})
        table.insert(testInputPairs, {variableBoundDefinitions[i].MaxValue-offset})
        table.insert(testInputPairs, {variableBoundDefinitions[i].MaxValue})

        local oldVarIdx = i

        --Iterate over the preceding set of test input pairs and add the new variable to them.
        for j = (i-1)*4, 1, -1 do
            table.insert(testInputPairs[j], variableBoundDefinitions[i].NominalValue)

            if j % 4 == 0 then
                oldVarIdx -= 1
            end

            --Add the older variable's Nominal value to the current variable's new set of pairings.
            table.insert(testInputPairs[(i*4)-(j%4)], variableBoundDefinitions[oldVarIdx].NominalValue)
        end

        table.insert(nominalPair, variableBoundDefinitions[i].NominalValue)
    end

    table.insert(testInputPairs, nominalPair)

    return testInputPairs
end

---Create a set of value pairs according to Robust BVA test generation for the passed variables.
function BoundaryValueTestFuncs.CreateRobustBVAInputs(...)
    local variableBoundDefinitions: {[number]: VariableBoundDefinition} = table.pack(...)
    local testInputPairs = {}
    local nominalPair = {}

    for i = 1, #variableBoundDefinitions, 1 do
        local offset = variableBoundDefinitions[i].OffsetIncrement or 1

        --#region Testing
        if not variableBoundDefinitions[i].MinValue then
            error(debug.info(2,"ln") .. ` Argument {i} missing MinValue param.`)
        end

        if not variableBoundDefinitions[i].MaxValue then
            error(debug.info(2,"ln") .. ` Argument {i} missing MaxValue param.`)
        end

        if type(variableBoundDefinitions[i].MinValue) ~= "number" then
            error(debug.info(2,"ln") .. ` Unexpected type for Argument {i} MinValue param.`)
        end

        if type(variableBoundDefinitions[i].MaxValue) ~= "number" then
            error(debug.info(2,"ln") .. ` Unexpected type for Argument {i} MaxValue param.`)
        end

        if not variableBoundDefinitions[i].NominalValue then
            variableBoundDefinitions[i].NominalValue =
                variableBoundDefinitions[i].MinValue + variableBoundDefinitions[i].MaxValue / 2
        end
        --#endregion

        table.insert(testInputPairs, {variableBoundDefinitions[i].MinValue-offset})
        table.insert(testInputPairs, {variableBoundDefinitions[i].MinValue})
        table.insert(testInputPairs, {variableBoundDefinitions[i].MinValue+offset})
        table.insert(testInputPairs, {variableBoundDefinitions[i].MaxValue-offset})
        table.insert(testInputPairs, {variableBoundDefinitions[i].MaxValue})
        table.insert(testInputPairs, {variableBoundDefinitions[i].MaxValue+offset})

        local oldVarIdx = i

        --Iterate over the preceding set of test input pairs and add the new variable to them.
        for j = (i-1)*6, 1, -1 do
            table.insert(testInputPairs[j], variableBoundDefinitions[i].NominalValue)

            if j % 6 == 0 then
                oldVarIdx -= 1
            end

            --Add the older variable's Nominal value to the current variable's new set of pairings.
            table.insert(testInputPairs[(i*6)-(j%6)], variableBoundDefinitions[oldVarIdx].NominalValue)
        end

        table.insert(nominalPair, variableBoundDefinitions[i].NominalValue)
    end

    table.insert(testInputPairs, nominalPair)

    return testInputPairs
end

return BoundaryValueTestFuncs