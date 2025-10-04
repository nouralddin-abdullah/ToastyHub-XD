-- ################################# --
-- ##    99 Nights Hub Main       ## --
-- ################################# --

local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")

-- Check authentication status
local AuthStatus = getgenv().HubAuthStatus or { authenticated = false, username = "User", timestamp = 0 }
local HasPremium = AuthStatus.authenticated

-- ################################# --
-- ## Game Configuration ## --
-- ################################# --

-- Add your games here with their configuration
local GamesList = {
    {
        name = "99 Nights",
        gameId = 123456789, -- Replace with actual game ID
        scriptUrl = "https://raw.githubusercontent.com/nouralddin-abdullah/99-night/refs/heads/main/main-en-script.lua",
        premium = true, -- Requires key
        description = "Main 99 Nights script",
        icon = "🌙"
    },
    {
        name = "Example Game 1",
        gameId = 987654321,
        scriptUrl = "https://example.com/script1.lua",
        premium = false, -- Free
        description = "Free game script",
        icon = "🎮"
    },
    {
        name = "Example Game 2",
        gameId = 111222333,
        scriptUrl = "https://example.com/script2.lua",
        premium = true,
        description = "Premium game script",
        icon = "⚔️"
    },
    {
        name = "Example Game 3",
        gameId = 444555666,
        scriptUrl = "https://example.com/script3.lua",
        premium = false,
        description = "Another free script",
        icon = "🏃"
    },
    -- Add more games here...
}

-- ################################# --
-- ## Helper Functions ## --
-- ################################# --

local function canAccessGame(game)
    if not game.premium then
        return true -- Free games are always accessible
    end
    return HasPremium -- Premium games require authentication
end

local function loadGameScript(scriptUrl, gameName)
    local success, scriptContent = pcall(function()
        return game:HttpGet(scriptUrl)
    end)
    
    if success then
        loadstring(scriptContent)()
        print(gameName .. " script loaded successfully!")
        return true
    else
        warn("Failed to load " .. gameName .. " script: " .. tostring(scriptContent))
        return false
    end
end

local function getCurrentGameId()
    return game.PlaceId
end

-- ################################# --
-- ## Create Hub GUI ## --
-- ################################# --

-- Remove old hub if exists
if CoreGui:FindFirstChild("NinetyNineNightsHub") then
    CoreGui:FindFirstChild("NinetyNineNightsHub"):Destroy()
end

local HubScreen = Instance.new("ScreenGui")
HubScreen.Name = "NinetyNineNightsHub"
HubScreen.Parent = CoreGui
HubScreen.ResetOnSpawn = false
HubScreen.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
HubScreen.DisplayOrder = 999998
HubScreen.IgnoreGuiInset = true

-- Protect the GUI
pcall(function()
    HubScreen:SetAttribute("Protected", true)
    gethui = gethui or function() return CoreGui end
    HubScreen.Parent = gethui()
end)

-- Main Frame
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.fromOffset(600, 450)
MainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
MainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
MainFrame.BorderSizePixel = 0
MainFrame.Parent = HubScreen
MainFrame.Visible = false -- Start hidden for animation
local MainCorner = Instance.new("UICorner", MainFrame)
MainCorner.CornerRadius = UDim.new(0, 12)

-- Shadow effect
local Shadow = Instance.new("ImageLabel")
Shadow.Name = "Shadow"
Shadow.BackgroundTransparency = 1
Shadow.Position = UDim2.fromOffset(-15, -15)
Shadow.Size = UDim2.new(1, 30, 1, 30)
Shadow.ZIndex = 0
Shadow.Image = "rbxasset://textures/ui/GuiImagePlaceholder.png"
Shadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
Shadow.ImageTransparency = 0.5
Shadow.ScaleType = Enum.ScaleType.Slice
Shadow.SliceCenter = Rect.new(10, 10, 10, 10)
Shadow.Parent = MainFrame

