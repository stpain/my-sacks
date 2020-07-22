

local addonName, MySacks = ...

MySacks.FONT_COLOUR = '|cffA330C9'
MySacks.PlayerMixin = nil
MySacks.BagsReport_Everything = {}
MySacks.ContextMenu = {}
MySacks.ContextMenu_Separator = "|TInterface/COMMON/UI-TooltipDivider:8:150|t"
MySacks.ContextMenu_DropDown = CreateFrame("Frame", "MySacksContextMenuDropDown", UIParent, "UIDropDownMenuTemplate")
MySacks.ContextMenu_SoldIcon = 132050

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
        MySacks.Print(MySacks.ErrorCodes['tooltipitemerror'])
        return false
    end
end

----------------------------------------------------------------------------------------------------
-- slash commands
----------------------------------------------------------------------------------------------------
SLASH_MYSACKS1 = '/mysacks'
SlashCmdList['MYSACKS'] = function(msg)
	if msg == '-help' then
        print('help')

	end
end

----------------------------------------------------------------------------------------------------
-- minimap button
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
                InterfaceOptionsFrame_OpenToCategory(addonName)
                InterfaceOptionsFrame_OpenToCategory(addonName)
            elseif button == 'RightButton' then
                MySacks.GenerateMinimapButtonContextMenu()
                EasyMenu(MySacks.ContextMenu, MySacks.ContextMenu_DropDown, "cursor", -180, 0, "MENU")
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
-- minimap button menu
----------------------------------------------------------------------------------------------------

