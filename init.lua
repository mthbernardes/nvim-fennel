vim.g.mapleader = ","
vim.g.maplocalleader = ","
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1
vim.g.have_nerd_font = true

vim.opt.shiftwidth = 2
vim.opt.number = true
vim.opt.mouse = "a"
vim.opt.showmode = false
vim.opt.clipboard = "unnamedplus"
vim.opt.breakindent = true
vim.opt.undofile = true
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.signcolumn = "yes"
vim.opt.updatetime = 250
vim.opt.timeoutlen = 300
vim.opt.splitright = true
vim.opt.splitbelow = true
vim.opt.list = true
vim.opt.listchars = { tab = "» ", trail = "·", nbsp = "␣" }
vim.opt.inccommand = "split"
vim.opt.cursorline = true
vim.opt.scrolloff = 10
vim.opt.hlsearch = true

vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR>")

vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, { desc = "Go to previous [D]iagnostic message" })
vim.keymap.set("n", "]d", vim.diagnostic.goto_next, { desc = "Go to next [D]iagnostic message" })
vim.keymap.set("n", "<leader>e", vim.diagnostic.open_float, { desc = "Show diagnostic [E]rror messages" })
vim.keymap.set("n", "<leader>q", vim.diagnostic.setloclist, { desc = "Open diagnostic [Q]uickfix list" })

vim.keymap.set("n", "<c-d>", ":bd!<cr>", { noremap = true })

vim.keymap.set("t", "<Esc><Esc>", "<C-\\><C-n>", { desc = "Exit terminal mode" })

vim.keymap.set("n", "<C-h>", "<C-w><C-h>", { desc = "Move focus to the left window" })
vim.keymap.set("n", "<C-l>", "<C-w><C-l>", { desc = "Move focus to the right window" })
vim.keymap.set("n", "<C-j>", "<C-w><C-j>", { desc = "Move focus to the lower window" })
vim.keymap.set("n", "<C-k>", "<C-w><C-k>", { desc = "Move focus to the upper window" })

vim.api.nvim_create_autocmd("TextYankPost", {
  desc = "Highlight when yanking (copying) text",
  group = vim.api.nvim_create_augroup("kickstart-highlight-yank", { clear = true }),
  callback = function()
    vim.highlight.on_yank()
  end,
})

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  local lazyrepo = "https://github.com/folke/lazy.nvim.git"
  vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
