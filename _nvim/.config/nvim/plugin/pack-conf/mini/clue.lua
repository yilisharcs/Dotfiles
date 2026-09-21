if vim.g.shell_editor then
    return
end

require("mini.clue").setup({
    triggers = {
        { mode = { "n", "x" }, keys = "<Leader>" },
        { mode = "i", keys = "<C-x>" },
        { mode = { "n", "x" }, keys = "g" },
        { mode = { "n", "x" }, keys = "'" },
        { mode = { "n", "x" }, keys = "`" },
        { mode = { "n", "x" }, keys = '"' },
        { mode = { "i", "c" }, keys = "<C-r>" },
        { mode = "n", keys = "[" },
        { mode = "n", keys = "]" },
        { mode = "n", keys = "<C-w>" },
        { mode = { "n", "x" }, keys = "z" },
    },
    clues = {
        require("mini.clue").gen_clues.builtin_completion(),
        require("mini.clue").gen_clues.g(),
        require("mini.clue").gen_clues.marks(),
        require("mini.clue").gen_clues.registers(),
        require("mini.clue").gen_clues.square_brackets(),
        require("mini.clue").gen_clues.windows({
            submode_resize = true,
            submode_move = true,
        }),
        require("mini.clue").gen_clues.z(),
        { mode = "n", keys = "zh", postkeys = "z", desc = "Scroll right" },
        { mode = "n", keys = "zl", postkeys = "z", desc = "Scroll left" },
        { mode = "n", keys = "zH", postkeys = "z", desc = "Scroll right half screen" },
        { mode = "n", keys = "zL", postkeys = "z", desc = "Scroll left half screen" },
    },
    window = {
        delay = 500,
        config = {
            width = math.floor(vim.o.columns * 0.27 - 0.5),
        },
    },
})