--- generates a table to pass into the EasyMenu function
-- @table characters used for the delete character sub menu
-- @table MySacks.ContextMenu main menu table, contains level 1 menu buttons
function MySacks.GenerateMinimapButtonContextMenu()
    local characters = {
        { text = 'Delete Character', isTitle=true, notCheckable=true, }, -- this will be the sub menu title
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
                    name = tostring(MySacks.ClassData[tonumber(classID)].FontColour..name..'|r') -- format name with class colour if classID
                end
                table.insert(characters, { -- insert character into sub menu
                    text = name,
                    icon = MySacks.RaceInfo[tonumber(raceID)].IconID, -- add faction icon, determined by race
                    notCheckable=true, 
                    func = function() 
                        MySacks.DeleteCharacter(guid, name) 
                        CloseDropDownMenus() 
                    end 
                })
            end
        end
    end
    -- level 1 menu, written with in-line args to make menu layout easier to see
    MySacks.ContextMenu = {
        { text = tostring(MySacks.FONT_COLOUR..addonName..'|r'), isTitle=true, notCheckable=true },
        { text = 'Delete Character', hasArrow=true, notCheckable=true, menuList = characters },
        { text = 'Wipe global data', notCheckable=true, hasArrow=true, menuList = {
            { text = 'Confirm', notCheckable=true, func=MySacks.WipeGlobalSavedVariables } -- used as a 2 step confirmation, could add as dialog in future
        } },
        -- { text = MySacks.ContextMenu_Separator, notClickable=true, notCheckable=true},
        -- { text = 'Tooltip Settings', notCheckable=true, isTitle=true },
        -- { text = 'Show item type', isNotRadio=true, function(self)  end },
        -- { text = 'Show item sub-type', isNotRadio=true, function(self)  end },
        -- { text = 'Show item level', isNotRadio=true, function(self)  end },
        -- { text = 'Show item expansion', isNotRadio=true, function(self)  end },
        -- { text = 'Show item icon id', isNotRadio=true, function(self)  end },
    }
end



function MySacks.ContextMenu_RemoveBagsSubClassMenuButton(link)
    if MySacks.ContextMenu_ItemSubClassMenu and next(MySacks.ContextMenu_ItemSubClassMenu) then
        for k, button in pairs(MySacks.ContextMenu_ItemSubClassMenu) do
            if button.arg2.Info == 'item' then
                if tostring(button.arg2.Link) == tostring(link) then
                    table.remove(MySacks.ContextMenu_ItemSubClassMenu, button)
                end
            end
        end
    end
end



------------------------------------------------------------------------------------------------
-- merchant frame context menu
----------------------------------------------------------------------------------------------------

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


--- generates a table to pass to the EasyMenu function for the merchant frame
-- @function MySacks.GetBagsReport this will scan player bags and generate a table based on the contents
-- @table soulboundWeponArmorRarityList sub menu table for soulbound gear
-- @table allWeponArmorRarityList sub menu table for all gear
-- @table profTradeGoodsMenuList sub menu table for tadeskill items (allows players to bulk vendor tradeskill items looted in old expansion instances etc)
-- @table profRecipesMenuList sub menu table for recipes (allows players to bulk vendor recipes looted in old expansion instances etc)
-- @table MySacks.ContextMenu main menu table, contains level 1 menu buttons
-- @table MySacks.BagsReport_Everything table containing the players bags contents as returned by MySacks.GetBagsReport
-- @table itemClassReportList table sub menu for the item classes, this contains the sub classes categories 
-- @table itemSubClassReportList table sub menu for the item sub classes categories menu, this contains the players items of the sub class category
-- @table itemLevelThresholdSubMenu table for the min level custom frame slider
-- @table rarityIgnorList table to use for the rarity sub menu
function MySacks.GenerateMerchantButtonContextMenu()

    -- scan bags
    MySacks.GetBagsReport()

    --[[

    -- soulbound weapons and armor
    local soulboundWeaponArmorRarityList = {
        { text = tostring('Vendor soulbound '..GetItemClassInfo(2)..' & '..GetItemClassInfo(4)), isTitle=true, notCheckable=true, },
    }
    for i = 1, 4 do
        table.insert(soulboundWeaponArmorRarityList, { 
            text = tostring(ITEM_QUALITY_COLORS[i].hex.._G['ITEM_QUALITY'..i..'_DESC']), 
            notCheckable=true,
            keepShownOnClick=true,
            arg1 = i,
            --icon = 130750, -- grey tick
            --icon = 130768, -- faded gold coin
            --icon = 132060, -- bag and no gold coin
            icon = '', -- simple hack to create an icon but have no texture 
            func = function(self)
                for k, v in ipairs(soulboundWeaponArmorRarityList) do -- loop the menuList and update the icon field so that icon status persists through closing/opening of menuList
                    if tonumber(v.arg1) == i then
                        v.icon = MySacks.ContextMenu_SoldIcon
                    end
                end
                MySacks.SellWeaponArmor(i, true)
                --self.Icon:SetTexture(130751) -- gold tick
                --self.Icon:SetTexture(130769) -- bright gold coin
                self.Icon:SetTexture(MySacks.ContextMenu_SoldIcon) -- bag and gold coin
            end,
        })
    end
    table.insert(soulboundWeaponArmorRarityList, {
        text = MySacks.ContextMenu_Separator,
        notCheckable = true,
        notClickable = true,
    })
    table.insert(soulboundWeaponArmorRarityList, { 
        --text = '|cffC41F3BVendor All|r',  -- DK font color
        text = 'Vendor all', 
        notCheckable=true,
        keepShownOnClick=true,
        func = function()
            local i = 0
            C_Timer.NewTicker(0.2, function()
                MySacks.SellWeaponArmor(i, true)
                i = i + 1
            end, 5)
        end,
    })

    -- all weapons and armor
    local allWeaponArmorRarityList = {
        { text = tostring('Vendor all '..GetItemClassInfo(2)..' & '..GetItemClassInfo(4)), isTitle=true, notCheckable=true, },
    }
    for i = 1, 4 do
        table.insert(allWeaponArmorRarityList, { 
            text = tostring(ITEM_QUALITY_COLORS[i].hex.._G['ITEM_QUALITY'..i..'_DESC']), 
            notCheckable=true,
            keepShownOnClick=true,
            func = function()
                MySacks.SellWeaponArmor(i, false)
            end,
        })
    end
    table.insert(allWeaponArmorRarityList, {
        text = MySacks.ContextMenu_Separator,
        notCheckable = true,
        notClickable = true,
    })
    table.insert(allWeaponArmorRarityList, { 
        --text = '|cffC41F3BVendor All|r',  -- DK red font colour
        text = 'Vendor all', 
        notCheckable=true,
        keepShownOnClick=true,
        func = function()
            local i = 0
            C_Timer.NewTicker(0.2, function()
                MySacks.SellWeaponArmor(i, false)
                i = i + 1
            end, 5)
        end,
    })

    -- consumables menu
    MySacks.ContextMenu_ConsumablesMenu = {
        { text = tostring('Vendor '..GetItemClassInfo(0)), isTitle=true, notCheckable=true, arg2=-2, }
    }
    for k, v in ipairs({ 1, 2, 3, 5 }) do -- potion, elixir, flask, food & drink
        local name, isArmorType = GetItemSubClassInfo(0, v)
        local sellPrice = MySacks.GetSubClassSellTotal(0, v) or 0
        table.insert(MySacks.ContextMenu_ConsumablesMenu, {
            text = string.format('%s %s', name, GetCoinTextureString(sellPrice)),
            arg1 = v,
            arg2 = tonumber(sellPrice),
            notCheckable=true,
            keepShownOnClick=true,
            func=function(self)
                local button = self
                if IsShiftKeyDown() then
                    MySacks.SellItemBySubClass(0, tonumber(v), true) --override level threshold
                else
                    MySacks.SellItemBySubClass(0, tonumber(v), false)
                end   
                MySacks.GetBagsReport()       
                for _, b in pairs(MySacks.ContextMenu_ConsumablesMenu) do
                    if tonumber(b.arg1) == v then
                        C_Timer.After(1, function() -- delay to allow the game to process the selling, may need to adjust this?
                            MySacks.GetBagsReport()
                            b.text = string.format('%s %s', name, GetCoinTextureString(MySacks.GetSubClassSellTotal(0, v)))
                            button:SetText(string.format('%s %s', name, GetCoinTextureString(MySacks.GetSubClassSellTotal(0, v)))) 
                        end)
                    end
                end
            end,
        })
    end
    table.sort(MySacks.ContextMenu_ConsumablesMenu, function(a,b) return a.arg2 < b.arg2 end)

    -- tradeskill menu
    local profTradeGoodsMenuList = {
        { text = tostring('Vendor '..GetItemClassInfo(7)), isTitle=true, notCheckable=true, arg2=-2, }
    }
    for k, v in ipairs({ 1, 4, 5, 6, 7, 8, 9, 10, 11, 12, 16 }) do
        local name, isArmorType = GetItemSubClassInfo(7, v)
        local sellPrice = MySacks.GetSubClassSellTotal(7, v) or 0
        table.insert(profTradeGoodsMenuList, {
            text = string.format('%s %s', name, GetCoinTextureString(sellPrice)),
            arg1 = v,
            arg2 = tonumber(sellPrice),
            notCheckable=true,
            keepShownOnClick=true,
            func=function(self)
                local button = self
                if IsShiftKeyDown() then
                    MySacks.SellItemBySubClass(7, tonumber(v), true) --override level threshold
                else
                    MySacks.SellItemBySubClass(7, tonumber(v), false)
                end   
                MySacks.GetBagsReport()       
                for _, b in pairs(consumablesMenuList) do
                    if tonumber(b.arg1) == v then
                        C_Timer.After(1, function() -- delay to allow the game to process the selling, may need to adjust this?
                            MySacks.GetBagsReport()
                            b.text = string.format('%s %s', name, GetCoinTextureString(MySacks.GetSubClassSellTotal(7, v)))
                            button:SetText(string.format('%s %s', name, GetCoinTextureString(MySacks.GetSubClassSellTotal(7, v)))) 
                        end)
                    end
                end
            end,
        })
    end
    table.sort(profTradeGoodsMenuList, function(a,b) return a.arg2 < b.arg2 end)
    table.insert(profTradeGoodsMenuList, {
        text = tostring('|cffC41F3BVendor all '..GetItemClassInfo(7)),
        notCheckable=true,
    })

    -- recipes menu
    local profRecipesMenuList = {
        { text = tostring('Vendor '..GetItemClassInfo(9)), isTitle=true, notCheckable=true, arg2=-2, }
    }
    for k, v in ipairs({ 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11 }) do
        local name, isArmorType = GetItemSubClassInfo(9, v)
        local sellPrice = MySacks.GetSubClassSellTotal(9, v)
        table.insert(profRecipesMenuList, {
            text = string.format('%s %s', name, GetCoinTextureString(sellPrice)),
            arg1 = v,
            arg2 = tonumber(sellPrice),
            notCheckable=true,
            keepShownOnClick=true,
            func=function(self)
                local button = self
                if IsShiftKeyDown() then
                    MySacks.SellItemBySubClass(9, tonumber(v), true) --override level threshold
                else
                    MySacks.SellItemBySubClass(9, tonumber(v), false)
                end   
                MySacks.GetBagsReport()       
                for _, b in pairs(consumablesMenuList) do
                    if tonumber(b.arg1) == v then
                        C_Timer.After(1, function() -- delay to allow the game to process the selling, may need to adjust this?
                            MySacks.GetBagsReport()
                            b.text = string.format('%s %s', name, GetCoinTextureString(MySacks.GetSubClassSellTotal(9, v)))
                            button:SetText(string.format('%s %s', name, GetCoinTextureString(MySacks.GetSubClassSellTotal(9, v)))) 
                        end)
                    end
                end
            end,
        })
    end
    table.sort(profRecipesMenuList, function(a,b) return a.arg2 < b.arg2 end)
    table.insert(profRecipesMenuList, {
        text = tostring('|cffC41F3BVendor all '..GetItemClassInfo(9)),
        notCheckable=true,
    })

    -- artifact menu
    local artifactMenuList = {}
    if MySacks.BagsReport_Everything and next(MySacks.BagsReport_Everything) and MySacks.BagsReport_Everything[3] and next(MySacks.BagsReport_Everything[3]) and MySacks.BagsReport_Everything[3][11] and next(MySacks.BagsReport_Everything[3][11]) then
        table.insert(artifactMenuList, { 
            text = tostring('Vendor '..GetItemSubClassInfo(3, 11)), 
            isTitle=true, 
            notCheckable=true, 
        })
        for link, linkTable in pairs(MySacks.BagsReport_Everything[3][11]) do
            table.insert(artifactMenuList, {
                text = link,
                notCheckable=true,
            })
        end
        table.insert(artifactMenuList, {
            text = 'Vendor all',
            notCheckable=true,
        })
    end

    ]]--

    -- main menu
    MySacks.ContextMenu = {
        { text = 'Merchant Options', isTitle=true, notCheckable=true },
        { text = 'Vendor junk', notCheckable=true, keepShownOnClick=true, func = MySacks.SellJunk, },
        { text = MySacks.ContextMenu_Separator, notClickable=true, notCheckable=true},
        -- { text = tostring(GetItemClassInfo(2)..' & '..GetItemClassInfo(4)), isTitle=true, notCheckable=true },
        -- { text = 'Soulbound items', notCheckable=true, hasArrow=true, menuList=soulboundWeaponArmorRarityList, tooltipTitle='Note:', tooltipText='This is will not sell BoE gear that has become soulbound through equipping.', tooltipOnButton=true, },
        -- { text = 'All items', notCheckable=true, hasArrow=true, menuList=allWeaponArmorRarityList },
        -- { text = MySacks.ContextMenu_Separator, notClickable=true, notCheckable=true },
        -- { text = 'Other items', isTitle=true, notClickable=true, notCheckable=true },
        -- { text = tostring(GetItemClassInfo(0)), notCheckable=true, hasArrow=true, menuList=MySacks.ContextMenu_ConsumablesMenu }, -- consumables
        -- { text = tostring(GetItemClassInfo(7)), notCheckable=true, hasArrow=true, menuList=profTradeGoodsMenuList }, -- tradeskill items
        -- { text = tostring(GetItemClassInfo(9)), notCheckable=true, hasArrow=true, menuList=profRecipesMenuList }, -- recipes
        -- { text = tostring(GetItemSubClassInfo(3, 11)), arg1='artifactgems', notCheckable=true, hasArrow=true, menuList=artifactMenuList }, -- artifact items 
        -- { text = MySacks.ContextMenu_Separator, notClickable=true, notCheckable=true },
        { text = 'Items', notCheckable=true, isTitle=true, },
    }

    -- update artifact button if none in bags report
    -- if not next(artifactMenuList) then
    --     for k, v in ipairs(MySacks.ContextMenu) do
    --         if v.arg1 == 'artifactgems' then
    --             v.hasArrow=false
    --         end
    --     end
    -- end

    -- bags report, class table > sub class table
    MySacks.ContextMenu_ItemClassMenu = {}
    MySacks.ContextMenu_ItemSubClassMenu = {}
    if next(MySacks.BagsReport_Everything) then

        -- loop the bags report table
        for itemClassID, itemClassTable in pairs(MySacks.BagsReport_Everything) do
            local itemClass = GetItemClassInfo(tonumber(itemClassID))
            MySacks.ContextMenu_ItemClassMenu = {
                { text = itemClass, isTitle=true, notCheckable=true, arg1 = -1, } --set arg1 as -1 for table.sort purposes, will keep this as first/top item
            }

            -- if the report table item has items (a table)
            if next(itemClassTable) then
                local total = 0 -- create item count variable

                -- loop the class table
                for itemSubClassID, itemSubClassTable in pairs(itemClassTable) do
                    local itemSubClass = GetItemSubClassInfo(tonumber(itemClassID), tonumber(itemSubClassID))
                    MySacks.ContextMenu_ItemSubClassMenu = {
                        { text = itemSubClass, isTitle=true, notCheckable=true, arg1 = -2, },
                        { text = 'Click to vendor or |cffffffffShift|r click for tooltip, |cffffffffCtrl|r click to override rules', isTitle=true, notCheckable=true, arg1 = -1, }, --set arg1 as -1 for table.sort purposes, will keep this as first/top item
                    }

                    -- loop the items in the sub class table
                    for link, linkTable in pairs(itemSubClassTable) do --loop the items in the sub class table(s)
                        table.insert(MySacks.ContextMenu_ItemSubClassMenu, { 
                            text = string.format('[%s] %s %s', linkTable.Count, link, GetCoinTextureString(tonumber(linkTable.SellPrice))),
                            arg1 = tonumber(linkTable.Rarity), --set arg1 to item rarity, this is used to sort the table and display items in rarity order
                            arg2 = { Info = 'item', ClassID = tonumber(itemClassID), SubClassID = tonumber(itemSubClassID), Link = link, },
                            notCheckable=true,
                            keepShownOnClick=true,
                            icon = '',
                            func = function(self, arg1, arg2)
                                local button = self
                                if IsControlKeyDown() then
                                    print('selling item by link, override rules')
                                    --MySacks.SellItemByLink(link, linkTable.SellPrice, true) -- currently sells all stacks of item
                                    -- for k, v in pairs(MySacks.ContextMenu_ItemSubClassMenu) do
                                    --     if type(v.arg2) == 'table' and v.arg2.Info == 'item' then
                                    --         v.icon = MySacks.ContextMenu_SoldIcon
                                    --     end
                                    -- end
                                    -- button.Icon:SetTexture(MySacks.ContextMenu_SoldIcon)
                                elseif IsShiftKeyDown() then
                                    GameTooltip:SetOwner(self, 'ANCHOR_RIGHT', 0, -16) -- show an item tooltip, maybe helpful to further identify an item
                                    GameTooltip:SetHyperlink(link)
                                    GameTooltip:Show()
                                else 
                                    print('selling item by link')
                                    --MySacks.SellItemByLink(link, linkTable.SellPrice, false)
                                    -- for k, v in pairs(MySacks.ContextMenu_ItemSubClassMenu) do
                                    --     if type(v.arg2) == 'table' and v.arg2.Info == 'item' then
                                    --         v.icon = MySacks.ContextMenu_SoldIcon
                                    --     end
                                    -- end
                                    -- button.Icon:SetTexture(MySacks.ContextMenu_SoldIcon)
                                end
                            end,
                        })
                        table.sort(MySacks.ContextMenu_ItemSubClassMenu, function(a,b) return a.arg1 < b.arg1 end) -- sort the items by rarity
                        total = tonumber(total + linkTable.SellPrice)

                        -- add data to arg2
                        -- for k, v in ipairs(MySacks.ContextMenu_ItemSubClassMenu) do
                        --     if type(v.arg2) == 'table' and v.arg2.Info == 'item' then
                        --         v.arg2['Button'] = tostring('DropDownList3Button'..k)
                        --     end
                        -- end
                    end
                    table.insert(MySacks.ContextMenu_ItemClassMenu, { 
                        text = itemSubClass, 
                        arg1 = tonumber(itemSubClassID), --use arg1 to hold sub class id and sort by this value
                        hasArrow=true, 
                        keepShownOnClick=true,
                        notCheckable=true,
                        func=function(self)
                            if IsControlKeyDown() == false then
                                print('selling', itemSubClass)
                                MySacks.SellItemBySubClass(itemClassID, itemSubClassID, false)
                            else
                                MySacks.SellItemBySubClass(itemClassID, itemSubClassID, true)
                            end
                        end,
                        menuList=MySacks.ContextMenu_ItemSubClassMenu,
                    })
                end
                table.sort(MySacks.ContextMenu_ItemClassMenu, function(a,b) return a.arg1 < b.arg1 end) -- sort table, this means the menu lists will always follow the same order
                table.insert(MySacks.ContextMenu_ItemClassMenu, { 
                    text = string.format('Total %s', GetCoinTextureString(tonumber(total))),
                    notCheckable=true 
                })
            end
            table.insert(MySacks.ContextMenu, { 
                text = itemClass, 
                hasArrow=true, 
                keepShownOnClick=true,
                notCheckable=true, 
                menuList=MySacks.ContextMenu_ItemClassMenu,
                func=function(self)
                    if IsControlKeyDown() == false then
                        MySacks.SellItemByClass(itemClassID, false)
                    else
                        MySacks.SellItemByClass(itemClassID, true)
                    end
                end,
            })
        end
    end
    table.insert(MySacks.ContextMenu, { text = MySacks.ContextMenu_Separator, notClickable=true, notCheckable=true })
    table.insert(MySacks.ContextMenu, { text = 'Settings', isTitle=true, notClickable=true, notCheckable=true })
    local itemLevelThresholdSubMenu = {
        -- { text='Item level threshold', isTitle=true, notCheckable=true },
        -- { text=' ', isTitle=true, notCheckable=true },
        { text='itemLevelSlider', notCheckable=true, keepShownOnClick=true, customFrame=MySacks.ContextMenu_CustomFrame_ItemLevelSlider, }, -- tooltipTitle='Item Level', tooltipText='Use mouse wheel to make small value changes', tooltipOnButton=true, },
    }
    table.insert(MySacks.ContextMenu, { text = 'Item Level', hasArrow=true, notCheckable=true, menuList=itemLevelThresholdSubMenu, tooltipTitle='Item level threshold', tooltipText='Items *above* this level will |cffffffffNOT|r be vendored, use mouse wheel for small changes.', tooltipOnButton=true, })
    table.insert(MySacks.ContextMenu, { text = 'Auto vendor junk', checked=MYSACKS_CHARACTER['Merchant'].AutoVendorJunk, isNotRadio=true, keepShownOnClick=true, func=MySacks.ToggleAutoVendorJunk, tooltipTitle='Auto vendor junk', tooltipText='MySacks will auto vendor any poor rarity items, to override this hold shift when opening MySacks menu', tooltipOnButton=true, })
    local ignoreRules = {
        { text = 'Item ignore rules', isTitle=true, notCheckable=true, }, -- this will be the sub menu title
    }
    for i = 1, 4 do
        table.insert(ignoreRules, { -- insert rarity into sub menu
            keepShownOnClick=true,
            checked = MYSACKS_CHARACTER['Merchant'].VendorRules[i] or false,
            arg1 = tonumber(i),
            keepShownOnClick = true,
            arg2 = _G['ITEM_QUALITY'..i..'_DESC'],
            text = tostring(ITEM_QUALITY_COLORS[i].hex.._G['ITEM_QUALITY'..i..'_DESC']),
            isNotRadio=true,
            func = function(self)
                MySacks.SetVendorRule(self.arg1, 'rarity')
            end,
        })        
    end
    table.insert(ignoreRules, {text = MySacks.ContextMenu_Separator, notClickable=true, notCheckable=true })
    table.insert(ignoreRules, {
        text = 'BoE items',
        arg1 = 'boe',
        keepShownOnClick = true,
        isNotRadio = true,
        checked = MYSACKS_CHARACTER['Merchant'].VendorRules['boe'],
        func = function(self)
            MySacks.SetVendorRule(self.arg1, false)
        end,
    })
    table.insert(MySacks.ContextMenu, { text = 'Ignore rules', notCheckable=true, hasArrow=true, keepShownOnClick=true, menuList=ignoreRules, tooltipTitle='Item rarity Ignore List', tooltipText='These items will |cffffffffNOT|r be vendored.', tooltipOnButton=true, })

