# Runtime Debugging Tools

The scripts contained within this folder can be used for debugging values at runtime.

## DebugOutput.lua
This ModuleScript contains functions for outputting formatted print messages and warnings that can be invoked from any other scripts. 
It is designed to offer finer control over the output of print and warning messages when debugging a game in real-time.

Messages and warnings can be filtered according to specific contexts or source scripts.
A set of configurable settings are defined at the top of the module.

### Module Functions
There are four public module functions used for output.

**PrintDebug:** Print a message to output irregardless of the active context.

**PrintDebugWithContext:** Print a message to output tied to a specific debugging context.

**WarnDebug:** Print a warning to output irregardless of the active context.

**WarnDebugWithContext:** Print a warning to output tied to a specific debugging context.

### Example
Consider the use of this Module in the snippet below from another Script or ModuleScript.

```lua
--RoundTeleporter.lua

local DebugOutputMod = require(script.Parent.DebugOutput)

local RoundTeleporter = {}

---Teleport the Player into the round arena at the location specified.
---@param player Player
---@param destCF CFrame
function RoundTeleporter.TeleportToRound(player: Player, destCF: CFrame)
  if player and player.Character then
    local humanoid = player.Character:FindFirstChild("Humanoid")

    if humanoid and humanoid.Health > 0 then

      if destCF and destCF:IsA("CFrame") then
        player.Character:PivotTo(destCF)
      else
        DebugOutput.WarnDebugWithContext(
          `Invalid CFrame {destCF} provided for teleporting player into round.`,
          "RoundBegin",
          script.Name)
      end

    else
      DebugOutput.PrintDebugWithContext(
        `{player.Name} is dead and will not be teleported into the round.`,
        "RoundBegin",
        script.Name)
    end
  end
end

return RoundTeleporter
```
