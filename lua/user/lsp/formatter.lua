local nix = require("user.nix")

-- Formatters keyed by filetype, each gated on the nix toggle that provisions
-- its binary. Entries with a `nil` gate come from the always-on core set in
-- neovim.nix (yamlfmt, xmlformat, taplo) and are never dropped. When a gated
-- toggle is off (under nix) the filetype is omitted so conform doesn't invoke a
-- formatter whose executable was never put on PATH. Running without nix keeps
-- everything.
local formatters_by_ft = {}
for _, entry in ipairs({
	{ "lua", { "stylua" }, { "languages", "lua" } },
	{ "yaml", { "yamlfmt" }, nil }, -- core
	{ "c", { "clang-format" }, { "languages", "clang" } },
	{ "xml", { "xmlformat" }, nil }, -- core
	{ "sh", { "shfmt" }, { "languages", "shell" } },
	{ "python", { "ruff_organize_imports", "ruff_format" }, { "languages", "python" } },
	{ "cmake", { "gersemi" }, { "languages", "cmake" } },
	{ "rust", { "rustfmt" }, { "languages", "rust" } },
	{ "toml", { "taplo" }, nil }, -- core
	{ "tex", { "latexindent" }, { "languages", "latex" } },
	{ "nix", { "alejandra" }, { "languages", "nix" } },
	{ "css", { "prettier" }, { "languages", "css" } },
	--             function()
	--                 if vim.fn.executable("leptosfmt") == 0 then
	--                     return require("formatter.filetypes.rust").rustfmt()
	--                 end
	--                 return {
	--                     exe = "leptosfmt",
	--                     args = { "--stdin", "--rustfmt", "--tab-spaces 4", "--max-width 42" },
	--                     stdin = true,
	--                 }
	--             end,
}) do
	local ft, tools, gate = entry[1], entry[2], entry[3]
	if gate == nil or nix.enabled(gate[1], gate[2]) then
		formatters_by_ft[ft] = tools
	end
end

require("conform").setup({
	formatters_by_ft = formatters_by_ft,
	-- Set up format-on-save
	-- format_on_save = { timeout_ms = 500, lsp_fallback = true },
	-- Customize formatters
	formatters = {
		shfmt = {
			prepend_args = { "-i", "4" },
		},
	},
})

vim.keymap.set("n", "<leader>f", function()
	require("conform").format({
		async = true,
		lsp_fallback = true,
		timeout_ms = 1500,
		quiet = true,
	}, function(err, _)
		if err then
			local msg = vim.trim(err)
			msg = msg:gsub("[\n\r]", " ")
			msg = msg:sub(1, vim.opt.columns:get() - 14) .. "…"
			vim.notify(msg, vim.log.levels.ERROR)
		else
		end
	end)
end, {
	desc = "Format buffer",
})

vim.o.formatexpr = "v:lua.require'conform'.formatexpr()"
