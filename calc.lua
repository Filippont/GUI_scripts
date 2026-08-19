-- ===== ИНЖЕНЕРНЫЙ КАЛЬКУЛЯТОР ДЛЯ XENO — ИСПРАВЛЕННАЯ ВЕРСИЯ =====
-- Окно #141414, один оператор "=", безопасная математика,
-- исправленная клавиатура, перетаскивание и кнопка закрытия.

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- =========================================================
-- УДАЛЕНИЕ СТАРОЙ ВЕРСИИ
-- =========================================================

local oldGui = playerGui:FindFirstChild("CalculatorGUI")
if oldGui then
    oldGui:Destroy()
end

-- =========================================================
-- ЦВЕТА
-- =========================================================

local COLORS = {
    window = Color3.fromRGB(20, 20, 20),       -- #141414
    display = Color3.fromRGB(38, 38, 42),
    button = Color3.fromRGB(48, 48, 53),
    buttonHover = Color3.fromRGB(68, 68, 75),
    number = Color3.fromRGB(55, 55, 60),
    accent = Color3.fromRGB(100, 200, 255),
    accentHover = Color3.fromRGB(120, 215, 255),
    white = Color3.fromRGB(245, 245, 245),
    muted = Color3.fromRGB(155, 155, 170),
    error = Color3.fromRGB(255, 85, 85),
    success = Color3.fromRGB(100, 225, 120),
}

-- =========================================================
-- GUI
-- =========================================================

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "CalculatorGUI"
screenGui.ResetOnSpawn = false
screenGui.IgnoreGuiInset = true
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.Parent = playerGui

local frame = Instance.new("Frame")
frame.Name = "MainFrame"
frame.Size = UDim2.fromOffset(320, 470)
frame.Position = UDim2.new(0.5, -160, 0.5, -235)
frame.BackgroundColor3 = COLORS.window
frame.BackgroundTransparency = 0
frame.BorderSizePixel = 0
frame.Active = true
frame.Parent = screenGui

local frameCorner = Instance.new("UICorner")
frameCorner.CornerRadius = UDim.new(0, 14)
frameCorner.Parent = frame

local frameStroke = Instance.new("UIStroke")
frameStroke.Color = COLORS.accent
frameStroke.Thickness = 2
frameStroke.Parent = frame

-- =========================================================
-- ЗАКРЫТИЕ: рисуем X линиями, а не Unicode "❌",
-- чтобы крестик не ломался на шрифтах Roblox.
-- =========================================================

local function round(object, radius)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, radius or 6)
    c.Parent = object
    return c
end

local closeBtn = Instance.new("TextButton")
closeBtn.Name = "CloseBtn"
closeBtn.Size = UDim2.fromOffset(32, 32)
closeBtn.Position = UDim2.new(1, -40, 0, 7)
closeBtn.BackgroundTransparency = 1
closeBtn.Text = ""
closeBtn.AutoButtonColor = false
closeBtn.BorderSizePixel = 0
closeBtn.ZIndex = 10
closeBtn.Parent = frame

local closeLine1 = Instance.new("Frame")
closeLine1.Name = "CloseLine1"
closeLine1.Size = UDim2.fromOffset(3, 16)
closeLine1.AnchorPoint = Vector2.new(0.5, 0.5)
closeLine1.Position = UDim2.fromScale(0.5, 0.5)
closeLine1.Rotation = 45
closeLine1.BackgroundColor3 = COLORS.error
closeLine1.BorderSizePixel = 0
closeLine1.ZIndex = 11
closeLine1.Parent = closeBtn
round(closeLine1, 2)

local closeLine2 = Instance.new("Frame")
closeLine2.Name = "CloseLine2"
closeLine2.Size = UDim2.fromOffset(3, 16)
closeLine2.AnchorPoint = Vector2.new(0.5, 0.5)
closeLine2.Position = UDim2.fromScale(0.5, 0.5)
closeLine2.Rotation = -45
closeLine2.BackgroundColor3 = COLORS.error
closeLine2.BorderSizePixel = 0
closeLine2.ZIndex = 11
closeLine2.Parent = closeBtn
round(closeLine2, 2)

closeBtn.MouseEnter:Connect(function()
    closeLine1.BackgroundColor3 = Color3.fromRGB(255, 125, 125)
    closeLine2.BackgroundColor3 = Color3.fromRGB(255, 125, 125)
end)

