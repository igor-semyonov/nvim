local bufnr = vim.api.nvim_get_current_buf()

vim.keymap.set("n", "<F5>", "<esc>:w<bar>!julia %<cr>", { silent = true, buffer = bufnr })
