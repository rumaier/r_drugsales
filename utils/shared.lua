Language = Language or {}

---@param str string -- Name of the string to pull from the locale file
function _L(str, ...)
    if str then
        local string = Language[Cfg.Server.language][str]
        if string then
            return string.format(string, ...)
        else
            return "ERR_TRANSLATE_"..(str).."_404"
        end
    else
        return "ERR_TRANSLATE_404"
    end
end

math.lerp = function(a, b, t)
    return a + (b - a) * t
end