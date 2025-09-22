-- Numbers

vim.opt.number = true
vim.opt.relativenumber = true

-- Keep sign column

vim.opt.signcolumn = "yes"

-- Cursor

vim.opt.cursorline = true
vim.opt.updatetime = 50

-- Show whitespace characters

vim.opt.list = true
vim.opt.listchars = { tab = "⇥ ", trail = "·", nbsp = "␣" }

-- Preview substitutions

vim.opt.inccommand = "split"

-- Editor wrap and spacing

vim.opt.wrap = false
vim.opt.scrolloff = 8

-- Tabstops

vim.opt.expandtab = true
vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.shiftwidth = 4

-- Save undo

vim.opt.undofile = true

-- Floating window border

vim.opt.winborder = "rounded"

-- Markdown

vim.g.markdown_enable_math = 1
vim.g.markdown_syntax_conceal = 0
