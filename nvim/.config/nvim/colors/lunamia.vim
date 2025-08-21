runtime colors/lunaperche.vim

hi Normal guibg=Black guifg=#cdd6f4
hi NormalNC guibg=#0f0f0f
hi! link NormalFloat Normal
hi! link FloatBorder NormalFloat
hi Folded guibg=#181825 gui=bold
hi ColorColumn guibg=#313244
hi StatusLine guibg=#edf6f4 guifg=#313244
hi! link TabLineFill ColorColumn
hi! link CursorLineNr String

hi CommentHide guifg=Black ctermfg=0
hi CommentShow guifg=#5fafff ctermfg=8
hi Comment ctermfg=8

hi Visual ctermbg=6
hi MsgArea guifg=#5fd75f gui=bold
hi QuickFixLine gui=bold

hi ModeMsg guifg=NvimLightGreen
hi ErrorMsg guifg=Black gui=bold
hi DiffAdd guibg=NvimDarkGreen guifg=#5fd75f
hi! link Error Removed
hi! link DiagnosticError Removed

hi NonText guifg=#282835
hi LspInlayHint guifg=#fec43f guibg=#0f0f0f gui=bold
hi Delimiter guifg=NvimLightGrey2
hi Statement guifg=#afffff
hi markdownBlockQuote gui=bold
hi @markup.link.vimdoc guifg=#e0d561 gui=bold
hi @label.vimdoc guifg=NvimLightGreen gui=bold

hi gitcommitSummary guifg=#87d787 gui=bold
hi! link @markup.heading.gitcommit gitcommitSummary

hi! link @lsp.type.property.lua Type

let g:terminal_color_0  = '#282828'
let g:terminal_color_1  = '#ee5396'
let g:terminal_color_2  = '#25be6a'
let g:terminal_color_3  = '#f9e2af'
let g:terminal_color_4  = '#78a9ff'
let g:terminal_color_5  = '#be95ff'
let g:terminal_color_6  = '#33b1ff'
let g:terminal_color_7  = '#dfdfe0'
let g:terminal_color_8  = '#484848'
let g:terminal_color_9  = '#f16da6'
let g:terminal_color_10 = '#46c880'
let g:terminal_color_11 = '#fafecb'
let g:terminal_color_12 = '#8cb6ff'
let g:terminal_color_13 = '#c8a5ff'
let g:terminal_color_14 = '#52bdff'
let g:terminal_color_15 = '#e4e4e5'

hi Pmenu guibg=#181825
hi PmenuExtra guibg=#181825
hi PmenuKind guifg=#ffd787 guibg=#181825
hi! link PmenuSbar Pmenu
hi BlinkCmpDoc guifg=#cdd6f4 guibg=#181825
hi! link BlinkCmpDocBorder BlinkCmpDoc

"{{
hi MiniHipatternsNote guifg=#a6e3a1 gui=bold,reverse ctermfg=7 cterm=bold,reverse
"}}

"{{
hi MiniIconsAzure guifg=#74c7ec
hi MiniIconsBlue guifg=#89b4fa
hi MiniIconsCyan guifg=#94e2d5
hi MiniIconsGreen guifg=#a6e3a1
hi MiniIconsGrey guifg=#cdd6f4
hi MiniIconsOrange guifg=#fab387
hi MiniIconsPurple guifg=#cba6f7
hi MiniIconsRed guifg=#f38ba8
hi MiniIconsYellow guifg=#f9e2af
"}}

"{{
hi NeogitDiffAddHighlight guifg=#ffd787 guibg=#005523 ctermfg=2
hi NeogitDiffDeleteHighlight guifg=#d78787 guibg=#563434 ctermfg=1
hi NeogitStagedchanges guifg=#87d787 gui=bold ctermfg=2 cterm=bold
hi NeogitUnstagedchanges guifg=#fab387 gui=bold ctermfg=3 cterm=bold
hi NeogitUntrackedfiles guifg=#f38ba8 gui=bold ctermfg=1 cterm=bold
hi NeogitUnmergedchanges guifg=#cba6f7 gui=bold ctermfg=5 cterm=bold
hi NeogitGraphPurple guifg=#fab387 ctermfg=2 cterm=bold
hi! link NeogitPopupConfigEnabled Statement
hi! link NeogitPopupOptionEnabled Statement
hi! link NeogitPopupSwitchEnabled Statement
"}}

"{{
hi! link RainbowDelimiterRed Special
hi! link RainbowDelimiterYellow Delimiter
hi RainbowDelimiterBlue guifg=#87d787 ctermfg=2
hi! link RainbowDelimiterOrange Special
hi! link RainbowDelimiterGreen Delimiter
hi RainbowDelimiterViolet guifg=#87d787 ctermfg=2
hi clear RainbowDelimiterCyan
"}}

"{{
hi RenderMarkdownCode guibg=#181825
"}}

"{{
hi LualineNormalA guibg=#181825 guifg=#89b4fa gui=bold
hi LualineNormalB guibg=#313244 guifg=#89b4fa gui=bold
hi LualineNormalC guibg=#181825 guifg=#edf6f4

hi LualineInsertA guibg=#181825 guifg=#a6e3a1 gui=bold
hi LualineInsertB guibg=#313244 guifg=#a6e3a1 gui=bold

hi! link LualineTerminalA LualineInsertA
hi! link LualineTerminalB LualineInsertB

hi LualineVisualA guibg=#181825 guifg=#cba6f7 gui=bold
hi LualineVisualB guibg=#313244 guifg=#cba6f7 gui=bold

hi LualineReplaceA guibg=#181825 guifg=#f38ba8 gui=bold
hi LualineReplaceB guibg=#313244 guifg=#f38ba8 gui=bold

hi LualineCommandA guibg=#181825 guifg=#fab387 gui=bold
hi LualineCommandB guibg=#313244 guifg=#fab387 gui=bold

hi LualineInactiveA guibg=#767676 guifg=#0f0f0f gui=bold
hi LualineInactiveB guibg=#313244 guifg=#0f0f0f gui=bold
hi LualineInactiveC guibg=#767676 guifg=#edf6f4 gui=bold
"}}
