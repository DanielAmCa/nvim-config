return {
    {
        "mfussenegger/nvim-dap",
        dependencies = {
            "rcarriga/nvim-dap-ui",
            "nvim-neotest/nvim-nio",
            "HiPhish/debugpy.nvim",
        },
        config = function()
            local dap, dapui = require("dap"), require("dapui")

            dapui.setup({})

            dap.listeners.before.attach.dapui_config = function()
                dapui.open()
            end
            dap.listeners.before.launch.dapui_config = function()
                dapui.open()
            end
            dap.listeners.before.event_terminated.dapui_config = function()
                dapui.close()
            end
            dap.listeners.before.event_exited.dapui_config = function()
                dapui.close()
            end

            vim.keymap.set("n", "<Leader>dt", vim.cmd.DapToggleBreakpoint, { desc = "Toggle breakpoint" })
            vim.keymap.set("n", "<Leader>dc", vim.cmd.DapContinue, { desc = "Continue (Debug)" })
        end
    },
}
