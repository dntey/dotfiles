vim.g.mapleader = " "

local keymap = vim.keymap -- for conciseness

-- escape insert mode w/ jk
keymap.set("i", "jk", "<ESC>", { desc = "Exit insert mode w/ jk" })
-- leader for common functions
keymap.set("n", "<D-s>", "<cmd>w<CR>", { desc = "Save buffer"})
keymap.set("n", "qq", "<cmd>qa<CR>", { desc = "Quit all buffers"})

keymap.set("n", "<ESC>", "<cmd>nohl<CR>", { desc = "clear search highlights" })

-- increment/decrement numbers
keymap.set("n", "+", "<C-a>", { desc = "Increment number" })
keymap.set("n", "-", "<C-x>", { desc = "Decrement number" })

-- align after scrolling up/down
keymap.set("n", "<C-d>", "<C-d>zz")
keymap.set("n", "<C-u>", "<C-u>zz")

-- window management
keymap.set("n", "<leader>wv", "<C-w>v", { desc = "Split (w)indow (v)ertically" })
keymap.set("n", "<leader>ws", "<C-w>s", { desc = "Split (w)indow (h)orizonally" })
keymap.set("n", "<leader>we", "<C-w>=", { desc = "Make splits equal size" })

-- buffer navigation
keymap.set("n", "<leader>bn", "<cmd>bnext<CR>", { desc = "Next buffer" })
keymap.set("n", "<leader>bp", "<cmd>bprevious<CR>", { desc = "Previous buffer" })
keymap.set("n", "<leader>bi", "<cmd>FzfLua buffers<CR>", { desc = "List buffers interactively" })
keymap.set("n", "<leader>bq", "<cmd>bdelete<CR>", { desc = "Delete buffer" })

-- tab navigation
keymap.set("n", "<leader><Tab>o", "<cmd>tabnew<CR>", { desc = "Open new tab" })
keymap.set("n", "<leader><Tab>q", "<cmd>tabclose<CR>", { desc = "Close current tab" })
keymap.set("n", "<leader><Tab>n", "<cmd>tabn<CR>", { desc = "Go to next tab" })
keymap.set("n", "<leader><Tab>p", "<cmd>tabp<CR>", { desc = "Go to previous tab" })
keymap.set("n", "<leader><Tab>c", "<cmd>tabnew %<CR>", { desc = "Open current buffer in new tab" })

-- Better window navigation
keymap.set("n", "<leader>wh", "<C-w>h", { desc = "window left" })
keymap.set("n", "<leader>wj", "<C-w>j", { desc = "window down" })
keymap.set("n", "<leader>wk", "<C-w>k", { desc = "window up" })
keymap.set("n", "<leader>wl", "<C-w>l", { desc = "window right" })

-- Easy align columns of text
keymap.set("n", "ga", "<Plug>(EasyAlign)")

-- Exit terminal mode with ESC 
keymap.set("t", "<ESC><ESC><ESC>", "<C-\\><C-n>", { desc = "exit terminal" })

-- toggle zen mode
keymap.set("n", "<leader>tz", "<cmd>ZenMode<CR>", {desc = "(t)oggle (z)en mode"})

-- tree view
keymap.set("n", "<leader>te", "<cmd>NvimTreeToggle<CR>", { desc = "(t)oggle file (e)xplorer" }) -- toggle file explorer

-- auto sessions
keymap.set("n", "<leader>r", "<cmd>SessionRestore<CR>", { desc = "Restore session for cwd" }) -- restore last workspace session for current directory
keymap.set("n", "<leader>ss", "<cmd>SessionSave<CR>", { desc = "Save session for auto session root dir" }) -- save workspace session for current working directory

-- fzf 
keymap.set("n", "<leader>ff", "<cmd>FzfLua files<CR>", { desc = "(f)ind (f)iles" }) -- open fzf
keymap.set("n", "<leader>fc", "<cmd>FzfLua files cwd=~/.config<CR>", { desc = "(f)ind (c)onfig"}) -- open fzf
keymap.set("n", "<leader>fr", "<cmd>FzfLua resume<CR>", { desc = "(f)ind (r)esume" }) 
keymap.set("n", "<leader>fs", "<cmd>FzfLua live_grep<CR>", { desc = "(f)ind (s)tring" }) 
keymap.set("n", "<leader>fl", "<cmd>FzfLua blines<CR>", { desc = "(f)ind (l)ines in current buffer" }) 
keymap.set("n", "<leader>fm", "<cmd>FzfLua marks<CR>", { desc = "(f)ind (m)arks" }) 
keymap.set("n", "<leader>fh", "<cmd>FzfLua helptags<CR>", { desc = "(f)ind (h)elp" }) 
keymap.set("n", "<leader>fmp", "<cmd>FzfLua manpages<CR>", { desc = "(f)ind (m)an (p)ages" }) 
keymap.set("n", "<leader>fc", "<cmd>FzfLua commands<CR>", { desc = "(f)ind (c)ommands" }) 
keymap.set("n", "<leader>fk", "<cmd>FzfLua keymaps<CR>", { desc = "(f)ind (k)eyamps" }) 

-- insert-mode completion with <C-x><C-f>
vim.keymap.set({ "n", "v", "i" }, "<C-x><C-f>",
  function() require("fzf-lua").complete_path() end,
  { silent = true, desc = "Fuzzy complete path" })

-- terminal
keymap.set("n", "<leader>tv", "<cmd>FloatermToggle<CR>", { desc = "(t)oggle terminal" })

-- w3m browser
-- keymap.set("n", "<leader>e", "<cmd>W3m ", { desc = "(e)xplore web" })
-- keymap.set("n", "<leader>et", "<cmd>W3mTab ", { desc = "(e)xplore in new (t)ab" })
-- keymap.set("n", "<leader>es", "<cmd>W3mSplit ", { desc = "(e)xplore (s)plit" })
-- keymap.set("n", "<leader>ev", "<cmd>W3mVsplit ", { desc = "(e)xplore (v)split" })
-- keymap.set("n", "<leader>ey", "<cmd>W3mCopyUrl", { desc = "copy url from w3m" })
-- keymap.set("n", "<leader>er", "<cmd>W3mReload", { desc = "(r)eload W3m page" })
-- keymap.set("n", "<leader>eh", "<cmd>W3mHistory", { desc = "w3m (h)istory" })
-- keymap.set("n", "<leader>ec", "<cmd>W3mHistory", { desc = "w3m (h)istory (c)lear" })
