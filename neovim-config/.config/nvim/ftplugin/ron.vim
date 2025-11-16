" Vim filetype plugin file
" Language:     Rusty Object Notation
" Maintainer:   yilisharcs <yilisharcs@gmail.com>
" Last Change:  2025 Nov 16

if exists("b:did_ftplugin")
  finish
endif

" RON is not valid Rust, but has compatible syntax
runtime! ftplugin/rust.vim

" vim: nowrap sw=2 sts=2 ts=8
