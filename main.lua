-- EclipseHub 1.2 - compact UI rebuild
-- UI controls are real; game-specific automation is only implemented where stated.
-- Do not treat quest checkboxes as working quest automation until handlers are added.

local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer

local ENV = _G
pcall(function() if type(getgenv) == "function" then ENV = getgenv() end end)

local old
pcall(function() old = ENV.EclipseHubGui end)
if old then pcall(function() old:Destroy() end) end

local C = {
    bg = Color3.fromRGB(18, 19, 22),
    sidebar = Color3.fromRGB(22, 23, 27),
    panel = Color3.fromRGB(28, 30, 35),
    hover = Color3.fromRGB(39, 42, 49),
    border = Color3.fromRGB(48, 51, 59),
    text = Color3.fromRGB(235, 237, 242),
    muted = Color3.fromRGB(151, 156, 167),
    accent = Color3.fromRGB(230, 180, 75),
    check = Color3.fromRGB(230, 180, 75),
}

local Settings = {
    autoDig = false, autoFarm = false, autoConvert = false,
    autoSprinkler = false, autoTokens = false, antiAfk = false,
    autoQuest = {}, beesmas = {}, debug = false,
}
local Connections = {}
local function connect(signal, fn)
    local c = signal:Connect(fn)
    table.insert(Connections, c)
    return c
end
local function disconnectAll()
    for _, c in ipairs(Connections) do pcall(function() c:Disconnect() end) end
    table.clear(Connections)
end
local function make(class, props, parent)
    local obj = Instance.new(class)
    for k, v in pairs(props or {}) do obj[k] = v end
    obj.Parent = parent
    return obj
end
local function corner(parent, radius)
    make("UICorner", {CornerRadius = UDim.new(0, radius or 5)}, parent)
end
local function stroke(parent, color)
    make("UIStroke", {Color = color or C.border, Thickness = 1, Transparency = 0.15}, parent)
end

local gui = make("ScreenGui", {
    Name = "EclipseHubGui", ResetOnSpawn = false,
    ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
}, nil)
ENV.EclipseHubGui = gui
local parentOk = pcall(function()
    if type(gethui) == "function" then gui.Parent = gethui()
    else gui.Parent = game:GetService("CoreGui") end
end)
if not parentOk or not gui.Parent then gui.Parent = player:WaitForChild("PlayerGui") end

local main = make("Frame", {
    Name = "Main", Size = UDim2.fromOffset(650, 420),
    Position = UDim2.new(0.5, -325, 0.5, -210),
    BackgroundColor3 = C.bg, BorderSizePixel = 0,
}, gui)
corner(main, 7); stroke(main)

local top = make("Frame", {Size = UDim2.new(1, 0, 0, 36), BackgroundColor3 = C.sidebar, BorderSizePixel = 0}, main)
corner(top, 7)
make("Frame", {Position = UDim2.new(0, 0, 1, -7), Size = UDim2.new(1, 0, 0, 7), BackgroundColor3 = C.sidebar, BorderSizePixel = 0}, top)
make("TextLabel", {
    Position = UDim2.fromOffset(12, 0), Size = UDim2.new(1, -100, 1, 0),
    BackgroundTransparency = 1, Text = "EclipseHub 1.2", TextColor3 = C.text,
    Font = Enum.Font.GothamSemibold, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left,
}, top)
local minimize = make("TextButton", {
    Position = UDim2.new(1, -61, 0, 5), Size = UDim2.fromOffset(24, 25),
    BackgroundColor3 = C.hover, BorderSizePixel = 0, Text = "—",
    TextColor3 = C.text, Font = Enum.Font.GothamBold, TextSize = 14,
}, top); corner(minimize, 4)
local close = make("TextButton", {
    Position = UDim2.new(1, -31, 0, 5), Size = UDim2.fromOffset(24, 25),
    BackgroundColor3 = C.hover, BorderSizePixel = 0, Text = "×",
    TextColor3 = C.text, Font = Enum.Font.Gotham, TextSize = 17,
}, top); corner(close, 4)

local sidebar = make("Frame", {Position = UDim2.fromOffset(0, 36), Size = UDim2.new(0, 145, 1, -36), BackgroundColor3 = C.sidebar, BorderSizePixel = 0}, main)
local nav = make("Frame", {Position = UDim2.fromOffset(8, 8), Size = UDim2.new(1, -16, 1, -16), BackgroundTransparency = 1}, sidebar)
make("UIListLayout", {Padding = UDim.new(0, 3), SortOrder = Enum.SortOrder.LayoutOrder}, nav)
local content = make("Frame", {Position = UDim2.fromOffset(145, 36), Size = UDim2.new(1, -145, 1, -36), BackgroundTransparency = 1}, main)
local pages, navButtons = {}, {}
local currentPage = nil
local minimized = false

