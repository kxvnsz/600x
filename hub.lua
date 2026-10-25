-- *600x Hub V5 - Desync Fixed + Config in Hub + Double Hit Sliders*
-- Fixed: Desync works properly, Config inside hub, Double Hit range/probability, Addons fixed

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TextChatService = game:GetService("TextChatService")
local CoreGui = game:GetService("CoreGui")
local LogService = game:GetService("LogService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TeleportService = game:GetService("TeleportService")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local Mouse = LocalPlayer:GetMouse()
local Camera = workspace.CurrentCamera

-- ==================================================
-- GLOBAL CONFIG & ENV
-- ==================================================
getgenv().Prediction = 0.150
getgenv().AutoPrediction = true
getgenv().FOV = 100
getgenv().DontShootThesePeople = {"", "", ""}
getgenv().AimKey = ""
getgenv().Reach1Range = 3.5
getgenv().Reach2Range = 4
getgenv().Reach3Range = 4
getgenv().AuraRange = 25
getgenv().DoubleHitRange = 14
getgenv().DoubleHitChance = 100 -- 0-100%

local LANG = "es"
local LANG_DATA = {
    es = {
        Home="Inicio", Player="Jugador", Exploits="Exploits", Render="Render",
        Mundos="Juegos", Config="Config", Credits="Créditos", Addons="Addons",
        SYSTEM="SISTEMA", STATUS="ESTADO", LATEST="ÚLTIMOS CAMBIOS",
        Welcome="Bienvenido", Version="Versión", Executor="Ejecutor",
        FEATURES="CARACTERÍSTICAS", BLACKLIST="LISTA NEGRA",
        COLOR="COLOR", GAME_DETECT="DETECCIÓN DE JUEGO",
        PRESETS="PRESETS", GUI="INTERFAZ", NOTIFS="NOTIFICACIONES", RESET="RESETEAR",
        ADDONS="ADDONS", Theme="Color de Tema", Animated_Border="Borde Animado",
        Sounds="Sonidos", Welcome_Notif="Notificación", Click_Sound="Sonido al Clic",
        Reset_Settings="Resetear Ajustes", Creator="Creador", Logo_Asset="Asset del Logo",
        Interface="Interfaz", Fly="Fly", InfJump="Inf Jump", Invis="Invisibilidad", Desync="Desync",
        Reach1="Reach 1", Reach2="Reach 2", Reach3="Reach 3", MineAura="Mine Aura",
        SilentAim="Silent Aim", SpyChat="Spy Chat", ESP="ESP", InfiniteYield="Infinite Yield",
        DoubleHit="Double Hit", PurpleSky="Cielo Morado", CustomLighting="Iluminación Custom",
        WorldTint="Tinte del Mundo", Target="Objetivo", Range="Rango", Sound_Select="Seleccionar Sonido",
        Clone="Clonar", Teleport="Teleport", Hide="Ocultar", Noclip="Noclip",
        DesyncConfig="Config Desync", Speed="Velocidad", Jump="Salto",
        DoubleHitConfig="Config Double Hit", Probability="Probabilidad",
    },
    en = {
        Home="Home", Player="Player", Exploits="Exploits", Render="Render",
        Mundos="Games", Config="Config", Credits="Credits", Addons="Addons",
        SYSTEM="SYSTEM", STATUS="STATUS", LATEST="LATEST CHANGES",
        Welcome="Welcome", Version="Version", Executor="Executor",
        FEATURES="FEATURES", BLACKLIST="BLACKLIST",
        COLOR="COLOR", GAME_DETECT="GAME DETECTION",
        PRESETS="PRESETS", GUI="INTERFACE", NOTIFS="NOTIFICATIONS", RESET="RESET",
        ADDONS="ADDONS", Theme="Theme Color", Animated_Border="Animated Border",
        Sounds="Sounds", Welcome_Notif="Notification", Click_Sound="Click Sound",
        Reset_Settings="Reset Settings", Creator="Creator", Logo_Asset="Logo Asset",
        Interface="Interface", Fly="Fly", InfJump="Inf Jump", Invis="Invisibility", Desync="Desync",
        Reach1="Reach 1", Reach2="Reach 2", Reach3="Reach 3", MineAura="Mine Aura",
        SilentAim="Silent Aim", SpyChat="Spy Chat", ESP="ESP", InfiniteYield="Infinite Yield",
        DoubleHit="Double Hit", PurpleSky="Purple Sky", CustomLighting="Custom Lighting",
        WorldTint="World Tint", Target="Target", Range="Range", Sound_Select="Select Sound",
        Clone="Clone", Teleport="Teleport", Hide="Hide", Noclip="Noclip",
        DesyncConfig="Desync Config", Speed="Speed", Jump="Jump",
        DoubleHitConfig="Double Hit Config", Probability="Probability",
    },
}

local function T(key)
    return (LANG_DATA[LANG] and LANG_DATA[LANG][key]) or key
end

-- ==================================================
-- VISUAL CONFIG (PURPLE THEME)
-- ==================================================
local CONFIG = {
    Name        = "600x Hub",
    Version     = "v5 (Desync Fixed)",
    Logo        = "rbxassetid://85029161626386",
    Background  = Color3.fromRGB(10, 9, 14),
    Panel       = Color3.fromRGB(15, 13, 20),
    Panel2      = Color3.fromRGB(20, 17, 28),
    Text        = Color3.fromRGB(242, 238, 250),
    Muted       = Color3.fromRGB(145, 135, 160),
    Accent      = Color3.fromRGB(145, 65, 255),
    Accent2     = Color3.fromRGB(185, 100, 255),
    AccentDark  = Color3.fromRGB(72, 35, 125),
    On          = Color3.fromRGB(160, 80, 255),
    Off         = Color3.fromRGB(34, 30, 42),
}

local COLORS = {
    Color3.fromRGB(120, 45, 230),
    Color3.fromRGB(145, 65, 255),
    Color3.fromRGB(175, 80, 255),
    Color3.fromRGB(205, 120, 255),
    Color3.fromRGB(95, 35, 185),
}

-- ==================================================
-- CLEANUP & UTILITIES
-- ==================================================
pcall(function()
    for _, v in ipairs(getconnections(LogService.MessageOut)) do
        v:Disable()
    end
end)

for _, g in ipairs(PlayerGui:GetChildren()) do
    if g.Name == "600xHub_GUI" or g.Name == "600xColorPicker" then g:Destroy() end
end

local function corner(parent, radius)
    local c = Instance.new("UICorner"); c.CornerRadius = UDim.new(0, radius or 8); c.Parent = parent; return c
end
local function stroke(parent, color, thickness)
    local s = Instance.new("UIStroke"); s.Color = color or CONFIG.Accent; s.Thickness = thickness or 1; s.Transparency = 0; s.Parent = parent; return s
end
local function tween(obj, info, props)
    return TweenService:Create(obj, info, props)
end
local function label(parent, text, size, position, color, font)
    local l = Instance.new("TextLabel")
    l.BackgroundTransparency = 1; l.Text = text; l.TextSize = size or 13
    l.TextColor3 = color or CONFIG.Text; l.Font = font or Enum.Font.Gotham
    l.Position = position or UDim2.fromOffset(0, 0); l.Size = UDim2.fromOffset(100, 25)
    l.TextXAlignment = Enum.TextXAlignment.Left; l.Parent = parent; return l
end
local function detectExecutor()
    local name = "Unknown"
    pcall(function()
        if identifyexecutor then name = identifyexecutor()
        elseif getexecutorname then name = getexecutorname()
        elseif syn then name = "Synapse"
        elseif fluxus then name = "Fluxus"
        elseif KRNL_LOADED then name = "Krnl"
        end
    end)
    return tostring(name)
end

-- Interface sounds disabled. Existing callbacks remain compatible.
local function playSound() end

local AllConnections, AllGuis = {}, {}
local function track(conn) table.insert(AllConnections, conn); return conn end
local function trackGui(g) table.insert(AllGuis, g); return g end

local function DestroyEverything()
    for _, c in pairs(AllConnections) do pcall(function() c:Disconnect() end) end
    for _, g in pairs(AllGuis) do pcall(function() g:Destroy() end) end
    AllConnections, AllGuis = {}, {}
    print("[600x] Hub destruido.")
end

-- ==================================================
-- GAME DETECTION (Fixed - waits for proper game name)
-- ==================================================
local function getGameName()
    local gameName = game.Name
    if gameName == "UGC" or gameName == "Place" or gameName == "Game" then
        pcall(function()
            local MarketplaceService = game:GetService("MarketplaceService")
            local productInfo = MarketplaceService:GetProductInfo(game.PlaceId)
            if productInfo and productInfo.Name then
                gameName = productInfo.Name
            end
        end)
    end
    if gameName == "UGC" or gameName == "" then
        gameName = "Place #" .. tostring(game.PlaceId)
    end
    return gameName
end

-- ==================================================
-- MAIN GUI CONSTRUCTION
-- ==================================================
local Gui = trackGui(Instance.new("ScreenGui"))
Gui.Name = "600xHub_GUI"; Gui.ResetOnSpawn = false; Gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling; Gui.Parent = PlayerGui

local Main = Instance.new("Frame")
Main.Name = "Main"; Main.Size = UDim2.fromOffset(850, 590)
Main.Position = UDim2.new(0.5, -425, 0.5, -295)
Main.BackgroundColor3 = CONFIG.Background; Main.BorderSizePixel = 0
Main.Active = true; Main.Draggable = true; Main.Parent = Gui
corner(Main, 12)
local MainStroke = stroke(Main, CONFIG.Accent, 1.5)

task.spawn(function()
    local i = 1
    while Main.Parent do
        local c = COLORS[i]
        tween(MainStroke, TweenInfo.new(0.9, Enum.EasingStyle.Sine), {Color = c}):Play()
        i = i % #COLORS + 1; task.wait(1)
    end
end)

-- Sidebar
local Sidebar = Instance.new("Frame")
Sidebar.Name = "Sidebar"; Sidebar.Size = UDim2.new(0, 215, 1, 0)
Sidebar.BackgroundColor3 = Color3.fromRGB(11, 10, 15); Sidebar.BorderSizePixel = 0; Sidebar.Parent = Main
corner(Sidebar, 12)

local SideLine = Instance.new("Frame")
SideLine.Size = UDim2.new(0, 1, 1, -30); SideLine.Position = UDim2.new(1, -1, 0, 15)
SideLine.BackgroundColor3 = CONFIG.AccentDark; SideLine.BorderSizePixel = 0; SideLine.Parent = Sidebar

local LogoImage = Instance.new("ImageLabel")
LogoImage.Name = "Logo"; LogoImage.Size = UDim2.fromOffset(39, 39); LogoImage.Position = UDim2.fromOffset(16, 15)
LogoImage.BackgroundColor3 = CONFIG.AccentDark; LogoImage.Image = CONFIG.Logo
LogoImage.ScaleType = Enum.ScaleType.Fit; LogoImage.Parent = Sidebar; corner(LogoImage, 9)

local HubTitle = label(Sidebar, "600x", 20, UDim2.fromOffset(65, 14), CONFIG.Text, Enum.Font.GothamBlack)
HubTitle.Size = UDim2.fromOffset(120, 25)
local HubSub = label(Sidebar, "HUB", 10, UDim2.fromOffset(66, 37), CONFIG.Muted, Enum.Font.GothamBold)
HubSub.Size = UDim2.fromOffset(100, 18)

-- Content Area
local Content = Instance.new("Frame")
Content.Name = "Content"; Content.Size = UDim2.new(1, -215, 1, -28)
Content.Position = UDim2.fromOffset(215, 0); Content.BackgroundTransparency = 1; Content.Parent = Main

local pages = {}; local navButtons = {}

local function createPage(name)
    local page = Instance.new("ScrollingFrame")
    page.Name = name; page.Size = UDim2.new(1, -28, 1, -70); page.Position = UDim2.fromOffset(14, 60)
    page.BackgroundTransparency = 1; page.BorderSizePixel = 0
    page.ScrollBarThickness = 3; page.ScrollBarImageColor3 = CONFIG.Accent
    page.CanvasSize = UDim2.new(); page.AutomaticCanvasSize = Enum.AutomaticSize.Y
    page.Visible = false; page.Parent = Content
    local layout = Instance.new("UIListLayout"); layout.Padding = UDim.new(0, 9); layout.SortOrder = Enum.SortOrder.LayoutOrder; layout.Parent = page
    pages[name] = page; return page
end

local function navButton(text, icon, y)
    local b = Instance.new("TextButton")
    b.Name = text; b.Size = UDim2.new(1, -25, 0, 38); b.Position = UDim2.fromOffset(12, y)
    b.BackgroundColor3 = Color3.fromRGB(11, 10, 15); b.BorderSizePixel = 0; b.Text = ""; b.AutoButtonColor = false; b.Parent = Sidebar
    corner(b, 7)
    local ic = label(b, icon, 17, UDim2.fromOffset(12, 5), CONFIG.Muted, Enum.Font.GothamBold)
    ic.Size = UDim2.fromOffset(25, 28); ic.TextXAlignment = Enum.TextXAlignment.Center
    local tx = label(b, text, 12, UDim2.fromOffset(45, 6), CONFIG.Muted, Enum.Font.GothamMedium)
    tx.Size = UDim2.new(1, -50, 0, 25)
    navButtons[text] = {Button = b, Icon = ic, Text = tx}; return b
end

local nav = {
    {"Inicio", "🏠"}, {"Jugador", "♟"}, {"Exploits", "⚔"}, {"Render", "◉"},
    {"Juegos", "🎮"}, {"Config", "⚙"}, {"Créditos", "♡"}, {"Addons", ""},
}
for i, item in ipairs(nav) do navButton(item[1], item[2], 75 + ((i - 1) * 43)) end

local PageTitle = label(Content, "Inicio", 18, UDim2.fromOffset(14, 13), CONFIG.Text, Enum.Font.GothamBlack)
PageTitle.Size = UDim2.fromOffset(400, 27)
local PageSub = label(Content, "600x Hub", 10, UDim2.fromOffset(14, 37), CONFIG.Muted, Enum.Font.Gotham)
PageSub.Size = UDim2.fromOffset(500, 17)

-- ==================================================
-- COMPONENTS
-- ==================================================
local function makeSection(page, titleText)
    local holder = Instance.new("Frame")
    holder.Size = UDim2.new(1, -4, 0, 30); holder.BackgroundTransparency = 1; holder.Parent = page
    local t = label(holder, titleText, 11, UDim2.fromOffset(3, 5), CONFIG.Accent2, Enum.Font.GothamBold)
    t.Size = UDim2.new(1, -5, 0, 20); return holder
end

-- Action shortcuts start unassigned. M controls hub visibility.
local KeyBindings, KeyButtons = {}, {}
local pendingKeybind = nil
local reservedKeys = {[Enum.KeyCode.M] = true}

local function refreshKeybind(name)
    local button = KeyButtons[name]
    if button and button.Parent then
        local choosing = pendingKeybind == name
        local binding = KeyBindings[name]
        button.Text = choosing and "..." or (binding and binding.Name or "")
        local icon = button:FindFirstChild("KeyboardIcon")
        if icon then icon.Visible = not choosing and binding == nil end
        local clear = button.Parent:FindFirstChild("ClearKeybind_" .. name)
        if clear then clear.Visible = binding ~= nil end
        local hint = button:FindFirstChild("ShortcutHint")
        if hint then
            local binding = KeyBindings[name]
            hint.Text = choosing and "Pulsa una tecla | Esc: cancelar"
                or ((binding and ("Tecla: " .. binding.Name) or "Sin asignar")
                    .. " | Clic: cambiar | X: quitar")
        end
    end
end

local function cancelKeybind()
    local previous = pendingKeybind
    pendingKeybind = nil
    if previous then refreshKeybind(previous) end
end

local function clearKeybind(name)
    if pendingKeybind == name then cancelKeybind() end
    KeyBindings[name] = nil
    if name == "E" then getgenv().AimKey = "" end
    refreshKeybind(name)
end

local function beginKeybind(name)
    cancelKeybind()
    pendingKeybind = name
    refreshKeybind(name)
end

local function captureKeybind(input)
    if not pendingKeybind then return false end
    -- Consume input while choosing a shortcut; do not toggle an action.
    if input.UserInputType ~= Enum.UserInputType.Keyboard then return true end
    local key = input.KeyCode
    if key == Enum.KeyCode.Escape then
        cancelKeybind()
        return true
    end
    if key == Enum.KeyCode.Unknown or reservedKeys[key] then
        warn("[600x] Tecla reservada. Elige otra, o pulsa Esc para cancelar.")
        return true
    end
    local name = pendingKeybind
    for other, binding in pairs(KeyBindings) do
        if other ~= name and binding == key then
            warn("[600x] Esa tecla ya tiene otra función. Elige otra.")
            return true
        end
    end
    KeyBindings[name] = key
    if name == "E" then
        getgenv().AimKey = KeyBindings[name] and KeyBindings[name].Name:lower() or ""
    end
    cancelKeybind()
    playSound()
    return true
end

local function makeToggle(page, titleText, descText, keyText)
    local row = Instance.new("Frame")
    row.Size = UDim2.new(1, -4, 0, 58); row.BackgroundColor3 = CONFIG.Panel; row.BorderSizePixel = 0; row.Parent = page
    corner(row, 7); stroke(row, Color3.fromRGB(42, 35, 55), 1)

    local title = label(row, titleText, 12, UDim2.fromOffset(13, 8), CONFIG.Text, Enum.Font.GothamBold)
    title.Size = UDim2.new(1, -190, 0, 18)
    local desc = label(row, descText, 10, UDim2.fromOffset(13, 29), CONFIG.Muted, Enum.Font.Gotham)
    desc.Size = UDim2.new(1, -190, 0, 17)
    local shortcuts = {}
    for name in string.gmatch(keyText or "", "[^/]+") do
        table.insert(shortcuts, name)
    end
    -- R/Q has two independent buttons: increase / decrease.
    for index, name in ipairs(shortcuts) do
        local key = Instance.new("TextButton")
        key.Name = "Keybind_" .. name
        key.Size = UDim2.fromOffset(#shortcuts == 1 and 36 or 27, 24)
        key.Position = UDim2.new(1, (#shortcuts == 1 and -135 or -172) + (index - 1) * 45, 0, 17)
        key.BackgroundColor3 = Color3.fromRGB(17, 13, 23)
        key.BorderSizePixel = 0
        key.Font = Enum.Font.GothamBold
        key.TextColor3 = CONFIG.Accent2
        key.TextSize = 12
        key.TextScaled = true
        key.TextWrapped = false
        key.AutoButtonColor = true
        key.Parent = row
        corner(key, 5)
        local limit = Instance.new("UITextSizeConstraint")
        limit.MinTextSize = 7
        limit.MaxTextSize = 12
        limit.Parent = key
        stroke(key, Color3.fromRGB(57, 43, 70), 1)

        -- Draw a keyboard icon with UI elements; no external image required.
        local icon = Instance.new("Frame")
        icon.Name = "KeyboardIcon"
        icon.AnchorPoint = Vector2.new(0.5, 0.5)
        icon.Position = UDim2.fromScale(0.5, 0.5)
        icon.Size = UDim2.fromOffset(14, 10)
        icon.BackgroundTransparency = 1
        icon.BorderSizePixel = 0
        icon.Parent = key
        corner(icon, 2)
        stroke(icon, Color3.fromRGB(145, 128, 163), 1)
        for rowIndex = 0, 1 do
            for colIndex = 0, 3 do
                local dot = Instance.new("Frame")
                dot.Size = UDim2.fromOffset(2, 1)
                dot.Position = UDim2.fromOffset(2 + colIndex * 3, 2 + rowIndex * 2)
                dot.BackgroundColor3 = Color3.fromRGB(145, 128, 163)
                dot.BorderSizePixel = 0
                dot.Parent = icon
            end
        end
        local spacebar = Instance.new("Frame")
        spacebar.Size = UDim2.fromOffset(7, 1)
        spacebar.Position = UDim2.fromOffset(4, 7)
        spacebar.BackgroundColor3 = Color3.fromRGB(145, 128, 163)
        spacebar.BorderSizePixel = 0
        spacebar.Parent = icon

        local hint = Instance.new("TextLabel")
        hint.Name = "ShortcutHint"
        hint.AnchorPoint = Vector2.new(1, 1)
        hint.Position = UDim2.new(1, 0, 0, -4)
        hint.Size = UDim2.fromOffset(310, 24)
        hint.BackgroundColor3 = Color3.fromRGB(24, 18, 32)
        hint.BorderSizePixel = 0
        hint.TextColor3 = CONFIG.Text
        hint.Font = Enum.Font.Gotham
        hint.TextSize = 10
        hint.ZIndex = 20
        hint.Visible = false
        hint.Parent = key
        corner(hint, 4)
        local clear = Instance.new("TextButton")
        clear.Name = "ClearKeybind_" .. name
        clear.Size = UDim2.fromOffset(#shortcuts == 1 and 16 or 14, 24)
        clear.Position = UDim2.new(1,
            (#shortcuts == 1 and -96 or -143) + (index - 1) * 45, 0, 17)
        clear.BackgroundColor3 = Color3.fromRGB(45, 22, 34)
        clear.BorderSizePixel = 0
        clear.Text = "×"
        clear.TextColor3 = Color3.fromRGB(240, 153, 170)
        clear.Font = Enum.Font.GothamBold
        clear.TextSize = 15
        clear.Parent = row
        corner(clear, 4)
        track(clear.Activated:Connect(function()
            clearKeybind(name)
            playSound()
        end))
        KeyButtons[name] = key
        refreshKeybind(name)
        track(key.MouseEnter:Connect(function() hint.Visible = true end))
        track(key.MouseLeave:Connect(function() hint.Visible = false end))
        track(key.Activated:Connect(function() beginKeybind(name) end))
        track(key.MouseButton2Click:Connect(function()
            clearKeybind(name)
        end))
    end

    local switch = Instance.new("TextButton")
    switch.Name = "Toggle"; switch.Size = UDim2.fromOffset(55, 24); switch.Position = UDim2.new(1, -68, 0, 17)
    switch.BackgroundColor3 = CONFIG.Off; switch.BorderSizePixel = 0; switch.Text = ""; switch.AutoButtonColor = false; switch.Parent = row
    corner(switch, 12)

    local knob = Instance.new("Frame")
    knob.Name = "Knob"; knob.Size = UDim2.fromOffset(18, 18); knob.Position = UDim2.fromOffset(3, 3)
    knob.BackgroundColor3 = Color3.fromRGB(225, 220, 235); knob.BorderSizePixel = 0; knob.Parent = switch; corner(knob, 10)

    local state = false; local callback = nil
    local function setState(value, skipCallback)
        state = value
        tween(switch, TweenInfo.new(0.18, Enum.EasingStyle.Quad), {BackgroundColor3 = state and CONFIG.On or CONFIG.Off}):Play()
        tween(knob, TweenInfo.new(0.18, Enum.EasingStyle.Quad), {Position = state and UDim2.new(1, -21, 0, 3) or UDim2.fromOffset(3, 3)}):Play()
        if callback and not skipCallback then callback(state) end
    end
    switch.MouseButton1Click:Connect(function() setState(not state); playSound() end)
    return {Row = row, Button = switch, Set = setState, Get = function() return state end, OnChange = function(fn) callback = fn end}
end

local function makeSlider(page, titleText, minVal, maxVal, defaultVal, callback)
    local row = Instance.new("Frame")
    row.Size = UDim2.new(1, -4, 0, 60); row.BackgroundColor3 = CONFIG.Panel; row.BorderSizePixel = 0; row.Parent = page
    corner(row, 7); stroke(row, Color3.fromRGB(42, 35, 55), 1)

    local title = label(row, titleText, 12, UDim2.fromOffset(13, 8), CONFIG.Text, Enum.Font.GothamBold)
    title.Size = UDim2.new(1, -150, 0, 18)

    local valLabel = label(row, tostring(defaultVal), 13, UDim2.new(1, -50, 0, 6), CONFIG.Accent2, Enum.Font.GothamBold)
    valLabel.Size = UDim2.fromOffset(45, 22); valLabel.TextXAlignment = Enum.TextXAlignment.Right

    local trackFrame = Instance.new("Frame")
    trackFrame.Size = UDim2.new(1, -26, 0, 8); trackFrame.Position = UDim2.fromOffset(13, 36)
    trackFrame.BackgroundColor3 = Color3.fromRGB(30, 25, 40); trackFrame.BorderSizePixel = 0; trackFrame.Parent = row
    corner(trackFrame, 4)

    local fillFrame = Instance.new("Frame")
    fillFrame.Size = UDim2.new((defaultVal - minVal) / (maxVal - minVal), 0, 1, 0)
    fillFrame.BackgroundColor3 = CONFIG.Accent; fillFrame.BorderSizePixel = 0; fillFrame.Parent = trackFrame
    corner(fillFrame, 4)

    local dragging = false
    local function update(input)
        local percent = math.clamp((input.Position.X - trackFrame.AbsolutePosition.X) / trackFrame.AbsoluteSize.X, 0, 1)
        local val = math.floor(minVal + (maxVal - minVal) * percent)
        fillFrame.Size = UDim2.new(percent, 0, 1, 0)
        valLabel.Text = tostring(val)
        if callback then callback(val) end
    end

    trackFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true; update(input); playSound()
        end
    end)
    trackFrame.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
    end)
    UIS.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then update(input) end
    end)
    
    return {Update = function(v) 
        local p = (v - minVal)/(maxVal-minVal)
        fillFrame.Size = UDim2.new(p,0,1,0); valLabel.Text = tostring(v)
    end}
end

local function makeTextBox(page, titleText, placeholder, defaultText, callback)
    local row = Instance.new("Frame")
    row.Size = UDim2.new(1, -4, 0, 58); row.BackgroundColor3 = CONFIG.Panel; row.BorderSizePixel = 0; row.Parent = page
    corner(row, 7); stroke(row, Color3.fromRGB(42, 35, 55), 1)
    local t = label(row, titleText, 12, UDim2.fromOffset(13, 7), CONFIG.Text, Enum.Font.GothamBold)
    t.Size = UDim2.fromOffset(210, 18)
    local box = Instance.new("TextBox")
    box.Size = UDim2.fromOffset(250, 30); box.Position = UDim2.new(1, -265, 0, 14)
    box.BackgroundColor3 = Color3.fromRGB(24, 20, 31); box.BorderSizePixel = 0
    box.Text = defaultText or ""; box.PlaceholderText = placeholder or ""
    box.TextColor3 = CONFIG.Text; box.PlaceholderColor3 = CONFIG.Muted
    box.Font = Enum.Font.Gotham; box.TextSize = 11; box.ClearTextOnFocus = false; box.Parent = row; corner(box, 6)
    box.FocusLost:Connect(function(enter) if callback then callback(box.Text, enter) end end)
    return box
end

local function makeButton(page, titleText, descText, callback)
    local row = Instance.new("TextButton")
    row.Size = UDim2.new(1, -4, 0, 48); row.BackgroundColor3 = CONFIG.Panel; row.BorderSizePixel = 0
    row.Text = ""; row.AutoButtonColor = false; row.Parent = page; corner(row, 7); stroke(row, Color3.fromRGB(42, 35, 55), 1)
    local t = label(row, titleText, 12, UDim2.fromOffset(13, 6), CONFIG.Text, Enum.Font.GothamBold)
    t.Size = UDim2.new(1, -25, 0, 18)
    local d = label(row, descText, 10, UDim2.fromOffset(13, 25), CONFIG.Muted, Enum.Font.Gotham)
    d.Size = UDim2.new(1, -25, 0, 16)
    row.MouseEnter:Connect(function() tween(row, TweenInfo.new(0.12), {BackgroundColor3 = CONFIG.Panel2}):Play() end)
    row.MouseLeave:Connect(function() tween(row, TweenInfo.new(0.12), {BackgroundColor3 = CONFIG.Panel}):Play() end)
    row.MouseButton1Click:Connect(function() if callback then callback(); playSound() end end)
    return row
end

-- ==================================================
-- PAGES SETUP
-- ==================================================
local Home       = createPage("Inicio")
local PlayerPage = createPage("Jugador")
local Exploits   = createPage("Exploits")
local Render     = createPage("Render")
local Mundos     = createPage("Juegos")
local Config     = createPage("Config")
local Credits    = createPage("Créditos")
local Addons     = createPage("Addons")

-- HOME
makeSection(Home, T("SYSTEM"))
local avatarFrame = Instance.new("Frame")
avatarFrame.Size = UDim2.new(1, -4, 0, 90); avatarFrame.BackgroundColor3 = CONFIG.Panel; avatarFrame.BorderSizePixel = 0; avatarFrame.Parent = Home
corner(avatarFrame, 7); stroke(avatarFrame, Color3.fromRGB(42, 35, 55), 1)
local avatarImg = Instance.new("ImageLabel")
avatarImg.Size = UDim2.fromOffset(64, 64); avatarImg.Position = UDim2.fromOffset(14, 13)
avatarImg.BackgroundColor3 = CONFIG.AccentDark; avatarImg.ScaleType = Enum.ScaleType.Fit; avatarImg.Parent = avatarFrame; corner(avatarImg, 8)
task.spawn(function()
    local ok, content = pcall(function() return Players:GetUserThumbnailAsync(LocalPlayer.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size100x100) end)
    if ok and content then avatarImg.Image = content else avatarImg.Image = CONFIG.Logo end
end)
label(avatarFrame, LocalPlayer.DisplayName, 16, UDim2.fromOffset(90, 18), CONFIG.Text, Enum.Font.GothamBlack).Size = UDim2.fromOffset(300, 22)
label(avatarFrame, "@" .. LocalPlayer.Name, 11, UDim2.fromOffset(90, 42), CONFIG.Muted, Enum.Font.Gotham).Size = UDim2.fromOffset(300, 18)
label(avatarFrame, "Juego: " .. getGameName(), 10, UDim2.fromOffset(90, 62), CONFIG.Accent2, Enum.Font.Gotham).Size = UDim2.fromOffset(500, 16)

makeButton(Home, "600x Hub", "Interfaz personalizada · " .. CONFIG.Version, nil)
makeSection(Home, T("STATUS"))
makeButton(Home, T("Version"), CONFIG.Version .. " · GUI Completo", nil)
makeButton(Home, T("Executor"), detectExecutor() .. " · detectado", nil)
makeButton(Home, "Juego Detectado", getGameName(), nil)

-- PLAYER
makeSection(PlayerPage, "JUGADOR")
local flyToggle     = makeToggle(PlayerPage, T("Fly"), "Vuelo seguro (WASD + Space/Ctrl)", "T")
local infJumpToggle = makeToggle(PlayerPage, T("InfJump"), "Salto infinito", "F")
local invisToggle   = makeToggle(PlayerPage, T("Invis"), "Invis + limpieza de GUI", "I")
local desyncToggle  = makeToggle(PlayerPage, T("Desync"), "Clone · Fly · Noclip", "G")

-- DESYNC CONFIG (Inside Hub - No separate panel)
makeSection(PlayerPage, T("DesyncConfig"))
local desyncTpToggle = makeToggle(PlayerPage, T("Teleport"), "TP al desactivar desync", "")
local desyncHideToggle = makeToggle(PlayerPage, T("Hide"), "Ocultar cuerpo real", "")
local desyncNoclipToggle = makeToggle(PlayerPage, T("Noclip"), "Atravesar paredes", "")
local desyncFlyToggle = makeToggle(PlayerPage, "Desync Fly", "Vuelo en modo desync", "")
makeSlider(PlayerPage, T("Speed"), 1, 100, 16, function(v) getgenv().DesyncSpeed = v end)
makeSlider(PlayerPage, T("Jump"), 1, 200, 50, function(v) getgenv().DesyncJump = v end)

makeButton(PlayerPage, "Reset UI", "Restablecer posición de la interfaz", function() Main.Position = UDim2.new(0.5, -425, 0.5, -295); playSound() end)

-- EXPLOITS
makeSection(Exploits, T("FEATURES"))
local reach1Toggle  = makeToggle(Exploits, T("Reach1"), "Sphere/Line reach", "H")
local reach2Toggle  = makeToggle(Exploits, T("Reach2"), "Target reach", "Z")
local reach3Toggle  = makeToggle(Exploits, T("Reach3"), "Teclas editables: aumentar / disminuir", "R/Q")
local auraToggle    = makeToggle(Exploits, T("MineAura"), "Auto minar", "V")
local silentToggle  = makeToggle(Exploits, T("SilentAim"), "Predicción (Sin FOV)", "E")
local spyToggle     = makeToggle(Exploits, T("SpyChat"), "Ver chat de todos", "P")
local espToggle     = makeToggle(Exploits, T("ESP"), "Nombre · Vida · Distancia", "K")
local iyToggle      = makeToggle(Exploits, T("InfiniteYield"), "Admin commands", "Y")
local doubleToggle  = makeToggle(Exploits, T("DoubleHit"), "Alcance + golpes dobles", "B")

makeSlider(Exploits, "Rango Reach 1", 1, 50, 3.5, function(v) getgenv().Reach1Range = v end)
makeSlider(Exploits, "Rango Reach 2", 1, 50, 4, function(v) getgenv().Reach2Range = v end)
makeSlider(Exploits, "Rango Reach 3", 1, 50, 4, function(v) getgenv().Reach3Range = v end)
makeSlider(Exploits, "Rango Aura", 1, 100, 25, function(v) getgenv().AuraRange = v end)

-- DOUBLE HIT CONFIG (Inside Hub)
makeSection(Exploits, T("DoubleHitConfig"))
makeSlider(Exploits, "Alcance Double Hit", 1, 50, 14, function(v) getgenv().DoubleHitRange = v end)
makeSlider(Exploits, T("Probability") .. " (%)", 0, 100, 100, function(v) getgenv().DoubleHitChance = v end)

makeSection(Exploits, T("BLACKLIST"))
makeTextBox(Exploits, "Blacklist Player", "Escribe un nombre...", "", function(text)
    if text and text ~= "" then table.insert(getgenv().DontShootThesePeople, text); print("[600x] Blacklist:", text); playSound() end
end)

-- RENDER
makeSection(Render, "VISUAL")
local purpleSkyToggle   = makeToggle(Render, T("PurpleSky"), "Cambiar visualmente el cielo", "")
local customLightToggle = makeToggle(Render, T("CustomLighting"), "Control visual de iluminación", "")
local worldTintToggle   = makeToggle(Render, T("WorldTint"), "Aplicar tinte al ambiente", "")
makeSection(Render, T("COLOR"))
makeButton(Render, "Accent Color", "Cambiar el color principal", function() if ColorPickerGui then ColorPickerGui.Enabled = true; playSound() end end)

-- MUNDOS
makeSection(Mundos, T("GAME_DETECT"))
makeButton(Mundos, "Juego Actual", getGameName(), nil)
makeButton(Mundos, "Place ID", tostring(game.PlaceId), nil)
makeSection(Mundos, T("PRESETS"))
makeButton(Mundos, "Natural Disaster Survival", "Subir altura + fly rápido", function()
    local char = LocalPlayer.Character
    if char and char:FindFirstChild("HumanoidRootPart") then char.HumanoidRootPart.CFrame = char.HumanoidRootPart.CFrame + Vector3.new(0, 80, 0) end
    flyToggle.Set(true); playSound()
end)

-- CONFIG
makeSection(Config, T("GUI"))
makeButton(Config, T("Theme"), "Abrir selector de color", function() if ColorPickerGui then ColorPickerGui.Enabled = true; playSound() end end)
local animBorderToggle = makeToggle(Config, T("Animated_Border"), "Animación del borde", "")
makeSection(Config, "IDIOMA / LANGUAGE")
makeButton(Config, "Español", "Cambiar a español", function() LANG = "es"; print("[600x] Idioma → Español"); playSound() end)
makeButton(Config, "English", "Switch to English", function() LANG = "en"; print("[600x] Language → English"); playSound() end)
makeSection(Config, T("RESET"))
makeButton(Config, T("Reset_Settings"), "Restablecer configuración visual", function()
    CONFIG.Accent = Color3.fromRGB(145, 65, 255); CONFIG.Accent2 = Color3.fromRGB(185, 100, 255)
    MainStroke.Color = CONFIG.Accent; playSound()
end)

-- CREDITS
makeSection(Credits, "600x HUB")
makeButton(Credits, T("Creator"), "Gere / GzlyvchDraevanther · Kevin / iiddeennx", nil)
local creditImage = Instance.new("ImageLabel")
creditImage.Size = UDim2.new(1, -4, 0, 170); creditImage.BackgroundColor3 = CONFIG.Panel; creditImage.BorderSizePixel = 0
creditImage.Image = CONFIG.Logo; creditImage.ScaleType = Enum.ScaleType.Fit; creditImage.Parent = Credits; corner(creditImage, 8); stroke(creditImage, CONFIG.AccentDark, 1)
makeButton(Credits, T("Logo_Asset"), "85029161626386", nil)

-- ADDONS (Fixed)
makeSection(Addons, T("ADDONS"))
makeTextBox(Addons, "Cargar Script (URL)", "Pega URL raw...", "", function(text, enter)
    if not enter or not text or text == "" then return end
    if text:find("http") then
        local success, result = pcall(function()
            return game:HttpGet(text)
        end)
        if success and result then
            local loadSuccess, loadErr = pcall(function()
                loadstring(result)()
            end)
            if loadSuccess then
                print("[600x Addons] Script cargado correctamente")
            else
                warn("[600x Addons] Error al cargar:", loadErr)
            end
        else
            warn("[600x Addons] Error al obtener URL:", result)
        end
    else
        local success, err = pcall(function()
            loadstring(text)()
        end)
        if success then
            print("[600x Addons] Script cargado correctamente")
        else
            warn("[600x Addons] Error:", err)
        end
    end
    playSound()
end)
makeButton(Addons, "Addon Slot 01", "Espacio para función", nil)
makeButton(Addons, "Addon Slot 02", "Espacio para función", nil)
makeButton(Addons, "Addon Slot 03", "Espacio para función", nil)
makeButton(Addons, "Addon Slot 04", "Espacio para función", nil)

-- NAVIGATION LOGIC
local function showPage(name)
    for pageName, page in pairs(pages) do page.Visible = (pageName == name) end
    PageTitle.Text = name; PageSub.Text = "600x Hub  ·  " .. getGameName()
    for buttonName, data in pairs(navButtons) do
        local selected = buttonName == name
        tween(data.Button, TweenInfo.new(0.15), {BackgroundColor3 = selected and Color3.fromRGB(45, 22, 70) or Color3.fromRGB(11, 10, 15)}):Play()
        tween(data.Icon, TweenInfo.new(0.15), {TextColor3 = selected and CONFIG.Accent2 or CONFIG.Muted}):Play()
        tween(data.Text, TweenInfo.new(0.15), {TextColor3 = selected and CONFIG.Text or CONFIG.Muted}):Play()
    end
end
for name, data in pairs(navButtons) do data.Button.MouseButton1Click:Connect(function() showPage(name); playSound() end) end
showPage("Inicio")

-- FOOTER
local Footer = Instance.new("TextLabel")
Footer.Name = "Footer"; Footer.Size = UDim2.new(1, -25, 0, 20); Footer.Position = UDim2.new(0, 12, 1, -24)
Footer.BackgroundTransparency = 1; Footer.Text = CONFIG.Version .. "  |  600x  |  " .. getGameName() .. "  |  " .. detectExecutor()
Footer.TextColor3 = Color3.fromRGB(105, 98, 115); Footer.Font = Enum.Font.Code; Footer.TextSize = 10; Footer.TextXAlignment = Enum.TextXAlignment.Center; Footer.Parent = Main

-- ==================================================
-- COLOR PICKER GUI
-- ==================================================
local ColorPickerGui = trackGui(Instance.new("ScreenGui"))
ColorPickerGui.Name = "600xColorPicker"; ColorPickerGui.ResetOnSpawn = false; ColorPickerGui.Enabled = false; ColorPickerGui.Parent = PlayerGui
local CPFrame = Instance.new("Frame")
CPFrame.Size = UDim2.fromOffset(280, 340); CPFrame.Position = UDim2.new(0.5, -140, 0.5, -170)
CPFrame.BackgroundColor3 = CONFIG.Panel; CPFrame.BorderSizePixel = 0; CPFrame.Active = true; CPFrame.Draggable = true; CPFrame.Parent = ColorPickerGui
corner(CPFrame, 10); stroke(CPFrame, CONFIG.Accent, 2)
label(CPFrame, "Color System · 600x", 14, UDim2.fromOffset(12, 10), CONFIG.Accent2, Enum.Font.GothamBlack).Size = UDim2.fromOffset(220, 22)

local function makeRGBBox(parent, x, default, placeholder)
    local box = Instance.new("TextBox"); box.Size = UDim2.fromOffset(70, 28); box.Position = UDim2.fromOffset(x, 50)
    box.BackgroundColor3 = Color3.fromRGB(25, 15, 40); box.Text = tostring(default); box.PlaceholderText = placeholder
    box.TextColor3 = CONFIG.Text; box.Font = Enum.Font.GothamBold; box.TextSize = 13; box.Parent = parent; corner(box, 6); return box
end
local rBox = makeRGBBox(CPFrame, 20, 145, "R"); local gBox = makeRGBBox(CPFrame, 100, 65, "G"); local bBox = makeRGBBox(CPFrame, 180, 255, "B")
local preview = Instance.new("Frame"); preview.Size = UDim2.fromOffset(230, 40); preview.Position = UDim2.fromOffset(25, 95)
preview.BackgroundColor3 = CONFIG.Accent; preview.Parent = CPFrame; corner(preview, 8)
local applyBtn = Instance.new("TextButton")
applyBtn.Size = UDim2.fromOffset(230, 32); applyBtn.Position = UDim2.fromOffset(25, 150)
applyBtn.BackgroundColor3 = CONFIG.AccentDark; applyBtn.Text = "Aplicar Color"; applyBtn.TextColor3 = CONFIG.Text
applyBtn.Font = Enum.Font.GothamBold; applyBtn.TextSize = 13; applyBtn.Parent = CPFrame; corner(applyBtn, 7)
applyBtn.MouseButton1Click:Connect(function()
    local r = math.clamp(tonumber(rBox.Text) or 145, 0, 255); local g = math.clamp(tonumber(gBox.Text) or 65, 0, 255); local b = math.clamp(tonumber(bBox.Text) or 255, 0, 255)
    local newCol = Color3.fromRGB(r, g, b); CONFIG.Accent = newCol
    CONFIG.Accent2 = Color3.fromRGB(math.min(255, r + 40), math.min(255, g + 35), math.min(255, b))
    MainStroke.Color = newCol; preview.BackgroundColor3 = newCol; playSound()
end)
local closeCP = Instance.new("TextButton")
closeCP.Size = UDim2.fromOffset(230, 28); closeCP.Position = UDim2.fromOffset(25, 290)
closeCP.BackgroundColor3 = Color3.fromRGB(60, 20, 40); closeCP.Text = "Cerrar"; closeCP.TextColor3 = Color3.fromRGB(255, 180, 200)
closeCP.Font = Enum.Font.GothamBold; closeCP.TextSize = 12; closeCP.Parent = CPFrame; corner(closeCP, 6)
closeCP.MouseButton1Click:Connect(function() ColorPickerGui.Enabled = false; playSound() end)

-- ==================================================
-- FUNCTIONALITY IMPLEMENTATION
-- ==================================================

-- SILENT AIM
local SilentAim = true
local Options = {Torso = "HumanoidRootPart", Head = "Head"}
local oldIndex
oldIndex = hookmetamethod(game, "__index", function(self, Index)
    local result = oldIndex(self, Index)
    if self == Mouse and typeof(Index) == "string" and Index:lower() == "hit" then
        if not SilentAim then return result end
        local Distance, Target = 9e9, nil
        for _, v in pairs(Players:GetPlayers()) do
            if not table.find(getgenv().DontShootThesePeople, v.Name)
                and v ~= LocalPlayer and v.Character and v.Character:FindFirstChild("HumanoidRootPart")
                and v.Character:FindFirstChild("Humanoid") and v.Character.Humanoid.Health > 0 then
                local Enemy = v.Character
                local RootPartPosition, Visible = Camera:WorldToScreenPoint(Enemy[Options.Torso].Position)
                if Visible then
                    local Real_Magnitude = (Vector2.new(Mouse.X, Mouse.Y) - Vector2.new(RootPartPosition.X, RootPartPosition.Y)).Magnitude
                    if Real_Magnitude < Distance and Real_Magnitude < getgenv().FOV then
                        Distance = Real_Magnitude; Target = Enemy
                    end
                end
            end
        end
        if Target and Target[Options.Torso] and Target.Humanoid.Health > 0 then
            local Madox = Target[Options.Torso]
            local Formulate = Madox.CFrame + (Madox.AssemblyLinearVelocity * getgenv().Prediction + Vector3.new(0, -1, 0))
            return Formulate
        end
    end
    return result
end)
silentToggle.OnChange(function(state) SilentAim = state end)
silentToggle.Set(true, true)

-- ESP
local espOn = false; local ESPObjects = {}; local espConn = nil
local function ClearESP()
    for _, obj in pairs(ESPObjects) do
        pcall(function() if obj.Box then obj.Box:Remove() end; if obj.Name then obj.Name:Remove() end; if obj.Dist then obj.Dist:Remove() end; if obj.Health then obj.Health:Remove() end; if obj.Highlight then obj.Highlight:Destroy() end end)
    end; ESPObjects = {}
end
local function CreateESP(plr)
    if ESPObjects[plr] then return end
    local box = Drawing.new("Square"); box.Visible = false; box.Color = Color3.fromRGB(140, 60, 255); box.Thickness = 1; box.Filled = false
    local name = Drawing.new("Text"); name.Visible = false; name.Color = Color3.fromRGB(255, 255, 255); name.Size = 14; name.Center = true; name.Outline = true
    local dist = Drawing.new("Text"); dist.Visible = false; dist.Color = Color3.fromRGB(180, 255, 120); dist.Size = 13; dist.Center = true; dist.Outline = true
    local health = Drawing.new("Text"); health.Visible = false; health.Color = Color3.fromRGB(255, 100, 100); health.Size = 13; health.Center = true; health.Outline = true
    local highlight = Instance.new("Highlight"); highlight.FillColor = Color3.fromRGB(140, 60, 255); highlight.OutlineColor = Color3.fromRGB(200, 140, 255); highlight.FillTransparency = 0.7; highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop; highlight.Enabled = false
    ESPObjects[plr] = {Box = box, Name = name, Dist = dist, Health = health, Highlight = highlight}
end
local function UpdateESP()
    if not espOn then return end
    local myRoot = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    for _, plr in pairs(Players:GetPlayers()) do
        if plr == LocalPlayer then continue end
        if not ESPObjects[plr] then CreateESP(plr) end
        local obj = ESPObjects[plr]; local char = plr.Character; local hum = char and char:FindFirstChildOfClass("Humanoid"); local root = char and char:FindFirstChild("HumanoidRootPart")
        if char and hum and root and hum.Health > 0 then
            local pos, onScreen = Camera:WorldToViewportPoint(root.Position)
            if onScreen then
                local size = Vector2.new(1800 / pos.Z, 2500 / pos.Z)
                obj.Box.Size = size; obj.Box.Position = Vector2.new(pos.X - size.X/2, pos.Y - size.Y/2); obj.Box.Visible = true
                obj.Name.Text = plr.Name; obj.Name.Position = Vector2.new(pos.X, pos.Y - size.Y/2 - 18); obj.Name.Visible = true
                local distance = myRoot and math.floor((myRoot.Position - root.Position).Magnitude) or 0
                obj.Dist.Text = distance .. " studs"; obj.Dist.Position = Vector2.new(pos.X, pos.Y + size.Y/2 + 4); obj.Dist.Visible = true
                obj.Health.Text = math.floor(hum.Health) .. " / " .. math.floor(hum.MaxHealth); obj.Health.Position = Vector2.new(pos.X, pos.Y + size.Y/2 + 18); obj.Health.Visible = true
                obj.Highlight.Adornee = char; obj.Highlight.Parent = char; obj.Highlight.Enabled = true
            else
                obj.Box.Visible = false; obj.Name.Visible = false; obj.Dist.Visible = false; obj.Health.Visible = false; obj.Highlight.Enabled = false
            end
        else obj.Box.Visible = false; obj.Name.Visible = false; obj.Dist.Visible = false; obj.Health.Visible = false; obj.Highlight.Enabled = false end
    end
end
espToggle.OnChange(function(state)
    espOn = state; if espConn then espConn:Disconnect() espConn = nil end
    if not state then ClearESP() return end
    espConn = track(RunService.RenderStepped:Connect(UpdateESP))
end)

-- FLY
local flyOn = false; local flyConn = nil; local flyKeys = {W=false, A=false, S=false, D=false, Space=false, Ctrl=false}
local function getFlyHRP() local c = LocalPlayer.Character; return c and c:FindFirstChild("HumanoidRootPart") end
local function StopFly()
    if not flyOn then return end; flyOn = false; flyToggle.Set(false, true)
    if flyConn then flyConn:Disconnect() flyConn = nil end
    local hrp = getFlyHRP(); if hrp then for _, v in pairs(hrp:GetChildren()) do if v:IsA("LinearVelocity") or v:IsA("AlignOrientation") or v.Name == "SafeFlyAtt" then pcall(function() v:Destroy() end) end end end
    local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid"); if hum then hum.PlatformStand = false; hum.AutoRotate = true end
end
local function StartFly()
    if flyOn then return end; local hrp = getFlyHRP(); if not hrp then return end
    flyOn = true; flyToggle.Set(true, true)
    local hum = LocalPlayer.Character:FindFirstChildOfClass("Humanoid"); if hum then hum.PlatformStand = true; hum.AutoRotate = false end
    local att = Instance.new("Attachment"); att.Name = "SafeFlyAtt"; att.Parent = hrp
    local lv = Instance.new("LinearVelocity"); lv.Attachment0 = att; lv.MaxForce = 80000; lv.RelativeTo = Enum.ActuatorRelativeTo.World; lv.Parent = hrp
    local ao = Instance.new("AlignOrientation"); ao.Mode = Enum.OrientationAlignmentMode.OneAttachment; ao.Attachment0 = att; ao.RigidityEnabled = true; ao.MaxTorque = 40000; ao.Parent = hrp
    flyConn = track(RunService.Heartbeat:Connect(function()
        if not flyOn then return end; hrp = getFlyHRP(); if not hrp then StopFly() return end
        local move = Vector3.zero; local look = Camera.CFrame.LookVector; local right = Camera.CFrame.RightVector
        if flyKeys.W then move = move + look end; if flyKeys.S then move = move - look end
        if flyKeys.A then move = move - right end; if flyKeys.D then move = move + right end
        if flyKeys.Space then move = move + Vector3.yAxis end; if flyKeys.Ctrl then move = move - Vector3.yAxis end
        if move.Magnitude > 0 then move = move.Unit * 55 end
        lv.VectorVelocity = move; ao.CFrame = Camera.CFrame
    end))
end
flyToggle.OnChange(function(state) if state then StartFly(); playSound() else StopFly(); playSound() end end)

-- INF JUMP
local infJumpOn = false; local infJumpConn = nil
infJumpToggle.OnChange(function(state)
    infJumpOn = state; infJumpToggle.Set(state, true)
    if infJumpConn then infJumpConn:Disconnect() infJumpConn = nil end
    if not state then return end
    infJumpConn = track(UIS.JumpRequest:Connect(function()
        if infJumpOn and LocalPlayer.Character then local hum = LocalPlayer.Character:FindFirstChildOfClass("Humanoid"); if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end end
    end))
end)

-- REACH 1
local reach1On = false; local reach1Conn = nil
local function GetPlayer(str)
    local Found = {}; str = tostring(str or ""):lower()
    if str == "all" then for _, v in pairs(Players:GetPlayers()) do table.insert(Found, v) end
    elseif str == "others" then for _, v in pairs(Players:GetPlayers()) do if v ~= LocalPlayer then table.insert(Found, v) end end
    elseif str == "me" then table.insert(Found, LocalPlayer)
    else for _, v in pairs(Players:GetPlayers()) do if v.Name:lower():sub(1, #str) == str then table.insert(Found, v) end end end
    return Found
end

local function SetReach1(state)
    reach1On = state; reach1Toggle.Set(state, true)
    if reach1Conn then reach1Conn:Disconnect() reach1Conn = nil end
    if not state then return end
    reach1Conn = track(RunService.Heartbeat:Connect(function()
        if not reach1On then return end
        local char = LocalPlayer.Character; if not char then return end
        local tool = char:FindFirstChildOfClass("Tool"); if not tool then return end
        local handle = tool:FindFirstChild("Handle") or tool:FindFirstChildOfClass("BasePart"); if not handle then return end
        local reachSize = getgenv().Reach1Range or 3.5
        for _, pl in ipairs(GetPlayer("others")) do
            if pl and pl ~= LocalPlayer and pl.Character and pl.Character.Parent then
                local hrp = pl.Character:FindFirstChild("HumanoidRootPart") or pl.Character:FindFirstChild("Torso")
                if hrp and (hrp.Position - handle.Position).Magnitude <= reachSize then
                    pcall(function() firetouchinterest(handle, hrp, 0); firetouchinterest(handle, hrp, 1) end)
                end
            end
        end
    end))
end
reach1Toggle.OnChange(function(state) SetReach1(state); playSound() end)

-- REACH 2
local reach2On = false; local reach2Conn = nil
local function SetReach2(state)
    reach2On = state; reach2Toggle.Set(state, true)
    if reach2Conn then reach2Conn:Disconnect() reach2Conn = nil end
    if not state then return end
    reach2Conn = track(RunService.Heartbeat:Connect(function()
        if not reach2On then return end
        local char = LocalPlayer.Character; if not char then return end
        local tool = char:FindFirstChildOfClass("Tool"); if not tool then return end
        local handle = tool:FindFirstChild("Handle"); if not handle then return end
        local reachSize = getgenv().Reach2Range or 4
        for _, pl in ipairs(GetPlayer("others")) do
            if pl and pl ~= LocalPlayer and pl.Character then
                local hrp = pl.Character:FindFirstChild("HumanoidRootPart")
                if hrp and (handle.Position - hrp.Position).Magnitude <= reachSize then
                    pcall(function() firetouchinterest(handle, hrp, 0); firetouchinterest(handle, hrp, 1) end)
                end
            end
        end
    end))
end
reach2Toggle.OnChange(function(state) SetReach2(state); playSound() end)

-- REACH 3
local reach3On = false; local reach3Conn = nil; local lastR, lastQ = 0, 0
local function SetReach3(state)
    reach3On = state; reach3Toggle.Set(state, true)
    if reach3Conn then reach3Conn:Disconnect() reach3Conn = nil end
    if not state then return end
    reach3Conn = track(RunService.Heartbeat:Connect(function()
        if not reach3On then return end
        local char = LocalPlayer.Character; if not char then return end
        local tool = char:FindFirstChildOfClass("Tool"); if not tool or not tool:FindFirstChild("Handle") then return end
        local handle = tool.Handle
        local reachSize = getgenv().Reach3Range or 4
        for _, pl in pairs(Players:GetPlayers()) do
            if pl ~= LocalPlayer and pl.Character then
                local hum = pl.Character:FindFirstChildOfClass("Humanoid")
                local head = pl.Character:FindFirstChild("Head")
                if hum and hum.Health > 0 and head and (handle.Position - head.Position).Magnitude <= reachSize then
                    for _, p in pairs(pl.Character:GetChildren()) do
                        if p:IsA("BasePart") then
                            pcall(function() firetouchinterest(handle, p, 0); firetouchinterest(handle, p, 1) end)
                        end
                    end
                end
            end
        end
    end))
end
reach3Toggle.OnChange(function(state) SetReach3(state); playSound() end)

-- MINE AURA
local auraOn = false; local auraConn = nil
local function SetAura(state)
    auraOn = state; auraToggle.Set(state, true)
    if auraConn then auraConn:Disconnect() auraConn = nil end
    if not state then return end
    auraConn = track(RunService.Heartbeat:Connect(function()
        if not auraOn then return end
        local char = LocalPlayer.Character; if not char then return end
        local hrp = char:FindFirstChild("HumanoidRootPart"); if not hrp then return end
        local axe = LocalPlayer.Backpack:FindFirstChild("Axe") or char:FindFirstChild("Axe"); if not axe then return end
        local remote = axe:FindFirstChild("RemoteEvent"); if not remote then return end
        local range = getgenv().AuraRange or 25
        for _, item in pairs(workspace:GetDescendants()) do
            if item:IsA("BasePart") and item.Name == "Block" and (hrp.Position - item.Position).Magnitude <= range then
                pcall(function() remote:FireServer(item) end)
            end
        end
    end))
end
auraToggle.OnChange(function(state) SetAura(state); playSound() end)

-- DOUBLE HIT (With range and probability sliders)
local doubleOn = false; local doubleConn = nil
doubleToggle.OnChange(function(state)
    doubleOn = state; doubleToggle.Set(state, true)
    if doubleConn then doubleConn:Disconnect() doubleConn = nil end
    if not state then return end
    doubleConn = track(RunService.RenderStepped:Connect(function()
        local myChar = LocalPlayer.Character; if not myChar then return end
        local tool = myChar:FindFirstChildOfClass("Tool"); if not tool then return end
        local handle = tool:FindFirstChild("Handle"); if not handle then return end
        local range = getgenv().DoubleHitRange or 14
        local chance = getgenv().DoubleHitChance or 100
        
        -- Check probability
        if math.random(1, 100) > chance then return end
        
        for _, target in ipairs(Players:GetPlayers()) do
            if target ~= LocalPlayer then
                local char = target.Character; if char then
                    local hum = char:FindFirstChildOfClass("Humanoid"); local head = char:FindFirstChild("Head")
                    if hum and hum.Health > 0 and head and LocalPlayer:DistanceFromCharacter(head.Position) <= range then
                        pcall(function() tool:Activate() end)
                        for _, part in ipairs(char:GetChildren()) do if part:IsA("BasePart") then pcall(function() firetouchinterest(handle, part, 0); firetouchinterest(handle, part, 1) end) end end
                    end
                end
            end
        end
    end))
end)

-- SPY CHAT
local spyOn = false; local spyConns = {}
local function sendSpy(msg)
    local channel = TextChatService.TextChannels:FindFirstChild("RBXGeneral")
    if channel then channel:DisplaySystemMessage("<font color='#aa00ff'>" .. msg .. "</font>") end
end
spyToggle.OnChange(function(state)
    spyOn = state; spyToggle.Set(state, true)
    for _, c in pairs(spyConns) do pcall(function() c:Disconnect() end) end; spyConns = {}
    if not state then return end; sendSpy("SPY ENABLED"); playSound()
    local function hook(plr) table.insert(spyConns, plr.Chatted:Connect(function(msg) local text = "[SPY] " .. plr.Name .. ": " .. msg; print(text); sendSpy(text) end)) end
    for _, p in pairs(Players:GetPlayers()) do if p ~= LocalPlayer then hook(p) end end
    table.insert(spyConns, Players.PlayerAdded:Connect(hook))
end)

-- INFINITE YIELD
iyToggle.OnChange(function(state)
    if state then pcall(function() loadstring(game:HttpGet("https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source"))(); playSound() end) end
end)

-- INVIS
local invisOn = false
invisToggle.OnChange(function(state)
    invisOn = state; invisToggle.Set(state, true)
    local char = LocalPlayer.Character
    if state then
        pcall(function() loadstring(game:HttpGet("https://pastebin.com/raw/Mwxbt9pp"))(); playSound() end)
    else
        if char then for _, v in pairs(char:GetDescendants()) do if v:IsA("BasePart") then if v.Name == "HumanoidRootPart" then v.Transparency = 1 else v.Transparency = 0 end end end end
    end
end)

-- ==================================================
-- DESYNC (COMPLETELY REWRITTEN - WORKING)
-- ==================================================
local desyncOn = false
local desyncClone = nil
local originalChar = nil
local originalCF = nil
local desyncConn = nil
local desyncFlyConn = nil

-- Desync config values (from toggles/sliders)
local desyncTpOnClose = true
local desyncHideReal = false
local desyncNoclip = false
local desyncFlyMode = false

desyncTpToggle.OnChange(function(state) desyncTpOnClose = state; playSound() end)
desyncHideToggle.OnChange(function(state) desyncHideReal = state; playSound() end)
desyncNoclipToggle.OnChange(function(state) desyncNoclip = state; playSound() end)
desyncFlyToggle.OnChange(function(state) desyncFlyMode = state; playSound() end)

local function StopDesync()
    if not desyncOn then return end
    desyncOn = false
    desyncToggle.Set(false, true)
    playSound()
    
    -- Disconnect connections
    if desyncConn then desyncConn:Disconnect(); desyncConn = nil end
    if desyncFlyConn then desyncFlyConn:Disconnect(); desyncFlyConn = nil end
    
    -- Remove clone safely
    if desyncClone then
        pcall(function() 
            if desyncClone.Parent then desyncClone:Destroy() end
        end)
        desyncClone = nil
    end
    
    -- Restore original character
    if originalChar and originalChar.Parent then
        pcall(function()
            local root = originalChar:FindFirstChild("HumanoidRootPart")
            local hum = originalChar:FindFirstChildOfClass("Humanoid")
            
            -- Restore all parts
            for _, v in pairs(originalChar:GetDescendants()) do
                if v:IsA("BasePart") then
                    v.CanCollide = true
                    v.Anchored = false
                    if v.Name ~= "HumanoidRootPart" then
                        v.Transparency = 0
                    else
                        v.Transparency = 1
                    end
                end
            end
            
            if root then
                root.Anchored = false
                root.CanCollide = true
                if desyncTpOnClose and originalCF then
                    root.CFrame = originalCF
                end
            end
            
            if hum then
                hum.PlatformStand = false
                Camera.CameraSubject = hum
            end
            
            -- Reset character reference
            pcall(function() LocalPlayer.Character = originalChar end)
        end)
    end
    
    originalChar = nil
    originalCF = nil
    print("[600x] Desync desactivado correctamente")
end

local function StartDesync()
    if desyncOn then return end
    
    -- Wait for character to be ready
    local char = LocalPlayer.Character
    if not char then 
        print("[600x] Esperando character...")
        char = LocalPlayer.CharacterAdded:Wait()
    end
    
    local root = char:FindFirstChild("HumanoidRootPart")
    local hum = char:FindFirstChildOfClass("Humanoid")
    
    if not root or not hum then 
        print("[600x] Error: No root o humanoid encontrado")
        return 
    end
    
    if hum.Health <= 0 then
        print("[600x] Error: Personaje muerto")
        return
    end
    
    desyncOn = true
    desyncToggle.Set(true, true)
    playSound()
    
    -- Save original state
    originalChar = char
    originalCF = root.CFrame
    
    -- Clone character safely
    local success, clone = pcall(function()
        char.Archivable = true
        local c = char:Clone()
        c.Name = "DesyncClone_" .. tostring(math.random(1000, 9999))
        c.Parent = workspace
        return c
    end)
    
    if not success or not clone then
        print("[600x] Error al clonar:", clone)
        StopDesync()
        return
    end
    
    desyncClone = clone
    
    -- Setup clone
    local cloneRoot = clone:FindFirstChild("HumanoidRootPart")
    local cloneHum = clone:FindFirstChildOfClass("Humanoid")
    
    if not cloneRoot or not cloneHum then
        print("[600x] Error: Clone sin root o humanoid")
        StopDesync()
        return
    end
    
    -- Clean clone (remove scripts safely)
    pcall(function()
        for _, v in pairs(clone:GetDescendants()) do
            if v:IsA("Script") or v:IsA("LocalScript") or v:IsA("ModuleScript") then
                v:Destroy()
            end
        end
    end)
    
    -- Setup clone parts
    pcall(function()
        for _, v in pairs(clone:GetDescendants()) do
            if v:IsA("BasePart") then
                v.CanCollide = (v.Name == "HumanoidRootPart")
                v.Anchored = false
                if v.Name == "HumanoidRootPart" then
                    v.Transparency = 1
                end
            end
        end
    end)
    
    -- Hide real character if enabled
    if desyncHideReal then
        pcall(function()
            root.Anchored = true
            root.CanCollide = false
            for _, v in pairs(char:GetDescendants()) do
                if v:IsA("BasePart") and v.Name ~= "HumanoidRootPart" then
                    v.Transparency = 1
                end
            end
        end)
    end
    
    -- Setup clone humanoid
    cloneHum.WalkSpeed = getgenv().DesyncSpeed or 16
    cloneHum.JumpPower = getgenv().DesyncJump or 50
    cloneHum.PlatformStand = false
    
    -- Camera to clone
    Camera.CameraSubject = cloneHum
    
    -- Play idle animation
    pcall(function()
        local anim = Instance.new("Animation")
        anim.AnimationId = "rbxassetid://507766388"
        local track = cloneHum:LoadAnimation(anim)
        track:Play()
    end)
    
    -- Movement loop
    desyncConn = track(RunService.Heartbeat:Connect(function()
        if not desyncOn then return end
        
        if not desyncClone or not desyncClone.Parent or not cloneRoot or not cloneRoot.Parent then
            StopDesync()
            return
        end
        
        -- Update speed/jump from config
        cloneHum.WalkSpeed = getgenv().DesyncSpeed or 16
        cloneHum.JumpPower = getgenv().DesyncJump or 50
        
        -- Noclip
        if desyncNoclip then
            pcall(function()
                for _, v in pairs(desyncClone:GetDescendants()) do
                    if v:IsA("BasePart") then
                        v.CanCollide = false
                    end
                end
            end)
        end
        
        -- Movement
        local move = Vector3.zero
        local look = Camera.CFrame.LookVector
        local right = Camera.CFrame.RightVector
        
        if UIS:IsKeyDown(Enum.KeyCode.W) then move = move + look end
        if UIS:IsKeyDown(Enum.KeyCode.S) then move = move - look end
        if UIS:IsKeyDown(Enum.KeyCode.A) then move = move - right end
        if UIS:IsKeyDown(Enum.KeyCode.D) then move = move + right end
        
        if desyncFlyMode then
            -- Fly mode for desync
            if UIS:IsKeyDown(Enum.KeyCode.Space) then move = move + Vector3.yAxis end
            if UIS:IsKeyDown(Enum.KeyCode.LeftControl) then move = move - Vector3.yAxis end
            cloneHum.PlatformStand = true
            
            if move.Magnitude > 0 then
                move = move.Unit * cloneHum.WalkSpeed
            end
            
            -- Use BodyVelocity for fly
            local bv = cloneRoot:FindFirstChild("DesyncFlyBV")
            if not bv then
                bv = Instance.new("BodyVelocity")
                bv.Name = "DesyncFlyBV"
                bv.MaxForce = Vector3.new(1e5, 1e5, 1e5)
                bv.Parent = cloneRoot
            end
            bv.Velocity = move
        else
            cloneHum.PlatformStand = false
            local bv = cloneRoot:FindFirstChild("DesyncFlyBV")
            if bv then bv:Destroy() end
            
            if move.Magnitude > 0 then
                move = Vector3.new(move.X, 0, move.Z).Unit * cloneHum.WalkSpeed
                cloneHum:Move(move, false)
            end
            
            -- Jump
            if UIS:IsKeyDown(Enum.KeyCode.Space) then
                cloneHum.Jump = true
            end
        end
        
        -- Safety check - if clone too far from original
        if originalChar and originalChar:FindFirstChild("HumanoidRootPart") then
            local realRoot = originalChar.HumanoidRootPart
            if (cloneRoot.Position - realRoot.Position).Magnitude > 500 then
                print("[600x] Desync: Distancia excesiva, deteniendo")
                StopDesync()
            end
        end
    end))
    
    print("[600x] Desync activado correctamente")
end

desyncToggle.OnChange(function(state)
    if state then
        StartDesync()
    else
        StopDesync()
    end
end)

-- RENDER TOGGLES
purpleSkyToggle.OnChange(function(state)
    if state then Lighting.Ambient = Color3.fromRGB(90, 40, 150); Lighting.OutdoorAmbient = Color3.fromRGB(70, 30, 120); Lighting.FogColor = Color3.fromRGB(60, 25, 100)
    else Lighting.Ambient = Color3.fromRGB(140, 140, 140); Lighting.OutdoorAmbient = Color3.fromRGB(128, 128, 128); Lighting.FogColor = Color3.fromRGB(192, 192, 192) end
end)
customLightToggle.OnChange(function(state) if state then Lighting.Brightness = 2.5; Lighting.ClockTime = 14 else Lighting.Brightness = 1 end end)
worldTintToggle.OnChange(function(state)
    if state then local cc = Instance.new("ColorCorrectionEffect"); cc.Name = "600xTint"; cc.TintColor = Color3.fromRGB(180, 120, 255); cc.Saturation = 0.15; cc.Parent = Lighting
    else local old = Lighting:FindFirstChild("600xTint"); if old then old:Destroy() end end
end)

-- ==================================================
-- KEYBINDS
-- ==================================================
local hubVisible = true
track(UIS.InputBegan:Connect(function(input, gp)
    if captureKeybind(input) then return end
    if gp or UIS:GetFocusedTextBox() then return end
    if input.UserInputType ~= Enum.UserInputType.Keyboard then return end
    local k = input.KeyCode
    
    -- M key to toggle hub visibility
    if k == Enum.KeyCode.M then
        hubVisible = not hubVisible
        Main.Visible = hubVisible
        playSound()
        return
    end
    
    if k == KeyBindings.H then SetReach1(not reach1On)
    elseif k == KeyBindings.Z then reach2Toggle.Set(not reach2Toggle.Get())
    elseif k == KeyBindings.V then SetAura(not auraOn)
    elseif k == KeyBindings.G then desyncToggle.Set(not desyncToggle.Get())
    elseif k == KeyBindings.E then silentToggle.Set(not silentToggle.Get())
    elseif k == KeyBindings.T then if flyOn then StopFly() else StartFly() end
    elseif k == KeyBindings.I then invisToggle.Set(not invisOn)
    elseif k == KeyBindings.F then infJumpToggle.Set(not infJumpOn)
    elseif k == KeyBindings.B then doubleToggle.Set(not doubleOn)
    elseif k == KeyBindings.P then spyToggle.Set(not spyOn)
    elseif k == KeyBindings.K then espToggle.Set(not espOn)
    elseif k == KeyBindings.Y then iyToggle.Set(not iyToggle.Get())
    elseif k == KeyBindings.R then
        if not reach3On then SetReach3(true) end
        local now = tick()
        local add = (now - lastR < 0.35) and 1.5 or 0.5
        getgenv().Reach3Range = math.clamp(getgenv().Reach3Range + add, 1, 40)
        lastR = now
    elseif k == KeyBindings.Q then
        if not reach3On then SetReach3(true) end
        local now = tick()
        local sub = (now - lastQ < 0.35) and 1.5 or 0.5
        getgenv().Reach3Range = math.clamp(getgenv().Reach3Range - sub, 1, 40)
        lastQ = now
    end
    
    if k == Enum.KeyCode.W then flyKeys.W = true elseif k == Enum.KeyCode.A then flyKeys.A = true elseif k == Enum.KeyCode.S then flyKeys.S = true elseif k == Enum.KeyCode.D then flyKeys.D = true elseif k == Enum.KeyCode.Space then flyKeys.Space = true elseif k == Enum.KeyCode.LeftControl then flyKeys.Ctrl = true end
end))
track(UIS.InputEnded:Connect(function(input)
    local k = input.KeyCode
    if k == Enum.KeyCode.W then flyKeys.W = false elseif k == Enum.KeyCode.A then flyKeys.A = false elseif k == Enum.KeyCode.S then flyKeys.S = false elseif k == Enum.KeyCode.D then flyKeys.D = false elseif k == Enum.KeyCode.Space then flyKeys.Space = false elseif k == Enum.KeyCode.LeftControl then flyKeys.Ctrl = false end
end))

-- ==================================================
-- WELCOME NOTIFICATION (TOP RIGHT)
-- ==================================================
local Welcome = Instance.new("Frame")
Welcome.Size = UDim2.fromOffset(300, 100)
Welcome.Position = UDim2.new(1, -320, 0, 20)
Welcome.BackgroundColor3 = CONFIG.Panel
Welcome.BorderSizePixel = 0
Welcome.Visible = true
Welcome.Parent = Gui
corner(Welcome, 12)
stroke(Welcome, CONFIG.Accent, 2)

local WLogo = Instance.new("ImageLabel")
WLogo.Size = UDim2.fromOffset(40, 40)
WLogo.Position = UDim2.fromOffset(12, 12)
WLogo.BackgroundTransparency = 1
WLogo.Image = CONFIG.Logo
WLogo.ScaleType = Enum.ScaleType.Fit
WLogo.Parent = Welcome

label(Welcome, "¡Bienvenido!", 18, UDim2.fromOffset(62, 10), CONFIG.Text, Enum.Font.GothamBlack).Size = UDim2.fromOffset(200, 24)
label(Welcome, LocalPlayer.DisplayName, 11, UDim2.fromOffset(62, 36), CONFIG.Accent2, Enum.Font.Gotham).Size = UDim2.fromOffset(200, 18)
label(Welcome, CONFIG.Version, 10, UDim2.fromOffset(62, 56), CONFIG.Muted, Enum.Font.Gotham).Size = UDim2.fromOffset(200, 16)

task.spawn(function()
    playSound()
    task.wait(0.15)
    tween(Welcome, TweenInfo.new(0.55, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {Position = UDim2.new(1, -320, 0, 20)}):Play()
    task.wait(3)
    tween(Welcome, TweenInfo.new(0.45, Enum.EasingStyle.Quint, Enum.EasingDirection.In), {Position = UDim2.new(1, -320, 0, -120)}):Play()
    task.wait(0.5)
    Welcome.Visible = false
end)

print("[600x Hub V5] Desync Fixed + Config in Hub + Double Hit Sliders + Addons Fixed")
print("[600x] Presiona M para mostrar/ocultar el hub")
