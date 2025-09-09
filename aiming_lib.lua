print('upd2')

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera

workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(function()
    Camera = workspace.CurrentCamera
end)

local Aiming = {
    FOV = 60,
    NPCs = false,
    Players = true,
    Enabled = true,
    ShowFOV = true,
    AimTracer = true,
    DynamicFOV = true,
    FOVColor = Color3.fromRGB(255, 255, 255),
    AimTracerColor = Color3.fromRGB(255, 0, 0),
    CurrentTarget = nil
}

local InternalFOV = Aiming.FOV
local FOVCircle = Drawing.new("Circle")

FOVCircle.NumSides = 20
FOVCircle.Transparency = 1
FOVCircle.Thickness = 2
FOVCircle.Color = Aiming.FOVColor
FOVCircle.Filled = false

local FOVTracer = Drawing.new("Line")

FOVTracer.Thickness = 2

local function UpdateFOV()

    if Aiming.ShowFOV then
        if Aiming.DynamicFOV then
            InternalFOV = Aiming.FOV * (70 / Camera.FieldOfView)
        else
            InternalFOV = Aiming.FOV
        end
    
        FOVCircle.Visible = true
        FOVCircle.Radius = InternalFOV
        FOVCircle.Color = Aiming.FOVColor
        FOVCircle.Position = UserInputService:GetMouseLocation()
    else
        FOVCircle.Visible = false
    end

end

local function GetCharactersInViewport() : {{Character: Model, Position: Vector2}}
    local ToProcess = {}
    local CharactersOnScreen = {}

-- Players
if Aiming.Players then
    for _, Player in next, Players:GetPlayers() do
        if Player ~= Players.LocalPlayer then
            local ch = Player.Character
            local hrp = ch and ch:FindFirstChild("HumanoidRootPart")
            local hum = ch and ch:FindFirstChildOfClass("Humanoid")
            if hrp and hum and hum.Health > 0 and hum:GetState() ~= Enum.HumanoidStateType.Dead then
                table.insert(ToProcess, ch)
            end
        end
    end
end

-- NPCs (tagged)
if Aiming.NPCs then
    local CS = game:GetService("CollectionService")
    for _, NPC in next, CS:GetTagged("NPC") do
        if NPC:IsDescendantOf(workspace) and NPC:IsA("Model") then
            local hrp = NPC:FindFirstChild("HumanoidRootPart")
            local hum = NPC:FindFirstChildOfClass("Humanoid")
            if hrp and hum and hum.Health > 0 and hum:GetState() ~= Enum.HumanoidStateType.Dead
               and CS:HasTag(NPC, "ActiveCharacter") then
                table.insert(ToProcess, NPC)
            end
        end
    end
end


    for _, Character in next, ToProcess do
        local Position, OnScreen = Camera:WorldToViewportPoint(Character.HumanoidRootPart.Position)

        if OnScreen then
            table.insert(CharactersOnScreen, {
                Character = Character,
                Position = Vector2.new(Position.X, Position.Y)
            })
        end
    end

    return CharactersOnScreen
end

local function DistanceFromMouse(Position : Vector2) : number
    return (UserInputService:GetMouseLocation() - Position).Magnitude
end

local function GetPlayersInFOV() : {{Character: Model, Distance: number, Position: Vector2}}
    local Characters = GetCharactersInViewport()
    local PlayersInFOV = {}

    for _, Character in next, Characters do
        local Distance = DistanceFromMouse(Character.Position)
        if Distance <= InternalFOV then
            table.insert(PlayersInFOV, {
                Character = Character.Character,
                Distance = Distance,
                Position = Character.Position
            })
        end
    end

    return PlayersInFOV
end

local function GetClosestPlayer() : (Model, number, Vector2)
    local PlayersInFOV = GetPlayersInFOV()
    local ClosestPlayer = nil
    local ClosestDistance = math.huge
    local ClosestPosition = nil

    for _, Player in next, PlayersInFOV do
        if Player.Distance < ClosestDistance then
            ClosestPlayer = Player.Character
            ClosestPosition = Player.Position
            ClosestDistance = Player.Distance
        end
    end

    return ClosestPlayer, ClosestDistance, ClosestPosition
end

-- REPLACE your existing RenderStepped connection with this:
local Connection = RunService.RenderStepped:Connect(function()
    if Aiming.Enabled then
        UpdateFOV()
        local ClosestPlayer, Distance, Position = GetClosestPlayer()
        Aiming.CurrentTarget = ClosestPlayer

        -- no on-screen tracer line
        FOVTracer.Visible = false
    else
        FOVCircle.Visible = false
        FOVTracer.Visible = false
        Aiming.CurrentTarget = nil
    end
end)


local function Unload()
    Connection:Disconnect()
    FOVCircle:Remove()
    FOVTracer:Remove()
end

Aiming.Unload = Unload

-- Better silent-aim lead (constant-velocity prediction; gravity optional)
function Aiming.GetPredictedDirection(origin: Vector3, bulletSpeed: number, preferredPartName: string?, useGravity: boolean?)
    if not (Aiming.CurrentTarget and origin and bulletSpeed) then return nil end

    local targetChar = Aiming.CurrentTarget
    local part = (preferredPartName and targetChar:FindFirstChild(preferredPartName))
               or targetChar:FindFirstChild("HumanoidRootPart")
               or targetChar:FindFirstChildWhichIsA("BasePart")
    if not part then return nil end

    local pos = part.Position
    local vel = part.AssemblyLinearVelocity or Vector3.zero

    local toTarget = pos - origin
    local t = toTarget.Magnitude / math.max(bulletSpeed, 1)

    local g = useGravity and Vector3.new(0, -workspace.Gravity, 0) or Vector3.zero
    local predicted = pos + vel * t + 0.5 * g * (t * t)

    return (predicted - origin) -- not unit; caller keeps magnitude semantics
end

return Aiming
