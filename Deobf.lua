--[[ GPL-3.0 License
    This work is licensed under the GNU General Public License v3.0.
    You may redistribute and modify it under the terms of that license.
    https://www.gnu.org/licenses/gpl-3.0.html
]]
-- Deobf and AI-assisted var renaming by qquzi and Grok

local KavoLib = loadstring(game:HttpGet('https://raw.githubusercontent.com/xHeptc/Kavo-UI-Library/main/source.lua'))()
local MainGui = KavoLib.CreateLib('Rake Remastered Script', 'BloodTheme')
local MainTab = MainGui:NewTab('Main')
local MainSection = MainTab:NewSection('Main')

MainSection:NewButton('3rd Person and Shift Lock', 'ButtonInfo', function()
    local Players = game:GetService('Players')
    local UserInputService = game:GetService('UserInputService')
    local RunService = game:GetService('RunService')
    local LocalPlayer = Players.LocalPlayer
    local customMouseIcon = 'rbxassetid://6522857905'

    if _G.RakeMouseConn then
        _G.RakeMouseConn:Disconnect()
    end
    if _G.RakeCameraConn then
        _G.RakeCameraConn:Disconnect()
    end

    _G.RakeMouseConn = RunService.RenderStepped:Connect(function()
        UserInputService.MouseIconEnabled = true

        if UserInputService.MouseBehavior ~= Enum.MouseBehavior.LockCenter then
            if UserInputService.MouseIcon ~= '' then
                UserInputService.MouseIcon = ''
            end
        elseif UserInputService.MouseIcon ~= customMouseIcon then
            UserInputService.MouseIcon = customMouseIcon
        end
    end)
    _G.RakeCameraConn = RunService.RenderStepped:Connect(function()
        local Character = LocalPlayer.Character
        local Humanoid = Character and Character:FindFirstChildOfClass('Humanoid')
        if Humanoid then
            if Humanoid.Health >= 100 then
                LocalPlayer.CameraMode = Enum.CameraMode.Classic
                LocalPlayer.CameraMinZoomDistance = 0.5
                LocalPlayer.CameraMaxZoomDistance = 15
            else
                LocalPlayer.CameraMode = Enum.CameraMode.Classic
                LocalPlayer.CameraMinZoomDistance = 8
                LocalPlayer.CameraMaxZoomDistance = 15
            end
        end

        pcall(function()
            LocalPlayer.DevEnableMouseLock = true
            LocalPlayer.DevComputerCameraMode = Enum.DevComputerCameraMovementMode.Classic
        end)
    end)
end)

MainSection:NewToggle('FullBright', 'ToggleInfo', function(state)
    if state then
        local Lighting = game:GetService('Lighting')
        local PlayersService = game:GetService('Players')
        local LocalPlayer = PlayersService.LocalPlayer

        _G.LightingToggleEnabled = true

        local function updateLighting()
            Lighting.Ambient = Color3.fromRGB(255, 255, 255)
            Lighting.Brightness = 1
            Lighting.FogEnd = 10000000000

            for _, descendant in pairs(Lighting:GetDescendants()) do
                if descendant:IsA('BloomEffect') or descendant:IsA('BlurEffect') or descendant:IsA('ColorCorrectionEffect') or descendant:IsA('SunRaysEffect') then
                    descendant.Enabled = false
                end
            end
        end

        updateLighting()
        Lighting.Changed:Connect(function()
            if _G.LightingToggleEnabled then
                updateLighting()
            end
        end)
        spawn(function()
            while _G.LightingToggleEnabled do
                local Character = LocalPlayer.Character

                if Character and Character:FindFirstChild('HumanoidRootPart') then
                    local HumanoidRootPart = Character.HumanoidRootPart

                    if not HumanoidRootPart:FindFirstChildWhichIsA('PointLight') then
                        local PointLight = Instance.new('PointLight')
                        PointLight.Name = 'HeadLight'
                        PointLight.Brightness = 1
                        PointLight.Range = 60
                        PointLight.Parent = HumanoidRootPart
                    end
                end

                wait(1)
            end
        end)
    else
        local Lighting = game:GetService('Lighting')
        local LocalPlayer = game:GetService('Players').LocalPlayer

        _G.LightingToggleEnabled = false
        Lighting.Ambient = Color3.fromRGB(128, 128, 128)
        Lighting.Brightness = 2
        Lighting.FogEnd = 1000

        for _, descendant in pairs(Lighting:GetDescendants()) do
            if descendant:IsA('BloomEffect') or descendant:IsA('BlurEffect') or descendant:IsA('ColorCorrectionEffect') or descendant:IsA('SunRaysEffect') then
                descendant.Enabled = true
            end
        end

        local Character = LocalPlayer.Character

        if Character and Character:FindFirstChild('HumanoidRootPart') then
            local HumanoidRootPart = Character.HumanoidRootPart
            for _, child in pairs(HumanoidRootPart:GetChildren()) do
                if child:IsA('PointLight') and child.Name == 'HeadLight' then
                    child:Destroy()
                end
            end
        end
    end
end)

MainSection:NewToggle('NoClip (Doesnt work well)', 'ToggleInfo', function(state)
    if state then
        local LocalPlayer = game:GetService('Players').LocalPlayer
        local Character = LocalPlayer.Character

        while not Character do
            task.wait()
            Character = LocalPlayer.Character
        end

        local Humanoid = Character:WaitForChild('Humanoid')
        for _, descendant in pairs(Character:GetDescendants()) do
            if descendant:IsA('BasePart') then
                descendant.CanCollide = false
            end
        end

        Humanoid.WalkSpeed = 0
        Humanoid.JumpPower = 0
    else
        local LocalPlayer = game:GetService('Players').LocalPlayer
        local Character = LocalPlayer.Character

        while not Character do
            task.wait()
            Character = LocalPlayer.Character
        end

        local Humanoid = Character:WaitForChild('Humanoid')
        for _, descendant in pairs(Character:GetDescendants()) do
            if descendant:IsA('BasePart') then
                descendant.CanCollide = true
            end
        end

        Humanoid.WalkSpeed = 16
        Humanoid.JumpPower = 50
    end
end)

