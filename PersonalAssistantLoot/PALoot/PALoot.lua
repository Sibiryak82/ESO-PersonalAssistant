--
-- Created by IntelliJ IDEA.
-- User: Klingo
-- Date: 06.02.2017
-- Time: 20:00
--

-- TODO
-- - handle Bait when looting (loot, loot'n'destroy, ignore)
-- - loot raw material from mobs

PAL.alreadyHarvesting = false
PAL.alreadyFishing = false

function PAL.OnReticleTargetChanged()
    -- check if addon is enabled
    if PA.savedVars.Loot[PA.savedVars.General.activeProfile].enabled then
        local type = GetInteractionType()
        local active = IsPlayerInteractingWithObject()
        local isHarvesting = (active and (type == INTERACTION_HARVEST))
        local isFishing = (active and (type == INTERACTION_FISH))

        if (PA.debug) then
            if (not isHarvesting and not isFishing) then
                if (type ~= INTERACTION_NONE) then
                    PAL.println("new interactionType=%s with %s", tostring(type), GetUnitNameHighlightedByReticle())
                end
            end
        end


        if (PAL.alreadyHarvesting) then
            if (not isHarvesting) then
                -- stopped harvesting
                PAL.alreadyHarvesting = false
                -- DEBUG
                if (PA.debug) then
                    PAL.println("isHarvesting=%s   type=%s", tostring(isHarvesting), tostring(type))
                end
            end
        else
            if (isHarvesting) then
                -- started harvesting
                PAL.alreadyHarvesting = true
                -- DEBUG
                if (PA.debug) then
                    PAL.println("isHarvesting=%s   type=%s", tostring(isHarvesting), tostring(type))
                end
            end
        end

        if (PAL.alreadyFishing) then
            if (not isFishing) then
                -- stopped fishing
                PAL.alreadyFishing = false
                -- DEBUG
                if (PA.debug) then
                    PAL.println("isFishing=%s   type=%s", tostring(isFishing), tostring(type))
                end
            end
        else
            if (isFishing) then
                -- started fishing
                PAL.alreadyFishing = true
                -- DEBUG
                if (PA.debug) then
                    PAL.println("isFishing=%s   type=%s", tostring(isFishing), tostring(type))
                end
            end
        end

    end
end

function PAL.OnLootUpdated()
    local activeProfile = PA.savedVars.General.activeProfile

    -- check if addon is enabled
    if PA.savedVars.Loot[activeProfile].enabled then
        -- check if ItemLoot is enabled
        if PA.savedVars.Loot[activeProfile].lootItems then
            -- check if we are harvesting, auto-loot is only used for this case!
            if (PAL.alreadyHarvesting or PAL.alreadyFishing) then
                -- get number of lootable items
                local lootCount =  GetNumLootItems()

                -- loop through all of them
                for i = 1, lootCount do
                    local lootId, _, icon, itemCount = GetLootItemInfo(i)
                    local itemLink = GetLootItemLink(lootId, LINK_STYLE_BRACKETS)
                    local itemType = GetItemLinkItemType(itemLink)
                    local strItemType = PALocale.getResourceMessage(itemType)

                    -- DEBUG
                    if (PA.debug) then
                        PAL.println("itemType (%s): %s.", itemType, strItemType)
                    end

                    -- TODO: also check for stolen???

                    for currItemType = 1, #PALHarvestableItemTypes do
                        -- check if the itemType is configured for auto-loot
                        if (PALHarvestableItemTypes[currItemType] == itemType) then
                            -- then check if it is set to Auto-Loot
                            if (PA.savedVars.Loot[activeProfile].HarvestableItemTypes[itemType] == PAC_ITEMTYPE_LOOT) then
                                -- Loot the item
                                LootItemById(lootId)
                                local iconString = "|t20:20:"..icon.."|t "

                                -- show output to chat (depending on setting)
                                local lootItemsChatMode = PA.savedVars.Loot[PA.savedVars.General.activeProfile].lootItemsChatMode
                                if (lootItemsChatMode == PA_OUTPUT_TYPE_FULL) then PAL.println(PALocale.getResourceMessage("PAL_Items_ChatMode_Full"), itemCount, itemLink, iconString)
                                elseif (lootItemsChatMode == PA_OUTPUT_TYPE_NORMAL) then PAL.println(PALocale.getResourceMessage("PAL_Items_ChatMode_Normal"), itemCount, itemLink, iconString)
                                elseif (lootItemsChatMode == PA_OUTPUT_TYPE_MIN) then PAL.println(PALocale.getResourceMessage("PAL_Items_ChatMode_Min"), itemCount, iconString)
                                end -- PA_OUTPUT_TYPE_NONE => no chat output
                            end
                            break
                        end
                    end
                end
            else
                -- DEBUG
                if (PA.debug) then
                    PAL.println("looting enemy? --> %s", GetUnitNameHighlightedByReticle())
                end
            end
        end

        -- check if GoldLoot is enabled
        if PA.savedVars.Loot[activeProfile].lootGold then
            -- is there even gold to loot?
            local unownedMoney = GetLootMoney()
            if (unownedMoney > 0) then
                -- Loot the gold
                LootMoney()

                -- show output to chat (depending on setting)
                local lootGoldChatMode = PA.savedVars.Loot[PA.savedVars.General.activeProfile].lootGoldChatMode
                if (lootGoldChatMode == PA_OUTPUT_TYPE_FULL) then PAL.println(PALocale.getResourceMessage("PAL_Gold_ChatMode_Full"), unownedMoney)
                elseif (lootGoldChatMode == PA_OUTPUT_TYPE_NORMAL) then PAL.println(PALocale.getResourceMessage("PAL_Gold_ChatMode_Normal"), unownedMoney)
                elseif (lootGoldChatMode == PA_OUTPUT_TYPE_MIN) then PAL.println(PALocale.getResourceMessage("PAL_Gold_ChatMode_Min"), unownedMoney)
                end -- PA_OUTPUT_TYPE_NONE => no chat output
            end
        end


        -- TODO: Loot other currencies:
        -- GetLootCurrency(number CurrencyType type)
        -- Returns: number unownedCurrency, number ownedCurrency

        -- LootCurrency(number CurrencyType type)

        -- CURT_ALLIANCE_POINTS
        -- CURT_MONEY
        -- CURT_NONE
        -- CURT_TELVAR_STONES
        -- CURT_WRIT_VOUCHERS

    end
end

function PAL.println(key, ...)
    local args = {...}
    PAHF.println(key, unpack(args))
end

