return {
        cmd = { "lua-language-server" },
        filetypes = { "lua" },
        root_markers = {
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
                                        "vim",
                                        "Snacks",
                                        "P",
                                },
                                unusedLocalExclude = {
                                        "_*",
                                },
                        },
                        workspace = {
                                library = {
                                        "lua",
                                        vim.env.VIMRUNTIME,
                                        "${3rd}/luv/library",
                                },
                                checkThirdParty = false,
                        },
                        telemetry = { enable = false },
                },
        },
}
