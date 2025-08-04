local status_ok, _ = pcall(require, "lspconfig")
if not status_ok then
  return
end

require("neodev").setup({
  -- library = {
  --       plugins = { "nvim-dap-ui" }, 
  --       types = true 
  --   },
})

require "user.lsp.mason"
require("user.lsp.handlers").setup()
