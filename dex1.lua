--// SWILL DEX v2 (рабочий, без лагов) //
local player = game.Players.LocalPlayer
local uis = game:GetService("UserInputService")
local workspace = game:GetService("Workspace")

-- Удаляем старый Dex
if game.CoreGui:FindFirstChild("SwillDex") then
    game.CoreGui.SwillDex:Destroy()
end

-- Параметры
local COL_EXPAND = Color3.fromRGB(70, 130, 180)   -- цвет раскрытой папки
local COL_NORMAL = Color3.fromRGB(60, 60, 60)     -- обычный узел
local COL_HIGHLIGHT = Color3.fromRGB(255, 200, 0) -- выделенный объект

-- Основной GUI
local gui = Instance.new("ScreenGui")
gui.Name = "SwillDex"
gui.Parent = game.CoreGui
gui.ResetOnSpawn = false

local main = Instance.new("Frame")
main.Size = UDim2.new(0, 620, 0, 440)
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
title.Text = "SWILL DEX"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.Font = Enum.Font.SourceSansBold
title.TextSize = 16
title.Parent = titleBar

-- Кнопка пипетки
local pipBtn = Instance.new("TextButton")
pipBtn.Size = UDim2.new(0, 80, 0, 24)
pipBtn.Position = UDim2.new(1, -85, 0, 4)
pipBtn.BackgroundColor3 = Color3.fromRGB(255, 80, 80)
pipBtn.Text = "Pipette"
pipBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
pipBtn.Font = Enum.Font.SourceSansBold
pipBtn.TextSize = 12
pipBtn.BorderSizePixel = 0
pipBtn.Parent = main
Instance.new("UICorner", pipBtn).CornerRadius = UDim.new(0, 6)

local pipetteActive = false

-- Левая панель (дерево)
local treeFrame = Instance.new("ScrollingFrame")
treeFrame.Size = UDim2.new(0, 270, 1, -40)
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
infoBox.Size = UDim2.new(0, 320, 1, -40)
infoBox.Position = UDim2.new(0, 286, 0, 36)
infoBox.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
infoBox.TextColor3 = Color3.fromRGB(255, 255, 255)
infoBox.Font = Enum.Font.SourceSans
infoBox.TextSize = 12
infoBox.TextYAlignment = Enum.TextYAlignment.Top
infoBox.TextXAlignment = Enum.TextXAlignment.Left
infoBox.MultiLine = true
infoBox.ClearTextOnFocus = false
infoBox.BorderSizePixel = 0
infoBox.Text = "Выбери объект или используй пипетку"
infoBox.Parent = main
Instance.new("UICorner", infoBox).CornerRadius = UDim.new(0, 6)

-- Хранилище узлов: [instance] = {btn, expanded, children = {}}
local nodes = {}

-- Функция: получить или создать узел для instance (если нет, создаём кнопку)
local function getNode(instance, depth)
    if nodes[instance] then return nodes[instance] end
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -10, 0, 22)
    btn.BackgroundColor3 = COL_NORMAL
    btn.Text = string.rep("  ", depth) .. instance.Name .. " [" .. instance.ClassName .. "]"
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Font = Enum.Font.SourceSans
    btn.TextSize = 11
    btn.TextXAlignment = Enum.TextXAlignment.Left
    btn.BorderSizePixel = 0
    btn.AutoButtonColor = false
    btn.Parent = treeFrame
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 4)

    local node = {btn = btn, instance = instance, expanded = false, depth = depth, children = {}}
    nodes[instance] = node

    -- Клик по узлу: раскрыть/свернуть или показать инфо
    btn.MouseButton1Click:Connect(function()
        -- Показываем инфу
        local info = string.format(
            "Имя: %s\nКласс: %s\nРодитель: %s\nПуть: %s",
            instance.Name,
            instance.ClassName,
            instance.Parent and instance.Parent.Name or "нет",
            instance:GetFullName()
        )
        -- Доп. свойства в зависимости от типа
        if instance:IsA("BasePart") then
            info = info .. string.format("\nПозиция: %s\nРазмер: %s\nЦвет: %s\nПрозрачность: %.2f",
                tostring(instance.Position), tostring(instance.Size),
                tostring(instance.BrickColor), instance.Transparency)
        elseif instance:IsA("RemoteEvent") or instance:IsA("RemoteFunction") then
            info = info .. "\nТип: " .. instance.ClassName
        elseif instance:IsA("IntValue") or instance:IsA("NumberValue") or instance:IsA("StringValue") then
            info = info .. "\nЗначение: " .. tostring(instance.Value)
        end
        infoBox.Text = info

        -- Разворачиваем/сворачиваем
        if node.expanded then
            collapseNode(node)
        else
            expandNode(node)
        end
    end)
    return node
