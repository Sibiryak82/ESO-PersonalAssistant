MenuHelper = {}

-- PA Banking
function MenuHelper.setDepositAll()
	MenuHelper.setDropdownsTo(PAC_ITEMTYPE_DEPOSIT)
end

function MenuHelper.setWithdrawalAll()
	MenuHelper.setDropdownsTo(PAC_ITEMTYPE_WITHDRAWAL)
end

function MenuHelper.setIgnoreAll()
	MenuHelper.setDropdownsTo(PAC_ITEMTYPE_IGNORE)
end

-- PA Loot
function MenuHelper.setAutoLootAll()
    MenuHelper.setLootDropdownsTo(PAC_ITEMTYPE_LOOT)
end

function MenuHelper.setIgnoreLootAll()
    MenuHelper.setLootDropdownsTo(PAC_ITEMTYPE_IGNORE)
end

-- --------------------------------------------------------------------------------------------------------

function MenuHelper.setDropdownsTo(itemTypeKey)
	local activeProfile = PA.savedVars.General.activeProfile
	for i = 1, #PAItemTypes do
		-- only if the itemType is enabled
		if PAItemTypes[i] ~= "" then
			PA.savedVars.Banking[activeProfile].ItemTypes[PAItemTypes[i]] = itemTypeKey
		end
	end
end

function MenuHelper.setLootDropdownsTo(itemTypeKey)
    local activeProfile = PA.savedVars.General.activeProfile
    for i = 1, #PALoItemTypes do
        -- only if the itemType is enabled
        if PALoItemTypes[i] ~= "" then
            PA.savedVars.Loot[activeProfile].ItemTypes[PALoItemTypes[i]] = itemTypeKey
        end
    end
end

-- --------------------------------------------------------------------------------------------------------

function MenuHelper.loadProfile(profileText)
	-- first update the active profile in the savedVars
	PA.savedVars.General.activeProfile = MenuHelper.getProfileNumberFromText(profileText)
end

function MenuHelper.renameProfile(profileText)
	PA.savedVars.Profiles[PA.savedVars.General.activeProfile].name = profileText
    -- TODO: replace this with LAM-2's [requiresReload]
    -- https://github.com/sirinsidiator/ESO-LibAddonMenu/wiki/CommonProperties#requiresreload
	ReloadUI()
end

function MenuHelper.loadProfileNumber(profileNumber)
	PA.savedVars.General.activeProfile = profileNumber
end

-- --------------------------------------------------------------------------------------------------------

-- returns the matching dropdown-text based on the number that is behind it
function MenuHelper.getBankingTextFromNumber(number)
	local activeProfile = PA.savedVars.General.activeProfile
	local index = PA.savedVars.Banking[activeProfile].itemsJunkSetting
	-- if "number" is empty, it has to be the junkSetting
	if (number ~= nil) then
		index = PA.savedVars.Banking[activeProfile].ItemTypes[number]
	end
	
	if index == PAC_ITEMTYPE_DEPOSIT then
		return PALocale.getResourceMessage("PAB_ItemType_Deposit")
	elseif index == PAC_ITEMTYPE_WITHDRAWAL then
		return PALocale.getResourceMessage("PAB_ItemType_Withdrawal")
	elseif index == PAC_ITEMTYPE_INHERIT then
		return PALocale.getResourceMessage("PAB_ItemType_Inherit")
	else
		return PALocale.getResourceMessage("PAB_ItemType_None")
	end
end

-- returns the number behind the text, depending on the text
function MenuHelper.getBankingNumberFromText(text)
	if text == PALocale.getResourceMessage("PAB_ItemType_Deposit") then
		return PAC_ITEMTYPE_DEPOSIT		-- = Deposit
	elseif text == PALocale.getResourceMessage("PAB_ItemType_Withdrawal") then
		return PAC_ITEMTYPE_WITHDRAWAL	-- = Withdrawal
	elseif text == PALocale.getResourceMessage("PAB_ItemType_Inherit") then
		return PAC_ITEMTYPE_INHERIT		-- = Inherit
	else
		return PAC_ITEMTYPE_IGNORE		-- = Ignore
	end
end

-- --------------------------------------------------------------------------------------------------------

