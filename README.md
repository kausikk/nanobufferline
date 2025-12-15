# nanobufferline (nbl) 

*visions of editors past, and then jumping required ahead*

https://github.com/user-attachments/assets/5223a7fc-73ad-4c50-822f-b27008dfe3c8

Yet another statusline plugin for Neovim. Displays the list of buffers and
highlights the current buffer. Makes it nicer to switch buffers with :bn and
:bp (I've mapped these to \<Tab\> and <S-Tab>). I still make use of a buffer
picker (thank you Telescope).

Under the hood, nbl overlays a narrow and wide floating window directly above
the statusline, so it most likely interferes with other statusline plugins.

There will be bugs.

## Install

```lua
vim.pack.add({..., { src = "https://github.com/kausikk/nanobufferline", name = "nanobufferline" }, ...})
```

Not lazy-loaded. Setup is **not** required, but the highlight color of the
current buffer can be overridden. Default is "Error".

```lua
-- See ':h highlight-groups' for more options
require("nanobufferline").setup({ hl_group = "Label" })
```
