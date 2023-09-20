local FunctionTestMod = require(script.Parent.FunctionTest)

--Describes the results table formed while running the suite.
type TestResults = {
    NumTestsPassed: number,
    TestViolations: table
}

local TestSuite = {}
TestSuite.__index = TestSuite

---Class-like Table for managing a collection of functions to be run and tests under a single suite name.
---@param suiteName string
---@return table
function TestSuite.New(suiteName: string)
    local self = {
        SuiteName = tostring(suiteName),
        Tests = {}
    }

    setmetatable(self, TestSuite)
    return self
end

---Add a TestFunction to the TestSuite for evaluating mutations to one or more input arguments.
---@param funcToCall function
---@param expectedArgumentMutations table
---@param funcArgs table
---@param usePCall boolean
function TestSuite:AddArgumentMutationTest(
    funcToCall: (any) -> any, expectedArgumentMutations: table, funcArgs: table, usePCall: boolean)

    if not funcToCall then
        error("Missing argument #1. Expected function.")
    end

    if type(funcToCall) ~= "function" then
        error(`Invalid argument #1. Expected function. Actual {type(funcToCall)}.`)
    end

    if not expectedArgumentMutations then
        error(`Missing argument #2. Expected table.`)
    end

    if type(expectedArgumentMutations) ~= "table" then
        error(`Invalid argument #2. Expected table. Actual {type(expectedArgumentMutations)}.`)
    end

    if type(funcArgs) ~= "table" then
        error(`Invalid argument #3. Expected table. Actual {type(funcArgs)}.`)
    end

    table.insert(self.Tests, {
        ExpectedParamMutations = expectedArgumentMutations,
        FunctionParameters = funcArgs,
        FunctionToRun = funcToCall,
        RunWithPCall = usePCall,
        TestMethod = FunctionTestMod.TestTypes.ReturnValueCheck,
    })
end

---Add a TestFunction to the TestSuite for evaluating a function's return values.
---@param funcToCall function
---@param expectedReturnValues table
---@param funcArgs table
---@param usePCall boolean
function TestSuite:AddReturnValueTest(
    funcToCall: (any) -> any, expectedReturnValues: table, funcArgs: table, usePCall: boolean)

    if not funcToCall then
        error("Missing argument #1. Expected function.")
    end

    if type(funcToCall) ~= "function" then
        error(`Invalid argument #1. Expected function. Actual {type(funcToCall)}.`)
    end

    if not expectedReturnValues then
        error(`Missing argument #2. Expected table.`)
    end

    if type(expectedReturnValues) ~= "table" then
        error(`Invalid argument #2. Expected table. Actual {type(expectedReturnValues)}.`)
    end

    if type(funcArgs) ~= "table" then
        error(`Invalid argument #3. Expected table. Actual {type(funcArgs)}.`)
    end

    table.insert(self.Tests, {
        FunctionArguments = funcArgs,
        ExpectedReturnValues = expectedReturnValues,
        FunctionToRun = funcToCall,
        RunWithPCall = usePCall,
        TestMethod = FunctionTestMod.TestTypes.ReturnValueCheck,
    })
end

---Log the Test Suite's previous run results.
function TestSuite:LogResults()

    if not self.TestResults then
        print(`Test Suite {self.SuiteName} has not been run. No results to report.`)

    else
        local numTestsFailed = #self.Tests - self.TestResults.NumTestsPassed
        print(`{self.SuiteName}: {self.TestResults.NumTestsPassed} tests passed. {numTestsFailed} tests failed.`)

        if numTestsFailed > 0 then
            print("Violations: ", self.TestResults.Violations)
        end
    end
end

---Run the test suite for all registered tests and store the results.
---Equivalent to FunctionTestMod.RunTestSuite without logging.
function TestSuite:Run()
    self.TestResults = {
        NumTestsFailed = 0,
        NumTestsPassed = 0,
        Violations = {}
    }

    for testNum: number, functionTest: table in pairs(self.Tests) do
        local didTestPass = false
        local testViolation = nil

        if functionTest.TestMethod == FunctionTestMod.TestTypes.ReturnValueCheck then

            if functionTest.RunWithPCall then
                didTestPass, testViolation = FunctionTestMod.RunFunctionReturnTestSafe(
                    functionTest.FunctionToRun,
                    functionTest.ExpectedReturnValues,
                    functionTest.FunctionParameters,
                    self.SuiteName,
                    testNum)
            else
                didTestPass, testViolation = FunctionTestMod.RunFunctionReturnTest(
                    functionTest.FunctionToRun,
                    functionTest.ExpectedReturnValues,
                    functionTest.FunctionParameters,
                    self.SuiteName,
                    testNum)
            end
        else

            if functionTest.RunWithPCall then
                didTestPass, testViolation = FunctionTestMod.RunFunctionMutationTestSafe(
                    functionTest.FunctionToRun,
                    functionTest.ExpectedParamMutations,
                    functionTest.FunctionParameters,
                    self.SuiteName,
                    testNum)
            else
                didTestPass, testViolation = FunctionTestMod.RunFunctionMutationTest(
                    functionTest.FunctionToRun,
                    functionTest.ExpectedParamMutations,
                    functionTest.FunctionParameters,
                    self.SuiteName,
                    testNum)
            end
        end

        if didTestPass then
            self.TestResults.NumTestsPassed += 1
        else
            table.insert(self.TestResults.Violations, testViolation)
        end
    end
end

return TestSuite