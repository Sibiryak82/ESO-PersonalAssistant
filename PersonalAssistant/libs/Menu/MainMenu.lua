PA_SettingsMenu = {}

local LAM2 = LibStub("LibAddonMenu-2.0")

local panelData = {
    type = "panel",
    name = "PersonalAssistant",
    displayName = PALocale.getResourceMessage("MMenu_Title"),
    author = "Klingo",
    version = PA.AddonVersion,
    website = "http://www.esoui.com/downloads/info381-PersonalAssistant",
    slashCommand = "/pa",
    registerForRefresh  = true,
    registerForDefaults = true,
}

local optionsTable = setmetatable({}, { __index = table })
local PABItemTypeMaterialSubmenuTable = setmetatable({}, { __index = table })
local PABItemTypeSubmenuTable = setmetatable({}, { __index = table })
local PABItemTypeAdvancedSubmenuTable = setmetatable({}, { __index = table })
local PALHarvestableItemSubmenuTable = setmetatable({}, { __index = table })
local PALLootableItemSubmenuTable = setmetatable({}, { __index = table })


function PA_SettingsMenu.CreateOptions()

    -- create main- and submenus with LAM-2
    PA_SettingsMenu.createPABItemTypeMaterialSubmenuTable()
    PA_SettingsMenu.createPABItemSubMenu()
    PA_SettingsMenu.createPABItemAdvancedSubMenu()
    PA_SettingsMenu.createPALHarvestableItemSubMenu()
    PA_SettingsMenu.createPALLootableItemSubMenu()
    PA_SettingsMenu.createMainMenu()

    -- and register it
    LAM2:RegisterAddonPanel("PersonalAssistantAddonOptions", panelData)
    LAM2:RegisterOptionControls("PersonalAssistantAddonOptions", optionsTable)
end


