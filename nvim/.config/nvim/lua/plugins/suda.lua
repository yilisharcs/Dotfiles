return {
        "lambdalisue/suda.vim",
        init = function()
                vim.keymap.set("ca", "sudo", "(getcmdtype() ==# ':' && getcmdline() =~# '^sudo') ? 'SudaWrite' : 'sudo'",
                        { expr = true })
        end
}
