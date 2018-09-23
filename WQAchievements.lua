WQAchievements = LibStub("AceAddon-3.0"):NewAddon("WQAchievements", "AceConsole-3.0", "AceTimer-3.0")
local WQA = WQAchievements
WQA.data = {}
WQA.watched = {}
WQA.questList = {}
WQA.links = {}

-- Blizzard
local IsActive = C_TaskQuest.IsActive

-- Locales
local locale = GetLocale()
WQA.L = {}
local L = WQA.L
L["NO_QUESTS"] = "No interesting World Quests active!"
L["WQChat"] = "Interesting World Quests are active:"
L["WQforAch"] = "%s for %s"
L["achievements"] = "Achievements"
L["mounts"] = "Mounts"
L["pets"] = "Pets"
L["toys"] = "Toys"
if locale == "deDE" then
	L["WQChat"] = "Interessante Weltquests verfügbar:"
	L["WQforAch"] = "%s für %s"
end

local newOrder
do
	local current = 0
	function newOrder()
		current = current + 1
		return current
	end
end

WQA.data.custom = {wqID = "", rewardID = "", rewardType = "none"}
--WQA.data.customReward = 0

function WQA:OnInitialize()
	-- Defaults
	local defaults = {
		char = {
			options = {
				chat = true,
				PopUp = false,
				zone = { ['*'] = true},
				reward = {
					gear = {
						AzeriteArmorCache = true,
						itemLevelUpgrade = true,
						itemLevelUpgradeMin = 1,
						PawnUpgrade = true,
						PawnUpgradeMin = 1,
						unknownAppearance = true,
						unknownSource = false,
					},
					reputation = { ['*'] = false},
					currency = {},
					craftingreagent = { ['*'] = false},
					['*'] = { ['*'] = true},		
				},
			},
			['*'] = { ['*'] = true}
		},
		global = {
			['*'] = { ['*'] = false}
		}
	}
	self.db = LibStub("AceDB-3.0"):New("WQADB", defaults)
	self:UpdateOptions()
end

function WQA:OnEnable()
	------------------
	-- 	Options
	------------------
	LibStub("AceConfig-3.0"):RegisterOptionsTable("WQAchievements", self.options)
	self.optionsFrame = LibStub("AceConfigDialog-3.0"):AddToBlizOptions("WQAchievements", "WQAchievements")

	self.event = CreateFrame("Frame")
	self.event:RegisterEvent("PLAYER_ENTERING_WORLD")
	self.event:SetScript("OnEvent", function (...)
		local _, name, id = ...
		if name == "PLAYER_ENTERING_WORLD" then
			self.event:UnregisterEvent("PLAYER_ENTERING_WORLD")
			self:ScheduleTimer("Show", 5)
			self:ScheduleTimer(function ()
				self:Show("new")
				self:ScheduleRepeatingTimer("Show",30*60,"new")
			end, (32-(date("%M") % 30))*60)
		end
		if name == "QUEST_LOG_UPDATE" or name == "GET_ITEM_INFO_RECEIVED" then
			self.event:UnregisterEvent("QUEST_LOG_UPDATE")
			self.event:UnregisterEvent("GET_ITEM_INFO_RECEIVED")
			self:CancelTimer(self.timer)
			if GetTime() - self.start > 1 then
				self:Reward()
			else
				self:ScheduleTimer("Reward", 1)
			end
		end
	end)
end

WQA:RegisterChatCommand("wqa", "slash")

function WQA:slash(input)
	local arg1 = string.lower(input)

	if arg1 == "" then
		self:Show()
		--self:CheckWQ()
	elseif arg1 == "new" then
		self:Show("new")
	elseif arg1 == "details" then
		self:checkWQ("details")
	end
end

