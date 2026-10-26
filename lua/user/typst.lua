local M = {}

-- Main file for a typst buffer: nearest `main.typ` walking up to the git root,
-- so editing `lib/*.typ` previews/compiles the whole document.
function M.main_file(path)
	path = vim.fn.fnamemodify(path, ":p")
	local root = vim.fs.root(path, ".git")
	local found = vim.fs.find("main.typ", {
		path = vim.fs.dirname(path),
		upward = true,
		stop = root and vim.fs.dirname(root) or nil,
	})
	return found[1] or path
end

if require("user.nix").enabled("languages", "typst") then
	local ok, preview = pcall(require, "typst-preview")
	if ok then
		preview.setup({
			follow_cursor = true,
			get_main_file = M.main_file,
		})
	end
end

return M
