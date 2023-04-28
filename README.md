# git-push
This plugin is an extension to [vim-fugitive](https://github.com/tpope/vim-fugitive)

Creates a [nui.vim](https://github.com/MunifTanjim/nui.nvim) menu with the all the branches, where you can select the branch to push


### Usage

```lua
local git_push = require('git-push')
-- optional
git_push.setup({
  remote: 'origin'
})

-- display the dialog
git_push.show_push_dialog()
```

using a remap

```lua
vim.keymap.set("n", "<leader>gp", function()
    require("git-push").show_push_dialog()
end, {desc = "[G]it [P]ush"})
```
