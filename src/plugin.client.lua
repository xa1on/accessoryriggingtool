--[[
    [riggingtool]
    something#7597
    
]]--

-- dependencies
local gui = require(script.Parent.rblxgui.initialize)(plugin,"riggingtool")
local SelectionService = game:GetService("Selection")
local HistoryService = game:GetService("ChangeHistoryService")
local RigModule = require(script.Parent.modules.RigModule)

local SelectedRig = false
local SelectedRigs = {}
local ToggledRig = ""
local RigOptions = {}
local SelectedActions = {}
local ClonedWelds = {}
local Attachments = {}

local SelectionChanged



-- Local Functions
local function AutoRigInsert(model)
    local Camera = workspace.CurrentCamera
    local NewRig = RigModule.Insert(model, CFrame.new((Camera.CFrame + Camera.CFrame.LookVector * 10).Position));
    SelectionService:Set({NewRig})
    HistoryService:SetWaypoint("Inserted " .. model .. " Rig");
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
    model.PrimaryPart = RigModule.FindHandle(model, true)
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
    if model:IsA("Model") then
        model.PrimaryPart = Handle
    end
    return Handle
end

local function WeldModel(Model, Handle, Animatable)
    Handle = Handle or RigModule.FindHandle(Model)
    for _, part in pairs(Model:GetDescendants()) do
        if part:IsA("BasePart") then
            part.Anchored = false
            --part.Parent = NewAccessory
            if not (part == Handle) then
                local NewWeld = Instance.new(if Animatable then "Motor6D" else "Weld", Handle)
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
    Text = "Select a Rig Type:",
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
        ToggledRig = rig.Name
        FirstRig = false
    end
    RigOptions[rig.Name] = NewButton
    NewButton:Clicked(function()
        ToggledRig = rig.Name
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

local PlayerIDLabel = gui.Labeled.new({
    Text = "Player ID:",
    Objects = InputPlayerID
})

local InsertRigButton = gui.Button.new({
    Text = "Insert Rig"
})

gui.ListFrame.new({Height = 10})

InsertRigButton:Clicked(function()
    local DetectedRig
    local NewRig
    if not SelectedRig then
        if InputPlayerID.Value == "" then
            AutoRigInsert(ToggledRig)
        else
            local Camera = workspace.CurrentCamera
            local NewRig = RigModule.InsertByID(InputPlayerID.Value, CFrame.new((Camera.CFrame + Camera.CFrame.LookVector * 10).Position));
            SelectionService:Set({NewRig})
            HistoryService:SetWaypoint("Inserted Character Rig");
        end
    else
        for _, v in pairs(SelectedRigs) do
            DetectedRig = RigModule.DetectRigType(v)
            if RigModule.Convert[DetectedRig][ToggledRig] == nil then
                gui.TextPrompt.new({Title = "Incompatible Conversion", Text = "Unable to convert " .. DetectedRig .. " to " .. ToggledRig, Buttons = {"OK"}})
            else
                NewRig = RigModule.Convert[DetectedRig][ToggledRig](v)
                if NewRig ~= v then
                    SelectionService:Add({NewRig[1]})
                end
                if not NewRig[2] then
                    gui.TextPrompt.new({Title = "Missing Attachments", Text = "Some accessories were unable to be converted properly due to missing attachments\nand have been moved into seperate models.\n\nYou can convert them with the \"Create Accessory\" button.", Buttons = {"OK"}})
                end
            end
        end
        SelectionChanged(SelectionService:Get())
        HistoryService:SetWaypoint("Converted Character Rig");
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




SelectionChanged = function(Selection)
    --local CheckSelection = not(#Selection > 0)
    local CompatibleAlignment = false
    local CompatibleAccessory = false
    local CompatibleRig = false
    local HumanoidCheck
    local FoundAttachments = {}
    local FoundAttachment = false
    local MissingAttachment = false
    local RigsMissingAttachments = {}
    local RigAlreadyFound = false
    SelectedRigs = {}
    CreateAccessoryButton.Textbox.Text = "Create Accessory - "
    for _, v1 in pairs(AttachmentList.Content:GetChildren()) do
        if not v1:IsA("UIListLayout") then
            v1:Destroy()
        end
    end
    for index, v1 in pairs(Selection) do
        -- Alignment Compatibility Check
        if v1:IsA("Model") or v1:IsA("BasePart") then
            CompatibleAlignment = true
        end
        -- Accessory Compatibility Check
        if v1.Parent and v1.Parent.Parent then
            for _, v2 in pairs(v1.Parent.Parent:GetChildren()) do
                if (v1:IsA("Model") or v1:IsA("BasePart")) and v1.Parent:IsA("BasePart") and v2:IsA("Humanoid") then
                    MissingAttachment = false
                    FoundAttachments = {}
                    FoundAttachment = false
                    for _, v3 in pairs(script.Parent.models.Rigs[RigModule.DetectRigType(v1.Parent.Parent)][v1.Parent.Name]:GetChildren()) do
                        if v3:IsA("Attachment") then
                            FoundAttachments[#FoundAttachments+1] = v3.Name
                        end
                    end
                    CreateAccessoryButton.Textbox.Text ..= "(" .. v1.Name .. " → " .. v1.Parent.Name .. ") "
                    CompatibleAccessory = true
                    local AttachmentInput = gui.InputField.new({
                        Placeholder = "Attachment",
                        DisableEditing = true
                    })
                    local Container = gui.ListFrame.new(nil, AttachmentList.Content)
                    gui.Labeled.new({
                        Text = v1.Name .. " Attachment",
                        Object = AttachmentInput,
                    }, Container.Content)
                    Attachments[v1.Name] = AttachmentInput
                    for _, v3 in pairs(v1.Parent:GetChildren()) do
                        if v3:IsA("Attachment") then
                            for index, v4 in pairs(FoundAttachments) do
                                if v4 == v3.Name then
                                    table.remove(FoundAttachments, index)
                                    FoundAttachment = true
                                    break
                                end
                            end
                            if not FoundAttachment then MissingAttachment = true end
                            AttachmentInput:AddItem(v3)
                            if AttachmentInput.Value == "" then AttachmentInput:SetValue(v3) end
                        end
                    end
                    RigAlreadyFound = false
                    if #FoundAttachments > 0 or MissingAttachment then
                        for _, v3 in pairs(RigsMissingAttachments) do
                            if v3 == v1.Parent.Parent then
                                RigAlreadyFound = true
                            end
                        end
                        if not RigAlreadyFound then
                            RigsMissingAttachments[#RigsMissingAttachments+1] = v1.Parent.Parent
                        end
                    end
                end
            end
        end
        -- Rig Compatibility Check
        HumanoidCheck = RigModule.DetectRigType(v1)
        
        if HumanoidCheck ~= nil then
            if not CompatibleRig then
                SelectedRig = true
                InsertRigButton.Textbox.Text = "Convert Rig"
            end
            CompatibleRig = true
            InsertRigButton.Textbox.Text ..= " (\"" .. v1.Name .. "\": " .. HumanoidCheck .. ") "
            SelectedRigs[#SelectedRigs+1] = v1
        end

        -- AccessoryWeld Check
        if v1:IsA("Accessory") then
            local Handle = RigModule.FindHandle(v1)
            if Handle then
                for _, v2 in pairs(Handle:GetChildren()) do
                    if v2.Name == "AccessoryWeld" and v2:IsA("Weld") then
                        v2.Parent = nil
                        local p0, pcf0 = v2.Part0, v2.C0
                        local p1, pcf1 = v2.Part1, v2.C1
                        local New6D = Instance.new("Motor6D", Handle)
                        New6D.Name = "AccessoryWeld"
                        New6D.Part0 = p0
                        New6D.Part1 = p1
                        New6D.C0 = pcf0
                        New6D.C1 = pcf1
                    end
                end
            end
        end
    end
    if not CompatibleRig and SelectedRig then
        SelectedRig = false
        InsertRigButton.Textbox.Text = "Insert Rig"
    end
    local CurrentLimb
    local NewAttachment
    local PromptFixAttachment
    for _, rig in RigsMissingAttachments do
        PromptFixAttachment = gui.TextPrompt.new({
            Title = '"' .. rig.Name .. '"' .. " - Missing Attachments",
            Text = "\"" .. rig.Name .. "\" is missing some recommended attachments. Add missing attachments?",
            Buttons = {"OK", "Cancel"}
        })
        PromptFixAttachment:Clicked(function(p)
            if p == 1 then
                for _, part in pairs(script.Parent.models.Rigs[RigModule.DetectRigType(rig)]:GetChildren()) do
                    CurrentLimb = rig:FindFirstChild(part.Name)
                    for _, attachment in pairs(part:GetChildren()) do
                        if attachment:IsA("Attachment") then
                            if not CurrentLimb:FindFirstChild(attachment.Name) then
                                NewAttachment = attachment:Clone()
                                NewAttachment.Parent = CurrentLimb
                            end
                        end
                    end
                end
                SelectionChanged(SelectionService:Get())
            end
        end)
    end

    PlayerIDLabel:SetDisabled(CompatibleRig)
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
                if (model:IsA("Model") or model:IsA("BasePart")) and model.Parent:IsA("BasePart") and v2:IsA("Humanoid") then
                    ValidModel = true
                    break
                end
            end
        end
        if ValidModel then
            local NewAccessory = Instance.new("Accessory", model.Parent.Parent)
            if model:IsA("BasePart") then
                local NewModel = Instance.new("Model", model.Parent)
                model.Parent = NewModel
                NewModel.Name = model.Name
                model = NewModel
            end
            NewAccessory.Name = model.Name
            local Handle = RigModule.FindHandle(model)
            if not Handle then
                Handle = CreateHandle(model)
            end
            Handle.Parent = model
            Handle:ClearAllChildren()
            Handle.Anchored = false
            Handle.Name = "Handle"
            local AttachmentInput = Attachments[model.Name]
            if AttachmentInput.Value ~= "" then
                local BodyAttachment = AttachmentInput.Value[1]:Clone()
                BodyAttachment.Parent = Handle
                BodyAttachment.WorldCFrame = AttachmentInput.Value[1].WorldCFrame
            end
            if model:IsA("Model") then
                for _, v in pairs(model:GetChildren()) do
                    if v ~=  Handle then
                        v.Parent = NewAccessory
                    end
                end
                model.Parent = nil
            end
            WeldModel(NewAccessory, Handle, true)
            Handle.Parent = NewAccessory
            SelectionService:Add({NewAccessory})
        end
    end
    HistoryService:SetWaypoint("Created Accessory");
end)

SelectionService.SelectionChanged:Connect(function()
    local NewWeld
    for _, action in SelectedActions do
        action:Disconnect()
    end
    SelectedActions = {}
    ClonedWelds = {}
    for index, v1 in pairs(SelectionService:Get()) do
        SelectedActions[#SelectedActions+1] = v1.AncestryChanged:Connect(function()
            if Widget.Content.Enabled then SelectionChanged(SelectionService:Get()) end
        end)
        if v1:IsA("Accessory") then
            local Handle = RigModule.FindHandle(v1)
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
                    if v1.Parent:IsA("Humanoid") then
                        for _, v2 in pairs(ClonedWelds[index]) do
                            NewWeld = v2:Clone()
                            NewWeld.Parent = Handle
                        end
                    end
                end)
            end
        end
    end
    if not Widget.Content.Enabled then return end
    SelectionChanged(SelectionService:Get())
end)
