local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")

-- Local Player
local LocalPlayer = Players.LocalPlayer

-- Utility Functions
local function Tween(instance, properties, duration, style, direction)
    duration = duration or 0.3
    style = style or Enum.EasingStyle.Quint
    direction = direction or Enum.EasingDirection.Out
    
    local tween = TweenService:Create(instance, TweenInfo.new(duration, style, direction), properties)
    tween:Play()
    return tween
end

local function New(class, properties, children)
    local instance = Instance.new(class)
    
    for prop, value in pairs(properties or {}) do
        if prop ~= "Parent" then
            instance[prop] = value
        end
    end
    
    for _, child in ipairs(children or {}) do
        if child then
            child.Parent = instance
        end
    end
    
    if properties.Parent then
        instance.Parent = properties.Parent
    end
    
    return instance
end

-- Theme System
local Themes = {
    Dark = {
        Background = Color3.fromRGB(20, 20, 25),
        Secondary = Color3.fromRGB(25, 25, 30),
        Tertiary = Color3.fromRGB(30, 30, 35),
        Accent = Color3.fromRGB(88, 101, 242),
        AccentHover = Color3.fromRGB(71, 82, 196),
        Text = Color3.fromRGB(255, 255, 255),
        TextDark = Color3.fromRGB(180, 180, 180),
        Border = Color3.fromRGB(40, 40, 45),
        Success = Color3.fromRGB(67, 181, 129),
        Warning = Color3.fromRGB(250, 166, 26),
        Error = Color3.fromRGB(237, 66, 69),
    },
    Mocha = {
        Background = Color3.fromRGB(30, 25, 25),
        Secondary = Color3.fromRGB(35, 30, 30),
        Tertiary = Color3.fromRGB(40, 35, 35),
        Accent = Color3.fromRGB(180, 120, 100),
        AccentHover = Color3.fromRGB(160, 100, 80),
        Text = Color3.fromRGB(255, 255, 255),
        TextDark = Color3.fromRGB(180, 180, 180),
        Border = Color3.fromRGB(50, 45, 45),
        Success = Color3.fromRGB(67, 181, 129),
        Warning = Color3.fromRGB(250, 166, 26),
        Error = Color3.fromRGB(237, 66, 69),
    },
    Aqua = {
        Background = Color3.fromRGB(15, 25, 30),
        Secondary = Color3.fromRGB(20, 30, 35),
        Tertiary = Color3.fromRGB(25, 35, 40),
        Accent = Color3.fromRGB(0, 180, 220),
        AccentHover = Color3.fromRGB(0, 160, 200),
        Text = Color3.fromRGB(255, 255, 255),
        TextDark = Color3.fromRGB(180, 180, 180),
        Border = Color3.fromRGB(35, 45, 50),
        Success = Color3.fromRGB(67, 181, 129),
        Warning = Color3.fromRGB(250, 166, 26),
        Error = Color3.fromRGB(237, 66, 69),
    },
}

-- Main Library
local ToastyUI = {
    ScreenGui = nil,
    CurrentTheme = Themes.Dark,
    ActiveWindow = nil,
}

-- Create ScreenGui
ToastyUI.ScreenGui = New("ScreenGui", {
    Name = "ToastyUI_" .. tostring(tick()):gsub("%.", ""),
    Parent = CoreGui,
    ResetOnSpawn = false,
    ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
})

-- Notification Container
local NotificationContainer = New("Frame", {
    Name = "Notifications",
    Parent = ToastyUI.ScreenGui,
    Size = UDim2.new(0, 300, 1, 0),
    Position = UDim2.new(1, -310, 0, 10),
    BackgroundTransparency = 1,
}, {
    New("UIListLayout", {
        Padding = UDim.new(0, 10),
        SortOrder = Enum.SortOrder.LayoutOrder,
        VerticalAlignment = Enum.VerticalAlignment.Top,
    })
})

-- Notification Function
function ToastyUI:Notify(config)
    local title = config.Title or "Notification"
    local content = config.Content or ""
    local duration = config.Duration or 5
    local notifType = config.Type or "info"
    
    local typeColors = {
        info = self.CurrentTheme.Accent,
        success = self.CurrentTheme.Success,
        warning = self.CurrentTheme.Warning,
        error = self.CurrentTheme.Error,
    }
    
    local notif = New("Frame", {
        Name = "Notification",
        Parent = NotificationContainer,
        Size = UDim2.new(1, 0, 0, 0),
        BackgroundColor3 = CurrentTheme.Secondary,
        BorderSizePixel = 0,
        ClipsDescendants = true,
    }, {
        New("UICorner", {
            CornerRadius = UDim.new(0, 8),
        }),
        New("UIStroke", {
            Color = typeColors[notifType],
            Thickness = 2,
        }),
        New("Frame", {
            Name = "Content",
            Size = UDim2.new(1, -20, 1, -20),
            Position = UDim2.new(0, 10, 0, 10),
            BackgroundTransparency = 1,
        }, {
            New("TextLabel", {
                Name = "Title",
                Size = UDim2.new(1, 0, 0, 20),
                BackgroundTransparency = 1,
                Text = title,
                TextColor3 = CurrentTheme.Text,
                TextSize = 16,
                Font = Enum.Font.GothamBold,
                TextXAlignment = Enum.TextXAlignment.Left,
            }),
            New("TextLabel", {
                Name = "Content",
                Size = UDim2.new(1, 0, 1, -25),
                Position = UDim2.new(0, 0, 0, 25),
                BackgroundTransparency = 1,
                Text = content,
                TextColor3 = CurrentTheme.TextDark,
                TextSize = 14,
                Font = Enum.Font.Gotham,
                TextXAlignment = Enum.TextXAlignment.Left,
                TextYAlignment = Enum.TextYAlignment.Top,
                TextWrapped = true,
            }),
        }),
    })
    
    -- Animate in
    Tween(notif, {Size = UDim2.new(1, 0, 0, 80)}, 0.3)
    
    -- Auto dismiss
    task.delay(duration, function()
        Tween(notif, {Size = UDim2.new(1, 0, 0, 0)}, 0.3)
        task.wait(0.3)
        notif:Destroy()
    end)
