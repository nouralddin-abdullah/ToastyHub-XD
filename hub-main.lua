-- ################################# --
-- ##      99 Nights Hub          ## --
-- ##    Simple All-in-One        ## --
-- ################################# --

-- Configuration
local CONFIG = {
    KEY_URL = "https://pastefy.app/PaRgx1Pf/raw",
    KEY_LINK = "https://lootdest.org/s?NXoK9Psz",
    DISCORD = "https://discord.gg/pH3NyVYC72",
    GAMES_CONFIG_URL = "https://raw.githubusercontent.com/nouralddin-abdullah/ToastyHub-XD/refs/heads/main/games-config.lua",
    TUTORIAL_VIDEO = "https://cdn.discordapp.com/attachments/1419031899141046323/1419898441697591358/Timeline_1.mp4?ex=68e1ef78&is=68e09df8&hm=10a491e6bae58438aad041c0c7205ca866a2cee67c2bf40ce4563b9b4dcec990&",
    AUTH_FILE = "toastyxdd_auth.txt", -- File to save authentication
    EVENT_MODE_URL = "https://pastefy.app/YOUR_EVENT_URL/raw" -- URL that returns "true" or "false" for event mode
}

-- Services
local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")

-- State
local IsAuthenticated = false
local IsEventMode = false
local GamesList = {}

-- Authentication persistence functions
local function saveAuth(key)
    if writefile then
        writefile(CONFIG.AUTH_FILE, key)
        print("✅ Key saved locally")
    end
end

local function loadAuth()
    if readfile and isfile and isfile(CONFIG.AUTH_FILE) then
        local success, savedKey = pcall(function()
            return readfile(CONFIG.AUTH_FILE)
        end)
        if success and savedKey then
            return savedKey
        end
    end
    return nil
end

local function deleteAuth()
    if delfile and isfile and isfile(CONFIG.AUTH_FILE) then
        delfile(CONFIG.AUTH_FILE)
        print("🗑️ Saved key deleted (invalid/expired)")
    end
end

local function validateKey(keyToValidate)
    local success, correctKey = pcall(function()
        return game:HttpGet(CONFIG.KEY_URL)
    end)
    
    if success then
        local cleanKey = keyToValidate:gsub("%s+", ""):lower()
        local cleanCorrectKey = correctKey:gsub("%s+", ""):lower()
        return cleanKey == cleanCorrectKey
    end
    return false
end

local function autoAuthenticate()
    local savedKey = loadAuth()
    if savedKey then
        print("🔑 Found saved key, validating...")
        if validateKey(savedKey) then
            IsAuthenticated = true
            print("✅ Auto-authenticated successfully!")
            return true
        else
            print("❌ Saved key is invalid/expired")
            deleteAuth()
            return false
        end
    end
    return false
end

-- Check if event mode is active
local function checkEventMode()
    local success, response = pcall(function()
        return game:HttpGet(CONFIG.EVENT_MODE_URL)
    end)
    
    if success and response then
        local eventActive = response:gsub("%s+", ""):lower() == "true"
        if eventActive then
            IsEventMode = true
            print("🎉 EVENT MODE ACTIVE - All games are FREE!")
            return true
        end
    end
    return false
end

