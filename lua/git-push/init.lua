local M = {}

local function is_git_repo()
    local git_dir = vim.fn.finddir('.git', vim.fn.getcwd() .. ";")
    return git_dir ~= ""
end

function M.gitPushMeBabe(with_origin, with_menu)
    local out = vim.fn.system "git branch | tr -d '\n'"
    print(out)
    if (not is_git_repo()) then
        print("This is not a git repository")
        return
    end
    local menu_items = {}

    for substring in out:gmatch("%S+") do
        if (substring ~= nil or substring ~= '') then
            substring = string.gsub(substring, "*", "")
            if (with_menu) then
                table.insert(menu_items, require("nui.menu").item(substring))
            else
                table.insert(menu_items, substring)
            end
        end
    end

    if (with_menu) then
        local Menu = require("nui.menu")

        local menu = Menu({
            position = "50%",
            size = {
                width = 25,
                height = 5,
            },
            border = {
                style = "single",
                text = {
                    top = "Choose branch to push",
                    top_align = "center",
                },
            },
            win_options = {
                winhighlight = "Normal:Normal,FloatBorder:Normal",
            },
        }, {
            lines = menu_items,
            max_width = 20,
            keymap = {
                focus_next = { "j", "<Down>", "<Tab>" },
                focus_prev = { "k", "<Up>", "<S-Tab>" },
                close = { "<Esc>", "<C-c>" },
                submit = { "<CR>", "<Space>" },
            },
            on_submit = function(item)
                local cmd = "push "
                if (with_origin) then
                    cmd = cmd .. "origin "
                end
                vim.cmd.Git({ args = { cmd .. item.text } })
            end,
        })
        menu:mount()
    end
end

return M
