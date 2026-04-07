local manifest = {}

local function normalizeProfileName(profileName)
	local normalized = string.lower(tostring(profileName or ""))
	normalized = normalized:gsub("[%s%p_]+", "")
	return normalized
end

local bundledGuiStateFiles = {
	["2619619496"] = {
		file = "bedwars.gui.txt",
		aliases = {"2619619496.gui.txt"}
	}
}

local bundledProfileFiles = {
	["default:6872265039"] = {
		file = "default-bedwars-lobby.txt",
		aliases = {"default6872265039.txt"}
	},
	["default:6872274481"] = {
		file = "default-bedwars-game.txt",
		aliases = {"default6872274481.txt"}
	},
	["closetcheat:6872265039"] = {
		file = "closet-cheat-bedwars-lobby.txt",
		aliases = {"ClosetCheat6872265039.txt"}
	},
	["closetcheat:6872274481"] = {
		file = "closet-cheat-bedwars-game.txt",
		aliases = {"ClosetCheat6872274481.txt"}
	}
}

local function getProfileKey(profileName, placeId)
	return normalizeProfileName(profileName)..":"..tostring(placeId or "")
end

function manifest.resolveCanonicalGuiStateFile(gameId)
	local entry = bundledGuiStateFiles[tostring(gameId or "")]
	return entry and entry.file or (tostring(gameId or "")..".gui.txt")
end

function manifest.resolveExistingGuiStateFile(gameId, fileExists)
	local entry = bundledGuiStateFiles[tostring(gameId or "")]
	local canonical = manifest.resolveCanonicalGuiStateFile(gameId)
	if fileExists and fileExists(canonical) then
		return canonical
	end
	if entry then
		for _, alias in ipairs(entry.aliases) do
			if not fileExists or fileExists(alias) then
				return alias
			end
		end
	end
	return canonical
end

function manifest.resolveCanonicalProfileFile(profileName, placeId)
	local entry = bundledProfileFiles[getProfileKey(profileName, placeId)]
	return entry and entry.file or (tostring(profileName or "default")..tostring(placeId or "")..".txt")
end

function manifest.resolveExistingProfileFile(profileName, placeId, fileExists)
	local entry = bundledProfileFiles[getProfileKey(profileName, placeId)]
	local canonical = manifest.resolveCanonicalProfileFile(profileName, placeId)
	if fileExists and fileExists(canonical) then
		return canonical
	end
	if entry then
		for _, alias in ipairs(entry.aliases) do
			if not fileExists or fileExists(alias) then
				return alias
			end
		end
	end
	return canonical
end

function manifest.getProfileFileAliases(profileName, placeId)
	local aliases = {manifest.resolveCanonicalProfileFile(profileName, placeId)}
	local entry = bundledProfileFiles[getProfileKey(profileName, placeId)]
	if entry then
		for _, alias in ipairs(entry.aliases) do
			table.insert(aliases, alias)
		end
	end
	return aliases
end

return manifest
