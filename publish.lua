local Settings,SaveSettings = {},nil do
    local settingsfile = io.open("settings.txt","w")
    local settingstable = {}
    for VarName,VarValue in string.gmatch(settingsfile:read() or "","(.-): (.-)\n") do
        settingstable[VarName] = VarValue
    end
    settingsfile:close()
    local settingsmt = {
        __newindex = function(self,key,value)
            value = string.gsub(value,"\n","%&&&TXTDATA-ES-NEWLINE&&&%")
            settingstable[key] = value
        end;
        __index = function(self,key)
            local value = settingstable[key] or ""
            value = string.gsub(value,"%&&&TXTDATA-ES-NEWLINE&&&%","\n")
            return value
        end;
    }
    setmetatable(Settings,settingsmt)

    SaveSettings = function()
        local Data = ""
        for VarName,VarValue in pairs(settingstable) do
            Data = Data .. VarName .. ": " .. VarValue
        end
        settingsfile = io.open("settings.txt","w")
        settingsfile:write(Data)
        settingsfile:close()
        return true
    end
end

os.execute("mkdocs build")
os.execute("git add .")
os.execute(("git commit -m '%s'"):format((Settings.commit_comment):format(Settings.commit_version)))
os.execute("git push")

Settings.commit_version = tostring(tonumber(Settings.commit_version) + 1)

SaveSettings()