if vim.g.shell_editor then
    return
end

package.preload["nvim-web-devicons"] = function()
    require("mini.icons").mock_nvim_web_devicons()
    return package.loaded["nvim-web-devicons"]
end

require("mini.icons").setup({
    filetype = {
        c = { glyph = "" },
        nu = { hl = "MiniIconsGreen" },
    },
    extension = {
        lemon = {
            glyph = "",
            hl = "MiniIconsYellow",
        },
    },
    file = {
        ["init.lua"] = { glyph = "󰢱" },
    },
})
