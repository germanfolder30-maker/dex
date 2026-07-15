--// SWILL DEX v5 – Fixed Voxel Pipette (Works on Terrain) //
local player = game.Players.LocalPlayer
local uis = game:GetService("UserInputService")
local workspace = game:GetService("Workspace")
local runService = game:GetService("RunService")

if game.CoreGui:FindFirstChild("SwillDex") then
    game.CoreGui.SwillDex:Destroy()
end

local collectedColors = {}

-- ===================== GUI =====================
local gui = Instance.new("ScreenGui")
gui.Name = "SwillDex"
gui.Parent = game.CoreGui
gui.ResetOnSpawn = false

local main = Instance.new("Frame")
main.Size = UDim2.new(0, 620, 0, 460)
main.Position = UDim2.new(0.5, -310, 0.1, 0)
main.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
main.BorderSizePixel = 0
main.Active = true
main.Draggable = true
main.Parent = gui
Instance.new("UICorner", main).CornerRadius = UDim.new(0, 10)

local titleBar = Instance.new("Frame")
titleBar.Size = UDim2.new(1, 0, 0, 32)
titleBar.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
titleBar.BorderSizePixel = 0
titleBar.Parent = main
Instance.new("UICorner", titleBar).CornerRadius = UDim.new(0, 10)

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -90, 1, 0)
title.Position = UDim2.new(0, 10, 0, 0)
title.BackgroundTransparency = 1
title.Text = "SWILL DEX"
title.TextColor3 = Color3.new(1,1,1)
title.Font = Enum.Font.SourceSansBold
title.TextSize = 15
title.Parent = titleBar

local pipBtn = Instance.new("TextButton")
pipBtn.Size = UDim2.new(0, 80, 0, 24)
pipBtn.Position = UDim2.new(1, -85, 0, 4)
pipBtn.BackgroundColor3 = Color3.fromRGB(255, 80, 80)
pipBtn.Text = "Pipette"
pipBtn.TextColor3 = Color3.new(1,1,1)
pipBtn.Font = Enum.Font.SourceSansBold
pipBtn.TextSize = 12
pipBtn.BorderSizePixel = 0
pipBtn.Parent = main
Instance.new("UICorner", pipBtn).CornerRadius = UDim.new(0, 6)

local pipetteActive = false

local addEspBtn = Instance.new("TextButton")
addEspBtn.Size = UDim2.new(0, 100, 0, 24)
addEspBtn.Position = UDim2.new(0, 10, 0, 430)
addEspBtn.BackgroundColor3 = Color3.fromRGB(100, 180, 255)
addEspBtn.Text = "Add to ESP"
addEspBtn.TextColor3 = Color3.new(1,1,1)
addEspBtn.Font = Enum.Font.SourceSansBold
addEspBtn.TextSize = 12
addEspBtn.BorderSizePixel = 0
addEspBtn.Parent = main
Instance.new("UICorner", addEspBtn).CornerRadius = UDim.new(0, 6)

local treeFrame = Instance.new("ScrollingFrame")
treeFrame.Size = UDim2.new(0, 270, 1, -80)
treeFrame.Position = UDim2.new(0, 8, 0, 36)
treeFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
treeFrame.BorderSizePixel = 0
treeFrame.ScrollBarThickness = 5
treeFrame.ScrollBarImageColor3 = Color3.fromRGB(120, 120, 120)
treeFrame.AutomaticCanvasSize = "Y"
treeFrame.CanvasSize = UDim2.new(0,0,0,0)
treeFrame.Parent = main
Instance.new("UICorner", treeFrame).CornerRadius = UDim.new(0, 6)

local treeLayout = Instance.new("UIListLayout")
treeLayout.Parent = treeFrame
treeLayout.SortOrder = Enum.SortOrder.Name
treeLayout.Padding = UDim.new(0, 2)

local infoBox = Instance.new("TextBox")
infoBox.Size = UDim2.new(0, 320, 1, -80)
infoBox.Position = UDim2.new(0, 286, 0, 36)
infoBox.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
infoBox.TextColor3 = Color3.new(1,1,1)
infoBox.Font = Enum.Font.SourceSans
infoBox.TextSize = 12
infoBox.TextYAlignment = Enum.TextYAlignment.Top
infoBox.TextXAlignment = Enum.TextXAlignment.Left
infoBox.MultiLine = true
infoBox.ClearTextOnFocus = false
infoBox.BorderSizePixel = 0
infoBox.Text = "Нажми Pipette и кликни по объекту / руде"
infoBox.Parent = main
Instance.new("UICorner", infoBox).CornerRadius = UDim.new(0, 6)

-- ===================== ДЕРЕВО ОБЪЕКТОВ =====================
local nodes = {}

