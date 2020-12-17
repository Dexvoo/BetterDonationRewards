-------------------------------------
--- DiscordDonatorPerks by Badger ---
-------------------------------------

--- CONFIG ---
local webhook = 'https://discord.com/api/webhooks/788956623459581972/5ANUH1FQHkL2rOG_UqXsCM08kRk0H3p3w-n6_1npnkhSoDArUHDbHX17VCPdqhoMLOZI'
roleList = {
	{"Iron", 638821095176405012, {"100 Gems Voucher", {'Money', 100}} 
	}, -- Iron Tier 
	{"Gold", 638822168364580865, {"200 Gems Voucher",{'Money', 200}} 
	}, -- Gold Tier 
	{"Diamond", 638821558965764127, {"300 Gems Voucher",{'Money', 300}} 
	}, -- Diamond Tier 
	{"Quartz", 638821239015866369, {"350 Gems Voucher",{'Money', 300}} 
	}, -- Quartz Tier 
	{"God", 638822958680506388, {"150 Gems Voucher",{'Money', 150}} 
	}, -- God Tier 
	{"Booster", 714447115182669835, {"50 Gems Voucher",{'Money', 50}} 
	}, -- Booster Tier 
	{"money", 638819167872614450, {"100 Gems Voucher",{'Money', 100}} 
	}, -- Staff Tier 
	{"Job", 638819167872614450,
		{"Invitation to Black Diamond Cartel [Gang]", {'Job', 'ambulance', 0}}	
	}, -- Bronze Tier
	{"Item", 638819167872614450, 
		{" Testing ",{'Item','headlighty', 1}} 
	}, -- Staff Tier 
}

