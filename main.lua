-- EclipseHub 1.0
-- Clean, readable UI scaffold for Roblox Bee Swarm Simulator.
-- Gameplay automation is intentionally isolated from the UI and must be implemented/tested per executor.

local HUB_NAME = "EclipseHub"
local VERSION = "1.0"

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer

local function getGuiParent()
    local env = _G
    if type(getgenv) == "function" then
        local ok, result = pcall(getgenv)
        if ok and type(result) == "table" then env = result end
    end

    local candidates = {"gethui", "get_hidden_gui"}
    for _, name in ipairs(candidates) do
        local fn = env[name] or _G[name]
        if type(fn) == "function" then
            local ok, parent = pcall(fn)
            if ok and parent then return parent end
        end
    end
    return LocalPlayer:WaitForChild("PlayerGui")
end

local function safeDestroy(name)
    local parent = getGuiParent()
    local old = parent:FindFirstChild(name)
    if old then pcall(function() old:Destroy() end) end
end

local function make(className, props, parent)
    local obj = Instance.new(className)
    for key, value in pairs(props or {}) do
        obj[key] = value
    end
    obj.Parent = parent
    return obj
end

local COLORS = {
    background = Color3.fromRGB(18, 19, 24),
    panel = Color3.fromRGB(24, 26, 33),
    panel2 = Color3.fromRGB(31, 33, 42),
    border = Color3.fromRGB(49, 52, 64),
    text = Color3.fromRGB(235, 237, 244),
    muted = Color3.fromRGB(145, 150, 166),
    accent = Color3.fromRGB(151, 111, 255),
    green = Color3.fromRGB(93, 205, 143),
    red = Color3.fromRGB(235, 91, 105),
}

local FIELDS = {
    "Sunflower Field", "Dandelion Field", "Mushroom Field", "Blue Flower Field",
    "Clover Field", "Strawberry Field", "Spider Field", "Bamboo Field",
    "Pineapple Patch", "Stump Field", "Cactus Field", "Pumpkin Patch",
    "Pine Tree Forest", "Rose Field", "Mountain Top Field", "Pepper Patch",
    "Coconut Field"
}

local SPRINKLERS = {
    "Basic Sprinkler", "Silver Soakers", "Golden Gushers",
    "Diamond Drenchers", "Supreme Saturators"
}

local state = {
    selectedField = "Sunflower Field",
    autoFarm = false,
    autoDig = false,
    autoSprinkler = false,
    sprinklerType = "Basic Sprinkler",
    parachute = false,
    convertAt = 90,
    autoQuest = false,
    autoPlanters = false,
    autoToys = false,
    webhookEnabled = false,
    antiAfk = false,
    serverHop = false,
    debugMode = false,
}

local actions = {}
local screen -- Forward declaration used by notify().
local function notify(message)
    if type(message) ~= "string" then message = tostring(message) end
    local toast = make("TextLabel", {
        Name = "Toast", BackgroundColor3 = COLORS.panel2, BorderSizePixel = 0,
        Size = UDim2.fromOffset(300, 38), Position = UDim2.new(1, -316, 1, -58),
        Font = Enum.Font.Gotham, TextSize = 12, TextColor3 = COLORS.text,
        Text = message, TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 20,
    }, screen)
    make("UICorner", {CornerRadius = UDim.new(0, 7)}, toast)
    make("UIPadding", {PaddingLeft = UDim.new(0, 12), PaddingRight = UDim.new(0, 8)}, toast)
    task.delay(2.5, function()
        if toast and toast.Parent then
            pcall(function() toast:Destroy() end)
        end
    end)
end

local GUI_NAME = "EclipseHubUI"
safeDestroy(GUI_NAME)
screen = make("ScreenGui", {
    Name = GUI_NAME, ResetOnSpawn = false, IgnoreGuiInset = true,
    ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
}, getGuiParent())

local main = make("Frame", {
    Name = "Main", Size = UDim2.fromOffset(690, 440), Position = UDim2.new(0.5, -345, 0.5, -220),
    BackgroundColor3 = COLORS.background, BorderSizePixel = 0,
    Active = true,
}, screen)
make("UICorner", {CornerRadius = UDim.new(0, 10)}, main)
make("UIStroke", {Color = COLORS.border, Thickness = 1}, main)

