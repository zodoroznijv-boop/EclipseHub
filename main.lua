
-- EclipseHub | Bee Swarm Simulator
-- UI foundation v0.1
-- Gameplay automation is not implemented.

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local old = playerGui:FindFirstChild("EclipseHub")
if old then
    old:Destroy()
end

local Fields = {
    "Sunflower Field",
    "Dandelion Field",
    "Mushroom Field",
    "Blue Flower Field",
    "Clover Field",
    "Strawberry Field",
    "Spider Field",
    "Bamboo Field",
    "Pineapple Patch",
    "Stump Field",
    "Cactus Field",
    "Pumpkin Patch",
    "Pine Tree Forest",
    "Rose Field",
    "Mountain Top Field",
    "Pepper Patch",
    "Coconut Field"
}

local Tabs = {
    "Home", "Farm", "Quest", "Planters", "Toys",
    "Webhook", "Config", "Debug", "Farm Token",
    "AntiBan", "Server Hop"
}

local Settings = {
    AutoFarm = false,
    AutoQuest = false,
    AutoPlanters = false,
    AutoCollectTokens = false,
    AutoConvert = false,
    AutoUseSprinkler = false,
    SelectedField = Fields[1]
}

local Theme = {
    Background = Color3.fromRGB(16, 17, 23),
    Panel = Color3.fromRGB(23, 25, 33),
    Element = Color3.fromRGB(32, 35, 46),
    Accent = Color3.fromRGB(151, 103, 255),
    Text = Color3.fromRGB(240, 240, 248),
    Muted = Color3.fromRGB(150, 153, 170),
    Green = Color3.fromRGB(85, 205, 135)
}

local gui = Instance.new("ScreenGui")
gui.Name = "EclipseHub"
gui.ResetOnSpawn = false
gui.DisplayOrder = 20
gui.Parent = playerGui

local function create(class, props, parent)
    local obj = Instance.new(class)
    for key, value in pairs(props) do
        obj[key] = value
    end
    obj.Parent = parent
    return obj
end

local function round(obj, radius)
    create("UICorner", {
        CornerRadius = UDim.new(0, radius or 8)
    }, obj)
end

local function makeLabel(parent, text, size, position, fontSize, color)
    return create("TextLabel", {
        BackgroundTransparency = 1,
        Text = text,
        TextColor3 = color or Theme.Text,
        TextSize = fontSize or 14,
        Font = Enum.Font.Gotham,
        TextXAlignment = Enum.TextXAlignment.Left,
        Size = size,
        Position = position,
        TextWrapped = true
    }, parent)
end

local main = create("Frame", {
    Name = "Main",
    Size = UDim2.fromOffset(760, 490),
    Position = UDim2.new(0.5, -380, 0.5, -245),
    BackgroundColor3 = Theme.Background,
    BorderSizePixel = 0,
    ClipsDescendants = true
}, gui)
round(main, 12)

create("UIStroke", {
    Color = Color3.fromRGB(57, 51, 78),
    Thickness = 1
}, main)

-- Draggable window
local dragging = false
local dragStart
local startPosition

local top = create("Frame", {
    Name = "Topbar",
    Size = UDim2.new(1, 0, 0, 48),
    BackgroundColor3 = Theme.Panel,
    BorderSizePixel = 0
}, main)
round(top, 12)

-- Cover the lower rounded corners of the topbar
create("Frame", {
    Position = UDim2.new(0, 0, 1, -10),
    Size = UDim2.new(1, 0, 0, 10),
    BackgroundColor3 = Theme.Panel,
    BorderSizePixel = 0
}, top)

makeLabel(top, "ECLIPSE", UDim2.fromOffset(105, 30),
    UDim2.fromOffset(17, 9), 19, Theme.Accent).Font = Enum.Font.GothamBold

makeLabel(top, "HUB  /  BSS", UDim2.fromOffset(130, 25),
    UDim2.fromOffset(116, 12), 12, Theme.Muted)

local close = create("TextButton", {
    Text = "×",
    TextSize = 25,
    Font = Enum.Font.Gotham,
    TextColor3 = Theme.Text,
    BackgroundColor3 = Theme.Element,
    Size = UDim2.fromOffset(32, 30),
    Position = UDim2.new(1, -43, 0, 9),
    BorderSizePixel = 0
}, top)
round(close, 7)

close.MouseButton1Click:Connect(function()
    gui:Destroy()
end)