-- Load games configuration
local function loadGamesConfig()
    local success, result = pcall(function()
        local configScript = game:HttpGet(CONFIG.GAMES_CONFIG_URL)
        return loadstring(configScript)()
    end)
    
    if success and result then
        GamesList = result
        print("Loaded " .. #GamesList .. " games")
    else
        warn("Failed to load games config, using defaults")
        -- Fallback games
        GamesList = {
    {
        name = "99 Nights",
        gameId = 123456789, -- Replace with actual game ID
        scriptUrl = "https://raw.githubusercontent.com/nouralddin-abdullah/99-night/refs/heads/main/main-en-script.lua",
        premium = true, -- true = requires key, false = free
        icon = "🌙"
    },
    {
        name = "Plants Vs Brainrots",
        gameId = 13772394625,
        scriptUrl = "https://example.com/bladeball.lua",
        premium = false,
        icon = "🌱"
    }
}
    end
end

-- Load script function
local function loadScript(scriptUrl, gameName)
    local success, content = pcall(function()
        return game:HttpGet(scriptUrl)
    end)
    
    if success then
        loadstring(content)()
        return true
    else
        warn("Failed to load " .. gameName)
        return false
    end
end

-- Check if can run game
local function canRun(game)
    return not game.premium or IsAuthenticated or IsEventMode
end

-- Create GUI
loadGamesConfig()

-- Check for event mode
checkEventMode()

-- Try to auto-authenticate with saved key
autoAuthenticate()

if CoreGui:FindFirstChild("SimpleHub") then
    CoreGui:FindFirstChild("SimpleHub"):Destroy()
end

local Hub = Instance.new("ScreenGui")
Hub.Name = "SimpleHub"
Hub.Parent = CoreGui
Hub.ResetOnSpawn = false
Hub.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
Hub.DisplayOrder = 999999

pcall(function()
    Hub:SetAttribute("Protected", true)
    local gethui = gethui or function() return CoreGui end
    Hub.Parent = gethui()
end)

-- Main Frame (Responsive sizing)
local Main = Instance.new("Frame")
-- Use scale for responsive sizing: 85% width on mobile, 650px max on PC
local ViewportSize = workspace.CurrentCamera.ViewportSize
local isMobile = ViewportSize.X < 600 or ViewportSize.Y < 500

local function calculateSize(viewportSize, mobile)
    if mobile then
        -- Mobile: narrower width (75%), taller height (80%)
        local width = math.min(viewportSize.X * 0.75, 400) -- Max 400px or 75% of screen
        local height = viewportSize.Y * 0.8 -- 80% height
        return UDim2.fromOffset(width, height)
    else
        -- Calculate 70% of viewport but clamp between 500-650 width and 400-500 height
        local width = math.clamp(viewportSize.X * 0.7, 500, 650)
        local height = math.clamp(viewportSize.Y * 0.75, 400, 500)
        return UDim2.fromOffset(width, height)
    end
end

Main.Size = calculateSize(ViewportSize, isMobile)
Main.AnchorPoint = Vector2.new(0.5, 0.5)
Main.Position = UDim2.new(0.5, 0, 0.5, 0)
Main.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
Main.BorderSizePixel = 0
Main.Parent = Hub
Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 12)

-- Auto-adjust on viewport resize
workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(function()
    local newViewportSize = workspace.CurrentCamera.ViewportSize
    local newIsMobile = newViewportSize.X < 600 or newViewportSize.Y < 500
    Main.Size = calculateSize(newViewportSize, newIsMobile)
end)

-- Header
local Header = Instance.new("Frame")
Header.Size = UDim2.new(1, 0, 0, 50)
Header.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
Header.BorderSizePixel = 0
Header.Parent = Main
Instance.new("UICorner", Header).CornerRadius = UDim.new(0, 12)

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -100, 1, 0)
Title.Position = UDim2.fromOffset(15, 0)
Title.BackgroundTransparency = 1
Title.Text = "🌟 ToastyxDD Hub"
Title.Font = Enum.Font.GothamBold
Title.TextSize = 20
Title.TextColor3 = Color3.new(1, 1, 1)
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = Header

local MinimizeBtn = Instance.new("TextButton")
MinimizeBtn.Size = UDim2.fromOffset(35, 35)
MinimizeBtn.Position = UDim2.new(1, -90, 0.5, -17.5)
MinimizeBtn.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
MinimizeBtn.Text = "—"
MinimizeBtn.Font = Enum.Font.GothamBold
MinimizeBtn.TextSize = 16
MinimizeBtn.TextColor3 = Color3.new(1, 1, 1)
MinimizeBtn.Parent = Header
Instance.new("UICorner", MinimizeBtn).CornerRadius = UDim.new(0, 8)

local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.fromOffset(35, 35)
CloseBtn.Position = UDim2.new(1, -45, 0.5, -17.5)
CloseBtn.BackgroundColor3 = Color3.fromRGB(220, 50, 50)
CloseBtn.Text = "✕"
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextSize = 16
CloseBtn.TextColor3 = Color3.new(1, 1, 1)
CloseBtn.Parent = Header
Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0, 8)

CloseBtn.MouseButton1Click:Connect(function()
    Hub:Destroy()
end)

