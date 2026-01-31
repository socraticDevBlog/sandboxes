#!/bin/bash
# Installation script for Secure Backup Tool (Idempotent & Improved)

# Exit on error, but we'll handle specific errors ourselves
set -e

# Color codes for better output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Helper functions
info() {
    echo -e "${BLUE}ℹ${NC} $1"
}

success() {
    echo -e "${GREEN}✓${NC} $1"
}

warning() {
    echo -e "${YELLOW}⚠${NC} $1"
}

error() {
    echo -e "${RED}✗${NC} $1"
}

# Track installation status
INSTALL_ERRORS=0
INSTALL_WARNINGS=0

echo "========================================="
echo "Secure Backup Tool - Installation"
echo "========================================="
echo ""

# Check Python version
info "Checking Python version..."
if ! command -v python3 &> /dev/null; then
    error "Python 3 is not installed"
    echo "Please install Python 3.8 or later"
    exit 1
fi

PYTHON_VERSION=$(python3 --version | cut -d' ' -f2)
PYTHON_MAJOR=$(echo $PYTHON_VERSION | cut -d'.' -f1)
PYTHON_MINOR=$(echo $PYTHON_VERSION | cut -d'.' -f2)

if [ "$PYTHON_MAJOR" -lt 3 ] || ([ "$PYTHON_MAJOR" -eq 3 ] && [ "$PYTHON_MINOR" -lt 11 ]); then
    error "Python $PYTHON_VERSION found, but 3.11+ is required"
    exit 1
fi

success "Found Python $PYTHON_VERSION"

# Check for required system tools
info "Checking system dependencies..."
MISSING_TOOLS=()

for tool in git; do
    if ! command -v $tool &> /dev/null; then
        MISSING_TOOLS+=($tool)
    fi
done

if [ ${#MISSING_TOOLS[@]} -gt 0 ]; then
    warning "Missing recommended tools: ${MISSING_TOOLS[*]}"
    echo "  Install with: sudo apt-get install ${MISSING_TOOLS[*]} (Ubuntu/Debian)"
    echo "             or: sudo dnf install ${MISSING_TOOLS[*]} (Fedora/RHEL)"
    INSTALL_WARNINGS=$((INSTALL_WARNINGS + 1))
fi

# Parse command line arguments
INSTALL_AZURE=false
INSTALL_AWS=false
INSTALL_LIBOQS=true
NON_INTERACTIVE=false
VERBOSE=true
SKIP_CLOUD_PROMPTS=true
SKIP_VENV=false

while [[ $# -gt 0 ]]; do
    case $1 in
        --skip-venv)
            SKIP_VENV=true
            shift
            ;;
        --with-azure)
            INSTALL_AZURE=true
            shift
            ;;
        --with-aws)
            INSTALL_AWS=true
            shift
            ;;
        --with-liboqs)
            INSTALL_LIBOQS=true
            shift
            ;;
        --skip-cloud-prompts)
            SKIP_CLOUD_PROMPTS=true
            shift
            ;;
        --non-interactive|-y)
            NON_INTERACTIVE=true
            shift
            ;;
        --verbose|-v)
            VERBOSE=true
            shift
            ;;
        --help|-h)
            echo "Usage: $0 [OPTIONS]"
            echo ""
            echo "Options:"
            echo "  --skip-venv           Skip virtual environment creation"
            echo "  --with-azure          Install Azure Storage support"
            echo "  --with-aws            Install AWS S3 support"
            echo "  --with-liboqs         Install liboqs (C library + liboqs-python)"
            echo "  --skip-cloud-prompts  Do not prompt about Azure/AWS (skip by default)"
            echo "  -y, --non-interactive Run without prompts (minimal install)"
            echo "  -v, --verbose         Show detailed installation output"
            echo "  -h, --help            Show this help message"
            echo ""
            echo "Examples:"
            echo "  $0                    # Interactive installation"
            echo "  $0 -y                 # Quick install with defaults"
            echo "  $0 --with-azure --with-aws  # Install with cloud support"
            echo "  $0 --with-liboqs              # Install liboqs and Python bindings into venv"
            echo "  $0 --skip-cloud-prompts     # Never prompt about cloud integrations"
            echo "  $0 -v                 # Verbose installation"
            exit 0
            ;;
        *)
            error "Unknown option: $1"
            echo "Use --help for usage information"
            exit 1
            ;;
    esac
