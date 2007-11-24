local M = { _NAME = "uri._generic" }
local URI = require "uri"
URI._subclass_of(M, "uri")
M:_mix_in("uri._query")

local Util = require "uri._util"

local ACHAR = URI.uric:gsub("[/?]", "")
local PCHAR = URI.uric:gsub("%?", "")

function M._no_scheme_ok () return true end

local function _check_path (path, pre)
    local prefix = ""
    if pre:find("/") then   -- authority present
        if path ~= "" and not path:find("^[/?#]") then prefix = "/" end
    else
        if path:find("^//") then
            URI._warn("Path starting with double slash is confusing")
        elseif pre:len() == 0 and path:find("^[^:/?#]+:") then
            URI._warn("Path might look like scheme, './' prepended")
            prefix = "./"
        end
    end
    return prefix .. path
end

local function _split_segment (self, value)
    local Segment = require "uri._segment"
    return Segment:new(value)
end

function M.authority (self, ...)
    local uri = self.uri
    local _, scheme_end, scheme = uri:find("^(" .. URI.scheme_re .. ":)")
    if not scheme_end then scheme_end = 0; scheme = "" end
    local _, auth_end, auth = uri:find("^//([^/?#]*)", scheme_end + 1)
    if not auth_end then auth_end = scheme_end end

    if select('#', ...) > 0 then
        local new_auth = ...
        if new_auth then
            self.uri = scheme .. "//" .. Util.uri_escape(new_auth, "^" .. ACHAR)
        else
            self.uri = scheme
        end
        self.uri = self.uri .. _check_path(uri:sub(auth_end + 1), self.uri)
    end

    return auth
end

local function _split_at_start_of_path (uri)
    local _, auth_start = uri:find("^[^:/?#]+:")
    auth_start = auth_start and auth_start + 1 or 1
    local _, auth_end = uri:find("//[^/?#]*", auth_start)
    auth_end = auth_end and auth_end + 1 or auth_start
    return uri:sub(1, auth_end - 1), uri:sub(auth_end)
end

function M.path (self, ...)
    local before_path, path_etc = _split_at_start_of_path(self.uri)
    local _, path_end, path = path_etc:find("([^?#]*)")

    if select('#', ...) > 0 then
        local new_path = ... or ""
        new_path = Util.uri_escape(new_path, "^" .. PCHAR)
        self.uri = before_path .. _check_path(new_path, before_path) ..
                   path_etc:sub(path_end + 1)
    end

    return path
end

function M.path_query (self, ...)
    local before_path, path_etc = _split_at_start_of_path(self.uri)
    local _, path_end, path = path_etc:find("([^#]*)")

    if select('#', ...) > 0 then
        local new_path = ... or ""
        new_path = Util.uri_escape(new_path, "^" .. URI.uric)
        self.uri = before_path .. _check_path(new_path, before_path)
                   path_etc:sub(path_end + 1)
    end

    return path
end

function M.path_segments (self, arg)
    local path = self:path()

    if arg then
        local new = {}
        for _, seg in ipairs(arg) do
            if type(seg) == "table" then
                local segcpy = {}
                for i, v in ipairs(seg) do segcpy[i] = v end
                segcpy[1] = segcpy[1]:gsub("%%", "%%25")
                for i, v in segcpy do segcpy[i] = v:gsub(";", "%%3B") end
                seg = table.concat(segcpy, ";")
            else
                seg = seg:gsub("%%", "%%25")
                         :gsub(";", "%%3B")
            end
            new[#new + 1] = seg:gsub("/", "%%2F")
        end
        self:path(table.concat(new, "/"))
    end

    local segs = URI._split("/", path)
    for i, v in ipairs(segs) do
        if v:find(";") then
            segs[i] = self:_split_segment(v)
        else
            segs[i] = Util.uri_unescape(v)
        end
    end
    return segs
end

function M.abs (self, base)
    if not base then error"Missing base argument" end
    if self:scheme() then return self end

    if type(base) == "string" then base = URI:new(base) end
    local abs = M:new(self)
    abs:scheme(base:scheme())
    -- TODO - it should never match scheme_re or we'd have returned above
    if self.uri:find("^" .. URI.scheme_re .. "://") or
       self.uri:find("^//") then return abs end
    abs:authority(base:authority())

    local path = self:path()
    if path:find("^/") then return abs end

    if path == "" then
        local abs = M:new(base)
        local query = self:query()
        if query then abs:query(query) end
        abs:fragment(self:fragment())
        return abs
    end

    local p = base:path():gsub("[^/]+$", "", 1) .. path
    p = p:gsub("^/", "", 1)
    local ap = URI._split("/", p)
    if #ap > 0 and ap[1] == "" then table.remove(ap, 1) end
    local i = 1
    while i < #ap do
        if ap[i] == "." then
            table.remove(ap, i)
            if i > 1 then i = i - 1 end
        elseif ap[i + 1] == ".." and ap[i] ~= ".." then
            table.remove(ap, i)
            table.remove(ap, i)
            if i > 1 then
                i = i - 1
                if i == #ap then ap[#ap + 1] = "" end
            end
        else
            i = i + 1
        end
    end
    if #ap > 0 and ap[#ap] == "." then ap[#ap] = "" end     -- trailing "/."

    abs:path("/" .. table.concat(ap, "/"))
    return abs
end

local function _abs_path_without_slash (path)
    return path:find("/") and path or "/" .. path
end

local function _count_slashes (path)
    local count = 0
    for _ in path:gmatch("/") do count = count + 1 end
    return count
end

-- The oposite of $url->abs.  Return a URI which is as relative as possible
function M.rel (self, base)
    if not base then error"Missing base argument" end
    local rel = M:new(self)
    if type(base) ~= "table" then base = URI:new(base) end

    local scheme = rel:scheme()
    -- TODO - why doesn't authority() return a canonical authority anyway?
    local auth   = rel:canonical():authority()
    local path   = rel:path()

    if not scheme and not auth then return rel end  -- it is already relative

    local bscheme = base:scheme() or ""
    local bauth   = base:canonical():authority() or ""
    local bpath   = base:path()
    if not auth then auth = "" end

    -- different location, can't make it relative
    if scheme ~= bscheme or auth ~= bauth then return rel end

    path  = _abs_path_without_slash(path)
    bpath = _abs_path_without_slash(bpath)

    -- Make it relative by eliminating scheme and authority
    rel:scheme(nil)
    rel:authority(nil)

    -- This loop is based on code from Nicolai Langfeldt <janl@ifi.uio.no>.
    -- First we calculate common initial path components length (li).
    local li = 2
    while true do
        local i = path:find("/", li)
        if not i or i ~= bpath:find("/", li) or
           path:sub(li, i - 1) ~= bpath:sub(li, i - 1) then break end
        li = i + 1
    end
    -- then we nuke it from both paths
    path = path:sub(li)
    bpath = bpath:sub(li)

    if path == bpath and rel:fragment() and not rel:query() then
        rel:path("")
    else
        -- Add one "../" for each path component left in the base path
        path = ("../"):rep(_count_slashes(bpath)) .. path
        rel:path(path == "" and "./" or path);
    end

    return rel
end

return M
-- vi:ts=4 sw=4 expandtab
