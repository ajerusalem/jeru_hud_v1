local QBCore = exports['qb-core']:GetCoreObject()
local PlayerData = QBCore.Functions.GetPlayerData()
local prevStats = {}
local stats = {}
local prevcStats = {}
local cstats = {}
local prevVC = {}
local VC = {}
local hidden = false
local config = Config
local speedMultiplier = config.UseMPH and 2.23694 or 3.6
local show = false
local seatbelt = false
local online = 0
local date = "8.02.2022"
local time = "22:13"
local delay = false
local postal = 000
local directions = {
  N = 360, 0,
  NE = 315,
  E = 270,
  SE = 225,
  S = 180,
  SW = 135,
  W = 90,
  NW = 45
}

--REMOVE GTA V HEALTH AND ARMOUR BARS
function removeMinimapBars()
Citizen.CreateThread(function()
    local minimap = RequestScaleformMovie("minimap")
    SetRadarBigmapEnabled(true, false)
    Wait(0)
    SetRadarBigmapEnabled(false, false)
    while true do
        Wait(0)
        BeginScaleformMovieMethod(minimap, "SETUP_HEALTH_ARMOUR")
        ScaleformMovieMethodAddParamInt(3)
        EndScaleformMovieMethod()
        HideHudComponentThisFrame(7)
				HideHudComponentThisFrame(9)
    end
end)
end

Citizen.CreateThread(function()
    postals = LoadResourceFile(GetCurrentResourceName(), GetResourceMetadata(GetCurrentResourceName(), 'postal_file'))
    postals = json.decode(postals)
end)

AddEventHandler('seatbelt:client:ToggleSeatbelt', function()
  seatbelt = not seatbelt
end)

Citizen.CreateThread(function()
    while postals == nil do Wait(1) end

    local postals = postals
    local _total = #postals

    while config.usePostals do
        local coords = GetEntityCoords(PlayerPedId())
        local _nearestIndex, _nearestD
        coords = vec(coords[1], coords[2])

        for i = 1, _total do
            local D = #(coords - postals[i][1])
            if not _nearestD or D < _nearestD then
                _nearestIndex = i
                _nearestD = D
            end
        end

        postal = postals[_nearestIndex].code
online = #GetActivePlayers()
time = GetClockHours().."."..GetClockMinutes()
local year, month, day = GetLocalTime()
date = month.."."..day.."."..year
delay = false
        Wait(2000)
    end
end)

Citizen.CreateThread(function()
    while config.noShootingOnPeacetime do
      if stats["priority"] == "Peacetime" then
              if IsControlPressed(0, 106) and not delay then
              SendNUIMessage({
                  action = 'notify',
                  type = 'error',
                  title = "Priority Status",
                  desc = "It is currently peacetime."
              })
              delay = true
               end
               SetPlayerCanDoDriveBy(player, false)
               DisablePlayerFiring(player, true)
               DisableControlAction(0, 140) -- Melee R
        end
        Wait(1)
    end
end)

RegisterNetEvent("QBCore:Client:OnPlayerLoaded", function()
    Wait(2000)
    PlayerData = QBCore.Functions.GetPlayerData()
    show = true
    SendNUIMessage({
      action = 'show',
    })
    if config.donttouch then
    TriggerServerEvent("hud:server:getPriority")
    end
    SendNUIMessage({
      action = 'color',
      main = config.uiColor,
      accent = config.accentColor,
    })
    removeMinimapBars()
end)

RegisterNetEvent("QBCore:Client:OnPlayerUnload", function()
    PlayerData = {}
    show = false
end)

RegisterNetEvent("QBCore:Player:SetPlayerData", function(val)
    PlayerData = val
end)

AddEventHandler('onResourceStart', function(resourceName)
    if GetCurrentResourceName() ~= resourceName then return end
    Wait(1000)
    PlayerData = QBCore.Functions.GetPlayerData()
    if PlayerData ~= nil then
      show = true
    SendNUIMessage({
        action = 'show',
    })
    if config.donttouch then
    TriggerServerEvent("hud:server:getPriority")
    end
    SendNUIMessage({
      action = 'color',
      main = config.uiColor,
      accent = config.accentColor,
    })
    removeMinimapBars()
    end
end)

