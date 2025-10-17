return {
    {
        "williamboman/mason.nvim",
        opts = {},
    },
    {
        "williamboman/mason-lspconfig.nvim",
        opts = {
            ensure_installed = { "lua_ls", "pyright" },
        },
    },

    {
        "neovim/nvim-lspconfig",
        config = function()
            require("mason").setup()
            require("mason-lspconfig").setup()

            vim.diagnostic.config({ virtual_text = true })

            vim.lsp.config("lua_ls", {
                settings = {
                    Lua = {
                        diagnostics = {
                            globals = { "vim" },
                        },
                        workspace = {
                            library = vim.api.nvim_get_runtime_file("", true),
                            checkThirdParty = false,
                        },
                        telemetry = { enable = false },
                    },
                },
            })

            -- Delay enabling to ensure config is fully loaded
            vim.defer_fn(function()
                vim.lsp.enable("lua_ls")
                vim.lsp.enable("pyright")
            end, 100)
        end,
    },

    {
        "mfussenegger/nvim-lint",
        config = function()
            require("lint").linters_by_ft = {
                markdown = { "markdownlint-cli2", "alex" },
                python = { "flake8", "pylint", "mypy" },
                html = { "htmlhint" },
            }

            -- Auto-lint on save
            vim.api.nvim_create_autocmd({ "BufWritePost" }, {
                callback = function()
                    require("lint").try_lint()
                end,
            })
        end,
    },

    -- Your trouble.nvim and conform.nvim config remains the same
    {
        "folke/trouble.nvim",
        opts = {},
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
                    args = { "-", "--indent-type", "Spaces", "--indent-width", "4" },
                    stdin = true,
                },
                my_black = {
                    command = "black",
                    prepend_args = { "--line-length", "80" },
                    args = { "-" },
                    stdin = true,
                },
                my_isort = {
                    command = "isort",
                    args = { "-", "--profile", "black" },
                    stdin = true,
                },
            },
            formatters_by_ft = {
                ["markdown"] = { "prettier" },
                ["markdown.mdx"] = { "prettier" },
                ["lua"] = { "my_stylua" },
                ["python"] = { "my_isort", "my_black" },
                ["css"] = { "prettier" },
            },
            timeout_ms = 5000,
        },
    },
}