end



---------------------------------------------------------------------------------------------------------------------------------------------------------------
--tooltip extension
---------------------------------------------------------------------------------------------------------------------------------------------------------------
MySacks.TooltipLineAdded = false
function MySacks.OnTooltipSetItem(tooltip, ...)
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
                MySacks.Print(MySacks.ErrorCodes['tooltipitemerror'])
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

----------------------------------------------------------------------------------------------------
-- functions
----------------------------------------------------------------------------------------------------

function MySacks.GetSubClassSellTotal(classID, subClassID)
    local c = 0
    if MySacks.BagsReport_Everything and next(MySacks.BagsReport_Everything) and MySacks.BagsReport_Everything[tonumber(classID)] and next(MySacks.BagsReport_Everything[tonumber(classID)]) and MySacks.BagsReport_Everything[tonumber(classID)][tonumber(subClassID)] and next(MySacks.BagsReport_Everything[tonumber(classID)][tonumber(subClassID)]) then
        for link, linkTable in pairs(MySacks.BagsReport_Everything[tonumber(classID)][tonumber(subClassID)]) do
            c = tonumber(c + linkTable.SellPrice)
        end
    end
    return tonumber(c)
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
    MySacks.BagsReport_Everything = {}
    for bag = 0, 4 do
        for slot = 1, GetContainerNumSlots(bag) do
            local link = GetContainerItemLink(bag, slot)
            local slotCount = select(2, GetContainerItemInfo(bag, slot))
            if link then
                local classID = select(12, GetItemInfo(link))
                local subClassID = select(13, GetItemInfo(link))
                local sellPrice = select(11, GetItemInfo(link))
                local rarity = select(3, GetItemInfo(link))
                if classID and subClassID and sellPrice then
                    if not MySacks.BagsReport_Everything[tonumber(classID)] then
                        --print('created table for class', classID)
                        MySacks.BagsReport_Everything[tonumber(classID)] = {}
                    end
                    if not MySacks.BagsReport_Everything[tonumber(classID)][tonumber(subClassID)] then
                        --print('created table for sub class', subClassID)
                        MySacks.BagsReport_Everything[tonumber(classID)][tonumber(subClassID)] = {}
                    end
                    if not MySacks.BagsReport_Everything[tonumber(classID)][tonumber(subClassID)][link] then
                        --print('added', link, 'to sub class table')
                        MySacks.BagsReport_Everything[tonumber(classID)][tonumber(subClassID)][link] = { 
                            Rarity = tonumber(rarity), 
                            Count = tonumber(slotCount), 
                            SellPrice = (tonumber(sellPrice) * tonumber(slotCount)) 
                        }
                    else
                        --print('updated', link, 'in sub class table')
                        MySacks.BagsReport_Everything[tonumber(classID)][tonumber(subClassID)][link].Count = MySacks.BagsReport_Everything[tonumber(classID)][tonumber(subClassID)][link].Count + tonumber(slotCount)
                        MySacks.BagsReport_Everything[tonumber(classID)][tonumber(subClassID)][link].SellPrice = tonumber(MySacks.BagsReport_Everything[tonumber(classID)][tonumber(subClassID)][link].SellPrice + (tonumber(sellPrice) * tonumber(slotCount)))
                    end
                end
            end
        end
    end
