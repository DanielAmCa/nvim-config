-- lua/pickers/harpoon.lua
local harpoon = require("harpoon")

local function toggle_telescope(harpoon_files)
    local finder = function()
        local paths = {}
        for _, item in ipairs(harpoon_files.items) do
            table.insert(paths, item.value)
        end

        return require("telescope.finders").new_table({
            results = paths,
        })
    end

    require("telescope.pickers")
        .new({}, {
            prompt_title = "⇀ Harpoon",
            finder = finder(),
            previewer = false,
            sorter = require("telescope.config").values.generic_sorter({}),
            layout_config = {
                height = 0.4,
                width = 0.5,
                prompt_position = "top",
                preview_cutoff = 120,
            },
            attach_mappings = function(prompt_bufnr, map)
                map("i", "<C-d>", function()
                    local state = require("telescope.actions.state")
                    local selected_entry = state.get_selected_entry()
                    local current_picker = state.get_current_picker(prompt_bufnr)

                    table.remove(harpoon_files.items, selected_entry.index)
                    current_picker:refresh(finder())
                end)
                map("i", "<C-j>", function()
                    local state = require("telescope.actions.state")
                    local selected_entry = state.get_selected_entry()
                    if selected_entry.index + 1 > harpoon:list()._length then
                        return
                    end

                    local next_item = table.remove(harpoon_files.items, selected_entry.index + 1)
                    local curr_item = table.remove(harpoon_files.items, selected_entry.index)

                    table.insert(harpoon_files.items, selected_entry.index, next_item)
                    table.insert(harpoon_files.items, selected_entry.index + 1, curr_item)

                    state.get_current_picker(prompt_bufnr):refresh(finder())
                end)
                map("i", "<C-m>", function()
                    local state = require("telescope.actions.state")
                    local selected_entry = state.get_selected_entry()
                    if selected_entry.index - 1 < 1 then
                        return
                    end

                    local curr_item = table.remove(harpoon_files.items, selected_entry.index)
                    local prev_item = table.remove(harpoon_files.items, selected_entry.index - 1)

                    table.insert(harpoon_files.items, selected_entry.index - 1, curr_item)
                    table.insert(harpoon_files.items, selected_entry.index, prev_item)

                    state.get_current_picker(prompt_bufnr):refresh(finder())
                end)
                return true
            end,
        })
        :find()
end

vim.keymap.set("n", "<leader>hf", function()
    toggle_telescope(harpoon:list())
end, { desc = "Show harpoon list" })
