#!/usr/bin/env bash

set -Eeuo pipefail

# Configuration

REPO_URL="https://github.com/DamascusSmith/home-manager.git"
REPO_DIR="${HOME}/nix-home"
HM_PROFILE="wikkenden-home"

log() {
    printf '\n\033[1;34m==>\033[0m %s\n' "$*"
}

die() {
    printf '\n\033[1;31mError:\033[0m %s\n' "$*" >&2
    exit 1
}

command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Safety checks

if [[ "${EUID}" -eq 0 ]]; then
    die "Run this script as your normal user, not as root."
fi

if [[ "$(uname -s)" != "Linux" ]]; then
    die "This installer currently supports Linux only."
fi

# Install bootstrap dependencies

install_bootstrap_dependencies() {
    if command_exists git && command_exists curl; then
        log "Git and curl are already installed"
        return
    fi

    log "Installing Git and curl"

    if command_exists apt-get; then
        sudo apt-get update
        sudo apt-get install -y git curl

    elif command_exists dnf; then
        sudo dnf install -y git curl

    elif command_exists pacman; then
        sudo pacman -Sy --needed --noconfirm git curl

    elif command_exists zypper; then
        sudo zypper install -y git curl

    else
        die "Unsupported package manager. Install Git and curl manually."
    fi
}

# Install Nix

install_nix() {
    local nix_profile
    nix_profile="/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh"

    # Nix may already be installed but not loaded in this shell.
    if ! command_exists nix && [[ -r "$nix_profile" ]]; then
        # shellcheck disable=SC1090
        . "$nix_profile"
    fi

    if command_exists nix; then
        log "Nix is already installed"
        return
    fi

    log "Installing Determinate Nix"

    curl \
        --proto '=https' \
        --tlsv1.2 \
        -sSf \
        -L https://install.determinate.systems/nix |
        sh -s -- install

    if [[ -r "$nix_profile" ]]; then
        # Make Nix available to the remainder of this running script.
        # shellcheck disable=SC1090
        . "$nix_profile"
    fi

    if ! command_exists nix; then
        die "Nix was installed, but it is not available in this shell. Open a new terminal and rerun the installer."
    fi

    if ! nix flake --help >/dev/null 2>&1; then
        die "Nix is installed, but flake support is unavailable."
    fi
}

# Get Home Manager repository

get_repo() {
    if [[ -d "${REPO_DIR}/.git" ]]; then
        log "Home Manager repository already exists"

        if [[ -n "$(git -C "${REPO_DIR}" status --porcelain)" ]]; then
            log "Repository has local changes; not pulling automatically"
            return
        fi

        log "Updating repository"
        git -C "${REPO_DIR}" pull --ff-only

    elif [[ -e "${REPO_DIR}" ]]; then
        die "${REPO_DIR} exists but is not a Git repository."

    else
        log "Cloning Home Manager repository"
        git clone "${REPO_URL}" "${REPO_DIR}"
    fi
}

# Build and activate Home Manager

activate_home_manager() {
    local activation_package

    log "Building Home Manager profile: ${HM_PROFILE}"

    # Build the exact Home Manager version pinned by the flake.
    # --no-link avoids creating a result symlink inside the repository.
    activation_package="$(
        nix build \
						--impure \
            "${REPO_DIR}#homeConfigurations.${HM_PROFILE}.activationPackage" \
            --no-link \
            --print-out-paths
    )"

    if [[ ! -x "${activation_package}/activate" ]]; then
        die "The Home Manager activation script was not produced."
    fi

    log "Activating Home Manager configuration"
		HOME_MANAGER_BACKUP_EXT=backup \
		HOME_MANAGER_BACKUP_OVERWRITE=1 \
		env -u LD_PRELOAD \
		"${activation_package}/activate"
}

install_bootstrap_dependencies
install_nix
get_repo
activate_home_manager

log "Installation complete"

printf '\nRepository: %s\nProfile:    %s\n' "${REPO_DIR}" "${HM_PROFILE}"
