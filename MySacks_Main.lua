

-- 1519426 bag icon

local addonName, MySacks = ...

local LOCALES = MySacks.Locales

MySacks.FONT_COLOUR = '|cffA330C9'
MySacks.BAG_VENDOR_DELAY = 1.0
MySacks.BAG_SLOT_DELAY = 0.1
MySacks.PlayerMixin = nil
MySacks.CurrentBagReport = {}
MySacks.ContextMenu = {}
MySacks.ContextMenu_Separator = "|TInterface/COMMON/UI-TooltipDivider:8:150|t"
MySacks.ContextMenu_MerchantDropDown = CreateFrame("Frame", "MySacksContextMenuMerchantDropDown", UIParent, "UIDropDownMenuTemplate")
MySacks.ContextMenu_UIParentDropDown = CreateFrame("Frame", "MySacksContextMenuUIParentDropDown", UIParent, "UIDropDownMenuTemplate")
MySacks.ContextMenu_UIParentDropDown:SetPoint('CENTER', 0, 0)
MySacks.ContextMenu_UIParentDropDown:Hide()
MySacks.ContextMenu_SoldIcon = 132050

MySacks.PlayerBagSlotsMap_JunkRarity = {}
MySacks.PlayerBagSlotsMap_ItemClass = {}
MySacks.PlayerBagSlotsMap_ItemSubClass = {}

MySacks.Loaded = false

MySacks.ErrorCodes = {
    ['noguid'] = 'guid not ready',
    ['initfail'] = 'addon not initialised properly',
    ['tooltipitemerror'] = 'unable to get tooltip item data',
    ['playermixinerror'] = 'unable to get player mixin data',
}

MySacks.Tooltip = {
    Item = {},
    Keys = { 
        'Name', 
        'Link', 
        'Rarity', 
        'Level', 
        'MinLevel', 
        'Type', 
        'SubType', 
        'StackCount', 
        'EquipLocation', 
        'Icon', 
        'SellPrice', 
        'ClassID', 
        'SubClassID', 
        'BindType',
        'ExpansionID',
    },
}

