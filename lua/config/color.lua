local nightfox = require("nightfox")

nightfox.setup({
    options = {
        transparent = true,
        styles = {
            comments = "italic"
        }
    },
})

vim.cmd("colorscheme nightfox")
