RegisterServerEvent(Security.EventPrefix .. ':server:addVehicle')
AddEventHandler(Security.EventPrefix .. ':server:addVehicle', function(data)

    if(data.identifier == nil)then
        if(data.source ~= nil)then
            data.identifier = identifier(data.source)
        else
            local info = debug.getinfo(1,'l')
            TriggerEvent(Security.EventPrefix .. ":server:log", "ERROR: Couldn't find source to add entry in database -> /server/database.lua Line: " .. info.currentline, "error")
        end
    end

    if(data.identifier ~= nil)then

        local vin = vinCreator() --We generate a unique VIN ID.
        local plate = data.plate
        
        local keyholders = { --Initialising keyholders table.
            [1] = {
                steam = "NONE",
                name = "NONE",
            },
            [2] = {
                steam = "NONE",
                name = "NONE",
            },
            [3] = {
                steam = "NONE",
                name = "NONE",
            },
            [4] = {
                steam = "NONE",
                name = "NONE",
            },
            [5] = {
                steam = "NONE",
                name = "NONE",
            }
        }



        local position = { --Initialising vehicle spawn position.
            x = round(data.coords.x, 2),
            y = round(data.coords.y, 2),
            z = round(data.coords.z, 2),
            h = round(data.coords.w, 2)
        }

        local parts = partsCreator()

        if(data.locked == nil)then
            data.locked = true
        end

        if(data.garaged == nil)then
            data.garaged = false
        end

        if(data.exploded == nil)then
            data.exploded = false
        end

        if(data.impounded == nil)then
            data.impounded = false
        end

        if(data.garageValue == nil)then
            data.garageValue = 0
        end

        if(data.impoundReason == nil)then
            data.impoundReason = "NONE"
        end

        if(data.impoundPoliceNeeded == nil)then
            data.impoundPoliceNeeded = 0
        end

        if(data.impoundPrice == nil)then
            data.impoundPrice = 0
        end

        if(data.trackerData == nil)then
            data.trackerData = {
                type = 0, --0 means not intalled, 1 means basic, 2 means advanced.
                name = plate, --Default name of tracker is the plate. Advanced trackers support name changing.
                status = 0, --0 means normal tracker mode, 1 means emergency mode, 2 means stolen mode.
            }
        end

        if(data.vehType == nil)then
            data.vehType = nil
        end

        local metadata = {  --Initialising parts table.
            locked = data.locked,
            garaged = data.garaged,
            exploded = data.exploded,
            impounded = data.impounded,
            garageValue = data.garageValue,
            impoundReason = data.impoundReason,
            impoundPoliceNeeded = data.impoundPoliceNeeded,
            impoundPrice = data.impoundPrice,
            trackerData = data.trackerData,
            vehType = data.vehType,
            job = data.job,
        }

        if(data.color1 == nil)then
            data.color1 = 0
        end

        if(data.color2 == nil)then
            data.color2 = 0
        end

        if(data.hash == nil)then
            local info = debug.getinfo(1,'l')
            TriggerServerEvent(Security.EventPrefix .. ":server:log", "ERROR: Couldn't find hash to add entry in database -> /server/database.lua Line: " .. info.currentline, "error")
            return
        end

        local mods = {
            model = data.hash,
            plate = data.plate,
            color1 = data.color1, --Change this if you want other colour than black.
            color2 = data.color2, --If your car-dealer script supports colouring then send the colour with data.colour1 and data.colour2 then set the values here
        }

        local last_updated = os.time() --This initialises the last updated column made by our resource.

        vehicleList[plate] = { --Adds the vehicle to the dynamic array. Do not touch this code.
            vin = vin,
            owner = data.identifier,
            keyholders = keyholders,
            position = json.encode(position),
            mods = json.encode(mods),
            parts = parts,
            metadata = metadata,
            plate = plate,
            last_updated = last_updated,
            customDespawn = false,
            changed = false,
        }

        TriggerEvent(Security.EventPrefix .. ":server:spawnAddedVehicle", plate, data.identifier)
        updateSortTableByLastUpdated(plate, last_updated, "new")
        
        if(Config.UsingInventoryKeys)then --Gives Vehicle Keys to User if you are using inventory keys.
            if(data.source ~= nil)then
                TriggerEvent(Security.EventPrefix .. ":server:giveVehKeys", 1, plate, data.source)
            else
                local info = debug.getinfo(1,'l')
                TriggerEvent(Security.EventPrefix .. ":server:log", "ERROR: Couldn't find source to add entry in database -> /server/database.lua Line: " .. info.currentline, "error")
            end
        end
    else
        local info = debug.getinfo(1,'l')
        TriggerEvent(Security.EventPrefix .. ":server:log", "ERROR: Couldn't find identifier to add entry in database -> /server/database.lua Line: " .. info.currentline, "error")
    end
end)
