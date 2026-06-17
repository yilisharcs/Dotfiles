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
                if type(params.workspaceFolders) ~= "table" or #params.workspaceFolders == 0 then
                        return
                end

                -- NOTE: rootPath can return vim.NIL userdata, which is truthy, which is not fun
                local root = params.workspaceFolders[1].name
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
                                checkThirdParty = false,
                                library = {
                                        "${3rd}/busted/library",
                                },
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
