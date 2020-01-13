local ReplicatedStorage = game:GetService("ReplicatedStorage")

local CosmeticsDictionary = require(ReplicatedStorage.Core.CosmeticsDictionary)
local FontsDictionary = require(ReplicatedStorage.Core.FontsDictionary)
local SpraysDictionary = require(ReplicatedStorage.Core.SpraysDictionary)
local TitlesDictionary = require(ReplicatedStorage.Core.TitlesDictionary)

local function level(freeLoot, paidLoot, gamesNeeded)
	if freeLoot == nil then
		freeLoot = {}
	elseif freeLoot.Type ~= nil then
		freeLoot = { freeLoot }
	end

	if paidLoot.Type ~= nil then
		paidLoot = { paidLoot }
	end

	return {
		FreeLoot = freeLoot,
		GamesNeeded = gamesNeeded,
		PaidLoot = paidLoot,
	}
end

local function search(dictionary, name)
	local selected, selectedIndex

	for index, thing in ipairs(dictionary) do
		if thing.Name == name then
			selected = thing
			selectedIndex = index
			break
		end
	end

	return assert(selected, name .. " cannot be found"), selectedIndex
end

local function searchable(type, dictionary)
	return function(name)
		local item, itemIndex = search(dictionary, name)

		return {
			Type = type,
			[type] = item,
			Index = itemIndex,
		}
	end
end

local emote = searchable("Emote", SpraysDictionary)
local font = searchable("Font", FontsDictionary)
local skin = searchable("Skin", CosmeticsDictionary)

local function brains(brains)
	return {
		Type = "Brains",
		Brains = brains,
	}
end

local function title(name)
	return {
		Type = "Title",
		Title = name,
		Index = assert(table.find(TitlesDictionary, name)),
	}
end

local function xp(xp)
	return {
		Type = "XP",
		XP = xp,
	}
end

local ZombiePassDictionary = {
	level(
		emote("Smile"),
		{
			brains(100),
			skin("Photographer"),
			skin("Biker"),
			emote("Treasure"),
		},
		1
	),

	level(nil, title("The Wise"), 2),
	level(brains(20), skin("The Noble"), 2),
	level(nil, xp(15), 3),
	level(skin("Sleepy"), title("The Fragger"), 3),
	level(nil, brains(100), 4),
	level(xp(10), emote("Winner"), 4),
	level(nil, skin("Athlete"), 4),
	level(emote("Meh"), title("The Pro"), 5),
	level(nil, skin("Red Lights"), 5),
	level(title("The Gamer"), brains(100), 5),
	level(nil, skin("The Leader"), 5),
	level(brains(40), title("The Unstoppable"), 5),
	level(nil, brains(100), 5),
	level(title("The Cool"), emote("Cute"), 5),
	level(nil, xp(10), 6),
	level(brains(45), title("The Elite"), 7),
	level(nil, brains(100), 7),
	level(emote("Sad"), emote("Gun"), 8),
	level(nil, skin("The Comedian"), 8),
	level(emote("Heart"), emote("Gold"), 11),
	level(nil, font("Fantasy"), 11),
	level(brains(50), title("The Maniac"), 11),
	level(nil, skin("The Quirky"), 11),
	level(title("The Crook"), emote("Zombie"), 18),
}

return ZombiePassDictionary