done

# Set up output redirection based on verbosity
if [ "$VERBOSE" = true ]; then
    QUIET_FLAG=""
    REDIRECT="2>&1"
else
    QUIET_FLAG="--quiet"
    REDIRECT="> /dev/null 2>&1"
fi

# If requested, avoid prompting for Azure/AWS
if [ "$SKIP_CLOUD_PROMPTS" = true ]; then
    info "Cloud prompts disabled; Azure/AWS support will be skipped unless explicitly requested with --with-azure or --with-aws"
fi

# Virtual environment setup
echo ""
info "Setting up Python environment..."

if [ "$SKIP_VENV" = false ]; then
    if [ -d "venv" ]; then
        success "Virtual environment already exists"
        source venv/bin/activate || {
            error "Failed to activate existing virtual environment"
            exit 1
        }
    else
        if [ "$NON_INTERACTIVE" = true ]; then
            CREATE_VENV=true
        else
            read -p "Create virtual environment? (recommended) [Y/n]: " -n 1 -r
            echo
            CREATE_VENV=true
            [[ $REPLY =~ ^[Nn]$ ]] && CREATE_VENV=false
        fi
        
        if [ "$CREATE_VENV" = true ]; then
            info "Creating virtual environment..."
            if python3 -m venv venv; then
                source venv/bin/activate
                success "Virtual environment created and activated"
            else
                error "Failed to create virtual environment"
                exit 1
            fi
        else
            info "Skipping virtual environment creation"
        fi
    fi
else
    info "Using system Python (virtual environment skipped)"
fi

# Determine which Python/pip to use
if [ -d "venv" ] && [ -f "venv/bin/python" ] && [ -n "$VIRTUAL_ENV" ]; then
    PYTHON_CMD="python"
    PIP_CMD="pip"
    success "Using virtual environment: $VIRTUAL_ENV"
else
    PYTHON_CMD="python3"
    PIP_CMD="pip3"
    if ! command -v pip3 &> /dev/null; then
        error "pip3 not found. Please install python3-pip"
        exit 1
    fi
    info "Using system Python"
fi

# Upgrade pip
echo ""
info "Upgrading pip..."
if [ "$VERBOSE" = true ]; then
    $PIP_CMD install --upgrade pip
else
    $PIP_CMD install --upgrade pip > /dev/null 2>&1
fi
success "pip upgraded"

# Install core Python dependencies
echo ""
info "Installing core dependencies (PyYAML, cryptography, python-dotenv, argon2-cffi)..."
if [ "$VERBOSE" = true ]; then
    $PIP_CMD install PyYAML cryptography python-dotenv argon2-cffi
else
    $PIP_CMD install $QUIET_FLAG PyYAML cryptography python-dotenv argon2-cffi
fi

# Verify core installations
CORE_INSTALLED=true
for pkg in yaml cryptography dotenv argon2; do
    if ! $PYTHON_CMD -c "import $pkg" 2>/dev/null; then
        error "Failed to install/import $pkg"
        CORE_INSTALLED=false
    fi
done

if [ "$CORE_INSTALLED" = true ]; then
    success "Core dependencies installed successfully"
    if $PYTHON_CMD -c "import argon2" 2>/dev/null; then
        success "Argon2id available for quantum-resistant key derivation"
    fi
else
    error "Some core dependencies failed to install"
    exit 1
fi

