-- // SWILL CUSTOM DEX + PIPETTE //
local player = game.Players.LocalPlayer
local uis = game:GetService("UserInputService")
local workspace = game:GetService("Workspace")

-- Очищаем старый GUI
if game.CoreGui:FindFirstChild("SwillDex") then
    game.CoreGui.SwillDex:Destroy()
end

local gui = Instance.new("ScreenGui")
gui.Name = "SwillDex"
gui.Parent = game.CoreGui
gui.ResetOnSpawn = false

-- Основная рамка
local main = Instance.new("Frame")
main.Size = UDim2.new(0, 600, 0, 400)
main.Position = UDim2.new(0, 50, 0, 50)
main.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
main.BorderSizePixel = 0
main.Active = true
main.Draggable = true
main.Parent = gui
Instance.new("UICorner", main).CornerRadius = UDim.new(0, 8)

-- Заголовок
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 25)
title.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
title.Text = "SWILL DEX"
title.TextColor3 = Color3.white
title.Font = Enum.Font.SourceSansBold
title.TextSize = 14
title.BorderSizePixel = 0
title.Parent = main
Instance.new("UICorner", title).CornerRadius = UDim.new(0, 8)

-- Кнопка пипетки
local pipBtn = Instance.new("TextButton")
pipBtn.Size = UDim2.new(0, 80, 0, 22)
pipBtn.Position = UDim2.new(1, -85, 0, 2)
pipBtn.BackgroundColor3 = Color3.fromRGB(255, 80, 80)
pipBtn.Text = "Pipette"
pipBtn.TextColor3 = Color3.white
pipBtn.Font = Enum.Font.SourceSansBold
pipBtn.TextSize = 12
pipBtn.BorderSizePixel = 0
pipBtn.Parent = main
Instance.new("UICorner", pipBtn).CornerRadius = UDim.new(0, 4)

local pipetteActive = false
pipBtn.MouseButton1Click:Connect(function()
    pipetteActive = not pipetteActive
    pipBtn.Text = pipetteActive and "ON" or "Pipette"
    pipBtn.BackgroundColor3 = pipetteActive and Color3.fromRGB(80, 255, 80) or Color3.fromRGB(255, 80, 80)
end)

-- Панель дерева (левая)
local treeFrame = Instance.new("ScrollingFrame")
treeFrame.Size = UDim2.new(0, 250, 1, -30)
treeFrame.Position = UDim2.new(0, 5, 0, 28)
treeFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
treeFrame.BorderSizePixel = 0
treeFrame.ScrollBarThickness = 5
treeFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
treeFrame.Parent = main
Instance.new("UICorner", treeFrame).CornerRadius = UDim.new(0, 6)

local treeLayout = Instance.new("UIListLayout")
treeLayout.Parent = treeFrame
treeLayout.SortOrder = Enum.SortOrder.Name
treeLayout.Padding = UDim.new(0, 2)

-- Панель информации (правая)
local infoPanel = Instance.new("TextBox")
infoPanel.Size = UDim2.new(0, 330, 1, -30)
infoPanel.Position = UDim2.new(0, 260, 0, 28)
infoPanel.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
infoPanel.TextColor3 = Color3.white
infoPanel.Font = Enum.Font.SourceSans
infoPanel.TextSize = 11
infoPanel.Text = "Select an object"
infoPanel.TextYAlignment = Enum.TextYAlignment.Top
infoPanel.TextXAlignment = Enum.TextXAlignment.Left
infoPanel.MultiLine = true
infoPanel.ClearTextOnFocus = false
infoPanel.BorderSizePixel = 0
infoPanel.Parent = main
Instance.new("UICorner", infoPanel).CornerRadius = UDim.new(0, 6)

-- Хранилище узлов
local treeNodes = {} -- [Instance] = {button, expanded, children}