end

-- Create Window Function
function ToastyUI:CreateWindow(config)
    if self.ActiveWindow then
        warn("ToastyUI: Only one window can be active at a time")
        return self.ActiveWindow
    end
    
    local title = config.Title or "ToastyUI"
    local subtitle = config.Subtitle or ""
    local size = config.Size or UDim2.new(0, 600, 0, 450)
    local minimizeKey = config.MinimizeKey or Enum.KeyCode.RightShift
    local theme = config.Theme or "Dark"
    
    -- Set theme
    self.CurrentTheme = Themes[theme] or Themes.Dark
    local CurrentTheme = self.CurrentTheme  -- Store reference for nested functions
    
    -- Window Object
    local WindowObject = {
        Tabs = {},
        CurrentTab = nil,
        Minimized = false,
        Visible = true,
    }
    
    -- Main Window
    local Window = New("Frame", {
        Name = "Window",
        Parent = self.ScreenGui,
        Size = size,
        Position = UDim2.new(0.5, -size.X.Offset/2, 0.5, -size.Y.Offset/2),
        BackgroundColor3 = self.CurrentTheme.Background,
        BorderSizePixel = 0,
    }, {
        New("UICorner", {
            CornerRadius = UDim.new(0, 12),
        }),
        New("UIStroke", {
            Color = self.CurrentTheme.Border,
            Thickness = 1,
        }),
    })
    
    WindowObject.Window = Window
    
    -- Title Bar
    local TitleBar = New("Frame", {
        Name = "TitleBar",
        Parent = Window,
        Size = UDim2.new(1, 0, 0, 50),
        BackgroundColor3 = CurrentTheme.Secondary,
        BorderSizePixel = 0,
    }, {
        New("UICorner", {
            CornerRadius = UDim.new(0, 12),
        }),
        New("TextLabel", {
            Name = "Title",
            Size = UDim2.new(0, 200, 1, 0),
            Position = UDim2.new(0, 15, 0, 0),
            BackgroundTransparency = 1,
            Text = title,
            TextColor3 = CurrentTheme.Text,
            TextSize = 18,
            Font = Enum.Font.GothamBold,
            TextXAlignment = Enum.TextXAlignment.Left,
        }),
        New("TextLabel", {
            Name = "Subtitle",
            Size = UDim2.new(0, 150, 1, 0),
            Position = UDim2.new(0, 220, 0, 0),
            BackgroundTransparency = 1,
            Text = subtitle,
            TextColor3 = CurrentTheme.TextDark,
            TextSize = 14,
            Font = Enum.Font.Gotham,
            TextXAlignment = Enum.TextXAlignment.Left,
        }),
    })
    
    -- Cover bottom corners of title bar
    New("Frame", {
        Parent = TitleBar,
        Size = UDim2.new(1, 0, 0, 12),
        Position = UDim2.new(0, 0, 1, -12),
        BackgroundColor3 = CurrentTheme.Secondary,
        BorderSizePixel = 0,
    })
    
    -- Close Button
    local CloseButton = New("TextButton", {
        Name = "Close",
        Parent = TitleBar,
        Size = UDim2.new(0, 40, 0, 40),
        Position = UDim2.new(1, -45, 0, 5),
        BackgroundColor3 = CurrentTheme.Tertiary,
        Text = "✕",
        TextColor3 = CurrentTheme.Text,
        TextSize = 20,
        Font = Enum.Font.GothamBold,
        BorderSizePixel = 0,
    }, {
        New("UICorner", {
            CornerRadius = UDim.new(0, 8),
        }),
    })
    
    CloseButton.MouseButton1Click:Connect(function()
        Tween(Window, {Size = UDim2.new(0, 0, 0, 0), Position = UDim2.new(0.5, 0, 0.5, 0)}, 0.3)
        task.wait(0.3)
        self.ScreenGui:Destroy()
    end)
    
    CloseButton.MouseEnter:Connect(function()
        Tween(CloseButton, {BackgroundColor3 = CurrentTheme.Error}, 0.2)
    end)
    
    CloseButton.MouseLeave:Connect(function()
        Tween(CloseButton, {BackgroundColor3 = CurrentTheme.Tertiary}, 0.2)
    end)
    
    -- Minimize Button
    local MinimizeButton = New("TextButton", {
        Name = "Minimize",
        Parent = TitleBar,
        Size = UDim2.new(0, 40, 0, 40),
        Position = UDim2.new(1, -90, 0, 5),
        BackgroundColor3 = CurrentTheme.Tertiary,
        Text = "−",
        TextColor3 = CurrentTheme.Text,
        TextSize = 24,
        Font = Enum.Font.GothamBold,
        BorderSizePixel = 0,
    }, {
        New("UICorner", {
            CornerRadius = UDim.new(0, 8),
        }),
    })
    
    local function ToggleMinimize()
        WindowObject.Minimized = not WindowObject.Minimized
        if WindowObject.Minimized then
            WindowObject.SavedSize = Window.Size
            WindowObject.SavedPosition = Window.Position
            Tween(Window, {
                Size = UDim2.new(0, 60, 0, 60),
                Position = UDim2.new(1, -70, 1, -70)
            }, 0.3)
        else
            Tween(Window, {
                Size = WindowObject.SavedSize,
                Position = WindowObject.SavedPosition
            }, 0.3)
        end
    end
    
    MinimizeButton.MouseButton1Click:Connect(ToggleMinimize)
    
    MinimizeButton.MouseEnter:Connect(function()
        Tween(MinimizeButton, {BackgroundColor3 = CurrentTheme.Accent}, 0.2)
    end)
    
    MinimizeButton.MouseLeave:Connect(function()
        Tween(MinimizeButton, {BackgroundColor3 = CurrentTheme.Tertiary}, 0.2)
    end)
    
    -- Toggle keybind
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if not gameProcessed and input.KeyCode == minimizeKey then
            WindowObject.Visible = not WindowObject.Visible
            Window.Visible = WindowObject.Visible
        end
    end)
    
    -- Dragging
    local dragging, dragInput, dragStart, startPos
    
    TitleBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = Window.Position
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    
    TitleBar.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            dragInput = input
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            Window.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + delta.X,
                startPos.Y.Scale, startPos.Y.Offset + delta.Y
            )
        end
    end)
    
    -- Tab Container
    local TabContainer = New("Frame", {
        Name = "TabContainer",
        Parent = Window,
        Size = UDim2.new(0, 150, 1, -70),
        Position = UDim2.new(0, 10, 0, 60),
        BackgroundTransparency = 1,
    }, {
        New("UIListLayout", {
            Padding = UDim.new(0, 5),
            SortOrder = Enum.SortOrder.LayoutOrder,
        })
    })
    
    -- Content Container
    local ContentContainer = New("ScrollingFrame", {
        Name = "Content",
        Parent = Window,
        Size = UDim2.new(1, -180, 1, -70),
        Position = UDim2.new(0, 170, 0, 60),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ScrollBarThickness = 4,
        ScrollBarImageColor3 = self.CurrentTheme.Accent,
        CanvasSize = UDim2.new(0, 0, 0, 0),
    }, {
        New("UIListLayout", {
            Padding = UDim.new(0, 8),
            SortOrder = Enum.SortOrder.LayoutOrder,
        })
    })
    
    -- Auto-resize canvas
    ContentContainer.UIListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        ContentContainer.CanvasSize = UDim2.new(0, 0, 0, ContentContainer.UIListLayout.AbsoluteContentSize.Y + 10)
    end)
    
    -- Tab Function
    function WindowObject:Tab(tabConfig)
        local tabTitle = tabConfig.Title or "Tab"
        local tabDesc = tabConfig.Desc or ""
        
        local TabObject = {
            Elements = {},
        }
        
        -- Tab Button
        local TabButton = New("TextButton", {
            Name = tabTitle,
            Parent = TabContainer,
            Size = UDim2.new(1, 0, 0, 40),
            BackgroundColor3 = ToastyUI.CurrentTheme.Tertiary,
            Text = "",
            BorderSizePixel = 0,
        }, {
            New("UICorner", {
                CornerRadius = UDim.new(0, 8),
            }),
            New("TextLabel", {
                Name = "Label",
                Size = UDim2.new(1, -10, 1, 0),
                Position = UDim2.new(0, 10, 0, 0),
                BackgroundTransparency = 1,
                Text = tabTitle,
                TextColor3 = ToastyUI.CurrentTheme.TextDark,
                TextSize = 14,
                Font = Enum.Font.GothamBold,
                TextXAlignment = Enum.TextXAlignment.Left,
            }),
        })
        
        TabObject.Button = TabButton
        
        -- Tab Content Frame
        local TabContent = New("Frame", {
            Name = tabTitle .. "Content",
            Parent = ContentContainer,
            Size = UDim2.new(1, 0, 0, 0),
            BackgroundTransparency = 1,
            Visible = false,
        }, {
            New("UIListLayout", {
                Padding = UDim.new(0, 8),
                SortOrder = Enum.SortOrder.LayoutOrder,
            })
        })
        
        TabObject.Content = TabContent
        
        -- Auto-resize tab content
        TabContent.UIListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            TabContent.Size = UDim2.new(1, 0, 0, TabContent.UIListLayout.AbsoluteContentSize.Y)
        end)
        
        -- Tab switching
        TabButton.MouseButton1Click:Connect(function()
            for _, tab in pairs(WindowObject.Tabs) do
                tab.Content.Visible = false
                tab.Button.BackgroundColor3 = ToastyUI.CurrentTheme.Tertiary
                tab.Button.Label.TextColor3 = ToastyUI.CurrentTheme.TextDark
            end
            
            TabContent.Visible = true
            TabButton.BackgroundColor3 = ToastyUI.CurrentTheme.Accent
            TabButton.Label.TextColor3 = ToastyUI.CurrentTheme.Text
            WindowObject.CurrentTab = TabObject
        end)
        
        TabButton.MouseEnter:Connect(function()
            if WindowObject.CurrentTab ~= TabObject then
                Tween(TabButton, {BackgroundColor3 = ToastyUI.CurrentTheme.Secondary}, 0.2)
            end
        end)
        
        TabButton.MouseLeave:Connect(function()
            if WindowObject.CurrentTab ~= TabObject then
                Tween(TabButton, {BackgroundColor3 = ToastyUI.CurrentTheme.Tertiary}, 0.2)
            end
        end)
        
        -- Set as first tab
        if not WindowObject.CurrentTab then
            TabButton.MouseButton1Click:Fire()
        end
        
        table.insert(WindowObject.Tabs, TabObject)
        
        -- Section Function
        function TabObject:Section(sectionConfig)
            local sectionTitle = sectionConfig.Title or "Section"
            
            local Section = New("Frame", {
                Name = "Section",
                Parent = TabContent,
                Size = UDim2.new(1, 0, 0, 35),
                BackgroundTransparency = 1,
            }, {
                New("TextLabel", {
                    Size = UDim2.new(1, 0, 1, 0),
                    BackgroundTransparency = 1,
                    Text = sectionTitle,
                    TextColor3 = CurrentTheme.Text,
                    TextSize = 16,
                    Font = Enum.Font.GothamBold,
                    TextXAlignment = Enum.TextXAlignment.Left,
                }),
            })
            
            return Section
        end
        
        -- Button Function
        function TabObject:Button(buttonConfig)
            local buttonTitle = buttonConfig.Title or "Button"
            local buttonDesc = buttonConfig.Desc or ""
            local callback = buttonConfig.Callback or function() end
            
            local ButtonFrame = New("Frame", {
                Name = "Button",
                Parent = TabContent,
                Size = UDim2.new(1, 0, 0, 45),
                BackgroundColor3 = CurrentTheme.Secondary,
                BorderSizePixel = 0,
            }, {
                New("UICorner", {
                    CornerRadius = UDim.new(0, 8),
                }),
            })
            
            local ButtonLabel = New("TextLabel", {
                Name = "Label",
                Parent = ButtonFrame,
                Size = UDim2.new(1, -120, 1, 0),
                Position = UDim2.new(0, 10, 0, 0),
                BackgroundTransparency = 1,
                Text = buttonTitle,
                TextColor3 = CurrentTheme.Text,
                TextSize = 14,
                Font = Enum.Font.GothamBold,
                TextXAlignment = Enum.TextXAlignment.Left,
            })
            
            if buttonDesc ~= "" then
                ButtonLabel.Size = UDim2.new(1, -120, 0, 20)
                ButtonLabel.Position = UDim2.new(0, 10, 0, 5)
                
                New("TextLabel", {
                    Name = "Desc",
                    Parent = ButtonFrame,
                    Size = UDim2.new(1, -120, 0, 15),
                    Position = UDim2.new(0, 10, 0, 25),
                    BackgroundTransparency = 1,
                    Text = buttonDesc,
                    TextColor3 = CurrentTheme.TextDark,
                    TextSize = 12,
                    Font = Enum.Font.Gotham,
                    TextXAlignment = Enum.TextXAlignment.Left,
                })
            end
            
            local ClickButton = New("TextButton", {
                Name = "ClickButton",
                Parent = ButtonFrame,
                Size = UDim2.new(0, 100, 0, 30),
                Position = UDim2.new(1, -110, 0.5, -15),
                BackgroundColor3 = CurrentTheme.Accent,
                Text = "Click",
                TextColor3 = CurrentTheme.Text,
                TextSize = 14,
                Font = Enum.Font.GothamBold,
                BorderSizePixel = 0,
            }, {
                New("UICorner", {
                    CornerRadius = UDim.new(0, 6),
                }),
            })
            
            ClickButton.MouseButton1Click:Connect(function()
                pcall(callback)
                Tween(ClickButton, {BackgroundColor3 = CurrentTheme.AccentHover}, 0.1)
                task.wait(0.1)
                Tween(ClickButton, {BackgroundColor3 = CurrentTheme.Accent}, 0.1)
            end)
            
            ClickButton.MouseEnter:Connect(function()
                Tween(ClickButton, {BackgroundColor3 = CurrentTheme.AccentHover}, 0.2)
            end)
            
            ClickButton.MouseLeave:Connect(function()
                Tween(ClickButton, {BackgroundColor3 = CurrentTheme.Accent}, 0.2)
            end)
            
            return ButtonFrame
        end
        
        -- Toggle Function
        function TabObject:Toggle(toggleConfig)
            local toggleTitle = toggleConfig.Title or "Toggle"
            local toggleDesc = toggleConfig.Desc or ""
            local default = toggleConfig.Default or false
            local callback = toggleConfig.Callback or function() end
            
            local toggled = default
            
            local ToggleFrame = New("Frame", {
                Name = "Toggle",
                Parent = TabContent,
                Size = UDim2.new(1, 0, 0, 45),
                BackgroundColor3 = CurrentTheme.Secondary,
                BorderSizePixel = 0,
            }, {
                New("UICorner", {
                    CornerRadius = UDim.new(0, 8),
                }),
            })
            
            local ToggleLabel = New("TextLabel", {
                Name = "Label",
                Parent = ToggleFrame,
                Size = UDim2.new(1, -70, 1, 0),
                Position = UDim2.new(0, 10, 0, 0),
                BackgroundTransparency = 1,
                Text = toggleTitle,
                TextColor3 = CurrentTheme.Text,
                TextSize = 14,
                Font = Enum.Font.GothamBold,
                TextXAlignment = Enum.TextXAlignment.Left,
            })
            
            if toggleDesc ~= "" then
                ToggleLabel.Size = UDim2.new(1, -70, 0, 20)
                ToggleLabel.Position = UDim2.new(0, 10, 0, 5)
                
                New("TextLabel", {
                    Name = "Desc",
                    Parent = ToggleFrame,
                    Size = UDim2.new(1, -70, 0, 15),
                    Position = UDim2.new(0, 10, 0, 25),
                    BackgroundTransparency = 1,
                    Text = toggleDesc,
                    TextColor3 = CurrentTheme.TextDark,
                    TextSize = 12,
                    Font = Enum.Font.Gotham,
                    TextXAlignment = Enum.TextXAlignment.Left,
                })
            end
            
            local ToggleOuter = New("Frame", {
                Name = "ToggleOuter",
                Parent = ToggleFrame,
                Size = UDim2.new(0, 45, 0, 25),
                Position = UDim2.new(1, -55, 0.5, -12.5),
                BackgroundColor3 = toggled and CurrentTheme.Accent or CurrentTheme.Tertiary,
                BorderSizePixel = 0,
            }, {
                New("UICorner", {
                    CornerRadius = UDim.new(1, 0),
                }),
            })
            
            local ToggleInner = New("Frame", {
                Name = "ToggleInner",
                Parent = ToggleOuter,
                Size = UDim2.new(0, 19, 0, 19),
                Position = toggled and UDim2.new(1, -22, 0.5, -9.5) or UDim2.new(0, 3, 0.5, -9.5),
                BackgroundColor3 = CurrentTheme.Text,
                BorderSizePixel = 0,
            }, {
                New("UICorner", {
                    CornerRadius = UDim.new(1, 0),
                }),
            })
            
            local ToggleButton = New("TextButton", {
                Name = "ToggleButton",
                Parent = ToggleFrame,
                Size = UDim2.new(1, 0, 1, 0),
                BackgroundTransparency = 1,
                Text = "",
            })
            
            local function SetToggle(state)
                toggled = state
                pcall(callback, toggled)
                
                Tween(ToggleOuter, {BackgroundColor3 = toggled and CurrentTheme.Accent or CurrentTheme.Tertiary}, 0.2)
                Tween(ToggleInner, {Position = toggled and UDim2.new(1, -22, 0.5, -9.5) or UDim2.new(0, 3, 0.5, -9.5)}, 0.2)
            end
            
            ToggleButton.MouseButton1Click:Connect(function()
                SetToggle(not toggled)
            end)
            
            -- Call callback with default value
            if default then
                pcall(callback, toggled)
            end
            
            return ToggleFrame
        end
        
        -- Slider Function
        function TabObject:Slider(sliderConfig)
            local sliderTitle = sliderConfig.Title or "Slider"
            local sliderDesc = sliderConfig.Desc or ""
            local min = sliderConfig.Min or 0
            local max = sliderConfig.Max or 100
            local default = sliderConfig.Default or min
            local increment = sliderConfig.Increment or 1
            local suffix = sliderConfig.Suffix or ""
            local callback = sliderConfig.Callback or function() end
            
            local value = default
            
            local SliderFrame = New("Frame", {
                Name = "Slider",
                Parent = TabContent,
                Size = UDim2.new(1, 0, 0, 60),
                BackgroundColor3 = CurrentTheme.Secondary,
                BorderSizePixel = 0,
            }, {
                New("UICorner", {
                    CornerRadius = UDim.new(0, 8),
                }),
            })
            
            New("TextLabel", {
                Name = "Label",
                Parent = SliderFrame,
                Size = UDim2.new(1, -100, 0, 20),
                Position = UDim2.new(0, 10, 0, 5),
                BackgroundTransparency = 1,
                Text = sliderTitle,
                TextColor3 = CurrentTheme.Text,
                TextSize = 14,
                Font = Enum.Font.GothamBold,
                TextXAlignment = Enum.TextXAlignment.Left,
            })
            
            if sliderDesc ~= "" then
                New("TextLabel", {
                    Name = "Desc",
                    Parent = SliderFrame,
                    Size = UDim2.new(1, -100, 0, 15),
                    Position = UDim2.new(0, 10, 0, 25),
                    BackgroundTransparency = 1,
                    Text = sliderDesc,
                    TextColor3 = CurrentTheme.TextDark,
                    TextSize = 12,
                    Font = Enum.Font.Gotham,
                    TextXAlignment = Enum.TextXAlignment.Left,
                })
            end
            
            local ValueLabel = New("TextLabel", {
                Name = "Value",
                Parent = SliderFrame,
                Size = UDim2.new(0, 80, 0, 20),
                Position = UDim2.new(1, -90, 0, 5),
                BackgroundTransparency = 1,
                Text = tostring(value) .. suffix,
                TextColor3 = CurrentTheme.Accent,
                TextSize = 14,
                Font = Enum.Font.GothamBold,
                TextXAlignment = Enum.TextXAlignment.Right,
            })
            
            local SliderBar = New("Frame", {
                Name = "Bar",
                Parent = SliderFrame,
                Size = UDim2.new(1, -20, 0, 4),
                Position = UDim2.new(0, 10, 1, -12),
                BackgroundColor3 = CurrentTheme.Tertiary,
                BorderSizePixel = 0,
            }, {
                New("UICorner", {
                    CornerRadius = UDim.new(1, 0),
                }),
            })
            
            local SliderFill = New("Frame", {
                Name = "Fill",
                Parent = SliderBar,
                Size = UDim2.new((value - min) / (max - min), 0, 1, 0),
                BackgroundColor3 = CurrentTheme.Accent,
                BorderSizePixel = 0,
            }, {
                New("UICorner", {
                    CornerRadius = UDim.new(1, 0),
                }),
            })
            
            local SliderDot = New("Frame", {
                Name = "Dot",
                Parent = SliderBar,
                Size = UDim2.new(0, 14, 0, 14),
                Position = UDim2.new((value - min) / (max - min), -7, 0.5, -7),
                BackgroundColor3 = CurrentTheme.Text,
                BorderSizePixel = 0,
            }, {
                New("UICorner", {
                    CornerRadius = UDim.new(1, 0),
                }),
            })
            
            local dragging = false
            
            local function SetValue(newValue)
                value = math.clamp(math.floor((newValue - min) / increment + 0.5) * increment + min, min, max)
                ValueLabel.Text = tostring(value) .. suffix
                
                local scale = (value - min) / (max - min)
                Tween(SliderFill, {Size = UDim2.new(scale, 0, 1, 0)}, 0.1)
                Tween(SliderDot, {Position = UDim2.new(scale, -7, 0.5, -7)}, 0.1)
                
                pcall(callback, value)
            end
            
            SliderBar.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    dragging = true
                    local mousePos = UserInputService:GetMouseLocation().X
                    local barPos = SliderBar.AbsolutePosition.X
                    local barSize = SliderBar.AbsoluteSize.X
                    local scale = math.clamp((mousePos - barPos) / barSize, 0, 1)
                    SetValue(min + (max - min) * scale)
                end
            end)
            
            SliderBar.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    dragging = false
                end
            end)
            
            UserInputService.InputChanged:Connect(function(input)
                if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                    local mousePos = UserInputService:GetMouseLocation().X
                    local barPos = SliderBar.AbsolutePosition.X
                    local barSize = SliderBar.AbsoluteSize.X
                    local scale = math.clamp((mousePos - barPos) / barSize, 0, 1)
                    SetValue(min + (max - min) * scale)
                end
            end)
            
            -- Set default
            SetValue(default)
            
            return SliderFrame
        end
        
        -- Dropdown Function
        function TabObject:Dropdown(dropdownConfig)
            local dropdownTitle = dropdownConfig.Title or "Dropdown"
            local dropdownDesc = dropdownConfig.Desc or ""
            local values = dropdownConfig.Values or {"Option 1", "Option 2"}
            local default = dropdownConfig.Default or values[1]
            local callback = dropdownConfig.Callback or function() end
            
            local selected = default
            local opened = false
            
            local DropdownFrame = New("Frame", {
                Name = "Dropdown",
                Parent = TabContent,
                Size = UDim2.new(1, 0, 0, 45),
                BackgroundColor3 = CurrentTheme.Secondary,
                BorderSizePixel = 0,
                ClipsDescendants = true,
            }, {
                New("UICorner", {
                    CornerRadius = UDim.new(0, 8),
                }),
            })
            
            local DropdownLabel = New("TextLabel", {
                Name = "Label",
                Parent = DropdownFrame,
                Size = UDim2.new(1, -120, 1, 0),
                Position = UDim2.new(0, 10, 0, 0),
                BackgroundTransparency = 1,
                Text = dropdownTitle,
                TextColor3 = CurrentTheme.Text,
                TextSize = 14,
                Font = Enum.Font.GothamBold,
                TextXAlignment = Enum.TextXAlignment.Left,
            })
            
            if dropdownDesc ~= "" then
                DropdownLabel.Size = UDim2.new(1, -120, 0, 20)
                DropdownLabel.Position = UDim2.new(0, 10, 0, 5)
                
                New("TextLabel", {
                    Name = "Desc",
                    Parent = DropdownFrame,
                    Size = UDim2.new(1, -120, 0, 15),
                    Position = UDim2.new(0, 10, 0, 25),
                    BackgroundTransparency = 1,
                    Text = dropdownDesc,
                    TextColor3 = CurrentTheme.TextDark,
                    TextSize = 12,
                    Font = Enum.Font.Gotham,
                    TextXAlignment = Enum.TextXAlignment.Left,
                })
            end
            
            local SelectedLabel = New("TextLabel", {
                Name = "Selected",
                Parent = DropdownFrame,
                Size = UDim2.new(0, 100, 0, 30),
                Position = UDim2.new(1, -110, 0, 7.5),
                BackgroundColor3 = CurrentTheme.Tertiary,
                Text = selected,
                TextColor3 = CurrentTheme.Text,
                TextSize = 13,
                Font = Enum.Font.Gotham,
                BorderSizePixel = 0,
            }, {
                New("UICorner", {
                    CornerRadius = UDim.new(0, 6),
                }),
            })
            
            local OptionsContainer = New("Frame", {
                Name = "Options",
                Parent = DropdownFrame,
                Size = UDim2.new(1, -20, 0, 0),
                Position = UDim2.new(0, 10, 0, 50),
                BackgroundTransparency = 1,
            }, {
                New("UIListLayout", {
                    Padding = UDim.new(0, 3),
                    SortOrder = Enum.SortOrder.LayoutOrder,
                })
            })
            
            -- Create option buttons
            for _, option in ipairs(values) do
                local OptionButton = New("TextButton", {
                    Name = option,
                    Parent = OptionsContainer,
                    Size = UDim2.new(1, 0, 0, 30),
                    BackgroundColor3 = CurrentTheme.Tertiary,
                    Text = option,
                    TextColor3 = CurrentTheme.Text,
                    TextSize = 13,
                    Font = Enum.Font.Gotham,
                    BorderSizePixel = 0,
                }, {
                    New("UICorner", {
                        CornerRadius = UDim.new(0, 6),
                    }),
                })
                
                OptionButton.MouseButton1Click:Connect(function()
                    selected = option
                    SelectedLabel.Text = selected
                    pcall(callback, selected)
                    
                    opened = false
                    Tween(DropdownFrame, {Size = UDim2.new(1, 0, 0, 45)}, 0.3)
                end)
                
                OptionButton.MouseEnter:Connect(function()
                    Tween(OptionButton, {BackgroundColor3 = CurrentTheme.Accent}, 0.2)
                end)
                
                OptionButton.MouseLeave:Connect(function()
                    Tween(OptionButton, {BackgroundColor3 = CurrentTheme.Tertiary}, 0.2)
                end)
            end
            
            -- Toggle dropdown
            local DropdownButton = New("TextButton", {
                Name = "Toggle",
                Parent = DropdownFrame,
                Size = UDim2.new(1, 0, 0, 45),
                BackgroundTransparency = 1,
                Text = "",
                ZIndex = 2,
            })
            
            DropdownButton.MouseButton1Click:Connect(function()
                opened = not opened
                if opened then
                    local contentHeight = #values * 33 + 50
                    Tween(DropdownFrame, {Size = UDim2.new(1, 0, 0, contentHeight)}, 0.3)
                else
                    Tween(DropdownFrame, {Size = UDim2.new(1, 0, 0, 45)}, 0.3)
                end
            end)
            
            -- Call callback with default
            pcall(callback, selected)
            
            return DropdownFrame
        end
        
        -- Input Function
        function TabObject:Input(inputConfig)
            local inputTitle = inputConfig.Title or "Input"
            local inputDesc = inputConfig.Desc or ""
            local placeholder = inputConfig.Placeholder or "Enter text..."
            local default = inputConfig.Default or ""
            local callback = inputConfig.Callback or function() end
            
            local InputFrame = New("Frame", {
                Name = "Input",
                Parent = TabContent,
                Size = UDim2.new(1, 0, 0, 45),
                BackgroundColor3 = CurrentTheme.Secondary,
                BorderSizePixel = 0,
            }, {
                New("UICorner", {
                    CornerRadius = UDim.new(0, 8),
                }),
            })
            
            local InputLabel = New("TextLabel", {
                Name = "Label",
                Parent = InputFrame,
                Size = UDim2.new(1, -150, 1, 0),
                Position = UDim2.new(0, 10, 0, 0),
                BackgroundTransparency = 1,
                Text = inputTitle,
                TextColor3 = CurrentTheme.Text,
                TextSize = 14,
                Font = Enum.Font.GothamBold,
                TextXAlignment = Enum.TextXAlignment.Left,
            })
            
            if inputDesc ~= "" then
                InputLabel.Size = UDim2.new(1, -150, 0, 20)
                InputLabel.Position = UDim2.new(0, 10, 0, 5)
                
                New("TextLabel", {
                    Name = "Desc",
                    Parent = InputFrame,
                    Size = UDim2.new(1, -150, 0, 15),
                    Position = UDim2.new(0, 10, 0, 25),
                    BackgroundTransparency = 1,
                    Text = inputDesc,
                    TextColor3 = CurrentTheme.TextDark,
                    TextSize = 12,
                    Font = Enum.Font.Gotham,
                    TextXAlignment = Enum.TextXAlignment.Left,
                })
            end
            
            local TextBox = New("TextBox", {
                Name = "TextBox",
                Parent = InputFrame,
                Size = UDim2.new(0, 130, 0, 30),
                Position = UDim2.new(1, -140, 0.5, -15),
                BackgroundColor3 = CurrentTheme.Tertiary,
                Text = default,
                PlaceholderText = placeholder,
                TextColor3 = CurrentTheme.Text,
                PlaceholderColor3 = CurrentTheme.TextDark,
                TextSize = 13,
                Font = Enum.Font.Gotham,
                BorderSizePixel = 0,
                ClearTextOnFocus = false,
            }, {
                New("UICorner", {
                    CornerRadius = UDim.new(0, 6),
                }),
            })
            
            TextBox.FocusLost:Connect(function(enterPressed)
                if enterPressed then
                    pcall(callback, TextBox.Text)
                end
            end)
            
            return InputFrame
        end
        
        -- Keybind Function
        function TabObject:Keybind(keybindConfig)
            local keybindTitle = keybindConfig.Title or "Keybind"
            local keybindDesc = keybindConfig.Desc or ""
            local default = keybindConfig.Default or Enum.KeyCode.E
            local callback = keybindConfig.Callback or function() end
            
            local currentKey = default
            local waitingForKey = false
            
            local KeybindFrame = New("Frame", {
                Name = "Keybind",
                Parent = TabContent,
                Size = UDim2.new(1, 0, 0, 45),
                BackgroundColor3 = CurrentTheme.Secondary,
                BorderSizePixel = 0,
            }, {
                New("UICorner", {
                    CornerRadius = UDim.new(0, 8),
                }),
            })
            
            local KeybindLabel = New("TextLabel", {
                Name = "Label",
                Parent = KeybindFrame,
                Size = UDim2.new(1, -120, 1, 0),
                Position = UDim2.new(0, 10, 0, 0),
                BackgroundTransparency = 1,
                Text = keybindTitle,
                TextColor3 = CurrentTheme.Text,
                TextSize = 14,
                Font = Enum.Font.GothamBold,
                TextXAlignment = Enum.TextXAlignment.Left,
            })
            
            if keybindDesc ~= "" then
                KeybindLabel.Size = UDim2.new(1, -120, 0, 20)
                KeybindLabel.Position = UDim2.new(0, 10, 0, 5)
                
                New("TextLabel", {
                    Name = "Desc",
                    Parent = KeybindFrame,
                    Size = UDim2.new(1, -120, 0, 15),
                    Position = UDim2.new(0, 10, 0, 25),
                    BackgroundTransparency = 1,
                    Text = keybindDesc,
                    TextColor3 = CurrentTheme.TextDark,
                    TextSize = 12,
                    Font = Enum.Font.Gotham,
                    TextXAlignment = Enum.TextXAlignment.Left,
                })
            end
            
            local KeyButton = New("TextButton", {
                Name = "KeyButton",
                Parent = KeybindFrame,
                Size = UDim2.new(0, 100, 0, 30),
                Position = UDim2.new(1, -110, 0.5, -15),
                BackgroundColor3 = CurrentTheme.Tertiary,
                Text = currentKey.Name,
                TextColor3 = CurrentTheme.Text,
                TextSize = 13,
                Font = Enum.Font.GothamBold,
                BorderSizePixel = 0,
            }, {
                New("UICorner", {
                    CornerRadius = UDim.new(0, 6),
                }),
            })
            
            KeyButton.MouseButton1Click:Connect(function()
                waitingForKey = true
                KeyButton.Text = "..."
                KeyButton.BackgroundColor3 = CurrentTheme.Accent
            end)
            
            UserInputService.InputBegan:Connect(function(input, gameProcessed)
                if waitingForKey and input.UserInputType == Enum.UserInputType.Keyboard then
                    currentKey = input.KeyCode
                    KeyButton.Text = currentKey.Name
                    KeyButton.BackgroundColor3 = CurrentTheme.Tertiary
                    waitingForKey = false
                    pcall(callback, currentKey)
                end
            end)
            
            -- Call callback with default
            pcall(callback, currentKey)
            
            return KeybindFrame
        end
        
        -- Paragraph Function
        function TabObject:Paragraph(paragraphConfig)
            local paragraphTitle = paragraphConfig.Title or "Paragraph"
            local paragraphDesc = paragraphConfig.Desc or ""
            
            local ParagraphFrame = New("Frame", {
                Name = "Paragraph",
                Parent = TabContent,
                Size = UDim2.new(1, 0, 0, 60),
                BackgroundColor3 = CurrentTheme.Secondary,
                BorderSizePixel = 0,
            }, {
                New("UICorner", {
                    CornerRadius = UDim.new(0, 8),
                }),
                New("TextLabel", {
                    Name = "Title",
                    Size = UDim2.new(1, -20, 0, 20),
                    Position = UDim2.new(0, 10, 0, 5),
                    BackgroundTransparency = 1,
                    Text = paragraphTitle,
                    TextColor3 = CurrentTheme.Text,
                    TextSize = 14,
                    Font = Enum.Font.GothamBold,
                    TextXAlignment = Enum.TextXAlignment.Left,
                }),
                New("TextLabel", {
                    Name = "Content",
                    Size = UDim2.new(1, -20, 1, -30),
                    Position = UDim2.new(0, 10, 0, 25),
                    BackgroundTransparency = 1,
                    Text = paragraphDesc,
                    TextColor3 = CurrentTheme.TextDark,
                    TextSize = 13,
                    Font = Enum.Font.Gotham,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    TextYAlignment = Enum.TextYAlignment.Top,
                    TextWrapped = true,
                }),
            })
            
            return ParagraphFrame
        end
        
        -- Divider Function
        function TabObject:Divider()
            local Divider = New("Frame", {
                Name = "Divider",
                Parent = TabContent,
                Size = UDim2.new(1, 0, 0, 1),
                BackgroundColor3 = CurrentTheme.Border,
                BorderSizePixel = 0,
            })
            
            return Divider
        end
        
        return TabObject
    end
    
    -- Fade in animation
    Window.Size = UDim2.new(0, 0, 0, 0)
    Window.Position = UDim2.new(0.5, 0, 0.5, 0)
    Tween(Window, {Size = size, Position = UDim2.new(0.5, -size.X.Offset/2, 0.5, -size.Y.Offset/2)}, 0.4)
    
    self.ActiveWindow = WindowObject
    return WindowObject
end

return ToastyUI


