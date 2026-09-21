if vim.g.shell_editor then
    return
end

require("mini.notify").setup({
    window = {
        max_width_share = vim.o.columns * 0.27 + 0.5,
        winblend = os.getenv("DISPLAY") and 25 or 0,
    },
})
_G.MiniNotify = MiniNotify

-- suppress luals progress spam
local ignore_progress = {
    "Diagnosing",
    "Diagnosing workspace",
    "Processing full semantic tokens",
}
local Client = require("vim.lsp.client")
---@diagnostic disable-next-line: invisible
local _notification = Client._notification
local suppressed = {}
--/@ ~/Projects/github.com/neovim/neovim/runtime/lua/vim/lsp/client.lua:1388
---@diagnostic disable-next-line: invisible
function Client:_notification(method, params)
    if method == "$/progress" then
        local kind = params.value and params.value.kind
        local id = ("%d\0%s"):format(self.id, tostring(params.token or ""))
        if kind == "begin" then
            local text = ("%s %s"):format(params.value.title or "", params.value.message or "")
            suppressed[id] = vim.iter(ignore_progress):any(function(pattern)
                return text:find(pattern, 1, true) ~= nil
            end)
        end
        if suppressed[id] then
            if kind == "end" then
                suppressed[id] = nil
            end
            return
        end
    end
    _notification(self, method, params)
end

vim.keymap.set("n", "<leader>n", function()
    MiniNotify.show_history()
end, { desc = "Notification history" })
