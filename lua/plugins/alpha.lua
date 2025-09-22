return {
    "goolord/alpha-nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },

    config = function()
        local alpha = require("alpha")
        local dashboard = require("alpha.themes.startify")

        local logo = {
            [[                                                                     ]],
            [[                                                                     ]],
            [[=====================================================================]],
            [[ /$$$$$$$                                /$$    /$$ /$$              ]],
            [[| $$__  $$                              | $$   | $$|__/              ]],
            [[| $$  \ $$  /$$$$$$   /$$$$$$  /$$$$$$$$| $$   | $$ /$$ /$$$$$$/$$$$ ]],
            [[| $$  | $$ /$$__  $$ /$$__  $$|____ /$$/|  $$ / $$/| $$| $$_  $$_  $$]],
            [[| $$  | $$| $$$$$$$$| $$$$$$$$   /$$$$/  \  $$ $$/ | $$| $$ \ $$ \ $$]],
            [[| $$  | $$| $$_____/| $$_____/  /$$__/    \  $$$/  | $$| $$ | $$ | $$]],
            [[| $$$$$$$/|  $$$$$$$|  $$$$$$$ /$$$$$$$$   \  $/   | $$| $$ | $$ | $$]],
            [[|_______/  \_______/ \_______/|________/    \_/    |__/|__/ |__/ |__/]],
            [[=====================================================================]],
            [[                                                                     ]],
            [[A rather serious NeoVim config.  DeezVim is serious.  Really serious.]],
            [[                                                                     ]],
        }

        local function center_lines(lines)
            local width = vim.o.columns
            local centered = {}
            for _, line in ipairs(lines) do
                local line_width = vim.fn.strdisplaywidth(line)
                -- tweak offset to account for startify margins
                local padding = math.floor((width - line_width) / 2) - 2
                if padding < 0 then
                    padding = 0
                end
                table.insert(centered, string.rep(" ", padding) .. line)
            end
            return centered
        end

        dashboard.section.header.val = center_lines(logo)

        vim.api.nvim_create_autocmd("VimResized", {
            callback = function()
                dashboard.section.header.val = center_lines(logo)
                -- Refresh alpha to apply changes
                if vim.fn.exists(":Alpha") == 2 then
                    vim.cmd("AlphaRedraw")
                end
            end,
        })

        alpha.setup(dashboard.opts)
    end,
}
