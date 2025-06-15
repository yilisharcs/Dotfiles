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

let g:terminal_colors_mia = [
      \ '#282828',
      \ '#ee5396',
      \ '#25be6a',
      \ '#f9e2af',
      \ '#78a9ff',
      \ '#be95ff',
      \ '#33b1ff',
      \ '#dfdfe0',
      \ '#484848',
      \ '#f16da6',
      \ '#46c880',
      \ '#fafecb',
      \ '#8cb6ff',
      \ '#c8a5ff',
      \ '#52bdff',
      \ '#e4e4e5']

for i in range(g:terminal_ansi_colors->len())
  let g:terminal_color_{i} = g:terminal_colors_mia[i]
endfor

hi Pmenu guibg=#181825
hi PmenuExtra guibg=#181825
hi PmenuKind guifg=#ffd787 guibg=#181825
hi! link PmenuSbar Pmenu
hi BlinkCmpDoc guifg=#cdd6f4 guibg=#181825
hi! link BlinkCmpDocBorder BlinkCmpDoc

hi MiniHipatternsNote guifg=#a6e3a1 gui=bold,reverse

hi MiniIconsAzure guifg=#74c7ec
hi MiniIconsBlue guifg=#89b4fa
hi MiniIconsCyan guifg=#94e2d5
hi MiniIconsGreen guifg=#a6e3a1
hi MiniIconsGrey guifg=#cdd6f4
hi MiniIconsOrange guifg=#fab387
hi MiniIconsPurple guifg=#cba6f7
hi MiniIconsRed guifg=#f38ba8
hi MiniIconsYellow guifg=#f9e2af

hi NeogitStagedchanges guifg=#87d787 gui=bold
hi NeogitUnstagedchanges guifg=#fab387 gui=bold
hi NeogitUntrackedfiles guifg=#f38ba8 gui=bold
hi NeogitUnmergedchanges guifg=#cba6f7 gui=bold
hi NeogitGraphPurple guifg=#fab387
hi! link NeogitPopupConfigEnabled Statement
hi! link NeogitPopupOptionEnabled Statement
hi! link NeogitPopupSwitchEnabled Statement

hi! link RainbowDelimiterRed Special
hi! link RainbowDelimiterYellow Delimiter
hi RainbowDelimiterBlue guifg=#87d787
hi! link RainbowDelimiterOrange Special
hi! link RainbowDelimiterGreen Delimiter
hi RainbowDelimiterViolet guifg=#87d787
hi clear RainbowDelimiterCyan

hi RenderMarkdownCode guibg=#181825

hi! link @lsp.type.property.lua Type
hi! link @comment Comment
