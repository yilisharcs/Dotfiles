return {
        "nvim-mini/mini.splitjoin", -- see `:h MiniSplitjoin.config`.
        version = false,
        keys = {
                "gJ", desc = "Separate arguments by line"
        },
        opts = {
                mappings = {
                        toggle = "gJ",
                },
        }
}