local LocalPlayer = game.Players.LocalPlayer
local RunService = game:GetService('RunService')
local currentWalkSpeed = 30

MainSection:NewSlider('WalkSpeed', 'Adjust your WalkSpeed', 30, 0, function(value)
    currentWalkSpeed = value
end)
RunService.RenderStepped:Connect(function()
    local Character = LocalPlayer.Character

    if Character and Character:FindFirstChild('Humanoid') then
        local Humanoid = Character.Humanoid

        if Humanoid.WalkSpeed < currentWalkSpeed then
            Humanoid.WalkSpeed = currentWalkSpeed
        end
    end
end)

MainSection:NewToggle('Power Level', 'Shows Power level in a GUI', function(state)
    if state then
        local LocalPlayer = game.Players.LocalPlayer
        local ScreenGui = Instance.new('ScreenGui')

        ScreenGui.Name = 'PowerGUI'
        ScreenGui.Parent = LocalPlayer:WaitForChild('PlayerGui')

        local Frame = Instance.new('Frame')

        Frame.Size = UDim2.new(0, 120, 0, 40)
        Frame.Position = UDim2.new(0.5, -60, 0.12, 0)
        Frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
        Frame.BackgroundTransparency = 0.15
        Frame.Active = true
        Frame.Draggable = true
        Frame.Parent = ScreenGui

        local TextLabel = Instance.new('TextLabel')

        TextLabel.Size = UDim2.new(1, 0, 1, 0)
        TextLabel.BackgroundTransparency = 1
        TextLabel.Text = 'Power: --%'
        TextLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
        TextLabel.Font = Enum.Font.SourceSansBold
        TextLabel.TextSize = 28
        TextLabel.Parent = Frame

        local function findPowerLevel()
            local ReplicatedStorage = game:GetService('ReplicatedStorage')
            for _, descendant in ipairs(ReplicatedStorage:GetDescendants()) do
                if descendant.Name == 'PowerLevel' and descendant.Value ~= nil then
                    return descendant
                end
            end
            return nil
        end

        local PowerValue = findPowerLevel()

        game:GetService('RunService').RenderStepped:Connect(function()
            if not PowerValue then
                PowerValue = findPowerLevel()
            end
            if PowerValue and PowerValue.Value ~= nil then
                local percentage = math.floor(PowerValue.Value / 1000 * 100 + 0.5)
                TextLabel.Text = 'Power: ' .. tostring(percentage) .. '%'
            else
                TextLabel.Text = 'Power: --%'
            end
        end)
    else
        local PowerGUI = LocalPlayer.PlayerGui:FindFirstChild('PowerGUI')
        if PowerGUI then
            PowerGUI:Destroy()
        end
    end
end)

MainSection:NewToggle('Night/Timer Display', 'Shows time until day/night and timer in a GUI', function(state)
    local LocalPlayer = game.Players.LocalPlayer

    if state then
        local ScreenGui = Instance.new('ScreenGui')

        ScreenGui.Name = 'NightTimerGUI'
        ScreenGui.Parent = LocalPlayer:WaitForChild('PlayerGui')

        local Frame = Instance.new('Frame')

        Frame.Size = UDim2.new(0, 220, 0, 40)
        Frame.Position = UDim2.new(0.5, -110, 0.18, 0)
        Frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
        Frame.BackgroundTransparency = 0.15
        Frame.Active = true
        Frame.Draggable = true
        Frame.Parent = ScreenGui

        local TextLabel = Instance.new('TextLabel')

        TextLabel.Size = UDim2.new(1, 0, 1, 0)
        TextLabel.BackgroundTransparency = 1
        TextLabel.Text = 'Loading...'
        TextLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
        TextLabel.Font = Enum.Font.SourceSansBold
        TextLabel.TextSize = 22
        TextLabel.TextYAlignment = Enum.TextYAlignment.Center
        TextLabel.Parent = Frame

        local function findValue(name)
            local ReplicatedStorage = game:GetService('ReplicatedStorage')
            for _, descendant in ipairs(ReplicatedStorage:GetDescendants()) do
                if descendant.Name == name and descendant.Value ~= nil then
                    return descendant
                end
            end
            return nil
        end

        local NightValue = findValue('Night')
        local TimerValue = findValue('Timer')
        local connection = game:GetService('RunService').RenderStepped:Connect(function()
            if not NightValue then
                NightValue = findValue('Night')
            end
            if not TimerValue then
                TimerValue = findValue('Timer')
            end

            local timerText = (not TimerValue or TimerValue.Value == nil) and '--' or tostring(TimerValue.Value)

            if NightValue and NightValue.Value ~= nil then
                if NightValue.Value ~= true then
                    TextLabel.Text = 'Time until night: ' .. timerText
                else
                    TextLabel.Text = 'Time until day: ' .. timerText
                end
            else
                TextLabel.Text = 'Night/Timer not found'
            end
        end)

        ScreenGui.AncestryChanged:Connect(function(_, parent)
            if not parent and connection then
                connection:Disconnect()
            end
        end)
    else
        local NightTimerGUI = LocalPlayer.PlayerGui:FindFirstChild('NightTimerGUI')
        if NightTimerGUI then
            NightTimerGUI:Destroy()
        end
    end
end)

MainSection:NewButton('Chat Logger', 'Logs Chats', function()
    loadstring(game:HttpGet('https://raw.githubusercontent.com/v-oidd/chat-tracker/main/chat-tracker.lua'))()
end)

local ESPTab = MainGui:NewTab('ESP')
local ESPSection = ESPTab:NewSection('ESP')

