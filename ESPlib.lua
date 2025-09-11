-- ESPlib.lua  (Corner boxes + Health bar + Name + Dot ESP)
-- Drawing overlay + BillboardGui attachments
local ESP = {
    Enabled      = true,
    Boxes        = true,
    Names        = true,
    HealthBars   = true,
    Dot          = false,

    Thickness    = 2,
    FaceCamera   = false,

    -- box geometry
    BoxShift     = CFrame.new(0,-1.5,0),
    BoxSize      = Vector3.new(4,6,0),
    CornerFrac   = 0.22, -- 22% of edge length for L corners

    -- colors
    BoxColorA    = Color3.fromRGB(0,170,255),
    BoxColorB    = Color3.fromRGB(0,210,255),
    NameColor    = Color3.fromRGB(255,255,255),

    -- internal
    Objects      = setmetatable({}, {__mode="kv"}),
    Overrides    = {}
}

local cam = workspace.CurrentCamera
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RS = game:GetService("RunService")

-- ---------- Drawing helpers ----------
local function Draw(obj, props)
    local d = Drawing.new(obj)
    if props then for k,v in pairs(props) do d[k] = v end end
    return d
end

local function v2(x,y) return Vector2.new(x,y) end

-- ---------- Billboard helpers ----------
local function safePGui()
    local pg = LocalPlayer:FindFirstChild("PlayerGui")
    if not pg then pg = LocalPlayer:WaitForChild("PlayerGui",5) end
    return pg
end

local function mkBillboard(adornee, studsOffset, sizeXY)
    local bb = Instance.new("BillboardGui")
    bb.AlwaysOnTop = true
    bb.Adornee = adornee
    bb.StudsOffset = studsOffset or Vector3.new(0,3.2,0)
    bb.Size = UDim2.fromOffset(sizeXY.X, sizeXY.Y)
    bb.Name = "ESPLib_BB"
    bb.Parent = safePGui()
    return bb
end

local function mkHealthBar(bb)
    -- Name (top)
    local name = Instance.new("TextLabel")
    name.BackgroundTransparency = 1
    name.Size = UDim2.new(1,0,0,16)
    name.Position = UDim2.fromOffset(0,0)
    name.Font = Enum.Font.GothamBold
    name.TextScaled = false
    name.TextSize = 14
    name.TextColor3 = Color3.new(1,1,1)
    name.TextStrokeTransparency = 0.5
    name.Name = "Name"
    name.Parent = bb

    -- Bar background
    local back = Instance.new("Frame")
    back.BackgroundColor3 = Color3.fromRGB(20,20,20)
    back.BorderSizePixel = 0
    back.Size = UDim2.new(1,0,0,6)
    back.Position = UDim2.fromOffset(0,18)
    back.Name = "BarBack"
    back.Parent = bb

    -- Bar fill
    local fill = Instance.new("Frame")
    fill.BackgroundColor3 = Color3.fromRGB(255,0,0)
    fill.BorderSizePixel = 0
    fill.Size = UDim2.new(1,0,1,0)
    fill.Position = UDim2.fromOffset(0,0)
    fill.Name = "BarFill"
    fill.Parent = back

    local grad = Instance.new("UIGradient")
    grad.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.fromRGB(255,0,0)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(255,255,255))
    }
    grad.Rotation = 0
    grad.Parent = fill

    return name, back, fill
end

local function mkDotBillboard(adornee)
    local bb = mkBillboard(adornee, Vector3.new(0,0,0), Vector2.new(32,32))
    bb.Name = "ESPLib_Dot"
    local img = Instance.new("ImageLabel")
    img.Size = UDim2.fromScale(1,1)
    img.BackgroundTransparency = 1
    img.Image = "rbxassetid://11464903084"
    img.ImageColor3 = Color3.fromRGB(0,170,255)
    img.Parent = bb
    return bb
end

-- ---------- Box object ----------
local boxBase = {}
boxBase.__index = boxBase

function boxBase:Remove()
    local obj = self.Object
    local comps = self.Components
    -- drawings
    for _,d in pairs(comps) do
        if typeof(d)=="Instance" then d:Destroy()
        elseif typeof(d)=="table" and d.Destroy then d:Destroy()
        elseif d and d.Remove then d:Remove()
        end
    end
    self.Components = {}
    ESP.Objects[obj] = nil
