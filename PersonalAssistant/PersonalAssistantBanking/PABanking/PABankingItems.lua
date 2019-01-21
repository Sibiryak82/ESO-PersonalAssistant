-- Module: PersonalAssistant.PABanking.Items
-- Developer: Klingo

PAB_Items = {}

-- =====================================================================================================================
-- =====================================================================================================================

local function getItemsIn(bagId)
    local bagCache = SHARED_INVENTORY:GetOrCreateBagCache(bagId)
    local itemTable = setmetatable({}, { __index = table })

    -- create a table with all items
    for _, data in pairs(bagCache) do
        itemTable:insert({
            slotIndex = data.slotIndex,
            itemName = data.name,
            stackCount = data.stackCount,
            icon = data.iconFile,
        })
    end

    return itemTable
end


local function moveItemTo(itemData, toBagId)

    -- 1. get bagCache for correpsonding itemId
    -- 2. check if they have empty slots in the stack
    -- 3. fill these up
    -- 4. more items? YES: --> 5   NO --> 7
    -- 5. has free slots left? YES: --> 6   NO --> 7
    -- 6. move item --> 4
    -- 7. end


--        local firstEmptySlot = FindFirstEmptySlotInBag(bagId)

--    if IsProtectedFunction("RequestMoveItem") then
--        CallSecureProtected("RequestMoveItem", number sourceBag, number sourceSlot, number destBag, number destSlot, number stackCount)
--    else
--        RequestMoveItem(number sourceBag, number sourceSlot, number destBag, number destSlot, number stackCount)
--    end


end


local function doItemTransaction(fromBagId)

    local fromBagCache = SHARED_INVENTORY:GetOrCreateBagCache(fromBagId)

    for _, itemData in pairs(fromBagCache) do
        local _, maxStackSize = GetSlotStackSize(fromBagId, itemData.slotIndex)
        -- enrich the itemData
        itemData.itemId = GetItemId(fromBagId, itemData.slotIndex)
        itemData.itemType = GetItemType(fromBagId, itemData.slotIndex)
        itemData.maxStackSize = maxStackSize
        itemData.itemLink = GetItemLink(fromBagId, itemData.slotIndex, LINK_STYLE_BRACKETS)

        local itemMoveMode = PA.savedVars.Banking[PA.activeProfile].ItemTypes[itemData.itemType]

        if (itemMoveMode == PAB_MOVETO_BANK and fromBagId ~= BAG_BANK) then
            -- Deposit to Bank
            moveItemTo(itemData, BAG_BANK)

        elseif (itemMoveMode == PAB_MOVETO_BACKPACK and fromBagId ~= BAG_BACKPACK) then
            -- Withdraw to Backpack
            moveItemTo(itemData, BAG_BACKPACK)

        else
            -- Ignore
        end
    end

    -- TODO: Return whether at least one item was moved
end


-- =====================================================================================================================
-- =====================================================================================================================

function PAB_Items.DepositWithdrawItems()

    -- TODO: loop back and forth as long as both together had at least one item move

    -- first move items from the backpack
    doItemTransaction(BAG_BACKPACK)

    -- then move items from the bank
    doItemTransaction(BAG_BANK)

    -- then check the backpack again, since maybe new slots opened up
    doItemTransaction(BAG_BACKPACK)

end


-- =====================================================================================================================
-- =====================================================================================================================

PAB_Items.queueSize = 0
PAB_Items.loopCount = 0

-- =====================================================================================================================
-- =====================================================================================================================

