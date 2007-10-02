local M = { _NAME = "uri.file.Mac" }
local URI = require "uri"
URI._subclass_of(M, "uri.file.Base")

local Util = require "uri._util"

function M._file_extract_path (class, path)
    local pre = {}

    local _, num_colons_at_start = path:find("^:*")
    if num_colons_at_start > 0 then
        path = path:sub(num_colons_at_start + 1)    -- strip initial colons
        if num_colons_at_start == 1 then
            if path == "" then pre[1] = "." end
        else
            for _ = 1, num_colons_at_start - 1 do pre[#pre + 1] = ".." end
        end
    else    --absolute
        pre[1] = ""
    end

    local isdir
    path, isdir = path:gsub(":$", "", 1)
    isdir = isdir ~= 0
    path = Util.uri_escape(path, "%%/;")

    local pathsegs = URI._split(":", path)
    for i, v in ipairs(pathsegs) do
        if v == "." or v == ".." then
            v = ("%2E"):rep(v:len())
        end
        if v == "" then v = ".." end
        pathsegs[i] = v
    end
    if isdir then pathsegs[#pathsegs + 1] = "" end

    for _, v in ipairs(pathsegs) do pre[#pre + 1] = v end
    return table.concat(pre, "/"), true
end

function M.file (class, uri)
    local path = {}

    local auth = uri:authority()
    if auth then
        if auth:lower() ~= "localhost" and auth ~= "" then
            local u_auth = Util.uri_unescape(auth)
            if not class:_file_is_localhost(u_auth) then
                -- some other host (use it as volume name)
                path[1] = ""
                path[2] = auth
                -- XXX or just return to make it illegal;
            end
        end
    end
    local ps = URI._split("/", uri:path())
    if #path > 0 then table.remove(ps, 1) end
    for _, v in ipairs(ps) do path[#path + 1] = v end

    local pre = ""
    if #path == 0 then
        return  -- empty path; XXX return ":" instead?
    elseif path[1] == "" then
        -- absolute
        table.remove(path, 1)
        if #path == 1 then
            if path[1] == "" then return end    -- not root directory
            path[#path + 1] = ""        -- volume only, effectively append ":"
        end

        -- TODO - this stuff up to the end of the elseif are duplicated
        -- Move all elements in path to ps
        while #ps > 0 do table.remove(ps) end
        for i, v in ipairs(path) do ps[i] = path[i] end
        while #path > 0 do table.remove(path) end

        --fix up "." and "..", including interior, in relatives
        for _, v in ipairs(ps) do
            if v ~= "." then
                path[#path + 1] = (v == "..") and "" or v
            end
        end

        if ps[#ps] == ".." then     --if this happens, we need another :
            path[#path + 1] = ""
        end
    else
        pre = ":"

        -- Move all elements in path to ps
        while #ps > 0 do table.remove(ps) end
        for i, v in ipairs(path) do ps[i] = path[i] end
        while #path > 0 do table.remove(path) end

        --fix up "." and "..", including interior, in relatives
        for _, v in ipairs(ps) do
            if v ~= "." then
                path[#path + 1] = (v == "..") and "" or v
            end
        end

        if ps[#ps] == ".." then     --if this happens, we need another :
            path[#path + 1] = ""
        end
    end
    if pre == "" and #path == 0 then return end
    for i, v in ipairs(path) do
        v = v:gsub(";.*", "", 1)    -- get rid of parameters
        --return unless length; -- XXX
        v = Util.uri_unescape(v)
        if v:find("%z") or v:find(":") then return end  -- Should we for ':'?
        path[i] = v
    end
    return pre .. table.concat(path, ":")
end

function M.dir (class, ...)
    local path = class:file(...)
    if not path then return end
    if not path:find(":$") then path = path .. ":" end
    return path
end

return M
-- vi:ts=4 sw=4 expandtab
