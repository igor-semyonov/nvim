local spell_file = vim.fn.stdpath("config") .. "/spell/en.utf-8.add"
local function get_words()
	local words = {}
	for word in io.open(spell_file, "r"):lines() do
		table.insert(words, word)
	end
	return words
end

local function update_dictionary()
	vim.lsp.config.ltex_plus.settings.ltex.dictionary["en-US"] = get_words()
	vim.lsp.enable("ltex_plus", false)
	vim.lsp.enable("ltex_plus", true)
end
vim.keymap.set("n", "zg", function()
	update_dictionary()
	vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("zg", true, false, true), "n", false)
end, {
	desc = "Add spell word and reload ltex_plus",
	noremap = true,
	silent = true,
})

return {
	settings = {
		ltex = {
			language = "en-US",
			dictionary = {
				["en-US"] = get_words(),
			},
		},
	},
	-- other ltex setup options (e.g., on_attach, capabilities)
}
