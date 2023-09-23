
--Defines the basic structure of nodes in the Cache
type CacheNode = {
    AssetId: number,
    PrevNode: CacheNode,
    NextNode: CacheNode
}

local assetCacheLookup: {[number]: CacheNode} = {}
local assetCacheFront: CacheNode = nil
local assetCacheBack: CacheNode = nil
local assetCacheCount = 0
local ASSET_CACHE_CAPACITY = 100

local FunctionTestMod = require(script.Parent.Parent.FunctionTest.FunctionTest)
local TestSuiteMod = require(script.Parent.Parent.FunctionTest.TestSuite)

---Completely clear the AssetCache and its associated lookup.
local function clearCache()
    local currCacheNode = assetCacheFront

    if currCacheNode then

        while currCacheNode.NextNode ~= nil do
            currCacheNode = currCacheNode.NextNode
            currCacheNode.PrevNode.AssetId = nil
            currCacheNode.PrevNode.NextNode = nil
            currCacheNode.PrevNode = nil
        end

        currCacheNode.AssetId = nil
    end

    table.clear(assetCacheLookup)
    assetCacheCount = 0
end

---Create a new CacheNode with the assetId provided.
---@param assetId number
---@return table
local function createCacheNode(assetId: number)
    return {
        AssetId = assetId,
        PrevNode = nil,
        NextNode = nil
    }
end

---Get and return the first numAssets AssetIds from the AssetCache.
---@param numAssets number
---@return table
local function getFirstNCacheAssets(numAssets: number)
    local frontCacheAssets = {}
    local currCacheNode = assetCacheFront

    for nodeIdx = 1, numAssets, 1 do

        if currCacheNode == nil then
            break
        end

        frontCacheAssets[nodeIdx] = currCacheNode.AssetId
        currCacheNode = currCacheNode.NextNode
    end

    return frontCacheAssets
end

---Get and return the last numAssets AssetIds from the AssetCache.
---@param numAssets number
---@return table
local function getLastNCacheAsssets(numAssets: number)
    local rearCacheAssets = {}
    local currCacheNode = assetCacheBack

    for nodeIdx = 1, numAssets, 1 do

        if currCacheNode == nil then
            break
        end

        rearCacheAssets[nodeIdx] = currCacheNode.AssetId
        currCacheNode = currCacheNode.PrevNode
    end

    return rearCacheAssets
end

---Move a CacheNode with the assetId provided within the cache.
---If the assetId is new to the cache, insert it as a new node.
---@param assetId number
local function moveAssetInCache(assetId: number)

    if not assetCacheLookup[assetId] then
        local newCacheHead = createCacheNode(assetId)

        if assetCacheBack == nil then
            assetCacheFront = newCacheHead
            assetCacheBack = newCacheHead

        else
            newCacheHead.NextNode = assetCacheFront
            newCacheHead.NextNode.PrevNode = newCacheHead
            assetCacheFront = newCacheHead
        end

        assetCacheLookup[assetId] = assetCacheFront

        --Dequeue the back node which now exceeds capacity
        if assetCacheCount > ASSET_CACHE_CAPACITY then
            assetCacheLookup[assetCacheBack.AssetId] = nil
            assetCacheBack = assetCacheBack.PrevNode
            assetCacheBack.NextNode = nil

        else
            assetCacheCount += 1
        end

    else
        local assetToShift: CacheNode = assetCacheLookup[assetId]

        if assetToShift.PrevNode then
            assetToShift.PrevNode.NextNode = assetToShift.NextNode

            if assetToShift.NextNode then
                assetToShift.NextNode.PrevNode = assetToShift.PrevNode
            else
                assetCacheBack = assetCacheBack.PrevNode
                assetCacheBack.NextNode = nil
            end

            assetToShift.NextNode = assetCacheFront
            assetToShift.NextNode.PrevNode = assetToShift
            assetToShift.PrevNode = nil
            assetCacheFront = assetToShift
        end
    end
end

local TestSuiteDemo = {}

---Run the Demonstration.
function TestSuiteDemo.Run()
    moveAssetInCache(106709021)
    moveAssetInCache(129533465)
    moveAssetInCache(1743924583)

    local expectedReverseCacheTable = {
    [1] = 106709021,
    [2] = 129533465,
    [3] = 1743924583,
    }

    local expectedCacheTable = {
        [1] = 1743924583,
        [2] = 129533465,
        [3] = 106709021,
    }

    local frontTestReturnValue = FunctionTestMod.CreateTestReturnValueObject(
    "table", expectedCacheTable, nil, FunctionTestMod.ComparisonMethods.KeyTable, nil)

    local rearTestReturnValue = FunctionTestMod.CreateTestReturnValueObject(
    "table", expectedReverseCacheTable, nil, FunctionTestMod.ComparisonMethods.KeyTable, nil)

    local testSuite = TestSuiteMod.New("Demonstration Suite")

    testSuite:AddReturnValueTest(getFirstNCacheAssets, {frontTestReturnValue}, {3}, false)
    testSuite:AddReturnValueTest(getLastNCacheAsssets, {rearTestReturnValue}, {3}, false)

    --Can the function handle input that exceeds the cache size?
    testSuite:AddReturnValueTest(getFirstNCacheAssets, {frontTestReturnValue}, {10}, false)
    testSuite:AddReturnValueTest(getLastNCacheAsssets, {rearTestReturnValue}, {10}, false)

    testSuite:Run()
    testSuite:LogResults()
    clearCache()
end

return TestSuiteDemo