if vim.g.colors_name then
        vim.cmd.highlight("clear")
end
if vim.fn.exists("syntax_on") then
        vim.cmd.syntax("reset")
end

vim.g.colors_name = "silverwine"

local colors = {
        Wine1 = "#3f006c",
        Wine2 = "#2a0048",
        Wine3 = "#12001f",

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

        White1 = "#faebd7",

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

local function hi(name, val)
        -- force links
        val.force = true
        -- make sure that `cterm` attribute is not populated from `gui`
        val.cterm = val.cterm or {} ---@type vim.api.keyset.highlight
        -- define global highlight
        vim.api.nvim_set_hl(0, name, val)
end

-- custom
hi("QuickFixBg", { bg = colors.Wine3 })

-- general
hi("Normal", { fg = colors.Silver1, bg = colors.Ink2, ctermfg = "white" })
hi("NormalNC", { bg = colors.Ink3 })
hi("StatusLine", { fg = "fg", bg = colors.Gray2, bold = true, ctermfg = "black", ctermbg = "grey" })
hi("StatusLineNC", { fg = "fg", bg = colors.Wine2, bold = true })
hi("TabLineSel", { fg = colors.Yellow1, bg = colors.Ink1, bold = true, ctermfg = "yellow", ctermbg = "yellow" })
hi("Title", { fg = "NONE", bold = true })

-- color lines
hi("ColorColumn", { bg = colors.Wine2, ctermbg = "magenta" })
hi("CursorColumn", { bg = colors.Gray2 })
hi("CursorLine", { bg = colors.Gray2 })
hi("CursorLineFold", { fg = "fg" })
hi("FoldColumn", { fg = colors.Cyan2, ctermfg = "cyan" })
hi("Folded", { fg = colors.Cyan2, bg = colors.Ink4, ctermfg = "cyan" })
hi("LineNr", { fg = colors.Gray1, ctermfg = "blue" })
hi("QuickFixLine", { fg = colors.Cyan1, bg = "bg", bold = true, reverse = true, ctermfg = "black", ctermbg = "cyan" })

-- comment toggle
hi("CommentHide", { fg = "bg" })
hi("CommentShow", { fg = colors.Silver3, ctermfg = "grey" })
hi("Comment", { link = "CommentShow" })

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
hi("@character.rust", { link = "String", bold = false })
hi("@lsp.typemod.keyword.unsafe.rust", { fg = colors.Red2, bold = false, ctermfg = "red" })
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
