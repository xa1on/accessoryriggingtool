--[[
    [riggingtool]
    something#7597
    
]]--

-- dependencies
local gui = require(script.Parent.rblxgui.initialize)(plugin,"riggingtool")
local SelectionService = game:GetService("Selection")
local HistoryService = game:GetService("ChangeHistoryService")
local RigInserter = require(script.Parent.modules.RigInserter)

local SelectedRig = ""
local RigOptions = {}
local SelectedActions = {}
local ClonedWelds = {}
local Attachments = {}



-- Local Functions
local function AutoRigInsert(model)
    local Camera = workspace.CurrentCamera
    local NewRig = RigInserter.Insert(model, CFrame.new((Camera.CFrame + Camera.CFrame.LookVector * 10).Position));
    SelectionService:Set({NewRig})
    HistoryService:SetWaypoint("Inserted " .. model .. " Rig");
end

local function FindHandle(model, acceptmiddle)
    if model:IsA("BasePart") then return model
    elseif not model:IsA("Model") and not model:IsA("Accessory") then return nil end
    local Handle = nil
    if model:IsA("Model") then Handle = model.PrimaryPart end
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
    model.PrimaryPart = FindHandle(model, true)
    local NewMid
    ResetPivot(model);
    if not model.PrimaryPart then
        NewMid = Instance.new("Part")
        NewMid.Name = "Handle"
        NewMid.Transparency = 1
        NewMid.Size = Vector3.new(0.25,0.25,0.25)
        NewMid.CFrame = model:GetModelCFrame()
        NewMid.Parent = model
        model.PrimaryPart = NewMid
        print(NewMid.CFrame)
    end
    ResetPivot(model);
    model:SetPrimaryPartCFrame(Parent.CFrame);
end

local function Autoalign(model)
    if model:IsA("Model") then
        AlignModel(model)
    elseif model:IsA("BasePart") then
        model.CFrame = model.Parent.CFrame;
    end
end

local function CreateHandle(model)
    local Handle = model.Parent:Clone()
    Handle.Parent = model
    Handle.Transparency = 1
    Handle.Name = "Handle"
    Handle:ClearAllChildren()
    model.PrimaryPart = Handle
    return Handle
end

local function WeldModel(Model, Handle)
    Handle = Handle or FindHandle(Model)
    for _, part in pairs(Model:GetDescendants()) do
        if part:IsA("BasePart") then
            part.Anchored = false
            --part.Parent = NewAccessory
            if not (part == Handle) then
                local NewWeld = Instance.new("Motor6D", Handle)
                NewWeld.Name = part.Name
                NewWeld.Part0 = Handle
                NewWeld.C0 = Handle.CFrame:ToObjectSpace(part.CFrame)
                NewWeld.Part1 = part
            end
        end
        if part:IsA("Weld") then
            part.Parent = nil
        end
    end
end

-- toolbar
toolbar = plugin:CreateToolbar("riggingtool - something786")

-- toggle widget
local b_ToggleWidget = toolbar:CreateButton("toggle","toggle plugin widget","")

local Widget = gui.PluginWidget.new({
    ID = "riggingtool",
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
    Text = "riggingtool",
    Font = Enum.Font.SourceSansBold,
    Alignment = Enum.TextXAlignment.Center
})

gui.Textbox.new({
    Text = "Create a rig, or select model(s) to get started",
    Alignment = Enum.TextXAlignment.Center
})

gui.ListFrame.new({Height = 10})

gui.Section.new({
    Text = "Create Rig",
    Open = true
}):SetMain()

gui.Textbox.new({
    Text = "Insert a Rig:",
    Font = Enum.Font.SourceSansBold,
    Alignment = Enum.TextXAlignment.Center
})

local RigButtonFrame = gui.ListFrame.new()
local FirstRig = true

for _, rig in script.Parent.models.Rigs:GetChildren() do
    local NewButton = gui.ToggleableButton.new({
        Text = rig.Name,
        ButtonSize = 0.9
    }, RigButtonFrame.Content)
    if FirstRig then
        NewButton:SetValue(true)
        SelectedRig = rig.Name
        FirstRig = false
    end
    RigOptions[rig.Name] = NewButton
    NewButton:Clicked(function()
        SelectedRig = rig.Name
        NewButton:SetValue(true)
        for index, button in RigOptions do
            if index ~= rig.Name then
                button:SetValue(false)
            end
        end
    end)
end

gui.ListFrame.new({Height = 5})

local InputPlayerID = gui.InputField.new({
    Placeholder = "Template Rig",
    NoDropdown = true
})

gui.Labeled.new({
    Text = "Player ID:",
    Objects = InputPlayerID
})

local InsertRigButton = gui.Button.new({
    Text = "Insert Rig",
    ButtonSize = 0.5
})

