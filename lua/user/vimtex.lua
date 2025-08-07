-- vim.go.filetype = true
vim.g.vimtex_view_general_viewer = "okular"
vim.cmd([[
    let g:vimtex_quickfix_ignore_filters = [
    \ 'markboth',
    \ 'markright',
    \]
    let g:vimtex_quickfix_autoclose_after_keystrokes = 1
    let g:vimtex_view_general_options = "--unique file:@pdf\#src:@line@tex"
]])
