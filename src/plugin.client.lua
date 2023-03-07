--[[
    [accessorytool]
    something#7597
    
]]--

-- dependencies
local gui = require(script.Parent.rblxgui.initialize)(plugin,"accessorytool")
local SelectionService = game:GetService("Selection")
local HistoryService = game:GetService("ChangeHistoryService")
local RigInserter = require(script.Parent.modules.RigInserter)

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
MainPageFrame:SetMain()

gui.Textbox.new({
    Text = "accessorytool",
    Font = Enum.Font.SourceSansBold,
    Alignment = Enum.TextXAlignment.Center
})

gui.Textbox.new({
    Text = "Create a rig, or select model(s) to get started",
    Alignment = Enum.TextXAlignment.Center
})

gui.ListFrame.new({Height = 5})

local CreateR6Rig = gui.Button.new({
    Text = "Create R6 Rig"
})

CreateR6Rig:Clicked(function()
    local Camera = workspace.CurrentCamera
    local NewRig = RigInserter.Insert("R6", CFrame.new((Camera.CFrame + Camera.CFrame.LookVector * 10).Position));
    SelectionService:Set({NewRig})
    HistoryService:SetWaypoint("Inserted R6 Rig");
end)

local CreateR15Rig = gui.Button.new({
    Text = "Create R15 Rig"
})

CreateR15Rig:Clicked(function()
    local Camera = workspace.CurrentCamera
    local NewRig = RigInserter.Insert("R15", CFrame.new((Camera.CFrame + Camera.CFrame.LookVector * 10).Position));
    SelectionService:Set({NewRig})
    HistoryService:SetWaypoint("Inserted R15 Rig");
end)

gui.ListFrame.new({Height = 5})

local InputPlayerID = gui.InputField.new({
    Placeholder = "Player ID Here",
    NoDropdown = true
})

gui.Labeled.new({
    Text = "Insert Avatar by ID:",
    Objects = InputPlayerID
})

local InsertPlayerIDButton = gui.Button.new({
    Text = "Insert",
    ButtonSize = 0.5,
    Disabled = true
})

InputPlayerID:Changed(function(input)
    InsertPlayerIDButton:SetDisabled(input == "")
end)

gui.ListFrame.new({Height = 10})

InsertPlayerIDButton:Clicked(function()
    local Camera = workspace.CurrentCamera
    local NewRig = RigInserter.InsertByID(InputPlayerID.Value, CFrame.new((Camera.CFrame + Camera.CFrame.LookVector * 10).Position));
    SelectionService:Set({NewRig})
    HistoryService:SetWaypoint("Inserted Character Rig");
end)

gui.Section.new({
    Text = "Rigging",
    Open = true
}):SetMain()

gui.ListFrame.new({Height = 5})

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
    local NewMid
    if not model.PrimaryPart then
        NewMid = Instance.new("Part", model)
        NewMid.Name = "Middle"
        local cf, _  = model.GetBoundingBox()
        NewMid.CFrame = cf
        model.PrimaryPart = NewMid
    end
    model:SetPrimaryPartCFrame(Parent.CFrame);
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
    DisableEditing = true
})

local AttachmentLabel = gui.Labeled.new({Text = "Use Attachment", Object = AttachmentInput, Disabled = true})

local CreateAccessoryButton = gui.Button.new({
    Text = "Create Accessory",
    Disabled = true
})

local function CreateHandle(model)
    local Handle = model.Parent:Clone()
    Handle.Parent = model
    Handle.Transparency = 1
    Handle.Name = "Handle"
    Handle:ClearAllChildren()
    model.PrimaryPart = Handle
    return Handle
end

CreateAccessoryButton:Clicked(function()
    for _, model in pairs(SelectionService:Get()) do
        local ValidModel = false
        if model.Parent and model.Parent.Parent then
            for _, v2 in pairs(model.Parent.Parent:GetChildren()) do
                if (model:IsA("Model") or model:IsA("BasePart")) and model.Parent:IsA("Part") and v2:IsA("Humanoid") then
                    ValidModel = true
                    break
                end
            end
        end
        if ValidModel then
            local NewAccessory = Instance.new("Accessory", model.Parent.Parent)
            NewAccessory.Name = model.Name
            local Handle = FindHandle(model)
            if not Handle then
                Handle = CreateHandle(model)
            end
            --Handle.Parent = NewAccessory
            Handle:ClearAllChildren()
            Handle.Anchored = false
            Handle.Name = "Handle"
            for _, part in pairs(model:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.Anchored = false
                    --part.Parent = NewAccessory
                    if not (part == Handle) then
                        local NewWeld = Instance.new("Weld", Handle)
                        NewWeld.Name = part.Name
                        NewWeld.Part0 = Handle
                        NewWeld.C0 = Handle.CFrame:ToObjectSpace(part.CFrame)
                        NewWeld.Part1 = part
                    end
                end
            end
            if AttachmentInput.Value ~= "" then
                local BodyAttachment = AttachmentInput.Value[1]:Clone()
                BodyAttachment.Parent = Handle
            end
            if model:IsA("Model") then
                for _, v in pairs(model:GetChildren()) do
                    v.Parent = NewAccessory
                end
                model.Parent = nil
            else
                Handle.Parent = NewAccessory
            end
        end
    end
    HistoryService:SetWaypoint("Created Accessory");
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
