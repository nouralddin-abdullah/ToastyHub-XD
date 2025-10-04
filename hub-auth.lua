-- ################################# --
-- ##    99 Nights Hub Auth       ## --
-- ################################# --

-- Configure your links here
local HUB_SCRIPT_URL = "https://raw.githubusercontent.com/nouralddin-abdullah/99-night/refs/heads/main/hub-main.lua" -- Hub interface script
local KEY_URL = "https://pastefy.app/PaRgx1Pf/raw" -- Paste your Key URL here
local SHORTCUT_LINK = "https://lootdest.org/s?NXoK9Psz" -- Paste the link required to get the key
local DISCORD_LINK = "https://discord.gg/pH3NyVYC72" -- Discord link
local WHITELIST_URL = "https://pastefy.app/SlswyJqq/raw" -- Whitelist URL

-- Authentication settings
local REQUIRE_KEY = true -- Set to false to skip key verification for the hub
local FREE_ACCESS_GAMES = {} -- Game IDs that don't require key (will be loaded from hub config)

-- ################################# --
-- ## UI and Logic ## --
-- ################################# --

local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")

-- [PROTECT_START] - Don't obfuscate this section
-- Function to check if player is whitelisted
local function isPlayerWhitelisted()
    local localPlayer = Players.LocalPlayer
    if not localPlayer then return false end
    
    local username = localPlayer.Name
    
    -- Fetch whitelist from URL
    local success, whitelistContent = pcall(function()
        return game:HttpGet(WHITELIST_URL)
    end)
    
    if not success then
        warn("Failed to fetch whitelist: " .. tostring(whitelistContent))
        return false
    end
    
    -- Parse whitelist (each username on a new line)
    for line in whitelistContent:gmatch("[^\r\n]+") do
        local whitelistedName = line:match("^%s*(.-)%s*$") -- Remove whitespace
        if whitelistedName ~= "" and username == whitelistedName then
            print("Player " .. username .. " found in whitelist!")
            return true
        end
    end
    
    print("Player " .. username .. " not found in whitelist.")
    return false
end
-- [PROTECT_END] - End of protected section

-- Function to load the hub
local function loadHub(hasKey)
    local hubSuccess, hubContent = pcall(function()
        return game:HttpGet(HUB_SCRIPT_URL)
    end)

    if hubSuccess then
        -- Pass authentication status to hub
        getgenv().HubAuthStatus = {
            authenticated = hasKey,
            username = Players.LocalPlayer.Name,
            timestamp = os.time()
        }
        loadstring(hubContent)()
        print("Hub loaded successfully!")
    else
        warn("Failed to load hub: " .. tostring(hubContent))
    end
end

-- Check if player is whitelisted first
if isPlayerWhitelisted() then
    print("Player is whitelisted. Loading hub with full access...")
    loadHub(true)
    return
end

-- Check if key verification is required
if not REQUIRE_KEY then
    print("Key verification disabled. Loading hub directly...")
    loadHub(false) -- Load with limited access
    return
end

-- If REQUIRE_KEY = true, show authentication interface
print("Key verification enabled. Showing authentication interface...")

-- Create the interface
local KeyAuthScreen = Instance.new("ScreenGui")
KeyAuthScreen.Name = "HubKeyAuthScreen"
KeyAuthScreen.Parent = CoreGui
KeyAuthScreen.ResetOnSpawn = false
KeyAuthScreen.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
KeyAuthScreen.DisplayOrder = 999999
KeyAuthScreen.IgnoreGuiInset = true

-- Protect the GUI from being destroyed
pcall(function()
    KeyAuthScreen:SetAttribute("Protected", true)
    gethui = gethui or function() return CoreGui end
    KeyAuthScreen.Parent = gethui()
end)

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.fromOffset(400, 340)
MainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
MainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
MainFrame.Parent = KeyAuthScreen
local UICorner = Instance.new("UICorner", MainFrame)
UICorner.CornerRadius = UDim.new(0, 10)

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 50)
Title.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
Title.Text = "🌟 99 Nights Hub 🌟"
Title.Font = Enum.Font.GothamBold
Title.TextSize = 18
Title.TextColor3 = Color3.new(1, 1, 1)
Title.Parent = MainFrame
local UICorner2 = Instance.new("UICorner", Title)
UICorner2.CornerRadius = UDim.new(0, 10)