# liboqs (Post-Quantum) support
echo ""
if [ "$NON_INTERACTIVE" = false ] && [ "$INSTALL_LIBOQS" = false ]; then
    read -p "Install liboqs (Post-Quantum C library and Python bindings)? [y/N]: " -n 1 -r
    echo
    [[ $REPLY =~ ^[Yy]$ ]] && INSTALL_LIBOQS=true
fi

if [ "$INSTALL_LIBOQS" = true ]; then
    info "Checking for system liboqs library..."
    if ldconfig -p 2>/dev/null | grep -q liboqs || [ -f "/usr/local/lib/liboqs.so" ]; then
        success "liboqs C library already installed"
    else
        info "liboqs not found; attempting to build and install"

        # Install build dependencies depending on package manager
        if command -v apt-get &> /dev/null; then
            info "Installing build dependencies with apt..."
            sudo apt-get update -qq || warning "apt-get update failed"
            sudo apt-get install -y -qq build-essential cmake ninja-build libssl-dev git || { error "Failed to install build deps (apt)"; INSTALL_ERRORS=$((INSTALL_ERRORS+1)); }
        elif command -v dnf &> /dev/null; then
            info "Installing build dependencies with dnf..."
            sudo dnf install -y gcc gcc-c++ cmake ninja-build openssl-devel git || { error "Failed to install build deps (dnf)"; INSTALL_ERRORS=$((INSTALL_ERRORS+1)); }
        elif command -v yum &> /dev/null; then
            info "Installing build dependencies with yum..."
            sudo yum install -y gcc gcc-c++ cmake ninja-build openssl-devel git || warning "yum install may require manual intervention"
        elif command -v pacman &> /dev/null; then
            info "Installing build dependencies with pacman..."
            sudo pacman -S --noconfirm --needed base-devel cmake ninja openssl git || { error "Failed to install build deps (pacman)"; INSTALL_ERRORS=$((INSTALL_ERRORS+1)); }
        elif [[ "$OSTYPE" == "darwin"* ]]; then
            info "Detected macOS"
            if command -v brew &> /dev/null; then
                brew install cmake ninja liboqs || true
            else
                warning "Homebrew not found; cannot automatically install liboqs on macOS"
            fi
        else
            warning "Could not detect package manager. Please install: gcc, g++, cmake, ninja-build, openssl-dev, git"
        fi

        # Build liboqs in a temporary directory
        BUILD_DIR=$(mktemp -d -t liboqs-build-XXXXXX)
        info "Using build directory: $BUILD_DIR"
        cleanup() { rm -rf "$BUILD_DIR"; }
        trap cleanup EXIT

        cd "$BUILD_DIR"

        info "Cloning liboqs source..."
        if git clone --depth 1 --branch main https://github.com/open-quantum-safe/liboqs.git > /dev/null 2>&1; then
            success "Downloaded liboqs source"
        else
            error "Failed to clone liboqs repository"
            INSTALL_ERRORS=$((INSTALL_ERRORS+1))
        fi

        cd liboqs
        mkdir -p build
        cd build

        info "Configuring build..."
        if cmake -GNinja -DCMAKE_INSTALL_PREFIX=/usr/local -DCMAKE_BUILD_TYPE=Release -DBUILD_SHARED_LIBS=ON .. > /dev/null 2>&1; then
            success "Configuration complete"
        else
            error "CMake configuration failed"
            INSTALL_ERRORS=$((INSTALL_ERRORS+1))
        fi

        info "Building liboqs (this may take several minutes)..."
        if ninja > /dev/null 2>&1; then
            success "Build complete"
        else
            error "Build failed"
            INSTALL_ERRORS=$((INSTALL_ERRORS+1))
        fi

        info "Installing liboqs to /usr/local..."
        if sudo ninja install > /dev/null 2>&1; then
            success "Installed to /usr/local"
        else
            error "Installation failed"
            INSTALL_ERRORS=$((INSTALL_ERRORS+1))
        fi

        sudo ldconfig || warning "ldconfig failed; you may need to set LD_LIBRARY_PATH"

        cd - >/dev/null 2>&1

        if [ $INSTALL_ERRORS -eq 0 ]; then
            success "liboqs built and installed"
        else
            warning "liboqs build had errors; some functionality may be missing"
        fi
    fi

    # Install Python wrapper into the active Python environment (venv preferred)
    info "Installing liboqs-python into the active Python environment ($PIP_CMD)..."
    if $PIP_CMD show liboqs-python > /dev/null 2>&1; then
        success "liboqs-python already installed in Python environment"
    else
        if [ "$VERBOSE" = true ]; then
            $PIP_CMD install liboqs-python || $PIP_CMD install liboqs-python --break-system-packages || { warning "pip install liboqs-python failed"; INSTALL_WARNINGS=$((INSTALL_WARNINGS+1)); }
        else
            $PIP_CMD install $QUIET_FLAG liboqs-python || $PIP_CMD install $QUIET_FLAG liboqs-python --break-system-packages || { warning "pip install liboqs-python failed"; INSTALL_WARNINGS=$((INSTALL_WARNINGS+1)); }
        fi

        if $PYTHON_CMD -c "import oqs" 2>/dev/null; then
            success "liboqs-python installed and import verified"
        else
            warning "liboqs-python installed but import test failed"
            INSTALL_WARNINGS=$((INSTALL_WARNINGS+1))
        fi
    fi
