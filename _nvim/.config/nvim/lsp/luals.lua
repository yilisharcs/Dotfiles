return {
        cmd = { "lua-language-server" },
        filetypes = { "lua" },
        root_markers = {
                "lua",
                {
                        ".luarc.json",
                        ".luarc.jsonc",
                },
                ".nvim.lua",
        },
        settings = {
                Lua = {
                        runtime = {
                                version = "LuaJIT",
                                path = {
                                        "./lua/?.lua",
                                        "./lua/?/init.lua",
                                },
                        },
                        diagnostics = {
                                globals = {
                                        "P",
                                },
                                unusedLocalExclude = {
                                        "_*",
                                },
                                neededFileStatus = {
                                        ["codestyle-check"] = "Opened",
                                        ["doc-check"] = "Opened",
                                        ["type-check"] = "Opened",
                                },
                                groupFileStatus = {
                                        ambiguity = "Any",
                                        duplicate = "Any",
                                        global = "Any",
                                        luadoc = "Any",
                                        redefined = "Any",
                                        strict = "Any",
                                        strong = "Any",
                                        type = "Any",
                                        unbalanced = "Any",
                                        unused = "Any",
                                },
                        },
                        workspace = {
                                library = {
                                        "lua",
                                },
                                checkThirdParty = false,
                        },
                        hint = {
                                enable = true,
                                setType = true,
                                paramType = true,
                                paramName = "All",
                        },
                        telemetry = { enable = false },
                },
        },
}
