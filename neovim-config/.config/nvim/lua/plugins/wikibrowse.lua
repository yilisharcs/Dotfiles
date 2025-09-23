return {
        "yilisharcs/wikibrowse.nvim",
        enabled = false,
        dev = true,
        lazy = false,
        cmd = "WikiBrowse",
        keys = {
                { "<leader>e", "<CMD>WikiBrowse pizza<CR>" },
        },
        init = function()
                vim.keymap.set("ca", "wiki", "(getcmdtype() ==# ':' && getcmdline() =~# '^wiki') ? 'WikiBrowse' : 'wiki'",
                        { expr = true })
        end,
        opts = true
}
