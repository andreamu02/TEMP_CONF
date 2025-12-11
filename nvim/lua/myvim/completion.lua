-- lua/myvim/completion.lua

local cmp = require('cmp')
local luasnip = require('luasnip')
local lspkind = require('lspkind')

require('luasnip.loaders.from_vscode').lazy_load()

cmp.setup({
  snippet = {
    expand = function(args) luasnip.lsp_expand(args.body) end,
  },

  -- Finestre con bordo + doc bordata
 window = {
    completion = cmp.config.window.bordered({
      side_padding = 1,  -- aumenta se vuoi più spazio sinistra/destra
      winhighlight = "Normal:CmpPmenu,FloatBorder:CmpPmenuBorder,CursorLine:PmenuSel,Search:None",
    }),
    documentation = cmp.config.window.bordered({
      winhighlight = "Normal:CmpDoc,FloatBorder:CmpDocBorder,CursorLine:PmenuSel,Search:None",
      max_width = 80, -- solo estetico, non è padding
    }),
  },
  mapping = {
    ['<C-p>'] = cmp.mapping.select_prev_item(),
    ['<C-n>'] = cmp.mapping.select_next_item(),
    ['<C-d>'] = cmp.mapping.scroll_docs(-4),
    ['<C-f>'] = cmp.mapping.scroll_docs(4),
    ['<C-Space>'] = cmp.mapping.complete(),
    ['<CR>'] = cmp.mapping.confirm({ select = true }),
    ['<Tab>'] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_next_item()
      elseif luasnip.expand_or_jumpable() then
        luasnip.expand_or_jump()
      else
        fallback()
      end
    end, { 'i', 's' }),
    ['<S-Tab>'] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_prev_item()
      elseif luasnip.jumpable(-1) then
        luasnip.jump(-1)
      else
        fallback()
      end
    end, { 'i', 's' }),
  },

  -- Iconcine e testo tipo VSCode
  formatting = {
    format = lspkind.cmp_format({
      mode = "symbol_text",
      maxwidth = 50,
      ellipsis_char = '…',
      menu = {
        nvim_lsp = "[LSP]",
        luasnip  = "[Snip]",
        buffer   = "[Buf]",
      },
    }),
  },

  sources = {
    { name = 'nvim_lsp' },
    { name = 'luasnip' },
    { name = 'buffer' },
  },

  experimental = {
    ghost_text = true,
  },
})

