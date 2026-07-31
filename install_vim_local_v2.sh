#!/bin/bash
set -euo pipefail

# Local installation paths
VIM_PREFIX="$HOME/local/vim"
VIM_SOURCE_DIR="$HOME/src/vim"

# Avoid excessive parallel compilation on a login node.
# Override with, for example: MAKE_JOBS=8 ./install_vim_local.sh
MAKE_JOBS="${MAKE_JOBS:-4}"

echo ">>> Checking required commands..."

for command in git gcc make python3 python3-config; do
    if ! command -v "$command" >/dev/null 2>&1; then
        echo "ERROR: Required command '$command' was not found." >&2
        exit 1
    fi
done

echo ">>> Compiler environment:"
echo "gcc: $(command -v gcc)"
gcc --version | head -n 1
echo "as:  $(command -v as)"
as --version | head -n 1

echo ">>> Creating installation directories..."
mkdir -p "$HOME/local" "$HOME/src"

echo ">>> Preparing Vim source code..."

if [ -d "$VIM_SOURCE_DIR/.git" ]; then
    echo "Vim repository already exists. Updating it..."
    git -C "$VIM_SOURCE_DIR" pull --ff-only
else
    git clone https://github.com/vim/vim.git "$VIM_SOURCE_DIR"
fi

cd "$VIM_SOURCE_DIR"

echo ">>> Cleaning previous build files..."
make distclean >/dev/null 2>&1 || true

PYTHON3_CONFIG_DIR="$(python3-config --configdir)"

if [ ! -d "$PYTHON3_CONFIG_DIR" ]; then
    echo "ERROR: Python configuration directory does not exist:" >&2
    echo "       $PYTHON3_CONFIG_DIR" >&2
    exit 1
fi

echo ">>> Python 3 configuration directory:"
echo "$PYTHON3_CONFIG_DIR"

echo "linking the correct version of ncurses "
if [ -n "${EBROOTNCURSES:-}" ]; then
    export CPPFLAGS="-I$EBROOTNCURSES/include ${CPPFLAGS:-}"
    export LDFLAGS="-L$EBROOTNCURSES/lib -Wl,-rpath,$EBROOTNCURSES/lib ${LDFLAGS:-}"
fi

echo ">>> Configuring Vim..."

./configure \
    --prefix="$VIM_PREFIX" \
    --with-features=huge \
    --enable-multibyte \
    --enable-python3interp=yes \
    --with-python3-config-dir="$PYTHON3_CONFIG_DIR" \
    --enable-cscope \
    --enable-terminal \
    --enable-gui=no \
    --without-x \
    --enable-fail-if-missing

echo ">>> Building Vim with $MAKE_JOBS parallel jobs..."
make -j"$MAKE_JOBS"

echo ">>> Installing Vim in $VIM_PREFIX..."
make install

echo ">>> Updating PATH..."

PATH_LINE='export PATH="$HOME/local/vim/bin:$PATH"'

if ! grep -Fqx "$PATH_LINE" "$HOME/.bashrc" 2>/dev/null; then
    printf '\n%s\n' "$PATH_LINE" >> "$HOME/.bashrc"
    echo "Added Vim to PATH in $HOME/.bashrc"
else
    echo "Vim PATH entry is already present in $HOME/.bashrc"
fi

export PATH="$VIM_PREFIX/bin:$PATH"

echo ">>> Verifying installation..."
"$VIM_PREFIX/bin/vim" --version | head -n 12

echo
echo ">>> Vim installation completed successfully."
echo ">>> Executable: $VIM_PREFIX/bin/vim"
echo ">>> Run 'source ~/.bashrc' in the current shell if necessary."
