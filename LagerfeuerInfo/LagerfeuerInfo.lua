-- LagerfeuerInfo
-- German tooltips for WoW Forever camp objects (campfires and profession camp features):
-- what each object gives, at your level (Shift: all level ranges), what it does not stack with
-- and which profession places it.
-- CozyFire does the same but only matches the English object names, so on a German client its
-- tooltips never appear. Here the German names come from the client itself: the name of the spell
-- that places each object (C_Spell.GetSpellName), plus names seen in the game cache. Values are
-- taken from CozyFire 0.8.3 (unchanged in 0.8.6). Tier-1 German object names are from the
-- game object cache (Cache\WDB\deDE).
-- Tooltip lines are only added while you have the "Campfire Nearby" aura, so ordinary anvils,
-- chairs etc. in towns are left alone. Hovered objects near a fire that are not recognised are
-- remembered (/lagerfeuer zeigt sie), so missing names can be added.

local ADDON = ...

local CAMPFIRE_NEARBY_SPELL = 1283391

-- name = German name (if known), spell = spell that places the object
local PROFESSIONS = {
	{
		name = "Alchemie",
		objects = {
			{ tier = 1, spell = 1230564, names = { "Manaquell" } },                    -- Mana Well
			{ tier = 2, spell = 1263005, perk = "Nötig für bestimmte Reagenzien", skill = 140 }, -- Fermenter
			{ tier = 3, spell = 1263078, perk = "Nötig für bestimmte Rezepte", skill = 300 },    -- Alchemy Laboratory
		},
		buff = {
			{ 1, "+10 Mana alle 5 Sek." }, { 24, "+15 Mana alle 5 Sek." }, { 34, "+20 Mana alle 5 Sek." },
			{ 44, "+24 Mana alle 5 Sek." }, { 54, "+29 Mana alle 5 Sek." },
		},
		exclusive = "Segen der Weisheit",
	},
	{
		name = "Schmiedekunst",
		objects = {
			{ tier = 1, spell = 1230171, names = { "Schleifstein" } },                 -- Sharpening Wheel
			{ tier = 2, spell = 1263041, names = { "Amboss" }, perk = "Nötig für bestimmte Pläne", skill = 140 }, -- Anvil
			{ tier = 3, spell = 1263073, perk = "Nötig für bestimmte Pläne", skill = 300 }, -- Master Forge
		},
		buff = { { 1, "+6 Stärke" }, { 24, "+11 Stärke" }, { 38, "+20 Stärke" }, { 52, "+34 Stärke" } },
		exclusive = "Totem der Erdstärke",
	},
	{
		name = "Kochkunst",
		objects = {
			{ tier = 1, spell = 818, names = { "Einfaches Lagerfeuer" }, perk = "Zum Kochen, bis zu 3 Lagerobjekte" },
			{ tier = 2, spell = 1283400, perk = "Zum Kochen, bis zu 5 Lagerobjekte", skill = 140 },
			{ tier = 3, spell = 1291341, perk = "Zum Kochen, bis zu 10 Lagerobjekte", skill = 220 },
			{ spell = 1262978, perk = "Essen, das Ausdauer gibt", skill = 140, nobuff = true }, -- Cookie's Feast
			{ tier = 3, spell = 1263067, perk = "Nötig für bestimmte Rezepte", skill = 300, nobuff = true }, -- Iron Oven
			-- Welcoming Campfire (fixed fires in towns/camps): no profession, but the buff summary is useful there too
			{ spell = 1229739, campfire = true, town = true, nobuff = true },
			{ spell = 1289723, campfire = true, town = true, nobuff = true },
		},
	},
	{
		name = "Verzauberkunst",
		objects = {
			{ tier = 1, spell = 1230643, names = { "Verzauberte Laute" } },          -- Enchanted Lute
			{ tier = 2, spell = 1263056, perk = "Entzaubern lohnt sich mehr", skill = 140 }, -- Arcane Salvager
			{ tier = 3, spell = 1263082, perk = "Nötig für bestimmte Formeln", skill = 300 }, -- Arcane Forge
		},
		buff = {
			{ 1, "+28 Rüstung" },
			{ 10, "+71 Rüstung, +2 alle Werte" },
			{ 20, "+114 Rüstung, +4 alle Werte" },
			{ 30, "+163 Rüstung, +7 alle Werte, +6 alle Widerstände" },
			{ 40, "+211 Rüstung, +9 alle Werte, +12 alle Widerstände" },
			{ 50, "+260 Rüstung, +12 alle Werte, +16 alle Widerstände" },
			{ 60, "+308 Rüstung, +13 alle Werte, +22 alle Widerstände" },
		},
		exclusive = "Mal der Wildnis",
	},
	{
		name = "Ingenieurskunst",
		objects = {
			{ tier = 1, spell = 1230656, perk = "Reagenzien kaufen" },                  -- Reagent Bot
			{ tier = 2, spell = 1263034, perk = "Reagenzien kaufen, verkaufen, reparieren", skill = 140 }, -- Repair Bot
			{ tier = 3, spell = 1263083, perk = "Nötig für bestimmte Baupläne", skill = 300 }, -- Anarchist's Workbench
		},
	},
	{
		name = "Erste Hilfe",
		objects = {
			{ tier = 1, spell = 1230117, names = { "Erste-Hilfe-Kasten" } },           -- First Aid Kit
			{ tier = 2, spell = 1262996, perk = "Enthält Heiltränke und Gegengift", skill = 140 }, -- Toxin Study
			{ tier = 3, spell = 1263001, perk = "Enthält Heiltränke und Umschläge", skill = 300 },  -- Plague Doctor's Laboratory
		},
		buff = {
			{ 1, "+3 Ausdauer" }, { 12, "+8 Ausdauer" }, { 24, "+21 Ausdauer" },
			{ 36, "+34 Ausdauer" }, { 48, "+45 Ausdauer" }, { 60, "+56 Ausdauer" },
		},
		exclusive = "Machtwort: Seelenstärke",
	},
	{
		name = "Angeln",
		objects = {
			{ tier = 1, spell = 1229745, names = { "Fischglas" } },                  -- Fish Bowl
			{ tier = 2, spell = 1262990, perk = "1 Stunde lang ungewöhnliche Fische fangen\nEnthält Köder", skill = 140 }, -- Fishing Rack
			{ tier = 3, spell = 1262998, perk = "1 Stunde lang seltene Fische fangen\nEnthält Köder", skill = 300 },        -- Fishing Hut
		},
		buff = "+8% alle Werte",
		exclusive = "Segen der Könige",
	},
	{
		name = "Kräuterkunde",
		objects = {
			{ tier = 1, spell = 1229705, names = { "Räucherkerze" } },               -- Incense Candle
			{ tier = 2, spell = 1262980, perk = "Samen pflanzen und Kräuter ernten", skill = 140 }, -- Greenhouse
			{ tier = 3, spell = 1263070, perk = "Samen vermehren oder kombinieren", skill = 300 },  -- Seed Hybridizer
		},
		buff = { { 1, "+2 Intelligenz" }, { 14, "+6 Intelligenz" }, { 28, "+12 Intelligenz" }, { 42, "+18 Intelligenz" }, { 56, "+25 Intelligenz" } },
		exclusive = "Arkane Intelligenz",
	},
	{
		name = "Lederverarbeitung",
		objects = {
			{ tier = 1, spell = 1229432, names = { "Lagerzelt" } },                  -- Camp Tent
			{ tier = 2, spell = 1263031, perk = "Nötig für bestimmte Reagenzien", skill = 140 }, -- Tanning Rack
			{ tier = 3, spell = 1263079, perk = "Nötig für bestimmte Muster", skill = 300 },     -- Sewing Machine
		},
		buff = "Erholungs-EP (bis zu 5% einer Stufe, nur wenn du keine mehr hast)",
	},
	{
		name = "Bergbau",
		objects = {
			{ tier = 1, spell = 1230161, names = { "Leitstein" } },                    -- Lodestone
			{ tier = 2, spell = 1262975, perk = "Lässt ein einfaches Erzvorkommen entstehen", skill = 140 }, -- Rock Garden
			{ tier = 3, spell = 1263071, perk = "Nötig für bestimmte Verhüttungsrezepte", skill = 300 },     -- Molten Foundry
		},
		buff = {
			{ 1, "+12 Nahkampfangriffskraft" }, { 12, "+20 Nahkampfangriffskraft" }, { 22, "+32 Nahkampfangriffskraft" },
			{ 32, "+49 Nahkampfangriffskraft" }, { 42, "+67 Nahkampfangriffskraft" }, { 52, "+90 Nahkampfangriffskraft" },
		},
		exclusive = "Segen der Macht",
	},
	{
		name = "Kürschnerei",
		objects = {
			{ tier = 1, spell = 1229517, names = { "Stuhl" } },                       -- Camp Chair (placed as "Chair")
			{ tier = 2, spell = 1262985, perk = "Gibt Wildtiere aufspüren", skill = 140 }, -- Field Guide
			{ tier = 3, spell = 1262982, perk = "Enthält 1 Falle", skill = 300 },         -- Trapper's Workbench
		},
		buff = "+2% kritische Trefferchance",
		exclusive = "Mondkinaura / Rudelführer",
	},
	{
		name = "Schneiderei",
		objects = {
			{ tier = 1, spell = 1263425, names = { "Fraktionsbanner" } },            -- Faction Banner
			{ tier = 2, spell = 1263032, perk = "Nötig für bestimmte Reagenzien", skill = 140 }, -- Spinning Wheel
			{ tier = 3, spell = 1263080, perk = "Nötig für bestimmte Muster", skill = 300 },     -- Loom
		},
		buff = { { 1, "+14 Willenskraft" }, { 40, "+19 Willenskraft" }, { 50, "+27 Willenskraft" }, { 60, "+32 Willenskraft" } },
		exclusive = "Göttlicher Willen",
	},
}

