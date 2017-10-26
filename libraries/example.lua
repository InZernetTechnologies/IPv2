-- Example Module
-- By Assossa
-- Last Updated 2017.04.04.19.41

-- Required
function getModuleInformation()
    return {
        name = "example",
        version = "1.0.0",
        dependencies = {
            ["dependency1"] = "someDependency.lua"
        }
    }
end

-- Required
function load()
    print("Module loaded!")
end

-- Required
function unload()
    print("Module unloaded!")
end