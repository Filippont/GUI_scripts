local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local STUDS_PER_METER = 3.57

-- Удаляем старый GUI, если есть
pcall(function()
    player.PlayerGui:FindFirstChild("CombinedDashboardGui"):Destroy()
end)

-- Главный контейнер UI
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "CombinedDashboardGui"
screenGui.ResetOnSpawn = false
screenGui.Parent = player:WaitForChild("PlayerGui")

-- Главная панель
local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 300, 0, 345)
mainFrame.Position = UDim2.new(0, 10, 0, 10)
mainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
mainFrame.BackgroundTransparency = 0.1
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.Draggable = true
mainFrame.Parent = screenGui

local mainCorner = Instance.new("UICorner")
mainCorner.CornerRadius = UDim.new(0, 10)
mainCorner.Parent = mainFrame

-- Кнопка закрытия
local closeButton = Instance.new("TextButton")
closeButton.Size = UDim2.new(0, 28, 0, 28)
closeButton.Position = UDim2.new(1, -35, 0, 5)
closeButton.BackgroundTransparency = 1
closeButton.Text = "❌"
closeButton.TextColor3 = Color3.fromRGB(255, 80, 80)
closeButton.TextSize = 18
closeButton.Font = Enum.Font.GothamBold
closeButton.Parent = mainFrame

closeButton.MouseButton1Click:Connect(function()
    screenGui:Destroy()
end)

-- Заголовок
local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(1, -50, 0, 35)
titleLabel.Position = UDim2.new(0, 15, 0, 5)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "📍 Навигатор & Спидометр"
titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
titleLabel.TextSize = 15
titleLabel.Font = Enum.Font.GothamBold
titleLabel.TextXAlignment = Enum.TextXAlignment.Left
titleLabel.Parent = mainFrame

-- Координаты
local coordsBox = Instance.new("TextBox")
coordsBox.Size = UDim2.new(1, -20, 0, 60)
coordsBox.Position = UDim2.new(0, 10, 0, 45)
coordsBox.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
coordsBox.BackgroundTransparency = 0.3
coordsBox.TextColor3 = Color3.fromRGB(255, 255, 255)
coordsBox.TextSize = 14
coordsBox.Font = Enum.Font.GothamBold
coordsBox.TextXAlignment = Enum.TextXAlignment.Left
coordsBox.ClearTextOnFocus = false
coordsBox.TextEditable = false
coordsBox.Parent = mainFrame

local coordsCorner = Instance.new("UICorner")
coordsCorner.CornerRadius = UDim.new(0, 8)
coordsCorner.Parent = coordsBox

-- Копировать
local copyButton = Instance.new("TextButton")
copyButton.Size = UDim2.new(1, -20, 0, 28)
copyButton.Position = UDim2.new(0, 10, 0, 110)
copyButton.BackgroundColor3 = Color3.fromRGB(50, 50, 55)
copyButton.TextColor3 = Color3.fromRGB(255, 255, 255)
copyButton.TextSize = 13
copyButton.Font = Enum.Font.GothamBold
copyButton.Text = "📋 Копировать координаты"
copyButton.Parent = mainFrame

local copyCorner = Instance.new("UICorner")
copyCorner.CornerRadius = UDim.new(0, 8)
copyCorner.Parent = copyButton

-- Разделитель
local line = Instance.new("Frame")
line.Size = UDim2.new(1, -20, 0, 1)
line.Position = UDim2.new(0, 10, 0, 148)
line.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
line.BorderSizePixel = 0
line.Parent = mainFrame

-- Заголовок скорости
local calcTitle = Instance.new("TextLabel")
calcTitle.Size = UDim2.new(1, -20, 0, 20)
calcTitle.Position = UDim2.new(0, 10, 0, 155)
calcTitle.BackgroundTransparency = 1
calcTitle.Text = "Скорость (Studs/Sec) / Макс: 0.00"
calcTitle.TextColor3 = Color3.fromRGB(200, 200, 200)
calcTitle.TextSize = 13
calcTitle.Font = Enum.Font.GothamBold
calcTitle.TextXAlignment = Enum.TextXAlignment.Left
calcTitle.Parent = mainFrame

local inputField = Instance.new("TextBox")
inputField.Size = UDim2.new(1, -20, 0, 35)
inputField.Position = UDim2.new(0, 10, 0, 180)
inputField.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
inputField.TextColor3 = Color3.fromRGB(255, 255, 255)
inputField.PlaceholderText = "Введите скорость..."
inputField.PlaceholderColor3 = Color3.fromRGB(130, 130, 130)
inputField.Text = ""
inputField.TextSize = 14
inputField.Font = Enum.Font.Gotham
inputField.Parent = mainFrame

local inputCorner = Instance.new("UICorner")
inputCorner.CornerRadius = UDim.new(0, 8)
inputCorner.Parent = inputField

