local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")

local UI = {}

local DEFAULT_ACCENT = Color3.fromRGB(247, 215, 248)

local TI_SHOW = TweenInfo.new(0.22, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
local TI_HIDE = TweenInfo.new(0.20, Enum.EasingStyle.Quint, Enum.EasingDirection.In)
local TI_HOVER = TweenInfo.new(0.16, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
local TI_PRESS = TweenInfo.new(0.10, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

local function accentHighlight(c)
    return c:Lerp(Color3.new(1, 1, 1), 0.35)
end

local function textStroke(parent, color, transparency, thickness)
    local s = Instance.new("UITextStroke")
    s.Color = color or Color3.fromRGB(0, 0, 0)
    s.Transparency = transparency == nil and 0.55 or transparency
    s.Thickness = thickness or 1
    s.LineJoinMode = Enum.LineJoinMode.Round
    s.Parent = parent
    return s
end

local function styleText(inst, kind)
    if not inst then return end
    if inst:IsA("TextLabel") or inst:IsA("TextButton") or inst:IsA("TextBox") then
        if kind == "title" then
            inst.TextColor3 = Color3.fromRGB(255, 250, 255)
            textStroke(inst, Color3.fromRGB(0, 0, 0), 0.40, 1)
        elseif kind == "sub" then
            inst.TextColor3 = Color3.fromRGB(210, 205, 225)
            textStroke(inst, Color3.fromRGB(0, 0, 0), 0.62, 1)
        else
            inst.TextColor3 = inst.TextColor3 or Color3.fromRGB(235, 235, 245)
            textStroke(inst, Color3.fromRGB(0, 0, 0), 0.70, 1)
        end
    end
end

local function addShine(parent, accent)
    local shine = Instance.new("Frame")
    shine.Name = "Shine"
    shine.BackgroundTransparency = 1
    shine.BorderSizePixel = 0
    shine.Size = UDim2.new(1, 0, 1, 0)
    shine.ZIndex = (parent.ZIndex or 1) + 1
    shine.ClipsDescendants = true
    shine.Parent = parent

    local bar = Instance.new("Frame")
    bar.Name = "Bar"
    bar.BackgroundTransparency = 1
    bar.BorderSizePixel = 0
    bar.AnchorPoint = Vector2.new(0.5, 0.5)
    bar.Position = UDim2.fromScale(0.5, 0.5)
    bar.Size = UDim2.new(1.4, 0, 1.4, 0)
    bar.ZIndex = shine.ZIndex
    bar.Parent = shine

    local g = Instance.new("UIGradient")
    g.Rotation = 25
    g.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.new(1, 1, 1)),
        ColorSequenceKeypoint.new(0.45, accentHighlight(accent)),
        ColorSequenceKeypoint.new(1, Color3.new(1, 1, 1)),
    })
    g.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 1),
        NumberSequenceKeypoint.new(0.46, 0.88),
        NumberSequenceKeypoint.new(0.54, 0.88),
        NumberSequenceKeypoint.new(1, 1),
    })
    g.Offset = Vector2.new(-1, 0)
    g.Parent = bar

    local function sweep()
        g.Offset = Vector2.new(-1, 0)
        tween(g, TweenInfo.new(0.55, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), { Offset = Vector2.new(1, 0) })
    end

    return shine, g, sweep
end

local function glowStroke(parent, color, thickness, transparency)
    local s = Instance.new("UIStroke")
    s.Thickness = thickness
    s.Color = color
    s.Transparency = transparency
    s.LineJoinMode = Enum.LineJoinMode.Round
    s.Parent = parent

    local g = Instance.new("UIGradient")
    g.Rotation = 90
    g.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, color),
        ColorSequenceKeypoint.new(1, accentHighlight(color)),
    })
    g.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, transparency),
        NumberSequenceKeypoint.new(1, math.clamp(transparency + 0.25, 0, 1)),
    })
    g.Parent = s

    return s
end

local function softGradient(parent, c1, c2)
    local g = Instance.new("UIGradient")
    g.Rotation = 45
    g.Color = ColorSequence.new(c1, c2)
    g.Parent = parent
    return g
end

local function tween(i, ti, p)
    local t = TweenService:Create(i, ti, p)
    t:Play()
    return t
end

local function mk(c, props)
    local i = Instance.new(c)
    for k, v in pairs(props) do i[k] = v end
    return i
end

local function corner(p, r)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, r)
    c.Parent = p
end

local function stroke(p, th, col, tr)
    local s = Instance.new("UIStroke")
    s.Thickness = th
    s.Color = col
    s.Transparency = tr
    s.Parent = p
end

local function vlist(p, pad)
    local l = Instance.new("UIListLayout")
    l.FillDirection = Enum.FillDirection.Vertical
    l.SortOrder = Enum.SortOrder.LayoutOrder
    l.Padding = UDim.new(0, pad)
    l.Parent = p
    return l
end

local function pad(p, n)
    local u = Instance.new("UIPadding")
    u.PaddingTop = UDim.new(0, n)
    u.PaddingBottom = UDim.new(0, n)
    u.PaddingLeft = UDim.new(0, n)
    u.PaddingRight = UDim.new(0, n)
    u.Parent = p
end

local function pulse(btn)
    local s = btn.Size
    tween(btn, TI_PRESS, { Size = s + UDim2.fromOffset(6, 4) })
    task.delay(0.09, function()
        if btn and btn.Parent then
            tween(btn, TI_HOVER, { Size = s })
        end
    end)
end

local function btnState(btn, state)
    if state == "idle" then
        tween(btn, TI_HOVER, { BackgroundColor3 = Color3.fromRGB(20, 16, 28) })
    elseif state == "hover" then
        tween(btn, TI_HOVER, { BackgroundColor3 = Color3.fromRGB(28, 22, 38) })
    elseif state == "press" then
        tween(btn, TI_PRESS, { BackgroundColor3 = Color3.fromRGB(36, 28, 48) })
    end
end

local function draggable(handle, target)
    local drag, start, pos
    handle.InputBegan:Connect(function(i)
        if i.UserInputType ~= Enum.UserInputType.MouseButton1 then return end
        drag = true
        start = i.Position
        pos = target.Position
        i.Changed:Connect(function()
            if i.UserInputState == Enum.UserInputState.End then drag = false end
        end)
    end)
    UserInputService.InputChanged:Connect(function(i)
        if not drag or i.UserInputType ~= Enum.UserInputType.MouseMovement then return end
        local d = i.Position - start
        target.Position = UDim2.new(pos.X.Scale, pos.X.Offset + d.X, pos.Y.Scale, pos.Y.Offset + d.Y)
    end)
end

local function rootGui(name)
    local lp = Players.LocalPlayer
    local pg = lp:WaitForChild("PlayerGui")
    local ex = pg:FindFirstChild(name)
    if ex then ex:Destroy() end
    local g = Instance.new("ScreenGui")
    g.Name = name
    g.ResetOnSpawn = false
    g.IgnoreGuiInset = true
    g.Parent = pg
    return g
end

