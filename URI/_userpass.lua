module("URI._userpass", package.seeall)

function user (self, ...)
    local info = self:userinfo()
    local colon = info and info:find(":")

    if _G.select('#', ...) > 0 then
        local pass = colon and info:sub(colon) or ""    -- includes colon
        local new = ...
        if not new and pass == "" then
            self:userinfo(nil)
        else
            if not new then new = "" end
            new = new:gsub("%%", "%%25")
                     :gsub(":", "%%3A")
            self:userinfo(new .. pass)
        end
    end

    if not info then return end
    if colon then info = info:sub(1, colon - 1) end
    return URI.Escape.uri_unescape(info)
end

function password (self, ...)
    local info = self:userinfo()
    local colon = info and info:find(":")

    if _G.select('#', ...) > 0 then
        local new = ...
        local user = colon and info:sub(1, colon - 1) or info
        if not new and user == "" then
            self:userinfo(nil)
        else
            if not new then new = "" end
            new = new:gsub("%%", "%%25")
            self:userinfo(user .. ":" .. new)
        end
    end

    if not colon then return end
    return URI.Escape.uri_unescape(info:sub(colon + 1))
end

-- vi:ts=4 sw=4 expandtab
