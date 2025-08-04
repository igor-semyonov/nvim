local bufnr = vim.api.nvim_get_current_buf()

vim.keymap.set("n", "<F5>", "<esc>:so<cr>", { silent = true, buffer = bufnr })
