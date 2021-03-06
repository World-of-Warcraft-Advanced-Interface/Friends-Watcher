--
-- Advanced Friends Interface (SetUp)
--

local _, L = ...;
local AddOn = "Arranger_AdvancedFriendsUI"
local Path = "Interface\\AddOns\\"..AddOn.."\\"
local Build = "0150924:012"
local Constant = {ADVANCED_INTERFACE_FRIENDS_TRACKING = {}}
local function AdvancedInterface(L, key)
	return key;
end
local function CopyAdvancedInterfaceOptions(orig)
	local orig_type = type(orig)
	local copy
	if orig_type == 'table' then
		copy = {}
		for orig_key, orig_value in next, orig, nil do
			copy[CopyAdvancedInterfaceOptions(orig_key)] = CopyAdvancedInterfaceOptions(orig_value)
		end
		setmetatable(copy, CopyAdvancedInterfaceOptions(getmetatable(orig)))
	else
		copy = orig
	end
	return copy
end
local function SetAdvancedInterfaceOptions()
	if Current == nil then
		Current = CopyAdvancedInterfaceOptions(Constant)
	end
	setmetatable(L, {__index=AdvancedInterface});
	RegisterAddonMessagePrefix("ADVANCED")
end

-- --
-- -- Advanced Friends Interface (Action)
-- --

local function AdvancedInterfaceFriendsFrameFavoriteButton_OnClick(self)
	if not Current.ADVANCED_INTERFACE_FRIENDS_TRACKING[self.battleTag] then
		if self.isOnline then
			self:SetNormalTexture(Path.."Miscellaneous\\UI-Advanced-Friends-Frame-Favorites-Button-Selected")
		else
			self:SetNormalTexture(Path.."Miscellaneous\\UI-Advanced-Friends-Frame-Favorites-Button-Selected-Offline")
		end
		Current.ADVANCED_INTERFACE_FRIENDS_TRACKING[self.battleTag] = true
		GameTooltip:SetText(L["ADVANCED_INTERFACE_FRIENDS_FRAME_UNTRACK_TOOLTIP"], HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b, 1)
		SendSystemMessage(string.format( L["ADVANCED_INTERFACE_FRIENDS_FRAME_TRACK_MESSAGE"], self.accountName))
	else
		if self.isOnline then
			self:SetNormalTexture(Path.."Miscellaneous\\UI-Advanced-Friends-Frame-Favorites-Button-Normal")
		else
			self:SetNormalTexture(Path.."Miscellaneous\\UI-Advanced-Friends-Frame-Favorites-Button-Normal-Offline")
		end
		Current.ADVANCED_INTERFACE_FRIENDS_TRACKING[self.battleTag] = false
		GameTooltip:SetText(L["ADVANCED_INTERFACE_FRIENDS_FRAME_TRACK_TOOLTIP"], HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b, 1)
		SendSystemMessage(string.format( L["ADVANCED_INTERFACE_FRIENDS_FRAME_UNTRACK_MESSAGE"], self.accountName))
	end
	PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);
end
local function AdvancedInterfaceFriendsFrameFavoriteButton_OnEnter(self)
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
	if not Current.ADVANCED_INTERFACE_FRIENDS_TRACKING[self.battleTag] then
		GameTooltip:SetText(L["ADVANCED_INTERFACE_FRIENDS_FRAME_TRACK_TOOLTIP"], HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b, 1)
	else
		GameTooltip:SetText(L["ADVANCED_INTERFACE_FRIENDS_FRAME_UNTRACK_TOOLTIP"], HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b, 1)
	end
