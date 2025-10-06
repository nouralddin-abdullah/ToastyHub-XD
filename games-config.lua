-- ################################# --
-- ##     Games Configuration     ## --
-- ################################# --

-- Simply add or remove games from this list
return {
    {
        name = "99 Nights",
        gameId = 123456789, -- Replace with actual game ID
        scriptUrl = "https://raw.githubusercontent.com/nouralddin-abdullah/99-night/refs/heads/main/main-en-script.lua",
        premium = true, -- true = requires key, false = free
        icon = "🌙"
    },
    {
        name = "Plant Vs Brainrots",
        gameId = 123456789, -- Replace with actual game ID
        scriptUrl = "https://raw.githubusercontent.com/nouralddin-abdullah/Plants-Vs-Brainrots/refs/heads/main/main.lua",
        premium = false, -- true = requires key, false = free
        icon = "🪴"
    }
}
