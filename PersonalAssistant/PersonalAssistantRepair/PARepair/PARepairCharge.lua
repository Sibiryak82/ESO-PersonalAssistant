-- Local instances of Global tables --
local PA = PersonalAssistant
local PAC = PA.Constants
local PASV = PA.SavedVars
local PAHF = PA.HelperFunctions

-- ---------------------------------------------------------------------------------------------------------------------

local function _getSoulGemsIn(bagId)
    local bagCache = SHARED_INVENTORY:GetOrCreateBagCache(bagId) -- TODO: updateto use soul-gem filtertpye
    local gemTable = setmetatable({}, { __index = table })
    local totalGemCount = 0

    -- create a table with all soulgems
    for _, data in pairs(bagCache) do
        -- check if it is a filled soulGem
        if (IsItemSoulGem(SOUL_GEM_TYPE_FILLED, data.bagId, data.slotIndex)) then
            gemTable:insert({
                bagId = data.bagId,
                slotIndex = data.slotIndex,
                itemName = data.name,
                itemLink = GetItemLink(data.bagId, data.slotIndex, LINK_STYLE_BRACKETS),
--                stackCount = data.stackCount,
                gemTier = GetSoulGemItemInfo(data.bagId, data.slotIndex),
                iconString = "|t20:20:"..data.iconFile.."|t ",
            })
            -- update the total gem count
            totalGemCount = totalGemCount + data.stackCount
        end
    end

    -- sort table based on the gemTiers
    table.sort(gemTable, function(a, b) return a.gemTier > b.gemTier end)

    return gemTable, totalGemCount
end

-- ---------------------------------------------------------------------------------------------------------------------

local function ReChargeWeapons()

    local PARepairSavedVars = PASV.Repair[PA.activeProfile]

    -- Check and re-charged equipped weapons
    if PARepairSavedVars.RechargeWeapons.useSoulGems then

        PAHF.debugln("Check for Weapon Recharge")

        local chargeThreshold = PARepairSavedVars.RechargeWeapons.chargeWeaponsThreshold
        local weaponsToCharge = setmetatable({}, { __index = table })

        -- based on the list of chargeable slots, check which ones really need to be charged
        for _, weaponSlot in pairs(PAC.REPAIR.WEAPON_SLOTS) do
            local charges, maxCharges = GetChargeInfoForItem(BAG_WORN, weaponSlot)
            local chargePerc = PAHF.round(100 / maxCharges * charges, 2)

            -- check if charge level of item is below threshold
            if ((chargePerc) <= chargeThreshold) then
                local itemLink = GetItemLink(BAG_WORN, weaponSlot, LINK_STYLE_BRACKETS)
                local iconString = "|t20:20:"..GetItemLinkInfo(itemLink).."|t "
                weaponsToCharge:insert({weaponSlot = weaponSlot, charges = charges, maxCharges = maxCharges, chargePerc = chargePerc, itemLink = itemLink , iconString = iconString})
            end
        end

        -- are there weapons to charge?
        if (#weaponsToCharge > 0) then
            local gemTable, totalGemCount = _getSoulGemsIn(BAG_BACKPACK)

            -- from the list of actually to be charged weapons, charge them
            for _, weapon in pairs(weaponsToCharge) do

                -- are there gems to be used for charging?
                if (totalGemCount > 0) then
                    -- collect some additional information
                    local chargeableAmount = GetAmountSoulGemWouldChargeItem(BAG_WORN, weapon.weaponSlot, BAG_BACKPACK, gemTable[#gemTable].slotIndex)
                    local finalChargesPerc = 100
                    if ((weapon.charges + chargeableAmount) < weapon.maxCharges) then
                        finalChargesPerc = PAHF.round(100 / weapon.maxCharges * (weapon.charges + chargeableAmount))
                    end

                    -- some debug information
                    PAHF.debugln("Want to charge: %s with: %s for %d from currently: %d/%d", GetItemName(BAG_WORN, weapon.weaponSlot), gemTable[#gemTable].itemName, chargeableAmount, weapon.charges, weapon.maxCharges)

                    -- actually charge the item
                    d(GetItemName(gemTable[#gemTable].bagId, gemTable[#gemTable].slotIndex))
                    d(GetItemName(BAG_WORN, weapon.weaponSlot))
                    ChargeItemWithSoulGem(BAG_WORN, weapon.weaponSlot, gemTable[#gemTable].bagId, gemTable[#gemTable].slotIndex)
                    totalGemCount = totalGemCount - 1

                    -- show output to chat (depending on setting)
                    local chargeWeaponsChatMode = PARepairSavedVars.RechargeWeapons.chargeWeaponsChatMode
                    if (chargeWeaponsChatMode == PA_OUTPUT_TYPE_FULL) then PAHF.println(GetString(SI_PA_REPAIR_CHARGE_CHATMODE_MAX), weapon.iconString, weapon.itemLink, weapon.chargePerc, finalChargesPerc, gemTable[#gemTable].iconString, gemTable[#gemTable].itemLink)
                    elseif (chargeWeaponsChatMode == PA_OUTPUT_TYPE_NORMAL) then PAHF.println(GetString(SI_PA_REPAIR_CHARGE_CHATMODE_NORMAL), weapon.itemLink, weapon.chargePerc, finalChargesPerc, gemTable[#gemTable].itemLink)
                    elseif (chargeWeaponsChatMode == PA_OUTPUT_TYPE_MIN) then PAHF.println(GetString(SI_PA_REPAIR_CHARGE_CHATMODE_MIN), gemTable[#gemTable].iconString, weapon.iconString, weapon.chargePerc, finalChargesPerc)
                    end -- PA_OUTPUT_TYPE_NONE => no chat output

                    if (totalGemCount < 10) then
                        -- TODO: low gem count warning
                        -- TODO: replace '10' with savedVars setting
                    end
                else
                    -- TODO: message about no more gems available
                    -- TODO: warn only every X minutes
                end
            end
        end
    end
end

-- Export
PA.Repair = PA.Repair or {}
PA.Repair.ReChargeWeapons = ReChargeWeapons