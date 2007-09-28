local M = { _NAME = "uri._server" }
local URI = require "uri"
URI._subclass_of(M, "uri._generic")

local Esc = require "uri.Escape"

function M.userinfo (self, ...)
    local old = self:authority()

    if select('#', ...) > 0 then
        local ui = ...
        local new = old or ""
        new = new:gsub(".*@", "", 1)    -- remove old stuff
        if ui then
            ui = ui:gsub("@", "%%40")   -- protect @
            new = ui .. "@" .. new
        end
        self:authority(new)
    end

    if old then
        local _, _, ui = old:find("(.*)@")
        return ui
    end
end

function M.host (self, ...)
    local old = self:authority()

    if select('#', ...) > 0 then
        local tmp = old or ""
        local _, _, ui = tmp:find("(.*@)")
        if not ui then ui = "" end
        local _, _, port = tmp:find("(:%d+)$")
        if not port then port = "" end
        local new = ... or ""
        if new ~= "" then
            new = new:gsub("@", "%%40") -- protect @
            local port_start, _, newtmp, porttmp = new:find("(.*)(:%d+)$")
            if port_start then new = newtmp; port = porttmp end
        end
        self:authority(ui .. new .. port)
    end

    if old then
        return Esc.uri_unescape(old:gsub("^.*@", "", 1)
                                             :gsub(":%d+$", "", 1))
    end
end

function M._port (self, ...)
    local old = self:authority()
    if select('#', ...) > 0 then
        local new = old
        new = new:gsub(":%d*$", "", 1)
        local port = ...
        if port then new = new .. ":" .. port end
        self:authority(new)
    end
    if old then
        local _, _, port = old:find(":(%d+)$")
        if port and port ~= "0" then return tonumber(port) end
    end
end

function M.port (self, ...)
    return self:_port(...) or self:default_port()
end

function M.host_port (self, ...)
    local old = self:authority()
    if select('#', ...) > 0 then self:host(...) end
    if not old then return end
    old = old:gsub(".*@", "", 1)        -- zap userinfo
             :gsub(":$", "", 1)         -- empty port does not could
    if old:find(":") then
        return old
    else
        return old .. ":" .. self:port()
    end
end

function M.default_port () return nil end

function M.canonical (self)
    local other = M._SUPER.canonical(self)
    local host = other:host() or ""
    local port = other:_port()
    local uc_host = host:find("[A-Z]")
    local def_port = port and (port == "" or port == self:default_port())
    if uc_host or def_port then
        if other == self then other = other:clone() end
        if uc_host then other:host(host:lower()) end
        if def_port then other:port(nil) end
    end
    return other
end

return M
-- vi:ts=4 sw=4 expandtab
