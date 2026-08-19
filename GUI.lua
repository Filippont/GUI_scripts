-- ===== GUI МЕНЮ ДЛЯ ЗАПУСКА СКРИПТОВ =====
local Players = game:GetService("Players")
local player = Players.LocalPlayer

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "ScriptsMenu"
screenGui.Parent = player:WaitForChild("PlayerGui")
screenGui.ResetOnSpawn = false

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 530, 0, 80)
frame.Position = UDim2.new(0.5, -265, 0.9, 0)
frame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
frame.BackgroundTransparency = 0
frame.BorderSizePixel = 0
frame.Active = true
frame.Draggable = true
frame.Parent = screenGui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 12)
corner.Parent = frame

-- Функция создания кнопки
local function createButton(text, xPos, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 110, 0, 50)
    btn.Position = UDim2.new(0, xPos, 0.5, -25)
    btn.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.TextSize = 12
    btn.Font = Enum.Font.GothamBold
    btn.Text = text
    btn.BorderSizePixel = 0
    btn.Parent = frame

    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 8)
    btnCorner.Parent = btn

    btn.MouseEnter:Connect(function()
        btn.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
    end)

    btn.MouseLeave:Connect(function()
        btn.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
    end)

    btn.MouseButton1Click:Connect(callback)
    return btn
end

-- Кнопка 1: Аудиоплеер
createButton("🎵 Аудиоплеер", 20, function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/Filippont/GUI_scripts/master/AudioPlayer.lua"))()
end)

-- Кнопка 2: GPS & Speed
createButton("📍 GPS & Speed", 145, function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/Filippont/GUI_scripts/master/GPSSpeed.lua"))()
end)

-- Кнопка 3: Fling
createButton("💥 Fling", 270, function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/Filippont/GUI_scripts/master/fling.lua"))()
end)

-- Кнопка 4: Калькулятор
createButton("🧮 Калькулятор", 395, function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/Filippont/GUI_scripts/master/calc.lua"))()
end)

-- Кнопка Закрыть (❌)
local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 30, 0, 30)
closeBtn.Position = UDim2.new(1, -38, 0, 5)
closeBtn.Text = "❌"
closeBtn.TextColor3 = Color3.fromRGB(255, 80, 80)
closeBtn.TextSize = 18
closeBtn.Font = Enum.Font.GothamBold
closeBtn.BackgroundTransparency = 1
closeBtn.Parent = frame

closeBtn.MouseEnter:Connect(function()
    closeBtn.TextColor3 = Color3.fromRGB(255, 120, 120)
end)

closeBtn.MouseLeave:Connect(function()
    closeBtn.TextColor3 = Color3.fromRGB(255, 80, 80)
end)

closeBtn.MouseButton1Click:Connect(function()
    screenGui:Destroy()
end)

print("✅ GUI меню загружено!")
