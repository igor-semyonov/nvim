local dark_grey = "#666666"
local bright_fg = "#EEEEEE"
local crosshair = "#183018"
local monk = "#80FF80"
local monk_inverse = "#800080"

require("nightfox").setup({
    options = {
        transparent = true,
        styles = {             -- Style to be applied to different syntax groups
            comments = "NONE", -- Value is any valid attr-list value `:help attr-list`
            conditionals = "NONE",
            constants = "NONE",
            functions = "NONE",
            keywords = "bold",
            numbers = "bold",
            operators = "NONE",
            strings = "NONE",
            types = "NONE",
            variables = "NONE",
        },
        inverse = {
            match_paren = true,
            search = false,
            visual = true,
        },
    },
    palettes = {
        all = {},
    },
    groups = {
        all = {
            LineNr = { fg = bright_fg, bg = "black", },
            SignColumn = { fg = bright_fg, bg = "black", },
            -- LineNr = { fg = bright_fg, bg = "#000000", style = "bold" },
            -- LineNrAbove = { fg = bright_fg, bg = dark_grey },
            -- LineNrBelow = { fg = bright_fg, bg = dark_grey },
            -- FoldColumn = { fg = bright_fg, bg = "#8000FF" },
            Cursor = { bg = "#FF30FF" },
            CursorLine = { bg = crosshair },
            CursorColumn = { bg = crosshair },
            CursorLineNr = { bg = monk, fg = monk_inverse },
            -- Folded = { bg = "orange" },
            Folded = { bg = "#FF4040" },
            NormalFloat = { bg = "black" },
            FloatBorder = { bg = "black", fg = monk },
            illuminatedWordText = { fg = "#80FF80" , bg="#E06040"},
        },
    },
})

vim.cmd("colorscheme terafox")

require("colorizer").setup()
