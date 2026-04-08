--[[
    pealzware Loader
    Simplified single-entry loader -- replaces the original 8-step chain.
    All files are loaded from: github.com/1AreYouMental110/pealzware
]]

repeat task.wait() until game:IsLoaded()

local REPO_BASE = "https://raw.githubusercontent.com/1AreYouMental110/pealzware/main/"

-- Polyfills for executor compatibility
local isfile = isfile or function(file)
    local suc, res = pcall(function() return readfile(file) end)
    return suc and res ~= nil and res ~= ''
end
local delfile = delfile or function(file) writefile(file, '') end
if not getgenv then getgenv = function() return shared end end
if not getgenv().shared then getgenv().shared = {} end
if not getgenv().debug then getgenv().debug = {traceback = function(s) return s end} end

-- Folder setup
for _, folder in ipairs({
    'pealzware', 'pealzware/profiles', 'pealzware/assets',
    'pealzware/libraries', 'pealzware/Libraries'
}) do
    if not isfolder(folder) then makefolder(folder) end
end

pcall(function()
    if not isfile('pealzware/profiles/gui.txt') then
        writefile('pealzware/profiles/gui.txt', 'new')
    end
end)

-- Executor capability detection (CheatEngineMode)
local CheatEngineMode = false
if (not getgenv) or (getgenv and type(getgenv) ~= "function") then CheatEngineMode = true end
if getgenv and not getgenv().require then CheatEngineMode = true end
if getgenv and getgenv().require and type(getgenv().require) ~= "function" then CheatEngineMode = true end

local debugChecks = {
    Type = "table",
    Functions = {"getupvalue", "getupvalues", "getconstants", "getproto"}
}
local function checkDebug()
    if CheatEngineMode then return end
    if not getgenv().debug then
        CheatEngineMode = true
    elseif type(debug) ~= debugChecks.Type then
        CheatEngineMode = true
    else
        for _, v in pairs(debugChecks.Functions) do
            if not debug[v] or type(debug[v]) ~= "function" then
                CheatEngineMode = true
            else
                local suc, res = pcall(debug[v])
                if tostring(res) == "Not Implemented" then CheatEngineMode = true end
            end
        end
    end
end
pcall(checkDebug)

-- Executor-specific patches
pcall(function()
    if identifyexecutor and type(identifyexecutor) == "function" then
        local suc, res = pcall(identifyexecutor)
        if suc then
            local name = string.lower(tostring(res))
            local blacklist = {"solara", "cryptic", "xeno", "ember", "ronix"}
            for _, v in pairs(blacklist) do
                if name:find(v) then CheatEngineMode = true end
            end
            if name:find("solara") or name:find("xeno") then
                pcall(function()
                    getgenv().queue_on_teleport = function() warn("queue_on_teleport disabled!") end
                end)
            end
            if name:find("delta") then
                getgenv().isnetworkowner = function() return true end
            end
        end
    end
end)

if shared.ForceDisableCE then CheatEngineMode = false end
shared.CheatEngineMode = shared.CheatEngineMode or CheatEngineMode

-- getcustomasset restoration
shared.oldgetcustomasset = shared.oldgetcustomasset or getcustomasset
task.spawn(function()
    repeat task.wait() until shared.VapeFullyLoaded
    getgenv().getcustomasset = shared.oldgetcustomasset
end)

shared.VapeDeveloper = shared.VapeDeveloper or shared.PealzDev

-- Profile installation
local baseDirectory = "pealzware/"
local function installProfiles()
    local profileApiUrl = "https://api.github.com/repos/1AreYouMental110/pealzware/contents/profiles?ref=main"
    local profileRawBaseUrl = "https://raw.githubusercontent.com/1AreYouMental110/pealzware/main/profiles/"
    local profilesfetched = false
    local guiprofiles = {}
    task.spawn(function()
        local suc, res = pcall(function()
            return game:HttpGet(profileApiUrl, true)
        end)
        if suc and res ~= '404: Not Found' then
            for _, v in next, game:GetService("HttpService"):JSONDecode(res) do
                if type(v) == 'table' and v.name and v.type == "file" and v.name:match("%.txt$") then
                    table.insert(guiprofiles, v.name)
                end
            end
        end
        profilesfetched = true
    end)
    repeat task.wait() until profilesfetched
    if not isfolder(baseDirectory..'profiles') then makefolder(baseDirectory..'profiles') end
    for _, name in pairs(guiprofiles) do
        pcall(function()
            local data = game:HttpGet(profileRawBaseUrl..name, true)
            writefile(baseDirectory..'profiles/'..name, data)
        end)
        task.wait()
    end
    if not isfolder(baseDirectory..'libraries') then makefolder(baseDirectory..'libraries') end
    writefile(baseDirectory..'libraries/profilesinstalled5.txt', "true")
end
if not isfile(baseDirectory..'libraries/profilesinstalled5.txt') then
    pcall(installProfiles)
end

-- Core file loader -- fetches from pealzware repo
local function vapeGithubRequest(scripturl, isImportant)
    if isfile(baseDirectory..scripturl) then
        if shared.PealzDev then
            return readfile(baseDirectory..scripturl)
        else
            pcall(function() delfile(baseDirectory..scripturl) end)
        end
    end
    local suc, res = pcall(function()
        return game:HttpGet(REPO_BASE..scripturl, true)
    end)
    if not suc or res == "404: Not Found" then
        if isImportant then
            game:GetService('StarterGui'):SetCore('SendNotification', {
                Title = 'pealzware | Loading Failed',
                Text = "Failed to load: "..tostring(scripturl).."\n"..tostring(res),
                Duration = 15,
            })
        end
        warn("[pealzware] Failed to load: "..baseDirectory..scripturl, res)
    end
    if scripturl:find(".lua") then
        res = "--This watermark is used to delete the file if its cached, remove it to make the file persist after commits.\n"..res
    end
    return res
end

local function pload(fileName, isImportant, required)
    fileName = tostring(fileName)
    if string.find(fileName, "CustomModules") and string.find(fileName, "Pealzware") then
        fileName = string.gsub(fileName, "Pealzware", "PW")
    end
    if shared.PealzDev and shared.DebugMode then warn(fileName, isImportant, required, debug.traceback(fileName)) end
    local res = vapeGithubRequest(fileName, isImportant)
    local a = loadstring(res)
    local suc, err = true, ""
    if type(a) ~= "function" then
        suc = false
        err = tostring(a)
    else
        if required then return a() else a() end
    end
    if not suc then
        if isImportant then
            if not string.find(string.lower(err), "already injected") then
                warn("[pealzware] Critical load failure: "..baseDirectory..tostring(fileName)..": "..tostring(debug.traceback(err)))
            end
        else
            task.spawn(function()
                repeat task.wait() until errorNotification
                if not string.find(res, "404: Not Found") then
                    errorNotification('Failed to load: '..baseDirectory..tostring(fileName), tostring(debug.traceback(err)), 30, 'alert')
                end
            end)
        end
    end
end
shared.pload = pload
getgenv().pload = pload

-- Load the main script
return pload('main.lua', true)
