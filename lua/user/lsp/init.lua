local status_ok, _ = pcall(require, "lspconfig")
if not status_ok then
	return
end

require("neoconf").setup()
require("user.lsp.servers")
require("user.lsp.handlers").setup()
require("user.lsp.signature")
require("user.lsp.formatter")
require("lazydev")

vim.api.nvim_create_autocmd({ "BufEnter", "BufWinEnter" }, {
	pattern = { "*.nix" },
	callback = function(ev)
		require("otter").activate(nil, true, true, nil)
	end,
})

require("lsp-endhints").setup({
	icons = {
		type = "󰜁 ",
		parameter = "󰏪 ",
		offspec = " ", -- hint kind not defined in official LSP spec
		unknown = " ", -- hint kind is nil
	},
	label = {
		truncateAtChars = 80,
		padding = 0,
		marginLeft = 2,
		sameKindSeparator = ", ",
	},
	extmark = {
		priority = 50,
	},
	autoEnableHints = true,
})
vim.keymap.set("n", "<leader>vh", function()
	vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled())
end, { desc = "Toggle inlay LSP hints", silent = true })

vim.lsp.set_log_level("WARN")