top.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPosition = main.Position
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging and (
        input.UserInputType == Enum.UserInputType.MouseMovement
        or input.UserInputType == Enum.UserInputType.Touch
    ) then
        local delta = input.Position - dragStart
        main.Position = UDim2.new(
            startPosition.X.Scale,
            startPosition.X.Offset + delta.X,
            startPosition.Y.Scale,
            startPosition.Y.Offset + delta.Y
        )
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
        dragging = false
    end
end)

local sidebar = create("Frame", {
    Name = "Sidebar",
    Position = UDim2.fromOffset(0, 48),
    Size = UDim2.new(0, 155, 1, -48),
    BackgroundColor3 = Theme.Panel,
    BorderSizePixel = 0
}, main)

local tabList = create("ScrollingFrame", {
    Position = UDim2.fromOffset(9, 12),
    Size = UDim2.new(1, -18, 1, -24),
    BackgroundTransparency = 1,
    BorderSizePixel = 0,
    ScrollBarThickness = 3,
    ScrollBarImageColor3 = Theme.Accent,
    CanvasSize = UDim2.new()
}, sidebar)

local tabLayout = create("UIListLayout", {
    Padding = UDim.new(0, 5),
    SortOrder = Enum.SortOrder.LayoutOrder
}, tabList)

tabLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    tabList.CanvasSize = UDim2.fromOffset(
        0, tabLayout.AbsoluteContentSize.Y + 5
    )
end)

local content = create("Frame", {
    Name = "Content",
    Position = UDim2.fromOffset(155, 48),
    Size = UDim2.new(1, -155, 1, -48),
    BackgroundTransparency = 1,
    BorderSizePixel = 0
}, main)

local currentPage
local tabButtons = {}

local function newPage(name)
    local page = create("ScrollingFrame", {
        Name = name,
        Size = UDim2.new(1, -24, 1, -24),
        Position = UDim2.fromOffset(12, 12),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ScrollBarThickness = 3,
        ScrollBarImageColor3 = Theme.Accent,
        CanvasSize = UDim2.new(),
        Visible = false
    }, content)

    local layout = create("UIListLayout", {
        Padding = UDim.new(0, 9),
        SortOrder = Enum.SortOrder.LayoutOrder
    }, page)

    layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        page.CanvasSize = UDim2.fromOffset(
            0, layout.AbsoluteContentSize.Y + 10
        )
    end)

    return page
end

local pages = {}

for _, name in ipairs(Tabs) do
    local button = create("TextButton", {
        Name = name,
        Text = name,
        TextSize = 13,
        Font = Enum.Font.GothamMedium,
        TextColor3 = Theme.Muted,
        BackgroundColor3 = Theme.Panel,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 35),
        BorderSizePixel = 0,
        AutoButtonColor = false
    }, tabList)

    round(button, 7)
    tabButtons[name] = button
    pages[name] = newPage(name)

    button.MouseButton1Click:Connect(function()
        if currentPage then
            currentPage.Visible = false
        end

        for _, other in pairs(tabButtons) do
            other.BackgroundTransparency = 1
            other.TextColor3 = Theme.Muted
        end

        currentPage = pages[name]
        currentPage.Visible = true
        button.BackgroundColor3 = Theme.Accent
        button.BackgroundTransparency = 0.72
        button.TextColor3 = Theme.Text
    end)
end

local function section(page, title)
    return makeLabel(page, title, UDim2.new(1, -4, 0, 28),
        UDim2.fromOffset(0, 0), 17, Theme.Text)
end

local function info(page, text)
    local frame = create("Frame", {
        Size = UDim2.new(1, -4, 0, 58),
        BackgroundColor3 = Theme.Panel,
        BorderSizePixel = 0
    }, page)
    round(frame, 8)

    makeLabel(frame, text, UDim2.new(1, -24, 1, -12),
        UDim2.fromOffset(12, 6), 12, Theme.Muted)
    return frame
end

local function toggle(page, title, settingKey)
    local row = create("Frame", {
        Size = UDim2.new(1, -4, 0, 43),
        BackgroundColor3 = Theme.Panel,
        BorderSizePixel = 0
    }, page)
    round(row, 8)

    makeLabel(row, title, UDim2.new(1, -95, 1, 0),
        UDim2.fromOffset(12, 0), 13, Theme.Text)

    local button = create("TextButton", {
        Size = UDim2.fromOffset(62, 27),
        Position = UDim2.new(1, -73, 0.5, -13),
        BackgroundColor3 = Theme.Element,
        Text = "OFF",
        TextColor3 = Theme.Muted,
        TextSize = 11,
        Font = Enum.Font.GothamBold,
        BorderSizePixel = 0
    }, row)
    round(button, 7)

    local function refresh()
        local enabled = Settings[settingKey]
        button.Text = enabled and "ON" or "OFF"
        button.BackgroundColor3 = enabled and Theme.Accent or Theme.Element
        button.TextColor3 = enabled and Theme.Text or Theme.Muted
    end

    refresh()

    button.MouseButton1Click:Connect(function()
        Settings[settingKey] = not Settings[settingKey]
        refresh()
    end)

    return row
