if vim.g.colors_name then vim.cmd.highlight("clear") end
if vim.fn.exists("syntax_on") then vim.cmd.syntax("reset") end

vim.g.colors_name = "silverwine"

local colors = {
        -- NOTE
        --      Wine1: 1
        --      Wine3: 0
        --      Ink1: 1
        --      Ink2: 4
        --      Ink3: 4
        --      Green3: 2
        --      Green4: 1
        --      Yellow3: 1
        --      Blue1: 1
        --      Blue2: 1
        --      Magenta1: 1
        Wine1 = "#3f006c",
        Wine2 = "#2a0048",
        Wine3 = "#1b002f",

        Silver1 = "#cdd6f4",
        Silver2 = "#bcc8f0",
        Silver3 = "#afafff",

        Ink1 = "#0f051e",
        Ink2 = "#0a001a",
        Ink3 = "#060010",
        Ink4 = "#030008",

        Gray1 = "#708090",
        Gray2 = "#362b49",
        Gray3 = "#1e1829",

        Cyan1 = "#8cf8f7",
        Cyan2 = "#00afff",
        Cyan3 = "#004666",

        Red1 = "#ef7184",
        Red2 = "#d31834",

        Green1 = "#8af19e",
        Green2 = "#00af5f",
        Green3 = "#004928",
        Green4 = "#00220e",

        Yellow1 = "#ffff5f",
        Yellow2 = "#ffaf00",
        Yellow3 = "#daa520",

        Blue1 = "#8787ff",
        Blue2 = "#5f5fff",

        Magenta1 = "#c87bff",
        Magenta2 = "#b348ff",
}

vim.g.terminal_ansi_colors = {
        colors.Ink4,
        colors.Red2,
        colors.Green2,
        colors.Yellow2,
        colors.Blue2,
        colors.Magenta2,
        colors.Cyan2,
        colors.Silver3,
        --
        colors.Gray1,
        colors.Red1,
        colors.Green2,
        colors.Yellow1,
        colors.Blue1,
        colors.Magenta1,
        colors.Cyan1,
        colors.Silver1,
}
for k, v in ipairs(vim.g.terminal_ansi_colors) do
        local num = "terminal_color_" .. k - 1
        vim.g[num] = v
end

local function hi(name, val)
        -- Force links
        val.force = true
        -- Make sure that `cterm` attribute is not populated from `gui`
        val.cterm = val.cterm or {} ---@type vim.api.keyset.highlight
        -- Define global highlight
        vim.api.nvim_set_hl(0, name, val)
end

