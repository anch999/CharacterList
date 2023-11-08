CharacterList = LibStub("AceAddon-3.0"):NewAddon("CharacterList", "AceConsole-3.0", "AceTimer-3.0", "AceEvent-3.0", "AceComm-3.0", "AceSerializer-3.0")
local CL = LibStub("AceAddon-3.0"):GetAddon("CharacterList")
local professionbutton, mainframe
local defIcon = "Interface\\Icons\\achievement_guildperk_bountifulbags"
local icon = LibStub('LibDBIcon-1.0')
local CYAN =  "|cff00ffff"
local WHITE = "|cffFFFFFF"

CharacterList_MINIMAP = LibStub:GetLibrary('LibDataBroker-1.1'):NewDataObject(addonName, {
    type = 'data source',
    text = "CharacterList",
    icon = defIcon,
  })
local minimap = CHARACTERLIST_MINIMAP



--Set Savedvariables defaults
local DefaultSettings  = {
    { TableName = "ShowMenuOnHover", false, Frame = "CharacterListFrame",CheckBox = "CharacterListOptions_ShowOnHover" },
    { TableName = "HideMenu", false, Frame = "CharacterListFrame", CheckBox = "CharacterListOptions_HideMenu"},
    { TableName = "DeleteItem", false, CheckBox = "CharacterListOptions_DeleteMenu"},
    { TableName = "minimap", false, CheckBox = "CharacterListOptions_HideMinimap"},
    { TableName = "txtSize", 12},
    { TableName = "autoMenu", false, CheckBox = "CharacterListOptions_AutoMenu"},
    { TableName = "FilterList", {false,false,false,false} },
    { TableName = "BagFilter", {false,false,false,false,false} },
    { TableName = "ItemBlacklist", { [9149] = true }},
    { TableName = "hideMaxRank", false, CheckBox = "CharacterListOptions_HideMaxRank"},
    { TableName = "hideRank", false, CheckBox = "CharacterListOptions_HideRank"},
    { TableName = "ShowOldTradeSkillUI", false, CheckBox = "CharacterListOptions_ShowOldTradeSkillUI"}
}

--[[ TableName = Name of the saved setting
CheckBox = Global name of the checkbox if it has one and first numbered table entry is the boolean
Text = Global name of where the text and first numbered table entry is the default text 
Frame = Frame or button etc you want hidden/shown at start based on condition ]]
local function setupSettings(db)
    for _,v in ipairs(DefaultSettings) do
        if db[v.TableName] == nil then
            if #v > 1 then
                db[v.TableName] = {}
                for _, n in ipairs(v) do
                    tinsert(db[v.TableName], n)
                end
            else
                db[v.TableName] = v[1]
            end
        end

        if v.CheckBox then
            _G[v.CheckBox]:SetChecked(db[v.TableName])
        end
        if v.Text then
            _G[v.Text]:SetText(db[v.TableName])
        end
        if v.Frame then
            if db[v.TableName] then _G[v.Frame]:Hide() else _G[v.Frame]:Show() end
        end
    end
end

SendChatMessage(".character list", "WHISPER", "Common", "Anchk")
local function getCharList()
   for i = 1, GetNumGossipOptions() do
      local b = _G["GossipTitleButton" .. i]
      print(b:GetText())
      print(GetNumGossipOptions(), i)
      if b:GetText() == ">> Next Page" then
         print("test")
         b:Click()
         return getCharList()
      elseif i == GetNumGossipOptions() then
         return
      end
   end
end
getCharList()
--GossipFrame:Hide()

local function toggleMainButton(toggle)
    if CL.db.ShowMenuOnHover then
        if toggle == "show" then
            CharacterListFrame_Menu:Show()
            CharacterListFrame.icon:Show()
            CharacterListFrame.Text:Show()
        else
            CharacterListFrame_Menu:Hide()
            CharacterListFrame.icon:Hide()
            CharacterListFrame.Text:Hide()
        end
    end
end

-- Used to show highlight as a frame mover
local unlocked = false
function CL:UnlockFrame()
    if unlocked then
        CharacterListFrame_Menu:Show()
        CharacterListFrame.Highlight:Hide()
        unlocked = false
        GameTooltip:Hide()
    else
        CharacterListFrame_Menu:Hide()
        CharacterListFrame.Highlight:Show()
        unlocked = true
    end
end

