-- ESPlib.lua  (Box outline + name + rounded health bar + optional dot)
local ESP = {
    Enabled    = true,
    Boxes      = true,
    Names      = true,
    HealthBars = true,
    Dot        = false,

    Thickness  = 2,
    BoxColorA  = Color3.fromRGB(0,170,255),
    BoxColorB  = Color3.fromRGB(0,210,255),
    NameColor  = Color3.fromRGB(255,255,255),

    Objects    = setmetatable({}, {__mode="kv"}),
}

local cam = workspace.CurrentCamera
local RS  = game:GetService("RunService")
local Players = game:GetService("Players")
local LP = Players.LocalPlayer

local function Draw(cls, props)
    local d = Drawing.new(cls)
    if props then for k,v in pairs(props) do d[k]=v end end
    return d
end

local function w2v(p3)
    local v, on = cam:WorldToViewportPoint(p3)
    return Vector2.new(v.X, v.Y), on
end

local function mkBillboard(adornee)
    local bb = Instance.new("BillboardGui")
    bb.Name = "ESPLib_BB"
    bb.AlwaysOnTop = true
    bb.StudsOffset = Vector3.new(0, 3.2, 0)
    bb.Size = UDim2.fromOffset(120, 28)
    bb.Adornee = adornee
    bb.Parent = LP:WaitForChild("PlayerGui")
    -- name
    local name = Instance.new("TextLabel")
    name.Name = "Name"
    name.BackgroundTransparency = 1
    name.Size = UDim2.new(1,0,0,16)
    name.Position = UDim2.fromOffset(0,0)
    name.Font = Enum.Font.GothamBold
    name.TextSize = 14
    name.TextColor3 = Color3.new(1,1,1)
    name.TextStrokeTransparency = 0.5
    name.TextXAlignment = Enum.TextXAlignment.Center
    name.Parent = bb
    -- bar back small + rounded
    local back = Instance.new("Frame")
    back.Name = "BarBack"
    back.BackgroundColor3 = Color3.fromRGB(20,20,20)
    back.BorderSizePixel = 0
    back.Size = UDim2.fromOffset(80, 4)
    back.Position = UDim2.fromOffset(20, 18) -- centered at 120 width
    back.Parent = bb
    local backCorner = Instance.new("UICorner")
    backCorner.CornerRadius = UDim.new(0, 3)
    backCorner.Parent = back
    -- bar fill with red->white gradient, rounded
    local fill = Instance.new("Frame")
    fill.Name = "BarFill"
    fill.BackgroundColor3 = Color3.fromRGB(255,0,0)
    fill.BorderSizePixel = 0
    fill.Size = UDim2.fromOffset(80, 4)
    fill.Position = UDim2.fromOffset(0, 0)
    fill.Parent = back
    local fillCorner = Instance.new("UICorner")
    fillCorner.CornerRadius = UDim.new(0, 3)
    fillCorner.Parent = fill
    local grad = Instance.new("UIGradient")
    grad.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.fromRGB(255,0,0)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(255,255,255))
    }
    grad.Rotation = 0
    grad.Parent = fill
    return bb, name, back, fill
end

local function mkDotBillboard(adornee)
    local bb = Instance.new("BillboardGui")
    bb.Name = "ESPLib_Dot"
    bb.AlwaysOnTop = true
    bb.Size = UDim2.fromOffset(18,18)
    bb.Adornee = adornee
    bb.Parent = LP:WaitForChild("PlayerGui")
    local img = Instance.new("ImageLabel")
    img.BackgroundTransparency = 1
    img.Size = UDim2.fromScale(1,1)
    img.Image = "rbxassetid://11464903084"
    img.ImageColor3 = Color3.fromRGB(0,180,255)
    img.Parent = bb
    return bb
end

-- per-object container
local Box = {}
Box.__index = Box

function Box:Destroy()
    for _,d in pairs(self.D) do
        if typeof(d)=="Instance" then d:Destroy()
        elseif d and d.Remove then d:Remove() end
    end
    self.D = {}
    ESP.Objects[self.Model] = nil
end

