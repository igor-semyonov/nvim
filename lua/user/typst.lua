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

-- Background `typst watch` jobs, keyed by main file.
local jobs = {}

local function notify(msg, level)
	vim.notify(msg, level or vim.log.levels.INFO, { title = "typst" })
end

-- Parse `typst watch --diagnostic-format short` output into the quickfix list.
local function watch_handler(dir)
	local partial, items, failed = "", {}, false
	local function set_qf()
		vim.fn.setqflist({}, "r", { title = "typst watch", items = items })
	end
	local function on_line(line)
		if line:match("compiling %.%.%.") then
			items = {}
		elseif line:match("compiled successfully") then
			set_qf()
			if failed then
				notify("compiled successfully")
			end
			failed = false
		elseif line:match("compiled with errors") then
			failed = true
			notify("compiled with errors, see :copen", vim.log.levels.ERROR)
		else
			local f, l, c, sev, msg = line:match("^(.-):(%d+):(%d+): (%a+): (.*)$")
			if f then
				table.insert(items, {
					filename = vim.startswith(f, "/") and f or vim.fs.joinpath(dir, f),
					lnum = tonumber(l),
					col = tonumber(c),
					type = sev == "error" and "E" or "W",
					text = msg,
				})
				set_qf()
			end
		end
	end
	return function(_, data)
		if not data then
			return
		end
		local lines = vim.split(partial .. data, "\n", { plain = true })
		partial = table.remove(lines)
		vim.schedule(function()
			vim.tbl_map(on_line, lines)
		end)
	end
end

-- Start/stop a background `typst watch` that rebuilds the PDF next to main.typ.
function M.watch_toggle(path)
	local main = M.main_file(path)
	if jobs[main] then
		jobs[main]:kill("sigterm")
		jobs[main] = nil
		notify("watch stopped")
		return
	end
	local dir = vim.fs.dirname(main)
	local root = vim.fs.root(main, ".git") or dir
	local handler = watch_handler(dir)
	local ok, job = pcall(vim.system, {
		"typst",
		"watch",
		"--root",
		root,
		"--diagnostic-format",
		"short",
		main,
	}, { cwd = dir, text = true, stdout = handler, stderr = handler }, function(res)
		vim.schedule(function()
			if jobs[main] and res.signal ~= 15 then
				notify("watch exited (" .. res.code .. ")", vim.log.levels.WARN)
			end
			jobs[main] = nil
		end)
	end)
	if not ok then
		notify(tostring(job), vim.log.levels.ERROR)
		return
	end
	jobs[main] = job
	notify("watching " .. vim.fs.basename(main))
end

-- Open the PDF built from the main file.
function M.view(path)
	local pdf = M.main_file(path):gsub("%.typ$", ".pdf")
	if not vim.uv.fs_stat(pdf) then
		return notify(pdf .. " not built yet", vim.log.levels.WARN)
	end
	vim.ui.open(pdf)
end

vim.api.nvim_create_autocmd("VimLeavePre", {
	group = vim.api.nvim_create_augroup("UserTypstWatch", {}),
	callback = function()
		for _, job in pairs(jobs) do
			job:kill("sigterm")
		end
	end,
})

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
