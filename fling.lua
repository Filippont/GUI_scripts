-- ===== ФЛИНГ СЕБЯ (GUI) ДЛЯ XENO — ИСПРАВЛЕННЫЙ =====
local Players = game:GetService("Players")
local player = Players.LocalPlayer
local UserInputService = game:GetService("UserInputService")

-- Удаляем старый GUI, если есть
pcall(function()
    player.PlayerGui:FindFirstChild("FlingSelfGUI"):Destroy()
end)

-- Переменные состояния
local hum = nil
local oldPlatform = false

-- Создаём GUI
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "FlingSelfGUI"
screenGui.Parent = player:WaitForChild("PlayerGui")
screenGui.ResetOnSpawn = false

-- Главное окно
local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 200, 0, 140)
frame.Position = UDim2.new(0.5, -100, 0.6, 0)
frame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
frame.BackgroundTransparency = 0
frame.BorderSizePixel = 0
frame.Active = true
frame.Draggable = true
frame.Parent = screenGui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 12)
corner.Parent = frame

local stroke = Instance.new("UIStroke")
stroke.Color = Color3.fromRGB(255, 100, 100)
stroke.Thickness = 2
stroke.Parent = frame

-- Кнопка закрыть
local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 30, 0, 30)
closeBtn.Position = UDim2.new(1, -38, 0, 5)
closeBtn.Text = "❌"
closeBtn.TextColor3 = Color3.fromRGB(255, 80, 80)
closeBtn.TextSize = 18
closeBtn.Font = Enum.Font.GothamBold
closeBtn.BackgroundTransparency = 1
closeBtn.Parent = frame

closeBtn.MouseButton1Click:Connect(function()
    screenGui:Destroy()
end)

-- Заголовок
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0.2, 0)
title.Position = UDim2.new(0, 0, 0, 0)
title.BackgroundTransparency = 1
title.Text = "💥 ФЛИНГ СЕБЯ"
title.TextColor3 = Color3.fromRGB(255, 200, 200)
title.TextSize = 16
title.Font = Enum.Font.GothamBold
title.TextXAlignment = Enum.TextXAlignment.Center
title.Parent = frame

-- Статус
local statusLabel = Instance.new("TextLabel")
statusLabel.Size = UDim2.new(1, 0, 0.15, 0)
statusLabel.Position = UDim2.new(0, 0, 0.25, 0)
statusLabel.BackgroundTransparency = 1
statusLabel.Text = "🔴 НАЖМИ ФЛИНГ"
statusLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
statusLabel.TextSize = 12
statusLabel.Font = Enum.Font.GothamBold
statusLabel.TextXAlignment = Enum.TextXAlignment.Center
statusLabel.Parent = frame

-- Ползунок силы
local powerLabel = Instance.new("TextLabel")
powerLabel.Size = UDim2.new(0.8, 0, 0.15, 0)
powerLabel.Position = UDim2.new(0.1, 0, 0.42, 0)
powerLabel.BackgroundTransparency = 1
powerLabel.Text = "Сила: 100"
powerLabel.TextColor3 = Color3.fromRGB(200, 200, 255)
powerLabel.TextSize = 13
powerLabel.Font = Enum.Font.Gotham
powerLabel.TextXAlignment = Enum.TextXAlignment.Center
powerLabel.Parent = frame

local powerSlider = Instance.new("Frame")
powerSlider.Size = UDim2.new(0.8, 0, 0.06, 0)
powerSlider.Position = UDim2.new(0.1, 0, 0.60, 0)
powerSlider.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
powerSlider.BorderSizePixel = 0
powerSlider.Parent = frame

local sliderCorner = Instance.new("UICorner")
sliderCorner.CornerRadius = UDim.new(0, 4)
sliderCorner.Parent = powerSlider

local sliderFill = Instance.new("Frame")
sliderFill.Size = UDim2.new(0.5, 0, 1, 0)
sliderFill.BackgroundColor3 = Color3.fromRGB(255, 100, 100)
sliderFill.BorderSizePixel = 0
sliderFill.Parent = powerSlider

local sliderCornerFill = Instance.new("UICorner")
sliderCornerFill.CornerRadius = UDim.new(0, 4)
sliderCornerFill.Parent = sliderFill

-- Переменная силы
local power = 100

-- Функция обновления силы
local function updatePower(value)
    power = math.clamp(value, 10, 500)
    sliderFill.Size = UDim2.new((power - 10) / 490, 0, 1, 0)
    powerLabel.Text = "Сила: " .. math.floor(power)
end

-- Обработка клика по ползунку
powerSlider.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        local x = (input.Position.X - powerSlider.AbsolutePosition.X) / powerSlider.AbsoluteSize.X
        updatePower(10 + x * 490)
    end
end)

powerSlider.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement and input.UserInputState == Enum.UserInputState.Change then
        local x = (input.Position.X - powerSlider.AbsolutePosition.X) / powerSlider.AbsoluteSize.X
        updatePower(10 + x * 490)
    end
end)

-- Кнопка ФЛИНГ
local flingBtn = Instance.new("TextButton")
flingBtn.Size = UDim2.new(0.8, 0, 0.18, 0)
flingBtn.Position = UDim2.new(0.1, 0, 0.70, 0)
flingBtn.Text = "💥 ФЛИНГ"
flingBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
flingBtn.TextColor3 = Color3.new(1, 1, 1)
flingBtn.Font = Enum.Font.GothamBold
flingBtn.TextSize = 14
flingBtn.Parent = frame

local flingCorner = Instance.new("UICorner")
flingCorner.CornerRadius = UDim.new(0, 8)
flingCorner.Parent = flingBtn

flingBtn.MouseEnter:Connect(function()
    flingBtn.BackgroundColor3 = Color3.fromRGB(230, 60, 60)
end)

flingBtn.MouseLeave:Connect(function()
    flingBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
end)

-- ===== ФУНКЦИЯ ВСТАТЬ =====
local function standUp()
    local char = player.Character
    if not char then return end

    local humanoid = char:FindFirstChild("Humanoid")
    if not humanoid then return end

    humanoid.PlatformStand = false
    humanoid.AutoRotate = true

    statusLabel.Text = "🔴 НАЖМИ ФЛИНГ"
    statusLabel.TextColor3 = Color3.fromRGB(255, 100, 100)

    print("✅ Встал по пробелу!")
end

-- ===== ОБРАБОТЧИК ПРОБЕЛА =====
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.Space then
        standUp()
    end
end)

-- ===== ФУНКЦИЯ ФЛИНГА =====
local function flingSelf(powerValue)
    local char = player.Character
    if not char then
        warn("❌ Персонаж не найден!")
        return
    end

    local root = char:FindFirstChild("HumanoidRootPart")
    local humanoid = char:FindFirstChild("Humanoid")
    if not root or not humanoid then
        warn("❌ Root или Humanoid не найдены!")
        return
    end

    humanoid.PlatformStand = true

    local cam = workspace.CurrentCamera
    local dir = cam.CFrame.LookVector * 0.5 + Vector3.new(0, 0.8, 0)
    root.AssemblyLinearVelocity = dir * powerValue

    statusLabel.Text = "🟢 ЛЕТИМ!"
    statusLabel.TextColor3 = Color3.fromRGB(100, 255, 100)

    print("✅ Флингнут СЕБЯ с силой " .. powerValue)
    print("📌 Нажми ПРОБЕЛ, чтобы встать")
end

flingBtn.MouseButton1Click:Connect(function()
    flingSelf(power)
end)

print("✅ Fling загружен!")