closeBtn.MouseLeave:Connect(function()
    closeLine1.BackgroundColor3 = COLORS.error
    closeLine2.BackgroundColor3 = COLORS.error
end)

closeBtn.MouseButton1Click:Connect(function()
    if screenGui.Parent then
        screenGui:Destroy()
    end
end)

-- =========================================================
-- ЗАГОЛОВОК
-- =========================================================

local title = Instance.new("TextLabel")
title.Name = "Title"
title.Size = UDim2.new(1, -70, 0, 32)
title.Position = UDim2.fromOffset(20, 7)
title.BackgroundTransparency = 1
title.Text = "🧮 ИНЖЕНЕРНЫЙ КАЛЬКУЛЯТОР"
title.TextColor3 = Color3.fromRGB(200, 210, 255)
title.TextSize = 13
title.Font = Enum.Font.GothamBold
title.TextXAlignment = Enum.TextXAlignment.Center
title.Parent = frame

-- =========================================================
-- ДИСПЛЕЙ
-- =========================================================

local display = Instance.new("TextLabel")
display.Name = "Display"
display.Size = UDim2.new(1, -32, 0, 58)
display.Position = UDim2.fromOffset(16, 45)
display.BackgroundColor3 = COLORS.display
display.BorderSizePixel = 0
display.Text = "0"
display.TextColor3 = COLORS.white
display.TextSize = 20
display.Font = Enum.Font.GothamBold
display.TextXAlignment = Enum.TextXAlignment.Right
display.TextYAlignment = Enum.TextYAlignment.Center
display.TextTruncate = Enum.TextTruncate.AtEnd
display.Parent = frame
round(display, 8)

local historyLabel = Instance.new("TextLabel")
historyLabel.Name = "History"
historyLabel.Size = UDim2.new(1, -40, 0, 24)
historyLabel.Position = UDim2.fromOffset(20, 103)
historyLabel.BackgroundTransparency = 1
historyLabel.Text = ""
historyLabel.TextColor3 = COLORS.muted
historyLabel.TextSize = 11
historyLabel.Font = Enum.Font.Gotham
historyLabel.TextXAlignment = Enum.TextXAlignment.Right
historyLabel.TextTruncate = Enum.TextTruncate.AtEnd
historyLabel.Parent = frame

-- =========================================================
-- СОСТОЯНИЕ
-- =========================================================

local currentInput = "0"
local result = nil
local operation = nil
local isNewInput = true
local memory = 0
local history = ""
local errorState = false
local lastOperation = nil
local lastOperand = nil

local MAX_DIGITS = 20
local MAX_FACTORIAL = 170

-- =========================================================
-- ФОРМАТИРОВАНИЕ
-- =========================================================

local function isFiniteNumber(value)
    return type(value) == "number" and value == value and value < math.huge and value > -math.huge
end

local function formatNumber(value)
    if not isFiniteNumber(value) then
        return "Ошибка"
    end

    if value == 0 then
        return "0"
    end

    local text = string.format("%.12g", value)
    if text == "-0" then
        return "0"
    end
    return text
end

local function updateDisplay()
    display.Text = errorState and "Ошибка" or (currentInput == "" and "0" or currentInput)
    historyLabel.Text = history
end

local function setError(message)
    errorState = true
    currentInput = "0"
    result = nil
    operation = nil
    isNewInput = true
    history = message or "Ошибка вычисления"
    updateDisplay()
end

local function clearError()
    if errorState then
        errorState = false
        currentInput = "0"
        result = nil
        operation = nil
        isNewInput = true
        history = ""
    end
end

-- =========================================================
-- МАТЕМАТИКА
-- =========================================================

