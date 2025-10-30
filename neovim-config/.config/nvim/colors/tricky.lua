vim.cmd.highlight("clear")
vim.g.colors_name = "tricky"

--stylua: ignore start
vim.g.terminal_ansi_colors = {
        "#060010", "#d7005f", "#00af5f", "#ffaf00", "#5f5fff", "#d700ff", "#00afff", "#d7d5db",
        "#878092", "#ff5faf", "#00d700", "#ffd700", "#8787ff", "#ff87ff", "#00ffff", "#ffffff"
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

-- General
hi("Normal",       { fg = "#cdd6f4", bg = "#0e0024",              ctermfg = "white",    ctermbg = "black" })
hi("NormalNC",     {                 bg = "#090019" })
hi("NonText",      { fg = "#878092",                              ctermfg = "darkgray", ctermbg = "black" })
hi("Conceal",      {})
hi("StatusLine",   { fg = "#edf6f4", bg = "#1e0015", bold = true, ctermfg = "white",    ctermbg = "black", cterm = { reverse = true } })
hi("StatusLineNC", { fg = "#0e0024", bg = "#afafff", bold = true, ctermfg = "darkgray", ctermbg = "gray",  cterm = { reverse = true } })
hi("NormalFloat",  { link = "Normal" })
hi("FloatBorder",  { link = "Normal" })
hi("ExTUIArea",    { fg = "#87ff00", bg = "#0e0024" })

-- Color lines
hi("ColorColumn",    {                 bg = "#510039",                              ctermfg = "white",      ctermbg = "darkred" })
hi("CursorLine",     {                                                                                                           cterm = { underline = true } })
hi("CursorLineFold", { fg = "#edf6f4" })
hi("CursorColumn",   {                 bg = "#362b49",                              ctermbg = "blue" })
hi("FoldColumn",     { fg = "#00afff",                                              ctermfg = "darkcyan" })
hi("Folded",         { fg = "#00afff", bg = "#1e1829", bold = true,                 ctermfg = "darkyellow", ctermbg = "black",   cterm = { reverse = true } })
hi("LineNr",         { fg = "#afafff",                                              ctermfg = "blue" })
hi("QuickFixLine",   { fg = "#ffafff", bg = "#0e0024", bold = true, reverse = true, ctermfg = "magenta",    ctermbg = "black",   cterm = { reverse = true } })
hi("SignColumn",     { fg = "#00afff",                                                                      ctermfg = "darkcyan" })
hi("VertSplit",      { fg = "#afafff",                                              ctermfg = "blue" })

-- Comment toggle
hi("CommentHide",  { fg = "bg",      ctermfg = "black" })
hi("CommentShow",  { fg = "#afafff", ctermfg = "darkgray" })
hi("Comment",      { link = "CommentShow" })

-- Completion menu
hi("Pmenu",         {                 bg = "#060010", ctermfg = "black",    ctermbg = "white" })
hi("PmenuSel",      { fg = "#0e0024", bg = "#afafff", ctermfg = "white",    ctermbg = "blue" })
hi("PmenuThumb",    { fg = "#878092", bg = "#afafff", ctermfg = "darkgray", ctermbg = "darkgray" })
hi("PmenuExtra",    { fg = "#878092", bg = "#060010", ctermfg = "darkgray", ctermbg = "white" })
hi("PmenuKind",     { fg = "#ffaf00", bg = "#060010", ctermfg = "darkgray", ctermbg = "white" })
hi("PmenuMatch",    { fg = "#ffafff", bg = "#0e0024", ctermfg = "black",    ctermbg = "white",   cterm = { bold = true } })
hi("PmenuMatchSel", { fg = "#d7005f", bg = "#afafff", ctermfg = "white",    ctermbg = "blue" ,   cterm = { bold = true } })
hi("PmenuSbar",     { link = "Pmenu" })
hi("PmenuExtraSel", { link = "PmenuSel" })
hi("PmenuKindSel",  { link = "PmenuSel" })

-- Diff mode
hi("Added",      { fg = "#87ff00",                              ctermfg = 1 })
hi("Changed",    { fg = "#afafff",                              ctermfg = 2 })
hi("Removed",    { fg = "#ff5faf",                              ctermfg = 3 })
hi("DiffAdd",    { fg = "#87ff00", bg = "#362b49", bold = true, ctermfg = "darkgreen",   ctermbg = "white", cterm = { reverse = true } })
hi("DiffChange", { fg = "#afafff", bg = "#362b49", bold = true, ctermfg = "darkblue",    ctermbg = "white", cterm = { reverse = true } })
hi("DiffText",   { fg = "#ffaf00", bg = "#362b49", bold = true, ctermfg = "grey",        ctermbg = "black", cterm = { reverse = true } })
hi("DiffDelete", { fg = "#ff5faf", bg = "#362b49", bold = true, ctermfg = "darkmagenta", ctermbg = "white", cterm = { reverse = true } })

-- Command-line
hi("Error",      { fg = "#d70000", bg = "#ffffff", reverse = true, ctermfg = "red",   ctermbg = "white", cterm = { reverse = true } })
hi("ErrorMsg",   { fg = "#ffffff", bg = "#d70000",                 ctermfg = "white", ctermbg = "red" })
hi("ModeMsg",    { fg = "#0e0024", bg = "#87ff00",                 ctermfg = "black", ctermbg = "green" })
hi("MoreMsg",    { fg = "#87ffff",                                 ctermfg = "cyan" })
hi("WarningMsg", { fg = "#ffafff",                                 ctermfg = "magenta" })
hi("MsgArea",    { link = "Special" })

-- Keywords
hi("Constant",   { fg = "#ffff5f",                                   ctermfg = "yellow" })
hi("Identifier", { fg = "#87ffff",                                   ctermfg = "cyan" })
hi("Ignore",     { fg = "#878092",                                   ctermfg = "darkgray" })
hi("PreProc",    { fg = "#00afff",                                   ctermfg = "darkcyan" })
hi("Special",    { fg = "#87ff00",                                   ctermfg = "green" })
hi("Statement",  { fg = "#ffafff",                                   ctermfg = "magenta" })
hi("Todo",       {                 reverse = true,                                        cterm = { reverse = true } })
hi("Type",       { fg = "#ff5faf",                                   ctermfg = "red" })
hi("Underlined", {                                 underline = true,                      cterm = { underline = true } })

-- MatchParen
local matchparen = vim.api.nvim_create_augroup("MatchParenInsertMode", { clear = true })
vim.api.nvim_create_autocmd("InsertEnter", {
        group = matchparen,
        callback = function()
                hi("MatchParen", {})
        end,
})
vim.api.nvim_create_autocmd({ "ColorScheme", "InsertLeave" }, {
        group = matchparen,
        callback = function()
                hi("MatchParen", { bold = true, reverse = true, cterm = { reverse = true } })
        end,
})

-- Spelling
hi("SpellBad",   { sp = "#ff5faf", undercurl = true, ctermfg = "red",     cterm = { undercurl = true } })
hi("SpellCap",   { sp = "#87ff00", undercurl = true, ctermfg = "green",   cterm = { undercurl = true } })
hi("SpellLocal", { sp = "#ffffff", undercurl = true, ctermfg = "white",   cterm = { undercurl = true } })
hi("SpellRare",  { sp = "#ffafff", undercurl = true, ctermfg = "magenta", cterm = { undercurl = true } })

-- Treesitter elements
hi("markdownBlockQuote",          {                 bold = true })
hi("@markup.link.vimdoc",         { fg = "#ffaf00", bold = true })
hi("@label.vimdoc",               { fg = "#00af5f", bold = true })
hi("gitcommitSummary",            { link = "Identifier" })
hi("@markup.raw.block.markdown",  { link = "CommentShow" })
hi("@markup.raw.markdown_inline", { link = "CommentShow" })
hi("@markup.heading.gitcommit",   { link = "gitcommitSummary" })

-- Miscellaneous
hi("IncSearch",         { fg = "#ffaf00", bg = "#0e0024",              reverse = true, ctermfg = "darkyellow", ctermbg = "black",   cterm = { reverse = true } })
hi("Search",            { fg = "#87ffff", bg = "#0e0024",              reverse = true,                                              cterm = { reverse = true } })
hi("WildMenu",          { fg = "#0e0024", bg = "#afafff",                              ctermfg = "white",      ctermbg = "blue" })
hi("Visual",            { fg = "#0e0024", bg = "#5fd7ff",                              ctermfg = "black",      ctermbg = "darkcyan" })
hi("VisualNOS",         { fg = "#0e0024", bg = "#ffffff",                              ctermfg = "black",      ctermbg = "white" })
hi("Directory",         { fg = "#87ffff",                                              ctermfg = "cyan" })
hi("Title",             {})
hi("LspInlayHint",      { fg = "#edf6f4", bg = "#1e0015", bold = true })
hi("Question",          { fg = "#87ff00",                                              ctermfg = "green" })
hi("SpecialKey",        { fg = "#878092",                                              ctermfg = "darkgray" })
hi("debugBreakpoint",   { fg = "#87ff00", bg = "#5f00d7",              reverse = true, ctermfg = "green",      ctermbg = "darkblue", cterm = { reverse = true } })
hi("debugPC",           { fg = "#87ff00", bg = "#5f00d7",              reverse = true, ctermfg = "cyan",       ctermbg = "darkblue", cterm = { reverse = true } })
hi("ToolbarButton",     { fg = "#ffffff", bg = "#5e556d",                              ctermfg = "white",      ctermbg = "darkgray" })
hi("ToolbarLine",       {})
hi("DiagnosticError",   { fg = "#d70000" })
hi("CurSearch",         { link = "IncSearch" })
hi("CursorLineNr",      { link = "Special" })
hi("CursorLineSign",    { link = "CursorLine" })
hi("LineNrAbove",       { link = "LineNr" })
hi("LineNrBelow",       { link = "LineNr" })
hi("StatusLineTerm",    { link = "StatusLine" })
hi("StatusLineTermNC",  { link = "StatusLineNC" })
hi("TabLine",           { link = "StatusLineNC" })
hi("TabLineFill",       { link = "ColorColumn" })
hi("Terminal",          { link = "Normal" })
hi("lCursor",           { link = "Cursor" })
hi("PopupSelected",     { link = "PmenuSel" })
hi("Boolean",           { link = "Constant" })
hi("Character",         { link = "Constant" })
hi("Conditional",       { link = "Statement" })
hi("Define",            { link = "PreProc" })
hi("Delimiter",         { link = "Special" })
hi("Exception",         { link = "Statement" })
hi("Float",             { link = "Constant" })
hi("Function",          { link = "Identifier" })
hi("Include",           { link = "PreProc" })
hi("Keyword",           { link = "Statement" })
hi("Label",             { link = "Statement" })
hi("Macro",             { link = "PreProc" })
hi("Number",            { link = "Constant" })
hi("Operator",          { link = "Statement" })
hi("PreCondit",         { link = "PreProc" })
hi("Repeat",            { link = "Statement" })
hi("SpecialChar",       { link = "Special" })
hi("SpecialComment",    { link = "Special" })
hi("StorageClass",      { link = "Type" })
hi("String",            { link = "Constant" })
hi("Structure",         { link = "Type" })
hi("Tag",               { link = "Special" })
hi("Typedef",           { link = "Type" })
hi("Terminal",          { link = "Normal" })
hi("MessageWindow",     { link = "Pmenu" })
hi("PopupNotification", { link = "Todo" })

-- blink.cmp {{{
hi("BlinkCmpDoc",       { fg = "#cdd6f4", bg = "#060010" })
hi("BlinkCmpDocBorder", { link = "BlinkCmpDoc" })
-- }}}

-- fzf-lua {{{
hi("FzfLuaCustomMarks", { fg = "#ffaf00" })
-- }}}

-- Lualine {{{
hi("LualineNormalA",   { fg = "#afafff", bg = "#1e0015", bold = true })
hi("LualineNormalB",   { fg = "#afafff", bg = "#510039", bold = true })
hi("LualineNormalC",   { fg = "#edf6f4", bg = "#1e0015" })
hi("LualineInsertA",   { fg = "#87ff00", bg = "#1e0015", bold = true })
hi("LualineInsertB",   { fg = "#87ff00", bg = "#510039", bold = true })
hi("LualineTerminalA", { fg = "#00af5f", bg = "#1e0015", bold = true })
hi("LualineTerminalB", { fg = "#00af5f", bg = "#510039", bold = true })
hi("LualineVisualA",   { fg = "#5fd7ff", bg = "#1e0015", bold = true })
hi("LualineVisualB",   { fg = "#5fd7ff", bg = "#510039", bold = true })
hi("LualineReplaceA",  { fg = "#ffff5f", bg = "#1e0015", bold = true })
hi("LualineReplaceB",  { fg = "#ffff5f", bg = "#510039", bold = true })
hi("LualineCommandA",  { fg = "#ff5faf", bg = "#1e0015", bold = true })
hi("LualineCommandB",  { fg = "#ff5faf", bg = "#510039", bold = true })
hi("LualineInactiveA", { fg = "#0e0024", bg = "#afafff", bold = true })
hi("LualineInactiveB", { fg = "#edf6f4", bg = "#510039", bold = true })
hi("LualineInactiveC", { fg = "#0e0024", bg = "#afafff", bold = true })
-- }}}

-- mini.hipatterns {{{
hi("MiniHipatternsNote",  { fg = "#00af5f", bold = true, reverse = true, ctermfg = "darkgray", cterm = { bold = true, reverse = true } })
hi("MiniHipatternsFixme", { fg = "#d7005f", bold = true, reverse = true, ctermfg = "red",      cterm = { bold = true, reverse = true } })
-- }}}

-- neogit {{{
hi("NeogitDiffAddHighlight",    { fg = "NONE",    bg = "#005523",                 ctermfg = "darkgreen" })
hi("NeogitDiffAdd",             { fg = "NONE",    bg = "#00220e",                 ctermfg = "darkgreen" })
hi("NeogitDiffDeleteHighlight", { fg = "NONE",    bg = "#510039",                 ctermfg = "darkred" })
hi("NeogitDiffDelete",          { fg = "NONE",    bg = "#1e0015",                 ctermfg = "darkred" })
hi("NeogitStagedchanges",       { fg = "#00af5f",                 bold = true,    ctermfg = "darkgreen", cterm = { bold = true } })
hi("NeogitUnstagedchanges",     { fg = "#ffaf00",                 bold = true,    ctermfg = "darkgreen", cterm = { bold = true } })
hi("NeogitUntrackedfiles",      { fg = "#d7005f",                 bold = true,    ctermfg = "darkred",   cterm = { bold = true } })
hi("NeogitUnmergedchanges",     { fg = "#ff5faf",                 bold = true,    ctermfg = "darkblue",  cterm = { bold = true } })
hi("NeogitGraphPurple",         { fg = "#ffaf00",                                 ctermfg = "darkgreen", cterm = { bold = true } })
hi("NeogitPopupConfigEnabled",  { link = "Special" })
hi("NeogitPopupOptionEnabled",  { link = "Special" })
hi("NeogitPopupSwitchEnabled",  { link = "Special" })
-- }}}

-- rainbow-delimiters {{{
hi("RainbowDelimiterRed",    { fg = "#87ff00", ctermfg = "black" })
hi("RainbowDelimiterYellow", { fg = "#d7005f", ctermfg = "darkyellow" })
hi("RainbowDelimiterBlue",   { fg = "#00afff", ctermfg = "darkblue" })
hi("RainbowDelimiterOrange", { fg = "#ffaf00", ctermfg = "lightgrey" })
hi("RainbowDelimiterGreen",  { fg = "#00af5f", ctermfg = "darkgreen" })
hi("RainbowDelimiterViolet", { fg = "#ff5faf", ctermfg = "darkmagenta" })
hi("RainbowDelimiterCyan",   { fg = "#5f00d7", ctermfg = "darkcyan" })
-- }}}

-- Render Markdown {{{
hi("RenderMarkdownH1Bg",   { fg = "#87ff00", bg = "#510039", bold = true })
hi("RenderMarkdownH2Bg",   { fg = "#ffff5f", bg = "#470032", bold = true })
hi("RenderMarkdownH3Bg",   { fg = "#87ffff", bg = "#3d002a", bold = true })
hi("RenderMarkdownH4Bg",   { fg = "#ff5faf", bg = "#320023", bold = true })
hi("RenderMarkdownH5Bg",   { fg = "#ffaf00", bg = "#28001c", bold = true })
hi("RenderMarkdownH6Bg",   { fg = "#afafff", bg = "#1e0015", bold = true })
hi("RenderMarkdownCode",   {                 bg = "#1e1829" })
hi("RenderMarkdownBullet", { link = "Statement" })
-- }}}

-- vim-sneak {{{
hi("SneakShow",  { fg = "#060010", bg = "#87ff00", bold = true })
hi("Sneak",      { link = "SneakShow" })
-- }}}

-- stylua: ignore end
