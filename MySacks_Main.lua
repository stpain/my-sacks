

-- 1519426 bag icon

local addonName, MySacks = ...

local LOCALES = MySacks.Locales

local FONT_COLOUR = '|cff88C03B'


MySacks.BAG_SLOT_DELAY = 0.2
MySacks.PlayerMixin = nil
MySacks.CurrentBagReport = {}
MySacks.ContextMenu = {}
MySacks.ContextMenu_Separator = "|TInterface/COMMON/UI-TooltipDivider:8:150|t"
MySacks.ContextMenu_Separator_Wide = "|TInterface/COMMON/UI-TooltipDivider:8:250|t"
MySacks.ContextMenu_MerchantDropDown = CreateFrame("Frame", "MySacksContextMenuMerchantDropDown", UIParent, "UIDropDownMenuTemplate")
MySacks.ContextMenu_SoldIcon = 132050

MySacks.PlayerBagSlotsMap_JunkRarity = {}
MySacks.PlayerBagSlotsMap_ItemClass = {}
MySacks.PlayerBagSlotsMap_ItemSubClass = {}

MySacks.CurrentSessionLootedClassIDs = {}

MySacks.Loaded = false

MySacks.ErrorCodes = {
    ['noguid'] = 'guid not ready',
    ['initfail'] = 'addon not initialised properly',
    ['tooltipitemerror'] = 'unable to get tooltip item data',
    ['playermixinerror'] = 'unable to get player mixin data',
}


MySacks.ClassData = {
    [1] = { Name = 'WARRIOR', IconID = 626008, RGB={ 0.78, 0.61, 0.43 }, FontColour='|cffC79C6E', },
    [2] = { Name = 'PALADIN', IconID = 626003, RGB={ 0.96, 0.55, 0.73 }, FontColour='|cffF58CBA', },
    [3] = { Name = 'HUNTER', IconID = 626000, RGB={ 0.67, 0.83, 0.45 }, FontColour='|cffABD473', },
    [4] = { Name = 'ROGUE', IconID = 626005, RGB={ 1.00, 0.96, 0.41 }, FontColour='|cffFFF569', },
    [5] = { Name = 'PRIEST', IconID = 626004, RGB={ 1.00, 1.00, 1.00 }, FontColour='|cffFFFFFF', },
    [6] = { Name = 'DEATHKNIGHT', IconID = 135771, RGB={ 0.77, 0.12, 0.23 }, FontColour='|cffC41F3B', },
    [7] = { Name = 'SHAMAN', IconID = 626006, RGB={ 0.00, 0.44, 0.87 }, FontColour='|cff0070DE', },
    [8] = { Name = 'MAGE', IconID = 626001, RGB={ 0.25, 0.78, 0.92 }, FontColour='|cff40C7EB', },
    [9] = { Name = 'WARLOCK', IconID = 626007, RGB={ 0.53, 0.53, 0.93 }, FontColour='|cff8787ED', },
    [10] = { Name = 'MONK', IconID = 626002, RGB={ 0.00, 1.00, 0.59}, FontColour='|cff00FF96', },
    [11] = { Name = 'DRUID', IconID = 625999, RGB={ 1.00, 0.49, 0.04 }, FontColour='|cffFF7D0A', },
    [12] = { Name = 'DEMONHUNTER', IconID = 236415, RGB={ 0.64, 0.19, 0.79}, FontColour='|cffA330C9', },
}


--Item binding type: 0 - none; 1 - on pickup; 2 - on equip; 3 - on use; 4 - quest.

----------------------------------------------------------------------------------------------------
-- minimap button ****** this is no longer used as all functionality is now in the main context menu
----------------------------------------------------------------------------------------------------
function MySacks.CreateMinimapButton()
    local ldb = LibStub("LibDataBroker-1.1")
    MySacks.MinimapButtonObject = ldb:NewDataObject(addonName, {
        type = "data source",
        icon = 1392955,
        OnClick = function(self, button)
            if button == "LeftButton" then
                -- Standard workaround call OpenToCategory twice
                -- https://www.wowinterface.com/forums/showpost.php?p=319664&postcount=2
                -- InterfaceOptionsFrame_OpenToCategory(addonName)
                -- InterfaceOptionsFrame_OpenToCategory(addonName)
            end
        end,
        OnTooltipShow = function(tooltip)
            if not tooltip or not tooltip.AddLine then return end
            tooltip:AddLine(MySacks.FONT_COLOUR..addonName)
            tooltip:AddLine("|cffFFFFFFLeft click:|r Options")
        end,
    })
    MySacks.MinimapIcon = LibStub("LibDBIcon-1.0")
    if not MYSACKS_CHARACTER['MinimapButton'] then MYSACKS_CHARACTER['MinimapButton'] = {} end
    MySacks.MinimapIcon:Register(addonName, MySacks.MinimapButtonObject, MYSACKS_CHARACTER['MinimapButton'])
end

----------------------------------------------------------------------------------------------------
-- helper functions
----------------------------------------------------------------------------------------------------

--- print a message to the default chat window using player class to highlight addon name
-- @param msg the string to print
function MySacks.Print(msg)
    if MySacks.Loaded == true then
        if not MySacks.PlayerMixin then
            MySacks.PlayerMixin = PlayerLocation:CreateFromGUID(UnitGUID('player'))
        else
            MySacks.PlayerMixin:SetGUID(UnitGUID('player'))
        end
        if MySacks.PlayerMixin:IsValid() then
            local class, filename, classID = C_PlayerInfo.GetClass(MySacks.PlayerMixin)
            DEFAULT_CHAT_FRAME:AddMessage(tostring(MySacks.ClassData[tonumber(classID)].FontColour..'My Sacks:|r '..msg))
        else
            DEFAULT_CHAT_FRAME:AddMessage(tostring('My Sacks:|r '..msg))
        end
    end
end

--- set a frame to be moveable by the player
-- @param frame the frame to enable
function MySacks.MakeFrameMovable(frame)
	frame:SetMovable(true)
	frame:EnableMouse(true)
	frame:RegisterForDrag("LeftButton")
	frame:SetScript("OnDragStart", frame.StartMoving)
	frame:SetScript("OnDragStop", frame.StopMovingOrSizing)
end

--- set a frame to be non moveable by the player
-- @param frame the frame to disable
function MySacks.LockFramePos(frame)
    frame:SetMovable(false)
    frame:EnableMouse(false)
end

--- returns a table of rgb values converted into a 0.0-1.0 scale
-- @param t the rgb table to convert
-- @return {r, g, b} the converted values
function MySacks.RgbToPercent(t)
    if type(t) == 'table' then
        if type(t[1]) == 'number' and type(t[2]) == 'number' and type(t[3]) == 'number' then
            local r = tonumber(t[1] / 256.0)
            local g = tonumber(t[2] / 256.0)
            local b = tonumber(t[3] / 256.0)
            return {r, g, b}
        end
    else
        return false
    end
end

--- returns an item id from an item link
-- @param s the item link to extract an id from
-- @return id the item id 
function MySacks.GetItemIdFromString(s)
    if string.find(s, '|Hitem') then
        local l = string.sub(tostring(s), (string.find(s, '|Hitem')), (string.find(s, '|h')))
        local t, i = {}, 1
        for d in string.gmatch(l, '[^:]+') do
            t[i] = d
            i = i + 1
        end
        local id = tonumber(t[2])
        if type(id) == 'number' then
            return id
        else
            return false
        end
    else
        return false
    end
end

--- returns empty mail slots on the current open mail 
-- @return number the number of empty slots
function MySacks.GetSendMailEmptySlots()
    local s = 0
    for i = 1, ATTACHMENTS_MAX_SEND do
        local name, itemID, texture, count, quality = GetSendMailItem(i)
        if name then
            s = s + 1
        end
    end
    return ATTACHMENTS_MAX_SEND - s
end

----------------------------------------------------------------------------------------------------
-- slash commands
----------------------------------------------------------------------------------------------------
SLASH_MYSACKS1 = '/mysacks'
SlashCmdList['MYSACKS'] = function(msg)
    MySacks.ReportFrame:Show()
end














---------------------------------------------------------------------------------------------------------------------------------------------------------------
--tooltip extension
---------------------------------------------------------------------------------------------------------------------------------------------------------------
MySacks.TooltipLineAdded = false
function MySacks.OnTooltipSetItem(tooltip, ...)
    MySacks.ScanBags()
    if BankFrame:IsVisible() then
        MySacks.ScanBanks()
    end
    if BankFrame:IsVisible() then
        MySacks.ScanBanks()
    end
    if MySacks.Loaded == true then
        local name, link = GameTooltip:GetItem()
        local nameScan = GameTooltipTextLeft1:GetText()
        if link and nameScan then
            local id = select(1, GetItemInfoInstant(link))
            --print(id, 'first api call')
            if not id then
                id = select(1, GetItemInfoInstant(nameScan))
                --print(id, 'using item name')
            end
            if not id then
                id = tonumber(MySacks.GetItemIdFromString(link))
                --print(id, 'using link')
            end
            local itemCount = 0
            if next(MYSACKS_GLOBAL.Characters) then
                for guid, character in pairs(MYSACKS_GLOBAL.Characters) do            
                    if not MySacks.PlayerMixin then
                        MySacks.PlayerMixin = PlayerLocation:CreateFromGUID(guid)
                    else
                        MySacks.PlayerMixin:SetGUID(guid)
                    end
                    if MySacks.PlayerMixin:IsValid() then
                        local class, filename, classID = C_PlayerInfo.GetClass(MySacks.PlayerMixin)
                        local name = C_PlayerInfo.GetName(MySacks.PlayerMixin) or ''
                        local fs = ''
                        if classID then
                            fs = MySacks.ClassData[tonumber(classID)].FontColour
                        end
                        local bags, bank = 0, 0
                        if next(character.Bags) and character.Bags[id] then
                            bags = tonumber(character.Bags[id].Count)
                        end
                        if next(character.Bank) and character.Bank[id] then
                            bank = tonumber(character.Bank[id].Count)
                        end                  
                        itemCount = bags + bank
                        if tonumber(itemCount) > 0 then
                            tooltip:AddDoubleLine(tostring(fs..name), tostring(fs..'Bags: |cffffffff'..bags..fs..' Bank: |cffffffff'..bank..fs..' Total: |cffffffff'..itemCount))
                            --tooltip:AddTexture() --?
                        end
                    end
                end
            end
        end
    end
end

function MySacks.OnTooltipCleared(tooltip, ...)
    MySacks.TooltipLineAdded = false
end











