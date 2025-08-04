local bufnr = vim.api.nvim_get_current_buf()

vim.keymap.set("n", "<F5>", "<esc>:w<bar>!python %<cr>", { silent = true, buffer = bufnr })
-- auto reload buffer on change
-- vim.o.autoread = true
-- vim.api.nvim_create_autocmd({ "BufEnter", "CursorHold", "CursorHoldI", "FocusGained" , "BufWritePost"}, {
--   command = "if mode() != 'c' | checktime | endif",
--   pattern = { "*" },
-- })

-- local r,c = unpack(vim.api.nvim_win_get_cursor(0))
-- vim.cmd("e")
-- vim.api.nvim_win_set_cursor(0, {r, c})
-- print(r, c)