end

local function w2v(p3)
    return cam:WorldToViewportPoint(p3)
end

local function lerp(a,b,t) return a + (b-a)*t end

function boxBase:Update()
    if not self.PrimaryPart or not self.PrimaryPart.Parent then
        return self:Remove()
    end

    -- visibility gating
    if not ESP.Enabled then
        for k,v in pairs(self.Components) do
            if v.Visible ~= nil then v.Visible = false end
            if v.Name == "BB" then v.Enabled = false end
        end
        return
    end

    -- world corners
    local cf = self.PrimaryPart.CFrame
    if ESP.FaceCamera then cf = CFrame.new(cf.Position, cam.CFrame.Position) end
    local size = self.Size

    local locs = {
        TL = cf * ESP.BoxShift * CFrame.new( size.X/2,  size.Y/2, 0),
        TR = cf * ESP.BoxShift * CFrame.new(-size.X/2,  size.Y/2, 0),
        BL = cf * ESP.BoxShift * CFrame.new( size.X/2, -size.Y/2, 0),
        BR = cf * ESP.BoxShift * CFrame.new(-size.X/2, -size.Y/2, 0),
        TAG= cf * ESP.BoxShift * CFrame.new(0, size.Y/2, 0),
        TORSO= cf * ESP.BoxShift
    }

    local TL, v1 = w2v(locs.TL.Position)
    local TR, v2 = w2v(locs.TR.Position)
    local BL, v3 = w2v(locs.BL.Position)
    local BR, v4 = w2v(locs.BR.Position)

    local onScreen = v1 or v2 or v3 or v4

    -- corner Ls
    local lines = self.Components.Lines
    if ESP.Boxes and onScreen then
        lines.Visible = true
        local w = math.max(2, math.abs(TR.X - TL.X))
        local h = math.max(2, math.abs(BL.Y - TL.Y))
        local lx = math.floor(w * ESP.CornerFrac)
        local ly = math.floor(h * ESP.CornerFrac)

        local cA = ESP.BoxColorA
        local cB = ESP.BoxColorB

        -- Top-Left
        lines.LT_H.Color = cA; lines.LT_H.From = v2(TL.X,TL.Y);       lines.LT_H.To = v2(TL.X+lx, TL.Y)
        lines.LT_V.Color = cB; lines.LT_V.From = v2(TL.X,TL.Y);       lines.LT_V.To = v2(TL.X, TL.Y+ly)
        -- Top-Right
        lines.RT_H.Color = cA; lines.RT_H.From = v2(TR.X-lx,TR.Y);    lines.RT_H.To = v2(TR.X, TR.Y)
        lines.RT_V.Color = cB; lines.RT_V.From = v2(TR.X,TR.Y);       lines.RT_V.To = v2(TR.X, TR.Y+ly)
        -- Bottom-Left
        lines.LB_H.Color = cA; lines.LB_H.From = v2(BL.X,BL.Y);       lines.LB_H.To = v2(BL.X+lx, BL.Y)
        lines.LB_V.Color = cB; lines.LB_V.From = v2(BL.X,BL.Y-ly);    lines.LB_V.To = v2(BL.X, BL.Y)
        -- Bottom-Right
        lines.RB_H.Color = cA; lines.RB_H.From = v2(BR.X-lx,BR.Y);    lines.RB_H.To = v2(BR.X, BR.Y)
        lines.RB_V.Color = cB; lines.RB_V.From = v2(BR.X,BR.Y-ly);    lines.RB_V.To = v2(BR.X, BR.Y)
    else
        lines.Visible = false
    end

    -- billboard attachments
    local hum = self.Humanoid
    if hum and self.Components.BB then
        local bb = self.Components.BB
        bb.Enabled = (ESP.Names or ESP.HealthBars)
        if bb.Enabled then
            -- head or primary
            local head = self.Object:FindFirstChild("Head")
            bb.Adornee = head or self.PrimaryPart
            -- name
            bb.NameText.Text = ("Type: %s"):format(self.DisplayName or self.Object.Name or "NPC")
            bb.NameText.TextColor3 = ESP.NameColor
            -- health bar
            local hp = math.clamp(hum.Health, 0, math.max(1, hum.MaxHealth))
            local max = math.max(1, hum.MaxHealth)
            local ratio = hp / max
            bb.BarBack.Visible = ESP.HealthBars
            bb.BarFill.Visible = ESP.HealthBars
            if ESP.HealthBars then
                bb.BarFill.Size = UDim2.new(ratio, 0, 1, 0)
            end
        end
    end

    -- dot esp
    if self.Components.DotBB then
        self.Components.DotBB.Enabled = ESP.Dot
        if ESP.Dot then
            self.Components.DotBB.Adornee = self.PrimaryPart
        end
    end