function PA_SettingsMenu.createMainMenu()

    optionsTable:insert({
        type = "header",
        name = PALocale.getResourceMessage("PAGMenu_Header"),
    })

    optionsTable:insert({
        type = "dropdown",
        name = PALocale.getResourceMessage("PAGMenu_ActiveProfile"),
        tooltip = PALocale.getResourceMessage("PAGMenu_ActiveProfile_T"),
        choices = MenuHelper.getProfileList(),
        choicesValues = MenuHelper.getProfileListValues(),
        getFunc = PAMenu_Functions.getFunc.PAGeneral.activeProfile,
        setFunc = PAMenu_Functions.setFunc.PAGeneral.activeProfile,
        width = "half",
        reference = "PERSONALASSISTANT_PROFILEDROPDOWN",
    })

    optionsTable:insert({
        type = "editbox",
        name = PALocale.getResourceMessage("PAGMenu_ActiveProfileRename"),
        tooltip = PALocale.getResourceMessage("PAGMenu_ActiveProfileRename_T"),
        getFunc = PAMenu_Functions.getFunc.PAGeneral.activeProfileRename,
        setFunc = PAMenu_Functions.setFunc.PAGeneral.activeProfileRename,
        width = "half",
        disabled = PAMenu_Functions.disabled.PAGeneral.noProfileSelected,
    })

    optionsTable:insert({
        type = "checkbox",
        name = PALocale.getResourceMessage("PAGMenu_Welcome"),
        tooltip = PALocale.getResourceMessage("PAGMenu_Welcome_T"),
        getFunc = PAMenu_Functions.getFunc.PAGeneral.welcomeMessage,
        setFunc = PAMenu_Functions.setFunc.PAGeneral.welcomeMessage,
        disabled = PAMenu_Functions.disabled.PAGeneral.noProfileSelected,
        default = PAMenu_Defaults.defaultSettings.PAGeneral.welcomeMessage,
    })

    -- =================================================================================================================

    if (PAR) then
        -- ------------------------ --
        -- PersonalAssistant Repair --
        -- ------------------------ --
        optionsTable:insert({
            type = "header",
            name = PALocale.getResourceMessage("PARMenu_Header"),
        })

        optionsTable:insert({
            type = "checkbox",
            name = PALocale.getResourceMessage("PARMenu_Enable"),
            tooltip = PALocale.getResourceMessage("PARMenu_Enable_T"),
            getFunc = PAMenu_Functions.getFunc.PARepair.enabled,
            setFunc = PAMenu_Functions.setFunc.PARepair.enabled,
            disabled = PAMenu_Functions.disabled.PAGeneral.noProfileSelected,
            default = PAMenu_Defaults.defaultSettings.PARepair.enabled,
        })

        optionsTable:insert({
            type = "checkbox",
            name = PALocale.getResourceMessage("PARMenu_RepairWornGold"),
            tooltip = PALocale.getResourceMessage("PARMenu_RepairWornGold_T"),
            getFunc = PAMenu_Functions.getFunc.PARepair.repairEquipped,
            setFunc = PAMenu_Functions.setFunc.PARepair.repairEquipped,
            width = "half",
            disabled = PAMenu_Functions.disabled.PARepair.repairEquipped,
            default = PAMenu_Defaults.defaultSettings.PARepair.repairEquipped,
        })

        optionsTable:insert({
            type = "slider",
            name = PALocale.getResourceMessage("PARMenu_RepairWornGoldDura"),
            tooltip = PALocale.getResourceMessage("PARMenu_RepairWornGoldDura_T"),
            min = 0,
            max = 99,
            step = 1,
            getFunc = PAMenu_Functions.getFunc.PARepair.repairEquippedThreshold,
            setFunc = PAMenu_Functions.setFunc.PARepair.repairEquippedThreshold,
            width = "half",
            disabled = PAMenu_Functions.disabled.PARepair.repairEquippedThreshold,
            default = PAMenu_Defaults.defaultSettings.PARepair.repairEquppedThreshold,
        })

        optionsTable:insert({
            type = "checkbox",
            name = PALocale.getResourceMessage("PARMenu_RepairWornKit"),
            tooltip = PALocale.getResourceMessage("PARMenu_RepairWornKit_T"),
            getFunc = PAMenu_Functions.getFunc.PARepair.repairEquippedWithKit,
            setFunc = PAMenu_Functions.setFunc.PARepair.repairEquippedWithKit,
            width = "half",
            disabled = PAMenu_Functions.disabled.PARepair.repairEquippedWithKit,
            default = PAMenu_Defaults.defaultSettings.PARepair.repairEquippedWithKit,
        })

        optionsTable:insert({
            type = "slider",
            name = PALocale.getResourceMessage("PARMenu_RepairWornKitDura"),
            tooltip = PALocale.getResourceMessage("PARMenu_RepairWornKitDura_T"),
            min = 0,
            max = 99,
            step = 1,
            getFunc = PAMenu_Functions.getFunc.PARepair.repairEquippedWithKitThreshold,
            setFunc = PAMenu_Functions.setFunc.PARepair.repairEquippedWithKitThreshold,
            width = "half",
            disabled = PAMenu_Functions.disabled.PARepair.repairEquippedWithKitThreshold,
            default = PAMenu_Defaults.defaultSettings.PARepair.repairEquippedWithKitThreshold,
        })

        optionsTable:insert({
            type = "dropdown",
            name = PALocale.getResourceMessage("PARMenu_RepairFullChatMode"),
            tooltip = PALocale.getResourceMessage("PARMenu_RepairFullChatMode_T"),
            choices = PAMenu_Choices.choices.PARepair.repairFullChatMode,
            choicesValues = PAMenu_Choices.choicesValues.PARepair.repairFullChatMode,
            getFunc = PAMenu_Functions.getFunc.PARepair.repairFullChatMode,
            setFunc = PAMenu_Functions.setFunc.PARepair.repairFullChatMode,
            width = "half",
            disabled = PAMenu_Functions.disabled.PARepair.repairFullChatMode,
            default = PAMenu_Defaults.defaultSettings.PARepair.repairFullChatMode,
        })

        optionsTable:insert({
            type = "dropdown",
            name = PALocale.getResourceMessage("PARMenu_RepairPartialChatMode"),
            tooltip = PALocale.getResourceMessage("PARMenu_RepairPartialChatMode_T"),
            choices = PAMenu_Choices.choices.PARepair.repairPartialChatMode,
            choicesValues = PAMenu_Choices.choicesValues.PARepair.repairPartialChatMode,
            getFunc = PAMenu_Functions.getFunc.PARepair.repairPartialChatMode,
            setFunc = PAMenu_Functions.setFunc.PARepair.repairPartialChatMode,
            width = "half",
            disabled = PAMenu_Functions.disabled.PARepair.repairPartialChatMode,
            default = PAMenu_Defaults.defaultSettings.PARepair.repairPartialChatMode,
        })

        optionsTable:insert({
            type = "divider",
            alpha = 0.5,
        })

        optionsTable:insert({
            type = "checkbox",
            name = PALocale.getResourceMessage("PARMenu_ChargeWeapons"),
            tooltip = PALocale.getResourceMessage("PARMenu_ChargeWeapons_T"),
            getFunc = PAMenu_Functions.getFunc.PARepair.chargeWeapons,
            setFunc = PAMenu_Functions.setFunc.PARepair.chargeWeapons,
            width = "half",
            disabled = PAMenu_Functions.disabled.PARepair.chargeWeapons,
            default = PAMenu_Defaults.defaultSettings.PARepair.chargeWeapons,
        })

        optionsTable:insert({
            type = "slider",
            name = PALocale.getResourceMessage("PARMenu_ChargeWeaponsDura"),
            tooltip = PALocale.getResourceMessage("PARMenu_ChargeWeaponsDura_T"),
            min = 0,
            max = 99,
            step = 1,
            getFunc = PAMenu_Functions.getFunc.PARepair.chargeWeaponsThreshold,
            setFunc = PAMenu_Functions.setFunc.PARepair.chargeWeaponsThreshold,
            width = "half",
            disabled = PAMenu_Functions.disabled.PARepair.chargeWeaponsThreshold,
            default = PAMenu_Defaults.defaultSettings.PARepair.chargeWeaponsThreshold,
        })

    end

    -- =================================================================================================================

    if (PAB) then
        -- ------------------------- --
        -- PersonalAssistant Banking --
        -- ------------------------- --
        optionsTable:insert({
            type = "header",
            name = PALocale.getResourceMessage("PABMenu_Header"),
        })

        optionsTable:insert({
            type = "checkbox",
            name = PALocale.getResourceMessage("PABMenu_Enable"),
            tooltip = PALocale.getResourceMessage("PABMenu_Enable_T"),
            getFunc = PAMenu_Functions.getFunc.PABanking.enabled,
            setFunc = PAMenu_Functions.setFunc.PABanking.enabled,
            disabled = PAMenu_Functions.disabled.PAGeneral.noProfileSelected,
            default = PAMenu_Defaults.defaultSettings.PABanking.enabled,
        })

        optionsTable:insert({
            type = "checkbox",
            name = PALocale.getResourceMessage("PABMenu_EnabledGold"),
            tooltip = PALocale.getResourceMessage("PABMenu_EnabledGold_T"),
            getFunc = PAMenu_Functions.getFunc.PABanking.enabledGold,
            setFunc = PAMenu_Functions.setFunc.PABanking.enabledGold,
            disabled = PAMenu_Functions.disabled.PABanking.enabledGold,
            default = PAMenu_Defaults.defaultSettings.PABanking.enabledGold,
        })

        -- enabledGoldChatMode

        optionsTable:insert({
            type = "dropdown",
            name = PALocale.getResourceMessage("PABMenu_GoldTransactionStep"),
            tooltip = PALocale.getResourceMessage("PABMenu_GoldTransactionStep_T"),
            choices = PAMenu_Choices.choices.PABanking.goldTransactionStep,
            choicesValues = PAMenu_Choices.choicesValues.PABanking.goldTransactionStep,
            getFunc = PAMenu_Functions.getFunc.PABanking.goldTransactionStep,
            setFunc = PAMenu_Functions.setFunc.PABanking.goldTransactionStep,
            disabled = PAMenu_Functions.disabled.PABanking.goldTransactionStep,
            default = PAMenu_Defaults.defaultSettings.PABanking.goldTransactionStep,
        })

        optionsTable:insert({
            type = "editbox",
            name = PALocale.getResourceMessage("PABMenu_GoldMinToKeep"),
            tooltip = PALocale.getResourceMessage("PABMenu_GoldMinToKeep_T"),
            getFunc = PAMenu_Functions.getFunc.PABanking.goldMinToKeep,
            setFunc = PAMenu_Functions.setFunc.PABanking.goldMinToKeep,
            disabled = PAMenu_Functions.disabled.PABanking.goldMinToKeep,
            warning = PALocale.getResourceMessage("PABMenu_GoldMinToKeep_W"),
            default = PAMenu_Defaults.defaultSettings.PABanking.goldMinToKeep,
        })

        optionsTable:insert({
            type = "checkbox",
            name = PALocale.getResourceMessage("PABMenu_WithdrawToMinGold"),
            tooltip = PALocale.getResourceMessage("PABMenu_WithdrawToMinGold_T"),
            getFunc = PAMenu_Functions.getFunc.PABanking.withdrawToMinGold,
            setFunc = PAMenu_Functions.setFunc.PABanking.withdrawToMinGold,
            disabled = PAMenu_Functions.disabled.PABanking.withdrawToMinGold,
            default = PAMenu_Defaults.defaultSettings.PABanking.withdrawToMinGold,
        })

        optionsTable:insert({
            type = "divider",
            alpha = 0.5,
        })

        optionsTable:insert({
            type = "checkbox",
            name = PALocale.getResourceMessage("PABMenu_EnabledItems"),
            tooltip = PALocale.getResourceMessage("PABMenu_EnabledItems_T"),
            getFunc = PAMenu_Functions.getFunc.PABanking.enabledItems,
            setFunc = PAMenu_Functions.setFunc.PABanking.enabledItems,
            disabled = PAMenu_Functions.disabled.PABanking.enabledItems,
            default = PAMenu_Defaults.defaultSettings.PABanking.enabledItems,
        })

        -- enabledItemsChatMode

        optionsTable:insert({
            type = "description",
            text = PALocale.getResourceMessage("PABMenu_DepItemTypeDesc"),
        })

        optionsTable:insert({
            type = "submenu",
            name = PALocale.getResourceMessage("PABMenu_ItemTypeMaterialSubmenu"),
--            tooltip = PALocale.getResourceMessage("PABMenu_ItemTypeMaterialSubmenu_T"),
            controls = PABItemTypeMaterialSubmenuTable,
        })

        optionsTable:insert({
            type = "submenu",
            name = PALocale.getResourceMessage("PABMenu_DepItemType"),
            tooltip = PALocale.getResourceMessage("PABMenu_DepItemType_T"),
            controls = PABItemTypeSubmenuTable,
        })

        optionsTable:insert({
            type = "submenu",
            name = PALocale.getResourceMessage("PABMenu_Advanced_DepItemType"),
            tooltip = PALocale.getResourceMessage("PABMenu_Advanced_DepItemType_T"),
            controls = PABItemTypeAdvancedSubmenuTable,
        })

        optionsTable:insert({
            type = "slider",
            name = PALocale.getResourceMessage("PABMenu_DepItemTimerInterval"),
            tooltip = PALocale.getResourceMessage("PABMenu_DepItemTimerInterval_T"),
            min = 200,
            max = 1000,
            step = 50,
            getFunc = PAMenu_Functions.getFunc.PABanking.depositTimerInterval,
            setFunc = PAMenu_Functions.setFunc.PABanking.depositTimerInterval,
            disabled = PAMenu_Functions.disabled.PABanking.depositTimerInterval,
            default = PAMenu_Defaults.defaultSettings.PABanking.depositTimerInterval,
        })
    end

    -- =================================================================================================================

    if (PAL) then
        -- ---------------------- --
        -- PersonalAssistant Loot --
        -- ---------------------- --
        optionsTable:insert({
            type = "header",
            name = PALocale.getResourceMessage("PALMenu_Header"),
        })

        optionsTable:insert({
            type = "checkbox",
            name = PALocale.getResourceMessage("PALMenu_Enable"),
            tooltip = PALocale.getResourceMessage("PALMenu_Enable_T"),
            getFunc = PAMenu_Functions.getFunc.PALoot.enabled,
            setFunc = PAMenu_Functions.setFunc.PALoot.enabled,
            disabled = PAMenu_Functions.disabled.PAGeneral.noProfileSelected,
            default = PAMenu_Defaults.defaultSettings.PALoot.enabled,
        })

        optionsTable:insert({
            type = "checkbox",
            name = PALocale.getResourceMessage("PALMenu_LootGold"),
            tooltip = PALocale.getResourceMessage("PALMenu_LootGold_T"),
            getFunc = PAMenu_Functions.getFunc.PALoot.lootGoldEnabled,
            setFunc = PAMenu_Functions.setFunc.PALoot.lootGoldEnabled,
            width = "half",
            disabled = PAMenu_Functions.disabled.PALoot.lootGoldEnabled,
            default = PAMenu_Defaults.defaultSettings.PALoot.lootGoldEnabled,
        })

        optionsTable:insert({
            type = "dropdown",
            name = PALocale.getResourceMessage("PALMenu_LootGoldChatMode"),
            tooltip = PALocale.getResourceMessage("PALMenu_LootGoldChatMode_T"),
            choices = PAMenu_Choices.choices.PALoot.lootGoldChatMode,
            choicesValues = PAMenu_Choices.choicesValues.PALoot.lootGoldChatMode,
            getFunc = PAMenu_Functions.getFunc.PALoot.lootGoldChatMode,
            setFunc = PAMenu_Functions.setFunc.PALoot.lootGoldChatMode,
            width = "half",
            disabled = PAMenu_Functions.disabled.PALoot.lootGoldChatMode,
            default = PAMenu_Defaults.defaultSettings.PALoot.lootGoldChatMode,
        })

        optionsTable:insert({
            type = "checkbox",
            name = PALocale.getResourceMessage("PALMenu_LootItems"),
            tooltip = PALocale.getResourceMessage("PALMenu_LootItems_T"),
            getFunc = PAMenu_Functions.getFunc.PALoot.lootItemsEnabled,
            setFunc = PAMenu_Functions.setFunc.PALoot.lootItemsEnabled,
            width = "half",
            disabled = PAMenu_Functions.disabled.PALoot.lootItemsEnabled,
            default = PAMenu_Defaults.defaultSettings.PALoot.lootItemsEnabled,
        })

        optionsTable:insert({
            type = "dropdown",
            name = PALocale.getResourceMessage("PALMenu_LootItemsChatMode"),
            tooltip = PALocale.getResourceMessage("PALMenu_LootItemsChatMode_T"),
            choices = PAMenu_Choices.choices.PALoot.lootItemsChatMode,
            choicesValues = PAMenu_Choices.choicesValues.PALoot.lootItemsChatMode,
            getFunc = PAMenu_Functions.getFunc.PALoot.lootItemsChatMode,
            setFunc = PAMenu_Functions.setFunc.PALoot.lootItemsChatMode,
            width = "half",
            disabled = PAMenu_Functions.disabled.PALoot.lootItemsChatMode,
            default = PAMenu_Defaults.defaultSettings.PALoot.lootItemsChatMode,
        })

        optionsTable:insert({
            type = "submenu",
            name = PALocale.getResourceMessage("PALMenu_HarvestableItems"),
            tooltip = PALocale.getResourceMessage("PALMenu_HarvestableItems_T"),
            controls = PALHarvestableItemSubmenuTable,
        })

        optionsTable:insert({
            type = "submenu",
            name = PALocale.getResourceMessage("PALMenu_LootableItems"),
            tooltip = PALocale.getResourceMessage("PALMenu_LootableItems_T"),
            controls = PALLootableItemSubmenuTable,
        })
    end

    -- =================================================================================================================

    if (PAJ) then
        -- ------------------------- --
        -- PersonalAssistant Junk --
        -- ------------------------- --
        optionsTable:insert({
            type = "header",
            name = PALocale.getResourceMessage("PAJMenu_Header"),
        })

        optionsTable:insert({
            type = "checkbox",
            name = PALocale.getResourceMessage("PAJMenu_Enable"),
            tooltip = PALocale.getResourceMessage("PAJMenu_Enable_T"),
            getFunc = PAMenu_Functions.getFunc.PAJunk.enabled,
            setFunc = PAMenu_Functions.setFunc.PAJunk.enabled,
            disabled = PAMenu_Functions.disabled.PAGeneral.noProfileSelected,
            default = PAMenu_Defaults.defaultSettings.PAJunk.enabled,
        })

        optionsTable:insert({
            type = "checkbox",
            name = PALocale.getResourceMessage("PAJMenu_AutoSellJunk"),
            tooltip = PALocale.getResourceMessage("PAJMenu_AutoSellJunk_T"),
            getFunc = PAMenu_Functions.getFunc.PAJunk.autoSellJunk,
            setFunc = PAMenu_Functions.setFunc.PAJunk.autoSellJunk,
            disabled = PAMenu_Functions.disabled.PAJunk.autoSellJunk,
            default = PAMenu_Defaults.defaultSettings.PAJunk.autoSellJunk,
        })

        optionsTable:insert({
            type = "description",
            text = PALocale.getResourceMessage("PAJMenu_ItemTypeDesc"),
        })

        optionsTable:insert({
            type = "checkbox",
            name = PALocale.getResourceMessage("PAJMenu_AutoMarkTrash"),
            tooltip = PALocale.getResourceMessage("PAJMenu_AutoMarkTrash_T"),
            getFunc = PAMenu_Functions.getFunc.PAJunk.autoMarkTrash,
            setFunc = PAMenu_Functions.setFunc.PAJunk.autoMarkTrash,
            disabled = PAMenu_Functions.disabled.PAJunk.autoMarkTrash,
            default = PAMenu_Defaults.defaultSettings.PAJunk.autoMarkTrash,
        })

        optionsTable:insert({
            type = "checkbox",
            name = PALocale.getResourceMessage("PAJMenu_AutoMarkOrnate"),
            tooltip = PALocale.getResourceMessage("PAJMenu_AutoMarkOrnate_T"),
            getFunc = PAMenu_Functions.getFunc.PAJunk.autoMarkOrnate,
            setFunc = PAMenu_Functions.setFunc.PAJunk.autoMarkOrnate,
            disabled = PAMenu_Functions.disabled.PAJunk.autoMarkOrnate,
            default = PAMenu_Defaults.defaultSettings.PAJunk.autoMarkOrnate,
        })
    end
