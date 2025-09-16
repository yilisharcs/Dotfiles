return {
        "nvim-mini/mini.misc", -- see `:h MiniMisc.config`.
        version = false,
        event = "BufReadPost [^:]*",
        config = function()
                require("mini.misc").setup_auto_root({ ".git", ".jj" })
                require("mini.misc").setup_restore_cursor({ center = false })
        end
}
