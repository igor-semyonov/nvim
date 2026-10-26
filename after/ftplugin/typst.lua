local bufnr = vim.api.nvim_get_current_buf()
local typst = require("user.typst")

vim.wo.spell = true
vim.bo.spelllang = "en_us"
vim.bo.commentstring = "// %s"

-- Pin tinymist to the document's main file so diagnostics/completion in
-- included files resolve against the full document.
vim.api.nvim_create_autocmd("LspAttach", {
	buffer = bufnr,
	callback = function(args)
		local client = vim.lsp.get_client_by_id(args.data.client_id)
		if client and client.name == "tinymist" then
			client:exec_cmd({
				title = "pin main",
				command = "tinymist.pinMain",
				arguments = { typst.main_file(vim.api.nvim_buf_get_name(bufnr)) },
			}, { bufnr = bufnr })
		end
	end,
})

local map = function(lhs, rhs, desc)
	vim.keymap.set("n", lhs, rhs, { buffer = bufnr, silent = true, desc = desc })
end
map("<localleader>p", "<cmd>TypstPreviewToggle<cr>", "Typst preview toggle")
map("<localleader>s", "<cmd>TypstPreviewSyncCursor<cr>", "Typst preview sync cursor")
map("<localleader>c", function()
	typst.watch_toggle(vim.api.nvim_buf_get_name(bufnr))
end, "Typst watch (compile on save) toggle")
map("<localleader>v", function()
	typst.view(vim.api.nvim_buf_get_name(bufnr))
end, "Typst view PDF")
