-- TODO: remove on stable
if vim.version().minor < 12 then return end

require("vim._core.ui2").enable({
        enable = true,
        msg = {
                target = "cmd",
                timeout = 4000,
        },
})