-- Minimized circle button
local MinimizedCircle = Instance.new("TextButton")
MinimizedCircle.Size = UDim2.fromOffset(60, 60)
MinimizedCircle.AnchorPoint = Vector2.new(0.5, 0.5)
MinimizedCircle.Position = UDim2.new(0.5, 0, 0.5, 0)
MinimizedCircle.BackgroundColor3 = Color3.fromRGB(0, 120, 255)
MinimizedCircle.Text = "🌟"
MinimizedCircle.Font = Enum.Font.GothamBold
MinimizedCircle.TextSize = 30
MinimizedCircle.TextColor3 = Color3.new(1, 1, 1)
MinimizedCircle.Visible = false
MinimizedCircle.Parent = Hub
Instance.new("UICorner", MinimizedCircle).CornerRadius = UDim.new(1, 0) -- Perfect circle

-- Make window draggable
local UserInputService = game:GetService("UserInputService")
local dragging
local dragInput
local dragStart
local startPos

local function update(input)
    local delta = input.Position - dragStart
    if Main.Visible then
        Main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    else
        MinimizedCircle.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end

Header.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = Main.Position
        
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

Header.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)

MinimizedCircle.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = MinimizedCircle.Position
        
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

MinimizedCircle.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        update(input)
    end
end)

-- Minimize/Restore functionality
MinimizeBtn.MouseButton1Click:Connect(function()
    Main.Visible = false
    MinimizedCircle.Visible = true
end)

MinimizedCircle.MouseButton1Click:Connect(function()
    MinimizedCircle.Visible = false
    Main.Visible = true
end)

-- Event Banner (if event is active)
local EventBanner = nil
if IsEventMode then
    EventBanner = Instance.new("Frame")
    EventBanner.Size = UDim2.new(1, -30, 0, 30)
    EventBanner.Position = UDim2.fromOffset(15, 60)
    EventBanner.BackgroundColor3 = Color3.fromRGB(255, 100, 0)
    EventBanner.BorderSizePixel = 0
    EventBanner.Parent = Main
    Instance.new("UICorner", EventBanner).CornerRadius = UDim.new(0, 8)
    
    local BannerText = Instance.new("TextLabel")
    BannerText.Size = UDim2.new(1, 0, 1, 0)
    BannerText.BackgroundTransparency = 1
    BannerText.Text = "🎉 EVENT MODE: All Games FREE! 🎉"
    BannerText.Font = Enum.Font.GothamBold
    BannerText.TextSize = 14
    BannerText.TextColor3 = Color3.new(1, 1, 1)
    BannerText.Parent = EventBanner
    
    -- Animated glow effect
    task.spawn(function()
        while EventBanner and EventBanner.Parent do
            for i = 0, 1, 0.05 do
                if EventBanner and EventBanner.Parent then
                    EventBanner.BackgroundColor3 = Color3.new(1, 0.4 + (i * 0.2), 0)
                    task.wait(0.05)
                end
            end
            for i = 1, 0, -0.05 do
                if EventBanner and EventBanner.Parent then
                    EventBanner.BackgroundColor3 = Color3.new(1, 0.4 + (i * 0.2), 0)
                    task.wait(0.05)
                end
            end
        end
    end)
end

-- Tabs
local TabsFrame = Instance.new("Frame")
local tabYPos = IsEventMode and 100 or 60
TabsFrame.Size = UDim2.new(1, -30, 0, 40)
TabsFrame.Position = UDim2.fromOffset(15, tabYPos)
TabsFrame.BackgroundTransparency = 1
TabsFrame.Parent = Main

local GamesTab = Instance.new("TextButton")
GamesTab.Size = UDim2.fromOffset(120, 35)
GamesTab.Position = UDim2.fromOffset(0, 0)
GamesTab.BackgroundColor3 = Color3.fromRGB(0, 120, 255)
GamesTab.Text = "🎮 Games"
GamesTab.Font = Enum.Font.GothamBold
GamesTab.TextSize = 12
GamesTab.TextColor3 = Color3.new(1, 1, 1)
GamesTab.Parent = TabsFrame
Instance.new("UICorner", GamesTab).CornerRadius = UDim.new(0, 8)

local AuthTab = Instance.new("TextButton")
AuthTab.Size = UDim2.fromOffset(120, 35)
AuthTab.Position = UDim2.fromOffset(130, 0)
AuthTab.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
AuthTab.Text = "🔐 Auth"
AuthTab.Font = Enum.Font.GothamBold
AuthTab.TextSize = 12
AuthTab.TextColor3 = Color3.new(1, 1, 1)
AuthTab.Parent = TabsFrame
Instance.new("UICorner", AuthTab).CornerRadius = UDim.new(0, 8)