ESPSection:NewToggle('ScrapESP', 'ToggleInfo', function(state)
    if state then
        local Players = game:GetService('Players')
        local RunService = game:GetService('RunService')
        local LocalPlayer = Players.LocalPlayer
        local labelObjects = {}
        local highlightObjects = {}
        local maxDistance = 800
        local labelSize = Vector2.new(60, 20)
        local minScale = 0.3

        local function createLabel(model)
            local basePart = nil
            for _, BasePart in ipairs(model:GetChildren()) do
                if BasePart:IsA('BasePart') then
                    basePart = BasePart
                    break
                end
            end

            if basePart then
                if not basePart:FindFirstChild('ScrapLabel') then
                    local BillboardGui = Instance.new('BillboardGui')
                    BillboardGui.Name = 'ScrapLabel'
                    BillboardGui.Size = UDim2.new(0, labelSize.X, 0, labelSize.Y)
                    BillboardGui.StudsOffset = Vector3.new(0, 3, 0)
                    BillboardGui.Adornee = basePart
                    BillboardGui.AlwaysOnTop = true
                    BillboardGui.MaxDistance = maxDistance
                    BillboardGui.Parent = basePart

                    local TextLabel = Instance.new('TextLabel')
                    TextLabel.Size = UDim2.new(1, 0, 1, 0)
                    TextLabel.BackgroundTransparency = 1
                    TextLabel.Text = 'Scrap'
                    TextLabel.TextColor3 = Color3.fromRGB(255, 255, 0)
                    TextLabel.TextStrokeColor3 = Color3.new(0, 0, 0)
                    TextLabel.TextStrokeTransparency = 0
                    TextLabel.TextScaled = true
                    TextLabel.Font = Enum.Font.SourceSansBold
                    TextLabel.Parent = BillboardGui

                    table.insert(labelObjects, {
                        gui = BillboardGui,
                        part = basePart,
                    })
                end
            end
        end

        local function createHighlight(model)
            if not model:FindFirstChild('ScrapHighlight') then
                local Highlight = Instance.new('Highlight')
                Highlight.Name = 'ScrapHighlight'
                Highlight.Adornee = model
                Highlight.FillColor = Color3.fromRGB(255, 255, 0)
                Highlight.OutlineColor = Color3.fromRGB(0, 0, 0)
                Highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                Highlight.Parent = model

                table.insert(highlightObjects, Highlight)
            end
        end

        local function applyESP(model)
            createHighlight(model)
            createLabel(model)
        end

        local function scanExisting()
            for _, ScrapModel in ipairs(game:GetDescendants()) do
                if ScrapModel:IsA('Model') and string.find(ScrapModel.Name:lower(), 'scrap') then
                    applyESP(ScrapModel)
                end
            end
        end

        local function onDescendantAdded(descendant)
            if descendant:IsA('Model') and string.find(descendant.Name:lower(), 'scrap') then
                task.wait(0.1)
                applyESP(descendant)
            end
        end

        RunService.RenderStepped:Connect(function()
            local Character = LocalPlayer.Character
            local HumanoidRootPart = Character and Character:FindFirstChild('HumanoidRootPart')
            if HumanoidRootPart then
                for i = #labelObjects, 1, -1 do
                    local entry = labelObjects[i]
                    if entry.part and entry.gui then
                        local distance = (HumanoidRootPart.Position - entry.part.Position).Magnitude
                        if distance > maxDistance then
                            entry.gui.Size = UDim2.new(0, 0, 0, 0)
                        else
                            local scale = math.clamp(1 - distance / maxDistance, minScale, 1)
                            entry.gui.Size = UDim2.new(0, labelSize.X * scale, 0, labelSize.Y * scale)
                        end
                    end
                end
            end
        end)

        game.DescendantAdded:Connect(onDescendantAdded)
        scanExisting()
    else
        for _, descendant in ipairs(game:GetDescendants()) do
            if descendant:IsA('Model') then
                local highlight = descendant:FindFirstChild('ScrapHighlight')
                if highlight then
                    highlight:Destroy()
                end

                for _, child in ipairs(descendant:GetChildren()) do
                    if child:IsA('BasePart') then
                        local label = child:FindFirstChild('ScrapLabel')
                        if label then
                            label:Destroy()
                        end
                    end
                end
            end
        end
    end
end)