local SubTitle = Instance.new("TextLabel")
SubTitle.Size = UDim2.new(1, -40, 0, 25)
SubTitle.Position = UDim2.new(0, 20, 0, 60)
SubTitle.BackgroundTransparency = 1
SubTitle.Text = "🔐 Enter key for premium games access"
SubTitle.Font = Enum.Font.Gotham
SubTitle.TextSize = 13
SubTitle.TextColor3 = Color3.fromRGB(200, 200, 200)
SubTitle.Parent = MainFrame

local KeyInput = Instance.new("TextBox")
KeyInput.Size = UDim2.new(1, -40, 0, 35)
KeyInput.Position = UDim2.new(0, 20, 0, 95)
KeyInput.BackgroundColor3 = Color3.fromRGB(55, 55, 55)
KeyInput.PlaceholderText = "Enter key here..."
KeyInput.Text = ""
KeyInput.Font = Enum.Font.Gotham
KeyInput.TextSize = 14
KeyInput.TextColor3 = Color3.new(1, 1, 1)
KeyInput.Parent = MainFrame
local UICorner3 = Instance.new("UICorner", KeyInput)
UICorner3.CornerRadius = UDim.new(0, 8)

local GetKeyButton = Instance.new("TextButton")
GetKeyButton.Size = UDim2.new(0.48, 0, 0, 35)
GetKeyButton.Position = UDim2.new(0.02, 20, 0, 145)
GetKeyButton.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
GetKeyButton.Text = "🔑 Get Key"
GetKeyButton.Font = Enum.Font.GothamBold
GetKeyButton.TextSize = 12
GetKeyButton.TextColor3 = Color3.new(1, 1, 1)
GetKeyButton.Parent = MainFrame
local UICorner4 = Instance.new("UICorner", GetKeyButton)
UICorner4.CornerRadius = UDim.new(0, 8)

local CheckKeyButton = Instance.new("TextButton")
CheckKeyButton.Size = UDim2.new(0.48, 0, 0, 35)
CheckKeyButton.Position = UDim2.new(0.5, 0, 0, 145)
CheckKeyButton.BackgroundColor3 = Color3.fromRGB(0, 120, 255)
CheckKeyButton.Text = "✅ Check Key"
CheckKeyButton.Font = Enum.Font.GothamBold
CheckKeyButton.TextSize = 12
CheckKeyButton.TextColor3 = Color3.new(1, 1, 1)
CheckKeyButton.Parent = MainFrame
local UICorner5 = Instance.new("UICorner", CheckKeyButton)
UICorner5.CornerRadius = UDim.new(0, 8)

local FreeAccessButton = Instance.new("TextButton")
FreeAccessButton.Size = UDim2.new(1, -40, 0, 35)
FreeAccessButton.Position = UDim2.new(0, 20, 0, 195)
FreeAccessButton.BackgroundColor3 = Color3.fromRGB(0, 170, 80)
FreeAccessButton.Text = "🎮 Continue with Free Games Only"
FreeAccessButton.Font = Enum.Font.GothamBold
FreeAccessButton.TextSize = 12
FreeAccessButton.TextColor3 = Color3.new(1, 1, 1)
FreeAccessButton.Parent = MainFrame
local UICorner6 = Instance.new("UICorner", FreeAccessButton)
UICorner6.CornerRadius = UDim.new(0, 8)

local DiscordButton = Instance.new("TextButton")
DiscordButton.Size = UDim2.new(1, -40, 0, 35)
DiscordButton.Position = UDim2.new(0, 20, 0, 245)
DiscordButton.BackgroundColor3 = Color3.fromRGB(114, 137, 218)
DiscordButton.Text = "💬 Join Discord"
DiscordButton.Font = Enum.Font.GothamBold
DiscordButton.TextSize = 14
DiscordButton.TextColor3 = Color3.new(1, 1, 1)
DiscordButton.Parent = MainFrame
local UICorner7 = Instance.new("UICorner", DiscordButton)
UICorner7.CornerRadius = UDim.new(0, 8)