-- Header
local Header = Instance.new("Frame")
Header.Name = "Header"
Header.Size = UDim2.new(1, 0, 0, 60)
Header.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
Header.BorderSizePixel = 0
Header.Parent = MainFrame
local HeaderCorner = Instance.new("UICorner", Header)
HeaderCorner.CornerRadius = UDim.new(0, 12)

local HeaderTitle = Instance.new("TextLabel")
HeaderTitle.Size = UDim2.new(1, -120, 1, 0)
HeaderTitle.Position = UDim2.fromOffset(20, 0)
HeaderTitle.BackgroundTransparency = 1
HeaderTitle.Text = "🌟 99 Nights Hub"
HeaderTitle.Font = Enum.Font.GothamBold
HeaderTitle.TextSize = 22
HeaderTitle.TextColor3 = Color3.new(1, 1, 1)
HeaderTitle.TextXAlignment = Enum.TextXAlignment.Left
HeaderTitle.Parent = Header

local StatusBadge = Instance.new("TextLabel")
StatusBadge.Size = UDim2.fromOffset(100, 30)
StatusBadge.Position = UDim2.new(1, -110, 0.5, -15)
StatusBadge.BackgroundColor3 = HasPremium and Color3.fromRGB(255, 215, 0) or Color3.fromRGB(100, 100, 100)
StatusBadge.Text = HasPremium and "⭐ PREMIUM" or "FREE"
StatusBadge.Font = Enum.Font.GothamBold
StatusBadge.TextSize = 11
StatusBadge.TextColor3 = Color3.fromRGB(0, 0, 0)
StatusBadge.Parent = Header
local BadgeCorner = Instance.new("UICorner", StatusBadge)
BadgeCorner.CornerRadius = UDim.new(0, 6)

-- Close Button
local CloseButton = Instance.new("TextButton")
CloseButton.Size = UDim2.fromOffset(30, 30)
CloseButton.Position = UDim2.new(1, -40, 0, 15)
CloseButton.BackgroundColor3 = Color3.fromRGB(220, 50, 50)
CloseButton.Text = "✕"
CloseButton.Font = Enum.Font.GothamBold
CloseButton.TextSize = 18
CloseButton.TextColor3 = Color3.new(1, 1, 1)
CloseButton.Parent = Header
local CloseCorner = Instance.new("UICorner", CloseButton)
CloseCorner.CornerRadius = UDim.new(0, 8)

CloseButton.MouseButton1Click:Connect(function()
    HubScreen:Destroy()
end)

-- User Info
local UserInfo = Instance.new("TextLabel")
UserInfo.Size = UDim2.new(1, -40, 0, 20)
UserInfo.Position = UDim2.fromOffset(20, 70)
UserInfo.BackgroundTransparency = 1
UserInfo.Text = "👤 User: " .. AuthStatus.username
UserInfo.Font = Enum.Font.Gotham
UserInfo.TextSize = 12
UserInfo.TextColor3 = Color3.fromRGB(180, 180, 180)
UserInfo.TextXAlignment = Enum.TextXAlignment.Left
UserInfo.Parent = MainFrame

-- Search/Filter Frame
local FilterFrame = Instance.new("Frame")
FilterFrame.Size = UDim2.new(1, -40, 0, 35)
FilterFrame.Position = UDim2.fromOffset(20, 100)
FilterFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
FilterFrame.BorderSizePixel = 0
FilterFrame.Parent = MainFrame
local FilterCorner = Instance.new("UICorner", FilterFrame)
FilterCorner.CornerRadius = UDim.new(0, 8)

local FilterLabel = Instance.new("TextLabel")
FilterLabel.Size = UDim2.fromOffset(60, 35)
FilterLabel.BackgroundTransparency = 1
FilterLabel.Text = "🔍 Filter:"
FilterLabel.Font = Enum.Font.GothamBold
FilterLabel.TextSize = 12
FilterLabel.TextColor3 = Color3.new(1, 1, 1)
FilterLabel.TextXAlignment = Enum.TextXAlignment.Left
FilterLabel.Parent = FilterFrame

