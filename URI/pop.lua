-- RFC 2384
local _G = _G
module("URI.pop", package.seeall)
URI._subclass_of(_M, "URI._server")

function default_port () return 110 end

--pop://<user>;auth=<auth>@<host>:<port>

function user (self, ...)
    local old = self:userinfo()

    if _G.select('#', ...) > 0 then
        local new_info = old or ""
        new_info = new_info:gsub("^[^;]*", "", 1)

        local new = ...
        if not new and new_info == "" then
            self:userinfo(nil)
        else
            if not new then new = "" end
            new = new:gsub("%%", "%%25")
                     :gsub(";", "%%3B")
            self:userinfo(new .. new_info)
        end
    end

    if old then
        old = old:gsub(";.*", "", 1)
        return _G.URI.Escape.uri_unescape(old)
    end
end

function auth (self, ...)
    local old = self:userinfo()

    if _G.select('#', ...) > 0 then
        local new = old or ""
        local _, user_end, user = new:find("^([^;]*)")
        new = new:sub(user_end + 1)
        new = new:gsub(";[aA][uU][tT][hH]=[^;]*", "", 1)

        local auth = ...
        if auth then
            auth = auth:gsub("%%", "%%25")
                       :gsub(";", "%%3B")
            new = ";AUTH=" .. auth .. new
        end
        self:userinfo(user .. new)
    end

    if old then
        old = old:gsub("^[^;]*", "", 1)
        local _, _, oldauth = old:find(";[aA][uU][tT][hH]=(.*)")
        if oldauth then return _G.URI.Escape.uri_unescape(oldauth) end
    end
end

-- vi:ts=4 sw=4 expandtab
