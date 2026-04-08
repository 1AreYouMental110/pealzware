repeat task.wait() until game:IsLoaded()
if shared.vape then shared.vape:Uninject(); shared.VapeExecuted = false end

if identifyexecutor and ({identifyexecutor()})[1] == 'Argon' then
	getgenv().setthreadidentity = nil
end

shared.OLD_SETTHREADIDENTITY = shared.OLD_SETTHREADIDENTITY or getgenv().setthreadidentity or function() end
getgenv().setthreadidentity = function(...)
	local args = {...}
	local suc, err = pcall(function()
		return shared.OLD_SETTHREADIDENTITY(unpack(args))
	end)
	if not suc and shared.PealzDev then
		warn(`SETTHREADIDENTITY ERROR: {tostring(err)}`)
	end
	return suc and err
end
getgenv().run = function(func)
	local suc, err = pcall(function() func() end)
	if (not suc) then
		warn('Error in module! Error log: '..debug.traceback(tostring(err)))
	end
end

local vape
local baseLoadstring = loadstring
local loadstring = function(...)
	local res, err = baseLoadstring(...)
	if err and vape then
		vape:CreateNotification('Pealzware', 'Failed to load : '..err, 30, 'alert')
	end
	return res
end
if hookfunction == nil then getgenv().hookfunction = function() end end
local queue_on_teleport = queue_on_teleport or function() end
local isfile = isfile or function(file)
	local suc, res = pcall(function()
		return readfile(file)
	end)
	return suc and res ~= nil and res ~= ''
end
getgenv().cloneref = function(obj) return obj end
local cloneref = cloneref or function(obj)
	return obj
end
local playersService = cloneref(game:GetService('Players'))

local savingTable = {
	"TeleportExploitAutowinEnabled",
	"NoPealzwareModules",
	"VapeCustomProfile",
	"ProfilesDisabled",
	"CheatEngineMode",
	"ClosetCheatMode",
	"NoAutoExecute",
	"VapeDeveloper",
	"CustomCommit",
	"TestingMode",
	"VapePrivate",
	"PealzDev"
}

local oldtbl = {}
local function finishLoading()
	vape.Init = nil
	vape:Load()
	task.spawn(function()
		repeat
			shared.VapeFullyLoaded = vape.Loaded
			vape:Save()
			task.wait(10)
		until not vape.Loaded
	end)

	local teleportedServers
	vape:Clean(playersService.LocalPlayer.OnTeleport:Connect(function()
		if (not teleportedServers) and (not shared.VapeIndependent) then
			teleportedServers = true
			local teleportScript = [[
				repeat task.wait() until game:IsLoaded()
				if getgenv and not getgenv().shared then shared.CheatEngineMode = true; getgenv().shared = {}; end
				shared.VapeSwitchServers = true
				shared.vapereload = true
				if shared.VapeDeveloper or shared.PealzDev then
					if isfile('pealzware/loader.lua') then
						loadstring(readfile("pealzware/loader.lua"))()
					else
						loadstring(game:HttpGet("https://raw.githubusercontent.com/1AreYouMental110/pealzware/main/loader.lua", true))()
					end
				else
					loadstring(game:HttpGet("https://raw.githubusercontent.com/1AreYouMental110/pealzware/main/loader.lua", true))()
				end
			]]
			for _, v in pairs(savingTable) do
				if shared[v] ~= nil then
					teleportScript = 'shared.'..tostring(v).." = "..tostring(shared[v]).."\n"..teleportScript
				end
			end
			if shared.PealzDev then
				teleportScript = 'shared.PealzDev = true\n'..teleportScript
			end
			vape:Save()
			queue_on_teleport(teleportScript)
		end
	end))

	if not shared.vapereload then
		if not vape.Categories then return end
		if vape.Categories.Main.Options['GUI bind indicator'].Enabled then
			vape:CreateNotification('Finished Loading', vape.VapeButton and 'Press the button in the top right to open GUI' or 'Press '..table.concat(vape.Keybind, ' + '):upper()..' to open GUI', 5)
		end
	end
end

if not isfile('pealzware/profiles/gui.txt') then
	writefile('pealzware/profiles/gui.txt', 'new')
end
local manifest = pload('core/manifest.lua', true, true)
local gui = manifest.normalizeGuiValue(readfile('pealzware/profiles/gui.txt'))

pcall(function()
	if readfile('pealzware/profiles/gui.txt') ~= gui then
		writefile('pealzware/profiles/gui.txt', gui)
	end
end)

if not isfolder('pealzware/assets/'..gui) then
	makefolder('pealzware/assets/'..gui)
end

local PWFunctions = pload('core/functions.lua', true, true)
--pload('core/functions.lua', true, true)
PWFunctions.GlobaliseObject("PealzwareFunctions", PWFunctions)
PWFunctions.GlobaliseObject("PWFunctions", PWFunctions)

local guiFile = manifest.resolveGuiFile(gui)
vape = pload('gui/'..guiFile, true, true)
shared.vape = vape
getgenv().vape = vape
getgenv().GuiLibrary = vape
shared.GuiLibrary = vape
shared.VapeExecuted = true

getgenv().InfoNotification = function(title, msg, dur)
	--warn('info', tostring(title), tostring(msg), tostring(dur))
	vape:CreateNotification(title, msg, dur)
end
getgenv().warningNotification = function(title, msg, dur)
	--warn('warn', tostring(title), tostring(msg), tostring(dur))
	vape:CreateNotification(title, msg, dur, 'warning')
end
getgenv().errorNotification = function(title, msg, dur)
	--warn("error", tostring(title), tostring(msg), tostring(dur))
	vape:CreateNotification(title, msg, dur, 'alert')
end
if shared.CheatEngineMode then
	InfoNotification("Pealzware | CheatEngineMode", "Due to your executor not supporting some functions \n some modules might be missing!", 5)
end
local bedwarsID = {
	game = {6872274481, 8444591321, 8560631822},
	lobby = {6872265039}
}
if not shared.VapeIndependent then
	local isGame = table.find(bedwarsID.game, game.PlaceId)
	local isLobby = table.find(bedwarsID.lobby, game.PlaceId)
	if not isGame and not isLobby then
		vape:CreateNotification('Pealzware', 'This build only includes BedWars.', 10, 'alert')
		finishLoading()
		return
	end
	if isGame then
		if game.PlaceId ~= 6872274481 then vape.Place = 6872274481 end
	end
	pload('modules/bedwars-main.lua')
	finishLoading()
else
	vape.Init = finishLoading
	return vape
end