local function DoItemTransactionOld(fromBagId, toBagId, transactionType, lastLoop)

    local timer = 100
    local skipChecksAndProceed = false
    local itemMoved = false

    local depStackType = PA.savedVars.Banking[PA.activeProfile].itemsDepStackType
    local witStackType = PA.savedVars.Banking[PA.activeProfile].itemsWitStackType

    local fromBagItemTypeList = PAB_Items.getItemTypeList(fromBagId)
    local toBagItemTypeList = PAB_Items.getItemTypeList(toBagId)

    -- pre-determine if in case of Junk the checks shall be skipped
    if ((transactionType == PAC_ITEMTYPE_DEPOSIT) and (PA.savedVars.Banking[PA.activeProfile].junkItemsMoveMode == PAC_ITEMTYPE_DEPOSIT)) then
        -- we are in deposit mode and junk shall be deposited
        skipChecksAndProceed = true
    elseif ((transactionType == PAC_ITEMTYPE_WITHDRAWAL) and (PA.savedVars.Banking[PA.activeProfile].junkItemsMoveMode == PAC_ITEMTYPE_WITHDRAWAL)) then
        -- we are in withdrawal mode and junk shall be withdrawn
        skipChecksAndProceed = true
    end

    for currFromBagItem = 0, #fromBagItemTypeList do
        -- store some transfer related information per item
        local transferInfo = {}
        transferInfo["fromBagId"] = fromBagId
        transferInfo["toBagId"] = toBagId
        transferInfo["fromItemName"] = GetItemName(transferInfo["fromBagId"], currFromBagItem):upper()
        transferInfo["fromItemLink"] = PAHF.getFormattedItemLink(transferInfo["fromBagId"], currFromBagItem)
        transferInfo["stackSize"] = GetSlotStackSize(transferInfo["fromBagId"], currFromBagItem)
        transferInfo["origStackSize"] = transferInfo["stackSize"]

        local isJunk = IsItemJunk(transferInfo["fromBagId"], currFromBagItem)
        local itemFound = false

        -- check if the item is marked as junk and whether junk shall be deposited too
        if isJunk and PA.savedVars.Banking[PA.activeProfile].junkItemsMoveMode == PAC_ITEMTYPE_IGNORE then
            -- do nothing; skip item (no junk shall be moved)
        elseif isJunk and ((transactionType == PAC_ITEMTYPE_DEPOSIT) and (PA.savedVars.Banking[PA.activeProfile].junkItemsMoveMode == PAC_ITEMTYPE_WITHDRAWAL)) then
            -- do nothing; skip item (junk has to be withdrawn but we are in deposit mode)
        elseif isJunk and ((transactionType == PAC_ITEMTYPE_WITHDRAWAL) and (PA.savedVars.Banking[PA.activeProfile].junkItemsMoveMode == PAC_ITEMTYPE_DEPOSIT)) then
            -- do nothing; skip item (junk has to be deposited but we are in withdraw mode)
        else
            -- loop through all item types
            for currItemType = 1, #PABItemTypes do
                -- checks if this item type has been enabled for deposits/withdraws and if it does match the type of the source item.... or if it is Junk and checks shall be skipped
                if (((PA.savedVars.Banking[PA.activeProfile].ItemTypes[PABItemTypes[currItemType]] == transactionType) and (fromBagItemTypeList[currFromBagItem] == PABItemTypes[currItemType])) or (isJunk and skipChecksAndProceed)) then
                    -- then loop through all items in the target bag
                    for currToBagItem = 0, #toBagItemTypeList do
                        -- store the name of the target item
                        transferInfo["toItemName"] = GetItemName(transferInfo["toBagId"], currToBagItem):upper()

                        -- compare the names
                        if transferInfo["fromItemName"] == transferInfo["toItemName"] then
                            -- item found in target bag, transfer item from source bag to target bag and get info how many items left
                            itemFound = true
                            itemMoved = true
                            transferInfo["stackSize"] = PAB_Items.transferItem(currFromBagItem, currToBagItem, transferInfo, lastLoop)
                        end

                        -- if no items left, break. otherwise continue the loop
                        if transferInfo["stackSize"] == 0 then
                            break
                            -- if "-1" returned, not enough space was available. stop the rest.
                        elseif transferInfo["stackSize"] < 0 then
                            return
                        end
                    end

                    -- all target-items checked - are still stacks left?
                    if transferInfo["stackSize"] > 0 then
                        -- only continue if it is allowed to start new stacks
                        if ((transactionType == PAC_ITEMTYPE_DEPOSIT and not (depStackType == PAB_STACKING_INCOMPLETE)) or (transactionType == PAC_ITEMTYPE_WITHDRAWAL and not (witStackType == PAB_STACKING_INCOMPLETE))) then
                            -- only deposit them, if full transaction is set or the item was already found (but had a full stack already)
                            if ((transactionType == PAC_ITEMTYPE_DEPOSIT and depStackType == PAB_STACKING_FULL) or (transactionType == PAC_ITEMTYPE_WITHDRAWAL and witStackType == PAB_STACKING_FULL) or itemFound) then
                                itemMoved = true
                                zo_callLater(function() PAB_Items.transferItem(currFromBagItem, nil, transferInfo, lastLoop) end, timer)
                                timer = timer + PA.savedVars.Banking[PA.activeProfile].depositTimerInterval
                                -- increase the queue of the "callLater" calls
                                PAB_Items.queueSize = PAB_Items.queueSize + 1
                                break
                            end
                        end
                    end

                end
            end
        end
    end

    return itemMoved
end


