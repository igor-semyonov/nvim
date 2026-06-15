local tts_cmd = "tts"
if vim.uv.os_uname().sysname == "Darwin" then
    tts_cmd = "say -v Samantha -r 750"
end

local send_to_tts = function(text)
	local tmp_file = vim.fn.tempname()
	vim.fn.writefile({ text }, tmp_file)

	local job_id = vim.fn.jobstart({ "sh", "-c", tts_cmd .. ' < "$1"; rm -f "$1"', "_", tmp_file })

	if job_id <= 0 then
		vim.notify("Failed to start background job", vim.log.levels.ERROR)
	end
end
vim.keymap.set("n", "<leader>t", function()
	local line = vim.api.nvim_get_current_line()
	send_to_tts(line)
end, { desc = "Text-to-speach Line" })
vim.keymap.set("v", "<leader>t", function()
	vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Esc>", true, false, true), "x", false)
	vim.schedule(function()
		local lines = vim.fn.getline("'<", "'>")
        vim.cmd("normal! gv")
		local selection = table.concat(lines, "\n")
		send_to_tts(selection)
	end)
end, { desc = "Text-to-speach Selection" })
