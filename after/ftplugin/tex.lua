local bufnr = vim.api.nvim_get_current_buf()

vim.wo.spell = true
vim.bo.spelllang="en_us"

-- vim.keymap.set("n", "<F5>", "<esc>:w <bar> !xelatex %<CR>", { silent = true,  buffer = bufnr })
-- vim.keymap.set("n", "<F6>", "<esc>:w <bar> !okular %:r.pdf &<CR>", { silent = true,  buffer = bufnr })
-- vim.keymap.set("n", "<F4>", "<esc>:w <bar> !bibtex %:r<CR>", { silent = true,  buffer = bufnr })