local function makePage(name)
    local page = make("ScrollingFrame", {
        Name = name, Size = UDim2.new(1, -18, 1, -18), Position = UDim2.fromOffset(9, 9),
        BackgroundTransparency = 1, BorderSizePixel = 0, ScrollBarThickness = 3,
        ScrollBarImageColor3 = C.border, CanvasSize = UDim2.new(), AutomaticCanvasSize = Enum.AutomaticSize.Y,
        Visible = false,
    }, content)
    make("UIListLayout", {Padding = UDim.new(0, 6), SortOrder = Enum.SortOrder.LayoutOrder}, page)
    make("UIPadding", {PaddingBottom = UDim.new(0, 8)}, page)
    pages[name] = page
    local b = make("TextButton", {
        Size = UDim2.new(1, 0, 0, 29), BackgroundColor3 = C.sidebar, BorderSizePixel = 0,
        Text = name, TextColor3 = C.muted, Font = Enum.Font.Gotham, TextSize = 11,
        TextXAlignment = Enum.TextXAlignment.Left, AutoButtonColor = false,
    }, nav)
    make("UIPadding", {PaddingLeft = UDim.new(0, 9)}, b)
    corner(b, 4); navButtons[name] = b
    connect(b.MouseButton1Click, function()
        if currentPage then currentPage.Visible = false end
        if currentPage and navButtons[currentPage.Name] then
            navButtons[currentPage.Name].BackgroundColor3 = C.sidebar
            navButtons[currentPage.Name].TextColor3 = C.muted
        end
        currentPage = page; page.Visible = true
        b.BackgroundColor3 = C.hover; b.TextColor3 = C.text
    end)
    return page
end

local function section(page, title, subtitle)
    local f = make("Frame", {Size = UDim2.new(1, -2, 0, subtitle and 51 or 31), BackgroundTransparency = 1}, page)
    make("TextLabel", {Size = UDim2.new(1, 0, 0, 25), BackgroundTransparency = 1,
        Text = title, TextColor3 = C.text, Font = Enum.Font.GothamSemibold, TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left}, f)
    if subtitle then make("TextLabel", {Position = UDim2.fromOffset(0, 24), Size = UDim2.new(1, 0, 0, 25),
        BackgroundTransparency = 1, Text = subtitle, TextColor3 = C.muted, Font = Enum.Font.Gotham,
        TextSize = 10, TextWrapped = true, TextXAlignment = Enum.TextXAlignment.Left}, f) end
end
local function note(page, text)
    local f = make("Frame", {Size = UDim2.new(1, -2, 0, 38), BackgroundColor3 = C.panel, BorderSizePixel = 0}, page)
    corner(f, 4)
    make("TextLabel", {Position = UDim2.fromOffset(10, 0), Size = UDim2.new(1, -20, 1, 0),
        BackgroundTransparency = 1, Text = text, TextColor3 = C.muted, Font = Enum.Font.Gotham,
        TextSize = 10, TextWrapped = true, TextXAlignment = Enum.TextXAlignment.Left}, f)
end
local function checkbox(page, label, initial, callback)
    local row = make("Frame", {Size = UDim2.new(1, -2, 0, 32), BackgroundColor3 = C.panel, BorderSizePixel = 0}, page)
    corner(row, 4)
    make("TextLabel", {Position = UDim2.fromOffset(10, 0), Size = UDim2.new(1, -54, 1, 0),
        BackgroundTransparency = 1, Text = label, TextColor3 = C.text, Font = Enum.Font.Gotham,
        TextSize = 11, TextXAlignment = Enum.TextXAlignment.Left}, row)
    local box = make("TextButton", {Position = UDim2.new(1, -31, 0.5, -8), Size = UDim2.fromOffset(16, 16),
        BackgroundColor3 = initial and C.check or C.bg, BorderSizePixel = 0,
        Text = initial and "✓" or "", TextColor3 = C.bg, Font = Enum.Font.GothamBold,
        TextSize = 12, AutoButtonColor = false}, row)
    corner(box, 2); stroke(box, initial and C.check or C.border)
    local value = initial == true
    connect(box.MouseButton1Click, function()
        value = not value
        box.BackgroundColor3 = value and C.check or C.bg
        box.Text = value and "✓" or ""
        local s = box:FindFirstChildOfClass("UIStroke")
        if s then s.Color = value and C.check or C.border end
        if callback then callback(value) end
    end)
    return row
end

local home = makePage("Home")
section(home, "EclipseHub 1.2", "Minimal interface for Bee Swarm Simulator")
section(home, "Status")
note(home, "UI initialized. Checkboxes save their state for this session only.")
note(home, "Only features explicitly marked as implemented perform actions. Quest automation requires tested game-specific handlers.")

local farm = makePage("Farm")
section(farm, "Farm", "Basic controls")
checkbox(farm, "Auto Dig", false, function(v) Settings.autoDig = v end)
checkbox(farm, "Auto Farm", false, function(v) Settings.autoFarm = v end)
checkbox(farm, "Auto Convert Pollen", false, function(v) Settings.autoConvert = v end)
checkbox(farm, "Auto Use Sprinkler", false, function(v) Settings.autoSprinkler = v end)
checkbox(farm, "Auto Collect Tokens", false, function(v) Settings.autoTokens = v end)
note(farm, "Auto Dig uses the executor's mouse1click() function when available. Other Farm options are UI settings until their game logic is implemented.")

