-- Local instances of Global tables --
local PA = PersonalAssistant

-- =====================================================================================================================
-- =====================================================================================================================

local registeredIdentifierSet = {}

local function addEventToSet(key)
    registeredIdentifierSet[key] = true
end

local function removeEventFromSet(key)
    registeredIdentifierSet[key] = nil
end

local function containsEventInSet(key)
    return registeredIdentifierSet[key] ~= nil
end

local function listAllEventsInSet()
    d("----------------------------------------------------")
    d("PA: listing all registered events")
    for key, value in pairs(registeredIdentifierSet) do
        -- d(key.."="..tostring(value))
        d(key)
    end
    d("----------------------------------------------------")
end


-- =====================================================================================================================
-- =====================================================================================================================


local function WaitForJunkProcessingToExecute(functionToExecute, firstCall)
    local PAEM = PA.EventManager
    if (PAEM.isJunkProcessing or firstCall) then
        -- still 'true', try again in 50 ms
        zo_callLater(function() WaitForJunkProcessingToExecute(functionToExecute, false) end, 50)
    else
        -- boolean is false, execute method now
        functionToExecute()
    end
end

--  Acts as a dispatcher between PARepair and PAJunk that both depend on [EVENT_OPEN_STORE]
local function SharedEventOpenStore()

    if (PAJ) then
        -- first execute PAJunk (to sell junk and get gold)
        PAJ.OnShopOpen()
    end

    local PAR = PersonalAssistant.Repair
    if (PAR) then
        -- only then execute PARepair (to spend gold for repairs)
        -- has to be done with some delay to get a proper update on the current gold amount from selling junk
        WaitForJunkProcessingToExecute(function() PAR.OnShopOpen() end, true)
    end
end

-- =====================================================================================================================
-- =====================================================================================================================


local function RegisterForEvent(addonName, ESOevent, executableFunction, paIdentifier)
    -- create esoIdentifier based on module/addonName and ESO event
    local esoIdentifier = ESOevent .. "_" .. addonName

    -- if a specific PA identifier was set, use this one as the ESO identifer
    if (paIdentifier ~= nil and paIdentifier ~= "") then esoIdentifier = ESOevent .. "_" .. paIdentifier end

    -- an event will only be registered with ESO, when the same identiifer is not yet registered
    if not containsEventInSet(esoIdentifier) then
        -- register the event with ESO
        EVENT_MANAGER:RegisterForEvent(esoIdentifier, ESOevent, executableFunction)
        -- and add it to PA's internal list of registered events
        addEventToSet(esoIdentifier)
    end
end


local function UnregisterForEvent(addonName, ESOevent, paIdentifier)
    -- create esoIdentifier based on addonName and ESO event
    local esoIdentifier = ESOevent .. "_" .. addonName

    -- if a specific PA identifier was set, use this one as the ESO identifer
    if (paIdentifier ~= nil and paIdentifier ~= "") then esoIdentifier = ESOevent .. "_" .. paIdentifier end

    -- unregister the event from ESO
    EVENT_MANAGER:UnregisterForEvent(esoIdentifier, ESOevent)
    -- and remove it from PA's internal list of registered events
    removeEventFromSet(esoIdentifier)
end



local function RefreshAllEventRegistrations()
    local PAMenuFunctions = PA.MenuFunctions
    local PAR = PA.Repair
    local PAB = PA.Banking
    local PAL = PA.Loot
    local PAJ = PA.Junk


    -- Check if the Addon 'PARepair' is even enabled
    if (PAR) then
        -- Check if the functionality is turned on within the addon
        if (PAMenuFunctions.PARepair.isEnabled()) then
            -- Register PARepair for RepairKits and WeaponCharges
            RegisterForEvent(PAR.AddonName, EVENT_PLAYER_COMBAT_STATE, PAR.EventPlayerCombateState)
            -- Register PARepair (in correspondance with PAJunk)
            RegisterForEvent(PAR.AddonName, EVENT_OPEN_STORE, SharedEventOpenStore, "RepairJunkSharedEvent")
        else
            -- Unregister PARepair
            UnregisterForEvent(PAR.AddonName, EVENT_PLAYER_COMBAT_STATE)
            -- Unregister the SharedEvent, but only if PAJunk is not enabled!
            if not (PAJ and PAMenuFunctions.PAJunk.isEnabled()) then
                UnregisterForEvent(PAR.AddonName, EVENT_OPEN_STORE, "RepairJunkSharedEvent")
            end
        end
    end

    -- Check if the Addon 'PABanking' is even enabled
    if (PAB) then
        -- Check if the functionality is turned on within the addon
        if (PAMenuFunctions.PABanking.isEnabled()) then
            -- Register PABanking
            RegisterForEvent(PAB.AddonName, EVENT_OPEN_BANK, PAB.OnBankOpen)
            RegisterForEvent(PAB.AddonName, EVENT_CLOSE_BANK, PAB.OnBankClose)
        else
            -- Unregister PABanking
            UnregisterForEvent(PAB.AddonName, EVENT_OPEN_BANK)
            UnregisterForEvent(PAB.AddonName, EVENT_CLOSE_BANK)
        end
    end


    -- Check if the Addon 'PAloot' is even enabled
    if (PAL) then
        -- Check if the functionality is turned on within the addon
        if (PAMenuFunctions.PALoot.isEnabled()) then
            -- Register PALoot
            RegisterForEvent(PAL.AddonName, EVENT_LOOT_UPDATED, PAL.OnLootUpdated)
            RegisterForEvent(PAL.AddonName, EVENT_INVENTORY_SINGLE_SLOT_UPDATE, PAL.OnInventorySingleSlotUpdate)
            ZO_PreHookHandler(RETICLE.interact, "OnEffectivelyShown", PAL.OnReticleTargetChanged)
        else
            -- Unregister PALoot
            UnregisterForEvent(PAL.AddonName, EVENT_LOOT_UPDATED)
            UnregisterForEvent(PAL.AddonName, EVENT_INVENTORY_SINGLE_SLOT_UPDATE)
            ZO_PreHookHandler(RETICLE.interact, "OnEffectivelyShown", nil)
        end
    end


    -- Check if the Addon 'PAJunk' is even enabled
    if (PAJ) then
        -- Check if the functionality is turned on within the addon
        if (PAMenuFunctions.PAJunk.isEnabled()) then
            -- Register PAJunk for looting junk items
            RegisterForEvent(PAJ.AddonName, EVENT_INVENTORY_SINGLE_SLOT_UPDATE, PAJ.OnInventorySingleSlotUpdate)
            -- Register PAJunk (in correspondance with PARepair)
            RegisterForEvent(PAJ.AddonName, EVENT_OPEN_STORE, SharedEventOpenStore, "RepairJunkSharedEvent")
        else
            -- Unegister PAJunk
            UnregisterForEvent(PAJ.AddonName, EVENT_INVENTORY_SINGLE_SLOT_UPDATE)
            -- Unregister the SharedEvent, but only if PARepair is not enabled!
            if not (PAR and PAMenuFunctions.PARepair.isEnabled()) then
                UnregisterForEvent(PAJ.AddonName, EVENT_OPEN_STORE, "RepairJunkSharedEvent")
            end
        end
    end
end

-- =====================================================================================================================
-- =====================================================================================================================

PersonalAssistant.EventManager = {
    listAllEventsInSet = listAllEventsInSet,
    RegisterForEvent = RegisterForEvent,
    UnregisterForEvent = UnregisterForEvent,
    RefreshAllEventRegistrations = RefreshAllEventRegistrations,
    isJunkProcessing = false,
}