local HowToTab = Instance.new("TextButton")
HowToTab.Size = UDim2.fromOffset(120, 35)
HowToTab.Position = UDim2.fromOffset(260, 0)
HowToTab.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
HowToTab.Text = "📺 How to Get Key"
HowToTab.Font = Enum.Font.GothamBold
HowToTab.TextSize = 11
HowToTab.TextColor3 = Color3.new(1, 1, 1)
HowToTab.Parent = TabsFrame
Instance.new("UICorner", HowToTab).CornerRadius = UDim.new(0, 8)

-- Games Content
local contentYPos = IsEventMode and 150 or 110
local contentHeight = IsEventMode and -160 or -120
local GamesContent = Instance.new("Frame")
GamesContent.Size = UDim2.new(1, -30, 1, contentHeight)
GamesContent.Position = UDim2.fromOffset(15, contentYPos)
GamesContent.BackgroundTransparency = 1
GamesContent.Visible = true
GamesContent.Parent = Main

local GamesScroll = Instance.new("ScrollingFrame")
GamesScroll.Size = UDim2.new(1, 0, 1, 0)
GamesScroll.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
GamesScroll.BorderSizePixel = 0
GamesScroll.ScrollBarThickness = 6
GamesScroll.ScrollBarImageColor3 = Color3.fromRGB(80, 80, 80)
GamesScroll.Parent = GamesContent
Instance.new("UICorner", GamesScroll).CornerRadius = UDim.new(0, 8)

local Layout = Instance.new("UIListLayout")
Layout.Padding = UDim.new(0, 8)
Layout.Parent = GamesScroll

-- Auth Content
local AuthContent = Instance.new("Frame")
AuthContent.Size = UDim2.new(1, -30, 1, contentHeight)
AuthContent.Position = UDim2.fromOffset(15, contentYPos)
AuthContent.BackgroundTransparency = 1
AuthContent.Visible = false
AuthContent.Parent = Main

local AuthStatus = Instance.new("TextLabel")
AuthStatus.Size = UDim2.new(1, 0, 0, 30)
AuthStatus.BackgroundTransparency = 1
AuthStatus.Text = IsAuthenticated and "✅ Authenticated (Auto)" or "🔒 Not Authenticated"
AuthStatus.Font = Enum.Font.GothamBold
AuthStatus.TextSize = 14
AuthStatus.TextColor3 = IsAuthenticated and Color3.fromRGB(0, 255, 120) or Color3.fromRGB(255, 100, 100)
AuthStatus.Parent = AuthContent

local KeyInput = Instance.new("TextBox")
KeyInput.Size = UDim2.new(1, 0, 0, 40)
KeyInput.Position = UDim2.fromOffset(0, 50)
KeyInput.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
KeyInput.PlaceholderText = "Enter key here..."
KeyInput.Text = ""
KeyInput.Font = Enum.Font.Gotham
KeyInput.TextSize = 14
KeyInput.TextColor3 = Color3.new(1, 1, 1)
KeyInput.Visible = not IsAuthenticated
KeyInput.Parent = AuthContent
Instance.new("UICorner", KeyInput).CornerRadius = UDim.new(0, 8)

local CheckBtn = Instance.new("TextButton")
if isMobile then
    -- Mobile: 32% width, first in row
    CheckBtn.Size = UDim2.new(0.31, 0, 0, 40)
    CheckBtn.Position = UDim2.fromOffset(0, 105)
else
    -- Desktop: full width
    CheckBtn.Size = UDim2.new(1, 0, 0, 40)
    CheckBtn.Position = UDim2.fromOffset(0, 105)
end
CheckBtn.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
CheckBtn.Text = isMobile and "✅ Verify" or "✅ Verify Key"
CheckBtn.Font = Enum.Font.GothamBold
CheckBtn.TextSize = isMobile and 11 or 13
CheckBtn.TextColor3 = Color3.new(1, 1, 1)
CheckBtn.Visible = not IsAuthenticated
CheckBtn.Parent = AuthContent
Instance.new("UICorner", CheckBtn).CornerRadius = UDim.new(0, 8)

local GetKeyBtn = Instance.new("TextButton")
if isMobile then
    -- Mobile: 32% width, middle in row
    GetKeyBtn.Size = UDim2.new(0.31, 0, 0, 40)
    GetKeyBtn.Position = UDim2.new(0.345, 0, 0, 105)
