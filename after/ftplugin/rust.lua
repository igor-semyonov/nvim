local opts = {
    on_attach = require("user.lsp.handlers").on_attach,
    capabilities = require("user.lsp.handlers").capabilities,
}
local require_ok, conf_opts = pcall(require, "user.lsp.settings.rust_analyzer")
if require_ok then
    opts = vim.tbl_deep_extend("force", conf_opts, opts)
end
vim.g.rustaceanvim = {
    server = opts,
}

local bufnr = vim.api.nvim_get_current_buf()
local key_prefix = "<leader>u"

vim.keymap.set("n", "<F5>", "<esc>:w<bar>!cargo run<cr>", { silent = true, buffer = bufnr })
vim.keymap.set("n", "<F3>", "<esc>:w<bar>!cargo run --release<cr>", { silent = true, buffer = bufnr })
vim.keymap.set("n", "<F4>", "<esc>:w<bar>!maturin develop<cr>", { silent = true, buffer = bufnr })
vim.keymap.set("n", "<F6>", "<esc>:w<bar>!maturin develop --release<cr>", { silent = true, buffer = bufnr })
vim.keymap.set("n", "<F7>", "<esc>:w<bar>!cargo clippy<cr>", { silent = true, buffer = bufnr })
vim.keymap.set("n", "<F8>", "<esc>:w<bar>!cargo test<cr>", { silent = true, buffer = bufnr })
vim.keymap.set("n", "<F9>", "<esc>:w<bar>!cargo doc --no-deps --open<cr>", { silent = true, buffer = bufnr })

vim.keymap.set("n", key_prefix .. "a", function()
    vim.cmd.RustLsp("codeAction")
end, { silent = true, buffer = bufnr })
vim.keymap.set("n", key_prefix .. "m", function()
    vim.cmd.RustLsp("expandMacro")
end, { silent = true, buffer = bufnr })
vim.keymap.set("n", "<CA-j>", function()
    vim.cmd.RustLsp("moveItem", "down")
end, { silent = true, buffer = bufnr })
vim.keymap.set("n", "<CA-k>", function()
    vim.cmd.RustLsp("moveItem", "up")
end, { silent = true, buffer = bufnr })
vim.keymap.set("n", key_prefix .. "h", function()
    vim.cmd.RustLsp("hover", "actions")
    vim.cmd.RustLsp("hover", "actions")
end, { silent = true, buffer = bufnr })
vim.keymap.set("n", key_prefix .. "e", function()
    vim.cmd.RustLsp("explainError")
end, { silent = true, buffer = bufnr })
vim.keymap.set("n", key_prefix .. "d", function()
    vim.cmd.RustLsp("renderDiagnostic")
end, { silent = true, buffer = bufnr })
vim.keymap.set("n", key_prefix .. "c", function()
    vim.cmd.RustLsp("openCargo")
end, { silent = true, buffer = bufnr })
