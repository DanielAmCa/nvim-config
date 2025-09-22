return {
    {
        "nvim-treesitter/nvim-treesitter",
        branch = "master",
        lazy = "false",
        build = ":TSUpdate",
        opts = {
            ensure_installed = {
                "c",
                "regex",
                "lua",
                "css",
                "python",
                "cpp",
                "javascript",
                "html",
                "java",
                "markdown",
                "markdown_inline",
                "latex",
                "yaml",
            },

            sync_install = false,

            auto_install = true,

            highlight = {
                enable = true,
                additional_vim_regex_highlighting = { "markdown", "markdown_inline" },
            },
        },
    },
}