------------------
-- 	Data
------------------
--	Legion
do
	local legion = {}
	local trainer = {42159, 40299, 40277, 42442, 40298, 40280, 40282, 41687, 40278, 41944, 41895, 40337, 41990, 40279, 41860}
	legion = {
		name = "Legion",
		achievements = {
			{name = "Free For All, More For Me", id = 11474, criteriaType = "ACHIEVEMENT", criteria = {
				{id = 11475, notAccountwide = true},
				{id = 11476, notAccountwide = true},
				{id = 11477, notAccountwide = true},
				{id = 11478, notAccountwide = true}}
			},
			{name = "Family Familiar", id = 9696, criteriaType = "ACHIEVEMENT", criteria = {
				{id = 9686, criteriaType = "QUESTS", criteria = trainer},
				{id = 9687, criteriaType = "QUESTS", criteria = trainer},
				{id = 9688, criteriaType = "QUESTS", criteria = trainer},
				{id = 9689, criteriaType = "QUESTS", criteria = trainer},
				{id = 9690, criteriaType = "QUESTS", criteria = trainer},
				{id = 9691, criteriaType = "QUESTS", criteria = trainer},
				{id = 9692, criteriaType = "QUESTS", criteria = trainer},
				{id = 9693, criteriaType = "QUESTS", criteria = trainer},
				{id = 9694, criteriaType = "QUESTS", criteria = trainer},
				{id = 9695, criteriaType = "QUESTS", criteria = trainer}}
			},
			{name = "Battle on the Broken Isles", id = 10876},
			{name = "Fishing \'Round the Isles", id = 10598, criteriaType = "QUESTS", criteria = {
				{41612, 41613, 41270},
				nil,
				{41604, 41605, 41279},
				{41598, 41599, 41264},
				nil,
				nil,
				{41611, 41265, 41610},
				{41617, 41280, 41616},
				{41597, 41244, 41596},
				{41602, 41274, 41603},
				{41609, 41243},
				nil,
				nil,
				{41615, 41275, 41614},
				nil,
				nil,
				nil,
				nil,
				{41269, 41600, 41601}},
			},
			{name = "Crate Expectations", id = 11681, criteriaType = "QUEST_SINGLE", criteria = 45542},
			{name = "They See Me Rolling", id = 11607, criteriaType = "QUEST_SINGLE", criteria = 46175}
		},
		mounts = {
			{name = "Maddened Chaosrunner", itemID = 152814, spellID = 253058, quest = {{trackingID = 48695, wqID = 48696}}},
			{name = "Crimson Slavermaw", itemID = 152905, spellID = 253661, quest = {{trackingID = 49183, wqID = 47561}}},
			{name = "Acid Belcher", itemID = 152904, spellID = 253662, quest = {{trackingID = 48721, wqID = 48740}}},
			{name = "Vile Fiend", itemID = 152790, spellID = 243652, quest = {{trackingID = 48821, wqID = 48835}}},
			{name = "Lambent Mana Ray", itemID = 152844, spellID = 253107, quest = {{trackingID = 48705, wqID = 48725}}},
			{name = "Biletooth Gnasher", itemID = 152903, spellID = 253660, quest = {{trackingID = 48810, wqID = 48465}, {trackingID = 48809, wqID = 48467}}},
			--Egg
			{name = "Vibrant Mana Ray", itemID = 152842, spellID = 253106, quest = {{trackingID = 48667, wqID = 48502}, {trackingID = 48712, wqID = 48732}, {trackingID = 48812, wqID = 48827}}},
			{name = "Felglow Mana Ray", itemID = 152841, spellID = 253108, quest = {{trackingID = 48667, wqID = 48502}, {trackingID = 48712, wqID = 48732}, {trackingID = 48812, wqID = 48827}}},
			{name = "Scintillating Mana Ray", itemID = 152840, spellID = 253109, quest = {{trackingID = 48667, wqID = 48502}, {trackingID = 48712, wqID = 48732}, {trackingID = 48812, wqID = 48827}}},
			{name = "Darkspore Mana Ray", itemID = 152843, spellID = 235764, quest = {{trackingID = 48667, wqID = 48502}, {trackingID = 48712, wqID = 48732}, {trackingID = 48812, wqID = 48827}}},
		},
		pets = {
			{name = "Grasping Manifestation", itemID = 153056, creatureID = 128159, quest = {{trackingID = 0, wqID = 48729}}},
			--Egg
			{name = "Fel-Afflicted Skyfin", itemID = 153055, creatureID = 128158, quest = {{trackingID = 48667, wqID = 48502}, {trackingID = 48712, wqID = 48732}, {trackingID = 48812, wqID = 48827}}},
			{name = "Docile Skyfin", itemID = 153054, creatureID = 128157, quest = {{trackingID = 48667, wqID = 48502}, {trackingID = 48712, wqID = 48732}, {trackingID = 48812, wqID = 48827}}}
		},
		toys = {
			{name = "Barrier Generator", itemID = 153183, quest = {{trackingID = 0, wqID = 48724}, {trackingID = 0, wqID = 48723}}},
			{name = "Micro-Artillery Controller", itemID = 153126, quest = {{trackingID = 0, wqID = 48829}}},
			{name = "Spire of Spite", itemID = 153124, quest = {{trackingID = 0, wqID = 48512}}},
			{name = "Yellow Conservatory Scroll", itemID = 153180, quest = {{trackingID = 48718, wqID = 48737}}},
			{name = "Red Conservatory Scroll", itemID = 153181, quest = {{trackingID = 48718, wqID = 48737}}},
			{name = "Blue Conservatory Scroll", itemID = 153179, quest = {{trackingID = 48718, wqID = 48737}}},
			{name = "Baarut the Brisk", itemID = 153193, quest = {{trackingID = 0, wqID = 48701}}},
		}
	}
	WQA.data[1] = legion
