" Vim syntax file
" Language:     Lemonscript
" Maintainer:   yilisharcs <yilisharcs@gmail.com>
" Last Change:  2025 Sep 04

" quit when a syntax file was already loaded
if exists("b:current_syntax")
  finish
endif

" let s:cpo_save = &cpo
" set cpo&vim

" Lemonscript is described in the handbook as similar to C/C++ in syntax
runtime! syntax/c.vim

let b:current_syntax = "lemon"

" let &cpo = s:cpo_save
" unlet s:cpo_save

" vim: ft=vim expandtab nowrap shiftwidth=2 softtabstop=2