end


-- =================================================================================================================
-- =================================================================================================================


function PA_SettingsMenu.createPABItemTypeMaterialSubmenuTable()
    if (PAB) then

        if (IsESOPlusSubscriber()) then

            PABItemTypeMaterialSubmenuTable:insert({
                type = "description",
                text = PALocale.getResourceMessage("PABMenu_ItemTypeMaterialESOPlusDesc"),
            })

        else

            for _, itemType in pairs(PABItemTypesMaterial) do
                PABItemTypeMaterialSubmenuTable:insert({
                    type = "dropdown",
                    name = PALocale.getResourceMessage(itemType),
                    choices = PAMenu_Choices.choices.PABanking.itemMoveMode,
                    choicesValues = PAMenu_Choices.choicesValues.PABanking.itemMoveMode,
                    -- TODO: choicesTooltips
                    getFunc = function() return PAMenu_Functions.getFunc.PABanking.itemTypesMaterialMoveMode(itemType) end,
                    setFunc = function(value) PAMenu_Functions.setFunc.PABanking.itemTypesMaterialMoveMode(itemType, value) end,
                    width = "half",
                    disabled = PAMenu_Functions.disabled.PABanking.itemTypesMaterialMoveMode,
                    -- default = PAC_ITEMTYPE_IGNORE,  -- TODO: extract?
                })
            end

        end
    end
