-- **********************************************************
-- **                Deadly Boss Mods - GUI                **
-- **             http://www.deadlybossmods.com            **
-- **********************************************************
--
-- This addon is written and copyrighted by:
--    * Martin Verges (Nitram @ EU-Azshara) (DBM-Gui)
--    * Paul Emmerich (Tandanu @ EU-Aegwynn) (DBM-Core)
-- 
-- The localizations are written by:
--    * deDE: Nitram/Tandanu
--    * enGB: Nitram/Tandanu
--    * (add your names here!)
--
-- 
-- The code of this addon is licensed under a Creative Commons Attribution-Noncommercial-Share Alike 3.0 License. (see license.txt)
-- All included textures and sounds are copyrighted by their respective owners.
--
--
--  You are free:
--    * to Share � to copy, distribute, display, and perform the work
--    * to Remix � to make derivative works
--  Under the following conditions:
--    * Attribution. You must attribute the work in the manner specified by the author or licensor (but not in any way that suggests that they endorse you or your use of the work).
--    * Noncommercial. You may not use this work for commercial purposes.
--    * Share Alike. If you alter, transform, or build upon this work, you may distribute the resulting work only under the same or similar license to this one.
--
--


local FrameTitle = "DBM_GUI_Option_"	-- all GUI frames get automatically a name FrameTitle..ID

local PanelPrototype = {}
DBM_GUI = {}
setmetatable(PanelPrototype, {__index = DBM_GUI})

local L = DBM_GUI_Translations

L.AreaTitle_BarSetup = "General Bar Options"
L.AreaTitle_BarSetupSmall = "Small Bar Options"
L.AreaTitle_BarSetupHuge = "Huge Bar Options"
L.BarIconLeft = "Left Icon"
L.BarIconRight = "Right Icon"
L.Reset = "reset"
L.BarOffSetX = "OffSet X"
L.BarOffSetY = "OffSet Y"

local usemodelframe = true	-- very beta

function DBM_GUI:ShowHide(forceshow)
	if not DBM_GUI_Frame then DBM_GUI:CreateOptionsMenu() end

	if forceshow == true then
		self:UpdateModList()
		DBM_GUI_OptionsFrame:Show()

	elseif forceshow == false then
		DBM_GUI_OptionsFrame:Hide()

	else 
		if DBM_GUI_OptionsFrame:IsShown() then 
			DBM_GUI_OptionsFrame:Hide() 
		else 
			self:UpdateModList()
			DBM_GUI_OptionsFrame:Show() 
		end
	end
end