-- returns the matching dropdown-text based on the number that is behind it
function MenuHelper.getOperatorTextFromNumber(number)
	local activeProfile = PA.savedVars.General.activeProfile
	local index = PA.savedVars.Banking[activeProfile].ItemTypesAdvanced[number].Key
	
	if index == PAC_OPERATOR_EQUAL then
		return PALocale.getResourceMessage("REL_Equal")
	elseif index == PAC_OPERATOR_LESSTHAN then
		return PALocale.getResourceMessage("REL_LessThan")
	elseif index == PAC_OPERATOR_LESSTAHNEQAL then
		return PALocale.getResourceMessage("REL_LessThanEqual")
	elseif index == PAC_OPERATOR_GREATERTHAN then
		return PALocale.getResourceMessage("REL_GreaterThan")
	elseif index == PAC_OPERATOR_GREATERTHANEQUAL then
		return PALocale.getResourceMessage("REL_GreaterThanEqual")
	else
		return PALocale.getResourceMessage("REL_None")
	end
end

-- returns the number behind the text, depending on the text
function MenuHelper.getOperatorNumberFromText(text)
	if text == PALocale.getResourceMessage("REL_Equal") then
		return PAC_OPERATOR_EQUAL
	elseif text == PALocale.getResourceMessage("REL_LessThan") then
		return PAC_OPERATOR_LESSTHAN
	elseif text == PALocale.getResourceMessage("REL_LessThanEqual") then
		return PAC_OPERATOR_LESSTAHNEQAL
	elseif text == PALocale.getResourceMessage("REL_GreaterThan") then
		return PAC_OPERATOR_GREATERTHAN
	elseif text == PALocale.getResourceMessage("REL_GreaterThanEqual") then
		return PAC_OPERATOR_GREATERTHANEQUAL
	else
		return PAC_OPERATOR_NONE
	end
end

-- --------------------------------------------------------------------------------------------------------

-- returns the matching dropdown-text based on the number that is behind it
function MenuHelper.getStackTypeTextFromNumber(index)
	if index == PAB_STACKING_CONTINUE then
		return PALocale.getResourceMessage("ST_MoveExistingFull")
	elseif index == PAB_STACKING_INCOMPLETE then
		return PALocale.getResourceMessage("ST_FillIncompleteOnly")
	else
		return PALocale.getResourceMessage("ST_MoveAllFull")
	end
end

-- returns the number behind the text, depending on the text
function MenuHelper.getStackTypeNumberFromText(text)
	if text == PALocale.getResourceMessage("ST_MoveExistingFull") then
		return PAB_STACKING_CONTINUE
	elseif text == PALocale.getResourceMessage("ST_FillIncompleteOnly") then
		return PAB_STACKING_INCOMPLETE
	else
		return PAB_STACKING_FULL
	end
end

-- --------------------------------------------------------------------------------------------------------

-- returns the matching dropdown-text based on the number that is behind it
function MenuHelper.getLootTextFromNumber(number)
    local activeProfile = PA.savedVars.General.activeProfile
    local index = PA.savedVars.Loot[activeProfile].ItemTypes[number]
    if index == PAC_ITEMTYPE_LOOT then
        return PALocale.getResourceMessage("PALo_ItemType_Loot")
    else
        return PALocale.getResourceMessage("PALo_ItemType_None")
    end
end

-- returns the number behind the text, depending on the text
function MenuHelper.getLootNumberFromText(text)
    if text == PALocale.getResourceMessage("PALo_ItemType_Loot") then
        return PAC_ITEMTYPE_LOOT		-- = Auto-Loot
    else
        return PAC_ITEMTYPE_IGNORE		-- = Ignore
    end
end

-- --------------------------------------------------------------------------------------------------------

function MenuHelper.getProfileList()
	local profiles = {}
	for profileNo = 1, PAG_MAX_PROFILES do
		profiles[profileNo] = PA.savedVars.Profiles[profileNo].name
	end
	return profiles
end

function MenuHelper.getProfileTextFromNumber(number)
	local profileNo = PA.savedVars.General.activeProfile
	if (number ~= nil) then
		profileNo = number
	end
	
	return PA.savedVars.Profiles[profileNo].name
end

function MenuHelper.getDefaultProfileName(profileNo)
	if profileNo == 2 then
		return PALocale.getResourceMessage("PAG_Profile2")
	elseif profileNo == 3 then
		return PALocale.getResourceMessage("PAG_Profile3")
	elseif profileNo == 4 then
		return PALocale.getResourceMessage("PAG_Profile4")
	elseif profileNo == 5 then
		return PALocale.getResourceMessage("PAG_Profile5")
	else
		return PALocale.getResourceMessage("PAG_Profile1")
	end
end

function MenuHelper.getProfileNumberFromText(profileText)
	for profileNo = 1, PAG_MAX_PROFILES do
		if PA.savedVars.Profiles[profileNo].name == profileText then
			return profileNo
		end
	end
	-- if nothing found, return 1
	return 1
end