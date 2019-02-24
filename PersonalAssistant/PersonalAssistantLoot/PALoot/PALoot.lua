-- Local instances of Global tables --
local PA = PersonalAssistant
local PAC = PA.Constants
local PASV = PA.SavedVars
local PAHF = PA.HelperFunctions

-- ---------------------------------------------------------------------------------------------------------------------

local TraitIndexFromItemTraitType = {
    [ITEM_TRAIT_TYPE_WEAPON_POWERED] = 1,       -- 1
    [ITEM_TRAIT_TYPE_WEAPON_CHARGED] = 2,       -- 2
    [ITEM_TRAIT_TYPE_WEAPON_PRECISE] = 3,       -- 3
    [ITEM_TRAIT_TYPE_WEAPON_INFUSED] = 4,       -- 4
    [ITEM_TRAIT_TYPE_WEAPON_DEFENDING] = 5,     -- 5
    [ITEM_TRAIT_TYPE_WEAPON_TRAINING] = 6,      -- 6
    [ITEM_TRAIT_TYPE_WEAPON_SHARPENED] = 7,     -- 7
    [ITEM_TRAIT_TYPE_WEAPON_DECISIVE] = 8,      -- 8
    [ITEM_TRAIT_TYPE_WEAPON_WEIGHTED] = 8,      -- 8
    [ITEM_TRAIT_TYPE_WEAPON_NIRNHONED] = 9,     -- 26
    [ITEM_TRAIT_TYPE_WEAPON_INTRICATE] = nil,   -- 9
    [ITEM_TRAIT_TYPE_WEAPON_ORNATE] = nil,      -- 10

    [ITEM_TRAIT_TYPE_ARMOR_STURDY] = 1,         -- 11
    [ITEM_TRAIT_TYPE_ARMOR_IMPENETRABLE] = 2,   -- 12
    [ITEM_TRAIT_TYPE_ARMOR_REINFORCED] = 3,     -- 13
    [ITEM_TRAIT_TYPE_ARMOR_WELL_FITTED] = 4,    -- 14
    [ITEM_TRAIT_TYPE_ARMOR_TRAINING] = 5,       -- 15
    [ITEM_TRAIT_TYPE_ARMOR_INFUSED] = 6,        -- 16
    [ITEM_TRAIT_TYPE_ARMOR_EXPLORATION] = 7,    -- 17
    [ITEM_TRAIT_TYPE_ARMOR_PROSPEROUS] = 7,     -- 17
    [ITEM_TRAIT_TYPE_ARMOR_DIVINES] = 8,        -- 18
    [ITEM_TRAIT_TYPE_ARMOR_NIRNHONED] = 9,      -- 25
    [ITEM_TRAIT_TYPE_ARMOR_INTRICATE] = nil,    -- 20
    [ITEM_TRAIT_TYPE_ARMOR_ORNATE] = nil,       -- 19

    [ITEM_TRAIT_TYPE_JEWELRY_ARCANE] = 1,       -- 22
    [ITEM_TRAIT_TYPE_JEWELRY_HEALTHY] = 2,      -- 21
    [ITEM_TRAIT_TYPE_JEWELRY_ROBUST] = 3,       -- 23
    [ITEM_TRAIT_TYPE_JEWELRY_TRIUNE] = 4,       -- 30
    [ITEM_TRAIT_TYPE_JEWELRY_INFUSED] = 5,      -- 33
    [ITEM_TRAIT_TYPE_JEWELRY_PROTECTIVE] = 6,   -- 32
    [ITEM_TRAIT_TYPE_JEWELRY_SWIFT] = 7,        -- 28
    [ITEM_TRAIT_TYPE_JEWELRY_HARMONY] = 8,      -- 29
    [ITEM_TRAIT_TYPE_JEWELRY_BLOODTHIRSTY] = 9, -- 31
    [ITEM_TRAIT_TYPE_JEWELRY_INTRICATE] = nil,  -- 27
    [ITEM_TRAIT_TYPE_JEWELRY_ORNATE] = nil,     -- 24
}

local CLOTHIER = CRAFTING_TYPE_CLOTHIER
local WOODWORKING = CRAFTING_TYPE_WOODWORKING
local BLACKSMITHING = CRAFTING_TYPE_BLACKSMITHING
local JEWELCRAFTING = CRAFTING_TYPE_JEWELRYCRAFTING

