-- ################################# --
-- ##  Hub Main with Auto-Detect  ## --
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

-- Load games config from external file (optional) or use embedded config
local GamesList = {
    {
        name = "99 Nights",
        gameId = 123456789, -- Replace with actual game ID
        scriptUrl = "https://raw.githubusercontent.com/nouralddin-abdullah/99-night/refs/heads/main/main-en-script.lua",
        premium = true,
        description = "Main 99 Nights script",
        icon = "🌙",
        enabled = true
    },
    {
        name = "Blade Ball",
        gameId = 13772394625,
        scriptUrl = "https://example.com/bladeball.lua",
        premium = false,
        description = "Auto parry and deflect script",
        icon = "⚔️",
        enabled = true
    },
    {
        name = "Blox Fruits",
        gameId = 2753915549,
        scriptUrl = "https://example.com/bloxfruits.lua",
        premium = true,
        description = "Auto farm, auto stats, teleport",
        icon = "🍎",
        enabled = true
    },
    {
        name = "Arsenal",
        gameId = 286090429,
        scriptUrl = "https://example.com/arsenal.lua",
        premium = false,
        description = "ESP, aimbot, no recoil",
        icon = "🔫",
        enabled = true
    },
    {
        name = "Jailbreak",
        gameId = 606849621,
        scriptUrl = "https://example.com/jailbreak.lua",
        premium = true,
        description = "Auto rob, ESP, vehicle speed",
        icon = "🚓",
        enabled = true
    },
    -- Add more games here...
}

-- ################################# --
-- ## Helper Functions ## --
-- ################################# --

local function canAccessGame(game)
    if not game.premium then
        return true
    end
    return HasPremium
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

-- Auto-detect current game and show notification
local function detectCurrentGame()
    local currentGameId = getCurrentGameId()
    for _, gameData in ipairs(GamesList) do
        if gameData.gameId == currentGameId and gameData.enabled then
            return gameData
        end
    end
    return nil
end

-- ################################# --
-- ## Create Hub GUI ## --
-- ################################# --

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

pcall(function()
    HubScreen:SetAttribute("Protected", true)
    gethui = gethui or function() return CoreGui end
    HubScreen.Parent = gethui()
end)

-- Game Detection Notification
local detectedGame = detectCurrentGame()
if detectedGame then
    local NotifFrame = Instance.new("Frame")
    NotifFrame.Name = "GameDetectedNotification"
    NotifFrame.Size = UDim2.fromOffset(350, 80)
    NotifFrame.Position = UDim2.new(0.5, -175, 0, -100)
    NotifFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    NotifFrame.BorderSizePixel = 0
    NotifFrame.Parent = HubScreen
    local NotifCorner = Instance.new("UICorner", NotifFrame)
    NotifCorner.CornerRadius = UDim.new(0, 10)
    
    local NotifIcon = Instance.new("TextLabel")
    NotifIcon.Size = UDim2.fromOffset(50, 50)
    NotifIcon.Position = UDim2.fromOffset(10, 15)
    NotifIcon.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    NotifIcon.Text = detectedGame.icon
    NotifIcon.Font = Enum.Font.GothamBold
    NotifIcon.TextSize = 28
    NotifIcon.Parent = NotifFrame
    local NotifIconCorner = Instance.new("UICorner", NotifIcon)
    NotifIconCorner.CornerRadius = UDim.new(0, 8)
    
    local NotifText = Instance.new("TextLabel")
    NotifText.Size = UDim2.new(1, -70, 0, 20)
    NotifText.Position = UDim2.fromOffset(70, 15)
    NotifText.BackgroundTransparency = 1
    NotifText.Text = "🎮 Game Detected!"
    NotifText.Font = Enum.Font.GothamBold
    NotifText.TextSize = 13
    NotifText.TextColor3 = Color3.fromRGB(0, 255, 120)
    NotifText.TextXAlignment = Enum.TextXAlignment.Left
    NotifText.Parent = NotifFrame
    
    local NotifName = Instance.new("TextLabel")
    NotifName.Size = UDim2.new(1, -70, 0, 18)
    NotifName.Position = UDim2.fromOffset(70, 35)
    NotifName.BackgroundTransparency = 1
    NotifName.Text = detectedGame.name
    NotifName.Font = Enum.Font.Gotham
    NotifName.TextSize = 12
    NotifName.TextColor3 = Color3.new(1, 1, 1)
    NotifName.TextXAlignment = Enum.TextXAlignment.Left
    NotifName.Parent = NotifFrame
    
    local NotifStatus = Instance.new("TextLabel")
    NotifStatus.Size = UDim2.new(1, -70, 0, 16)
    NotifStatus.Position = UDim2.fromOffset(70, 53)
    NotifStatus.BackgroundTransparency = 1
    NotifStatus.Text = canAccessGame(detectedGame) and "✓ Ready to load" or "🔒 Premium required"
    NotifStatus.Font = Enum.Font.Gotham
    NotifStatus.TextSize = 10
    NotifStatus.TextColor3 = canAccessGame(detectedGame) and Color3.fromRGB(0, 200, 100) or Color3.fromRGB(255, 165, 0)
    NotifStatus.TextXAlignment = Enum.TextXAlignment.Left
    NotifStatus.Parent = NotifFrame
    
    -- Animate notification
    local notifTween = TweenService:Create(NotifFrame, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
        Position = UDim2.new(0.5, -175, 0, 20)
    })
    notifTween:Play()
    
    -- Auto-hide after 4 seconds
    task.delay(4, function()
        local hideTween = TweenService:Create(NotifFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
            Position = UDim2.new(0.5, -175, 0, -100)
        })
        hideTween:Play()
        hideTween.Completed:Wait()
        NotifFrame:Destroy()
    end)