ESPSection:NewToggle('Flare Gun ESP', 'See the flare gun', function(state)
    if state then
        local Players = game:GetService('Players')
        local RunService = game:GetService('RunService')
        local LocalPlayer = Players.LocalPlayer
        local labelObjects = {}
        local highlightObjects = {}
        local maxDistance = 800
        local labelSize = Vector2.new(60, 20)
        local minScale = 0.3

        _G.FlareGunESPEnabled = true

        local function contains(str, substr)
            return string.find(string.lower(str), string.lower(substr)) ~= nil
        end

        local function isFlareGun(model)
            local nameLower = model.Name:lower()
            local isFlare = contains(nameLower, 'flaregun')
            if isFlare then
                isFlare = not contains(nameLower, 'Clue')
            end
            return isFlare
        end

        local function createLabel(model)
            local basePart = model:FindFirstChildWhichIsA('BasePart')
            if basePart then
                if not basePart:FindFirstChild('ItemLabel') then
                    local BillboardGui = Instance.new('BillboardGui')
                    BillboardGui.Name = 'ItemLabel'
                    BillboardGui.Size = UDim2.new(0, labelSize.X, 0, labelSize.Y)
                    BillboardGui.StudsOffset = Vector3.new(0, 3, 0)
                    BillboardGui.Adornee = basePart
                    BillboardGui.AlwaysOnTop = true
                    BillboardGui.MaxDistance = maxDistance
                    BillboardGui.Parent = basePart

                    local TextLabel = Instance.new('TextLabel')
                    TextLabel.Size = UDim2.new(1, 0, 1, 0)
                    TextLabel.BackgroundTransparency = 1
                    TextLabel.Text = 'FlareGun'
                    TextLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
                    TextLabel.TextStrokeColor3 = Color3.new(0, 0, 0)
                    TextLabel.TextStrokeTransparency = 0
                    TextLabel.TextScaled = true
                    TextLabel.Font = Enum.Font.SourceSansBold
                    TextLabel.Parent = BillboardGui

                    table.insert(labelObjects, {
                        gui = BillboardGui,
                        part = basePart,
                    })
                end
            end
        end

        local function createHighlight(model)
            if not model:FindFirstChildOfClass('Highlight') then
                local Highlight = Instance.new('Highlight')
                Highlight.Adornee = model
                Highlight.FillColor = Color3.fromRGB(255, 100, 100)
                Highlight.OutlineColor = Color3.new(0, 0, 0)
                Highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                Highlight.Parent = model

                table.insert(highlightObjects, Highlight)
            end
        end

        local function applyESP(model)
            createHighlight(model)
            createLabel(model)
        end

        local function scanExisting()
            for _, FlareGunModel in ipairs(game:GetDescendants()) do
                if FlareGunModel:IsA('Model') and isFlareGun(FlareGunModel) then
                    applyESP(FlareGunModel)
                end
            end
        end

        local function onDescendantAdded(descendant)
            if descendant:IsA('Model') and isFlareGun(descendant) then
                task.wait(0.1)
                applyESP(descendant)
            end
        end

        RunService.RenderStepped:Connect(function()
            if _G.FlareGunESPEnabled then
                local Character = LocalPlayer.Character
                local HumanoidRootPart = Character and Character:FindFirstChild('HumanoidRootPart')
                if HumanoidRootPart then
                    for i = #labelObjects, 1, -1 do
                        local entry = labelObjects[i]
                        if entry.part and entry.gui then
                            local distance = (HumanoidRootPart.Position - entry.part.Position).Magnitude
                            entry.gui.Enabled = true
                            if distance > maxDistance then
                                entry.gui.Size = UDim2.new(0, 0, 0, 0)
                            else
                                local scale = math.clamp(1 - distance / maxDistance, minScale, 1)
                                entry.gui.Size = UDim2.new(0, labelSize.X * scale, 0, labelSize.Y * scale)
                            end
                        end
                    end

                    for _, highlight in ipairs(highlightObjects) do
                        highlight.Enabled = true
                    end
                end
            else
                for _, entry in ipairs(labelObjects) do
                    if entry.gui then
                        entry.gui.Enabled = false
                    end
                end

                for _, highlight in ipairs(highlightObjects) do
                    highlight.Enabled = false
                end
            end
        end)

        game.DescendantAdded:Connect(onDescendantAdded)
        _G.FlareGunESPEnabled = true
        scanExisting()
    else
        for _, descendant in ipairs(game:GetDescendants()) do
            if descendant:IsA('Highlight') and descendant.Adornee and typeof(descendant.Adornee) == 'Instance' and string.find(descendant.Adornee.Name:lower(), 'flaregun') then
                descendant:Destroy()
            end
            if descendant:IsA('BillboardGui') and descendant.Name == 'ItemLabel' and descendant.Adornee and descendant.Adornee:IsA('BasePart') and string.find(descendant.Adornee.Parent.Name:lower(), 'flaregun') then
                descendant:Destroy()
            end
        end

        _G.FlareGunESPEnabled = false
        print('FlareGun ESP fully removed and disabled.')
    end
end)

ESPSection:NewToggle('Supply Crate ESP', 'ToggleInfo', function(state)
    if state then
        local Players = game:GetService('Players')
        local RunService = game:GetService('RunService')
        local LocalPlayer = Players.LocalPlayer
        local maxDistance = 1000
        local labelSize = Vector2.new(120, 40)
        local minScale = 0.3
        local labelObjects = {}

        local function createLabel(model)
            local basePart = nil
            for _, BasePart in ipairs(model:GetChildren()) do
                if BasePart:IsA('BasePart') then
                    basePart = BasePart
                    break
                end
            end

            if basePart then
                if not basePart:FindFirstChild('SupplyCrateLabel') then
                    local BillboardGui = Instance.new('BillboardGui')
                    BillboardGui.Name = 'SupplyCrateLabel'
                    BillboardGui.Size = UDim2.new(0, labelSize.X, 0, labelSize.Y)
                    BillboardGui.StudsOffset = Vector3.new(0, 4, 0)
                    BillboardGui.Adornee = basePart
                    BillboardGui.AlwaysOnTop = true
                    BillboardGui.Parent = basePart

                    local TextLabel = Instance.new('TextLabel')
                    TextLabel.Size = UDim2.new(1, 0, 1, 0)
                    TextLabel.BackgroundTransparency = 0.3
                    TextLabel.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
                    TextLabel.Text = 'Supply Crate'
                    TextLabel.TextColor3 = Color3.fromRGB(0, 255, 255)
                    TextLabel.TextStrokeColor3 = Color3.new(0, 0, 0)
                    TextLabel.TextStrokeTransparency = 0
                    TextLabel.TextScaled = true
                    TextLabel.Font = Enum.Font.SourceSansBold
                    TextLabel.Parent = BillboardGui

                    table.insert(labelObjects, {
                        gui = BillboardGui,
                        part = basePart,
                    })
                end
            end
        end

        local function createHighlight(model)
            if not model:FindFirstChildOfClass('Highlight') then
                local Highlight = Instance.new('Highlight')
                Highlight.Name = 'SupplyCrateHighlight'
                Highlight.Adornee = model
                Highlight.FillColor = Color3.fromRGB(0, 255, 255)
                Highlight.OutlineColor = Color3.fromRGB(0, 0, 0)
                Highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                Highlight.Parent = model
            end
        end

        local function applyESP(model)
            createHighlight(model)
            createLabel(model)
        end

        local function scanExisting()
            for _, SupplyCrateModel in ipairs(game:GetDescendants()) do
                if SupplyCrateModel:IsA('Model') then
                    local nameLower = SupplyCrateModel.Name:lower()
                    if string.find(nameLower, 'supplycrate') then
                        applyESP(SupplyCrateModel)
                    end
                end
            end
        end

        local descendantConn = game.DescendantAdded:Connect(function(descendant)
            if descendant:IsA('Model') then
                local nameLower = descendant.Name:lower()
                if string.find(nameLower, 'supplycrate') then
                    task.wait(0.1)
                    applyESP(descendant)
                end
            end
        end)

        local renderConn = RunService.RenderStepped:Connect(function()
            local Character = LocalPlayer.Character
            local HumanoidRootPart = Character and Character:FindFirstChild('HumanoidRootPart')
            if HumanoidRootPart then
                for i = #labelObjects, 1, -1 do
                    local entry = labelObjects[i]
                    if entry.part and entry.gui then
                        local distance = (HumanoidRootPart.Position - entry.part.Position).Magnitude
                        if distance > maxDistance then
                            entry.gui.Size = UDim2.new(0, 0, 0, 0)
                        else
                            local scale = math.clamp(1 - distance / maxDistance, minScale, 1)
                            entry.gui.Size = UDim2.new(0, labelSize.X * scale, 0, labelSize.Y * scale)
                        end
                    else
                        table.remove(labelObjects, i)
                    end
                end
            end
        end)

        local function cleanup()
            if descendantConn then
                descendantConn:Disconnect()
                descendantConn = nil
            end
            if renderConn then
                renderConn:Disconnect()
                renderConn = nil
            end

            for _, entry in ipairs(labelObjects) do
                if entry.gui and entry.gui.Parent then
                    entry.gui:Destroy()
                end
                if entry.part and entry.part.Parent then
                    local highlight = entry.part.Parent:FindFirstChildOfClass('Highlight')
                    if highlight and highlight.Name == 'SupplyCrateHighlight' then
                        highlight:Destroy()
                    end
                end
            end

            labelObjects = {}
        end

        _G.SupplyCrateESPCleanup = cleanup
    elseif _G.SupplyCrateESPCleanup then
        _G.SupplyCrateESPCleanup()
        _G.SupplyCrateESPCleanup = nil
        print('Supply Crate ESP disabled.')
    end
end)