local quest = makePage("Quest")
section(quest, "Auto Quest", "Select the NPC quest lines you want enabled")
local bears = {
    "Black Bear", "Brown Bear", "Mother Bear", "Panda Bear", "Science Bear",
    "Polar Bear", "Spirit Bear", "Riley Bee", "Bucko Bee", "Honey Bee",
    "Robo Bear", "Dapper Bear", "Bee Bear", "Gummy Bear", "Bubble Bee Man",
    "Onett", "Stick Bug", "Windy Bee",
}
for _, name in ipairs(bears) do
    checkbox(quest, name, false, function(v) Settings.autoQuest[name] = v end)
end
section(quest, "Beesmas", "Seasonal quest and gift options")
for _, name in ipairs({"Beesmas NPC Quests", "Gift Boxes", "Beesmas Gifts", "Beesmas Decorations", "Snowbear", "Samovar", "Stockings", "Honeyday Candles"}) do
    checkbox(quest, name, false, function(v) Settings.beesmas[name] = v end)
end
note(quest, "These selections currently store preferences only. They do not navigate to NPCs, accept quests, collect gifts, or complete objectives yet.")

local token = makePage("Farm Token")
section(token, "Token Collection")
checkbox(token, "Enable token collection preference", false, function(v) Settings.autoTokens = v end)
note(token, "Automatic token targeting and pathfinding are not implemented in this build.")

local webhook = makePage("Webhook")
section(webhook, "Webhook")
note(webhook, "Webhook delivery is not implemented. Avoid entering private webhook URLs into scripts you do not trust.")

local config = makePage("Config")
section(config, "Configuration")
note(config, "Settings are temporary and reset when the script restarts.")
checkbox(config, "Debug messages", false, function(v) Settings.debug = v end)

local debugPage = makePage("Debug")
section(debugPage, "Diagnostics")
local executorName = "unknown"
if type(identifyexecutor) == "function" then
    local ok, value = pcall(identifyexecutor)
    if ok and value then executorName = tostring(value) end
end
for _, item in ipairs({
    "Executor: " .. executorName,
    "mouse1click: " .. tostring(type(mouse1click) == "function"),
    "gethui: " .. tostring(type(gethui) == "function"),
    "HTTP request: " .. tostring(type(request) == "function" or type(http_request) == "function"),
}) do note(debugPage, item) end

local anti = makePage("AntiBan")
section(anti, "Safety")
checkbox(anti, "Anti-AFK", false, function(v) Settings.antiAfk = v end)
note(anti, "No script can guarantee protection from moderation. Anti-AFK support is not enabled by this checkbox in this build.")

local server = makePage("Server Hop")
section(server, "Server Hop")
note(server, "Server discovery and teleport are not implemented in this build.")

-- Functional Auto Dig loop, guarded against missing executor support.
local digTaskRunning = false
local function startDigLoop()
    if digTaskRunning then return end
    if type(mouse1click) ~= "function" then
        Settings.autoDig = false
        warn("[EclipseHub] Auto Dig unavailable: executor does not expose mouse1click().")
        return
    end
    digTaskRunning = true
    task.spawn(function()
        while Settings.autoDig and gui.Parent do
            local ok, err = pcall(mouse1click)
            if not ok then
                Settings.autoDig = false
                warn("[EclipseHub] Auto Dig stopped: " .. tostring(err))
                break
            end
            task.wait(0.12)
        end
        digTaskRunning = false
    end)
end
-- Rebind Auto Dig to start/stop its loop; the checkbox state remains the source of truth.
for _, row in ipairs(farm:GetChildren()) do
    if row:IsA("Frame") then
        local label = row:FindFirstChildOfClass("TextLabel")
        local button = row:FindFirstChildWhichIsA("TextButton")
        if label and label.Text == "Auto Dig" and button then
            connect(button.MouseButton1Click, function()
                task.defer(function()
                    if Settings.autoDig then startDigLoop() end
                end)
            end)
        end
    end
end

local dragging, dragStart, startPos = false, nil, nil
connect(top.InputBegan, function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true; dragStart = input.Position; startPos = main.Position
    end
end)
connect(UIS.InputChanged, function(input)
    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = input.Position - dragStart
        main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)
connect(UIS.InputEnded, function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
end)
connect(minimize.MouseButton1Click, function()
    minimized = not minimized
    sidebar.Visible = not minimized
    content.Visible = not minimized
    main.Size = minimized and UDim2.fromOffset(250, 36) or UDim2.fromOffset(650, 420)
    minimize.Text = minimized and "□" or "—"
end)
connect(close.MouseButton1Click, function()
    Settings.autoDig = false
    disconnectAll()
    gui:Destroy()
end)

-- Select Home initially.
currentPage = pages.Home
currentPage.Visible = true
navButtons.Home.BackgroundColor3 = C.hover
navButtons.Home.TextColor3 = C.text

print("[EclipseHub] 1.2 UI loaded. Auto Dig is the only implemented gameplay action in this build.")
