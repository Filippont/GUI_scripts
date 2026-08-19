local Players = game:GetService("Players")
local SoundService = game:GetService("SoundService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer

-- =========================================================
-- AUDIO PLAYER — исправленная и переработанная версия
-- Окно: #141414
-- =========================================================

local COLORS = {
    window = Color3.fromRGB(20, 20, 20),       -- #141414
    panel = Color3.fromRGB(29, 29, 29),
    input = Color3.fromRGB(38, 38, 38),
    button = Color3.fromRGB(45, 45, 45),
    buttonHover = Color3.fromRGB(55, 55, 55),
    white = Color3.fromRGB(245, 245, 245),
    muted = Color3.fromRGB(160, 160, 170),
    purple = Color3.fromRGB(110, 105, 255),
    green = Color3.fromRGB(76, 190, 86),
    red = Color3.fromRGB(205, 65, 65),
    orange = Color3.fromRGB(235, 175, 75),
}

local settings = {
    volume = 0.5,
    defaultId = "142376088",
}

local logs = {}
local isLooped = false
local currentId = nil
local destroyed = false

-- =========================================================
-- SCREEN GUI
-- =========================================================

local oldGui = nil

pcall(function()
    oldGui = player:WaitForChild("PlayerGui"):FindFirstChild("BoomboxPlayer")
end)

if oldGui then
    oldGui:Destroy()
end

local sg = Instance.new("ScreenGui")
sg.Name = "BoomboxPlayer"
sg.ResetOnSpawn = false
sg.IgnoreGuiInset = true
sg.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
sg.Parent = player:WaitForChild("PlayerGui")

-- =========================================================
-- SOUND
-- =========================================================

local sound = Instance.new("Sound")
sound.Name = "BoomboxSound"
sound.Volume = settings.volume
sound.Looped = false
sound.Parent = SoundService

-- =========================================================
-- HELPERS
-- =========================================================

local function corner(object, radius)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, radius or 8)
    c.Parent = object
    return c
end

local function stroke(object, color, thickness, transparency)
    local s = Instance.new("UIStroke")
    s.Color = color
    s.Thickness = thickness or 1
    s.Transparency = transparency or 0
    s.Parent = object
    return s
end

local function makeButton(button, normalColor, hoverColor)
    button.AutoButtonColor = false
    button.BackgroundColor3 = normalColor
    corner(button, 8)

    button.MouseEnter:Connect(function()
        if not destroyed then
            button.BackgroundColor3 = hoverColor
        end
    end)

    button.MouseLeave:Connect(function()
        if not destroyed then
            button.BackgroundColor3 = normalColor
        end
    end)
end

local function updateStatus(text, color)
    if statusLabel and statusLabel.Parent then
        statusLabel.Text = text
        statusLabel.TextColor3 = color or COLORS.muted
    end
end

local function setVolume(value, writeLog)
    settings.volume = math.clamp(value, 0, 1)
    sound.Volume = settings.volume

    if volumeLabel and volumeLabel.Parent then
        volumeLabel.Text = "🔊 " .. math.floor(settings.volume * 100 + 0.5) .. "%"
    end

    if writeLog then
        table.insert(logs, 1, {
            text = "🔊 Громкость: " .. math.floor(settings.volume * 100 + 0.5) .. "%",
            color = COLORS.white,
        })
    end
end

