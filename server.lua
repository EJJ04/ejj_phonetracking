ESX = exports["es_extended"]:getSharedObject()

lib.callback.register('police:trackPhone', function(source, phoneNumber)
    phoneNumber = tostring(phoneNumber)

    local targetSource = exports["lb-phone"]:GetSourceFromNumber(phoneNumber)

    if targetSource then
        local x, y, z = table.unpack(GetEntityCoords(GetPlayerPed(targetSource)))

        local creationTime = os.date("%d-%m-%Y Kl. %H:%M", os.time())  

        return { 
            coordinates = { x, y, z }, 
            time = creationTime 
        }
    else
        return nil
    end
end)