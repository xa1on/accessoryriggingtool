local m = {}
local Rigs = script.Parent.Parent.models.Rigs

function m.Insert(rig, cf)
    local newRig = Rigs[rig]:Clone()
    newRig:SetPrimaryPartCFrame(cf)
    newRig.Parent = workspace
    return newRig
    --[[
    local r6 = Instance.new("Model")
    r6.Name = "R6"
    r6.Parent = workspace

    local humanoidRootPart = Instance.new("Part")
    humanoidRootPart.Name = "HumanoidRootPart"
    humanoidRootPart.Anchored = true
    humanoidRootPart.BottomSurface = Enum.SurfaceType.Smooth
    humanoidRootPart.CFrame = cf
    humanoidRootPart.CanCollide = false
    humanoidRootPart.Size = Vector3.new(2, 2, 1)
    humanoidRootPart.TopSurface = Enum.SurfaceType.Smooth
    humanoidRootPart.Transparency = 1
    r6.PrimaryPart = humanoidRootPart
    humanoidRootPart.Parent = r6

    local head = Instance.new("Part")
    head.Name = "Head"
    head.CFrame = cf
    head.Size = Vector3.new(2, 1, 1)
    head.TopSurface = Enum.SurfaceType.Smooth
    head.Parent = r6

    local mesh = Instance.new("SpecialMesh")
    mesh.Name = "Mesh"
    mesh.MeshType = Enum.MeshType.Head
    mesh.Scale = Vector3.new(1.25, 1.25, 1.25)
    mesh.Parent = head

    local hairAttachment = Instance.new("Attachment")
    hairAttachment.Name = "HairAttachment"
    hairAttachment.CFrame = CFrame.new(0, 0.6, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1)
    hairAttachment.Parent = head

    local hatAttachment = Instance.new("Attachment")
    hatAttachment.Name = "HatAttachment"
    hatAttachment.CFrame = CFrame.new(0, 0.6, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1)
    hatAttachment.Parent = head

    local faceFrontAttachment = Instance.new("Attachment")
    faceFrontAttachment.Name = "FaceFrontAttachment"
    faceFrontAttachment.CFrame = CFrame.new(0, 0, -0.6, 1, 0, 0, 0, 1, 0, 0, 0, 1)
    faceFrontAttachment.Parent = head

    local faceCenterAttachment = Instance.new("Attachment")
    faceCenterAttachment.Name = "FaceCenterAttachment"
    faceCenterAttachment.Parent = head

    local face = Instance.new("Decal")
    face.Name = "face"
    face.Texture = "rbxasset://textures/face.png"
    face.Parent = head

    

    local torso = Instance.new("Part")
    torso.Name = "Torso"
    torso.BrickColor = BrickColor.DarkGray()
    torso.CFrame = cf
    torso.Color = Color3.fromRGB(99, 95, 98)
    torso.LeftSurface = Enum.SurfaceType.Weld
    torso.RightSurface = Enum.SurfaceType.Weld
    torso.Size = Vector3.new(2, 2, 1)
    torso.Parent = r6

    local neckAttachment = Instance.new("Attachment")
    neckAttachment.Name = "NeckAttachment"
    neckAttachment.CFrame = CFrame.new(0, 1, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1)
    neckAttachment.Parent = torso

    local bodyFrontAttachment = Instance.new("Attachment")
    bodyFrontAttachment.Name = "BodyFrontAttachment"
    bodyFrontAttachment.CFrame = CFrame.new(0, 0, -0.5, 1, 0, 0, 0, 1, 0, 0, 0, 1)
    bodyFrontAttachment.Parent = torso

    local bodyBackAttachment = Instance.new("Attachment")
    bodyBackAttachment.Name = "BodyBackAttachment"
    bodyBackAttachment.CFrame = CFrame.new(0, 0, 0.5, 1, 0, 0, 0, 1, 0, 0, 0, 1)
    bodyBackAttachment.Parent = torso

    local leftCollarAttachment = Instance.new("Attachment")
    leftCollarAttachment.Name = "LeftCollarAttachment"
    leftCollarAttachment.CFrame = CFrame.new(-1, 1, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1)
    leftCollarAttachment.Parent = torso

    local rightCollarAttachment = Instance.new("Attachment")
    rightCollarAttachment.Name = "RightCollarAttachment"
    rightCollarAttachment.CFrame = CFrame.new(1, 1, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1)
    rightCollarAttachment.Parent = torso

    local waistFrontAttachment = Instance.new("Attachment")
    waistFrontAttachment.Name = "WaistFrontAttachment"
    waistFrontAttachment.CFrame = CFrame.new(0, -1, -0.5, 1, 0, 0, 0, 1, 0, 0, 0, 1)
    waistFrontAttachment.Parent = torso

    local waistCenterAttachment = Instance.new("Attachment")
    waistCenterAttachment.Name = "WaistCenterAttachment"
    waistCenterAttachment.CFrame = CFrame.new(0, -1, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1)
    waistCenterAttachment.Parent = torso

    local waistBackAttachment = Instance.new("Attachment")
    waistBackAttachment.Name = "WaistBackAttachment"
    waistBackAttachment.CFrame = CFrame.new(0, -1, 0.5, 1, 0, 0, 0, 1, 0, 0, 0, 1)
    waistBackAttachment.Parent = torso

    local left_Arm = Instance.new("Part")
    left_Arm.Name = "Left Arm"
    left_Arm.CanCollide = false
    left_Arm.Size = Vector3.new(1, 2, 1)
    left_Arm.Parent = r6

    local leftShoulderAttachment = Instance.new("Attachment")
    leftShoulderAttachment.Name = "LeftShoulderAttachment"
    leftShoulderAttachment.CFrame = CFrame.new(0, 1, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1)
    leftShoulderAttachment.Parent = left_Arm

    local leftGripAttachment = Instance.new("Attachment")
    leftGripAttachment.Name = "LeftGripAttachment"
    leftGripAttachment.CFrame = CFrame.new(0, -1, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1)
    leftGripAttachment.Parent = left_Arm

    local right_Arm = Instance.new("Part")
    right_Arm.Name = "Right Arm"
    right_Arm.BottomSurface = Enum.SurfaceType.Smooth
    right_Arm.CanCollide = false
    right_Arm.Size = Vector3.new(1, 2, 1)
    right_Arm.Parent = r6

    local rightShoulderAttachment = Instance.new("Attachment")
    rightShoulderAttachment.Name = "RightShoulderAttachment"
    rightShoulderAttachment.CFrame = CFrame.new(0, 1, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1)
    rightShoulderAttachment.Parent = right_Arm

    local rightGripAttachment = Instance.new("Attachment")
    rightGripAttachment.Name = "RightGripAttachment"
    rightGripAttachment.CFrame = CFrame.new(0, -1, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1)
    rightGripAttachment.Parent = right_Arm

    local left_Leg = Instance.new("Part")
    left_Leg.Name = "Left Leg"
    left_Leg.BottomSurface = Enum.SurfaceType.Smooth
    left_Leg.CanCollide = false
    left_Leg.Size = Vector3.new(1, 2, 1)
    left_Leg.Parent = r6

    local leftFootAttachment = Instance.new("Attachment")
    leftFootAttachment.Name = "LeftFootAttachment"
    leftFootAttachment.CFrame = CFrame.new(0, -1, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1)
    leftFootAttachment.Parent = left_Leg

    local right_Leg = Instance.new("Part")
    right_Leg.Name = "Right Leg"
    right_Leg.BottomSurface = Enum.SurfaceType.Smooth
    right_Leg.CanCollide = false
    right_Leg.Size = Vector3.new(1, 2, 1)
    right_Leg.Parent = r6

    local rightFootAttachment = Instance.new("Attachment")
    rightFootAttachment.Name = "RightFootAttachment"
    rightFootAttachment.CFrame = CFrame.new(0, -1, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1)
    rightFootAttachment.Parent = right_Leg

    local humanoid = Instance.new("Humanoid")
    humanoid.Name = "Humanoid"
    humanoid.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
    humanoid.HealthDisplayDistance = 0
    humanoid.HealthDisplayType = Enum.HumanoidHealthDisplayType.AlwaysOff
    humanoid.NameDisplayDistance = 0
    humanoid.Parent = r6

    local humanoidDescription = Instance.new("HumanoidDescription")
    humanoidDescription.Name = "HumanoidDescription"
    humanoidDescription.BodyTypeScale = 0
    humanoidDescription.HeadColor = Color3.fromRGB(163, 162, 165)
    humanoidDescription.LeftArmColor = Color3.fromRGB(163, 162, 165)
    humanoidDescription.LeftLegColor = Color3.fromRGB(163, 162, 165)
    humanoidDescription.ProportionScale = 0
    humanoidDescription.RightArmColor = Color3.fromRGB(163, 162, 165)
    humanoidDescription.RightLegColor = Color3.fromRGB(163, 162, 165)
    humanoidDescription.TorsoColor = Color3.fromRGB(99, 95, 98)
    humanoidDescription.Parent = humanoid

    local rootAttachment = Instance.new("Attachment")
    rootAttachment.Name = "RootAttachment"
    rootAttachment.Parent = humanoidRootPart

    local rootJoint = Instance.new("Motor6D")
    rootJoint.Name = "RootJoint"
    rootJoint.MaxVelocity = 0.1
    rootJoint.Part0 = humanoidRootPart
    rootJoint.Part1 = torso
    rootJoint.C0 = CFrame.new(0, 0, 0, -1, 0, 0, 0, 0, 1, 0, 1, -0)
    rootJoint.C1 = CFrame.new(0, 0, 0, -1, 0, 0, 0, 0, 1, 0, 1, -0)
    rootJoint.Parent = humanoidRootPart

    local right_Shoulder = Instance.new("Motor6D")
    right_Shoulder.Name = "Right Shoulder"
    right_Shoulder.MaxVelocity = 0.1
    right_Shoulder.Part0 = torso
    right_Shoulder.Part1 = right_Arm
    right_Shoulder.C0 = CFrame.new(1, 0.5, 0, 0, 0, 1, 0, 1, -0, -1, 0, 0)
    right_Shoulder.C1 = CFrame.new(-0.5, 0.5, 0, 0, 0, 1, 0, 1, -0, -1, 0, 0)
    right_Shoulder.Parent = torso

    local left_Shoulder = Instance.new("Motor6D")
    left_Shoulder.Name = "Left Shoulder"
    left_Shoulder.MaxVelocity = 0.1
    left_Shoulder.Part0 = torso
    left_Shoulder.Part1 = left_Arm
    left_Shoulder.C0 = CFrame.new(-1, 0.5, 0, 0, 0, -1, 0, 1, 0, 1, 0, 0)
    left_Shoulder.C1 = CFrame.new(0.5, 0.5, 0, 0, 0, -1, 0, 1, 0, 1, 0, 0)
    left_Shoulder.Parent = torso

    local right_Hip = Instance.new("Motor6D")
    right_Hip.Name = "Right Hip"
    right_Hip.MaxVelocity = 0.1
    right_Hip.Part0 = torso
    right_Hip.Part1 = right_Leg
    right_Hip.C0 = CFrame.new(1, -1, 0, 0, 0, 1, 0, 1, -0, -1, 0, 0)
    right_Hip.C1 = CFrame.new(0.5, 1, 0, 0, 0, 1, 0, 1, -0, -1, 0, 0)
    right_Hip.Parent = torso

    local left_Hip = Instance.new("Motor6D")
    left_Hip.Name = "Left Hip"
    left_Hip.MaxVelocity = 0.1
    left_Hip.Part0 = torso
    left_Hip.Part1 = left_Leg
    left_Hip.C0 = CFrame.new(-1, -1, 0, 0, 0, -1, 0, 1, 0, 1, 0, 0)
    left_Hip.C1 = CFrame.new(-0.5, 1, 0, 0, 0, -1, 0, 1, 0, 1, 0, 0)
    left_Hip.Parent = torso

    local neck = Instance.new("Motor6D")
    neck.Name = "Neck"
    neck.MaxVelocity = 0.1
    neck.Part0 = torso
    neck.Part1 = head
    neck.C0 = CFrame.new(0, 1, 0, -1, 0, 0, 0, 0, 1, 0, 1, -0)
    neck.C1 = CFrame.new(0, -0.5, 0, -1, 0, 0, 0, 0, 1, 0, 1, -0)
    neck.Parent = torso

    local snap = Instance.new("Snap")
    snap.Name = "Snap"
    --snap.Part0 = left_Leg
    --snap.Part1 = humanoidRootPart
    snap.C0 = CFrame.new(0, 1, 0, -1, 0, 0, 0, 0, 1, 0, 1, -0)
    snap.C1 = CFrame.new(-0.5, -1, 0, -1, 0, 0, 0, 0, 1, 0, 1, -0)
    snap.Parent = left_Leg

    local snap1 = Instance.new("Snap")
    snap1.Name = "Snap"
    --snap1.Part0 = right_Leg
    --snap1.Part1 = humanoidRootPart
    snap1.C0 = CFrame.new(0, 1, 0, -1, 0, 0, 0, 0, 1, 0, 1, -0)
    snap1.C1 = CFrame.new(0.5, -1, 0, -1, 0, 0, 0, 0, 1, 0, 1, -0)
    snap1.Parent = right_Leg

    return r6]]--
end

return m