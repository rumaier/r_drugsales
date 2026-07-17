Language = Language or {}

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