local function safeCalculate(num1, op, num2)
    if not isFiniteNumber(num1) or (num2 ~= nil and not isFiniteNumber(num2)) then
        return nil, "Недопустимое число"
    end

    if op == "+" then
        return num1 + num2
    elseif op == "-" then
        return num1 - num2
    elseif op == "*" then
        return num1 * num2
    elseif op == "/" then
        if num2 == 0 then
            return nil, "Деление на ноль"
        end
        return num1 / num2
    elseif op == "^" then
        local value = num1 ^ num2
        if not isFiniteNumber(value) then
            return nil, "Слишком большое значение"
        end
        return value
    elseif op == "%" then
        if num2 == 0 then
            return nil, "Остаток от деления на ноль"
        end
        return num1 % num2
    elseif op == "√" then
        if num1 < 0 then
            return nil, "√: число должно быть ≥ 0"
        end
        return math.sqrt(num1)
    elseif op == "x²" then
        local value = num1 * num1
        if not isFiniteNumber(value) then
            return nil, "Слишком большое значение"
        end
        return value
    elseif op == "1/x" then
        if num1 == 0 then
            return nil, "Деление на ноль"
        end
        return 1 / num1
    elseif op == "ln" then
        if num1 <= 0 then
            return nil, "ln: число должно быть > 0"
        end
        return math.log(num1)
    elseif op == "log" then
        if num1 <= 0 then
            return nil, "log: число должно быть > 0"
        end
        return math.log(num1) / math.log(10)
    elseif op == "sin" then
        return math.sin(math.rad(num1))
    elseif op == "cos" then
        return math.cos(math.rad(num1))
    elseif op == "tan" then
        local radians = math.rad(num1)
        if math.abs(math.cos(radians)) < 1e-12 then
            return nil, "tan: не определён"
        end
        return math.tan(radians)
    elseif op == "asin" then
        if num1 < -1 or num1 > 1 then
            return nil, "asin: диапазон [-1; 1]"
        end
        return math.deg(math.asin(num1))
    elseif op == "acos" then
        if num1 < -1 or num1 > 1 then
            return nil, "acos: диапазон [-1; 1]"
        end
        return math.deg(math.acos(num1))
    elseif op == "atan" then
        return math.deg(math.atan(num1))
    elseif op == "sinh" then
        local value = (math.exp(num1) - math.exp(-num1)) / 2
        return isFiniteNumber(value) and value or nil
    elseif op == "cosh" then
        local value = (math.exp(num1) + math.exp(-num1)) / 2
        return isFiniteNumber(value) and value or nil
    elseif op == "tanh" then
        local positive = math.exp(num1)
        local negative = math.exp(-num1)
        local denominator = positive + negative
        if denominator == 0 or not isFiniteNumber(denominator) then
            return num1 >= 0 and 1 or -1
        end
        return (positive - negative) / denominator
    elseif op == "asinh" then
        local value = math.log(num1 + math.sqrt(num1 * num1 + 1))
        return isFiniteNumber(value) and value or nil
    elseif op == "acosh" then
        if num1 < 1 then
            return nil, "acosh: число должно быть ≥ 1"
        end
        local value = math.log(num1 + math.sqrt(num1 * num1 - 1))
        return isFiniteNumber(value) and value or nil
    elseif op == "atanh" then
        if num1 <= -1 or num1 >= 1 then
            return nil, "atanh: диапазон (-1; 1)"
        end
        return 0.5 * math.log((1 + num1) / (1 - num1))
    elseif op == "!" then
        if num1 < 0 or num1 % 1 ~= 0 then
            return nil, "Факториал: нужно целое число ≥ 0"
        end
        if num1 > MAX_FACTORIAL then
            return nil, "Факториал слишком большой"
        end

        local fact = 1
        for i = 2, num1 do
            fact *= i
        end
        return fact
    end

    return nil, "Неизвестная операция"
end

-- =========================================================
-- ВВОД
-- =========================================================

local function canAppendDigit(text, digit)
    if #text >= MAX_DIGITS then
        return false
    end

    if text == "0" then
        return digit == "0" and false or true
    end

    if text == "-0" then
        return digit ~= "0"
    end

    return true
end

local function appendDigit(digit)
    clearError()

    if isNewInput then
        currentInput = digit
        isNewInput = false
        return
    end

    if currentInput == "0" then
        if digit ~= "0" then
            currentInput = digit
        end
        return
    end

    if currentInput == "-0" then
        if digit ~= "0" then
            currentInput = "-" .. digit
        end
        return
    end

    if #currentInput < MAX_DIGITS then
        currentInput ..= digit
    end
end

local function appendDecimal()
    clearError()

    if isNewInput then
        currentInput = "0."
        isNewInput = false
        return
    end

    if not currentInput:find("%.") and not currentInput:find("[eE]") then
        currentInput ..= "."
    end
end

local function appendExponent()
    clearError()

    if isNewInput then
        currentInput = "1e"
        isNewInput = false
        return
    end

    if not currentInput:find("[eE]") then
        currentInput ..= "e"
    end
end