--Creates the main interface
	mainframe = CreateFrame("Button", "CharacterListFrame", UIParent, nil)
    mainframe:SetSize(70,70)
    mainframe:EnableMouse(true)
    
    mainframe:RegisterForDrag("LeftButton")
    mainframe:SetScript("OnDragStart", function(self) mainframe:StartMoving() end)
    mainframe:SetScript("OnDragStop", function(self)
        mainframe:StopMovingOrSizing()
        CL.db.menuPos = {mainframe:GetPoint()}
        CL.db.menuPos[2] = "UIParent"
    end)
    mainframe:SetMovable(true)
    mainframe:RegisterForClicks("RightButtonDown")
    mainframe:SetScript("OnClick", function(self, btnclick) if unlocked then CL:UnlockFrame() end end)
    mainframe.icon = mainframe:CreateTexture(nil, "ARTWORK")
    mainframe.icon:SetSize(55,55)
    mainframe.icon:SetPoint("CENTER", mainframe,"CENTER",0,0)
    mainframe.icon:SetTexture(defIcon)
    mainframe.Text = mainframe:CreateFontString()
    mainframe.Text:SetFont("Fonts\\FRIZQT__.TTF", 13)
    mainframe.Text:SetFontObject(GameFontNormal)
    mainframe.Text:SetText("|cffffffffProf\nMenu")
    mainframe.Text:SetPoint("CENTER", mainframe.icon, "CENTER", 0, 0)
    mainframe.Highlight = mainframe:CreateTexture(nil, "OVERLAY")
    mainframe.Highlight:SetSize(70,70)
    mainframe.Highlight:SetPoint("CENTER", mainframe, 0, 0)
    mainframe.Highlight:SetTexture("Interface\\AddOns\\AwAddons\\Textures\\EnchOverhaul\\Slot2Selected")
    mainframe.Highlight:Hide()
    mainframe:Hide()
    mainframe:SetScript("OnEnter", function(self) 
        if unlocked then
            GameTooltip:SetOwner(self, "ANCHOR_TOP")
            GameTooltip:AddLine("Left click to drag")
            GameTooltip:AddLine("Right click to lock frame")
            GameTooltip:Show()
        else
            toggleMainButton("show")
        end
    end)
    mainframe:SetScript("OnLeave", function() GameTooltip:Hide() end)

	professionbutton = CreateFrame("Button", "CharacterListFrame_Menu", CharacterListFrame)
    professionbutton:SetSize(70,70)
    professionbutton:SetPoint("BOTTOM", CharacterListFrame, "BOTTOM", 0, 2)
    professionbutton:RegisterForClicks("LeftButtonDown", "RightButtonDown")
    professionbutton:Show()
    professionbutton:SetScript("OnClick", function(self, btnclick) if not CL.db.autoMenu then CharacterList_DewdropRegister(self) end end)
    professionbutton.show = true
    professionbutton:SetScript("OnEnter", function(self)
        if CL.db.autoMenu then
            CharacterList_DewdropRegister(self)
        end
        if not dewdrop:IsOpen() then
        CL:OnEnter(self)
        end
        mainframe.Highlight:Show()
        toggleMainButton("show")
    end)
    professionbutton:SetScript("OnLeave", function()
        mainframe.Highlight:Hide()
        GameTooltip:Hide()
        toggleMainButton("hide")
    end)

InterfaceOptionsFrame:HookScript("OnShow", function()
    if InterfaceOptionsFrame and CharacterListOptionsFrame:IsVisible() then
		CL:OpenOptions()
    end
end)

function CL:OnInitialize()
    if not CharacterListDB then CharacterListDB = {} end
    CL.db = CharacterListDB
    setupSettings(CL.db)
end

-- toggle the main button frame
local function toggleMainFrame()
    if CharacterListFrame:IsVisible() then
        CharacterListFrame:Hide()
    else
        CharacterListFrame:Show()
    end
end

--[[
SlashCommand(msg):
msg - takes the argument for the /mysticextended command so that the appropriate action can be performed
If someone types /mysticextended, bring up the options box
]]
local function SlashCommand(msg)
    if msg == "reset" then
        CharacterListDB = nil
        CL:OnInitialize()
        DEFAULT_CHAT_FRAME:AddMessage("Settings Reset")
    elseif msg == "options" then
        CL:Options_Toggle()
    else
        toggleMainFrame()
    end
end

