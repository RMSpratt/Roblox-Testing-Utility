---Check a table of variables and evaluate each according to its expected and actual type.
---@param variableContext string Descriptor of the type of variable being checked
---@param variableTable table A table of {expected, actual} value pairs for validation.
---@return table
local function _checkVariableTypes(variableContext: string, variableTable: table)
    local typeMismatches = {}

    for variableIdx, variableInfo in ipairs(variableTable) do

        if variableInfo[2] then
            local actualType = string.lower(typeof(variableInfo[2]))

            if actualType == "instance" and variableInfo[1] ~= actualType then

                if not variableInfo[2]["ClassName"] then
                    table.insert(
                        typeMismatches,
                        `Invalid {variableContext} var type #{variableIdx}. ` ..
                        `Ex: {variableInfo[1]} Actual: {actualType}.`)

                elseif string.lower(variableInfo[2].ClassName) ~= string.lower(variableInfo[1]) then
                    table.insert(
                        typeMismatches,
                        `Invalid {variableContext} var type #{variableIdx}. ` ..
                        `Ex: {variableInfo[1]} Actual: {variableInfo[2].ClassName}.`)
                end

            elseif actualType ~= string.lower(variableInfo[1]) then
                table.insert(
                    typeMismatches,
                    `Invalid {variableContext} var type #{variableIdx}.` ..
                    `Ex: {variableInfo[1]} Actual: {actualType}.`)
            end

        --The actual value of the variable provided is nil
        else
            table.insert(typeMismatches, `Missing variable {variableContext}_{variableIdx}.`)
        end
    end

    return typeMismatches
end

--Module provides functions for comparing variables for their expected type against their actual type.
local DebugValueTest = {
    DataTypes = {
        Character = "character",
        Folder = "folder",
        Function = "function",
        Instance = "instance",
        Modulescript = "modulescript",
        Number = "number",
        Player = "player",
        RemoteEvent = "remoteEvent",
        RemoteFunction = "remoteFunction",
        String = "string",
        Table = "table",
        Vector = "vector",
    }
}

---Check the passed Instance for a set of expected attributes.
---@param instanceToCheck Instance
---@param expectedAttributes table
function DebugValueTest.CheckInstanceAttributes(instanceToCheck: Instance, expectedAttributes: table)
    local violationTable = {}

    for attribName, attribType in pairs(expectedAttributes) do
        local actualAttrib = instanceToCheck:GetAttribute(attribName)

        if actualAttrib then

            if not typeof(actualAttrib) == attribType then
                table.insert(
                    violationTable,
                    `Unexpected value on {instanceToCheck.Name} for attribute {attribName}.`)
            end

        else
            table.insert(violationTable, `Missing attribute {attribName} on {instanceToCheck.Name}.`)
        end
    end

    return violationTable
end

---Evaluate each {type, value} pair to see if the value is of the expected type.
---Types are expected as strings.
---@param localTable table
---@return table
function DebugValueTest.CheckLocalTypes(localTable: {[string]: any})
    return _checkVariableTypes("local", localTable)
end

---Evaluate each {type, value} pair to see if the value matches the expected type.
---Types are expected as strings.
---@param argumentTable table
---@return table
function DebugValueTest.CheckArgumentTypes(argumentTable: {[string]: any})
   return _checkVariableTypes("argument", argumentTable)
end

---Look for the key lookupKey in lookupTable and return true if it is contained therewithin.
---@param lookupKey any
---@param lookupTable table
---@param lookupTableName string
---@return table
function DebugValueTest.CheckValueInLookup(lookupKey: any, lookupTable: table, lookupTableName: string)

    if not lookupKey then
        error("Missing argument #1 to CheckValueInLookup.")

    elseif not lookupTable then
        error("Missing argument #2. Table expected to CheckValueInLookup.")

    elseif not type(lookupTable) == "table" then
        error(`Invalid argument #2. Table expected. Got {type(lookupTable)}`)
    end

    lookupTableName = tostring(lookupTableName) or "table"

    return lookupTable[lookupKey] ~= nil
end

---Evaluates each {type, value} pair to see if the value matches the expected type (string).
---@param variableContext string
---@param valueTable table
---@return table
function DebugValueTest.CheckVariableTypes(variableContext: string, valueTable: {[number]: any})

    if not variableContext then
        variableContext = "variable"
    end

    return _checkVariableTypes(variableContext, valueTable)
end

---Return a formatted warning message for an Instance missing a required attribute.
---@param instanceName string
---@param expectedAttrib string
---@return string
function DebugValueTest.WarnMissingAttrib(instanceName: string, expectedAttrib: string)
    return (`Instance {instanceName} missing expected attribute {expectedAttrib}.`)
end

---Return a formatted warning message for a missing Instance.
---@param searchName string
---@param parentName string
---@return string
function DebugValueTest.WarnMissingInstance(searchName: string, parentName: string)
    return (`Parent {parentName} is missing expected child {searchName}.`)
end

---Return a formatted warning message for an unexpected variable type.
---@param variableName string
---@param actualType string
---@param expectedType string
---@return string
function DebugValueTest.WarnUnexpectedType(variableName: string, actualType: string, expectedType: string)
    return (`Variable {variableName} is type {actualType} and not expected type {expectedType}.`)
end

return DebugValueTest