else
    -- Desktop: full width
    GetKeyBtn.Size = UDim2.new(1, 0, 0, 40)
    GetKeyBtn.Position = UDim2.fromOffset(0, 160)
end
GetKeyBtn.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
GetKeyBtn.Text = isMobile and "🔑 Key" or "🔑 Get Key"
GetKeyBtn.Font = Enum.Font.GothamBold
GetKeyBtn.TextSize = isMobile and 11 or 13
GetKeyBtn.TextColor3 = Color3.new(1, 1, 1)
GetKeyBtn.Visible = not IsAuthenticated
GetKeyBtn.Parent = AuthContent
Instance.new("UICorner", GetKeyBtn).CornerRadius = UDim.new(0, 8)

local DiscordBtn = Instance.new("TextButton")
if isMobile then
    -- Mobile: 32% width, last in row (all 3 buttons in same line)
    DiscordBtn.Size = UDim2.new(0.31, 0, 0, 40)
    DiscordBtn.Position = UDim2.new(0.69, 0, 0, 105)
else
    -- Desktop: full width below Get Key
    DiscordBtn.Size = UDim2.new(1, 0, 0, 40)
    DiscordBtn.Position = UDim2.fromOffset(0, 215)
end
DiscordBtn.BackgroundColor3 = Color3.fromRGB(114, 137, 218)
DiscordBtn.Text = isMobile and "💬 DC" or "💬 Discord"
DiscordBtn.Font = Enum.Font.GothamBold
DiscordBtn.TextSize = isMobile and 11 or 13
DiscordBtn.TextColor3 = Color3.new(1, 1, 1)
DiscordBtn.Parent = AuthContent
Instance.new("UICorner", DiscordBtn).CornerRadius = UDim.new(0, 8)

-- How To Get Key Content
local HowToContent = Instance.new("Frame")
HowToContent.Size = UDim2.new(1, -30, 1, contentHeight)
HowToContent.Position = UDim2.fromOffset(15, contentYPos)
HowToContent.BackgroundTransparency = 1
HowToContent.Visible = false
HowToContent.Parent = Main

local HowToTitle = Instance.new("TextLabel")
HowToTitle.Size = UDim2.new(1, 0, 0, 30)
HowToTitle.BackgroundTransparency = 1
HowToTitle.Text = "📺 How to Get Your Key"
HowToTitle.Font = Enum.Font.GothamBold
HowToTitle.TextSize = 16
HowToTitle.TextColor3 = Color3.fromRGB(255, 200, 0)
HowToTitle.Parent = HowToContent

-- Video Coming Soon Placeholder
local VideoPlaceholder = Instance.new("Frame")
VideoPlaceholder.Size = UDim2.new(1, 0, 1, -50)
VideoPlaceholder.Position = UDim2.fromOffset(0, 40)
VideoPlaceholder.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
VideoPlaceholder.BorderSizePixel = 0
VideoPlaceholder.Parent = HowToContent
Instance.new("UICorner", VideoPlaceholder).CornerRadius = UDim.new(0, 8)

local ComingSoonIcon = Instance.new("TextLabel")
ComingSoonIcon.Size = UDim2.new(1, 0, 0, 80)
ComingSoonIcon.Position = UDim2.new(0, 0, 0.5, -60)
ComingSoonIcon.BackgroundTransparency = 1
ComingSoonIcon.Text = "🎬"
ComingSoonIcon.Font = Enum.Font.GothamBold
ComingSoonIcon.TextSize = 60
ComingSoonIcon.TextColor3 = Color3.fromRGB(255, 200, 0)
ComingSoonIcon.Parent = VideoPlaceholder

local ComingSoonText = Instance.new("TextLabel")
ComingSoonText.Size = UDim2.new(1, -40, 0, 40)
ComingSoonText.Position = UDim2.new(0, 20, 0.5, 20)
ComingSoonText.BackgroundTransparency = 1
ComingSoonText.Text = "Video Tutorial\nComing Soon!"
ComingSoonText.Font = Enum.Font.GothamBold
ComingSoonText.TextSize = 18
ComingSoonText.TextColor3 = Color3.fromRGB(200, 200, 200)
ComingSoonText.TextWrapped = true
ComingSoonText.Parent = VideoPlaceholder

