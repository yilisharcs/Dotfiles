local root_markers = {
        {
                ".luarc.json",
                ".luarc.jsonc",
                "luarc.json",
                "luarc.jsonc",
        },
        "lua",
        ".nvim.lua",
}

return {
        cmd = { "lua-language-server" },
        filetypes = { "lua" },
        root_markers = root_markers,
        before_init = function(params, config)
                local root = params.rootPath
                if not root then
                        return
                end

                for _, file in ipairs(root_markers[1]) do
                        if vim.uv.fs_stat(root .. "/" .. file) then
                                config.settings.Lua = nil
                                return
                        end
                end
        end,
        settings = {
                Lua = {
                        runtime = {
                                version = "Lua 5.5",
                        },
                        workspace = {
                                library = {
                                        "${3rd}/busted/library",
                                },
                                checkThirdParty = false,
                        },
                        diagnostics = {
                                unusedLocalExclude = {
                                        "_*",
                                },
                                groupFileStatus = {
                                        ambiguity = "Any",
                                        duplicate = "Any",
                                        global = "Any",
                                        luadoc = "None",
                                        redefined = "Any",
                                        strict = "Any",
                                        strong = "None",
                                        ["type-check"] = "Any",
                                        unbalanced = "Any",
                                        unused = "Any",
                                },
                        },
                        hint = {
                                enable = true,
                                setType = true,
                                paramType = true,
                                paramName = "All",
                        },
                },
        },
}
