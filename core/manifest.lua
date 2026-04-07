local manifest = {}

local guiValueAliases = {
	[""] = "new",
	new = "new",
	modern = "new",
	old = "new",
	classic = "new",
	rise = "new",
	wurst = "new"
}

local guiFiles = {
	new = "modern.lua"
}

local moduleDefinitions = {
	{
		file = "bedwars-main.lua",
		aliases = {
			"6872274481.lua",
			"8444591321.lua",
			"8560631822.lua",
			"CE6872274481.lua",
			"PW6872274481.lua",
			"6872265039.lua",
			"CE6872265039.lua",
			"PW6872265039.lua",
			"bedwars-game-core.lua",
			"bedwars-game-cheat-engine.lua",
			"bedwars-game-pealzware.lua",
			"bedwars-lobby-core.lua",
			"bedwars-lobby-cheat-engine-stub.lua",
			"bedwars-lobby-pealzware.lua",
			"bedwars-shared-core.lua",
			"bedwars-shared-pealzware.lua"
		}
	}
}

local moduleAliases = {}
local canonicalModuleFiles = {}

for _, definition in ipairs(moduleDefinitions) do
	canonicalModuleFiles[definition.file] = true
	for _, alias in ipairs(definition.aliases) do
		moduleAliases[alias] = definition.file
	end
end

function manifest.normalizeGuiValue(guiValue)
	local normalized = string.lower(tostring(guiValue or ""))
	return guiValueAliases[normalized] or guiValueAliases[""]
end

function manifest.resolveGuiFile(guiValue)
	local normalized = manifest.normalizeGuiValue(guiValue)
	return guiFiles[normalized] or guiFiles.new
end

function manifest.resolveModuleFile(fileName)
	local normalized = tostring(fileName or "")
	return moduleAliases[normalized] or normalized
end

function manifest.resolveOptionalModuleFile(fileName)
	local resolved = manifest.resolveModuleFile(fileName)
	return canonicalModuleFiles[resolved] and resolved or nil
end

function manifest.getModuleDefinitions()
	return moduleDefinitions
end

return manifest