end

function MySacks.SellJunk()
    local soldTotal, itemCount = 0, 0
    for bag = 0, 4 do
        for slot = 1, GetContainerNumSlots(bag) do
            --local id = select(10, GetContainerItemInfo(bag, slot))
            local link = GetContainerItemLink(bag, slot)
            local slotCount = select(2, GetContainerItemInfo(bag, slot))
            if link then
                local itemName, itemLink, itemRarity, itemLevel, itemMinLevel, itemType, itemSubType, itemStackCount, itemEquipLoc, itemIcon, itemSellPrice, itemClassID, itemSubClassID, bindType, expacID, itemSetID, isCraftingReagent = GetItemInfo(link)
                if itemRarity == 0 then
                    soldTotal = tonumber(soldTotal + (slotCount * itemSellPrice))
                    itemCount = tonumber(itemCount + slotCount)
                    UseContainerItem(bag, slot)
                    MySacks.Print(tostring('sold '..itemLink..' for '..GetCoinTextureString(soldTotal)))
                end
            end
        end
    end
    MySacks.Print(string.format('sold %s items for %s ', itemCount, GetCoinTextureString(soldTotal)))
end

--Item binding type: 0 - none; 1 - on pickup; 2 - on equip; 3 - on use; 4 - quest.
function MySacks.SellWeaponArmor(rarity, soulbound)
    for bag = 0, 4 do
        for slot = 1, GetContainerNumSlots(bag) do
            --local id = select(10, GetContainerItemInfo(bag, slot))
            local link = select(7, GetContainerItemInfo(bag, slot))
            local sell, msg = false, nil
            if link then
                local itemName, itemLink, itemRarity, itemLevel, itemMinLevel, itemType, itemSubType, itemStackCount, itemEquipLoc, itemIcon, itemSellPrice, itemClassID, itemSubClassID, bindType, expacID, itemSetID, isCraftingReagent = GetItemInfo(link)
                local effectiveILvl, isPreview, baseILvl = GetDetailedItemLevelInfo(link)
                if tonumber(effectiveILvl) <= tonumber(MYSACKS_CHARACTER['Merchant'].ItemlevelThreshold) then
                    if tonumber(itemRarity) == tonumber(rarity) then
                        if tonumber(itemClassID) == 2 then --weapons
                            if tonumber(itemSubClassID) ~= 14 and tonumber(itemSubClassID) ~= 20 then --misc & fishing poles
                                if soulbound == true then
                                    if tonumber(bindType) == 1 then
                                        sell, msg = true, tostring('sold '..itemLink..' for '..GetCoinTextureString(itemSellPrice))
                                    end
                                else
                                    sell, msg = true, tostring('sold '..itemLink..' for '..GetCoinTextureString(itemSellPrice))
                                end
                            end
                        elseif tonumber(itemClassID) == 4 then --armor
                            if soulbound == true then
                                if tonumber(bindType) == 1 then
                                    sell, msg = true, tostring('sold '..itemLink..' for '..GetCoinTextureString(itemSellPrice))
                                end
                            else
                                sell, msg = true, tostring('sold '..itemLink..' for '..GetCoinTextureString(itemSellPrice))
                            end
                        end
                    end
                end
            end
            if sell == true then
                UseContainerItem(bag, slot)
                MySacks.Print(msg)
                sell, msg = false, nil
            end
        end
    end