RegisterNetEvent('hud:client:recievePriority', function(priority, pnotes, cooldown, notify)
    stats["priority"] = priority:gsub("^%l", string.upper)
    stats["pnotes"] = pnotes
    stats["cooldown"] = cooldown
    if notify then
    if pnotes ~= "" then
      priority = priority.." ("..pnotes..")"
    end
    SendNUIMessage({
        action = 'notify',
        type = 'info',
        title = "Priority Status",
        desc = "The priority is now "..priority.."."
    })
    end
end)

local function updateVC()
    local shouldUpdate = false
    for k, v in pairs(VC) do
        if prevVC[k] ~= v then
            shouldUpdate = true
            break
        end
    end
    if shouldUpdate then
      prevVC["enabled"] = VC["enabled"]
      prevVC["list"] = VC["list"]
    SendNUIMessage({
        action = 'radio',
        enabled = VC["enabled"],
        list = VC["list"],
    })
    end
end

RegisterNetEvent('hud:client:recieveTalkingPlayers', function(players)
  if players then
  VC["enabled"] = true
  VC["list"] = json.encode(players)
  else
  VC["enabled"] = false
  end
  updateVC()
end)

RegisterNetEvent('hud:client:toggle', function()
  hidden = not hidden
  if hidden then
SendNUIMessage({
    action = 'hide',
})
  DisplayRadar(false)
else

SendNUIMessage({
    action = 'show',
})
  DisplayRadar(true)
end
end)

local function updateHud()
    local shouldUpdate = false
    for k, v in pairs(stats) do
        if prevStats[k] ~= v then
            shouldUpdate = true
            break
        end
    end
    if shouldUpdate then
      prevStats["postal"] = stats["postal"]
      prevStats["street"] = stats["street"]
      prevStats["zone"] = stats["zone"]
      prevStats["heading"] = stats["heading"]
      prevStats["priority"] = stats["priority"]
      prevStats["pnotes"] = stats["pnotes"]
      prevStats["cooldown"] = stats["cooldown"]
      prevStats["time"] = stats["time"]
      prevStats["date"] = stats["date"]
      prevStats["id"] = stats["id"]
      prevStats["online"] = stats["online"]
      prevStats["servername"] = stats["servername"]
      prevStats["logo"] = stats["logo"]
      prevStats["health"] = stats["health"]
      prevStats["hunger"] = stats["hunger"]
      prevStats["thirst"] = stats["thirst"]
      prevStats["armour"] = stats["armour"]
    SendNUIMessage({
        action = 'update',
        postal = stats["postal"],
        street = stats["street"],
        zone = stats["zone"],
        heading = stats["heading"],
        priority = stats["priority"],
        pnotes = stats["pnotes"],
        cooldown = stats["cooldown"],
        time = stats["time"],
        date = stats["date"],
        id = stats["id"],
        online = stats["online"],
        servername = stats["servername"],
        logo = stats["logo"],
        health = stats["health"],
        hunger = stats["hunger"],
        thirst = stats["thirst"],
        armour = stats["armour"],
    })
    end
end

local function updateCarHud()
    local shouldUpdate = false
    for k, v in pairs(cstats) do
        if prevcStats[k] ~= v then
            shouldUpdate = true
            break
        end
    end
    if shouldUpdate then
      prevcStats["incar"] = cstats["incar"]
      prevcStats["fuel"] = cstats["fuel"]
      prevcStats["speed"] = cstats["speed"]
      prevcStats["useMPH"] = cstats["useMPH"]
      prevcStats["vehhealth"] = cstats["vehhealth"]
      prevcStats["brake"] = cstats["brake"]
      prevcStats["lock"] = cstats["lock"]
      prevcStats["seatbelt"] = cstats["seatbelt"]
      prevcStats["rpm"] = cstats["rpm"]
    SendNUIMessage({
        action = 'carhud',
        incar = cstats["incar"],
        fuel = cstats["fuel"],
        speed = cstats["speed"],
        useMPH = cstats["useMPH"],
        vehhealth = cstats["vehhealth"],
        brake = cstats["brake"],
        lock = cstats["lock"],
        rpm = cstats["rpm"],
        seatbelt = cstats["seatbelt"],
    })
    end
end

