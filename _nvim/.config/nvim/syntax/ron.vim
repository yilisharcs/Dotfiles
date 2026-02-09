" Vim syntax file
" Language:     Rusty Object Notation
" Maintainer:   yilisharcs <yilisharcs@gmail.com>
" Last Change:  2025 Nov 16

" quit when a syntax file was already loaded
if exists("b:current_syntax")
  finish
endif

" RON is not valid Rust, but has compatible syntax
runtime! syntax/rust.vim

let b:current_syntax = "ron"

" vim: ft=vim expandtab nowrap shiftwidth=2 softtabstop=2
