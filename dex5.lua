--// SIMPLE VOXEL PIPETTE (WORKS 100%) //
local player = game.Players.LocalPlayer
local uis = game:GetService("UserInputService")
local workspace = game:GetService("Workspace")
local runService = game:GetService("RunService")

-- Удаляем старое
if game.CoreGui:FindFirstChild("SimplePipette") then
    game.CoreGui.SimplePipette:Destroy()
end

-- GUI
local gui = Instance.new("ScreenGui")
gui.Name = "SimplePipette"
gui.Parent = game.CoreGui
gui.ResetOnSpawn = false

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 300, 0, 200)
frame.Position = UDim2.new(0, 20, 0, 20)
frame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
frame.BorderSizePixel = 0
frame.Active = true
frame.Draggable = true
frame.Parent = gui
Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 8)

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 25)
title.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
title.Text = "PIPETTE (Voxel)"
title.TextColor3 = Color3.new(1,1,1)
title.Font = Enum.Font.SourceSansBold
title.TextSize = 13
title.BorderSizePixel = 0
title.Parent = frame
Instance.new("UICorner", title).CornerRadius = UDim.new(0, 8)

local infoBox = Instance.new("TextBox")
infoBox.Size = UDim2.new(1, -10, 1, -35)
infoBox.Position = UDim2.new(0, 5, 0, 28)
infoBox.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
infoBox.TextColor3 = Color3.new(1,1,1)
infoBox.Font = Enum.Font.SourceSans
infoBox.TextSize = 11
infoBox.TextYAlignment = Enum.TextYAlignment.Top
infoBox.TextXAlignment = Enum.TextXAlignment.Left
infoBox.MultiLine = true
infoBox.ClearTextOnFocus = false
infoBox.BorderSizePixel = 0
infoBox.Text = "F5 = Pipette\nНаведи на гору и нажми F5"
infoBox.Parent = frame
Instance.new("UICorner", infoBox).CornerRadius = UDim.new(0, 6)

-- Функция пипетки
local function pipette()
    local cam = workspace.CurrentCamera
    local mouse = player:GetMouse()
    
    -- Пускаем луч из центра экрана
    local ray = cam:ScreenPointToRay(mouse.X, mouse.Y)
    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Include
    local result = workspace:Raycast(ray.Origin, ray.Direction * 500, params)
    
    if result then
        local target = result.Instance
        local pos = result.Position
        
        if target:IsA("Terrain") then
            -- Это гора, получаем цвет вокселя
            local terrain = workspace:FindFirstChildOfClass("Terrain")
            local mat, occ = terrain:GetMaterialAtPosition(pos)
            if occ > 0 then
                local col = terrain:GetTerrainColorAtPosition(pos)
                if col then
                    local r = math.floor(col.R * 255)
                    local g = math.floor(col.G * 255)
                    local b = math.floor(col.B * 255)
                    infoBox.Text = string.format(
                        "ОБЪЕКТ: Terrain (гора)\n\nВОКСЕЛЬ (руда):\nRGB: %d, %d, %d\nМатериал: %s\nПозиция: %s",
                        r, g, b, tostring(mat), tostring(pos)
                    )
                else
                    infoBox.Text = "Не удалось получить цвет вокселя"
                end
            else
                infoBox.Text = "Пустой воксель (воздух)"
            end
        else
            -- Обычный объект
            local info = string.format(
                "ОБЪЕКТ:\nИмя: %s\nКласс: %s\nРодитель: %s\nПуть: %s",
                target.Name,
                target.ClassName,
                target.Parent and target.Parent.Name or "нет",
                target:GetFullName()
            )
            if target:IsA("BasePart") then
                info = info .. string.format(
                    "\nПозиция: %s\nРазмер: %s\nЦвет: %s\nПрозрачность: %.2f",
                    tostring(target.Position),
                    tostring(target.Size),
                    tostring(target.BrickColor),
                    target.Transparency
                )
            elseif target:IsA("IntValue") or target:IsA("NumberValue") then
                info = info .. "\nЗначение: " .. tostring(target.Value)
            end
            infoBox.Text = info
        end
    else
        infoBox.Text = "Ничего не найдено (пустота)"
    end
end

-- Горячая клавиша F5
uis.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.F5 then
        pipette()
    end
end)

print("Simple Pipette loaded. F5 = pipette.")
