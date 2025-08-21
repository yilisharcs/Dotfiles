runtime colors/zaibatsu.vim

hi Normal guifg=#cdd6f4
hi NormalNC guibg=#0a001a
hi! link NormalFloat Normal
hi! link FloatBorder NormalFloat
hi Folded gui=bold,reverse
hi! link TabLineFill ColorColumn
hi! link CursorLineNr Special
hi CursorLine guibg=NONE

hi CommentHide guifg=#0e0024 ctermfg=0
hi CommentShow guifg=#afafff ctermfg=8
hi Comment ctermfg=8

hi Visual ctermbg=6
hi! link MsgArea Special
hi QuickFixLine gui=bold,reverse

hi Added   guifg=#87ff00 ctermfg=1
hi Changed guifg=#afafff ctermfg=2
hi Removed guifg=#ff5faf ctermfg=3

hi DiffAdd    gui=bold
hi DiffChange gui=bold
hi DiffText   gui=bold
hi DiffDelete gui=bold

hi MatchParen gui=bold
hi NonText guifg=#878092 guibg=NONE
hi EndOfBuffer guibg=NONE
hi Delimiter guifg=NvimLightGrey2
hi markdownBlockQuote gui=bold
hi @markup.link.vimdoc guifg=#ffaf00 gui=bold
hi @label.vimdoc guifg=#00af5f gui=bold

hi! link gitcommitSummary Identifier
hi! link @markup.heading.gitcommit gitcommitSummary

hi! link @lsp.type.property.lua Delimiter

let g:terminal_color_0  = '#0a001a'

hi Pmenu guifg=NONE guibg=#0a001a
hi PmenuExtra guibg=#0a001a
hi PmenuKind guifg=#ffaf00 guibg=#0a001a
hi PmenuMatch guifg=#ffafff guibg=#0e0024
hi PmenuMatchSel guifg=#d7005f
hi! link PmenuSbar Pmenu
hi PmenuThumb guibg=#afafff
hi BlinkCmpDoc guifg=#cdd6f4 guibg=#0a001a
hi! link BlinkCmpDocBorder BlinkCmpDoc

"{{
hi MiniHipatternsNote guifg=#00af5f gui=bold,reverse ctermfg=7 cterm=bold,reverse
"}}

"{{
hi NeogitDiffAddHighlight    guifg=NONE guibg=#005523 ctermfg=2
hi NeogitDiffAdd             guifg=NONE guibg=#00220e ctermfg=2
hi NeogitDiffDeleteHighlight guifg=NONE guibg=#510039 ctermfg=1
hi NeogitDiffDelete          guifg=NONE guibg=#1e0015 ctermfg=1
hi NeogitStagedchanges       guifg=#00af5f gui=bold ctermfg=2 cterm=bold
hi NeogitUnstagedchanges     guifg=#ffaf00 gui=bold ctermfg=3 cterm=bold
hi NeogitUntrackedfiles      guifg=#d7005f gui=bold ctermfg=1 cterm=bold
hi NeogitUnmergedchanges     guifg=#ff5faf gui=bold ctermfg=5 cterm=bold
hi NeogitGraphPurple         guifg=#ffaf00 ctermfg=2 cterm=bold
hi! link NeogitPopupConfigEnabled Special
hi! link NeogitPopupOptionEnabled Special
hi! link NeogitPopupSwitchEnabled Special
"}}

"{{
hi RainbowDelimiterRed    guifg=#87ff00 ctermfg=1
hi RainbowDelimiterYellow guifg=#d7005f ctermfg=3
hi RainbowDelimiterBlue   guifg=#00afff ctermfg=4
hi RainbowDelimiterOrange guifg=#ffaf00 ctermfg=7
hi RainbowDelimiterGreen  guifg=#00af5f ctermfg=2
hi RainbowDelimiterViolet guifg=#ff5faf ctermfg=5
hi RainbowDelimiterCyan   guifg=#5f00d7 ctermfg=6
"}}

"{{
hi RenderMarkdownH1Bg guifg=#87ff00 guibg=NONE gui=bold,reverse
hi RenderMarkdownH2Bg guifg=#ff5faf guibg=NONE gui=bold,reverse
hi RenderMarkdownH3Bg guifg=#8787ff guibg=NONE gui=bold,reverse
hi RenderMarkdownH4Bg guifg=#ffaf00 guibg=NONE gui=bold,reverse
hi RenderMarkdownH5Bg guifg=#00af5f guibg=NONE gui=bold,reverse
hi RenderMarkdownH6Bg guifg=#afafff guibg=NONE gui=bold,reverse
"}}

"{{
hi LualineNormalA guibg=#1e0015 guifg=#afafff gui=bold
hi LualineNormalB guibg=#510039 guifg=#afafff gui=bold
hi LualineNormalC guibg=#1e0015 guifg=#edf6f4

hi LualineInsertA guibg=#1e0015 guifg=#00af5f gui=bold
hi LualineInsertB guibg=#510039 guifg=#00af5f gui=bold

hi! link LualineTerminalA LualineInsertA
hi! link LualineTerminalB LualineInsertB

hi LualineVisualA guibg=#1e0015 guifg=#5fd7ff gui=bold
hi LualineVisualB guibg=#510039 guifg=#5fd7ff gui=bold

hi LualineReplaceA guibg=#1e0015 guifg=#d7005f gui=bold
hi LualineReplaceB guibg=#510039 guifg=#d7005f gui=bold

hi LualineCommandA guibg=#1e0015 guifg=#ffaf00 gui=bold
hi LualineCommandB guibg=#510039 guifg=#ffaf00 gui=bold

hi LualineInactiveA guibg=#ff5faf guifg=#0e0024 gui=bold
hi LualineInactiveB guibg=#510039 guifg=#edf6f4 gui=bold
hi LualineInactiveC guibg=#ff5faf guifg=#0e0024 gui=bold
"}}
