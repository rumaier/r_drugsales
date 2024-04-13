RegisterNetEvent('r_drugsales:dataCheck')
AddEventHandler('r_drugsales:dataCheck', function(coords, info, qty)
    local src = source
    local dist = #(coords[1] - coords[2])
    local hasItem = SvInvCheck(info["drug"])
    if dist > 5 then return end
    if hasItem["count"] < qty then return end
    local pay = info.pay * qty
    SvRemoveItem(src, hasItem["name"], qty)
    SvAddMoney(src, pay)
    SvNotify('You sold x'.. qty ..' '.. hasItem["label"] ..' for $'.. pay ..'', 'info')
end)

print('ServerSide Is Loaded [r_drugsales, Disco shit... Pure as the driven snow.]')
print('Why did the duck go to the drug dealer?')
print('Quack.')