local AllButton = Instance.new("TextButton")
AllButton.Size = UDim2.fromOffset(70, 25)
AllButton.Position = UDim2.fromOffset(70, 5)
AllButton.BackgroundColor3 = Color3.fromRGB(0, 120, 255)
AllButton.Text = "All"
AllButton.Font = Enum.Font.GothamBold
AllButton.TextSize = 11
AllButton.TextColor3 = Color3.new(1, 1, 1)
AllButton.Parent = FilterFrame
local AllCorner = Instance.new("UICorner", AllButton)
AllCorner.CornerRadius = UDim.new(0, 6)

local FreeButton = Instance.new("TextButton")
FreeButton.Size = UDim2.fromOffset(70, 25)
FreeButton.Position = UDim2.fromOffset(150, 5)
FreeButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
FreeButton.Text = "Free"
FreeButton.Font = Enum.Font.GothamBold
FreeButton.TextSize = 11
FreeButton.TextColor3 = Color3.new(1, 1, 1)
FreeButton.Parent = FilterFrame
local FreeCorner = Instance.new("UICorner", FreeButton)
FreeCorner.CornerRadius = UDim.new(0, 6)

local PremiumButton = Instance.new("TextButton")
PremiumButton.Size = UDim2.fromOffset(80, 25)
PremiumButton.Position = UDim2.fromOffset(230, 5)
PremiumButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
PremiumButton.Text = "Premium"
PremiumButton.Font = Enum.Font.GothamBold
PremiumButton.TextSize = 11
PremiumButton.TextColor3 = Color3.new(1, 1, 1)
PremiumButton.Parent = FilterFrame
local PremiumCorner = Instance.new("UICorner", PremiumButton)
PremiumCorner.CornerRadius = UDim.new(0, 6)

-- Games List Container
local GamesContainer = Instance.new("ScrollingFrame")
GamesContainer.Name = "GamesContainer"
GamesContainer.Size = UDim2.new(1, -40, 1, -245)
GamesContainer.Position = UDim2.fromOffset(20, 145)
GamesContainer.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
GamesContainer.BorderSizePixel = 0
GamesContainer.ScrollBarThickness = 6
GamesContainer.ScrollBarImageColor3 = Color3.fromRGB(80, 80, 80)
GamesContainer.Parent = MainFrame
local ContainerCorner = Instance.new("UICorner", GamesContainer)
ContainerCorner.CornerRadius = UDim.new(0, 8)

local GamesLayout = Instance.new("UIListLayout")
GamesLayout.Padding = UDim.new(0, 8)
GamesLayout.Parent = GamesContainer

-- Footer
local Footer = Instance.new("Frame")
Footer.Size = UDim2.new(1, 0, 0, 45)
Footer.Position = UDim2.new(0, 0, 1, -45)
Footer.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
Footer.BorderSizePixel = 0
Footer.Parent = MainFrame
local FooterCorner = Instance.new("UICorner", Footer)
FooterCorner.CornerRadius = UDim.new(0, 12)

local DiscordButton = Instance.new("TextButton")
DiscordButton.Size = UDim2.new(0.48, 0, 0, 30)
DiscordButton.Position = UDim2.new(0.02, 0, 0.5, -15)
DiscordButton.BackgroundColor3 = Color3.fromRGB(114, 137, 218)
DiscordButton.Text = "💬 Discord"
DiscordButton.Font = Enum.Font.GothamBold
DiscordButton.TextSize = 12
DiscordButton.TextColor3 = Color3.new(1, 1, 1)
DiscordButton.Parent = Footer
local DiscordCorner = Instance.new("UICorner", DiscordButton)
DiscordCorner.CornerRadius = UDim.new(0, 8)

local RefreshButton = Instance.new("TextButton")
RefreshButton.Size = UDim2.new(0.48, 0, 0, 30)
RefreshButton.Position = UDim2.new(0.5, 0, 0.5, -15)
RefreshButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
RefreshButton.Text = "🔄 Refresh"
RefreshButton.Font = Enum.Font.GothamBold
RefreshButton.TextSize = 12
RefreshButton.TextColor3 = Color3.new(1, 1, 1)
RefreshButton.Parent = Footer
local RefreshCorner = Instance.new("UICorner", RefreshButton)
RefreshCorner.CornerRadius = UDim.new(0, 8)

