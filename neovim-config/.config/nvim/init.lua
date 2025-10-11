vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Expose socket env variable outside of nvim
vim.env.NVIM_LISTEN_SOCKET = vim.v.servername

if string.match(vim.v.argv[#vim.v.argv], "^/tmp/%S+%.nu$") ~= nil then
        vim.g.shell_editor = true
end

vim.keymap.set("n", "-", "<CMD>Ex<CR>", { desc = "Fallback file explorer " })
vim.keymap.set("ca", "grep", function()
        if vim.fn.getcmdtype() == ":" then
                local cmd = vim.fn.getcmdline()
                if cmd:match("^grep") then return "silent grep" else return "grep" end
        end
end, { expr = true, desc = "Fallback grep command" })

-- EDITOR OPTIONS {{{
-- Enable project-local configuration
vim.o.exrc = true

-- Sync clipboard between OS and Neovim
vim.opt.clipboard:append({ "unnamedplus" })
vim.g.clipboard = "xclip"

vim.cmd("aunmenu PopUp.How-to\\ disable\\ mouse")
vim.cmd("aunmenu PopUp.-2-")

-- Long-running undo trees
vim.o.swapfile = false
vim.o.undofile = true

vim.o.grepprg = "vimgrep.nu"
vim.o.spelllang = "en_us"

vim.o.ignorecase = true
vim.o.smartcase = true
vim.o.wrap = false
vim.o.linebreak = true
vim.o.scrolloff = 4
vim.o.sidescrolloff = 4

-- Indenting
vim.o.tabstop = 8
vim.o.softtabstop = 8
vim.o.shiftwidth = 8
vim.o.expandtab = true
vim.o.smartindent = true

vim.o.number = true
vim.o.relativenumber = true
vim.o.cursorline = true
vim.o.cursorlineopt = "number"

-- Hide search finish warning
vim.opt.shortmess:append({ s = true })

-- Proper splits
vim.o.splitright = true
vim.o.splitbelow = true

vim.o.tabclose = "uselast"

vim.o.foldcolumn = "1"
vim.o.foldmethod = "marker"
vim.o.foldlevel = 0

vim.o.numberwidth = 3
vim.o.signcolumn = "yes:1"
vim.o.statuscolumn = "%C%l%s"

vim.opt.isfname:append({ "@-@" })

vim.o.pumheight = math.floor(vim.o.lines * 0.25 + 0.5)
vim.o.completeopt = "noinsert,menuone,popup,fuzzy"

-- Ctrl-a/x doesn't recognize signed numbers
vim.opt.nrformats:append({ "unsigned" })

-- No more ~ on empty buffer space
vim.o.fillchars = "eob: "

vim.o.guicursor = "a:block,c-ci-i-r:blinkwait700-blinkoff700-blinkon700"

vim.opt.diffopt:prepend({ "algorithm:patience", "hiddenoff" })

-- Terminal scrollback
vim.o.scrollback = 100000

vim.o.updatetime = 1000
vim.o.virtualedit = "block"
vim.o.winborder = "rounded"

-- Rusty-tags support with custom tagfile name
vim.opt.tags:append({ "./rtags", ",rtags" })

vim.o.shell = vim.fn.exepath("bash")
if vim.fn.exepath("nu") ~= "" then
        vim.o.shell = vim.fn.exepath("nu")
        vim.o.shelltemp = false
        vim.o.shellredir = "o+e> %s"
        vim.o.shellcmdflag = "--no-config-file --no-newline --stdin -c"
        vim.o.shellpipe =
        "| complete | update stderr { ansi strip } | tee { get stderr | save --force --raw %s } | into record"

        vim.keymap.set("ca", "nu", function()
                if vim.fn.getcmdtype() == ":" then
                        local cmd = vim.fn.getcmdline()
                        if cmd:match("^('<,'>)!nu")
                            or cmd:match("^%.!nu")
                            or cmd:match("^%.,%$!nu")
                            or cmd:match("^%.,%.%+%d+!nu")
                        then
                                return "nu -c $in"
                        else
                                return "nu"
                        end
                end
        end, { expr = true })
end

-- Display vs TTY
vim.o.list = true
vim.o.termguicolors = true
vim.opt_global.listchars = { nbsp = "␣", tab = "› ", trail = "•" }

if os.getenv("DISPLAY") == nil then
        vim.o.termguicolors = false
end

vim.cmd.colorscheme("tricky")
-- }}}

vim.pack.add({
        -- { src = "https://github.com/saghen/blink.cmp" },
        -- -- dependencies = { "rafamadriz/friendly-snippets" },
        -- -- version = "1.*",
        -- -- opts = {
        -- --         keymap = {
        -- --                 preset = "none",
        -- --                 ["<C-t>"] = { "show", "show_documentation", "hide_documentation", "fallback" },
        -- --                 ["<C-l>"] = { "hide", "fallback" },
        -- --                 ["<C-p>"] = { "select_prev", "fallback" },
        -- --                 ["<C-n>"] = { "select_next", "fallback" },
        -- --                 ["<C-u>"] = { "scroll_documentation_up", "fallback" },
        -- --                 ["<C-d>"] = { "scroll_documentation_down", "fallback" },
        -- --                 ["<C-q>"] = { "snippet_backward", "fallback" },
        -- --                 ["<C-j>"] = {
        -- --                         function(cmp)
        -- --                                 if cmp.snippet_active() then
        -- --                                         return cmp.accept()
        -- --                                 else
        -- --                                         return cmp.select_and_accept()
        -- --                                 end
        -- --                         end,
        -- --                         "snippet_forward",
        -- --                         "fallback"
        -- --                 },
        -- --         },
        -- --         cmdline = { keymap = { preset = "inherit" } },
        -- --         appearance = { nerd_font_variant = "mono" },
        -- --         completion = {
        -- --                 documentation = { auto_show = false },
        -- --                 ghost_text = {
        -- --                         enabled = function()
        -- --                                 return not vim.tbl_contains({
        -- --                                         "markdown",
        -- --                                         "gitcommit",
        -- --                                 }, vim.bo.filetype)
        -- --                         end
        -- --                 },
        -- --                 menu = {
        -- --                         auto_show = false,
        -- --                         draw = {
        -- --                                 treesitter = { "lsp" },
        -- --                                 components = {
        -- --                                         kind_icon = {
        -- --                                                 text = function(ctx)
        -- --                                                         return " " ..
        -- --                                                             ctx.kind_icon .. ctx.icon_gap .. " "
        -- --                                                 end
        -- --                                         },
        -- --                                         item_idx = {
        -- --                                                 text = function(ctx)
        -- --                                                         return tostring(ctx.idx)
        -- --                                                 end
        -- --                                         },
        -- --                                 },
        -- --                                 columns = {
        -- --                                         {
        -- --                                                 "item_idx",
        -- --                                                 "label",
        -- --                                                 "label_description",
        -- --                                                 gap = 1,
        -- --                                         },
        -- --                                         {
        -- --                                                 "kind_icon",
        -- --                                                 "kind",
        -- --                                                 "source_name",
        -- --                                                 gap = 1
        -- --                                         }
        -- --                                 },
        -- --                         }
        -- --                 },
        -- --         },
        -- --         fuzzy = {
        -- --                 sorts = {
        -- --                         "exact",
        -- --                         "score",
        -- --                         "sort_text"
        -- --                 },
        -- --         },
        -- --         sources = {
        -- --                 default = { "lsp", "path", "snippets", "buffer" },
        -- --                 providers = {
        -- --                         -- recipe for writers
        -- --                         buffer = {
        -- --                                 -- keep case of first char
        -- --                                 transform_items = function(a, items)
        -- --                                         local keyword = a.get_keyword()
        -- --                                         local correct, case
        -- --                                         if keyword:match("^%l") then
        -- --                                                 correct = "^%u%l+$"
        -- --                                                 case = string.lower
        -- --                                         elseif keyword:match("^%u") then
        -- --                                                 correct = "^%l+$"
        -- --                                                 case = string.upper
        -- --                                         else
        -- --                                                 return items
        -- --                                         end
        -- --
        -- --                                         -- avoid duplicates from the corrections
        -- --                                         local seen = {}
        -- --                                         local out = {}
        -- --                                         for _, item in ipairs(items) do
        -- --                                                 local raw = item.insertText
        -- --                                                 if raw:match(correct) then
        -- --                                                         local text = case(raw:sub(1, 1)) .. raw:sub(2)
        -- --                                                         item.insertText = text
        -- --                                                         item.label = text
        -- --                                                 end
        -- --                                                 if not seen[item.insertText] then
        -- --                                                         seen[item.insertText] = true
        -- --                                                         table.insert(out, item)
        -- --                                                 end
        -- --                                         end
        -- --                                         return out
        -- --                                 end
        -- --                         },
        -- --                 },
        -- --         },
        -- -- },
        -- -- opts_extend = { "sources.default" },
        -- -- init = function()
        -- --         local capabilities = {
        -- --                 textDocument = {
        -- --                         foldingRange = {
        -- --                                 dynamicRegistration = false,
        -- --                                 lineFoldingOnly = true
        -- --                         },
        -- --                         semanticTokens = {
        -- --                                 multilineTokenSupport = true,
        -- --                         }
        -- --                 }
        -- --         }
        -- --         capabilities = require("blink.cmp").get_lsp_capabilities(capabilities)
        -- --
        -- --         vim.lsp.config("*", {
        -- --                 root_markers = { ".git", ".jj" },
        -- --                 capabilities = capabilities,
        -- --         })
        -- -- end

        { src = "https://github.com/Saecki/crates.nvim" },
        -- tag = "stable",
        -- event = { "BufEnter Cargo.toml" },

        -- -- https://github.com/willothy/flatten.nvim/issues/108
        -- -- "willothy/flatten.nvim",
        -- -- { src = "https://github.com/qw457812/flatten.nvim" },
        -- -- dependencies = { "akinsho/toggleterm.nvim" },
        -- -- lazy = false,
        -- -- priority = 1001,
        -- -- opts = function()
        -- --         local term = require("toggleterm.terminal")
        -- --
        -- --         ---@type Terminal?
        -- --         local saved_terminal
        -- --         return {
        -- --                 nest_if_no_args = true,
        -- --                 window = { open = "alternate" },
        -- --                 block_for = {
        -- --                         crontab   = true,
        -- --                         gitcommit = true,
        -- --                         gitrebase = true,
        -- --                 },
        -- --                 hooks = {
        -- --                         should_nest = function()
        -- --                                 -- FIXME: Missing check for toggleterm vs builtin.
        -- --                                 -- These hooks are getting in the way of success.
        -- --                                 local default_term_denylist = {
        -- --                                         "%.git/COMMIT_EDITMSG$",
        -- --                                         "%.git/rebase%-merge/git%-rebase%-todo$",
        -- --                                         "^/tmp/crontab%.%w+/crontab$",
        -- --                                 }
        -- --                                 local toggleterm_denylist   = {
        -- --                                         "^/tmp/%S+%.nu$",
        -- --                                         "^/tmp/yazi%-%d+/bulk",
        -- --                                 }
        -- --                                 for _, pat in ipairs(toggleterm_denylist) do
        -- --                                         if string.match(vim.v.argv[#vim.v.argv], pat) ~= nil then
        -- --                                                 return true
        -- --                                         end
        -- --                                 end
        -- --                         end,
        -- --                         pre_open = function()
        -- --                                 local termid   = term.get_focused_id()
        -- --                                 saved_terminal = term.get(termid)
        -- --                         end,
        -- --                         post_open = function(opts)
        -- --                                 local bufnr, winnr, ft, is_blocking, is_diff =
        -- --                                     opts.bufnr, opts.winnr, opts.filetype, opts.is_blocking, opts.is_diff
        -- --
        -- --                                 if is_blocking and saved_terminal then
        -- --                                         saved_terminal:close()
        -- --                                 elseif not is_diff then
        -- --                                         vim.api.nvim_set_current_win(winnr)
        -- --                                 end
        -- --
        -- --                                 if vim.tbl_contains({
        -- --                                             "crontab",
        -- --                                             "gitrebase",
        -- --                                             "gitcommit",
        -- --                                     }, ft) then
        -- --                                         vim.api.nvim_create_autocmd("BufWritePost", {
        -- --                                                 buffer = bufnr,
        -- --                                                 callback = vim.schedule_wrap(function()
        -- --                                                         vim.api.nvim_buf_delete(bufnr, {})
        -- --                                                 end),
        -- --                                         })
        -- --                                 end
        -- --                         end,
        -- --                         block_end = function()
        -- --                                 vim.schedule(function()
        -- --                                         if saved_terminal then
        -- --                                                 saved_terminal:open()
        -- --                                                 saved_terminal = nil
        -- --                                         end
        -- --                                 end)
        -- --                         end,
        -- --                 }
        -- --         }
        -- -- end

        -- { src = "https://github.com/tpope/vim-fugitive" },
        -- -- cmd = {
        -- --         "Git",
        -- --         "Gread",
        -- --         "Gwrite",
        -- -- },
        -- -- keys = {
        -- --         { "<leader>gb", "<CMD>Git blame<CR>",     desc = "[Git] Blame" },
        -- --         { "<leader>gd", "<CMD>Gvdiffsplit<CR>",   desc = "[Git] Diff file" },
        -- --         { "<leader>gD", "<CMD>Git difftool<CR>",  desc = "[Git] Difftool" },
        -- --         { "<leader>gm", "<CMD>Git mergetool<CR>", desc = "[Git] Mergetool" },
        -- --         { "<leader>gl", "<CMD>0Gclog<CR>",        desc = "[Git] File history" },
        -- --         { "<leader>gL", "<CMD>Gclog<CR>",         desc = "[Git] Repo history" },
        -- -- },
        -- -- init = function()
        -- --         vim.keymap.set("ca", "git", function()
        -- --                 if vim.fn.getcmdtype() == ":" then
        -- --                         local cmd = vim.fn.getcmdline()
        -- --                         if cmd:match("^git") then
        -- --                                 return "Git"
        -- --                         else
        -- --                                 return "git"
        -- --                         end
        -- --                 end
        -- --         end, { expr = true })
        -- --
        -- --         vim.g.fugitive_no_maps = 1
        -- --         vim.g.fugitive_summary_format = "%an | %s"
        -- --
        -- --         function _G.qfxfugitive(info)
        -- --                 local items
        -- --                 local ret = {}
        -- --                 if info.quickfix == 1 then
        -- --                         items = vim.fn.getqflist({ id = info.id, items = 0 }).items
        -- --                 end
        -- --                 local validFmt = " %s || %s"
        -- --                 for i = info.start_idx, info.end_idx do
        -- --                         local e = items[i]
        -- --                         local mod = e.module:sub(0, 7) -- commit hash
        -- --                         local str = validFmt:format(mod, e.text)
        -- --                         table.insert(ret, str)
        -- --                 end
        -- --                 return ret
        -- --         end
        -- --
        -- --         local Qfx_Format = vim.api.nvim_create_augroup("Qfx_Format", { clear = true })
        -- --         vim.api.nvim_create_autocmd({ "QuickFixCmdPre", "QuickFixCmdPost" }, {
        -- --                 desc     = "Post Fugitive quickfix format",
        -- --                 group    = Qfx_Format,
        -- --                 callback = function()
        -- --                         local qf_title = vim.fn.getqflist({ title = 1 }).title
        -- --                         if qf_title:match("Gclog") then
        -- --                                 vim.o.qftf = "{info -> v:lua._G.qfxfugitive(info)}"
        -- --                         else
        -- --                                 vim.o.qftf = "{info -> v:lua._G.qfx(info)}"
        -- --                         end
        -- --                 end
        -- --         })
        -- -- end

        -- { src = "https://github.com/kevinhwang91/nvim-fundo" },
        -- -- dependencies = { "kevinhwang91/promise-async" },
        -- -- event = "VeryLazy",
        -- -- build = function()
        -- --         require("fundo").install()
        -- -- end,
        -- -- config = function()
        -- --         require("fundo").setup()
        -- --         vim.o.undofile = true
        -- -- end

        -- { src = "https://github.com/ibhagwan/fzf-lua" },
        -- -- local fd_exclude = "--exclude={Trash,.git,.cache,state/undo,target}"
        -- --
        -- -- local icons_cond
        -- -- if os.getenv("DISPLAY") == nil then
        -- --         icons_cond = false
        -- -- else
        -- --         icons_cond = true
        -- -- end
        -- -- keys = {
        -- --         { "<leader>fi", "<CMD>FzfLua files<CR>",            desc = "[FZF] List all files" },
        -- --         { "<leader>fl", "<CMD>FzfLua git_files<CR>",        desc = "[FZF] List tracked files" },
        -- --         { "<leader>fh", "<CMD>FzfLua oldfiles<CR>",         desc = "[FZF] File history" },
        -- --         { "<leader>fb", "<CMD>FzfLua buffers<CR>",          desc = "[FZF] Buffers" },
        -- --         { "<leader>fc", "<CMD>FzfLua git_commits<CR>",      desc = "[FZF] Commits" },
        -- --         { "<leader>fg", "<CMD>FzfLua live_grep_native<CR>", desc = "[FZF] Live grep" },
        -- --         { "<leader>fk", "<CMD>FzfLua helptags<CR>",         desc = "[FZF] Help tags" },
        -- --         { "<leader>fK", "<CMD>FzfLua keymaps<CR>",          desc = "[FZF] List mappings" },
        -- --         { "<C-h>",      "<CMD>FzfLua marks<CR>",            desc = "[FZF] Get global marks" },
        -- --         {
        -- --                 "<C-r>",
        -- --                 "<CMD>FzfLua command_history<CR>",
        -- --                 mode = { "n", "x" },
        -- --                 desc = "[FZF] Search command history"
        -- --         },
        -- --         {
        -- --                 "<C-x><C-f>",
        -- --                 function()
        -- --                         require("fzf-lua").complete_path({
        -- --                                 cmd = table.concat({
        -- --                                         "fd",
        -- --                                         "--color=never",
        -- --                                         "--hidden",
        -- --                                         "--follow",
        -- --                                         "--no-ignore",
        -- --                                         fd_exclude
        -- --                                 }, " "),
        -- --                         })
        -- --                 end,
        -- --                 mode = "i",
        -- --                 desc = "[FZF] Complete Path"
        -- --         },
        -- --         { "<leader>fs", "<CMD>lua _G.fzf_dirs()<CR>", desc = "[FZF] New project tab" },
        -- -- },
        -- -- init = function()
        -- --         require("fzf-lua").register_ui_select()
        -- --
        -- --         _G.fzf_dirs = function(opts)
        -- --                 opts = opts or {}
        -- --                 opts.winopts = { title = " Projects " }
        -- --                 opts.actions = {
        -- --                         ["default"] = function(selected)
        -- --                                 vim.cmd("tabnew " .. selected[1])
        -- --                                 vim.cmd("tcd " .. selected[1])
        -- --                         end
        -- --                 }
        -- --                 local dirs = {
        -- --                         "~/Projects/",
        -- --                         "~/Projects/plugins-nvim/",
        -- --                         "~/.local/share/nvim/lazy/",
        -- --                         "~/.local/share/bob/nightly/share/nvim/runtime/",
        -- --                         "~/"
        -- --                 }
        -- --                 require("fzf-lua").fzf_exec(
        -- --                         table.concat({
        -- --                                 "fd",
        -- --                                 "--hidden",
        -- --                                 "--follow",
        -- --                                 "--type d",
        -- --                                 "--no-ignore",
        -- --                                 "--exact-depth 1",
        -- --                                 ". "
        -- --                         }, " ") ..
        -- --                         table.concat(dirs, " "), opts
        -- --                 )
        -- --         end
        -- -- end,
        -- -- opts = {
        -- --         keymap = {
        -- --                 builtin = {
        -- --                         ["<C-k>"] = "preview-page-up",
        -- --                         ["<C-j>"] = "preview-page-down",
        -- --                         ["<F1>"] = "toggle-help",
        -- --                         ["<F2>"] = "toggle-fullscreen",
        -- --                         ["<F4>"] = "toggle-preview",
        -- --                 },
        -- --                 fzf = {
        -- --                         ["ctrl-q"] = "select-all+accept",
        -- --                         ["alt-a"] = "toggle-all",
        -- --                         ["alt-g"] = "last",
        -- --                         ["alt-G"] = "first",
        -- --                 },
        -- --         },
        -- --         winopts = {
        -- --                 height     = 0.80,
        -- --                 width      = 0.90,
        -- --                 row        = 0.50,
        -- --                 col        = 0.55,
        -- --                 backdrop   = 100,
        -- --                 border     = "rounded",
        -- --                 preview    = { border = "rounded" },
        -- --                 treesitter = { enabled = false },
        -- --         },
        -- --         fzf_colors = {
        -- --                 ["hl"] = { "fg", "Type", "bold" },
        -- --                 ["hl+"] = { "fg", "Type", "bold" },
        -- --         },
        -- --         command_history = {
        -- --                 fzf_colors = {
        -- --                         ["hl"] = { "fg", "Type", "bold" },
        -- --                         ["hl+"] = { "fg", "Type", "bold" },
        -- --                 },
        -- --         },
        -- --         hls = { buf_nr = "FzfLuaCustomMarks" },
        -- --         git = { files = { file_icons = icons_cond } },
        -- --         files = {
        -- --                 file_icons = icons_cond,
        -- --                 fd_opts = table.concat({
        -- --                         "--color=never",
        -- --                         "--hidden",
        -- --                         "--no-ignore",
        -- --                         "--type f",
        -- --                         "--type l",
        -- --                         fd_exclude
        -- --                 }, " "),
        -- --                 winopts = { preview = { layout = "vertical" } },
        -- --         },
        -- --         grep = {
        -- --                 rg_opts = table.concat({
        -- --                         "--color=always",
        -- --                         "--column",
        -- --                         "--line-number",
        -- --                         "--no-heading",
        -- --                         "--smart-case",
        -- --                         "--max-columns=4096",
        -- --                         "--hidden",
        -- --                         "-g=!.git",
        -- --                         "-g=!.jj",
        -- --                         "-e",
        -- --                 }, " "),
        -- --         },
        -- --         helptags = {
        -- --                 winopts = { height = 0.5 },
        -- --         },
        -- --         marks = {
        -- --                 sort = true,
        -- --                 marks = "[^%d%.\"'<>]",
        -- --                 fzf_opts = {
        -- --                         ["--cycle"] = true,
        -- --                         ["--tiebreak"] = "begin",
        -- --                 },
        -- --                 winopts = {
        -- --                         preview = { layout = "vertical" },
        -- --                 }
        -- --         }
        -- -- }

        -- { src = "https://github.com/RaafatTurki/hex.nvim" },
        -- -- keys = {
        -- --         { "<leader>X", "<CMD>HexToggle<CR>", desc = "Toggle hex dump" },
        -- -- },
        -- -- opts = {
        -- --         -- Not too fond of this plugin trying to read files that
        -- --         -- are NOT binary or are already read by other plugins
        -- --         is_file_binary_pre_read = function()
        -- --                 return false
        -- --         end,
        -- --         is_file_binary_post_read = function()
        -- --                 return false
        -- --         end,
        -- -- }

        -- { src = "https://github.com/nvimtools/hydra.nvim" },
        -- -- keys = { "<C-w>", "z" },
        -- -- config = function()
        -- --         local hydra = require("hydra")
        -- --
        -- --         hydra({
        -- --                 name = "SIDE SCROLL",
        -- --                 mode = "n",
        -- --                 body = "z",
        -- --                 heads = {
        -- --                         { "h", "5zh", {} },
        -- --                         { "l", "5zl", { desc = "<= =>" } },
        -- --                         { "H", "zH",  {} },
        -- --                         { "L", "zL",  { desc = "Half screen <= =>" } },
        -- --                 }
        -- --         })
        -- --
        -- --         hydra({
        -- --                 name = "WINCMD",
        -- --                 mode = "n",
        -- --                 body = "<C-w>",
        -- --                 heads = {
        -- --                         { "<", "<C-w>2<" },
        -- --                         { ">", "<C-w>2>" },
        -- --                         { "-", "<C-w>2-" },
        -- --                         { "+", "<C-w>2+" },
        -- --                         { "=", "<C-w>=" },
        -- --                         { "H", "<C-w>H" },
        -- --                         { "L", "<C-w>L" },
        -- --                         { "J", "<C-w>J" },
        -- --                         { "K", "<C-w>K" },
        -- --                         { "c", "<C-w>c" },
        -- --                 },
        -- --         })
        -- -- end

        -- { src = "https://github.com/nvim-lualine/lualine.nvim" },
        -- -- local icons_cond
        -- -- local icon_rightpad
        -- -- local component_separators
        -- -- local section_separators
        -- --
        -- -- if os.getenv("DISPLAY") == nil then
        -- --         icons_cond           = false
        -- --         icon_rightpad        = 1
        -- --         section_separators   = { left = '>', right = '<' }
        -- --         component_separators = { left = '|', right = '|' }
        -- -- else
        -- --         icons_cond           = true
        -- --         icon_rightpad        = 0
        -- --         section_separators   = { left = "", right = "" }
        -- --         component_separators = { left = "", right = "" }
        -- -- end
        -- --
        -- -- local diagnostic_cond = function()
        -- --         if vim.api.nvim_win_get_width(0) < 80 then
        -- --                 return false
        -- --         else
        -- --                 return true
        -- --         end
        -- -- end
        -- -- dependencies = { "nvim-tree/nvim-web-devicons" },
        -- -- init = function()
        -- --         vim.go.showmode = false
        -- -- end,
        -- -- opts = {
        -- --         options = {
        -- --                 icons_enabled        = icons_cond,
        -- --                 section_separators   = section_separators,
        -- --                 component_separators = component_separators,
        -- --                 theme                = {
        -- --                         normal = {
        -- --                                 a = "LualineNormalA",
        -- --                                 b = "LualineNormalB",
        -- --                                 c = "LualineNormalC",
        -- --                         },
        -- --                         insert = {
        -- --                                 a = "LualineInsertA",
        -- --                                 b = "LualineInsertB",
        -- --                         },
        -- --                         terminal = {
        -- --                                 a = "LualineTerminalA",
        -- --                                 b = "LualineTerminalB",
        -- --                         },
        -- --                         visual = {
        -- --                                 a = "LualineVisualA",
        -- --                                 b = "LualineVisualB",
        -- --                         },
        -- --                         replace = {
        -- --                                 a = "LualineReplaceA",
        -- --                                 b = "LualineReplaceB",
        -- --                         },
        -- --                         command = {
        -- --                                 a = "LualineCommandA",
        -- --                                 b = "LualineCommandB",
        -- --                         },
        -- --                         inactive = {
        -- --                                 a = "LualineInactiveA",
        -- --                                 b = "LualineInactiveB",
        -- --                                 c = "LualineInactiveC",
        -- --                         },
        -- --                 },
        -- --         },
        -- --         sections = {
        -- --                 lualine_a = { "branch" },
        -- --                 lualine_b = {
        -- --                         { "diff",        cond = diagnostic_cond },
        -- --                         { "diagnostics", cond = diagnostic_cond },
        -- --                         {
        -- --                                 "filetype",
        -- --                                 icon_only = true,
        -- --                                 padding = { left = 1, right = icon_rightpad }
        -- --                         },
        -- --                 },
        -- --                 lualine_c = { { "filename", path = 1 } },
        -- --                 lualine_x = {
        -- --                         {
        -- --                                 function()
        -- --                                         local macro = vim.fn.reg_recording()
        -- --                                         if macro == "" then return "" end
        -- --                                         return "recording @" .. vim.fn.reg_recording()
        -- --                                 end,
        -- --                                 padding = { left = 0, right = 1 },
        -- --                                 separator = { right = "" },
        -- --                                 color = { fg = "#fab387", gui = "bold" },
        -- --                         },
        -- --                         {
        -- --                                 "searchcount",
        -- --                                 maxcount = 999,
        -- --                                 timeout = 500,
        -- --                                 separator = { right = "" },
        -- --                                 color = { fg = "#e0d561", gui = "bold" }
        -- --                         },
        -- --                         { "location", padding = 2 }
        -- --                 },
        -- --                 lualine_y = { "progress" },
        -- --                 lualine_z = { "mode" }
        -- --         },
        -- --         inactive_sections = {
        -- --                 lualine_a = { "branch" },
        -- --                 lualine_b = {
        -- --                         { "diff",        cond = diagnostic_cond },
        -- --                         { "diagnostics", cond = diagnostic_cond },
        -- --                         {
        -- --                                 "filetype",
        -- --                                 icon_only = true,
        -- --                                 padding = { left = 1, right = icon_rightpad }
        -- --                         },
        -- --                 },
        -- --                 lualine_c = { { "filename", path = 0 } },
        -- --                 lualine_x = { { "location", padding = 2 } },
        -- --                 lualine_y = { "progress" },
        -- --                 lualine_z = {},
        -- --         },
        -- --         extensions = {
        -- --                 "man",
        -- --                 "quickfix",
        -- --                 "toggleterm",
        -- --         }
        -- -- }

        -- { src = "https://github.com/williamboman/mason.nvim" },
        -- -- build = ":MasonInstall " ..
        -- --     "clangd " ..
        -- --     "lua-language-server " ..
        -- --     "tinymist " ..
        -- --     "vim-language-server",
        -- -- ft = {
        -- --         "c",
        -- --         "cpp",
        -- --         "lua",
        -- --         "nu",
        -- --         "rust",
        -- --         "typst",
        -- --         "vim",
        -- -- },
        -- -- keys = {
        -- --         { "<leader>qm", "<CMD>Mason<CR>", desc = "[MASON] Menu" }
        -- -- },
        -- -- opts = {
        -- --         ui = {
        -- --                 border = "rounded",
        -- --                 backdrop = 100,
        -- --         }
        -- -- },
        -- -- init = function()
        -- --         vim.lsp.enable({
        -- --                 "clangd",
        -- --                 "luals",
        -- --                 "nuls",
        -- --                 "rust-analyzer",
        -- --                 "typls",
        -- --                 "vimls",
        -- --         })
        -- --
        -- --         -- Ensure Mason can detect fnm
        -- --         vim.env.PATH = vim.fs.abspath(".local/share/fnm/aliases/default/bin") .. ":" .. os.getenv("PATH")
        -- -- end

        -- { src = "https://github.com/nvim-mini/mini.ai" },
        -- -- version = false,
        -- -- dependencies = {
        -- --         "nvim-treesitter/nvim-treesitter",
        -- --         "nvim-treesitter/nvim-treesitter-textobjects",
        -- -- },
        -- -- cond = not vim.g.shell_editor == true,
        -- -- keys = {
        -- --         { "ca" },
        -- --         { "ci" },
        -- --         { "da" },
        -- --         { "di" },
        -- --         { "ya" },
        -- --         { "yi" },
        -- --         { "gca" },
        -- --         { "gci" },
        -- -- },
        -- -- config = function()
        -- --         require("mini.ai").setup({
        -- --                 custom_textobjects = {
        -- --                         -- FIXME: doesn't work
        -- --                         a = require("mini.ai").gen_spec.treesitter({
        -- --                                 a = "@parameter.outer",
        -- --                                 i = "@parameter.inner"
        -- --                         }, {}),
        -- --                         f = require("mini.ai").gen_spec.treesitter({
        -- --                                 a = "@function.outer",
        -- --                                 i = "@function.inner"
        -- --                         }, {}),
        -- --                         g = require("mini.ai").gen_spec.treesitter({
        -- --                                 a = { "@conditional.outer", "@loop.outer" },
        -- --                                 i = { "@conditional.inner", "@loop.inner" },
        -- --                         }, {}),
        -- --                         h = require("mini.ai").gen_spec.pair("— ", " —", { type = "non-balanced" }),
        -- --                         ["<"] = require("mini.ai").gen_spec.pair("<", ">", { type = "non-balanced" }),
        -- --                 },
        -- --         })
        -- -- end

        -- { src = "https://github.com/nvim-mini/mini.diff" },
        -- -- version = false,
        -- -- event = "BufReadPost [^:]*",
        -- -- keys = {
        -- --         { "<leader>gh", "<CMD>lua MiniDiff.toggle_overlay()<CR>", desc = "[Git] Diff overlay" }
        -- -- },
        -- -- opts = {
        -- --         view = {
        -- --                 style = "sign",
        -- --                 signs = { add = "┃", change = "┃", delete = "┃" },
        -- --         }
        -- -- }

        -- { src = "https://github.com/nvim-mini/mini.hipatterns" },
        -- -- version = false,
        -- -- event = "BufReadPost [^:]*",
        -- -- config = function()
        -- --         require("mini.hipatterns").setup({
        -- --                 highlighters = {
        -- --                         hex_color = require("mini.hipatterns").gen_highlighter.hex_color(),
        -- --                         fixme = { pattern = "%f[%w]()FIXME()%f[%W]", group = "MiniHipatternsFixme" },
        -- --                         hack = { pattern = "%f[%w]()HACK()%f[%W]", group = "MiniHipatternsHack" },
        -- --                         todo = { pattern = "%f[%w]()TODO()%f[%W]", group = "MiniHipatternsTodo" },
        -- --                         note = { pattern = "%f[%w]()NOTE()%f[%W]", group = "MiniHipatternsNote" },
        -- --                         todo_rust_macro = { pattern = "todo!%(%)", group = "MiniHipatternsFixme" },
        -- --                 },
        -- --         })
        -- -- end

        -- { src = "https://github.com/nvim-mini/mini.icons" },
        -- -- version = false,
        -- -- lazy = true,
        -- -- specs = { { "nvim-tree/nvim-web-devicons", enabled = false, optional = true } },
        -- -- init = function()
        -- --         package.preload["nvim-web-devicons"] = function()
        -- --                 require("mini.icons").mock_nvim_web_devicons()
        -- --                 return package.loaded["nvim-web-devicons"]
        -- --         end
        -- -- end,
        -- -- opts = {
        -- --         filetype = {
        -- --                 nu = { glyph = "" }
        -- --         }
        -- -- }

        -- { src = "https://github.com/nvim-mini/mini.misc" },
        -- -- version = false,
        -- -- event = "BufReadPost [^:]*",
        -- -- config = function()
        -- --         require("mini.misc").setup_auto_root({ ".git", ".jj" })
        -- --         require("mini.misc").setup_restore_cursor({ center = false })
        -- -- end

        -- { src = "https://github.com/nvim-mini/mini.operators" },
        -- -- version = false,
        -- -- keys = {
        -- --         { "g=", mode = { "n", "x" } },
        -- --         { "cx", mode = { "n", "x" } },
        -- --         { "gm", mode = { "n", "x" } },
        -- --         { "cs", mode = { "n", "x" } },
        -- -- },
        -- -- init = function()
        -- --         vim.keymap.set("n", "gyy", "mzgmmkgcc`zj", { remap = true, desc = "Duplicate and comment" })
        -- --         vim.keymap.set("x", "gy", "gmmzgvgc`z", { remap = true, desc = "Duplicate and comment selection" })
        -- -- end,
        -- -- opts = {
        -- --         evaluate = {
        -- --                 prefix = "g=",
        -- --                 func = nil,
        -- --         },
        -- --         exchange = {
        -- --                 prefix = "cx",
        -- --                 reindent_linewise = true,
        -- --         },
        -- --         multiply = {
        -- --                 prefix = "gm",
        -- --                 func = nil,
        -- --         },
        -- --         replace = {
        -- --                 prefix = "cs",
        -- --                 reindent_linewise = true,
        -- --         },
        -- --         sort = {
        -- --                 prefix = ""
        -- --         }
        -- -- }

        -- { src = "https://github.com/nvim-mini/mini.pairs" },
        -- -- version = false,
        -- -- event = { "InsertEnter", "CmdlineEnter", "CmdwinEnter" },
        -- -- opts = {
        -- --         modes = { insert = true, command = false, terminal = false },
        -- --         mappings = {
        -- --                 ["("] = { action = "open", pair = "()", neigh_pattern = "[^\\].", register = { bs = true, cr = true } },
        -- --                 ["["] = { action = "open", pair = "[]", neigh_pattern = "[^\\].", register = { bs = true, cr = true } },
        -- --                 ["{"] = { action = "open", pair = "{}", neigh_pattern = "[^\\].", register = { bs = true, cr = true } },
        -- --
        -- --                 ["<"] = { action = "open", pair = "<>", neigh_pattern = "[^ \\].", register = { bs = true } },
        -- --                 [">"] = { action = "close", pair = "<>", neigh_pattern = "[^\\]." },
        -- --                 ["|"] = { action = "closeopen", pair = "||", neigh_pattern = "[\\{\\][}]", register = { bs = true } },     -- closures
        -- --                 ["'"] = { action = "closeopen", pair = "''", neigh_pattern = "[^%a&<\\][^>]", register = { cr = false } }, -- lifetimes
        -- --                 ['"'] = { action = "closeopen", pair = '""', neigh_pattern = "[^%a\\].", register = { cr = false } },
        -- --         }
        -- -- },
        -- -- config = function(_, opts)
        -- --         require("mini.pairs").setup(opts)
        -- --
        -- --         local map_bs = function(lhs, rhs)
        -- --                 vim.keymap.set("i", lhs, rhs, { expr = true, replace_keycodes = false })
        -- --         end
        -- --
        -- --         map_bs("<C-h>", "v:lua.MiniPairs.bs()")
        -- --         map_bs("<C-w>", "v:lua.MiniPairs.bs('\23')")
        -- --         map_bs("<C-u>", "v:lua.MiniPairs.bs('\21')")
        -- --
        -- --         vim.cmd([[
        -- --                 augroup Cmdlinewin_No_Pairs
        -- --                         au!
        -- --                         au CmdwinEnter * lua vim.b.minipairs_disable = true
        -- --                 augroup END
        -- --         ]])
        -- -- end

        -- { src = "https://github.com/nvim-mini/mini.splitjoin" },
        -- -- version = false,
        -- -- keys = {
        -- --         "gJ", desc = "Separate arguments by line"
        -- -- },
        -- -- opts = {
        -- --         mappings = {
        -- --                 toggle = "gJ",
        -- --         },
        -- -- }

        -- { src = "https://github.com/nvim-mini/mini.surround" },
        -- -- version = false,
        -- -- keys = {
        -- --         { "ys" },
        -- --         { "yd" },
        -- --         { "yc" },
        -- --         { "yS" },
        -- --         { "yss" },
        -- --         { "Y",  mode = "x" },
        -- -- },
        -- -- opts = {
        -- --         mappings = {
        -- --                 add = "ys",
        -- --                 delete = "yd",
        -- --                 replace = "yc",
        -- --                 find = "",
        -- --                 find_left = "",
        -- --                 highlight = "",
        -- --                 update_n_lines = "",
        -- --         },
        -- --         respect_selection_type = true,
        -- --         search_method = "cover_or_next",
        -- --         custom_surroundings = {
        -- --                 ["B"] = { -- Bold
        -- --                         input = { "%*%*().-()%*%*" },
        -- --                         output = { left = "**", right = "**" },
        -- --                 },
        -- --                 ["G"] = { -- Code block
        -- --                         input = { "%```().-()%```" },
        -- --                         output = { left = "```", right = "\n```" },
        -- --                 },
        -- --         },
        -- -- },
        -- -- config = function(_, opts)
        -- --         require("mini.surround").setup(opts)
        -- --         vim.keymap.del("x", "ys")
        -- --         vim.keymap.set("x", "Y", ":<C-u>lua MiniSurround.add('visual')<CR>", { silent = true })
        -- --         vim.keymap.set("n", "yS", "ys$", { remap = true })
        -- --         vim.keymap.set("n", "yss", "ys_", { remap = true })
        -- -- end

        -- -- "NeogitOrg/neogit",
        -- { src = "https://github.com/yilisharcs/neogit" },
        -- -- local graph_style
        -- -- if vim.g.neovide then
        -- --         graph_style = "unicode"
        -- -- else
        -- --         graph_style = "kitty"
        -- -- end
        -- -- dev = true,
        -- -- dependencies = {
        -- --         "nvim-lua/plenary.nvim",
        -- --         "sindrets/diffview.nvim",
        -- -- },
        -- -- event = "CmdlineEnter",
        -- -- keys = {
        -- --         { "<leader>i", "<CMD>Neogit<CR>" },
        -- -- },
        -- -- opts = {
        -- --         graph_style = graph_style,
        -- --         disable_hint = true,
        -- --         integrations = {
        -- --                 fzf_lua = true,
        -- --                 snacks = false,
        -- --         },
        -- --         commit_editor = {
        -- --                 kind = "split",
        -- --                 show_staged_diff = false,
        -- --         },
        -- -- },
        -- -- config = function(_, opts)
        -- --         require("neogit").setup(opts)
        -- --
        -- --         local actions = require("diffview.actions")
        -- --
        -- --         require("diffview").setup({
        -- --                 -- diff_binaries = true,
        -- --                 view = {
        -- --                         default = {
        -- --                                 layout = "diff2_vertical"
        -- --                         }
        -- --                 },
        -- --                 file_panel = {
        -- --                         win_config = {
        -- --                                 position = "right",
        -- --                                 width = math.floor(vim.o.columns * 0.33 + 0.5),
        -- --                         },
        -- --                 },
        -- --                 keymaps = {
        -- --                         view = {
        -- --                                 { "n", "<C-n>", actions.select_next_entry, { desc = "Open the diff for the next file" } },
        -- --                                 { "n", "<C-p>", actions.select_prev_entry, { desc = "Open the diff for the previous file" } },
        -- --                         },
        -- --                         file_panel = {
        -- --                                 { "n", "<C-n>", actions.select_next_entry,  { desc = "Open the diff for the next file" } },
        -- --                                 { "n", "<C-p>", actions.select_prev_entry,  { desc = "Open the diff for the previous file" } },
        -- --                                 { "n", "<C-k>", actions.scroll_view(-0.25), { desc = "Scroll the view up" } },
        -- --                                 { "n", "<C-j>", actions.scroll_view(0.25),  { desc = "Scroll the view down" } },
        -- --                         },
        -- --                         file_history_panel = {
        -- --                                 { "n", "<C-n>", actions.select_next_entry,  { desc = "Open the diff for the next file" } },
        -- --                                 { "n", "<C-p>", actions.select_prev_entry,  { desc = "Open the diff for the previous file" } },
        -- --                                 { "n", "<C-k>", actions.scroll_view(-0.25), { desc = "Scroll the view up" } },
        -- --                                 { "n", "<C-j>", actions.scroll_view(0.25),  { desc = "Scroll the view down" } },
        -- --                         },
        -- --                 },
        -- --         })
        -- -- end

        -- { src = "https://github.com/pwntester/octo.nvim" },
        -- -- lazy = false,
        -- -- dependencies = {
        -- --         "ibhagwan/fzf-lua",
        -- --         "nvim-tree/nvim-web-devicons",
        -- -- },
        -- -- keys = {
        -- --         { "<leader>o", "<CMD>Octo actions<CR>" }
        -- -- },
        -- -- opts = {
        -- --         picker = "fzf-lua",
        -- --         picker_config = {
        -- --                 use_emojis = true,
        -- --         },
        -- -- }

        -- { src = "https://github.com/MeanderingProgrammer/render-markdown.nvim" },
        -- -- enabled = false,
        -- -- cond = os.getenv("DISPLAY") ~= nil,
        -- -- ft = "markdown",
        -- -- keys = {
        -- --         { "<leader>y", "<CMD>RenderMarkdown toggle<CR>", desc = "Toggle markdown rendering" },
        -- -- },
        -- -- opts = {
        -- --         render_modes = true,
        -- --         anti_conceal = {
        -- --                 enabled = true,
        -- --                 above = 1,
        -- --                 below = 1,
        -- --         },
        -- --         pipe_table = { preset = "round" },
        -- --         html = { comment = { conceal = false } },
        -- --         sign = { enabled = false },
        -- -- }

        -- -- "folke/snacks.nvim",
        -- { src = "https://github.com/yilisharcs/snacks.nvim" },
        -- -- branch = "bigfile-mini-hipatterns",
        -- -- priority = 1000,
        -- -- lazy = false,
        -- -- keys = {
        -- --         { "<leader>gB", function() Snacks.gitbrowse() end,             desc = "Open git repo in the browser" },
        -- --         { "<leader>n",  function() Snacks.notifier.show_history() end, desc = "Notification history" },
        -- --         { "<leader>p",  ":= _G.dd()<LEFT>",                            desc = "Debug inspect" },
        -- --         { "<leader>s",  function() Snacks.scratch() end,               desc = "Toggle scratch buffer" },
        -- --         { "<leader>S",  function() Snacks.scratch.select() end,        desc = "Select scratch buffer" },
        -- --         {
        -- --                 "<M-q>",
        -- --                 function()
        -- --                         if vim.bo.filetype == "help" then
        -- --                                 vim.cmd.bdelete()
        -- --                         else
        -- --                                 Snacks.bufdelete.delete()
        -- --                         end
        -- --                 end,
        -- --                 desc = "Delete buffer"
        -- --         },
        -- -- },
        -- -- opts = {
        -- --         bigfile = {
        -- --                 enabled = true,
        -- --                 size = 1.5 * 1024 * 1024, -- 1.5MB
        -- --         },
        -- --         gitbrowse = { enabled = true },
        -- --         -- picker = { enabled = true },
        -- --         image = {
        -- --                 -- enabled = vim.env.TERM == "xterm-kitty",
        -- --                 enabled = false,
        -- --                 doc = { inline = false }
        -- --         },
        -- --         input = { enabled = true },
        -- --         notifier = { enabled = true },
        -- --         quickfile = { enabled = true },
        -- --         scratch = {
        -- --                 enable = true,
        -- --                 win = {
        -- --                         height = 24
        -- --                 }
        -- --         },
        -- --         styles = {
        -- --                 notification_history = {
        -- --                         width = 0.9,
        -- --                         wo = { wrap = true },
        -- --                 }
        -- --         }
        -- -- },
        -- -- init = function()
        -- --         -- setup some globals for debugging
        -- --         _G.dd = function(...) Snacks.debug.inspect(...) end
        -- --         _G.bt = function() Snacks.debug.backtrace() end
        -- --         vim.print = _G.dd
        -- --
        -- --         -- simple lsp progress example
        -- --         vim.api.nvim_create_autocmd("LspProgress", {
        -- --                 ---@param ev {data: {client_id: integer, params: lsp.ProgressParams}}
        -- --                 callback = function(ev)
        -- --                         local spinner = { "⠋", "⠙", "⠹", "⠸", "⠼", "⠴", "⠦", "⠧", "⠇", "⠏" }
        -- --                         vim.notify(vim.lsp.status(), vim.log.levels.INFO, {
        -- --                                 id = "lsp_progress",
        -- --                                 title = "LSP Progress",
        -- --                                 opts = function(notif)
        -- --                                         notif.icon = ev.data.params.value.kind == "end" and " "
        -- --                                             or spinner[math.floor(vim.uv.hrtime() / (1e6 * 80)) % #spinner + 1]
        -- --                                 end
        -- --                         })
        -- --                 end
        -- --         })
        -- -- end

        -- { src = "https://github.com/akinsho/toggleterm.nvim" },
        -- -- version = "*",
        -- -- event = "VeryLazy",
        -- -- opts = {
        -- --         open_mapping = "<C-g>",
        -- --         shell = vim.fn.executable("nu") == 1 and vim.fn.exepath("nu") or vim.o.shell,
        -- --         size = function(term)
        -- --                 if term.direction == "horizontal" then
        -- --                         return vim.o.lines * 0.4
        -- --                 elseif term.direction == "vertical" then
        -- --                         return vim.o.columns * 0.5
        -- --                 end
        -- --         end,
        -- --         float_opts = {
        -- --                 border = "rounded"
        -- --         }
        -- -- },
        -- -- config = function(_, opts)
        -- --         require("toggleterm").setup(opts)
        -- --
        -- --         local Terminal = require("toggleterm.terminal").Terminal
        -- --
        -- --         local gh_dash = Terminal:new({
        -- --                 cmd = "gh dash",
        -- --                 dir = "~",
        -- --                 direction = "float",
        -- --                 display_name = "GITHUB DASHBOARD",
        -- --                 count = 2
        -- --         })
        -- --         vim.keymap.set("n", "<leader><F2>", function() gh_dash:toggle() end)
        -- --
        -- --         local btop = Terminal:new({
        -- --                 cmd = "btop",
        -- --                 direction = "float",
        -- --                 display_name = "RESOURCE MONITOR",
        -- --                 count = 3
        -- --         })
        -- --         vim.keymap.set("n", "<leader><F3>", function() btop:toggle() end)
        -- -- end

        -- { src = "https://github.com/nvim-treesitter/nvim-treesitter" },
        -- -- enabled = false,
        -- -- dependencies = {
        -- --         "RRethy/nvim-treesitter-endwise",
        -- --         "HiPhish/rainbow-delimiters.nvim",
        -- -- },
        -- -- build = ":TSUpdate",
        -- -- cond = not vim.g.shell_editor == true,
        -- -- event = { "BufReadPost [^:]*", "BufNewFile" },
        -- -- config = function()
        -- --         require("nvim-treesitter.configs").setup({
        -- --                 ensure_installed = {
        -- --                         "asm",
        -- --                         "bash",
        -- --                         "c",
        -- --                         "cpp",
        -- --                         "comment",
        -- --                         "desktop",
        -- --                         "diff",
        -- --                         "editorconfig",
        -- --                         "git_config",
        -- --                         "gitcommit",
        -- --                         "gitignore",
        -- --                         "html",
        -- --                         "ini",
        -- --                         "json",
        -- --                         "lua",
        -- --                         "markdown",
        -- --                         "markdown_inline",
        -- --                         "meson",
        -- --                         -- "muttrc",
        -- --                         "ninja",
        -- --                         "nu",
        -- --                         "objdump",
        -- --                         -- "php",
        -- --                         "python",
        -- --                         "query",
        -- --                         "rust",
        -- --                         "strace",
        -- --                         "toml",
        -- --                         "typst",
        -- --                         "udev",
        -- --                         "vim",
        -- --                         "vimdoc",
        -- --                         -- "wgsl_bevy",
        -- --                         "xml",
        -- --                         "yaml",
        -- --                 },
        -- --                 sync_install = false,
        -- --                 auto_install = true,
        -- --                 ignore_install = {
        -- --                         "make",
        -- --                         "tmux",
        -- --                 },
        -- --                 highlight = { enable = true },
        -- --                 indent = { enable = true },
        -- --                 additional_vim_regex_highlighting = { "markdown" },
        -- --         })
        -- --
        -- --         vim.keymap.set("n", "<M-u>", "<CMD>TSBufToggle highlight<CR>", { desc = "[TS] Toggle highlights" })
        -- --         vim.keymap.set("n", "<leader><F9>", "<CMD>InspectTree<CR>", { desc = "[TS] Inspect tree" })
        -- --
        -- --         vim.cmd([[
        -- --                 " Required: treesitter resets filetype syntax opts
        -- --                 augroup Markdown_Syn
        -- --                         au!
        -- --                         au BufEnter *.md set syntax=ON
        -- --                 augroup END
        -- --         ]])
        -- -- end

        -- { src = "https://github.com/chomosuke/typst-preview.nvim" },
        -- -- ft = "typst",
        -- -- opts = {
        -- --         port = 8080,
        -- --         dependencies_bin = {
        -- --                 ["tinymist"] = "tinymist",
        -- --                 ["websocat"] = nil,
        -- --         },
        -- -- },

        { src = "https://github.com/jbyuki/venn.nvim" },
        -- dependencies = { "nvimtools/hydra.nvim" },
        -- event = "CmdlineEnter",
        -- keys = { "<leader>v", desc = "[HYDRA] Venn mode" },
        -- config = function()
        --         local hydra = require("hydra")
        --
        --         local M = {}
        --
        --         local venn_hint_utf = "" ..
        --             "Arrow^^^^^^  Select region with <C-v>^^^^^^" .. "\n" ..
        --             "^ ^ _K_ ^ ^  _f_: Surround with box ^ ^ ^ ^" .. "\n" ..
        --             "_H_ ^ ^ _L_  _<C-h>_: ◄, _<C-j>_: ▼ ^ ^ ^ ^" .. "\n" ..
        --             "^ ^ _J_ ^ ^  _<C-k>_: ▲, _<C-l>_: ► _<C-c>_"
        --
        --         -- :setlocal ve=all
        --         -- :setlocal ve=none
        --         M.venn_hydra = hydra {
        --                 name = "Draw Utf-8 Venn Diagram",
        --                 hint = venn_hint_utf,
        --                 config = {
        --                         hint = { position = "bottom-right" },
        --                         color = "pink",
        --                         invoke_on_body = true,
        --                         on_enter = function() vim.wo.virtualedit = "all" end,
        --                 },
        --                 mode = "n",
        --                 body = "<leader>v",
        --                 heads = {
        --                         { "<C-h>", "xi<C-v>u25c4<Esc>" }, -- mode = "v" somehow breaks
        --                         { "<C-j>", "xi<C-v>u25bc<Esc>" },
        --                         { "<C-k>", "xi<C-v>u25b2<Esc>" },
        --                         { "<C-l>", "xi<C-v>u25ba<Esc>" },
        --                         { "H",     "<C-v>h:VBox<CR>" },
        --                         { "J",     "<C-v>j:VBox<CR>" },
        --                         { "K",     "<C-v>k:VBox<CR>" },
        --                         { "L",     "<C-v>l:VBox<CR>" },
        --                         { "f",     ":VBox<CR>",        { mode = "v" } },
        --                         { "<C-c>", nil,                { exit = true } },
        --                 },
        --         }
        --
        --         return M
        -- end

        -- { src = "https://github.com/mhinz/vim-grepper" },
        -- -- event = "VeryLazy",
        -- -- init = function()
        -- --         vim.g.grepper = nil
        -- --         vim.g.grepper = {
        -- --                 jump = 1,
        -- --                 searchreg = 1,
        -- --                 switch = 0,
        -- --                 quickfix = 1,
        -- --                 operator = {
        -- --                         prompt = 0,
        -- --                         tools = { "rg" },
        -- --                 },
        -- --                 rg = {
        -- --                         escape = "\\^$.*[]",
        -- --                         grepformat = "%f:%l:%c:%m",
        -- --                         grepprg = "vimgrep.nu",
        -- --                 },
        -- --                 tools = { "rg", "git", "grep" },
        -- --         }
        -- --
        -- --         vim.keymap.set({ "n", "x" }, "gs", "<Plug>(GrepperOperator)")
        -- --         vim.keymap.set("ca", "grep", function()
        -- --                 if vim.fn.getcmdtype() == ":" then
        -- --                         local cmd = vim.fn.getcmdline()
        -- --                         if cmd:match("^grep") then
        -- --                                 return "GrepperRg"
        -- --                         else
        -- --                                 return "grep"
        -- --                         end
        -- --                 end
        -- --         end, { expr = true })
        -- -- end

        -- { src = "https://github.com/justinmk/vim-sneak" },
        -- -- dependencies = { { "yilisharcs/vim-repeat", branch = "maparg" } },
        -- -- init = function()
        -- --         vim.g["sneak#use_ic_scs"] = 1
        -- --         vim.cmd([[
        -- --                 augroup Sneak_Insert_HL
        -- --                         au!
        -- --                         au InsertEnter * hi Sneak NONE
        -- --                         au ColorScheme,InsertLeave * hi Sneak guifg=White guibg=Magenta
        -- --                         au TermOpen * hi SneakScope guibg=Black
        -- --                 augroup END
        -- --         ]])
        -- -- end,
        -- -- keys = {
        -- --         { "s", "<Plug>Sneak_s", mode = { "n", "x" } },
        -- --         { "S", "<Plug>Sneak_S", mode = { "n", "x" } },
        -- --         { "z", "<Plug>Sneak_s", mode = "o" },
        -- --         { "Z", "<Plug>Sneak_S", mode = "o" },
        -- --         { "f", "<Plug>Sneak_f", mode = { "n", "x", "o" } },
        -- --         { "F", "<Plug>Sneak_F", mode = { "n", "x", "o" } },
        -- --         { "t", "<Plug>Sneak_t", mode = { "n", "x", "o" } },
        -- --         { "T", "<Plug>Sneak_T", mode = { "n", "x", "o" } },
        -- -- }

        { src = "https://github.com/lambdalisue/suda.vim" },
        -- init = function()
        --         vim.keymap.set("ca", "sudo", function()
        --                 if vim.fn.getcmdtype() == ":" then
        --                         local cmd = vim.fn.getcmdline()
        --                         if cmd:match("^sudo") then
        --                                 return "SudaWrite"
        --                         else
        --                                 return "sudo"
        --                         end
        --                 end
        --         end, { expr = true })
        -- end

        { src = "https://github.com/aymericbeaumet/vim-symlink" },
        -- event = "BufReadPre",

        { src = "https://github.com/dhruvasagar/vim-table-mode" },
        -- event = { "InsertEnter *.md", "InsertEnter *.txt" },
        -- cmd = { "Tableize" },
        -- init = function()
        --         vim.g.table_mode_disable_mappings = 1
        -- end

        -- { src = "https://github.com/yilisharcs/undotree" },
        -- -- branch = "u-redo",
        -- -- keys = {
        -- --         { "<leader>u", "<CMD>UndotreeToggle<CR>", desc = "Toggle history bar" }
        -- -- },
        -- -- config = function()
        -- --         vim.g.undotree_SplitWidth = math.floor(vim.o.columns * 0.27 + 0.5)
        -- --         vim.g.undotree_WindowLayout = 4
        -- --         vim.g.undotree_SetFocusWhenToggle = 1
        -- --         vim.g.undotree_DiffCommand = "diff -u0"
        -- -- end

        { src = "https://github.com/folke/which-key.nvim" },
        -- lazy = false,
        -- opts = {
        --         win = {
        --                 border = "solid"
        --         }
        -- }

        { src = "https://github.com/yilisharcs/wikibrowse.nvim" },
        -- dev = true,
        -- init = function()
        --         vim.g.wikibrowse = {
        --                 -- lang = "pt",
        --                 hello = "world"
        --         }
        --
        --         vim.api.nvim_create_user_command("Reload", function()
        --                 vim.cmd("write")
        --                 vim.cmd("restart")
        --         end, {})
        --         vim.keymap.set("n", "<leader>e", "<CMD>Wikibrowse pizza<CR>")
        --         vim.keymap.set("n", "<leader>w", "<CMD>Reload<CR>")
        --         vim.keymap.set("ca", "wiki", function()
        --                 if vim.fn.getcmdtype() == ":" then
        --                         local cmd = vim.fn.getcmdline()
        --                         if cmd:match("^wiki") then
        --                                 return "Wikibrowse"
        --                         else
        --                                 return "wiki"
        --                         end
        --                 end
        --         end, { expr = true })
        -- end

        -- { src = "https://github.com/mikavilpas/yazi.nvim" },
        -- -- dev = true,
        -- -- lazy = false,
        -- -- dependencies = { "ibhagwan/fzf-lua" },
        -- -- keys = {
        -- --         { "-",         "<CMD>Yazi<CR>",        desc = "Open yazi at the current file" },
        -- --         { "<leader>-", "<CMD>Yazi cwd<CR>",    desc = "Open yazi in the working directory" },
        -- --         { "<leader>_", "<CMD>Yazi toggle<CR>", desc = "Resume the last yazi session", },
        -- -- },
        -- -- opts = {
        -- --         open_for_directories = true,
        -- --         open_multiple_tabs = true,
        -- --         log_level = vim.log.levels.WARN,
        -- --         floating_window_scaling_factor = {
        -- --                 height = 0.96,
        -- --                 width = 0.99,
        -- --         },
        -- --         keymaps = {
        -- --                 open_file_in_vertical_split = "<C-v>",
        -- --                 open_file_in_horizontal_split = "<C-s>",
        -- --                 grep_in_directory = "<C-x>",
        -- --                 cycle_open_buffers = false,
        -- --         },
        -- --         integrations = {
        -- --                 grep_in_directory = "fzf-lua",
        -- --                 grep_in_selected_files = "fzf-lua",
        -- --         },
        -- -- },
        -- -- init = function()
        -- --         vim.g.loaded_netrw = 1
        -- --         vim.g.loaded_netrwPlugin = 1
        -- -- end,

        -- { src = "https://github.com/zk-org/zk-nvim" },
        -- -- keys = {
        -- --         {
        -- --                 "<leader>zn",
        -- --                 function()
        -- --                         vim.ui.input({ prompt = "Title: " }, function(input)
        -- --                                 require("zk").new({ title = input })
        -- --                                 vim.defer_fn(function()
        -- --                                         vim.api.nvim_feedkeys("Gi", "n", false)
        -- --                                 end, 200)
        -- --                         end)
        -- --                 end,
        -- --                 desc = "Create new note"
        -- --         },
        -- --         {
        -- --                 "<leader>zu",
        -- --                 function()
        -- --                         vim.ui.input({ prompt = "Source: " }, function(input)
        -- --                                 local title = string.match(input, "%s(.*)")
        -- --                                 local type_l = string.match(input, "(%a*)")
        -- --                                 local type = string.gsub(type_l, "^%l", string.upper)
        -- --
        -- --                                 require("zk").new({
        -- --                                         title = type .. " - " .. title,
        -- --                                         group = "source",
        -- --                                         extra = { type = type },
        -- --                                 })
        -- --                                 vim.defer_fn(function()
        -- --                                         vim.api.nvim_feedkeys("11GA ", "n", false)
        -- --                                 end, 200)
        -- --                         end)
        -- --                 end,
        -- --                 desc = "Create source note"
        -- --         },
        -- --         {
        -- --                 "<leader>zc",
        -- --                 function()
        -- --                         vim.ui.input({ prompt = "Opponent: " }, function(input)
        -- --                                 require("zk").new({ title = input, group = "chess" })
        -- --                                 vim.defer_fn(function()
        -- --                                         vim.api.nvim_feedkeys("9GA ", "n", false)
        -- --                                 end, 200)
        -- --                         end)
        -- --                 end,
        -- --                 desc = "Create chess game entry"
        -- --         },
        -- --         {
        -- --                 "<leader>zl",
        -- --                 function()
        -- --                         require("zk").new({ dir = "journal", group = "journal" })
        -- --                 end,
        -- --                 desc = "Create journal entry"
        -- --         },
        -- --         {
        -- --                 "<leader>zo",
        -- --                 function()
        -- --                         require("zk").edit({ sort = { "modified" } })
        -- --                 end,
        -- --                 desc = "Open notes"
        -- --         },
        -- --         { "<leader>zt", "<CMD>ZkTags<CR>", desc = "Open tagged notes" },
        -- --         {
        -- --                 "<leader>zy",
        -- --                 function()
        -- --                         -- HACK: https://github.com/zk-org/zk-nvim/issues/122
        -- --                         -- The methods discussed here didn't work for me.
        -- --                         vim.api.nvim_feedkeys('"zy', "x", false)
        -- --                         require("zk").new({ title = vim.fn.getreg("z") })
        -- --                         vim.defer_fn(function()
        -- --                                 vim.api.nvim_feedkeys("Gi", "n", false)
        -- --                         end, 200)
        -- --                 end,
        -- --                 mode = "x",
        -- --                 desc = "Create note from selection"
        -- --         },
        -- --         {
        -- --                 "<leader>zf",
        -- --                 ":ZkMatch<CR>",
        -- --                 mode = "x",
        -- --                 desc = "Find matching selection in notebook"
        -- --         },
        -- --         {
        -- --                 "<leader>zf",
        -- --                 function()
        -- --                         vim.ui.input({ prompt = "Query: " }, function(input)
        -- --                                 require("zk").edit({
        -- --                                         sort = { "modified" },
        -- --                                         match = { input },
        -- --                                 })
        -- --                         end)
        -- --                 end,
        -- --                 desc = "Find matching query in notebook"
        -- --         },
        -- -- },
        -- -- opts = { picker = "fzf_lua" },
        -- -- config = function(_, opts)
        -- --         require("zk").setup(opts)
        -- -- end

})
