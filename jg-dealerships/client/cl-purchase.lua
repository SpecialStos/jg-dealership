DoScreenFadeIn(100)

RegisterNUICallback("purchase-vehicle", function(data, cb)
  local dealership = Config.DealershipLocations[data.dealership]

  local purchaseType = data.purchaseType
  local purchaseSpawn = Functions.GetVehicleSpawnPoint(dealership.purchaseSpawn)
  local society = data.society
  local societyType = data.societyType
  local dealershipId = data.dealership
  local vehicleModel = data.vehicle
  local vehicleColor = data.color
  local paymentMethod = data.paymentMethod
  local finance = data.finance
  local dealerPlayerId = data.dealerPlayerId
  local noOfPayments = data.noOfPayments or Config.FinancePayments
  local downPayment = data.downPayment or Config.FinanceDownPayment
  local hash = type(vehicleModel) == "string" and joaat(vehicleModel) or vehicleModel
  local vehicleType = Functions.VehTypeFromClass(GetVehicleClassFromName(hash))

  Framework.Client.TriggerCallback("jg-dealerships:server:get-showroom-vehicle-data", function(vehicle)
    local vehiclePrice = vehicle.price
    local amountToPay = roundVal(vehiclePrice)
    local financed, financeData = 0, null
    local accBalance = -1

    Citizen.CreateThread(function()
      DoScreenFadeOut(200)
      Citizen.Wait(200)

      if purchaseType == "society" and paymentMethod == "societyFund" then
        accBalance = Framework.Client.GetSocietyBalance(society, societyType)
      else
        accBalance = Framework.Client.GetBalance(paymentMethod)
      end
      while accBalance == -1 do Wait(0) end

      if finance and purchaseType == "personal" then
        amountToPay = roundVal(vehiclePrice * (1 + Config.FinanceInterest) * downPayment) -- down payment
        if data.directSale then amountToPay = roundVal(vehiclePrice * (1 + Config.FinanceInterest) * data.downPayment) end

        financed = 1
        financeData = {
          total = roundVal(vehiclePrice * (1 + Config.FinanceInterest)),
          paid = amountToPay,
          recurring_payment = roundVal((vehiclePrice * (1 + Config.FinanceInterest) * (1 - downPayment)) / noOfPayments),
          payments_complete = 0,
          total_payments = noOfPayments,
          payment_interval = Config.FinancePaymentInterval,
          payment_failed = false,
          seconds_to_next_payment = Config.FinancePaymentInterval * 3600,
          seconds_to_repo = 0,
          dealership_id = dealershipId,
          vehicle = vehicleModel
        }
      end

      if amountToPay > accBalance then
        Framework.Client.Notify(Locale.errorCannotAffordVehicle, "error")
        DoScreenFadeIn(0)
        return cb({ error = true })
      end

      TriggerEvent("jg-dealerships:client:exit-showroom", function()
        Framework.Client.TriggerCallback("jg-dealerships:server:purchase-vehicle", function(cbData)
          if cbData and cbData.error then
            DoScreenFadeIn(0)
            return cb(false)
          end

          local plate = cbData.plate
          local hasUsableSeats = GetVehicleModelNumberOfSeats(hash) > 0

          local data = {
            hash = GetHashKey(vehicleModel),
            vehicleName = vehicleModel,
            plate = plate,
            coords = purchaseSpawn
          }

          if(vehicleColor == "purple")then
            data.color1 = 145
          elseif(vehicleColor == "yellow")then
            data.color1 = 88
          elseif(vehicleColor == "blue")then
            data.color1 = 73
          elseif(vehicleColor == "green")then
            data.color1 = 139
          elseif(vehicleColor == "orange")then
            data.color1 = 138
          elseif(vehicleColor == "red")then
            data.color1 = 27
          elseif(vehicleColor == "black")then
            data.color1 = 0
          elseif(vehicleColor == "white")then
            data.color1 = 111
          end
          

          TriggerServerEvent("tcvs:server:addVehicle", data)
          SetEntityCoords(PlayerPedId(), purchaseSpawn.x, purchaseSpawn.y + 4, purchaseSpawn.z)
          DoScreenFadeIn(500)
          Citizen.Wait(500)
          cb(cbData)
        end, purchaseType, society, societyType, vehicleModel, amountToPay, paymentMethod, dealershipId, financed, financeData, dealerPlayerId)
      end)
    end)
  end, dealershipId, vehicleModel)
end)