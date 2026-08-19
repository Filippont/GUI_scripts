-- ===== ИНЖЕНЕРНЫЙ КАЛЬКУЛЯТОР ДЛЯ XENO (ИСПРАВЛЕННЫЙ) =====
local Players = game:GetService("Players")
local player = Players.LocalPlayer
local UserInputService = game:GetService("UserInputService")

-- Удаляем старый калькулятор, если есть
pcall(function()
    player.PlayerGui:FindFirstChild("CalculatorGUI"):Destroy()
end)

-- Создаём GUI
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "CalculatorGUI"
screenGui.Parent = player:WaitForChild("PlayerGui")
screenGui.ResetOnSpawn = false

-- Главное окно
local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 320, 0, 420)
frame.Position = UDim2.new(0.5, -160, 0.25, 0)
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
stroke.Color = Color3.fromRGB(100, 200, 255)
stroke.Thickness = 2
stroke.Parent = frame

-- Заголовок
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0.06, 0)
title.Position = UDim2.new(0, 0, 0, 0)
title.BackgroundTransparency = 1
title.Text = "🧮 ИНЖЕНЕРНЫЙ КАЛЬКУЛЯТОР"
title.TextColor3 = Color3.fromRGB(200, 200, 255)
title.TextSize = 13
title.Font = Enum.Font.GothamBold
title.TextXAlignment = Enum.TextXAlignment.Center
title.Parent = frame

-- Кнопка закрыть
local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 28, 0, 28)
closeBtn.Position = UDim2.new(1, -33, 0, 2)
closeBtn.Text = "❌"
closeBtn.TextColor3 = Color3.fromRGB(255, 80, 80)
closeBtn.TextSize = 16
closeBtn.Font = Enum.Font.GothamBold
closeBtn.BackgroundTransparency = 1
closeBtn.Parent = frame

closeBtn.MouseButton1Click:Connect(function()
    screenGui:Destroy()
end)

-- Дисплей
local display = Instance.new("TextBox")
display.Size = UDim2.new(0.9, 0, 0.12, 0)
display.Position = UDim2.new(0.05, 0, 0.08, 0)
display.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
display.TextColor3 = Color3.new(1, 1, 1)
display.TextSize = 18
display.Font = Enum.Font.GothamBold
display.TextXAlignment = Enum.TextXAlignment.Right
display.Text = "0"
display.ClearTextOnFocus = false
display.Parent = frame

local displayCorner = Instance.new("UICorner")
displayCorner.CornerRadius = UDim.new(0, 6)
displayCorner.Parent = display

-- Поле истории
local historyLabel = Instance.new("TextLabel")
historyLabel.Size = UDim2.new(0.9, 0, 0.05, 0)
historyLabel.Position = UDim2.new(0.05, 0, 0.21, 0)
historyLabel.BackgroundTransparency = 1
historyLabel.Text = ""
historyLabel.TextColor3 = Color3.fromRGB(150, 150, 170)
historyLabel.TextSize = 12
historyLabel.Font = Enum.Font.Gotham
historyLabel.TextXAlignment = Enum.TextXAlignment.Right
historyLabel.Parent = frame

-- ===== ЛОГИКА КАЛЬКУЛЯТОРА =====
local currentInput = ""
local result = 0
local operation = nil
local isNewInput = true
local memory = 0
local history = ""

local function updateDisplay()
    if currentInput == "" then
        display.Text = "0"
    else
        display.Text = currentInput
    end
    historyLabel.Text = history
end

local function calculate(num1, op, num2)
    if op == "+" then return num1 + num2
    elseif op == "-" then return num1 - num2
    elseif op == "*" then return num1 * num2
    elseif op == "/" then
        if num2 == 0 then return nil end
        return num1 / num2
    elseif op == "^" then return num1 ^ num2
    elseif op == "%" then return num1 % num2
    elseif op == "√" then return math.sqrt(num1)
    elseif op == "x²" then return num1 * num1
    elseif op == "1/x" then
        if num1 == 0 then return nil end
        return 1 / num1
    elseif op == "ln" then return math.log(num1)
    elseif op == "log" then return math.log10(num1)
    elseif op == "sin" then return math.sin(math.rad(num1))
    elseif op == "cos" then return math.cos(math.rad(num1))
    elseif op == "tan" then return math.tan(math.rad(num1))
    elseif op == "asin" then return math.deg(math.asin(math.clamp(num1, -1, 1)))
    elseif op == "acos" then return math.deg(math.acos(math.clamp(num1, -1, 1)))
    elseif op == "atan" then return math.deg(math.atan(num1))
    elseif op == "sinh" then return math.sinh(num1)
    elseif op == "cosh" then return math.cosh(num1)
    elseif op == "tanh" then return math.tanh(num1)
    elseif op == "asinh" then return math.asinh(num1)
    elseif op == "acosh" then return math.acosh(num1)
    elseif op == "atanh" then return math.atanh(num1)
    elseif op == "!" then
        local fact = 1
        for i = 2, math.floor(num1) do fact = fact * i end
        return fact
    end
    return nil