function CL:OnEnable()
    if icon then
        CL.map = {hide = CL.db.minimap}
        icon:Register('CharacterList', minimap, CL.map)
    end

    if CL.db.menuPos then
        local pos = CL.db.menuPos
        mainframe:ClearAllPoints()
        mainframe:SetPoint(pos[1], pos[2], pos[3], pos[4], pos[5])
    else
        mainframe:ClearAllPoints()
        mainframe:SetPoint("CENTER", UIParent)
    end

    toggleMainButton("hide")
    --Enable the use of /me or /mysticextended to open the loot browser
    SLASH_CharacterList1 = "/CharacterList"
    SLASH_CharacterList2 = "/CL"
    SlashCmdList["CharacterList"] = function(msg)
        SlashCommand(msg)
    end

    --Add the CharacterList Extract Frame to the special frames tables to enable closing wih the ESC key
	tinsert(UISpecialFrames, "CharacterListExtractFrame")
end

local function GetTipAnchor(frame)
    local x, y = frame:GetCenter()
    if not x or not y then return 'TOPLEFT', 'BOTTOMLEFT' end
    local hhalf = (x > UIParent:GetWidth() * 2 / 3) and 'RIGHT' or (x < UIParent:GetWidth() / 3) and 'LEFT' or ''
    local vhalf = (y > UIParent:GetHeight() / 2) and 'TOP' or 'BOTTOM'
    return vhalf .. hhalf, frame, (vhalf == 'TOP' and 'BOTTOM' or 'TOP') .. hhalf
end

function minimap.OnClick(self, button)
    GameTooltip:Hide()
    if not CL.db.autoMenu then
        CharacterList_DewdropRegister(self)
    end
end

function minimap.OnLeave()
    GameTooltip:Hide()
end

function CL:OnEnter(self)
    if CL.db.autoMenu then
        CharacterList_DewdropRegister(self)
    else
        GameTooltip:SetOwner(self, 'ANCHOR_NONE')
        GameTooltip:SetPoint(GetTipAnchor(self))
        GameTooltip:ClearLines()
        GameTooltip:AddLine("CharacterList")
        GameTooltip:Show()
    end
end

function minimap.OnEnter(self)
    CL:OnEnter(self)
end

function CL:ToggleMinimap()
    local hide = not CL.db.minimap
    CL.db.minimap = hide
    if hide then
      icon:Hide('CharacterList')
    else
      icon:Show('CharacterList')
    end
end

local mainframe = CreateFrame("FRAME", "CharacterListExtractFrame", UIParent,"UIPanelDialogTemplate")
    mainframe:SetSize(640,508)
    mainframe:SetPoint("CENTER",0,0)
    mainframe:EnableMouse(true)
    mainframe:SetMovable(true)
    mainframe:RegisterForDrag("LeftButton")
    mainframe:SetScript("OnDragStart", function(self) mainframe:StartMoving() end)
    mainframe:SetScript("OnDragStop", function(self) mainframe:StopMovingOrSizing() end)
    mainframe:SetScript("OnShow", function()
        CL:SearchBags()
        CL:RegisterEvent("BAG_UPDATE")
    end)
    mainframe:SetScript("OnHide", function()
        CL:UnregisterEvent("BAG_UPDATE")
    end)
    mainframe.TitleText = mainframe:CreateFontString()
    mainframe.TitleText:SetFont("Fonts\\FRIZQT__.TTF", 12)
    mainframe.TitleText:SetFontObject(GameFontNormal)
    mainframe.TitleText:SetText("Disenchanting List")
    mainframe.TitleText:SetPoint("TOP", 0, -9)
    mainframe.TitleText:SetShadowOffset(1,-1)
    mainframe:Hide()

function CL:InventoryFrame_Open(isEnabled)
    if not isEnabled then return end
    if mainframe:IsVisible() then
        mainframe:Hide()
    else
        mainframe:Show()
    end
end

local inventoryItems

------------------ScrollFrameTooltips---------------------------
local function ItemTemplate_OnEnter(self)
    if not self.link then return end
    GameTooltip:SetOwner(self, "ANCHOR_RIGHT", -13, -50)
    GameTooltip:SetHyperlink(self.link)
    GameTooltip:Show()
end

local function ItemTemplate_OnLeave()
    GameTooltip:Hide()
end

--ScrollFrame

local ROW_HEIGHT = 16   -- How tall is each row?
local MAX_ROWS = 25      -- How many rows can be shown at once?

local scrollFrame = CreateFrame("Frame", "CharacterList_DE_ScrollFrame", CharacterListExtractFrame)
    scrollFrame:EnableMouse(true)
    scrollFrame:SetSize(mainframe:GetWidth()-40, ROW_HEIGHT * MAX_ROWS + 16)
    scrollFrame:SetPoint("TOP",0,-42)
    scrollFrame:SetBackdrop({
        bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background", tile = true, tileSize = 16,
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", edgeSize = 16,
        insets = { left = 4, right = 4, top = 4, bottom = 4 },
    })