local function parseCurrentInput()
    local value = tonumber(currentInput)
    if value and isFiniteNumber(value) then
        return value
    end
    return nil
end

-- =========================================================
-- ОПЕРАЦИИ
-- =========================================================

local function calculatePending(newOperation)
    local number = parseCurrentInput()
    if not number then
        setError("Некорректное число")
        return false
    end

    if operation then
        local value, errorMessage = safeCalculate(result, operation, number)
        if value == nil then
            setError(errorMessage)
            return false
        end
        result = value
        currentInput = formatNumber(value)
    else
        result = number
    end

    operation = newOperation
    isNewInput = true
    history = formatNumber(result) .. " " .. newOperation
    updateDisplay()
    return true
end

local function pressUnary(op)
    local number = parseCurrentInput()

    if not number then
        setError("Некорректное число")
        return
    end

    local value, errorMessage = safeCalculate(number, op, nil)
    if value == nil then
        setError(errorMessage)
        return
    end

    history = op .. "(" .. formatNumber(number) .. ") = " .. formatNumber(value)
    currentInput = formatNumber(value)
    result = value
    isNewInput = true
    updateDisplay()
end

local function pressEquals()
    if errorState then
        return
    end

    local number = parseCurrentInput()

    if operation then
        if not number then
            setError("Некорректное число")
            return
        end

        local value, errorMessage = safeCalculate(result, operation, number)
        if value == nil then
            setError(errorMessage)
            return
        end

        lastOperation = operation
        lastOperand = number
        history = formatNumber(result) .. " " .. operation .. " " .. formatNumber(number) .. " = " .. formatNumber(value)
        currentInput = formatNumber(value)
        result = value
        operation = nil
        isNewInput = true
        updateDisplay()
        return
    end

    -- Повторное "=" повторяет последнюю операцию.
    if lastOperation and lastOperand ~= nil and number ~= nil then
        local value, errorMessage = safeCalculate(number, lastOperation, lastOperand)
        if value == nil then
            setError(errorMessage)
            return
        end

        history = formatNumber(number) .. " " .. lastOperation .. " " .. formatNumber(lastOperand) .. " = " .. formatNumber(value)
        currentInput = formatNumber(value)
        result = value
        isNewInput = true
        updateDisplay()
    end
end

local function pressButton(value)
    if value == "C" then
        currentInput = "0"
        result = nil
        operation = nil
        isNewInput = true
        history = ""
        errorState = false
        lastOperation = nil
        lastOperand = nil
        updateDisplay()
        return
    end

    if value == "CE" then
        currentInput = "0"
        isNewInput = true
        errorState = false
        updateDisplay()
        return
    end

    if errorState then
        if value:match("^%d$") or value == "." or value == "π" or value == "e" then
            clearError()
        else
            return
        end
    end

    if value:match("^%d$") then
        appendDigit(value)
    elseif value == "." then
        appendDecimal()
    elseif value == "EXP" then
        appendExponent()
    elseif value == "⌫" then
        if isNewInput then
            currentInput = "0"
        else
            currentInput = currentInput:sub(1, -2)
            if currentInput == "" or currentInput == "-" then
                currentInput = "0"
            end
        end
    elseif value == "=" then
        pressEquals()
        return
    elseif value == "+" or value == "-" or value == "*" or value == "/" or value == "^" or value == "%" then
        calculatePending(value)
        return
    elseif value == "√" or value == "x²" or value == "1/x" or value == "ln" or value == "log" or value == "!"
        or value == "sin" or value == "cos" or value == "tan"
        or value == "asin" or value == "acos" or value == "atan"
        or value == "sinh" or value == "cosh" or value == "tanh"
        or value == "asinh" or value == "acosh" or value == "atanh" then
        pressUnary(value)
        return
    elseif value == "π" then
        currentInput = formatNumber(math.pi)
        isNewInput = true
    elseif value == "e" then
        currentInput = formatNumber(math.exp(1))
        isNewInput = true
    elseif value == "±" then
        if currentInput ~= "0" then
            if currentInput:sub(1, 1) == "-" then
                currentInput = currentInput:sub(2)
            else
                currentInput = "-" .. currentInput
            end
        end
    elseif value == "MS" then
        local number = parseCurrentInput()
        if number then
            memory = number
        end
    elseif value == "MR" then
        currentInput = formatNumber(memory)
        isNewInput = true
    elseif value == "MC" then
        memory = 0
    elseif value == "M+" then
        local number = parseCurrentInput()
        if number then
            memory += number
            isNewInput = true
        end
    elseif value == "M-" then
        local number = parseCurrentInput()
        if number then
            memory -= number
            isNewInput = true
        end
    else
        return
    end

    updateDisplay()