end ---@diagnostic disable-next-line: undefined-field
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({

  "907th/vim-auto-save",

  {
    "almo7aya/openingh.nvim",
    keys = {
      {
	"<leader>og",
	":OpenInGHFileLines<CR>",
	mode = "n",
	desc = "[O]open [G]ithub",
      }
    }
  },
  { "nvim-tree/nvim-web-devicons", opts = {} },
  { -- Adds git related signs to the gutter, as well as utilities for managing changes
    "lewis6991/gitsigns.nvim",
    opts = {
      signs = {
	add = { text = "+" },
	change = { text = "~" },
	delete = { text = "_" },
	topdelete = { text = "‾" },
	changedelete = { text = "~" },
      },
    },
  },

  {
    "nvim-neotest/neotest",
    dependencies = {
      "nvim-neotest/nvim-nio",
      "nvim-lua/plenary.nvim",
      "antoinemadec/FixCursorHold.nvim",
      "nvim-neotest/neotest-jest",
      "mfussenegger/nvim-dap",
      "nvim-treesitter/nvim-treesitter",
    },
    keys = {
      {
	"<space>tr",
	function()
	  require("neotest").watch.toggle(vim.fn.expand("%"))
	  require("neotest").run.run({ vim.fn.expand("%") })
	end,
	mode = "n",
	desc = "[T]est [R]un",
      },
      {
	"<space>to",
	function()
	  require("neotest").summary.toggle()
	end,
	mode = "n",
	desc = "[T]est [O]pen",
      },
    },
    config = function()
      require("neotest").setup({
	adapters = {
	  require("neotest-jest")({
	    jestCommand = "npm test --",
	    cwd = function(path)
	      return vim.fn.getcwd()
	    end,
	  }),
	},
      })
    end,
  },

  {
    "nvim-tree/nvim-tree.lua",
    enabled = true,
    requires = "nvim-tree/nvim-web-devicons",
    config = function()
      require("nvim-tree").setup({
	auto_close = true, -- Deprecated in newer versions: consider using setup options as per latest docs
	update_focused_file = {
	  enable = true,
	  update_cwd = true,
	},
	view = {
	  width = 30,
	  side = "left",
	},
      })
      vim.api.nvim_set_keymap("n", "<leader>t", ":NvimTreeToggle<CR>", { noremap = true, silent = true })
    end,
  },
  { -- Fuzzy Finder (files, lsp, etc)
    "nvim-telescope/telescope.nvim",
    event = "VimEnter",
    branch = "0.1.x",
    dependencies = {
      "nvim-lua/plenary.nvim",
      {
	"nvim-telescope/telescope-fzf-native.nvim",

	build = "make",

	cond = function()
	  return vim.fn.executable("make") == 1
	end,
      },
      { "nvim-telescope/telescope-ui-select.nvim" },
    },
    config = function()
      require("telescope").setup({
	extensions = {
	  ["ui-select"] = {
	    require("telescope.themes").get_dropdown(),
	  },
	},
      })

      pcall(require("telescope").load_extension, "fzf")
      pcall(require("telescope").load_extension, "ui-select")

      local builtin = require("telescope.builtin")
      vim.keymap.set("n", "<leader>sh", builtin.help_tags, { desc = "[S]earch [H]elp" })
      vim.keymap.set("n", "<leader>sk", builtin.keymaps, { desc = "[S]earch [K]eymaps" })
      vim.keymap.set("n", "<C-p>", builtin.find_files, { desc = "[S]earch [F]iles" })
      vim.keymap.set("n", "<leader>ss", builtin.builtin, { desc = "[S]earch [S]elect Telescope" })
      vim.keymap.set("n", "<leader>sw", builtin.grep_string, { desc = "[S]earch current [W]ord" })
      vim.keymap.set("n", "<C-f>", builtin.live_grep, { desc = "[S]earch by [G]rep" })
      vim.keymap.set("n", "<leader>sd", builtin.diagnostics, { desc = "[S]earch [D]iagnostics" })
      vim.keymap.set("n", "<leader>sr", builtin.resume, { desc = "[S]earch [R]esume" })
      vim.keymap.set("n", "<leader>s.", builtin.oldfiles, { desc = '[S]earch Recent Files ("." for repeat)' })
      vim.keymap.set("n", "<leader><leader>", builtin.buffers, { desc = "[ ] Find existing buffers" })

      vim.keymap.set("n", "<leader>/", function()
	builtin.current_buffer_fuzzy_find(require("telescope.themes").get_dropdown({
	  winblend = 10,
	  previewer = false,
	}))
	end, { desc = "[/] Fuzzily search in current buffer" })

      vim.keymap.set("n", "<leader>s/", function()
	builtin.live_grep({
	  grep_open_files = true,
	  prompt_title = "Live Grep in Open Files",
	})
	end, { desc = "[S]earch [/] in Open Files" })

      vim.keymap.set("n", "<leader>sn", function()
	builtin.find_files({ cwd = vim.fn.stdpath("config") })
	end, { desc = "[S]earch [N]eovim files" })
    end,
  },

  { -- LSP Configuration & Plugins
    "neovim/nvim-lspconfig",
    dependencies = {
      { "williamboman/mason.nvim", config = true }, -- NOTE: Must be loaded before dependants
      "williamboman/mason-lspconfig.nvim",
      "WhoIsSethDaniel/mason-tool-installer.nvim",

      { "j-hui/fidget.nvim", opts = {} },

      { "folke/neodev.nvim", opts = {} },
    },
    config = function()
      vim.api.nvim_create_autocmd("LspAttach", {
	group = vim.api.nvim_create_augroup("kickstart-lsp-attach", { clear = true }),
	callback = function(event)
	  local map = function(keys, func, desc)
	    vim.keymap.set("n", keys, func, { buffer = event.buf, desc = "LSP: " .. desc })
	  end

	  map("gd", require("telescope.builtin").lsp_definitions, "[G]oto [D]efinition")

	  map("gr", require("telescope.builtin").lsp_references, "[G]oto [R]eferences")

	  map("gI", require("telescope.builtin").lsp_implementations, "[G]oto [I]mplementation")

	  map("<leader>D", require("telescope.builtin").lsp_type_definitions, "Type [D]efinition")

	  map("<leader>ds", require("telescope.builtin").lsp_document_symbols, "[D]ocument [S]ymbols")

	  map(
	    "<leader>ws",
	    require("telescope.builtin").lsp_dynamic_workspace_symbols,
	    "[W]orkspace [S]ymbols"
	  )

	  map("<leader>rn", vim.lsp.buf.rename, "[R]e[n]ame")

	  map("ff", vim.lsp.buf.code_action, "[C]ode [A]ction")

	  map("K", vim.lsp.buf.hover, "Hover Documentation")

	  map("gD", vim.lsp.buf.declaration, "[G]oto [D]eclaration")

	  local client = vim.lsp.get_client_by_id(event.data.client_id)
	  if client and client.server_capabilities.documentHighlightProvider then
	    local highlight_augroup =
	    vim.api.nvim_create_augroup("kickstart-lsp-highlight", { clear = false })
	    vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
	      buffer = event.buf,
	      group = highlight_augroup,
	      callback = vim.lsp.buf.document_highlight,
	    })

	    vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
	      buffer = event.buf,
	      group = highlight_augroup,
	      callback = vim.lsp.buf.clear_references,
	    })
	  end

	  if client and client.server_capabilities.inlayHintProvider and vim.lsp.inlay_hint then
	    map("<leader>h", function()
	      vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled())
	      end, "[T]oggle Inlay [H]ints")
	  end
	end,
      })

      vim.api.nvim_create_autocmd("LspDetach", {
	group = vim.api.nvim_create_augroup("kickstart-lsp-detach", { clear = true }),
	callback = function(event)
	  vim.lsp.buf.clear_references()
	  vim.api.nvim_clear_autocmds({ group = "kickstart-lsp-highlight", buffer = event.buf })
	end,
      })

      local capabilities = vim.lsp.protocol.make_client_capabilities()
      capabilities = vim.tbl_deep_extend("force", capabilities, require("cmp_nvim_lsp").default_capabilities())

      local servers = {

	lua_ls = {
	  settings = {
	    Lua = {
	      completion = {
		callSnippet = "Replace",
	      },
	    },
	  },
	},
      }

      require("mason").setup()

      local ensure_installed = vim.tbl_keys(servers or {})
      vim.list_extend(ensure_installed, {
	"stylua",
      })
      require("mason-tool-installer").setup({ ensure_installed = ensure_installed })

      require("mason-lspconfig").setup({
	handlers = {
	  function(server_name)
	    local server = servers[server_name] or {}
	    server.capabilities = vim.tbl_deep_extend("force", {}, capabilities, server.capabilities or {})
	    require("lspconfig")[server_name].setup(server)
	  end,
	},
      })
    end,
  },

  --{ -- Autoformat
  --	"stevearc/conform.nvim",
  --	lazy = false,
  --	keys = {
  --		{
  --			"<leader>f",
  --			function()
  --				require("conform").format({ async = true, lsp_fallback = false })
  --			end,
  --			mode = "n",
  --			desc = "[F]ormat buffer",
  --		},
  --	},
  --	opts = {
  --		notify_on_error = true,
  --		format_on_save = function(bufnr)
  --			local disable_filetypes = { c = true, cpp = true }
  --			return {
  --				timeout_ms = 500,
  --				lsp_fallback = not disable_filetypes[vim.bo[bufnr].filetype],
  --			}
  --		end,
  --		formatters_by_ft = {
  --			lua = { "stylua" },
  --			-- Conform will run multiple formatters sequentially
  --			python = { "isort", "black" },
  --			-- Use a sub-list to run only the first available formatter
  --			javascript = { { "prettierd", "prettier" } },
  --		},
  --	},
  --},

  {
    "nvim-tree/nvim-tree.lua",
    lazy = true,
    dependencies = {
      "nvim-tree/nvim-web-devicons",
    },
  },

  { -- Autocompletion
    "hrsh7th/nvim-cmp",
    event = "InsertEnter",
    dependencies = {
      {
	"L3MON4D3/LuaSnip",
	build = (function()
	  if vim.fn.has("win32") == 1 or vim.fn.executable("make") == 0 then
	    return
	  end
	  return "make install_jsregexp"
	end)(),
	dependencies = {},
      },
      "saadparwaiz1/cmp_luasnip",
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-path",
    },
    config = function()
      local cmp = require("cmp")
      local luasnip = require("luasnip")
      luasnip.config.setup({})

      cmp.setup({
	snippet = {
	  expand = function(args)
	    luasnip.lsp_expand(args.body)
	  end,
	},
	completion = { completeopt = "menu,menuone,noinsert" },
	mapping = cmp.mapping.preset.insert({
	  ["<C-b>"] = cmp.mapping.scroll_docs(-4),
	  ["<C-f>"] = cmp.mapping.scroll_docs(4),

	  ["<CR>"] = cmp.mapping.confirm({ select = true }),
	  ["<Tab>"] = cmp.mapping.select_next_item(),
	  ["<S-Tab>"] = cmp.mapping.select_prev_item(),

	  ["<C-l>"] = cmp.mapping(function()
	    if luasnip.expand_or_locally_jumpable() then
	      luasnip.expand_or_jump()
	    end
	    end, { "i", "s" }),
	  ["<C-h>"] = cmp.mapping(function()
	    if luasnip.locally_jumpable(-1) then
	      luasnip.jump(-1)
	    end
	    end, { "i", "s" }),
	}),
	sources = {
	  { name = "nvim_lsp" },
	  { name = "luasnip" },
	  { name = "path" },
	},
      })
    end,
  },

  {
    "folke/tokyonight.nvim",
    priority = 1000,
    init = function()
      vim.cmd.colorscheme("tokyonight-night")

      vim.cmd.hi("Comment gui=none")
    end,
  },

  { -- Highlight todo, notes, etc in comments
    "folke/todo-comments.nvim",
    event = "VimEnter",
    dependencies = { "nvim-lua/plenary.nvim" },
    opts = { signs = false },
  },

  { -- Collection of various small independent plugins/modules
    "echasnovski/mini.nvim",
    config = function()
      require("mini.ai").setup({ n_lines = 500 })

      require("mini.surround").setup()

      local statusline = require("mini.statusline")
      statusline.setup({ use_icons = vim.g.have_nerd_font })

      ---@diagnostic disable-next-line: duplicate-set-field
      statusline.section_location = function()
	return "%2l:%-2v"
      end
    end,
  },
  { -- Highlight, edit, and navigate code
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    opts = {
      ensure_installed = { "bash", "c", "html", "lua", "luadoc", "markdown", "vim", "vimdoc" },
      auto_install = true,
      highlight = {
	enable = true,
	additional_vim_regex_highlighting = { "ruby" },
      },
      indent = { enable = true, disable = { "ruby" } },
    },
    config = function(_, opts)
      require("nvim-treesitter.install").prefer_git = true
      require("nvim-treesitter.configs").setup(opts)
    end,
  },
}, {
    ui = {
      icons = vim.g.have_nerd_font and {} or {
	cmd = "⌘",
	config = "🛠",
	event = "📅",
	ft = "📂",
	init = "⚙",
	keys = "🗝",
	plugin = "🔌",
	runtime = "💻",
	require = "🌙",
	source = "📄",
	start = "🚀",
	task = "📌",
	lazy = "💤 ",
      },
    },
  })