local InfoText = Instance.new("TextLabel")
InfoText.Size = UDim2.new(1, -40, 0, 30)
InfoText.Position = UDim2.new(0, 20, 0.5, 70)
InfoText.BackgroundTransparency = 1
InfoText.Text = "Check back later for a step-by-step video guide"
InfoText.Font = Enum.Font.Gotham
InfoText.TextSize = 12
InfoText.TextColor3 = Color3.fromRGB(150, 150, 150)
InfoText.TextWrapped = true
InfoText.Parent = VideoPlaceholder

-- Tab switching (defined early so game cards can use it)
local function switchTab(tabName)
    -- Hide all content
    GamesContent.Visible = false
    AuthContent.Visible = false
    HowToContent.Visible = false
    
    -- Reset all tab colors
    GamesTab.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    AuthTab.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    HowToTab.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    
    -- Show selected tab
    if tabName == "games" then
        GamesContent.Visible = true
        GamesTab.BackgroundColor3 = Color3.fromRGB(0, 120, 255)
    elseif tabName == "auth" then
        AuthContent.Visible = true
        AuthTab.BackgroundColor3 = Color3.fromRGB(0, 120, 255)
    elseif tabName == "howto" then
        HowToContent.Visible = true
        HowToTab.BackgroundColor3 = Color3.fromRGB(0, 120, 255)
    end
end

-- Create game cards
local function createGameCard(game)
    local Card = Instance.new("Frame")
    Card.Size = UDim2.new(1, -12, 0, 60)
    Card.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    Card.BorderSizePixel = 0
    Card.Parent = GamesScroll
    Instance.new("UICorner", Card).CornerRadius = UDim.new(0, 8)
    
    local Icon = Instance.new("TextLabel")
    Icon.Size = UDim2.fromOffset(45, 45)
    Icon.Position = UDim2.fromOffset(8, 7.5)
    Icon.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    Icon.Text = game.icon
    Icon.Font = Enum.Font.GothamBold
    Icon.TextSize = 22
    Icon.Parent = Card
    Instance.new("UICorner", Icon).CornerRadius = UDim.new(0, 8)
    
    local Name = Instance.new("TextLabel")
    Name.Size = UDim2.new(1, -180, 0, 25)
    Name.Position = UDim2.fromOffset(63, 10)
    Name.BackgroundTransparency = 1
    Name.Text = game.name
    Name.Font = Enum.Font.GothamBold
    Name.TextSize = 13
    Name.TextColor3 = Color3.new(1, 1, 1)
    Name.TextXAlignment = Enum.TextXAlignment.Left
    Name.Parent = Card
    
    local Badge = Instance.new("TextLabel")
    Badge.Size = UDim2.fromOffset(60, 20)
    Badge.Position = UDim2.fromOffset(63, 35)
    Badge.BackgroundColor3 = game.premium and Color3.fromRGB(255, 200, 0) or Color3.fromRGB(0, 170, 80)
    Badge.Text = game.premium and "⭐ Premium" or "✓ Free"
    Badge.Font = Enum.Font.GothamBold
    Badge.TextSize = 9
    Badge.TextColor3 = Color3.fromRGB(0, 0, 0)
    Badge.Parent = Card
    Instance.new("UICorner", Badge).CornerRadius = UDim.new(0, 4)
    
    local RunBtn = Instance.new("TextButton")
    RunBtn.Size = UDim2.fromOffset(90, 45)
    RunBtn.Position = UDim2.new(1, -98, 0.5, -22.5)
    RunBtn.BackgroundColor3 = canRun(game) and Color3.fromRGB(0, 170, 80) or Color3.fromRGB(100, 100, 100)
    RunBtn.Text = canRun(game) and "▶️ Run" or "🔒 Locked"
    RunBtn.Font = Enum.Font.GothamBold
    RunBtn.TextSize = 12
    RunBtn.TextColor3 = Color3.new(1, 1, 1)
    RunBtn.Parent = Card
    Instance.new("UICorner", RunBtn).CornerRadius = UDim.new(0, 8)
    
    RunBtn.MouseButton1Click:Connect(function()
        if canRun(game) then
            RunBtn.Text = "⏳ Loading..."
            RunBtn.BackgroundColor3 = Color3.fromRGB(0, 120, 200)
            
            if loadScript(game.scriptUrl, game.name) then
                RunBtn.Text = "✅ Loaded"
                RunBtn.BackgroundColor3 = Color3.fromRGB(0, 200, 100)
                task.wait(2)
                RunBtn.Text = "▶️ Run"
                RunBtn.BackgroundColor3 = Color3.fromRGB(0, 170, 80)
            else
                RunBtn.Text = "❌ Failed"
                RunBtn.BackgroundColor3 = Color3.fromRGB(220, 50, 50)
                task.wait(2)
                RunBtn.Text = "▶️ Run"
                RunBtn.BackgroundColor3 = Color3.fromRGB(0, 170, 80)
            end
        else
            -- Switch to Auth tab when locked game is clicked
            RunBtn.Text = "🔑 Need Key"
            task.wait(0.5)
            RunBtn.Text = "🔒 Locked"
            switchTab("auth") -- Switch to Auth tab
        end
    end)
    
    return Card, RunBtn