ESPSection:NewToggle('Rake ESP', 'ToggleInfo', function(state)
    local Players = game:GetService('Players')
    local LocalPlayer = Players.LocalPlayer

    local function createRakeESP(rakeModel)
        if rakeModel and not rakeModel:FindFirstChild('RakeESP') then
            local Highlight = Instance.new('Highlight')
            Highlight.Name = 'RakeESP'
            Highlight.OutlineColor = Color3.fromRGB(255, 0, 0)
            Highlight.FillColor = Color3.fromRGB(255, 100, 100)
            Highlight.FillTransparency = 0.7
            Highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
            Highlight.Adornee = rakeModel
            Highlight.Parent = rakeModel
        end
    end

    local function removeRakeESP()
        local Rake = workspace:FindFirstChild('Rake')
        if Rake then
            local esp = Rake:FindFirstChild('RakeESP')
            if esp then
                esp:Destroy()
            end
            local distanceLabel = Rake:FindFirstChild('RakeDistance')
            if distanceLabel then
                distanceLabel:Destroy()
            end
        end
        if _G.RakeESPConn then
            _G.RakeESPConn:Disconnect()
            _G.RakeESPConn = nil
        end
    end

    if _G.RakeESPWorkspaceConn then
        _G.RakeESPWorkspaceConn:Disconnect()
    end

    if state then
        local function checkRake()
            local Rake = workspace:FindFirstChild('Rake')
            if Rake and not Rake:FindFirstChild('RakeESP') then
                createRakeESP(Rake)
            end
        end

        checkRake()

        _G.RakeESPWorkspaceConn = workspace.ChildAdded:Connect(function(child)
            if child.Name == 'Rake' then
                task.wait(0.2)
                checkRake()
            end
        end)
    else
        removeRakeESP()
        if _G.RakeESPWorkspaceConn then
            _G.RakeESPWorkspaceConn:Disconnect()
            _G.RakeESPWorkspaceConn = nil
        end
    end
end)

