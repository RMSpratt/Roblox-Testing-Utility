# ModuleScript for Generating Random Values
This ModuleScript has several functions for generating RandomValues according to
uniform or weighted probability distributions, and according to user-defined
restrictions or limits.

Weighted selection when present is based on percentage-chance in decimal format.

Ex. If you have five values that can be selected at random with associated weights:
{0.1, 0.2, 0.2, 0.2, 0.3}, value 5 will have a 30% chance of selection on average.

## Module Types
There are a few custom types to help define restrictions and weightings for values to be generated.

### NumberRangeWeight
Describes a continuous number range for numbers to be generated with a weighted probability.

It is an object-like table with keys:
- **MinNum** (number) The minimum number that can be generated (inclusive)
- **MaxNum** (number) The maximum number that can be generated (inclusive)
- **Weight** (number) The weighted probability for this range in selection. (0-1)

### TableKeyWeight
Assigns a weight for selecting a named key within a table.

It is an object-like table with keys:
- **Key** (any) The key from the table for selection.
- **Weight** (number) The weighted probability for this key in selection (0-1)

## Module Warnings
This function is equipped to detect misuse when generating random values.

As this ModuleScript may be invoked during runtime, it will never purposefully
throw errors. Instead, it can optionally generate warning messages.

There are four options for the level of detail for warnings:

- None: No messages are printed
- MessageOnly: Just the module function misuse error is reported.
- FunctionTrace: The module function misuse error and function name are reported.
- FullTraceback: The warning is output in debug.traceback()

## Module Functions
The functions available are listed below.

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

**SetNewRandomSeed:** Generate a new random seed for the Module's random number generator.

**SetRandomSeed:** Set the Module's random number generator to use the seed passed.

**SetWarningLevelOfDetail:** Set the level of detail to use when displaying Module function
misuse warnings.
