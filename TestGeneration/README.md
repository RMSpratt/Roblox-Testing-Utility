# Test Case Generation Tools

This folder contains ModuleScripts designed to assist in the generation of test cases.

## BoundaryValue.lua
This ModuleScript contains functions capable of generating sets of input variable values that align with Boundary-Value Analysis techniques.

These inputs can then be fed to functions as arguments for test cases.

### Custom Types

#### VariableBoundDefinition
This type defines the expected structure of arguments in each of the functions included.

It is a key-value table with the parameters:
- **MinValue:** (number) The minimum value possible for the variable.
- **MaxValue:** (number) The maximum value possible for the variable.
- **NominalValue:** (number) A typical value for the variable within the range.
- **OffsetIncrement:** (number) A custom increment to be used when offsetting the value.

### Functions