Cfg = Cfg or {}

local LOG = {
    debug = { color = 6, tag = 'DEBUG', enabled = true },
    warn = { color = 3, tag = 'WARN', enabled = true },
    error = { color = 1, tag = 'ERROR', enabled = true },
}

Language = Language or {}

function locale(key, ...)
    if not key then
        return 'ERR_TRANSLATE_NO_KEY'
    end
    local lang = (Cfg and Cfg.Language) or 'en'
    local string = Language[lang] and Language[lang][key]
    if not string then
        return 'ERR_TRANSLATE_' .. lang .. '_' .. key
    end
    return string:format(...)
end

---@param level 'debug' | 'warn' | 'error'
function log(level, ...)
    local cfg = LOG[level]
    if not cfg then return end
    if level == 'debug' and not (Cfg and Cfg.Debug) then return end
    if not cfg.enabled then return end
    print(('[^%d%s^0] %s'):format(cfg.color, cfg.tag, ...))
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