end

-- Раскрытие узла (создаём дочерние кнопки)
function expandNode(node)
    node.expanded = true
    node.btn.BackgroundColor3 = COL_EXPAND
    local children = node.instance:GetChildren()
    table.sort(children, function(a, b) return a.Name < b.Name end)
    for _, child in ipairs(children) do
        local childNode = getNode(child, node.depth + 1)
        -- Устанавливаем позицию после родителя
        childNode.btn.LayoutOrder = node.btn.LayoutOrder + #node.children + 1
        table.insert(node.children, childNode)
    end
    updateCanvasSize()
end

-- Сворачивание узла (удаляем дочерние кнопки и чистим записи)
function collapseNode(node)
    node.expanded = false
    node.btn.BackgroundColor3 = COL_NORMAL
    for _, childNode in ipairs(node.children) do
        if childNode.expanded then collapseNode(childNode) end
        childNode.btn:Destroy()
        nodes[childNode.instance] = nil
    end
    node.children = {}
    updateCanvasSize()
end

-- Обновление размера канваса
function updateCanvasSize()
    local count = 0
    for _, _ in pairs(nodes) do count = count + 1 end
    treeFrame.CanvasSize = UDim2.new(0, 0, 0, count * 24)
end

-- Переключение пипетки
pipBtn.MouseButton1Click:Connect(function()
    pipetteActive = not pipetteActive
    pipBtn.Text = pipetteActive and "ON" or "Pipette"
    pipBtn.BackgroundColor3 = pipetteActive and Color3.fromRGB(80, 255, 80) or Color3.fromRGB(255, 80, 80)
end)

-- Обработка пипетки (клик левой кнопкой в мире)
uis.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.UserInputType == Enum.UserInputType.MouseButton1 and pipetteActive then
        local mouse = player:GetMouse()
        local target = mouse.Target
        if target then
            -- Выключаем пипетку
            pipetteActive = false
            pipBtn.Text = "Pipette"
            pipBtn.BackgroundColor3 = Color3.fromRGB(255, 80, 80)

            -- Раскрываем все узлы от game до target
            local path = {}
            local obj = target
            while obj do
                table.insert(path, 1, obj)
                obj = obj.Parent
            end
            -- Для каждого элемента пути создаём/раскрываем узел
            for _, inst in ipairs(path) do
                local node = getNode(inst, nodeDepth(inst)) -- глубина будет вычислена позже, но это не критично
                if not node.expanded and #inst:GetChildren() > 0 then
                    expandNode(node)
                end
            end
            updateCanvasSize()

            -- Выделяем кнопку цели
            if nodes[target] then
                nodes[target].btn.BackgroundColor3 = COL_HIGHLIGHT
                -- Прокручиваем к цели
                treeFrame.CanvasPosition = Vector2.new(0, math.max(0, nodes[target].btn.AbsolutePosition.Y - treeFrame.AbsolutePosition.Y - 100))
                -- Выводим инфу
                local info = string.format(
                    "Имя: %s\nКласс: %s\nРодитель: %s\nПуть: %s",
                    target.Name,
                    target.ClassName,
                    target.Parent and target.Parent.Name or "нет",
                    target:GetFullName()
                )
                if target:IsA("BasePart") then
                    info = info .. string.format("\nПозиция: %s\nРазмер: %s\nЦвет: %s\nПрозрачность: %.2f",
                        tostring(target.Position), tostring(target.Size),
                        tostring(target.BrickColor), target.Transparency)
                end
                infoBox.Text = info
            end
        end
    end
end)

-- Определение глубины узла (вспомогательная)
function nodeDepth(instance)
    local depth = 0
    local current = instance
    while current.Parent do
        depth = depth + 1
        current = current.Parent
    end
    return depth
end

-- Первоначальная загрузка: корневые сервисы
for _, service in ipairs(game:GetChildren()) do
    getNode(service, 0)
end
updateCanvasSize()

print("SwillDex v2 готов. Нажми Pipette, затем кликни по объекту в мире.")