do 
	local prottypemetatable = {__index = PanelPrototype}
	-- This function creates a new entry in the menu
	--
	--  arg1 = Text for the UI Button
	--  arg2 = nil or ("option" or 2)  ... nil will place as a Boss Mod, otherwise as a Option Tab
	--
	function DBM_GUI:CreateNewPanel(FrameName, FrameTyp, showsub) 
		local panel = CreateFrame('Frame', FrameTitle..self:GetNewID(), DBM_GUI_OptionsFramePanelContainer)
		panel.mytype = "panel"
		panel.sortID = self:GetCurrentID()
		panel:SetWidth(DBM_GUI_OptionsFramePanelContainerFOV:GetWidth());
		panel:SetHeight(DBM_GUI_OptionsFramePanelContainerFOV:GetHeight()); 
		panel:SetPoint("TOPLEFT", DBM_GUI_OptionsFramePanelContainer, "TOPLEFT")
	
		panel.name = FrameName
		panel.showsub = showsub
		--panel:SetAllPoints(DBM_GUI_OptionsFramePanelContainer)
		panel:Hide()
	
		if FrameTyp == "option" or FrameTyp == 2 then
			DBM_GUI_Options:CreateCategory(panel, self and self.frame and self.frame.name)
		else
			DBM_GUI_Bosses:CreateCategory(panel, self and self.frame and self.frame.name)
		end
	
		self:SetLastObj(nil)
		self.panels = self.panels or {}
		table.insert(self.panels, {frame = panel, parent = self, framename = FrameTitle..self:GetCurrentID()})
		local obj = self.panels[#self.panels]
		return setmetatable(obj, prottypemetatable)
	end

	-- This function adds areas to group widgets
	--
	--  arg1 = titel of this area
	--  arg2 = width ot the area
	--  arg3 = hight of the area
	--  arg4 = autoplace
	--
	function PanelPrototype:CreateArea(name, width, height, autoplace)
		local area = CreateFrame('Frame', FrameTitle..self:GetNewID(), self.frame, 'OptionsBoxTemplate')
		area.mytype = "area"
		area:SetBackdropBorderColor(0.4, 0.4, 0.4)
		area:SetBackdropColor(0.15, 0.15, 0.15, 0.5)
		getglobal(FrameTitle..self:GetCurrentID()..'Title'):SetText(name)
		area:SetWidth(width or self.frame:GetWidth()-10)
		area:SetHeight(height or self.frame:GetHeight()-10)
		
		if autoplace then
			if select('#', self.frame:GetChildren()) == 1 then
				area:SetPoint('TOPLEFT', self.frame, 5, -17)
			else
				area:SetPoint('TOPLEFT', select(-2, self.frame:GetChildren()) or self.frame, "BOTTOMLEFT", 0, -17)
			end
		end
	
		self:SetLastObj(nil)
		self.areas = self.areas or {}
		table.insert(self.areas, {frame = area, parent = self, framename = FrameTitle..self:GetCurrentID()})
		return setmetatable(self.areas[#self.areas], prottypemetatable)
	end
end

do 
	local FrameNames = {}
	function DBM_GUI:AddFrame(FrameName)
		table.insert(FrameNames, FrameName)
	end
	function DBM_GUI:IsPresent(FrameName)
		for k,v in ipairs(FrameNames) do
			if v == FrameName then
				return true
			end
		end
		return false
	end
end


do
	local framecount = 0
	function DBM_GUI:GetNewID() 
		framecount = framecount + 1
		return framecount
	end
	function DBM_GUI:GetCurrentID()
		return framecount
	end

	local lastobject = nil
	function DBM_GUI:GetLastObj() 
		return lastobject
	end
	function DBM_GUI:SetLastObj(obj)
		lastobject = obj
		return lastobject
	end
end

-- This function creates a check box
-- Autoplaced buttons will be placed under the last widget
--
--  arg1 = text right to the CheckBox
--  arg2 = autoplaced (true or nil/false)
--  arg3 = text on left side
--  arg4 = DBM.Options[arg4] 
--  arg5 = DBM.Bars:SetOption(arg5, ...)
--
function PanelPrototype:CreateCheckButton(name, autoplace, textleft, dbmvar, dbtvar)
	local button = CreateFrame('CheckButton', FrameTitle..self:GetNewID(), self.frame, 'OptionsCheckButtonTemplate')
	button.myheight = 25
	getglobal(button:GetName() .. 'Text'):SetText(name)
	getglobal(button:GetName() .. 'Text'):SetWidth( self.frame:GetWidth() - 50 )

	if textleft then
		getglobal(button:GetName() .. 'Text'):ClearAllPoints()
		getglobal(button:GetName() .. 'Text'):SetPoint("RIGHT", button, "LEFT", 0, 0)
		getglobal(button:GetName() .. 'Text'):SetJustifyH("RIGHT")
	else
		getglobal(button:GetName() .. 'Text'):SetJustifyH("LEFT")
	end
	
	if dbmvar and DBM.Options[dbmvar] ~= nil then
		button:SetScript("OnShow",  function() button:SetChecked(DBM.Options[dbmvar]) end)
		button:SetScript("OnClick", function() DBM.Options[dbmvar] = not DBM.Options[dbmvar] end)
	end

	if dbtvar then
		button:SetScript("OnShow",  function() button:SetChecked( DBM.Bars:GetOption(dbtvar) ) end)
		button:SetScript("OnClick", function() DBM.Bars:SetOption(dbtvar, not DBM.Bars:GetOption(dbtvar)) end)
	end

	if autoplace then
		if self:GetLastObj() then
			button:ClearAllPoints()
			button:SetPoint('TOPLEFT', self:GetLastObj(), "BOTTOMLEFT", 0, 2)
		else
			button:ClearAllPoints()
			button:SetPoint('TOPLEFT', 10, -12)
		end
	end

	self:SetLastObj(button)
	return button
end

-- This function creates an EditBox
--
--  arg1 = Title text, placed ontop of the EditBox
--  arg2 = Text placed within the EditBox
--  arg3 = width
--  arg4 = height
--
function PanelPrototype:CreateEditBox(text, value, width, height)
	local textbox = CreateFrame('EditBox', FrameTitle..self:GetNewID(), self.frame, 'DBM_GUI_FrameEditBoxTemplate')
	getglobal(FrameTitle..self:GetCurrentID().."Text"):SetText(text)
	textbox:SetWidth(width or 100)
	textbox:SetHeight(height or 20)

	self:SetLastObj(textbox)
	return textbox
end

-- This function creates a slider for numeric values
--
--  arg1 = text ontop of the slider, centered
--  arg2 = lowest value
--  arg3 = highest value
--  arg4 = stepping
--  arg5 = framewidth
--
function PanelPrototype:CreateSlider(text, low, high, step, framewidth)
	local slider = CreateFrame('Slider', FrameTitle..self:GetNewID(), self.frame, 'OptionsSliderTemplate')
	slider:SetMinMaxValues(low, high)
	slider:SetValueStep(step)
	slider:SetWidth(famewidth or 180)
	getglobal(FrameTitle..self:GetCurrentID()..'Text'):SetText(text)

	self:SetLastObj(slider)
	return slider
end

-- This function creates a color picker
--
--  arg1 = width of the colorcircle (128 default)
--  arg2 = true if you want an alpha selector
--  arg3 = width of the alpha selector (32 default)

function PanelPrototype:CreateColorSelect(dimension, withalpha, alphawidth)
	--- Color select texture with wheel and value
	local colorselect = CreateFrame("ColorSelect", FrameTitle..self:GetNewID(), self.frame)
	if withalpha then
		colorselect:SetWidth((dimension or 128)+37)
	else
		colorselect:SetWidth((dimension or 128))
	end
	colorselect:SetHeight(dimension or 128)
	
	-- create a color wheel
	local colorwheel = colorselect:CreateTexture()
	colorwheel:SetWidth(dimension or 128)
	colorwheel:SetHeight(dimension or 128)
	colorwheel:SetPoint("TOPLEFT", colorselect, "TOPLEFT", 5, 0)
	colorselect:SetColorWheelTexture(colorwheel)
	
	-- create the colorpicker
	local colorwheelthumbtexture = colorselect:CreateTexture()
	colorwheelthumbtexture:SetTexture("Interface\\Buttons\\UI-ColorPicker-Buttons")
	colorwheelthumbtexture:SetWidth(10)
	colorwheelthumbtexture:SetHeight(10)
	colorwheelthumbtexture:SetTexCoord(0,0.15625, 0, 0.625)
	colorselect:SetColorWheelThumbTexture(colorwheelthumbtexture)
	
	if withalpha then
		-- create the alpha bar
		local colorvalue = colorselect:CreateTexture()
		colorvalue:SetWidth(alphawidth or 32)
		colorvalue:SetHeight(dimension or 128)
		colorvalue:SetPoint("LEFT", colorwheel, "RIGHT", 10, -3)
		colorselect:SetColorValueTexture(colorvalue)
	
		-- create the alpha arrows
		local colorvaluethumbtexture = colorselect:CreateTexture()
		colorvaluethumbtexture:SetTexture("Interface\\Buttons\\UI-ColorPicker-Buttons")
		colorvaluethumbtexture:SetWidth( (alphawidth/32  or 1) * 48)
		colorvaluethumbtexture:SetHeight( (alphawidth/32 or 1) * 14)
		colorvaluethumbtexture:SetTexCoord(0.25, 1, 0.875, 0)
		colorselect:SetColorValueThumbTexture(colorvaluethumbtexture)
	end
	
	self:SetLastObj(colorselect)
	return colorselect
end


-- This function creates a button
--
--  arg1 = text on the button "OK", "Cancel",...
--  arg2 = widht
--  arg3 = height
--  arg4 = function to call when clicked
--
function PanelPrototype:CreateButton(title, width, height, onclick, FontObject)
	local button = CreateFrame('Button', FrameTitle..self:GetNewID(), self.frame, 'DBM_GUI_OptionsFramePanelButtonTemplate')
	button:SetWidth(width or 100)
	button:SetHeight(height or 20)
	button:SetText(title)
	if onclick then
		button:SetScript("OnClick", onclick)
	end
	if FontObject then
		button:SetNormalFontObject(FontObject);
		button:SetHighlightFontObject(FontObject);		
	end

	self:SetLastObj(button)
	return button
end

-- This function creates a text block for descriptions
--
--  arg1 = text to write
--  arg2 = width to set
function PanelPrototype:CreateText(text, width, autoplaced)
	local textblock = self.frame:CreateFontString(FrameTitle..self:GetNewID(), "ARTWORK", "GameFontNormal")
	textblock:SetText(text)
	if width then
		textblock:SetWidth( width or 100 )
	else
		textblock:SetWidth( self.frame:GetWidth() )
	end

	if autoplaced then
		textblock:SetPoint('TOPLEFT',self.frame, "TOPLEFT", 10, -10);
	end

	self:SetLastObj(textblock)
	return textblock
end


function PanelPrototype:CreateCreatureModelFrame(width, height, creatureid)
	local ModelFrame = CreateFrame('PlayerModel', FrameTitle..self:GetNewID(), self.frame)
	ModelFrame:SetWidth(width or 100)
	ModelFrame:SetHeight(height or 200)
	ModelFrame:SetCreature(tonumber(creatureid) or 448)	-- Hogger!!! he kills all of you
	
	self:SetLastObj(ModelFrame)
	return ModelFrame	
end

function PanelPrototype:AutoSetDimension()
	if not self.frame.mytype == "area" then return end
	local height = self.frame:GetHeight()

	local need_height = 25
	
	local kids = { self.frame:GetChildren() }
	for _, child in pairs(kids) do
		if child.myheight and type(child.myheight) == "number" then
			need_height = need_height + child.myheight
		else
			need_height = need_height + child:GetHeight() + 50
		end
	end

	self.frame.myheight = need_height + 25
	self.frame:SetHeight(need_height)
end

function PanelPrototype:SetMyOwnHeight()
	if not self.frame.mytype == "panel" then return end

	local need_height = 50

	local kids = { self.frame:GetChildren() }
	for _, child in pairs(kids) do
		if child.mytype == "area" and child.myheight then
			need_height = need_height + child.myheight
		elseif child.mytype == "area" then
			need_height = need_height + child:GetHeight() + 30
		end
	end
	self.frame:SetHeight(need_height)
end


local ListFrameButtonsPrototype = {}
-- Prototyp for ListFrame Options Buttons

function ListFrameButtonsPrototype:CreateCategory(frame, parent)
	if not type(frame) == "table" or not frame.name then
		DBM:AddMsg("Failed to create category - frame is not a table or doesn't have a name")
		return false
	elseif self:IsPresent(frame.name) then
		DBM:AddMsg("Frame ("..frame.name..") already exists")
		return false
	end

	frame.showsub = (frame.showsub == nil)
	if parent then
		frame.depth = self:GetDepth(parent)
	else 
		frame.depth = 1
	end

	self:SetParentHasChilds(parent)

	table.insert(self.Buttons, {
		frame = frame,
		parent = parent
	})
end

function ListFrameButtonsPrototype:IsPresent(framename)
	for k,v in ipairs(self.Buttons) do
		if v.frame.name == framename then
			return true
		end
	end
	return false
end

function ListFrameButtonsPrototype:GetDepth(framename, depth)
	depth = depth or 1
	for k,v in ipairs(self.Buttons) do
		if v.frame.name == framename then
			if v.parent == nil then		
				return depth+1
			else				
				depth = depth + self:GetDepth(v.parent, depth)
			end
		end
	end
	return depth
end

function ListFrameButtonsPrototype:SetParentHasChilds(parent)
	if not parent then return end
	for k,v in ipairs(self.Buttons) do
		if v.frame.name == parent then		
			v.frame.haschilds = true
		end
	end
end


do
	local mytable = {}
	function ListFrameButtonsPrototype:GetVisibleTabs()
		for i = #mytable, 1, -1 do mytable[i] = nil end
		for k,v in ipairs(self.Buttons) do
			if v.parent == nil then 
				table.insert(mytable, v)
	
				if v.frame.showsub then
					self:GetVisibleSubTabs(v.frame.name, mytable)
				end
			end
		end
		return mytable
	end
end

function ListFrameButtonsPrototype:GetVisibleSubTabs(parent, t)
	for i, v in ipairs(self.Buttons) do
		if v.parent == parent then
			table.insert(t, v)
			if v.frame.showsub then
				self:GetVisibleSubTabs(v.frame.name, t)
			end
		end
	end
end
	
do
	local mt = {__index = ListFrameButtonsPrototype}
	function CreateNewFauxScrollFrameList()
		return setmetatable({ Buttons={} }, mt)
	end
end

DBM_GUI_Bosses = CreateNewFauxScrollFrameList()
DBM_GUI_Options = CreateNewFauxScrollFrameList()


local function GetSharedMedia3()
	if LibStub and LibStub("LibSharedMedia-3.0", true) then
		return LibStub("LibSharedMedia-3.0", true)
	end
	return false
end


local UpdateAnimationFrame
do
	local function HideScrollBar (frame)
		local list = getglobal(frame:GetName() .. "List");
		list:Hide();
		local listWidth = list:GetWidth();
		for _, button in next, frame.buttons do
			button:SetWidth(button:GetWidth() + listWidth);
		end
	end

	local function DisplayScrollBar (frame)
		local list = getglobal(frame:GetName() .. "List");
		list:Show();
	
		local listWidth = list:GetWidth();
	
		for _, button in next, frame.buttons do
			button:SetWidth(button:GetWidth() - listWidth);
		end
	end

	-- the functions in this block are only used to 
	-- create/update/manage the Fauxscrollframe for Boss/Options Selection
	local displayedElements = {}

	-- This function is for internal use.
	-- Function to update the left scrollframe buttons with the menu entries
	function DBM_GUI_OptionsFrame:UpdateMenuFrame(listframe)
		local offset = getglobal(listframe:GetName().."List").offset;
		local buttons = listframe.buttons;
		local TABLE 

		if not buttons then return false; end

		if listframe:GetParent().tab == 2 then
			TABLE = DBM_GUI_Options:GetVisibleTabs()
		else 
			TABLE = DBM_GUI_Bosses:GetVisibleTabs()
		end
		local element;
		
		for i, element in ipairs(displayedElements) do
			displayedElements[i] = nil;
		end

		for i, element in ipairs(TABLE) do
			--DBM:AddMsg("TABLE: "..element.frame.name)
			table.insert(displayedElements, element.frame);
		end


		local numAddOnCategories = #displayedElements;
		local numButtons = #buttons;

		if ( numAddOnCategories > numButtons and ( not listframe:IsShown() ) ) then
			DisplayScrollBar(listframe);
		elseif ( numAddOnCategories <= numButtons and ( listframe:IsShown() ) ) then
			HideScrollBar(listframe);
		end
		
		FauxScrollFrame_Update(getglobal(listframe:GetName().."List"), numAddOnCategories, numButtons, buttons[1]:GetHeight());	


		local selection = DBM_GUI_OptionsFrameBossMods.selection;
		if ( selection ) then
			DBM_GUI_OptionsFrame:ClearSelection(listframe, listframe.buttons);
		end

		for i = 1, #buttons do
			element = displayedElements[i + offset]
			if ( not element ) then
				DBM_GUI_OptionsFrame:HideButton(buttons[i]);
			else
				DBM_GUI_OptionsFrame:DisplayButton(buttons[i], element);
				
				if ( selection ) and ( selection == element ) and ( not listframe.selection ) then
					DBM_GUI_OptionsFrame:SelectButton(listframe, buttons[i]);
				end
			end
		end
	end

	-- This function is for internal use.
	-- Used to show a button from the list
	function DBM_GUI_OptionsFrame:DisplayButton(button, element)
		button:Show();
		button.element = element;
		
		button.text:SetPoint("LEFT", 12 + 8 * element.depth, 2);
		button.toggle:ClearAllPoints()
		button.toggle:SetPoint("LEFT", 8 * element.depth - 2, 1);

		if element.depth > 2 then
			button:SetNormalFontObject(GameFontHighlightSmall);
			button:SetHighlightFontObject(GameFontHighlightSmall);

		elseif element.depth > 1  then
			button:SetNormalFontObject(GameFontNormalSmall);
			button:SetHighlightFontObject(GameFontNormalSmall);
		else
			button:SetNormalFontObject(GameFontNormal);
			button:SetHighlightFontObject(GameFontNormal);
		end
		button:SetWidth(165)

		if element.haschilds then
			if not element.showsub then
				button.toggle:SetNormalTexture("Interface\\Buttons\\UI-PlusButton-UP");
				button.toggle:SetPushedTexture("Interface\\Buttons\\UI-PlusButton-DOWN");
			else
				button.toggle:SetNormalTexture("Interface\\Buttons\\UI-MinusButton-UP");
				button.toggle:SetPushedTexture("Interface\\Buttons\\UI-MinusButton-DOWN");		
			end
			button.toggle:Show();
		else
			button.toggle:Hide();
		end

		button.text:SetText(element.name);
	end

	-- This function is for internal use.
	-- Used to hide a button from the list
	function DBM_GUI_OptionsFrame:HideButton(button)
		button:SetWidth(165)
		button:Hide()
	end

	-- This function is for internal use.
	-- Called when a new entry is selected
	function DBM_GUI_OptionsFrame:ClearSelection(listFrame, buttons)
		for _, button in ipairs(buttons) do button:UnlockHighlight(); end
		listFrame.selection = nil;
	end
	
	-- This function is for Internal use.
	-- Called when a button is selected
	function DBM_GUI_OptionsFrame:SelectButton(listFrame, button)
		button:LockHighlight()
		listFrame.selection = button.element;
	end

	-- This function is for Internal use.
	-- Required to create a list of buttons in the scrollframe
	function DBM_GUI_OptionsFrame:CreateButtons(frame)
		local name = frame:GetName()
	
		frame.scrollBar = getglobal(name.."ListScrollBar")
		frame:SetBackdropBorderColor(0.6, 0.6, 0.6, 1)
		getglobal(name.."Bottom"):SetVertexColor(0.66, 0.66, 0.66)
	
		local buttons = {}
		local button = CreateFrame("BUTTON", name.."Button1", frame, "DBM_GUI_FrameButtonTemplate")
		button:SetPoint("TOPLEFT", frame, 0, -8)
		frame.buttonHeight = button:GetHeight()
		table.insert(buttons, button)
	
		local maxButtons = (frame:GetHeight() - 8) / frame.buttonHeight
		for i = 2, maxButtons do
			button = CreateFrame("BUTTON", name.."Button"..i, frame, "DBM_GUI_FrameButtonTemplate")
			button:SetPoint("TOPLEFT", buttons[#buttons], "BOTTOMLEFT")
			table.insert(buttons, button)
		end
		frame.buttons = buttons
	end

	-- This function is for internal use.
	-- Called when someone clicks a Button
	function DBM_GUI_OptionsFrame:OnButtonClick(button)
		local parent = button:GetParent();
		local buttons = parent.buttons;
	
		self:ClearSelection(getglobal(self:GetName().."BossMods"),   getglobal(self:GetName().."BossMods").buttons);
		self:ClearSelection(getglobal(self:GetName().."DBMOptions"), getglobal(self:GetName().."DBMOptions").buttons);
		self:SelectButton(parent, button);

		self:DisplayFrame(button.element);
	end

	function DBM_GUI_OptionsFrame:ToggleSubCategories(button)
		local parent = button:GetParent();
		if parent.element.showsub then
			parent.element.showsub = false
		else
			parent.element.showsub = true
		end
		self:UpdateMenuFrame(parent:GetParent())
	end

	-- This function is for internal use.
	-- places the selected tab on the container frame
	function DBM_GUI_OptionsFrame:DisplayFrame(frame)
		local container = getglobal(self:GetName().."PanelContainer")
		if ( container.displayedFrame ) then
			container.displayedFrame:Hide();
		end
		
		container.displayedFrame = frame;
		
		getglobal(container:GetName().."FOV"):SetScrollChild(frame)

		local mymax = frame:GetHeight() - container:GetHeight()
		if mymax <= 0 then mymax = 0 end

		getglobal(container:GetName().."FOVScrollBar"):SetMinMaxValues(0, mymax)
	
		if usemodelframe then
			for _, mod in ipairs(DBM.Mods) do
				if mod.panel.frame == frame then
					UpdateAnimationFrame(mod)
				end
			end
		end

		frame:Show();
	end

end

function UpdateAnimationFrame(mod)
	DBM_BossPreview:SetCreature(mod.modelId or mod.creatureId or 0)
	DBM_BossPreview:SetModelScale(mod.modelScale or 0.15)

	DBM_BossPreview.atime = 0 
	DBM_BossPreview.apos = 0
	DBM_BossPreview.rotation = 0
	DBM_BossPreview.modelRotation = mod.modelRotation or 0
	DBM_BossPreview.modelOffsetX = mod.modelOffsetX or 0
	DBM_BossPreview.modelOffsetY = mod.modelOffsetY or 0
	DBM_BossPreview.modelOffsetZ = mod.modelOffsetZ or 0
	DBM_BossPreview.modelscale = mod.modelScale or 0.15
	DBM_BossPreview.modelMoveSpeed = mod.modelMoveSpeed or 1
	DBM_BossPreview.pos_x = 0
	DBM_BossPreview.pos_y = 0
	DBM_BossPreview.pos_z = 0
	DBM_BossPreview.alpha = 1
	DBM_BossPreview.scale = 0
	DBM_BossPreview.apos = 0
	--DBM_BossPreview:SetPosition(DBM_BossPreview.pos_y, DBM_BossPreview.pos_x, DBM_BossPreview.pos_z)
	--DBM_BossPreview:SetPosition(DBM_BossPreview.pos_z, DBM_BossPreview.pos_x, DBM_BossPreview.pos_y)
	DBM_BossPreview:SetAlpha(DBM_BossPreview.alpha)
	DBM_BossPreview.enabled = true
end

local function CreateAnimationFrame()
	local mobstyle = CreateFrame('PlayerModel', "DBM_BossPreview", DBM_GUI_OptionsFramePanelContainer)
	mobstyle:SetPoint("BOTTOMRIGHT", DBM_GUI_OptionsFramePanelContainer, "BOTTOMRIGHT", -5, 5)
	mobstyle:SetWidth( DBM_GUI_OptionsFramePanelContainer:GetWidth()-10 )
	mobstyle:SetHeight( DBM_GUI_OptionsFramePanelContainer:GetHeight()-10 )

	mobstyle.atime = 0 
	mobstyle.apos = 0
	mobstyle.rotation = 0
	mobstyle.modelOffsetX = 0
	mobstyle.modelOffsetY = 0
	mobstyle.modelOffsetZ = 0
	mobstyle.modelscale = 0.25
	mobstyle.pos_x = 0
	mobstyle.pos_y = 0
	mobstyle.pos_z = 0
	mobstyle.alpha = 1
	mobstyle.scale = mobstyle.modelscale
	mobstyle.modelMoveSpeed = 1
	mobstyle.enabled = false
	
	mobstyle.playlist = { 	-- start animation outside of our fov    
				{set_y = 0.30, set_x = 3, set_z = 0, setfacing = -90, setalpha = 1},
				-- wait outside fov befor begining
				{mintime = 1000, maxtime = 7000},	-- randomtime to wait
				-- {time = 10000},  			-- just wait 10 seconds

				-- move in the fov and to waypoint #1
				{animation = 4, time = 1500, move_x = -0.7},
				--{animation = 0, time = 10, endfacing = -90 }, -- rotate in an animation

				-- stay on waypoint #1 
				{setfacing = 0},
				{animation = 0, time = 10000},
				--{animation = 0, time = 2000, randomanimation = {45,46,47}},	-- play a random emote

				-- move to next waypoint
				{setfacing = -90},
				{animation = 4, time = 3000, move_x = -1.5},

				-- stay on waypoint #2
				{setfacing = 0},
				{animation = 0, time = 10000,},
				 
				-- move to the horizont
				{setfacing = 180},
				{animation = 4, time = 10000, move_z = 1, move_x = 0.375, toscale=0.05},

				-- die and despawn
				{animation = 1, time = 2000},
				{animation = 6, time = 2000, toalpha = 0},

				-- we want so sleep a little while on animation end
				{mintime = 1000, maxtime = 3000},
	} 
	
	mobstyle:SetScript("OnUpdate", function(self, e)
		if not self.enabled then return end
		self.atime = self.atime + e * 1000  
		if self.apos == 0 or self.atime >= (self.playlist[self.apos].time or 0) then
			self.apos = self.apos + 1
			if self.apos <= #self.playlist and self.playlist[self.apos].setfacing then
				self:SetFacing( (self.playlist[self.apos].setfacing + self.modelRotation) * math.pi/180)
			end
			if self.apos <= #self.playlist and self.playlist[self.apos].setalpha then
				self:SetAlpha(self.playlist[self.apos].setalpha)
			end
			if self.apos <= #self.playlist and self.playlist[self.apos].set_y then
				self.pos_y = self.playlist[self.apos].set_y
				--self:SetPosition(self.pos_y, self.pos_x, self.pos_z)
				self:SetPosition(self.pos_z+self.modelOffsetZ, self.pos_x+self.modelOffsetX, self.pos_y+self.modelOffsetY)
			end
			if self.apos <= #self.playlist and self.playlist[self.apos].set_x then
				self.pos_x = self.playlist[self.apos].set_x
				--self:SetPosition(self.pos_y, self.pos_x, self.pos_z)
				self:SetPosition(self.pos_z+self.modelOffsetZ, self.pos_x+self.modelOffsetX, self.pos_y+self.modelOffsetY)
			end
			if self.apos <= #self.playlist and self.playlist[self.apos].set_z then
				self.pos_z = self.playlist[self.apos].set_z
				--self:SetPosition(self.pos_y, self.pos_x, self.pos_z)
				self:SetPosition(self.pos_z+self.modelOffsetZ, self.pos_x+self.modelOffsetX, self.pos_y+self.modelOffsetY)
			end
			if self.apos > #self.playlist then
				self.apos = 0 
				self.pos_x = self.modelOffsetX
				self.pos_y = self.modelOffsetY
				self.pos_z = self.modelOffsetZ
				self.alpha = 1
				self.scale = self.modelscale
				self:SetFacing(self.modelRotation)
				--self:SetPosition(self.pos_y, self.pos_x, self.pos_z)
				self:SetPosition(self.pos_z+self.modelOffsetZ, self.pos_x+self.modelOffsetX, self.pos_y+self.modelOffsetY)
				self:SetAlpha(0)
				self:SetModelScale(self.modelscale)
				return 
			end
			self.rotation = self:GetFacing()
			if self.playlist[self.apos].randomanimation then
				self.playlist[self.apos].animation = self.playlist[self.apos].randomanimation[math.random(1, #self.playlist[self.apos].randomanimation)]
			end
			if self.playlist[self.apos].mintime and self.playlist[self.apos].maxtime then
				self.playlist[self.apos].time = math.random(self.playlist[self.apos].mintime, self.playlist[self.apos].maxtime)
			end


			self.atime = 0
			self.playlist[self.apos].animation = self.playlist[self.apos].animation or 0
			self:SetSequence(self.playlist[self.apos].animation)
		end

		if self.playlist[self.apos].animation > 0 then
			self:SetSequenceTime(self.playlist[self.apos].animation,  self.atime) 
		end
	
		if self.playlist[self.apos].endfacing then -- not self.playlist[self.apos].endfacing == self:GetFacing() 
			self.rotation = self.rotation + (e * 2 * math.pi * -- Rotations per second
						((self.playlist[self.apos].endfacing/360)
						/ (self.playlist[self.apos].time/1000))
						)

			self:SetRotation( self.rotation )							
		end
		if self.playlist[self.apos].move_x then
			--self.pos_x = self.pos_x + (self.playlist[self.apos].move_x / (self.playlist[self.apos].time/1000) ) * e
			self.pos_x = self.pos_x + (((self.playlist[self.apos].move_x / (self.playlist[self.apos].time/1000) ) * e) * self.modelMoveSpeed)
			--self:SetPosition(self.pos_y, self.pos_x, self.pos_z)
			self:SetPosition(self.pos_z+self.modelOffsetZ, self.pos_x+self.modelOffsetX, self.pos_y+self.modelOffsetY)
		end
		if self.playlist[self.apos].move_y then
			self.pos_y = self.pos_y + (self.playlist[self.apos].move_y / (self.playlist[self.apos].time/1000) ) * e
			--self:SetPosition(self.pos_y, self.pos_x, self.pos_z)
			self:SetPosition(self.pos_z+self.modelOffsetZ, self.pos_x+self.modelOffsetX, self.pos_y+self.modelOffsetY)
		end
		if self.playlist[self.apos].move_z then
			self.pos_z = self.pos_z + (self.playlist[self.apos].move_z / (self.playlist[self.apos].time/1000) ) * e
			--self:SetPosition(self.pos_y, self.pos_x, self.pos_z)
			self:SetPosition(self.pos_z+self.modelOffsetZ, self.pos_x+self.modelOffsetX, self.pos_y+self.modelOffsetY)
		end
		if self.playlist[self.apos].toalpha then
			self.alpha = self.alpha - ((1 - self.playlist[self.apos].toalpha) / (self.playlist[self.apos].time/1000) ) * e
			self:SetAlpha(self.alpha)
		end
		if self.playlist[self.apos].toscale then
			self.scale = self.scale - ((self.modelscale - self.playlist[self.apos].toscale) / (self.playlist[self.apos].time/1000) ) * e
			if self.scale < 0 then self.scale = 0.01 end
			self:SetModelScale(self.scale)
		end
	end)
	return mobstyle
end

function DBM_GUI:CreateOptionsMenu()
	-- *****************************************************************
	-- 
	--  begin creating the Option Frames, this is mainly hardcoded
	--  because this allows me to place all the options as I want.
	--
	--  This API can be used to add your own tabs to our menu
	--
	--  To create a new tab please use the following function:
	--
	--    yourframe = DBM_GUI_Frame:CreateNewPanel("title", "option")
	--  
	--  You can use the DBM widgets by calling methods like
	--
	--    yourframe:CreateCheckButton("my first checkbox", true)
	--
	--  If you Set the second argument to true, the checkboxes will be
	--  placed automatically.
	--
	-- *****************************************************************


	DBM_GUI_Frame = DBM_GUI:CreateNewPanel(L.TabCategory_Options, "option")
	if usemodelframe then CreateAnimationFrame() end
	do
		----------------------------------------------
		--             General Options              --
		----------------------------------------------
		local generaloptions = DBM_GUI_Frame:CreateArea(L.General, nil, 140, true)
	
		local enabledbm = generaloptions:CreateCheckButton(L.EnableDBM, true)
		enabledbm:SetScript("OnShow",  function() enabledbm:SetChecked(DBM:IsEnabled()) end)
		enabledbm:SetScript("OnClick", function() if DBM:IsEnabled() then DBM:Disable(); else DBM:Enable(); end end)
	
		local StatusEnabled = generaloptions:CreateCheckButton(L.EnableStatus, true, nil, "StatusEnabled")
		local AutoRespond   = generaloptions:CreateCheckButton(L.AutoRespond,  true, nil, "AutoRespond")
	

		-- Pizza Timer (create your own timer menu)
		local pizzaarea = DBM_GUI_Frame:CreateArea(L.PizzaTimer_Headline, nil, 85)
		pizzaarea.frame:SetPoint('TOPLEFT', generaloptions.frame, "BOTTOMLEFT", 0, -20)
	
		local textbox = pizzaarea:CreateEditBox(L.PizzaTimer_Title, "Pizza is done", 175)
		local hourbox = pizzaarea:CreateEditBox(L.PizzaTimer_Hours, "0", 25)
		local minbox  = pizzaarea:CreateEditBox(L.PizzaTimer_Mins, "15", 25)
		local secbox  = pizzaarea:CreateEditBox(L.PizzaTimer_Secs, "0", 25)
	
		textbox:SetPoint('TOPLEFT', 30, -25)
		hourbox:SetPoint('TOPLEFT', textbox, "TOPRIGHT", 20, 0)
		minbox:SetPoint('TOPLEFT', hourbox, "TOPRIGHT", 20, 0)
		secbox:SetPoint('TOPLEFT', minbox, "TOPRIGHT", 20, 0)

		local BcastTimer = pizzaarea:CreateCheckButton(L.PizzaTimer_BroadCast)
		local okbttn  = pizzaarea:CreateButton(L.PizzaTimer_ButtonStart);
		okbttn:SetPoint('TOPLEFT', textbox, "BOTTOMLEFT", -7, -8)
		BcastTimer:SetPoint("TOPLEFT", okbttn, "TOPRIGHT", 10, 3)

		okbttn:SetScript("OnClick", function() 
			local time =  (hourbox:GetNumber() * 60*60) + (minbox:GetNumber() * 60) + secbox:GetNumber()
			if textbox:GetText() and time > 0 then
				DBM.Bars:CreateBar(time, textbox:GetText())
			end
		end)

		-- END Pizza Timer
		--
		DBM_GUI_Frame:SetMyOwnHeight()
	end
	do
		-----------------------------------------------
		--            Raid Warning Colors            --
		-----------------------------------------------
		local RaidWarningPanel = DBM_GUI_Frame:CreateNewPanel(L.Tab_RaidWarning, "option")
		local raidwarnoptions = RaidWarningPanel:CreateArea(L.Tab_RaidWarning, nil, 175, true)

		local ShowWarningsInChat 	= raidwarnoptions:CreateCheckButton(L.ShowWarningsInChat, true, nil, "ShowWarningsInChat")
		local ShowFakedRaidWarnings 	= raidwarnoptions:CreateCheckButton(L.ShowFakedRaidWarnings,  true, nil, "ShowFakedRaidWarnings")
		local WarningIconLeft		= raidwarnoptions:CreateCheckButton(L.WarningIconLeft,  true, nil, "WarningIconLeft")
		local WarningIconRight 		= raidwarnoptions:CreateCheckButton(L.WarningIconRight,  true, nil, "WarningIconRight")
		raidwarnoptions:AutoSetDimension()

		local raidwarncolors = RaidWarningPanel:CreateArea(L.RaidWarnColors, nil, 175, true)
	
		local color1 = raidwarncolors:CreateColorSelect(64)
		local color2 = raidwarncolors:CreateColorSelect(64)
		local color3 = raidwarncolors:CreateColorSelect(64)
		local color4 = raidwarncolors:CreateColorSelect(64)
		local color1text = raidwarncolors:CreateText(L.RaidWarnColor_1, 64)
		local color2text = raidwarncolors:CreateText(L.RaidWarnColor_2, 64)
		local color3text = raidwarncolors:CreateText(L.RaidWarnColor_3, 64)
		local color4text = raidwarncolors:CreateText(L.RaidWarnColor_4, 64)
		local color1reset = raidwarncolors:CreateButton(L.Reset, 60, 10, nil, GameFontNormalSmall)
		local color2reset = raidwarncolors:CreateButton(L.Reset, 60, 10, nil, GameFontNormalSmall)
		local color3reset = raidwarncolors:CreateButton(L.Reset, 60, 10, nil, GameFontNormalSmall)
		local color4reset = raidwarncolors:CreateButton(L.Reset, 60, 10, nil, GameFontNormalSmall)
	
		color1:SetPoint('TOPLEFT', 30, -20)
		color2:SetPoint('TOPLEFT', color1, "TOPRIGHT", 30, 0)
		color3:SetPoint('TOPLEFT', color2, "TOPRIGHT", 30, 0)
		color4:SetPoint('TOPLEFT', color3, "TOPRIGHT", 30, 0)
	
		local function UpdateColor(self)
			local r, g, b = self:GetColorRGB()
			self.textid:SetTextColor(r, g, b)
			DBM.Options.WarningColors[self.myid].r = r
			DBM.Options.WarningColors[self.myid].g = g
			DBM.Options.WarningColors[self.myid].b = b 
		end
		local function ResetColor(id, frame)
			return function(self)
				DBM.Options.WarningColors[id].r = DBM.DefaultOptions.WarningColors[id].r
				DBM.Options.WarningColors[id].g = DBM.DefaultOptions.WarningColors[id].g
				DBM.Options.WarningColors[id].b = DBM.DefaultOptions.WarningColors[id].b
				frame:SetColorRGB(DBM.Options.WarningColors[id].r, DBM.Options.WarningColors[id].g, DBM.Options.WarningColors[id].b)
			end
		end
		local function UpdateColorFrames(color, text, rset, id)
			color.textid = text
			color.myid = id
			color:SetScript("OnColorSelect", UpdateColor)
			color:SetColorRGB(DBM.Options.WarningColors[id].r, DBM.Options.WarningColors[id].g, DBM.Options.WarningColors[id].b)
			text:SetPoint('TOPLEFT', color, "BOTTOMLEFT", 3, -10) 
			text:SetJustifyH("CENTER")
			rset:SetPoint("TOP", text, "BOTTOM", 0, -5)
			rset:SetScript("OnClick", ResetColor(id, color))
		end
		UpdateColorFrames(color1, color1text, color1reset, 1)
		UpdateColorFrames(color2, color2text, color2reset, 2)
		UpdateColorFrames(color3, color3text, color3reset, 3)
		UpdateColorFrames(color4, color4text, color4reset, 4)
		
		local infotext = raidwarncolors:CreateText(L.InfoRaidWarning, 380, false)
		infotext:SetPoint('BOTTOMLEFT', raidwarncolors.frame, "BOTTOMLEFT", 10, 10)
		infotext:SetJustifyH("LEFT")
		infotext:SetFontObject(GameFontNormalSmall);
	
		local movemebutton = raidwarncolors:CreateButton(L.MoveMe, 100, 16)
		movemebutton:SetPoint('BOTTOMRIGHT', raidwarncolors.frame, "TOPRIGHT", 0, -1)
		movemebutton:SetNormalFontObject(GameFontNormalSmall);
		movemebutton:SetHighlightFontObject(GameFontNormalSmall);		

	
	end

	do
		BarSetupPanel = DBM_GUI_Frame:CreateNewPanel(L.BarSetup, "option")
		
		BarSetup = BarSetupPanel:CreateArea(L.AreaTitle_BarSetup, nil, 180, true)

		local movemebutton = BarSetup:CreateButton(L.MoveMe, 100, 16)
		movemebutton:SetPoint('BOTTOMRIGHT', BarSetup.frame, "TOPRIGHT", 0, -1)
		movemebutton:SetNormalFontObject(GameFontNormalSmall);
		movemebutton:SetHighlightFontObject(GameFontNormalSmall);		
		movemebutton:SetScript("OnClick", function() DBM.Bars:ShowMovableBar() end)

		local maindummybar = DBM.Bars:CreateDummyBar()
		maindummybar.frame:SetParent(BarSetup.frame)
		maindummybar.frame:SetPoint('BOTTOM', BarSetup.frame, "TOP", 0, -65)
		maindummybar.frame:SetScript("OnUpdate", function(self, elapsed) maindummybar:Update(elapsed) end)
		do 
			-- little hook to prevent this bar from size/scale change
			local old = maindummybar.ApplyStyle 
			function maindummybar:ApplyStyle(...) 
				old(self, ...) 
				self.frame:SetWidth(183)
				self.frame:SetScale(0.9)
				getglobal(self.frame:GetName().."Bar"):SetWidth(183)
			end 
		end

		local iconleft = BarSetup:CreateCheckButton(L.BarIconLeft, nil, nil, nil, "IconLeft")
		local iconright = BarSetup:CreateCheckButton(L.BarIconRight, nil, true, nil, "IconRight")
		iconleft:SetPoint('BOTTOMRIGHT', maindummybar.frame, "TOPLEFT", -5, 5)
		iconright:SetPoint('BOTTOMLEFT', maindummybar.frame, "TOPRIGHT", 5, 5)

		local color1 = BarSetup:CreateColorSelect(64)
		local color2 = BarSetup:CreateColorSelect(64)
		color1:SetPoint('TOPLEFT', BarSetup.frame, "TOPLEFT", 20, -80)
		color2:SetPoint('TOPLEFT', color1, "TOPRIGHT", 20, 0)

		local color1reset = BarSetup:CreateButton(L.Reset, 64, 10, nil, GameFontNormalSmall)
		local color2reset = BarSetup:CreateButton(L.Reset, 64, 10, nil, GameFontNormalSmall)
		color1reset:SetPoint('TOP', color1, "BOTTOM", 5, -10)
		color2reset:SetPoint('TOP', color2, "BOTTOM", 5, -10)
		color1reset:SetScript("OnClick", function(self) 
			color1:SetColorRGB(DBM.Bars:GetDefaultOption("StartColorR"), DBM.Bars:GetDefaultOption("StartColorG"), DBM.Bars:GetDefaultOption("StartColorB"))
		end)
		color2reset:SetScript("OnClick", function(self) 
			color2:SetColorRGB(DBM.Bars:GetDefaultOption("EndColorR"), DBM.Bars:GetDefaultOption("EndColorG"), DBM.Bars:GetDefaultOption("EndColorB"))
		end)


		color1:SetScript("OnShow", function(self) self:SetColorRGB(
								DBM.Bars:GetOption("StartColorR"),
								DBM.Bars:GetOption("StartColorG"),
								DBM.Bars:GetOption("StartColorB")) 
							  end)
		color2:SetScript("OnShow", function(self) self:SetColorRGB(
								DBM.Bars:GetOption("EndColorR"),
								DBM.Bars:GetOption("EndColorG"),
								DBM.Bars:GetOption("EndColorB")) 
							  end)
		color1:SetScript("OnColorSelect", function(self)
							DBM.Bars:SetOption("StartColorR", select(1, self:GetColorRGB()))
							DBM.Bars:SetOption("StartColorG", select(2, self:GetColorRGB()))
							DBM.Bars:SetOption("StartColorB", select(3, self:GetColorRGB()))							
						  end)
		color2:SetScript("OnColorSelect", function(self)
							DBM.Bars:SetOption("EndColorR", select(1, self:GetColorRGB()))
							DBM.Bars:SetOption("EndColorG", select(2, self:GetColorRGB()))
							DBM.Bars:SetOption("EndColorB", select(3, self:GetColorRGB()))							
						  end)


		local Textures = { 
			{	text	= "Default",	value 	= "Interface\\AddOns\\DBM-Core\\textures\\default.tga", 	texture	= "Interface\\AddOns\\DBM-Core\\textures\\default.tga"	},
			{	text	= "Blizzad",	value 	= "Interface\\PaperDollInfoFrame\\UI-Character-Skills-Bar", 	texture	= "Interface\\PaperDollInfoFrame\\UI-Character-Skills-Ba"	},
			{	text	= "Glaze",	value 	= "Interface\\AddOns\\DBM-Core\\textures\\glaze.tga", 		texture	= "Interface\\AddOns\\DBM-Core\\textures\\glaze.tga"	},
			{	text	= "Otravi",	value 	= "Interface\\AddOns\\DBM-Core\\textures\\otravi.tga", 		texture	= "Interface\\AddOns\\DBM-Core\\textures\\otravi.tga"	},
			{	text	= "Smooth",	value 	= "Interface\\AddOns\\DBM-Core\\textures\\smooth.tga", 		texture	= "Interface\\AddOns\\DBM-Core\\textures\\smooth.tga"	}
		}
		if GetSharedMedia3() then
			for k,v in next, GetSharedMedia3():HashTable("statusbar") do
				table.insert(Textures, {text=k, value=v, texture=v})
			end
		end
		local TextureDropDown = BarSetup:CreateDropdown(L.BarTexture, Textures, 
			DBM.Bars:GetOption("Texture"), function(value) 
				DBM.Bars:SetOption("Texture", value) 
			end
		);
		TextureDropDown:SetPoint("TOPLEFT", BarSetup.frame, "TOPLEFT", 210, -80)


		-- Functions for the next 2 Areas
		local function createDBTOnShowHandler(option)
			return function(self)
				self:SetValue(DBM.Bars:GetOption(option))
			end
		end
		local function createDBTOnValueChangedHandler(option)
			return function(self)
				DBM.Bars:SetOption(option, self:GetValue())
			end
		end

		-----------------------
		-- Small Bar Options --
		-----------------------
		BarSetupSmall = BarSetupPanel:CreateArea(L.AreaTitle_BarSetupSmall, nil, 160, true)

		local smalldummybar = DBM.Bars:CreateDummyBar()
		smalldummybar.frame:SetParent(BarSetupSmall.frame)
		smalldummybar.frame:SetPoint('BOTTOM', BarSetupSmall.frame, "TOP", 0, -35)
		smalldummybar.frame:SetScript("OnUpdate", function(self, elapsed) smalldummybar:Update(elapsed) end)

		local BarWidthSlider = BarSetup:CreateSlider(L.Slider_BarWidth, 100, 325, 1)
		BarWidthSlider:SetPoint("TOPLEFT", BarSetupSmall.frame, "TOPLEFT", 20, -90)
		BarWidthSlider:SetScript("OnShow", createDBTOnShowHandler("Width"))
		BarWidthSlider:SetScript("OnValueChanged", createDBTOnValueChangedHandler("Width"))

		local BarScaleSlider = BarSetup:CreateSlider(L.Slider_BarScale, 0.75, 2, 0.05)
		BarScaleSlider:SetPoint("TOPLEFT", BarWidthSlider, "BOTTOMLEFT", 0, -10)
		BarScaleSlider:SetScript("OnShow", createDBTOnShowHandler("Scale"))
		BarScaleSlider:SetScript("OnValueChanged", createDBTOnValueChangedHandler("Scale"))

		local BarOffsetXSlider = BarSetup:CreateSlider(L.BarOffSetX, -50, 50, 1)
		BarOffsetXSlider:SetPoint("TOPLEFT", BarSetupSmall.frame, "TOPLEFT", 220, -90)
		BarOffsetXSlider:SetScript("OnShow", createDBTOnShowHandler("BarXOffset"))
		BarOffsetXSlider:SetScript("OnValueChanged", createDBTOnValueChangedHandler("BarXOffset"))

		local BarOffsetYSlider = BarSetup:CreateSlider(L.BarOffSetY, -5, 25, 1)
		BarOffsetYSlider:SetPoint("TOPLEFT", BarOffsetXSlider, "BOTTOMLEFT", 0, -10)
		BarOffsetYSlider:SetScript("OnShow", createDBTOnShowHandler("BarYOffset"))
		BarOffsetYSlider:SetScript("OnValueChanged", createDBTOnValueChangedHandler("BarYOffset"))
		
		-----------------------
		-- Huge Bar Options --
		-----------------------
		BarSetupHuge = BarSetupPanel:CreateArea(L.AreaTitle_BarSetupHuge, nil, 160, true)
		
		local hugedummybar = DBM.Bars:CreateDummyBar()
		hugedummybar.frame:SetParent(BarSetupSmall.frame)
		hugedummybar.frame:SetPoint('BOTTOM', BarSetupHuge.frame, "TOP", 0, -35)
		hugedummybar.frame:SetScript("OnUpdate", function(self, elapsed) hugedummybar:Update(elapsed) end)
		hugedummybar.enlarged = true                                
		hugedummybar:ApplyStyle()     

		local HugeBarWidthSlider = BarSetup:CreateSlider(L.Slider_BarWidth, 100, 325, 1)
		HugeBarWidthSlider:SetPoint("TOPLEFT", BarSetupHuge.frame, "TOPLEFT", 20, -90)
		HugeBarWidthSlider:SetScript("OnShow", createDBTOnShowHandler("HugeWidth"))
		HugeBarWidthSlider:SetScript("OnValueChanged", createDBTOnValueChangedHandler("HugeWidth"))

		local HugeBarScaleSlider = BarSetup:CreateSlider(L.Slider_BarScale, 0.75, 2, 0.05)
		HugeBarScaleSlider:SetPoint("TOPLEFT", HugeBarWidthSlider, "BOTTOMLEFT", 0, -10)
		HugeBarScaleSlider:SetScript("OnShow", createDBTOnShowHandler("HugeScale"))
		HugeBarScaleSlider:SetScript("OnValueChanged", createDBTOnValueChangedHandler("HugeScale"))

		local HugeBarOffsetXSlider = BarSetup:CreateSlider(L.BarOffSetX, -50, 50, 1)
		HugeBarOffsetXSlider:SetPoint("TOPLEFT", BarSetupHuge.frame, "TOPLEFT", 220, -90)
		HugeBarOffsetXSlider:SetScript("OnShow", createDBTOnShowHandler("HugeBarXOffset"))
		HugeBarOffsetXSlider:SetScript("OnValueChanged", createDBTOnValueChangedHandler("HugeBarXOffset"))

		local HugeBarOffsetYSlider = BarSetup:CreateSlider(L.BarOffSetY, -5, 25, 1)
		HugeBarOffsetYSlider:SetPoint("TOPLEFT", HugeBarOffsetXSlider, "BOTTOMLEFT", 0, -10)
		HugeBarOffsetYSlider:SetScript("OnShow", createDBTOnShowHandler("HugeBarYOffset"))
		HugeBarOffsetYSlider:SetScript("OnValueChanged", createDBTOnValueChangedHandler("HugeBarYOffset"))


		BarSetupPanel:SetMyOwnHeight() 
	end

end	

	
do

	local function LoadAddOn_Button(self) 
		if DBM:LoadMod(self.modid) then 
			self:Hide()
			DBM_GUI_OptionsFrameBossMods:Hide()
			DBM_GUI_OptionsFrameBossMods:Show()

			local ptext = self.modid.panel:CreateText(L.BossModLoaded)
			ptext:SetPoint('TOPLEFT', self.modid.panel.frame, "TOPLEFT", 10, -10)
		end
	end

	local Categories = {}
	function DBM_GUI:UpdateModList()
		for k,addon in ipairs(DBM.AddOns) do
			if not Categories[addon.category] then
				Categories[addon.category] = DBM_GUI:CreateNewPanel(L["TabCategory_"..string.upper(addon.category)] or L.TabCategory_Other)
	
				if L["TabCategory_"..string.upper(addon.category)] then
					local ptext = Categories[addon.category]:CreateText(L["TabCategory_"..string.upper(addon.category)])
					ptext:SetPoint('TOPLEFT', Categories[addon.category].frame, "TOPLEFT", 10, -10)
				end
			end
			
			if not addon.panel then
				addon.panel = Categories[addon.category]:CreateNewPanel(addon.name or "Error: X-DBM-Mod-Name", nil, false)

				if not IsAddOnLoaded(addon.modId) then
					local button = addon.panel:CreateButton(L.Button_LoadMod, 200, 30)
					button.modid = addon
					button:SetScript("OnClick", LoadAddOn_Button)
					button:SetPoint('CENTER', 0, -20)
				else
					local ptext = addon.panel:CreateText(L.BossModLoaded)
					ptext:SetPoint('TOPLEFT', addon.panel.frame, "TOPLEFT", 10, -10)
				end
			end

			if addon.panel and addon.subTabs and IsAddOnLoaded(addon.modId) then
				if not addon.subPanels then addon.subPanels = {} end

				for k,v in pairs(addon.subTabs) do
					if not addon.subPanels[k] then
						addon.subPanels[k] = addon.panel:CreateNewPanel(v or "Error: X-DBM-Mod-Name", nil, false)
					end
				end
			end


			for _, mod in ipairs(DBM.Mods) do
				if mod.modId == addon.modId then
					if not mod.panel and (not addon.subTabs or addon.subPanels[mod.subTab]) then
						if addon.subTabs and addon.subPanels[mod.subTab] then
							mod.panel = addon.subPanels[mod.subTab]:CreateNewPanel(mod.localization.general.name or "Error: DBM.Mods")
						else
							mod.panel = addon.panel:CreateNewPanel(mod.localization.general.name or "Error: DBM.Mods")
						end
						DBM_GUI:CreateBossModTab(mod)
					end
				end
			end	
		end
	end


	function DBM_GUI:CreateBossModTab(mod)
		if not mod.panel then
			DBM:AddMsg("Couldn't create boss mod panel for "..mod.localization.general.name)
			return false
		end
		--DBM:AddMsg("Creating Panel for Mod: "..mod.localization.general.name)
		local panel = mod.panel
		local category
		
		local button = panel:CreateCheckButton("Enabled", true)
		button:SetScript("OnShow",  function(self) 
						self:SetChecked(mod.Options.Enabled) 
						end)

		button:SetScript("OnClick", function(self) 
						mod:Toggle()
						end)
		
		for _, catident in pairs(mod.categorySort) do
			category = mod.optionCategories[catident]

			local catpanel = panel:CreateArea(mod.localization.cats[catident], nil, nil, true)
			for _,v in ipairs(category) do

				if type(mod.Options[v]) == "boolean" then

					local button = catpanel:CreateCheckButton(mod.localization.options[v], true)

					button:SetScript("OnShow",  function(self) 
									self:SetChecked(mod.Options[v]) 
								    end)

					button:SetScript("OnClick", function(self) 
									if mod.Options[v] then 
										mod.Options[v] = false 
									else 
										mod.Options[v] = true
									end 
									self:SetChecked(mod.Options[v]) 
								    end)
				end
			end
			catpanel:AutoSetDimension()
			panel:SetMyOwnHeight()
		end
	end

end

