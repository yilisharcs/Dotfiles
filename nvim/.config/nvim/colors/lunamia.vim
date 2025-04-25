runtime colors/lunaperche.vim

hi Normal guibg=Black guifg=#cdd6f4
hi NormalNC guibg=#0f0f0f guifg=#cdd6f4
hi Folded guibg=#181825 guifg=#fec43f gui=bold
hi ColorColumn guibg=#181825
hi Statusline guibg=#181825 guifg=#edf6f4
hi! link TabLineFill ColorColumn

hi LineNrAbove guifg=#585858
hi! link LineNrBelow LineNrAbove
hi! link LineNr String

hi MsgArea guifg=#e0d561 gui=bold
hi QuickFixLine guibg=#ff87ff guifg=Black gui=bold
hi! link PmenuSbar Pmenu

hi ModeMsg guifg=NvimLightGreen
hi ErrorMsg guibg=#ff5f5f guifg=Black gui=bold
hi DiffAdd guibg=NvimDarkGreen guifg=#5fd75f
hi Removed guifg=#e64343
hi! link Error Removed
hi! link DiagnosticError Removed

hi NonText guifg=#282835
hi LspInlayHint guifg=#585858 guibg=#0f0f0f gui=bold
hi Delimiter guifg=NvimLightGrey2
hi Statement guifg=#afffff
hi markdownBlockQuote gui=bold
hi @markup.link.vimdoc guifg=#e0d561 gui=bold
hi @label.vimdoc guifg=NvimLightGreen gui=bold

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
