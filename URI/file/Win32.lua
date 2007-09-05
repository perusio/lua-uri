local _G = _G
module("URI.file.Win32", package.seeall)
URI._subclass_of(_M, "URI.file.Base")

function _file_extract_authority (class, path)
    if _G.URI.file.DEFAULT_AUTHORITY then
        return _SUPER._file_extract_authority(class, path)
    end

    local _, skipchars, auth = path:find("^\\\\([^\\]+)")   -- UNC
    if auth then return path:sub(skipchars + 1), auth end
    _, skipchars, auth = path:find("^//([^/]+)")            -- UNC too?
    if auth then return path:sub(skipchars + 1), auth end

    _, skipchars, auth = path:find("^([a-zA-Z]:)")
    if auth then
        path = path:sub(skipchars + 1)
        if path:find("^[\\/]") then auth = auth .. "relative" end
        return path, auth
    end

    return path, nil
end

function _file_extract_path (class, path)
    path = path:gsub("\\", "/")
    --$path =~ s,//+,/,g;
    while path:find("/%./") do path = path:gsub("/%./", "/") end

    if _G.URI.file.DEFAULT_AUTHORITY then
        path = path:gsub("^([a-zA-Z]:)", "/%1", 1)
    end

    return path, false
end

function _file_is_absolute (class, path)
    return path:find("^[a-zA-Z]:") or path:find("^[/\\]")
end

function file (class, uri)
    local auth = uri:authority()
    local isrel     -- is filename relative to drive specified in authority
    if auth then
        auth = _G.URI.Escape.uri_unescape(auth)
        local _, _, drive, isrel_ = auth:find("^([a-zA-Z])[:|](relative)")
        if not drive then
            _, _, drive = auth:find("^([a-zA-Z])[:|]")
        end
        if drive then
            auth = drive:upper() .. ":"
            if isrel_ then isrel = true end
        elseif auth:lower() == "localhost" then
            auth = ""
        elseif auth ~= "" then
            auth = "\\\\" .. auth   -- UNC
        end
    else
        auth = ""
    end

    local pathsegs = uri:path_segments()
    for _, v in _G.ipairs(pathsegs) do
        if v:find("%z") or v:find("/") then return end
        --return undef if /\\/;        -- URLs with "\" is not uncommon
    end
    if not class:fix_path(pathsegs) then return end

    local path = _G.URI._join("\\", pathsegs)
    if isrel then path = path:gsub("^\\", "", 1) end
    path = auth .. path
    path = path:gsub("^\\([a-zA-Z])[:|]", function (drive)
        return drive:upper() .. ":"
    end, 1)

    return path
end

function fix_path () return true end

-- vi:ts=4 sw=4 expandtab