Citizen.CreateThread(function()
    while true do
      if LocalPlayer.state.isLoggedIn then
      local coords = GetEntityCoords(PlayerPedId());
      local var1, var2 = GetStreetNameAtCoord(coords.x, coords.y, coords.z, Citizen.ResultAsInteger(), Citizen.ResultAsInteger())
			local hash1 = GetStreetNameFromHashKey(var1);
      local zone = GetNameOfZone(coords.x, coords.y, coords.z);
      local heading = GetEntityHeading(PlayerPedId());
      for k, v in pairs(directions) do
				if (math.abs(heading - v) < 22.5) then
					heading = k;

					if (heading == 1) then
						heading = 'N';
						break;
					end

					break;
				end
			end
      if config.usePostals then
        stats["postal"] = postal
      else
        stats["postal"] = false
      end
      if config.showInfo then
        stats["id"] = GetPlayerServerId(PlayerId())
        stats["servername"] = config.serverName
        stats["online"] = online
        stats["logo"] = config.infoIcon
      else
        stats["id"] = false
      end
        stats["health"] = GetEntityHealth(GetPlayerPed(-1))/200
        stats["hunger"] = PlayerData.metadata['hunger']/100
        stats["thirst"] = PlayerData.metadata['thirst']/100
        stats["armour"] = GetPedArmour(GetPlayerPed(-1))/100
        stats["time"] = time
        stats["date"] = date
        stats["street"] = hash1
        stats["zone"] = GetLabelText(zone)
        stats["heading"] = heading
        updateHud()
      end
      Wait(500)
    end
end)

Citizen.CreateThread(function()
  local wasInVehicle = false

  -- Sunucuya ilk girişte harita ve HUD'ı tamamen kapat
  Citizen.Wait(450) -- İlk başta kısa bir gecikme ekleyelim
  DisplayRadar(false) 
  SendNUIMessage({ action = 'hideCircle' }) 

  while true do
      Citizen.Wait(100)
      local ped = PlayerPedId()
      local inVehicle = IsPedInAnyVehicle(ped, false)

      if inVehicle and not wasInVehicle then
          wasInVehicle = true
          Citizen.Wait(500)
          if IsPedInAnyVehicle(ped, false) then 
              DisplayRadar(true) -- Araçtayken harita açılır
              SendNUIMessage({ action = 'showCircle' }) -- HUD açılır
          end
      elseif not inVehicle and wasInVehicle then
          wasInVehicle = false
          Citizen.Wait(100) -- Kapatmadan önce küçük bir gecikme ekleyelim
          DisplayRadar(false) -- Araçtan inince harita kapanır
          SendNUIMessage({ action = 'hideCircle' }) -- HUD kapanır
      end
  end
end)

AddEventHandler("playerSpawned", function()
  Citizen.Wait(0) -- Spawn olana kadar bekleyelim
  DisplayRadar(false) -- Haritayı sunucuya girişte kapat
  SendNUIMessage({ action = 'hideCircle' }) -- HUD'ı da gizle
end)

-- Minimap
Citizen.CreateThread(function()
	RequestStreamedTextureDict("circlemap", false)
	while not HasStreamedTextureDictLoaded("circlemap") do
		Wait(100)
	end

	AddReplaceTexture("platform:/textures/graphics", "radarmasksm", "circlemap", "radarmasksm")

	SetMinimapClipType(1)
	SetMinimapComponentPosition('minimap', 'L', 'B', -0.0085, -0.010, 0.128, 0.221)
	SetMinimapComponentPosition('minimap_mask', 'L', 'B', 0.010 + 0.10, 0.010 + 0.10, 0.10 - 0.026, 0.15 - 0.026 ) -- MARKER
	SetMinimapComponentPosition('minimap_blur', 'L', 'B', -0.0067, 0.020, 0.178, 0.262)

    local minimap = RequestScaleformMovie("minimap")
    SetRadarBigmapEnabled(true, false)
    Wait(0)
    SetRadarBigmapEnabled(false, false)

    while true do
        Citizen.Wait(100)
        BeginScaleformMovieMethod(minimap, "SETUP_HEALTH_ARMOUR")
        ScaleformMovieMethodAddParamInt(3)
        EndScaleformMovieMethod()
    end
end)

local isInVehicle = false

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(500) -- Daha az yoğunluk için 500ms bekletelim

        local ped = PlayerPedId()
        local veh = GetVehiclePedIsIn(ped, false)

        if veh ~= 0 and not isInVehicle then
            isInVehicle = true
            SendNUIMessage({ action = "setHudVehicle", inVehicle = true })
        elseif veh == 0 and isInVehicle then
            isInVehicle = false
            SendNUIMessage({ action = "setHudVehicle", inVehicle = false })
        end
    end
end)


