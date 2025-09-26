local icons_cond
local icon_rightpad
local component_separators
local section_separators

if os.getenv("DISPLAY") == nil then
        icons_cond           = false
        icon_rightpad        = 1
        section_separators   = { left = '>', right = '<' }
        component_separators = { left = '|', right = '|' }
else
        icons_cond           = true
        icon_rightpad        = 0
        section_separators   = { left = "", right = "" }
        component_separators = { left = "", right = "" }
end

local diagnostic_cond = function()
        if vim.api.nvim_win_get_width(0) < 80 then
                return false
        else
                return true
        end
end

return {
        "nvim-lualine/lualine.nvim",
        dependencies = { "nvim-tree/nvim-web-devicons" },
        init = function()
                vim.go.showmode = false
        end,
        opts = {
                options = {
                        icons_enabled        = icons_cond,
                        section_separators   = section_separators,
                        component_separators = component_separators,
                        theme                = {
                                normal = {
                                        a = "LualineNormalA",
                                        b = "LualineNormalB",
                                        c = "LualineNormalC",
                                },
                                insert = {
                                        a = "LualineInsertA",
                                        b = "LualineInsertB",
                                },
                                terminal = {
                                        a = "LualineTerminalA",
                                        b = "LualineTerminalB",
                                },
                                visual = {
                                        a = "LualineVisualA",
                                        b = "LualineVisualB",
                                },
                                replace = {
                                        a = "LualineReplaceA",
                                        b = "LualineReplaceB",
                                },
                                command = {
                                        a = "LualineCommandA",
                                        b = "LualineCommandB",
                                },
                                inactive = {
                                        a = "LualineInactiveA",
                                        b = "LualineInactiveB",
                                        c = "LualineInactiveC",
                                },
                        },
                },
                sections = {
                        lualine_a = { "branch" },
                        lualine_b = {
                                { "diff",        cond = diagnostic_cond },
                                { "diagnostics", cond = diagnostic_cond },
                                {
                                        "filetype",
                                        icon_only = true,
                                        padding = { left = 1, right = icon_rightpad }
                                },
                        },
                        lualine_c = { { "filename", path = 1 } },
                        lualine_x = {
                                {
                                        function()
                                                local macro = vim.fn.reg_recording()
                                                if macro == "" then return "" end
                                                return "recording @" .. vim.fn.reg_recording()
                                        end,
                                        padding = { left = 0, right = 1 },
                                        separator = { right = "" },
                                        color = { fg = "#fab387", gui = "bold" },
                                },
                                {
                                        "searchcount",
                                        maxcount = 999,
                                        timeout = 500,
                                        separator = { right = "" },
                                        color = { fg = "#e0d561", gui = "bold" }
                                },
                                { "location", padding = 2 }
                        },
                        lualine_y = { "progress" },
                        lualine_z = { "mode" }
                },
                inactive_sections = {
                        lualine_a = { "branch" },
                        lualine_b = {
                                { "diff",        cond = diagnostic_cond },
                                { "diagnostics", cond = diagnostic_cond },
                                {
                                        "filetype",
                                        icon_only = true,
                                        padding = { left = 1, right = icon_rightpad }
                                },
                        },
                        lualine_c = { { "filename", path = 0 } },
                        lualine_x = { { "location", padding = 2 } },
                        lualine_y = { "progress" },
                        lualine_z = {},
                },
                extensions = {
                        "man",
                        "quickfix",
                        "toggleterm",
                }
        }
}
