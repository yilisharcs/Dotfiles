if vim.g.colors_name then
        vim.cmd.highlight("clear")
end
vim.cmd.syntax("reset")

vim.g.colors_name = "moyin"

local colors = {
        Silver1 = "#cdd6f4",
        Silver2 = "#bcc8f0",
        Silver3 = "#afafff",

        Ink1 = "#0c1018",
        Ink2 = "#070b14",
        Ink3 = "#04070c",
        Ink4 = "#020407",

        Gray1 = "#708090",
        Gray2 = "#362b49",
        Gray3 = "#1e1829",

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

        Cyan1 = "#8cf8f7",
        Cyan2 = "#00afff",
        Cyan3 = "#004666",

        White1 = "#faebd7",
}

local function hi(name, val)
        -- force links
        val.force = true
        -- make sure that `cterm` attribute is not populated from `gui`
        val.cterm = val.cterm or {} ---@type vim.api.keyset.highlight
        -- define global highlight
        vim.api.nvim_set_hl(0, name, val)
end

local terminal_ansi_colors = {
        colors.Ink4,
        colors.Red2,
        colors.Green2,
        colors.Yellow2,
        colors.Blue1,
        colors.Magenta2,
        colors.Cyan2,
        colors.Silver3,
        --
        colors.Gray1,
        colors.Red1,
        colors.Green2,
        colors.Yellow1,
        colors.Silver2,
        colors.Magenta1,
        colors.Cyan1,
        colors.Silver1,
}
for k, v in ipairs(terminal_ansi_colors) do
        local num = "terminal_color_" .. k - 1
        vim.g[num] = v
end

-- general
hi("Normal", { fg = colors.Silver1, bg = colors.Ink2, ctermfg = "white" })
hi("NormalNC", { bg = colors.Ink3 })
hi("StatusLine", { fg = "fg", bg = colors.Gray2, bold = true, ctermfg = "white", ctermbg = "NONE" })
hi("StatusLineNC", { fg = "fg", bg = colors.Gray3, bold = true, ctermfg = "grey" })
hi("TabLineSel", { fg = colors.Yellow1, bg = colors.Ink1, bold = true, ctermfg = "yellow", ctermbg = "yellow" })
hi("Title", { fg = "NONE", bold = true })

-- color lines
hi("ColorColumn", { bg = colors.Gray3, ctermbg = "blue" })
hi("CursorColumn", { bg = colors.Gray2 })
hi("CursorLine", { bg = colors.Gray2 })
hi("CursorLineFold", { fg = "fg" })
hi("FoldColumn", { fg = colors.Cyan2, ctermfg = "cyan" })
hi("Folded", { fg = colors.Cyan2, bg = colors.Ink4, ctermfg = "cyan" })
hi("LineNr", { fg = colors.Gray1, ctermfg = "blue" })
hi("QuickFixLine", { fg = colors.Cyan1, bg = "bg", bold = true, reverse = true, ctermfg = "black", ctermbg = "cyan" })

-- comment toggle
hi("CommentHide", { fg = "bg" })
hi("Comment", { fg = colors.Silver3, ctermfg = "grey" })

-- completion menu
hi("Pmenu", { bg = colors.Ink4, ctermfg = "black", ctermbg = "grey" })
hi("PmenuSel", { fg = "bg", bg = colors.Silver3, ctermfg = "yellow", ctermbg = "black" })
hi("PmenuThumb", { bg = colors.Silver2, ctermbg = "black" })
hi("PmenuExtra", { fg = colors.Gray1, bg = colors.Ink4 })
hi("PmenuKind", { fg = colors.Yellow2, bg = colors.Ink4 })
hi("PmenuMatch", { fg = colors.Red1, bg = "bg", ctermfg = "red" })
hi("PmenuMatchSel", { fg = colors.Red2, bg = colors.Silver3 })
hi("PmenuSbar", { link = "Pmenu" })
hi("PmenuKindSel", { link = "PmenuSel" })

