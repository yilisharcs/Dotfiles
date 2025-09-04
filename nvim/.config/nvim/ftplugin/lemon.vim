" Vim filetype plugin file
" Language:     Lemonscript
" Maintainer:   yilisharcs <yilisharcs@gmail.com>
" Last Change:  2025 Sep 04

" Only do this when not done yet for this buffer
if exists("b:did_ftplugin")
  finish
endif

" Don't load another plugin for this buffer
let b:did_ftplugin = 1

let s:cpo_save = &cpo
set cpo&vim

setlocal commentstring=//\ %s

setlocal suffixesadd+=.lemon

let &cpo = s:cpo_save
unlet s:cpo_save

" vim: ft=vim expandtab nowrap shiftwidth=2 softtabstop=2