end

-- =========================================================
-- ПЕРЕТАСКИВАНИЕ
-- Делаем отдельную область заголовка, чтобы клики по кнопкам
-- никогда не запускали drag.
-- =========================================================

local dragArea = Instance.new("TextButton")
dragArea.Name = "DragArea"
dragArea.Size = UDim2.new(1, -55, 0, 40)
dragArea.Position = UDim2.fromOffset(0, 0)
dragArea.BackgroundTransparency = 1
dragArea.Text = ""
dragArea.AutoButtonColor = false
dragArea.BorderSizePixel = 0
dragArea.ZIndex = 5
dragArea.Parent = frame

local dragging = false
local dragStart = nil
local startPosition = nil

dragArea.InputBegan:Connect(function(input)
    if input.UserInputType ~= Enum.UserInputType.MouseButton1
        and input.UserInputType ~= Enum.UserInputType.Touch then
        return
    end

    dragging = true
    dragStart = input.Position
    startPosition = frame.Position
end)

dragArea.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
        dragging = false
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if not dragging then
        return
    end

    if input.UserInputType ~= Enum.UserInputType.MouseMovement
        and input.UserInputType ~= Enum.UserInputType.Touch then
        return
    end

    local delta = input.Position - dragStart
    frame.Position = UDim2.new(
        startPosition.X.Scale,
        startPosition.X.Offset + delta.X,
        startPosition.Y.Scale,
        startPosition.Y.Offset + delta.Y
    )
end)

-- =========================================================
-- КНОПКИ
-- =========================================================

local function createButton(text, x, y, w, h, customColor)
    local btn = Instance.new("TextButton")
    btn.Name = "Button_" .. text:gsub("%W", "_")
    btn.Size = UDim2.new(w or 0.14, 0, h or 0.065, 0)
    btn.Position = UDim2.new(x, 0, y, 0)
    btn.Text = text
    btn.TextColor3 = COLORS.white
    btn.TextSize = 12
    btn.Font = Enum.Font.GothamBold
    btn.BackgroundColor3 = customColor or COLORS.button
    btn.BorderSizePixel = 0
    btn.AutoButtonColor = false
    btn.Parent = frame
    btn.ZIndex = 2
    round(btn, 5)

    local normalColor = btn.BackgroundColor3
    local hoverColor = customColor and COLORS.accentHover or COLORS.buttonHover

    btn.MouseEnter:Connect(function()
        btn.BackgroundColor3 = hoverColor
    end)

    btn.MouseLeave:Connect(function()
        btn.BackgroundColor3 = normalColor
    end)

    btn.Activated:Connect(function()
        pressButton(text)
    end)

    return btn
end

-- На калькуляторе 6 кнопок в каждой строке для компактной раскладки.
local rows = {
    { {"sin", 0.025}, {"cos", 0.175}, {"tan", 0.325}, {"ln", 0.475}, {"log", 0.625}, {"!", 0.775} },
    { {"asin", 0.025}, {"acos", 0.175}, {"atan", 0.325}, {"sinh", 0.475}, {"cosh", 0.625}, {"tanh", 0.775} },
    { {"x²", 0.025}, {"√", 0.175}, {"1/x", 0.325}, {"π", 0.475}, {"e", 0.625}, {"EXP", 0.775} },
    { {"MC", 0.025}, {"MR", 0.175}, {"MS", 0.325}, {"M+", 0.475}, {"M-", 0.625}, {"±", 0.775} },
}

local yPositions = {0.285, 0.355, 0.425, 0.495}
for rowIndex, row in ipairs(rows) do
    for _, item in ipairs(row) do
        createButton(item[1], item[2], yPositions[rowIndex], 0.14, 0.06)
    end
end

-- Нижний блок.
createButton("C", 0.025, 0.575, 0.14, 0.07, Color3.fromRGB(85, 52, 52))
createButton("CE", 0.175, 0.575, 0.14, 0.07)
createButton("DEL", 0.325, 0.575, 0.14, 0.07)
createButton("/", 0.475, 0.575, 0.14, 0.07)
createButton("^", 0.625, 0.575, 0.14, 0.07)
createButton("%", 0.775, 0.575, 0.14, 0.07)

