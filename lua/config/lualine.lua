require("lualine").setup({
    sections = {
        lualine_c = {
            function()
                local reg = vim.fn.reg_recording()
                if reg == "" then
                    return vim.fn.expand("%:t")
                end -- not recording
                return "@" .. reg
            end,
        },
        lualine_x = {
            "venv-selector", -- You can customize the look of the output, see below`.
            "encoding",
            "fileformat",
            "filetype",
        },
    },
})
