return {
        "dhruvasagar/vim-table-mode",
        event = { "InsertEnter *.md", "InsertEnter *.txt" },
        cmd = { "Tableize" },
        init = function()
                vim.g.table_mode_disable_mappings = 1
        end
}
