local builtin = require("telescope.builtin")
local harpoon = require("harpoon")
local ls = require("luasnip")

harpoon:setup()

-- File finding

--- vanilla vim
vim.keymap.set("n", "<leader>ft", vim.cmd.Ex, { desc = "Show Netwr" })

--- telescope
vim.keymap.set("n", "<leader>ff", builtin.find_files, { desc = "Telescope find files" })
vim.keymap.set("n", "<leader>fg", builtin.live_grep, { desc = "Telescope live grep" })
vim.keymap.set("n", "<leader>fc", function()
    require("telescope.builtin").find_files({
        prompt_title = "  Find Config",
        cwd = vim.fn.stdpath("config"), -- ~/.config/nvim by default
        hidden = true, -- include dotfiles
    })
end, { desc = "Find in Config" })

-- Buffer management

--- vanilla vim
vim.keymap.set("n", "<leader>bp", vim.cmd.bprevious, { desc = "Go to previous buffer" })
vim.keymap.set("n", "<leader>bn", vim.cmd.bnext, { desc = "Go to next buffer" })

vim.keymap.set("n", "<C-d>", "<C-d>zz", { desc = "Move down half a page" })
vim.keymap.set("n", "<C-u>", "<C-u>zz", { desc = "Move up half a page" })

--- harpoon
vim.keymap.set("n", "<leader>ba", function()
    harpoon:list():add()
end, { desc = "Harpoon file" })

vim.keymap.set("n", "<leader>bh", function()
    harpoon:list():select(1)
end, { desc = "Reel into first file" })
vim.keymap.set("n", "<leader>bj", function()
    harpoon:list():select(2)
end, { desc = "Reel into second file" })
vim.keymap.set("n", "<leader>bk", function()
    harpoon:list():select(3)
end, { desc = "Reel into third file" })
vim.keymap.set("n", "<leader>bl", function()
    harpoon:list():select(4)
end, { desc = "Reel into fourth file" })

-- Window management

--- vanilla vim
vim.keymap.set("n", "<leader>w-", vim.cmd.sp, { desc = "Split window horizontally" })
vim.keymap.set("n", "<leader>w|", vim.cmd.vs, { desc = "Split window vertically" })

-- Clipboard handling

---vanilla vim
vim.keymap.set("v", "<leader>y", '"+y', { desc = "Yank to system clipboard" })
vim.keymap.set({ "n", "v" }, "<leader>p", '"+p', { desc = "Paste from system clipoard after cursor position" })
vim.keymap.set({ "n", "v" }, "<leader>P", '"+P', { desc = "Paste from system clipoard before cursor position" })

vim.keymap.set("n", "yif", function()
    local view = vim.fn.winsaveview()
    vim.cmd('normal! gg"0VGy')
    vim.fn.winrestview(view)
end, { desc = "Yank entire file" })
vim.keymap.set("n", "<leader>Y", function()
    local view = vim.fn.winsaveview()
    vim.cmd('normal! gg"+VGy')
    vim.fn.winrestview(view)
end, { desc = "Yank entire file to system clipboard" })

-- Line handling

---vanilla vim
vim.keymap.set("n", "<M-j>", ":m +1<CR>", { desc = "Move line down" })
vim.keymap.set("n", "<M-k>", ":m -2<CR>", { desc = "Move line up" })
vim.keymap.set({ "v", "x" }, "<M-j>", ":m '>+1<CR>gv=gv", { desc = "Move line down" })
vim.keymap.set({ "v", "x" }, "<M-k>", ":m '<-2<CR>gv=gv", { desc = "Move line up" })

vim.keymap.set("n", "J", "mzJ`z", { desc = "Append next line" })

-- Search and replace

--- vanilla vim
vim.keymap.set("n", "n", "nzzzv", { desc = "Next search match" })
vim.keymap.set("n", "N", "nzzzv", { desc = "Previous search match" })

vim.keymap.set(
    "n",
    "<leader>s",
    ":%s/\\<<C-r><C-w>\\>/<C-r><C-w>/gI<Left><Left><Left>",
    { desc = "Change current word" }
)

-- Code

--- vanilla vim
vim.keymap.set("n", "<leader>cf", function()
    require("conform").format()
end, { desc = "Format code" })
vim.keymap.set("n", "<leader>ch", function()
    vim.lsp.buf.hover()
end, { desc = "Show hover info" })
vim.keymap.set("n", "<leader>ca", function()
    vim.lsp.buf.code_action()
end, { desc = "Code actions" })
vim.keymap.set("n", "<leader>cp", vim.cmd.MarkdownPreviewToggle, { desc = "Preview Markdown" })

vim.keymap.set("n", "gd", function()
    vim.lsp.buf.definition()
end, { desc = "Go to definition" })

vim.keymap.set("n", "<leader>dv", function()
    vim.diagnostic.enable(not vim.diagnostic.is_enabled())
end, { silent = true, noremap = true })

-- Lazy
--- vanilla vim
vim.keymap.set("n", "<leader>l", vim.cmd.Lazy, { desc = "Show Lazy" })

-- Completions and snippets
--- luasnip
vim.keymap.set({ "i", "s" }, "<Tab>", function()
    if ls.expand_or_jumpable() then
        return "<Plug>luasnip-expand-or-jump"
    else
        return "<Tab>"
    end
end, { expr = true, silent = true })

vim.keymap.set({ "i", "s" }, "<S-Tab>", function()
    if ls.jumpable(-1) then
        return "<Plug>luasnip-jump-prev"
    else
        return "<S-Tab>"
    end
end, { expr = true, silent = true })

vim.keymap.set({ "i", "s" }, "<C-E>", function()
    if ls.choice_active() then
        ls.change_choice(1)
    end
end, { silent = true })

-- Notifications

--- vanilla vim
vim.keymap.set("n", "<leader>nl", function()
    require("noice").cmd("last")
end)

vim.keymap.set("n", "<leader>nh", function()
    require("noice").cmd("history")
end)
