# Plugin to check updates for Golang Packages in Go.mod

This plugin checks your go.mod file for outdated dependencies with a single command. No need to manually search for updates or run go get commands.

## Installation using lazy vim

```
return {
  {
    "sukhjit/go-pkgs-check.nvim",
    config = function()
      require("GoPkgsCheck").setup()
    end,
  },
}
```

## Commands

List outdated packages in go.mod file

```
GoPkgsCheckShow
```

Update outdated package currently under cursor in go.mod file

```
GoPkgsCheckUpdate
```

Clear list with

```
GoPkgsCheckClear
```

## Config for lazyvim

Config containing keymaps for the commands

```
return {
  {
    "sukhjit/go-pkgs-check.nvim",
    config = function()
      local gpc = require "GoPkgsCheck"

      gpc.setup()

      vim.keymap.set("n", "<Leader>cps", gpc.show, { desc = "[Code] [P]ackage [S]how" })
      vim.keymap.set("n", "<Leader>cpu", gpc.update, { desc = "[Code] [P]ackage [U]pdate" })
      vim.keymap.set("n", "<Leader>cpc", gpc.clear, { desc = "[Code] [P]ackage [C]lear" })
    end,
  },
}
```

### Resource for creating this plugin

https://www.youtube.com/watch?v=PdaObkGazoU
