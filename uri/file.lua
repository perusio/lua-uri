local M = { _NAME = "uri.file" }
local URI = require "uri"
URI._subclass_of(M, "uri._generic")

local Esc = require "uri.Escape"

M.DEFAULT_AUTHORITY = ""

-- Map from $^O values to implementation classes.  The Unix
-- class is the default.
M.OS_CLASS = {
    os2     = "OS2",
    mac     = "Mac",
    MacOS   = "Mac",
    MSWin32 = "Win32",
    win32   = "Win32",
    msdos   = "FAT",
    dos     = "FAT",
    qnx     = "QNX",
}

local os_module = {}
function M.os_class (os)
    if not os then os = what_the_hell_operating_system_is_this() end    -- TODO
    local class_name = "uri.file." .. (M.OS_CLASS[os] or "Unix")
    if os_module[class_name] then return os_module[class_name] end
    os_module[class_name] = require(class_name)
    return os_module[class_name]
end

function M.path (self, ...) return self:path_query(...) end
function M.host (self, ...)
    return Esc.uri_unescape(self:authority(...))
end

function M.new (class, path, os) return M.os_class(os):new(path) end

function M.new_abs (class, ...)
    local file = class:new(...)
    if file.uri:find("^file:") then
        return file
    else
        return file:abs(class:cwd())
    end
end

-- TODO - is there a Lua library which can give be the cwd?
--function cwd (class)
--    require Cwd;
--    my $cwd = Cwd::cwd();
--    $cwd = VMS::Filespec::unixpath($cwd) if $^O eq 'VMS';
--    $cwd = $class->new($cwd);
--    $cwd .= "/" unless substr($cwd, -1, 1) eq "/";
--    return $cwd;
--end

function M.canonical (self)
    local other = M._SUPER.canonical(self)

    local scheme = other:scheme()
    local auth = other:authority()
    if not scheme and not auth then return other end    -- relative

    if not auth or auth == "" or auth:lower() == "localhost" or
       (DEFAULT_AUTHORITY and auth:lower() == DEFAULT_AUTHORITY:lower()) then
        -- avoid cloning if $auth already match
        if (auth or DEFAULT_AUTHORITY) and
           (not auth or not DEFAULT_AUTHORITY or auth ~= DEFAULT_AUTHORITY) then
            if self == other then other = other:clone() end
            other:authority(DEFAULT_AUTHORITY)
        end
    end

    return other
end

function M.file (self, os) return M.os_class(os):file(self) end
function M.dir (self, os)  return M.os_class(os):dir(self)  end

return M
-- vi:ts=4 sw=4 expandtab
