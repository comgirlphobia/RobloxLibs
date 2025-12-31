local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")

local UI = {}

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
    tween(btn, TweenInfo.new(0.08, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { Size = s + UDim2.fromOffset(6, 4) })
    task.delay(0.09, function()
        if btn and btn.Parent then
            tween(btn, TweenInfo.new(0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { Size = s })
        end
    end)
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
    local accent = opts.AccentColor or Color3.fromRGB(86, 102, 255)
    local toggleKey = opts.ToggleKey or Enum.KeyCode.RightShift

    local gui = rootGui(opts.GuiName or "SleekUI")

    local window = mk("Frame", {
        Name = "Window",
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.fromScale(0.5, 0.5),
        Size = UDim2.fromOffset(760, 520),
        BackgroundColor3 = Color3.fromRGB(14, 14, 16),
        BorderSizePixel = 0,
        Parent = gui,
    })
    corner(window, 16)
    stroke(window, 1, Color3.fromRGB(70, 70, 84), 0.35)

    local shadow = mk("ImageLabel", {
        Name = "Shadow",
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.fromScale(0.5, 0.5),
        Size = UDim2.new(1, 70, 1, 70),
        BackgroundTransparency = 1,
        Image = "rbxassetid://1316045217",
        ImageColor3 = Color3.fromRGB(0, 0, 0),
        ImageTransparency = 0.5,
        ScaleType = Enum.ScaleType.Slice,
        SliceCenter = Rect.new(10, 10, 118, 118),
        Parent = window,
        ZIndex = 0,
    })
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
        BackgroundColor3 = Color3.fromRGB(18, 18, 22),
        BorderSizePixel = 0,
        Parent = window,
    })
    corner(tabs, 14)
    stroke(tabs, 1, Color3.fromRGB(70, 70, 84), 0.55)
    pad(tabs, 12)

    local tabList = mk("Frame", { Name = "List", Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, Parent = tabs })
    vlist(tabList, 10)

    local content = mk("Frame", {
        Name = "Content",
        Position = UDim2.fromOffset(214, 58),
        Size = UDim2.new(1, -226, 1, -70),
        BackgroundColor3 = Color3.fromRGB(18, 18, 22),
        BorderSizePixel = 0,
        Parent = window,
    })
    corner(content, 14)
    stroke(content, 1, Color3.fromRGB(70, 70, 84), 0.55)

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
        tween(window, TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { BackgroundTransparency = 0, Position = UDim2.fromScale(0.5, 0.5) })
    end
    local function hide()
        if not visible then return end
        visible = false
        tween(window, TweenInfo.new(0.16, Enum.EasingStyle.Quad, Enum.EasingDirection.In), { BackgroundTransparency = 1, Position = UDim2.fromScale(0.5, 0.53) })
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

    local api = { _accent = accent, _content = content, _tabList = tabList, _tabs = {}, _current = nil }

    function api:Notify(text, duration)
        duration = tonumber(duration) or 3
        local card = mk("Frame", { Size = UDim2.fromOffset(320, 62), BackgroundColor3 = Color3.fromRGB(16, 16, 18), BorderSizePixel = 0, Parent = notifHost, ZIndex = 101 })
        corner(card, 14)
        stroke(card, 1, Color3.fromRGB(70, 70, 84), 0.55)
        local bar = mk("Frame", { Size = UDim2.new(0, 4, 1, 0), BackgroundColor3 = accent, BorderSizePixel = 0, Parent = card, ZIndex = 102 })
        corner(bar, 14)
        mk("TextLabel", {
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
        api._current = name
        for tName, t in pairs(api._tabs) do
            local on = (tName == name)
            t.frame.Visible = on
            if on then
                tween(t.accent, TweenInfo.new(0.14, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { Size = UDim2.new(0, 4, 0, 14) })
                tween(t.button, TweenInfo.new(0.14, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { BackgroundColor3 = Color3.fromRGB(36, 36, 44) })
            else
                tween(t.accent, TweenInfo.new(0.14, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { Size = UDim2.new(0, 0, 0, 14) })
                tween(t.button, TweenInfo.new(0.14, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { BackgroundColor3 = Color3.fromRGB(28, 28, 34) })
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
            BackgroundColor3 = Color3.fromRGB(28, 28, 34),
            BorderSizePixel = 0,
            AutoButtonColor = false,
            Font = Enum.Font.GothamSemibold,
            Text = name,
            TextSize = 13,
            TextColor3 = Color3.fromRGB(220, 220, 235),
            Parent = tabList,
        })
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

        local frame = mk("Frame", { BackgroundTransparency = 1, Size = UDim2.new(1, 0, 1, 0), Parent = content, Visible = false })
        local scroll = makeScroll(frame)

        local tabApi = { _scroll = scroll }

        local function section(titleText)
            local box = mk("Frame", { BackgroundColor3 = Color3.fromRGB(14, 14, 16), BorderSizePixel = 0, Parent = scroll })
            corner(box, 14)
            stroke(box, 1, Color3.fromRGB(70, 70, 84), 0.6)

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

            local inner = mk("Frame", { BackgroundTransparency = 1, Position = UDim2.fromOffset(14, 36), Size = UDim2.new(1, -28, 1, -46), Parent = box })
            local lay = vlist(inner, 10)
            lay:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                box.Size = UDim2.new(1, 0, 0, lay.AbsoluteContentSize.Y + 54)
            end)

            local sApi = { _inner = inner }

            function sApi:AddLabel(text)
                local lbl = mk("TextLabel", { BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 18), Font = Enum.Font.Gotham, Text = tostring(text), TextSize = 12, TextColor3 = Color3.fromRGB(175, 175, 195), TextXAlignment = Enum.TextXAlignment.Left, Parent = inner })
                return { SetText = function(_, t) lbl.Text = tostring(t) end }
            end

            function sApi:AddButton(text, cb)
                local b = mk("TextButton", { Size = UDim2.new(1, 0, 0, 38), BackgroundColor3 = Color3.fromRGB(28, 28, 34), BorderSizePixel = 0, AutoButtonColor = false, Font = Enum.Font.GothamSemibold, Text = tostring(text), TextSize = 13, TextColor3 = Color3.fromRGB(235, 235, 245), Parent = inner })
                corner(b, 12)
                stroke(b, 1, Color3.fromRGB(70, 70, 84), 0.7)
                b.MouseButton1Click:Connect(function()
                    pulse(b)
                    if typeof(cb) == "function" then task.spawn(cb) end
                end)
                return { SetText = function(_, t) b.Text = tostring(t) end }
            end

            function sApi:AddToggle(text, default, onChanged)
                local state = default == true
                local row = mk("Frame", { Size = UDim2.new(1, 0, 0, 38), BackgroundColor3 = Color3.fromRGB(28, 28, 34), BorderSizePixel = 0, Parent = inner })
                corner(row, 12)
                stroke(row, 1, Color3.fromRGB(70, 70, 84), 0.7)
                mk("TextLabel", { BackgroundTransparency = 1, Position = UDim2.fromOffset(12, 0), Size = UDim2.new(1, -70, 1, 0), Font = Enum.Font.GothamSemibold, Text = tostring(text), TextSize = 13, TextColor3 = Color3.fromRGB(235, 235, 245), TextXAlignment = Enum.TextXAlignment.Left, Parent = row })

                local knob = mk("Frame", { AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -12, 0.5, 0), Size = UDim2.fromOffset(44, 22), BackgroundColor3 = Color3.fromRGB(20, 20, 24), BorderSizePixel = 0, Parent = row })
                corner(knob, 11)
                stroke(knob, 1, Color3.fromRGB(70, 70, 84), 0.7)

                local dot = mk("Frame", { AnchorPoint = Vector2.new(0, 0.5), Position = UDim2.new(0, 2, 0.5, 0), Size = UDim2.fromOffset(18, 18), BackgroundColor3 = Color3.fromRGB(140, 140, 160), BorderSizePixel = 0, Parent = knob })
                corner(dot, 9)

                local click = mk("TextButton", { BackgroundTransparency = 1, Size = UDim2.new(1, 0, 1, 0), Text = "", Parent = row })

                local function render()
                    if state then
                        tween(dot, TweenInfo.new(0.14, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { Position = UDim2.new(1, -20, 0.5, 0), BackgroundColor3 = accent })
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

                return {
                    GetValue = function() return state end,
                    SetValue = function(_, v) state = v == true; render() end,
                }
            end

            function sApi:AddInput(text, default, placeholder, onChanged)
                local row = mk("Frame", { Size = UDim2.new(1, 0, 0, 38), BackgroundColor3 = Color3.fromRGB(28, 28, 34), BorderSizePixel = 0, Parent = inner })
                corner(row, 12)
                stroke(row, 1, Color3.fromRGB(70, 70, 84), 0.7)
                mk("TextLabel", { BackgroundTransparency = 1, Position = UDim2.fromOffset(12, 0), Size = UDim2.new(0.45, -12, 1, 0), Font = Enum.Font.GothamSemibold, Text = tostring(text), TextSize = 13, TextColor3 = Color3.fromRGB(235, 235, 245), TextXAlignment = Enum.TextXAlignment.Left, Parent = row })

                local box = mk("TextBox", {
                    AnchorPoint = Vector2.new(1, 0.5),
                    Position = UDim2.new(1, -12, 0.5, 0),
                    Size = UDim2.new(0.55, -12, 0, 26),
                    BackgroundColor3 = Color3.fromRGB(18, 18, 22),
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

                box:GetPropertyChangedSignal("Text"):Connect(function()
                    if typeof(onChanged) == "function" then task.spawn(onChanged, box.Text) end
                end)

                return {
                    GetValue = function() return box.Text end,
                    SetValue = function(_, v) box.Text = tostring(v or "") end,
                }
            end

            return sApi
        end

        function tabApi:AddSection(titleText)
            return section(titleText)
        end

        api._tabs[name] = { button = btn, accent = accentBar, frame = frame }

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

return UI