end


-- =================================================================================================================
-- =================================================================================================================


function PA_SettingsMenu.createPABItemSubMenu()
    if (PAB) then

        PABItemTypeSubmenuTable:insert({
            type = "dropdown",
            name = PALocale.getResourceMessage("PABMenu_DepStackOnly"),
            tooltip = PALocale.getResourceMessage("PABMenu_DepStackOnly_T"),
            choices = PAMenu_Choices.choices.PABanking.stackingType,
            choicesValues = PAMenu_Choices.choicesValues.PABanking.stackingType,
            -- TODO: choicesTooltips
            getFunc = PAMenu_Functions.getFunc.PABanking.itemsDepStackType,
            setFunc = PAMenu_Functions.setFunc.PABanking.itemsDepStackType,
            width = "half",
            disabled = PAMenu_Functions.disabled.PABanking.itemsDepStackType,
            default = PAMenu_Defaults.defaultSettings.PABanking.itemsDepStackType,
        })

        PABItemTypeSubmenuTable:insert({
            type = "dropdown",
            name = PALocale.getResourceMessage("PABMenu_WitStackOnly"),
            tooltip = PALocale.getResourceMessage("PABMenu_WitStackOnly_T"),
            choices = PAMenu_Choices.choices.PABanking.stackingType,
            choicesValues = PAMenu_Choices.choicesValues.PABanking.stackingType,
            getFunc = PAMenu_Functions.getFunc.PABanking.itemsWitStackType,
            setFunc = PAMenu_Functions.setFunc.PABanking.itemsWitStackType,
            width = "half",
            disabled = PAMenu_Functions.disabled.PABanking.itemsWitStackType,
            default = PAMenu_Defaults.defaultSettings.PABanking.itemsWitStackType,
        })

        PABItemTypeSubmenuTable:insert({
            type = "header",
            name = PALocale.getResourceMessage("PABMenu_ItemType_Header"),
        })

        for _, itemType in pairs(PABItemTypes) do
            PABItemTypeSubmenuTable:insert({
                type = "dropdown",
                name = PALocale.getResourceMessage(itemType),
                choices = PAMenu_Choices.choices.PABanking.itemMoveMode,
                choicesValues = PAMenu_Choices.choicesValues.PABanking.itemMoveMode,
                -- TODO: choicesTooltips
                getFunc = function() return PAMenu_Functions.getFunc.PABanking.itemTypesMoveMode(itemType) end,
                setFunc = function(value) PAMenu_Functions.setFunc.PABanking.itemTypesMoveMode(itemType, value) end,
                width = "half",
                disabled = PAMenu_Functions.disabled.PABanking.itemTypesMoveMode,
--                default = PAC_ITEMTYPE_IGNORE,  -- TODO: extract?
            })
        end

        PABItemTypeSubmenuTable:insert({
            type = "button",
            name = PALocale.getResourceMessage("PABMenu_DepButton"),
            tooltip = PALocale.getResourceMessage("PABMenu_DepButton_T"),
            func = PAMenu_Functions.func.PABanking.depositAllItemTypesButton,
            disabled = PAMenu_Functions.disabled.PABanking.depositAllItemTypesButton,
        })

        PABItemTypeSubmenuTable:insert({
            type = "button",
            name = PALocale.getResourceMessage("PABMenu_WitButton"),
            tooltip = PALocale.getResourceMessage("PABMenu_WitButton_T"),
            func = PAMenu_Functions.func.PABanking.withdrawAllItemTypesButton,
            disabled = PAMenu_Functions.disabled.PABanking.withdrawAllItemTypesButton,
        })

        PABItemTypeSubmenuTable:insert({
            type = "button",
            name = PALocale.getResourceMessage("PABMenu_IgnButton"),
            tooltip = PALocale.getResourceMessage("PABMenu_IgnButton_T"),
            func = PAMenu_Functions.func.PABanking.ignoreAllItemTypesButton,
            disabled = PAMenu_Functions.disabled.PABanking.ignoreAllItemTypesButton,
        })
    end
