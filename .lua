-- Script para Delta Executor - Saber Showdown
-- Funcionalidades: Kill Aura, Anti Slap, Farm de Points
-- Otimizado para mobile e GitHub

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

-- Configurações iniciais
local Settings = {
    KillAura = {
        Enabled = false,
        Range = 25,
        Damage = 10,
        Cooldown = 0.5
    },
    AntiSlap = {
        Enabled = false,
        AutoParry = true
    },
    FarmPoints = {
        Enabled = false,
        AutoCollect = true,
        AutoSell = false
    }
}

-- Interface gráfica
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/xHeptc/Kavo-UI-Library/main/source.lua"))()
local Window = Library.CreateLib("Saber Showdown v1.0", "DarkTheme")

-- Main Tab
local MainTab = Window:NewTab("Principal")
local MainSection = MainTab:NewSection("Controles Principais")

MainSection:NewToggle("Kill Aura", "Ataca inimigos automaticamente", function(state)
    Settings.KillAura.Enabled = state
end)

MainSection:NewSlider("Alcance Kill Aura", "Distância de ataque", 50, 5, function(value)
    Settings.KillAura.Range = value
end)

MainSection:NewToggle("Anti Slap", "Proteção contra tapas", function(state)
    Settings.AntiSlap.Enabled = state
end)

MainSection:NewToggle("Farm Points", "Coleta automática de pontos", function(state)
    Settings.FarmPoints.Enabled = state
end)

-- Configurações Tab
local ConfigTab = Window:NewTab("Configurações")
local ConfigSection = ConfigTab:NewSection("Ajustes")

ConfigSection:NewSlider("Dano Kill Aura", "Dano por ataque", 50, 1, function(value)
    Settings.KillAura.Damage = value
end)

ConfigSection:NewSlider("Cooldown", "Tempo entre ataques", 2, 0.1, function(value)
    Settings.KillAura.Cooldown = value
end)

ConfigSection:NewToggle("Auto Parry", "Para ataques automaticamente", function(state)
    Settings.AntiSlap.AutoParry = state
end)

ConfigSection:NewToggle("Auto Coletar", "Coleta pontos automaticamente", function(state)
    Settings.FarmPoints.AutoCollect = state
end)

ConfigSection:NewToggle("Auto Vender", "Vende itens automaticamente", function(state)
    Settings.FarmPoints.AutoSell = state
end)

-- Info Tab
local InfoTab = Window:NewTab("Informações")
local InfoSection = InfoTab:NewSection("Status do Script")

InfoSection:NewLabel("Script carregado com sucesso!")
InfoSection:NewLabel("Versão: 1.0")
InfoSection:NewLabel("Delta Executor Compatível")

-- Função para encontrar inimigos próximos
local function findNearestEnemy()
    local closest = nil
    local closestDistance = Settings.KillAura.Range
    
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local distance = (LocalPlayer.Character.HumanoidRootPart.Position - player.Character.HumanoidRootPart.Position).Magnitude
            if distance < closestDistance then
                closest = player
                closestDistance = distance
            end
        end
    end
    
    return closest
end

-- Função de Kill Aura
local lastAttack = 0
local function killAura()
    if not Settings.KillAura.Enabled or not LocalPlayer.Character then return end
    if tick() - lastAttack < Settings.KillAura.Cooldown then return end
    
    local enemy = findNearestEnemy()
    if enemy and enemy.Character then
        local humanoid = enemy.Character:FindFirstChild("Humanoid")
        if humanoid then
            humanoid:TakeDamage(Settings.KillAura.Damage)
            lastAttack = tick()
        end
    end
end

-- Função Anti Slap
local function antiSlap()
    if not Settings.AntiSlap.Enabled then return end
    
    if Settings.AntiSlap.AutoParry then
        -- Lógica para parry automático
        for _, tool in ipairs(LocalPlayer.Backpack:GetChildren()) do
            if tool:IsA("Tool") and tool.Name:lower():find("saber") then
                LocalPlayer.Character.Humanoid:EquipTool(tool)
                -- Simular ação de parry
                break
            end
        end
    end
end

-- Função Farm Points
local function farmPoints()
    if not Settings.FarmPoints.Enabled then return end
    
    if Settings.FarmPoints.AutoCollect then
        -- Procurar por pontos no mapa
        local points = workspace:FindFirstChild("Points") or workspace:FindFirstChild("Coins")
        if points then
            for _, point in ipairs(points:GetChildren()) do
                if point:IsA("Part") and (LocalPlayer.Character.HumanoidRootPart.Position - point.Position).Magnitude < 20 then
                    firetouchinterest(LocalPlayer.Character.HumanoidRootPart, point, 0)
                    firetouchinterest(LocalPlayer.Character.HumanoidRootPart, point, 1)
                end
            end
        end
    end
end

-- Conexões principais
local connections = {}

connections.killAura = RunService.Heartbeat:Connect(killAura)
connections.antiSlap = RunService.Heartbeat:Connect(antiSlap)
connections.farmPoints = RunService.Heartbeat:Connect(farmPoints)

-- Função para limpar conexões
local function cleanup()
    for _, connection in pairs(connections) do
        connection:Disconnect()
    end
end

-- UI para mobile
local function createMobileUI()
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "MobileControls"
    screenGui.Parent = game:GetService("CoreGui")
    
    -- Botão de toggle para Kill Aura
    local killAuraBtn = Instance.new("TextButton")
    killAuraBtn.Size = UDim2.new(0, 100, 0, 50)
    killAuraBtn.Position = UDim2.new(0, 10, 0.8, 0)
    killAuraBtn.Text = "Kill Aura: OFF"
    killAuraBtn.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
    killAuraBtn.Parent = screenGui
    
    killAuraBtn.MouseButton1Click:Connect(function()
        Settings.KillAura.Enabled = not Settings.KillAura.Enabled
        killAuraBtn.Text = "Kill Aura: " .. (Settings.KillAura.Enabled and "ON" or "OFF")
        killAuraBtn.BackgroundColor3 = Settings.KillAura.Enabled and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)
    end)
end

-- Detectar se é mobile
if UserInputService.TouchEnabled then
    createMobileUI()
end

-- Notificação de carregamento
Library:Notify("Script carregado!", "Saber Showdown v1.0 ativo")

-- Cleanup quando o script for desativado
game:GetService("UserInputService").WindowFocused:Connect(function()
    cleanup()
end)