local ResearchLineIndexFromType = {
    [CLOTHIER] = {
        ARMOR =  {
            -- add +7 for "Medium" armor (instead of "Light")
            [EQUIP_TYPE_CHEST] = 1,             -- 3
            [EQUIP_TYPE_FEET] = 2,              -- 10
            [EQUIP_TYPE_HAND] = 3,              -- 13
            [EQUIP_TYPE_HEAD] = 4,              -- 1
            [EQUIP_TYPE_LEGS] = 5,              -- 9
            [EQUIP_TYPE_SHOULDERS] = 6,         -- 4
            [EQUIP_TYPE_WAIST] = 7,             -- 8
        },
    },
    [WOODWORKING] = {
        WEAPON = {
            [WEAPONTYPE_BOW] = 1,               -- 8
            [WEAPONTYPE_FIRE_STAFF] = 2,        -- 12
            [WEAPONTYPE_FROST_STAFF] = 3,       -- 13
            [WEAPONTYPE_LIGHTNING_STAFF] = 4,   -- 15
            [WEAPONTYPE_HEALING_STAFF] = 5,     -- 9
        },
        ARMOR = {
            [EQUIP_TYPE_OFF_HAND] = 6,          -- 7
        },
    },
    [BLACKSMITHING] = {
        WEAPON = {
            [WEAPONTYPE_AXE] = 1,               -- 1
            [WEAPONTYPE_HAMMER] = 2,            -- 2
            [WEAPONTYPE_SWORD] = 3,             -- 3
            [WEAPONTYPE_TWO_HANDED_AXE] = 4,    -- 5
            [WEAPONTYPE_TWO_HANDED_HAMMER] = 5, -- 6
            [WEAPONTYPE_TWO_HANDED_SWORD] = 6,  -- 4
            [WEAPONTYPE_DAGGER] = 7,            -- 11
        },
        ARMOR = {
            [EQUIP_TYPE_CHEST] = 8,             -- 3
            [EQUIP_TYPE_FEET] = 9,              -- 10
            [EQUIP_TYPE_HAND] = 10,             -- 13
            [EQUIP_TYPE_HEAD] = 11,             -- 1
            [EQUIP_TYPE_LEGS] = 12,             -- 9
            [EQUIP_TYPE_SHOULDERS] = 13,        -- 4
            [EQUIP_TYPE_WAIST] = 14,            -- 8
        }
    },
    [JEWELCRAFTING] = {
        ARMOR = {
            [EQUIP_TYPE_NECK] = 1,              -- 2
            [EQUIP_TYPE_RING] = 2,              -- 12
        },
    },
}

local function GetResearchLineIndexFromItemLink(itemLink)

end


-- ---------------------------------------------------------------------------------------------------------------------

-- TODO: check if maybe still needed later?
local function DestroyNumOfItems(bagId, slotId, amountToDestroy)
    local itemDestroyed = false
    -- create the itemlink of the to be destroyed item
    local itemLink = GetItemLink(bagId, slotId, LINK_STYLE_BRACKETS)
    local icon = GetItemLinkInfo(itemLink)
    local iconString = "|t20:20:" .. icon .. "|t "
    -- get the current size of item stack
    local stackSize = GetSlotStackSize(bagId, slotId)
    -- check if there were items before
    if (stackSize > amountToDestroy) then
        -- there already was a stack existing in the inventory, we shall only delete the new items
        local firstEmptySlot = FindFirstEmptySlotInBag(bagId)
        if (firstEmptySlot ~= nil) then
            -- there is a free slot to split the stack, go ahead!
            local result = CallSecureProtected("RequestMoveItem", bagId, slotId, bagId, firstEmptySlot, amountToDestroy)

            -- give it some time to actually move the item
            zo_callLater(function()
                if (result) then
                    -- item successfully moved to new empty stlot, destroy that now
                    DestroyItem(bagId, firstEmptySlot)
                    itemDestroyed = true
                else
                    -- could not move items, therefore cannot safely destroy item
                    PAHF.println(SI_PA_LOOT_ITEMS_DESTROYED_FAILED_MOVE, amountToDestroy, stackSize, itemLink, iconString)
                end
            end, 500)
        else
            -- no free slot available, cannot safely destroy item!
            PAHF.println(SI_PA_LOOT_ITEMS_DESTROYED_FAILED_DESTORY, amountToDestroy, stackSize, itemLink, iconString)
        end
    else
        -- destroy all items (since there were no existing before)
        DestroyItem(bagId, slotId)
        itemDestroyed = true
    end

    if (itemDestroyed) then
        PAHF_DEBUG.debugln("Item destroyed --> %d x %s      %d should remain in inventory", amountToDestroy, itemLink, stackSize - amountToDestroy)
        local lootItemsChatMode = PA.savedVars.Loot[PA.activeProfile].lootItemsChatMode
        if (lootItemsChatMode == PAC.CHATMODE.OUTPUT_MAX) then PAHF.println(SI_PA_LOOT_ITEMS_DESTROYED_CHATMODE_MAX, amountToDestroy, itemLink, iconString)
        elseif (lootItemsChatMode == PAC.CHATMODE.OUTPUT_NORMAL) then PAHF.println(SI_PA_LOOT_ITEMS_DESTROYED_CHATMODE_NORMAL, amountToDestroy, itemLink, iconString)
        elseif (lootItemsChatMode == PAC.CHATMODE.OUTPUT_MIN) then PAHF.println(SI_PA_LOOT_ITEMS_DESTROYED_CHATMODE_MIN, amountToDestroy, iconString)
        end -- PAC.CHATMODE.OUTPUT_NONE => no chat output
    end