local db
local exact      -- lowercase name -> object
local fromSpell  -- { lowercase spell name, object } for partial matching

local function IsSecret(v)
	return issecretvalue and issecretvalue(v) or false
end

local function Build()
	exact, fromSpell = {}, {}
	for _, prof in ipairs(PROFESSIONS) do
		for _, obj in ipairs(prof.objects) do
			obj.profession = prof.name
			obj.campfire = obj.campfire or (obj.perk and obj.perk:find("^Zum Kochen") and true) or nil
			if not obj.nobuff then
				obj.buff = obj.buff or prof.buff
				obj.exclusive = obj.exclusive or prof.exclusive
			end
			for _, n in ipairs(obj.names or {}) do exact[n:lower()] = obj end
			local sname = C_Spell and C_Spell.GetSpellName and C_Spell.GetSpellName(obj.spell)
			if sname and not IsSecret(sname) and sname ~= "" then
				obj.spellName = sname
				exact[sname:lower()] = exact[sname:lower()] or obj
				table.insert(fromSpell, { sname:lower(), obj })
			end
		end
	end
end

local Find

-- Drop names from the "not recognised" list that are known by now (added in a later version).
local function CleanUnknown()
	if not (db and db.unknown) then return end
	if not exact then Build() end
	for n in pairs(db.unknown) do
		if Find(n) then db.unknown[n] = nil end
	end