-- ################################# --
-- ## Game Cards Creation ## --
-- ################################# --

local currentFilter = "all" -- "all", "free", "premium"

local function createGameCard(gameData, index)
    local card = Instance.new("Frame")
    card.Name = "GameCard_" .. index
    card.Size = UDim2.new(1, -12, 0, 70)
    card.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    card.BorderSizePixel = 0
    card.Parent = GamesContainer
    local cardCorner = Instance.new("UICorner", card)
    cardCorner.CornerRadius = UDim.new(0, 8)
    
    local icon = Instance.new("TextLabel")
    icon.Size = UDim2.fromOffset(50, 50)
    icon.Position = UDim2.fromOffset(10, 10)
    icon.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    icon.Text = gameData.icon
    icon.Font = Enum.Font.GothamBold
    icon.TextSize = 24
    icon.Parent = card
    local iconCorner = Instance.new("UICorner", icon)
    iconCorner.CornerRadius = UDim.new(0, 8)
    
    local nameLabel = Instance.new("TextLabel")
    nameLabel.Size = UDim2.new(1, -180, 0, 20)
    nameLabel.Position = UDim2.fromOffset(70, 10)
    nameLabel.BackgroundTransparency = 1
    nameLabel.Text = gameData.name
    nameLabel.Font = Enum.Font.GothamBold
    nameLabel.TextSize = 14
    nameLabel.TextColor3 = Color3.new(1, 1, 1)
    nameLabel.TextXAlignment = Enum.TextXAlignment.Left
    nameLabel.Parent = card
    
    local descLabel = Instance.new("TextLabel")
    descLabel.Size = UDim2.new(1, -180, 0, 16)
    descLabel.Position = UDim2.fromOffset(70, 32)
    descLabel.BackgroundTransparency = 1
    descLabel.Text = gameData.description
    descLabel.Font = Enum.Font.Gotham
    descLabel.TextSize = 11
    descLabel.TextColor3 = Color3.fromRGB(160, 160, 160)
    descLabel.TextXAlignment = Enum.TextXAlignment.Left
    descLabel.TextTruncate = Enum.TextTruncate.AtEnd
    descLabel.Parent = card
    
    local badge = Instance.new("TextLabel")
    badge.Size = UDim2.fromOffset(65, 18)
    badge.Position = UDim2.fromOffset(70, 50)
    badge.BackgroundColor3 = gameData.premium and Color3.fromRGB(255, 200, 0) or Color3.fromRGB(0, 170, 80)
    badge.Text = gameData.premium and "⭐ Premium" or "✓ Free"
    badge.Font = Enum.Font.GothamBold
    badge.TextSize = 9
    badge.TextColor3 = Color3.fromRGB(0, 0, 0)
    badge.Parent = card
    local badgeCorner = Instance.new("UICorner", badge)
    badgeCorner.CornerRadius = UDim.new(0, 4)
    
    local canAccess = canAccessGame(gameData)
    
    local loadButton = Instance.new("TextButton")
    loadButton.Size = UDim2.fromOffset(90, 50)
    loadButton.Position = UDim2.new(1, -100, 0.5, -25)
    loadButton.BackgroundColor3 = canAccess and Color3.fromRGB(0, 140, 255) or Color3.fromRGB(80, 80, 80)
    loadButton.Text = canAccess and "▶️ Load" or "🔒 Locked"
    loadButton.Font = Enum.Font.GothamBold
    loadButton.TextSize = 12
    loadButton.TextColor3 = Color3.new(1, 1, 1)
    loadButton.Parent = card
    local loadCorner = Instance.new("UICorner", loadButton)
    loadCorner.CornerRadius = UDim.new(0, 8)
    
    if canAccess then
        loadButton.MouseButton1Click:Connect(function()
            loadButton.Text = "⏳ Loading..."
            loadButton.BackgroundColor3 = Color3.fromRGB(0, 100, 180)
            
            if loadGameScript(gameData.scriptUrl, gameData.name) then
                loadButton.Text = "✅ Loaded"
                loadButton.BackgroundColor3 = Color3.fromRGB(0, 170, 80)
                task.wait(2)
                loadButton.Text = "▶️ Load"
                loadButton.BackgroundColor3 = Color3.fromRGB(0, 140, 255)
            else
                loadButton.Text = "❌ Failed"
                loadButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
                task.wait(2)
                loadButton.Text = "▶️ Load"
                loadButton.BackgroundColor3 = Color3.fromRGB(0, 140, 255)
            end
        end)
    else
        loadButton.MouseButton1Click:Connect(function()
            loadButton.Text = "🔑 Get Key"
            task.wait(1)
            loadButton.Text = "🔒 Locked"
        end)
    end
    
    return card