end

local function dropdown(page, title, options, settingKey)
    local frame = create("Frame", {
        Size = UDim2.new(1, -4, 0, 66),
        BackgroundColor3 = Theme.Panel,
        BorderSizePixel = 0
    }, page)
    round(frame, 8)

    makeLabel(frame, title, UDim2.new(1, -20, 0, 23),
        UDim2.fromOffset(12, 5), 12, Theme.Muted)

    local selectedIndex = 1

    local button = create("TextButton", {
        Position = UDim2.fromOffset(10, 32),
        Size = UDim2.new(1, -20, 0, 26),
        BackgroundColor3 = Theme.Element,
        Text = options[selectedIndex] .. "   ▼",
        TextColor3 = Theme.Text,
        TextSize = 12,
        Font = Enum.Font.Gotham,
        BorderSizePixel = 0
    }, frame)
    round(button, 6)

    button.MouseButton1Click:Connect(function()
        selectedIndex = selectedIndex % #options + 1
        Settings[settingKey] = options[selectedIndex]
        button.Text = options[selectedIndex] .. "   ▼"
    end)

    return frame
end

-- HOME
section(pages.Home, "Welcome to EclipseHub")
info(pages.Home,
    "A customizable Bee Swarm Simulator hub. Select a section from the left menu.")
info(pages.Home,
    "Version: 0.1 UI foundation\nStatus: Interface loaded")
info(pages.Home,
    "Gameplay automation is not connected yet. Toggle states currently only save in this session.")

-- FARM
section(pages.Farm, "Farm Settings")
dropdown(pages.Farm, "Select Field", Fields, "SelectedField")
toggle(pages.Farm, "Auto Farm", "AutoFarm")
toggle(pages.Farm, "Auto Collect Tokens", "AutoCollectTokens")
toggle(pages.Farm, "Auto Convert Pollen", "AutoConvert")
toggle(pages.Farm, "Auto Use Sprinkler", "AutoUseSprinkler")

-- QUEST
section(pages.Quest, "Quest Settings")
toggle(pages.Quest, "Auto Quest", "AutoQuest")
info(pages.Quest,
    "Quest automation is not implemented. NPC selection and quest progress need to be added.")

-- PLANTERS
section(pages.Planters, "Planter Settings")
toggle(pages.Planters, "Auto Planters", "AutoPlanters")
info(pages.Planters,
    "Planter placement, harvesting, and planter selection are not connected yet.")

-- TOYS
section(pages.Toys, "Toy Settings")
info(pages.Toys,
    "Toy automation options will be added here.")

-- WEBHOOK
section(pages.Webhook, "Webhook Settings")
info(pages.Webhook,
    "Webhook delivery is not configured. Do not enter private tokens into untrusted scripts.")

-- CONFIG
section(pages.Config, "Configuration")
info(pages.Config,
    "Current settings are temporary and reset when the script is restarted.")

-- DEBUG
section(pages.Debug, "Debug")
info(pages.Debug,
    "UI status: loaded\nThis page does not bypass Roblox protections.")

-- FARM TOKEN
section(pages["Farm Token"], "Farm Token")
toggle(pages["Farm Token"], "Token options", "AutoCollectTokens")
info(pages["Farm Token"],
    "This switch shares the Auto Collect Tokens setting on the Farm page.")

-- ANTIBAN
section(pages.AntiBan, "Safety")
info(pages.AntiBan,
    "No script can guarantee that an account will not be moderated. This page does not bypass anti-cheat.")

-- SERVER HOP
section(pages["Server Hop"], "Server Hop")
info(pages["Server Hop"],
    "Server switching is not implemented in this UI foundation.")

-- Open Home by default
tabButtons.Home.BackgroundColor3 = Theme.Accent
tabButtons.Home.BackgroundTransparency = 0.72
tabButtons.Home.TextColor3 = Theme.Text
currentPage = pages.Home
currentPage.Visible = true

print("[EclipseHub] UI foundation loaded.")