local StatusLabel = Instance.new("TextLabel")
StatusLabel.Size = UDim2.new(1, -40, 0, 30)
StatusLabel.Position = UDim2.new(0, 20, 0, 295)
StatusLabel.BackgroundTransparency = 1
StatusLabel.Text = "Enter key or continue with free games"
StatusLabel.Font = Enum.Font.Gotham
StatusLabel.TextSize = 11
StatusLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
StatusLabel.TextWrapped = true
StatusLabel.Parent = MainFrame

-- Button functions
GetKeyButton.MouseButton1Click:Connect(function()
    if setclipboard then
        setclipboard(SHORTCUT_LINK)
        StatusLabel.Text = "Key link copied to clipboard!"
        StatusLabel.TextColor3 = Color3.fromRGB(0, 255, 120)
        GetKeyButton.Text = "✅ Copied!"
        GetKeyButton.BackgroundColor3 = Color3.fromRGB(0, 150, 50)
        task.wait(2)
        GetKeyButton.Text = "🔑 Get Key"
        GetKeyButton.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
    else
        StatusLabel.Text = "Could not copy link."
        StatusLabel.TextColor3 = Color3.fromRGB(255, 80, 80)
    end
end)

DiscordButton.MouseButton1Click:Connect(function()
    if setclipboard then
        setclipboard(DISCORD_LINK)
        StatusLabel.Text = "Discord link copied to clipboard!"
        StatusLabel.TextColor3 = Color3.fromRGB(0, 255, 120)
        DiscordButton.Text = "✅ Discord link copied!"
        DiscordButton.BackgroundColor3 = Color3.fromRGB(0, 200, 80)
        task.wait(2)
        DiscordButton.Text = "💬 Join Discord"
        DiscordButton.BackgroundColor3 = Color3.fromRGB(114, 137, 218)
    else
        StatusLabel.Text = "Could not copy link."
        StatusLabel.TextColor3 = Color3.fromRGB(255, 80, 80)
    end
end)

FreeAccessButton.MouseButton1Click:Connect(function()
    StatusLabel.Text = "Loading hub with free games..."
    StatusLabel.TextColor3 = Color3.fromRGB(0, 255, 120)
    FreeAccessButton.Text = "🎮 Loading..."
    FreeAccessButton.BackgroundColor3 = Color3.fromRGB(0, 140, 60)
    task.wait(1)
    KeyAuthScreen:Destroy()
    loadHub(false) -- Load hub without premium access
end)

CheckKeyButton.MouseButton1Click:Connect(function()
    StatusLabel.Text = "Checking key..."
    StatusLabel.TextColor3 = Color3.fromRGB(255, 255, 0)

    -- Fetch the correct key from the link
    local success, correctKey = pcall(function()
        return game:HttpGet(KEY_URL)
    end)

    if not success then
        StatusLabel.Text = "Key fetch failed. Loading hub with free access..."
        StatusLabel.TextColor3 = Color3.fromRGB(255, 165, 0)
        CheckKeyButton.Text = "⚠️ Bypassed"
        CheckKeyButton.BackgroundColor3 = Color3.fromRGB(255, 165, 0)
        task.wait(1)
        KeyAuthScreen:Destroy()
        loadHub(false)
        return
    end

    -- Remove all spaces and make case insensitive for proper comparison
    local enteredKey = KeyInput.Text:gsub("%s+", ""):lower()
    correctKey = correctKey:gsub("%s+", ""):lower()

    if enteredKey == correctKey then
        StatusLabel.Text = "Success! Loading hub with premium access..."
        StatusLabel.TextColor3 = Color3.fromRGB(0, 255, 120)
        CheckKeyButton.Text = "✅ Valid Key!"
        CheckKeyButton.BackgroundColor3 = Color3.fromRGB(0, 200, 80)
        task.wait(1)
        KeyAuthScreen:Destroy()
        loadHub(true) -- Load hub with premium access
    else
        StatusLabel.Text = "Invalid key. Try again or use free access."
        StatusLabel.TextColor3 = Color3.fromRGB(255, 80, 80)
        CheckKeyButton.Text = "❌ Wrong Key"
        CheckKeyButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
        task.wait(2)
        CheckKeyButton.Text = "✅ Check Key"
        CheckKeyButton.BackgroundColor3 = Color3.fromRGB(0, 120, 255)
    end
end)