end

local function pressButton(value)
    if value == "C" then
        currentInput = ""
        result = 0
        operation = nil
        isNewInput = true
        history = ""
    elseif value == "CE" then
        currentInput = ""
        isNewInput = true
    elseif value == "⌫" then
        currentInput = currentInput:sub(1, -2)
        if currentInput == "" then currentInput = "0" end
    elseif value == "=" then
        if operation and currentInput ~= "" then
            local num = tonumber(currentInput)
            if num then
                local newResult = calculate(result, operation, num)
                if newResult == nil then
                    display.Text = "Ошибка"
                    return
                end
                history = tostring(result) .. " " .. operation .. " " .. tostring(num) .. " = " .. tostring(newResult)
                currentInput = tostring(newResult)
                result = newResult
                operation = nil
                isNewInput = true
            end
        end
    elseif value == "+" or value == "-" or value == "*" or value == "/" or value == "^" or value == "%" then
        if currentInput ~= "" then
            if operation then
                local num = tonumber(currentInput)
                if num then
                    local newResult = calculate(result, operation, num)
                    if newResult == nil then
                        display.Text = "Ошибка"
                        return
                    end
                    currentInput = tostring(newResult)
                    result = newResult
                end
            else
                result = tonumber(currentInput) or 0
            end
            operation = value
            isNewInput = true
            history = tostring(result) .. " " .. operation
        end
    elseif value == "√" or value == "x²" or value == "1/x" or value == "ln" or value == "log" or value == "!" then
        if currentInput ~= "" then
            local num = tonumber(currentInput)
            if num then
                local newResult = calculate(num, value, 0)
                if newResult == nil then
                    display.Text = "Ошибка"
                    return
                end
                history = value .. "(" .. tostring(num) .. ") = " .. tostring(newResult)
                currentInput = tostring(newResult)
                operation = nil
                isNewInput = true
            end
        end
    elseif value == "sin" or value == "cos" or value == "tan" or value == "asin" or value == "acos" or value == "atan" or value == "sinh" or value == "cosh" or value == "tanh" or value == "asinh" or value == "acosh" or value == "atanh" then
        if currentInput ~= "" then
            local num = tonumber(currentInput)
            if num then
                local newResult = calculate(num, value, 0)
                if newResult == nil then
                    display.Text = "Ошибка"
                    return
                end
                history = value .. "(" .. tostring(num) .. ") = " .. tostring(newResult)
                currentInput = tostring(newResult)
                operation = nil
                isNewInput = true
            end
        end
    elseif value == "π" then
        currentInput = tostring(math.pi)
        isNewInput = true
    elseif value == "e" then
        currentInput = tostring(math.exp(1))
        isNewInput = true
    elseif value == "MS" then
        memory = tonumber(currentInput) or 0
    elseif value == "MR" then
        currentInput = tostring(memory)
        isNewInput = true
    elseif value == "MC" then
        memory = 0
    elseif value == "M+" then
        memory = memory + (tonumber(currentInput) or 0)
    elseif value == "M-" then
        memory = memory - (tonumber(currentInput) or 0)
    elseif value == "±" then
        if currentInput ~= "" and currentInput ~= "0" then
            if currentInput:sub(1, 1) == "-" then
                currentInput = currentInput:sub(2)
            else
                currentInput = "-" .. currentInput
            end
        end
    elseif value == "EXP" then
        if currentInput ~= "" then
            currentInput = currentInput .. "e"
            isNewInput = false
        end
    else
        if isNewInput then
            currentInput = value
            isNewInput = false
        else
            if #currentInput < 20 then
                currentInput = currentInput .. value
            end
        end
    end
    updateDisplay()
end

-- ===== СОЗДАНИЕ КНОПОК =====
local function createButton(text, x, y, w, h)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(w or 0.2, 0, h or 0.08, 0)
    btn.Position = UDim2.new(x, 0, y, 0)
    btn.Text = text
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.TextSize = 13
    btn.Font = Enum.Font.GothamBold
    btn.BackgroundColor3 = Color3.fromRGB(50, 50, 55)
    btn.BorderSizePixel = 0
    btn.Parent = frame

    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 4)
    btnCorner.Parent = btn

    btn.MouseEnter:Connect(function()
        btn.BackgroundColor3 = Color3.fromRGB(70, 70, 80)
    end)
    btn.MouseLeave:Connect(function()
        btn.BackgroundColor3 = Color3.fromRGB(50, 50, 55)
    end)

    btn.MouseButton1Click:Connect(function()
        pressButton(text)
    end)
    return btn
