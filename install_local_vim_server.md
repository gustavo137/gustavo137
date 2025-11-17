# Instrucctions to Install a Local Vim in a Server

To install a local Vim server on your machine, follow these steps in the file `install_vim_local.sh` or simple execute the `.sh` script below:
```bash
cat <<'EOF' > install_vim_local.sh
#!/bin/bash
set -e

echo ">>> Creating directories..."
mkdir -p $HOME/local/vim $HOME/src
cd $HOME/src

echo ">>> Cloning Vim..."
git clone https://github.com/vim/vim.git
cd vim

echo ">>> Configuring build..."
./configure --prefix=$HOME/local/vim \
    --with-features=huge \
    --enable-multibyte \
    --enable-python3interp=yes \
    --enable-cscope \
    --enable-terminal \
    --enable-fail-if-missing \
    --enable-gui=no \
    --without-x

# Notes:
# --enable-python3interp=yes is required for modern plugins (Copilot, ALE, LSP, etc.).
# If your system has multiple Python versions, specify the Python config directory:
# ------ 
PYTHON3_CONFIG_DIR=$(python3-config --configdir)
./configure --prefix=$HOME/local/vim \
    --enable-python3interp=yes \
    --with-python3-config-dir=$PYTHON3_CONFIG_DIR
# In general we don't need to specify other options.
# ------


echo ">>> Building..."
make -j$(nproc)
make install
echo ">>> Updating PATH... in /.bashrc or /.zshrc file:"
echo 'export PATH="$HOME/local/vim/bin:$PATH"' >> $HOME/.bashrc
source $HOME/.bashrc
echo ">>> Installation complete!"
EOF

## Running the Installation Script
chmod +x install_vim_local.sh
./install_vim_local.sh
```

## Node.js
 To use plugins that require Node.js (like coc.nvim), install Node.js locally:

```bash
cd $HOME
mkdir -p $HOME/local/node
cd $HOME/local/node
wget https://nodejs.org/dist/v20.18.0/node-v20.18.0-linux-x64.tar.xz
tar -xf node-v20.18.0-linux-x64.tar.xz --strip-components=1
export PATH="$HOME/local/node/bin:$PATH"
echo 'export PATH="$HOME/local/node/bin:$PATH"' >> $HOME/.bashrc
source $HOME/.bashrc # or source $HOME/.zshrc
```

## Setup copilot
To set up GitHub Copilot in your local Vim installation we go to vim and in the comand line we type:
```vim
:Copilot setup
```
This will open a browser window to authenticate with GitHub. Follow the prompts to complete the setup.
Make sure you have the pluggin installed and configured in your vimrc file. 
