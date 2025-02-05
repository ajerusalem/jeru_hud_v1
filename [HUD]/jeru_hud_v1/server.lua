local QBCore = exports['qb-core']:GetCoreObject()
local config = Config
local priority = "peacetime"
local pnotes = ""
local cooldown = -1

QBCore.Commands.Add('cash', 'Check Cash Balance', {}, false, function(source, args)
    local Player = QBCore.Functions.GetPlayer(source)
    local cashamount = Player.PlayerData.money.cash
    TriggerClientEvent('hud:client:ShowAccounts', source, 'cash', cashamount)
end)

QBCore.Commands.Add('bank', 'Check Bank Balance', {}, false, function(source, args)
    local Player = QBCore.Functions.GetPlayer(source)
    local bankamount = Player.PlayerData.money.bank
    TriggerClientEvent('hud:client:ShowAccounts', source, 'bank', bankamount)
end)

QBCore.Commands.Add('togglehud', 'Show/Hide the HUD Interface', {}, false, function(source, args)
    TriggerClientEvent('hud:client:toggle', source)
end)

RegisterNetEvent('hud:server:getPriority')
AddEventHandler('hud:server:getPriority', function()
  TriggerClientEvent('hud:client:recievePriority', source, priority, pnotes, cooldown, true)
end)
RegisterNetEvent('hud:server:getTalkingPlayers')
AddEventHandler('hud:server:getTalkingPlayers', function(channel)
  local list = {}
  local players = exports['pma-voice']:getPlayersInRadioChannel(channel)
    for src, isTalking in pairs(players) do
      if isTalking then
        local Player = QBCore.Functions.GetPlayer(src)
        local name = Player.PlayerData.charinfo.firstname.." "..Player.PlayerData.charinfo.lastname
        if not (Player.PlayerData.metadata["callsign"] == "NO CALLSIGN") then
          name = name.." ["..Player.PlayerData.metadata["callsign"].."]"
        end
        table.insert(list, name)
      end
    end
    if list ~= {} and list ~= nil and list[1] ~= nil then
  TriggerClientEvent('hud:client:recieveTalkingPlayers', source, list)
else
TriggerClientEvent('hud:client:recieveTalkingPlayers', source, false)
end
end)

local function initCooldown()
  cooldown = config.prioCooldownTime
  while cooldown > -1 do
    if cooldown > 0 then
    Citizen.Wait(60000)
    cooldown = (cooldown-1)
    TriggerClientEvent('hud:client:recievePriority', -1, priority, pnotes, cooldown, false)
  else
    priority = "inactive"
    pnotes = ""
    cooldown = -1
    TriggerClientEvent('hud:client:recievePriority', -1, priority, pnotes, cooldown, false)
    end
  end
end
if config.usePrioStatus then
QBCore.Commands.Add('setp', 'Update the Priority Status', { {name = 'priority', help = 'Options: inactive,active,cooldown,peacetime' }, { name = 'notes', help = 'Optionally provide notes such as 10-80 or Low LEO.' }}, false, function(source, args)
  local pdata = QBCore.Functions.GetPlayer(source).PlayerData
  if pdata.job.name == 'police' or QBCore.Functions.HasPermission(source, 'admin') or QBCore.Functions.HasPermission(source, 'god') then
    if args[1] and not args[2] then
      if args[1] == "inactive" or args[1] == "active" or args[1] == "peacetime" then
        cooldown = -1
    --TriggerClientEvent('hud:client:notify', source, 'success', "Priority Status", "Set priority status to "..args[1]..".")
      priority = args[1]
      pnotes = ""
      TriggerClientEvent('hud:client:recievePriority', -1, priority, pnotes, cooldown, true)
      elseif args[1] == "cooldown" then
        cooldown = config.prioCooldownTime
        priority = args[1]
        pnotes = ""
        --TriggerClientEvent('hud:client:notify', source, 'success', "Priority Status", "Set priority status to "..args[1]..".")
        TriggerClientEvent('hud:client:recievePriority', -1, priority, pnotes, cooldown, true)
        initCooldown()
      else
      TriggerClientEvent('hud:client:notify', source, 'error', "Priority Status", "Invalid Command Syntax")
      end
    elseif args[1] and args[2] then
        if args[1] == "inactive" or args[1] == "active" or args[1] == "peacetime" then
          cooldown = -1
          priority = args[1]
          local string = ""
          for i = 2,#args,1
    do
      if i == #args then
       string = string..args[i]
      else
       string = string..args[i].." "
     end
    end
        pnotes = string
        --TriggerClientEvent('hud:client:notify', source, 'success', "Priority Status", "Set priority status to "..args[1]..".")
        TriggerClientEvent('hud:client:recievePriority', -1, priority, pnotes, cooldown, true)
        elseif args[1] == "cooldown" then
          cooldown = config.prioCooldownTime
          priority = args[1]
          pnotes = ""
        --TriggerClientEvent('hud:client:notify', source, 'success', "Priority Status", "Set priority status to "..args[1]..".")
        TriggerClientEvent('hud:client:recievePriority', -1, priority, pnotes, cooldown, true)
          initCooldown()
        else
        TriggerClientEvent('hud:client:notify', source, 'error', "Priority Status", "Invalid Command Syntax")
        end
    else
    TriggerClientEvent('hud:client:notify', source, 'error', "Priority Status", "Invalid Command Syntax")
    end
  else
  TriggerClientEvent('hud:client:notify', source, 'error', "Priority Status", "You are not police.")
  end
end)

QBCore.Commands.Add('setn', 'Set the priority notes', {{name = 'notes', help = "Minimal but useful information"}}, false, function(source, args)
  local pdata = QBCore.Functions.GetPlayer(source).PlayerData
  if pdata.job.name == 'police' or QBCore.Functions.HasPermission(source, 'admin') or QBCore.Functions.HasPermission(source, 'god') then
    if not args[1] then
    TriggerClientEvent('hud:client:notify', source, 'error', "Priority Status", "Invalid Command Syntax")
    else
      if cooldown > -1 then
      TriggerClientEvent('hud:client:notify', source, 'error', "Priority Status", "Can't set notes on cooldown.")
      else
      local string = ""
      for i = 1,#args,1
do
  if i == #args then
   string = string..args[i]
  else
   string = string..args[i].." "
 end
end
    pnotes = string
    TriggerClientEvent('hud:client:notify', source, 'success', "Priority Status", "Updated Priority Notes.")
    TriggerClientEvent('hud:client:recievePriority', -1, priority, pnotes, cooldown, false)
      end
    end
  else
  TriggerClientEvent('hud:client:notify', source, 'error', "Priority Status", "You are not police.")
  end
end)
end