local function addLog(text, color)
    table.insert(logs, 1, {
        text = text,
        color = color or COLORS.white,
    })

    if #logs > 50 then
        table.remove(logs, #logs)
    end

    if logScrolling and logScrolling.Parent then
        task.defer(function()
            updateLogUI()
        end)
    end
end

-- =========================================================
-- MAIN WINDOW
-- =========================================================

local frame = Instance.new("Frame")
frame.Name = "MainFrame"
frame.Size = UDim2.fromOffset(355, 275)
frame.Position = UDim2.new(0.5, -177, 0.5, -137)
frame.BackgroundColor3 = COLORS.window
frame.BackgroundTransparency = 0
frame.BorderSizePixel = 0
frame.Active = true
frame.Parent = sg

corner(frame, 16)
stroke(frame, COLORS.purple, 2, 0)

-- =========================================================
-- DRAGGING (вместо устаревшего Draggable)
-- =========================================================

local dragging = false
local dragStart
local startPos
local dragInput

local function updateDrag(input)
    local delta = input.Position - dragStart
    frame.Position = UDim2.new(
        startPos.X.Scale,
        startPos.X.Offset + delta.X,
        startPos.Y.Scale,
        startPos.Y.Offset + delta.Y
    )
end

frame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then

        dragging = true
        dragStart = input.Position
        startPos = frame.Position

        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

frame.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement
        or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        updateDrag(input)
    end
end)

-- =========================================================
-- TOP BAR
-- =========================================================

local logBtn = Instance.new("TextButton")
logBtn.Name = "LogBtn"
logBtn.Size = UDim2.fromOffset(67, 30)
logBtn.Position = UDim2.fromOffset(12, 10)
logBtn.BackgroundColor3 = Color3.fromRGB(55, 45, 28)
logBtn.BorderSizePixel = 0
logBtn.Text = "📋 Логи"
logBtn.TextColor3 = COLORS.orange
logBtn.TextSize = 11
logBtn.Font = Enum.Font.GothamBold
logBtn.Parent = frame
makeButton(logBtn, Color3.fromRGB(55, 45, 28), Color3.fromRGB(70, 56, 33))

local loopBtn = Instance.new("TextButton")
loopBtn.Name = "LoopBtn"
loopBtn.Size = UDim2.fromOffset(34, 30)
loopBtn.Position = UDim2.fromOffset(86, 10)
loopBtn.BackgroundColor3 = COLORS.button
loopBtn.BorderSizePixel = 0
loopBtn.Text = "🔁"
loopBtn.TextColor3 = COLORS.muted
loopBtn.TextSize = 14
loopBtn.Font = Enum.Font.GothamBold
loopBtn.Parent = frame
makeButton(loopBtn, COLORS.button, COLORS.buttonHover)

local title = Instance.new("TextLabel")
title.Name = "Title"
title.Size = UDim2.new(1, -130, 0, 32)
title.Position = UDim2.fromOffset(115, 9)
title.BackgroundTransparency = 1
title.Text = "🎵 AUDIO PLAYER"
title.TextColor3 = Color3.fromRGB(180, 185, 255)
title.TextSize = 17
title.Font = Enum.Font.GothamBold
title.TextXAlignment = Enum.TextXAlignment.Center
title.Parent = frame

local closeBtn = Instance.new("TextButton")
closeBtn.Name = "CloseBtn"
closeBtn.Size = UDim2.fromOffset(30, 30)
closeBtn.Position = UDim2.new(1, -40, 0, 10)
closeBtn.BackgroundTransparency = 1
closeBtn.BorderSizePixel = 0
closeBtn.Text = "❌"
closeBtn.TextColor3 = Color3.fromRGB(255, 75, 75)
closeBtn.TextSize = 21
closeBtn.Font = Enum.Font.GothamBold
closeBtn.Parent = frame

closeBtn.MouseEnter:Connect(function()
    closeBtn.TextColor3 = Color3.fromRGB(255, 120, 120)
end)

closeBtn.MouseLeave:Connect(function()
    closeBtn.TextColor3 = Color3.fromRGB(255, 75, 75)
end)

-- =========================================================
-- CLOCK
-- =========================================================

local timeLabel = Instance.new("TextLabel")
timeLabel.Name = "TimeLabel"
timeLabel.Size = UDim2.fromOffset(100, 20)
timeLabel.Position = UDim2.new(1, -145, 0, 43)
timeLabel.BackgroundTransparency = 1
timeLabel.Text = ""
timeLabel.TextColor3 = COLORS.muted
timeLabel.TextSize = 11
timeLabel.Font = Enum.Font.Gotham
timeLabel.TextXAlignment = Enum.TextXAlignment.Right
timeLabel.Parent = frame

