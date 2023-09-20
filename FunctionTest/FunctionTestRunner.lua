local FunctionTestMod = require(script.Parent.FunctionTest)

--Describes information of a test to be run and evaluated.
export type TestInfo = {
    TestMethod: string,
    RunWithPCall: boolean,
    FunctionToRun: (any) -> any,
    FunctionArguments: table,
    ExpectedReturnValues: {[number]: FunctionTestMod.TestReturnValue},
    ExpectedArgumentMutations: {[number]: FunctionTestMod.TestArgumentMutation}
}

---Module to simplify running multiple tests under the guise of a single context string.
---Useful for running "UnitTests" as they deemed in other languages
local FunctionTestRunner = {
    TestTypes = FunctionTestMod.TestTypes
}

---Run a suite of tests through the FunctionTest Module and return the results.
---@param testsToRun table
---@param suiteName string
function FunctionTestRunner.RunTestSuite(testsToRun: {[number]: TestInfo}, suiteName: string)
    local numTestsPassed = 0
    local testViolations = {}

    if not testsToRun then
        error("Missing argument #1. Expected table.")
    end

    if not type(testsToRun) == "table" then
        error(`Invalid argument #1. Expected table. Actual {type(testsToRun)}`)
    end

    suiteName = suiteName and tostring(suiteName) or "TestSuite"

    for testNum: number, testInfo: TestInfo in pairs(testsToRun) do
        local didTestPass = false
        local testViolation = nil

        if testInfo.TestMethod == FunctionTestRunner.TestTypes.ReturnValueCheck then

            if testInfo.RunWithPCall then
                didTestPass, testViolation = FunctionTestMod.RunFunctionReturnTestSafe(
                    testInfo.FunctionToRun,
                    testInfo.ExpectedReturnValues,
                    testInfo.FunctionArguments,
                    suiteName,
                    testNum)
            else
                didTestPass, testViolation = FunctionTestMod.RunFunctionReturnTest(
                    testInfo.FunctionToRun,
                    testInfo.ExpectedReturnValues,
                    testInfo.FunctionArguments,
                    suiteName,
                    testNum)
            end
        else

            if testInfo.RunWithPCall then
                didTestPass, testViolation = FunctionTestMod.RunFunctionMutationTestSafe(
                    testInfo.FunctionToRun,
                    testInfo.ExpectedArgumentMutations,
                    testInfo.FunctionArguments,
                    suiteName,
                    testNum)
            else
                didTestPass, testViolation = FunctionTestMod.RunFunctionMutationTest(
                    testInfo.FunctionToRun,
                    testInfo.ExpectedArgumentMutations,
                    testInfo.FunctionArguments,
                    suiteName,
                    testNum)
            end
        end

        if didTestPass then
            numTestsPassed += 1
        else
            table.insert(testViolations, testViolation)
        end
    end

    return {
        SuiteName = suiteName,
        NumPassed = numTestsPassed,
        NumFailed = #testsToRun - numTestsPassed,
        Violations = testViolations
    }
end

return FunctionTestRunner