end

-- Первая строка (научные функции)
createButton("sin", 0.025, 0.28, 0.14, 0.07)
createButton("cos", 0.175, 0.28, 0.14, 0.07)
createButton("tan", 0.325, 0.28, 0.14, 0.07)
createButton("ln", 0.475, 0.28, 0.14, 0.07)
createButton("log", 0.625, 0.28, 0.14, 0.07)
createButton("!", 0.775, 0.28, 0.14, 0.07)

-- Вторая строка
createButton("asin", 0.025, 0.365, 0.14, 0.07)
createButton("acos", 0.175, 0.365, 0.14, 0.07)
createButton("atan", 0.325, 0.365, 0.14, 0.07)
createButton("sinh", 0.475, 0.365, 0.14, 0.07)
createButton("cosh", 0.625, 0.365, 0.14, 0.07)
createButton("tanh", 0.775, 0.365, 0.14, 0.07)

-- Третья строка
createButton("x²", 0.025, 0.45, 0.14, 0.07)
createButton("√", 0.175, 0.45, 0.14, 0.07)
createButton("1/x", 0.325, 0.45, 0.14, 0.07)
createButton("π", 0.475, 0.45, 0.14, 0.07)
createButton("e", 0.625, 0.45, 0.14, 0.07)
createButton("EXP", 0.775, 0.45, 0.14, 0.07)

-- Четвёртая строка (память)
createButton("MC", 0.025, 0.535, 0.14, 0.07)
createButton("MR", 0.175, 0.535, 0.14, 0.07)
createButton("MS", 0.325, 0.535, 0.14, 0.07)
createButton("M+", 0.475, 0.535, 0.14, 0.07)
createButton("M-", 0.625, 0.535, 0.14, 0.07)
createButton("±", 0.775, 0.535, 0.14, 0.07)

-- Пятая строка
createButton("C", 0.025, 0.62, 0.14, 0.08)
createButton("CE", 0.175, 0.62, 0.14, 0.08)
createButton("⌫", 0.325, 0.62, 0.14, 0.08)
createButton("/", 0.475, 0.62, 0.14, 0.08)
createButton("^", 0.625, 0.62, 0.14, 0.08)
createButton("%", 0.775, 0.62, 0.14, 0.08)

-- Шестая строка
createButton("7", 0.025, 0.71, 0.14, 0.08)
createButton("8", 0.175, 0.71, 0.14, 0.08)
createButton("9", 0.325, 0.71, 0.14, 0.08)
createButton("*", 0.475, 0.71, 0.14, 0.08)
createButton("-", 0.625, 0.71, 0.14, 0.08)
createButton("+", 0.775, 0.71, 0.14, 0.08)

-- Седьмая строка (исправлена)
createButton("4", 0.025, 0.80, 0.14, 0.08)
createButton("5", 0.175, 0.80, 0.14, 0.08)
createButton("6", 0.325, 0.80, 0.14, 0.08)
createButton("=", 0.475, 0.80, 0.30, 0.08)

-- Восьмая строка (исправлена)
createButton("0", 0.025, 0.89, 0.20, 0.08)
createButton(".", 0.235, 0.89, 0.14, 0.08)
createButton("=", 0.475, 0.89, 0.30, 0.08)

-- ===== ГОРЯЧИЕ КЛАВИШИ =====
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if not screenGui.Parent then return end

    local key = input.KeyCode.Name
    if key == "NumPad0" or key == "Zero" then pressButton("0")
    elseif key == "NumPad1" or key == "One" then pressButton("1")
    elseif key == "NumPad2" or key == "Two" then pressButton("2")
    elseif key == "NumPad3" or key == "Three" then pressButton("3")
    elseif key == "NumPad4" or key == "Four" then pressButton("4")
    elseif key == "NumPad5" or key == "Five" then pressButton("5")
    elseif key == "NumPad6" or key == "Six" then pressButton("6")
    elseif key == "NumPad7" or key == "Seven" then pressButton("7")
    elseif key == "NumPad8" or key == "Eight" then pressButton("8")
    elseif key == "NumPad9" or key == "Nine" then pressButton("9")
    elseif key == "NumPadPlus" then pressButton("+")
    elseif key == "NumPadMinus" then pressButton("-")
    elseif key == "NumPadMultiply" then pressButton("*")
    elseif key == "NumPadDivide" then pressButton("/")
    elseif key == "NumPadEnter" then pressButton("=")
    elseif key == "Delete" or key == "Backspace" then pressButton("C")
    end
end)

print("✅ Инженерный калькулятор загружен!")
print("📌 Доступны: sin, cos, tan, ln, log, √, x², 1/x, π, e, EXP, память (MC/MR/MS/M+/M-)")