local function DoItemStacking(bagId)

    -- TODO: check the configuration if this shall be done or skipped

    local itemMoved = false

    local fromBagItemNameList = PAB_Items.getItemNameList(bagId)
    local toBagItemNameList = PAB_Items.getItemNameList(bagId)

    for currFromBagItem = #fromBagItemNameList, 1, -1 do
        -- only the upcoming items shall be checked, not the full list again
        for currToBagItem = (currFromBagItem - 1), 0, -1 do
            if not(currFromBagItem == currToBagItem) then
                local fromItemName = GetItemName(bagId, currFromBagItem):upper()
                local toItemName = GetItemName(bagId, currToBagItem):upper()

                if (fromItemName == toItemName) and not (fromItemName == "") then


                    local toStackSize, maxStack = GetSlotStackSize(bagId, currToBagItem)
                    if (maxStack > toStackSize) then
                        local fromStackSize, _ = GetSlotStackSize(bagId, currFromBagItem)
                        local size = 0
                        if (maxStack - toStackSize) > fromStackSize then
                            size = fromStackSize
                        else
                            size = maxStack - toStackSize
                        end

                        -- PAHF.println("stacking %s from %d (%d/%d) to %d (%d/%d)", fromItemName, currFromBagItem, toStackSize, maxStack, currToBagItem, fromStackSize, maxStack)

                        ClearCursor()
                        -- call secure protected (pickup the item via cursor)
                        result = CallSecureProtected("PickupInventoryItem", bagId, currFromBagItem, size)
                        if (result) then
                            -- call secure protected (drop the item on the cursor)
                            result = CallSecureProtected("PlaceInInventory", bagId, currToBagItem)
                        end
                        -- clear the cursor again to avoid issues
                        ClearCursor()
                        itemMoved = true
                        break
                    end
                end
            end
        end
    end

    -- as long as there was at least one stacking done, try to stack more
    if (itemMoved) then
        zo_callLater(function() DoItemStacking(bagId) end, 250)
    else
        -- return 'true' to indicate that stacking is complete
        return true
    end
end


-- checks if there are failedDeposits and re-runs the whole deposit-process in case the bank has not yet been closed
local function reDeposit()
    -- the bank is still open and there were failed Deposits
    if not PAB.isBankClosed and PAB_Items.failedDeposits > 0 then
        -- only run the deposit again if it didn't loop for three times yet
        if PAB_Items.loopCount < PAB_DEPOSIT_MAX_LOOPS then
            -- do it again! :)
            PAB_Items.DepositAndWithdrawItems()
        elseif PAB_Items.loopCount == PAB_DEPOSIT_MAX_LOOPS then
            -- and a last time (lastLoop = true)
            PAB_Items.DepositAndWithdrawItems(true)
        end
    else
        -- either the bank was closed or there are no more items to be deposited; or the maxLoop was reached
        -- TODO: implement summary stats
    end
end


-- checks if an item really has been moved or of it is still there
local function isItemMoved(fromSlotIndex, moveableStackSize, transferInfo, lastLoop)
    local depositFailed = false
    -- check if the same stack size is in the "old" slotIndex
    if (GetSlotStackSize(transferInfo["fromBagId"], fromSlotIndex) == transferInfo["origStackSize"]) then
        -- check if the same item name is in the "old" slotIndex
        if (GetItemName(transferInfo["fromBagId"], fromSlotIndex):upper() == transferInfo["fromItemName"]) then
            -- the item is still there and has NOT been moved.
            depositFailed = true
            PAB_Items.failedDeposits = PAB_Items.failedDeposits + 1
            if lastLoop then
                PAHF.println("PAB_ItemMovedToFailed", transferInfo["fromItemLink"], PAHF.getBagName(transferInfo["toBagId"]))
            end
        end
    end

    if not depositFailed then
        -- now we know for sure that the deposit did work
        PAHF.println("PAB_ItemMovedTo", moveableStackSize, transferInfo["fromItemLink"], PAHF.getBagName(transferInfo["toBagId"]))
    end

    -- decrease the queue size as the check has been done
    PAB_Items.queueSize = PAB_Items.queueSize - 1

    if PAB_Items.queueSize == 0 then
        reDeposit()
    end
end


-- actually moves the item
local function moveItem(fromSlotIndex, toSlotIndex, stackSize, transferInfo)

    local result = true
    -- clear the cursor first
    ClearCursor()
    -- call secure protected (pickup the item via cursor)
    result = CallSecureProtected("PickupInventoryItem", transferInfo["fromBagId"], fromSlotIndex, stackSize)
    if (result) then
        -- call secure protected (drop the item on the cursor)
        result = CallSecureProtected("PlaceInInventory", transferInfo["toBagId"], toSlotIndex)
    end
    -- clear the cursor again to avoid issues
    ClearCursor()

    if result then
        -- we only know for sure that it did work after the check that is done later. Don't post the success message yet!
        -- PAHF.println("PAB_ItemMovedTo", stackSize, transferInfo["fromItemLink"], PAHF.getBagName(transferInfo["toBagId"]))
    else
        PAHF.println("PAB_ItemNotMovedTo", stackSize, transferInfo["fromItemLink"], PAHF.getBagName(transferInfo["toBagId"]))
    end
