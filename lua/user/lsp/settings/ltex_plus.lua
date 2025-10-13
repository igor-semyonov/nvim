local path_spelling = vim.fn.stdpath("config") .. "/spell/en.utf-8.add"
local custom_words = {}
for word in io.open(path_spelling, "r"):lines() do
	table.insert(custom_words, word)
end

return {
	settings = {
		ltex = {
			language = "en-US",
			dictionary = {
				["en-US"] = custom_words,
			},
		},
	},
	-- other ltex setup options (e.g., on_attach, capabilities)
}