-- diff mode
hi("Added", { fg = colors.Green2, ctermfg = "green" })
hi("Changed", { fg = colors.Silver3, ctermfg = "grey" })
hi("Removed", { fg = colors.Red2, ctermfg = "red" })
hi("DiffAdd", { fg = colors.Green2, bg = colors.Gray2, bold = true, ctermfg = "green" })
hi("DiffChange", { fg = colors.Silver3, bg = colors.Gray2, bold = true, ctermfg = "grey" })
hi("DiffText", { fg = colors.Yellow2, bg = colors.Gray2, bold = true, ctermfg = "yellow" })
hi("DiffDelete", { fg = colors.Red1, bg = colors.Gray2, bold = true, ctermfg = "red" })

-- command-line
hi("ErrorMsg", { fg = colors.Red1, ctermfg = "red" })
hi("ModeMsg", { fg = colors.Green2, ctermfg = "green" })
hi("MsgArea", { fg = colors.Yellow1, bg = "bg", ctermfg = "yellow" })
hi("ExTUIArea", { link = "MsgArea" })

-- keywords
hi("Constant", { update = true, bold = true })
hi("Statement", { fg = colors.Yellow1, bold = true, ctermfg = "yellow" })
hi("String", { fg = colors.Green1, ctermfg = "green" })
hi("PreProc", { fg = colors.Red1, bold = true, ctermfg = "red" })
hi("Delimiter", { fg = colors.Silver3, ctermfg = "grey" })
hi("Type", { bold = true })
hi("Label", { fg = colors.Magenta1, ctermfg = "magenta" })

-- treesitter
hi("@markup.link.vimdoc", { fg = colors.Yellow2, bold = true, ctermfg = "yellow" })
hi("@markup.raw.markdown_inline", { fg = colors.Green1, bg = colors.Gray3 })
hi("markdownCodeBlock", { bg = colors.Gray3 })
--
hi("@label.vimdoc", { fg = colors.Green2, bold = true, ctermfg = "green" })
--
hi("gitcommitSummary", { link = "Identifier" })
--
hi("@markup.heading.gitcommit", { link = "gitcommitSummary" })
hi("@markup.link.label.markdown_inline", { link = "Identifier" })
--
hi("@character.rust", { link = "String" })
hi("@function.macro.rust", { link = "PreProc" })
hi("@lsp.typemod.keyword.unsafe.rust", { fg = colors.Red2, bold = false, ctermfg = "red" })
hi("rustAttribute", { link = "Label" })
--
hi("@number.hex", { link = "Statement" })
--
hi("@keyword.conditional.fennel", { fg = colors.Silver2, bold = true, ctermfg = "blue" })

-- LSP
hi("DiagnosticError", { fg = colors.Red2, ctermfg = "red" })
hi("DiagnosticWarn", { fg = colors.Yellow3, ctermfg = "yellow" })
hi("DiagnosticInfo", { fg = colors.Cyan2, ctermfg = "cyan" })
hi("DiagnosticHint", { fg = colors.Blue2, ctermfg = "blue" })
hi("DiagnosticOk", { fg = colors.Green2, ctermfg = "green" })

-- misc
hi("Visual", { fg = "fg", bg = colors.Cyan3, ctermbg = "cyan" })
hi("LspInlayHint", { fg = colors.Cyan2, bg = colors.Ink3, ctermfg = "cyan" })
hi("Search", { fg = colors.Cyan1, bg = "bg", reverse = true, ctermfg = "cyan" })
hi("IncSearch", { fg = colors.Yellow2, bg = "bg", reverse = true, ctermfg = "black", ctermbg = "yellow" })
hi("CurSearch", { link = "IncSearch" })
-- syn jj
hi("jjGrey", { fg = colors.Silver3, ctermfg = "grey", bold = true })
hi("jjRed", { fg = colors.Red2, ctermfg = "red", bold = true })
hi("jjGreen", { fg = colors.Green2, ctermfg = "green", bold = true })
hi("jjYellow", { fg = colors.Yellow2, ctermfg = "yellow" })
hi("jjBlue", { fg = colors.Blue1, ctermfg = "blue", bold = true })
hi("jjMagenta", { fg = colors.Magenta1, ctermfg = "magenta", bold = true })
hi("jjCyan", { fg = colors.Cyan1, ctermfg = "cyan" })
hi("jjCyan2", { fg = colors.Cyan2, ctermfg = "cyan" })
hi("jjWhite", { fg = colors.Silver1, ctermfg = "white", bold = true })

