#!/bin/sh

echo "Setting up the environment for local development"

VENV_DIR="env"

PYTHONPATH="$(pwd)/src"
export PYTHONPATH
echo "PYTHONPATH set to $PYTHONPATH"

if [ ! -d "$VENV_DIR" ]; then
    python3 -m venv "$VENV_DIR"
    echo "created a new virtual environment"
fi

# shellcheck disable=SC1091
if ! . "$VENV_DIR/bin/activate"; then
    echo "Failed to activate the virtual environment. Exiting."
    exit 1
fi
echo "activated the virtual environment"

pip install -r requirements.txt
echo "installed the requirements"
cat requirements.txt

if pytest; then
    echo "Tests ran successfully. Your setup is done."
else
    echo "Tests failed. Please check the errors above."
fi