------------------------------------------------------------------------------------------------
-- merchant frame context menu
------------------------------------------------------------------------------------------------
--- create a custom frame for the merchant dropdown menu item level slider
MySacks.ContextMenu_CustomFrame_ItemLevelSlider = CreateFrame('FRAME', 'MySacksContextMenuCustomFrameItemLevel', UIParent, 'UIDropDownCustomMenuEntryTemplate')
MySacks.ContextMenu_CustomFrame_ItemLevelSlider:SetSize(150, 16)
MySacks.ContextMenu_CustomFrame_ItemLevelSlider:Hide()
--- create the slider frame
MySacks.ContextMenu_CustomFrame_ItemLevelSlider.slider = CreateFrame('SLIDER', 'MySacksContextMenuCustomFrameItemLevelSlider', MySacks.ContextMenu_CustomFrame_ItemLevelSlider, 'OptionsSliderTemplate')
MySacks.ContextMenu_CustomFrame_ItemLevelSlider.slider:SetPoint('LEFT', 10, 0)
MySacks.ContextMenu_CustomFrame_ItemLevelSlider.slider:SetThumbTexture("Interface/Buttons/UI-SliderBar-Button-Horizontal")
MySacks.ContextMenu_CustomFrame_ItemLevelSlider.slider:SetSize(100, 16)
MySacks.ContextMenu_CustomFrame_ItemLevelSlider.slider:SetOrientation('HORIZONTAL')
MySacks.ContextMenu_CustomFrame_ItemLevelSlider.slider:SetMinMaxValues(1, 300) -- this is determined by max item level in game
MySacks.ContextMenu_CustomFrame_ItemLevelSlider.slider:SetValueStep(1)
--- set texts to nil ('') makes them appear hidden
_G[MySacks.ContextMenu_CustomFrame_ItemLevelSlider.slider:GetName()..'Low']:SetText('')
_G[MySacks.ContextMenu_CustomFrame_ItemLevelSlider.slider:GetName()..'High']:SetText('')
--- set slider value from saved variables
if MYSACKS_CHARACTER and MYSACKS_CHARACTER['Merchant'] and MYSACKS_CHARACTER['Merchant'].ItemlevelThreshold then
    MySacks.ContextMenu_CustomFrame_ItemLevelSlider.slider:SetValue(tonumber(MYSACKS_CHARACTER['Merchant'].ItemlevelThreshold))
else
    MySacks.ContextMenu_CustomFrame_ItemLevelSlider.slider:SetValue(100)
end
--- create a fontstring to display the slider value
MySacks.ContextMenu_CustomFrame_ItemLevelSlider.text = MySacks.ContextMenu_CustomFrame_ItemLevelSlider:CreateFontString('MySacksContextMenuCustomFrameItemLevelSliderText', 'OVERLAY', 'GameFontNormal')
MySacks.ContextMenu_CustomFrame_ItemLevelSlider.text:SetPoint('LEFT', MySacks.ContextMenu_CustomFrame_ItemLevelSlider.slider, 'RIGHT', 10, 0)
MySacks.ContextMenu_CustomFrame_ItemLevelSlider.text:SetText(tostring(string.format('%.0f', tostring(MySacks.ContextMenu_CustomFrame_ItemLevelSlider.slider:GetValue()))))
MySacks.ContextMenu_CustomFrame_ItemLevelSlider.text:SetFont("Fonts\\FRIZQT__.TTF", 10)
MySacks.ContextMenu_CustomFrame_ItemLevelSlider.text:SetTextColor(1,1,1,1)
--- set scripts for slider, using mouse wheel for fine tuning
MySacks.ContextMenu_CustomFrame_ItemLevelSlider.slider:SetScript('OnMouseWheel', function(self, delta)
    if delta == -1 then
        self:SetValue(self:GetValue() - 1)
    else
        self:SetValue(self:GetValue() + 1)
    end
end)
MySacks.ContextMenu_CustomFrame_ItemLevelSlider.slider:SetScript('OnValueChanged', function(self)
    if MYSACKS_CHARACTER and MYSACKS_CHARACTER['Merchant'] then
        MYSACKS_CHARACTER['Merchant'].ItemlevelThreshold = tonumber(self:GetValue())
    end
    MySacks.ContextMenu_CustomFrame_ItemLevelSlider.text:SetText(tostring(string.format('%.0f', tostring(self:GetValue()))))
end)
MySacks.ContextMenu_CustomFrame_ItemLevelSlider.slider:SetScript('OnShow', function(self)
    if MYSACKS_CHARACTER and MYSACKS_CHARACTER['Merchant'] then
        self:SetValue(tonumber(MYSACKS_CHARACTER['Merchant'].ItemlevelThreshold))
    end
    MySacks.ContextMenu_CustomFrame_ItemLevelSlider.text:SetText(tostring(string.format('%.0f', tostring(self:GetValue()))))
end)







------------------------------------------------------------------------------------------------
-- mail attachments menu
------------------------------------------------------------------------------------------------
function MySacks.GenerateMailButtonContextMenu()
    MySacks.GetBagsReport()
    MySacks.ContextMenu = {
        {text = LOCALES['mailMenu'], isTitle=true, notCheckable=true },
    }
    if next(MySacks.CurrentBagReport) then
        -- loop the bags report table
        for itemClassID, itemClassTable in pairs(MySacks.CurrentBagReport) do           
            local itemClass = GetItemClassInfo(tonumber(itemClassID))            
            table.insert(MySacks.ContextMenu, { 
                text = itemClass, 
                hasArrow=true, 
                keepShownOnClick=true,
                notCheckable=true, 
                menuList=MySacks.GenerateItemSubClassMenu_Mail(itemClassID),
                func=function(self)
                    if IsAltKeyDown() then
                        local i = 1
                        local slotsEmpty = MySacks.GetSendMailEmptySlots()
                        if slotsEmpty > 0 then
                            while (slotsEmpty > 0)
                            do
                                if MySacks.PlayerBagSlotsMap_ItemClass[itemClassID][i] then
                                    local location = MySacks.PlayerBagSlotsMap_ItemClass[itemClassID][i]
                                    if location then
                                        UseContainerItem(location.BagID, location.SlotID)
                                        i = i + 1
                                        slotsEmpty = MySacks.GetSendMailEmptySlots()
                                        --print(string.format('added %s from bag %s slot %s to mail, slots left in mail %s', itemClass, location.BagID, location.SlotID, slotsEmpty))
                                    end
                                else
                                    break
                                end
                            end
                        end
                    end
                end,
            })
        end
    end
    table.insert(MySacks.ContextMenu, {
        text = LOCALES['mailMenuHelp'], 
        notCheckable=true, 
        icon=374216, 
        tooltipTitle=LOCALES['mailMenuHelp_tooltipTitle'], 
        tooltipText=LOCALES['mailMenuHelp_tooltipText'], 
        tooltipOnButton=true 
    } )
end






