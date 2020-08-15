

local addonName, MySacks = ...

local L = {}
L['merchantOptions'] = 'Merchant Options'
L['vendorJunk'] = 'Vendor Junk'
L['items'] = 'Items'
L['itemLevel'] = 'Item Level'
L['itemLevel_tooltipTitle'] = 'Item level threshold'
L['itemLevel_tooltipText'] = 'Use mouse wheel for small adjustments'
L['autoVendorJunk'] = 'Auto vendor Junk'
L['boeItems'] = 'BoE items'
L['armorTypes'] = 'Armor types'
L['rarityTypes'] = 'Item rarity'
L['ignoreRules'] = 'Ignore rules'
L['ignoreRules_tooltipTitle'] = 'Vendor ignore rules'
L['ignoreRules_tooltipText'] = 'These items will |cffffffffnot|r be vendored.'
L['selectCharacter'] = 'Select Character'
L['deleteCharacterData'] = 'Delete character data'
L['addonOptions'] = 'Addon options'
L['deleteGlobalData'] = 'Delete global data'
L['help'] = 'Help'
L['confirm'] = 'Confirm'
L['help_tooltipTitle'] = 'Help'
L['help_tooltipText'] = tostring(
[[
MySacks will scan your bags when you interact with a merchant. Your items will be listed by item class (Weapons, Consumables, etc) and then sub class (Potion, Food & Drink, etc).

|cffffffffVendoring|r
Items can be vendored by class or sub class or directly by link.
|cffffffffAlt|r+click will vendor the item or class/sub-class of item(s).
|cffffffffCtrl|r+click will vendor and override any merchant rules.
|cffffffffShift|r+click will show item tooltip (only works on item links).

|cffffffffRules|r
You can set up rules for vendoring,
-|cffffffffItem level threshold|r - only items with an item level lower than the threshold will be vendored.
-|cffffffffIgnore rules|r - any items with the selected rarity or that are BoE (items that become soulbound through equipping are still classed as BoE) will not be vendored.
-|cffffffffAuto sell junk|r - when you open the MySacks menu, all items with a rarity of junk (not items of the junk item class) will be vendored, 
you can override this by holding |cffffffffCtrl|r when you open the MySacks menu.
]])
L['subClassMenu_tooltipTitle'] = 'Check items to ignore'
L['subClassMenu_tooltipText'] = 'You can ignore specific items by checking them'
L['mailMenu'] = 'Send attachments'
L['mailMenuHelp'] = 'Help'
L['mailMenuHelp_tooltipTitle'] = 'Mail items'
L['mailMenuHelp_tooltipText'] = tostring(
[[
Add items to mail by either class, sub class or by item.

|cffffffffAlt|r+click to attach the first 12 slots of your bags that contain the item(s) you've clicked.
]]
)

local locale = GetLocale()

if locale == "deDE" then

end

MySacks.Locales = L