end



function MySacks.SellItemBySubClass(classID, subClassID, ignoreRules)
    for bag = 0, 4 do
        for slot = 1, GetContainerNumSlots(bag) do
            --local id = select(10, GetContainerItemInfo(bag, slot))
            local link = select(7, GetContainerItemInfo(bag, slot))
            local sell = true
            if link then
                local itemName, itemLink, itemRarity, itemLevel, itemMinLevel, itemType, itemSubType, itemStackCount, itemEquipLoc, itemIcon, itemSellPrice, itemClassID, itemSubClassID, bindType, expacID, itemSetID, isCraftingReagent = GetItemInfo(link)
                local effectiveILvl, isPreview, baseILvl = GetDetailedItemLevelInfo(link)
                if tonumber(itemClassID) == tonumber(classID) then
                    if tonumber(itemSubClassID) == tonumber(subClassID) then
                        if ignoreRules == true then
                            UseContainerItem(bag, slot)
                            MySacks.Print(tostring('sold '..itemLink..' for '..GetCoinTextureString(itemSellPrice)))
                        elseif ignoreRules == false then
                            if tonumber(effectiveILvl) > tonumber(MYSACKS_CHARACTER['Merchant'].ItemlevelThreshold) then
                                sell, msg = false, tostring('sold '..itemLink..' for '..GetCoinTextureString(itemSellPrice))
                            end
                            if MYSACKS_CHARACTER['Merchant'].VendorRules[tonumber(itemRarity)] == true then
                                sell = false
                            end
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
                    end
                end
            end
            sell = true
        end
    end