end

local function refreshGamesList()
    -- Clear existing cards
    for _, child in ipairs(GamesContainer:GetChildren()) do
        if child:IsA("Frame") and child.Name:match("GameCard_") then
            child:Destroy()
        end
    end
    
    -- Create cards based on filter
    local cardCount = 0
    for i, gameData in ipairs(GamesList) do
        local shouldShow = false
        
        if currentFilter == "all" then
            shouldShow = true
        elseif currentFilter == "free" and not gameData.premium then
            shouldShow = true
        elseif currentFilter == "premium" and gameData.premium then
            shouldShow = true
        end
        
        if shouldShow then
            createGameCard(gameData, i)
            cardCount = cardCount + 1
        end
    end
    
    -- Update canvas size
    GamesContainer.CanvasSize = UDim2.new(0, 0, 0, cardCount * 78)
end

-- Filter button handlers
local function setFilter(filter)
    currentFilter = filter
    
    -- Update button colors
    AllButton.BackgroundColor3 = filter == "all" and Color3.fromRGB(0, 120, 255) or Color3.fromRGB(50, 50, 50)
    FreeButton.BackgroundColor3 = filter == "free" and Color3.fromRGB(0, 120, 255) or Color3.fromRGB(50, 50, 50)
    PremiumButton.BackgroundColor3 = filter == "premium" and Color3.fromRGB(0, 120, 255) or Color3.fromRGB(50, 50, 50)
    
    refreshGamesList()
end

AllButton.MouseButton1Click:Connect(function() setFilter("all") end)
FreeButton.MouseButton1Click:Connect(function() setFilter("free") end)
PremiumButton.MouseButton1Click:Connect(function() setFilter("premium") end)

-- Footer button handlers
DiscordButton.MouseButton1Click:Connect(function()
    if setclipboard then
        setclipboard("https://discord.gg/pH3NyVYC72")
        DiscordButton.Text = "✅ Copied!"
        DiscordButton.BackgroundColor3 = Color3.fromRGB(0, 200, 80)
        task.wait(2)
        DiscordButton.Text = "💬 Discord"
        DiscordButton.BackgroundColor3 = Color3.fromRGB(114, 137, 218)
    end
end)

RefreshButton.MouseButton1Click:Connect(function()
    RefreshButton.Text = "⏳ Refreshing..."
    refreshGamesList()
    task.wait(1)
    RefreshButton.Text = "🔄 Refresh"
end)

-- Initialize
refreshGamesList()

-- Animate entrance
MainFrame.Visible = true
MainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
MainFrame.Position = UDim2.new(0.5, 0, 0.5, 50)
MainFrame.Size = UDim2.fromOffset(0, 0)

local tweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
local tween = TweenService:Create(MainFrame, tweenInfo, {
    Size = UDim2.fromOffset(600, 450),
    Position = UDim2.new(0.5, 0, 0.5, 0)
})
tween:Play()

print("99 Nights Hub loaded successfully!")
print("Authentication Status: " .. (HasPremium and "Premium" or "Free"))
print("Total Games: " .. #GamesList)