local top = make("Frame", {Name = "TopBar", Size = UDim2.new(1, 0, 0, 48), BackgroundColor3 = COLORS.panel, BorderSizePixel = 0}, main)
make("UICorner", {CornerRadius = UDim.new(0, 10)}, top)
make("Frame", {Size = UDim2.new(1, 0, 0, 10), Position = UDim2.new(0, 0, 1, -10), BackgroundColor3 = COLORS.panel, BorderSizePixel = 0}, top)
make("TextLabel", {
    BackgroundTransparency = 1, Position = UDim2.fromOffset(16, 0), Size = UDim2.new(1, -130, 1, 0),
    Font = Enum.Font.GothamBold, TextSize = 15, TextColor3 = COLORS.text,
    Text = "EclipseHub", TextXAlignment = Enum.TextXAlignment.Left,
}, top)
make("TextLabel", {
    BackgroundTransparency = 1, Position = UDim2.new(1, -116, 0, 0), Size = UDim2.fromOffset(70, 48),
    Font = Enum.Font.Gotham, TextSize = 10, TextColor3 = COLORS.muted,
    Text = "v" .. VERSION, TextXAlignment = Enum.TextXAlignment.Right,
}, top)
local close = make("TextButton", {
    Name = "Close", Position = UDim2.new(1, -38, 0, 9), Size = UDim2.fromOffset(26, 26),
    BackgroundColor3 = COLORS.panel2, BorderSizePixel = 0, Text = "×",
    Font = Enum.Font.Gotham, TextSize = 19, TextColor3 = COLORS.text,
}, top)
make("UICorner", {CornerRadius = UDim.new(0, 6)}, close)
close.MouseButton1Click:Connect(function() screen.Enabled = false end)

local sidebar = make("Frame", {
    Name = "Sidebar", Position = UDim2.fromOffset(10, 58), Size = UDim2.new(0, 146, 1, -68),
    BackgroundColor3 = COLORS.panel, BorderSizePixel = 0,
}, main)
make("UICorner", {CornerRadius = UDim.new(0, 8)}, sidebar)
local navList = make("UIListLayout", {Padding = UDim.new(0, 4), SortOrder = Enum.SortOrder.LayoutOrder}, sidebar)
make("UIPadding", {PaddingTop = UDim.new(0, 9), PaddingLeft = UDim.new(0, 7), PaddingRight = UDim.new(0, 7)}, sidebar)

local content = make("Frame", {
    Name = "Content", Position = UDim2.fromOffset(166, 58), Size = UDim2.new(1, -176, 1, -68),
    BackgroundColor3 = COLORS.panel, BorderSizePixel = 0,
}, main)
make("UICorner", {CornerRadius = UDim.new(0, 8)}, content)
local pageTitle = make("TextLabel", {
    Name = "PageTitle", BackgroundTransparency = 1, Position = UDim2.fromOffset(16, 9),
    Size = UDim2.new(1, -32, 0, 26), Font = Enum.Font.GothamBold,
    TextSize = 14, TextColor3 = COLORS.text, TextXAlignment = Enum.TextXAlignment.Left,
    Text = "Home",
}, content)
local pageScroll = make("ScrollingFrame", {
    Name = "Page", Position = UDim2.fromOffset(10, 42), Size = UDim2.new(1, -20, 1, -52),
    BackgroundTransparency = 1, BorderSizePixel = 0, ScrollBarThickness = 3,
    ScrollBarImageColor3 = COLORS.accent, CanvasSize = UDim2.new(0, 0, 0, 0),
}, content)
local pageLayout = make("UIListLayout", {Padding = UDim.new(0, 7), SortOrder = Enum.SortOrder.LayoutOrder}, pageScroll)
pageLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    pageScroll.CanvasSize = UDim2.new(0, 0, 0, pageLayout.AbsoluteContentSize.Y + 8)
end)

local pageConnections = {}
local function trackPageConnection(connection)
    table.insert(pageConnections, connection)
    return connection
end