function Box:Update()
    if not self.Model or not self.Model.Parent then return self:Destroy() end
    if not self.Primary or not self.Primary.Parent then return self:Destroy() end

    local cf, size = self.Model:GetBoundingBox()
    local half = size * 0.5
    local corners = {
        cf * Vector3.new(-half.X,  half.Y, -half.Z),
        cf * Vector3.new( half.X,  half.Y, -half.Z),
        cf * Vector3.new( half.X, -half.Y, -half.Z),
        cf * Vector3.new(-half.X, -half.Y, -half.Z),
        cf * Vector3.new(-half.X,  half.Y,  half.Z),
        cf * Vector3.new( half.X,  half.Y,  half.Z),
        cf * Vector3.new( half.X, -half.Y,  half.Z),
        cf * Vector3.new(-half.X, -half.Y,  half.Z),
    }

    local proj, anyOn = {}, false
    local minX, maxX = 1e9, -1e9
    local minY, maxY = 1e9, -1e9
    for i=1,8 do
        local p2, on = w2v(corners[i])
        proj[i] = p2
        anyOn = anyOn or on
        if on then
            minX, maxX = math.min(minX, p2.X), math.max(maxX, p2.X)
            minY, maxY = math.min(minY, p2.Y), math.max(maxY, p2.Y)
        end
    end

    -- box lines
    local L = self.D.Lines
    local showBox = ESP.Enabled and ESP.Boxes and anyOn
    L.Visible = showBox
    if showBox then
        local tl = Vector2.new(minX, minY)
        local tr = Vector2.new(maxX, minY)
        local bl = Vector2.new(minX, maxY)
        local br = Vector2.new(maxX, maxY)

        -- vertical gradient by Y midpoint per edge
        local function colAt(y)
            local t = (maxY - minY) > 1 and (y - minY) / (maxY - minY) or 0
            local a,b = ESP.BoxColorA, ESP.BoxColorB
            return Color3.new(a.R + (b.R - a.R)*t, a.G + (b.G - a.G)*t, a.B + (b.B - a.B)*t)
        end

        L.Top.From,    L.Top.To    = tl, tr; L.Top.Color    = colAt((tl.Y+tr.Y)/2)
        L.Bottom.From, L.Bottom.To = bl, br; L.Bottom.Color = colAt((bl.Y+br.Y)/2)
        L.Left.From,   L.Left.To   = tl, bl; L.Left.Color   = colAt((tl.Y+bl.Y)/2)
        L.Right.From,  L.Right.To  = tr, br; L.Right.Color  = colAt((tr.Y+br.Y)/2)
    end

    -- Billboard (name + health)
    local showBill = ESP.Enabled and (ESP.Names or ESP.HealthBars)
    local bb = self.D.Bill
    if bb then
        bb.Enabled = showBill
        if showBill then
            local head = self.Model:FindFirstChild("Head")
            bb.Adornee = head or self.Primary
            self.D.Name.Text = tostring(self.Model.Name)
            -- health
            local hum = self.Hum
            local ok = hum and hum.Parent ~= nil
            local hp = ok and math.max(0, math.min(hum.Health, hum.MaxHealth)) or 0
            local max = ok and math.max(1, hum.MaxHealth) or 1
            local ratio = hp/max
            self.D.BarBack.Visible = ESP.HealthBars
            self.D.BarFill.Visible = ESP.HealthBars
            if ESP.HealthBars then
                self.D.BarFill.Size = UDim2.fromOffset(math.floor(80*ratio), 4)
            end
        end
    end

    -- Dot
    if self.D.Dot then
        self.D.Dot.Enabled = ESP.Enabled and ESP.Dot
        if self.D.Dot.Enabled then
            self.D.Dot.Adornee = self.Primary
        end
    end
end

-- API
function ESP:Toggle(b) self.Enabled = (b==nil) and not self.Enabled or b end

function ESP:Add(model, opt)
    if not model or not model.Parent then return end
    if self.Objects[model] then return self.Objects[model] end

    local primary = opt and opt.PrimaryPart
    if typeof(primary)=="function" then primary = primary(model) end
    if not primary then
        if model:IsA("Model") then
            primary = model.PrimaryPart or model:FindFirstChild("HumanoidRootPart") or model:FindFirstChildWhichIsA("BasePart")
        elseif model:IsA("BasePart") then
            primary = model
        end
    end
    if not primary then return end

    local hum = model:FindFirstChildOfClass("Humanoid")

    local box = setmetatable({
        Model   = model,
        Primary = primary,
        Hum     = hum,
        D       = {}
    }, Box)

    -- 4 connected lines (outline)
    box.D.Lines = {
        Top    = Draw("Line", {Thickness=self.Thickness}),
        Bottom = Draw("Line", {Thickness=self.Thickness}),
        Left   = Draw("Line", {Thickness=self.Thickness}),
        Right  = Draw("Line", {Thickness=self.Thickness}),
        Visible = true
    }

    -- Billboard (name + health)
    local bb,name,back,fill = mkBillboard(primary)
    box.D.Bill, box.D.Name, box.D.BarBack, box.D.BarFill = bb,name,back,fill

    -- Dot billboard
    local dot = mkDotBillboard(primary)
    dot.Enabled = false
    box.D.Dot = dot

    -- cleanup
    model.AncestryChanged:Connect(function(_, parent)
        if parent == nil then box:Destroy() end
    end)
    if hum then hum.Died:Connect(function() box:Destroy() end) end

    self.Objects[model] = box
    return box
end

function ESP:AddObjectListener(parent, opt)
    local function consider(x)
        if opt.Type and not x:IsA(opt.Type) then return end
        if opt.Name and x.Name ~= opt.Name then return end
        if opt.Validator and not opt.Validator(x) then return end
        local pp = opt.PrimaryPart
        if typeof(pp)=="function" then pp = pp(x) elseif typeof(pp)=="string" then pp = x:FindFirstChild(pp) end
        self:Add(x, {PrimaryPart = pp})
    end

    -- existing + live additions
    for _,d in ipairs(parent:GetDescendants()) do consider(d) end
    parent.DescendantAdded:Connect(consider)
end

-- per-frame update
RS.RenderStepped:Connect(function()
    cam = workspace.CurrentCamera
    for _,box in pairs(ESP.Objects) do
        local ok = pcall(function() box:Update() end)
        if not ok then -- ignore errors per object
        end
    end
end)

return ESP