end
-- Battle for Azeroth
do
	local bfa = {}
	bfa = {
		name = "Battle for Azeroth",
		achievements = {
			{name = "Adept Sandfisher", id = 13009, criteriaType = "QUEST_SINGLE", criteria = 51173},
			{name = "Scourge of Zem'lan", id = 13011, criteriaType = "QUESTS", criteria = {{51763, 51783}}},
			{name = "Vorrik's Champion", id = 13014, criteriaType = "QUESTS", criteria = {51957, 51983}},
			{name = "Revenge is Best Served Speedily", id = 13022, criteriaType = "QUEST_SINGLE", criteria = 50786},
			{name = "It's Really Getting Out of Hand", id = 13023, criteriaType = "QUEST_SINGLE", criteria = 50559},
			{name = "Zandalari Spycatcher", id = 13025, criteriaType = "QUEST_SINGLE", criteria = 50717},
			{name = "7th Legion Spycatcher", id = 13026, criteriaType = "QUEST_SINGLE", criteria = 50899},
			{name = "By de Power of de Loa!", id = 13035, criteriaType = "QUEST_SINGLE", criteria = 51178},
			{name = "Bless the Rains Down in Freehold", id = 13050, criteriaType = "QUESTS", criteria = {{53196, 52159}}},
			{name = "Kul Runnings", id = 13060, criteriaType = "QUESTS", criteria = {49994, 53188, 53189}},	-- Frozen Freestyle
			{name = "Battle on Zandalar and Kul Tiras", id = 12936},
			{name = "A Most Efficient Apocalypse", id = 13021, criteriaType = "QUEST_SINGLE", criteria = 50665},
			-- Thanks NatalieWright
			{name = "Adventurer of Zuldazar", id = 12944, criteriaType = "QUESTS", criteria = {50864, 50877, {51085, 51087}, 51081, {50287, 51374, 50866}, 50885, 50863, 50862, 50861, 50859, 50845, 50857, nil, 50875, 50874, nil, 50872, 50876, 50871, 50870, 50869, 50868, 50867}},
			{name = "Adventurer of Vol'dun", id = 12943, criteriaType = "QUESTS", criteria = {51105, 51095, 51096, 51117, nil, 51118, 51120, 51098, 51121, 51099, 51108, 51100, 51125, 51102, 51429, 51103, 51124, 51107, 51122, 51123, 51104, 51116, 51106, 51119, 51112, 51113, 51114, 51115}},
			{name = "Adventurer of Nazmir", id = 12942, criteriaType = "QUESTS", criteria = {50488, 50570, 50564, nil, 50490, 50506, 50568, 50491, 50492, 50499, 50496, 50498, 50501, nil, 50502, 50503, 50505, 50507, 50566, 50511, 50512, nil, 50513, 50514, nil, 50515, 50516, 50489, 50519, 50518, 50509, 50517}},
			{name = "Adventurer of Drustvar", id = 12941, criteriaType = "QUESTS", criteria = {51469, 51505, 51506, 51508, 51468, 51972, nil, nil, nil, 51897, 51457, nil, 51909, 51507, 51917, nil, 51919, 51908, 51491, 51512, 51527, 51461, 51467, 51528, 51466, 51541, 51542, 51884, 51874, 51906, 51887, 51989, 51988}},
			{name = "Adventurer of Tiragarde Sound", id = 12939, criteriaType = "QUESTS", criteria = {51653, 51652, 51666, 51669, 51841, 51665, 51848, 51842, 51654, 51662, 51844, 51664, 51670, 51895, nil, 51659, 51843, 51660, 51661, 51890, 51656, 51893, 51892, 51651, 51839, 51891, 51849, 51894, 51655, 51847, nil, 51657}},
			{name = "Adventurer of Stormsong Valley", id = 12940, criteriaType = "QUESTS", criteria = {52452, 52315, 51759, {51976, 51977, 51978}, 52476, 51774, 51921, nil, 51776, 52459, 52321, 51781, nil, 51886, 51779, 51778, 52306, 52310, 51901, 51777, 52301, nil, 52463, nil, 52328, 51782, 52299, nil, 52300, nil, 52464, 52309, 52322, nil}},
			{name = "Sabertron Assemble", id = 13054, criteriaType = "QUESTS", criteria = {nil, nil, nil, 51976, nil}},
			-- Sabertron Assemble
			-- green 51976
			{name = "Drag Race", id = 13059, criteriaType = "QUEST_SINGLE", criteria = 53346}
		},
	}
	WQA.data[2] = bfa
end

-- Terrors of the Shore
-- Commander of Argus

function WQA:CreateQuestList()
	self:Debug("CreateQuestList")
	self.questList = {}
	for _,v in pairs(self.data[1].achievements) do
		self:AddAchievements(v)
	end
	self:AddMounts(self.data[1].mounts)
	self:AddPets(self.data[1].pets)
	self:AddToys(self.data[1].toys)
	for _,v in pairs(self.data[2].achievements) do
		self:AddAchievements(v)
	end
	self:AddCustom()
	self:Reward()
end

function WQA:AddAchievements(achievement)
	if self.db.char.achievements[achievement.name] == false then return end
	local id = achievement.id
	local _,_,_,completed,_,_,_,_,_,_,_,_,wasEarnedByMe = GetAchievementInfo(id)
	if (achievement.notAccountwide and not wasEarnedByMe) or not completed then
		if achievement.criteriaType == "ACHIEVEMENT" then
			for _,v in pairs(achievement.criteria) do
				self:AddAchievements(v)
			end
		elseif achievement.criteriaType == "QUEST_SINGLE" then
			self:AddReward(achievement.criteria, "ACHIEVEMENT", id)
		else
			for i=1, GetAchievementNumCriteria(id) do
				local _,t,completed,_,_,_,_,questID = GetAchievementCriteriaInfo(id,i)
				if not completed then
					if achievement.criteriaType == "QUESTS" then
						if type(achievement.criteria[i]) == "table" then
							for _,questID in pairs(achievement.criteria[i]) do
								self:AddReward(questID, "ACHIEVEMENT", id)
							end
						else
							questID = achievement.criteria[i] or 0
							self:AddReward(questID, "ACHIEVEMENT", id)
						end
					elseif achievement.criteriaType == 1 and t == 0 then
						for _,questID in pairs(achievement.criteria[i]) do
							self:AddReward(questID, "ACHIEVEMENT", id)
						end
					else
						self:AddReward(questID, "ACHIEVEMENT", id)
					end
				end
			end	
		end
	end
end

function WQA:AddMounts(mounts)
	for i,id in pairs(C_MountJournal.GetMountIDs()) do
		local n, spellID, _, _, _, _, _, _, _, _, isCollected = C_MountJournal.GetMountInfoByID(id)
		if not isCollected then
			for _,mount in pairs(mounts) do
				if self.db.char.mounts[mount.name] == true then
					if spellID == mount.spellID then
						for _,v  in pairs(mount.quest) do
							if not IsQuestFlaggedCompleted(v.trackingID) then
								self:AddReward(v.wqID, "CHANCE", mount.itemID)
							end
						end
					end
				end
			end
		end
	end
end

