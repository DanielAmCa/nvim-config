-- AUTOCOMMANDS --

-- Highlight on yank

vim.api.nvim_create_autocmd("TextYankPost", {
    group = vim.api.nvim_create_augroup("highlight_yank", { clear = true }),
    desc = "Hightlight selection on yank",
    pattern = "*",
    callback = function()
        vim.highlight.on_yank({ higroup = "IncSearch", timeout = 75 })
    end,
})

-- Autoformat on save

vim.api.nvim_create_autocmd("BufWritePre", {
    pattern = "*",
    callback = function(args)
        require("conform").format({ bufnr = args.buf })
    end,
})

-- Autolint on save

vim.api.nvim_create_autocmd({ "BufWritePost", "BufReadPost" }, {
    callback = function()
        require("lint").try_lint()
    end,
})

-- Attach treesitter to md files

vim.api.nvim_create_autocmd("FileType", {
    pattern = { "markdown", "markdown_inline" },
    callback = function(args)
        vim.treesitter.start(args.buf, "markdown")
    end,
})

-- Remember position in file

vim.api.nvim_create_autocmd("BufReadPost", {
    callback = function()
        local mark = vim.api.nvim_buf_get_mark(0, '"')
        local lcount = vim.api.nvim_buf_line_count(0)
        if mark[1] > 0 and mark[1] <= lcount then
            pcall(vim.api.nvim_win_set_cursor, 0, mark)
        end
    end,
})
