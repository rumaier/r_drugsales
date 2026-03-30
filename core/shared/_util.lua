Language = Language or {}

function roll(odds)
    return math.random() < odds
end

function locale(key, ...)
    local locale = Cfg.Language
    if not key then
        return 'ERR_TRANSLATE_NO_KEY'
    end
    local string = Language[locale] and Language[locale][key]
    if not string then
        return 'ERR_TRANSLATE_'..locale..'_'..key
    end
    return string:format(...)
end

function _debug(...)
    if not Cfg.Debug then return end
    print('[^6DEBUG^0] ' .. ...)
end

function _error(...)
    if not Cfg.Debug then return false end
    print('[^1ERROR^0] ' .. ...)
    return false
end
