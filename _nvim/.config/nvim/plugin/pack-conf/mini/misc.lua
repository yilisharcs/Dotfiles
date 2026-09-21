if vim.g.shell_editor then
    return
end

require("mini.misc").setup_auto_root({ ".git", ".jj" })
require("mini.misc").setup_restore_cursor({ center = false })