if vim.o.background == "dark" then
        -- General
        hi("Normal", { fg = colors.Silver1, bg = colors.Ink2 })
        hi("NormalNC", { bg = colors.Ink3 })
        hi("StatusLine", { fg = colors.Ink3, bg = colors.Silver3, bold = true })
        hi("StatusLineNC", { fg = "fg", bg = colors.Wine2, bold = true })

        -- Color lines
        hi("ColorColumn", { bg = colors.Wine2 })
        hi("CursorColumn", { bg = colors.Gray2 })
        hi("CursorLine", { bg = colors.Gray2 })
        hi("CursorLineFold", { fg = "fg" })
        hi("FoldColumn", { fg = colors.Cyan2 })
        hi("Folded", { fg = colors.Cyan2, bg = colors.Ink4 })
        hi("LineNr", { fg = colors.Gray1 })
        hi("QuickFixLine", { fg = colors.Cyan1, bg = "bg", bold = true, reverse = true })

        -- Comment toggle
        hi("CommentHide", { fg = "bg" })
        hi("CommentShow", { fg = colors.Silver3 })
        hi("Comment", { link = "CommentShow" })

        -- Completion menu
        hi("Pmenu", { bg = colors.Ink4 })
        hi("PmenuSel", { fg = "bg", bg = colors.Silver3 })
        hi("PmenuThumb", { bg = colors.Silver2 })
        hi("PmenuExtra", { fg = colors.Gray1, bg = colors.Ink4 })
        hi("PmenuKind", { fg = colors.Yellow2, bg = colors.Ink4 })
        hi("PmenuMatch", { fg = colors.Red1, bg = "bg" })
        hi("PmenuMatchSel", { fg = colors.Red2, bg = colors.Silver3 })
        hi("PmenuSbar", { link = "Pmenu" })
        hi("PmenuKindSel", { link = "PmenuSel" })

        -- Diff Mode
        hi("Added", { fg = colors.Green2 })
        hi("Changed", { fg = colors.Silver3 })
        hi("Removed", { fg = colors.Red2 })
        hi("DiffAdd", { fg = colors.Green2, bg = colors.Gray2, bold = true })
        hi("DiffChange", { fg = colors.Silver3, bg = colors.Gray2, bold = true })
        hi("DiffText", { fg = colors.Yellow2, bg = colors.Gray2, bold = true })
        hi("DiffDelete", { fg = colors.Red1, bg = colors.Gray2, bold = true })

        -- Command-line
        hi("ErrorMsg", { fg = colors.Red1 })
        hi("ModeMsg", { fg = colors.Green2, bg = "bg" })
        hi("MsgArea", { fg = colors.Yellow1, bg = "bg" })
        hi("ExTUIArea", { link = "MsgArea" })

        -- Keywords
        hi("Constant", { fg = colors.Yellow1, bold = true })
        hi("String", { fg = colors.Green1 })
        hi("PreProc", { fg = colors.Red1 })

        -- Treesitter
        hi("@markup.link.vimdoc", { fg = colors.Yellow2, bold = true })
        hi("@label.vimdoc", { fg = colors.Green2, bold = true })
        hi("gitcommitSummary", { link = "Identifier" })
        hi("@markup.link.label.markdown_inline", { link = "Identifier" })
        hi("@markup.heading.gitcommit", { link = "gitcommitSummary" })
        hi("@markup.raw.markdown_inline", { fg = colors.Green1, bg = colors.Gray3 })

        -- Miscellaneous
        hi("Visual", { fg = "fg", bg = colors.Cyan3 })
        hi("LspInlayHint", { fg = colors.Cyan2, bg = colors.Ink3 })
        hi("Search", { fg = colors.Cyan1, bg = "bg", reverse = true })
        hi("IncSearch", { fg = colors.Yellow2, bg = "bg", reverse = true })
        hi("CurSearch", { link = "IncSearch" })

        -- fzf-lua {{{
        hi("FzfLuaCustomMarks", { fg = colors.Yellow2 })
        -- }}}

        -- mini.hipatterns {{{
        hi("MiniHipatternsNote", { fg = colors.Green2, bold = true, reverse = true })
        hi("MiniHipatternsFixme", { fg = colors.Red2, bold = true, reverse = true })
        -- }}}

        ---{{{
        hi("NeogitDiffAddHighlight", { fg = "NONE", bg = colors.Green3 })
        hi("NeogitDiffAdd", { fg = "NONE", bg = colors.Green4 })
        hi("NeogitDiffDelete", { fg = colors.Red2, bg = colors.Ink1 })
        hi("NeogitDiffDeleteHighlight", { fg = colors.Red1, bg = colors.Gray3 })
        hi("NeogitDiffContextHighlight", { bg = colors.Gray3 })
        hi("NeogitStagedchanges", { fg = colors.Green2, bold = true })
        hi("NeogitUnstagedchanges", { fg = colors.Yellow2, bold = true })
        hi("NeogitUntrackedfiles", { fg = colors.Red2, bold = true })
        hi("NeogitUnmergedchanges", { fg = colors.Magenta1, bold = true })
        hi("NeogitGraphPurple", { fg = colors.Yellow2 })
        hi("NeogitChangeModified", { fg = colors.Cyan2, bold = true, italic = true })
        hi("NeogitHunkHeaderHighlight", { fg = colors.Ink2, bg = colors.Gray1, bold = true })
        hi("NeogitHunkHeaderCursor", { fg = colors.Ink2, bg = colors.Silver3, bold = true })
        -- }}}

        -- vim-sneak {{{
        hi("SneakShow", { fg = colors.Ink4, bg = colors.Green1, bold = true })
        hi("Sneak", { link = "SneakShow" })
        -- }}}
