-- ===== ФЛИНГ СЕБЯ (GUI) — ИСПРАВЛЕННАЯ ВЕРСИЯ =====
local Players = game:GetService("Players")
local player = Players.LocalPlayer
local UserInputService = game:GetService("UserInputService")

-- Удаляем старый GUI
pcall(function()
    if player and player.PlayerGui then
        local old = player.PlayerGui:FindFirstChild("FlingSelfGUI")
        if old then old:Destroy() end
    end
end)

-- Переменные
local power = 100
local minPower = 10
local maxPower = 1000
local step = 100
local isFlying = false

-- Создаём GUI
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "FlingSelfGUI"
screenGui.Parent = player:WaitForChild("PlayerGui")
screenGui.ResetOnSpawn = false

-- Главное окно
local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 220, 0, 160)
frame.Position = UDim2.new(0.5, -110, 0.6, 0)
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

-- Кнопка "-"
local minusBtn = Instance.new("TextButton")
minusBtn.Size = UDim2.new(0, 40, 0, 30)
minusBtn.Position = UDim2.new(0, 15, 0, 0.45)
minusBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
minusBtn.TextColor3 = Color3.new(1, 1, 1)
minusBtn.TextSize = 18
minusBtn.Font = Enum.Font.GothamBold
minusBtn.Text = "−"
minusBtn.Parent = frame

local minusCorner = Instance.new("UICorner")
minusCorner.CornerRadius = UDim.new(0, 8)
minusCorner.Parent = minusBtn

-- Текст силы
local powerLabel = Instance.new("TextLabel")
powerLabel.Size = UDim2.new(0.5, 0, 0.15, 0)
powerLabel.Position = UDim2.new(0.25, 0, 0.45, 0)
powerLabel.BackgroundTransparency = 1
powerLabel.Text = "Сила: " .. power
powerLabel.TextColor3 = Color3.fromRGB(200, 200, 255)
powerLabel.TextSize = 14
powerLabel.Font = Enum.Font.GothamBold
powerLabel.TextXAlignment = Enum.TextXAlignment.Center
powerLabel.Parent = frame

-- Кнопка "+"
local plusBtn = Instance.new("TextButton")
plusBtn.Size = UDim2.new(0, 40, 0, 30)
plusBtn.Position = UDim2.new(1, -55, 0, 0.45)
plusBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
plusBtn.TextColor3 = Color3.new(1, 1, 1)
plusBtn.TextSize = 18
plusBtn.Font = Enum.Font.GothamBold
plusBtn.Text = "+"
plusBtn.Parent = frame

local plusCorner = Instance.new("UICorner")
plusCorner.CornerRadius = UDim.new(0, 8)
plusCorner.Parent = plusBtn

-- Кнопка "ФЛИНГ"
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

-- ===== ФУНКЦИИ =====
local function updatePower()
    power = math.clamp(power, minPower, maxPower)
    powerLabel.Text = "Сила: " .. power
end

local function flingSelf()
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
    root.AssemblyLinearVelocity = dir * power

    statusLabel.Text = "🟢 ЛЕТИМ!"
    statusLabel.TextColor3 = Color3.fromRGB(100, 255, 100)

    print("✅ Флингнут СЕБЯ с силой " .. power)
    print("📌 Нажми ПРОБЕЛ, чтобы встать")
end

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

-- ===== СОБЫТИЯ =====
minusBtn.MouseButton1Click:Connect(function()
    power = power - step
    updatePower()
end)

plusBtn.MouseButton1Click:Connect(function()
    power = power + step
    updatePower()
end)

flingBtn.MouseButton1Click:Connect(function()
    flingSelf()
end)

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.Space then
        standUp()
    end
end)

-- Обновляем при старте
updatePower()

print("✅ Fling загружен!")
print("📌 Кнопки + и - меняют силу с шагом 100 (от 10 до 1000)")
print("📌 После флинга нажми ПРОБЕЛ, чтобы встать")
