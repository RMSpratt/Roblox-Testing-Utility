local FunctionTestMod = require(script.Parent.FunctionTest)

--Describes the results table formed while running the suite.
type TestResults = {
    NumTestsPassed: number,
    TestViolations: table
}

---Class-like Table for managing a collection of functions to be run and tests under a single suite name.
local TestSuite = {}
TestSuite.__index = TestSuite

---Create a new Instance of the TestSuite table with Index pointing to the TestSuite base table.
---@param suiteName string
---@return table
function TestSuite.New(suiteName: string)
    local self = {
    }

    setmetatable(self, TestSuite)

    self.SuiteName = tostring(suiteName)
    self.Tests = {}
    return self
end

---Add a TestFunction to the TestSuite for evaluating mutations to one or more input arguments.
---@param funcToCall function The function to be invoked and tested.
---@param expectedArgumentMutations table The full set of TestArgumentMutation objects for testing.
---@param funcArgs table The arguments to be passed to the function to be invoked and tested.
---@param usePCall boolean Describes whether or not to invoke the function with xpcall.
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
        ExpectedArgumentMutations = expectedArgumentMutations,
        FunctionArguments = funcArgs,
        FunctionToRun = funcToCall,
        RunWithPCall = usePCall,
        TestMethod = FunctionTestMod.TestTypes.ArgumentMutationCheck,
    })
end

---Add a TestFunction to the TestSuite for evaluating a function's return values.
---@param funcToCall function The function to be invoked and tested.
---@param expectedReturnValues table The full set of TestReturnValue objects for testing.
---@param funcArgs table The arguments to be passed to the function to be invoked and tested.
---@param usePCall boolean Describes whether or not to invoke the function with xpcall.
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
                    functionTest.FunctionArguments,
                    self.SuiteName,
                    testNum)
            else
                didTestPass, testViolation = FunctionTestMod.RunFunctionReturnTest(
                    functionTest.FunctionToRun,
                    functionTest.ExpectedReturnValues,
                    functionTest.FunctionArguments,
                    self.SuiteName,
                    testNum)
            end

        else
            if functionTest.RunWithPCall then
                didTestPass, testViolation = FunctionTestMod.RunFunctionMutationTestSafe(
                    functionTest.FunctionToRun,
                    functionTest.ExpectedArgumentMutations,
                    functionTest.FunctionArguments,
                    self.SuiteName,
                    testNum)
            else
                didTestPass, testViolation = FunctionTestMod.RunFunctionMutationTest(
                    functionTest.FunctionToRun,
                    functionTest.ExpectedArgumentMutations,
                    functionTest.FunctionArguments,
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