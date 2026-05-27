-- HACK: return a fake success response when `gx` calls `cmd:wait(1000)`. why so? because
-- `xdg-open` finishes after a full second, so i get a spurious 124: command timeout error.
local _ui_open = vim.ui.open
---@diagnostic disable-next-line: duplicate-set-field
vim.ui.open = function(path, opt)
        local cmd, err = _ui_open(path, opt)
        if cmd then
                cmd.wait = function()
                        return { code = 0 }
                end
        end
        return cmd, err
end