end


function MySacks.SellItemByClass(classID, ignoreRules)
    for bag = 0, 4 do
        for slot = 1, GetContainerNumSlots(bag) do
            --local id = select(10, GetContainerItemInfo(bag, slot))
            local link = select(7, GetContainerItemInfo(bag, slot))
            local sell, msg = false, nil
            if link then
                local itemName, itemLink, itemRarity, itemLevel, itemMinLevel, itemType, itemSubType, itemStackCount, itemEquipLoc, itemIcon, itemSellPrice, itemClassID, itemSubClassID, bindType, expacID, itemSetID, isCraftingReagent = GetItemInfo(link)
                local effectiveILvl, isPreview, baseILvl = GetDetailedItemLevelInfo(link)
                if tonumber(itemClassID) == tonumber(classID) then
                    if ignoreRules == true then
                        UseContainerItem(bag, slot)
                        MySacks.Print(tostring('sold '..itemLink..' for '..GetCoinTextureString(itemSellPrice)))
                    elseif ignoreRules == false then
                        if tonumber(effectiveILvl) <= tonumber(MYSACKS_CHARACTER['Merchant'].ItemlevelThreshold) then
                            sell, msg = true, tostring('sold '..itemLink..' for '..GetCoinTextureString(itemSellPrice))
                        end
                        if MYSACKS_CHARACTER['Merchant'].VendorRules[tonumber(itemRarity)] == true then
                            sell = false
                        end
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
                end
            end
            sell, msg = false, nil
        end
    end