end


-- =================================================================================================================


function PA_SettingsMenu.createPABItemAdvancedSubMenu()
    if (PAB) then

        PABItemTypeAdvancedSubmenuTable:insert({
            type = "header",
            name = PALocale.getResourceMessage("PABMenu_Lockipck_Header"),
        })

        for _, advancedItemType in pairs(PABItemTypesAdvanced) do
            PABItemTypeAdvancedSubmenuTable:insert({
                type = "dropdown",
                name = PALocale.getResourceMessage("REL_Operator"),
                choices = PAMenu_Choices.choices.PABanking.mathOperator,
                choicesValues = PAMenu_Choices.choicesValues.PABanking.mathOperator,
                -- TODO: choicesTooltips
                getFunc = function() return PAMenu_Functions.getFunc.PABanking.advItemTypesOperator(advancedItemType) end,
                setFunc = function(value) PAMenu_Functions.setFunc.PABanking.advItemTypesOperator(advancedItemType, value) end,
                width = "half",
                disabled = PAMenu_Functions.disabled.PABanking.advItemTypesOperator,
                default = PALocale.getResourceMessage("REL_None"),  -- TODO: extract?
            })

            PABItemTypeAdvancedSubmenuTable:insert({
                type = "editbox",
                name = PALocale.getResourceMessage("PABMenu_Keep_in_Backpack"),
                tooltip = PALocale.getResourceMessage("PABMenu_Keep_in_Backpack_T"),
                getFunc = function() return PAMenu_Functions.getFunc.PABanking.advItemTypesValue(advancedItemType) end,
                setFunc = function(value) PAMenu_Functions.setFunc.PABanking.advItemTypesValue(advancedItemType, value) end,
                width = "half",
                disabled = PAMenu_Functions.disabled.PABanking.advItemTypesValue,
                default = 100,  -- TODO: extract?
            })
        end
    end
