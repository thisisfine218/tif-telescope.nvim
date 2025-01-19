# tif-telescope.nvim

A Neovim plugin collection for Telescope custom queries with preview capabilities.

## Features

- **TifJq**: Interactive `jq` query builder with live preview
- **TifCheat**: Quick access to `cheat.sh` with Telescope interface

## Prerequisites

- Neovim >= 0.8.0
- [telescope.nvim](https://github.com/nvim-telescope/telescope.nvim)
- curl (for cheat.sh integration)
- jq (for JSON querying)

## Installation

Using [lazy.nvim](https://github.com/folke/lazy.nvim):

```lua
{
    "thisisfine218/tif-telescope.nvim",
    dependencies = {
        "nvim-telescope/telescope.nvim",
    },
    config = true
}
```

## Usage

### jq

The `jq` query builder allows you to interactively build and preview `jq` queries on your JSON files.

- Open with `:TifJq` (to query the current file)
- Open with `:TifJq /path/to/file.json` (to query a custom file)
- Type your `jq` query in the prompt
- See live results in the preview window
- Use `<CR>` to open in current window
- Use `<C-v>` to open in vertical split
- Use `<C-s>` to open in horizontal split

Example queries:
```
.[] | select(.name == "test")
.items | map(.price)
```

### cht.sh

Access cheat.sh directly from Neovim with a Telescope interface.

- Open with `:TifCheat`
- Type your query (e.g., "python/list", "git/rebase")
- Results update after 1 second of typing inactivity
- Use `<CR>` to open in current window
- Use `<C-v>` to open in vertical split
- Use `<C-s>` to open in horizontal split

Example queries:
```
python/reverse list
git/rebase
lua/table insert
```

## Credits

- [telescope.nvim](https://github.com/nvim-telescope/telescope.nvim) for the interface
- [cheat.sh](https://cheat.sh/) for the cheat sheet database
- [jq](https://stedolan.github.io/jq/) for JSON processing

## License

MIT
