local bufnr = vim.api.nvim_get_current_buf()

vim.keymap.set("n", "<F8>", "<esc>:%!python3 -m json.tool<CR>", { silent = true, buffer = bufnr })
