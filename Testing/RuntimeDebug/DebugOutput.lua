local RunService = game:GetService("RunService")

--Sets whether or not messages will be output while testing in Studio.
local DEBUG_OUTPUT_STUDIO = true

--Sets whether or not messages will be output while testing live.
local DEBUG_OUTPUT_LIVE = false

--Filters the message output to only include those matching a specific context.
local MSG_CONTEXT_FILTER = nil

--Filters the message output to only include those genered by a specific source script
local MSG_SOURCE_FILTER = nil

--Filters the warning message output to only include those matching a specific context.
local WARN_CONTEXT_FILTER = nil

--Filters the warning message output to only include those genered by a specific source script
local WARN_SOURCE_FILTER = nil

local DebugOutput = {
    Contexts = {}   --User-defined contexts for filtering messages and warnings
}

---Initialization step. Gets the runtime context.
local function _init()

    if RunService:IsStudio() then
        DebugOutput.ActiveContext = 'Studio'

        if DEBUG_OUTPUT_STUDIO then
            DebugOutput.ActiveOutput = true
        else
            DebugOutput.ActiveOutput = false
        end
    else
        DebugOutput.ActiveContext = 'Live'

        if DEBUG_OUTPUT_LIVE then
            DebugOutput.ActiveOutput = true
        else
            DebugOutput.ActiveOutput = false
        end
    end

    if DebugOutput.ActiveOutput then
        print(`{script.Name}: Output active for current runtime context.`)

        if MSG_SOURCE_FILTER then
            print(`\t> Only log messages from source: {MSG_SOURCE_FILTER}.`)
        end

        if MSG_CONTEXT_FILTER then
            print(`\t> Only log messages with context: {MSG_CONTEXT_FILTER}.`)
        end

        if WARN_SOURCE_FILTER then
            print(`\t> Only log warnings from source: {WARN_SOURCE_FILTER}.`)
        end

        if WARN_CONTEXT_FILTER then
            print(`\t> Only log warnings with context: {WARN_CONTEXT_FILTER}.`)
        end
    end
end

---Print a message to output irregardless of the active context.
---@param debugMsg string
---@param msgSource string
function DebugOutput.PrintDebug(debugMsg: string, msgSource: string, ...)
    msgSource = msgSource or "Server"

    if DebugOutput.ActiveOutput then

        if not MSG_SOURCE_FILTER or MSG_SOURCE_FILTER == msgSource then
            print(`{msgSource}: {debugMsg}`)

            if ... then
                print(`\t>`, ...)
            end
        end
    end
end

---Print a message to output tied to a specific debugging context.
---@param debugMsg string
---@param debugContext string
---@param msgSource string
function DebugOutput.PrintDebugWithContext(debugMsg: string, debugContext: string, msgSource: string, ...)
    msgSource = msgSource or "Server"

    if not debugContext and RunService:IsStudio() then
        warn(`{script.Name}: Missing context for passed message to print from {msgSource}.`)
        return
    end

    if DebugOutput.ActiveOutput then

        if not MSG_SOURCE_FILTER or MSG_SOURCE_FILTER == msgSource then

            if not MSG_CONTEXT_FILTER or MSG_CONTEXT_FILTER == debugContext then
                print(`{debugContext} in {msgSource}: {debugMsg}`)

                if ... then
                    print(`\t>`, ...)
                end
            end
        end
    end
end

---Print a warning to output irregardless of the active context.
---@param debugWarn string
---@param warnSource string
function DebugOutput.WarnDebug(debugWarn: string, warnSource: string, ...)
    warnSource = warnSource or "Server"

    if DebugOutput.ActiveOutput then

        if not WARN_SOURCE_FILTER or WARN_SOURCE_FILTER == warnSource then
            warn(`{warnSource}: {debugWarn}`)

            if ... then
                print(`\t>`, ...)
            end
        end
    end
end

---Print a warning to output tied to a specific debugging context.
---@param debugWarn string
---@param debugContext string
---@param warnSource string
function DebugOutput.WarnDebugWithContext(debugWarn: string, debugContext: string, warnSource: string, ...)
    warnSource = warnSource or "Server"

    if not debugContext and RunService:IsStudio() then
        warn(`{script.Name}: Missing context for passed warning to print from {warnSource}.`)
        return
    end

    if DebugOutput.ActiveOutput then

        if not WARN_SOURCE_FILTER or WARN_SOURCE_FILTER == warnSource then

            if not WARN_CONTEXT_FILTER or WARN_CONTEXT_FILTER == debugContext then
                warn(`{debugContext} in {warnSource}: {debugWarn}`)

                if ... then
                    warn(`\t>`, ...)
                end
            end
        end
    end
end

_init()

return DebugOutput