function UI:CreateWindow(opts)
    opts = opts or {}
    local accent = opts.AccentColor or DEFAULT_ACCENT
    local toggleKey = opts.ToggleKey or Enum.KeyCode.RightShift

    local gui = rootGui(opts.GuiName or "SleekUI")

    local window = mk("Frame", {
        Name = "Window",
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.fromScale(0.5, 0.5),
        Size = UDim2.fromOffset(760, 520),
        BackgroundColor3 = Color3.fromRGB(12, 10, 16),
        BorderSizePixel = 0,
        Parent = gui,
    })
    corner(window, 16)
    stroke(window, 1, Color3.fromRGB(95, 85, 110), 0.55)
    softGradient(window, Color3.fromRGB(16, 12, 24), Color3.fromRGB(10, 10, 12))

    window.ZIndex = 1

    local top = mk("Frame", { Name = "Top", Size = UDim2.new(1, 0, 0, 54), BackgroundTransparency = 1, Parent = window })
    local title = mk("TextLabel", {
        BackgroundTransparency = 1,
        Position = UDim2.fromOffset(18, 10),
        Size = UDim2.new(1, -36, 0, 22),
        Font = Enum.Font.GothamSemibold,
        Text = tostring(opts.Title or "SleekUI"),
        TextSize = 18,
        TextColor3 = Color3.fromRGB(245, 245, 255),
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = top,
    })
    styleText(title, "title")
    local sub = mk("TextLabel", {
        BackgroundTransparency = 1,
        Position = UDim2.fromOffset(18, 31),
        Size = UDim2.new(1, -36, 0, 16),
        Font = Enum.Font.Gotham,
        Text = tostring(opts.Subtitle or ("Toggle: " .. toggleKey.Name)),
        TextSize = 12,
        TextColor3 = Color3.fromRGB(165, 165, 185),
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = top,
    })

    local tabs = mk("Frame", {
        Name = "Tabs",
        Position = UDim2.fromOffset(12, 58),
        Size = UDim2.new(0, 190, 1, -70),
        BackgroundColor3 = Color3.fromRGB(14, 12, 18),
        BorderSizePixel = 0,
        Parent = window,
    })
    corner(tabs, 14)
    stroke(tabs, 1, Color3.fromRGB(95, 85, 110), 0.65)
    softGradient(tabs, Color3.fromRGB(16, 12, 22), Color3.fromRGB(10, 10, 12))
    pad(tabs, 12)

    local tabList = mk("Frame", { Name = "List", Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, Parent = tabs })
    vlist(tabList, 10)

    local content = mk("Frame", {
        Name = "Content",
        Position = UDim2.fromOffset(214, 58),
        Size = UDim2.new(1, -226, 1, -70),
        BackgroundColor3 = Color3.fromRGB(14, 12, 18),
        BorderSizePixel = 0,
        Parent = window,
    })
    corner(content, 14)
    stroke(content, 1, Color3.fromRGB(95, 85, 110), 0.65)
    softGradient(content, Color3.fromRGB(16, 12, 22), Color3.fromRGB(10, 10, 12))

    local notifHost = mk("Frame", {
        Name = "Notifications",
        AnchorPoint = Vector2.new(1, 1),
        Position = UDim2.new(1, -18, 1, -18),
        Size = UDim2.fromOffset(320, 320),
        BackgroundTransparency = 1,
        Parent = gui,
        ZIndex = 100,
    })
    local nlayout = Instance.new("UIListLayout")
    nlayout.FillDirection = Enum.FillDirection.Vertical
    nlayout.SortOrder = Enum.SortOrder.LayoutOrder
    nlayout.VerticalAlignment = Enum.VerticalAlignment.Bottom
    nlayout.Padding = UDim.new(0, 10)
    nlayout.Parent = notifHost

    draggable(top, window)

    local visible = true
    local function show()
        if visible then return end
        visible = true
        gui.Enabled = true
        window.Visible = true
        window.BackgroundTransparency = 1
        window.Position = UDim2.fromScale(0.5, 0.53)
        tween(window, TI_SHOW, { BackgroundTransparency = 0, Position = UDim2.fromScale(0.5, 0.5) })
    end
    local function hide()
        if not visible then return end
        visible = false
        tween(window, TI_HIDE, { BackgroundTransparency = 1, Position = UDim2.fromScale(0.5, 0.53) })
        task.delay(0.17, function()
            if not visible and gui and gui.Parent then
                window.Visible = false
                gui.Enabled = false
            end
        end)
    end

    UserInputService.InputBegan:Connect(function(i, gp)
        if gp then return end
        if i.KeyCode == toggleKey then
            if visible then hide() else show() end
        end
    end)

    local api = { _accent = accent, _accentTargets = {}, _content = content, _tabList = tabList, _tabs = {}, _current = nil }

    function api:_bindAccent(inst, prop)
        table.insert(self._accentTargets, { inst = inst, prop = prop })
        if typeof(inst) == "function" then
            pcall(function() inst(self._accent) end)
        else
            pcall(function() inst[prop] = self._accent end)
        end
    end

    function api:SetAccent(color)
        if typeof(color) ~= "Color3" then return end
        self._accent = color
        for _, t in ipairs(self._accentTargets) do
            if typeof(t.inst) == "function" then
                pcall(function() t.inst(color) end)
            elseif t.inst and t.inst.Parent then
                pcall(function() t.inst[t.prop] = color end)
            end
        end
    end

    do
        local gs = glowStroke(window, accent, 2, 0.60)
        api:_bindAccent(gs, "Color")

        local shine, _, sweep = addShine(window, accent)
        shine.ZIndex = window.ZIndex + 2
        api:_bindAccent(function(c)
            local bar = shine:FindFirstChild("Bar")
            if not bar then return end
            local grad = bar:FindFirstChildOfClass("UIGradient")
            if not grad then return end
            grad.Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0, Color3.new(1, 1, 1)),
                ColorSequenceKeypoint.new(0.45, accentHighlight(c)),
                ColorSequenceKeypoint.new(1, Color3.new(1, 1, 1)),
            })
        end, "__func")
        task.delay(0.2, sweep)
    end

    function api:Notify(text, duration)
        duration = tonumber(duration) or 3
        local card = mk("Frame", { Size = UDim2.fromOffset(320, 62), BackgroundColor3 = Color3.fromRGB(12, 10, 16), BorderSizePixel = 0, Parent = notifHost, ZIndex = 101 })
        corner(card, 14)
        stroke(card, 1, Color3.fromRGB(95, 85, 110), 0.65)
        softGradient(card, Color3.fromRGB(16, 12, 24), Color3.fromRGB(10, 10, 12))
        local bar = mk("Frame", { Size = UDim2.new(0, 4, 1, 0), BackgroundColor3 = accent, BorderSizePixel = 0, Parent = card, ZIndex = 102 })
        corner(bar, 14)
        api:_bindAccent(bar, "BackgroundColor3")
        local txt = mk("TextLabel", {
            BackgroundTransparency = 1,
            Position = UDim2.fromOffset(14, 10),
            Size = UDim2.new(1, -24, 1, -20),
            Font = Enum.Font.Gotham,
            Text = tostring(text),
            TextSize = 13,
            TextColor3 = Color3.fromRGB(235, 235, 245),
            TextXAlignment = Enum.TextXAlignment.Left,
            TextYAlignment = Enum.TextYAlignment.Top,
            TextWrapped = true,
            Parent = card,
            ZIndex = 102,
        })
        styleText(txt)
        card.BackgroundTransparency = 1
        card.Size = UDim2.fromOffset(320, 0)
        tween(card, TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { BackgroundTransparency = 0, Size = UDim2.fromOffset(320, 62) })
        task.delay(duration, function()
            if not card or not card.Parent then return end
            tween(card, TweenInfo.new(0.16, Enum.EasingStyle.Quad, Enum.EasingDirection.In), { BackgroundTransparency = 1, Size = UDim2.fromOffset(320, 0) })
            task.delay(0.17, function() if card and card.Parent then card:Destroy() end end)
        end)
    end

    function api:SelectTab(name)
        if api._current == name then return end
        local prevName = api._current
        api._current = name
        for tName, t in pairs(api._tabs) do
            local on = (tName == name)
            if t.group then
                if on then
                    t.frame.Visible = true
                    t.group.GroupTransparency = 1
                    t.frame.Position = UDim2.fromOffset(10, 0)
                    tween(t.group, TweenInfo.new(0.22, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), { GroupTransparency = 0 })
                    tween(t.frame, TweenInfo.new(0.22, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), { Position = UDim2.fromOffset(0, 0) })
                elseif prevName == tName then
                    tween(t.group, TweenInfo.new(0.18, Enum.EasingStyle.Quint, Enum.EasingDirection.In), { GroupTransparency = 1 })
                    tween(t.frame, TweenInfo.new(0.18, Enum.EasingStyle.Quint, Enum.EasingDirection.In), { Position = UDim2.fromOffset(-8, 0) })
                    task.delay(0.19, function()
                        if api._current ~= tName and t.frame and t.frame.Parent then
                            t.frame.Visible = false
                        end
                    end)
                else
                    t.group.GroupTransparency = 1
                    t.frame.Visible = false
                end
            else
                t.frame.Visible = on
            end
            if on then
                tween(t.accent, TweenInfo.new(0.14, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { Size = UDim2.new(0, 4, 0, 14) })
                tween(t.button, TweenInfo.new(0.14, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { BackgroundColor3 = Color3.fromRGB(28, 22, 38) })
            else
                tween(t.accent, TweenInfo.new(0.14, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { Size = UDim2.new(0, 0, 0, 14) })
                tween(t.button, TweenInfo.new(0.14, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { BackgroundColor3 = Color3.fromRGB(20, 16, 28) })
            end
        end
    end

    local function makeScroll(parent)
        local sc = mk("ScrollingFrame", {
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            Size = UDim2.new(1, 0, 1, 0),
            CanvasSize = UDim2.new(0, 0, 0, 0),
            ScrollBarThickness = 4,
            ScrollBarImageColor3 = Color3.fromRGB(80, 80, 96),
            Parent = parent,
        })
        pad(sc, 14)
        local lay = vlist(sc, 12)
        lay:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            sc.CanvasSize = UDim2.new(0, 0, 0, lay.AbsoluteContentSize.Y + 14)
        end)
        return sc
    end

    function api:AddTab(name)
        name = tostring(name)
        local btn = mk("TextButton", {
            Size = UDim2.new(1, 0, 0, 38),
            BackgroundColor3 = Color3.fromRGB(20, 16, 28),
            BorderSizePixel = 0,
            AutoButtonColor = false,
            Font = Enum.Font.GothamSemibold,
            Text = name,
            TextSize = 13,
            TextColor3 = Color3.fromRGB(220, 220, 235),
            Parent = tabList,
        })
        styleText(btn)
        corner(btn, 12)
        stroke(btn, 1, Color3.fromRGB(70, 70, 84), 0.7)

        local accentBar = mk("Frame", {
            AnchorPoint = Vector2.new(0, 0.5),
            Position = UDim2.new(0, 8, 0.5, 0),
            Size = UDim2.new(0, 0, 0, 14),
            BackgroundColor3 = accent,
            BorderSizePixel = 0,
            Parent = btn,
        })
        corner(accentBar, 10)
        api:_bindAccent(accentBar, "BackgroundColor3")

        local frame = mk("Frame", { BackgroundTransparency = 1, Size = UDim2.new(1, 0, 1, 0), Parent = content, Visible = false, Position = UDim2.fromOffset(0, 0) })
        local cg = mk("CanvasGroup", {
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            Size = UDim2.new(1, 0, 1, 0),
            GroupTransparency = 1,
            Parent = frame,
        })
        local scroll = makeScroll(cg)

        local tabApi = { _scroll = scroll }

        local function section(titleText)
            local box = mk("Frame", { BackgroundColor3 = Color3.fromRGB(12, 10, 16), BorderSizePixel = 0, Parent = scroll })
            corner(box, 14)
            stroke(box, 1, Color3.fromRGB(95, 85, 110), 0.7)
            softGradient(box, Color3.fromRGB(18, 12, 28), Color3.fromRGB(10, 10, 12))
            do
                local gs = glowStroke(box, api._accent, 1, 0.78)
                api:_bindAccent(gs, "Color")
            end

            mk("TextLabel", {
                BackgroundTransparency = 1,
                Position = UDim2.fromOffset(14, 10),
                Size = UDim2.new(1, -28, 0, 20),
                Font = Enum.Font.GothamSemibold,
                Text = tostring(titleText),
                TextSize = 14,
                TextColor3 = Color3.fromRGB(240, 240, 250),
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = box,
            })
            styleText(box:FindFirstChildOfClass("TextLabel"), "title")

            local inner = mk("Frame", { BackgroundTransparency = 1, Position = UDim2.fromOffset(14, 36), Size = UDim2.new(1, -28, 1, -46), Parent = box })
            local lay = vlist(inner, 10)
            lay:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                box.Size = UDim2.new(1, 0, 0, lay.AbsoluteContentSize.Y + 54)
            end)

            local sApi = { _inner = inner }

            function sApi:AddLabel(text)
                local lbl = mk("TextLabel", { BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 18), Font = Enum.Font.Gotham, Text = tostring(text), TextSize = 12, TextColor3 = Color3.fromRGB(210, 205, 225), TextXAlignment = Enum.TextXAlignment.Left, Parent = inner })
                styleText(lbl, "sub")
                return { SetText = function(_, t) lbl.Text = tostring(t) end }
            end

            function sApi:AddButton(text, cb)
                local b = mk("TextButton", { Size = UDim2.new(1, 0, 0, 38), BackgroundColor3 = Color3.fromRGB(20, 16, 28), BorderSizePixel = 0, AutoButtonColor = false, Font = Enum.Font.GothamSemibold, Text = tostring(text), TextSize = 13, TextColor3 = Color3.fromRGB(245, 235, 250), Parent = inner })
                styleText(b)
                corner(b, 12)
                stroke(b, 1, Color3.fromRGB(95, 85, 110), 0.75)
                softGradient(b, Color3.fromRGB(26, 18, 38), Color3.fromRGB(16, 14, 20))
                do
                    local gs = glowStroke(b, api._accent, 1, 0.85)
                    api:_bindAccent(gs, "Color")
                end

                local shine, _, sweep = addShine(b, api._accent)
                shine.ZIndex = b.ZIndex + 2
                api:_bindAccent(function(c)
                    local bar = shine:FindFirstChild("Bar")
                    if not bar then return end
                    local grad = bar:FindFirstChildOfClass("UIGradient")
                    if not grad then return end
                    grad.Color = ColorSequence.new({
                        ColorSequenceKeypoint.new(0, Color3.new(1, 1, 1)),
                        ColorSequenceKeypoint.new(0.45, accentHighlight(c)),
                        ColorSequenceKeypoint.new(1, Color3.new(1, 1, 1)),
                    })
                end, "__func")

                b.MouseEnter:Connect(function() btnState(b, "hover") sweep() end)
                b.MouseLeave:Connect(function() btnState(b, "idle") end)
                b.MouseButton1Down:Connect(function() btnState(b, "press") end)
                b.MouseButton1Up:Connect(function() btnState(b, "hover") end)

                b.MouseButton1Click:Connect(function()
                    pulse(b)
                    if typeof(cb) == "function" then task.spawn(cb) end
                end)

                local bApi = {}
                function bApi:SetText(t)
                    b.Text = tostring(t)
                end
                return bApi
            end

            function sApi:AddToggle(text, default, onChanged)
                local state = default == true

                local row = mk("Frame", { Size = UDim2.new(1, 0, 0, 38), BackgroundColor3 = Color3.fromRGB(20, 16, 28), BorderSizePixel = 0, Parent = inner })
                corner(row, 12)
                stroke(row, 1, Color3.fromRGB(95, 85, 110), 0.75)
                softGradient(row, Color3.fromRGB(26, 18, 38), Color3.fromRGB(16, 14, 20))

                local tLbl = mk("TextLabel", { BackgroundTransparency = 1, Position = UDim2.fromOffset(12, 0), Size = UDim2.new(1, -70, 1, 0), Font = Enum.Font.GothamSemibold, Text = tostring(text), TextSize = 13, TextColor3 = Color3.fromRGB(245, 235, 250), TextXAlignment = Enum.TextXAlignment.Left, Parent = row })
                styleText(tLbl)

                local knob = mk("Frame", { AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -12, 0.5, 0), Size = UDim2.fromOffset(44, 22), BackgroundColor3 = Color3.fromRGB(14, 12, 18), BorderSizePixel = 0, Parent = row })
                corner(knob, 11)
                stroke(knob, 1, Color3.fromRGB(95, 85, 110), 0.7)

                local dot = mk("Frame", { AnchorPoint = Vector2.new(0, 0.5), Position = UDim2.new(0, 2, 0.5, 0), Size = UDim2.fromOffset(18, 18), BackgroundColor3 = Color3.fromRGB(140, 140, 160), BorderSizePixel = 0, Parent = knob })
                corner(dot, 9)

                local click = mk("TextButton", { BackgroundTransparency = 1, Size = UDim2.new(1, 0, 1, 0), Text = "", Parent = row })

                local function render()
                    if state then
                        tween(dot, TweenInfo.new(0.14, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { Position = UDim2.new(1, -20, 0.5, 0), BackgroundColor3 = api._accent })
                    else
                        tween(dot, TweenInfo.new(0.14, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { Position = UDim2.new(0, 2, 0.5, 0), BackgroundColor3 = Color3.fromRGB(140, 140, 160) })
                    end
                end
                render()

                click.MouseButton1Click:Connect(function()
                    state = not state
                    render()
                    if typeof(onChanged) == "function" then task.spawn(onChanged, state) end
                end)

                local tApi = {}
                function tApi:GetValue() return state end
                function tApi:SetValue(v)
                    state = v == true
                    render()
                end
                return tApi
            end

            function sApi:AddInput(text, default, placeholder, onChanged)
                local row = mk("Frame", { Size = UDim2.new(1, 0, 0, 38), BackgroundColor3 = Color3.fromRGB(20, 16, 28), BorderSizePixel = 0, Parent = inner })
                corner(row, 12)
                stroke(row, 1, Color3.fromRGB(95, 85, 110), 0.75)
                softGradient(row, Color3.fromRGB(26, 18, 38), Color3.fromRGB(16, 14, 20))
                local iLbl = mk("TextLabel", { BackgroundTransparency = 1, Position = UDim2.fromOffset(12, 0), Size = UDim2.new(0.45, -12, 1, 0), Font = Enum.Font.GothamSemibold, Text = tostring(text), TextSize = 13, TextColor3 = Color3.fromRGB(245, 235, 250), TextXAlignment = Enum.TextXAlignment.Left, Parent = row })
                styleText(iLbl)

                local box = mk("TextBox", {
                    AnchorPoint = Vector2.new(1, 0.5),
                    Position = UDim2.new(1, -12, 0.5, 0),
                    Size = UDim2.new(0.55, -12, 0, 26),
                    BackgroundColor3 = Color3.fromRGB(14, 12, 18),
                    BorderSizePixel = 0,
                    ClearTextOnFocus = false,
                    Font = Enum.Font.Gotham,
                    Text = tostring(default or ""),
                    PlaceholderText = tostring(placeholder or ""),
                    TextSize = 12,
                    TextColor3 = Color3.fromRGB(235, 235, 245),
                    PlaceholderColor3 = Color3.fromRGB(120, 120, 140),
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Parent = row,
                })
                corner(box, 10)
                styleText(box)

                box:GetPropertyChangedSignal("Text"):Connect(function()
                    if typeof(onChanged) == "function" then task.spawn(onChanged, box.Text) end
                end)

                return {
                    GetValue = function() return box.Text end,
                    SetValue = function(_, v) box.Text = tostring(v or "") end,
                }
            end

            function sApi:AddDropdown(text, values, defaultIndex, onChanged)
                values = values or {}
                local selected = values[defaultIndex or 1]

                local row = mk("Frame", { Size = UDim2.new(1, 0, 0, 38), BackgroundColor3 = Color3.fromRGB(20, 16, 28), BorderSizePixel = 0, Parent = inner })
                corner(row, 12)
                stroke(row, 1, Color3.fromRGB(95, 85, 110), 0.75)
                softGradient(row, Color3.fromRGB(26, 18, 38), Color3.fromRGB(16, 14, 20))
                local dLbl = mk("TextLabel", { BackgroundTransparency = 1, Position = UDim2.fromOffset(12, 0), Size = UDim2.new(0.45, -12, 1, 0), Font = Enum.Font.GothamSemibold, Text = tostring(text), TextSize = 13, TextColor3 = Color3.fromRGB(245, 235, 250), TextXAlignment = Enum.TextXAlignment.Left, Parent = row })
                styleText(dLbl)

                local btn = mk("TextButton", {
                    AnchorPoint = Vector2.new(1, 0.5),
                    Position = UDim2.new(1, -12, 0.5, 0),
                    Size = UDim2.new(0.55, -12, 0, 26),
                    BackgroundColor3 = Color3.fromRGB(14, 12, 18),
                    BorderSizePixel = 0,
                    AutoButtonColor = false,
                    Font = Enum.Font.Gotham,
                    Text = tostring(selected or "-"),
                    TextSize = 12,
                    TextColor3 = Color3.fromRGB(235, 235, 245),
                    Parent = row,
                })
                corner(btn, 10)
                styleText(btn)

                local menu = mk("Frame", {
                    AnchorPoint = Vector2.new(1, 0),
                    Position = UDim2.new(1, -12, 1, 6),
                    Size = UDim2.new(0.55, -12, 0, 0),
                    BackgroundColor3 = Color3.fromRGB(12, 10, 16),
                    BorderSizePixel = 0,
                    Parent = row,
                    Visible = false,
                    ClipsDescendants = true,
                    ZIndex = 30,
                })
                corner(menu, 12)
                stroke(menu, 1, Color3.fromRGB(95, 85, 110), 0.7)
                softGradient(menu, Color3.fromRGB(18, 12, 28), Color3.fromRGB(10, 10, 12))

                local sc = mk("ScrollingFrame", {
                    BackgroundTransparency = 1,
                    BorderSizePixel = 0,
                    Size = UDim2.new(1, 0, 1, 0),
                    CanvasSize = UDim2.new(0, 0, 0, 0),
                    ScrollBarThickness = 3,
                    ScrollBarImageColor3 = Color3.fromRGB(80, 80, 96),
                    Parent = menu,
                    ZIndex = 31,
                })
                pad(sc, 10)
                local lay = vlist(sc, 8)
                lay:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                    sc.CanvasSize = UDim2.new(0, 0, 0, lay.AbsoluteContentSize.Y + 10)
                end)

                local open = false
                local function closeMenu()
                    if not open then return end
                    open = false
                    tween(menu, TweenInfo.new(0.14, Enum.EasingStyle.Quad, Enum.EasingDirection.In), { Size = UDim2.new(0.55, -12, 0, 0) })
                    task.delay(0.15, function()
                        if not open and menu and menu.Parent then
                            menu.Visible = false
                        end
                    end)
                end
                local function openMenu()
                    if open then return end
                    open = true
                    menu.Visible = true
                    local height = math.min(200, lay.AbsoluteContentSize.Y + 20)
                    menu.Size = UDim2.new(0.55, -12, 0, 0)
                    tween(menu, TweenInfo.new(0.16, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { Size = UDim2.new(0.55, -12, 0, height) })
                end

                btn.MouseEnter:Connect(function() tween(btn, TweenInfo.new(0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { BackgroundColor3 = Color3.fromRGB(18, 14, 22) }) end)
                btn.MouseLeave:Connect(function() tween(btn, TweenInfo.new(0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { BackgroundColor3 = Color3.fromRGB(14, 12, 18) }) end)

                btn.MouseButton1Click:Connect(function()
                    pulse(btn)
                    if open then closeMenu() else openMenu() end
                end)

                local function rebuildOptions(newValues)
                    for _, ch in ipairs(sc:GetChildren()) do
                        if ch:IsA("TextButton") then ch:Destroy() end
                    end
                    for _, v in ipairs(newValues) do
                        local opt = mk("TextButton", { Size = UDim2.new(1, 0, 0, 30), BackgroundColor3 = Color3.fromRGB(28, 28, 34), BorderSizePixel = 0, AutoButtonColor = false, Font = Enum.Font.Gotham, Text = tostring(v), TextSize = 12, TextColor3 = Color3.fromRGB(235, 235, 245), Parent = sc, ZIndex = 32 })
                        corner(opt, 10)
                        opt.MouseEnter:Connect(function() btnState(opt, "hover") end)
                        opt.MouseLeave:Connect(function() btnState(opt, "idle") end)
                        opt.MouseButton1Click:Connect(function()
                            selected = v
                            btn.Text = tostring(v)
                            closeMenu()
                            if typeof(onChanged) == "function" then task.spawn(onChanged, v) end
                        end)
                    end
                end
                rebuildOptions(values)

                UserInputService.InputBegan:Connect(function(input, gp)
                    if gp then return end
                    if open and input.UserInputType == Enum.UserInputType.MouseButton1 then
                        local pos = UserInputService:GetMouseLocation()
                        local abs = menu.AbsolutePosition
                        local size = menu.AbsoluteSize
                        if not (pos.X >= abs.X and pos.X <= abs.X + size.X and pos.Y >= abs.Y and pos.Y <= abs.Y + size.Y) then
                            closeMenu()
                        end
                    end
                end)

                return {
                    GetValue = function() return selected end,
                    SetValue = function(_, v) selected = v; btn.Text = tostring(v) end,
                    SetValues = function(_, newValues)
                        values = newValues or {}
                        rebuildOptions(values)
                    end,
                }
            end

            function sApi:AddSearchDropdown(text, values, defaultIndex, onChanged)
                values = values or {}
                local selected = values[defaultIndex or 1]

                local row = mk("Frame", { Size = UDim2.new(1, 0, 0, 38), BackgroundColor3 = Color3.fromRGB(20, 16, 28), BorderSizePixel = 0, Parent = inner })
                corner(row, 12)
                stroke(row, 1, Color3.fromRGB(95, 85, 110), 0.75)
                softGradient(row, Color3.fromRGB(26, 18, 38), Color3.fromRGB(16, 14, 20))
                mk("TextLabel", { BackgroundTransparency = 1, Position = UDim2.fromOffset(12, 0), Size = UDim2.new(0.45, -12, 1, 0), Font = Enum.Font.GothamSemibold, Text = tostring(text), TextSize = 13, TextColor3 = Color3.fromRGB(235, 235, 245), TextXAlignment = Enum.TextXAlignment.Left, Parent = row })

                local btn = mk("TextButton", {
                    AnchorPoint = Vector2.new(1, 0.5),
                    Position = UDim2.new(1, -12, 0.5, 0),
                    Size = UDim2.new(0.55, -12, 0, 26),
                    BackgroundColor3 = Color3.fromRGB(14, 12, 18),
                    BorderSizePixel = 0,
                    AutoButtonColor = false,
                    Font = Enum.Font.Gotham,
                    Text = tostring(selected or "-"),
                    TextSize = 12,
                    TextColor3 = Color3.fromRGB(235, 235, 245),
                    Parent = row,
                })
                corner(btn, 10)

                local menu = mk("Frame", {
                    AnchorPoint = Vector2.new(1, 0),
                    Position = UDim2.new(1, -12, 1, 6),
                    Size = UDim2.new(0.55, -12, 0, 0),
                    BackgroundColor3 = Color3.fromRGB(12, 10, 16),
                    BorderSizePixel = 0,
                    Parent = row,
                    Visible = false,
                    ClipsDescendants = true,
                    ZIndex = 40,
                })
                corner(menu, 12)
                stroke(menu, 1, Color3.fromRGB(95, 85, 110), 0.7)
                softGradient(menu, Color3.fromRGB(18, 12, 28), Color3.fromRGB(10, 10, 12))

                local search = mk("TextBox", {
                    Position = UDim2.fromOffset(10, 10),
                    Size = UDim2.new(1, -20, 0, 26),
                    BackgroundColor3 = Color3.fromRGB(14, 12, 18),
                    BorderSizePixel = 0,
                    ClearTextOnFocus = false,
                    Font = Enum.Font.Gotham,
                    Text = "",
                    PlaceholderText = "Search...",
                    TextSize = 12,
                    TextColor3 = Color3.fromRGB(235, 235, 245),
                    PlaceholderColor3 = Color3.fromRGB(120, 120, 140),
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Parent = menu,
                    ZIndex = 41,
                })
                corner(search, 10)

                local sc = mk("ScrollingFrame", {
                    BackgroundTransparency = 1,
                    BorderSizePixel = 0,
                    Position = UDim2.fromOffset(0, 44),
                    Size = UDim2.new(1, 0, 1, -44),
                    CanvasSize = UDim2.new(0, 0, 0, 0),
                    ScrollBarThickness = 3,
                    ScrollBarImageColor3 = Color3.fromRGB(80, 80, 96),
                    Parent = menu,
                    ZIndex = 41,
                })
                pad(sc, 10)
                local lay = vlist(sc, 8)
                lay:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                    sc.CanvasSize = UDim2.new(0, 0, 0, lay.AbsoluteContentSize.Y + 10)
                end)

                local open = false
                local function closeMenu()
                    if not open then return end
                    open = false
                    tween(menu, TweenInfo.new(0.14, Enum.EasingStyle.Quad, Enum.EasingDirection.In), { Size = UDim2.new(0.55, -12, 0, 0) })
                    task.delay(0.15, function()
                        if not open and menu and menu.Parent then
                            menu.Visible = false
                        end
                    end)
                end
                local function openMenu()
                    if open then return end
                    open = true
                    menu.Visible = true
                    search.Text = ""
                    local height = math.min(240, lay.AbsoluteContentSize.Y + 54)
                    menu.Size = UDim2.new(0.55, -12, 0, 0)
                    tween(menu, TweenInfo.new(0.16, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { Size = UDim2.new(0.55, -12, 0, height) })
                end

                btn.MouseEnter:Connect(function() tween(btn, TweenInfo.new(0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { BackgroundColor3 = Color3.fromRGB(18, 14, 22) }) end)
                btn.MouseLeave:Connect(function() tween(btn, TweenInfo.new(0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { BackgroundColor3 = Color3.fromRGB(14, 12, 18) }) end)
                btn.MouseButton1Click:Connect(function()
                    pulse(btn)
                    if open then closeMenu() else openMenu() end
                end)

                local function rebuildOptions(filter)
                    filter = tostring(filter or ""):lower()
                    for _, ch in ipairs(sc:GetChildren()) do
                        if ch:IsA("TextButton") then ch:Destroy() end
                    end
                    for _, v in ipairs(values) do
                        local vs = tostring(v)
                        if filter == "" or vs:lower():find(filter, 1, true) then
                            local opt = mk("TextButton", { Size = UDim2.new(1, 0, 0, 30), BackgroundColor3 = Color3.fromRGB(20, 16, 28), BorderSizePixel = 0, AutoButtonColor = false, Font = Enum.Font.Gotham, Text = vs, TextSize = 12, TextColor3 = Color3.fromRGB(235, 235, 245), Parent = sc, ZIndex = 42 })
                            corner(opt, 10)
                            opt.MouseEnter:Connect(function() btnState(opt, "hover") end)
                            opt.MouseLeave:Connect(function() btnState(opt, "idle") end)
                            opt.MouseButton1Click:Connect(function()
                                selected = v
                                btn.Text = tostring(v)
                                closeMenu()
                                if typeof(onChanged) == "function" then task.spawn(onChanged, v) end
                            end)
                        end
                    end
                end
                rebuildOptions("")

                search:GetPropertyChangedSignal("Text"):Connect(function()
                    rebuildOptions(search.Text)
                end)

                UserInputService.InputBegan:Connect(function(input, gp)
                    if gp then return end
                    if open and input.UserInputType == Enum.UserInputType.MouseButton1 then
                        local pos = UserInputService:GetMouseLocation()
                        local abs = menu.AbsolutePosition
                        local size = menu.AbsoluteSize
                        if not (pos.X >= abs.X and pos.X <= abs.X + size.X and pos.Y >= abs.Y and pos.Y <= abs.Y + size.Y) then
                            closeMenu()
                        end
                    end
                end)

                return {
                    GetValue = function() return selected end,
                    SetValue = function(_, v) selected = v; btn.Text = tostring(v) end,
                    SetValues = function(_, newValues)
                        values = newValues or {}
                        rebuildOptions(search.Text)
                    end,
                }
            end

            function sApi:AddMultiSelect(text, values, defaultSelected, onChanged)
                values = values or {}
                local selectedSet = {}
                if type(defaultSelected) == "table" then
                    for _, v in ipairs(defaultSelected) do selectedSet[tostring(v)] = true end
                end

                local row = mk("Frame", { Size = UDim2.new(1, 0, 0, 38), BackgroundColor3 = Color3.fromRGB(20, 16, 28), BorderSizePixel = 0, Parent = inner })
                corner(row, 12)
                stroke(row, 1, Color3.fromRGB(95, 85, 110), 0.75)
                softGradient(row, Color3.fromRGB(26, 18, 38), Color3.fromRGB(16, 14, 20))
                mk("TextLabel", { BackgroundTransparency = 1, Position = UDim2.fromOffset(12, 0), Size = UDim2.new(0.45, -12, 1, 0), Font = Enum.Font.GothamSemibold, Text = tostring(text), TextSize = 13, TextColor3 = Color3.fromRGB(235, 235, 245), TextXAlignment = Enum.TextXAlignment.Left, Parent = row })

                local function countSelected()
                    local n = 0
                    for _, v in ipairs(values) do if selectedSet[tostring(v)] then n += 1 end end
                    return n
                end

                local btn = mk("TextButton", {
                    AnchorPoint = Vector2.new(1, 0.5),
                    Position = UDim2.new(1, -12, 0.5, 0),
                    Size = UDim2.new(0.55, -12, 0, 26),
                    BackgroundColor3 = Color3.fromRGB(14, 12, 18),
                    BorderSizePixel = 0,
                    AutoButtonColor = false,
                    Font = Enum.Font.Gotham,
                    Text = tostring(countSelected()) .. " selected",
                    TextSize = 12,
                    TextColor3 = Color3.fromRGB(235, 235, 245),
                    Parent = row,
                })
                corner(btn, 10)

                local menu = mk("Frame", {
                    AnchorPoint = Vector2.new(1, 0),
                    Position = UDim2.new(1, -12, 1, 6),
                    Size = UDim2.new(0.55, -12, 0, 0),
                    BackgroundColor3 = Color3.fromRGB(12, 10, 16),
                    BorderSizePixel = 0,
                    Parent = row,
                    Visible = false,
                    ClipsDescendants = true,
                    ZIndex = 40,
                })
                corner(menu, 12)
                stroke(menu, 1, Color3.fromRGB(95, 85, 110), 0.7)
                softGradient(menu, Color3.fromRGB(18, 12, 28), Color3.fromRGB(10, 10, 12))

                local search = mk("TextBox", {
                    Position = UDim2.fromOffset(10, 10),
                    Size = UDim2.new(1, -20, 0, 26),
                    BackgroundColor3 = Color3.fromRGB(14, 12, 18),
                    BorderSizePixel = 0,
                    ClearTextOnFocus = false,
                    Font = Enum.Font.Gotham,
                    Text = "",
                    PlaceholderText = "Search...",
                    TextSize = 12,
                    TextColor3 = Color3.fromRGB(235, 235, 245),
                    PlaceholderColor3 = Color3.fromRGB(120, 120, 140),
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Parent = menu,
                    ZIndex = 41,
                })
                corner(search, 10)

                local sc = mk("ScrollingFrame", {
                    BackgroundTransparency = 1,
                    BorderSizePixel = 0,
                    Position = UDim2.fromOffset(0, 44),
                    Size = UDim2.new(1, 0, 1, -44),
                    CanvasSize = UDim2.new(0, 0, 0, 0),
                    ScrollBarThickness = 3,
                    ScrollBarImageColor3 = Color3.fromRGB(80, 80, 96),
                    Parent = menu,
                    ZIndex = 41,
                })
                pad(sc, 10)
                local lay = vlist(sc, 8)
                lay:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                    sc.CanvasSize = UDim2.new(0, 0, 0, lay.AbsoluteContentSize.Y + 10)
                end)

                local open = false
                local function closeMenu()
                    if not open then return end
                    open = false
                    tween(menu, TweenInfo.new(0.14, Enum.EasingStyle.Quad, Enum.EasingDirection.In), { Size = UDim2.new(0.55, -12, 0, 0) })
                    task.delay(0.15, function()
                        if not open and menu and menu.Parent then menu.Visible = false end
                    end)
                end
                local function openMenu()
                    if open then return end
                    open = true
                    menu.Visible = true
                    search.Text = ""
                    local height = math.min(240, lay.AbsoluteContentSize.Y + 54)
                    menu.Size = UDim2.new(0.55, -12, 0, 0)
                    tween(menu, TweenInfo.new(0.16, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { Size = UDim2.new(0.55, -12, 0, height) })
                end

                btn.MouseEnter:Connect(function() tween(btn, TweenInfo.new(0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { BackgroundColor3 = Color3.fromRGB(22, 22, 28) }) end)
                btn.MouseLeave:Connect(function() tween(btn, TweenInfo.new(0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { BackgroundColor3 = Color3.fromRGB(18, 18, 22) }) end)
                btn.MouseButton1Click:Connect(function()
                    pulse(btn)
                    if open then closeMenu() else openMenu() end
                end)

                local function getSelectedList()
                    local out = {}
                    for _, v in ipairs(values) do
                        if selectedSet[tostring(v)] then
                            table.insert(out, v)
                        end
                    end
                    return out
                end

                local function renderButtonText()
                    btn.Text = tostring(countSelected()) .. " selected"
                end

                local function rebuildOptions(filter)
                    filter = tostring(filter or ""):lower()
                    for _, ch in ipairs(sc:GetChildren()) do
                        if ch:IsA("Frame") or ch:IsA("TextButton") then ch:Destroy() end
                    end

                    for _, v in ipairs(values) do
                        local vs = tostring(v)
                        if filter == "" or vs:lower():find(filter, 1, true) then
                            local optRow = mk("Frame", { Size = UDim2.new(1, 0, 0, 30), BackgroundColor3 = Color3.fromRGB(20, 16, 28), BorderSizePixel = 0, Parent = sc, ZIndex = 42 })
                            corner(optRow, 10)

                            local check = mk("Frame", { AnchorPoint = Vector2.new(0, 0.5), Position = UDim2.new(0, 8, 0.5, 0), Size = UDim2.fromOffset(14, 14), BackgroundColor3 = selectedSet[vs] and api._accent or Color3.fromRGB(14, 12, 18), BorderSizePixel = 0, Parent = optRow, ZIndex = 43 })
                            corner(check, 4)

                            mk("TextLabel", { BackgroundTransparency = 1, Position = UDim2.new(0, 28, 0, 0), Size = UDim2.new(1, -36, 1, 0), Font = Enum.Font.Gotham, Text = vs, TextSize = 12, TextColor3 = Color3.fromRGB(235, 235, 245), TextXAlignment = Enum.TextXAlignment.Left, Parent = optRow, ZIndex = 43 })

                            local hit = mk("TextButton", { BackgroundTransparency = 1, Size = UDim2.new(1, 0, 1, 0), Text = "", Parent = optRow, ZIndex = 44 })
                            hit.MouseButton1Click:Connect(function()
                                selectedSet[vs] = not selectedSet[vs]
                                check.BackgroundColor3 = selectedSet[vs] and api._accent or Color3.fromRGB(14, 12, 18)
                                renderButtonText()
                                if typeof(onChanged) == "function" then task.spawn(onChanged, getSelectedList()) end
                            end)
                        end
                    end
                end

                rebuildOptions("")
                renderButtonText()

                search:GetPropertyChangedSignal("Text"):Connect(function()
                    rebuildOptions(search.Text)
                end)

                UserInputService.InputBegan:Connect(function(input, gp)
                    if gp then return end
                    if open and input.UserInputType == Enum.UserInputType.MouseButton1 then
                        local pos = UserInputService:GetMouseLocation()
                        local abs = menu.AbsolutePosition
                        local size = menu.AbsoluteSize
                        if not (pos.X >= abs.X and pos.X <= abs.X + size.X and pos.Y >= abs.Y and pos.Y <= abs.Y + size.Y) then
                            closeMenu()
                        end
                    end
                end)

                return {
                    GetValue = function() return getSelectedList() end,
                    SetValue = function(_, list)
                        selectedSet = {}
                        if type(list) == "table" then
                            for _, v in ipairs(list) do selectedSet[tostring(v)] = true end
                        end
                        rebuildOptions(search.Text)
                        renderButtonText()
                    end,
                    SetValues = function(_, newValues)
                        values = newValues or {}
                        rebuildOptions(search.Text)
                        renderButtonText()
                    end,
                }
            end

            function sApi:AddColorPicker(text, defaultColor, onChanged)
                local color = defaultColor
                if typeof(color) ~= "Color3" then
                    color = Color3.fromRGB(235, 203, 170)
                end

                local row = mk("Frame", { Size = UDim2.new(1, 0, 0, 38), BackgroundColor3 = Color3.fromRGB(28, 28, 34), BorderSizePixel = 0, Parent = inner })
                corner(row, 12)
                stroke(row, 1, Color3.fromRGB(70, 70, 84), 0.7)
                mk("TextLabel", { BackgroundTransparency = 1, Position = UDim2.fromOffset(12, 0), Size = UDim2.new(0.55, -12, 1, 0), Font = Enum.Font.GothamSemibold, Text = tostring(text), TextSize = 13, TextColor3 = Color3.fromRGB(235, 235, 245), TextXAlignment = Enum.TextXAlignment.Left, Parent = row })

                local preview = mk("TextButton", {
                    AnchorPoint = Vector2.new(1, 0.5),
                    Position = UDim2.new(1, -12, 0.5, 0),
                    Size = UDim2.new(0.45, -12, 0, 26),
                    BackgroundColor3 = color,
                    BorderSizePixel = 0,
                    AutoButtonColor = false,
                    Text = "",
                    Parent = row,
                })
                corner(preview, 10)
                stroke(preview, 1, Color3.fromRGB(0, 0, 0), 0.65)

                local menu = mk("Frame", {
                    AnchorPoint = Vector2.new(1, 0),
                    Position = UDim2.new(1, -12, 1, 6),
                    Size = UDim2.new(0.45, -12, 0, 0),
                    BackgroundColor3 = Color3.fromRGB(14, 14, 16),
                    BorderSizePixel = 0,
                    Parent = row,
                    Visible = false,
                    ClipsDescendants = true,
                    ZIndex = 50,
                })
                corner(menu, 12)
                stroke(menu, 1, Color3.fromRGB(70, 70, 84), 0.6)

                local holder = mk("Frame", { BackgroundTransparency = 1, Position = UDim2.fromOffset(10, 10), Size = UDim2.new(1, -20, 1, -20), Parent = menu, ZIndex = 51 })
                local lay = vlist(holder, 10)

                local function miniSlider(label, min, max, value0, cb)
                    local wrap = mk("Frame", { Size = UDim2.new(1, 0, 0, 46), BackgroundColor3 = Color3.fromRGB(28, 28, 34), BorderSizePixel = 0, Parent = holder, ZIndex = 52 })
                    corner(wrap, 10)
                    stroke(wrap, 1, Color3.fromRGB(70, 70, 84), 0.7)

                    mk("TextLabel", { BackgroundTransparency = 1, Position = UDim2.fromOffset(10, 6), Size = UDim2.new(1, -20, 0, 16), Font = Enum.Font.GothamSemibold, Text = tostring(label), TextSize = 12, TextColor3 = Color3.fromRGB(235, 235, 245), TextXAlignment = Enum.TextXAlignment.Left, Parent = wrap, ZIndex = 53 })
                    local valLbl = mk("TextLabel", { BackgroundTransparency = 1, Position = UDim2.fromOffset(10, 6), Size = UDim2.new(1, -20, 0, 16), Font = Enum.Font.Gotham, Text = tostring(value0), TextSize = 12, TextColor3 = Color3.fromRGB(170, 170, 190), TextXAlignment = Enum.TextXAlignment.Right, Parent = wrap, ZIndex = 53 })

                    local bar = mk("Frame", { Position = UDim2.fromOffset(10, 28), Size = UDim2.new(1, -20, 0, 10), BackgroundColor3 = Color3.fromRGB(18, 18, 22), BorderSizePixel = 0, Parent = wrap, ZIndex = 53 })
                    corner(bar, 8)
                    local fill = mk("Frame", { Size = UDim2.new((value0 - min) / (max - min), 0, 1, 0), BackgroundColor3 = api._accent, BorderSizePixel = 0, Parent = bar, ZIndex = 54 })
                    corner(fill, 8)
                    api:_bindAccent(fill, "BackgroundColor3")

                    local hit = mk("TextButton", { BackgroundTransparency = 1, Size = UDim2.new(1, 0, 1, 0), Text = "", Parent = bar, ZIndex = 55 })
                    local dragging = false
                    local value = value0

                    local function set(v)
                        v = tonumber(v)
                        if v == nil then return end
                        if v < min then v = min end
                        if v > max then v = max end
                        value = v
                        valLbl.Text = tostring(math.floor(v + 0.5))
                        fill.Size = UDim2.new((value - min) / (max - min), 0, 1, 0)
                        cb(value)
                    end

                    local function setFromX(x)
                        local abs = bar.AbsolutePosition
                        local sz = bar.AbsoluteSize
                        local pct = (x - abs.X) / math.max(1, sz.X)
                        if pct < 0 then pct = 0 end
                        if pct > 1 then pct = 1 end
                        set(min + (max - min) * pct)
                    end

                    hit.MouseButton1Down:Connect(function()
                        dragging = true
                        setFromX(UserInputService:GetMouseLocation().X)
                    end)
                    UserInputService.InputEnded:Connect(function(inp)
                        if inp.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
                    end)
                    UserInputService.InputChanged:Connect(function(inp)
                        if dragging and inp.UserInputType == Enum.UserInputType.MouseMovement then
                            setFromX(UserInputService:GetMouseLocation().X)
                        end
                    end)

                    return function() return value end
                end

                local r = math.floor(color.R * 255 + 0.5)
                local g = math.floor(color.G * 255 + 0.5)
                local b = math.floor(color.B * 255 + 0.5)

                local function apply()
                    color = Color3.fromRGB(r, g, b)
                    preview.BackgroundColor3 = color
                    if typeof(onChanged) == "function" then task.spawn(onChanged, color) end
                end

                miniSlider("Red", 0, 255, r, function(v) r = math.floor(v + 0.5); apply() end)
                miniSlider("Green", 0, 255, g, function(v) g = math.floor(v + 0.5); apply() end)
                miniSlider("Blue", 0, 255, b, function(v) b = math.floor(v + 0.5); apply() end)

                lay:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                    menu.Size = UDim2.new(menu.Size.X.Scale, menu.Size.X.Offset, 0, lay.AbsoluteContentSize.Y + 20)
                end)

                local open = false
                local function closeMenu()
                    if not open then return end
                    open = false
                    tween(menu, TweenInfo.new(0.14, Enum.EasingStyle.Quad, Enum.EasingDirection.In), { Size = UDim2.new(menu.Size.X.Scale, menu.Size.X.Offset, 0, 0) })
                    task.delay(0.15, function()
                        if not open and menu and menu.Parent then menu.Visible = false end
                    end)
                end
                local function openMenu()
                    if open then return end
                    open = true
                    menu.Visible = true
                    local targetH = lay.AbsoluteContentSize.Y + 20
                    menu.Size = UDim2.new(menu.Size.X.Scale, menu.Size.X.Offset, 0, 0)
                    tween(menu, TweenInfo.new(0.16, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { Size = UDim2.new(menu.Size.X.Scale, menu.Size.X.Offset, 0, targetH) })
                end

                preview.MouseButton1Click:Connect(function()
                    pulse(preview)
                    if open then closeMenu() else openMenu() end
                end)

                UserInputService.InputBegan:Connect(function(input, gp)
                    if gp then return end
                    if open and input.UserInputType == Enum.UserInputType.MouseButton1 then
                        local pos = UserInputService:GetMouseLocation()
                        local abs = menu.AbsolutePosition
                        local size = menu.AbsoluteSize
                        if not (pos.X >= abs.X and pos.X <= abs.X + size.X and pos.Y >= abs.Y and pos.Y <= abs.Y + size.Y) then
                            closeMenu()
                        end
                    end
                end)

                return {
                    GetValue = function() return color end,
                    SetValue = function(_, c)
                        if typeof(c) == "Color3" then
                            color = c
                            r = math.floor(c.R * 255 + 0.5)
                            g = math.floor(c.G * 255 + 0.5)
                            b = math.floor(c.B * 255 + 0.5)
                            apply()
                        end
                    end,
                }
            end

            function sApi:AddSlider(text, min, max, defaultValue, onChanged)
                min = tonumber(min) or 0
                max = tonumber(max) or 100
                local value = tonumber(defaultValue)
                if value == nil then value = min end
                if value < min then value = min end
                if value > max then value = max end

                local row = mk("Frame", { Size = UDim2.new(1, 0, 0, 46), BackgroundColor3 = Color3.fromRGB(28, 28, 34), BorderSizePixel = 0, Parent = inner })
                corner(row, 12)
                stroke(row, 1, Color3.fromRGB(70, 70, 84), 0.7)

                mk("TextLabel", { BackgroundTransparency = 1, Position = UDim2.fromOffset(12, 6), Size = UDim2.new(1, -24, 0, 16), Font = Enum.Font.GothamSemibold, Text = tostring(text), TextSize = 13, TextColor3 = Color3.fromRGB(235, 235, 245), TextXAlignment = Enum.TextXAlignment.Left, Parent = row })
                local valLbl = mk("TextLabel", { BackgroundTransparency = 1, Position = UDim2.fromOffset(12, 6), Size = UDim2.new(1, -24, 0, 16), Font = Enum.Font.Gotham, Text = tostring(value), TextSize = 12, TextColor3 = Color3.fromRGB(170, 170, 190), TextXAlignment = Enum.TextXAlignment.Right, Parent = row })

                local bar = mk("Frame", { Position = UDim2.fromOffset(12, 28), Size = UDim2.new(1, -24, 0, 10), BackgroundColor3 = Color3.fromRGB(18, 18, 22), BorderSizePixel = 0, Parent = row })
                corner(bar, 8)

                local fill = mk("Frame", { Size = UDim2.new((value - min) / (max - min), 0, 1, 0), BackgroundColor3 = accent, BorderSizePixel = 0, Parent = bar })
                corner(fill, 8)
                api:_bindAccent(fill, "BackgroundColor3")

                local hit = mk("TextButton", { BackgroundTransparency = 1, Size = UDim2.new(1, 0, 1, 0), Text = "", Parent = bar })
                local dragging = false

                local function setValue(v)
                    v = tonumber(v)
                    if v == nil then return end
                    if v < min then v = min end
                    if v > max then v = max end
                    value = v
                    valLbl.Text = tostring(math.floor(v * 1000) / 1000)
                    fill.Size = UDim2.new((value - min) / (max - min), 0, 1, 0)
                    if typeof(onChanged) == "function" then task.spawn(onChanged, value) end
                end

                local function setFromX(x)
                    local abs = bar.AbsolutePosition
                    local sz = bar.AbsoluteSize
                    local pct = (x - abs.X) / math.max(1, sz.X)
                    if pct < 0 then pct = 0 end
                    if pct > 1 then pct = 1 end
                    setValue(min + (max - min) * pct)
                end

                hit.MouseButton1Down:Connect(function()
                    dragging = true
                    setFromX(UserInputService:GetMouseLocation().X)
                end)
                UserInputService.InputEnded:Connect(function(inp)
                    if inp.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
                end)
                UserInputService.InputChanged:Connect(function(inp)
                    if dragging and inp.UserInputType == Enum.UserInputType.MouseMovement then
                        setFromX(UserInputService:GetMouseLocation().X)
                    end
                end)

                return {
                    GetValue = function() return value end,
                    SetValue = function(_, v) setValue(v) end,
                }
            end

            function sApi:AddKeybind(text, defaultKey, onChanged)
                local key = defaultKey
                local listening = false

                local row = mk("Frame", { Size = UDim2.new(1, 0, 0, 38), BackgroundColor3 = Color3.fromRGB(28, 28, 34), BorderSizePixel = 0, Parent = inner })
                corner(row, 12)
                stroke(row, 1, Color3.fromRGB(70, 70, 84), 0.7)
                mk("TextLabel", { BackgroundTransparency = 1, Position = UDim2.fromOffset(12, 0), Size = UDim2.new(0.55, -12, 1, 0), Font = Enum.Font.GothamSemibold, Text = tostring(text), TextSize = 13, TextColor3 = Color3.fromRGB(235, 235, 245), TextXAlignment = Enum.TextXAlignment.Left, Parent = row })

                local btn = mk("TextButton", {
                    AnchorPoint = Vector2.new(1, 0.5),
                    Position = UDim2.new(1, -12, 0.5, 0),
                    Size = UDim2.new(0.45, -12, 0, 26),
                    BackgroundColor3 = Color3.fromRGB(18, 18, 22),
                    BorderSizePixel = 0,
                    AutoButtonColor = false,
                    Font = Enum.Font.Gotham,
                    Text = key and key.Name or "None",
                    TextSize = 12,
                    TextColor3 = Color3.fromRGB(235, 235, 245),
                    Parent = row,
                })
                corner(btn, 10)
                btn.MouseEnter:Connect(function() tween(btn, TweenInfo.new(0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { BackgroundColor3 = Color3.fromRGB(22, 22, 28) }) end)
                btn.MouseLeave:Connect(function() tween(btn, TweenInfo.new(0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { BackgroundColor3 = Color3.fromRGB(18, 18, 22) }) end)

                local conn
                local function stopListen()
                    listening = false
                    if conn then conn:Disconnect() conn = nil end
                    btn.Text = key and key.Name or "None"
                end

                local function startListen()
                    if listening then return end
                    listening = true
                    btn.Text = "Press a key..."
                    if conn then conn:Disconnect() conn=nil end
                    conn = UserInputService.InputBegan:Connect(function(input, gp)
                        if gp then return end
                        if input.UserInputType == Enum.UserInputType.Keyboard then
                            key = input.KeyCode
                            stopListen()
                            if typeof(onChanged) == "function" then
                                task.spawn(onChanged, key)
                            end
                        end
                    end)
                end

                btn.MouseButton1Click:Connect(function()
                    pulse(btn)
                    if listening then
                        stopListen()
                    else
                        startListen()
                    end
                end)

                local kApi = {}
                function kApi:GetValue() return key end
                function kApi:SetValue(v)
                    key = v
                    stopListen()
                end
                return kApi
            end

            return sApi
        end

        function tabApi:AddSection(titleText)
            return section(titleText)
        end

        api._tabs[name] = { button = btn, accent = accentBar, frame = frame, group = cg }

        btn.MouseButton1Click:Connect(function()
            pulse(btn)
            api:SelectTab(name)
        end)

        if not api._current then
            api:SelectTab(name)
        end

        return tabApi
    end

    return api
end

if getgenv then
    pcall(function()
        getgenv().SleekUI = UI
    end)
end

return UI
