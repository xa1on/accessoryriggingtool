--[[
    [accessorytool]
    something#7597
    
]]--

-- dependencies
local gui = require(script.Parent.rblxgui.initialize)(plugin,"accessorytool")
local SelectionService = game:GetService("Selection")
local HistoryService = game:GetService("ChangeHistoryService")

-- toolbar
toolbar = plugin:CreateToolbar("accessorytool - something786")

-- toggle widget
local b_ToggleWidget = toolbar:CreateButton("toggle","toggle plugin widget","")

local Widget = gui.PluginWidget.new({
    ID = "accessorytool",
    Enabled = false,
    DockState = Enum.InitialDockState.Float
})

b_ToggleWidget.Click:Connect(function() Widget.Content.Enabled = not Widget.Content.Enabled end)

gui.ViewButton.new();

local MainPage = gui.Page.new({
    Name = "MAIN",
    TitlebarMenu = Widget.TitlebarMenu,
    Open = true
})

local MainPageFrame = gui.ScrollingFrame.new(nil, MainPage.Content)
MainPageFrame:SetMain();

gui.Textbox.new({
    Text = "accessorytool",
    Font = Enum.Font.SourceSansBold,
    Alignment = Enum.TextXAlignment.Center
})

gui.Textbox.new({
    Text = "Select an model or a group of models to get started",
    Alignment = Enum.TextXAlignment.Center
})


local AutoalignButton = gui.Button.new({
    Text = "Auto-align Selection",
    Disabled = true
})

local function FindHandle(model, acceptmiddle)
    if model:IsA("BasePart") then return model
    elseif not model:IsA("Model") then return nil end
    local Handle = model.PrimaryPart
    for _, v in pairs(model:GetChildren()) do
        local lowerName = string.lower(v.Name)
        if v:IsA("BasePart") and (lowerName == "handle" or (acceptmiddle and lowerName == "middle")) then
            Handle = v
        end
    end
    return Handle
end

local function ResetPivot(model)
	local boundsCFrame = model:GetBoundingBox()
	if model.PrimaryPart then
		model.PrimaryPart.PivotOffset = model.PrimaryPart.CFrame:ToObjectSpace(boundsCFrame)
	else
		model.WorldPivot = boundsCFrame
	end
end

local function AlignModel(model)
    local Parent = model.Parent
    ResetPivot(model);
    model.PrimaryPart = FindHandle(model, true)
    local TempPart
    if not model.PrimaryPart then
        TempPart = Instance.new("Part", model)
        local cf, _  = model.GetBoundingBox()
        TempPart.CFrame = cf
        model.PrimaryPart = TempPart
    end
    model:SetPrimaryPartCFrame(Parent.CFrame);
    if TempPart then
        model.PrimaryPart = nil
        TempPart.Parent = nil
    end
    ResetPivot(model);
end

local function Autoalign(model)
    if model:IsA("Model") then
        AlignModel(model)
    elseif model:IsA("BasePart") then
        model.CFrame = model.Parent.CFrame;
    end
end

AutoalignButton:Clicked(function()
    for _, v in pairs(SelectionService:Get()) do
        Autoalign(v)
    end
    HistoryService:SetWaypoint("Auto-aligned part");
end)

local AttachmentInput = gui.InputField.new({
    Placeholder = "Attachment",
    ClearText = true,
})

local AttachmentLabel = gui.Labeled.new({Text = "Use Attachment", Object = AttachmentInput, DisableEditing = true, Disabled = true})

local CreateAccessoryButton = gui.Button.new({
    Text = "Create Accessory",
    Disabled = true
})

CreateAccessoryButton:Clicked(function()
    for _, v1 in pairs(SelectionService:Get()) do
        local ValidModel = false
        if v1.Parent and v1.Parent.Parent then
            for _, v2 in pairs(v1.Parent.Parent:GetChildren()) do
                if (v1:IsA("Model") or v1:IsA("BasePart")) and v1.Parent:IsA("Part") and v2:IsA("Humanoid") then
                    ValidModel = true
                    break
                end
            end
        end
        if ValidModel then
            local Handle = FindHandle(v1)
            if not Handle then
                Autoalign(v1)
                Handle = FindHandle(v1)
            end
        end
    end
end)

SelectionService.SelectionChanged:Connect(function()
    --local CheckSelection = not(#SelectionService:Get() > 0)
    local CompatibleAlignment = false
    local CompatibleAccessory = false
    CreateAccessoryButton.Textbox.Text = "Create Accessory - "
    AttachmentInput:SetValue()
    AttachmentInput:ClearItems()
    for _, v1 in pairs(SelectionService:Get()) do
        if v1:IsA("Model") or v1:IsA("BasePart") then
            CompatibleAlignment = true
        end
        if v1.Parent and v1.Parent.Parent then
            for _, v2 in pairs(v1.Parent.Parent:GetChildren()) do
                if (v1:IsA("Model") or v1:IsA("BasePart")) and v1.Parent:IsA("Part") and v2:IsA("Humanoid") then
                    CreateAccessoryButton.Textbox.Text ..= "(" .. v1.Name .. " → " .. v1.Parent.Name .. ") "
                    CompatibleAccessory = true
                    for _, v3 in pairs(v1.Parent:GetChildren()) do
                        if v3:IsA("Attachment") then
                            AttachmentInput:AddItem(v3)
                            if AttachmentInput.Value == "" then AttachmentInput:SetValue(v3) end
                        end
                    end
                end
            end
        end
    end
    AutoalignButton:SetDisabled(not CompatibleAlignment)
    CreateAccessoryButton:SetDisabled(not CompatibleAccessory)
    AttachmentLabel:SetDisabled(not CompatibleAccessory)
end)