ESPSection:NewToggle('Player ESP', 'ToggleInfo', function(state)
    local Players = game:GetService('Players')
    local RunService = game:GetService('RunService')
    local LocalPlayer = Players.LocalPlayer
    local maxDistance = 800
    local labelSize = Vector2.new(80, 20)
    local minScale = 0.375
    local outlineColor = Color3.fromRGB(0, 255, 0)
    local labelObjects = {}
    local highlightObjects = {}
    local connections = {}

    local function createPlayerESP(character, player)
        if character and player and player ~= LocalPlayer then
            local Head = character:FindFirstChild('Head')
            if Head then
                if not Head:FindFirstChild('PlayerESPLabel') then
                    local BillboardGui = Instance.new('BillboardGui')
                    BillboardGui.Name = 'PlayerESPLabel'
                    BillboardGui.Size = UDim2.new(0, labelSize.X, 0, labelSize.Y)
                    BillboardGui.StudsOffset = Vector3.new(0, 3, 0)
                    BillboardGui.Adornee = Head
                    BillboardGui.AlwaysOnTop = true
                    BillboardGui.MaxDistance = maxDistance
                    BillboardGui.Parent = Head

                    local TextLabel = Instance.new('TextLabel')
                    TextLabel.Size = UDim2.new(1, 0, 1, 0)
                    TextLabel.BackgroundTransparency = 1
                    TextLabel.Text = player.Name
                    TextLabel.TextColor3 = Color3.new(1, 1, 1)
                    TextLabel.TextStrokeColor3 = Color3.new(0, 0, 0)
                    TextLabel.TextStrokeTransparency = 0
                    TextLabel.TextScaled = true
                    TextLabel.Font = Enum.Font.SourceSansBold
                    TextLabel.Parent = BillboardGui

                    table.insert(labelObjects, {
                        gui = BillboardGui,
                        part = Head,
                    })
                end

                if not character:FindFirstChild('PlayerESPHighlight') then
                    local Highlight = Instance.new('Highlight')
                    Highlight.Name = 'PlayerESPHighlight'
                    Highlight.Adornee = character
                    Highlight.FillTransparency = 1
                    Highlight.OutlineTransparency = 0
                    Highlight.OutlineColor = outlineColor
                    Highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                    Highlight.Parent = character

                    table.insert(highlightObjects, Highlight)
                end
            end
        end
    end

    local function setupPlayer(player)
        if player ~= LocalPlayer then
            if player.Character then
                createPlayerESP(player.Character, player)
            end

            table.insert(connections, player.CharacterAdded:Connect(function(character)
                if character:WaitForChild('Head', 3) then
                    createPlayerESP(character, player)
                end
            end))
        end
    end

    if state then
        for _, player in ipairs(Players:GetPlayers()) do
            setupPlayer(player)
        end

        table.insert(connections, Players.PlayerAdded:Connect(setupPlayer))
        table.insert(connections, Players.PlayerRemoving:Connect(function(player)
            if player.Character then
                local Character = player.Character
                local highlight = Character:FindFirstChild('PlayerESPHighlight')
                if highlight then
                    highlight:Destroy()
                end

                local Head = Character:FindFirstChild('Head')
                local label = Head and Head:FindFirstChild('PlayerESPLabel')
                if label then
                    label:Destroy()
                end
            end
        end))

        RunService.RenderStepped:Connect(function()
            local Character = LocalPlayer.Character
            local HumanoidRootPart = Character and Character:FindFirstChild('HumanoidRootPart')
            if HumanoidRootPart then
                for _, entry in ipairs(labelObjects) do
                    if entry.part and entry.gui then
                        local distance = (HumanoidRootPart.Position - entry.part.Position).Magnitude
                        if distance > maxDistance then
                            entry.gui.Size = UDim2.new(0, 0, 0, 0)
                        else
                            local scale = math.clamp(1 - distance / maxDistance, minScale, 1)
                            entry.gui.Size = UDim2.new(0, labelSize.X * scale, 0, labelSize.Y * scale)
                        end
                    end
                end
            end
        end)
    else
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character then
                local Character = player.Character
                local highlight = Character:FindFirstChild('PlayerESPHighlight')
                if highlight then
                    highlight:Destroy()
                end

                local Head = Character:FindFirstChild('Head')
                if Head then
                    local label = Head:FindFirstChild('PlayerESPLabel')
                    if label then
                        label:Destroy()
                    end
                end
            end
        end

        for _, conn in ipairs(connections) do
            if conn then
                conn:Disconnect()
            end
        end

        connections = {}

        print('Player ESP disabled.')
    end
end)

local KeybindsTab = MainGui:NewTab('Keybinds')
local KeybindsSection = KeybindsTab:NewSection('Keybinds')

KeybindsSection:NewKeybind('Toggle UI', 'KeybindInfo', Enum.KeyCode.Q, function()
    KavoLib:ToggleUI()
end)

local RiskySection = KeybindsTab:NewSection('Risky Remotes')
local safehouseDoorCooldown = false

RiskySection:NewKeybind('Toggle SafeHouse Door (Anywhere)(glitchy)', 'Opens/Closes Safehouse door from any distance', Enum.KeyCode.F, function()
    if safehouseDoorCooldown then
        return
    else
        safehouseDoorCooldown = true

        local Character = game.Players.LocalPlayer.Character
        if Character then
            Character = Character:FindFirstChild('HumanoidRootPart')
        end
        if Character then
            local originalCFrame = Character.CFrame

            Character.CFrame = CFrame.new(-365.13, 15.72, 65.05)

            task.wait(0.25)
            workspace.Map.SafeHouse.Door.RemoteEvent:FireServer('Door')
            task.wait(0.15)

            Character.CFrame = originalCFrame

            task.wait(2.5)

            safehouseDoorCooldown = false
        else
            safehouseDoorCooldown = false
        end
    end
end)

local safehouseLightCooldown = false

RiskySection:NewKeybind('Toggle SafeHouse Light (Anywhere)(glitchy)', 'Toggle safehouse light from any distance', Enum.KeyCode.G, function()
    if safehouseLightCooldown then
        return
    else
        safehouseLightCooldown = true

        local Character = game.Players.LocalPlayer.Character
        if Character then
            Character = Character:FindFirstChild('HumanoidRootPart')
        end
        if Character then
            local originalCFrame = Character.CFrame

            Character.CFrame = CFrame.new(-371.1, 15.68, 57.85)

            task.wait(0.25)
            workspace.Map.SafeHouse.Door.RemoteEvent:FireServer('Light')
            task.wait(0.15)

            Character.CFrame = originalCFrame

            task.wait(2.5)

            safehouseLightCooldown = false
        else
            safehouseLightCooldown = false
        end
    end
end)

local towerLightCooldown = false

RiskySection:NewKeybind('Toggle Tower Light (Anywhere)(glitchy)', 'Toggle tower light from any distance', Enum.KeyCode.L, function()
    if towerLightCooldown then
        return
    else
        towerLightCooldown = true

        local Character = game.Players.LocalPlayer.Character
        if Character then
            Character = Character:FindFirstChild('HumanoidRootPart')
        end
        if Character then
            local originalCFrame = Character.CFrame

            Character.CFrame = CFrame.new(42.63, 57.82, -50.22)

            task.wait(0.25)
            workspace.Map.ObservationTower.Lights.RemoteEvent:FireServer('Light')
            task.wait(0.15)

            Character.CFrame = originalCFrame

            task.wait(2.5)

            towerLightCooldown = false
        else
            towerLightCooldown = false
        end
    end
end)

local SafeSection = KeybindsTab:NewSection('Safe Remotes')

SafeSection:NewKeybind('Toggle SafeHouse Door (Close distance)(Safe)', 'Fires the SafeHouse Door remote without teleporting', Enum.KeyCode.X, function()
    workspace.Map.SafeHouse.Door.RemoteEvent:FireServer('Door')
end)

SafeSection:NewKeybind('Toggle SafeHouse Light (Close distance)(Safe)', 'Fires the SafeHouse Light remote without teleporting', Enum.KeyCode.C, function()
    workspace.Map.SafeHouse.Door.RemoteEvent:FireServer('Light')
end)

