# Testing Utility ModuleScript Suite

This repository features a set of ModuleScripts designed to provide basic function testing
and runtime debugging.

These ModuleScripts are designed to be lightweight and flexible for use.

## Main directory
This directory contains one lone ModuleScript.

### RandomValue.lua
This ModuleScript has several functions for generating RandomValues according to
uniform or weighted probability distributions, and according to user-defined
restrictions or limits.

Weighted selection when present is based on percentage-chance in decimal format.

Ex. If you have five values that can be selected at random with associated weights:
{0.1, 0.2, 0.2, 0.2, 0.3}, value 5 will have a 30% chance of selection on average.

#### Module Types
There are a few custom types to help define restrictions and weightings for values to be generated.

##### NumberRangeWeight
Describes a continuous number range for numbers to be generated with a weighted probability.

It is an object-like table with keys:
- MinNum (number) The minimum number that can be generated (inclusive)
- MaxNum (number) The maximum number that can be generated (inclusive)
- Weight (number) The weighted probability for this range in selection. (0-1)

##### TableKeyWeight
Assigns a weight for selecting a named key within a table.

It is an object-like table with keys:
- Key (any) The key from the table for selection.
- Weight (number) The weighted probability for this key in selection (0-1)

#### Module Warnings
This function is equipped to detect misuse when generating random values.

As this ModuleScript may be invoked during runtime, it will never purposefully
throw errors. Instead, it can optionally generate warning messages.

There are four options for the level of detail for warnings:

- None: No messages are printed
- MessageOnly: Just the module function misuse error is reported.
- FunctionTrace: The module function misuse error and function name are reported.
- FullTraceback: The warning is output in debug.traceback()

#### Module Functions

**GetArrayValueByIndex:** Get and return a random value selected from the passed array table.

**GetBooleanValue:** Get and return a random boolean value. Probability of a true value is
optionally skewed.

**GetIntegerInRange:** Get and return a random integer of uniform chance distributed
within the range specified.

**GetIntegerInBrokenRange:** Get and return a random integer of uniform chance distributed
across one or more number ranges.

**GetNumber01:** Get and return a random (0,1) number rounded to numPlaces or 2 decimal places.

**GetTableValueByKey:** Get a random value from the passed object table.
Uniform selection across the keys is used.

**GetWeightedArrayValueByIndex:** Get a random value from the passed array.
Weighted selection is used based on probabilities specified.

**GetWeightedIntegerFromRanges:** Get and return a random integer of weighted chance
distributed across one or more number ranges.

**GetWeightedTableValueByKey:** Get a random value from the passed table.
Weighted selection is used based on probabilities specified.

**SetRandomSeed:** Set the Module's random number generator to use the seed passed.

**SetNewRandomSeed:** Generate a new random seed for the Module's random number generator.

**SetWarningLevelOfDetail:** Set the level of detail to use when displaying Module function
misuse warnings.

## Subdirectory: FunctionTest
This directory contains three ModuleScripts designed for testing function behaviour
according to their return values and mutations to input parameters.

There are three ModuleScripts catered to this purpose.

### FunctionTest.lua
This is the only required ModuleScript for this unit designed to support unit tests that
run a function and evaluate it against a set of expected return values or mutations to
input arguments.

Each of the functions included for testing return a (boolean, string) tuple pair as output.

If the function to be tested passes according to its expected behaviour, a true value is returned
with no string as output. Otherwise, a false value is returned along with a string describing the
violation that caused the test to fail.

#### Module Types
There are three custom types defined in this Module, and all three are used by its functions
for testing.

##### TestReturnValue
This data type describes an expected return value from a function.

It is an object-like table with the keys:
- ExpectedType: (string) The expected basic data type for the return value.
- ExpectedValue: (any) The expected return value itself.
- ExpectedClassName: (string) The expected specific ClassName for the return value. (Optional)
- ComparisonInfo: (table) Describes how the expected and actual return values are compared.

##### TestArgumentMutation
This data type describes an expected function argument mutation from a function.

It is an object-like table with the keys:
- ArgumentIdx: (number) The position of the argument as a function input argument.
- ExpectedValue: (any) The expected mutated value.
- ComparisonInfo: (table) Describes how the expected and actual return values are compared.

##### ComparisonInfo
This data type describes how two variables are compared (==) comparison.

It is an object-like table with the keys:
- ComparisonMethod: (string) The method of comparison for the two values.
- ComparisonFunction: (function) The function used to compare the two values. (Optional)

#### Module Functions
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

### FunctionTestRunner.lua
This function provides a method for running multiple FunctionTest methods together in
a single context, as a suite of tests.

This ModuleScript is optional for use. TestSuite.lua offers an alternative method for
running "suites" of tests.

#### Module Types
Only one custom type is used by this ModuleScript.

#### TestInfo
This data type describes test information to match FunctionTest's functions.

It is an object-like table with the keys:
- TestMethod: (string) The type of test to be run. One of FunctionTest.TESTABLE_BEHAVIOURS.
- RunWithPCall: (boolean) Whether or not this function should be invoked wrapped in an xpcall.
- FunctionToRun: (function) The function to be invoked and tested.
- FunctionArguments: (table) A table of arguments to the function to be invokeed and tested.
- ExpectedReturnValues: (table) An array table of FunctionTestMod.ExpectedReturnValue objects.
- ExpectedArgumentMutations: (table) An array table of FunctionTestMod.ExpectedArgumentMutation objects.

#### Module Functions
A single function is used to run tests.

**RunTestSuite:** Runs a set of tests formatted using the custom TestInfo type.

### TestSuite.lua
A class-like ModuleScript to more easily create and manage suites of tests.

Unlike FunctionTestRunner.lua, this Module doesn't require on knowledge of the
TestInfo custom type structure.

#### Module Functions
There are functions for creating TestSuite table instances, adding tests to the created
test suite, running the test suite instances, and logging the results.

**New:** Create a new Instance of the TestSuite table with Index pointing to the TestSuite base table.

**AddArgumentMutationTest:** Add a TestFunction to the TestSuite for evaluating mutations
to one or more input arguments.

**AddReturnValueTest:** Add a TestFunction to the TestSuite for evaluating a function's
return values.

**LogResults:** Log the Test Suite's previous run results.

**Run:** Run the test suite for all registered tests and store the results.

## Directory: Demonstrations
This sub-directory contains ModuleScripts with examples of how the other testing modules
should be used. Currently, examples for FunctionTest and RandomValue are included.

## Directory: RuntimeDebug
This sub-directory contains ModuleScripts with functions designed for in-studio and/or
in-game runtime debugging.

### DebugOutput.lua
This ModuleScript contains functions for outputting formatted print messages and warnings
that can be invoked from any other scripts.

Messagges and warnings can be filtered according to specific contexts or script sources.
A set of configurable settings are defined at the top of the module.

#### Module Functions
There are four public module functions used for output.

**PrintDebug:** Print a message to output irregardless of the active context.

**PrintDebugWithContext:** Print a message to output tied to a specific debugging context.

**WarnDebug:** Print a warning to output irregardless of the active context.

**WarnDebugWithContext:** Print a warning to output tied to a specific debugging context.