--- CODE ---
local idfromsource
ESX = nil;
TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end);
RegisterNetEvent('PatreonDonatorPerks:OfferMoney')
AddEventHandler('PatreonDonatorPerks:OfferMoney', function(src, label, amount)
	-- Offer them their money
	-- {'Money', label, amount}
	TriggerClientEvent('Perksy', src, {'Money', label, amount});
end)
RegisterNetEvent('PatreonDonatorPerks:OfferJob')
AddEventHandler('PatreonDonatorPerks:OfferJob', function(src, label, jobName, jobGrade)
	-- Offer them their job 
	TriggerClientEvent('Perksy', src, {'Job', label, jobName, jobGrade});
end)
RegisterNetEvent('PatreonDonatorPerks:OfferItem')
AddEventHandler('PatreonDonatorPerks:OfferItem', function(src, label, item, count)
	-- Offer them their job 
	TriggerClientEvent('Perksy', src, {'Item', label, item, count});
end)
RegisterNetEvent('PatreonDonatorPerks:DenyItem')
AddEventHandler('PatreonDonatorPerks:DenyItem', function(jobName, jobGrade)
	-- Check to see if they have value perk queued for this 
	local src = source;
	local xPlayer = ESX.GetPlayerFromId(src);
	local steamID = ExtractIdentifiers(src).steam;
	-- table.insert(perkQueue[src], {offerDetails, rankName, i});
	local removeIndex = nil;
	if perkQueue[src] ~= nil then 
		-- They have valid perks to obtain 
		local perks = perkQueue[src];
		for i = 1, #perks do 
			-- Perks 
			local perkType = perks[i][1][1];
			if perkType == 'Item' then 
				local perkJob = perks[i][1][2];
				local perkGrade = perks[i][1][3];
				if perkJob == jobName and jobGrade == perkGrade then 
					-- This is a valid request, give them it and remove this index 
					--xPlayer.setJob(jobName, tonumber(perkGrade));
					-- SQL 
					local rankName = perks[i][2];
					local perkID = perks[i][3];
					local datesOfPerks = MySQL.Sync.fetchAll('SELECT id FROM tebex_data WHERE identifier = "' ..
						steamID .. '" AND rankPackage = "' .. rankName .. '" AND acceptedPerkID = ' .. perkID); 
					local dateNow = os.time() + (60 * 60 * 24 * 30);
					if datesOfPerks ~= nil and #datesOfPerks > 1 then 
						-- They had this package last month 
						local patDataID = datesOfPerks[1].id;
						MySQL.Async.execute('UPDATE tebex_data SET dateReceiveNext = @date WHERE id = @patData', 
							{
								['@date'] = dateNow,
								['@patData'] = patDataID
							});
					else 
						-- Never had package, add it 
						PerformHttpRequest(webhook, function(err, text, headers) end,
						'POST',
						json.encode(
						{
							username = ('BetterDiscordDonations'),
							content = (
								'```css\n' .. ExtractIdentifiers(src).steam .. '\n' ..
								'' .. ExtractIdentifiers(src).license .. '\n' ..
								'' .. ExtractIdentifiers(src).xbl .. '\n' .. 
								'' .. ExtractIdentifiers(src).live .. '\n' .. 
								'' .. ExtractIdentifiers(src).discord .. '\n\n' .. 
								'Has claimed there ITEM reward which is for rank ' .. rankName ..'.\n```'),
							avatar_url = 'https://i.imgur.com/WKXOLOs.png'
						}
						),
						{['Content-Type'] = 'application/json' })
						MySQL.Async.execute('INSERT INTO tebex_data VALUES (@id, @ident, @playerName, @dateNext, @perkID, @rankPack)', {
							['@id'] = 0,
							['@ident'] = steamID,
							['@playerName'] = GetPlayerName(src),
							['@dateNext'] = dateNow,
							['@perkID'] = perkID,
							['@rankPack'] = rankName
						});
					end
					removeIndex = i;
					break;
				end
			end
		end
		local temp = {};
		for i = 1, #perks do 
			if i ~= removeIndex then 
				table.insert(temp, perks[i]);
			end
		end
		perkQueue[src] = temp;
	end
end)
RegisterNetEvent('PatreonDonatorPerks:DenyJob')
AddEventHandler('PatreonDonatorPerks:DenyJob', function(jobName, jobGrade)
	-- Check to see if they have value perk queued for this 
	local src = source;
	local xPlayer = ESX.GetPlayerFromId(src);
	local steamID = ExtractIdentifiers(src).steam;
	-- table.insert(perkQueue[src], {offerDetails, rankName, i});
	local removeIndex = nil;
	if perkQueue[src] ~= nil then 
		-- They have valid perks to obtain 
		local perks = perkQueue[src];
		for i = 1, #perks do 
			-- Perks 
			local perkType = perks[i][1][1];
			if perkType == 'Job' then 
				local perkJob = perks[i][1][2];
				local perkGrade = perks[i][1][3];
				if perkJob == jobName and jobGrade == perkGrade then 
					-- This is a valid request, give them it and remove this index 
					--xPlayer.setJob(jobName, tonumber(perkGrade));
					-- SQL 
					local rankName = perks[i][2];
					local perkID = perks[i][3];
					local datesOfPerks = MySQL.Sync.fetchAll('SELECT id FROM tebex_data WHERE identifier = "' ..
						steamID .. '" AND rankPackage = "' .. rankName .. '" AND acceptedPerkID = ' .. perkID); 
					local dateNow = os.time() + (60 * 60 * 24 * 30);
					if datesOfPerks ~= nil and #datesOfPerks > 1 then 
						-- They had this package last month 
						local patDataID = datesOfPerks[1].id;
						MySQL.Async.execute('UPDATE tebex_data SET dateReceiveNext = @date WHERE id = @patData', 
							{
								['@date'] = dateNow,
								['@patData'] = patDataID
							});
					else 
						-- Never had package, add it 
						PerformHttpRequest(webhook, function(err, text, headers) end,
						'POST',
						json.encode(
						{
							username = ('BetterDiscordDonations'),
							content = (
								'```css\n' .. ExtractIdentifiers(src).steam .. '\n' ..
								'' .. ExtractIdentifiers(src).license .. '\n' ..
								'' .. ExtractIdentifiers(src).xbl .. '\n' .. 
								'' .. ExtractIdentifiers(src).live .. '\n' .. 
								'' .. ExtractIdentifiers(src).discord .. '\n\n' .. 
								'Has claimed there JOB reward which is for rank ' .. rankName ..'.\n```'),
							avatar_url = 'https://i.imgur.com/WKXOLOs.png'
						}
						),
						{['Content-Type'] = 'application/json' })
						MySQL.Async.execute('INSERT INTO tebex_data VALUES (@id, @ident, @playerName, @dateNext, @perkID, @rankPack)', {
							['@id'] = 0,
							['@ident'] = steamID,
							['@playerName'] = GetPlayerName(src),
							['@dateNext'] = dateNow,
							['@perkID'] = perkID,
							['@rankPack'] = rankName
						});
					end
					removeIndex = i;
					break;
				end
			end
		end
		local temp = {};
		for i = 1, #perks do 
			if i ~= removeIndex then 
				table.insert(temp, perks[i]);
			end
		end
		perkQueue[src] = temp;
	end
end)
RegisterNetEvent('PatreonDonatorPerks:GiveItem')
AddEventHandler('PatreonDonatorPerks:GiveItem', function(item, count)
	-- Check to see if they have value perk queued for this 
	local src = source;
	local xPlayer = ESX.GetPlayerFromId(src);
	local steamID = ExtractIdentifiers(src).steam;
	-- table.insert(perkQueue[src], {offerDetails, rankName, i});
	local removeIndex = nil;
	if perkQueue[src] ~= nil then 
		-- They have valid perks to obtain 
		local perks = perkQueue[src];
		for i = 1, #perks do 
			-- Perks 
			local perkType = perks[i][1][1];
			if perkType == 'Item' then 
				local perkJob = perks[i][1][2];
				local perkGrade = perks[i][1][3];
				if perkJob == item and count == perkGrade then 
					-- This is a valid request, give them it and remove this index 
					-- SQL 
					local rankName = perks[i][2];
					local perkID = perks[i][3];
					local datesOfPerks = MySQL.Sync.fetchAll('SELECT id FROM tebex_data WHERE identifier = "' ..
						steamID .. '" AND rankPackage = "' .. rankName .. '" AND acceptedPerkID = ' .. perkID); 
					local dateNow = os.time() + (60 * 60 * 24 * 30);
					if datesOfPerks ~= nil and #datesOfPerks > 1 then 
						-- They had this package last month 
						local patDataID = datesOfPerks[1].id;
						MySQL.Async.execute('UPDATE tebex_data SET dateReceiveNext = @date WHERE id = @patData', 
							{
								['@date'] = dateNow,
								['@patData'] = patDataID
							});
					else 
						-- Never had package, add it 
						PerformHttpRequest(webhook, function(err, text, headers) end,
						'POST',
						json.encode(
						{
							username = ('BetterDiscordDonations'),
							content = (
								'```css\n' .. ExtractIdentifiers(src).steam .. '\n' ..
								'' .. ExtractIdentifiers(src).license .. '\n' ..
								'' .. ExtractIdentifiers(src).xbl .. '\n' .. 
								'' .. ExtractIdentifiers(src).live .. '\n' .. 
								'' .. ExtractIdentifiers(src).discord .. '\n\n' .. 
								'Has claimed there ITEM reward which is for rank ' .. rankName ..'.\n```'),
							avatar_url = 'https://i.imgur.com/WKXOLOs.png'
						}
						),
						{['Content-Type'] = 'application/json' })
						MySQL.Async.execute('INSERT INTO tebex_data VALUES (@id, @ident, @playerName, @dateNext, @perkID, @rankPack)', {
							['@id'] = 0,
							['@ident'] = steamID,
							['@playerName'] = GetPlayerName(src),
							['@dateNext'] = dateNow,
							['@perkID'] = perkID,
							['@rankPack'] = rankName
						});
					end
					xPlayer.addInventoryItem(item, count);
					removeIndex = i;
					break;
				end
			end
		end
		local temp = {};
		for i = 1, #perks do 
			if i ~= removeIndex then 
				table.insert(temp, perks[i]);
			end
		end
		perkQueue[src] = temp;
	end
end)
RegisterNetEvent('PatreonDonatorPerks:GiveJob')
AddEventHandler('PatreonDonatorPerks:GiveJob', function(jobName, jobGrade)
	-- Check to see if they have value perk queued for this 
	local src = source;
	local xPlayer = ESX.GetPlayerFromId(src);
	local steamID = ExtractIdentifiers(src).steam;
	-- table.insert(perkQueue[src], {offerDetails, rankName, i});
	local removeIndex = nil;
	if perkQueue[src] ~= nil then 
		-- They have valid perks to obtain 
		local perks = perkQueue[src];
		for i = 1, #perks do 
			-- Perks 
			local perkType = perks[i][1][1];
			if perkType == 'Job' then 
				local perkJob = perks[i][1][2];
				local perkGrade = perks[i][1][3];
				if perkJob == jobName and jobGrade == perkGrade then 
					-- This is a valid request, give them it and remove this index 
					-- SQL 
					local rankName = perks[i][2];
					local perkID = perks[i][3];
					local datesOfPerks = MySQL.Sync.fetchAll('SELECT id FROM tebex_data WHERE identifier = "' ..
						steamID .. '" AND rankPackage = "' .. rankName .. '" AND acceptedPerkID = ' .. perkID); 
					local dateNow = os.time() + (60 * 60 * 24 * 30);
					if datesOfPerks ~= nil and #datesOfPerks > 1 then 
						-- They had this package last month 
						local patDataID = datesOfPerks[1].id;
						MySQL.Async.execute('UPDATE tebex_data SET dateReceiveNext = @date WHERE id = @patData', 
							{
								['@date'] = dateNow,
								['@patData'] = patDataID
							});
					else 
						-- Never had package, add it 
						PerformHttpRequest(webhook, function(err, text, headers) end,
						'POST',
						json.encode(
						{
							username = ('BetterDiscordDonations'),
							content = (
								'```css\n' .. ExtractIdentifiers(src).steam .. '\n' ..
								'' .. ExtractIdentifiers(src).license .. '\n' ..
								'' .. ExtractIdentifiers(src).xbl .. '\n' .. 
								'' .. ExtractIdentifiers(src).live .. '\n' .. 
								'' .. ExtractIdentifiers(src).discord .. '\n\n' .. 
								'Has claimed there JOB reward which is for rank ' .. rankName ..'.\n```'),
							avatar_url = 'https://i.imgur.com/WKXOLOs.png'
						}
						),
						{['Content-Type'] = 'application/json' })
						MySQL.Async.execute('INSERT INTO tebex_data VALUES (@id, @ident, @playerName, @dateNext, @perkID, @rankPack)', {
							['@id'] = 0,
							['@ident'] = steamID,
							['@playerName'] = GetPlayerName(src),
							['@dateNext'] = dateNow,
							['@perkID'] = perkID,
							['@rankPack'] = rankName
						});
					end
					xPlayer.setJob(jobName, tonumber(perkGrade));
					removeIndex = i;
					break;
				end
			end
		end
		local temp = {};
		for i = 1, #perks do 
			if i ~= removeIndex then 
				table.insert(temp, perks[i]);
			end
		end
		perkQueue[src] = temp;
	end
end)
RegisterNetEvent('PatreonDonatorPerks:GiveMoney')
AddEventHandler('PatreonDonatorPerks:GiveMoney', function(amount)
	-- Check to see if they have valid perk queued for this 
	local src = source;
	local xPlayer = ESX.GetPlayerFromId(src);
	local steamID = ExtractIdentifiers(src).steam;
	-- table.insert(perkQueue[src], {offerDetails, rankName, i});
	local removeIndex = nil;
	if perkQueue[src] ~= nil then 
		-- They have valid perks to obtain 
		local perks = perkQueue[src];
		for i = 1, #perks do 
			-- Perks 
			local perkType = perks[i][1][1];
			if perkType == 'Money' then 
				local perkMoney = perks[i][1][2];
				if perkMoney == amount then 
					-- This is a valid request, give them it and remove this index 
					-- SQL 
					local rankName = perks[i][2];
					local perkID = perks[i][3];
					local datesOfPerks = MySQL.Sync.fetchAll('SELECT id FROM tebex_data WHERE identifier = "' ..
						steamID .. '" AND rankPackage = "' .. rankName .. '" AND acceptedPerkID = ' .. perkID); 
					local dateNow = os.time() + (60 * 60 * 24 * 30);
					if datesOfPerks ~= nil and #datesOfPerks > 1 then 
						-- They had this package last month 
						local patDataID = datesOfPerks[1].id;
						MySQL.Async.execute('UPDATE tebex_data SET dateReceiveNext = @date WHERE id = @patData', 
							{
								['@date'] = dateNow,
								['@patData'] = patDataID
							});
					else 
						-- Never had package, add it 
						PerformHttpRequest(webhook, function(err, text, headers) end,
						'POST',
						json.encode(
						{
							username = ('BetterDiscordDonations'),
							content = (
								'```css\n' .. ExtractIdentifiers(src).steam .. '\n' ..
								'' .. ExtractIdentifiers(src).license .. '\n' ..
								'' .. ExtractIdentifiers(src).xbl .. '\n' .. 
								'' .. ExtractIdentifiers(src).live .. '\n' .. 
								'' .. ExtractIdentifiers(src).discord .. '\n\n' .. 
								'Has claimed there MONEY reward which is for rank ' .. rankName ..'.\n```'),
							avatar_url = 'https://i.imgur.com/WKXOLOs.png'
						}
						),
						{['Content-Type'] = 'application/json' })
						MySQL.Async.execute('INSERT INTO tebex_data VALUES (@id, @ident, @playerName, @dateNext, @perkID, @rankPack)', {
							['@id'] = 0,
							['@ident'] = steamID,
							['@playerName'] = GetPlayerName(src),
							['@dateNext'] = dateNow,
							['@perkID'] = perkID,
							['@rankPack'] = rankName
						});
					end
					xPlayer.addAccountMoney('black_money', amount);
					removeIndex = i;
					break;
				end
			end
		end
		local temp = {};
		for i = 1, #perks do 
			if i ~= removeIndex then 
				table.insert(temp, perks[i]);
			end
		end
		perkQueue[src] = temp;
	end
end)
perkQueue = {}
hasPerkAccess = {}
RegisterNetEvent('PatreonDonatorPerks:CheckPerks')
AddEventHandler('PatreonDonatorPerks:CheckPerks', function()
	local src = source;
	local identifierDiscord = ExtractIdentifiers(src).discord;
	local steamID = ExtractIdentifiers(src).steam; 
	if identifierDiscord then
		local roleIDs = exports.Badger_Discord_API:GetDiscordRoles(src)
		if not (roleIDs == false) then
			for i = 1, #roleList do
				for j = 1, #roleIDs do
					if (tostring(roleList[i][2]) == tostring(roleIDs[j])) then
						-- They have the role 
						-- Now check if they got their perks already 
						local maxPerks = #roleList[i] - 2;
						local rankName = roleList[i][1];
						local currentPerkCount = MySQL.Sync.fetchScalar('SELECT COUNT(*) FROM tebex_data WHERE ' ..
							'identifier = "' .. steamID .. '" AND rankPackage = "' .. rankName .. '"');
						if (currentPerkCount == nil or currentPerkCount < maxPerks) then 
							-- Offer them their perks
							hasPerkAccess[src] = true;
							if (perkQueue[src] == nil) then 
								perkQueue[src] = {};
							end
							--[[
									1                2                        ((1))      (3)      ((2))
								{"Bronze-Tier", 698239215388983417, {"$1,000,000 voucher", {'Money', 1000000} } }, -- Bronze Tier 
							]]--
							for k = 3, #roleList[i] do 
								-- These are the offers 
								local offer = roleList[i][k]; -- (Offer)
								local offerName = offer[1]; -- ((1))
								local offerDetails = offer[2]; -- ((2))
								table.insert(perkQueue[src], {offerDetails, rankName, (k - 2)});
								for l = 1, #offer do 
									local offerEvent = offer[l];
									if type(offerEvent) == 'table' then 
										if offerEvent[1] == 'Job' then 
											-- Give them job 2 args 
											TriggerEvent('PatreonDonatorPerks:OfferJob', src, offerName, offerEvent[2], offerEvent[3]);
										end
										if offerEvent[1] == 'Item' then 
											-- Give them item 2 args 
											TriggerEvent('PatreonDonatorPerks:OfferItem', src, offerName, offerEvent[2], offerEvent[3]);
										end
										if offerEvent[1] == 'Money' then 
											-- Give them money 1 args 
											TriggerEvent('PatreonDonatorPerks:OfferMoney', src, offerName, offerEvent[2]);
										end 
									end
								end 
							end
							-- We have finished giving them the offers
						else 
							-- Check if the month has pasted and if so, update the date and offer perks
							local datesOfPerks = MySQL.Sync.fetchAll('SELECT dateReceiveNext, id FROM tebex_data WHERE identifier = "' ..
								steamID .. '" AND rankPackage = "' .. rankName .. '"'); 
							local dateNow = os.time();
							for kk = 1, #datesOfPerks do 
								local dateReceiveNext = datesOfPerks[kk].dateReceiveNext;
								local id = datesOfPerks[kk].id;
								if (dateReceiveNext <= dateNow) then 
									-- Offer perks 
									--[[
											1                2                        ((1))      (3)      ((2))
										{"Bronze-Tier", 698239215388983417, {"$1,000,000 voucher", {'Money', 1000000} } }, -- Bronze Tier 
									]]--
									for k = 3, #roleList[i] do 
										-- These are the offers 
										local offer = roleList[i][k]; -- (Offer)
										local offerName = offer[1]; -- ((1))
										local offerDetails = offer[2]; -- ((2))
										table.insert(perkQueue[src], {offerDetails, rankName, (k - 2)});
										for l = 1, #offer do 
											local offerEvent = offer[l];
											if type(offerEvent) == 'table' then 
												if offerEvent[1] == 'Job' then 
													-- Give them job 2 args 
													TriggerEvent('PatreonDonatorPerks:OfferJob', src, offerName, offerEvent[2], offerEvent[3]);
												end
												if offerEvent[1] == 'Item' then 
													-- Give them item 2 args 
													TriggerEvent('PatreonDonatorPerks:OfferItem', src, offerName, offerEvent[2], offerEvent[3]);
												end
												if offerEvent[1] == 'Money' then 
													-- Give them money 1 args 
													TriggerEvent('PatreonDonatorPerks:OfferMoney', src, offerName, offerEvent[2]);
												end 
											end
										end
									end
								end
							end
						end
					end
				end
			end 
		else
			print("[PatreonDonatorPerks] " .. GetPlayerName(src) .. " has not gotten their donator role checked cause roleIDs == false")
		end
	else
		print("[PatreonDonatorPerks] " .. GetPlayerName(src) .. " has not gotten their (possible) donator perks cause their discord was not detected...")
	end
	-- We update their name in MySQL down here 
	MySQL.Async.execute('UPDATE tebex_data SET playerName = @pname WHERE identifier = @sid', {['@pname'] = GetPlayerName(src), ['@sid'] = steamID});
end)

function ExtractIdentifiers(src)
    local identifiers = {
        steam = "",
        ip = "",
        discord = "",
        license = "",
        xbl = "",
        live = ""
    }

    --Loop over all identifiers
    for i = 0, GetNumPlayerIdentifiers(src) - 1 do
        local id = GetPlayerIdentifier(src, i)

        --Convert it to a nice table.
        if string.find(id, "steam") then
            identifiers.steam = id
        elseif string.find(id, "ip") then
            identifiers.ip = id
        elseif string.find(id, "discord") then
            identifiers.discord = id
        elseif string.find(id, "license") then
            identifiers.license = id
        elseif string.find(id, "xbl") then
            identifiers.xbl = id
        elseif string.find(id, "live") then
            identifiers.live = id
        end
    end

    return identifiers
end
