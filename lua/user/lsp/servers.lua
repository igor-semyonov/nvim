-- Servers grouped by the nix toggle that provisions their binary. A group is
-- included only when its toggle is enabled (see lua/user/nix.lua); running
-- without nix keeps everything. This avoids `vim.lsp.enable`-ing a server whose
-- executable a disabled toggle never put on PATH.
local servers = require("user.nix").collect({
	languages = {
		cmake = { "cmake" },
		hypr = { "hyprls" },
		clang = { "clangd" },
		lua = { "lua_ls" },
		nix = { "nixd", "nil_ls" },
		python = {
			"ruff",
			"pyrefly",
			-- "pyright",
			-- "pylsp",
		},
		shell = { "bashls" },
		json = { "jsonls" },
		docker = { "docker_compose_language_service" },
		html = {
			"html",
			"tailwindcss", -- shared: kept if html OR css OR tailwind is on
		},
		latex = {
			"ltex_plus", -- shared: also serves markdown/plaintext
			"texlab",
			-- "ltex",
		},
		matlab = { "matlab_ls" },
		css = {
			"cssls",
			"tailwindcss", -- shared (see html)
		},
		tailwind = { "tailwindcss" },
		-- yaml = { "yamlls" },
	},
	tools = {
		extras = { "ast_grep" },
	},
	always = {
		"awk_ls",
		"julials", -- no nix module yet
		"vhdl_ls",
		-- rust_analyzer handled by rustaceanvim (see bottom of file)
		-- "hdl_checker",
	},
})

vim.lsp.config("*", {
	before_init = function(_, config)
		require("codesettings").with_local_settings(config.name, config)
	end,
})

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
