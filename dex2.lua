--// SWILL DEX v3 – Terrain Voxel Pipette + ESP Color Collector //
local player = game.Players.LocalPlayer
local uis = game:GetService("UserInputService")
local workspace = game:GetService("Workspace")
local runService = game:GetService("RunService")

-- Удаляем старое
if game.CoreGui:FindFirstChild("SwillDex") then
    game.CoreGui.SwillDex:Destroy()
end

-- Хранилище найденных цветов (для ESP)
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

-- Заголовок
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
title.Text = "SWILL DEX (Voxel Pipette)"
title.TextColor3 = Color3.white
title.Font = Enum.Font.SourceSansBold
title.TextSize = 15
title.Parent = titleBar

-- Кнопка пипетки
local pipBtn = Instance.new("TextButton")
pipBtn.Size = UDim2.new(0, 80, 0, 24)
pipBtn.Position = UDim2.new(1, -85, 0, 4)
pipBtn.BackgroundColor3 = Color3.fromRGB(255, 80, 80)
pipBtn.Text = "Pipette"
pipBtn.TextColor3 = Color3.white
pipBtn.Font = Enum.Font.SourceSansBold
pipBtn.TextSize = 12
pipBtn.BorderSizePixel = 0
pipBtn.Parent = main
Instance.new("UICorner", pipBtn).CornerRadius = UDim.new(0, 6)

local pipetteActive = false

-- Кнопка Add to ESP
local addEspBtn = Instance.new("TextButton")
addEspBtn.Size = UDim2.new(0, 100, 0, 24)
addEspBtn.Position = UDim2.new(0, 10, 0, 430)
addEspBtn.BackgroundColor3 = Color3.fromRGB(100, 180, 255)
addEspBtn.Text = "Add to ESP"
addEspBtn.TextColor3 = Color3.white
addEspBtn.Font = Enum.Font.SourceSansBold
addEspBtn.TextSize = 12
addEspBtn.BorderSizePixel = 0
addEspBtn.Parent = main
Instance.new("UICorner", addEspBtn).CornerRadius = UDim.new(0, 6)

-- Левая панель (дерево объектов) – как раньше, но чуть меньше
local treeFrame = Instance.new("ScrollingFrame")
treeFrame.Size = UDim2.new(0, 270, 1, -80)
treeFrame.Position = UDim2.new(0, 8, 0, 36)
treeFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
treeFrame.BorderSizePixel = 0
treeFrame.ScrollBarThickness = 5
treeFrame.ScrollBarImageColor3 = Color3.fromRGB(120, 120, 120)
treeFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
treeFrame.Parent = main
Instance.new("UICorner", treeFrame).CornerRadius = UDim.new(0, 6)

local uiList = Instance.new("UIListLayout")
uiList.Parent = treeFrame
uiList.SortOrder = Enum.SortOrder.Name
uiList.Padding = UDim.new(0, 2)

-- Правая панель (инфо)
local infoBox = Instance.new("TextBox")
infoBox.Size = UDim2.new(0, 320, 1, -80)
infoBox.Position = UDim2.new(0, 286, 0, 36)
infoBox.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
infoBox.TextColor3 = Color3.white
infoBox.Font = Enum.Font.SourceSans
infoBox.TextSize = 12
infoBox.TextYAlignment = Enum.TextYAlignment.Top
infoBox.TextXAlignment = Enum.TextXAlignment.Left
infoBox.MultiLine = true
infoBox.ClearTextOnFocus = false
infoBox.BorderSizePixel = 0
infoBox.Text = "Наведи пипетку на руду в горе"
infoBox.Parent = main
Instance.new("UICorner", infoBox).CornerRadius = UDim.new(0, 6)

-- ===================== ЛОГИКА ДЕРЕВА (без изменений) =====================
local nodes = {}
local function getNode(instance, depth)
    if nodes[instance] then return nodes[instance] end
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -10, 0, 22)
    btn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    btn.Text = string.rep("  ", depth) .. instance.Name .. " [" .. instance.ClassName .. "]"
    btn.TextColor3 = Color3.white
    btn.Font = Enum.Font.SourceSans
    btn.TextSize = 11
    btn.TextXAlignment = Enum.TextXAlignment.Left
    btn.BorderSizePixel = 0
    btn.AutoButtonColor = false
    btn.Parent = treeFrame
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 4)

    local node = {btn = btn, instance = instance, expanded = false, depth = depth, children = {}}
    nodes[instance] = node

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

        if node.expanded then collapseNode(node) else expandNode(node) end
    end)
    return node
end