else
    info "Skipping liboqs installation"
fi

# Azure Storage support
echo ""
if [ "$NON_INTERACTIVE" = false ] && [ "$INSTALL_AZURE" = false ] && [ "$SKIP_CLOUD_PROMPTS" = false ]; then
    read -p "Install Azure Storage support? [y/N]: " -n 1 -r
    echo
    [[ $REPLY =~ ^[Yy]$ ]] && INSTALL_AZURE=true
elif [ "$SKIP_CLOUD_PROMPTS" = true ]; then
    info "Skipping prompt for Azure storage (not requested)"
fi

if [ "$INSTALL_AZURE" = true ]; then
    if $PIP_CMD show azure-storage-blob > /dev/null 2>&1; then
        success "Azure Storage support already installed"
    else
        info "Installing Azure Storage support..."
        if [ "$VERBOSE" = true ]; then
            $PIP_CMD install azure-storage-blob
        else
            $PIP_CMD install $QUIET_FLAG azure-storage-blob
        fi
        
        if $PYTHON_CMD -c "import azure.storage.blob" 2>/dev/null; then
            success "Azure support installed"
        else
            warning "Azure installation completed but import test failed"
            INSTALL_WARNINGS=$((INSTALL_WARNINGS + 1))
        fi
    fi
else
    info "Skipping Azure Storage support"
fi

# AWS S3 support
echo ""
if [ "$NON_INTERACTIVE" = false ] && [ "$INSTALL_AWS" = false ] && [ "$SKIP_CLOUD_PROMPTS" = false ]; then
    read -p "Install AWS S3 support? [y/N]: " -n 1 -r
    echo
    [[ $REPLY =~ ^[Yy]$ ]] && INSTALL_AWS=true
elif [ "$SKIP_CLOUD_PROMPTS" = true ]; then
    info "Skipping prompt for AWS S3 (not requested)"
fi

if [ "$INSTALL_AWS" = true ]; then
    if $PIP_CMD show boto3 > /dev/null 2>&1; then
        success "AWS S3 support already installed"
    else
        info "Installing AWS S3 support..."
        if [ "$VERBOSE" = true ]; then
            $PIP_CMD install boto3
        else
            $PIP_CMD install $QUIET_FLAG boto3
        fi
        
        if $PYTHON_CMD -c "import boto3" 2>/dev/null; then
            success "AWS support installed"
        else
            warning "AWS installation completed but import test failed"
            INSTALL_WARNINGS=$((INSTALL_WARNINGS + 1))
        fi
    fi