end


function MySacks.SellItemByLink(itemLink, sellPrice, ignoreRules)
    for bag = 0, 4 do
        for slot = 1, GetContainerNumSlots(bag) do
            local slotLink = GetContainerItemLink(bag, slot)
            if tostring(slotLink) == tostring(itemLink) then
                local itemName, itemLink, itemRarity, itemLevel, itemMinLevel, itemType, itemSubType, itemStackCount, itemEquipLoc, itemIcon, itemSellPrice, itemClassID, itemSubClassID, bindType, expacID, itemSetID, isCraftingReagent = GetItemInfo(slotLink)
                local effectiveILvl, isPreview, baseILvl = GetDetailedItemLevelInfo(link)
                if ignoreRules == true then
                    UseContainerItem(bag, slot)
                    MySacks.Print(string.format('sold %s for %s ', itemLink, GetCoinTextureString(itemSellPrice)))
                elseif ignoreRules == false then
                    if tonumber(effectiveILvl) <= tonumber(MYSACKS_CHARACTER['Merchant'].ItemlevelThreshold) then
                        UseContainerItem(bag, slot)
                        MySacks.Print(string.format('sold %s for %s ', itemLink, GetCoinTextureString(itemSellPrice)))
                    end
                end
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

function MySacks.SetVendorRule(rule, info)
    if not MYSACKS_CHARACTER['Merchant'] then
        MYSACKS_CHARACTER['Merchant'] = {}
    end
    if not MYSACKS_CHARACTER['Merchant'].VendorRules then
        MYSACKS_CHARACTER['Merchant'].VendorRules = {}
    end
    MYSACKS_CHARACTER['Merchant'].VendorRules[rule] = not MYSACKS_CHARACTER['Merchant'].VendorRules[rule]
    if info == 'rarity' then
        MySacks.Print(string.format('ignore %s items rule: %s', tostring(ITEM_QUALITY_COLORS[rule].hex.._G['ITEM_QUALITY'..rule..'_DESC']..'|r'), tostring(MYSACKS_CHARACTER['Merchant'].VendorRules[rule])))
    else
        MySacks.Print(string.format('ignore %s items rule: %s', tostring(rule), tostring(MYSACKS_CHARACTER['Merchant'].VendorRules[rule])))
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
                AutoVendorJunk = false,
                VendorRules = {
                    [1] = true,
                    [2] = true,
                    [3] = true,
                    [4] = true,
                    ['boe'] = true,
                },
                ItemlevelThreshold = 100,
            },
        }
    end
    if not MYSACKS_CHARACTER['Merchant']then
        MYSACKS_CHARACTER['Merchant'] = {
            AutoVendorJunk = false,
            VendorRules = {
                [1] = true,
                [2] = true,
                [3] = true,
                [4] = true,
                ['boe'] = true,
            },
            ItemlevelThreshold = 100,
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
        MySacks.CreateMinimapButton()
        
        GameTooltip:HookScript("OnTooltipSetItem", MySacks.OnTooltipSetItem)
        GameTooltip:HookScript("OnTooltipCleared", MySacks.OnTooltipCleared)

        BankFrameTab2:HookScript("OnMouseUp", MySacks.ScanReagentsBank)

        --move this?
        local merchantButton = CreateFrame('BUTTON', 'MySacksMerchantFramePortraitButton', MerchantFrame)
        merchantButton:SetPoint('TOPLEFT', 0, 0)
        merchantButton:SetPoint('BOTTOMRIGHT', MerchantFrame, 'TOPLEFT', 45, -45)
        merchantButton:RegisterForClicks('RightButtonUp')
        merchantButton:SetScript('OnClick', function(self, button)
            if button == 'RightButton' and not IsShiftKeyDown() then
                MySacks.GenerateMerchantButtonContextMenu()
                EasyMenu(MySacks.ContextMenu, MySacks.ContextMenu_DropDown, "cursor", 0 , 0, "MENU")
                if MYSACKS_CHARACTER['Merchant'].AutoVendorJunk == true then
                    MySacks.SellJunk()
                end
            elseif button == 'RightButton' and IsShiftKeyDown() then
                MySacks.GenerateMerchantButtonContextMenu()
                EasyMenu(MySacks.ContextMenu, MySacks.ContextMenu_DropDown, "cursor", 0 , 0, "MENU")
            end
        end)

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
    ['MERCHANT_CLOSED'] = function(self, ...)
        CloseDropDownMenus()
    end,
    ['BANKFRAME_OPENED'] = function(self, ...)
        MySacks.ScanBanks()
    end,
}