-- =========================================================
-- SOUND ID INPUT
-- =========================================================

local input = Instance.new("TextBox")
input.Name = "InputID"
input.Size = UDim2.new(1, -40, 0, 58)
input.Position = UDim2.fromOffset(20, 60)
input.BackgroundColor3 = COLORS.input
input.BackgroundTransparency = 0
input.BorderSizePixel = 0
input.ClearTextOnFocus = false
input.PlaceholderText = "Введите Sound ID..."
input.PlaceholderColor3 = Color3.fromRGB(120, 120, 130)
input.Text = settings.defaultId
input.TextColor3 = COLORS.white
input.TextSize = 14
input.Font = Enum.Font.Gotham
input.TextXAlignment = Enum.TextXAlignment.Center
input.Parent = frame
corner(input, 9)

-- Только цифры.
input:GetPropertyChangedSignal("Text"):Connect(function()
    local cleaned = input.Text:gsub("%D", "")
    if cleaned ~= input.Text then
        local cursor = math.min(#cleaned, input.CursorPosition - 1)
        input.Text = cleaned
        input.CursorPosition = cursor + 1
    end
end)

-- =========================================================
-- VOLUME
-- =========================================================

local volumeDown = Instance.new("TextButton")
volumeDown.Name = "VolumeDown"
volumeDown.Size = UDim2.fromOffset(38, 38)
volumeDown.Position = UDim2.fromOffset(20, 128)
volumeDown.Text = "−"
volumeDown.TextColor3 = COLORS.white
volumeDown.TextSize = 20
volumeDown.Font = Enum.Font.GothamBold
volumeDown.BorderSizePixel = 0
volumeDown.Parent = frame
makeButton(volumeDown, COLORS.button, COLORS.buttonHover)

volumeLabel = Instance.new("TextLabel")
volumeLabel.Name = "VolumeLabel"
volumeLabel.Size = UDim2.new(1, -120, 0, 38)
volumeLabel.Position = UDim2.fromOffset(60, 128)
volumeLabel.BackgroundTransparency = 1
volumeLabel.Text = "🔊 50%"
volumeLabel.TextColor3 = COLORS.white
volumeLabel.TextSize = 14
volumeLabel.Font = Enum.Font.GothamBold
volumeLabel.TextXAlignment = Enum.TextXAlignment.Center
volumeLabel.Parent = frame

local volumeUp = Instance.new("TextButton")
volumeUp.Name = "VolumeUp"
volumeUp.Size = UDim2.fromOffset(38, 38)
volumeUp.Position = UDim2.new(1, -58, 0, 128)
volumeUp.Text = "+"
volumeUp.TextColor3 = COLORS.white
volumeUp.TextSize = 20
volumeUp.Font = Enum.Font.GothamBold
volumeUp.BorderSizePixel = 0
volumeUp.Parent = frame
makeButton(volumeUp, COLORS.button, COLORS.buttonHover)

-- =========================================================
-- VOLUME HOLD
-- =========================================================

local holdDirection = 0
local holdToken = 0

local function startVolumeHold(direction)
    holdDirection = direction
    holdToken += 1
    local myToken = holdToken

    setVolume(settings.volume + direction * 0.05, false)

    task.spawn(function()
        task.wait(0.35)

        while holdDirection == direction and holdToken == myToken and not destroyed do
            setVolume(settings.volume + direction * 0.05, false)
            task.wait(0.08)

            if settings.volume <= 0 or settings.volume >= 1 then
                break
            end
        end
    end)
end

local function stopVolumeHold()
    holdDirection = 0
    holdToken += 1
end

volumeDown.MouseButton1Down:Connect(function()
    startVolumeHold(-1)
end)

volumeDown.MouseButton1Up:Connect(stopVolumeHold)
volumeDown.MouseLeave:Connect(stopVolumeHold)

volumeUp.MouseButton1Down:Connect(function()
    startVolumeHold(1)
end)

volumeUp.MouseButton1Up:Connect(stopVolumeHold)
volumeUp.MouseLeave:Connect(stopVolumeHold)

-- =========================================================
-- PLAY / STOP
-- =========================================================

local playBtn = Instance.new("TextButton")
playBtn.Name = "PlayBtn"
playBtn.Size = UDim2.new(0.44, 0, 0, 46)
playBtn.Position = UDim2.fromOffset(20, 179)
playBtn.Text = "▶ PLAY"
playBtn.TextColor3 = Color3.new(1, 1, 1)
playBtn.TextSize = 14
playBtn.Font = Enum.Font.GothamBold
playBtn.BorderSizePixel = 0
playBtn.Parent = frame
makeButton(playBtn, COLORS.green, Color3.fromRGB(91, 205, 101))

local stopBtn = Instance.new("TextButton")
stopBtn.Name = "StopBtn"
stopBtn.Size = UDim2.new(0.44, 0, 0, 46)
stopBtn.Position = UDim2.new(0.56, -20, 0, 179)
stopBtn.Text = "■ STOP"
stopBtn.TextColor3 = Color3.new(1, 1, 1)
stopBtn.TextSize = 14
stopBtn.Font = Enum.Font.GothamBold
stopBtn.BorderSizePixel = 0
stopBtn.Parent = frame
makeButton(stopBtn, COLORS.red, Color3.fromRGB(225, 80, 80))

statusLabel = Instance.new("TextLabel")
statusLabel.Name = "StatusLabel"
statusLabel.Size = UDim2.new(1, -30, 0, 22)
statusLabel.Position = UDim2.fromOffset(15, 235)
statusLabel.BackgroundTransparency = 1
statusLabel.Text = "🔴 Stopped"
statusLabel.TextColor3 = COLORS.muted
statusLabel.TextSize = 11
statusLabel.Font = Enum.Font.Gotham
statusLabel.TextXAlignment = Enum.TextXAlignment.Center
statusLabel.Parent = frame

-- =========================================================
-- LOG WINDOW
-- =========================================================

local logFrame = Instance.new("Frame")
logFrame.Name = "LogFrame"
logFrame.Size = UDim2.fromOffset(300, 275)
logFrame.Position = UDim2.new(0.5, 190, 0.5, -137)
logFrame.BackgroundColor3 = COLORS.window
logFrame.BackgroundTransparency = 0
logFrame.BorderSizePixel = 0
logFrame.Visible = false
logFrame.Active = true
logFrame.Parent = sg

corner(logFrame, 16)
stroke(logFrame, COLORS.orange, 2, 0)

local logTitle = Instance.new("TextLabel")
logTitle.Size = UDim2.new(1, -50, 0, 35)
logTitle.Position = UDim2.fromOffset(15, 7)
logTitle.BackgroundTransparency = 1
logTitle.Text = "📋 Логи"
logTitle.TextColor3 = COLORS.orange
logTitle.TextSize = 14
logTitle.Font = Enum.Font.GothamBold
logTitle.TextXAlignment = Enum.TextXAlignment.Center
logTitle.Parent = logFrame

local logCloseBtn = Instance.new("TextButton")
logCloseBtn.Size = UDim2.fromOffset(28, 28)
logCloseBtn.Position = UDim2.new(1, -38, 0, 8)
logCloseBtn.BackgroundTransparency = 1
logCloseBtn.Text = "❌"
logCloseBtn.TextColor3 = Color3.fromRGB(255, 85, 85)
logCloseBtn.TextSize = 16
logCloseBtn.Font = Enum.Font.GothamBold
logCloseBtn.BorderSizePixel = 0
logCloseBtn.Parent = logFrame

logScrolling = Instance.new("ScrollingFrame")
logScrolling.Name = "LogScrolling"
logScrolling.Size = UDim2.new(1, -20, 1, -50)
logScrolling.Position = UDim2.fromOffset(10, 42)
logScrolling.BackgroundColor3 = Color3.fromRGB(26, 26, 26)
logScrolling.BackgroundTransparency = 0
logScrolling.BorderSizePixel = 0
logScrolling.ScrollBarThickness = 5
logScrolling.ScrollBarImageColor3 = COLORS.orange
logScrolling.CanvasSize = UDim2.fromOffset(0, 0)
logScrolling.AutomaticCanvasSize = Enum.AutomaticSize.Y
logScrolling.Parent = logFrame
corner(logScrolling, 8)

local logPadding = Instance.new("UIPadding")
logPadding.PaddingTop = UDim.new(0, 7)
logPadding.PaddingBottom = UDim.new(0, 7)
logPadding.PaddingLeft = UDim.new(0, 7)
logPadding.PaddingRight = UDim.new(0, 7)
logPadding.Parent = logScrolling

local logLayout = Instance.new("UIListLayout")
logLayout.SortOrder = Enum.SortOrder.LayoutOrder
logLayout.Padding = UDim.new(0, 3)
logLayout.Parent = logScrolling

-- Reusable log renderer; no conflicting Position/UIListLayout.
function updateLogUI()
    if not logScrolling or not logScrolling.Parent then
        return
    end

    for _, child in ipairs(logScrolling:GetChildren()) do
        if child:IsA("TextLabel") then
            child:Destroy()
        end
    end

    for i = #logs, 1, -1 do
        local item = logs[i]

        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(1, 0, 0, 20)
        label.BackgroundTransparency = 1
        label.Text = item.text
        label.TextColor3 = item.color
        label.TextSize = 11
        label.Font = Enum.Font.Gotham
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.TextYAlignment = Enum.TextYAlignment.Center
        label.LayoutOrder = i
        label.Parent = logScrolling
    end

    task.defer(function()
        if logScrolling and logScrolling.Parent then
            logScrolling.CanvasPosition = Vector2.new(
                0,
                math.max(0, logScrolling.AbsoluteCanvasSize.Y - logScrolling.AbsoluteSize.Y)
            )
        end
    end)
end

-- =========================================================
-- LOOP
-- =========================================================

local function setLoop(value)
    isLooped = value == true
    sound.Looped = isLooped

    if isLooped then
        loopBtn.TextColor3 = COLORS.green
        addLog("🔁 Зацикливание ВКЛЮЧЕНО", COLORS.green)
    else
        loopBtn.TextColor3 = COLORS.muted
        addLog("🔁 Зацикливание ВЫКЛЮЧЕНО", COLORS.muted)
    end
end

loopBtn.MouseButton1Click:Connect(function()
    setLoop(not isLooped)
end)

-- =========================================================
-- PLAY / STOP FUNCTIONS
-- =========================================================

local function sanitizeId(value)
    local id = tostring(value or ""):gsub("%D", "")
    return id
end

local function stopSound(writeLog)
    sound:Stop()
    currentId = nil

    updateStatus("⏹ Stopped", Color3.fromRGB(200, 200, 200))

    playBtn.Text = "▶ PLAY"
    playBtn.BackgroundColor3 = COLORS.green

    if writeLog ~= false then
        addLog("⏹ Воспроизведение остановлено", Color3.fromRGB(200, 200, 200))
    end
end

local function playSound(id)
    id = sanitizeId(id)

    if id == "" then
        updateStatus("⚠️ Неверный Sound ID", Color3.fromRGB(255, 200, 50))
        addLog("⚠️ Неверный Sound ID", Color3.fromRGB(255, 200, 50))
        return false
    end

    if currentId == id and sound.IsPlaying then
        updateStatus("▶ Уже играет: " .. id, COLORS.green)
        return true
    end

    sound:Stop()
    sound.SoundId = "rbxassetid://" .. id
    sound.Volume = settings.volume
    sound.Looped = isLooped
    currentId = id

    local ok, err = pcall(function()
        sound:Play()
    end)

    if not ok then
        currentId = nil
        updateStatus("❌ Ошибка запуска", COLORS.red)
        playBtn.Text = "▶ PLAY"
        playBtn.BackgroundColor3 = COLORS.green
        addLog("❌ Ошибка: " .. tostring(err), COLORS.red)
        return false
    end

    local loopText = isLooped and " 🔁" or ""

    updateStatus("▶ Playing: " .. id .. loopText, COLORS.green)
    playBtn.Text = "▶ PLAYING"
    playBtn.BackgroundColor3 = Color3.fromRGB(91, 205, 101)

    addLog("🎵 Воспроизведение ID: " .. id .. loopText, COLORS.green)
    return true
end

-- =========================================================
-- SOUND EVENTS
-- =========================================================

sound.Ended:Connect(function()
    if not destroyed and not sound.Looped then
        currentId = nil
        updateStatus("⏹ Finished", Color3.fromRGB(200, 200, 200))
        playBtn.Text = "▶ PLAY"
        playBtn.BackgroundColor3 = COLORS.green
    end
end)

sound.Loaded:Connect(function()
    if not destroyed and currentId then
        updateStatus("▶ Playing: " .. currentId .. (isLooped and " 🔁" or ""), COLORS.green)
    end
end)

-- =========================================================
-- BUTTON EVENTS
-- =========================================================

playBtn.MouseButton1Click:Connect(function()
    local id = sanitizeId(input.Text)

    if id == "" then
        id = settings.defaultId
        input.Text = id
    end

    playSound(id)
end)

stopBtn.MouseButton1Click:Connect(function()
    stopSound(true)
end)

logBtn.MouseButton1Click:Connect(function()
    logFrame.Visible = not logFrame.Visible

    if logFrame.Visible then
        updateLogUI()
    end
end)

logCloseBtn.MouseButton1Click:Connect(function()
    logFrame.Visible = false
end)

closeBtn.MouseButton1Click:Connect(function()
    destroyed = true
    stopVolumeHold()

    pcall(function()
        sound:Stop()
        sound:Destroy()
    end)

    if sg then
        sg:Destroy()
    end
end)

-- =========================================================
-- KEYBINDS
-- Ctrl + Left / Right = volume
-- =========================================================

UserInputService.InputBegan:Connect(function(key, gameProcessed)
    if gameProcessed or destroyed then
        return
    end

    if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
        if key.KeyCode == Enum.KeyCode.Right then
            setVolume(settings.volume + 0.05, true)
        elseif key.KeyCode == Enum.KeyCode.Left then
            setVolume(settings.volume - 0.05, true)
        end
    end
end)

-- =========================================================
-- CLOCK
-- =========================================================

task.spawn(function()
    while sg.Parent and not destroyed do
        timeLabel.Text = "🕐 " .. os.date("%H:%M:%S")
        task.wait(1)
    end
end)

-- =========================================================
-- PUBLIC API
-- =========================================================

_G.Player = {
    play = function(id)
        id = sanitizeId(id)

        if input and input.Parent then
            input.Text = id
        end

        return playSound(id)
    end,

    stop = function()
        stopSound(true)
    end,

    volume = function(value)
        local v = tonumber(value)

        if not v then
            return false
        end

        setVolume(v, true)
        return true
    end,

    loop = function(value)
        setLoop(value == true)
        return isLooped
    end,

    logs = function()
        return logs
    end,

    gui = function()
        return sg
    end,

    sound = function()
        return sound
    end,
}

-- =========================================================
-- START
-- =========================================================

addLog("🚀 Audio Player загружен", COLORS.green)

if settings.defaultId ~= "" then
    task.delay(0.5, function()
        if not destroyed and input and input.Parent then
            playSound(settings.defaultId)
        end
    end)
end

print("🎵 Audio Player loaded — fixed version")
