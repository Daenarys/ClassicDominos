--------------------------------------------------------------------------------
-- Pet Bar
-- A movable action bar for pets
--------------------------------------------------------------------------------

local AddonName, Addon = ...
local L = LibStub('AceLocale-3.0'):GetLocale(AddonName)

--------------------------------------------------------------------------------
-- Button Setup
--------------------------------------------------------------------------------

local function getPetButton(id)
    return _G[('PetActionButton%d'):format(id)]
end

local function skinPetButton(self)
    _G[self:GetName() .. 'Icon']:SetTexCoord(0.06, 0.94, 0.06, 0.94)
    self.IconMask:SetSize(64, 64)
    self.SlotBackground:Hide()
    self.PushedTexture:SetTexture([[Interface\Buttons\UI-Quickslot-Depress]])
    self.PushedTexture:ClearAllPoints()
    self.PushedTexture:SetAllPoints()
    self.HighlightTexture:SetTexture([[Interface\Buttons\ButtonHilight-Square]])
    self.HighlightTexture:ClearAllPoints()
    self.HighlightTexture:SetAllPoints()
    self.HighlightTexture:SetBlendMode("ADD")
    self.CheckedTexture:SetTexture([[Interface\Buttons\CheckButtonHilight]])
    self.CheckedTexture:ClearAllPoints()
    self.CheckedTexture:SetAllPoints()
    self.CheckedTexture:SetBlendMode("ADD")
    self.Flash:SetTexture([[Interface\Buttons\UI-QuickslotRed]])
    self.Flash:ClearAllPoints()
    self.Flash:SetAllPoints()
    self.AutoCastable:SetTexture("Interface\\Buttons\\UI-AutoCastableOverlay")
    self.AutoCastable:SetSize(58, 58)
    self.AutoCastable:ClearAllPoints()
    self.AutoCastable:SetPoint("CENTER", 0, 0)

    --simulate old floatingbg
    hooksecurefunc(PetActionBar, 'Update', function()
        local petActionID = self:GetID()
        local texture = GetPetActionInfo(petActionID);
        if ( texture ) then
            self.NormalTexture:SetTexture([[Interface\Buttons\UI-Quickslot2]])
            self.NormalTexture:SetSize(54, 54)
            self.NormalTexture:ClearAllPoints()
            self.NormalTexture:SetPoint("CENTER", 0, -1)
            self.NormalTexture:SetVertexColor(1, 1, 1, 0.5)
        else
            self.NormalTexture:SetTexture([[Interface\Buttons\UI-Quickslot]])
            self.NormalTexture:SetSize(54, 54)
            self.NormalTexture:ClearAllPoints()
            self.NormalTexture:SetPoint("CENTER", 0, -1)
            self.NormalTexture:SetVertexColor(1, 1, 1, 0.5)
        end
    end)
end

for id = 1, NUM_PET_ACTION_SLOTS do
    local button = getPetButton(id)

    button.buttonType = 'BONUSACTIONBUTTON'

    Addon.BindableButton:AddQuickBindingSupport(button, ('BONUSACTIONBUTTON%d'):format(id))

    skinPetButton(button)

    -- disable to prevent art updates
    if button.UpdateButtonArt then
        button.UpdateButtonArt = function() end
    end
end

--------------------------------------------------------------------------------
-- The Pet Bar
--------------------------------------------------------------------------------

local PetBar = Addon:CreateClass('Frame', Addon.ButtonBar)

function PetBar:New()
    return PetBar.proto.New(self, 'pet')
end

function PetBar:GetDisplayName()
    return L.PetBarDisplayName
end

function PetBar:IsOverrideBar()
    -- TODO: make overrideBar a property of the bar itself instead of a global
    -- setting
    return Addon.db.profile.possessBar == self.id
end

function PetBar:UpdateOverrideBar()
    self:UpdateDisplayConditions()
end

function PetBar:GetDisplayConditions()
    return '[@pet,exists,nopossessbar]show;hide'
end

function PetBar:GetDefaults()
    return {
        point = 'CENTER',
        x = 0,
        y = -32,
        spacing = 6
    }
end

function PetBar:NumButtons()
    return NUM_PET_ACTION_SLOTS
end

function PetBar:AcquireButton(index)
    return getPetButton(index)
end

function PetBar:OnAttachButton(button)
    button:UpdateHotkeys()
    Addon:GetModule('Tooltips'):Register(button)
end

function PetBar:OnDetachButton(button)
    Addon:GetModule('Tooltips'):Unregister(button)
end

-- keybound events
function PetBar:KEYBOUND_ENABLED()
    self:ForButtons("Show")
end

function PetBar:KEYBOUND_DISABLED()
    local petBarShown = PetHasActionBar()

    for _, button in pairs(self.buttons) do
        if petBarShown and GetPetActionInfo(button:GetID()) then
            button:Show()
        else
            button:Hide()
        end
    end
end

--------------------------------------------------------------------------------
-- the module
--------------------------------------------------------------------------------

local PetBarModule = Addon:NewModule('PetBar', 'AceEvent-3.0')

function PetBarModule:Load()
    self.bar = PetBar:New()

    self:RegisterEvent('UPDATE_BINDINGS')
end

function PetBarModule:Unload()
    self:UnregisterAllEvents()

    if self.bar then
        self.bar:Free()
        self.bar = nil
    end
end

function PetBarModule:UPDATE_BINDINGS()
    self.bar:ForButtons('UpdateHotkeys')
end