local function createNode(instance, depth)
    if nodes[instance] then return nodes[instance] end

    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -10, 0, 22)
    btn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    btn.Text = string.rep("  ", depth) .. instance.Name .. " [" .. instance.ClassName .. "]"
    btn.TextColor3 = Color3.new(1,1,1)
    btn.Font = Enum.Font.SourceSans
    btn.TextSize = 11
    btn.TextXAlignment = Enum.TextXAlignment.Left
    btn.BorderSizePixel = 0
    btn.AutoButtonColor = false
    btn.Parent = treeFrame
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 4)

    nodes[instance] = btn

    btn.MouseButton1Click:Connect(function()
        local info = string.format("Имя: %s\nКласс: %s\nРодитель: %s\nПуть: %s",
            instance.Name, instance.ClassName,
            instance.Parent and instance.Parent.Name or "нет",
            instance:GetFullName())
        if instance:IsA("BasePart") then
            info = info .. string.format("\nПозиция: %s\nРазмер: %s\nЦвет: %s\nПрозрачность: %.2f",
                tostring(instance.Position), tostring(instance.Size),
                tostring(instance.BrickColor), instance.Transparency)
        elseif instance:IsA("IntValue") or instance:IsA("NumberValue") then
            info = info .. "\nЗначение: " .. tostring(instance.Value)
        end
        infoBox.Text = info

        local children = instance:GetChildren()
        if #children > 0 then
            local expanded = false
            for _, child in ipairs(children) do
                if nodes[child] then
                    expanded = true
                    break
                end
            end
            if expanded then
                local function removeDescendants(obj)
                    for _, child in ipairs(obj:GetChildren()) do
                        if nodes[child] then
                            nodes[child]:Destroy()
                            nodes[child] = nil
                            removeDescendants(child)
                        end
                    end
                end
                removeDescendants(instance)
            else
                local function expand(obj, d)
                    for _, child in ipairs(obj:GetChildren()) do
                        createNode(child, d + 1)
                    end
                end
                expand(instance, depth)
            end
            treeFrame.CanvasSize = UDim2.new(0,0,0,0)
        end
    end)

    return btn
end

for _, service in ipairs(game:GetChildren()) do
    createNode(service, 0)
end

-- ===================== ПИПЕТКА (исправленная) =====================
local currentVoxelColor = nil

local function getVoxelInfo(pos)
    local terrain = workspace:FindFirstChildOfClass("Terrain")
    if not terrain then return nil end
    local mat, occ = terrain:GetMaterialAtPosition(pos)
    if occ > 0 then
        local col = terrain:GetTerrainColorAtPosition(pos)
        if col then
            return {
                r = math.floor(col.R * 255),
                g = math.floor(col.G * 255),
                b = math.floor(col.B * 255),
                material = mat
            }
        end
    end
    return nil
end

uis.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.UserInputType == Enum.UserInputType.MouseButton1 and pipetteActive then
        local mouse = player:GetMouse()
        local cam = workspace.CurrentCamera
        local ray = cam:ScreenPointToRay(mouse.X, mouse.Y)
        local params = RaycastParams.new()
        params.FilterType = Enum.RaycastFilterType.Include
        local result = workspace:Raycast(ray.Origin, ray.Direction * 1000, params)
        local info = ""
        if result then
            local target = result.Instance
            if target:IsA("Terrain") then
                info = "Объект: Terrain\nРодитель: Workspace\nПуть: Workspace.Terrain"
                local voxel = getVoxelInfo(result.Position)
                if voxel then
                    currentVoxelColor = voxel
                    info = info .. string.format("\n\nВОКСЕЛЬ (руда):\nRGB: %d, %d, %d\nМатериал: %s\nПозиция: %s",
                        voxel.r, voxel.g, voxel.b, tostring(voxel.material), tostring(result.Position))
                else
                    info = info .. "\n\nНе удалось получить цвет вокселя"
                end
            else
                info = string.format("Объект: %s (%s)\nРодитель: %s\nПуть: %s",
                    target.Name, target.ClassName,
                    target.Parent and target.Parent.Name or "нет",
                    target:GetFullName())
                if target:IsA("BasePart") then
                    info = info .. string.format("\nПозиция: %s\nРазмер: %s\nЦвет: %s\nПрозрачность: %.2f",
                        tostring(target.Position), tostring(target.Size),
                        tostring(target.BrickColor), target.Transparency)
                elseif target:IsA("IntValue") or target:IsA("NumberValue") then
                    info = info .. "\nЗначение: " .. tostring(target.Value)
                end
            end
        else
            info = "Ничего не найдено"
        end
        infoBox.Text = info
        pipetteActive = false
        pipBtn.Text = "Pipette"
        pipBtn.BackgroundColor3 = Color3.fromRGB(255, 80, 80)
    end
end)

pipBtn.MouseButton1Click:Connect(function()
    pipetteActive = not pipetteActive
    pipBtn.Text = pipetteActive and "ON" or "Pipette"
    pipBtn.BackgroundColor3 = pipetteActive and Color3.fromRGB(80, 255, 80) or Color3.fromRGB(255, 80, 80)
end)

-- ===================== Add to ESP =====================
addEspBtn.MouseButton1Click:Connect(function()
    if currentVoxelColor then
        local found = false
        for _, c in ipairs(collectedColors) do
            if c.r == currentVoxelColor.r and c.g == currentVoxelColor.g and c.b == currentVoxelColor.b then
                found = true
                break
            end
        end
        if not found then
            table.insert(collectedColors, {r = currentVoxelColor.r, g = currentVoxelColor.g, b = currentVoxelColor.b, range = 25})
            infoBox.Text = infoBox.Text .. "\n\nЦвет сохранён! Всего: " .. #collectedColors
        else
            infoBox.Text = infoBox.Text .. "\n\nЭтот цвет уже есть в коллекции."
        end
    else
        infoBox.Text = "Сначала получи цвет руды пипеткой"
    end
end)

-- Вывод всех цветов по F9
uis.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.F9 then
        local str = "Цвета для ESP:\n"
        for i, c in ipairs(collectedColors) do
            str = str .. string.format("{r = %d, g = %d, b = %d, range = 25},\n", c.r, c.g, c.b)
        end
        print(str)
        infoBox.Text = str
    end
end)

print("SwillDex v5 готов. Пипетка теперь точно работает на террейне.")
