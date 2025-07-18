## 📄 Vimrc Shortcuts Cheatsheet
By Gustavo Paredes based om [Vim-guide](https://www.freecodecamp.org/news/vimrc-configuration-guide-customize-your-vim-editor/).

This is a good docs for learning vim please read [vim-docs](https://www.tutorialspoint.com/vim/index.htm).

### 🔑 General mappings

| Shortcut      | Description                              |
| ------------- | ---------------------------------------- |
| `jj` (insert) | Exit insert mode (like `<Esc>`)          |
| `\t`          | Open terminal inside Vim                 |
| `\s`          | Reload vimrc (`:source ~/.vimrc`)        |
| `\q`          | Open new tab (`:tabnew`)                 |
| `gr`          | Next buffer (`:bnext`)                   |
| `gR`          | Previous buffer (`:bprevious`)           |
| `gt`          | Next tab (`:tabnext`) "go to"            |
| `\d`          | Disable ALE linter                       |
| `\e`          | Enable ALE linter                        |
| `\o`          | Open Instant Markdown preview            |
| `\p`          | Stop Instant Markdown preview            |
| `\\`          | Turn off search highlight                |
| `\h`          | Browse recent files (`:browse oldfiles`) |
| \`\`\`        | Jump to last cursor position (` `` `)    |
| `<Space>`     | Enter command mode (`:`)                 |

### 🪄 Editing mappings

| Shortcut | Description                           |
| -------- | ------------------------------------- |
| `o`      | Open new line below                   |
| `O`      | Open new line above                   |
| `n`      | Next search result, center screen     |
| `N`      | Previous search result, center screen |
| `Y`      | Yank (copy) to end of line (`y$`)     |

### 💻 Run code

| Shortcut | Description                                    |
| -------- | ---------------------------------------------- |
| `<F5>`   | Save and run current Python script in terminal |

### 🌳 NERDTree

| Shortcut | Description                                                          |
| -------- | -------------------------------------------------------------------- |
| `<F2>`   | Toggle NERDTree and update                                           |
| command  | :NERDTreeRefreshRoot<CR>\:NERDTreeToggle<CR>\:set relativenumber<CR> |

### 🪟 Split window navigation

| Shortcut | Description |
| -------- | ----------- |
| `<C-j>`  | Move down   |
| `<C-k>`  | Move up     |
| `<C-h>`  | Move left   |
| `<C-l>`  | Move right  |

### 🔧 Resize splits (macOS safe)

| Shortcut      | Description     |
| ------------- | --------------- |
| `<C-S-Up>`    | Increase height |
| `<C-S-Down>`  | Decrease height |
| `<C-S-Left>`  | Increase width  |
| `<C-S-Right>` | Decrease width  |

### 🏗️ Move split positions

| Shortcut | Description                 |
| -------- | --------------------------- |
| `\H`     | Move split to the far left  |
| `\L`     | Move split to the far right |
| `\K`     | Move split to the top       |
| `\J`     | Move split to the bottom    |

### ✍️ Comments (vim-commentary)

| Shortcut | Description                               |
| -------- | ----------------------------------------- |
| `gcc`    | Comment/uncomment line                    |
| `gc3j`   | Comment/uncomment 3 lines below (example) |

---

⚡ **Leader key is set to `\`** (so `\t` means press `\` then `t`).

In order to use `OpenPreview` and `StopPreview`, you need to install the \[Instant Markdown] using:

```bash
brew install node
npm install -g instant-markdown-d
```
### Colapse all sections and uncollapse the section

```bash 
z + shift , R # Collapse all sections
z + shift , M # Uncollapse all sections
```