end

-- Main Frame
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.fromOffset(600, 450)
MainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
MainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
MainFrame.BorderSizePixel = 0
MainFrame.Parent = HubScreen
MainFrame.Visible = false
local MainCorner = Instance.new("UICorner", MainFrame)
MainCorner.CornerRadius = UDim.new(0, 12)

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
UserInfo.Text = "👤 User: " .. AuthStatus.username .. (detectedGame and "  |  🎮 Current: " .. detectedGame.name or "")
UserInfo.Font = Enum.Font.Gotham
UserInfo.TextSize = 12
UserInfo.TextColor3 = Color3.fromRGB(180, 180, 180)
UserInfo.TextXAlignment = Enum.TextXAlignment.Left
UserInfo.Parent = MainFrame

-- Filter Frame
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

-- Games Container
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

-- [Rest of the game card creation and logic - same as before]
local currentFilter = "all"

local function createGameCard(gameData, index)
    local isCurrentGame = detectedGame and gameData.gameId == detectedGame.gameId
    
    local card = Instance.new("Frame")
    card.Name = "GameCard_" .. index
    card.Size = UDim2.new(1, -12, 0, 70)
    card.BackgroundColor3 = isCurrentGame and Color3.fromRGB(45, 60, 45) or Color3.fromRGB(40, 40, 40)
    card.BorderSizePixel = 0
    card.Parent = GamesContainer
    local cardCorner = Instance.new("UICorner", card)
    cardCorner.CornerRadius = UDim.new(0, 8)
    
    -- Add border for current game
    if isCurrentGame then
        local border = Instance.new("UIStroke", card)
        border.Color = Color3.fromRGB(0, 200, 100)
        border.Thickness = 2
    end
    
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
    nameLabel.Text = gameData.name .. (isCurrentGame and " 🎯" or "")
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
    for _, child in ipairs(GamesContainer:GetChildren()) do
        if child:IsA("Frame") and child.Name:match("GameCard_") then
            child:Destroy()
        end
    end
    
    local cardCount = 0
    for i, gameData in ipairs(GamesList) do
        if not gameData.enabled then continue end
        
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
    
    GamesContainer.CanvasSize = UDim2.new(0, 0, 0, cardCount * 78)
end

local function setFilter(filter)
    currentFilter = filter
    AllButton.BackgroundColor3 = filter == "all" and Color3.fromRGB(0, 120, 255) or Color3.fromRGB(50, 50, 50)
    FreeButton.BackgroundColor3 = filter == "free" and Color3.fromRGB(0, 120, 255) or Color3.fromRGB(50, 50, 50)
    PremiumButton.BackgroundColor3 = filter == "premium" and Color3.fromRGB(0, 120, 255) or Color3.fromRGB(50, 50, 50)
    refreshGamesList()
end

AllButton.MouseButton1Click:Connect(function() setFilter("all") end)
FreeButton.MouseButton1Click:Connect(function() setFilter("free") end)
PremiumButton.MouseButton1Click:Connect(function() setFilter("premium") end)

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
if detectedGame then
    print("Current Game Detected: " .. detectedGame.name)
end