end

function Find(name)
	local key = name:lower()
	if exact[key] then return exact[key] end
	if #key < 5 then return nil end
	-- "Campingstuhl" (spell) vs "Stuhl" (object), "… aufstellen" etc.
	for _, e in ipairs(fromSpell) do
		local s = e[1]
		if s:find(key, 1, true) or (#s >= 5 and key:find(s, 1, true)) then return e[2] end
	end
end

-- true/false, or nil if unknown (in combat aura data is a secret value and must not be compared)
local function NearCampfire()
	if InCombatLockdown() then return nil end
	local ok, near = pcall(function()
		return C_UnitAuras.GetPlayerAuraBySpellID(CAMPFIRE_NEARBY_SPELL) ~= nil
	end)
	if not ok then return nil end
	return near
end

local function BuffLines(buff, all)
	if type(buff) == "string" then return { { buff, true } } end
	local level = UnitLevel("player") or 1
	local cur = 1
	for i, e in ipairs(buff) do
		if level >= e[1] then cur = i end
	end
	if not all then return { { buff[cur][2], true } } end
	local lines = {}
	for i, e in ipairs(buff) do
		local nextE = buff[i + 1]
		local maxL = nextE and nextE[1] - 1 or 60
		local range = (maxL ~= e[1]) and (e[1] .. "-" .. maxL) or tostring(e[1])
		lines[i] = { e[2] .. " (Stufe " .. range .. ")", i == cur }
	end
	return lines
end

local hasScaling = false

-- Objects hovered at the current campfire (profession -> object). The game offers no way to list
-- the objects around a fire, so only hovered ones are known. Cleared when you leave the fire.
local seen = {}

local function HasAura(name)
	if not (AuraUtil and AuraUtil.FindAuraByName) then return false end
	local ok, found = pcall(AuraUtil.FindAuraByName, name, "player", "HELPFUL")
	return ok and found ~= nil
end

-- Calls add(text, r, g, b) for every line of the "buffs at this fire" summary.
local function Summary(add)
	local profs = {}
	for prof in pairs(seen) do table.insert(profs, prof) end
	table.sort(profs)
	local any = false
	for _, prof in ipairs(profs) do
		local obj = seen[prof]
		if obj.buff then
			any = true
			local text = BuffLines(obj.buff)[1][1]
			local blocked
			for part in (obj.exclusive or ""):gmatch("[^/]+") do
				part = part:match("^%s*(.-)%s*$")
				if part ~= "" and HasAura(part) then blocked = part end
			end
			if blocked then
				add("  " .. text .. "  (nicht, du hast " .. blocked .. ")", 0.6, 0.6, 0.6)
			else
				add("  " .. text .. "  |cff999999" .. obj.profession .. "|r", 0.25, 1, 0.25)
			end
		end
	end
	if not any then
		add("  noch keine - fahr mit der Maus über die Objekte am Feuer", 0.6, 0.6, 0.6)
	else
		add("  (nur Objekte, über die du gefahren bist)", 0.5, 0.5, 0.5)
	end
end

-- Posting the fire's buffs to the group -----------------------------------------------------------

local PREFIX = "|cffff8000Lagerfeuer:|r "
local campfireHover = false     -- GameTooltip currently shows a campfire
local lastClick, lastPost = 0, 0

local function GroupChannel()
	if IsInGroup(LE_PARTY_CATEGORY_INSTANCE) then return "INSTANCE_CHAT" end
	if IsInRaid() then return "RAID" end
	if IsInGroup() then return "PARTY" end
end

local function PostBuffs()
	local profs = {}
	for prof in pairs(seen) do table.insert(profs, prof) end
	table.sort(profs)
	local parts = {}
	for _, prof in ipairs(profs) do
		local obj = seen[prof]
		if obj.buff then
			local text = BuffLines(obj.buff)[1][1]
			if obj.exclusive then text = text .. " (nicht mit " .. obj.exclusive .. ")" end
			table.insert(parts, text)
		end
	end
	if #parts == 0 then
		print(PREFIX .. "Noch keine Buffs bekannt. Fahr erst mit der Maus über die Objekte am Feuer.")
		return
	end

	local channel = GroupChannel()
	local header = "[Lagerfeuer] Buffs an diesem Feuer:"
	local lines, cur = { header }, ""
	for _, p in ipairs(parts) do
		local add = (cur == "") and p or (cur .. ", " .. p)
		if #add > 240 then
			table.insert(lines, cur)
			cur = p
		else
			cur = add
		end
	end
	table.insert(lines, cur)

	if not channel then
		print(PREFIX .. "Du bist in keiner Gruppe. Das würde gepostet:")
		for _, l in ipairs(lines) do print("  " .. l) end
		return
	end
	local send = (C_ChatInfo and C_ChatInfo.SendChatMessage) or SendChatMessage
	for _, l in ipairs(lines) do pcall(send, l, channel) end
end

-- Double left-click on the campfire in the world (tooltip of the fire is showing).
local clickFrame = CreateFrame("Frame")
clickFrame:RegisterEvent("GLOBAL_MOUSE_DOWN")
clickFrame:SetScript("OnEvent", function(_, _, button)
	if button ~= "LeftButton" or not campfireHover or not GameTooltip:IsShown() then return end
	local foci = GetMouseFoci and GetMouseFoci()
	local focus = foci and foci[1] or (GetMouseFocus and GetMouseFocus())
	if focus and focus ~= WorldFrame then return end
	local now = GetTime()
	if now - lastClick < 0.4 then
		lastClick = 0
		if now - lastPost < 10 then return end -- no spam
		lastPost = now
		PostBuffs()
	else
		lastClick = now
	end
end)

local function OnTooltip(tooltip, data)
	if tooltip == GameTooltip then hasScaling = false; campfireHover = false end
	if not db or not db.enabled then return end
	local line = data and data.lines and data.lines[1]
	local name = line and line.leftText
	if not name or IsSecret(name) or name == "" then return end
	local near = NearCampfire()
	if near == false then return end
	if not exact then Build() end

	local obj = Find(name)
	if not obj then
		if near and data.type == Enum.TooltipDataType.Object then
			db.unknown = db.unknown or {}
			db.unknown[name] = true
		end
		return
	end
	if obj.buff then seen[obj.profession] = obj end
	if obj.campfire and tooltip == GameTooltip then campfireHover = true end

	if obj.perk then tooltip:AddLine(obj.perk, 0.4, 0.65, 0.95, true) end
	if obj.buff then
		if tooltip == GameTooltip and type(obj.buff) == "table" then hasScaling = true end
		tooltip:AddLine(" ")
		for _, l in ipairs(BuffLines(obj.buff, IsShiftKeyDown())) do
			if l[2] then
				tooltip:AddLine(l[1], 0.25, 1, 0.25, true)
			else
				tooltip:AddLine(l[1], 0.65, 0.65, 0.65, true)
			end
		end
		if obj.exclusive then
			tooltip:AddLine("|cffff8080Nicht zusammen mit: |r" .. obj.exclusive, 1, 1, 1, true)
		end
		if hasScaling and not IsShiftKeyDown() then
			tooltip:AddLine("Shift: alle Stufen", 0.5, 0.5, 0.5)
		end
	end
	if not obj.town then
		tooltip:AddLine(" ")
		local prof = obj.profession .. (obj.skill and (" (" .. obj.skill .. ")") or "")
		if obj.tier then prof = prof .. " - Stufe " .. obj.tier end
		tooltip:AddLine(prof, 0.5, 0.5, 0.5, true)
	end

	if obj.campfire then
		tooltip:AddLine(" ")
		tooltip:AddLine("Buffs an diesem Feuer (1 Min. sitzen):", 1, 0.82, 0)
		Summary(function(text, r, g, b) tooltip:AddLine(text, r, g, b) end)
		tooltip:AddLine("Doppelklick: Buffs in die Gruppe posten", 0.5, 0.5, 0.5)
	end
end

-- Forget the fire's objects once you are away from it (aura reading works out of combat only).
C_Timer.NewTicker(3, function()
	if next(seen) and NearCampfire() == false then wipe(seen) end
end)

local f = CreateFrame("Frame")
f:RegisterEvent("ADDON_LOADED")
f:RegisterEvent("MODIFIER_STATE_CHANGED")
f:SetScript("OnEvent", function(_, event, arg1)
	if event == "ADDON_LOADED" then
		if arg1 ~= ADDON then return end
		LagerfeuerInfoDB = LagerfeuerInfoDB or {}
		db = LagerfeuerInfoDB
		if db.enabled == nil then db.enabled = true end
		-- v2: the old list was full of signposts, town fires and chairs; start fresh once.
		if (db.unknownVersion or 1) < 2 then db.unknown = nil; db.unknownVersion = 2 end
		CleanUnknown()
		TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.Object, OnTooltip)
		TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.Unit, OnTooltip)
	elseif event == "MODIFIER_STATE_CHANGED" then
		if (arg1 == "LSHIFT" or arg1 == "RSHIFT") and hasScaling and GameTooltip:IsShown() then
			GameTooltip:RefreshData()
		end
	end