function WQA:AddPets(pets)
	local total = C_PetJournal.GetNumPets()
 	for i = 1, total do
  		local petID, _, owned, _, _, _, _, _, _, _, companionID = C_PetJournal.GetPetInfoByIndex(i)
  		if not owned then
  			for _,pet in pairs(pets) do
  				if self.db.char.pets[pet.name] == true then
	  				if companionID == pet.creatureID then
						for _,v in pairs(pet.quest) do
							if not IsQuestFlaggedCompleted(v.trackingID) then
								self:AddReward(v.wqID, "CHANCE", pet.itemID)
							end
		  				end
		  			end
		  		end
  			end
  		end
  	end
end

function WQA:AddToys(toys)
	for _,toy in pairs(toys) do
		if self.db.char.toys[toy.name] == true then
			if not PlayerHasToy(toy.itemID) then
				for _,v in pairs(toy.quest) do
					if not IsQuestFlaggedCompleted(v.trackingID) then
						self:AddReward(v.wqID, "CHANCE", toy.itemID)
					end
				end
			end
		end
	end
end

function WQA:AddCustom()
	if type(self.db.global.custom) == "table" then
		for k,v in pairs(self.db.global.custom) do
			if self.db.char.custom[k] == true then
				self:AddReward(k, "CUSTOM")
			end
		end
	end
end