-- diffview.nvim {{{
hi("DiffviewFilePanelSelected", { fg = colors.Yellow1, bold = true, ctermfg = "yellow" })
-- }}}

-- fzf-lua {{{
hi("FzfLuaCustomMarks", { fg = colors.Yellow2, ctermfg = "yellow" })
hi("FzfLuaFzfCursorLine", { ctermfg = "yellow", ctermbg = "blue" })
hi("FzfLuaFzfPointer", { fg = colors.Red2, ctermfg = "yellow" })
-- }}}

-- mini.hipatterns {{{
hi("MiniHipatternsNote", { fg = colors.Green2, bold = true, reverse = true, ctermbg = "green" })
hi("MiniHipatternsFixme", { fg = colors.Red2, bold = true, reverse = true, ctermbg = "red" })
-- }}}

-- mini.icons {{{
hi("MiniIconsYellow", { fg = colors.Yellow1 })
-- }}}

-- neogit {{{
hi("NeogitDiffAddHighlight", { fg = "NONE", bg = colors.Green3, ctermbg = "green" })
hi("NeogitDiffAdd", { fg = "NONE", bg = colors.Green4, ctermbg = "green" })
hi("NeogitDiffDelete", { fg = colors.Red2, bg = colors.Ink1, ctermfg = "red" })
hi("NeogitDiffDeleteHighlight", { fg = colors.Red1, bg = colors.Gray3, ctermfg = "red", ctermbg = "grey" })
hi("NeogitDiffContextHighlight", { bg = colors.Gray3 })
hi("NeogitStagedchanges", { fg = colors.Green2, bold = true, ctermfg = "green" })
hi("NeogitUnstagedchanges", { fg = colors.Yellow2, bold = true, ctermfg = "yellow" })
hi("NeogitUntrackedfiles", { fg = colors.Red2, bold = true, ctermfg = "red" })
hi("NeogitUnmergedchanges", { fg = colors.Magenta1, bold = true, ctermfg = "magenta" })
hi("NeogitGraphPurple", { fg = colors.Yellow2, ctermfg = "yellow" })
hi("NeogitChangeModified", { fg = colors.Cyan2, bold = true, italic = true, ctermfg = "cyan" })
hi("NeogitHunkHeaderHighlight", {
        fg = colors.Ink2,
        bg = colors.Gray1,
        bold = true,
        ctermfg = "black",
        ctermbg = "grey",
})
hi("NeogitHunkHeaderCursor", {
        fg = colors.Ink2,
        bg = colors.Silver3,
        bold = true,
        ctermfg = "black",
        ctermbg = "white",
})
-- }}}

-- rainbow-delimiters {{{
hi("RainbowHide", { fg = "bg" })
hi("RainbowDelimiterRed", { link = "Delimiter" })
hi("RainbowDelimiterYellow", { link = "WarningMsg" })
hi("RainbowDelimiterBlue", { link = "ModeMsg" })
hi("RainbowDelimiterOrange", { link = "Label" })
hi("RainbowDelimiterGreen", { link = "RainbowDelimiterRed" })
hi("RainbowDelimiterViolet", { link = "RainbowDelimiterYellow" })
hi("RainbowDelimiterCyan", { link = "RainbowDelimiterBlue" })
-- }}}

-- vim-sneak {{{
hi("SneakShow", { fg = colors.Ink4, bg = colors.Green1, bold = true })
hi("Sneak", { link = "SneakShow" })
-- }}}

-- matchparen
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
                hi("MatchParen", { fg = colors.Red2, bold = true })
        end,
})

-- vim: nowrap