local function clearPage()
    for _, connection in ipairs(pageConnections) do
        pcall(function() connection:Disconnect() end)
    end
    table.clear(pageConnections)

    for _, child in ipairs(pageScroll:GetChildren()) do
        if not child:IsA("UIListLayout") then child:Destroy() end
    end
end

local function section(text)
    return make("TextLabel", {
        BackgroundTransparency = 1, Size = UDim2.new(1, -6, 0, 22),
        Font = Enum.Font.GothamBold, TextSize = 11, TextColor3 = COLORS.accent,
        Text = string.upper(text), TextXAlignment = Enum.TextXAlignment.Left,
    }, pageScroll)
end

local function description(text)
    return make("TextLabel", {
        BackgroundTransparency = 1, Size = UDim2.new(1, -6, 0, 34),
        Font = Enum.Font.Gotham, TextSize = 11, TextColor3 = COLORS.muted,
        Text = text, TextWrapped = true, TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Top,
    }, pageScroll)
end

local function rowBase(height)
    local row = make("Frame", {
        Size = UDim2.new(1, -6, 0, height or 38), BackgroundColor3 = COLORS.panel2,
        BorderSizePixel = 0,
    }, pageScroll)
    make("UICorner", {CornerRadius = UDim.new(0, 6)}, row)
    return row
end

local function toggle(label, key, callback)
    local row = rowBase(38)
    make("TextLabel", {
        BackgroundTransparency = 1, Position = UDim2.fromOffset(11, 0), Size = UDim2.new(1, -75, 1, 0),
        Font = Enum.Font.Gotham, TextSize = 11, TextColor3 = COLORS.text,
        Text = label, TextXAlignment = Enum.TextXAlignment.Left,
    }, row)
    local button = make("TextButton", {
        Position = UDim2.new(1, -55, 0.5, -10), Size = UDim2.fromOffset(43, 20),
        BackgroundColor3 = state[key] and COLORS.accent or COLORS.border,
        BorderSizePixel = 0, Text = state[key] and "ON" or "OFF",
        Font = Enum.Font.GothamBold, TextSize = 9, TextColor3 = COLORS.text,
    }, row)
    make("UICorner", {CornerRadius = UDim.new(0, 5)}, button)
    button.MouseButton1Click:Connect(function()
        state[key] = not state[key]
        button.Text = state[key] and "ON" or "OFF"
        button.BackgroundColor3 = state[key] and COLORS.accent or COLORS.border
        if callback then
            local ok, err = pcall(callback, state[key])
            if not ok then notify(label .. " error: " .. tostring(err)) end
        end
    end)
end

local function dropdown(label, key, options, callback)
    local row = rowBase(40)
    make("TextLabel", {
        BackgroundTransparency = 1, Position = UDim2.fromOffset(11, 0), Size = UDim2.new(0.48, 0, 1, 0),
        Font = Enum.Font.Gotham, TextSize = 11, TextColor3 = COLORS.text,
        Text = label, TextXAlignment = Enum.TextXAlignment.Left,
    }, row)
    local button = make("TextButton", {
        Position = UDim2.new(0.48, 0, 0.5, -13), Size = UDim2.new(0.52, -8, 0, 26),
        BackgroundColor3 = COLORS.background, BorderSizePixel = 0,
        Text = tostring(state[key]), Font = Enum.Font.Gotham, TextSize = 10,
        TextColor3 = COLORS.text, TextTruncate = Enum.TextTruncate.AtEnd,
    }, row)
    make("UICorner", {CornerRadius = UDim.new(0, 5)}, button)
    local index = table.find(options, state[key]) or 1
    button.MouseButton1Click:Connect(function()
        index = index % #options + 1
        state[key] = options[index]
        button.Text = options[index]
        if callback then
            local ok, err = pcall(callback, options[index])
            if not ok then notify(label .. " error: " .. tostring(err)) end
        end
    end)
end

