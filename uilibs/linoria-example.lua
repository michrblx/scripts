-- ez example of linoria

local GameName = game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId).Name

local repo = 'https://raw.githubusercontent.com/wally-rblx/LinoriaLib/main/'

local Library = loadstring(game:HttpGet(repo .. 'Library.lua'))()
local ThemeManager = loadstring(game:HttpGet(repo .. 'addons/ThemeManager.lua'))()
local SaveManager = loadstring(game:HttpGet(repo .. 'addons/SaveManager.lua'))()

local Window = Library:CreateWindow({
    Title = 'linoria - ' .. GameName,
    Center = true, 
    AutoShow = true,
})

local Tabs = {
    Main = Window:AddTab('Main'),
    ['UI Settings'] = Window:AddTab('Config'),
}

local TabBox1 = Tabs.Main:AddLeftTabbox() 

local Tab0 = TabBox1:AddTab('Gun Mods')

Tab0:AddDropdown('dropdown', {
    Values = { 'AK-47', 'Pistol', 'Knife', 'Hammer', "Shotgun" },
    Default = 0,
    Multi = false,

    Text = 'Gear Giver',
    Tooltip = 'Select a gear from the dropdown to give it to you.',
})

Options.dropdown:OnChanged(function()

end)

Tab0:AddToggle('toggle', {
    Text = 'toggle',
    Default = false,
    Tooltip = 'Tries to pick up a keycard extremely fast.',
})

Toggles.toggle:OnChanged(function()
    print(Toggles.toggle.Value)
end)

local buttonshit = Tab3:AddButton('button', function()

end)

Tab0:AddSlider('walkspeed', {
    Text = 'WalkSpeed',

    Default = 16,
    Min = 16,
    Max = 350,
    Rounding = 0,

    Compact = false,
})

Options.walkspeed:OnChanged(function()
    local Humanoid = game.Players.LocalPlayer.Character:WaitForChild("Humanoid")
	Humanoid.WalkSpeed = Options.walkspeed.Value
end)

Library.KeybindFrame.Visible = false;

Library:OnUnload(function()
    print('Unloaded!')
    Library.Unloaded = true
end)

local MenuGroup = Tabs['UI Settings']:AddLeftGroupbox('Menu')

MenuGroup:AddButton('Unload', function() Library:Unload() end)
MenuGroup:AddLabel('Menu bind'):AddKeyPicker('MenuKeybind', { Default = 'Insert', NoUI = true, Text = 'Menu keybind' }) 

Library.ToggleKeybind = Options.MenuKeybind

ThemeManager:SetLibrary(Library)
SaveManager:SetLibrary(Library)

SaveManager:IgnoreThemeSettings() 

SaveManager:SetIgnoreIndexes({ 'MenuKeybind' }) 

ThemeManager:SetFolder('universal')
SaveManager:SetFolder('universal/game')

SaveManager:BuildConfigSection(Tabs['UI Settings']) 
 
ThemeManager:ApplyToTab(Tabs['UI Settings'])

