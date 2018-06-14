#!/usr/bin/env bash

set -o errexit  # exit script if a command fails
set -o nounset  # exit when script uses undeclared vars
set -o pipefail
#set -o xtrace


action="install"
install_dir="$HOME/.vstest"
install_version=""
verbosity=0

function _log() {
    printf "%s\\n" "$*"
}

function _log_debug() {
    if [[ $verbosity == 1 ]]; then
        printf "DEBUG: %s\\n" "$*" 1>&2
    fi
}

function _log_error() {
    printf "%s\\n" "$*" 1>&2
}


function verify_dependencies() {
    _log_debug "Verify dependencies"
    depends=(curl cp grep mktemp unzip)
    
    for tool in "${depends[@]}"; do
        if ! [ -x "$(command -v "$tool")" ]; then
            _log_error "Required command '${tool}' is not available."
            return 1
        fi
    done
}

function install_vstest() {
    _log_debug "Installing vstest"

    url="https://www.nuget.org/api/v2/package/Microsoft.TestPlatform.Portable"
    tmpdir=$(mktemp -d 2> /dev/null || mktemp -d -t 'vstest')
    nupkg=$tmpdir/Microsoft.TestPlatform.Portable.nupkg

    if ! [ -d "$install_dir" ]; then
        _log "Installation directory '$install_dir' does not exist. We'll create it."
        mkdir "$install_dir"
        _log_debug "Created install directory at '$install_dir'"
    fi

    if ! [ -z $install_version ]; then
        _log_debug "Version is not supported yet. We'll download latest."
    fi

    _log "Downloading package to '$tmpdir'..."
    curl --fail --location --silent --show-error --output "$nupkg" "$url"

    _log_debug "Extracting nuget package in '$tmpdir'..."
    unzip -oq "$nupkg" -d "$tmpdir"

    _log "Installing test runner to '$install_dir'..."
    cp -r "$tmpdir/tools/." "$install_dir"

    _log "Installation complete"
}

function list_vstest_versions() {
    _log_debug "available vstest versions"

    info_url="https://api.nuget.org/v3-flatcontainer/Microsoft.TestPlatform.Portable/index.json"
    _log "Available vstest versions:"
    curl --silent $info_url --stderr - | grep -o -P "^.*\"\\d.*\""
}

function show_usage() {
    printf "Usage: install.sh [OPTION]... [DIRECTORY]\\n"
    printf "Install vstest runner to DIRECTORY (installs to ~/.vstest by default).\\n"
    printf "\\n"
    printf "Available options:\\n"
    printf "  -v, --version         fetch the specified version of vstest runner\\n"
    printf "  -l, --list            list available versions of vstest runner\\n"
    printf "      --help            display this help and exit\\n"
    printf "\\n"
    printf "Full documentation at <https://spekt.github.io/vstest-get>.\\n"
    printf "Please report any issues at <https://github.com/spekt/vstest-get/issues>.\\n"
}

function do_action() {
    case "$1" in
        install)
            install_vstest
            ;;
        list)
            list_vstest_versions
            ;;
        help)
            show_usage
            ;;
    esac
}


while [[ $# -ne 0 ]]; do
    case "$1" in
        -l|--list)
            shift
            action="list"
            ;;
        -v|--version)
            install_version=$2
            shift
            shift
            ;;
        --help)
            shift
            action="help"
            ;;
        *)
            if [[ "$1" == -* ]]; then
                _log_error "install.sh: invalid option '$1'"
                printf "Try 'install.sh --help' for more information."
                action="error"
            else
                install_dir=$1
                action="install"
            fi
            break
    esac
done


verify_dependencies && do_action $action
