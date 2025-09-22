return {
    { "mason-org/mason.nvim", opts = {} },
    { "mason-org/mason-lspconfig.nvim", opts = {} },

    {
        "neovim/nvim-lspconfig",

        config = function()
            vim.lsp.config("lua_ls", {
                settings = {
                    Lua = {
                        diagnostics = {
                            globals = { "vim" }, -- Add 'vim' as a recognized global
                        },
                        workspace = {
                            library = vim.api.nvim_get_runtime_file("", true), -- Include Neovim runtime files
                            checkThirdParty = false, -- Avoid annoying prompts for third-party libraries
                        },
                        telemetry = {
                            enable = false, -- Disable telemetry
                        },
                    },
                },
            })
            vim.lsp.enable("lua_ls")
            vim.lsp.handlers["$/progress"] = function() end
            vim.diagnostic.config({ virtual_text = true })
        end,
    },
    {
        "mfussenegger/nvim-lint",

        config = function()
            require("lint").linters_by_ft = {
                markdown = { "markdownlint-cli2", "alex" },
                python = { "ruff" },
                html = { "htmlhint" },
            }
        end,
    },
    {
        "folke/trouble.nvim",
        opts = {}, -- for default options, refer to the configuration section for custom setup.
        cmd = "Trouble",
        keys = {
            {
                "<leader>xx",
                "<cmd>Trouble diagnostics toggle<cr>",
                desc = "Diagnostics (Trouble)",
            },
            {
                "<leader>xX",
                "<cmd>Trouble diagnostics toggle filter.buf=0<cr>",
                desc = "Buffer Diagnostics (Trouble)",
            },
            {
                "<leader>cs",
                "<cmd>Trouble symbols toggle focus=false<cr>",
                desc = "Symbols (Trouble)",
            },
            {
                "<leader>cl",
                "<cmd>Trouble lsp toggle focus=false win.position=right<cr>",
                desc = "LSP Definitions / references / ... (Trouble)",
            },
            {
                "<leader>xL",
                "<cmd>Trouble loclist toggle<cr>",
                desc = "Location List (Trouble)",
            },
            {
                "<leader>xQ",
                "<cmd>Trouble qflist toggle<cr>",
                desc = "Quickfix List (Trouble)",
            },
        },
    },
    {
        "stevearc/conform.nvim",
        opts = {
            formatters = {
                my_stylua = {
                    command = "stylua",
                    args = { "--indent-type", "Spaces", "--indent-width", "4", "-" },
                    stdin = true,
                },
            },
            formatters_by_ft = {
                ["markdown"] = { "prettier", "markdownlint-cli2", "markdown-toc" },
                ["markdown.mdx"] = { "prettier", "markdownlint-cli2", "markdown-toc" },
                ["lua"] = { "my_stylua" },
            },
        },
    },
}
