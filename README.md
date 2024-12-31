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

Clear list with

```
GoPkgsCheckClear
```

### Resource for creating this plugin

https://www.youtube.com/watch?v=PdaObkGazoU