end


local function OnInventorySingleSlotUpdate(eventCode, bagId, slotIndex, isNewItem, itemSoundCategory, inventoryUpdateReason, stackCountChange)
    if (PAHF.hasActiveProfile()) then
        local PALootSavedVars = PASV.Loot[PA.activeProfile]

        -- check if addon is enabled
        if PALootSavedVars.enabled then

            local itemLink = GetItemLink(bagId, slotIndex, LINK_STYLE_BRACKETS)
            local itemType, specializedItemType = GetItemType(bagId, slotIndex)

            local canBeResearched = CanItemLinkBeTraitResearched(itemLink)

            if itemType == ITEMTYPE_RECIPE then
                local isRecipeKnown = IsItemLinkRecipeKnown(itemLink)
                if not isRecipeKnown then
                    PAHF.println("UNKNOWN recipe looted: %s", itemLink)
                else
                    PAHF.println("known recipe looted: %s", itemLink)
                end
            end

            if canBeResearched then
                PAHF.println("UNKNOWN trait looted: %s", itemLink)

                local tradeskillType = GetItemLinkCraftingSkillType(itemLink)
                local numLines = GetNumSmithingResearchLines(tradeskillType)
                local traitType, traitDescription = GetItemLinkTraitInfo(itemLink)
                local craftingType, researchLineName = GetRearchLineInfoFromRetraitItem(bagId, slotIndex)
                d("canBeResearched="..tostring(canBeResearched))
                d("tradeskillType="..tostring(tradeskillType))
                d("numLines="..tostring(numLines))
                d("traitType="..tostring(traitType))
                d("traitName="..GetString("SI_ITEMTRAITTYPE", traitType))
                d("traitDescription="..tostring(traitDescription))
                d("craftingType="..tostring(craftingType))
                d("researchLineName="..tostring(researchLineName))
            else
            end



--            Search on ESOUI Source Code IsItemLinkRecipeKnown(string itemLink)
--            Returns: boolean isRecipeKnown



--            GetItemTrait(number Bag bagId, number slotIndex)
--            Returns: number ItemTraitType trait
--
--            GetItemLinkTraitInfo(string itemLink)
--            Returns: number ItemTraitType traitType, string traitDescription
--
--            GetItemTraitInformation(number Bag bagId, number slotIndex)
--            Returns: number ItemTraitInformation itemTraitInformation
--
--            GetItemTraitInformationFromItemLink(string itemLink)
--            Returns: number ItemTraitInformation itemTraitInformation
--
--
--
--
--            CanItemLinkBeTraitResearched(string itemLink)
--            Returns: boolean canBeResearched
--
--
--
--            ResearchSmithingTrait(number Bag bagId, number slotIndex)
--
--
--
--            GetItemLinkCraftingSkillType(string itemLink)
--            Returns: number TradeskillType tradeskillType
--
--            GetItemCraftingInfo(number Bag bagId, number slotIndex)
--            Returns: number TradeskillType usedInCraftingType, number ItemType itemType, number:nilable extraInfo1, number:nilable extraInfo2, number:nilable extraInfo3
--
--            GetNumSmithingResearchLines(number TradeskillType craftingSkillType)
--            Returns: number numLines
--
--            GetSmithingResearchLineTraitInfo(number TradeskillType craftingSkillType, number researchLineIndex, number traitIndex)
--            Returns: number ItemTraitType traitType, string traitDescription, boolean known
--
--
--
--
--            GetCraftingSkillName(number TradeskillType craftingSkillType)
--            Returns: string name

            --            -- check if ItemLoot is enabled
--            if PA.savedVars.Loot[PA.activeProfile].lootItems then
--                -- check if the updated happened in the backpack
--                if (bagId == BAG_BACKPACK) then
--                    -- only proceed if the update was triggered while harvesting (i.e. not from looting chests, wasps, mobs, etc)
--                    if (alreadyHarvesting) then
--                        -- get the itemType
--                        local itemType = GetItemType(BAG_BACKPACK, slotId)
--                        -- check if it is bait, and if bait is set to be destroyed
--                        if ((itemType == ITEMTYPE_LURE) and (PAMenu_Functions.getFunc.PALoot.harvestableBaitLootMode() == PAC_ITEMTYPE_DESTROY)) then
--                            DestroyNumOfItems(BAG_BACKPACK, slotId, stackCountChange)
--                        end
--                    end
--                end
--            end
        end
    end
end


-- ---------------------------------------------------------------------------------------------------------------------
-- Export
PA.Loot = PA.Loot or {}
PA.Loot.TraitIndexFromItemTraitType = TraitIndexFromItemTraitType
PA.Loot.OnInventorySingleSlotUpdate = OnInventorySingleSlotUpdate