function WQA:AddReward(questID, rewardType, reward)
	if not self.questList[questID] then self.questList[questID] = {} end
	local l = self.questList[questID]
	if rewardType == "ACHIEVEMENT" then
		if not l.achievement then l.achievement = {} end
		l.achievement[#l.achievement + 1] = {id = reward}
	elseif rewardType == "CHANCE" then
		if not l.chance then l.chance = {} end
		l.chance[#l.chance + 1] = {id = reward}
	elseif rewardType == "CUSTOM" then
		if not l.custom then l.custom = true end
	elseif rewardType == "ITEM" then
 		if not l.item then l.item = {} end
 		for k,v in pairs(reward) do
 			l.item[k] = v
 		end
	elseif rewardType == "REPUTATION" then
		if not l.reputation then l.reputation = {} end
 		for k,v in pairs(reward) do
 			l.reputation[k] = v
 		end
	elseif rewardType == "RECIPE" then
		l.recipe = reward
	elseif rewardType == "CUSTOM_ITEM" then
		l.customItem = reward
	elseif rewardType == "CURRENCY" then
		if not l.currency then l.currency = {} end
 		for k,v in pairs(reward) do
 			l.currency[k] = v
 		end	
	end
end

WQA.first = false
function WQA:Show(mode)
	self:Debug("Show", mode)
	self:CreateQuestList()
	self:CheckWQ(mode)
	self.first = true
end

function WQA:CheckWQ(mode)
	self:Debug("CheckWQ")
	if self.rewards ~= true then
		self:ScheduleTimer("CheckWQ", .4, mode)
		return
	end
	local activeQuests = {}
	local newQuests = {}
	for questID,qList in pairs(self.questList) do
		if IsActive(questID) then
			local questLink = GetQuestLink(questID)
			local link = self:link(self.questList[questID][1])
			if not questLink or not link then
				self:ScheduleTimer("CheckWQ", .5, mode)
				return
			end
			activeQuests[questID] = true
			if not self.watched[questID] then
				newQuests[questID] = true
			end
		end
	end

	for id,_ in pairs(newQuests) do
		self.watched[id] = true
	end

	if mode == "new" then
		self:AnnounceChat(newQuests, self.first)
		self:AnnouncePopUp(newQuests, self.first)
	else
		self:AnnounceChat(activeQuests)
		self:AnnouncePopUp(activeQuests)
	end
	self.activeQuests = activeQuests
	self.newQuests = newQuests
end

function WQA:link(x)
	if not x then return "" end
	local t = string.upper(x.type)
	if t == "ACHIEVEMENT" then
		return GetAchievementLink(x.id)
	elseif t == "ITEM" then
		return select(2,GetItemInfo(x.id))
	else
		return ""
	end
end

local icons = {
	unknown = "|TInterface\\AddOns\\CanIMogIt\\Icons\\UNKNOWN:0|t",
	known = "|TInterface\\AddOns\\CanIMogIt\\Icons\\KNOWN_circle:0|t",
}

function WQA:GetRewardForID(questID)
	local l = self.questList[questID]
	local r = ""
	if l then
		if l.item then
			if l.item then
				if l.item.transmog then
					r = r..icons[l.item.transmog]
				end
				if l.item.itemLevelUpgrade then
					if r ~= "" then r = r.." " end
					r = r.."|cFF00FF00+"..l.item.itemLevelUpgrade.." iLvl|r"
				end
				if l.item.itemPercentUpgrade then
					if r ~= "" then r = r..", " end
					r = r.."|cFF00FF00+"..l.item.itemPercentUpgrade.."%|r"
				end
				if l.item.AzeriteArmorCache then
					for i=1,5,2 do
						local upgrade = l.item.AzeriteArmorCache[i]
						if upgrade > 0 then
							r = r.."|cFF00FF00+"..upgrade.." iLvl|r"
						elseif upgrade < 0 then
							r = r.."|cFFFF0000"..upgrade.." iLvl|r"
						else
							r = r.."±"..upgrade
						end
						if i ~= 5 then
							r = r.." / "
						end
					end
				end
			end
			r = l.item.itemLink.." "..r
		end
		if l.currency then
			r = r..l.currency.amount.." "..l.currency.name
		end
	end
	return r
end

function WQA:AnnounceChat(activeQuests, silent)
	if self.db.char.options.chat == false then return end
	if next(activeQuests) == nil then
		if silent ~= true then
			print(L["NO_QUESTS"])
		end
		return
	end

	local output = L["WQChat"]
	print(output)
	for questID,_ in pairs(activeQuests) do
		local text, i = "", 0
		for k,v in pairs(self.questList[questID]) do
			i = i + 1
			if i > 1 then
				text = text.." & "..self:GetRewardTextByID(questID, k, v)
			else
				text =self:GetRewardTextByID(questID, k, v)
			end
		end
		output = "   "..string.format(L["WQforAch"], GetQuestLink(questID), text)
		print(output)
	end
end

function WQA:CreatePopUp()
	if self.PopUp then return self.PopUp end
	local f = CreateFrame("Frame", "WQAchievementsPopUp", UIParent, "UIPanelDialogTemplate")
	f:SetFrameStrata("BACKGROUND")
	f:SetWidth(500)
	f:SetPoint("TOP",0,-200)

	-- Move and resize
	f:SetMovable(true)
	f:EnableMouse(true)
	f:RegisterForDrag("LeftButton")
	f:SetScript("OnDragStart", function(self)
		self.moving = true
        self:StartMoving()
	end)
	f:SetScript("OnDragStop", function(self)
		self.moving = nil
        self:StopMovingOrSizing()
	end)

	f.ResizeButton = CreateFrame("Button", f:GetName().."ResizeButton", f)
	f.ResizeButton:SetWidth(16)
	f.ResizeButton:SetHeight(16)
	f.ResizeButton:SetPoint("BOTTOMRIGHT", f, "BOTTOMRIGHT")
	f.ResizeButton:SetNormalTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Up")

	f.Title:SetText("WQAchievements")
	f.Title:SetFontObject(GameFontNormalLarge)
	
	f.ScrollingMessageFrame = CreateFrame("ScrollingMessageFrame", "PopUpScroll", f)
	f.ScrollingMessageFrame:SetHyperlinksEnabled(true)
	f.ScrollingMessageFrame:SetWidth(470)
	f.ScrollingMessageFrame:SetPoint("TOP",f,"TOP",0,-28)
	f.ScrollingMessageFrame:SetFontObject(GameFontNormalLarge)
	f.ScrollingMessageFrame:SetFading(false)
	f.ScrollingMessageFrame:SetScript("OnHyperlinkEnter", function(_,_,link,line)
		GameTooltip_SetDefaultAnchor(GameTooltip, line)
		GameTooltip:ClearLines()
		GameTooltip:ClearAllPoints()
		GameTooltip:SetPoint("BOTTOM", line, "TOP", 0, 0)
		GameTooltip:SetHyperlink(link)
		GameTooltip:Show() end)
	f.ScrollingMessageFrame:SetScript("OnHyperlinkLeave", function() GameTooltip:Hide() end)
	f.ScrollingMessageFrame:SetJustifyV("CENTER")

	f.ScrollingMessageFrame:SetInsertMode(1)

	f.ScrollingMessageFrame:SetScript("OnMouseWheel", function(self, delta)
		if ( delta > 0 ) then
			self:ScrollDown()
		else
			self:ScrollUp()
		end
	end)

	--f.CloseButton = CreateFrame("Button", "CloseButton", f, "UIPanelCloseButton")
	--f.CloseButton:SetPoint("TOPRIGHT", f, "TOPRIGHT")

	self.PopUp = f
	return f
end

function WQA:AnnouncePopUp_(activeQuests, silent)
	if self.db.char.options.PopUp == false then return end
	local f = self:CreatePopUp()
	if f:IsShown() ~= true then
		f.ScrollingMessageFrame:Clear()
	end
	local i = 1
	if next(activeQuests) == nil then
		if silent ~= true then
			f.ScrollingMessageFrame:AddMessage(L["NO_QUESTS"])
			f:Show()
		end
	else
		f.ScrollingMessageFrame:SetJustifyH("LEFT")
		local Message = {}
		for questID,_ in pairs(activeQuests) do
			if not self.questList[questID].reward then
				Message[i] = string.format(L["WQforAch"],GetQuestLink(questID),self:link(self.questList[questID][1]))
			else
				Message[i] = string.format(L["WQforAch"],GetQuestLink(questID),self:GetRewardForID(questID))
			end			
			i = i+1
		end
		for j=#Message,1,-1 do
			f.ScrollingMessageFrame:AddMessage(Message[j])
		end
		f.ScrollingMessageFrame:AddMessage(L["WQChat"])

		f:Show()
	end
	i = math.max(3,i)
	f:SetHeight(38+i*16)
	f.ScrollingMessageFrame:SetHeight(16*i)
end

local inspectScantip = CreateFrame("GameTooltip", "WorldQuestListInspectScanningTooltip", nil, "GameTooltipTemplate")
inspectScantip:SetOwner(UIParent, "ANCHOR_NONE")

local EquipLocToSlot1 = 
{
	INVTYPE_HEAD = 1,
	INVTYPE_NECK = 2,
	INVTYPE_SHOULDER = 3,
	INVTYPE_BODY = 4,
	INVTYPE_CHEST = 5,
	INVTYPE_ROBE = 5,
	INVTYPE_WAIST = 6,
	INVTYPE_LEGS = 7,
	INVTYPE_FEET = 8,
	INVTYPE_WRIST = 9,
	INVTYPE_HAND = 10,
	INVTYPE_FINGER = 11,
	INVTYPE_TRINKET = 13,
	INVTYPE_CLOAK = 15,
	INVTYPE_WEAPON = 16,
	INVTYPE_SHIELD = 17,
	INVTYPE_2HWEAPON = 16,
	INVTYPE_WEAPONMAINHAND = 16,
	INVTYPE_RANGED = 16,
	INVTYPE_RANGEDRIGHT = 16,
	INVTYPE_WEAPONOFFHAND = 17,
	INVTYPE_HOLDABLE = 17,
	INVTYPE_TABARD = 19,
}
local EquipLocToSlot2 = 
{
	INVTYPE_FINGER = 12,
	INVTYPE_TRINKET = 14,
	INVTYPE_WEAPON = 17,
}

ItemTooltipScan = CreateFrame ("GameTooltip", "WQTItemTooltipScan", UIParent, "InternalEmbeddedItemTooltipTemplate")
   	ItemTooltipScan.texts = {
   		_G ["WQTItemTooltipScanTooltipTextLeft1"],
   		_G ["WQTItemTooltipScanTooltipTextLeft2"],
   		_G ["WQTItemTooltipScanTooltipTextLeft3"],
   		_G ["WQTItemTooltipScanTooltipTextLeft4"],
  }
	ItemTooltipScan.patern = ITEM_LEVEL:gsub ("%%d", "(%%d+)") --from LibItemUpgradeInfo-1.0

local ReputationItemList = {
	[152957] = 2165, -- Army of the Light Insignia
	[152960] = 2170, -- Argussian Reach Insignia
}

local ReputationCurrencyList = {
	[1579] = 2164, -- Champions of Azeroth
	[1598] = 2163, -- Tortollan Seekers
	[1593] = 2160, -- Proudmoore Admiralty
	[1592] = 2161, -- Order of Embers
	[1594] = 2162, -- Storm's Wake
	[1599] = 2159, -- 7th Legion
	[1597] = 2103, -- Zandalari Empire
	[1595] = 2156, -- Talanji's Expedition
	[1596] = 2158, -- Voldunai
	[1600] = 2157, -- The Honorbound
}

function WQA:Reward()
	self:Debug("Reward")

	self.event:UnregisterEvent("QUEST_LOG_UPDATE")
	self.event:UnregisterEvent("GET_ITEM_INFO_RECEIVED")
	self.rewards = false
	local retry = false

	for i=1,#self.ZoneIDList do
		for _,mapID in pairs(self.ZoneIDList[i]) do
			if self.db.char.options.zone[mapID] == true then
				local quests = C_TaskQuest.GetQuestsForPlayerByMapID(mapID)
				if quests then
					for i=1,#quests do
						local questID = quests[i].questId
						if self.db.char.options.zone[C_TaskQuest.GetQuestZoneID(questID)] == true then
							if HaveQuestData(questID) and not HaveQuestRewardData(questID) then
								C_TaskQuest.RequestPreloadRewardData(questID)
								retry = true
							end

							local numQuestRewards = GetNumQuestLogRewards(questID)
							if numQuestRewards > 0 then
								local itemName, itemTexture, quantity, quality, isUsable, itemID = GetQuestLogRewardInfo(1, questID)
								if itemID then
									inspectScantip:SetQuestLogItem("reward", 1, questID)
									itemLink = select(2,inspectScantip:GetItem())
									local itemName, _, itemRarity, itemLevel, itemMinLevel, itemType, itemSubType, itemStackCount, itemEquipLoc, itemTexture, itemSellPrice, itemClassID, itemSubClassID, _, expacID = GetItemInfo(itemLink)

									-- Ask Pawn if this is an Upgrade
									if PawnIsItemAnUpgrade and self.db.char.options.reward.gear.PawnUpgrade then
										local Item = PawnGetItemData(itemLink)
										if Item then
											local UpgradeInfo, BestItemFor, SecondBestItemFor, NeedsEnhancements = PawnIsItemAnUpgrade(Item)
											if UpgradeInfo and UpgradeInfo[1].PercentUpgrade*100 >= self.db.char.options.reward.gear.PawnUpgradeMin then
												local item = {itemLink = itemLink, itemPercentUpgrade = math.floor(UpgradeInfo[1].PercentUpgrade*100+.5)}
												self:AddReward(questID, "ITEM", item)
											end
										end
									end

									--StatWeightScore
									--local StatWeightScore = LibStub("AceAddon-3.0"):GetAddon("StatWeightScore")
									--local ScoreModule = StatWeightScore:GetModule("StatWeightScoreScore")

									-- Upgrade by itemLevel
									if self.db.char.options.reward.gear.itemLevelUpgrade then
										local itemLevel1, itemLevel2 = nil, nil
										if EquipLocToSlot1[itemEquipLoc] then
											local itemLink1 = GetInventoryItemLink("player", EquipLocToSlot1[itemEquipLoc])
											if itemLink1 then
												itemLevel1 = GetDetailedItemLevelInfo(itemLink1)
											end
										end
										if EquipLocToSlot2[itemEquipLoc] then
											local itemLink2 = GetInventoryItemLink("player", EquipLocToSlot2[itemEquipLoc])
											if itemLink2 then
												itemLevel2 = GetDetailedItemLevelInfo(itemLink2)
											end
										end
										itemLevel = GetDetailedItemLevelInfo(itemLink)
										local itemLevelEquipped = math.min(itemLevel1 or 1000, itemLevel2 or 1000)
										if itemLevel - itemLevelEquipped >= self.db.char.options.reward.gear.itemLevelUpgradeMin then
											local item = {itemLink = itemLink, itemLevelUpgrade = itemLevel - itemLevelEquipped}
											self:AddReward(questID, "ITEM", item)
										end
									end

									-- Azerite Armor Cache
									if itemID == 163857 and self.db.char.options.reward.gear.AzeriteArmorCache then
										itemLevel = GetDetailedItemLevelInfo(itemLink)
										local AzeriteArmorCacheIsUpgrade = false
										local AzeriteArmorCache = {}
										for i=1,5,2 do
											local itemLink1 = GetInventoryItemLink("player", i)
											if itemLink1 then
												local itemLevel1 = GetDetailedItemLevelInfo(itemLink1) or 0
												AzeriteArmorCache[i] = itemLevel - itemLevel1
												if itemLevel > itemLevel1 and itemLevel - itemLevel1 >= self.db.char.options.reward.gear.itemLevelUpgradeMin then
													AzeriteArmorCacheIsUpgrade = true
												end
											end
										end
										if AzeriteArmorCacheIsUpgrade == true then
											local item = {itemLink = itemLink, AzeriteArmorCache = AzeriteArmorCache}
											self:AddReward(questID, "ITEM", item)
										end
									end

									-- Transmog
									if CanIMogIt and self.db.char.options.reward.gear.unknownAppearance then
										if CanIMogIt:IsEquippable(itemLink) and CanIMogIt:CharacterCanLearnTransmog(itemLink) then
											local transmog
											if not CanIMogIt:PlayerKnowsTransmog(itemLink) then
												transmog = "unknown"
											elseif not CanIMogIt:PlayerKnowsTransmogFromItem(itemLink) and self.db.char.options.reward.gear.unknownSource then
												transmog = "known"
											end
											if transmog then
												local item = {itemLink = itemLink, transmog = transmog}
												self:AddReward(questID, "ITEM", item)
											end
										end
									end

									-- Reputation Token
									local factionID = ReputationItemList[itemID] or nil
									if factionID then
										if self.db.char.options.reward.reputation[factionID] == true then
											local reputation = {itemLink = itemLink, factionID = factionID}
											self:AddReward(questID, "REPUTATION", reputation)
										end
									end

									-- Recipe
									if itemClassID == 9 then
										if self.db.char.options.reward.recipe[expacID] == true then
											self:AddReward(questID, "RECIPE", itemLink)
										end
									end

									-- Crafting Reagent
									--[[
									if self.db.char.options.reward.craftingreagent[itemID] == true then
										if not self.questList[questID] then self.questList[questID] = {} end
								 		local l = self.questList[questID]
								 		if not l.reward then l.reward = {} end
										if not l.reward.item then l.reward.item = {} end
										l.reward.item.itemLink = itemLink
									end--]]

									-- Custom itemID
									if self.db.global.customReward[itemID] == true then
										if self.db.char.customReward[itemID] == true then
											self:AddReward(questID, "CUSTOM_ITEM", itemLink)
										end
									end

								else
									retry = true
								end
							end

							local numQuestCurrencies = GetNumQuestLogRewardCurrencies(questID)
							for i = 1, numQuestCurrencies do
								local name, texture, numItems, currencyID = GetQuestLogRewardCurrencyInfo(i, questID)
								if self.db.char.options.reward.currency[currencyID] then
						 			local currency = {currencyID = currencyID, currencyAmount = numItems}
						 			self:AddReward(questID, "CURRENCY", currency)
						 		end

						 		-- Reputation Currency
						 		local factionID = ReputationCurrencyList[currencyID] or nil
						 		if factionID then
						 			if self.db.char.options.reward.reputation[factionID] == true then
							 			local repuation = {name = name, currencyID = currencyID, currencyAmount = numItems, factionID = factionID}
							 			self:AddReward(questID, "REPUTATION", reputation)
						 			end
						 		end
							end
						end
					end
				end
			end
		end
	end

	if retry == true then
		self.Debug("|cFFFF0000<<<RETRY>>>|r")
		self.start = GetTime()
		self.timer = self:ScheduleTimer(function() self:Reward() end, 2)
		self.event:RegisterEvent("QUEST_LOG_UPDATE")
		self.event:RegisterEvent("GET_ITEM_INFO_RECEIVED")
	else
		self.rewards = true
	end
end

WQA.debug = false
function WQA:Debug(...)
	if self.debug == true
		then print(GetTime(),GetFramerate(),...)
	end
end

local LibQTip = LibStub("LibQTip-1.0")

function WQA:CreateQTip()
	if not self.tooltip then
		local tooltip = LibQTip:Acquire("WQAchievements", 2, "LEFT", "LEFT")
		self.tooltip = tooltip
		tooltip:SetPoint("TOP", self.PopUp, "TOP", 2, -27)
		tooltip:SetFrameStrata("HIGH")
		tooltip:AddHeader("World Quest", "Reward")
	end
end

function WQA:UpdateQTip(quests)
	local tooltip = self.tooltip
	if next(quests) == nil then
		tooltip:AddLine(L["NO_QUESTS"])
	else
		tooltip.quests = tooltip.quests or {}
		local i = tooltip:GetLineCount()
		for questID,_ in pairs(quests) do
			if not tooltip.quests[questID] then
				tooltip.quests[questID] = true
				i = i + 1
				local questLink = GetQuestLink(questID)
				tooltip:AddLine(questLink)
				tooltip:SetCellScript(i, 1, "OnEnter", function(self) 
					GameTooltip_SetDefaultAnchor(GameTooltip, self)
					GameTooltip:ClearLines()
					GameTooltip:ClearAllPoints()
					GameTooltip:SetPoint("BOTTOMLEFT", self, "TOPLEFT", 0, 0)
					GameTooltip:SetHyperlink(questLink)
					GameTooltip:Show()
				end)
				tooltip:SetCellScript(i, 1, "OnLeave", function() GameTooltip:Hide() end)

				local j = 1
				for k,v in pairs(WQA.questList[questID]) do
					j = j + 1
					local text = self:GetRewardTextByID(questID, k, v)
					if j > tooltip:GetColumnCount() then tooltip:AddColumn() end
					tooltip:SetCell(i, j, text)
				
					tooltip:SetCellScript(i, j, "OnEnter", function(self) 
						GameTooltip_SetDefaultAnchor(GameTooltip, self)
						GameTooltip:ClearLines()
						GameTooltip:ClearAllPoints()
						GameTooltip:SetPoint("BOTTOMLEFT", self, "TOPLEFT", 0, 0)
						if WQA:GetRewardLinkByID(questID, k, v) then
							GameTooltip:SetHyperlink(WQA:GetRewardLinkByID(questID, k, v))
						else
							GameTooltip:SetText(WQA:GetRewardTextByID(questID, k, v))
						end
						GameTooltip:Show()
					end)
					tooltip:SetCellScript(i, j, "OnLeave", function() GameTooltip:Hide() end)
				end
				--[[



				tooltip:SetCellScript(i, 1, "OnEnter", function(self) 
					GameTooltip_SetDefaultAnchor(GameTooltip, self)
					GameTooltip:ClearLines()
					GameTooltip:ClearAllPoints()
					GameTooltip:SetPoint("BOTTOMLEFT", self, "TOPLEFT", 0, 0)
					GameTooltip:SetHyperlink(questLink)
					GameTooltip:Show()
				end)
				tooltip:SetCellScript(i, 1, "OnLeave", function() GameTooltip:Hide() end)

				if achievementLink ~= "" then
					ColumnTwoEmpty = false
					tooltip:SetCellScript(i, 2, "OnEnter", function(self)
						GameTooltip_SetDefaultAnchor(GameTooltip, self)
						GameTooltip:ClearLines()
						GameTooltip:ClearAllPoints()
						GameTooltip:SetPoint("BOTTOMLEFT", self, "TOPLEFT", 0, 0)
						GameTooltip:SetHyperlink(achievementLink)
						GameTooltip:Show()
					end)
					tooltip:SetCellScript(i, 2, "OnLeave", function() GameTooltip:Hide() end)
				end

				if reward then
					if reward.item then
						tooltip:SetCellScript(i, 3, "OnEnter", function(self) 
							GameTooltip_SetDefaultAnchor(GameTooltip, self)
							GameTooltip:ClearLines()
							GameTooltip:ClearAllPoints()
							GameTooltip:SetPoint("BOTTOMLEFT", self, "TOPLEFT", 0, 0)
							GameTooltip:SetHyperlink(reward.item.itemLink)
							GameTooltip:Show()
						end)
						tooltip:SetCellScript(i, 3, "OnLeave", function() GameTooltip:Hide() end)
					end
				end]]
			end
		end
	end
	tooltip:Show()
	self.PopUp:SetWidth(tooltip:GetWidth()+8.5)
	self.PopUp:SetHeight(tooltip:GetHeight()+32)
end

function WQA:AnnouncePopUp(quests, silent)
	if self.db.char.options.PopUp == false then return end
	if not self.PopUp then
		local PopUp = CreateFrame("Frame", "WQAchievementsPopUp", UIParent, "UIPanelDialogTemplate")
		self.PopUp = PopUp
		PopUp:SetMovable(true)
		PopUp:EnableMouse(true)
		PopUp:RegisterForDrag("LeftButton")
		PopUp:SetScript("OnDragStart", function(self)
			self.moving = true
		    self:StartMoving()
		end)
		PopUp:SetScript("OnDragStop", function(self)
			self.moving = nil
		    self:StopMovingOrSizing()
		end)
		PopUp:SetWidth(300)
		PopUp:SetHeight(100)
		PopUp:SetPoint("CENTER")
		PopUp:Hide()

		PopUp:SetScript("OnHide", function()
			LibQTip:Release(WQA.tooltip)
			WQA.tooltip.quests = nil
   			WQA.tooltip = nil
		end)
	end
	if next(quests) == nil and silent == true then
		return
	end
	local PopUp = self.PopUp
	PopUp:Show()
	self:CreateQTip()
	self:UpdateQTip(quests)
end

function WQA:GetRewardTextByID(questID, key, value)
	local k, v = key, value
	local text
	if k == "achievement" then
		text = GetAchievementLink(v[1].id)
	elseif k == "chance" then
		text = select(2,GetItemInfo(v[1].id))
	elseif k == "custom" then
		text = "Custom"
	elseif k == "item" then
		text = self:GetRewardForID(questID)
	elseif k == "reputation" then
		if v.itemLink then
			text = select(2,GetItemInfo(v.itemLink))
		else
			text = v.amount.." "..v.name
		end
	elseif k == "recipe" then
		text = v
	elseif k == "customItem" then
		text = v
	elseif k == "currency" then
		text = v.currencyAmount.." "..GetCurrencyLink(v.currencyID, v.currencyAmount)
	end
	return text
end

function WQA:GetRewardLinkByID(questId, key, value)
	local k, v = key, value
	local link = nil
	if k == "achievement" then
		link = GetAchievementLink(v[1].id)
	elseif k == "chance" then
		link = select(2,GetItemInfo(v[1].id))
	elseif k == "custom" then
		return nil
	elseif k == "item" then
		link = v.itemLink
	elseif k == "reputation" then
		if v.itemLink then
			link = v.itemLink
		else
			link = GetCurrencyLink(v.currencyID, v.currencyAmount)
		end
	elseif k == "recipe" then
		link = v
	elseif k == "customItem" then
		link = v
	elseif k == "currency" then
		link = GetCurrencyLink(v.currencyID, v.currencyAmount)
	end
	return link
end