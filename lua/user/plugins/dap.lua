return {
	{
		"rcarriga/nvim-dap-ui",
        -- enabled = false,
		dependencies = {
			"mfussenegger/nvim-dap",
			"nvim-neotest/nvim-nio",
			"mfussenegger/nvim-dap-python",
			"ldelossa/nvim-dap-projects",
		},
		config = function()
			-- this is for dap setup

			local dap, dapui = require("dap"), require("dapui")

			local opts = { noremap = true, silent = true }
			local keymap = vim.keymap.set
			keymap("n", "<leader>dd", function()
				dap.toggle_breakpoint()
			end, opts)
			keymap("n", "<leader>dx", function()
				-- vim.cmd([[:!cargo build]])
				dap.continue()
			end, opts)
			keymap("n", "<leader>di", function()
				dap.step_into()
			end, opts)
			keymap("n", "<leader>do", function()
				dap.step_over()
			end, opts)
			keymap("n", "<leader>du", function()
				dap.step_out()
			end, opts)
			keymap("n", "<leader>de", function()
				dap.step_back()
			end, opts)
			keymap("n", "<leader>dr", function()
				dap.repl.toggle()
			end, opts)
			keymap("n", "<leader>dt", function()
				dap.terminate()
			end, opts)

			require("dapui").setup({
				controls = {
					element = "repl",
					enabled = true,
					icons = {
						disconnect = "",
						pause = "",
						play = "",
						run_last = "",
						step_back = "",
						step_into = "",
						step_out = "",
						step_over = "",
						terminate = "",
					},
				},
				element_mappings = {},
				expand_lines = true,
				floating = {
					border = "single",
					mappings = {
						close = { "q", "<Esc>" },
					},
				},
				force_buffers = true,
				icons = {
					collapsed = "",
					current_frame = "",
					expanded = "",
				},
				layouts = {
					{
						elements = {
							{
								id = "scopes",
								size = 0.25,
							},
							{
								id = "breakpoints",
								size = 0.25,
							},
							{
								id = "stacks",
								size = 0.25,
							},
							{
								id = "watches",
								size = 0.25,
							},
						},
						position = "left",
						size = 40,
					},
					{
						elements = {
							{
								id = "repl",
								size = 0.5,
							},
							{
								id = "console",
								size = 0.5,
							},
						},
						position = "bottom",
						size = 10,
					},
				},
				mappings = {
					edit = "e",
					expand = { "<CR>", "<2-LeftMouse>" },
					open = "o",
					remove = "d",
					repl = "r",
					toggle = "t",
				},
				render = {
					indent = 1,
					max_value_lines = 100,
				},
			})

			dap.listeners.after.event_initialized["dapui_config"] = function()
				dapui.open()
			end
			dap.listeners.before.event_terminated["dapui_config"] = function()
				dapui.close()
			end
			dap.listeners.before.event_exited["dapui_config"] = function()
				dapui.close()
			end

			require("nvim-dap-projects").search_project_config()

			require("dap-python").setup("~/venv/debugpy/bin/python")

            vim.fn.sign_define("DapBreakpoint", { text = "", texthl = "red", linehl = "", numhl = "" })
			-- vim.highlight.create("DapBreakpoint", { ctermbg = 0, guifg = "#993939", guibg = "#31353f" }, false)
			-- vim.highlight.create("DapLogPoint", { ctermbg = 0, guifg = "#61afef", guibg = "#31353f" }, false)
			-- vim.highlight.create("DapStopped", { ctermbg = 0, guifg = "#98c379", guibg = "#31353f" }, false)

			-- vim.fn.sign_define(
			--     "DapBreakpoint",
			--     { text = "", texthl = "DapBreakpoint", linehl = "DapBreakpoint", numhl = "DapBreakpoint" }
			-- )
			-- vim.fn.sign_define(
			--     "DapBreakpointCondition",
			--     { text = "ﳁ", texthl = "DapBreakpoint", linehl = "DapBreakpoint", numhl = "DapBreakpoint" }
			-- )
			-- vim.fn.sign_define(
			--     "DapBreakpointRejected",
			--     { text = "", texthl = "DapBreakpoint", linehl = "DapBreakpoint", numhl = "DapBreakpoint" }
			-- )
			-- vim.fn.sign_define(
			--     "DapLogPoint",
			--     { text = "", texthl = "DapLogPoint", linehl = "DapLogPoint", numhl = "DapLogPoint" }
			-- )
			-- vim.fn.sign_define(
			--     "DapStopped",
			--     { text = "", texthl = "DapStopped", linehl = "DapStopped", numhl = "DapStopped" }
			-- )
		end,
	},
}