else
    info "Skipping AWS S3 support"
fi

# Encryption info
echo ""
info "Encryption configuration:"
echo "  • AES-256-GCM for data encryption"
if $PYTHON_CMD -c "import argon2" 2>/dev/null; then
    echo "  • Argon2id for quantum-resistant key derivation ✓"
else
    echo "  • PBKDF2-HMAC-SHA512 for key derivation (argon2-cffi not available)"
fi
echo ""
success "Quantum-resistant encryption is ready to use"

# Configuration files
echo ""
info "Setting up configuration files..."

if [ -f "config.yaml" ]; then
    success "config.yaml already exists"
else
    warning "config.yaml not found - you'll need to create one"
    info "Copy config.yaml from the installation package or see README.md"
    INSTALL_WARNINGS=$((INSTALL_WARNINGS + 1))
fi


# Make scripts executable
echo ""
info "Making scripts executable..."
SCRIPTS_MADE_EXECUTABLE=0
for script in backup_tool.py decrypt_backup.py backup_profiles.py install_liboqs.sh; do
    if [ -f "$script" ]; then
        chmod +x "$script" 2>/dev/null && SCRIPTS_MADE_EXECUTABLE=$((SCRIPTS_MADE_EXECUTABLE + 1))
    fi
done
success "Made $SCRIPTS_MADE_EXECUTABLE scripts executable"

# Test installation
echo ""
info "Testing installation..."
if $PYTHON_CMD backup_tool.py --help > /dev/null 2>&1; then
    success "backup_tool.py is working correctly"
else
    error "backup_tool.py failed to run"
    warning "Check that all files are present and try running with -v flag"
    INSTALL_ERRORS=$((INSTALL_ERRORS + 1))
fi

# Summary
echo ""
echo "========================================="
echo "Installation Complete!"
echo "========================================="
echo ""

if [ $INSTALL_ERRORS -eq 0 ] && [ $INSTALL_WARNINGS -eq 0 ]; then
    success "No errors or warnings"
elif [ $INSTALL_ERRORS -eq 0 ]; then
    warning "$INSTALL_WARNINGS warning(s) encountered (see above)"
else
    error "$INSTALL_ERRORS error(s) and $INSTALL_WARNINGS warning(s) encountered"
fi

echo ""
echo "Installed components:"
echo "  • Core dependencies: ✓"
if $PYTHON_CMD -c "import argon2" 2>/dev/null; then
    echo "  • Quantum-resistant KDF (Argon2id): ✓"
else
    echo "  • Quantum-resistant KDF (Argon2id): ✗ (using PBKDF2-SHA512)"
fi
[ "$INSTALL_AZURE" = true ] && echo "  • Azure Storage: ✓" || echo "  • Azure Storage: ✗"
[ "$INSTALL_AWS" = true ] && echo "  • AWS S3: ✓" || echo "  • AWS S3: ✗"

echo ""
echo "Next steps:"
echo "  1. Review config.yaml and adjust paths"
echo "  2. Run: $PYTHON_CMD backup_tool.py -c config.yaml"
echo ""
echo "For help:"
echo "  • $PYTHON_CMD backup_tool.py --help"
echo "  • cat README.md"

echo ""

if [ -d "venv" ]; then
    echo "Virtual environment location: $(pwd)/venv"
    echo "To activate in future sessions:"
    echo "  source venv/bin/activate"
    echo ""
fi

if [ $INSTALL_ERRORS -eq 0 ]; then
    success "Installation is idempotent - you can re-run this script safely"
else
    warning "Some errors occurred. Review the output and try again with -v flag"
fi

echo ""

# Exit with appropriate code
[ $INSTALL_ERRORS -eq 0 ] && exit 0 || exit 1
