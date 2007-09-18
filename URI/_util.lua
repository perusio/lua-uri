local M = { _MODULE_NAME = "uri._util" }

-- TODO - wouldn't this be better as a method on string?  s:split(patn)
function M.split (patn, s, max)
    if s == "" then return {} end

    local i, j = 1, string.find(s, patn)
    if not j then return { s } end

    local list = {}
    while true do
        if #list + 1 == max then list[max] = s:sub(i); return list end
        list[#list + 1] = s:sub(i, j - 1)
        i = j + 1
        j = string.find(s, patn, i)
        if not j then
            list[#list + 1] = s:sub(i)
            break
        end
    end
    return list
end

function M.attempt_require (modname)
    local ok, result = pcall(require, modname)
    if ok then
        return result
    elseif type(result) == "string" and
           result:find("module '.*' not found") then
        return nil
    else
        error(result)
    end
end

function M.subclass_of (class, baseclass_name)
    local baseclass = baseclass_name == "URI" and M or require(baseclass_name)
    class.__index = class
    class._SUPER = baseclass
    class.__tostring = M.__tostring     -- not inherited
    setmetatable(class, baseclass)
end

function M.mix_in (class, mixin_name)
    local mixin = require(mixin_name)
    for name, value in pairs(mixin) do
        if name:sub(1, 1) ~= "_" then
            class[name] = value
        end
    end
end

return M
-- vi:ts=4 sw=4 expandtab
