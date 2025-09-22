return {
    {
        "MeanderingProgrammer/render-markdown.nvim",
        dependencies = { "nvim-treesitter/nvim-treesitter", "nvim-tree/nvim-web-devicons" }, -- if you prefer nvim-web-devicons
        ---@module 'render-markdown'
        ---@type render.md.UserConfig
        opts = {
            completions = { lsp = { enabled = true } },

            latex = { enabled = false },

            heading = {
                icons = { "# ", "## ", "### ", "#### ", "##### ", "###### " },
                signs = { "󰉫", "󰉬", "󰉭", "󰉮", "󰉯", "󰉰" },
                position = "inline",
            },

            bullet = {
                icons = { "•", "▪", "▸" },
            },

            code = {
                language_pad = 1,
                width = "block",
                border = "thin",
                left_pad = 2,
                right_pad = 2,
                highlight = nil,
            },
        },
    },
    {
        "iamcco/markdown-preview.nvim",
        cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
        pin = true,
        version = false,
        ignore = true,
        build = "cd app && yarn install",
        init = function()
            vim.g.mkdp_filetypes = { "markdown" }
        end,
        ft = { "markdown" },
    },
    {
        "epwalsh/obsidian.nvim",
        version = "*", -- recommended, use latest release instead of latest commit
        lazy = true,
        ft = "markdown",
        dependencies = {
            -- Required.
            "nvim-lua/plenary.nvim",
        },
        opts = {
            workspaces = {
                {
                    name = "unidani",
                    path = "/Users/danielac/Library/Mobile Documents/iCloud~md~obsidian/Documents/Unidani",
                },
            },

            log_level = vim.log.levels.INFO,

            completion = {
                nvim_cmp = true,
                min_chars = 2,
            },

            mappings = {
                ["<cr>"] = {
                    action = function()
                        return require("obsidian").util.smart_action()
                    end,
                    opts = { buffer = true, expr = true },
                },
                ["gf"] = {
                    action = function()
                        return require("obsidian").util.gf_passthrough()
                    end,
                    opts = { noremap = false, expr = true, buffer = true },
                },
            },

            disable_frontmatter = false,

            picker = {
                name = "telescope.nvim",
            },

            open_notes_in = "current",

            callbacks = {
                -- Runs at the end of `require("obsidian").setup()`.
                ---@param client obsidian.Client
                post_setup = function(client) end,

                -- Runs anytime you enter the buffer for a note.
                ---@param client obsidian.Client
                ---@param note obsidian.Note
                enter_note = function(client, note) end,

                -- Runs anytime you leave the buffer for a note.
                ---@param client obsidian.Client
                ---@param note obsidian.Note
                leave_note = function(client, note) end,

                -- Runs right before writing the buffer for a note.
                ---@param client obsidian.Client
                ---@param note obsidian.Note
                pre_write_note = function(client, note) end,

                -- Runs anytime the workspace is set/changed.
                ---@param client obsidian.Client
                ---@param workspace obsidian.Workspace
                post_set_workspace = function(client, workspace) end,
            },

            ui = { enable = false },
        },
    },
}
