# nanobufferline (nbl) 

*visions of editors past, and then jumping required ahead*

Yet another statusline plugin for Neovim. Displays the list of buffers and
highlights the current buffer. Makes it nicer to switch buffers with :bn and
:bp (I've mapped these to <Tab> and <S-Tab>). I still make use of a buffer
picker (thank you Telescope).

Under the hood, nbl overlays a narrow and wide floating window directly above
the statusline, so it most likely interferes with other statusline plugins.

There will be bugs.

## Install

```lua
vim.pack.add({ "https://github.com/kausikk/nanobufferline", name = "nanobufferline" })
```

Not lazy-loaded. Setup is **not** required, but the highlight of the current
buffer can be overridden:

```lua
-- See ':h highlight-groups' for more options
require("nanobufferline").setup({ hl_group = "Label" })
```