createButton("7", 0.025, 0.655, 0.14, 0.07, COLORS.number)
createButton("8", 0.175, 0.655, 0.14, 0.07, COLORS.number)
createButton("9", 0.325, 0.655, 0.14, 0.07, COLORS.number)
createButton("*", 0.475, 0.655, 0.14, 0.07)
createButton("-", 0.625, 0.655, 0.14, 0.07)
createButton("+", 0.775, 0.655, 0.14, 0.07)

createButton("4", 0.025, 0.735, 0.14, 0.07, COLORS.number)
createButton("5", 0.175, 0.735, 0.14, 0.07, COLORS.number)
createButton("6", 0.325, 0.735, 0.14, 0.07, COLORS.number)
createButton("1", 0.475, 0.735, 0.14, 0.07, COLORS.number)
createButton("2", 0.625, 0.735, 0.14, 0.07, COLORS.number)
createButton("3", 0.775, 0.735, 0.14, 0.07, COLORS.number)

createButton("0", 0.025, 0.815, 0.30, 0.07, COLORS.number)
createButton(".", 0.325, 0.815, 0.14, 0.07)
createButton("=", 0.625, 0.815, 0.29, 0.07, Color3.fromRGB(60, 95, 115))

-- =========================================================
-- КЛАВИАТУРА
-- =========================================================

local keyMap = {
    [Enum.KeyCode.Zero] = "0",
    [Enum.KeyCode.One] = "1",
    [Enum.KeyCode.Two] = "2",
    [Enum.KeyCode.Three] = "3",
    [Enum.KeyCode.Four] = "4",
    [Enum.KeyCode.Five] = "5",
    [Enum.KeyCode.Six] = "6",
    [Enum.KeyCode.Seven] = "7",
    [Enum.KeyCode.Eight] = "8",
    [Enum.KeyCode.Nine] = "9",
    [Enum.KeyCode.KeypadZero] = "0",
    [Enum.KeyCode.KeypadOne] = "1",
    [Enum.KeyCode.KeypadTwo] = "2",
    [Enum.KeyCode.KeypadThree] = "3",
    [Enum.KeyCode.KeypadFour] = "4",
    [Enum.KeyCode.KeypadFive] = "5",
    [Enum.KeyCode.KeypadSix] = "6",
    [Enum.KeyCode.KeypadSeven] = "7",
    [Enum.KeyCode.KeypadEight] = "8",
    [Enum.KeyCode.KeypadNine] = "9",
    [Enum.KeyCode.Backspace] = "⌫",
    [Enum.KeyCode.Delete] = "C",
    [Enum.KeyCode.Return] = "=",
    [Enum.KeyCode.KeypadEnter] = "=",
    [Enum.KeyCode.KeypadPlus] = "+",
    [Enum.KeyCode.KeypadMinus] = "-",
    [Enum.KeyCode.KeypadMultiply] = "*",
    [Enum.KeyCode.KeypadDivide] = "/",
}

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed or not screenGui.Parent then
        return
    end

    local value = keyMap[input.KeyCode]
    if value then
        pressButton(value)
    elseif input.KeyCode == Enum.KeyCode.Period or input.KeyCode == Enum.KeyCode.KeypadPeriod then
        pressButton(".")
    elseif input.KeyCode == Enum.KeyCode.Equals then
        pressButton("=")
    elseif input.KeyCode == Enum.KeyCode.Slash then
        pressButton("/")
    elseif input.KeyCode == Enum.KeyCode.Minus then
        pressButton("-")
    elseif input.KeyCode == Enum.KeyCode.LeftBracket then
        pressButton("^")
    end
end)

-- =========================================================
-- API
-- =========================================================

_G.EngineeringCalculator = {
    press = function(value)
        pressButton(tostring(value))
    end,

    clear = function()
        pressButton("C")
    end,

    getValue = function()
        return parseCurrentInput()
    end,

    getMemory = function()
        return memory
    end,

    setMemory = function(value)
        local number = tonumber(value)
        if number and isFiniteNumber(number) then
            memory = number
            return true
        end
        return false
    end,

    getGui = function()
        return screenGui
    end,
}

updateDisplay()
print("✅ Инженерный калькулятор загружен — исправленная версия")