elseif vim.o.background == "light" then
        -- General
        hi("Normal", { fg = colors.Ink2, bg = colors.Silver1 })
        hi("NormalNC", { bg = colors.Silver2 })
        hi("NormalFloat", { link = "NormalNC" })
        hi("StatusLine", { fg = "bg", bg = "fg" })
        hi("StatusLineNC", { fg = colors.Ink3, bg = colors.Silver3, bold = true })

        -- Color lines
        hi("ColorColumn", { bg = colors.Silver3 })
        hi("CursorColumn", { bg = colors.Gray1 })
        hi("CursorLine", { bg = colors.Gray1 })
        hi("CursorLineFold", { fg = "fg" })
        hi("FoldColumn", { fg = colors.Cyan2 })
        hi("Folded", { fg = colors.Cyan3, bg = colors.Silver3, bold = true })
        hi("LineNr", { fg = colors.Gray2 })
        hi("QuickFixLine", { fg = colors.Cyan2, bg = "bg", bold = true, reverse = true })

        -- Comment toggle
        hi("CommentHide", { fg = "bg" })
        hi("CommentShow", { fg = colors.Gray2 })
        hi("Comment", { link = "CommentShow" })

        -- Completion menu
        hi("Pmenu", { fg = colors.Silver1, bg = colors.Gray2 })
        hi("PmenuSel", { fg = "fg", bg = colors.Silver3 })
        hi("PmenuThumb", { bg = colors.Silver2 })
        -- hi("PmenuExtra", { fg = colors.Gray1, bg = colors.Ink4 })
        hi("PmenuKind", { fg = colors.Yellow2, bg = colors.Gray2 })
        -- hi("PmenuMatch", { fg = colors.Red1, bg = "bg" })
        -- hi("PmenuMatchSel", { fg = colors.Red2, bg = colors.Silver3 })
        hi("PmenuSbar", { link = "Pmenu" })
        hi("PmenuKindSel", { link = "PmenuSel" })

        -- Diff Mode
        -- hi("Added", { fg = colors.Green2 })
        -- hi("Changed", { fg = colors.Green1 })
        -- hi("Removed", { fg = colors.Red2 })
        -- hi("DiffAdd", { fg = colors.Green2, bg = colors.Gray2, bold = true })
        hi("DiffChange", { fg = colors.Ink4, bg = colors.Silver3, bold = true })
        hi("DiffText", { fg = colors.Yellow1, bg = colors.Silver3, bold = true })
        hi("DiffDelete", { fg = colors.Red2, bold = true })

        -- Command-line
        hi("ErrorMsg", { fg = colors.Silver1, bg = colors.Red2 })
        hi("ModeMsg", { fg = colors.Green2, bg = "bg" })
        hi("MsgArea", { fg = colors.Wine1, bg = "bg" })
        hi("ExTUIArea", { link = "MsgArea" })

        -- Keywords
        hi("Constant", { fg = colors.Yellow3, bold = true })
        hi("String", { fg = colors.Green3 })
        hi("PreProc", { fg = colors.Red1 })

        -- Spelling
        hi("SpellBad", { sp = colors.Red2, undercurl = true })

        -- Treesitter
        hi("@markup.link.vimdoc", { fg = colors.Cyan3, bold = true })
        hi("@label.vimdoc", { fg = colors.Green2, bold = true })
        hi("gitcommitSummary", { link = "Identifier" })
        hi("@markup.link.label.markdown_inline", { link = "Identifier" })
        hi("@markup.heading.gitcommit", { link = "gitcommitSummary" })
        hi("@markup.raw.markdown_inline", { fg = colors.Cyan3, bg = colors.Silver3 })

        -- Miscellaneous
        hi("Visual", { fg = "bg", bg = colors.Cyan3 })
        hi("LspInlayHint", { fg = colors.Cyan3, bg = colors.Silver3 })
        hi("IncSearch", { fg = colors.Yellow2, bg = "fg", reverse = true })
        hi("CurSearch", { link = "IncSearch" })

        -- mini.hipatterns {{{
        hi("MiniHipatternsNote", { fg = colors.Green2, bold = true, reverse = true })
        hi("MiniHipatternsFixme", { fg = colors.Red2, bold = true, reverse = true })
        -- }}}

        ---{{{
        hi("NeogitDiffAddHighlight", { fg = "NONE", bg = colors.Green1 })
        hi("NeogitDiffAdd", { fg = "NONE", bg = colors.Green2 })
        hi("NeogitDiffDelete", { fg = colors.Ink4, bg = colors.Red2 })
        hi("NeogitDiffDeleteHighlight", { fg = colors.Ink4, bg = colors.Red1 })
        hi("NeogitDiffContextHighlight", { bg = colors.Silver1 })
        hi("NeogitDiffContext", { bg = colors.Silver2 })
        hi("NeogitStagedchanges", { fg = colors.Green2, bold = true })
        hi("NeogitUnstagedchanges", { fg = colors.Yellow2, bold = true })
        hi("NeogitUntrackedfiles", { fg = colors.Red2, bold = true })
        hi("NeogitUnmergedchanges", { fg = colors.Magenta1, bold = true })
        hi("NeogitGraphPurple", { fg = colors.Yellow2 })
        -- }}}

        -- vim-sneak {{{
        hi("SneakShow", { fg = colors.Ink4, bg = colors.Green1, bold = true })
        hi("Sneak", { link = "SneakShow" })
        -- }}}
end

-- MatchParen
local matchparen = vim.api.nvim_create_augroup("MatchParenInsertMode", { clear = true })
vim.api.nvim_create_autocmd({ "InsertEnter", "CmdlineEnter" }, {
        group = matchparen,
        callback = function()
                hi("MatchParen", {})
        end,
})
vim.api.nvim_create_autocmd({ "ColorScheme", "InsertLeave", "CmdlineLeave" }, {
        group = matchparen,
        callback = function()
                hi("MatchParen", { bold = true, reverse = true })
        end,
})

-- vim: nowrap