MySacks.ExpansionIdToName = {
    [0] = { Short = 'WOW', Full = 'World of Warcraft' },
    [1] = { Short = 'TBC', Full = 'The Buring Crusades' },
    [2] = { Short = 'WOTLK', Full = 'Wrath of the Lich King' },
    [3] = { Short = 'CATA', Full = 'Cataclysm' },
    [4] = { Short = 'MOP', Full = 'Mist of Pandaria' },
    [5] = { Short = 'WOD', Full = 'Warloards of Draenor' },
    [6] = { Short = 'LEGION', Full = 'Legion' },
    [7] = { Short = 'BFA', Full = 'Battle for Azeroth' },
    [8] = { Short = 'SL', Full = 'Shadowlands' },
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

--132067 132068
--136781 136782
MySacks.RaceInfo = {
    [-1] = { Name = 'Unknown', Faction = 'Unknown', IconID = nil, }, -- fallback option
    [1] = { Name = 'Human', Faction = 'Alliance', IconID = 2175463, },
    [2] = { Name = 'Orc', Faction = 'Horde', IconID = 2175464, },
    [3] = { Name = 'Dwarf', Faction = 'Alliance', IconID = 2175463, },
    [4] = { Name = 'NightElf', Faction = 'Alliance', IconID = 2175463, },
    [5] = { Name = 'Scourge', Faction = 'Horde', IconID = 2175464, },
    [6] = { Name = 'Tauren', Faction = 'Horde', IconID = 2175464, },
    [7] = { Name = 'Gnome', Faction = 'Alliance', IconID = 2175463, },
    [8] = { Name = 'Troll', Faction = 'Horde', IconID = 2175464, },
    [9] = { Name = 'Goblin', Faction = 'Horde', IconID = 2175464, },
    [10] = { Name = 'BloodElf', Faction = 'Horde', IconID = 2175464, },
    [11] = { Name = 'Draenei', Faction = 'Alliance', IconID = 2175463, },
    [12] = { Name = 'FelOrc', Faction = 'Alliance', IconID = 2175463, },
    [13] = { Name = 'Naga_', Faction = 'Alliance', IconID = 2175463, },
    [14] = { Name = 'Broken', Faction = 'Alliance', IconID = 2175463, },
    [15] = { Name = 'Skeleton', Faction = 'Alliance', IconID = 2175463, },
    [16] = { Name = 'Vrykul', Faction = 'Alliance', IconID = 2175463, },
    [17] = { Name = 'Tuskarr', Faction = 'Alliance', IconID = 2175463, },
    [18] = { Name = 'ForestTroll', Faction = 'Alliance', IconID = 2175463, },
    [19] = { Name = 'Taunka', Faction = 'Alliance', IconID = 2175463, },
    [20] = { Name = 'NorthrendSkeleton', Faction = 'Alliance', IconID = 2175463, },
    [21] = { Name = 'IceTroll', Faction = 'Alliance', IconID = 2175463, },
    [22] = { Name = 'Worgen', Faction = 'Alliance', IconID = 2175463, },
    [23] = { Name = 'Human', Faction = 'Alliance', IconID = 2175463, },
    [24] = { Name = 'Pandaren', Faction = 'Neutral', IconID = 2175463, },
    [25] = { Name = 'Pandaren', Faction = 'Alliance', IconID = 2175463, },
    [26] = { Name = 'Pandaren', Faction = 'Horde', IconID = 2175464, },
    [27] = { Name = 'Nightborne', Faction = 'Horde', IconID = 2175464, },
    [28] = { Name = 'HighmountainTauren', Faction = 'Horde', IconID = 2175464, },
    [29] = { Name = 'VoidElf', Faction = 'Alliance', IconID = 2175463, },
    [30] = { Name = 'LightforgedDraenei', Faction = 'Alliance', IconID = 2175463, },
    [31] = { Name = 'ZandalariTroll', Faction = 'Horde', IconID = 2175464, },
    [32] = { Name = 'KulTiran', Faction = 'Alliance', IconID = 2175463, },
    [33] = { Name = 'ThinHuman', Faction = 'Alliance', IconID = 2175463, },
    [34] = { Name = 'DarkIronDwarf', Faction = 'Alliance', IconID = 2175463, },
    [35] = { Name = 'Vulpera', Faction = 'Alliance', IconID = 2175463, },
    [36] = { Name = 'MagharOrc', Faction = 'Horde', IconID = 2175464, },
    [37] = { Name = 'Mechagnome', Faction = 'Alliance', IconID = 2175463, },
}

--Item binding type: 0 - none; 1 - on pickup; 2 - on equip; 3 - on use; 4 - quest.

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

--- returns an item id using an item link
-- @param link the item link to extract an id from
-- @return id the item id 
function MySacks.GetItemIdFromLink(link)
    if string.find(link, '|Hitem') then
        local l = string.sub(tostring(link), (string.find(link, '|Hitem')), (string.find(link, '|h')))
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

----------------------------------------------------------------------------------------------------
-- slash commands
----------------------------------------------------------------------------------------------------
SLASH_MYSACKS1 = '/mysacks'
SlashCmdList['MYSACKS'] = function(msg)
    MySacks.GenerateMerchantButtonContextMenu()
    EasyMenu(MySacks.ContextMenu, MySacks.ContextMenu_UIParentDropDown, MySacks.ContextMenu_UIParentDropDown, 0 , 0, "MENU")
end

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


-- function MySacks.ContextMenu_RemoveBagsSubClassMenuButton(link)
--     if MySacks.ContextMenu_ItemSubClassMenuList and next(MySacks.ContextMenu_ItemSubClassMenuList) then
--         for k, button in pairs(MySacks.ContextMenu_ItemSubClassMenuList) do
--             if button.arg1 == 'item' then
--                 if tostring(button.arg2.Link) == tostring(link) then
--                     table.remove(MySacks.ContextMenu_ItemSubClassMenuList, button)
--                 end
--             end
--         end
--     end
-- end












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
                id = tonumber(MySacks.GetItemIdFromLink(link))
                --print(id, 'using link')
            end
            if link then
                for i = 1, 15 do
                    MySacks.Tooltip.Item[MySacks.Tooltip.Keys[i]] = select(i, GetItemInfo(link))
                    local d = select(i, GetItemInfo(link))
                    --print(MySacks.Tooltip.Keys[i], d)
                end
                local effectiveILvl, isPreview, baseILvl = GetDetailedItemLevelInfo(link)
                MySacks.Tooltip.Item['EffectiveLevel'] = tonumber(effectiveILvl)
            else
                --MySacks.Print(MySacks.ErrorCodes['tooltipitemerror'])
                return
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
                        local bags, bank, reagents = 0, 0, 0
                        if next(character.Bags) and character.Bags[id] then
                            bags = tonumber(character.Bags[id].Count)
                        end
                        if next(character.Bank) and character.Bank[id] then
                            bank = tonumber(character.Bank[id].Count)
                        end
                        if next(character.Reagents) and character.Reagents[id] then
                            reagents = tonumber(character.Reagents[id].Count)
                        end                    
                        itemCount = bags + bank + reagents
                        if tonumber(itemCount) > 0 then
                            tooltip:AddDoubleLine(tostring(fs..name), tostring(fs..'Bags: |cffffffff'..bags..fs..' Bank: |cffffffff'..bank..fs..' Reagents: |cffffffff'..reagents..fs..' Total: |cffffffff'..itemCount))
                            --tooltip:AddTexture() --?
                        end
                    end
                end
            end
            -- using a 1==1 check until adding options available to user to choose what is shown
            if 1 == 1 then
                if MySacks.Tooltip.Item['ClassID'] and MySacks.Tooltip.Item['SubClassID'] then
                    tooltip:AddDoubleLine(GetItemClassInfo(tonumber(MySacks.Tooltip.Item['ClassID'])), GetItemSubClassInfo(tonumber(MySacks.Tooltip.Item['ClassID']), tonumber(MySacks.Tooltip.Item['SubClassID'])), 1, 1, 1, 1, 1, 1)
                end
            end
            if 1 == 1 then
                if MySacks.Tooltip.Item['ExpansionID'] then
                    tooltip:AddLine(MySacks.ExpansionIdToName[tonumber(MySacks.Tooltip.Item['ExpansionID'])].Full, 1, 1, 1)
                end
            end
            if 1 == 1 then
                if MySacks.Tooltip.Item['MinLevel'] then
                    tooltip:AddDoubleLine('Min Level', tostring(MySacks.Tooltip.Item['MinLevel']), 1, 1, 1, 1, 1, 1)
                end
            end
            if 1 == 1 then
                if MySacks.Tooltip.Item['Level'] then
                    tooltip:AddDoubleLine('Level', tostring(MySacks.Tooltip.Item['Level']), 1, 1, 1, 1, 1, 1)
                end
            end
            if 1 == 1 then
                if MySacks.Tooltip.Item['EffectiveLevel']  then
                    tooltip:AddDoubleLine('Effective Level', tostring(MySacks.Tooltip.Item['EffectiveLevel']), 1, 1, 1, 1, 1, 1)
                end
            end
            if 1 == 1 then
                if MySacks.Tooltip.Item['Icon'] then
                    tooltip:AddDoubleLine('Icon ID', MySacks.Tooltip.Item['Icon'], 1, 1, 1, 1, 1, 1)
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
MySacks.ContextMenu_CustomFrame_ItemLevelSlider.slider:SetMinMaxValues(1, 500) -- this is determined by max item level in game
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
                                    end
                                    -- if i > #MySacks.PlayerBagSlotsMap_ItemSubClass[itemClassID] then
                                    --     break
                                    -- end
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
    table.insert(MySacks.ContextMenu, {text = LOCALES['mailMenuHelp'], notCheckable=true, icon=374216, tooltipTitle=LOCALES['mailMenuHelp_tooltipTitle'], tooltipText=LOCALES['mailMenuHelp_tooltipText'], tooltipOnButton=true } )
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
        { text = MySacks.ContextMenu_Separator, notClickable=true, notCheckable=true},
        { text = LOCALES['items'], notCheckable=true, isTitle=true, },
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
    table.insert(MySacks.ContextMenu, { text = MySacks.ContextMenu_Separator, notClickable=true, notCheckable=true })
    table.insert(MySacks.ContextMenu, { text = LOCALES['merchantOptions'], isTitle=true, notClickable=true, notCheckable=true })
    local itemLevelThresholdSubMenu = {
        { text='itemLevelSlider', notCheckable=true, keepShownOnClick=true, customFrame=MySacks.ContextMenu_CustomFrame_ItemLevelSlider, },
    }
    table.insert(MySacks.ContextMenu, { text = LOCALES['itemLevel'], hasArrow=true, notCheckable=true, menuList=itemLevelThresholdSubMenu, tooltipTitle=LOCALES['itemLevel_tooltipTitle'], tooltipText=LOCALES['itemLevel_tooltipText'], tooltipOnButton=true,})
    table.insert(MySacks.ContextMenu, { text = LOCALES['autoVendorJunk'], checked=MYSACKS_CHARACTER['Merchant'].AutoVendorJunk, isNotRadio=true, keepShownOnClick=true, func=MySacks.ToggleAutoVendorJunk, })
    local ignoreRules = {
        { text = LOCALES['ignoreRules'], isTitle=true, notCheckable=true, },
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
    table.insert(ignoreRules, {text = MySacks.ContextMenu_Separator, notClickable=true, notCheckable=true })
    table.insert(ignoreRules, {text = LOCALES['rarityTypes'], isTitle=true, notClickable=true, notCheckable=true })
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
    table.insert(ignoreRules, {text = MySacks.ContextMenu_Separator, notClickable=true, notCheckable=true })
    table.insert(ignoreRules, {text = LOCALES['armorTypes'], isTitle=true, notClickable=true, notCheckable=true })
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
    table.insert(MySacks.ContextMenu, { text=LOCALES['ignoreRules'], notCheckable=true, hasArrow=true, keepShownOnClick=true, menuList=ignoreRules, tooltipTitle=LOCALES['ignoreRules_tooltipTitle'], tooltipText=LOCALES['ignoreRules_tooltipText'], tooltipOnButton=true, })
    local characters = {
        { text = LOCALES['selectCharacter'], isTitle=true, notCheckable=true, },
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
                    icon = MySacks.RaceInfo[tonumber(raceID)].IconID,
                    notCheckable=true, 
                    func = function() 
                        MySacks.DeleteCharacter(guid, name) 
                        CloseDropDownMenus() 
                    end 
                })
            end
        end
    end
    table.insert(MySacks.ContextMenu, { text = MySacks.ContextMenu_Separator, notCheckable=true, notClickable=true, })
    table.insert(MySacks.ContextMenu, { text = LOCALES['addonOptions'], isTitle=true, notCheckable=true })
    table.insert(MySacks.ContextMenu, { text = LOCALES['deleteCharacterData'], hasArrow=true, notCheckable=true, menuList = characters })
    table.insert(MySacks.ContextMenu, { text = LOCALES['deleteGlobalData'], notCheckable=true, hasArrow=true, menuList = {
        { text = LOCALES['confirm'], notCheckable=true, func=MySacks.WipeGlobalSavedVariables } -- used as a 2 step confirmation, could add as dialog in future
    } })
    table.insert(MySacks.ContextMenu, { text = LOCALES['help'], notCheckable=true, icon=374216, tooltipTitle=LOCALES['help_tooltipTitle'], tooltipText=LOCALES['help_tooltipText'], tooltipOnButton=true,})
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
                notCheckable=true,
                --checked = function() return linkTable.Ignore end,
                keepShownOnClick=true,
                icon = linkTable.Icon,
                func = function(self, arg1, arg2)
                    -- update the report table ignore status  <<<<<<---- CREATE A MAIL IGNORE SETTINGS TABLE AT SOME POINT IF USEFUL
                    --linkTable.Ignore = not linkTable.Ignore
                    -- update saved var table, this ensures item ignore status persists through logout
                    -- if linkTable.Ignore == false then
                    --     MYSACKS_CHARACTER.Merchant.IgnoreList[link] = nil
                    -- else
                    --     MYSACKS_CHARACTER.Merchant.IgnoreList[link] = true
                    -- end
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
                    end
                end,
            })
        end
        -- sort the items by rarity
        table.sort(MySacks.ContextMenu_ItemSubClassMenuList, function(a,b) return a.arg2.Rarity < b.arg2.Rarity end)
        -- add a separator and total at the bottom
        -- table.insert(MySacks.ContextMenu_ItemSubClassMenuList, {
        --     text = MySacks.ContextMenu_Separator,
        --     notCheckable=true,
        --     notClickable=true,
        -- })
        -- table.insert(MySacks.ContextMenu_ItemSubClassMenuList, {
        --     text = string.format('Total %s', GetCoinTextureString(MySacks.GetItemSubClassSellTotal(itemClassID, itemSubClassID))),
        --     notCheckable=true,
        --     notClickable=true,
        -- })
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
                                        end
                                        -- if i > #MySacks.PlayerBagSlotsMap_ItemSubClass[itemClassID][itemSubClassID] then
                                        --     break
                                        -- end
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
        -- add a separator and total at the bottom
        -- table.insert(MySacks.ContextMenu_ItemClassMenuList, {
        --     text = MySacks.ContextMenu_Separator,
        --     notCheckable=true,
        --     notClickable=true,
        -- })
        -- table.insert(MySacks.ContextMenu_ItemClassMenuList, {
        --     text = string.format('Total %s', GetCoinTextureString(MySacks.GetItemClassSellTotal(itemClassID))),
        --     notCheckable=true,
        --     notClickable=true,
        -- })
        -- insert menu header
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
            table.insert(MySacks.ContextMenu_ItemSubClassMenuList, { 
                text = string.format('[%s] %s %s', linkTable.Count, link, GetCoinTextureString(tonumber(linkTable.SellPrice))),
                arg1 = 'item', 
                arg2 = linkTable,
                isNotRadio=true,
                checked = function() return linkTable.Ignore end,
                keepShownOnClick=true,
                icon = '',
                func = function(self, arg1, arg2)
                    -- update the report table ignore status
                    linkTable.Ignore = not linkTable.Ignore
                    -- update saved var table, this ensures item ignore status persists through logout
                    if linkTable.Ignore == false then
                        MYSACKS_CHARACTER.Merchant.IgnoreList[link] = nil
                    else
                        MYSACKS_CHARACTER.Merchant.IgnoreList[link] = true
                    end
                    --local button = self
                    if IsControlKeyDown() then
                        -- ctrl overrides merchant rules
                        MySacks.SellItemByLink(link, linkTable.SellPrice, true)
                    elseif IsShiftKeyDown() then
                        -- shift will show tooltip(s)
                        GameTooltip:SetOwner(self, 'ANCHOR_RIGHT', 0, -16)
                        GameTooltip:SetHyperlink(link)
                        GameTooltip:Show()
                    elseif IsAltKeyDown() then
                        -- alt sells items, avoids miss sells by clicking
                        MySacks.SellItemByLink(link, linkTable.SellPrice, false)
                    end
                end,
            })
        end
        -- sort the items by rarity
        table.sort(MySacks.ContextMenu_ItemSubClassMenuList, function(a,b) return a.arg2.Rarity < b.arg2.Rarity end)
        -- add a separator and total at the bottom
        table.insert(MySacks.ContextMenu_ItemSubClassMenuList, {
            text = MySacks.ContextMenu_Separator,
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

-- this function will loop through the characters bags and update the global saved variables
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
                            SellPrice = tonumber(SellPrice),
                            BagID = tonumber(bag),
                            SlotID = tonumber(slot),
                            EffectiveLevel = tonumber(effectiveILvl),
                        }
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
                        SellPrice = tonumber(SellPrice),
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
                            SellPrice = tonumber(SellPrice),
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

function MySacks.ScanReagentsBank()
    if MySacks.Loaded == true then
        MYSACKS_GLOBAL.Characters[UnitGUID('player')].Reagents = {}
        for slot = 1, 98 do
            local link = GetContainerItemLink(-3, slot)
            local id = select(10, GetContainerItemInfo(-3, slot))
            local slotCount = select(2, GetContainerItemInfo(-3, slot))
            if link and id and slotCount then
                id = tonumber(id)
                local effectiveILvl, isPreview, baseILvl = GetDetailedItemLevelInfo(link)
                local itemName, itemLink, itemRarity, itemLevel, itemMinLevel, itemType, itemSubType, itemStackCount, itemEquipLoc, itemIcon, itemSellPrice, itemClassID, itemSubClassID, bindType, expacID, itemSetID, isCraftingReagent = GetItemInfo(link)
                if not MYSACKS_GLOBAL.Characters[UnitGUID('player')].Reagents[id] then
                    MYSACKS_GLOBAL.Characters[UnitGUID('player')].Reagents[id] = {
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
                        SellPrice = tonumber(SellPrice),
                        BagID = tonumber(bag),
                        SlotID = tonumber(slot),
                        EffectiveLevel = tonumber(effectiveILvl),
                    }
                else
                    MYSACKS_GLOBAL.Characters[UnitGUID('player')].Reagents[id].Count = tonumber(MYSACKS_GLOBAL.Characters[UnitGUID('player')].Reagents[id].Count + slotCount)
                end
            end
        end
    else
        MySacks.Print(MySacks.ErrorCodes['initfail'])
    end
end

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
                local classID = select(12, GetItemInfo(link))
                local subClassID = select(13, GetItemInfo(link))
                local sellPrice = select(11, GetItemInfo(link))
                local rarity = select(3, GetItemInfo(link))
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
                        if MYSACKS_CHARACTER.Merchant.IgnoreList[link] then
                            ignore = MYSACKS_CHARACTER.Merchant.IgnoreList[link]
                        end
                        MySacks.CurrentBagReport[tonumber(classID)][tonumber(subClassID)][link] = { 
                            Rarity = tonumber(rarity), 
                            Count = tonumber(slotCount), 
                            SellPrice = (tonumber(sellPrice) * tonumber(slotCount)),
                            ItemClassID = tonumber(classID),
                            ItemSubClassID = tonumber(subClassID),
                            Link = link,
                            Ignore = ignore,
                            Icon = tonumber(icon),
                            LocationMap = {
                                BagID = tonumber(bag),
                                SlotID = tonumber(slot),
                            },
                        }
                    else
                        MySacks.CurrentBagReport[tonumber(classID)][tonumber(subClassID)][link].Count = MySacks.CurrentBagReport[tonumber(classID)][tonumber(subClassID)][link].Count + tonumber(slotCount)
                        MySacks.CurrentBagReport[tonumber(classID)][tonumber(subClassID)][link].SellPrice = tonumber(MySacks.CurrentBagReport[tonumber(classID)][tonumber(subClassID)][link].SellPrice + (tonumber(sellPrice) * tonumber(slotCount)))
                        table.insert(MySacks.CurrentBagReport[tonumber(classID)][tonumber(subClassID)][link].LocationMap, { BagID = tonumber(bag), SlotID = tonumber(slot) })
                    end
                end
            end
        end
    end
end


function MySacks.VendorItemByLocation(ignoreRules, bagID, slotID)
    local link = select(7, GetContainerItemInfo(tonumber(bagID), tonumber(slotID)))
    local sell = true
    if link then
        local itemName, itemLink, itemRarity, itemLevel, itemMinLevel, itemType, itemSubType, itemStackCount, itemEquipLoc, itemIcon, itemSellPrice, itemClassID, itemSubClassID, bindType, expacID, itemSetID, isCraftingReagent = GetItemInfo(link)
        local effectiveILvl, isPreview, baseILvl = GetDetailedItemLevelInfo(link)
        -- check item wasn't marked for ignore in menu list
        if MySacks.CurrentBagReport[tonumber(itemClassID)][tonumber(itemSubClassID)][link] then
            if MySacks.CurrentBagReport[tonumber(itemClassID)][tonumber(itemSubClassID)][link].Ignore == true then
                sell = false
            end
        end
        -- check if item is weapon > misc (profession tools etc) or weapon > fishing pole
        if tonumber(itemClassID) == 2 then
            if tonumber(itemSubClassID) == 14 or tonumber(itemSubClassID) == 20 then
                -- set this before ignore override to avoid vendoring of tools and fishing poles
                sell = false
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
            end
            -- check item rarity
            if MYSACKS_CHARACTER['Merchant'].VendorRules['rarity'][tonumber(itemRarity)] == true then
                sell = false
            end
            -- check armor type
            if tonumber(itemClassID) == 4 and MYSACKS_CHARACTER['Merchant'].VendorRules['armor'][tonumber(itemSubClassID)] == true then
                sell = false
            end
            -- check boe
            if MYSACKS_CHARACTER['Merchant'].VendorRules['boe'] == true then
                if tonumber(bindType) == 2 then
                    sell = false
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


function MySacks.SellItemByLink(itemLink, sellPrice, ignoreRules)
    local sell = true
    for bag = 0, 4 do
        for slot = 1, GetContainerNumSlots(bag) do
            local slotLink = GetContainerItemLink(bag, slot)
            if tostring(slotLink) == tostring(itemLink) then
                local itemName, itemLink, itemRarity, itemLevel, itemMinLevel, itemType, itemSubType, itemStackCount, itemEquipLoc, itemIcon, itemSellPrice, itemClassID, itemSubClassID, bindType, expacID, itemSetID, isCraftingReagent = GetItemInfo(slotLink)
                local effectiveILvl, isPreview, baseILvl = GetDetailedItemLevelInfo(slotLink)
                -- check item wasn't marked for ignore in menu list
                if MySacks.CurrentBagReport[tonumber(itemClassID)][tonumber(itemSubClassID)][slotLink] then
                    if MySacks.CurrentBagReport[tonumber(itemClassID)][tonumber(itemSubClassID)][slotLink].Ignore == true then
                        sell = false
                    end
                end
                -- check if item is weapon > misc (prof tools etc) or weapon > fishing pole
                if tonumber(itemClassID) == 2 then
                    if tonumber(itemSubClassID) == 14 or tonumber(itemSubClassID) == 20 then
                        -- set this before ignore override to avoid vendoring of tools and fishing poles
                        sell = false
                    end
                end
                if sell == true and ignoreRules == true then
                    UseContainerItem(bag, slot)
                    MySacks.Print(string.format('sold %s for %s ', itemLink, GetCoinTextureString(itemSellPrice)))
                elseif ignoreRules == false then
                    -- check item level
                    if tonumber(effectiveILvl) >= tonumber(MYSACKS_CHARACTER['Merchant'].ItemlevelThreshold) then
                        sell = false
                    end
                    -- check item rarity
                    if MYSACKS_CHARACTER['Merchant'].VendorRules['rarity'][tonumber(itemRarity)] == true then
                        sell = false
                    end
                    -- check armor type
                    if tonumber(itemClassID) == 4 and MYSACKS_CHARACTER['Merchant'].VendorRules['armor'][tonumber(itemSubClassID)] == true then
                        sell = false
                    end
                    -- check boe
                    if MYSACKS_CHARACTER['Merchant'].VendorRules['boe'] == true then
                        if tonumber(bindType) == 2 then
                            sell = false
                        end
                    end
                    if sell == true then
                        UseContainerItem(bag, slot)
                        MySacks.Print(tostring('sold '..itemLink..' for '..GetCoinTextureString(itemSellPrice)))
                    end
                end
                if sell == true then
                    UseContainerItem(bag, slot)
                    MySacks.Print(string.format('sold %s for %s ', itemLink, GetCoinTextureString(itemSellPrice)))
                end
                sell = true
            end
        end
    end
end

function MySacks.ToggleAutoVendorJunk()
    if not MYSACKS_CHARACTER['Merchant'] then
        MYSACKS_CHARACTER['Merchant'] = {}
    end
    MYSACKS_CHARACTER['Merchant'].AutoVendorJunk = not MYSACKS_CHARACTER['Merchant'].AutoVendorJunk
    MySacks.Print('auto vendor junk rule: '..tostring(MYSACKS_CHARACTER['Merchant'].AutoVendorJunk))
end

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

function MySacks.WipeGlobalSavedVariables()
    for guid, character in pairs(MYSACKS_GLOBAL.Characters) do
        character.Bags = {}
        character.Bank = {}
        character.Reagents = {}
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

        BankFrameTab2:HookScript("OnMouseUp", MySacks.ScanReagentsBank)

        --move this?
        local merchantButton = CreateFrame('BUTTON', 'MySacksMerchantFramePortraitButton', MerchantFrame)
        merchantButton:SetPoint('TOPLEFT', 0, 0)
        merchantButton:SetPoint('BOTTOMRIGHT', MerchantFrame, 'TOPLEFT', 45, -45)
        merchantButton:RegisterForClicks('RightButtonUp')
        merchantButton:SetScript('OnClick', function(self, button)
            if button == 'RightButton' and not IsControlKeyDown() then
                MySacks.GenerateMerchantButtonContextMenu()
                EasyMenu(MySacks.ContextMenu, MySacks.ContextMenu_MerchantDropDown, "cursor", 0 , 0, "MENU")
                if MYSACKS_CHARACTER['Merchant'].AutoVendorJunk == true then
                    MySacks.SellJunk()
                end
            elseif button == 'RightButton' and IsControlKeyDown() then
                MySacks.GenerateMerchantButtonContextMenu()
                EasyMenu(MySacks.ContextMenu, MySacks.ContextMenu_MerchantDropDown, "cursor", 0 , 0, "MENU")
            end
        end)

        local mailButton = CreateFrame('BUTTON', 'MySacksMerchantFramePortraitButton', SendMailFrame)
        mailButton:SetPoint('TOPLEFT', SendMailSendMoneyButtonText, 'TOPRIGHT', 12, -2)
        mailButton:SetSize(24, 24)
        mailButton:SetScript('OnClick', function(self)
            MySacks.GenerateMailButtonContextMenu()
            EasyMenu(MySacks.ContextMenu, MySacks.ContextMenu_MerchantDropDown, "cursor", 0 , 0, "MENU")
        end)
        --dropdown
        -- mailButton:SetNormalTexture(130955)
        -- mailButton:SetPushedTexture(130954)
        --red +
        mailButton:SetNormalTexture(130838)
        mailButton:SetPushedTexture(130836)
        --green +
        -- mailButton:SetNormalTexture(130743)
        -- mailButton:SetPushedTexture(130741)

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
MySacks.EventFrame:SetScript("OnEvent", function(self, event, ...)
    MySacks.Events[event](MySacks, ...)
end)

MySacks.Events = {
    ['ADDON_LOADED'] = function(self, ...)
        if select(1, ...):lower() == "mysacks" then
            C_Timer.After(2, MySacks.Init) --delay this to help ensure guid is ready
        end
    end,
    ['MERCHANT_SHOW'] = function(self, ...)
        MySacks.ScanBags()
    end,
    ['PLAYER_LOGOUT'] = function(self, ...)
        MySacks.ScanBags()
    end,
    ['MERCHANT_CLOSED'] = function(self, ...)
        CloseDropDownMenus()
    end,
    ['BANKFRAME_OPENED'] = function(self, ...)
        MySacks.ScanBanks()
    end,
}
