local M = {}

local status_cmp_ok, cmp_nvim_lsp = pcall(require, "cmp_nvim_lsp")
if not status_cmp_ok then
	return
end

M.capabilities = vim.lsp.protocol.make_client_capabilities()
M.capabilities.textDocument.completion.completionItem.snippetSupport = true
M.capabilities = cmp_nvim_lsp.default_capabilities(M.capabilities)
-- folding to support UFO fold
M.capabilities.textDocument.foldingRange = {
	dynamicRegistration = false,
	lineFoldingOnly = true,
}

M.setup = function()
	local config = {
		virtual_text = false, -- disable virtual text
		signs = {
			text = {
				[vim.diagnostic.severity.ERROR] = "",
				[vim.diagnostic.severity.WARN] = "",
                [vim.diagnostic.severity.INFO] = "",
                -- [vim.diagnostic.severity.HINT] = "",
                [vim.diagnostic.severity.HINT] = "",
			},
			numhl = {
				[vim.diagnostic.severity.ERROR] = "NumError",
				[vim.diagnostic.severity.WARN] = "NumWarn",
				[vim.diagnostic.severity.INFO] = "NumInfo",
				[vim.diagnostic.severity.HINT] = "NumHint",
			},
			linehl = {
				[vim.diagnostic.severity.ERROR] = "LineError",
			},
		},
		update_in_insert = true,
		underline = true,
		severity_sort = true,
		float = {
			focusable = true,
			style = "minimal",
			border = "bold",
			source = "always",
			header = "",
			prefix = "",
		},
	}

	vim.diagnostic.config(config)
	-- automatically open diagnostic float under cursor
	-- vim.api.nvim_create_autocmd(
	--     {"CursorHold"},
	--     {
	--         callback = function(env)
	--             vim.diagnostic.open_float(config)
	--         end
	--     }
	-- )

	-- vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, {
	--     border = "rounded",
	-- })

	-- vim.lsp.handlers["textDocument/signatureHelp"] = vim.lsp.with(vim.lsp.handlers.signature_help, {
	--     border = "rounded",
	-- })
end

local function lsp_keymaps(bufnr)
	local opts = { noremap = true, silent = true, buffer = bufnr }
	local keymaps = {
		{
			mode = "n",
			lhs = "gD",
			rhs = function()
				vim.lsp.buf.declaration()
			end,
			opts = opts,
		},
		{
			mode = "n",
			lhs = "gd",
			rhs = function()
				vim.lsp.buf.definition()
			end,
			opts = opts,
		},
		{
			mode = "n",
			lhs = "gI",
			rhs = function()
				vim.lsp.buf.implementation()
			end,
			opts = opts,
		},
		{
			mode = "n",
			lhs = "gr",
			rhs = function()
				vim.lsp.buf.references()
			end,
			opts = opts,
		},
		{
			mode = "n",
			lhs = "gl",
			rhs = function()
				vim.diagnostic.open_float()
			end,
			opts = opts,
		},
		{
			mode = "n",
			lhs = "<leader>lf",
			rhs = function()
				vim.dlsp.buf.format({ async = true })
			end,
			opts = opts,
		},
		{
			mode = "n",
			lhs = "<leader>li",
			rhs = "<cmd>LspInfo<cr>",
			opts = opts,
		},
		{
			mode = "n",
			lhs = "<leaderlI",
			rhs = "<cmd>LspInstallInfo<cr>",
			opts = opts,
		},
		{
			mode = "n",
			lhs = "<leader>la",
			rhs = function()
				vim.lsp.buf.code_action()
			end,
			opts = opts,
		},
		{
			mode = "n",
			lhs = "<leader>lj",
			rhs = function()
				vim.diagnostic.jump({ count = 1, float = true, wrap = true })
			end,
			opts = opts,
		},
		{
			mode = "n",
			lhs = "<leader>lk",
			rhs = function()
				vim.diagnostic.jump({ count = -1, float = true, wrap = true })
			end,
			opts = opts,
		},
		{
			mode = "n",
			lhs = "<leader>lr",
			rhs = function()
				vim.lsp.buf.rename()
			end,
			opts = opts,
		},
		{
			mode = "n",
			lhs = "<leader>ls",
			rhs = function()
				vim.lsp.buf.signature_help()
			end,
			opts = opts,
		},
		{
			mode = "n",
			lhs = "<leader>lq",
			rhs = function()
				vim.diagnostic.setloclist()
			end,
			opts = opts,
		},
	}
	for _, k in pairs(keymaps) do
		vim.keymap.set(k.mode, k.lhs, k.rhs, k.opts)
	end
end

M.on_attach = function(client, bufnr)
	if client.name == "tsserver" then
		client.server_capabilities.documentFormattingProvider = false
	end

	if client.name == "sumneko_lua" then
		client.server_capabilities.documentFormattingProvider = false
	end

	lsp_keymaps(bufnr)
end

return M
