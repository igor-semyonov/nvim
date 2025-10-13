local words = {}
for word in io.open(vim.fn.stdpath("config") .. "/spell/en.utf-8.add", "r"):lines() do
	table.insert(words, word)
end
vim.print(words)

local opts = {
    settings = {
        ltex = {
            dictionary = {
                ["en-US"] = words,
            },
        },
    }
}

return opts
