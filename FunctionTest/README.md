# ModuleScripts for Testing Expected Function Behaviour
This directory contains three ModuleScripts designed for testing function behaviour
according to their return values and changes made to input parameters.

## FunctionTest.lua
This ModuleScript is designed to support unit tests that run a function and evaluate it 
against a set of expected return values or mutations to input arguments.

Each of the functions included for testing return a (boolean, string) tuple pair as output.

If the function to be tested passes according to its expected behaviour, a true value is returned
with no string as output. Otherwise, a false value is returned along with a string describing the
violation that caused the test to fail.

### Custom Types
There are three custom types defined in this Module for use in its functions.
These types are exported and can be referenced in other scripts.

#### TestReturnValue
This data type describes an expected return value from a function.

It is an object-like table with the keys:
- **ExpectedType:** (string) The expected basic data type for the return value.
- **ExpectedValue:** (any) The expected return value itself.
- **ExpectedClassName:** (string) The expected specific ClassName for the return value. (Optional)
- **ComparisonInfo:** (table) Describes how the expected and actual return values are compared.

#### TestArgumentMutation
This data type describes an expected function argument mutation from a function.

It is an object-like table with the keys:
- **ArgumentIdx:** (number) The position of the argument as a function input argument.
- **ExpectedValue:** (any) The expected mutated value.
- **ComparisonInfo:** (table) Describes how the expected and actual return values are compared.

#### ComparisonInfo
This data type describes how two variables are compared (==) comparison.

It is an object-like table with the keys:
- **ComparisonMethod:** (string) The method of comparison for the two values.
- **ComparisonFunction:** (function) The function used to compare the two values. (Optional)

### Functions
There are four functions used specifically for running and testing functions.
There are two functions used for creating custom types to help with Module compliance.

**RunFunctionReturnTest:** Run the passed function with any arguments provided and evaluate
the resulting return values against those expected (ReturnValue objects).

**RunFunctionReturnTestSafe:** Same functionality as RunFunctionReturnTest, but xpcall
is used in invocation to catch errors that may be thrown.

**RunFunctionMutationTest:** Run the passed function with any arguments provided and
evaluate the resulting argument mutations against those expected.

**RunFunctionReturnTestSafe:** Same functionality as RunFunctionMutationTest, but xpcall
is used in invocation to catch errors that may be thrown.

**CreateTestArgumentMutationObject:** Creates and returns a TestArgumentMutation object
with the required fields provided.

**CreateTestReturnValueObject:** Creates and returns a TestReturnValue object with the
required fields provided.

### Examples
A few examples of FunctionTest's methods can be found in Demonstrations: [Demonstration Directory](../Demonstrations/README.md).

A simplified template example is presented below.
```lua
local FunctionTestMod = require(script.Parent.FunctionTest)

local playerData = {
  Coins = 300,
  Items = {}
}

local itemsForSale = {
  [1] = {
    Name = "GravityCoil",
    Cost = 250
  },
}

---Try to purchase the item specified and adjust the Player's data if valid.
local function tryPurchaseItem(playerData: table, itemId: number)
  local purchaseSuccessful = false
  --Function validation logic--
  return purchaseSuccessful
end

--Create a TestReturnValue object table describing the expected return value of tryPurchaseItem
local testReturnValue = FunctionTestFuncs.CreateTestReturnValueObject(
  "boolean",
  true,
  nil,
  FunctionTestMod.ComparisonMethods.Direct,
  nil)

local testPassed, testViolation = FunctionTestMod.RunFunctionReturnTest(
  tryPurchaseItem, {testReturnValue}, {playerData, itemId}, nil, 1)
```

---
## FunctionTestRunner.lua
This module provides a single function for running multiple FunctionTest calls together under
a single context. This is designed to mimic how a test suite would be created and ran.

This ModuleScript is an alternative to TestSuite.lua which offers the same functionality.

### Module Types
Only one custom type is used by this ModuleScript.

#### TestInfo
This data type describes test information to match FunctionTest's functions.

It is an object-like table with the keys:
- **TestMethod:** (string) The type of test to be run. One of FunctionTest.TESTABLE_BEHAVIOURS.
- **RunWithPCall:** (boolean) Whether or not this function should be invoked wrapped in an xpcall.
- **FunctionToRun:** (function) The function to be invoked and tested.
- **FunctionArguments:** (table) A table of arguments to the function to be invokeed and tested.
- **ExpectedReturnValues:** (table) An array table of FunctionTestMod.ExpectedReturnValue objects.
- **ExpectedArgumentMutations:** (table) An array table of FunctionTestMod.ExpectedArgumentMutation objects.

### Module Functions
A single function is used to run tests.

**RunTestSuite:** Runs a set of tests formatted using the custom TestInfo type.

## TestSuite.lua
A class-like ModuleScript to more easily create and manage suites of tests.

Unlike FunctionTestRunner.lua, this Module doesn't require on knowledge of the
TestInfo custom type structure.

### Module Functions
There are functions for creating TestSuite table instances, adding tests to the created
test suite, running the test suite instances, and logging the results.

**New:** Create a new Instance of the TestSuite table with Index pointing to the TestSuite base table.

**AddArgumentMutationTest:** Add a TestFunction to the TestSuite for evaluating mutations
to one or more input arguments.

**AddReturnValueTest:** Add a TestFunction to the TestSuite for evaluating a function's
return values.

**LogResults:** Log the Test Suite's previous run results.

**Run:** Run the test suite for all registered tests and store the results.

### Example
The code snippet below illustrates the general flow of how a TestSuite is created and run.
A full example can be found in the [Demonstrations folder](../Demonstrations/README.md)

```lua
local FunctionTestMod = require(script.Parent.FunctionTest)
local TestSuiteMod = require(script.Parent.TestSuite)

---Manipulate the passed dataTable.
---@param dataTable table
local function sampleMutationFunction(dataTable: table)
  dataTable.key = 11
end

---Return a passed value.
---@return any
local function returnPassedValue(someValue: any)
  return someValue
end

local testArgMutation = FunctionTestMod.CreateTestArgumentMutationObject(...)
local testReturnValue = FunctionTestMod.CreateTestReturnValueObject(...)

local testSuite = TestSuiteMod.New("demonstration-test")

testSuite.AddParamMutationTest(sampleMutationFunction, testArgMutation, {{["key"] = 10}, false)
testSuite.AddReturnValueTest(sampleReturnFunction, testReturnValue, {"Hello World"}, false)

testSuite.Run()
testSuite.LogResults()

```