end
local function InitializeAdvancedInterfaceFriendsFrame()
	local texture = Path.."Miscellaneous\\UI-Advanced-Friends-Frame-Status-Icon"
	FRIENDS_TEXTURE_ONLINE = texture.."-".."Online";
	FRIENDS_TEXTURE_AFK = texture.."-".."Away";
	FRIENDS_TEXTURE_DND = texture.."-".."Busy";
	FRIENDS_TEXTURE_OFFLINE = texture.."-".."Offline";
	FRIENDS_TEXTURE_BROADCAST = texture.."-".."Stream";
	local frame = FriendsTabHeaderRecruitAFriendButton
	texture = Path.."Miscellaneous\\UI-Advanced-Friends-Frame-Recruit-Icon"
	FriendsTabHeaderRecruitAFriendButtonIcon:Hide()
	frame:SetNormalTexture(texture.."-".."Normal")
	frame:SetPushedTexture(texture.."-".."Pushed")
	frame:SetHighlightTexture("Interface\\Buttons\\UI-Common-MouseHilight")
	frame:SetPoint("TOPRIGHT", -5, -54);
	frame:SetSize(32,32)
	for i = 1, FRIENDS_FRIENDS_TO_DISPLAY do
		local frame = "FriendsFrameFriendsScrollFrameButton"
		local button = "TravelPassButton"
		local icon = "GameIcon"
		local textures = {{type = "NormalTexture", coordinates = {0,0.5,0.5,1}},{type = "HighlightTexture", coordinates = {0.5,1,0,0.5}},{type = "PushedTexture", coordinates = {0.5,1,0.5,1}},{type = "DisabledTexture", coordinates = {0,0.5,0,0.5}}}
		for _, texture in pairs(textures) do
			_G[frame..i..button..texture.type]:SetTexture(Path.."Miscellaneous\\UI-Advanced-Friends-Frame-Invitation-Buttons")
			_G[frame..i..button..texture.type]:SetTexCoord(texture.coordinates[1],texture.coordinates[2],texture.coordinates[3],texture.coordinates[4])
		end
		_G[frame..i..button]:SetHitRectInsets(4, 4, 2, 2);
		_G[frame..i..button]:SetSize(32,32)
		_G[frame..i..icon]:SetSize(32,32)
	end
	hooksecurefunc("FriendsFrame_UpdateFriends", function()
		local friends = FriendsFrameFriendsScrollFrame.buttons
		for i = 1, #friends do
			local friend = friends[i]
			if friend:IsShown() then
				if not friend.favoriteButton then
					local name = friend:GetName().."FavoritesButton"
					local texture = Path.."Miscellaneous\\UI-Advanced-Friends-Frame-Favorites-Button"
					local button = CreateFrame("Button", name, friend)
					button:SetScript("OnClick", AdvancedInterfaceFriendsFrameFavoriteButton_OnClick)
					button:SetScript("OnEnter", AdvancedInterfaceFriendsFrameFavoriteButton_OnEnter)
					button:SetScript("OnLeave", GameTooltip_Hide)
					button:SetNormalTexture(texture.."-".."Normal")
					button:SetPushedTexture(texture.."-".."Pushed")
					button:SetHighlightTexture(texture.."-".."Highlight")
					button:SetHitRectInsets(4, 4, 2, 2);
					button:SetSize(32, 32)
					friend.favoriteButton = button
				end
				if not friend.factionFrame then
					local name = friend:GetName()
					local frame = friend:CreateTexture(name.."FactionFrame", "OVERLAY")
					frame:SetTexture(Path.."Miscellaneous\\UI-Advanced-Friends-Frame-Friend-Faction-Frames")
					frame:SetTexCoord(0,0.5,0,1)
					frame:SetSize(32,32)
					friend.factionFrame = frame
				end
				if not friend.factionTexture then
					local name = friend:GetName()
					local icon = friend:CreateTexture(name.."FactionTexture", "OVERLAY", nil, 1)
					icon:SetTexture(Path.."Miscellaneous\\UI-Advanced-Friends-Frame-Friend-Faction-Icons")
					icon:SetSize(16,16)
					friend.factionTexture = icon
				end
				if not friend.gameTexture then
					local name = friend:GetName()
					local frame = friend:CreateTexture(name.."GameTexture", "OVERLAY", nil, -1)
					frame:SetTexture(Path.."Miscellaneous\\UI-Advanced-Friends-Frame-Friend-Game-Icons")
					frame:SetSize(24,24)
					friend.gameTexture = frame
				end
				local button = friend.favoriteButton
				if friend.buttonType == FRIENDS_BUTTON_TYPE_BNET then
					local _, accountName, battleTag, _, _, bnetIDGameAccount, client, isOnline = BNGetFriendInfo(friend.id)
					button.accountName = accountName
					button.battleTag = battleTag
					button.isOnline = isOnline
					if client then
						local _, _, _, _, _, faction = BNGetGameAccountInfo(bnetIDGameAccount)
						friend.gameTexture:Show()
						friend.gameTexture:SetPoint("CENTER",friend.gameIcon, 0.5, 0)
						friend.gameIcon:ClearAllPoints()
						friend.gameIcon:SetTexture(Path.."Miscellaneous\\UI-Advanced-Friends-Frame-Friend-Game-Button")
						if battleTag then
							friend.gameIcon:SetPoint("RIGHT", friend.favoriteButton, "LEFT", 8, 0)
						else
							friend.gameIcon:SetPoint("RIGHT", friend.travelPassButton, "LEFT", 8, 0)
						end
						if client == BNET_CLIENT_WOW then
							-- friend.gameTexture:SetTexCoord(0,0.25,0.5,1)
							if faction ~= "Neutral" then
								friend.factionFrame:Show()
								friend.factionFrame:SetPoint("CENTER",friend.status, 0, -12.5)
								friend.factionTexture:Show()
								friend.factionTexture:SetPoint("CENTER",friend.factionFrame, 0, 0)
								if faction == "Alliance" then
									friend.factionTexture:SetTexCoord(0,0.5,0,1)
								elseif faction == "Horde" then
									friend.factionTexture:SetTexCoord(0.5,1,0,1)
								end
							end
							friend.gameIcon:Hide()
							friend.gameTexture:Hide()
						else
							friend.factionFrame:Hide()
							friend.factionTexture:Hide()
							if client == BNET_CLIENT_APP or client == BNET_CLIENT_CLNT then
								friend.gameTexture:SetTexCoord(0,0.25,0,0.5)
							elseif client == BNET_CLIENT_SC2 then
								friend.gameTexture:SetTexCoord(0.75,1,0,0.5)
							elseif client == BNET_CLIENT_D3 then
								friend.gameTexture:SetTexCoord(0.25,0.5,0,0.5)
							elseif client == BNET_CLIENT_WTCG then
								friend.gameTexture:SetTexCoord(0.25,0.5,0.5,1)
							elseif client == BNET_CLIENT_HEROES then
								friend.gameTexture:SetTexCoord(0.5,0.75,0,0.5)
							elseif client == BNET_CLIENT_SC then
								friend.gameTexture:SetTexCoord(0.75,1,0.5,1)
							elseif client == BNET_CLIENT_OVERWATCH then
								friend.gameTexture:SetTexCoord(0,0.25,0.5,1)
							elseif client == BNET_CLIENT_DESTINY2 then
								friend.gameTexture:SetTexCoord(0.5,0.75,0.5,1)
							else
								friend.gameIcon:Hide()
								friend.gameTexture:Hide()
							end
						end
					else
						friend.gameTexture:Hide()
					end
					if battleTag then
						friend.favoriteButton:Show()
						if isOnline then
							friend.favoriteButton:SetPoint("TOPRIGHT", friend, -23, -1)
							if Current.ADVANCED_INTERFACE_FRIENDS_TRACKING[battleTag] then
								friend.favoriteButton:SetNormalTexture(Path.."Miscellaneous\\UI-Advanced-Friends-Frame-Favorites-Button-Selected")
							else
								friend.favoriteButton:SetNormalTexture(Path.."Miscellaneous\\UI-Advanced-Friends-Frame-Favorites-Button-Normal")
							end
						else
							friend.favoriteButton:SetPoint("TOPRIGHT", friend, 1, -1)
							if Current.ADVANCED_INTERFACE_FRIENDS_TRACKING[battleTag] then
								friend.favoriteButton:SetNormalTexture(Path.."Miscellaneous\\UI-Advanced-Friends-Frame-Favorites-Button-Selected-Offline")
							else
								friend.favoriteButton:SetNormalTexture(Path.."Miscellaneous\\UI-Advanced-Friends-Frame-Favorites-Button-Normal-Offline")
							end
						end
					else
						friend.favoriteButton:Hide()
					end
					if not isOnline then
						friend.factionFrame:Hide()
						friend.factionTexture:Hide()
					end
				else
					friend.factionFrame:Hide()
					friend.factionTexture:Hide()
					friend.gameTexture:Hide()
					friend.favoriteButton:Hide()
				end
			end
		end
	end)
	FriendsFrameFriendsScrollFrame.update = function() return FriendsFrame_UpdateFriends() end
