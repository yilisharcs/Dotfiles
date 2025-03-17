vim.cmd.colorscheme('carbonfox')

vim.api.nvim_create_augroup('Color_Sets', { clear = true })
vim.api.nvim_create_autocmd({ 'VimEnter', 'ColorScheme' }, {
  group    = 'Color_Sets',
  callback = function()
    local hi = vim.api.nvim_set_hl

    hi(0, 'NormalFloat', { link = 'Normal' })
    -- hi(0, 'FloatBorder', { link = 'NormalFloat' })
    hi(0, 'TermCursorNC', { link = 'Normal' })
    hi(0, 'MatchParen', { fg = '#fffa2b', bold = true })
    hi(0, 'MsgArea', { fg = '#e0d561', bold = true })
    hi(0, 'SpellBad', { fg = '#e0d561', undercurl = true })
    hi(0, 'QuickFixLine', { bg = '#a6da95', fg = '#000000', bold = true })
    hi(0, 'Pmenu', { bg = '#14161b', fg = '#cdd6f4' })
    hi(0, 'PmenuSbar', { link = 'Pmenu' })
    hi(0, 'PmenuSel', { bg = '#a6da95', fg = '#000000', bold = true })
    hi(0, 'PmenuThumb', { bg = '#cdd6f4' })

    -- no italics
    hi(0, 'Type', { fg = '#f9e2af', bold = true })
    hi(0, '@type.builtin', { fg = '#52bdff', bold = true })

    hi(0, 'CmpItemAbbr', { link = 'Pmenu' }) -- doesn't work from cmp setup

    hi(0, 'TreesitterContext', { link = 'ColorColumn' })

    hi(0, 'WhichKeyNormal', { link = 'StatusLine' })

    hi(0, '@markup.link.vimdoc', { fg = '#e0d561', bold = true })
    hi(0, 'markdownBlockQuote', { bold = true }) -- unlink from Comment

    if vim.g.colors_name == 'carbonfox' then
      hi(0, 'Normal', { bg = '#000000', fg = '#cdd6f4' })
      hi(0, 'NormalNC', { bg = '#0c0c0c', fg = '#cdd6f4' })
      hi(0, 'ColorColumn', { bg = '#313244' })
      hi(0, 'Function', { fg = '#a9d4ff', italic = false })
      hi(0, 'MiniIconsYellow', { fg = '#fec43f' })
      hi(0, 'MiniIconsOrange', { fg = '#fe8019' })
      hi(0, 'MiniIconsRed', { fg = '#e64343' })
      hi(0, '@markup.heading.1.markdown', { fg = '#8cb6ff', bold = true })
      hi(0, '@markup.heading.2.markdown', { fg = '#6ae4b9', bold = true })
      hi(0, '@markup.heading.3.markdown', { fg = '#79ff61', bold = true })
      hi(0, '@markup.heading.4.markdown', { fg = '#fec43f', bold = true })
      hi(0, '@markup.heading.5.markdown', { fg = '#e64343', bold = true })
      hi(0, '@markup.heading.6.markdown', { fg = '#b6a0ff', bold = true })
      hi(0, '@punctuation.special.markdown', { link = '@markup.heading.1.markdown' })
      hi(0, '@markup.quote.markdown', { link = '@punctuation.special.markdown' })
    end
  end
})
