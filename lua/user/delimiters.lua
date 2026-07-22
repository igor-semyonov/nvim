-- Lua-native replacements for vim-surround (nvim-surround) and auto-pairs
-- (nvim-autopairs). Unlike the VimScript originals these need an explicit
-- setup() to activate. nvim-surround keeps tpope's keymaps (ys/ds/cs), so
-- muscle memory (ds(, cs{[, etc.) carries over unchanged.
local surround_ok, surround = pcall(require, "nvim-surround")
if surround_ok then
	surround.setup({})
end

local autopairs_ok, autopairs = pcall(require, "nvim-autopairs")
if autopairs_ok then
	autopairs.setup({})

	-- Insert `()` after confirming a function/method completion.
	local cmp_ap_ok, cmp_autopairs = pcall(require, "nvim-autopairs.completion.cmp")
	local cmp_ok, cmp = pcall(require, "cmp")
	if cmp_ap_ok and cmp_ok then
		cmp.event:on("confirm_done", cmp_autopairs.on_confirm_done())
	end
end
