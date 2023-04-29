# git-push
This plugin is an extension to [vim-fugitive](https://github.com/tpope/vim-fugitive)

Creates a [nui.vim](https://github.com/MunifTanjim/nui.nvim) menu with the all the branches, where you can select the branch to push


### Usage

```lua
local git_push = require('git-push')
-- optional
git_push.setup({
  remote = 'origin',
  use_nui = false
})

-- display the dialog
git_push.show_push_dialog()
```

`use_nui` default: `true` if set to `false` it will use the native `vim.ui.input` to get the selection

using a remap

```lua
vim.keymap.set("n", "<leader>gp", function()
    require("git-push").show_push_dialog()
end, {desc = "[G]it [P]ush"})
```

