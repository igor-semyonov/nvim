local servers = {
	"cmake",
	-- "rust_analyzer", -- handled by rustaceanvim
	"hyprls",
	"clangd",
	"lua_ls",
	"ast_grep",
	"nil_ls",

	-- "pyright",
	"pylsp",
	"ruff",

	"bashls",
	-- "yamlls",
	"jsonls",
	"awk_ls",
	"docker_compose_language_service",
	"html",
	-- "ltex",
	"ltex_plus",
	"texlab",
	"matlab_ls",
	"julials",
	"vhdl_ls",
	"nixd",
	-- "hdl_checker",

    "tailwindcss",
    "cssls",
}

local settings = {
	ui = {
		border = "rounded",
		icons = {
			package_installed = "◍",
			package_pending = "◍",
			package_uninstalled = "◍",
		},
	},
	log_level = vim.log.levels.INFO,
	max_concurrent_installers = 6,
}

require("mason").setup(settings)

local opts = {
	capabilities = require("user.lsp.handlers").capabilities,
}
vim.lsp.config("*", opts)

for _, server in pairs(servers) do
	server = vim.split(server, "@")[1]

	local require_ok, server_opts = pcall(require, "user.lsp.settings." .. server)
	if require_ok then
		vim.lsp.config[server] = vim.tbl_deep_extend("keep", server_opts, opts)
	end
	vim.lsp.enable(server)
end

local on_attach = require("user.lsp.handlers").on_attach
vim.api.nvim_create_autocmd("LspAttach", {
	group = vim.api.nvim_create_augroup("MyLspKeymaps", {}),
	callback = function(args)
		local bufnr = args.buf
		local clients = vim.lsp.get_clients({ bufnr = bufnr })
		for _, client in ipairs(clients) do
			on_attach(client, bufnr)
		end
	end,
})

local require_ok, rust_specific_opts = pcall(require, "user.lsp.settings.rust_analyzer")
if require_ok then
	rust_specific_opts = vim.tbl_deep_extend("keep", rust_specific_opts, opts)
end
vim.g.rustaceanvim = {
	server = rust_specific_opts,
}
