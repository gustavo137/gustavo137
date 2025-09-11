## 📄 Vimrc Shortcuts Cheatsheet
By Gustavo Paredes based om [Vim-guide](https://www.freecodecamp.org/news/vimrc-configuration-guide-customize-your-vim-editor/).

This is a good docs for learning vim please read [vim-docs](https://www.tutorialspoint.com/vim/index.htm).

### 📖 General Vim Commands
| Shortcut  | Description                                             |
| --------- | ------------------------------------------------------- |
| `Switch to terminal` | `:terminal` or `:term` (from vim)              |
| `cntrl + z` | Suspend vim and return to terminal.                     |
| `fg       ` | (type from the terminal) Return to vim from terminal.   |
| `ca", ca{, ca[, ca(, etc.` | Change the text inside quotes, braces, brackets, etc. |
| `ci", ci{, ci[, ci(, etc.` | Change the text inside quotes, braces, brackets, etc. (without the closing character) |
| `ciw, cw, c3w` | Change the word under the cursor.                     |
| `_  ` | to go to the first character of the line.         |
| ` n>>` | to indent n lines |
| ` n<<` | to unindent n lines |
| `cntrl + b` | to move one  page up. |
| `cntrl + f` | to move one page down. |
| `cntrl + d` | to move half a page down. |
| `cntrl + u` | to move half a page up. |
| `zt` | to move the current line to the top of the screen. |
| `zz` | to move the current line to the center of the screen. |
| `zb` | to move the current line to the bottom of the screen. |
| `w`           | Move the cursor to the beginning of the next word |
| `W`         | Similar to `w`, but ignores punctuation and moves between spaces. |
| `b`           | Move the cursor to the beginning of the previous word |
| `B`           | Similar to `b`, but ignores punctuation and moves between spaces. |
| `e`           | Move the cursor to the end of the current word |
| `0`           | Move the cursor to the beginning of the line |
| `$`           | Move the cursor to the end of the line   |
| `gg`          | Move the cursor to the top of the file   |
| `gt`          | Next tab (`:tabnext`) "go to"            |
| `gT`         | Previous tab (`:tabprevious`) "go to"   |

### :%s/world/new_world/gc
This is not a good idea to map it, so is better to learn it.

### learns macros  EYE

### 🔑 My mappings

| Shortcut      | Description                              |
| ------------- | ---------------------------------------- |
| `jj` (insert) | Exit insert mode (like `<Esc>`)          |
| `\t`          | Open terminal inside Vim                 |
| `\s`          | Reload vimrc (`:source ~/.vimrc`)        |
| `\q`          | Open new tab (`:tabnew`)                 |
| `gr`          | Next buffer (`:bnext`)                   |
| `gR`          | Previous buffer (`:bprevious`)           |
| `\d`          | Disable ALE linter                       |
| `\e`          | Enable ALE linter                        |
| `\o`          | Open Instant Markdown preview            |
| `\c`          | Stop Instant Markdown preview            |
| `\\`          | Turn off search highlight                |
| `\h`          | Browse recent files (`:browse oldfiles`) |
| \`\`\`        | Jump to last cursor position (` `` `)    |
| `<Space>`     | Enter command mode (`:`)                 |
| `ge`          | Move the cursor to the end of the previous word |
| `\y="+y`      | Bind to copy to the clipboard a line or visual selection.|
| `\y="+yy`     | copy a line to the clipboard in normal mode |
| `\p="+p`      | Paste from the clipboard in normal mode.           |
| `\ya=gg"+yG`  | Copy the entire file to the clipboard in normal mode. |

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


**Note**: When we open a new terminal using `:terminal` or `\t`, we can use `control + w` then `j`, `k`, `h`, or `l` to navigate between splits.
### 🔧 Resize splits (macOS safe)
The `C-S` means Control + Shift.
| Shortcut      | Description     |
| ------------- | --------------- |
| `<C-S-Up>`    | Increase height |
| `<C-S-Down>`  | Decrease height |
| `<C-S-Left>`  | Increase width  |
| `<C-S-Right>` | Decrease width  |

### 🔧 Resize splits (linux)

| Shortcut      | Description     |
| ------------- | --------------- |
| `<C-Up>`    | Increase height |
| `<C-Down>`  | Decrease height |
| `<C-Left>`  | Increase width  |
| `<C-Right>` | Decrease width  |
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
zR # Collapse all sections (folds)
zM # Uncollapse all sections (folds)
zo # Uncollapse the current section (fold)
zc # Collapse the current section (fold)
za # Toggle the current section (fold)
zO # Uncollapse all sections (folds) recursively
zC # Collapse all sections (folds) recursively
```
### In the server

In the server we need to install the plugins using the following command:

```bash
curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
```
Then inside vim we can use PlugInstall to install the plugins, PlugUpdate to update the plugins, and PlugClean to remove unused plugins, etc.