local msLabel = Instance.new("TextLabel")
msLabel.Size = UDim2.new(1, -20, 0, 25)
msLabel.Position = UDim2.new(0, 10, 0, 225)
msLabel.BackgroundTransparency = 1
msLabel.Text = "Скорость в м/с: 0.00 / Макс: 0.00"
msLabel.TextColor3 = Color3.fromRGB(180, 255, 180)
msLabel.TextSize = 14
msLabel.Font = Enum.Font.GothamBold
msLabel.TextXAlignment = Enum.TextXAlignment.Left
msLabel.Parent = mainFrame

local kmhLabel = Instance.new("TextLabel")
kmhLabel.Size = UDim2.new(1, -20, 0, 25)
kmhLabel.Position = UDim2.new(0, 10, 0, 255)
kmhLabel.BackgroundTransparency = 1
kmhLabel.Text = "Скорость в км/ч: 0.00 / Макс: 0.00"
kmhLabel.TextColor3 = Color3.fromRGB(255, 180, 180)
kmhLabel.TextSize = 14
kmhLabel.Font = Enum.Font.GothamBold
kmhLabel.TextXAlignment = Enum.TextXAlignment.Left
kmhLabel.Parent = mainFrame

local resetMaxButton = Instance.new("TextButton")
resetMaxButton.Size = UDim2.new(1, -20, 0, 28)
resetMaxButton.Position = UDim2.new(0, 10, 0, 290)
resetMaxButton.BackgroundColor3 = Color3.fromRGB(80, 40, 40)
resetMaxButton.TextColor3 = Color3.fromRGB(255, 210, 210)
resetMaxButton.TextSize = 13
resetMaxButton.Font = Enum.Font.GothamBold
resetMaxButton.Text = "🔄 Сбросить макс. скорость"
resetMaxButton.Parent = mainFrame

local resetCorner = Instance.new("UICorner")
resetCorner.CornerRadius = UDim.new(0, 8)
resetCorner.Parent = resetMaxButton

-- ===== ЛОГИКА =====
local currentCoordsString = ""
local isUserTyping = false
local maxStudsSpeed = 0

inputField.Focused:Connect(function() isUserTyping = true end)
inputField.FocusLost:Connect(function() isUserTyping = false end)

local function updateSpeedLabels(studs)
    local currentStuds = studs or 0
    if currentStuds < 0 then currentStuds = 0 end

    if currentStuds > maxStudsSpeed then
        maxStudsSpeed = currentStuds
    end

    local ms = currentStuds / STUDS_PER_METER
    local kmh = ms * 3.6

    local maxMs = maxStudsSpeed / STUDS_PER_METER
    local maxKmh = maxMs * 3.6

    calcTitle.Text = string.format("Скорость (Studs/Sec) / Макс: %.2f", maxStudsSpeed)
    msLabel.Text = string.format("Скорость в м/с: %.2f / Макс: %.2f", ms, maxMs)
    kmhLabel.Text = string.format("Скорость в км/ч: %.2f / Макс: %.2f", kmh, maxKmh)
end

RunService.RenderStepped:Connect(function()
    local character = player.Character
    if character and character:FindFirstChild("HumanoidRootPart") then
        local root = character.HumanoidRootPart
        local pos = root.Position
        currentCoordsString = string.format("X: %.2f, Y: %.2f, Z: %.2f", pos.X, pos.Y, pos.Z)
        coordsBox.Text = string.format("  X: %.2f\n  Y: %.2f\n  Z: %.2f", pos.X, pos.Y, pos.Z)

        if not isUserTyping then
            local currentSpeed = root.AssemblyLinearVelocity.Magnitude
            inputField.Text = string.format("%.2f", currentSpeed)
            updateSpeedLabels(currentSpeed)
        end
    else
        coordsBox.Text = "  Загрузка персонажа..."
        if not isUserTyping then
            inputField.Text = "0.00"
            updateSpeedLabels(0)
        end
    end
end)

copyButton.MouseButton1Click:Connect(function()
    if currentCoordsString ~= "" then
        setclipboard(currentCoordsString)
        copyButton.Text = "✅ Скопировано!"
        copyButton.BackgroundColor3 = Color3.fromRGB(0, 130, 0)
        task.wait(0.8)
        copyButton.Text = "📋 Копировать координаты"
        copyButton.BackgroundColor3 = Color3.fromRGB(50, 50, 55)
    end
end)

resetMaxButton.MouseButton1Click:Connect(function()
    maxStudsSpeed = 0
    local currentInputSpeed = tonumber(inputField.Text) or 0
    updateSpeedLabels(currentInputSpeed)
    resetMaxButton.Text = "✅ Сброшено!"
    resetMaxButton.BackgroundColor3 = Color3.fromRGB(0, 130, 0)
    task.wait(0.8)
    resetMaxButton.Text = "🔄 Сбросить макс. скорость"
    resetMaxButton.BackgroundColor3 = Color3.fromRGB(80, 40, 40)
end)

print("✅ GPS & Speed загружен!")