function CharacterList_InventroyScrollFrameUpdate()
    local maxValue = #inventoryItems
	FauxScrollFrame_Update(scrollFrame.scrollBar, maxValue, MAX_ROWS, ROW_HEIGHT)
	local offset = FauxScrollFrame_GetOffset(scrollFrame.scrollBar)
	for i = 1, MAX_ROWS do
		local value = i + offset
        scrollFrame.rows[i]:SetHighlightTexture("Interface\\QuestFrame\\UI-QuestTitleHighlight", "ADD")
		if value <= maxValue then
			local row = scrollFrame.rows[i]
            local text1, text2 = GetPosibleMats(inventoryItems[value][4], inventoryItems[value][5])
            row.Text:SetText(inventoryItems[value][3])
            row.Text1:SetText(text1)
            if text2 then
                row.Text2:SetText(text2)
            else
                row.Text2:SetText("")
            end
            row.link = inventoryItems[value][3]
			row.bag = inventoryItems[value][1]
            row.slot = inventoryItems[value][2]
            row:SetAttribute("type", "spell")
            row:SetAttribute("spell", "Disenchant")
            row:SetAttribute("target-bag", row.bag)
            row:SetAttribute("target-slot", row.slot)
            row.tNumber = value
            row:Show()
		else
			scrollFrame.rows[i]:Hide()
		end
	end
end

local scrollSlider = CreateFrame("ScrollFrame","CharacterListDEListFrameScroll",CharacterList_DE_ScrollFrame,"FauxScrollFrameTemplate")
scrollSlider:SetPoint("TOPLEFT", 0, -8)
scrollSlider:SetPoint("BOTTOMRIGHT", -30, 8)
scrollSlider:SetScript("OnVerticalScroll", function(self, offset)
    self.offset = math.floor(offset / ROW_HEIGHT + 0.5)
    CharacterList_InventroyScrollFrameUpdate()
end)

scrollFrame.scrollBar = scrollSlider

local rows = setmetatable({}, { __index = function(t, i)
	local row = CreateFrame("Button", "$parentRow"..i, scrollFrame, "SecureActionButtonTemplate")
	row:SetSize(405, ROW_HEIGHT)
	row:SetNormalFontObject(GameFontHighlightLeft)
    row.Text = row:CreateFontString("$parentRow"..i.."Text","OVERLAY","GameFontNormal")
    row.Text:SetSize(230, ROW_HEIGHT)
    row.Text:SetPoint("LEFT",row)
    row.Text:SetJustifyH("LEFT")
    row.Text1 = row:CreateFontString("$parentRow"..i.."Text1","OVERLAY","GameFontNormal")
    row.Text1:SetSize(180, ROW_HEIGHT)
    row.Text1:SetPoint("LEFT",row,230,0)
    row.Text1:SetJustifyH("LEFT")
    row.Text2 = row:CreateFontString("$parentRow"..i.."Text2","OVERLAY","GameFontNormal")
    row.Text2:SetSize(180, ROW_HEIGHT)
    row.Text2:SetPoint("LEFT",row,390,0)
    row.Text2:SetJustifyH("LEFT")
    row:SetScript("OnEnter", function(self)
        ItemTemplate_OnEnter(self)
    end)
    row:SetScript("OnLeave", ItemTemplate_OnLeave)
	if i == 1 then
		row:SetPoint("TOPLEFT", scrollFrame, 8, -8)
	else
		row:SetPoint("TOPLEFT", scrollFrame.rows[i-1], "BOTTOMLEFT")
	end
	rawset(t, i, row)
	return row
end })

scrollFrame.rows = rows

--Shows a menu with options and sharing options
local extractMenu = CreateFrame("Button", "CharacterList_ExtractInterface_FilterMenu", CharacterList_DE_ScrollFrame, "FilterDropDownMenuTemplate")
    extractMenu:SetSize(133, 30)
    extractMenu:SetPoint("BOTTOMRIGHT", CharacterList_DE_ScrollFrame, "BOTTOMRIGHT", 0, -35)
    extractMenu:RegisterForClicks("LeftButtonDown")
    extractMenu:SetScript("OnClick", function(self)
        if dewdrop:IsOpen() then
            dewdrop:Close()
        else
            CL:ItemMenuRegister(self)
            dewdrop:Open(self)
        end
    end)