end

-- ---------- API ----------
function ESP:Toggle(b)
    self.Enabled = (b == nil and not self.Enabled) or b
end

function ESP:GetBox(obj)
    return self.Objects[obj]
end

function ESP:Add(obj, options)
    if not obj or not obj.Parent then return end

    local primary = options and options.PrimaryPart or (obj.ClassName=="Model" and (obj.PrimaryPart or obj:FindFirstChild("HumanoidRootPart") or obj:FindFirstChildWhichIsA("BasePart"))) or (obj:IsA("BasePart") and obj)
    if not primary then return end

    local hum = obj:FindFirstChildOfClass("Humanoid")
    local box = setmetatable({
        Object      = obj,
        PrimaryPart = primary,
        Size        = options.Size or self.BoxSize,
        Humanoid    = hum,
        DisplayName = options.CustomName,
        Components  = {}
    }, boxBase)

    -- corner lines set
    local lines = {
        LT_H = Draw("Line", {Thickness=self.Thickness}), LT_V = Draw("Line", {Thickness=self.Thickness}),
        RT_H = Draw("Line", {Thickness=self.Thickness}), RT_V = Draw("Line", {Thickness=self.Thickness}),
        LB_H = Draw("Line", {Thickness=self.Thickness}), LB_V = Draw("Line", {Thickness=self.Thickness}),
        RB_H = Draw("Line", {Thickness=self.Thickness}), RB_V = Draw("Line", {Thickness=self.Thickness}),
        Visible = true
    }
    box.Components.Lines = lines

    -- billboard for name + health
    local adornee = obj:FindFirstChild("Head") or primary
    local bb = mkBillboard(adornee, Vector3.new(0,3.2,0), Vector2.new(160,30))
    local name, back, fill = mkHealthBar(bb)
    box.Components.BB = bb
    box.Components.NameText = name
    box.Components.BarBack  = back
    box.Components.BarFill  = fill

    -- dot esp billboard
    local dotBB = mkDotBillboard(primary)
    box.Components.DotBB = dotBB
    dotBB.Enabled = false

    -- cleanup on removal
    obj.AncestryChanged:Connect(function(_, parent)
        if parent == nil then box:Remove() end
    end)
    if hum then
        hum.Died:Connect(function() box:Remove() end)
    end

    self.Objects[obj] = box
    return box
end

function ESP:AddObjectListener(parent, options)
    local function addCandidate(c)
        if options.Type and not c:IsA(options.Type) then return end
        if options.Name and c.Name ~= options.Name then return end
        if options.Validator and not options.Validator(c) then return end
        local pp = options.PrimaryPart
        pp = (typeof(pp)=="function" and pp(c)) or (typeof(pp)=="string" and c:FindFirstChild(pp)) or pp
        local box = ESP:Add(c, {
            PrimaryPart = pp,
            CustomName  = (typeof(options.CustomName)=="function" and options.CustomName(c)) or options.CustomName
        })
        if options.OnAdded and box then task.spawn(options.OnAdded, box) end
    end

    if options.Recursive then
        for _,d in ipairs(parent:GetDescendants()) do addCandidate(d) end
        parent.DescendantAdded:Connect(addCandidate)
    else
        for _,d in ipairs(parent:GetChildren()) do addCandidate(d) end
        parent.ChildAdded:Connect(addCandidate)
    end
end

-- per-frame update
RS.RenderStepped:Connect(function()
    cam = workspace.CurrentCamera
    if not ESP.Enabled then return end
    for _,box in pairs(ESP.Objects) do
        local ok, err = pcall(function() box:Update() end)
        if not ok then warn("[ESPlib] Update error:", err) end
    end
end)

return ESP