end


-- =====================================================================================================================
-- =====================================================================================================================


function PAB_Items.DepositAndWithdrawItems(lastLoop)
    lastLoop = lastLoop or false

    PAB_Items.failedDeposits = 0
    PAB_Items.loopCount = PAB_Items.loopCount + 1


--    local itemMoved = DoItemStacking(BAG_BANK)
--    while (itemMoved == nil) do
        -- do nothing; wait
--    end
--    http://wiki.esoui.com/AddOn_Quick_Questions#How_do_I_generate_my_own_.22events.22_in_Lua.3F

    -- first deposit items to the bank
    local itemsDeposited = DoItemTransaction(BAG_BACKPACK, BAG_BANK, PAC_ITEMTYPE_DEPOSIT, lastLoop)

    -- then withdraw items from the bank
    local itemsWithdrawn = DoItemTransaction(BAG_BANK, BAG_BACKPACK, PAC_ITEMTYPE_WITHDRAWAL, lastLoop)

    -- then we can deposit the advanced items to the bank
-- TODO: TEMPORARILY DISABLED !!!!!
--    local itemsAdvancedDepositedWithdrawn = PAB_AdvancedItems.DoAdvancedItemTransaction()

--    while (itemsAdvancedDepositedWithdrawn == nil) do
        -- do nothing; wait
--    end

    if (itemsDeposited or itemsWithdrawn or itemsAdvancedDepositedWithdrawn) then
        return true
    else
        return false
    end
end

-- prepares the actual move
function PAB_Items.transferItem(fromSlotIndex, toSlotIndex, transferInfo, lastLoop)
    -- if there is no toSlot, try to find one
    if toSlotIndex == nil then toSlotIndex = FindFirstEmptySlotInBag(transferInfo["toBagId"]) end
    -- good, there is a slot
    if toSlotIndex ~= nil then
        local bankStackSize = GetSlotStackSize(transferInfo["toBagId"], toSlotIndex)
        -- have to read GetSlotStackSize again, as the targetBag-Slot could be empty, leading to value 0
        local _, maxStackSize = GetSlotStackSize(transferInfo["fromBagId"], fromSlotIndex)
        -- new stack size = maxStackSize minus existing bankStack
        local moveableStackSize = maxStackSize - bankStackSize
        local remainingStackSize = 0

        if (transferInfo["stackSize"] <= moveableStackSize) then
            moveableStackSize = transferInfo["stackSize"]
        else
            remainingStackSize = transferInfo["stackSize"] - moveableStackSize
        end


        if moveableStackSize > 0 then
            moveItem(fromSlotIndex, toSlotIndex, moveableStackSize, transferInfo)

            -- Before version 1.4.0 it could happen that when the item is not yet in the bank, the itemMove failed.
            -- This used to happen only if there are more than ~20 new items for the bank.
            -- This method will check if the item is still in its original place after 1-2 seconds
            -- and prints a message in case it happened again.
            zo_callLater(function() isItemMoved(fromSlotIndex, moveableStackSize, transferInfo, lastLoop) end, (1000 + PA.savedVars.Banking[PA.activeProfile].depositTimerInterval))
        end

        return remainingStackSize
    else
        PAHF.println("PAB_NoSpaceInFor", PAHF.getBagName(transferInfo["toBagId"]) , transferInfo["fromItemLink"])
        return -1
    end
end



-- =====================================================================================================================
-- =====================================================================================================================


-- returns a list of all item types in a bag
function PAB_Items.getItemTypeList(bagId)
    local itemTypeList = {}
    local bagSlots = GetBagSize(bagId)

    for slotIndex = 0, bagSlots - 1 do
        itemTypeList[slotIndex] = GetItemType(bagId, slotIndex)
    end

    return itemTypeList
end

-- returns a list of all item names in a bag
function PAB_Items.getItemNameList(bagId)
    local itemNameList = {}
    local bagSlots = GetBagSize(bagId)

    for slotIndex = 0, bagSlots - 1 do
        itemNameList[slotIndex] = GetItemName(bagId, slotIndex):upper()
    end

    return itemNameList
end