end)

SLASH_LAGERFEUERINFO1 = "/lagerfeuer"
SlashCmdList.LAGERFEUERINFO = function(input)
	local cmd = (input or ""):lower():match("^%s*(%S*)")
	if cmd == "aus" or cmd == "an" then
		db.enabled = (cmd == "an")
		print(PREFIX .. "Tooltips " .. (db.enabled and "an." or "aus."))
		return
	elseif cmd == "buffs" then
		print(PREFIX .. "Buffs an diesem Feuer:")
		Summary(function(text, r, g, b)
			print(string.format("|cff%02x%02x%02x%s|r", r * 255, g * 255, b * 255, text))
		end)
		return
	elseif cmd == "posten" then
		PostBuffs()
		return
	end
	Build()
	CleanUnknown()
	print(PREFIX .. "Tooltips " .. (db.enabled and "an" or "aus") .. " (/lagerfeuer an | aus | buffs | posten). Bekannte Namen:")
	for _, prof in ipairs(PROFESSIONS) do
		local names = {}
		for _, obj in ipairs(prof.objects) do
			table.insert(names, obj.spellName or ("Zauber " .. obj.spell))
		end
		print("  " .. prof.name .. ": " .. table.concat(names, ", "))
	end
	local unknown = {}
	for n in pairs(db.unknown or {}) do table.insert(unknown, n) end
	if #unknown > 0 then
		table.sort(unknown)
		print(PREFIX .. "Am Lagerfeuer gesehen, aber nicht erkannt: " .. table.concat(unknown, ", "))
	end
end
