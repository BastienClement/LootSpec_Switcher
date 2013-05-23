local size, space = 28, 5
local anchor = CreateFrame("Frame", "LootSpecSwitcher", UIParent)
local buttons = {}

anchor:SetPoint("CENTER", 0, 0)

local backdrop = {
	bgFile = "Interface\\BUTTONS\\WHITE8X8",
	edgeFile = "",
	tile = false, tileSize = 0, edgeSize = 1,
	insets = { left = 0, right = 0, top = 0, bottom = 0 }
}

anchor:SetBackdrop(backdrop)
anchor:SetBackdropColor(0, 0, 0, 0)

local function OnDragStart()
	anchor:StartMoving()
end

local function OnDragStop()
	anchor:StopMovingOrSizing()
end

anchor:SetClampedToScreen(true)
anchor:SetMovable(true)
anchor:RegisterForDrag("LeftButton")
anchor:SetScript("OnDragStart", OnDragStart)
anchor:SetScript("OnDragStop", OnDragStop)

anchor:EnableMouse(false)

local function ButtonHandler(id)
	return function()
		if GetLootSpecialization() == id then
			SetLootSpecialization(0)
		else
			SetLootSpecialization(id)
		end
	end
end

local function Init()
	local numSpecs = GetNumSpecializations()
	anchor:SetSize((size * numSpecs) + (space * (numSpecs + 1)), size + (space * 2))
	
	for i = 1, numSpecs do
		local id, _, _, icon = GetSpecializationInfo(i)
		
		local button = CreateFrame("Button", nil, anchor)
		button:SetSize(size, size)
		button:SetPoint("CENTER", anchor, "BOTTOMLEFT", ((i - 1) * (size + space)) + (size / 2) + space, (size / 2) + space)
		
		button:SetScript("OnClick", ButtonHandler(id))
		
		local tex = button:CreateTexture()
		tex:SetAllPoints()
		tex:SetTexture(icon)
		button.tex = tex
		
		buttons[id] = button
	end
end

function UpdateButtons(_, ev)
	if ev == "PLAYER_ENTERING_WORLD" and Init then
		Init()
		Init = nil
	end
	
	local current = GetLootSpecialization()
	
	for id, button in pairs(buttons) do
		if current == 0 or id == current then
			button.tex:SetAlpha(1)
		else
			button.tex:SetAlpha(0.5)
		end
	end
end

anchor:RegisterEvent("PLAYER_ENTERING_WORLD")
anchor:RegisterEvent("PLAYER_LOOT_SPEC_UPDATED")
anchor:SetScript("OnEvent", UpdateButtons)

local locked = true
local function SlashHandler()
	if locked then
		anchor:SetBackdropColor(0, 0, 0, 0.6)
		anchor:EnableMouse(true)
	else
		anchor:SetBackdropColor(0, 0, 0, 0)
		anchor:EnableMouse(false)
	end
	locked = not locked
end

SlashCmdList.LSS = SlashHandler
SLASH_LSS1 = "/lss"
