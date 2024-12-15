lib.locale()

local tablet = nil
local radiusBlips = {}

lib.registerContext({
    id = 'police_phone_tracking',
    title = locale('ejj_politisporing:title1'),
    canClose = true,
    onExit = function()
        ClearPedTasks(cache.ped)
        DeleteObject(tablet)
    end,
    options = {
        {
            title = locale('ejj_politisporing:title2'),
            description = locale('ejj_politisporing:description1'),
            icon = 'phone',
            onSelect = function()
                local input = lib.inputDialog(locale('ejj_politisporing:inputdialogtitle'), {
                    { type = 'input', label = locale('ejj_politisporing:inputdialoglabel'), placeholder = locale('ejj_politisporing:inputdialogplaceholder'), required = true }
                })

                if input and tonumber(input[1]) then
                    local phoneNumber = tonumber(input[1])
                    local data = lib.callback.await('police:trackPhone', false, phoneNumber)

                    local isAirplaneMode = exports["lb-phone"]:GetAirplaneMode()
                    if isAirplaneMode then
                        lib.notify({
                            description = locale('ejj_politisporing:description6'),
                            type = 'error'
                        })
                        return
                    end

                    if data then
                        local x, y, z = table.unpack(data.coordinates)
                        local formattedTime = data.time  

                        lib.notify({
                            description = locale('ejj_politisporing:notifydescription1'),
                            type = 'success'
                        })

                        local radiusBlip = AddBlipForRadius(x, y, z, Config.RadiusBlip.radiussize)
                        SetBlipHighDetail(radiusBlip, true)
                        SetBlipColour(radiusBlip, Config.RadiusBlip.blipcolour)  
                        SetBlipAlpha(radiusBlip, Config.RadiusBlip.blipalpha) 

                        table.insert(radiusBlips, { 
                            radiusBlip = radiusBlip, 
                            phoneNumber = phoneNumber, 
                            time = formattedTime,
                            coordinates = {x, y, z}
                        })

                        SetTimeout(Config.Settings.activebliptime * 60000, function()
                            RemoveBlip(radiusBlip)
                            for i, data in ipairs(radiusBlips) do
                                if data.radiusBlip == radiusBlip then
                                    table.remove(radiusBlips, i)
                                    break
                                end
                            end
                        end)
                    else
                        lib.notify({
                            description = locale('ejj_politisporing:notifydescription2'),
                            type = 'error'
                        })
                    end
                else
                    ClearPedTasks(cache.ped)
                    DeleteObject(tablet)
                end
            end
        },
        {
            title = locale('ejj_politisporing:title3'),
            description = locale('ejj_politisporing:description2'),
            icon = 'list',
            onSelect = function()
                local options = {}
                for i, data in ipairs(radiusBlips) do
                    local formattedPhoneNumber = string.format("%02d %02d %02d %02d", 
                        tostring(data.phoneNumber):sub(1,2), 
                        tostring(data.phoneNumber):sub(3,4), 
                        tostring(data.phoneNumber):sub(5,6), 
                        tostring(data.phoneNumber):sub(7,8))

                        local title = locale("ejj_politisporing:title4") .. ' ' .. i .. ' - ' .. formattedPhoneNumber
                        local description = locale('ejj_politisporing:description3') .. ' ' .. date.time

                    table.insert(options, {
                        title = title,  
                        description = description,  
                        onSelect = function()
                            RemoveBlip(data.radiusBlip)
                            table.remove(radiusBlips, i)
                            lib.notify({
                                description = locale('ejj_politisporing:notifydescription3'),
                                type = 'success'
                            })
                        end
                    })

                    table.insert(options, {
                        description = locale('ejj_politisporing:description4'),
                        progress = 100,
                        colorScheme = 'blue',
                        readOnly = true,
                    })
                end

                if #options > 0 then
                    lib.registerContext({
                        id = 'delete_radius_blips',
                        title = locale('ejj_politisporing:title5'),
                        canClose = true,
                        menu = 'police_phone_tracking',
                        onExit = function()
                            ClearPedTasks(cache.ped)
                            DeleteObject(tablet)
                        end,
                        options = options
                    })
                    lib.showContext('delete_radius_blips')
                else
                    lib.notify({
                        description = locale('There are no active tracking areas to delete.'),
                        type = 'error'
                    })
                    lib.showContext('police_phone_tracking')
                end
            end
        },
        {
            description = locale('ejj_politisporing:description4'),
            progress = 100,
            colorScheme = 'blue',
            readOnly = true,
        }
    }
})

local keybind = lib.addKeybind({
    name = 'phone_tracking',
    description = locale('ejj_politisporing:description5'),
    defaultKey = Config.Settings.defaultkey,
    onPressed = function()
        if ESX.PlayerData.job.name == Config.PoliceJob then
            lib.showContext('police_phone_tracking')

            lib.requestAnimDict('amb@code_human_in_bus_passenger_idles@female@tablet@idle_a', 10000)
            lib.requestModel('prop_cs_tablet', 10000)

            local boneIndex = GetPedBoneIndex(cache.ped, 28422)
            tablet = CreateObject(GetHashKey('prop_cs_tablet'), 0, 0, 0, true, true, false)
            AttachEntityToEntity(tablet, cache.ped, boneIndex, vector3(-0.05, 0.0, 0.0), vector3(0.0, -90.0, 0.0), true, true, false, true, 1, true)

            TaskPlayAnim(cache.ped, 'amb@code_human_in_bus_passenger_idles@female@tablet@idle_a', 'idle_a', 8.0, -8.0, -1, 50, 0, false, false, false)
        end
    end
})