function expandNode(node)
    node.expanded = true
    node.btn.BackgroundColor3 = Color3.fromRGB(70, 130, 180)
    local children = node.instance:GetChildren()
    table.sort(children, function(a,b) return a.Name < b.Name end)
    for _, child in ipairs(children) do
        local childNode = getNode(child, node.depth + 1)
        childNode.btn.LayoutOrder = node.btn.LayoutOrder + #node.children + 1
        table.insert(node.children, childNode)
    end
    treeFrame.CanvasSize = UDim2.new(0, 0, 0, #nodes * 24)
end

function collapseNode(node)
    node.expanded = false
    node.btn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    for _, childNode in ipairs(node.children) do
        if childNode.expanded then collapseNode(childNode) end
        childNode.btn:Destroy()
        nodes[childNode.instance] = nil
    end
    node.children = {}
    treeFrame.CanvasSize = UDim2.new(0, 0, 0, #nodes * 24)
end

-- Загружаем корневые сервисы
for _, service in ipairs(game:GetChildren()) do
    getNode(service, 0)
end
treeFrame.CanvasSize = UDim2.new(0, 0, 0, #nodes * 24)

-- ===================== ПИПЕТКА С ВОКСЕЛЯМИ =====================
local function getTerrainVoxelInfo(hitPosition)
    local terrain = workspace:FindFirstChildOfClass("Terrain")
    if not terrain then return nil end
    local mat, occ = terrain:GetMaterialAtPosition(hitPosition)
    if occ > 0 then
        local col = terrain:GetTerrainColorAtPosition(hitPosition)
        if col then
            local r = math.floor(col.R * 255)
            local g = math.floor(col.G * 255)
            local b = math.floor(col.B * 255)
            return {r = r, g = g, b = b, material = mat}
        end
    end
    return nil
end

local currentVoxelColor = nil  -- {r,g,b}

uis.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.UserInputType == Enum.UserInputType.MouseButton1 and pipetteActive then
        local mouse = player:GetMouse()
        local target = mouse.Target
        local info = ""
        if target then
            info = string.format("Объект: %s (%s)\nРодитель: %s\nПуть: %s",
                target.Name, target.ClassName,
                target.Parent and target.Parent.Name or "нет",
                target:GetFullName())
            -- Если цель – Terrain, получаем информацию о вокселе
            if target:IsA("Terrain") then
                local cam = workspace.CurrentCamera
                local ray = cam:ScreenPointToRay(mouse.X, mouse.Y)
                local params = RaycastParams.new()
                params.FilterType = Enum.RaycastFilterType.Include
                params.FilterDescendantsInstances = {workspace:FindFirstChildOfClass("Terrain")}
                local result = workspace:Raycast(ray.Origin, ray.Direction * 1000, params)
                if result and result.Instance:IsA("Terrain") then
                    local voxel = getTerrainVoxelInfo(result.Position)
                    if voxel then
                        currentVoxelColor = voxel
                        info = info .. string.format("\n\nВОКСЕЛЬ (руда):\nЦвет RGB: %d, %d, %d\nМатериал: %s\nПозиция: %s",
                            voxel.r, voxel.g, voxel.b, tostring(voxel.material), tostring(result.Position))
                    end
                end
            end
        else
            info = "Не выбран объект"
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

-- ===================== Добавление цвета в ESP коллекцию =====================
addEspBtn.MouseButton1Click:Connect(function()
    if currentVoxelColor then
        -- Проверим, нет ли уже такого цвета
        local already = false
        for _, col in ipairs(collectedColors) do
            if col.r == currentVoxelColor.r and col.g == currentVoxelColor.g and col.b == currentVoxelColor.b then
                already = true
                break
            end
        end
        if not already then
            table.insert(collectedColors, {r = currentVoxelColor.r, g = currentVoxelColor.g, b = currentVoxelColor.b, range = 25})
            infoBox.Text = infoBox.Text .. "\n\nЦвет добавлен в ESP! Всего цветов: " .. #collectedColors
        else
            infoBox.Text = infoBox.Text .. "\n\nЭтот цвет уже есть в коллекции."
        end
    else
        infoBox.Text = "Сначала возьми пипеткой цвет руды."
    end
end)

-- Вывод коллекции (для копирования в ESP скрипт) по нажатию F9
uis.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.F9 then
        local str = "Скопируй эти цвета в targetColors ESP скрипта:\n"
        for i, col in ipairs(collectedColors) do
            str = str .. string.format("{r = %d, g = %d, b = %d, range = 25},\n", col.r, col.g, col.b)
        end
        print(str)
        infoBox.Text = str
    end
end)

print("SwillDex v3 готов. Pipette показывает цвет вокселя, Add to ESP сохраняет, F9 выводит список.")