end


-- =================================================================================================================


function PA_SettingsMenu.createPALHarvestableItemSubMenu()
    if (PAL) then

        PALHarvestableItemSubmenuTable:insert({
            type = "description",
            text = PALocale.getResourceMessage("PALMenu_HarvestableItemsDesc"),
        })

        PALHarvestableItemSubmenuTable:insert({
            type = "header",
            name = PALocale.getResourceMessage("PALMenu_HarvestableItems_Bait_Header"),
        })

        PALHarvestableItemSubmenuTable:insert({
            type = "dropdown",
            name = PALocale.getResourceMessage("PALMenu_HarvestableItems_Bait"),
            tooltip = PALocale.getResourceMessage("PALMenu_HarvestableItems_Bait_T"),
            choices = PAMenu_Choices.choices.PALoot.harvestableBaitLootMode,
            choicesValues = PAMenu_Choices.choicesValues.PALoot.harvestableBaitLootMode,
            choicesTooltips = PAMenu_Choices.choicesTooltips.PALoot.harvestableBaitLootMode,
            getFunc = PAMenu_Functions.getFunc.PALoot.harvestableBaitLootMode,
            setFunc = PAMenu_Functions.setFunc.PALoot.harvestableBaitLootMode,
            disabled = PAMenu_Functions.disabled.PALoot.harvestableBaitLootMode,
            default = PAMenu_Defaults.defaultSettings.PALoot.harvestableBaitLootMode,
        })

        PALHarvestableItemSubmenuTable:insert({
            type = "header",
            name = PALocale.getResourceMessage("PALMenu_HarvestableItems_Header"),
        })

        for index, itemType in pairs(PALHarvestableItemTypes) do
            PALHarvestableItemSubmenuTable:insert({
                type = "dropdown",
                name = PALocale.getResourceMessage(itemType),
                choices = PAMenu_Choices.choices.PALoot.itemTypesLootMode,
                choicesValues = PAMenu_Choices.choicesValues.PALoot.itemTypesLootMode,
                choicesTooltips = PAMenu_Choices.choicesTooltips.PALoot.itemTypesLootMode,
                getFunc = function() return PAMenu_Functions.getFunc.PALoot.harvestableItemTypesLootMode(itemType) end,
                setFunc = function(value) PAMenu_Functions.setFunc.PALoot.harvestableItemTypesLootMode(itemType, value) end,
                width = "half",
                disabled = PAMenu_Functions.disabled.PALoot.harvestableItemTypesLootMode,
                default = PAMenu_Defaults.defaultSettings.PALoot.harvestableItemTypesLootMode,
            })
        end

        PALHarvestableItemSubmenuTable:insert({
            type = "button",
            name = PALocale.getResourceMessage("PALMenu_AutoLootAllButton"),
            tooltip = PALocale.getResourceMessage("PALMenu_AutoLootAllButton_T"),
            func = PAMenu_Functions.func.PALoot.autoLootAllHarvestableButton,
            disabled = PAMenu_Functions.disabled.PALoot.autoLootAllHarvestableButton,
        })

        PALHarvestableItemSubmenuTable:insert({
            type = "button",
            name = PALocale.getResourceMessage("PALMenu_IgnButton"),
            tooltip = PALocale.getResourceMessage("PALMenu_IgnButton_T"),
            func = PAMenu_Functions.func.PALoot.ignoreAllHarvestableButton,
            disabled = PAMenu_Functions.disabled.PALoot.ignoreAllHarvestableButton,
        })
    end
