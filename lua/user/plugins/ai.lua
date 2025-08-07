local ollama_mapping_prefix = "<leader>i"
local gen_mapping_prefix = "<leader>e"

return {
	{
		"nomnivore/ollama.nvim",
        enabled = false,
		dependencies = {
			"nvim-lua/plenary.nvim",
		},
		-- All the user commands added by the plugin
		cmd = { "Ollama", "OllamaModel", "OllamaServe", "OllamaServeStop" },
		keys = {
			-- Sample keybind for prompt menu. Note that the <c-u> is important for selections to work properly.
			{
				ollama_mapping_prefix .. "i",
				":<c-u>lua require('ollama').prompt()<cr>",
				desc = "Ollama prompt",
				mode = { "n", "v" },
			},

			-- Sample keybind for direct prompting. Note that the <c-u> is important for selections to work properly.
			{
				ollama_mapping_prefix .. "g",
				":<c-u>lua require('ollama').prompt('Generate_Code')<cr>",
				desc = "Ollama Generate Code",
				mode = { "n", "v" },
			},
			{
				ollama_mapping_prefix .. "m",
				":OllamaModel<cr>",
				desc = "Ollama choose model",
				mode = { "n", "v" },
			},
			{
				ollama_mapping_prefix .. ".",
				":OllamaServe<cr>",
				desc = "Ollama serve",
				mode = { "n", "v" },
			},
		},

		---@type Ollama.Config
		opts = {
			model = "mistral",
			url = "http://127.0.0.1:11434",
			serve = {
				on_start = false,
				command = "ollama",
				args = { "serve" },
				stop_command = "pkill",
				stop_args = { "-SIGTERM", "ollama" },
			},
			-- View the actual default prompts in ./lua/ollama/prompts.lua
			prompts = {
				-- Sample_prompt = {
				--     prompt = "This is a sample prompt that receives $input and $sel(ection), among others.",
				--     input_label = "arst> ",
				--     model = "mistral",
				--     action = "display",
				-- },
			},
		},
	},
	{
		"David-Kunz/gen.nvim",
        -- enabled = false,
		opts = {
			model = "mistral", -- The default model to use.
			host = "localhost", -- The host running the Ollama service.
			port = "11434", -- The port on which the Ollama service is listening.
			display_mode = "float", -- The display mode. Can be "float" or "split".
			show_prompt = true, -- Shows the Prompt submitted to Ollama.
			show_model = true, -- Displays which model you are using at the beginning of your chat session.
			no_auto_close = false, -- Never closes the window automatically.
			init = function(options)
				pcall(io.popen, "ollama serve > /dev/null 2>&1 &")
			end,
			-- Function to initialize Ollama
			command = function(options)
				return "curl --silent --no-buffer -X POST http://"
					.. options.host
					.. ":"
					.. options.port
					.. "/api/generate -d $body"
			end,
			-- The command for the Ollama service. You can use placeholders $prompt, $model and $body (shellescaped).
			-- This can also be a command string.
			-- The executed command must return a JSON object with { response, context }
			-- (context property is optional).
			-- list_models = '<omitted lua function>', -- Retrieves a list of model names
			debug = false, -- Prints errors and the command which is run.
		},
		keys = {
			{
				gen_mapping_prefix .. "e",
				":Gen<CR>",
				mode = { "n", "v" },
			},
			{
				gen_mapping_prefix .. "c",
				":Gen Chat<CR>",
				mode = { "n", "v" },
			},
			{
				gen_mapping_prefix .. "a",
				":Gen Ask<CR>",
				mode = { "n", "v" },
			},
			{
				gen_mapping_prefix .. "g",
				":Gen Generate<CR>",
				mode = { "n", "v" },
			},
			{
				gen_mapping_prefix .. "m",
				function()
					require("gen").select_model()
				end,
				mode = { "n", "v" },
			},
		},
	},
	{
		"danymat/neogen",
        -- enabled = false,
		config = true,
		-- Uncomment next line if you want to follow only stable versions
		-- version = "*"
		keys = {
			{
				"<leader>g",
				function()
					require("neogen").generate()
				end,
				mode = "n",
				desc = "Generate annotation",
			},
		},
		opts = {
			snippet_engine = "luasnip",
		},
	},
}
