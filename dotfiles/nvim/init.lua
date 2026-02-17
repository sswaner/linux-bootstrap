-- Neovim Configuration for Linux Bootstrap
-- A clean, minimal configuration focused on productivity

-- Basic Settings
vim.opt.number = true              -- Show line numbers
vim.opt.relativenumber = true      -- Show relative line numbers
vim.opt.mouse = 'a'                -- Enable mouse support
vim.opt.ignorecase = true          -- Case insensitive search
vim.opt.smartcase = true           -- Override ignorecase if search has uppercase
vim.opt.hlsearch = true            -- Highlight search results
vim.opt.incsearch = true           -- Incremental search
vim.opt.wrap = false               -- Don't wrap lines
vim.opt.tabstop = 4                -- Tab width
vim.opt.shiftwidth = 4             -- Indent width
vim.opt.expandtab = true           -- Use spaces instead of tabs
vim.opt.autoindent = true          -- Auto indent new lines
vim.opt.smartindent = true         -- Smart indent
vim.opt.clipboard = 'unnamedplus'  -- Use system clipboard
vim.opt.termguicolors = true       -- True color support
vim.opt.updatetime = 250           -- Faster completion
vim.opt.timeoutlen = 300           -- Faster key sequence timeout
vim.opt.splitright = true          -- Split to right
vim.opt.splitbelow = true          -- Split below
vim.opt.cursorline = true          -- Highlight current line
vim.opt.signcolumn = 'yes'         -- Always show sign column
vim.opt.scrolloff = 8              -- Keep 8 lines above/below cursor
vim.opt.sidescrolloff = 8          -- Keep 8 columns left/right of cursor
vim.opt.backup = false             -- No backup file
vim.opt.writebackup = false        -- No backup while writing
vim.opt.swapfile = false           -- No swap file
vim.opt.undofile = true            -- Persistent undo
vim.opt.undodir = os.getenv("HOME") .. "/.vim/undodir"
vim.opt.completeopt = 'menuone,noselect'  -- Better completion

-- Leader key
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

-- Key Mappings
local keymap = vim.keymap.set
local opts = { noremap = true, silent = true }

-- Better window navigation
keymap('n', '<C-h>', '<C-w>h', opts)
keymap('n', '<C-j>', '<C-w>j', opts)
keymap('n', '<C-k>', '<C-w>k', opts)
keymap('n', '<C-l>', '<C-w>l', opts)

-- Resize windows
keymap('n', '<C-Up>', ':resize -2<CR>', opts)
keymap('n', '<C-Down>', ':resize +2<CR>', opts)
keymap('n', '<C-Left>', ':vertical resize -2<CR>', opts)
keymap('n', '<C-Right>', ':vertical resize +2<CR>', opts)

-- Navigate buffers
keymap('n', '<S-l>', ':bnext<CR>', opts)
keymap('n', '<S-h>', ':bprevious<CR>', opts)

-- Clear search highlighting
keymap('n', '<leader>h', ':nohlsearch<CR>', opts)

-- Better indenting
keymap('v', '<', '<gv', opts)
keymap('v', '>', '>gv', opts)

-- Move text up and down
keymap('v', '<A-j>', ':m .+1<CR>==', opts)
keymap('v', '<A-k>', ':m .-2<CR>==', opts)
keymap('v', 'p', '"_dP', opts)

-- Visual Block mode
keymap('x', 'J', ":move '>+1<CR>gv-gv", opts)
keymap('x', 'K', ":move '<-2<CR>gv-gv", opts)
keymap('x', '<A-j>', ":move '>+1<CR>gv-gv", opts)
keymap('x', '<A-k>', ":move '<-2<CR>gv-gv", opts)

-- Stay in indent mode
keymap('v', '<', '<gv', opts)
keymap('v', '>', '>gv', opts)

-- File explorer (netrw)
keymap('n', '<leader>e', ':Explore<CR>', opts)

-- Quick save and quit
keymap('n', '<leader>w', ':w<CR>', opts)
keymap('n', '<leader>q', ':q<CR>', opts)
keymap('n', '<leader>Q', ':qa!<CR>', opts)

-- Split management
keymap('n', '<leader>sv', ':vsplit<CR>', opts)
keymap('n', '<leader>sh', ':split<CR>', opts)
keymap('n', '<leader>sc', ':close<CR>', opts)

-- Terminal mode
keymap('n', '<leader>t', ':terminal<CR>', opts)
keymap('t', '<Esc>', '<C-\\><C-n>', opts)  -- Exit terminal mode with Esc

-- Better paste (don't yank when pasting over)
keymap('v', 'p', '"_dP', opts)

-- Highlight on yank
local highlight_group = vim.api.nvim_create_augroup('YankHighlight', { clear = true })
vim.api.nvim_create_autocmd('TextYankPost', {
  callback = function()
    vim.highlight.on_yank()
  end,
  group = highlight_group,
  pattern = '*',
})

-- Auto-create undo directory if it doesn't exist
local undo_dir = os.getenv("HOME") .. "/.vim/undodir"
if vim.fn.isdirectory(undo_dir) == 0 then
  vim.fn.mkdir(undo_dir, "p")
end

-- Netrw settings (built-in file explorer)
vim.g.netrw_banner = 0          -- Hide banner
vim.g.netrw_liststyle = 3       -- Tree view
vim.g.netrw_browse_split = 4    -- Open in previous window
vim.g.netrw_altv = 1            -- Open splits to the right
vim.g.netrw_winsize = 25        -- 25% width

-- Colorscheme (using built-in schemes, fallback to default)
vim.cmd('colorscheme habamax')

-- Status line
vim.opt.laststatus = 2
vim.opt.showmode = false

-- Simple status line
vim.opt.statusline = '%f %m%r%h%w [%{&ff}] [%Y] %=%l,%c %p%%'

-- Auto-commands
local augroup = vim.api.nvim_create_augroup
local autocmd = vim.api.nvim_create_autocmd

-- Remove trailing whitespace on save
local trim_whitespace = augroup('TrimWhitespace', { clear = true })
autocmd('BufWritePre', {
  group = trim_whitespace,
  pattern = '*',
  command = '%s/\\s\\+$//e',
})

-- File type specific settings
local filetype_settings = augroup('FileTypeSettings', { clear = true })

-- Use 2 spaces for these file types
autocmd('FileType', {
  group = filetype_settings,
  pattern = { 'javascript', 'typescript', 'json', 'html', 'css', 'yaml', 'lua' },
  callback = function()
    vim.opt_local.tabstop = 2
    vim.opt_local.shiftwidth = 2
  end,
})

-- Enable spell check for markdown and text files
autocmd('FileType', {
  group = filetype_settings,
  pattern = { 'markdown', 'text' },
  callback = function()
    vim.opt_local.spell = true
  end,
})

-- Return to last edit position when opening files
autocmd('BufReadPost', {
  callback = function()
    local mark = vim.api.nvim_buf_get_mark(0, '"')
    local lcount = vim.api.nvim_buf_line_count(0)
    if mark[1] > 0 and mark[1] <= lcount then
      pcall(vim.api.nvim_win_set_cursor, 0, mark)
    end
  end,
})

-- Welcome message
print("Neovim configured! Leader key: <Space>")
print("Quick commands: <leader>e (explorer), <leader>w (save), <leader>q (quit)")