end

-- =================================================================================================================

function PA_SettingsMenu.createPALLootableItemSubMenu()
    if (PAL) then

        PALLootableItemSubmenuTable:insert({
            type = "description",
            text = PALocale.getResourceMessage("PALMenu_LootableItemsDesc"),
        })

        PALLootableItemSubmenuTable:insert({
            type = "header",
            name = PALocale.getResourceMessage("PALMenu_LootableItems_Header"),
        })

        for index, itemType in pairs(PALLootableItemTypes) do
            PALLootableItemSubmenuTable:insert({
                type = "dropdown",
                name = PALocale.getResourceMessage(itemType),
                choices = PAMenu_Choices.choices.PALoot.itemTypesLootMode,
                choicesValues = PAMenu_Choices.choicesValues.PALoot.itemTypesLootMode,
                choicesTooltips = PAMenu_Choices.choicesTooltips.PALoot.itemTypesLootMode,
                getFunc = function() return PAMenu_Functions.getFunc.PALoot.lootableItemTypesLootMode(itemType) end,
                setFunc = function(value) PAMenu_Functions.setFunc.PALoot.lootableItemTypesLootMode(itemType, value) end,
                width = "half",
                disabled = PAMenu_Functions.disabled.PALoot.lootableItemTypesLootMode,
                default = PAMenu_Defaults.defaultSettings.PALoot.lootableItemTypesLootMode,
            })
        end

        PALLootableItemSubmenuTable:insert({
            type = "button",
            name = PALocale.getResourceMessage("PALMenu_AutoLootAllButton"),
            tooltip = PALocale.getResourceMessage("PALMenu_AutoLootAllButton_T"),
            func = PAMenu_Functions.func.PALoot.autoLootAllLootableButton,
            disabled = PAMenu_Functions.disabled.PALoot.autoLootAllLootableButton,
        })

        PALLootableItemSubmenuTable:insert({
            type = "button",
            name = PALocale.getResourceMessage("PALMenu_IgnButton"),
            tooltip = PALocale.getResourceMessage("PALMenu_IgnButton_T"),
            func = PAMenu_Functions.func.PALoot.ignoreAllLootableButton,
            disabled = PAMenu_Functions.disabled.PALoot.ignoreAllLootableButton,
        })

    end
end