gui.ListFrame.new({Height = 10})

InsertRigButton:Clicked(function()
    if InputPlayerID.Value == "" then
        AutoRigInsert(SelectedRig)
    else
        local Camera = workspace.CurrentCamera
        local NewRig = RigInserter.InsertByID(InputPlayerID.Value, CFrame.new((Camera.CFrame + Camera.CFrame.LookVector * 10).Position));
        SelectionService:Set({NewRig})
        HistoryService:SetWaypoint("Inserted Character Rig");
    end
end)

gui.Section.new({
    Text = "Rigging Models",
    Open = true
}, MainPageFrame.Content):SetMain()

gui.ListFrame.new({Height = 5})

gui.Textbox.new({
    Text = "Aligns middle of model with parent's CFrame",
    Alignment = Enum.TextXAlignment.Center
})

local AutoalignButton = gui.Button.new({
    Text = "Auto-align Selection",
    Disabled = true
})

gui.Textbox.new({
    Text = "Move accessory model into a body part\nSelect the model and choose an attachment.",
    Alignment = Enum.TextXAlignment.Center
}, gui.ListFrame.new({Height = 60}).Content)

local AttachmentList = gui.Section.new({
    Text = "Attachments",
    Open = true
})

gui.ListFrame.new({Height = 5})

local CreateAccessoryButton = gui.Button.new({
    Text = "Create Accessory",
    Disabled = true
})




local function SelectionChanged(Selection)
    --local CheckSelection = not(#Selection > 0)
    local CompatibleAlignment = false
    local CompatibleAccessory = false
    CreateAccessoryButton.Textbox.Text = "Create Accessory - "
    for _, v1 in pairs(AttachmentList.Content:GetChildren()) do
        if not v1:IsA("UIListLayout") then
            v1:Destroy()
        end
    end
    for _, v1 in pairs(Selection) do
        if v1:IsA("Model") or v1:IsA("BasePart") then
            CompatibleAlignment = true
        end
        if v1.Parent and v1.Parent.Parent then
            for _, v2 in pairs(v1.Parent.Parent:GetChildren()) do
                if (v1:IsA("Model") or v1:IsA("BasePart")) and v1.Parent:IsA("Part") and v2:IsA("Humanoid") then
                    CreateAccessoryButton.Textbox.Text ..= "(" .. v1.Name .. " → " .. v1.Parent.Name .. ") "
                    CompatibleAccessory = true
                    local AttachmentInput = gui.InputField.new({
                        Placeholder = "Attachment",
                        DisableEditing = true
                    })
                    local Container = gui.ListFrame.new(nil, AttachmentList.Content)
                    gui.Labeled.new({
                        Text = v1.Parent.Name .. " Attachment", 
                        Object = AttachmentInput,
                    }, Container.Content)
                    Attachments[v1.Name] = AttachmentInput
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
    --AttachmentLabel:SetDisabled(not CompatibleAccessory)
end

AutoalignButton:Clicked(function()
    for _, v in pairs(SelectionService:Get()) do
        Autoalign(v)
    end
    HistoryService:SetWaypoint("Auto-aligned part");
end)

CreateAccessoryButton:Clicked(function()
    local Selection = SelectionService:Get()
    for _, model in pairs(Selection) do
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
            WeldModel(model, Handle)
            local AttachmentInput = Attachments[model.Name]
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
            SelectionService:Add({NewAccessory})
        end
    end
    HistoryService:SetWaypoint("Created Accessory");
end)

SelectionService.SelectionChanged:Connect(function()
    for _, action in SelectedActions do
        action:Disconnect()
    end
    SelectedActions = {}
    ClonedWelds = {}
    for index, v1 in pairs(SelectionService:Get()) do
        SelectedActions[#SelectedActions+1] = v1.AncestryChanged:Connect(function()
            if Widget.Content.Enabled then SelectionChanged({v1}) end
        end)
        if v1:IsA("Accessory") then
            local Handle = FindHandle(v1)
            if Handle then
                for _, v2 in pairs(Handle:GetChildren()) do
                    if v2:IsA("Motor6D") or v2:IsA("Weld") then
                        local NewWeld = v2:Clone()
                        NewWeld.Parent = nil
                        if not ClonedWelds[index] then
                            ClonedWelds[index] = {}
                        end
                        ClonedWelds[index][#ClonedWelds[index]+1] = NewWeld
                    end
                end
                SelectedActions[#SelectedActions+1] = v1.AncestryChanged:Connect(function()
                    for _, v2 in pairs(ClonedWelds[index]) do
                        v2.Parent = Handle
                    end
                end)
            end
        end
    end
    if not Widget.Content.Enabled then return end
    SelectionChanged(SelectionService:Get())
end)
