Language = Language or {}
Cfg = Cfg or {}

function locale(key, ...)
    local language = Cfg.Language or 'en'
    if not key then
        return 'ERR_TRANSLATE_NO_KEY'
    end
    local string = Language[language] and Language[language][key]
    if not string then
        return 'ERR_TRANSLATE_' .. language .. '_' .. key
    end
    return string:format(...)
end

function _debug(...)
    if not Cfg or not Cfg.Debug then return end
    print('[^6DEBUG^0] ' .. ...)
end

function isPointInPolygon(point, polygon)
    local x, y = point.x, point.y
    local inside = false
    local j = #polygon
    for i = 1, #polygon do
        local xi, yi = polygon[i].x, polygon[i].y
        local xj, yj = polygon[j].x, polygon[j].y
        if ((yi > y) ~= (yj > y)) and (x < (xj - xi) * (y - yi) / (yj - yi) + xi) then
            inside = not inside
        end
        j = i
    end
    return inside
end

function isPointInZones(coords, zones)
    for i = 1, #zones do
        if isPointInPolygon(coords, zones[i]) then
            return true
        end
    end
    return false
end