end

-- Populate games
local gameButtons = {}
for _, game in ipairs(GamesList) do
    local card, btn = createGameCard(game)
    gameButtons[game.name] = {card = card, button = btn, game = game}
end

GamesScroll.CanvasSize = UDim2.new(0, 0, 0, #GamesList * 68)

-- Update UI based on auth status
local function updateAuthUI()
    if IsAuthenticated then
        AuthStatus.Text = "✅ Authenticated"
        AuthStatus.TextColor3 = Color3.fromRGB(0, 255, 120)
        KeyInput.Visible = false
        CheckBtn.Visible = false
        GetKeyBtn.Visible = false
    else
        AuthStatus.Text = "🔒 Not Authenticated"
        AuthStatus.TextColor3 = Color3.fromRGB(255, 100, 100)
        KeyInput.Visible = true
        CheckBtn.Visible = true
        GetKeyBtn.Visible = true
    end
    
    -- Update all game buttons
    for _, data in pairs(gameButtons) do
        local canRun = not data.game.premium or IsAuthenticated
        data.button.BackgroundColor3 = canRun and Color3.fromRGB(0, 170, 80) or Color3.fromRGB(100, 100, 100)
        data.button.Text = canRun and "▶️ Run" or "🔒 Locked"
    end
end

-- Connect tab buttons
GamesTab.MouseButton1Click:Connect(function() switchTab("games") end)
AuthTab.MouseButton1Click:Connect(function() switchTab("auth") end)
HowToTab.MouseButton1Click:Connect(function() switchTab("howto") end)

-- Auth buttons
CheckBtn.MouseButton1Click:Connect(function()
    CheckBtn.Text = "⏳ Checking..."
    
    local enteredKey = KeyInput.Text
    
    if validateKey(enteredKey) then
        IsAuthenticated = true
        saveAuth(enteredKey) -- Save key for future use
        CheckBtn.Text = "✅ Success!"
        CheckBtn.BackgroundColor3 = Color3.fromRGB(0, 200, 100)
        updateAuthUI()
        task.wait(1)
        switchTab("games")
    else
        CheckBtn.Text = "❌ Wrong Key"
        CheckBtn.BackgroundColor3 = Color3.fromRGB(220, 50, 50)
        task.wait(2)
        CheckBtn.Text = "✅ Verify Key"
        CheckBtn.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
    end
end)

GetKeyBtn.MouseButton1Click:Connect(function()
    if setclipboard then
        setclipboard(CONFIG.KEY_LINK)
        GetKeyBtn.Text = "✅ Copied!"
        GetKeyBtn.BackgroundColor3 = Color3.fromRGB(0, 200, 100)
        task.wait(2)
        GetKeyBtn.Text = "🔑 Get Key"
        GetKeyBtn.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
    end
end)

DiscordBtn.MouseButton1Click:Connect(function()
    if setclipboard then
        setclipboard(CONFIG.DISCORD)
        DiscordBtn.Text = "✅ Copied!"
        DiscordBtn.BackgroundColor3 = Color3.fromRGB(0, 200, 100)
        task.wait(2)
        DiscordBtn.Text = "💬 Discord"
        DiscordBtn.BackgroundColor3 = Color3.fromRGB(114, 137, 218)
    end
end)

print("✅ ToastyxDD Hub loaded!")
print("📊 Games: " .. #GamesList)
print("🔐 Auth: " .. (IsAuthenticated and "Yes" or "No"))
print("🎉 Event Mode: " .. (IsEventMode and "Active (All FREE!)" or "Inactive"))