------------------------------------------------------------------------------------------------
-- main menu drop down table
------------------------------------------------------------------------------------------------
--- generates a table to pass to the EasyMenu function for the merchant frame
-- @function MySacks.GetBagsReport this will scan player bags and generate a table based on the contents
-- @table MySacks.ContextMenu main menu table, contains level 1 menu buttons
-- @table MySacks.ContextMenu_ItemClassMenu classID menu table, contains level 2 menu buttons
-- @table MySacks.ContextMenu_ItemSubClassMenuList subClassID menu table, contains level 3 menu buttons
-- @table MySacks.CurrentBagReport table containing the players bags contents as returned by MySacks.GetBagsReport
-- @table MySacks.CurrentBagReport structure
-- MySacks.CurrentBagReport = {
--     [itemClassID] = {
--         [itemSubClassID] = {
--             [link] = {
                -- Rarity = number item rarity 
                -- Count = number item count, 
                -- SellPrice = number total value of all items with this link,
                -- ItemClassID = number item class id,
                -- ItemSubClassID = number item sub class id,
                -- Link = string item link,
--             },
--         },
--     }
-- }
function MySacks.GenerateMerchantButtonContextMenu()
    -- scan bags
    MySacks.GetBagsReport()
    -- main menu
    MySacks.ContextMenu = {
        { text = LOCALES['merchantOptions'], isTitle=true, notCheckable=true },
        { text = LOCALES['vendorJunk'], notCheckable=true, keepShownOnClick=true, func = function()
            MySacks.VendoringCooldown:Show()
            MySacks.VendoringCooldown.cooldown:SetCooldown(GetTime(), (#MySacks.PlayerBagSlotsMap_JunkRarity * MySacks.BAG_SLOT_DELAY))
            local i = 1
            copper = 0
            C_Timer.NewTicker(MySacks.BAG_SLOT_DELAY, function()
                local location = MySacks.PlayerBagSlotsMap_JunkRarity[i]
                if location then
                    --print(string.format('selling bag %s slot %s', location.BagID, location.SlotID))
                    local c = MySacks.VendorItemByLocation(true, location.BagID, location.SlotID)
                    copper = copper + c
                    i = i + 1
                end
                if i > #MySacks.PlayerBagSlotsMap_JunkRarity then
                    MySacks.VendoringCooldown:Hide()
                    MySacks.Print('sold junk for '..GetCoinTextureString(copper))
                end
            end, #MySacks.PlayerBagSlotsMap_JunkRarity)
        end},
        { 
            text = MySacks.ContextMenu_Separator, 
            notClickable=true, 
            notCheckable=true
        },
        { 
            text = LOCALES['items'], 
            notCheckable=true, 
            isTitle=true, 
        },
    }
    MySacks.ContextMenu_ItemClassMenuList = {}
    MySacks.ContextMenu_ItemSubClassMenuList = {}
    if next(MySacks.CurrentBagReport) then
        -- loop the bags report table
        for itemClassID, itemClassTable in pairs(MySacks.CurrentBagReport) do           
            local itemClass = GetItemClassInfo(tonumber(itemClassID))            
            table.insert(MySacks.ContextMenu, { 
                text = itemClass, 
                hasArrow=true, 
                keepShownOnClick=true,
                notCheckable=true, 
                menuList=MySacks.GenerateItemSubClassMenu(itemClassID),
                func=function(self)
                    if IsControlKeyDown() then
                        -- ctrl overrides merchant rules
                        MySacks.VendoringCooldown:Show()
                        MySacks.VendoringCooldown.cooldown:SetCooldown(GetTime(), (#MySacks.PlayerBagSlotsMap_ItemClass[itemClassID] * MySacks.BAG_SLOT_DELAY))
                        local i = 1
                        C_Timer.NewTicker(MySacks.BAG_SLOT_DELAY, function()
                            local location = MySacks.PlayerBagSlotsMap_ItemClass[itemClassID][i]
                            if location then
                                --print(string.format('selling bag %s slot %s', location.BagID, location.SlotID))
                                MySacks.VendorItemByLocation(true, location.BagID, location.SlotID)
                                i = i + 1
                            end
                            if i > #MySacks.PlayerBagSlotsMap_ItemClass[itemClassID] then
                                MySacks.VendoringCooldown:Hide()
                            end
                        end, #MySacks.PlayerBagSlotsMap_ItemClass[itemClassID])
                    elseif IsAltKeyDown() then
                        -- alt sells items, avoids miss sells by clicking
                        MySacks.VendoringCooldown:Show()
                        MySacks.VendoringCooldown.cooldown:SetCooldown(GetTime(), (#MySacks.PlayerBagSlotsMap_ItemClass[itemClassID] * MySacks.BAG_SLOT_DELAY))
                        local i = 1
                        C_Timer.NewTicker(MySacks.BAG_SLOT_DELAY, function()
                            local location = MySacks.PlayerBagSlotsMap_ItemClass[itemClassID][i]
                            if location then
                                --print(string.format('selling bag %s slot %s', location.BagID, location.SlotID))
                                MySacks.VendorItemByLocation(false, location.BagID, location.SlotID)
                                i = i + 1
                            end
                            if i > #MySacks.PlayerBagSlotsMap_ItemClass[itemClassID] then
                                MySacks.VendoringCooldown:Hide()
                            end
                        end, #MySacks.PlayerBagSlotsMap_ItemClass[itemClassID])
                    end
                end,
            })
        end
    end
    table.insert(MySacks.ContextMenu, { 
        text = MySacks.ContextMenu_Separator, 
        notClickable=true, 
        notCheckable=true 
    })
    table.insert(MySacks.ContextMenu, { 
        text = LOCALES['merchantOptions'], 
        isTitle=true, notClickable=true, 
        notCheckable=true 
    })
    local itemLevelThresholdSubMenu = {
        { 
            text='itemLevelSlider', 
            notCheckable=true, 
            keepShownOnClick=true, 
            customFrame=MySacks.ContextMenu_CustomFrame_ItemLevelSlider, 
        },
    }
    table.insert(MySacks.ContextMenu, { 
        text = LOCALES['itemLevel'], 
        hasArrow=true, 
        notCheckable=true, 
        menuList=itemLevelThresholdSubMenu, 
        tooltipTitle=LOCALES['itemLevel_tooltipTitle'], 
        tooltipText=LOCALES['itemLevel_tooltipText'], 
        tooltipOnButton=true,
    })
    table.insert(MySacks.ContextMenu, { 
        text = LOCALES['autoVendorJunk'], 
        checked=MYSACKS_CHARACTER['Merchant'].AutoVendorJunk, 
        isNotRadio=true, 
        keepShownOnClick=true, 
        func=MySacks.ToggleAutoVendorJunk, 
    })
    local ignoreRules = {
        { 
            text = LOCALES['ignoreRules'], 
            isTitle=true, 
            notCheckable=true, 
        },
    }
    table.insert(ignoreRules, {
        text = LOCALES['boeItems'],
        keepShownOnClick=true,
        isNotRadio=true,
        checked = MYSACKS_CHARACTER['Merchant'].VendorRules['boe'],
        func = function(self)
            MySacks.SetVendorRule('boe', nil)
        end,
    })
    table.insert(ignoreRules, {
        text = MySacks.ContextMenu_Separator, 
        notClickable=true, 
        notCheckable=true 
    })
    table.insert(ignoreRules, {
        text = LOCALES['rarityTypes'], 
        isTitle=true, 
        notClickable=true, 
        notCheckable=true 
    })
    for i = 1, 6 do
        table.insert(ignoreRules, {
            keepShownOnClick=true,
            checked = function() return MYSACKS_CHARACTER['Merchant'].VendorRules['rarity'][i] end,
            arg1 = tonumber(i),
            keepShownOnClick=true,
            arg2 = _G['ITEM_QUALITY'..i..'_DESC'],
            text = tostring(ITEM_QUALITY_COLORS[i].hex.._G['ITEM_QUALITY'..i..'_DESC']),
            isNotRadio=true,
            func = function(self)
                MySacks.SetVendorRule('rarity', self.arg1)
            end,
        })        
    end
    table.insert(ignoreRules, {
        text = MySacks.ContextMenu_Separator, 
        notClickable=true, 
        notCheckable=true 
    })
    table.insert(ignoreRules, {
        text = LOCALES['armorTypes'], 
        isTitle=true, 
        notClickable=true, 
        notCheckable=true 
    })
    for i = 0, 6 do
        table.insert(ignoreRules, {
            text = GetItemSubClassInfo(4, i),
            arg1 = tonumber(i),
            keepShownOnClick=true,
            isNotRadio=true,
            checked = function() return MYSACKS_CHARACTER['Merchant'].VendorRules['armor'][i] end,
            func = function(self)
                MySacks.SetVendorRule('armor', self.arg1)
            end,
        })
    end
    table.insert(MySacks.ContextMenu, { 
        text=LOCALES['ignoreRules'], 
        notCheckable=true, 
        hasArrow=true, 
        keepShownOnClick=true, 
        menuList=ignoreRules, 
        tooltipTitle=LOCALES['ignoreRules_tooltipTitle'], 
        tooltipText=LOCALES['ignoreRules_tooltipText'], 
        tooltipOnButton=true, 
    })
    local characters = {
        { 
            text = LOCALES['selectCharacter'], 
            isTitle=true, 
            notCheckable=true, 
        },
    }
    for guid, character in pairs(MYSACKS_GLOBAL.Characters) do
        if not MySacks.PlayerMixin then
            MySacks.PlayerMixin = PlayerLocation:CreateFromGUID(guid)
        else
            MySacks.PlayerMixin:SetGUID(guid)
        end
        if MySacks.PlayerMixin:IsValid() then
            local class, filename, classID = C_PlayerInfo.GetClass(MySacks.PlayerMixin)
            local name = C_PlayerInfo.GetName(MySacks.PlayerMixin)
            local raceID = C_PlayerInfo.GetRace(MySacks.PlayerMixin) or -1
            if name then
                if classID then
                    name = tostring(MySacks.ClassData[tonumber(classID)].FontColour..name..'|r')
                end
                table.insert(characters, {
                    text = name,
                    icon = nil,
                    notCheckable=true, 
                    func = function() 
                        MySacks.DeleteCharacter(guid, name) 
                        CloseDropDownMenus() 
                    end 
                })
            end
        end
    end
    table.insert(MySacks.ContextMenu, { 
        text = MySacks.ContextMenu_Separator, 
        notCheckable=true, 
        notClickable=true, 
    })
    table.insert(MySacks.ContextMenu, { 
        text = LOCALES['addonOptions'], 
        isTitle=true, 
        notCheckable=true 
    })
    table.insert(MySacks.ContextMenu, { 
        text = LOCALES['deleteCharacterData'], 
        hasArrow=true, 
        notCheckable=true, 
        menuList = 
        characters 
    })
    table.insert(MySacks.ContextMenu, { 
        text = LOCALES['deleteGlobalData'], 
        notCheckable=true, 
        hasArrow=true, 
        menuList = {
            { 
                text = LOCALES['confirm'], 
                notCheckable=true, 
                func=MySacks.WipeGlobalSavedVariables 
            }
        } 
    })
    table.insert(MySacks.ContextMenu, { 
        text = LOCALES['help'], 
        notCheckable=true, 
        icon=374216, 
        tooltipTitle=LOCALES['help_tooltipTitle'], 
        tooltipText=LOCALES['help_tooltipText'], 
        tooltipOnButton=true,
    })
    table.insert(MySacks.ContextMenu, { 
        text = LOCALES['cancel'], 
        notCheckable=true, 
        func=function() CloseDropDownMenus() end 
    })
end













----------------------------------------------------------------------------------------------------
-- functions
----------------------------------------------------------------------------------------------------


function MySacks.GenerateLinkMenu_Mail(itemClassID, itemSubClassID)
    MySacks.GetBagsReport()
    MySacks.ContextMenu_ItemSubClassMenuList = {}
    if MySacks.CurrentBagReport and MySacks.CurrentBagReport[itemClassID] and MySacks.CurrentBagReport[itemClassID][itemSubClassID] then
        local itemSubClass = GetItemSubClassInfo(tonumber(itemClassID), tonumber(itemSubClassID))
        MySacks.ContextMenu_ItemSubClassMenuList = {}
        for link, linkTable in pairs(MySacks.CurrentBagReport[itemClassID][itemSubClassID]) do
            table.insert(MySacks.ContextMenu_ItemSubClassMenuList, { 
                text = string.format('[%s] %s ', linkTable.Count, link),
                arg1 = 'item', 
                arg2 = linkTable,
                isNotRadio=true,
                --notCheckable=true,
                keepShownOnClick=true,
                icon = linkTable.Icon,
                func = function(self, arg1, arg2)
                    if IsShiftKeyDown() then
                        -- shift will show tooltip(s)
                        GameTooltip:SetOwner(self, 'ANCHOR_RIGHT', 0, -16)
                        GameTooltip:SetHyperlink(link)
                        GameTooltip:Show()
                    elseif IsAltKeyDown() then
                        local i = 1
                        local slotsEmpty = MySacks.GetSendMailEmptySlots()
                        if slotsEmpty > 0 then
                            while (slotsEmpty > 0)
                            do
                                if linkTable.LocationMap[i] then
                                    UseContainerItem(linkTable.LocationMap[i].BagID, linkTable.LocationMap[i].SlotID)
                                    i = i + 1
                                    slotsEmpty = MySacks.GetSendMailEmptySlots()
                                else
                                    break
                                end
                            end
                        end
                        self.checked = true -- not self.cheked
                    end
                end,
            })
        end
        table.sort(MySacks.ContextMenu_ItemSubClassMenuList, function(a,b) return a.arg2.Rarity < b.arg2.Rarity end)
        table.insert(MySacks.ContextMenu_ItemSubClassMenuList, 1, {
            text = itemSubClass, 
            isTitle=true, 
            notCheckable=true
        })
    end
    return MySacks.ContextMenu_ItemSubClassMenuList
end


function MySacks.GenerateItemSubClassMenu_Mail(itemClassID)
    MySacks.GetBagsReport()
    MySacks.ContextMenu_ItemClassMenuList = {}
    if MySacks.CurrentBagReport and MySacks.CurrentBagReport[itemClassID] then
        local itemClass = GetItemClassInfo(tonumber(itemClassID))
        --MySacks.ContextMenu_ItemClassMenuList = {}
        for itemSubClassID, itemSubClassTable in pairs(MySacks.CurrentBagReport[itemClassID]) do
            local itemSubClass = GetItemSubClassInfo(tonumber(itemClassID), tonumber(itemSubClassID))
            table.insert(MySacks.ContextMenu_ItemClassMenuList, { 
                text = itemSubClass, 
                arg1 = tonumber(itemSubClassID), 
                hasArrow=true, 
                keepShownOnClick=true,
                notCheckable=true,
                -- tooltipTitle = LOCALES['subClassMenu_tooltipTitle'],
                -- tooltipText = LOCALES['subClassMenu_tooltipText'],
                tooltipOnButton=true,
                func=function(self)
                    if MySacks.PlayerBagSlotsMap_ItemSubClass[itemClassID][itemSubClassID] then
                        if IsAltKeyDown() then
                            local i = 1
                            local slotsEmpty = MySacks.GetSendMailEmptySlots()
                            if slotsEmpty > 0 then
                                while (slotsEmpty > 0)
                                do
                                    if MySacks.PlayerBagSlotsMap_ItemSubClass[itemClassID][itemSubClassID][i] then
                                        local location = MySacks.PlayerBagSlotsMap_ItemSubClass[itemClassID][itemSubClassID][i]
                                        if location then
                                            UseContainerItem(location.BagID, location.SlotID)
                                            i = i + 1
                                            slotsEmpty = MySacks.GetSendMailEmptySlots()
                                            --print(string.format('added %s from bag %s slot %s to mail, slots left in mail %s', itemSubClass, location.BagID, location.SlotID, slotsEmpty))
                                        end
                                    else
                                        break
                                    end
                                end
                            end                            
                        end
                    end
                end,
                menuList=MySacks.GenerateLinkMenu_Mail(itemClassID, itemSubClassID) or {},
            })
        end
        table.sort(MySacks.ContextMenu_ItemClassMenuList, function(a,b) return a.arg1 < b.arg1 end)
        table.insert(MySacks.ContextMenu_ItemClassMenuList, 1, {
            text = itemClass, 
            isTitle=true, 
            notCheckable=true
        })
    end
    return MySacks.ContextMenu_ItemClassMenuList
end



--- generate the menuList for item sub classes, this is a list of item links of the sub class
-- @param itemClassID number value of item class
-- @param itemSubClassID number value of item sub class
function MySacks.GenerateLinkMenu(itemClassID, itemSubClassID)
    MySacks.GetBagsReport()
    MySacks.ContextMenu_ItemSubClassMenuList = {}
    if MySacks.CurrentBagReport and MySacks.CurrentBagReport[itemClassID] and MySacks.CurrentBagReport[itemClassID][itemSubClassID] then
        local itemSubClass = GetItemSubClassInfo(tonumber(itemClassID), tonumber(itemSubClassID))
        MySacks.ContextMenu_ItemSubClassMenuList = {}
        for link, linkTable in pairs(MySacks.CurrentBagReport[itemClassID][itemSubClassID]) do
            --print(link, linkTable.Count, linkTable.VendorPrice, linkTable.Count * linkTable.VendorPrice)
            table.insert(MySacks.ContextMenu_ItemSubClassMenuList, { 
                text = string.format('[%s] %s %s', linkTable.Count, link, GetCoinTextureString(tonumber(linkTable.Count * linkTable.VendorPrice))),
                arg1 = (linkTable.Count * linkTable.VendorPrice), 
                arg2 = linkTable,
                isNotRadio=true,
                checked = function() return linkTable.Ignore end,
                --checked = function() return MYSACKS_CHARACTER.Merchant.IgnoreList[linkTable.ItemID] end,
                keepShownOnClick=true,
                icon = '',
                func = function(self, arg1, arg2)
                    -- ctrl overrides merchant rules
                    if IsControlKeyDown() and not IsShiftKeyDown() and not IsAltKeyDown() then
                        MySacks.SellItemByLink(link, linkTable.VendorPrice, true)
                    -- shift will show tooltip(s)
                    elseif IsShiftKeyDown() and not IsControlKeyDown() and not IsAltKeyDown() then
                        GameTooltip:SetOwner(self, 'ANCHOR_RIGHT', 0, -16)
                        GameTooltip:SetHyperlink(link)
                        GameTooltip:Show()
                    -- alt sells items, avoids miss sells by clicking
                    elseif IsAltKeyDown() and not IsShiftKeyDown() and not IsControlKeyDown() then    
                        --print('selling item by link', link)
                        MySacks.SellItemByLink(link, linkTable.VendorPrice, false)
                    else
                        linkTable.Ignore = not linkTable.Ignore
                        if linkTable.Ignore == false then
                            MYSACKS_CHARACTER.Merchant.IgnoreList[linkTable.ItemID] = nil
                            --print(string.format('saved var table ignore list: item %s is now set to nil', link))
                        else
                            MYSACKS_CHARACTER.Merchant.IgnoreList[linkTable.ItemID] = true
                            --print(string.format('saved var table ignore list: item %s is now set to ignore: %s', link, tostring(linkTable.Ignore)))
                        end
                    end
                    -- update the checked icon
                    if linkTable.Ignore == true then
                        _G[self:GetName()..'Check']:Show()
                        _G[self:GetName()..'UnCheck']:Hide()
                    else
                        _G[self:GetName()..'Check']:Hide()
                        _G[self:GetName()..'UnCheck']:Show()
                    end
                end,
            })
        end
        -- sort menu by item value (all stack counts * vendorPrice)
        table.sort(MySacks.ContextMenu_ItemSubClassMenuList, function(a,b) return a.arg1 < b.arg1 end)
        -- add a separator and total at the bottom
        table.insert(MySacks.ContextMenu_ItemSubClassMenuList, {
            text = MySacks.ContextMenu_Separator_Wide,
            notCheckable=true,
            notClickable=true,
        })
        table.insert(MySacks.ContextMenu_ItemSubClassMenuList, {
            text = string.format('Total %s', GetCoinTextureString(MySacks.GetItemSubClassSellTotal(itemClassID, itemSubClassID))),
            notCheckable=true,
            notClickable=true,
        })
        -- insert menu header
        table.insert(MySacks.ContextMenu_ItemSubClassMenuList, 1, {
            text = itemSubClass, 
            isTitle=true, 
            notCheckable=true
        })
    end
    return MySacks.ContextMenu_ItemSubClassMenuList
end

--- generate the menuList for item classes, this is a list of sub classes of the item class
-- @param itemClassID number value of item class
function MySacks.GenerateItemSubClassMenu(itemClassID)
    MySacks.GetBagsReport()
    MySacks.ContextMenu_ItemClassMenuList = {}
    if MySacks.CurrentBagReport and MySacks.CurrentBagReport[itemClassID] then
        local itemClass = GetItemClassInfo(tonumber(itemClassID))
        --MySacks.ContextMenu_ItemClassMenuList = {}
        for itemSubClassID, itemSubClassTable in pairs(MySacks.CurrentBagReport[itemClassID]) do
            local itemSubClass = GetItemSubClassInfo(tonumber(itemClassID), tonumber(itemSubClassID))
            table.insert(MySacks.ContextMenu_ItemClassMenuList, { 
                text = itemSubClass, 
                arg1 = tonumber(itemSubClassID), 
                hasArrow=true, 
                keepShownOnClick=true,
                notCheckable=true,
                tooltipTitle = LOCALES['subClassMenu_tooltipTitle'],
                tooltipText = LOCALES['subClassMenu_tooltipText'],
                tooltipOnButton=true,
                func=function(self)
                    if MySacks.PlayerBagSlotsMap_ItemSubClass[itemClassID][itemSubClassID] then
                        if IsControlKeyDown() then
                            -- ctrl overrides merchant rules
                            MySacks.VendoringCooldown:Show()
                            MySacks.VendoringCooldown.cooldown:SetCooldown(GetTime(), (#MySacks.PlayerBagSlotsMap_ItemSubClass[itemClassID][itemSubClassID] * MySacks.BAG_SLOT_DELAY))
                            local i = 1
                            C_Timer.NewTicker(MySacks.BAG_SLOT_DELAY, function()
                                local location = MySacks.PlayerBagSlotsMap_ItemSubClass[itemClassID][itemSubClassID][i]
                                if location then
                                    --print(string.format('selling bag %s slot %s', location.BagID, location.SlotID))
                                    MySacks.VendorItemByLocation(true, location.BagID, location.SlotID)
                                    i = i + 1
                                end
                                if i > #MySacks.PlayerBagSlotsMap_ItemSubClass[itemClassID][itemSubClassID] then
                                    MySacks.VendoringCooldown:Hide()
                                end
                            end, #MySacks.PlayerBagSlotsMap_ItemSubClass[itemClassID][itemSubClassID])
                        elseif IsAltKeyDown() then
                            -- alt sells items, avoids miss sells by clicking
                            MySacks.VendoringCooldown:Show()
                            MySacks.VendoringCooldown.cooldown:SetCooldown(GetTime(), (#MySacks.PlayerBagSlotsMap_ItemSubClass[itemClassID][itemSubClassID] * MySacks.BAG_SLOT_DELAY))
                            local i = 1
                            C_Timer.NewTicker(MySacks.BAG_SLOT_DELAY, function()
                                local location = MySacks.PlayerBagSlotsMap_ItemSubClass[itemClassID][itemSubClassID][i]
                                if location then
                                    --print(string.format('selling bag %s slot %s', location.BagID, location.SlotID))
                                    MySacks.VendorItemByLocation(false, location.BagID, location.SlotID)
                                    i = i + 1
                                end
                                if i > #MySacks.PlayerBagSlotsMap_ItemSubClass[itemClassID][itemSubClassID] then
                                    MySacks.VendoringCooldown:Hide()
                                end
                            end, #MySacks.PlayerBagSlotsMap_ItemSubClass[itemClassID][itemSubClassID])                            
                        end
                    end
                end,
                menuList=MySacks.GenerateLinkMenu(itemClassID, itemSubClassID) or {},
            })
        end
        table.sort(MySacks.ContextMenu_ItemClassMenuList, function(a,b) return a.arg1 < b.arg1 end)
        -- add a separator and total at the bottom
        table.insert(MySacks.ContextMenu_ItemClassMenuList, {
            text = MySacks.ContextMenu_Separator,
            notCheckable=true,
            notClickable=true,
        })
        table.insert(MySacks.ContextMenu_ItemClassMenuList, {
            text = string.format('Total %s', GetCoinTextureString(MySacks.GetItemClassSellTotal(itemClassID))),
            notCheckable=true,
            notClickable=true,
        })
        -- insert menu header
        table.insert(MySacks.ContextMenu_ItemClassMenuList, 1, {
            text = itemClass, 
            isTitle=true, 
            notCheckable=true
        })
    end
    return MySacks.ContextMenu_ItemClassMenuList
end

--- get the total vendor price of an item sub class
function MySacks.GetItemSubClassSellTotal(classID, subClassID)
    local total = 0
    for bag = 0, 4 do
        for slot = 0, GetContainerNumSlots(bag) do
            local link = GetContainerItemLink(bag, slot)
            local id = select(10, GetContainerItemInfo(bag, slot))
            local slotCount = select(2, GetContainerItemInfo(bag, slot))
            if link and id and slotCount then
                --local effectiveILvl, isPreview, baseILvl = GetDetailedItemLevelInfo(link)
                local itemName, itemLink, itemRarity, itemLevel, itemMinLevel, itemType, itemSubType, itemStackCount, itemEquipLoc, itemIcon, itemSellPrice, itemClassID, itemSubClassID, bindType, expacID, itemSetID, isCraftingReagent = GetItemInfo(link)
                if tonumber(itemClassID) == tonumber(classID) and tonumber(itemSubClassID) == tonumber(subClassID) then
                    total = tonumber(total + (slotCount * itemSellPrice))
                end
            end
        end
    end
    return total
end

--- get the total vendor price of an item class
function MySacks.GetItemClassSellTotal(classID)
    local total = 0
    for bag = 0, 4 do
        for slot = 0, GetContainerNumSlots(bag) do
            local link = GetContainerItemLink(bag, slot)
            local id = select(10, GetContainerItemInfo(bag, slot))
            local slotCount = select(2, GetContainerItemInfo(bag, slot))
            if link and id and slotCount then
                --local effectiveILvl, isPreview, baseILvl = GetDetailedItemLevelInfo(link)
                local itemName, itemLink, itemRarity, itemLevel, itemMinLevel, itemType, itemSubType, itemStackCount, itemEquipLoc, itemIcon, itemSellPrice, itemClassID, itemSubClassID, bindType, expacID, itemSetID, isCraftingReagent = GetItemInfo(link)
                if tonumber(itemClassID) == tonumber(classID) then
                    total = tonumber(total + (slotCount * itemSellPrice))
                end
            end
        end
    end
    return total
end

--- this function will loop through the characters bags and update the global saved variables
function MySacks.ScanBags()
    if MySacks.Loaded == true then
        MYSACKS_GLOBAL.Characters[UnitGUID('player')].Bags = {}
        for bag = 0, 4 do
            for slot = 1, GetContainerNumSlots(bag) do
                local link = GetContainerItemLink(bag, slot)
                local id = select(10, GetContainerItemInfo(bag, slot))
                local slotCount = select(2, GetContainerItemInfo(bag, slot))
                if link and id and slotCount then
                    id = tonumber(id)
                    local effectiveILvl, isPreview, baseILvl = GetDetailedItemLevelInfo(link)
                    local itemName, itemLink, itemRarity, itemLevel, itemMinLevel, itemType, itemSubType, itemStackCount, itemEquipLoc, itemIcon, itemSellPrice, itemClassID, itemSubClassID, bindType, expacID, itemSetID, isCraftingReagent = GetItemInfo(link)
                    if not MYSACKS_GLOBAL.Characters[UnitGUID('player')].Bags[id] then
                        MYSACKS_GLOBAL.Characters[UnitGUID('player')].Bags[id] = {
                            Name = tostring(itemName),
                            Link = itemLink,
                            Rarity = tonumber(itemRarity),
                            MinLevel = tonumber(itemMinLevel),
                            Level = tonumber(itemLevel),
                            ClassID = tonumber(itemClassID),
                            SubClassID = tonumber(itemSubClassID),
                            Icon = tonumber(itemIcon),
                            Count = tonumber(slotCount),
                            ExpansionID = tonumber(expacID),
                            VendorPrice = tonumber(itemSellPrice),
                            BagID = tonumber(bag),
                            SlotID = tonumber(slot),
                            EffectiveLevel = tonumber(effectiveILvl),
                        }
                        --print(string.format('added: %s %s %s to bags db', itemName, bag, slot))
                    else
                        MYSACKS_GLOBAL.Characters[UnitGUID('player')].Bags[id].Count = tonumber(MYSACKS_GLOBAL.Characters[UnitGUID('player')].Bags[id].Count + slotCount)
                    end
                end
            end
        end
    else
        MySacks.Print(MySacks.ErrorCodes['initfail'])
    end
end

--- scan player bank and bank bags and update the saved var table
function MySacks.ScanBanks()
    if MySacks.Loaded == true then
        MYSACKS_GLOBAL.Characters[UnitGUID('player')].Bank = {}
        for slot = 1, 28 do
            local link = GetContainerItemLink(-1, slot)
            local id = select(10, GetContainerItemInfo(-1, slot))
            local slotCount = select(2, GetContainerItemInfo(-1, slot))
            if link and id and slotCount then
                id = tonumber(id)
                local effectiveILvl, isPreview, baseILvl = GetDetailedItemLevelInfo(link)
                local itemName, itemLink, itemRarity, itemLevel, itemMinLevel, itemType, itemSubType, itemStackCount, itemEquipLoc, itemIcon, itemSellPrice, itemClassID, itemSubClassID, bindType, expacID, itemSetID, isCraftingReagent = GetItemInfo(link)
                if not MYSACKS_GLOBAL.Characters[UnitGUID('player')].Bank[id] then
                    MYSACKS_GLOBAL.Characters[UnitGUID('player')].Bank[id] = {
                        Name = tostring(itemName),
                        Link = itemLink,
                        Rarity = tonumber(itemRarity),
                        MinLevel = tonumber(itemMinLevel),
                        Level = tonumber(itemLevel),
                        ClassID = tonumber(itemClassID),
                        SubClassID = tonumber(itemSubClassID),
                        Icon = tonumber(itemIcon),
                        Count = tonumber(slotCount),
                        ExpansionID = tonumber(expacID),
                        SellPrice = tonumber(itemSellPrice),
                        BagID = tonumber(bag),
                        SlotID = tonumber(slot),
                        EffectiveLevel = tonumber(effectiveILvl),
                    }
                else
                    MYSACKS_GLOBAL.Characters[UnitGUID('player')].Bank[id].Count = tonumber(MYSACKS_GLOBAL.Characters[UnitGUID('player')].Bank[id].Count + slotCount)
                end
            end
        end
        for bag = 5, 11 do
            for slot = 1, GetContainerNumSlots(bag) do
                local link = GetContainerItemLink(bag, slot)
                local id = select(10, GetContainerItemInfo(bag, slot))
                local slotCount = select(2, GetContainerItemInfo(bag, slot))
                if link and id and slotCount then
                    id = tonumber(id)
                    local effectiveILvl, isPreview, baseILvl = GetDetailedItemLevelInfo(link)
                    local itemName, itemLink, itemRarity, itemLevel, itemMinLevel, itemType, itemSubType, itemStackCount, itemEquipLoc, itemIcon, itemSellPrice, itemClassID, itemSubClassID, bindType, expacID, itemSetID, isCraftingReagent = GetItemInfo(link)
                    if not MYSACKS_GLOBAL.Characters[UnitGUID('player')].Bank[id] then
                        MYSACKS_GLOBAL.Characters[UnitGUID('player')].Bank[id] = {
                            Name = tostring(itemName),
                            Link = itemLink,
                            Rarity = tonumber(itemRarity),
                            MinLevel = tonumber(itemMinLevel),
                            Level = tonumber(itemLevel),
                            ClassID = tonumber(itemClassID),
                            SubClassID = tonumber(itemSubClassID),
                            Icon = tonumber(itemIcon),
                            Count = tonumber(slotCount),
                            ExpansionID = tonumber(expacID),
                            SellPrice = tonumber(itemSellPrice),
                            BagID = tonumber(bag),
                            SlotID = tonumber(slot),
                            EffectiveLevel = tonumber(effectiveILvl),
                        }
                    else
                        MYSACKS_GLOBAL.Characters[UnitGUID('player')].Bank[id].Count = tonumber(MYSACKS_GLOBAL.Characters[UnitGUID('player')].Bank[id].Count + slotCount)
                    end
                end
            end
        end
    else
        MySacks.Print(MySacks.ErrorCodes['initfail'])
    end
end

--- deletes a character from the saved var table or resets the character if its the currently logged in character
function MySacks.DeleteCharacter(guid, name)
    local characterName, class, filename, classID = '', nil, nil, nil
    if not MySacks.PlayerMixin then
        MySacks.PlayerMixin = PlayerLocation:CreateFromGUID(guid)
    else
        MySacks.PlayerMixin:SetGUID(guid)
    end
    if MySacks.PlayerMixin:IsValid() then
        class, filename, classID = C_PlayerInfo.GetClass(MySacks.PlayerMixin)
        characterName = C_PlayerInfo.GetName(MySacks.PlayerMixin) or ''
        if classID then
            characterName = tostring(MySacks.ClassData[tonumber(classID)].FontColour..characterName..'|r')
        end
        if next(MYSACKS_GLOBAL.Characters) then
            if MYSACKS_GLOBAL.Characters[guid] then
                if guid == UnitGUID('player') then -- reset current player
                    MYSACKS_GLOBAL.Characters[guid] = {
                        Bags = {},
                        Bank = {},
                        Reagents = {},
                    }
                    MYSACKS_CHARACTER = {
                        MinimapButton = {},
                        TooltipOptions = {},
                        Merchant = {
                            IgnoreList = {},
                            AutoVendorJunk = false,
                            VendorRules = {
                                ['rarity'] = {
                                    [1] = true,
                                    [2] = true,
                                    [3] = true,
                                    [4] = true,
                                    [5] = true,
                                    [6] = true,
                                },
                                ['boe'] = true,
                                ['armor'] = {
                                    [0] = true,
                                    [1] = true,
                                    [2] = true,
                                    [3] = true,
                                    [4] = true,
                                    [5] = true,
                                    [6] = true,
                                },
                            },
                            ItemlevelThreshold = 100,
                        },
                    }
                    MySacks.Print('reset '..characterName)
                else
                    MYSACKS_GLOBAL.Characters[guid] = nil
                    MySacks.Print('deleted '..characterName)
                end
            end
        end
    else
        -- something
    end
end

--- scan player bags and generate a report table and map tables for class/subClass/junk items
function MySacks.GetBagsReport()
    MySacks.CurrentBagReport = {}
    MySacks.PlayerBagSlotsMap_ItemClass = {}
    MySacks.PlayerBagSlotsMap_ItemSubClass = {}
    MySacks.PlayerBagSlotsMap_JunkRarity = {}
    for bag = 0, 4 do
        for slot = 1, GetContainerNumSlots(bag) do
            local link = GetContainerItemLink(bag, slot)
            local slotCount = select(2, GetContainerItemInfo(bag, slot))
            if link then
                local itemID = select(1, GetItemInfoInstant(link))
                local classID = select(12, GetItemInfo(link))
                local subClassID = select(13, GetItemInfo(link))
                local sellPrice = select(11, GetItemInfo(link))
                local rarity = select(3, GetItemInfo(link))
                local name = select(1, GetItemInfo(link))
                local icon = select(10, GetItemInfo(link))
                if rarity == 0 then
                    table.insert(MySacks.PlayerBagSlotsMap_JunkRarity, {
                        BagID = tonumber(bag), 
                        SlotID = tonumber(slot),
                    })
                end
                if classID and subClassID and sellPrice then
                    if not MySacks.CurrentBagReport[tonumber(classID)] then
                        MySacks.CurrentBagReport[tonumber(classID)] = {}
                    end
                    if not MySacks.PlayerBagSlotsMap_ItemClass[tonumber(classID)] then
                        MySacks.PlayerBagSlotsMap_ItemClass[tonumber(classID)] = {}
                    end
                    table.insert(MySacks.PlayerBagSlotsMap_ItemClass[tonumber(classID)], {
                        BagID = tonumber(bag), 
                        SlotID = tonumber(slot), 
                    })
                    if not MySacks.PlayerBagSlotsMap_ItemSubClass[tonumber(classID)] then
                        MySacks.PlayerBagSlotsMap_ItemSubClass[tonumber(classID)] = {}
                    end
                    if not MySacks.CurrentBagReport[tonumber(classID)][tonumber(subClassID)] then
                        MySacks.CurrentBagReport[tonumber(classID)][tonumber(subClassID)] = {}
                    end
                    if not MySacks.PlayerBagSlotsMap_ItemSubClass[tonumber(classID)][tonumber(subClassID)] then
                        MySacks.PlayerBagSlotsMap_ItemSubClass[tonumber(classID)][tonumber(subClassID)] = {}
                    end
                    table.insert(MySacks.PlayerBagSlotsMap_ItemSubClass[tonumber(classID)][tonumber(subClassID)], { 
                        BagID = tonumber(bag), 
                        SlotID = tonumber(slot),
                    })
                    if not MySacks.CurrentBagReport[tonumber(classID)][tonumber(subClassID)][link] then
                        local ignore = false
                        -- grab ignore value if it exists in saved variables
                        if MYSACKS_CHARACTER.Merchant.IgnoreList[itemID] then
                            ignore = MYSACKS_CHARACTER.Merchant.IgnoreList[itemID]
                        end
                        MySacks.CurrentBagReport[tonumber(classID)][tonumber(subClassID)][link] = { 
                            Rarity = tonumber(rarity), 
                            Count = tonumber(slotCount), 
                            VendorPrice = (tonumber(sellPrice)),
                            --SellPrice = (tonumber(sellPrice) * tonumber(slotCount)),
                            ItemClassID = tonumber(classID),
                            ItemSubClassID = tonumber(subClassID),
                            Link = link,
                            Name = name,
                            ItemID = itemID,
                            Ignore = ignore,
                            Icon = tonumber(icon),
                            LocationMap = {
                                { BagID = tonumber(bag), SlotID = tonumber(slot), },
                            },
                        }
                    else
                        MySacks.CurrentBagReport[tonumber(classID)][tonumber(subClassID)][link].Count = MySacks.CurrentBagReport[tonumber(classID)][tonumber(subClassID)][link].Count + tonumber(slotCount)
                        --MySacks.CurrentBagReport[tonumber(classID)][tonumber(subClassID)][link].SellPrice = tonumber(MySacks.CurrentBagReport[tonumber(classID)][tonumber(subClassID)][link].SellPrice + (tonumber(sellPrice) * tonumber(slotCount)))
                        table.insert(MySacks.CurrentBagReport[tonumber(classID)][tonumber(subClassID)][link].LocationMap, { BagID = tonumber(bag), SlotID = tonumber(slot) })
                    end
                end
            end
        end
    end
end

--- sells an item using a bag/slot values
function MySacks.VendorItemByLocation(ignoreRules, bagID, slotID)
    local link = select(7, GetContainerItemInfo(tonumber(bagID), tonumber(slotID)))
    local sell = true
    if link then
        local itemID = select(1, GetItemInfoInstant(link))
        local itemName, itemLink, itemRarity, itemLevel, itemMinLevel, itemType, itemSubType, itemStackCount, itemEquipLoc, itemIcon, itemSellPrice, itemClassID, itemSubClassID, bindType, expacID, itemSetID, isCraftingReagent = GetItemInfo(link)
        local effectiveILvl, isPreview, baseILvl = GetDetailedItemLevelInfo(link)
        -- check item wasn't marked for ignore in menu list
        if MYSACKS_CHARACTER.Merchant.IgnoreList[itemID] then
            print('id exists', MYSACKS_CHARACTER.Merchant.IgnoreList[itemID])
            if MYSACKS_CHARACTER.Merchant.IgnoreList[itemID] == true then
                sell = false
                --print(string.format('item %s will not be sold as its on ignore list', itemLink))
            end
        end
        -- check if item is weapon > misc (profession tools etc) or weapon > fishing pole
        if tonumber(itemClassID) == 2 then
            if tonumber(itemSubClassID) == 14 or tonumber(itemSubClassID) == 20 then
                -- set this before ignore override to avoid vendoring of tools and fishing poles
                sell = false
                --print(string.format('item %s will not be sold as its a misc/prof weapon/pole', itemLink))
            end
        end
        if ignoreRules == true and sell == true then
            UseContainerItem(bagID, slotID)
            MySacks.Print(tostring('sold '..itemLink..' for '..GetCoinTextureString(itemSellPrice)))
            return itemSellPrice
        elseif ignoreRules == false then
            -- check item level
            if tonumber(effectiveILvl) >= tonumber(MYSACKS_CHARACTER['Merchant'].ItemlevelThreshold) then
                sell = false
                --print(string.format('item %s will not be sold as its ilvl is higher than threshold', itemLink))
            end
            -- check item rarity
            if MYSACKS_CHARACTER['Merchant'].VendorRules['rarity'][tonumber(itemRarity)] == true then
                sell = false
                --print(string.format('item %s will not be sold as its rarity is isnt to be sold', itemLink))
            end
            -- check armor type
            if tonumber(itemClassID) == 4 and MYSACKS_CHARACTER['Merchant'].VendorRules['armor'][tonumber(itemSubClassID)] == true then
                sell = false
                --print(string.format('item %s will not be sold as its armor type isnt to be sold', itemLink))
            end
            -- check boe
            if MYSACKS_CHARACTER['Merchant'].VendorRules['boe'] == true then
                if tonumber(bindType) == 2 then
                    sell = false
                    --print(string.format('item %s will not be sold as its bind type isnt to be sold', itemLink))
                end
            end
            if sell == true then
                UseContainerItem(bagID, slotID)                
                MySacks.Print(string.format('sold %s for %s', itemLink, GetCoinTextureString(itemSellPrice)))
                return itemSellPrice
            end
        end
        if StaticPopup1Button1:IsVisible() then
            StaticPopup1Button1:Click()
        end
    end
end

--- sells an item using an item link, this will loop all bags and slots and vendor all items with matching link
function MySacks.SellItemByLink(itemLink, sellPrice, ignoreRules)
    local sell = true
    for bag = 0, 4 do
        for slot = 1, GetContainerNumSlots(bag) do
            local slotLink = GetContainerItemLink(bag, slot)
            local itemID = select(1, GetItemInfoInstant(itemLink))
            if tostring(slotLink) == tostring(itemLink) then
                local itemName, itemLink, itemRarity, itemLevel, itemMinLevel, itemType, itemSubType, itemStackCount, itemEquipLoc, itemIcon, itemSellPrice, itemClassID, itemSubClassID, bindType, expacID, itemSetID, isCraftingReagent = GetItemInfo(slotLink)
                local effectiveILvl, isPreview, baseILvl = GetDetailedItemLevelInfo(slotLink)
                -- check item wasn't marked for ignore in menu list
                if MYSACKS_CHARACTER.Merchant.IgnoreList[itemID] then
                    print('id exists', MYSACKS_CHARACTER.Merchant.IgnoreList[itemID])
                    if MYSACKS_CHARACTER.Merchant.IgnoreList[itemID] == true then
                        sell = false
                        print(string.format('item %s will not be sold as its on ignore list', itemLink))
                    end
                end
                -- check if item is weapon > misc (prof tools etc) or weapon > fishing pole
                if tonumber(itemClassID) == 2 then
                    if tonumber(itemSubClassID) == 14 or tonumber(itemSubClassID) == 20 then
                        -- set this before ignore override to avoid vendoring of tools and fishing poles
                        sell = false
                        print(string.format('item %s will not be sold as its a misc/prof weapon/pole', itemLink))
                    end
                end
                if sell == true and ignoreRules == true then
                    UseContainerItem(bag, slot)
                    MySacks.Print(string.format('sold %s for %s ', itemLink, GetCoinTextureString(itemSellPrice)))
                elseif ignoreRules == false then
                    -- check item level
                    if tonumber(effectiveILvl) >= tonumber(MYSACKS_CHARACTER['Merchant'].ItemlevelThreshold) then
                        sell = false
                        print(string.format('item %s will not be sold as its ilvl is higher than threshold', itemLink))
                    end
                    -- check item rarity
                    if MYSACKS_CHARACTER['Merchant'].VendorRules['rarity'][tonumber(itemRarity)] == true then
                        sell = false
                        print(string.format('item %s will not be sold as its rarity is isnt to be sold', itemLink))
                    end
                    -- check armor type
                    if tonumber(itemClassID) == 4 and MYSACKS_CHARACTER['Merchant'].VendorRules['armor'][tonumber(itemSubClassID)] == true then
                        sell = false
                        print(string.format('item %s will not be sold as its armor type isnt to be sold', itemLink))
                    end
                    -- check boe
                    if MYSACKS_CHARACTER['Merchant'].VendorRules['boe'] == true then
                        if tonumber(bindType) == 2 then
                            sell = false
                            print(string.format('item %s will not be sold as its bind type isnt to be sold', itemLink))
                        end
                    end
                    if sell == true then
                        UseContainerItem(bag, slot)
                        MySacks.Print(tostring('sold '..itemLink..' for '..GetCoinTextureString(itemSellPrice)))
                    end
                end
                if StaticPopup1Button1:IsVisible() then
                    StaticPopup1Button1:Click()
                end
                -- if sell == true then
                --     UseContainerItem(bag, slot)
                --     MySacks.Print(string.format('sold %s for %s ', itemLink, GetCoinTextureString(itemSellPrice)))
                -- end
                sell = true
            end
        end
    end
end

--- update auto vendor junk rule
function MySacks.ToggleAutoVendorJunk()
    if not MYSACKS_CHARACTER['Merchant'] then
        MYSACKS_CHARACTER['Merchant'] = {}
    end
    MYSACKS_CHARACTER['Merchant'].AutoVendorJunk = not MYSACKS_CHARACTER['Merchant'].AutoVendorJunk
    MySacks.Print('auto vendor junk rule: '..tostring(MYSACKS_CHARACTER['Merchant'].AutoVendorJunk))
end

--- update auto vendor rule
function MySacks.SetVendorRule(rule, subRule)
    if not MYSACKS_CHARACTER['Merchant'] then
        MYSACKS_CHARACTER['Merchant'] = {}
    end
    if not MYSACKS_CHARACTER['Merchant'].VendorRules then
        MYSACKS_CHARACTER['Merchant'].VendorRules = {}
    end
    if subRule ~= nil then
        MYSACKS_CHARACTER['Merchant'].VendorRules[rule][subRule] = not MYSACKS_CHARACTER['Merchant'].VendorRules[rule][subRule]
    else
        MYSACKS_CHARACTER['Merchant'].VendorRules[rule] = not MYSACKS_CHARACTER['Merchant'].VendorRules[rule]
    end       
end

--- wipe all global data
function MySacks.WipeGlobalSavedVariables()
    for guid, character in pairs(MYSACKS_GLOBAL.Characters) do
        character.Bags = {}
        character.Bank = {}
        character.Reagents = {}
    end
end

--- setup the report frame
function MySacks:SetupReportFrame()

    --136831 tabs texture

    self.ReportFrame:SetScript('OnShow', function(self)
        -- self.GoldText:SetText(GetCoinTextureString(MySacks.CurrentSession['gold']))
        -- self.ItemsLootedGoldText:SetText(GetCoinTextureString(MySacks.CurrentSession['lootedItemsValue']))
    end)

    self.CurrentSession = {
        ['gold'] = 0,
        ['lootedItems'] = {},
        ['lootedItemsValue'] = 0,
    }
    self.LootedItemsTreeviewTable = {}
    
    local vendorMenuText = self.ReportFrame:CreateFontString(nil, 'OVERLAY', 'GameFontNormal')
    vendorMenuText:SetPoint('TOP', 0, -16)
    vendorMenuText:SetText('My Sacks Report')

    local closeButton = CreateFrame('BUTTON', 'MySacksReportFrameCloseButton', self.ReportFrame, "UIPanelButtonTemplate")
    closeButton:SetPoint('TOPRIGHT', -10, -10)
    closeButton:SetSize(24, 22)
    closeButton:SetNormalTexture(130832)
    closeButton:GetNormalTexture():SetTexCoord(0.1, 0.9, 0.1, 0.85)
    closeButton:SetHighlightTexture(130831)
    closeButton:GetHighlightTexture(130831):SetTexCoord(0.1, 0.9, 0.1, 0.85)
    closeButton:SetScript('OnClick', function(self)
        self:GetParent():Hide()
    end)

    local goldText = self.ReportFrame:CreateFontString(nil, 'OVERLAY', 'GameFontNormal')
    goldText:SetPoint('TOPLEFT', 16, -48)
    goldText:SetText('Gold looted')

    self.ReportFrame.GoldText = self.ReportFrame:CreateFontString(nil, 'OVERLAY', 'GameFontNormal')
    self.ReportFrame.GoldText:SetPoint('LEFT', goldText, 'RIGHT', 10, 0)
    self.ReportFrame.GoldText:SetTextColor(1,1,1,1)
    self.ReportFrame.GoldText:SetText(GetCoinTextureString(MySacks.CurrentSession['gold']))

    local itemsGoldText = self.ReportFrame:CreateFontString(nil, 'OVERLAY', 'GameFontNormal')
    itemsGoldText:SetPoint('TOPLEFT', goldText, 'BOTTOMLEFT', 0, -4)
    itemsGoldText:SetText('Items looted vendor value')

    self.ReportFrame.ItemsLootedGoldText = self.ReportFrame:CreateFontString(nil, 'OVERLAY', 'GameFontNormal')
    self.ReportFrame.ItemsLootedGoldText:SetPoint('LEFT', itemsGoldText, 'RIGHT', 10, 0)
    self.ReportFrame.ItemsLootedGoldText:SetTextColor(1,1,1,1)
    self.ReportFrame.ItemsLootedGoldText:SetText(GetCoinTextureString(MySacks.CurrentSession['lootedItemsValue']))

    local resetSessionButton = CreateFrame('BUTTON', 'MySacksReportFrameResetSessionButton', self.ReportFrame, "UIPanelButtonTemplate")
    resetSessionButton:SetPoint('TOPRIGHT', -16, -48)
    resetSessionButton:SetText('Reset Session')
    resetSessionButton:SetSize(100, 22)
    resetSessionButton:SetScript('OnClick', function(self)
        MySacks.CurrentSession['gold'] = 0
        MySacks.CurrentSession['lootedItems'] = {}
        MySacks.CurrentSession['lootedItemsValue'] = 0
        self:GetParent().GoldText:SetText(GetCoinTextureString(MySacks.CurrentSession['gold']))
        self:GetParent().ItemsLootedGoldText:SetText(GetCoinTextureString(MySacks.CurrentSession['lootedItemsValue']))
        print('MySacks: '..FONT_COLOUR..'your current session has been reset')
    end)

    local currentSessionTreeviewContainer = CreateFrame('FRAME', 'MySacksReportFrameTreeviewContainer', self.ReportFrame)
    currentSessionTreeviewContainer:SetPoint('TOPLEFT', self.ReportFrame, 'TOPLEFT', 16, -130)
    currentSessionTreeviewContainer:SetPoint('TOPRIGHT', self.ReportFrame, 'TOPRIGHT', -36, -130)
    currentSessionTreeviewContainer:SetHeight(300)

    currentSessionTreeviewContainer.itemsHeader = currentSessionTreeviewContainer:CreateFontString(nil, 'OVERLAY', 'GameFontNormal')
    currentSessionTreeviewContainer.itemsHeader:SetPoint('BOTTOMLEFT', currentSessionTreeviewContainer, 'TOPLEFT', 4, 2)
    currentSessionTreeviewContainer.itemsHeader:SetText(LOCALES['items'])
    currentSessionTreeviewContainer.itemsHeader:SetWidth(300)
    currentSessionTreeviewContainer.itemsHeader:SetJustifyH('LEFT')
    currentSessionTreeviewContainer.itemsCountHeader = currentSessionTreeviewContainer:CreateFontString(nil, 'OVERLAY', 'GameFontNormal')
    currentSessionTreeviewContainer.itemsCountHeader:SetPoint('LEFT', currentSessionTreeviewContainer.itemsHeader, 'RIGHT', 20, 0)
    currentSessionTreeviewContainer.itemsCountHeader:SetText(LOCALES['count'])
    currentSessionTreeviewContainer.itemsCountHeader:SetWidth(75)
    currentSessionTreeviewContainer.itemsCountHeader:SetJustifyH('LEFT')
    currentSessionTreeviewContainer.itemsVendorPriceHeader = currentSessionTreeviewContainer:CreateFontString(nil, 'OVERLAY', 'GameFontNormal')
    currentSessionTreeviewContainer.itemsVendorPriceHeader:SetPoint('LEFT', currentSessionTreeviewContainer.itemsCountHeader, 'RIGHT', 4, 0)
    currentSessionTreeviewContainer.itemsVendorPriceHeader:SetText(LOCALES['vendorPrice'])
    currentSessionTreeviewContainer.itemsVendorPriceHeader:SetJustifyH('LEFT')

    self.ReportFrame.CurrentSessionTreeviewRows = {}
    for i = 1, 20 do
        local f = CreateFrame('FRAME', 'MySacksReportFrameCurrentSessionTreeviewRow'..i, currentSessionTreeviewContainer)
        f:SetPoint('TOPLEFT', 0, (i - 1) * -15)
        f:SetPoint('TOPRIGHT', 0, i * -15)
        f:SetHeight(14)
        f.background = f:CreateTexture(nil, 'BACKGROUND')
        f.background:SetAllPoints(f)
        f.background:SetColorTexture(0.3,0.3,0.3,0.2)
        f.data = {}

        f.expandButton = CreateFrame('BUTTON', 'MySacksReportFrameCurrentSessionTreeviewRow'..i..'ExpandButton', f)
        f.expandButton:SetPoint('LEFT', 4, 0)
        f.expandButton:SetSize(12, 12)
        f.expandButton:SetNormalTexture(130838)
        f.expandButton:SetPushedTexture(130836)
        f.expandButton.state = false
        f.expandButton:SetScript('OnClick', function(self)
            if self:GetParent().data then
                self:GetParent().data.Expand = not self:GetParent().data.Expand
                self:SetNormalTexture(self:GetParent().data.Expand and 130821 or 130838)
                self:SetPushedTexture(self:GetParent().data.Expand and 130820 or 130836)
                MySacks:HideCurrentSessionTreeviewRows()
                for k, v in ipairs(MySacks.CurrentSession['lootedItems']) do
                    if v.ClassID == self:GetParent().data.ClassID then
                        v.Visible = self:GetParent().data.Expand
                    end
                    if v.Parent == true then
                        v.Visible = true
                    end
                end      
                local c = 0
                for k, v in ipairs(MySacks.CurrentSession['lootedItems']) do
                    if v.Visible == true then
                        c = c + 1
                    end
                end
                if c <= 20 then
                    MySacks.ReportFrame.CurrentSessionTreeviewScrollBar:SetMinMaxValues(1, 1)
                else
                    MySacks.ReportFrame.CurrentSessionTreeviewScrollBar:SetMinMaxValues(1, c - 19)
                end        
                MySacks:RefreshCurrentSessionTreeviewRows()
                C_Timer.After(0.05, function() MySacks:RefreshCurrentSessionTreeviewRows() end)
            end
        end)

        f.itemName = f:CreateFontString(nil, 'OVERLAY', 'GameFontNormalSmall')
        f.itemName:SetPoint('LEFT', 16, 0)
        f.itemName:SetWidth(300)
        f.itemName:SetText('test item name'..i)
        f.itemName:SetJustifyH('LEFT')
        f.itemCount = f:CreateFontString(nil, 'OVERLAY', 'GameFontNormalSmall')
        f.itemCount:SetPoint('LEFT', f.itemName, 'RIGHT', 4, 0)
        f.itemCount:SetWidth(70)
        f.itemCount:SetTextColor(1,1,1,1)
        f.itemCount:SetJustifyH('LEFT')
        f.itemVendorPrice = f:CreateFontString(nil, 'OVERLAY', 'GameFontNormalSmall')
        f.itemVendorPrice:SetPoint('LEFT', f.itemCount, 'RIGHT', 4, 0)
        f.itemVendorPrice:SetWidth(140)
        f.itemVendorPrice:SetTextColor(1,1,1,1)
        f.itemVendorPrice:SetJustifyH('LEFT')

        -- f.deleteButton = CreateFrame('BUTTON', 'MySacksReportFrameCurrentSessionTreeviewRow'..i..'DeleteButton', f)
        -- f.deleteButton:SetPoint('LEFT', f.itemVendorPrice, 'RIGHT', 0, 0)
        -- f.deleteButton:SetSize(16, 16)
        -- --f.deleteButton:SetNormalTexture(130775) -- red no smoking style icon
        -- f.deleteButton:SetNormalTexture(130952)
        -- f.deleteButton:SetPushedTexture(130951)
        -- f.deleteButton:SetScript('OnClick', function(self)
        --     print('clcik')
        --     MySacks.ContextMenu = {
        --         {
        --             text = 'Options',
        --             isTitle = true,
        --             notCheckable = true,
        --         },
        --         {
        --             text = self:GetParent().data.itemName,
        --             isTitle = true,
        --             notCheckable = true,
        --         },
        --     }
        --     EasyMenu(MySacks.ContextMenu, MySacks.ContextMenu_MerchantDropDown, f.deleteButton, 0, 10)
        -- end)
        
        f:SetScript('OnShow', function(self)
            if self.data then
                self.expandButton:SetNormalTexture(self.data.Expand and 130821 or 130838)
                self.expandButton:SetPushedTexture(self.data.Expand and 130820 or 130836)
                if self.data.Parent == true then
                    self.expandButton:Show()
                    self.deleteButton:Hide()
                    self.itemName:SetText(self.data.DisplayText)
                    self.itemName:SetTextColor(NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b, 1)
                    self.itemVendorPrice:SetText(GetCoinTextureString(MySacks:GetCurrentSessionClassVendorPriceTotal(self.data.ClassID), 10))
                else
                    self.deleteButton:Show()
                    self.itemName:SetText('  '..self.data.Link)
                    self.itemName:SetTextColor(1,1,1,1)
                    self.itemCount:SetText(self.data.Count)
                    self.itemVendorPrice:SetText(GetCoinTextureString(self.data.VendorPrice, 10))
                end
            end        
        end)
        f:SetScript('OnHide', function(self)
            self.expandButton:Hide()
            self.itemName:SetText(' ')
            self.itemCount:SetText(' ')
            self.itemVendorPrice:SetText(' ')
        end)
        f:Hide()
        self.ReportFrame.CurrentSessionTreeviewRows[i] = f
    end

    self.ReportFrame.CurrentSessionTreeviewScrollBar = CreateFrame('SLIDER', 'MySacksReportFrameCurrentSessionTreeviewRowScrollBar', currentSessionTreeviewContainer, "UIPanelScrollBarTemplate")
    self.ReportFrame.CurrentSessionTreeviewScrollBar:SetPoint('TOPLEFT', currentSessionTreeviewContainer, 'TOPRIGHT', 28, -17)
    self.ReportFrame.CurrentSessionTreeviewScrollBar:SetPoint('BOTTOMRIGHT', currentSessionTreeviewContainer, 'BOTTOMRIGHT', 0, 16)
    self.ReportFrame.CurrentSessionTreeviewScrollBar:EnableMouse(true)
    self.ReportFrame.CurrentSessionTreeviewScrollBar:SetValueStep(0.1)
    self.ReportFrame.CurrentSessionTreeviewScrollBar:SetValue(1)
    self.ReportFrame.CurrentSessionTreeviewScrollBar:SetScript('OnValueChanged', function(self)
        MySacks:RefreshCurrentSessionTreeviewRows()
    end)

    self.ReportFrame:Hide()
end

function MySacks:RefreshCurrentSessionTreeviewRows()
    MySacks:HideCurrentSessionTreeviewRows()
    local scrollPos = math.floor(self.ReportFrame.CurrentSessionTreeviewScrollBar:GetValue()) - 1.0
    local row = 1
    for i = 1, 20 do
        if self.CurrentSession['lootedItems'][i + scrollPos] and self.CurrentSession['lootedItems'][i + scrollPos].Visible == true then
            --print(string.format('table obj[%s, %s] exists and is set to visible, binding to row [%s]', (i + scrollPos), self.CurrentSession['lootedItems'][i + scrollPos].DisplayText, row))
            MySacks.ReportFrame.CurrentSessionTreeviewRows[row].data = self.CurrentSession['lootedItems'][i + scrollPos]
            if self.CurrentSession['lootedItems'][i + scrollPos].Parent == true then
                MySacks.ReportFrame.CurrentSessionTreeviewRows[row].background:SetColorTexture(0.2,0.2,0.0,0.3)
            else
                MySacks.ReportFrame.CurrentSessionTreeviewRows[row].background:SetColorTexture(0.3,0.3,0.3,0.2)
            end
            MySacks.ReportFrame.CurrentSessionTreeviewRows[row]:Show()
            row = row + 1
        else
            -- something
            --print(string.format('skipping table obj[%s]', (i + scrollPos)))
        end
    end
end

function MySacks:HideCurrentSessionTreeviewRows()
    for i = 1, 20 do
        self.ReportFrame.CurrentSessionTreeviewRows[i]:Hide()
    end
end


function MySacks:GetCurrentSessionClassVendorPriceTotal(classID)
    local gold = 0.0
    for k, info in ipairs(self.CurrentSession['lootedItems']) do
        if info.ClassID == classID then
            gold = gold + info.VendorPrice
        end
    end
    return tonumber(gold)
end


function MySacks:CurrentSessionParseLootedItemInfo(...)
    local msg = select(1, ...)
    local i, t, lootCount = 1, {}, 1
    for d in msg:gmatch('%S+') do
        t[i] = d
        i = i + 1
    end
    local s = t[i-1]:find('|h|rx')
    local e = t[i-1]:len() - 1
    if s then
        lootCount = t[i-1]:sub(s + 5, e)
    end
    if msg:find('You receive') then
        local itemID = MySacks.GetItemIdFromString(msg)
        if itemID then
            local itemName, itemLink, itemRarity, _, _, _, _, _, _, itemIcon, itemSellPrice, itemClassID, itemSubClassID, bindType, _, _, _ = GetItemInfo(itemID)
            if itemSellPrice and itemClassID and itemSubClassID then
                if not MySacks.CurrentSessionLootedClassIDs[itemClassID] then
                    MySacks.CurrentSessionLootedClassIDs[itemClassID] = true
                    table.insert(self.CurrentSession['lootedItems'], {
                        DisplayText = GetItemClassInfo(tonumber(itemClassID)),
                        Link = false,
                        ItemID = false,
                        Rarity = itemRarity,
                        ClassID = itemClassID,
                        SubClassID = -1.0,
                        Count = 0,
                        VendorPrice = 0.0,
                        Parent = true,
                        Expand = false,
                        Visible = true,
                    })
                end
                local exists = false
                for k, v in ipairs(self.CurrentSession['lootedItems']) do
                    if v.ItemID == itemID then
                        exists = true
                        v.Count = v.Count + lootCount
                        v.VendorPrice = v.VendorPrice + (itemSellPrice * lootCount)
                    end
                end
                if exists == false then
                    table.insert(self.CurrentSession['lootedItems'], {
                        DisplayText = itemName,
                        Link = itemLink,
                        ItemID = itemID,
                        Rarity = itemRarity,
                        ClassID = itemClassID,
                        SubClassID = itemSubClassID,
                        Count = lootCount,
                        VendorPrice = itemSellPrice * (lootCount or 1),
                        Parent = false,
                        Expand = false,
                        Visible = false,
                    })
                    --print(string.format('added %s with classID %s to current session loot table', itemLink, itemClassID))
                end
                table.sort(self.CurrentSession['lootedItems'], function(a, b)
                    if a.ClassID == b.ClassID then
                        if a.SubClassID == b.SubClassID then
                            --return a.DisplayText < b.DisplayText
                            return a.VendorPrice > b.VendorPrice
                        else
                            return a.SubClassID < b.SubClassID
                        end
                    else
                        return a.ClassID < b.ClassID
                    end
                end)
                local c = 0
                for k, v in ipairs(self.CurrentSession['lootedItems']) do
                    if v.Parent == true then
                        c = c + 1
                    end
                end
                if c <= 20 then
                    self.ReportFrame.CurrentSessionTreeviewScrollBar:SetMinMaxValues(1, 1)
                else
                    self.ReportFrame.CurrentSessionTreeviewScrollBar:SetMinMaxValues(1, c - 19)
                end
                --self:RefreshCurrentSessionTreeviewRows()
                self.CurrentSession['lootedItemsValue'] = self.CurrentSession['lootedItemsValue'] + (itemSellPrice * lootCount)
                self.ReportFrame.ItemsLootedGoldText:SetText(GetCoinTextureString(MySacks.CurrentSession['lootedItemsValue']))
            end
        end
        self:RefreshCurrentSessionTreeviewRows()
    end
end

function MySacks:GetLootedGoldValue(msg)
    msg = msg:gsub('Copper.', 'Copper')
    msg = msg:gsub('Silver,', 'Silver')
    msg = msg:gsub('Gold,', 'Gold')
    local t = {}
    for d in msg:gmatch('%S+') do
        table.insert(t, d)
    end
    local gold = { 
        ['Gold'] = 0,
        ['Silver'] = 0,
        --['Copper.'] = 0,
        ['Copper'] = 0
    }
    for k, v in ipairs(t) do
        if gold[v] then
            if v == 'Gold' then
                --print('gold', t[k-1])
                gold[v] = t[k-1] * 10000
            elseif v == 'Silver' then
                --print('silver', t[k-1])
                gold[v] = t[k-1] * 100
            else
                --print('copper', t[k-1])
                gold[v] = t[k-1]
            end
        end
    end
    local g = gold['Gold'] + gold['Silver'] + gold['Copper']
    if g then
        return tonumber(g)
    else
        return false
    end
end

----------------------------------------------------------------------------------------------------
-- init
----------------------------------------------------------------------------------------------------
function MySacks.Init()
    if not MYSACKS_CHARACTER then 
        MYSACKS_CHARACTER = {
            MinimapButton = {},
            TooltipOptions = {},
            Merchant = {
                IgnoreList = {},
                AutoVendorJunk = false,
                VendorRules = {
                    ['rarity'] = {
                        [1] = true,
                        [2] = true,
                        [3] = true,
                        [4] = true,
                        [5] = true,
                        [6] = true,
                    },
                    ['boe'] = true,
                    ['armor'] = {
                        [0] = true,
                        [1] = true,
                        [2] = true,
                        [3] = true,
                        [4] = true,
                        [5] = true,
                        [6] = true,
                    },
                },
                ItemlevelThreshold = 100,
            },
        }
    end
    if not MYSACKS_GLOBAL then 
        MYSACKS_GLOBAL = {
            AddonName = addonName,
            Characters = {},
        } 
    end
    local guid = UnitGUID('player')
    if guid then
        if not MYSACKS_GLOBAL.Characters[guid] then
            MYSACKS_GLOBAL.Characters[guid] = {
                Bags = {},
                Bank = {},
                Reagents = {},
            }
        end
        MySacks.Loaded = true
        MySacks.Print('loaded successfully!')
        --MySacks.CreateMinimapButton()
        
        GameTooltip:HookScript("OnTooltipSetItem", MySacks.OnTooltipSetItem)
        GameTooltip:HookScript("OnTooltipCleared", MySacks.OnTooltipCleared)

        -- hook all bags ?
        ContainerFrame1:HookScript("OnShow", MySacks.ScanBags)

        local vendorMenuDropdown = CreateFrame('FRAME', "MySacksMerchantFrameVendorMenuDropdown", MerchantFrameLootFilter, "UIDropDownMenuTemplate")
        vendorMenuDropdown:SetPoint('RIGHT', MerchantFrameLootFilter, 'LEFT', 25, 0)
        UIDropDownMenu_SetWidth(vendorMenuDropdown, 80)
        UIDropDownMenu_SetText(vendorMenuDropdown, 'MySacks')
        _G['MySacksMerchantFrameVendorMenuDropdownButton']:SetScript('OnClick', function(self)
            if not IsControlKeyDown() then
                MySacks.GenerateMerchantButtonContextMenu()
                EasyMenu(MySacks.ContextMenu, MySacks.ContextMenu_MerchantDropDown, vendorMenuDropdown, 10 , 10) --, "MENU")
                if MYSACKS_CHARACTER['Merchant'].AutoVendorJunk == true then
                    MySacks.SellJunk()
                end
            elseif IsControlKeyDown() then
                MySacks.GenerateMerchantButtonContextMenu()
                EasyMenu(MySacks.ContextMenu, MySacks.ContextMenu_MerchantDropDown, vendorMenuDropdown, 10 , 10) --, "MENU")
            end
        end)

        MySacks.ReportFrame = CreateFrame('FRAME', 'MySacksReportFrame', UIParent, BackdropTemplateMixin and "BackdropTemplate")
        MySacks.MakeFrameMovable(MySacks.ReportFrame)
        MySacks.ReportFrame:SetPoint('CENTER', 0, 0)
        MySacks.ReportFrame:SetSize(600, 450)
        MySacks.ReportFrame:SetBackdrop({
            edgeFile = "interface/dialogframe/ui-dialogbox-border",
            edgeSize = 32,
            bgFile = "interface/dialogframe/ui-dialogbox-background-dark",
            tile = true,
            tileEdge = false,
            tileSize = 200,
            insets = { left = 4, right = 4, top = 4, bottom = 4 }
        })
        MySacks:SetupReportFrame()

        local mailButton = CreateFrame('BUTTON', 'MySacksMerchantFramePortraitButton', SendMailFrame)
        mailButton:SetPoint('TOPLEFT', SendMailSendMoneyButtonText, 'TOPRIGHT', 12, -2)
        mailButton:SetSize(24, 24)
        mailButton:SetScript('OnClick', function(self)
            MySacks.GenerateMailButtonContextMenu()
            EasyMenu(MySacks.ContextMenu, MySacks.ContextMenu_MerchantDropDown, "cursor", 0 , 0, "MENU")
        end)
        mailButton:SetNormalTexture(130838)
        mailButton:SetPushedTexture(130836)

        MySacks.VendoringCooldown = CreateFrame('FRAME', 'MySacksVendoringCooldown', UIParent)
        MySacks.VendoringCooldown:SetSize(50, 50)
        MySacks.VendoringCooldown:SetPoint('CENTER', 0, 0)
        MySacks.VendoringCooldown.texture = MySacks.VendoringCooldown:CreateTexture('$parentTexture', 'ARTWORK')
        MySacks.VendoringCooldown.texture:SetAllPoints(MySacks.VendoringCooldown)
        MySacks.VendoringCooldown.texture:SetTexture(133785)
        MySacks.VendoringCooldown.cooldown = CreateFrame("Cooldown", "$parentCooldown", MySacks.VendoringCooldown, "CooldownFrameTemplate")
        MySacks.VendoringCooldown.cooldown:SetFrameLevel(6)
        MySacks.VendoringCooldown.cooldown:SetAllPoints(MySacks.VendoringCooldown)
        MySacks.VendoringCooldown.cooldown:Show()
        MySacks.VendoringCooldown:Hide()

    else
        MySacks.Print(MySacks.ErrorCodes['noguid'])
        MySacks.Loaded = false
    end
end

----------------------------------------------------------------------------------------------------
-- register events
----------------------------------------------------------------------------------------------------
MySacks.EventFrame = CreateFrame('FRAME', 'MySacksEventFrame', UIParent)
MySacks.EventFrame:RegisterEvent('ADDON_LOADED')
MySacks.EventFrame:RegisterEvent('PLAYER_LOGOUT')
MySacks.EventFrame:RegisterEvent('MERCHANT_SHOW')
MySacks.EventFrame:RegisterEvent('MERCHANT_CLOSED')
MySacks.EventFrame:RegisterEvent('BANKFRAME_OPENED')
MySacks.EventFrame:RegisterEvent('CHAT_MSG_MONEY')
MySacks.EventFrame:RegisterEvent('CHAT_MSG_LOOT')
MySacks.EventFrame:SetScript("OnEvent", function(self, event, ...)
    MySacks[event](MySacks, ...)
end)


function MySacks:ADDON_LOADED(...)
    if select(1, ...):lower() == "mysacks" then
        C_Timer.After(2, MySacks.Init)
    end
end

function MySacks:MERCHANT_SHOW(...)
    MySacks.ScanBags()
end

function MySacks:MERCHANT_CLOSED(...)
    CloseDropDownMenus()
end

function MySacks:BANKFRAME_OPENED(...)
    MySacks.ScanBanks()
end

function MySacks:CHAT_MSG_MONEY(...)
    local msg = select(1, ...)
    if msg:find('You') then
        local gold = self:GetLootedGoldValue(msg)
        if gold then
            self.CurrentSession['gold'] = self.CurrentSession['gold'] + gold
            self.ReportFrame.GoldText:SetText(GetCoinTextureString(MySacks.CurrentSession['gold']))
        end
    end
end


function MySacks:CHAT_MSG_LOOT(...)
    self:CurrentSessionParseLootedItemInfo(...)
end