local function slider(label, key, minValue, maxValue, callback)
    local row = rowBase(55)
    make("TextLabel", {
        BackgroundTransparency = 1, Position = UDim2.fromOffset(11, 3), Size = UDim2.new(1, -70, 0, 20),
        Font = Enum.Font.Gotham, TextSize = 11, TextColor3 = COLORS.text,
        Text = label, TextXAlignment = Enum.TextXAlignment.Left,
    }, row)
    local valueLabel = make("TextLabel", {
        BackgroundTransparency = 1, Position = UDim2.new(1, -52, 0, 3), Size = UDim2.fromOffset(40, 20),
        Font = Enum.Font.GothamBold, TextSize = 11, TextColor3 = COLORS.text,
        Text = tostring(state[key]) .. "%", TextXAlignment = Enum.TextXAlignment.Right,
    }, row)
    local track = make("Frame", {
        Position = UDim2.fromOffset(11, 32), Size = UDim2.new(1, -22, 0, 5),
        BackgroundColor3 = COLORS.border, BorderSizePixel = 0,
    }, row)
    make("UICorner", {CornerRadius = UDim.new(1, 0)}, track)
    local range = math.max(1, maxValue - minValue)
    local initialAlpha = math.clamp((state[key] - minValue) / range, 0, 1)
    local fill = make("Frame", {
        Size = UDim2.new(initialAlpha, 0, 1, 0),
        BackgroundColor3 = COLORS.accent, BorderSizePixel = 0,
    }, track)
    make("UICorner", {CornerRadius = UDim.new(1, 0)}, fill)
    local dragging = false
    local function setFromX(x)
        local width = track.AbsoluteSize.X
        if width <= 0 then return end
        local alpha = math.clamp((x - track.AbsolutePosition.X) / width, 0, 1)
        local value = math.floor(minValue + alpha * range + 0.5)
        state[key] = value
        valueLabel.Text = tostring(value) .. "%"
        fill.Size = UDim2.new(alpha, 0, 1, 0)
        if callback then pcall(callback, value) end
    end
    track.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true; setFromX(input.Position.X)
        end
    end)
    trackPageConnection(UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            setFromX(input.Position.X)
        end
    end))
    trackPageConnection(UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then dragging = false end
    end))
end

-- Hook points for real game logic. UI controls should not claim to automate anything until handlers are implemented.
actions.startFarm = function()
    notify("Auto Farm logic is not configured yet.")
end
actions.stopFarm = function()
    notify("Auto Farm stopped.")
end
actions.startQuest = function()
    notify("Quest automation logic is not configured yet.")
end

