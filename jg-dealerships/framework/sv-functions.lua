RegisterServerEvent("tcvs:server:addVehicle")
AddEventHandler("tcvs:server:addVehicle", function(data)
  local src = source
  data.src = src

  if Config.Framework == "QBCore" then
    local player = QBCore.Functions.GetPlayer(src)
    data.identifier = player.PlayerData.citizenid
  elseif Config.Framework == "ESX" then
    data.identifier = Framework.Server.GetPlayerIdentifier(src)
  end

  TriggerEvent("realisticVehicleSystem:server:addVehicle", 1, data)
end)