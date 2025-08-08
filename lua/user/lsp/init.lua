local status_ok, _ = pcall(require, "lspconfig")
if not status_ok then
    return
end

require "user.lsp.servers"
require("user.lsp.handlers").setup()
require("user.lsp.signature")
require("user.lsp.formatter")
require("lazydev")

vim.api.nvim_create_autocmd({ 'BufEnter', 'BufWinEnter' }, {
    pattern = { "*.nix" },
    callback = function(ev)
        require("otter").activate(nil, true, true, nil)
    end
})
