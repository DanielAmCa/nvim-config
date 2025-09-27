return {
    {
        "akinsho/toggleterm.nvim",
        version = "*",
        opts = {--[[ things you want to change go here]]
            on_open = function(t)
                local venv_path = require("venv-selector").venv()
                if venv_path then
                    t:send("mamac " .. venv_path .. " ; clear")
                end
            end,
        },
    },
}