-- Функция создания кнопки-узла
local function createNode(parentFrame, instance, depth)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -10 - depth*15, 0, 20)
    btn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    btn.Text = string.rep("  ", depth) .. instance.Name .. " (" .. instance.ClassName .. ")"
    btn.TextColor3 = Color3.white
    btn.Font = Enum.Font.SourceSans
    btn.TextSize = 11
    btn.TextXAlignment = Enum.TextXAlignment.Left
    btn.BorderSizePixel = 0
    btn.AutoButtonColor = false
    btn.Parent = parentFrame

    -- Сохраняем данные
    treeNodes[instance] = {
        button = btn,
        expanded = false,
        children = {},
        depth = depth
    }

    -- Клик по узлу: раскрыть/свернуть или показать инфу
    btn.MouseButton1Click:Connect(function()
        local data = treeNodes[instance]
        if not data then return end

        -- Показываем информацию об объекте в правой панели
        local info = string.format(
            "Name: %s\nClass: %s\nParent: %s\nFull Path: %s\n\nProperties:\n",
            instance.Name,
            instance.ClassName,
            instance.Parent and instance.Parent.Name or "nil",
            instance:GetFullName()
        )
        -- Добавляем некоторые свойства в зависимости от типа
        if instance:IsA("BasePart") then
            info = info .. string.format("Position: %s\nSize: %s\nAnchored: %s\nCanCollide: %s\nTransparency: %.2f\n",
                tostring(instance.Position), tostring(instance.Size), tostring(instance.Anchored), tostring(instance.CanCollide), instance.Transparency)
        elseif instance:IsA("RemoteEvent") then
            info = info .. "RemoteEvent (fire to server)\n"
        elseif instance:IsA("IntValue") or instance:IsA("NumberValue") then
            info = info .. "Value: " .. tostring(instance.Value) .. "\n"
        end
        infoPanel.Text = info

        -- Раскрываем/сворачиваем узел
        if not data.expanded then
            data.expanded = true
            -- Загружаем детей
            local children = instance:GetChildren()
            for _, child in ipairs(children) do
                if not treeNodes[child] then
                    createNode(treeFrame, child, depth + 1)
                end
            end
            -- Пересчитываем размер Canvas
            treeFrame.CanvasSize = UDim2.new(0, 0, 0, #treeFrame:GetChildren() * 22)
        else
            data.expanded = false
            -- Удаляем дочерние узлы (рекурсивно)
            local function removeChildren(obj)
                if treeNodes[obj] then
                    for _, child in ipairs(treeNodes[obj].children) do
                        removeChildren(child)
                    end
                    treeNodes[obj].children = {}
                    if treeNodes[obj].button then
                        treeNodes[obj].button:Destroy()
                        treeNodes[obj] = nil
                    end
                end
            end
            -- Удаляем только прямых потомков, сохранённых в children (но проще удалить все, у кого родитель instance)
            for inst, data in pairs(treeNodes) do
                if data.depth > depth and data.button then
                    -- проверяем, что родитель в цепочке instance
                    local parent = inst.Parent
                    while parent do
                        if parent == instance then
                            data.button:Destroy()
                            treeNodes[inst] = nil
                            break
                        end
                        parent = parent.Parent
                    end
                end
            end
            treeFrame.CanvasSize = UDim2.new(0, 0, 0, #treeFrame:GetChildren() * 22)
        end
    end)
end

-- Строим корневые узлы (game)
for _, service in ipairs(game:GetChildren()) do
    createNode(treeFrame, service, 0)
end
-- Также добавим workspace отдельно?
-- workspace уже есть в game.

-- Функция пипетки
uis.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.UserInputType == Enum.UserInputType.MouseButton1 and pipetteActive then
        local mouse = player:GetMouse()
        local target = mouse.Target
        if target then
            -- Ищем узел в дереве, если его ещё нет, можно создать путь
            -- Пока просто покажем информацию и выделим в дереве?
            -- Для выделения нужно пройти вверх и раскрыть все родительские узлы
            local current = target
            local path = {}
            while current do
                table.insert(path, 1, current)
                current = current.Parent
            end
            -- Раскрываем все узлы по пути
            for _, inst in ipairs(path) do
                if treeNodes[inst] and not treeNodes[inst].expanded then
                    treeNodes[inst].expanded = true
                    local children = inst:GetChildren()
                    for _, child in ipairs(children) do
                        if not treeNodes[child] then
                            createNode(treeFrame, child, treeNodes[inst].depth + 1)
                        end
                    end
                end
            end
            treeFrame.CanvasSize = UDim2.new(0, 0, 0, #treeFrame:GetChildren() * 22)
            -- Прокручиваем к выбранному объекту (приблизительно)
            if treeNodes[target] and treeNodes[target].button then
                local btn = treeNodes[target].button
                -- высота кнопки
                local y = btn.Position.Y.Offset
                treeFrame.CanvasPosition = Vector2.new(0, math.max(0, y - 100))
            end
            -- Покажем инфу
            local info = string.format(
                "Name: %s\nClass: %s\nParent: %s\nFull Path: %s",
                target.Name,
                target.ClassName,
                target.Parent and target.Parent.Name or "nil",
                target:GetFullName()
            )
            infoPanel.Text = info
            pipetteActive = false
            pipBtn.Text = "Pipette"
            pipBtn.BackgroundColor3 = Color3.fromRGB(255, 80, 80)
        end
    end
end)

print("SwillDex loaded. Click Pipette button, then click on object in game.")
