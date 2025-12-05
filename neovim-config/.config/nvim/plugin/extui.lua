if not vim.g.neovide then
        require("vim._extui").enable({
                enable = true,
                msg = {
                        target = "cmd",
                        timeout = 4000,
                },
        })
end