SafeSection:NewKeybind('Toggle Tower Light (Close distance)(Safe)', 'Fires the Tower Light remote without teleporting', Enum.KeyCode.V, function()
    workspace.Map.ObservationTower.Lights.RemoteEvent:FireServer('Light')
end)

local LocationsTab = MainGui:NewTab('Show Locations')
local LocationsSection = LocationsTab:NewSection('Show Locations')

LocationsSection:NewToggle('Show SafeHouse', 'ToggleInfo', function(state)
    local MapFolder = workspace:FindFirstChild('Map')
    local SafeHouseModel = MapFolder and MapFolder:FindFirstChild('SafeHouse')
    if SafeHouseModel then
        local targetPart = SafeHouseModel:FindFirstChildWhichIsA('BasePart') or SafeHouseModel:FindFirstChild('Door') or SafeHouseModel:FindFirstChild('Main') or SafeHouseModel:FindFirstChildOfClass('Part')
        if targetPart then
            if state then
                if not targetPart:FindFirstChild('SafeHouseLabel') then
                    local BillboardGui = Instance.new('BillboardGui')
                    BillboardGui.Name = 'SafeHouseLabel'
                    BillboardGui.Size = UDim2.new(0, 120, 0, 40)
                    BillboardGui.StudsOffset = Vector3.new(0, 30, 0)
                    BillboardGui.Adornee = targetPart
                    BillboardGui.AlwaysOnTop = true
                    BillboardGui.Parent = targetPart

                    local TextLabel = Instance.new('TextLabel')
                    TextLabel.Size = UDim2.new(1, 0, 1, 0)
                    TextLabel.BackgroundTransparency = 0.3
                    TextLabel.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
                    TextLabel.Text = 'SafeHouse'
                    TextLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
                    TextLabel.TextStrokeColor3 = Color3.new(0, 0, 0)
                    TextLabel.TextStrokeTransparency = 0
                    TextLabel.TextScaled = true
                    TextLabel.Font = Enum.Font.SourceSansBold
                    TextLabel.Parent = BillboardGui

                    local UICorner = Instance.new('UICorner')
                    UICorner.CornerRadius = UDim.new(0, 12)
                    UICorner.Parent = TextLabel
                end
            else
                local label = targetPart:FindFirstChild('SafeHouseLabel')
                if label then
                    label:Destroy()
                end
            end
        end
    end
end)

LocationsSection:NewToggle('Show Observation Tower', 'ToggleInfo', function(state)
    local MapFolder = workspace:FindFirstChild('Map')
    local ObservationTowerModel = MapFolder and MapFolder:FindFirstChild('ObservationTower')
    if ObservationTowerModel then
        local targetPart = ObservationTowerModel:FindFirstChildWhichIsA('BasePart') or ObservationTowerModel:FindFirstChild('Main') or ObservationTowerModel:FindFirstChildOfClass('Part')
        if targetPart then
            if state then
                if not targetPart:FindFirstChild('ObservationTowerLabel') then
                    local BillboardGui = Instance.new('BillboardGui')
                    BillboardGui.Name = 'ObservationTowerLabel'
                    BillboardGui.Size = UDim2.new(0, 120, 0, 40)
                    BillboardGui.StudsOffset = Vector3.new(0, 50, 0)
                    BillboardGui.Adornee = targetPart
                    BillboardGui.AlwaysOnTop = true
                    BillboardGui.Parent = targetPart

                    local TextLabel = Instance.new('TextLabel')
                    TextLabel.Size = UDim2.new(1, 0, 1, 0)
                    TextLabel.BackgroundTransparency = 0.3
                    TextLabel.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
                    TextLabel.Text = 'Tower'
                    TextLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
                    TextLabel.TextStrokeColor3 = Color3.new(0, 0, 0)
                    TextLabel.TextStrokeTransparency = 0
                    TextLabel.TextScaled = true
                    TextLabel.Font = Enum.Font.SourceSansBold
                    TextLabel.Parent = BillboardGui

                    local UICorner = Instance.new('UICorner')
                    UICorner.CornerRadius = UDim.new(0, 12)
                    UICorner.Parent = TextLabel
                end
            else
                local label = targetPart:FindFirstChild('ObservationTowerLabel')
                if label then
                    label:Destroy()
                end
            end
        end
    end
end)

LocationsSection:NewToggle('Show Shop', 'ToggleInfo', function(state)
    local MapFolder = workspace:FindFirstChild('Map')
    local ShackModel = MapFolder and MapFolder:FindFirstChild('Shack')
    if ShackModel then
        local targetPart = ShackModel:FindFirstChildWhichIsA('BasePart') or ShackModel:FindFirstChild('Main') or ShackModel:FindFirstChildOfClass('Part')
        if targetPart then
            if state then
                if not targetPart:FindFirstChild('ShackLabel') then
                    local BillboardGui = Instance.new('BillboardGui')
                    BillboardGui.Name = 'ShackLabel'
                    BillboardGui.Size = UDim2.new(0, 120, 0, 40)
                    BillboardGui.StudsOffset = Vector3.new(0, 20, 0)
                    BillboardGui.Adornee = targetPart
                    BillboardGui.AlwaysOnTop = true
                    BillboardGui.Parent = targetPart

                    local TextLabel = Instance.new('TextLabel')
                    TextLabel.Size = UDim2.new(1, 0, 1, 0)
                    TextLabel.BackgroundTransparency = 0.3
                    TextLabel.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
                    TextLabel.Text = 'Shop'
                    TextLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
                    TextLabel.TextStrokeColor3 = Color3.new(0, 0, 0)
                    TextLabel.TextStrokeTransparency = 0
                    TextLabel.TextScaled = true
                    TextLabel.Font = Enum.Font.SourceSansBold
                    TextLabel.Parent = BillboardGui

                    local UICorner = Instance.new('UICorner')
                    UICorner.CornerRadius = UDim.new(0, 12)
                    UICorner.Parent = TextLabel
                end
            else
                local label = targetPart:FindFirstChild('ShackLabel')
                if label then
                    label:Destroy()
                end
            end
        end
    end
end)