end
local function InitializeAdvancedInterfaceFriendsStatus()
	local temp = {}
	local status = {}
	local function SetDefaultStatus()
		local numBNetTotal = BNGetNumFriends();
		for i = 1, numBNetTotal do
			local _, _, battleTag, _, _, _, client, isOnline = BNGetFriendInfoByID(i)
			status = { battleTag = {} }
			status.battleTag["client"] = client
			status.battleTag["isOnline"] = isOnline
		end
	end
	local icon = "Interface\\CHATFRAME\\UI-ChatIcon"
	local icons = {BN = "|TInterface\\FriendsFrame\\UI-Toast-FriendOnlineIcon:16:16:0:0:32:32:2:30:2:30|t", D3 = "|T"..icon.."-D3:14|t", Hero = "|T"..icon.."-HotS:14|t", S2 = "|T"..icon.."-SC2:14|t", WoW = "|T"..icon.."-WoW:14|t", WTCG = "|T"..icon.."-WTCG:14|t"}
	local f = AdvancedFriendsInterface or CreateFrame("Frame", "AdvancedFriendsInterface", UIParent)
	local function Messenger(self, event, friendIndex, ...)
		if friendIndex then
			local bnetIDAccount, _, _, _, _, bnetIDGameAccount = BNGetFriendInfo(friendIndex)
			local bnetIDAccount, accountName, battleTag, isBattleTagPresence, toonName, _, client, isOnline = BNGetFriendInfoByID(bnetIDAccount)
			if event == "BN_FRIEND_ACCOUNT_ONLINE" then
				temp[accountName] = true
			end
			if event == "BN_FRIEND_INFO_CHANGED" and client and battleTag then
				local globalName = string.format( "|HBNplayer:%s:%s|h[%s]|h", accountName, bnetIDAccount, accountName )
				local _, _, _, realmName, _, faction = BNGetGameAccountInfo(bnetIDGameAccount)
				for k,v in pairs(Current.ADVANCED_INTERFACE_FRIENDS_TRACKING) do
					if k == battleTag and v == true then
						if not temp[accountName] then
							-- print(status.battleTag["client"],status.battleTag["isOnline"])
							if client ~= nil and client == "App" and status.battleTag["client"] ~= client then
								print( BATTLENET_FONT_COLOR_CODE .. icons.BN .. string.format( L["ADVANCED_INTERFACE_FRIEND_TRACKING_OFFLINE"], globalName) .. FONT_COLOR_CODE_CLOSE );
								PlaySound(SOUNDKIT.UI_BNET_TOAST);
							elseif client == "WoW" and status.battleTag["client"] ~= client then
								local ADVANCED_INTERFACE_FRIEND_TRACKING_ONLINE
								if faction == "Horde" then
									ADVANCED_INTERFACE_FRIEND_TRACKING_ONLINE = "ADVANCED_INTERFACE_FRIEND_TRACKING_ONLINE_HORDE"
								elseif faction == "Alliance" then
									ADVANCED_INTERFACE_FRIEND_TRACKING_ONLINE = "ADVANCED_INTERFACE_FRIEND_TRACKING_ONLINE_ALLIANCE"
								else
									ADVANCED_INTERFACE_FRIEND_TRACKING_ONLINE = "ADVANCED_INTERFACE_FRIEND_TRACKING_ONLINE"
								end
								print( BATTLENET_FONT_COLOR_CODE .. icons.BN .. string.format( L[ADVANCED_INTERFACE_FRIEND_TRACKING_ONLINE], globalName, icons[client], toonName, realmName) .. FONT_COLOR_CODE_CLOSE );
								PlaySound(SOUNDKIT.UI_BNET_TOAST);
							end
							status.battleTag["client"] = client
							status.battleTag["isOnline"] = isOnline
						else
							temp[accountName] = nil
						end
					end
				end
			end
		end
	end
	local function UnregisterEvent()
		f:UnregisterEvent("BN_FRIEND_INFO_CHANGED")
	end
	local function RegisterEvent()
		f:RegisterEvent("BN_FRIEND_INFO_CHANGED")
		f:RegisterEvent("BN_FRIEND_ACCOUNT_ONLINE")
		f:SetScript("OnEvent", Messenger)
	end
	GameMenuButtonLogout:HookScript("OnClick", UnregisterEvent)
	GameMenuButtonQuit:HookScript("OnClick", UnregisterEvent)
	C_Timer.After(2, RegisterEvent);
	SetDefaultStatus()
end

-- --
-- -- Advanced Friends Interface (Initialization)
-- --

function InitializeAdvancedInterface()
	SetAdvancedInterfaceOptions()
	InitializeAdvancedInterfaceFriendsFrame()
	InitializeAdvancedInterfaceFriendsStatus()
end