local function buildPage(name)
    clearPage()
    pageTitle.Text = name
    if name == "Home" then
        section("Welcome to EclipseHub")
        description("A compact BSS hub with a clean, readable codebase.")
        section("Status")
        description("UI loaded successfully. Gameplay automation requires executor-specific testing and implemented handlers.")
        toggle("Debug messages", "debugMode", function(enabled) notify("Debug " .. (enabled and "enabled" or "disabled")) end)
    elseif name == "Farm" then
        section("Field")
        dropdown("Target Field", "selectedField", FIELDS, function(value) notify("Target field: " .. value) end)
        slider("Auto Convert Threshold", "convertAt", 1, 100)
        section("Automation")
        toggle("Auto Farm", "autoFarm", function(enabled)
            if enabled then actions.startFarm() else actions.stopFarm() end
        end)
        toggle("Auto Dig", "autoDig", function(enabled) notify("Auto Dig " .. (enabled and "enabled" or "disabled") .. " (handler pending)") end)
        toggle("Auto Sprinkler", "autoSprinkler", function(enabled) notify("Auto Sprinkler " .. (enabled and "enabled" or "disabled") .. " (handler pending)") end)
        dropdown("Sprinkler Type", "sprinklerType", SPRINKLERS, function(value) notify("Sprinkler: " .. value) end)
        toggle("Parachute", "parachute", function(enabled) notify("Parachute " .. (enabled and "enabled" or "disabled") .. " (handler pending)") end)
    elseif name == "Quest" then
        section("Quest Automation")
        toggle("Auto Quest", "autoQuest", function(enabled) if enabled then actions.startQuest() else notify("Auto Quest disabled") end end)
        description("Quest selection, NPC navigation, and objective handling are not wired up yet.")
    elseif name == "Planters" then
        section("Planters")
        toggle("Auto Planters", "autoPlanters", function(enabled) notify("Auto Planters " .. (enabled and "enabled" or "disabled") .. " (handler pending)") end)
        description("Planting, growth tracking, and harvesting logic is not wired up yet.")
    elseif name == "Toys" then
        section("Toys")
        toggle("Auto Toys", "autoToys", function(enabled) notify("Auto Toys " .. (enabled and "enabled" or "disabled") .. " (handler pending)") end)
        description("Toy selection and cooldown tracking are not wired up yet.")
    elseif name == "Webhook" then
        section("Webhook")
        toggle("Enable Webhook", "webhookEnabled", function(enabled) notify("Webhook " .. (enabled and "enabled" or "disabled") .. ". Add a validated endpoint handler before use.") end)
        description("Webhook delivery is not implemented. Do not paste private tokens into public scripts.")
    elseif name == "Config" then
        section("Configuration")
        description("Settings currently live in this session only; persistent save/load is not implemented.")
        local reset = make("TextButton", {Size = UDim2.new(1, -6, 0, 34), BackgroundColor3 = COLORS.panel2, BorderSizePixel = 0, Text = "Reset UI", Font = Enum.Font.Gotham, TextSize = 11, TextColor3 = COLORS.text}, pageScroll)
        make("UICorner", {CornerRadius = UDim.new(0, 6)}, reset)
        reset.MouseButton1Click:Connect(function() main.Position = UDim2.new(0.5, -345, 0.5, -220); notify("Window position reset") end)
    elseif name == "Debug" then
        section("Diagnostics")
        description("Executor capability checks")
        local function report(label, value) description(label .. ": " .. (value and "available" or "not available")) end
        report("getgenv", type(getgenv) == "function")
        report("request / http_request", type(request) == "function" or type(http_request) == "function")
        report("gethui", type(gethui) == "function")
        report("Drawing API", type(Drawing) == "table")
        toggle("Debug mode", "debugMode")
    elseif name == "Farm Token" then
        section("Token Collection")
        description("Token collection settings will be added alongside tested farm logic.")
    elseif name == "AntiBan" then
        section("Safety")
        toggle("Anti-AFK", "antiAfk", function(enabled) notify("Anti-AFK toggle changed; handler pending") end)
        description("No script can guarantee that an account will not be moderated or banned.")
    elseif name == "Server Hop" then
        section("Server Hop")
        toggle("Enable Server Hop", "serverHop", function(enabled) notify("Server Hop " .. (enabled and "enabled" or "disabled") .. " (handler pending)") end)
        description("Server discovery and teleport logic are not wired up yet.")
    end
end

local tabs = {"Home", "Farm", "Quest", "Planters", "Toys", "Webhook", "Config", "Debug", "Farm Token", "AntiBan", "Server Hop"}
for i, tabName in ipairs(tabs) do
    local button = make("TextButton", {
        Name = tabName:gsub("%s+", ""), Size = UDim2.new(1, 0, 0, 29),
        BackgroundColor3 = tabName == "Home" and COLORS.accent or COLORS.panel,
        BorderSizePixel = 0, Text = tabName, Font = Enum.Font.Gotham,
        TextSize = 11, TextColor3 = COLORS.text, LayoutOrder = i,
    }, sidebar)
    make("UICorner", {CornerRadius = UDim.new(0, 5)}, button)
    button.MouseButton1Click:Connect(function()
        for _, child in ipairs(sidebar:GetChildren()) do
            if child:IsA("TextButton") then child.BackgroundColor3 = COLORS.panel end
        end
        button.BackgroundColor3 = COLORS.accent
        buildPage(tabName)
    end)
end

-- Drag window by the top bar.
do
    local dragging, dragStart, startPosition
    top.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPosition = main.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            main.Position = UDim2.new(startPosition.X.Scale, startPosition.X.Offset + delta.X, startPosition.Y.Scale, startPosition.Y.Offset + delta.Y)
        end
    end)
end

UserInputService.InputBegan:Connect(function(input, processed)
    if not processed and input.KeyCode == Enum.KeyCode.RightShift then
        screen.Enabled = not screen.Enabled
    end
end)

buildPage("Home")
notify("EclipseHub UI loaded")