LocationsSection:NewToggle('Show BaseCamp', 'ToggleInfo', function(state)
    local MapFolder = workspace:FindFirstChild('Map')
    local BaseCampModel = MapFolder and MapFolder:FindFirstChild('BaseCamp')
    if BaseCampModel then
        local targetPart = BaseCampModel:FindFirstChildWhichIsA('BasePart') or BaseCampModel:FindFirstChild('Main') or BaseCampModel:FindFirstChildOfClass('Part')
        if targetPart then
            if state then
                if not targetPart:FindFirstChild('BaseCampLabel') then
                    local BillboardGui = Instance.new('BillboardGui')
                    BillboardGui.Name = 'BaseCampLabel'
                    BillboardGui.Size = UDim2.new(0, 120, 0, 40)
                    BillboardGui.StudsOffset = Vector3.new(0, 30, 0)
                    BillboardGui.Adornee = targetPart
                    BillboardGui.AlwaysOnTop = true
                    BillboardGui.Parent = targetPart

                    local TextLabel = Instance.new('TextLabel')
                    TextLabel.Size = UDim2.new(1, 0, 1, 0)
                    TextLabel.BackgroundTransparency = 0.3
                    TextLabel.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
                    TextLabel.Text = 'BaseCamp'
                    TextLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
                    TextLabel.TextStrokeColor3 = Color3.new(0, 0, 0)
                    TextLabel.TextStrokeTransparency = 0
                    TextLabel.TextScaled = true
                    TextLabel.Font = Enum.Font.SourceSansBold
                    TextLabel.Parent = BillboardGui

                    local UICorner = Instance.new('UICorner')
                    UICorner.CornerRadius = UDim.new(0, 12)
                    UICorner.Parent = TextLabel
                end
            else
                local label = targetPart:FindFirstChild('BaseCampLabel')
                if label then
                    label:Destroy()
                end
            end
        end
    end
end)

LocationsSection:NewToggle('Show Power Station', 'ToggleInfo', function(state)
    local position = Vector3.new(-281.82, 20, -211.18)
    local labelName = 'PowerLocationLabel'
    local markerPart = workspace:FindFirstChild(labelName)

    if not markerPart then
        markerPart = Instance.new('Part')
        markerPart.Name = labelName
        markerPart.Anchored = true
        markerPart.CanCollide = false
        markerPart.Size = Vector3.new(2, 2, 2)
        markerPart.Position = position
        markerPart.Transparency = 1
        markerPart.Parent = workspace
    end

    if state then
        if not markerPart:FindFirstChild('PowerLocationBillboard') then
            local BillboardGui = Instance.new('BillboardGui')
            BillboardGui.Name = 'PowerLocationBillboard'
            BillboardGui.Size = UDim2.new(0, 120, 0, 40)
            BillboardGui.StudsOffset = Vector3.new(0, 30, 0)
            BillboardGui.Adornee = markerPart
            BillboardGui.AlwaysOnTop = true
            BillboardGui.Parent = markerPart

            local TextLabel = Instance.new('TextLabel')
            TextLabel.Size = UDim2.new(1, 0, 1, 0)
            TextLabel.BackgroundTransparency = 0.3
            TextLabel.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
            TextLabel.Text = 'Power'
            TextLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
            TextLabel.TextStrokeColor3 = Color3.new(0, 0, 0)
            TextLabel.TextStrokeTransparency = 0
            TextLabel.TextScaled = true
            TextLabel.Font = Enum.Font.SourceSansBold
            TextLabel.Parent = BillboardGui

            local UICorner = Instance.new('UICorner')
            UICorner.CornerRadius = UDim.new(0, 12)
            UICorner.Parent = TextLabel
        end
    else
        local billboard = markerPart:FindFirstChild('PowerLocationBillboard')
        if billboard then
            billboard:Destroy()
        end
    end
end)

LocationsSection:NewToggle('Show Cave', 'ToggleInfo', function(state)
    local labelName = 'CaveLocationLabel'
    local position = Vector3.new(-149.67, 26.13, 36.42)
    local markerPart = workspace:FindFirstChild(labelName)

    if markerPart then
        markerPart.Position = position
    else
        markerPart = Instance.new('Part')
        markerPart.Name = labelName
        markerPart.Anchored = true
        markerPart.CanCollide = false
        markerPart.Size = Vector3.new(2, 2, 2)
        markerPart.Position = position
        markerPart.Transparency = 1
        markerPart.Parent = workspace
    end

    if state then
        if not markerPart:FindFirstChild('CaveBillboard') then
            local BillboardGui = Instance.new('BillboardGui')
            BillboardGui.Name = 'CaveBillboard'
            BillboardGui.Size = UDim2.new(0, 120, 0, 40)
            BillboardGui.StudsOffset = Vector3.new(0, 30, 0)
            BillboardGui.Adornee = markerPart
            BillboardGui.AlwaysOnTop = true
            BillboardGui.Parent = markerPart

            local TextLabel = Instance.new('TextLabel')
            TextLabel.Size = UDim2.new(1, 0, 1, 0)
            TextLabel.BackgroundTransparency = 0.3
            TextLabel.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
            TextLabel.Text = 'Cave'
            TextLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
            TextLabel.TextStrokeColor3 = Color3.new(0, 0, 0)
            TextLabel.TextStrokeTransparency = 0
            TextLabel.TextScaled = true
            TextLabel.Font = Enum.Font.SourceSansBold
            TextLabel.Parent = BillboardGui

            local UICorner = Instance.new('UICorner')
            UICorner.CornerRadius = UDim.new(0, 12)
            UICorner.Parent = TextLabel
        end
    else
        local billboard = markerPart:FindFirstChild('CaveBillboard')
        if billboard then
            billboard:Destroy()
        end
    end
end)
